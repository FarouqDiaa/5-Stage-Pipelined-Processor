LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_unsigned.all;

ENTITY SP IS
    PORT( 
        clk: IN std_logic;
        rst: IN std_logic;
		  sp_in : in std_logic_vector(15 DOWNTO 0);
        sp_out : out std_logic_vector(15 DOWNTO 0)
    );
END SP;

ARCHITECTURE sp_architecture OF SP IS
signal sp_signal : std_logic_vector(15 DOWNTO 0) := x"0FFF";

BEGIN
    PROCESS (clk, rst)
    BEGIN
        IF rst = '1' THEN
            sp_signal <= x"0FFF";
        ELSIF rising_edge(clk) THEN
            sp_signal <= sp_in;
        END IF;
    END PROCESS;
	 
    sp_out <= sp_signal;
	 
END sp_architecture;