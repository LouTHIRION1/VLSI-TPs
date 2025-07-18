library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg_tb is
  --empty
end reg_tb;

architecture testbench of reg_tb is

  component Reg is
    port
    (
      -- Write Port 1 prioritaire (EXEC stage)
      wdata1 : in std_logic_vector(31 downto 0);
      wadr1  : in std_logic_vector(3 downto 0);
      wen1   : in std_logic; -- Enable port

      -- Write Port 2 non prioritaire (MEM stage)
      wdata2 : in std_logic_vector(31 downto 0);
      wadr2  : in std_logic_vector(3 downto 0);
      wen2   : in std_logic; -- Enable port

      -- Write CSPR (Current Program Status Register) Port
      wcry    : in std_logic; -- Write C flag
      wzero   : in std_logic; -- Write Z flag
      wneg    : in std_logic; -- Write N flag
      wovr    : in std_logic; -- Write V flag
      cpsr_wb : in std_logic; -- CSPR register writeback enable

      -- Read Port 1 32 bits (Rd)
      reg_rd1 : out std_logic_vector(31 downto 0); -- Register 1
      radr1   : in std_logic_vector(3 downto 0);   -- Register 1 address
      reg_v1  : out std_logic;                     -- Register 1 validity bit

      -- Read Port 2 32 bits (Rs)
      reg_rd2 : out std_logic_vector(31 downto 0); -- Register 2
      radr2   : in std_logic_vector(3 downto 0);   -- Register 2 address
      reg_v2  : out std_logic;                     -- Register 2 validity bit

      -- Read Port 3 32 bits (Rt)
      reg_rd3 : out std_logic_vector(31 downto 0); -- Register 3
      radr3   : in std_logic_vector(3 downto 0);   -- Register 3 address
      reg_v3  : out std_logic;                     -- Register 3 validity bit

      -- Read CPSR (Current Program Status Register) Port
      reg_cry  : out std_logic; -- Read C flag
      reg_zero : out std_logic; -- Read Z flag
      reg_neg  : out std_logic; -- Read N flag
      reg_ovr  : out std_logic; -- Read V flag
      reg_cznv : out std_logic; -- CZN flag validity (for logic instructions)
      reg_vv   : out std_logic; -- V flag validity(for arithmetic instructions)

      -- Invalidate Port 
      inval_adr1 : in std_logic_vector(3 downto 0); -- Invalidate address Register 1
      inval1     : in std_logic;                    -- Invalidate Register 1

      inval_adr2 : in std_logic_vector(3 downto 0); -- Invalidate address Register 2
      inval2     : in std_logic;                    -- Invalidate Register 2

      inval_czn : in std_logic; -- Invalidate C Z N flags (Logic instructions)
      inval_ovr : in std_logic; -- Invalidate V flag (Arithmetic instructions)

      -- PC
      reg_pc  : out std_logic_vector(31 downto 0); -- Program Counter register
      reg_pcv : out std_logic;                     -- Program Counter validity
      inc_pc  : in std_logic;                      -- Increment PC +4

      -- global interface
      clk     : in std_logic; -- Clock
      reset_n : in std_logic; -- Reset (active low)
      vdd     : in bit;
      vss     : in bit);
  end component;

  -- Declaration des signaux
  signal wdata1_s     : std_logic_vector(31 downto 0);
  signal wadr1_s      : std_logic_vector(3 downto 0);
  signal wen1_s       : std_logic; -- Enable port
  signal wdata2_s     : std_logic_vector(31 downto 0);
  signal wadr2_s      : std_logic_vector(3 downto 0);
  signal wen2_s       : std_logic;                     -- Enable port
  signal wcry_s       : std_logic;                     -- Write C flag
  signal wzero_s      : std_logic;                     -- Write Z flag
  signal wneg_s       : std_logic;                     -- Write N flag
  signal wovr_s       : std_logic;                     -- Write V flag
  signal cpsr_wb_s    : std_logic;                     -- CSPR register writeback enable
  signal reg_rd1_s    : std_logic_vector(31 downto 0); -- Register 1
  signal radr1_s      : std_logic_vector(3 downto 0);  -- Register 1 address
  signal reg_v1_s     : std_logic;                     -- Register 1 validity bit
  signal reg_rd2_s    : std_logic_vector(31 downto 0); -- Register 2
  signal radr2_s      : std_logic_vector(3 downto 0);  -- Register 2 address
  signal reg_v2_s     : std_logic;                     -- Register 2 validity bit
  signal reg_rd3_s    : std_logic_vector(31 downto 0); -- Register 3
  signal radr3_s      : std_logic_vector(3 downto 0);  -- Register 3 address
  signal reg_v3_s     : std_logic;                     -- Register 3 validity bit
  signal reg_cry_s    : std_logic;                     -- Read C flag
  signal reg_zero_s   : std_logic;                     -- Read Z flag
  signal reg_neg_s    : std_logic;                     -- Read N flag
  signal reg_ovr_s    : std_logic;                     -- Read V flag
  signal reg_cznv_s   : std_logic;                     -- CZN flag validity (for logic instructions)
  signal reg_vv_s     : std_logic;                     -- V flag validity(for arithmetic instructions)
  signal inval_adr1_s : std_logic_vector(3 downto 0);  -- Invalidate address Register 1
  signal inval1_s     : std_logic;                     -- Invalidate Register 1
  signal inval_adr2_s : std_logic_vector(3 downto 0);  -- Invalidate address Register 2
  signal inval2_s     : std_logic;                     -- Invalidate Register 2
  signal inval_czn_s  : std_logic;                     -- Invalidate C Z N flags (Logic instructions)
  signal inval_ovr_s  : std_logic;                     -- Invalidate V flag (Arithmetic instructions)
  signal reg_pc_s     : std_logic_vector(31 downto 0); -- Program Counter register
  signal reg_pcv_s    : std_logic;                     -- Program Counter validity
  signal inc_pc_s     : std_logic;                     -- Increment PC +4
  signal clk_s        : std_logic;                     -- Clock
  signal reset_n_s    : std_logic;                     -- Reset (active low)
  signal vdd_s        : bit;
  signal vss_s        : bit;

  -- Clock period definitions
  constant clk_period : time := 1 ns;

begin

  DUT : Reg port map
  (
    wdata1     => wdata1_s,
    wadr1      => wadr1_s,
    wen1       => wen1_s,
    wdata2     => wdata2_s,
    wadr2      => wadr2_s,
    wen2       => wen2_s,
    wcry       => wcry_s,
    wzero      => wzero_s,
    wneg       => wneg_s,
    wovr       => wovr_s,
    cpsr_wb    => cpsr_wb_s,
    reg_rd1    => reg_rd1_s,
    radr1      => radr1_s,
    reg_v1     => reg_v1_s,
    reg_rd2    => reg_rd2_s,
    radr2      => radr2_s,
    reg_v2     => reg_v2_s,
    reg_rd3    => reg_rd3_s,
    radr3      => radr3_s,
    reg_v3     => reg_v3_s,
    reg_cry    => reg_cry_s,
    reg_zero   => reg_zero_s,
    reg_neg    => reg_neg_s,
    reg_ovr    => reg_ovr_s,
    reg_cznv   => reg_cznv_s,
    reg_vv     => reg_vv_s,
    inval_adr1 => inval_adr1_s,
    inval1     => inval1_s,
    inval_adr2 => inval_adr2_s,
    inval2     => inval2_s,
    inval_czn  => inval_czn_s,
    inval_ovr  => inval_ovr_s,
    reg_pc     => reg_pc_s,
    reg_pcv    => reg_pcv_s,
    inc_pc     => inc_pc_s,
    clk        => clk_s,
    reset_n    => reset_n_s,
    vdd        => vdd_s,
    vss        => vss_s
  );

  clk_process : process
  begin
    clk_s <= '0';
    wait for clk_period/2; --for 0.5 ns signal is '0'.
    clk_s <= '1';
    wait for clk_period/2; --for next 0.5 ns signal is '1'.
  end process;

  stim_proc : process
  begin

    -- Test Reset
    report "--- Test signals at reset ---" severity note;
      reset_n_s <= '0';
    -- CPSR
    inval_czn_s <= '0';
    inval_ovr_s <= '0';
    wneg_s      <= '0';
    wzero_s     <= '0';
    wcry_s      <= '0';
    wovr_s      <= '0';

    wait for clk_period;
    -- Register Bank
    assert (reg_pcv_s = '1') report "PC should be valid" severity error;
    assert (reg_cznv_s = '1') report "CZN should be valid" severity error; -- CZN Validity bit (logic instruction)
    assert (reg_vv_s = '1') report "V should be valid" severity error;     -- V Validity bit (arithmetic instruction)

    reset_n_s <= '1';
    wait for clk_period;

    -- CPSR tests
    report "--- CPSR Tests ---" severity note;
      report "Invalid CZN V and Writeback" severity note;
    inval_czn_s <= '1';
    inval_ovr_s <= '1';
    cpsr_wb_s   <= '1';
    wneg_s      <= '0';
    wzero_s     <= '0';
    wcry_s      <= '0';
    wovr_s      <= '0';
    wait for clk_period * 2;
    -- Flags are validated after being written
    assert (reg_cznv_s = '1') report "CZN Validity Error" severity error; -- CZN Validity bit (logic instruction)
    assert (reg_vv_s = '1') report "V Validity Error" severity error;     -- V Validity bit (arithmetic instruction)

    assert (reg_neg_s = '0') report "Wrong N" severity error;  -- N flag
    assert (reg_zero_s = '0') report "Wrong Z" severity error; -- Z flag
    assert (reg_cry_s = '0') report "Wrong C" severity error;  -- C fag
    assert (reg_ovr_s = '0') report "Wrong V" severity error;  -- V flag

    inval_czn_s <= '1';
    inval_ovr_s <= '1';
    cpsr_wb_s   <= '1';
    wneg_s      <= '1';
    wzero_s     <= '1';
    wcry_s      <= '1';
    wovr_s      <= '1';
    wait for clk_period * 2;

    -- Flags are validated after being written
    assert (reg_cznv_s = '1') report "CZN Validity Error" severity error; -- CZN Validity bit (logic instruction)
    assert (reg_vv_s = '1') report "V Validity Error" severity error;     -- V Validity bit (arithmetic instruction)

    assert (reg_neg_s = '1') report "Wrong N" severity error;  -- N flag
    assert (reg_zero_s = '1') report "Wrong Z" severity error; -- Z flag
    assert (reg_cry_s = '1') report "Wrong C" severity error;  -- C fag
    assert (reg_ovr_s = '1') report "Wrong V" severity error;  -- V flag

    report "Invalid CZN V and No Writeback" severity note;

    inval_czn_s <= '1';
    inval_ovr_s <= '1';
    cpsr_wb_s   <= '0';
    wneg_s      <= '0';
    wzero_s     <= '0';
    wcry_s      <= '0';
    wovr_s      <= '0';
    wait for clk_period * 2;

    -- Flags are not validated since they were not written (no writeback)
    assert (reg_cznv_s = '0') report "CZN Validity Error" severity error; -- CZN Validity bit (logic instruction)
    assert (reg_vv_s = '0') report "V Validity Error" severity error;     -- V Validity bit (arithmetic instruction)
    -- Flags keep their old value (no writeback)
    assert (reg_neg_s = '1') report "Wrong N" severity error;  -- N flag
    assert (reg_zero_s = '1') report "Wrong Z" severity error; -- Z flag
    assert (reg_cry_s = '1') report "Wrong C" severity error;  -- C fag
    assert (reg_ovr_s = '1') report "Wrong V" severity error;  -- V flag

    inval_czn_s <= '1';
    inval_ovr_s <= '1';
    cpsr_wb_s   <= '0';
    wneg_s      <= '1';
    wzero_s     <= '1';
    wcry_s      <= '1';
    wovr_s      <= '1';
    wait for clk_period * 2;

    -- Flags are not validated since they were not written (no writeback)
    assert (reg_cznv_s = '0') report "CZN Validity Error" severity error; -- CZN Validity bit (logic instruction)
    assert (reg_vv_s = '0') report "V Validity Error" severity error;     -- V Validity bit (arithmetic instruction)
    -- Flags keep their old value (no writeback)
    assert (reg_neg_s = '1') report "Wrong N" severity error;  -- N flag
    assert (reg_zero_s = '1') report "Wrong Z" severity error; -- Z flag
    assert (reg_cry_s = '1') report "Wrong C" severity error;  -- C fag
    assert (reg_ovr_s = '1') report "Wrong V" severity error;  -- V flag

    report "Valid CZN V and Writeback" severity note;

    inval_czn_s <= '0';
    inval_ovr_s <= '0';
    cpsr_wb_s   <= '1';

    wneg_s  <= '0';
    wzero_s <= '0';
    wcry_s  <= '0';
    wovr_s  <= '0';
    wait for clk_period;

    -- Flags are validated after being written
    assert (reg_cznv_s = '1') report "CZN Validity Error" severity error; -- CZN Validity bit (logic instruction)
    assert (reg_vv_s = '1') report "V Validity Error" severity error;     -- V Validity bit (arithmetic instruction)

    assert (reg_neg_s = '0') report "Wrong N" severity error;  -- N flag
    assert (reg_zero_s = '0') report "Wrong Z" severity error; -- Z flag
    assert (reg_cry_s = '0') report "Wrong C" severity error;  -- C fag
    assert (reg_ovr_s = '0') report "Wrong V" severity error;  -- V flag

    report "Valid CZN V and No Writeback" severity note;

    inval_czn_s <= '0';
    inval_ovr_s <= '0';
    cpsr_wb_s   <= '0';

    wneg_s  <= '0';
    wzero_s <= '0';
    wcry_s  <= '0';
    wovr_s  <= '0';
    wait for clk_period;

    -- Flags are validated after being written
    assert (reg_cznv_s = '1') report "CZN Validity Error" severity error; -- CZN Validity bit (logic instruction)
    assert (reg_vv_s = '1') report "V Validity Error" severity error;     -- V Validity bit (arithmetic instruction)

    assert (reg_neg_s = '0') report "Wrong N" severity error;  -- N flag
    assert (reg_zero_s = '0') report "Wrong Z" severity error; -- Z flag
    assert (reg_cry_s = '0') report "Wrong C" severity error;  -- C fag
    assert (reg_ovr_s = '0') report "Wrong V" severity error;  -- V flag
    report "--- Program Counter Tests ---" severity note;
      inc_pc_s <= '1';
    wen1_s   <= '0';
    wen2_s   <= '0';

    wait for clk_period;

    assert(reg_pc_s = x"0000_0004") report "1Expected PC = 00000004" severity error;
    report "1Program Counter = " & to_hstring(reg_pc_s) severity note;

    inval1_s     <= '1';
    inval_adr1_s <= x"F";
    inc_pc_s     <= '0';
    wen1_s       <= '1';
    wen2_s       <= '0';
    wadr1_s      <= x"F";
    wadr2_s      <= x"F";

    -- inval1_s <= '1';
    -- inval_adr1_s <= x"F";

    inval2_s     <= '0';
    inval_adr2_s <= x"F";
    wdata1_s     <= x"0000_1111";
    wdata2_s     <= x"0000_2222";
    wait for clk_period * 2;

    assert(reg_pc_s = x"0000_1111") report "2Expected PC = 00001111" severity error;
    report "2Program Counter = " & to_hstring(reg_pc_s) severity note;

    -- TODO : Why does this make the PC work?
    inc_pc_s <= '1';
    wen1_s   <= '0';
    wen2_s   <= '0';
    inval1_s <= '0';
    inval2_s <= '0';
    wait for clk_period;

    assert(reg_pc_s = x"0000_1115") report "3Expected PC = 00001111" severity error;
    report "3Program Counter = " & to_hstring(reg_pc_s) severity note;

    inc_pc_s <= '1';
    inval1_s <= '0';
    inval2_s <= '0';
    wait for clk_period;

    assert(reg_pc_s = x"0000_1119") report "4Expected PC = 00001115" severity error;
    report "4Program Counter = " & to_hstring(reg_pc_s) severity note;

    report "--- Register Tests ---" severity note;

      report "Enable Write port 1, Invalidate port 1, No conflict" severity note;

    wen1_s       <= '1';
    wen2_s       <= '0';
    wadr1_s      <= x"1";
    wadr2_s      <= x"2";
    inval1_s     <= '1';
    inval2_s     <= '0';
    inval_adr1_s <= x"1";
    inval_adr2_s <= x"2";

    wdata1_s <= x"0000_1111";
    wdata2_s <= x"0000_2222";
    radr1_s  <= x"1";
    radr2_s  <= x"2";
    radr3_s  <= x"3";
    wait for clk_period * 2;

    assert(reg_rd1_s = x"0000_1111") report "Wrong value for R" & integer'image(to_integer(unsigned(wadr1_s))) severity error;
    report "reg_rd1=" & to_hstring(reg_rd1_s) severity note;
    -- assert(reg_rd2_s = x"0000_0000") report "Wrong value for R" & integer'image(to_integer(unsigned(wadr2_s))) severity error;
    report "reg_rd2=" & to_hstring(reg_rd2_s) severity note;
    -- assert(reg_rd3_s = x"0000_0000") report "Wrong value for R" & integer'image(to_integer(unsigned(wadr2_s))) severity error;
    report "reg_rd3=" & to_hstring(reg_rd3_s) severity note;

    report "Enable Write port 2, Invalidate port 2, No conflict" severity note;
    wen1_s       <= '0';
    wen2_s       <= '1';
    wadr1_s      <= x"1";
    wadr2_s      <= x"2";
    inval1_s     <= '0';
    inval2_s     <= '1';
    inval_adr1_s <= x"1";
    inval_adr2_s <= x"2";
    wdata1_s     <= x"0000_1111";
    wdata2_s     <= x"0000_2222";
    radr1_s      <= x"1";
    radr2_s      <= x"2";
    radr3_s      <= x"3";
    wait for clk_period * 2;

    assert(reg_rd1_s = x"0000_1111") report "Wrong value for R" & integer'image(to_integer(unsigned(wadr1_s))) severity error;
    report "reg_rd1=" & to_hstring(reg_rd1_s) severity note;
    assert(reg_rd2_s = x"0000_2222") report "Wrong value for R" & integer'image(to_integer(unsigned(wadr2_s))) severity error;
    report "reg_rd2=" & to_hstring(reg_rd2_s) severity note;

    report "Enable Write port 1 & 2, Invalidate port 1 & 2, No conflict" severity note;
    wen1_s       <= '1';
    wen2_s       <= '1';
    wadr1_s      <= x"1";
    wadr2_s      <= x"2";
    inval1_s     <= '1';
    inval2_s     <= '1';
    inval_adr1_s <= x"1";
    inval_adr2_s <= x"2";
    wdata1_s     <= x"0000_1111";
    wdata2_s     <= x"0000_2222";
    radr1_s      <= x"1";
    radr2_s      <= x"2";
    radr3_s      <= x"3";
    wait for clk_period * 2;

    assert(reg_rd1_s = x"0000_1111") report "Wrong value for R" & integer'image(to_integer(unsigned(wadr1_s))) severity error;
    report "reg_rd1=" & to_hstring(reg_rd1_s) severity note;
    assert(reg_rd2_s = x"0000_2222") report "Wrong value for R" & integer'image(to_integer(unsigned(wadr2_s))) severity error;
    report "reg_rd2=" & to_hstring(reg_rd2_s) severity note;

    report "Enable Write port 1 & 2, Invalidate port 1 & 2, Conflict" severity note;

    wen1_s       <= '1';
    wen2_s       <= '1';
    wadr1_s      <= x"2";
    wadr2_s      <= x"2";
    inval1_s     <= '1';
    inval2_s     <= '1';
    inval_adr1_s <= x"1";
    inval_adr2_s <= x"2";
    wdata1_s     <= x"0000_EEEE";
    wdata2_s     <= x"0000_3333";
    radr1_s      <= x"1";
    radr2_s      <= x"2";
    radr3_s      <= x"3";
    wait for clk_period * 2;

    -- assert(reg_rd1_s = x"0000_0000") report "Wrong value for R" & integer'image(to_integer(unsigned(wadr1_s))) severity error;
    report "reg_rd1=" & to_hstring(reg_rd1_s) severity note;
    assert(reg_rd2_s = x"0000_EEEE") report "Wrong value for R" & integer'image(to_integer(unsigned(wadr2_s))) severity error;
    report "reg_rd2=" & to_hstring(reg_rd2_s) severity note;

    report "Enable Write port 1 & 2, Validate port 1 & 2, Conflict" severity note;

    wen1_s       <= '1';
    wen2_s       <= '1';
    wadr1_s      <= x"2";
    wadr2_s      <= x"2";
    inval1_s     <= '0';
    inval2_s     <= '0';
    inval_adr1_s <= x"1";
    inval_adr2_s <= x"2";
    wdata1_s     <= x"0000_FFFF";
    wdata2_s     <= x"0000_4444";
    radr1_s      <= x"1";
    radr2_s      <= x"2";
    radr3_s      <= x"3";
    wait for clk_period * 2;

    -- assert(reg_rd1_s = x"0000_0000") report "Wrong value for R" & integer'image(to_integer(unsigned(wadr1_s))) severity error;
    report "reg_rd1=" & to_hstring(reg_rd1_s) severity note;
    assert(reg_rd2_s = x"0000_EEEE") report "Wrong value for R" & integer'image(to_integer(unsigned(wadr2_s))) severity error; -- Valeur finale
    report "reg_rd2=" & to_hstring(reg_rd2_s) severity note;
    wait;
  end process;
end testbench;