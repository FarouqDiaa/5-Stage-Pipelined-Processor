LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY FlagReg IS
    GENERIC (n : INTEGER := 3); -- Number of flags
    PORT (
        clk : IN STD_LOGIC; -- Clock signal
        rst : IN STD_LOGIC; -- Reset signal
        en : IN STD_LOGIC; -- Enable signal for writing flags
        flag : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0); -- Current flags to update (come from alu)
        flag_out : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0); -- Output flags
        -- BranchEnable : IN STD_LOGIC; -- Clear Zero flag during branching
        save_flags : IN STD_LOGIC; -- Save current flags (INT)
        restore_flags : IN STD_LOGIC; -- Restore saved flags (RTI)
        restored_flags : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0); -- Flags to RESTORE FROM STACK
        saved_flags : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0) -- Flags to save on interrupt
    );
END FlagReg;

ARCHITECTURE Behavioral OF FlagReg IS
    SIGNAL internal_flags : STD_LOGIC_VECTOR(n - 1 DOWNTO 0); -- Internal flag storage
    SIGNAL saved_flags_reg : STD_LOGIC_VECTOR(n - 1 DOWNTO 0); -- Storage for saved flags
BEGIN
    PROCESS (clk, rst)
    BEGIN
        IF rst = '1' THEN
            internal_flags <= (OTHERS => '0');
            saved_flags_reg <= (OTHERS => '0');
        ELSIF rising_edge(clk) THEN
            IF save_flags = '1' THEN
                saved_flags_reg <= internal_flags; -- Save current flags during INT
            ELSIF restore_flags = '1' THEN
                internal_flags <= restored_flags; -- Restore saved flags during RTI
                -- ELSIF BranchEnable = '1' THEN
                --     internal_flags(0) <= '0'; -- Clear Zero flag during branching
            ELSIF en = '1' THEN
                internal_flags <= flag; -- Normal flag update
            ELSE
                internal_flags <= internal_flags;
            END IF;
        END IF;
    END PROCESS;

    -- Output connections
    flag_out <= internal_flags;
    saved_flags <= saved_flags_reg;
END Behavioral;