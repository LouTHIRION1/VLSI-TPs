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

    -- Read CPSR (Current Program Status Register) Port
    reg_neg  : out std_logic; -- Read N flag
    reg_zero : out std_logic; -- Read Z flag
    reg_cry  : out std_logic; -- Read C flag
    reg_cznv : out std_logic; -- CZN flag validity (Logic instructions)
    reg_ovr  : out std_logic; -- Read V flag
    reg_vv   : out std_logic; -- V flag validity (Arithmetic instructions)

    ---- Invalidation bits
    -- Port 1
    inval_adr1 : in std_logic_vector(3 downto 0); -- Invalidate address Register 1 (0 - 16)
    inval1     : in std_logic;                    -- Invalidate Register 1
    -- Port 2
    inval_adr2 : in std_logic_vector(3 downto 0); -- Invalidate address Register 2 (0 - 16)
    inval2     : in std_logic;                    -- Invalidate Register 2
    -- CPSR Flags
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
  -- Register bank
  type reg_bank_t is array (0 to 15) of std_logic_vector(31 downto 0); -- Array of 16 32-bit registers
  signal reg_bank          : reg_bank_t;
  signal reg_bank_validity : std_logic_vector(15 downto 0); -- Validity bits
  -- Program Counter
  signal pc_temp : std_logic_vector(31 downto 0);
  alias reg_pc_al is reg_bank(15);
  alias reg_pcv_al is reg_bank_validity(15);
  -- CPSR
  signal reg_n_s    : std_logic;
  signal reg_c_s    : std_logic;
  signal reg_z_s    : std_logic;
  signal reg_v_s    : std_logic;
  signal reg_cznv_s : std_logic; -- CZN Validity bit
  signal reg_vv_s   : std_logic; -- V Validity bit

  -- Signals used for integer conversion
  signal wadr1_i   : integer range 0 to 15 := 0;
  signal wadr2_i   : integer range 0 to 15 := 0;
  signal radr1_i   : integer range 0 to 15 := 0;
  signal radr2_i   : integer range 0 to 15 := 0;
  signal radr3_i   : integer range 0 to 15 := 0;
  signal invadr1_i : integer range 0 to 15 := 0;
  signal invadr2_i : integer range 0 to 15 := 0;
begin
  -- Convert addresses to integers to conveniently access bits of std_logic_vector 
  -- Note: Be sure to constrain the values!
  wadr1_i <= to_integer(unsigned(wadr1)) when (wadr1 >= x"0" and wadr1 <= x"F") else
    0;
  wadr2_i <= to_integer(unsigned(wadr2)) when (wadr2 >= x"0" and wadr2 <= x"F") else
    0;
  radr1_i <= to_integer(unsigned(radr1)) when (radr1 >= x"0" and radr1 <= x"F") else
    0;
  radr2_i <= to_integer(unsigned(radr2)) when (radr2 >= x"0" and radr2 <= x"F") else
    0;
  radr3_i <= to_integer(unsigned(radr3)) when (radr3 >= x"0" and radr3 <= x"F") else
    0;
  invadr1_i <= to_integer(unsigned(inval_adr1)) when (inval_adr1 >= x"0" and inval_adr1 <= x"F") else
    0;
  invadr2_i <= to_integer(unsigned(inval_adr2)) when (inval_adr2 >= x"0" and inval_adr2 <= x"F") else
    0;

  -- Increment PC by 4
  -- pc_temp <= std_logic_vector(unsigned(reg_pc_al) + 4);

  process (clk)
  begin
    if rising_edge(clk) then
      -- Synchronous Reset (active low)
      if (reset_n = '0') then
        -- Validate all registers regardless of what's stored inside them 
        reg_bank_validity <= x"FFFF";
        -- Reset PC
        reg_pc_al <= x"0000_0000";
        -- Validate CPSR
        reg_cznv_s <= '1'; -- CZN Validity bit (logic instruction)
        reg_vv_s   <= '1'; -- V Validity bit (arithmetic instruction)
      else
        ---- Register Bank
        -- Assign invalidation bit to the register corresponding to the address
        reg_bank_validity(invadr1_i) <= '0' when (inval1 = '1');
        reg_bank_validity(invadr2_i) <= '0' when (inval2 = '1');

        -- Always save EXEC result
        if (wen1 = '1') then
          if (reg_bank_validity(wadr1_i) = '0') then
            reg_bank(wadr1_i) <= wdata1;

            -- Validate after writing
            reg_bank_validity(wadr1_i) <= '1';
          end if;
        end if;
        -- No conflict, save MEM result
        if (wen2 = '1' and wadr1 /= wadr2) then
          if (reg_bank_validity(wadr2_i) = '0') then
            reg_bank(wadr2_i) <= wdata2;
            -- Validate after writing
            reg_bank_validity(wadr2_i) <= '1';
          end if;
        end if;

        -- Increment PC by 4 at every rising edge
        reg_pc_al <= std_logic_vector(unsigned(reg_pc_al) + 4) when inc_pc = '1';
        --   reg_pc_al;
        -- reg_bank(15) <= std_logic_vector(unsigned(reg_bank(15)) + 4) when inc_pc = '1';

        ---- CPSR
        -- Validity bits
        reg_cznv_s <= '0' when inval_czn = '1';
        reg_vv_s   <= '0' when inval_ovr = '1';

        if (cpsr_wb = '1') then
          if (reg_cznv_s = '0') then
            reg_c_s <= wcry;
            reg_z_s <= wzero;
            reg_n_s <= wneg;
            -- Validate after affecting values
            reg_cznv_s <= '1';
          end if;
          if (reg_vv_s = '0') then
            reg_v_s <= wovr;
            -- Validate after affecting values
            reg_vv_s <= '1';
          end if;
        end if;

      end if; -- Reset
    end if; -- Rising edge
  end process;

  ---- Register bank
  -- Port 1
  reg_rd1 <= wdata1 when (wen1 = '1' and wadr1 = radr1 and reg_bank_validity(wadr1_i) = '0') else
    wdata2 when (wen2 = '1' and wadr2 = radr1 and reg_bank_validity(wadr2_i) = '0') else
    reg_bank(radr1_i) when (radr1_i >= 0 and radr1_i <= 15) else
    x"0000_0000";
  reg_v1 <= '1' when (wadr1 = radr1 and wen1 = '1') else
    '1' when (wadr2 = radr1 and wen2 = '1') else
    reg_bank_validity(radr1_i);
  -- Port 2
  reg_rd2 <= wdata1 when (wen1 = '1' and wadr1 = radr2 and reg_bank_validity(wadr1_i) = '0') else
    wdata2 when (wen2 = '1' and wadr2 = radr2 and reg_bank_validity(wadr2_i) = '0') else
    reg_bank(radr2_i) when (radr2_i >= 0 and radr2_i <= 15) else
    x"0000_0000";
  reg_v2 <= '1' when (wadr1 = radr2 and wen1 = '1') else
    '1' when (wadr2 = radr2 and wen2 = '1') else
    reg_bank_validity(radr2_i);
  -- Port 3
  reg_rd3 <= wdata1 when (wen1 = '1' and wadr1 = radr3 and reg_bank_validity(wadr1_i) = '0') else
    wdata2 when (wen2 = '1' and wadr2 = radr3 and reg_bank_validity(wadr2_i) = '0') else
    reg_bank(radr3_i) when (radr3_i >= 0 and radr3_i <= 15) else
    x"0000_0000";
  reg_v3 <= '1' when (wadr1 = radr3 and wen1 = '1') else
    '1' when (wadr2 = radr3 and wen2 = '1') else
    reg_bank_validity(radr3_i);

  ---- PC
  -- Assign data when write is enabled (EXE has priority over MEM)
  -- otherwise use old value
  reg_pc <= wdata1 when (wen1 = '1' and wadr1_i = 15 and reg_pcv_al = '0') else
    wdata2 when (wen2 = '1' and wadr2_i = 15 and reg_pcv_al = '0') else
    reg_pc_al;
  -- Mark as valid when any write port is enabled and targets PC
  reg_pcv <= '1' when (wadr1_i = 15 and wen1 = '1') else
    '1' when (wadr2_i = 15 and wen2 = '1') else
    reg_pcv_al;

  ---- CPSR
  -- Assign input values when writeback is enabled and marked as invalid
  -- otherwise use old value
  reg_cry <= wcry when (cpsr_wb = '1' and reg_cznv_s = '0') else
    reg_c_s;
  reg_zero <= wzero when (cpsr_wb = '1' and reg_cznv_s = '0') else
    reg_z_s;
  reg_neg <= wneg when (cpsr_wb = '1' and reg_cznv_s = '0') else
    reg_n_s;
  reg_ovr <= wovr when (cpsr_wb = '1' and reg_vv_s = '0') else
    reg_v_s;
  -- Mark as valid when writeback is enabled, else take old value
  reg_cznv <= '1' when cpsr_wb = '1' else
    reg_cznv_s;
  reg_vv <= '1' when cpsr_wb = '1' else
    reg_vv_s;
end behavioral_reg;