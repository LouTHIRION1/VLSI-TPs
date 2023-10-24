library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity EXec is
  port
  (
    -- Decode interface synchronization
    dec2exe_empty : in std_logic  := '0'; -- '1' when DEC FIFO is empty
    exe_pop       : out std_logic := '0'; -- Gere la FIFO de décode

    -- Decode interface operands
    dec_op1      : in std_logic_vector(31 downto 0) := x"0000_0000"; -- first ALU input (Op1)
    dec_op2      : in std_logic_vector(31 downto 0) := x"0000_0000"; -- shifter input (into Op2)
    dec_exe_dest : in std_logic_vector(3 downto 0)  := "0000";       -- Rd destination {!}
    dec_exe_wb   : in std_logic                     := '0';          -- Rd destination write back {!}
    dec_flag_wb  : in std_logic                     := '0';          -- CSPR modifiy {S}

    -- Decode to mem interface 
    dec_mem_data  : in std_logic_vector(31 downto 0) := x"0000_0000"; -- data to MEM W
    dec_mem_dest  : in std_logic_vector(3 downto 0)  := "0000";       -- Destination MEM R
    dec_pre_index : in std_logic                     := '0';

    dec_mem_lw : in std_logic := '0'; -- Load Word
    dec_mem_lb : in std_logic := '0'; -- Load Byte
    dec_mem_sw : in std_logic := '0'; -- Store Word
    dec_mem_sb : in std_logic := '0'; -- Store Byte

    ---- Shifter
    dec_shift_lsl : in std_logic                    := '0';
    dec_shift_lsr : in std_logic                    := '0';
    dec_shift_asr : in std_logic                    := '0';
    dec_shift_ror : in std_logic                    := '0';
    dec_shift_rrx : in std_logic                    := '0';
    dec_shift_val : in std_logic_vector(4 downto 0) := "00000";
    dec_cy        : in std_logic                    := '0';

    ---- ALU
    dec_comp_op1 : in std_logic                    := '0';  -- MUX Operand 1
    dec_comp_op2 : in std_logic                    := '0';  -- MUX Operand 2
    dec_alu_cy   : in std_logic                    := '0';  -- ALU Cin
    dec_alu_cmd  : in std_logic_vector(1 downto 0) := "00"; -- ALU command

    ---- EXE bypass to DECOD
    exe_res : out std_logic_vector(31 downto 0) := x"0000_0000";

    -- Flags
    exe_c : out std_logic := '0';
    exe_v : out std_logic := '0';
    exe_n : out std_logic := '0';
    exe_z : out std_logic := '0';

    exe_dest    : out std_logic_vector(3 downto 0) := "0000"; -- Rd destination
    exe_wb      : out std_logic                    := '0';    -- Rd destination write back
    exe_flag_wb : out std_logic                    := '0';    -- CSPR modifiy

    -- Mem interface
    exe_mem_adr  : out std_logic_vector(31 downto 0) := x"0000_0000"; -- Alu res register
    exe_mem_data : out std_logic_vector(31 downto 0) := x"0000_0000";
    exe_mem_dest : out std_logic_vector(3 downto 0)  := "0000";

    exe_mem_lw : out std_logic := '0';
    exe_mem_lb : out std_logic := '0';
    exe_mem_sw : out std_logic := '0';
    exe_mem_sb : out std_logic := '0';

    exe2mem_empty : out std_logic := '0';
    mem_pop       : in std_logic  := '0';

    -- global interface
    clk     : in std_logic := '0';
    reset_n : in std_logic := '0';
    vdd     : in bit       := '0';
    vss     : in bit       := '0');

  -- Probe
  -- probe : out std_logic_vector(31 downto 0));
end EXec;

----------------------------------------------------------------------

architecture behavioral_exec of EXec is
  -- COMPONENT DECLARATIONS

  component Shifter
    port
    (
      -- Type of instruction
      shift_lsl : in std_logic := '0'; -- Logic Shift Left
      shift_lsr : in std_logic := '0'; -- Logic Shift Right
      shift_asr : in std_logic := '0'; -- Arithmetic Shift Right
      shift_ror : in std_logic := '0'; -- ROtate Right
      shift_rrx : in std_logic := '0'; -- Rotate Right eXtended
      -- Inputs
      shift_val : in std_logic_vector(4 downto 0);  -- Shift Value (2^5 = 32 possible places)
      din       : in std_logic_vector(31 downto 0); -- Data in
      cin       : in std_logic := '0';              -- Carry in
      -- Outputs
      dout : out std_logic_vector(31 downto 0); -- Data out
      cout : out std_logic := '0';              -- Carry out
      -- Global interface
      vdd : in bit;
      vss : in bit);
  end component;

  component Alu
    port
    (
      op1 : in std_logic_vector(31 downto 0);
      op2 : in std_logic_vector(31 downto 0);
      cin : in std_logic;

      cmd : in std_logic_vector(1 downto 0);

      res  : out std_logic_vector(31 downto 0);
      cout : out std_logic;
      z    : out std_logic;
      n    : out std_logic;
      v    : out std_logic;

      vdd : in bit;
      vss : in bit);
  end component;

  component fifo_72b
    port
    (
      din  : in std_logic_vector(71 downto 0);
      dout : out std_logic_vector(71 downto 0);

      -- commands
      push : in std_logic;
      pop  : in std_logic;

      -- flags
      full  : out std_logic;
      empty : out std_logic;

      reset_n : in std_logic;
      clk     : in std_logic;
      vdd     : in bit;
      vss     : in bit
    );
  end component;

  component mux2to1
    port
    (
      a   : in std_logic_vector(31 downto 0);
      b   : in std_logic_vector(31 downto 0);
      cmd : in std_logic;
      s   : out std_logic_vector(31 downto 0)
    );
  end component;

  -- SIGNAL DECLARATIONS

  signal shift_c, shift_c_wb                  : std_logic;
  signal alu_c, alu_c_wb, alu_n, alu_z, alu_v : std_logic;

  signal op2       : std_logic_vector(31 downto 0);
  signal op2_shift : std_logic_vector(31 downto 0);
  signal op1       : std_logic_vector(31 downto 0);
  signal alu_res   : std_logic_vector(31 downto 0);
  signal res_reg   : std_logic_vector(31 downto 0);
  signal mem_adr   : std_logic_vector(31 downto 0);

  signal mux_op1_s : std_logic_vector(31 downto 0);
  signal mux_op2_s : std_logic_vector(31 downto 0);

  signal exe_push     : std_logic;
  signal exe2mem_full : std_logic;
  signal mem_acces    : std_logic;

begin

  --  Component instantiation

  shifter_inst : Shifter
  port map
  (
    -- Type of instruction
    shift_lsl => dec_shift_lsl,
    shift_lsr => dec_shift_lsr,
    shift_asr => dec_shift_asr,
    shift_ror => dec_shift_ror,
    shift_rrx => dec_shift_rrx,
    -- Inputs
    shift_val => dec_shift_val,
    din       => dec_op2,
    cin       => dec_cy,
    -- Outputs
    dout => op2_shift,
    cout => shift_c, -- TODO: Verify it's correct (c flag?)
    -- Global interface
    vdd => vdd,
    vss => vss
  );

  alu_inst : Alu
  port
  map
  (
  -- Operandes + Carry in
  op1 => mux_op1_s,
  op2 => mux_op2_s,
  cin => dec_alu_cy,
  -- Commande pour le mux interne
  cmd => dec_alu_cmd,
  -- Resultat + Carry out
  res  => alu_res,
  cout => alu_c,
  -- Flags
  z => alu_z,
  n => alu_n,
  v => alu_v,
  -- Global interface
  vdd => vdd,
  vss => vss
  );

  exec2mem : fifo_72b
  port
  map
  (
  -- Inputs
  din(71) => dec_mem_lw,
  din(70) => dec_mem_lb,
  din(69) => dec_mem_sw,
  din(68) => dec_mem_sb,

  din(67 downto 64) => dec_mem_dest,
  din(63 downto 32) => dec_mem_data,
  din(31 downto 0)  => mem_adr,

  -- Outputs
  dout(71) => exe_mem_lw,
  dout(70) => exe_mem_lb,
  dout(69) => exe_mem_sw,
  dout(68) => exe_mem_sb,

  dout(67 downto 64) => exe_mem_dest,
  dout(63 downto 32) => exe_mem_data,
  dout(31 downto 0)  => exe_mem_adr,

  push => exe_push,
  pop  => mem_pop,

  empty => exe2mem_empty,
  full  => exe2mem_full,

  reset_n => reset_n,
  clk     => clk,
  vdd     => vdd,
  vss     => vss
  );

  -- MUX Operand 1
  mux_op1_s <= dec_op1 when (dec_comp_op1 = '0') else
    (not(dec_op1));

  -- MUX Operand 2
  mux_op2_s <= op2_shift when (dec_comp_op2 = '0') else
    (not(op2_shift));

  -- MUX ALU
  mem_adr <= alu_res when (dec_pre_index = '0') else
    (dec_op1);

  -- Writeback (wb) of the ALU result
  exe_res <= alu_res when (dec_exe_wb = '1') else
    (others => '0');
  exe_dest <= dec_exe_dest when(dec_exe_wb = '1') else
    (others => '0');

  -- Writeback for flags CVZN
  exe_z <= alu_z when dec_flag_wb = '1' else
    '0';
  exe_n <= alu_n when dec_flag_wb = '1' else
    '0';
  exe_v <= alu_v when dec_flag_wb = '1' else
    '0';
  alu_c_wb <= alu_c when dec_flag_wb = '1' else
    '0';
  shift_c_wb <= shift_c when dec_flag_wb = '1' else
    '0';

  -- Carry out (cout) depends if it's a logic (shifter) or arithmetic (alu) instruction
  exe_c <= alu_c when (dec_alu_cmd = "00") else
    shift_c;

  -- Loop dec

  -- MUX pre/post index
  mem_adr <= alu_res;

  exe_pop <= '1' when dec2exe_empty = '0' else
    '0'; -- Only allow pop when the FIFO is not empty

  exe_push <= '1' when exe2mem_full = '0' else
    '0'; -- Only allow push when the FIFO is not full

  -- probe <= alu_res; -- Probe used for simulation purposes

end behavioral_exec;