-- Testbench for adder
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity shifter_tb is
  -- empty (test bench)
end shifter_tb;

architecture testbench of shifter_tb is

  -- DUT component
  component Shifter is
    port
    (
      -- Type of instruction
      shift_lsl : in std_logic; -- Logic Shift Left
      shift_lsr : in std_logic; -- Logic Shift Right
      shift_asr : in std_logic; -- Arithmetic Shift Right
      shift_ror : in std_logic; -- ROtate Right
      shift_rrx : in std_logic; -- Rotate Right eXtended
      -- Inputs
      shift_val : in std_logic_vector(4 downto 0);  -- Shift Value (2^5 = 32 possible places)
      din       : in std_logic_vector(31 downto 0); -- Data in
      cin       : in std_logic;                     -- Carry in
      -- Outputs
      dout : out std_logic_vector(31 downto 0); -- Data out
      cout : out std_logic;                     -- Carry out
      -- Global interface
      vdd : in bit;
      vss : in bit);
  end component;

  -- Type of instruction
  signal shift_lsl_s : std_logic; -- Logic Shift Left
  signal shift_lsr_s : std_logic; -- Logic Shift Right
  signal shift_asr_s : std_logic; -- Arithmetic Shift Right
  signal shift_ror_s : std_logic; -- ROtate Right
  signal shift_rrx_s : std_logic; -- Rotate Right eXtended
  -- Inputs
  signal shift_val_s : std_logic_vector(4 downto 0);  -- Shift Value (2^5 = 32 possible places)
  signal din_s       : std_logic_vector(31 downto 0); -- Data in
  signal cin_s       : std_logic;                     -- Carry in
  -- Outputs
  signal dout_s : std_logic_vector(31 downto 0); -- Data out
  signal cout_s : std_logic;                     -- Carry out
  -- Global interface
  signal vdd_s : bit;
  signal vss_s : bit;

begin
  -- Connect DUT
  DUT : shifter port map
  (
    shift_lsl => shift_lsl_s,
    shift_lsr => shift_lsr_s,
    shift_asr => shift_asr_s,
    shift_ror => shift_ror_s,
    shift_rrx => shift_rrx_s,
    shift_val => shift_val_s,
    din       => din_s,
    cin       => cin_s,
    dout      => dout_s,
    cout      => cout_s,
    vdd       => vdd_s,
    vss       => vss_s
  );
  process
  begin

    -- No shift
    report "Logical Shift Left tests." severity note;

    shift_lsl_s <= '1';
    din_s       <= x"00000001";
    shift_val_s <= "00000";
    wait for 1 ns;
    assert(dout_s = x"00000001") report "Incorrect shift, expected 0x00000002, dout = 0x" & to_hstring(dout_s) severity error;
    assert(cout_s = '0') report "Incorrect carry out"severity error;

    ---- LSL
    din_s       <= x"00000001";
    shift_val_s <= "00001";
    wait for 1 ns;
    assert(dout_s = x"00000002") report "Incorrect shift, expected 0x00000002, dout = 0x" & to_hstring(dout_s) severity error;
    assert(cout_s = '0') report "Incorrect carry out"severity error;

    -- LSL
    din_s       <= x"00000001";
    shift_val_s <= "00010";
    wait for 1 ns;
    assert(dout_s = x"00000004") report "Incorrect shift, expected 0x00000004, dout = 0x" & to_hstring(dout_s) severity error;
    assert(cout_s = '0') report "Incorrect carry out"severity error;

    -- LSL
    din_s       <= x"80000000";
    shift_val_s <= "00001";
    wait for 1 ns;
    assert(dout_s = x"00000000") report "Incorrect shift, expected 0x00000000, dout = 0x" & to_hstring(dout_s) severity error;
    assert(cout_s = '1') report "Incorrect carry out"severity error;

    ---- LSR
    report "Logical Shift Right tests." severity note;

    shift_lsl_s <= '0';
    shift_lsr_s <= '1';
    din_s       <= x"00000001";
    shift_val_s <= "00001";
    wait for 1 ns;
    assert(dout_s = x"00000000") report "Incorrect shift, expected 00000000, dout = 0x" & to_hstring(dout_s) severity error;
    assert(cout_s = '1') report "Incorrect carry out"severity error;

    -- LSR
    din_s       <= x"80000000";
    shift_val_s <= "00001";
    wait for 1 ns;
    assert(dout_s = x"40000000") report "Incorrect shift, expected 40000000, dout = 0x" & to_hstring(dout_s) severity error;
    assert(cout_s = '0') report "Incorrect carry out"severity error;

    -- LSR
    din_s       <= x"80000000";
    shift_val_s <= "00010";
    wait for 1 ns;
    assert(dout_s = x"20000000") report "Incorrect shift, expected 20000000, dout = 0x" & to_hstring(dout_s) severity error;
    assert(cout_s = '0') report "Incorrect carry out"severity error;

    ---- ASR
    report "Arithmetic Shift Right tests." severity note;

    shift_lsr_s <= '0';
    shift_asr_s <= '1';
    din_s       <= x"00000001";
    shift_val_s <= "00001";
    wait for 1 ns;
    assert(dout_s = x"00000000") report "Incorrect shift, expected 00000000, dout = 0x" & to_hstring(dout_s) severity error;
    assert(cout_s = '1') report "Incorrect carry out"severity error;

    -- ASR
    din_s       <= x"80000000";
    shift_val_s <= "00001";
    wait for 1 ns;
    assert(dout_s = x"C0000000") report "Incorrect shift, expected C0000000, dout = 0x" & to_hstring(dout_s) severity error;
    assert(cout_s = '0') report "Incorrect carry out"severity error;

    -- ASR
    din_s       <= x"80000000";
    shift_val_s <= "00010";
    wait for 1 ns;
    assert(dout_s = x"E0000000") report "Incorrect shift, expected E0000000, dout = 0x" & to_hstring(dout_s) severity error;
    assert(cout_s = '0') report "Incorrect carry out"severity error;

    ---- ROR
    report "Rotate Right Tests." severity note;

    shift_asr_s <= '0';
    shift_ror_s <= '1';

    cin_s       <= '0';
    din_s       <= x"00000001";
    shift_val_s <= "00001";
    wait for 1 ns;
    assert(dout_s = x"80000000") report "Incorrect shift, expected 80000000, dout = 0x" & to_hstring(dout_s) severity error;
    assert(cout_s = '1') report "Incorrect carry out"severity error;

    -- ROR
    din_s       <= x"80000000";
    shift_val_s <= "00001";
    wait for 1 ns;
    assert(dout_s = x"40000000") report "Incorrect shift, expected 40000000, dout = 0x" & to_hstring(dout_s) severity error;
    assert(cout_s = '0') report "Incorrect carry out"severity error;

    -- ROR
    din_s       <= x"0FFFFFFF";
    shift_val_s <= "00100";
    wait for 1 ns;
    assert(dout_s = x"F0FFFFFF") report "Incorrect shift, expected F0FFFFFF, dout = 0x" & to_hstring(dout_s) severity error;
    assert(cout_s = '1') report "Incorrect carry out"severity error;

    ---- RRX
    report "Rotate Right Extended Tests." severity note;

    shift_ror_s <= '0';
    shift_rrx_s <= '1';

    -- 1 00000001 -> 1 10000000
    cin_s       <= '1';
    din_s       <= x"00000001";
    shift_val_s <= "00001";
    wait for 1 ns;
    assert(dout_s = x"80000000") report "Incorrect shift, expected 80000000, dout = 0x" & to_hstring(dout_s) severity error;
    assert(cout_s = '1') report "Incorrect carry out"severity error;

    -- RRX
    din_s       <= x"80000000";
    shift_val_s <= "00001";
    wait for 1 ns;
    assert(dout_s = x"C0000000") report "Incorrect shift, expected C0000000, dout = 0x" & to_hstring(dout_s) severity error;
    assert(cout_s = '0') report "Incorrect carry out"severity error;

    -- RRX
    -- 0 11111111111111111111111111111111 -> 1 111101111111111111111111111111111
    -- 0 FFFFFFFF -> 1 BFFFFFFF
    cin_s       <= '0';
    din_s       <= x"FFFFFFFF";
    shift_val_s <= "00010";
    wait for 1 ns;
    assert(dout_s = x"BFFFFFFF") report "Incorrect shift, expected BFFFFFFF, dout = 0x" & to_hstring(dout_s) severity error;
    assert(cout_s = '1') report "Incorrect carry out"severity error;

    -- Clear inputs
    shift_lsl_s <= '0';
    shift_lsr_s <= '0';
    shift_asr_s <= '0';
    shift_ror_s <= '0';
    shift_rrx_s <= '0';
    shift_val_s <= "00000";
    din_s       <= x"00000000";
    cin_s       <= '0';

    report "Test done." severity note;
    wait;
  end process;
end testbench;