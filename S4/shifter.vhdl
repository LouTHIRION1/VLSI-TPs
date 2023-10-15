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
  cin       : in std_logic := '0';              -- Carry in
  -- Outputs
  dout : out std_logic_vector(31 downto 0); -- Data out
  cout : out std_logic := '0';              -- Carry out
  -- Global interface
  vdd : in bit;
  vss : in bit);
end Shifter;

architecture Behavioral of Shifter is
  signal dout_s : std_logic_vector(32 downto 0);
  signal temp   : std_logic_vector(31 downto 0);
  signal din_s  : std_logic_vector(32 downto 0);
  signal cout_s : std_logic := '0';
begin
  process (din, din_s, dout_s, temp, shift_val, cin, shift_lsl, shift_lsr, shift_asr, shift_ror, shift_rrx) is
    variable shift_amount : integer := 0;
  begin
    shift_amount := to_integer(unsigned(shift_val));

    if (shift_lsl = '1') then
      din_s  <= '0' & din; -- Add extra bit at MSB to capture C flag
      dout_s <= std_logic_vector(shift_left(unsigned(din_s), shift_amount));
      cout_s <= dout_s(32); -- Capture C flag
      temp   <= dout_s(31 downto 0);

    elsif (shift_lsr = '1') then
      din_s  <= din & '0'; -- Add extra bit at LSB to capture C flag
      dout_s <= std_logic_vector(shift_right(unsigned(din_s), shift_amount));
      cout_s <= dout_s(0); -- Capture C flag
      temp   <= dout_s(32 downto 1);

    elsif (shift_asr = '1') then
      din_s  <= din & '0'; -- Add extra bit at LSB to capture C flag
      dout_s <= std_logic_vector(shift_right(signed(din_s), shift_amount));
      cout_s <= dout_s(0); -- Capture C flag
      temp   <= dout_s(32 downto 1);

    elsif (shift_ror = '1') then
      -- TODO: Fix logic for C flag
      temp   <= din; -- Add extra bit at LSB to capture C flag
      dout_s <= std_logic_vector(rotate_right(unsigned(temp), shift_amount));
      cout_s <= dout_s(0); -- Capture C flag
      temp   <= dout_s(32 downto 1);

    elsif (shift_rrx = '1') then
      din_s  <= cin & din; -- Concatenate C flag at MSB
      dout_s <= std_logic_vector(rotate_right(unsigned(din_s), shift_amount));
      cout_s <= dout_s(32); -- Capture C flag
      temp   <= dout_s(31 downto 0);

    end if;
  end process;

  -- Affect signals
  cout <= cout_s;
  dout <= temp;
end Behavioral;