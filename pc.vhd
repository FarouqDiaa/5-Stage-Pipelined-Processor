LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY pc IS
    PORT (
        clk, reset, freeze_signal, hlt_signal : IN STD_LOGIC;
        address : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        counter : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
END pc;
ARCHITECTURE pc_arch OF pc IS
    SIGNAL c_counter : STD_LOGIC_VECTOR(15 DOWNTO 0) := X"0200"; -- Default value is 200 hex
BEGIN
    PROCESS (clk, reset)
    BEGIN
        -- Reset the counter to 200 hex
        IF reset = '1' THEN
            c_counter <= X"0200"; -- Reset value to 200 hex
        ELSIF falling_edge(clk) THEN
            -- Keep the counter as it is if halt or freeze signals are active
            IF hlt_signal = '1' OR freeze_signal = '1' THEN
                NULL; -- Do nothing, keep the counter as is
            ELSE
                -- Take the input address and update the counter
                c_counter <= address;
            END IF;
        END IF;
    END PROCESS;
-- Assign the internal counter to the output
counter <= c_counter;
END ARCHITECTURE;