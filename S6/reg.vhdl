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
    vss     : in bit;

    -- Probe (Comment if unused)
    probe : out std_logic_vector(15 downto 0)
  );
end Reg;

architecture behavioral_reg of Reg is
  -- TODO: Implement loops instead 
  -- TODO: Implement R16 PC behaviour
  type reg_arr is array (0 to 15) of std_logic_vector(31 downto 0); -- Array of 16 32-bit registers
  signal registre : reg_arr;

  -- Validity bits for each register
  signal regs_v : std_logic_vector(15 downto 0);

  -- CPSR
  signal n_s : std_logic;
  signal c_s : std_logic;
  signal z_s : std_logic;
  signal v_s : std_logic;
  -- CPSR Validity bits
  -- TODO: Affect signals correctly
  signal reg_cznv_s : std_logic;
  signal reg_vv_s   : std_logic;

  signal exec_conflict : std_logic; -- 1 when conflict between EXEC and MEM address 
  signal wadr1_int     : integer;
  signal wadr2_int     : integer;
begin

  wadr1_int <= to_integer(unsigned(wadr1));
  wadr2_int <= to_integer(unsigned(wadr2));

  process (clk)
  begin
    -- Synchronous
    if rising_edge(clk) then
      -- Reset
      if (reset_n = '0') then
        -- Validate Register ports
        reg_v1   <= '1';
        reg_v2   <= '1';
        reg_v3   <= '1';
        reg_cznv <= '1'; -- CZN Validity bit (logic)
        reg_vv   <= '1'; -- V Validity bit (arithmetic)
        -- TODO: Empty all registers
        -- Reset CPSR
        reg_cry  <= '0';             -- C fag
        reg_zero <= '0';             -- Z flag
        reg_neg  <= '0';             -- N flag
        reg_ovr  <= '0';             -- V flag
        regs_v   <= (others => '1'); -- Validate all registers regardless of what's stored inside them 

      else
        -- Write CPSR register when writeback is enabled
        if (cpsr_wb = '1') then
          -- When CZN is invalid
          if (reg_cznv_s = '0') then
            reg_neg    <= wneg;
            reg_zero   <= wzero;
            reg_cry    <= wcry;
            reg_cznv_s <= '1'; -- Validate after affecting values
          end if;

          -- When V is invalid
          if (reg_vv_s = '0') then
            reg_ovr  <= wovr;
            reg_vv_s <= '1'; -- Validate after affecting values
          end if;
        end if;

        -- Assign invalidation bit to the register corresponding to the address
        regs_v(to_integer(unsigned(inval_adr1))) <= inval1;
        regs_v(to_integer(unsigned(inval_adr2))) <= inval2;

        -- Take address of the register to be written, save the data and validate the register afterwards
        for i in 0 to 15 loop
          -- Verify register is invalidated TODO: Verify
          if (regs_v(i) = '0') then
            -- Check if there is a conflict between wadr1 and wadr2
            if (wadr1 = wadr2) then
              -- Discard MEM result in case of conflict as it's older than the result from EXEC
              registre(wadr1_int) <= wdata1 when (wen1 = '1' and i = wadr1_int);
            else
              -- No conflict, save both MEM and EXEC results
              registre(wadr1_int) <= wdata1 when (wen1 = '1');
              registre(wadr2_int) <= wdata2 when (wen2 = '1');
            end if;
            -- Validate after writing
            regs_v(i) <= '1';
          end if;
        end loop;

        reg_rd1 <= registre(to_integer(unsigned(radr1)));
        reg_rd2 <= registre(to_integer(unsigned(radr2)));
        reg_rd3 <= registre(to_integer(unsigned(radr3)));

        reg_v1 <= regs_v(to_integer(unsigned(radr1)));
        reg_v2 <= regs_v(to_integer(unsigned(radr2)));
        reg_v3 <= regs_v(to_integer(unsigned(radr3)));

      end if; -- Reset
    end if; -- Rising edge
  end process;
end behavioral_reg;