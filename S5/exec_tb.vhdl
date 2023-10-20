library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity exec_tb is
  --empty
end exec_tb;

architecture testbench of exec_tb is

  component EXec is
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

      -- flags
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
    -- Probe
    -- probe : out std_logic_vector(31 downto 0));
  end component;
  -- Declaration des signaux
  signal exe_pop_s       : std_logic;
  signal dec2exe_empty_s : std_logic;
  signal dec_op1_s       : std_logic_vector(31 downto 0); -- first alu input
  signal dec_op2_s       : std_logic_vector(31 downto 0); -- shifter input
  signal dec_exe_dest_s  : std_logic_vector(3 downto 0);  -- Rd destination
  signal dec_exe_wb_s    : std_logic;                     -- Rd destination write back
  signal dec_flag_wb_s   : std_logic;                     -- CSPR modifiy
  signal dec_mem_data_s  : std_logic_vector(31 downto 0); -- data to MEM W
  signal dec_mem_dest_s  : std_logic_vector(3 downto 0);  -- Destination MEM R
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
  signal dec_alu_cmd_s   : std_logic_vector(1 downto 0);
  signal exe_res_s       : std_logic_vector(31 downto 0);
  signal exe_c_s         : std_logic;
  signal exe_v_s         : std_logic;
  signal exe_n_s         : std_logic;
  signal exe_z_s         : std_logic;
  signal exe_dest_s      : std_logic_vector(3 downto 0);  -- Rd destination
  signal exe_wb_s        : std_logic;                     -- Rd destination write back
  signal exe_flag_wb_s   : std_logic;                     -- CSPR modifiy
  signal exe_mem_adr_s   : std_logic_vector(31 downto 0); -- Alu res register
  signal exe_mem_data_s  : std_logic_vector(31 downto 0);
  signal exe_mem_dest_s  : std_logic_vector(3 downto 0);
  signal exe_mem_lw_s    : std_logic;
  signal exe_mem_lb_s    : std_logic;
  signal exe_mem_sw_s    : std_logic;
  signal exe_mem_sb_s    : std_logic;
  signal exe2mem_empty_s : std_logic;
  signal mem_pop_s       : std_logic;
  signal ck_s            : std_logic;
  signal reset_n_s       : std_logic;
  signal vdd_s           : bit;
  signal vss_s           : bit;
  -- signal probe_s         : std_logic_vector(31 downto 0);

begin

  DUT : EXec port map
  (
    dec2exe_empty => dec2exe_empty_s,
    exe_pop       => exe_pop_s,
    dec_op1       => dec_op1_s,      -- first alu input
    dec_op2       => dec_op2_s,      -- shifter input
    dec_exe_dest  => dec_exe_dest_s, -- Rd destination
    dec_exe_wb    => dec_exe_wb_s,   -- Rd destination write back
    dec_flag_wb   => dec_flag_wb_s,  -- CSPR modifiy
    dec_mem_data  => dec_mem_data_s, -- data to MEM W
    dec_mem_dest  => dec_mem_dest_s, -- Destination MEM R
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
    dec_comp_op1  => dec_comp_op1_s, -- MUX cmd for ALU Op1
    dec_comp_op2  => dec_comp_op2_s, -- MUX cmd for ALU Op1
    dec_alu_cy    => dec_alu_cy_s,
    dec_alu_cmd   => dec_alu_cmd_s,
    exe_res       => exe_res_s,
    exe_c         => exe_c_s,
    exe_v         => exe_v_s,
    exe_n         => exe_n_s,
    exe_z         => exe_z_s,
    exe_dest      => exe_dest_s,    -- Rd destination
    exe_wb        => exe_wb_s,      -- Rd destination write back
    exe_flag_wb   => exe_flag_wb_s, -- CSPR modifiy
    exe_mem_adr   => exe_mem_adr_s, -- Alu res register
    exe_mem_data  => exe_mem_data_s,
    exe_mem_dest  => exe_mem_dest_s,
    exe_mem_lw    => exe_mem_lw_s,
    exe_mem_lb    => exe_mem_lb_s,
    exe_mem_sw    => exe_mem_sw_s,
    exe_mem_sb    => exe_mem_sb_s,
    exe2mem_empty => exe2mem_empty_s,
    mem_pop       => mem_pop_s,
    ck            => ck_s,
    reset_n       => reset_n_s,
    vdd           => vdd_s,
    vss           => vss_s
    -- probe         => probe_s
  );

  process
    -- alias myalias is << signal .exec_tb.DUT.alu_inst.res_s : std_logic_vector(31 downto 0) >> ;
    -- alias myalias is << signal DUT.alu_inst.res_s : std_logic_vector(31 downto 0) >> ;
  begin

    report "EXEC stage tests" severity note;
    report "Sum without shift" severity note;
    -- report "Sum 1+2 = 3" severity note;
    dec_op1_s       <= x"0000_0001";
    dec_op2_s       <= x"0000_0002";
    dec_alu_cmd_s   <= "00"; -- Sum
    dec_shift_lsl_s <= '1';
    dec_shift_val_s <= "00000";
    dec_comp_op1_s  <= '0';
    dec_comp_op2_s  <= '0';
    dec_cy_s        <= '0';
    dec_alu_cy_s    <= '0';
    wait for 1 ns;
    assert(exe_res_s = x"0000_0003") report "Incorrect res, exe_res = 0x" & to_hstring(exe_res_s) severity error;
    assert(exe_c_s = '0') report "Incorrect C flag" severity error;
    assert(exe_v_s = '0') report "Incorrect V flag" severity error;
    assert(exe_n_s = '0') report "Incorrect N flag" severity error;
    assert(exe_z_s = '0') report "Incorrect Z flag" severity error;

    report "Sum with LSL" severity note;
    -- report "Sum 1 + 2<<2 = 1 + 8 = 9" severity note;
    dec_op1_s       <= x"0000_0001";
    dec_op2_s       <= x"0000_0002";
    dec_alu_cmd_s   <= "00"; -- Sum
    dec_shift_lsl_s <= '1';
    dec_shift_val_s <= "00010";
    dec_comp_op1_s  <= '0';
    dec_comp_op2_s  <= '0';
    dec_cy_s        <= '0';
    dec_alu_cy_s    <= '0';
    wait for 1 ns;
    assert(exe_res_s = x"0000_0009") report "Incorrect res, exe_res = 0x" & to_hstring(exe_res_s) severity error;
    assert(exe_c_s = '0') report "Incorrect C flag" severity error;
    assert(exe_v_s = '0') report "Incorrect V flag" severity error;
    assert(exe_n_s = '0') report "Incorrect N flag" severity error;
    assert(exe_z_s = '0') report "Incorrect Z flag" severity error;

    report "Sum overflow with LSL" severity note;
    -- report "8000_0000 + 4000_0000<<1 = 8000_0000 + 8000_0000 = 0000_0000 with Cout" severity note;
    dec_op1_s       <= x"8000_0000";
    dec_op2_s       <= x"4000_0000";
    dec_alu_cmd_s   <= "00"; -- Sum
    dec_shift_lsl_s <= '1';
    dec_shift_val_s <= "00001";
    dec_comp_op1_s  <= '0';
    dec_comp_op2_s  <= '0';
    dec_cy_s        <= '0';
    dec_alu_cy_s    <= '0';
    wait for 1 ns;
    assert(exe_res_s = x"0000_0000") report "Incorrect res, exe_res = 0x" & to_hstring(exe_res_s) severity error;
    assert(exe_c_s = '1') report "Incorrect C flag" severity error;
    assert(exe_v_s = '1') report "Incorrect V flag" severity error;
    assert(exe_n_s = '0') report "Incorrect N flag" severity error;
    assert(exe_z_s = '1') report "Incorrect Z flag" severity error;

    report "Sum overflow" severity note;
    -- report "FFFF_FFFF + 0000_0001 = 0000_0000 with Cout" severity note;
    dec_op1_s       <= x"FFFF_FFFF";
    dec_op2_s       <= x"0000_0001";
    dec_alu_cmd_s   <= "00"; -- Sum
    dec_shift_lsl_s <= '1';
    dec_shift_val_s <= "00000";
    dec_comp_op1_s  <= '0';
    dec_comp_op2_s  <= '0';
    dec_cy_s        <= '0';
    dec_alu_cy_s    <= '0';
    wait for 1 ns;
    assert(exe_res_s = x"0000_0000") report "Incorrect res, exe_res = 0x" & to_hstring(exe_res_s) severity error;
    assert(exe_c_s = '1') report "Incorrect C flag" severity error;
    assert(exe_v_s = '0') report "Incorrect V flag" severity error;
    assert(exe_n_s = '0') report "Incorrect N flag" severity error;
    assert(exe_z_s = '1') report "Incorrect Z flag" severity error;

    report "RRX Test with carry" severity note;
    dec_op1_s       <= x"0000_0000";
    dec_op2_s       <= x"0000_0000";
    dec_alu_cmd_s   <= "00"; -- Sum
    dec_shift_lsl_s <= '0';
    dec_shift_rrx_s <= '1';
    dec_shift_val_s <= "00001";
    dec_comp_op1_s  <= '0';
    dec_comp_op2_s  <= '0';
    dec_cy_s        <= '1';
    dec_alu_cy_s    <= '0';
    wait for 1 ns;
    assert(exe_res_s = x"8000_0000") report "Incorrect res, exe_res = 0x" & to_hstring(exe_res_s) severity error;
    assert(exe_c_s = '0') report "Incorrect C flag" severity error;
    assert(exe_v_s = '0') report "Incorrect V flag" severity error;
    assert(exe_n_s = '1') report "Incorrect N flag" severity error;
    assert(exe_z_s = '0') report "Incorrect Z flag" severity error;

    report "RRX Test without carry" severity note;
    dec_op1_s       <= x"0000_0000";
    dec_op2_s       <= x"0000_0001";
    dec_alu_cmd_s   <= "00"; -- Sum
    dec_shift_lsl_s <= '0';
    dec_shift_rrx_s <= '1';
    dec_shift_val_s <= "00001";
    dec_comp_op1_s  <= '0';
    dec_comp_op2_s  <= '0';
    dec_cy_s        <= '0';
    dec_alu_cy_s    <= '0';
    wait for 1 ns;
    assert(exe_res_s = x"0000_0000") report "Incorrect res, exe_res = 0x" & to_hstring(exe_res_s) severity error;
    assert(exe_c_s = '1') report "Incorrect C flag" severity error;
    assert(exe_v_s = '0') report "Incorrect V flag" severity error;
    assert(exe_n_s = '0') report "Incorrect N flag" severity error;
    assert(exe_z_s = '1') report "Incorrect Z flag" severity error;

    report "Logic OR test (set bitmask)" severity note;
    dec_op1_s       <= x"0000_0000";
    dec_op2_s       <= x"0030_0300";
    dec_alu_cmd_s   <= "10"; -- OR
    dec_shift_lsl_s <= '1';
    dec_shift_val_s <= "00000";
    dec_comp_op1_s  <= '0';
    dec_comp_op2_s  <= '0';
    dec_cy_s        <= '0';
    dec_alu_cy_s    <= '0';
    wait for 1 ns;
    assert(exe_res_s = x"0030_0300") report "Incorrect res, exe_res = 0x" & to_hstring(exe_res_s) severity error;
    assert(exe_c_s = '0') report "Incorrect C flag" severity error;
    assert(exe_v_s = '0') report "Incorrect V flag" severity error;
    assert(exe_n_s = '0') report "Incorrect N flag" severity error;
    assert(exe_z_s = '0') report "Incorrect Z flag" severity error;

    report "Logic AND test (bitmask)" severity note;
    dec_op1_s       <= x"FFFF_FFFF";
    dec_op2_s       <= x"0FF0_F00F";
    dec_alu_cmd_s   <= "01"; -- AND
    dec_shift_lsl_s <= '1';
    dec_shift_val_s <= "00000";
    dec_comp_op1_s  <= '0';
    dec_comp_op2_s  <= '0';
    dec_cy_s        <= '0';
    dec_alu_cy_s    <= '0';
    wait for 1 ns;
    assert(exe_res_s = x"0FF0_F00F") report "Incorrect res, exe_res = 0x" & to_hstring(exe_res_s) severity error;
    assert(exe_c_s = '0') report "Incorrect C flag" severity error;
    assert(exe_v_s = '0') report "Incorrect V flag" severity error;
    assert(exe_n_s = '0') report "Incorrect N flag" severity error;
    assert(exe_z_s = '0') report "Incorrect Z flag" severity error;

    report "Logic XOR test" severity note;
    dec_op1_s       <= x"FFFF_FFFF";
    dec_op2_s       <= x"8000_0001";
    dec_alu_cmd_s   <= "11"; -- XOR
    dec_shift_lsl_s <= '1';
    dec_shift_val_s <= "00000";
    dec_comp_op1_s  <= '0';
    dec_comp_op2_s  <= '0';
    dec_cy_s        <= '0';
    dec_alu_cy_s    <= '0';
    wait for 1 ns;
    assert(exe_res_s = x"7FFF_FFFE") report "Incorrect res, exe_res = 0x" & to_hstring(exe_res_s) severity error;
    assert(exe_c_s = '0') report "Incorrect C flag" severity error;
    assert(exe_v_s = '1') report "Incorrect V flag" severity error;
    assert(exe_n_s = '0') report "Incorrect N flag" severity error;
    assert(exe_z_s = '0') report "Incorrect Z flag" severity error;
    -- assert(false) report "probe = 0x" & to_hstring(probe_s) severity error;

    wait;
  end process;
end testbench;