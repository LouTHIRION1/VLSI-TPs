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

  component alu
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
      ck      : in std_logic;
      vdd     : in bit;
      vss     : in bit
    );
  end component;

  --  Component instantiation.
  alu_inst : alu
  port map
  (
    vss => vss);

  exec2mem : fifo_72b
  port
  map (din(71) => dec_mem_lw,
  din(70)      => dec_mem_lb,
  din(69)      => dec_mem_sw,
  din(68)      => dec_mem_sb,

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

end Behavior;