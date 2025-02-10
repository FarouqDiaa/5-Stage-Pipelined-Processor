LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY exception_handler IS
    PORT (
        -- 00: No Exception, 01: Stack Exception, 10: DM Exception, 11: IM Exception
        exception_type : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        reset : IN STD_LOGIC;
        next_pc : IN STD_LOGIC_VECTOR(15 DOWNTO 0); -- Next PC value
        exception_handler_signal : IN STD_LOGIC; -- Indicates that an exception occurred
        exception_address : OUT STD_LOGIC_VECTOR(15 DOWNTO 0); -- The Address in IM to handle the exception (2 bits are used)
        epc : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) -- Exception Program Counter
    );
END exception_handler;

ARCHITECTURE exception_handler_arch OF exception_handler IS
BEGIN
    PROCESS (reset, exception_handler_signal)
    BEGIN
        IF reset = '1' THEN
            -- Reset all outputs
            exception_address <= "0000000000000000";
            epc <= (OTHERS => '0');
        ELSIF exception_handler_signal = '1' THEN
            -- Handle exceptions based on exception_type
            CASE exception_type IS
                WHEN "01" => -- Stack Exception
                    exception_address <= X"0400"; -- Address 1
                    epc <= STD_LOGIC_VECTOR(unsigned(next_pc) - 1);
                WHEN "10" => -- DM Exception
                    exception_address <= X"0600"; -- Address 2
                        epc <= STD_LOGIC_VECTOR(unsigned(next_pc) - 1);
                WHEN "11" => -- IM Exception
                    exception_address <= X"0600"; -- Address 2
                    epc <= next_pc; -- Save current PC
                WHEN OTHERS => -- No Exception or invalid exception type
                    exception_address <= "0000000000000000";
                    epc <= (OTHERS => '0');
            END CASE;
        ELSE
            exception_address <= "0000000000000000";
            epc <= (OTHERS => '0');
        END IF;
    END PROCESS;
END exception_handler_arch;