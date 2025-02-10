LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY ForwardingUnit IS
    PORT (
        Rs : IN STD_LOGIC_VECTOR(2 DOWNTO 0); -- Source register 1
        Rt : IN STD_LOGIC_VECTOR(2 DOWNTO 0); -- Source register 2
        WBEX_M : IN STD_LOGIC; -- Write-back enable from EX/MEM
        WBM_WB : IN STD_LOGIC; -- Write-back enable from MEM/WB
        RegDesE_M : IN STD_LOGIC_VECTOR(2 DOWNTO 0); -- Destination register EX/MEM
        RegDesM_WB : IN STD_LOGIC_VECTOR(2 DOWNTO 0); -- Destination register MEM/WB
        MemToReg_M_WB : IN STD_LOGIC; -- Memory-to-register signal from MEM/WB
        ForwardA : OUT STD_LOGIC_VECTOR(1 DOWNTO 0); -- Forward control for ALU input A
        ForwardB : OUT STD_LOGIC_VECTOR(1 DOWNTO 0) -- Forward control for ALU input B
        ----UseMemResult : OUT STD_LOGIC -- Indicates if forwarding memory result
    );
END ENTITY ForwardingUnit;

ARCHITECTURE Behavioral OF ForwardingUnit IS
BEGIN
    PROCESS (Rs, Rt, WBEX_M, WBM_WB, RegDesE_M, RegDesM_WB, MemToReg_M_WB)
    BEGIN
        -- Default values (no forwarding)
        ForwardA <= "00";
        ForwardB <= "00";
        --UseMemResult <= '0';

        -- Check for forwarding to ALU input A
        IF WBEX_M = '1' AND RegDesE_M = Rs THEN
            ForwardA <= "01"; -- Forward from EX/MEM
        ELSIF WBM_WB = '1' AND RegDesM_WB = Rs THEN

                ForwardA <= "10"; -- Forward memory result from MEM/WB
                --UseMemResult <= '1'; -- Memory result is being used
        END IF;

        -- Check for forwarding to ALU input B
        IF WBEX_M = '1' AND RegDesE_M = Rt THEN
            ForwardB <= "01"; -- Forward from EX/MEM
        ELSIF WBM_WB = '1' AND RegDesM_WB = Rt THEN

                ForwardB <= "10"; -- Forward memory result from MEM/WB
                --UseMemResult <= '1'; -- Memory result is being used
        END IF;
    END PROCESS;
END ARCHITECTURE Behavioral;

-- forward a/b  --------> 00  ---->no forwarding
--                        01  ---->Forward from EX/MEM
--                        10  ---->Forward memory or alu result from MEM/WB
--                   