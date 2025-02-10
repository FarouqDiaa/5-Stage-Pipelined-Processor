LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY ALU IS
    GENERIC (n : INTEGER := 16);
    PORT (
        A, B : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0); -- Two operands
        Sel : IN STD_LOGIC_VECTOR(4 DOWNTO 0); -- Select lines
        FlagsIn : IN STD_LOGIC_VECTOR(2 DOWNTO 0); -- Flags input (Zero, Negative,  Carry)
        FlagsOut : OUT STD_LOGIC_VECTOR(2 DOWNTO 0); -- Flags output (Zero, Negative,  Carry)
        Res : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0) -- Result
        --BranchEnable : IN STD_LOGIC
    );
END ENTITY ALU;

ARCHITECTURE Behavioral OF ALU IS
    -- Operations

    CONSTANT ALU_NOT : STD_LOGIC_VECTOR(4 DOWNTO 0) := "11000";
    CONSTANT ALU_INC : STD_LOGIC_VECTOR(4 DOWNTO 0) := "11001";
    CONSTANT ALU_ADD : STD_LOGIC_VECTOR(4 DOWNTO 0) := "11011";
    CONSTANT ALU_ADDI : STD_LOGIC_VECTOR(4 DOWNTO 0) := "01000";
    CONSTANT ALU_SUB : STD_LOGIC_VECTOR(4 DOWNTO 0) := "11100";
    CONSTANT ALU_AND : STD_LOGIC_VECTOR(4 DOWNTO 0) := "11101";
	 CONSTANT ALU_IN : STD_LOGIC_VECTOR(4 DOWNTO 0) := "00100";
	 CONSTANT ALU_MOV : STD_LOGIC_VECTOR(4 DOWNTO 0) := "11010";
	 CONSTANT ALU_LDM : STD_LOGIC_VECTOR(4 DOWNTO 0) := "01011";
	 CONSTANT ALU_LDD : STD_LOGIC_VECTOR(4 DOWNTO 0) := "01100";
	 CONSTANT ALU_STD : STD_LOGIC_VECTOR(4 DOWNTO 0) := "01101";
    -- CONSTANT ALU_A : STD_LOGIC_VECTOR(4 DOWNTO 0) := "11010"; -- Output readdata1
    -- CONSTANT ALU_B : STD_LOGIC_VECTOR(4 DOWNTO 0) := "11111"; -- output readdata2 or immediate
    SIGNAL TempOut : STD_LOGIC_VECTOR(n DOWNTO 0);
    -- SIGNAL TempCarryOut : STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
    SIGNAL TempA, TempB : STD_LOGIC_VECTOR(n DOWNTO 0);

BEGIN

    TempA <= '0' & A(n - 1 DOWNTO 0);
    TempB <= '0' & B(n - 1 DOWNTO 0);
    TempOut <= NOT TempA WHEN Sel = ALU_NOT
        ELSE
        STD_LOGIC_VECTOR(unsigned(TempA) + 1) WHEN Sel = ALU_INC
        ELSE
        STD_LOGIC_VECTOR(unsigned(TempA) + unsigned(TempB)) WHEN Sel = ALU_ADD OR Sel = ALU_ADDI OR Sel = ALU_LDD or Sel = ALU_STD
        ELSE
        STD_LOGIC_VECTOR(signed(TempA) - signed(TempB)) WHEN Sel = ALU_SUB
        ELSE
        TempA AND TempB WHEN Sel = ALU_AND
		  ELSE
        TempA WHEN Sel = ALU_IN or Sel = ALU_MOV
		  ELSE
        TempB WHEN Sel = ALU_LDM
		  ELSE TempA;

		  
        -- ELSE
        -- TempA WHEN Sel = ALU_A
        -- ELSE
        -- TempB WHEN Sel = ALU_B OR Sel = ALU_SWAP
       
    -- TempCarryOut <= STD_LOGIC_VECTOR(unsigned('0' & TempA(n - 2 DOWNTO 0)) + 1) WHEN Sel = ALU_INC
    --     ELSE
    --     STD_LOGIC_VECTOR(unsigned('0' & TempA(n - 2 DOWNTO 0)) - 1) WHEN Sel = ALU_DEC
    --     ELSE
    --     STD_LOGIC_VECTOR(unsigned('0' & TempA(n - 2 DOWNTO 0)) + unsigned('0' & TempB(n - 2 DOWNTO 0))) WHEN Sel = ALU_ADD OR Sel = ALU_ADDI
    --     ELSE
    --     STD_LOGIC_VECTOR(unsigned('0' & TempA(n - 2 DOWNTO 0)) - unsigned('0' & TempB(n - 2 DOWNTO 0))) WHEN Sel = ALU_SUB OR Sel = ALU_CMP OR Sel = ALU_SUBI;

    -- Zero flag
    FlagsOut(0) <= '1' WHEN (Sel = ALU_NOT OR Sel = ALU_INC OR Sel = ALU_ADD OR Sel = ALU_ADDI OR Sel = ALU_SUB OR Sel = ALU_AND) AND TempOut(n - 1 DOWNTO 0) = "0000000000000000"
ELSE
    '0' WHEN (Sel = ALU_NOT OR Sel = ALU_INC OR Sel = ALU_ADD OR Sel = ALU_ADDI OR Sel = ALU_SUB OR Sel = ALU_AND) AND TempOut(n - 1 DOWNTO 0) /= "0000000000000000"
ELSE
    FlagsIn(0);

    -- Negative flag
    FlagsOut(1) <=TempOut(n-2);
	 
    -- Carry flag
    FlagsOut(2) <= TempOut(n) WHEN (Sel = ALU_ADD OR Sel = ALU_ADDI OR Sel = ALU_SUB OR Sel = ALU_INC)
ELSE
    FlagsIn(2);

    Res <= TempOut(n - 1 DOWNTO 0);
END ARCHITECTURE Behavioral;