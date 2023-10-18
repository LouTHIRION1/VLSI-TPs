library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity EXec is
  port
  (
    -- Decode interface synchro
    dec2exe_empty : in std_logic;
    exe_pop       : out std_logic;

    -- Decode interface operands
    dec_op1      : in std_logic_vector(31 downto 0); -- first alu input
    dec_op2      : in std_logic_vector(31 downto 0); -- shifter input
    dec_exe_dest : in std_logic_vector(3 downto 0);  -- Rd destination
    dec_exe_wb   : in std_logic;                     -- Rd destination write back
    dec_flag_wb  : in std_logic;                     -- CSPR modifiy

    -- Decode to mem interface 
    dec_mem_data  : in std_logic_vector(31 downto 0); -- data to MEM W
    dec_mem_dest  : in std_logic_vector(3 downto 0);  -- Destination MEM R
    dec_pre_index : in std_logic;

    dec_mem_lw : in std_logic;
    dec_mem_lb : in std_logic;
    dec_mem_sw : in std_logic;
    dec_mem_sb : in std_logic;

    -- Shifter command
    dec_shift_lsl : in std_logic;
    dec_shift_lsr : in std_logic;
    dec_shift_asr : in std_logic;
    dec_shift_ror : in std_logic;
    dec_shift_rrx : in std_logic;
    dec_shift_val : in std_logic_vector(4 downto 0);
    dec_cy        : in std_logic;

    -- Alu operand selection
    dec_comp_op1 : in std_logic;
    dec_comp_op2 : in std_logic;
    dec_alu_cy   : in std_logic;

    -- Alu command
    dec_alu_cmd : in std_logic_vector(1 downto 0);

    -- Exe bypass to decod
    exe_res : out std_logic_vector(31 downto 0);

    exe_c : out std_logic;
    exe_v : out std_logic;
    exe_n : out std_logic;
    exe_z : out std_logic;

    exe_dest    : out std_logic_vector(3 downto 0); -- Rd destination
    exe_wb      : out std_logic;                    -- Rd destination write back
    exe_flag_wb : out std_logic;                    -- CSPR modifiy

    -- Mem interface
    exe_mem_adr  : out std_logic_vector(31 downto 0); -- Alu res register
    exe_mem_data : out std_logic_vector(31 downto 0);
    exe_mem_dest : out std_logic_vector(3 downto 0);

    exe_mem_lw : out std_logic;
    exe_mem_lb : out std_logic;
    exe_mem_sw : out std_logic;
    exe_mem_sb : out std_logic;

    exe2mem_empty : out std_logic;
    mem_pop       : in std_logic;

    -- global interface
    ck      : in std_logic;
    reset_n : in std_logic;
    vdd     : in bit;
    vss     : in bit);
end EXec;

----------------------------------------------------------------------

architecture Behavior of EXec is
  -- COMPONENT DECLARATIONS

  component mux2to1
    port
    (
      a   : in std_logic_vector(31 downto 0);
      b   : in std_logic_vector(31 downto 0);
      cmd : in std_logic;
      s   : out std_logic_vector(31 downto 0);
      -- Global interface
      vdd : in bit;
      vss : in bit
    );
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
      ck      : in std_logic;
      vdd     : in bit;
      vss     : in bit
    );
  end component;

  -- SIGNAL DECLARATIONS

begin
  --  Component instantiation.
  -- TODO: Remplace 'x' by their respective signals

  mux_op1 : mux2to1
  port map
  (
    a   => dec_op1,
    b   => not dec_op1,
    cmd => dec_comp_op1,
    s   => mux_op1,
    vdd => vdd,
    vss => vss
  );

  mux_op2 : mux2to1
  port
  map
  (
  a   => dec_op2_shift,
  b   => not dec_op2_shift,
  cmd => dec_comp_op2,
  s   => mux_op2,
  vdd => vdd,
  vss => vss
  );

  mux_res : mux2to1
  port
  map
  (
  a   => exe_res,
  b   => dec_op1,
  cmd => x,
  s   => x,
  vdd => vdd,
  vss => vss
  );

  shifter_inst : Shifter
  port
  map
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
  dout => dec_op2_shift,
  cout => x,
  -- Global interface
  vdd => vdd,
  vss => vss
  );

  alu_inst : Alu
  port
  map
  (
  -- Operandes + Retenue Carry in
  op1 => mux_op1,
  op2 => mux_op2,
  cin => dec_alu_cys,
  -- Commande pour le mux
  cmd => dec_alu_cmd,
  -- Resultat + retenue Carry out
  res  => exe_res,
  cout => exe_c,
  -- Flags
  z => exe_z,
  n => exe_n,
  v => exe_v,
  -- Global interface
  vdd => vdd,
  vss => vss
  );

  exec2mem : fifo_72b
  port
  map
  (
  din(71) => dec_mem_lw,
  din(70) => dec_mem_lb,
  din(69) => dec_mem_sw,
  din(68) => dec_mem_sb,

  din(67 downto 64) => dec_mem_dest,
  din(63 downto 32) => dec_mem_data,
  din(31 downto 0)  => mem_adr,

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
  ck      => ck,
  vdd     => vdd,
  vss     => vss);

  -- TODO: Create MUX component & instantiate it
end Behavior;