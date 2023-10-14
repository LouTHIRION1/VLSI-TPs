library ieee;
use ieee.std_logic_1164.all;

entity C3P is
port (A, B : in std_logic;
		C : in std_logic;
		S1 : out std_logic;
		S2 : out std_logic);
end C3P;

architecture dataflow of C3P is

signal X : std_logic;

begin
	X <= A AND B;
	S1 <= C XOR X;
	S2 <= C NOR A;

end dataflow;
