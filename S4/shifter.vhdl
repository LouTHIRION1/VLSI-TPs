library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Declaration de l'interface
entity Shifter is port
(
  -- Type of instruction
  shift_lsl : in std_logic := '0'; -- Logic Shift Left
  shift_lsr : in std_logic := '0'; -- Logic Shift Right
  shift_asr : in std_logic := '0'; -- Arithmetic Shift Right
  shift_ror : in std_logic := '0'; -- ROtate Right
  shift_rrx : in std_logic := '0'; -- Rotate Right eXtended
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
end Shifter;

-- Description du shifter
architecture Behavioral of Shifter is
  signal dout_s : std_logic_vector(31 downto 0); -- Add one extra bit for cout
begin
  process (din, dout_s, shift_lsl, shift_lsr, shift_asr, shift_ror, shift_rrx) is
  begin
    if (shift_lsl = '1') then
      dout_s <= std_logic_vector(shift_left(unsigned(din), to_integer(unsigned(shift_val))));
    end if;
  end process;

  -- Affect signals
  dout <= dout_s(31 downto 0);
  -- cout <= dout_s(32);
end Behavioral;