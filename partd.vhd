library ieee;
use ieee.std_logic_1164.all;

entity partd is 
	port(
		A:in std_logic_vector(7 downto 0);
		SEL:in std_logic_vector (3 downto 0);
		Cin:in std_logic;
		F:out std_logic_vector(7 downto 0);
		Cout:out std_logic
	);

end entity partd;


architecture rightAluArch of partd is
begin

	F <= '0' & A(7 downto 1) when SEL (1 downto 0)="00"
	else A(0) & A(7 downto 1) when SEL (1 downto 0)="01"
	else Cin & A(7 downto 1) when SEL (1 downto 0)="10"
	else A(7) & A(7 downto 1) when SEL (1 downto 0)="11"
	else "00000000";

	Cout <= A(0) when (SEL (1 downto 0) = "00" or SEL (1 downto 0) = "01" or SEL (1 downto 0) = "10") 
        else	'0';

end rightAluArch;