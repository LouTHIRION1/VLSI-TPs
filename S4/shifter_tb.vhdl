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

    -- LSL
    shift_lsl_s <= '1';
    din_s       <= x"00000001";
    shift_val_s <= "00001";
    wait for 1 ns;
    assert(dout_s = x"00000010") report "Incorrect shift, dout = 0x" & to_hstring(dout_s) severity error;
    assert(cout_s = '0') report "Incorrect carry out" severity error;

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