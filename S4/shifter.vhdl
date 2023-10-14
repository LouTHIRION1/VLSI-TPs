library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Declaration de l'interface
entity Shifter is port
(
  shift_lsl : in std_logic; -- Logic Shift Left
  shift_lsr : in std_logic; -- Logic Shift Right
  shift_asr : in std_logic; -- Arithmetic Shift Right
  shift_ror : in std_logic; -- ROtate Right
  shift_rrx : in std_logic; -- Rotate Right eXtended
  shift_val : in std_logic_vector(4 downto 0); -- Shift Value

  din : in std_logic_vector(31 downto 0); -- Data in
  cin : in std_logic; -- Carry in

  dout : out std_logic_vector(31 downto 0); -- Data out
  cout : out std_logic; -- Carry out

  -- global interface
  vdd : in bit;
  vss : in bit);
end Shifter;

-- Description de l'alu
architecture Behavioral of Shifter is
  process (
    shift_lsl,
    shift_lsr,
    shift_asr,
    shift_ror,
    shift_rrx,
    shift_val,
    )
  begin
    -- TODO
  end process;
end Behavioral;