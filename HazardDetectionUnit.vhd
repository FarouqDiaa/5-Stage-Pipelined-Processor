LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY HazardDetectionUnit IS
    PORT (
        IF_ID_Rs : IN STD_LOGIC_VECTOR(2 DOWNTO 0); -- (Rs) from fetech decode
        IF_ID_Rt : IN STD_LOGIC_VECTOR(2 DOWNTO 0); -- (Rt) from fetech decode
        ID_EX_Rd : IN STD_LOGIC_VECTOR(2 DOWNTO 0); -- Destination register (Rd) from decode execute
        ID_EX_MemRead : IN STD_LOGIC; -- Memory read signal from decode execute
        stall : OUT STD_LOGIC -- Stall signal
    );
END HazardDetectionUnit;

ARCHITECTURE Behavioral OF HazardDetectionUnit IS
BEGIN
    PROCESS( IF_ID_Rs, IF_ID_Rt, ID_EX_Rd, ID_EX_MemRead)
    BEGIN
        IF (ID_EX_MemRead = '1' AND ID_EX_Rd /= "000" AND
              (IF_ID_Rs = ID_EX_Rd OR IF_ID_Rt = ID_EX_Rd)) THEN
            stall <= '1'; -- Stall on load-use hazard
        ELSE
            stall <= '0'; -- No hazard, no stall
        END IF;
    END PROCESS;
END Behavioral;
