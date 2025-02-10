library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity partb is
    port(
        A, B : in std_logic_vector(7 downto 0); 
        SEL  : in std_logic_vector(3 downto 0); 
        F    : out std_logic_vector(7 downto 0); 
        Cout : out std_logic                    
    );
end partb;


architecture SimpleALUArch of partb is

begin

    F <= A xor B when SEL (1 downto 0) = "00"  
         else A NAND B when SEL (1 downto 0) = "01"  
         else A OR B when SEL (1 downto 0) = "10"    
         else NOT A when SEL (1 downto 0)="11"
			else "00000000";
    Cout <= '0';

end SimpleALUArch;


