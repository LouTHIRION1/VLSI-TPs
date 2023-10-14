library ieee;
use ieee.std_logic_1164.all;

--library work;
--use work.bidon.all;


--  A testbench has no ports.
entity c3p_tb is
end c3p_tb;

architecture Structurel of c3p_tb is
	--  Declaration un composant
	component C3P
	port (A, B : in std_logic;
			C : in std_logic;
			S1 : out std_logic;
			S2 : out std_logic);

	end component;

	signal A, B, C, S1, S2 : std_logic;

	begin
	C3P_0: C3P
	port map (	A => A,
					B => B,
					C => C,
					S1 => S1,
					S2 => S2);

process

function nat_to_std (v: in natural) return std_logic is
variable res : std_logic;
begin
	if v = 1 then
		res := '1';
	else
		res := '0';
	end if;
	return res;
end function nat_to_std;

variable vs1 : std_logic;
variable vs2 : std_logic;

begin
La : for va in 0 to 1 loop
	Lb : for vb in 0 to 1 loop
		Lc : for vc in 0 to 1 loop
			A <= nat_to_std(va);
			B <= nat_to_std(vb);
			C <= nat_to_std(vc);
			vs1 := nat_to_std(vc) xor ( nat_to_std(va) and nat_to_std(vb));
			vs2 := nat_to_std(vc) nor  nat_to_std(va);
			wait for 1 ns;
			assert vs1 = S1 report "Erreur sur S1" severity error;
			assert vs2 = S2 report "Erreur sur S2" severity error;
		end loop Lc;
	end loop Lb;
end loop La;
assert false report "end of test" severity note;
--  Wait forever; this will finish the simulation.
wait;
end process;
end Structurel;
