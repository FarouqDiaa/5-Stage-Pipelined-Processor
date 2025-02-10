LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;

ENTITY F_D_FF IS
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        data_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        data_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE f_dff_arch OF F_D_FF IS
    SIGNAL data_out_reg : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
BEGIN
    PROCESS (clk)
    BEGIN
        IF rst = '1' THEN
            data_out_reg <= x"0000";
        ELSIF rising_edge(clk) THEN
            data_out_reg <= data_in;
        END IF;
    END PROCESS;

    data_out <= data_out_reg;
END ARCHITECTURE;