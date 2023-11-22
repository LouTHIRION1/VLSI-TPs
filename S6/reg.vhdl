library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Reg is
  port
  (
    ---- Write interface
    -- Write Port 1 prioritaire (EXEC stage)
    wdata1 : in std_logic_vector(31 downto 0);-- EXEC Data
    wadr1  : in std_logic_vector(3 downto 0); -- Register address (0 - 16)
    wen1   : in std_logic;                    -- Enable port

    -- Write Port 2 non prioritaire (MEM stage)
    wdata2 : in std_logic_vector(31 downto 0);-- MEM Data
    wadr2  : in std_logic_vector(3 downto 0); -- Register address (0 - 16)
    wen2   : in std_logic;                    -- Enable port

    -- Write CPSR (Current Program Status Register) Port
    wneg    : in std_logic; -- Write N flag
    wzero   : in std_logic; -- Write Z flag
    wcry    : in std_logic; -- Write C flag
    wovr    : in std_logic; -- Write V flag
    cpsr_wb : in std_logic; -- CPSR register writeback enable {S}

    ---- Read interface (Rd, Rs, Rt)
    -- Read Port 1 32 bits
    reg_rd1 : out std_logic_vector(31 downto 0); -- Register 1
    radr1   : in std_logic_vector(3 downto 0);   -- Register 1 address (0 - 16)
    reg_v1  : out std_logic;                     -- Register 1 validity bit

    -- Read Port 2 32 bits
    reg_rd2 : out std_logic_vector(31 downto 0); -- Register 2
    radr2   : in std_logic_vector(3 downto 0);   -- Register 2 address (0 - 16)
    reg_v2  : out std_logic;                     -- Register 2 validity bit

    -- Read Port 3 32 bits
    reg_rd3 : out std_logic_vector(31 downto 0); -- Register 3
    radr3   : in std_logic_vector(3 downto 0);   -- Register 3 address (0 - 16)
    reg_v3  : out std_logic;                     -- Register 3 validity bit

    ---- CPSR
    -- Read CPSR (Current Program Status Register) Port
    reg_neg  : out std_logic; -- Read N flag
    reg_zero : out std_logic; -- Read Z flag
    reg_cry  : out std_logic; -- Read C flag
    reg_cznv : out std_logic; -- CZN flag validity (Logic instructions)
    reg_ovr  : out std_logic; -- Read V flag
    reg_vv   : out std_logic; -- V flag validity (Arithmetic instructions)

    ---- Invalidation
    -- Invalidate Port 1
    inval_adr1 : in std_logic_vector(3 downto 0); -- Invalidate address Register 1 (0 - 16)
    inval1     : in std_logic;                    -- Invalidate Register 1
    -- Invalidate Port 2
    inval_adr2 : in std_logic_vector(3 downto 0); -- Invalidate address Register 2 (0 - 16)
    inval2     : in std_logic;                    -- Invalidate Register 2
    -- Invalidate Flags
    inval_czn : in std_logic; -- Invalidate C Z N flags (Logic instructions)
    inval_ovr : in std_logic; -- Invalidate V flag (Arithmetic instructions)

    ---- Program Counter (PC)
    reg_pc  : out std_logic_vector(31 downto 0); -- Program Counter register
    reg_pcv : out std_logic;                     -- Program Counter validity
    inc_pc  : in std_logic;                      -- Increment PC +4

    ---- Global Interface
    clk     : in std_logic; -- Clock
    reset_n : in std_logic; -- Reset (active low)
    vdd     : in bit;
    vss     : in bit
  );
end Reg;

architecture behavioral_reg of Reg is
  -- TODO: Implement R16 PC behaviour
  type reg_arr is array (0 to 15) of std_logic_vector(31 downto 0); -- Array of 16 32-bit registers
  signal reg_bank : reg_arr;
  signal regs_v   : std_logic_vector(15 downto 0); -- Validity bits for each register

  -- CPSR
  signal n_s : std_logic;
  signal c_s : std_logic;
  signal z_s : std_logic;
  signal v_s : std_logic;
  -- CPSR Validity bits
  signal reg_cznv_s : std_logic;
  signal reg_vv_s   : std_logic;

  -- Signals used for integer conversion
  signal wadr1_int      : integer;
  signal wadr2_int      : integer;
  signal radr1_int      : integer;
  signal radr2_int      : integer;
  signal radr3_int      : integer;
  signal inval_adr1_int : integer;
  signal inval_adr2_int : integer;
begin
  -- Convert addresses to integers to access bits of std_logic_vector conveniently
  wadr1_int <= to_integer(unsigned(wadr1));
  wadr2_int <= to_integer(unsigned(wadr2));

  radr1_int <= to_integer(unsigned(radr1));
  radr2_int <= to_integer(unsigned(radr2));
  radr3_int <= to_integer(unsigned(radr3));

  inval_adr1_int <= to_integer(unsigned(inval_adr1));
  inval_adr2_int <= to_integer(unsigned(inval_adr2));

  process (clk)
  begin

    if rising_edge(clk) then
      -- Synchronous Reset (active low)
      if (reset_n = '0') then
        -- Validate Register ports
        reg_v1     <= '1';
        reg_v2     <= '1';
        reg_v3     <= '1';
        reg_cznv_s <= '1'; -- CZN Validity bit (logic instruction)
        reg_vv_s   <= '1'; -- V Validity bit (arithmetic instruction)
        -- TODO: Empty all registers
        reg_bank <= (others => (others => '0'));
        -- Reset CPSR
        c_s    <= '0';             -- C fag
        z_s    <= '0';             -- Z flag
        n_s    <= '0';             -- N flag
        v_s    <= '0';             -- V flag
        regs_v <= (others => '1'); -- Validate all registers regardless of what's stored inside them 
        -- PC
        reg_pcv <= '1';
      else
        if (cpsr_wb = '1') then
          n_s        <= wneg;
          z_s        <= wzero;
          c_s        <= wcry;
          reg_cznv_s <= '1'; -- Validate after affecting values
          v_s        <= wovr;
          reg_vv_s   <= '1'; -- Validate after affecting values
        end if;

        -- Assign invalidation bit to the register corresponding to the address
        -- TODO: active low or high?
        regs_v(inval_adr1_int) <= '0' when inval1 = '1';
        regs_v(inval_adr2_int) <= '0' when inval2 = '1';

        -- Take address of the register to be written, save the data and validate the register afterwards
        -- Always save EXEC result
        if (wen1 = '1') then
          reg_bank(wadr1_int) <= wdata1 when (regs_v(wadr1_int) = '0');
          -- Validate after writing
          regs_v(wadr1_int) <= '1';
        end if;
        -- No conflict, save MEM result
        if (wen2 = '1' and wadr1 /= wadr2) then
          reg_bank(wadr2_int) <= wdata2 when (regs_v(wadr2_int) = '0');
          -- Validate after writing
          regs_v(wadr2_int) <= '1';
        end if;

        -- Program Counter
        reg_bank(15) <= std_logic_vector(to_unsigned(4, reg_bank(15)'length)) when inc_pc = '1';
        reg_pc       <= reg_bank(15);
        reg_pcv      <= regs_v(15);

        -- Read register corresponding to the read address
        reg_rd1 <= reg_bank(radr1_int);
        reg_rd2 <= reg_bank(radr2_int);
        reg_rd3 <= reg_bank(radr3_int);
        -- Read the validity bit corresponding to the read address
        reg_v1 <= regs_v(radr1_int);
        reg_v2 <= regs_v(radr2_int);
        reg_v3 <= regs_v(radr3_int);

        -- relie les flags à leurs signaux de sorties
        reg_cry  <= c_s;
        reg_neg  <= n_s;
        reg_zero <= z_s;
        reg_ovr  <= v_s;
        reg_cznv <= reg_cznv_s;
        reg_vv   <= reg_vv_s;

        -- CZN Flags validity
        reg_cznv_s <= '0' when (inval_czn = '1' and reset_n = '1');
        -- V Flag validity
        reg_vv_s <= '0' when (inval_ovr = '1' and reset_n = '1');

      end if; -- Reset
    end if; -- Rising edge
  end process;
end behavioral_reg;