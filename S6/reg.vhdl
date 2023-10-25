library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Reg is
  port
  (
    ---- Write interface
    -- Write Port 1 prioritaire (EXEC stage)
    wdata1 : in std_logic_vector(31 downto 0);
    wadr1  : in std_logic_vector(3 downto 0); -- Register address (0 - 16)
    wen1   : in std_logic;                    -- Enable port

    -- Write Port 2 non prioritaire (MEM stage)
    wdata2 : in std_logic_vector(31 downto 0);
    wadr2  : in std_logic_vector(3 downto 0); -- Register address (0 - 16)
    wen2   : in std_logic;                    -- Enable port

    -- Write CSPR (Current Program Status Register) Port
    wneg    : in std_logic; -- Write N flag
    wzero   : in std_logic; -- Write Z flag
    wcry    : in std_logic; -- Write C flag
    wovr    : in std_logic; -- Write V flag
    cpsr_wb : in std_logic; -- CPSR register writeback enable {S}

    ---- Read interface
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

    -- global interface
    clk     : in std_logic; -- Clock
    reset_n : in std_logic; -- Reset (active low)
    vdd     : in bit;
    vss     : in bit);
end Reg;

architecture behavioral_reg of Reg is
  -- Registers 1 - 12
  signal reg0  : std_logic_vector(31 downto 0);
  signal reg1  : std_logic_vector(31 downto 0);
  signal reg2  : std_logic_vector(31 downto 0);
  signal reg3  : std_logic_vector(31 downto 0);
  signal reg4  : std_logic_vector(31 downto 0);
  signal reg5  : std_logic_vector(31 downto 0);
  signal reg6  : std_logic_vector(31 downto 0);
  signal reg7  : std_logic_vector(31 downto 0);
  signal reg8  : std_logic_vector(31 downto 0);
  signal reg9  : std_logic_vector(31 downto 0);
  signal reg10 : std_logic_vector(31 downto 0);
  signal reg11 : std_logic_vector(31 downto 0);
  signal reg12 : std_logic_vector(31 downto 0);
  -- Register SP
  signal reg13 : std_logic_vector(31 downto 0);
  -- Register LR
  signal reg14 : std_logic_vector(31 downto 0);
  -- Register PC
  signal reg15 : std_logic_vector(31 downto 0);
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

begin
  process (clk)
  begin
    -- Synchronous
    if rising_edge(clk) then
      -- Reset
      if (reset_n = '0') then
        -- Invalidate Register ports
        reg_v1 <= '1';
        reg_v2 <= '1';
        reg_v3 <= '1';
        -- Reset CPSR
        reg_cry  <= '0'; -- C fag
        reg_zero <= '0'; -- Z flag
        reg_neg  <= '0'; -- N flag
        reg_ovr  <= '0'; -- V flag
        reg_cznv <= '0'; -- CZN Validity bit (logic)
        reg_vv   <= '0'; -- V Validity bit (arithmetic)

        reg_v <= x"F_F_F_F"; -- Validate all registers regardless of what's stored inside them 
      else
        -- Write CPSR register when writeback is enabled
        if (cpsr_wb = '1') then
          -- When CZN is invalid
          if (reg_cznv_s = '0') then
            reg_neg  <= wneg;
            reg_zero <= wzero;
            reg_cry  <= wcry;
            reg_cznv_s = '1'; -- Validate after affecting values
          end if;

          -- When V is invalid
          if (reg_vv_s = '0') then
            reg_ovr <= wovr;
            reg_vv_s = '1'; -- Validate after affecting values
          end if;
        end if;

        -- Take address of the register to be written, save the data and validate the register afterwards
        -- TODO: à completer pour wadr2
        case (wadr1) is
          when x"0" =>
            -- Verify if the regiter is invalid
            if (regs_v and not ("0000_0000_0000_0001"))
              reg0   <= wdata1;
              regs_v <= regs_v or "0000_0000_0000_0001";
            end if;

          when x"1" =>
            if (regs_v and not ("0000_0000_0000_0010"))
              reg0   <= wdata1;
              regs_v <= regs_v or "0000_0000_0000_0010";
            end if;

          when x"2" =>
            if (regs_v and not ("0000_0000_0000_0100"))
              reg0   <= wdata1;
              regs_v <= regs_v or "0000_0000_0000_0100";
            end if;

          when x"3" =>
            if (regs_v and not ("0000_0000_0000_1000"))
              reg0   <= wdata1;
              regs_v <= regs_v or "0000_0000_0000_1000";
            end if;

          when x"4" =>
            if (regs_v and not ("0000_0000_0001_0000"))
              reg0   <= wdata1;
              regs_v <= regs_v or "0000_0000_0001_0000";
            end if;

          when x"5" =>
            if (regs_v and not ("0000_0000_0010_0000"))
              reg0   <= wdata1;
              regs_v <= regs_v or "0000_0000_0010_0000";
            end if;

          when x"6" =>
            if (regs_v and not ("0000_0000_0100_0000"))
              reg0   <= wdata1;
              regs_v <= regs_v or "0000_0000_0100_0000";
            end if;

          when x"7" =>
            if (regs_v and not ("0000_0000_1000_0000"))
              reg0   <= wdata1;
              regs_v <= regs_v or "0000_0000_1000_0000";
            end if;

          when x"8" =>
            if (regs_v and not ("0000_0001_0000_0000"))
              reg0   <= wdata1;
              regs_v <= regs_v or "0000_0001_0000_0000";
            end if;

          when x"9" =>
            if (regs_v and not ("0000_0010_0000_0000"))
              reg0   <= wdata1;
              regs_v <= regs_v or "0000_0010_0000_0000";
            end if;

          when x"A" =>
            if (regs_v and not ("0000_0100_0000_0000"))
              reg0   <= wdata1;
              regs_v <= regs_v or "0000_0100_0000_0000";
            end if;

          when x"B" =>
            if (regs_v and not ("0000_1000_0000_0000"))
              reg0   <= wdata1;
              regs_v <= regs_v or "0000_1000_0000_0000";
            end if;

          when x"C" =>
            if (regs_v and not ("0001_0000_0000_0000"))
              reg0   <= wdata1;
              regs_v <= regs_v or "0001_0000_0000_0000";
            end if;

          when x"D" =>
            if (regs_v and not ("0010_0000_0000_0000"))
              reg0   <= wdata1;
              regs_v <= regs_v or "0010_0000_0000_0000";
            end if;

          when x"E" =>
            if (regs_v and not ("0100_0000_0000_0000"))
              reg0   <= wdata1;
              regs_v <= regs_v or "0100_0000_0000_0000";
            end if;

          when x"F" =>
            if (regs_v and not ("1000_0000_0000_0000"))
              reg0   <= wdata1;
              regs_v <= regs_v or "1000_0000_0000_0000";
            end if;
        end case;

        case (wadr2) is
          when x"0" =>
            -- Verify if the regiter is invalid
            if (regs_v and not ("0000_0000_0000_0001"))
              reg0   <= wdata2;
              regs_v <= regs_v or "0000_0000_0000_0001";
            end if;

          when x"1" =>
            if (regs_v and not ("0000_0000_0000_0010"))
              reg0   <= wdata2;
              regs_v <= regs_v or "0000_0000_0000_0010";
            end if;

          when x"2" =>
            if (regs_v and not ("0000_0000_0000_0100"))
              reg0   <= wdata2;
              regs_v <= regs_v or "0000_0000_0000_0100";
            end if;

          when x"3" =>
            if (regs_v and not ("0000_0000_0000_1000"))
              reg0   <= wdata2;
              regs_v <= regs_v or "0000_0000_0000_1000";
            end if;

          when x"4" =>
            if (regs_v and not ("0000_0000_0001_0000"))
              reg0   <= wdata2;
              regs_v <= regs_v or "0000_0000_0001_0000";
            end if;

          when x"5" =>
            if (regs_v and not ("0000_0000_0010_0000"))
              reg0   <= wdata2;
              regs_v <= regs_v or "0000_0000_0010_0000";
            end if;

          when x"6" =>
            if (regs_v and not ("0000_0000_0100_0000"))
              reg0   <= wdata2;
              regs_v <= regs_v or "0000_0000_0100_0000";
            end if;

          when x"7" =>
            if (regs_v and not ("0000_0000_1000_0000"))
              reg0   <= wdata2;
              regs_v <= regs_v or "0000_0000_1000_0000";
            end if;

          when x"8" =>
            if (regs_v and not ("0000_0001_0000_0000"))
              reg0   <= wdata2;
              regs_v <= regs_v or "0000_0001_0000_0000";
            end if;

          when x"9" =>
            if (regs_v and not ("0000_0010_0000_0000"))
              reg0   <= wdata2;
              regs_v <= regs_v or "0000_0010_0000_0000";
            end if;

          when x"A" =>
            if (regs_v and not ("0000_0100_0000_0000"))
              reg0   <= wdata2;
              regs_v <= regs_v or "0000_0100_0000_0000";
            end if;

          when x"B" =>
            if (regs_v and not ("0000_1000_0000_0000"))
              reg0   <= wdata2;
              regs_v <= regs_v or "0000_1000_0000_0000";
            end if;

          when x"C" =>
            if (regs_v and not ("0001_0000_0000_0000"))
              reg0   <= wdata2;
              regs_v <= regs_v or "0001_0000_0000_0000";
            end if;

          when x"D" =>
            if (regs_v and not ("0010_0000_0000_0000"))
              reg0   <= wdata2;
              regs_v <= regs_v or "0010_0000_0000_0000";
            end if;

          when x"E" =>
            if (regs_v and not ("0100_0000_0000_0000"))
              reg0   <= wdata2;
              regs_v <= regs_v or "0100_0000_0000_0000";
            end if;

          when x"F" =>
            if (regs_v and not ("1000_0000_0000_0000"))
              reg0   <= wdata2;
              regs_v <= regs_v or "1000_0000_0000_0000";
            end if;
        end case;
      end if;
    end if;
  end process;
end behavioral_reg;