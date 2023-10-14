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
	PROCESS (A, B, C)
	VARIABLE X : std_logic;
	BEGIN
		X := A AND B;
		S1 <= C XOR X;
	END PROCESS;

	PROCESS (C, A)
	VARIABLE CetA : std_logic_vector(1 DOWNTO 0);
	BEGIN
		CetA := C & A;
		CASE CetA IS
			WHEN "00" => S2 <= '1';
			WHEN OTHERS => S2 <= '0';
		END CASE;
	END PROCESS;

end dataflow;
