LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY BranchingExecuteUnit IS
    PORT (
        reset : IN STD_LOGIC;
        ZeroFlag : IN STD_LOGIC; -- Flag for JZ (Jump if Zero)
        CarryFlag : IN STD_LOGIC; -- Flag for JC (Jump if Carry)
        NegativeFlag : IN STD_LOGIC; -- Flag for JN (Jump if Negative)
        PCPlus1 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); -- Next sequential PC address
        ConditionalJumpAddress : IN STD_LOGIC_VECTOR(15 DOWNTO 0); -- Address for conditional jumps
        ConditionalJumpZero : IN STD_LOGIC; -- Indicates a conditional jump (JZ)
        ConditionalJumpNegative : IN STD_LOGIC; -- Indicates a conditional jump (JN)
        ConditionalJumpCarry : IN STD_LOGIC; -- Indicates a conditional jump (JC)
        UnconditionalJump : IN STD_LOGIC; -- Indicates an unconditional jump (e.g., JMP, CALL, RET)
        FlushDecode : OUT STD_LOGIC; -- Control signal to flush the decode stage
        FlushExecute : OUT STD_LOGIC; -- Control signal to flush the execute stage
        ChangePC : OUT STD_LOGIC; -- Control signal to change the PC
        JumpAddress : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) -- Address to jump to
    );
END BranchingExecuteUnit;

ARCHITECTURE Behavioral OF BranchingExecuteUnit IS
BEGIN
    -- FlushDecode: Flush the decode stage if a branch is taken
    FlushDecode <= '0' WHEN reset = '1' ELSE
        '1' WHEN UnconditionalJump = '1' ELSE -- Flush on unconditional jump
        '1' WHEN ConditionalJumpZero = '1' AND (ZeroFlag = '1') ELSE
        '1' WHEN ConditionalJumpNegative = '1' AND (NegativeFlag = '1') ELSE
        '1' WHEN ConditionalJumpCarry = '1' AND (CarryFlag = '1') ELSE
        '0'; -- No flush otherwise

    -- FlushExecute: Flush the execute stage under similar conditions
    FlushExecute <= '0' WHEN reset = '1' ELSE
        '1' WHEN UnconditionalJump = '1' ELSE -- Flush on unconditional jump
        '1' WHEN ConditionalJumpZero = '1' AND (ZeroFlag = '1') ELSE
        '1' WHEN ConditionalJumpNegative = '1' AND (NegativeFlag = '1') ELSE
        '1' WHEN ConditionalJumpCarry = '1' AND (CarryFlag = '1') ELSE
        '0'; -- No flush otherwise

    -- ChangePC: Change the PC if a branch is taken
    ChangePC <= '0' WHEN reset = '1' ELSE
        '1' WHEN UnconditionalJump = '1' ELSE -- Always change PC on unconditional jump
        '1' WHEN ConditionalJumpZero = '1' AND (ZeroFlag = '1') ELSE
        '1' WHEN ConditionalJumpNegative = '1' AND (NegativeFlag = '1') ELSE
        '1' WHEN ConditionalJumpCarry = '1' AND (CarryFlag = '1') ELSE
        '0'; -- No change otherwise

    -- JumpAddress: Set the jump address if the branch is taken
    JumpAddress <= (OTHERS => '0') WHEN reset = '1' ELSE
        ConditionalJumpAddress WHEN UnconditionalJump = '1' ELSE -- Unconditional jump
        ConditionalJumpAddress WHEN (ConditionalJumpZero = '1' AND (ZeroFlag = '1')) OR (ConditionalJumpNegative = '1' AND (NegativeFlag = '1')) OR (ConditionalJumpCarry = '1' AND (CarryFlag = '1')) ELSE
        (OTHERS => '0'); -- Default address otherwise
END Behavioral;