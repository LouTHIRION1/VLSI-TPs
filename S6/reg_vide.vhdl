library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Reg is
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
    cspr_wb : in std_logic; -- CSPR register writeback enable

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
end Reg;

architecture behavioral_reg of Reg is
  process (clk)
  begin
    -- Synchronous
    if rising_edge(ck) then
      if (reset_n = '0') then
        -- Invalidate Register ports
        reg_v1 <= '0';
        reg_v2 <= '0';
        reg_v3 <= '0';
        -- Reset CPSR
        reg_cry  <= '0';
        reg_zero <= '0';
        reg_neg  <= '0';
        reg_ovr  <= '0';
        reg_cznv <= '0';
        reg_vv   <= '0';
      else
      end if;
    end if;
  end process;
end behavioral_reg;