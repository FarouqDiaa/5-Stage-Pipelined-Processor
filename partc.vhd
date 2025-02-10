library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity partc is 
  port(
	A: in std_logic_vector(7 downto 0);
	SEL:in std_logic_vector(3 downto 0);
	Cin:in std_logic; 
	F: out std_logic_vector(7 downto 0);
	Cout:out std_logic
    );
end partc;


architecture leftALUArch of partc is 
begin 
	f<=A(6 downto 0) & '0' when SEL (1 downto 0) = "00" else
	A(6 downto 0 ) & A(7) when SEL (1 downto 0) = "01" else
	A(6 downto 0 ) & Cin when SEL (1 downto 0) = "10" else
	(others => '0');

	Cout <= A(7) when (SEL (1 downto 0) = "00" or SEL (1 downto 0) = "01" or SEL (1 downto 0) = "10") else
            '0';  
end leftALUArch;
