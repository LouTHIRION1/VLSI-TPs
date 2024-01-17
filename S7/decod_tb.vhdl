library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity decod_tb is
  --empty
end decod_tb;

architecture testbench of decod_tb is

  component Decod is
    port
    (
      dec_op1       : out std_logic_vector(31 downto 0); -- first alu input
      dec_op2       : out std_logic_vector(31 downto 0); -- shifter input
      dec_exe_dest  : out std_logic_vector(3 downto 0);  -- Rd destination
      dec_exe_wb    : out std_logic;                     -- Rd destination write back
      dec_flag_wb   : out std_logic;                     -- CSPR modifiy
      dec_mem_data  : out std_logic_vector(31 downto 0); -- data to MEM
      dec_mem_dest  : out std_logic_vector(3 downto 0);
      dec_pre_index : out std_logic;
      dec_mem_lw    : out std_logic;
      dec_mem_lb    : out std_logic;
      dec_mem_sw    : out std_logic;
      dec_mem_sb    : out std_logic;
      dec_shift_lsl : out std_logic;
      dec_shift_lsr : out std_logic;
      dec_shift_asr : out std_logic;
      dec_shift_ror : out std_logic;
      dec_shift_rrx : out std_logic;
      dec_shift_val : out std_logic_vector(4 downto 0);
      dec_cy        : out std_logic;
      dec_comp_op1  : out std_logic;
      dec_comp_op2  : out std_logic;
      dec_alu_cy    : out std_logic;
      dec2exe_empty : out std_logic;
      exe_pop       : in std_logic;
      dec_alu_cmd   : out std_logic_vector(1 downto 0);
      exe_res       : in std_logic_vector(31 downto 0);
      exe_c         : in std_logic;
      exe_v         : in std_logic;
      exe_n         : in std_logic;
      exe_z         : in std_logic;
      exe_dest      : in std_logic_vector(3 downto 0); -- Rd destination
      exe_wb        : in std_logic;                    -- Rd destination write back
      exe_flag_wb   : in std_logic;                    -- CSPR modifiy
      dec_pc        : out std_logic_vector(31 downto 0);
      if_ir         : in std_logic_vector(31 downto 0);
      dec2if_empty  : out std_logic;
      if_pop        : in std_logic;
      if2dec_empty  : in std_logic;
      dec_pop       : out std_logic;
      mem_res       : in std_logic_vector(31 downto 0);
      mem_dest      : in std_logic_vector(3 downto 0);
      mem_wb        : in std_logic;
      ck            : in std_logic;
      reset_n       : in std_logic;
      vdd           : in bit;
      vss           : in bit);
  end component;

  signal dec_op1_s       : std_logic_vector(31 downto 0); -- first alu input
  signal dec_op2_s       : std_logic_vector(31 downto 0); -- shifter input
  signal dec_exe_dest_s  : std_logic_vector(3 downto 0);  -- Rd destination
  signal dec_exe_wb_s    : std_logic;                     -- Rd destination write back
  signal dec_flag_wb_s   : std_logic;                     -- CSPR modifiy
  signal dec_mem_data_s  : std_logic_vector(31 downto 0); -- data to MEM
  signal dec_mem_dest_s  : std_logic_vector(3 downto 0);
  signal dec_pre_index_s : std_logic;
  signal dec_mem_lw_s    : std_logic;
  signal dec_mem_lb_s    : std_logic;
  signal dec_mem_sw_s    : std_logic;
  signal dec_mem_sb_s    : std_logic;
  signal dec_shift_lsl_s : std_logic;
  signal dec_shift_lsr_s : std_logic;
  signal dec_shift_asr_s : std_logic;
  signal dec_shift_ror_s : std_logic;
  signal dec_shift_rrx_s : std_logic;
  signal dec_shift_val_s : std_logic_vector(4 downto 0);
  signal dec_cy_s        : std_logic;
  signal dec_comp_op1_s  : std_logic;
  signal dec_comp_op2_s  : std_logic;
  signal dec_alu_cy_s    : std_logic;
  signal dec2exe_empty_s : std_logic;
  signal exe_pop_s       : std_logic;
  signal dec_alu_cmd_s   : std_logic_vector(1 downto 0);
  signal exe_res_s       : std_logic_vector(31 downto 0);
  signal exe_c_s         : std_logic;
  signal exe_v_s         : std_logic;
  signal exe_n_s         : std_logic;
  signal exe_z_s         : std_logic;
  signal exe_dest_s      : std_logic_vector(3 downto 0); -- Rd destination
  signal exe_wb_s        : std_logic;                    -- Rd destination write back
  signal exe_flag_wb_s   : std_logic;                    -- CSPR modifiy
  signal dec_pc_s        : std_logic_vector(31 downto 0);
  signal if_ir_s         : std_logic_vector(31 downto 0);
  signal dec2if_empty_s  : std_logic;
  signal if_pop_s        : std_logic;
  signal if2dec_empty_s  : std_logic;
  signal dec_pop_s       : std_logic;
  signal mem_res_s       : std_logic_vector(31 downto 0);
  signal mem_dest_s      : std_logic_vector(3 downto 0);
  signal mem_wb_s        : std_logic;
  signal ck_s            : std_logic;
  signal reset_n_s       : std_logic;
  signal vdd_s           : bit;
  signal vss_s           : bit;

  -- Clock period definitions
  constant clk_period : time := 1 ns;

begin

  DUT : Decod
  port map
  (
    dec_op1       => dec_op1_s,
    dec_op2       => dec_op2_s,
    dec_exe_dest  => dec_exe_dest_s,
    dec_exe_wb    => dec_exe_wb_s,
    dec_flag_wb   => dec_flag_wb_s,
    dec_mem_data  => dec_mem_data_s,
    dec_mem_dest  => dec_mem_dest_s,
    dec_pre_index => dec_pre_index_s,
    dec_mem_lw    => dec_mem_lw_s,
    dec_mem_lb    => dec_mem_lb_s,
    dec_mem_sw    => dec_mem_sw_s,
    dec_mem_sb    => dec_mem_sb_s,
    dec_shift_lsl => dec_shift_lsl_s,
    dec_shift_lsr => dec_shift_lsr_s,
    dec_shift_asr => dec_shift_asr_s,
    dec_shift_ror => dec_shift_ror_s,
    dec_shift_rrx => dec_shift_rrx_s,
    dec_shift_val => dec_shift_val_s,
    dec_cy        => dec_cy_s,
    dec_comp_op1  => dec_comp_op1_s,
    dec_comp_op2  => dec_comp_op2_s,
    dec_alu_cy    => dec_alu_cy_s,
    dec2exe_empty => dec2exe_empty_s,
    exe_pop       => exe_pop_s,
    dec_alu_cmd   => dec_alu_cmd_s,
    exe_res       => exe_res_s,
    exe_c         => exe_c_s,
    exe_v         => exe_v_s,
    exe_n         => exe_n_s,
    exe_z         => exe_z_s,
    exe_dest      => exe_dest_s,
    exe_wb        => exe_wb_s,
    exe_flag_wb   => exe_flag_wb_s,
    dec_pc        => dec_pc_s,
    if_ir         => if_ir_s,
    dec2if_empty  => dec2if_empty_s,
    if_pop        => if_pop_s,
    if2dec_empty  => if2dec_empty_s,
    dec_pop       => dec_pop_s,
    mem_res       => mem_res_s,
    mem_dest      => mem_dest_s,
    mem_wb        => mem_wb_s,
    ck            => ck_s,
    reset_n       => reset_n_s,
    vdd           => vdd_s,
    vss           => vss_s
  );

  clk_process : process
  begin
    ck_s <= '0';
    wait for clk_period/2; --for 0.5 ns signal is '0'.
    ck_s <= '1';
    wait for clk_period/2; --for next 0.5 ns signal is '1'.
  end process;

  stim_proc : process
  begin

    wait;
  end process;
end testbench;