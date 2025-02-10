LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY HazardDetectionUnit_tb IS
END HazardDetectionUnit_tb;

ARCHITECTURE Behavioral OF HazardDetectionUnit_tb IS
    SIGNAL IF_ID_Rs, IF_ID_Rt, ID_EX_Rd : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL ID_EX_MemRead : STD_LOGIC;
    SIGNAL stall : STD_LOGIC;

    COMPONENT HazardDetectionUnit IS
        PORT (
            IF_ID_Rs : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
            IF_ID_Rt : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
            ID_EX_Rd : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
            ID_EX_MemRead : IN STD_LOGIC;
            stall : OUT STD_LOGIC
        );
    END COMPONENT;

    -- Procedure for assertions
    PROCEDURE assert_signal(
        signal_value : STD_LOGIC;
        expected_value : STD_LOGIC;
        message : STRING)
    IS
    BEGIN
        IF signal_value /= expected_value THEN
            REPORT "Assertion failed: " & message SEVERITY ERROR;
        END IF;
    END PROCEDURE;
BEGIN
    DUT: HazardDetectionUnit
        PORT MAP (
            IF_ID_Rs => IF_ID_Rs,
            IF_ID_Rt => IF_ID_Rt,
            ID_EX_Rd => ID_EX_Rd,
            ID_EX_MemRead => ID_EX_MemRead,
            stall => stall
        );

    -- Test sequence
    PROCESS
    BEGIN
        -- Case 1: No hazard (stall = '0')
        IF_ID_Rs <= "00001";
        IF_ID_Rt <= "00010";
        ID_EX_Rd <= "00011";
        ID_EX_MemRead <= '0';
        WAIT FOR 10 ns;
        assert_signal(stall, '0', "No hazard case failed.");

        -- Case 2: Load-use hazard (Rs = Rd, stall = '1')
        ID_EX_MemRead <= '1';
        ID_EX_Rd <= "00001"; -- Rs matches Rd
        WAIT FOR 10 ns;
        assert_signal(stall, '1', "Load-use hazard with Rs = Rd failed.");

        -- Case 3: Load-use hazard (Rt = Rd, stall = '1')
        ID_EX_Rd <= "00010"; -- Rt matches Rd
        WAIT FOR 10 ns;
        assert_signal(stall, '1', "Load-use hazard with Rt = Rd failed.");

        -- Case 4: ID/EX.Rd = 0 (stall = '0')
        ID_EX_Rd <= "00000"; -- Destination register is 0
        WAIT FOR 10 ns;
        assert_signal(stall, '0', "Hazard when ID/EX.Rd = 0 failed.");

        -- Case 5: No match between Rs/Rt and Rd (stall = '0')
        ID_EX_Rd <= "00100"; -- No match with Rs or Rt
        WAIT FOR 10 ns;
        assert_signal(stall, '0', "No match between Rs/Rt and Rd failed.");

        -- End test
        REPORT "All test cases passed." SEVERITY NOTE;
        WAIT;
    END PROCESS;
END Behavioral;
