LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY instruction_memory IS
    PORT (
        clk : IN STD_LOGIC;
        address : IN STD_LOGIC_VECTOR(11 DOWNTO 0); -- size of PC is 16 but we only use the first 12
        instruction1 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0); -- Current instruction
        instruction2 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0); -- Next instruction
        interrupt_0 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        interrupt_1 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
END instruction_memory;

ARCHITECTURE instruction_memory_arch OF instruction_memory IS
    -- Memory array: 4K x 16 bits
    TYPE memory_array IS ARRAY (0 TO 4095) OF STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL memory : memory_array := (OTHERS => (OTHERS => '0'));
    --SIGNAL fetched_instruction1 : STD_LOGIC_VECTOR(15 DOWNTO 0) := "1100000100101100";
    --SIGNAL fetched_instruction2 : STD_LOGIC_VECTOR(15 DOWNTO 0) := "1100100100001001";
BEGIN
    instruction1 <= memory(to_integer(unsigned(address(11 DOWNTO 0))));
    instruction2 <= memory(to_integer(unsigned(address(11 DOWNTO 0)) + 1));
    interrupt_0 <= memory(16#0800#); -- Convert binary string to unsigned
    interrupt_1 <= memory(16#0A00#); -- Convert binary string to unsigned


END instruction_memory_arch;