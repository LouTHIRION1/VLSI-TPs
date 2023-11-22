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
    report "Test signals at reset" severity note;
    reset_n_s <= '0';

    wneg_s    <= '0';
    wzero_s   <= '0';
    wcry_s    <= '0';
    wovr_s    <= '0';
    cpsr_wb_s <= '0';

    inval1_s <= '1'; -- Mark as valid
    inval2_s <= '1'; -- Mark as valid

    wait for clk_period;

    assert (reg_v1_s = '1') report "Error!" severity error;
    assert (reg_v2_s = '1') report "Error!" severity error;
    assert (reg_v3_s = '1') report "Error!" severity error;
    assert (reg_cznv_s = '1') report "Error!" severity error; -- CZN Validity bit (logic instruction)
    assert (reg_vv_s = '1') report "Error!" severity error;   -- V Validity bit (arithmetic instruction)
    assert (reg_cry_s = '0') report "Error!" severity error;  -- C fag
    assert (reg_zero_s = '0') report "Error!" severity error; -- Z flag
    assert (reg_neg_s = '0') report "Error!" severity error;  -- N flag
    assert (reg_ovr_s = '0') report "Error!" severity error;  -- V flag
    assert (reg_pcv_s = '1') report "Error!" severity error;

    report "Test Read Address 1" severity note;
    reset_n_s <= '1';
    wdata1_s  <= x"AAAA_0000";
    wadr1_s   <= x"A";
    wen1_s    <= '1';

    wdata2_s <= x"0000_0000";
    wadr2_s  <= x"A";
    wen2_s   <= '0';

    inval_adr1_s <= x"A";
    inval_adr2_s <= x"0";
    inval1_s     <= '0'; -- Mark as invalid

    radr1_s <= x"A";
    wait for clk_period;

    assert(reg_rd1_s = x"AAAA_0000") report "Wrong value for R" & integer'image(to_integer(unsigned(wadr1_s))) severity error;
    report "reg_rd1=" & to_hstring(reg_rd1_s) severity note;

    inval1_s <= '1'; -- Mark as valid
    wait;
  end process;
end testbench;