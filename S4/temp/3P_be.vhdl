library ieee;
use ieee.std_logic_1164.all;

entity C3P is
  port
  (
    A, B : in std_logic;
    C    : in std_logic;
    S1   : out std_logic;
    S2   : out std_logic);
end C3P;

architecture dataflow of C3P is

  signal X : std_logic;

begin
  process (A, B, C)
    variable X : std_logic;
  begin
    X := A and B;
    S1 <= C xor X;
  end process;

  process (C, A)
    variable CetA : std_logic_vector(1 downto 0);
  begin
    CetA := C & A;
    case CetA is
      when "00"   => S2   <= '1';
      when others => S2 <= '0';
    end case;
  end process;

end dataflow;