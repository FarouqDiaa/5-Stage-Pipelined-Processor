LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY DataMemory IS
    GENERIC (
        addressWidth : INTEGER := 12;
        dataWidth    : INTEGER := 16
    );
    PORT (
		  clk 		: in std_logic;
        memRead   : in std_logic;
        memWrite  : in std_logic;
		  address   : in std_logic_vector(addressWidth - 1 DOWNTO 0); -- 12-bit address
		  data_in   : in std_logic_vector(dataWidth - 1 DOWNTO 0);    -- 16-bit data
        data_out  : out std_logic_vector(dataWidth - 1 DOWNTO 0)    -- 16-bit data
    );
END DataMemory;

ARCHITECTURE DataMemoryArch OF DataMemory IS

    TYPE memoryType IS ARRAY (0 TO (2 ** addressWidth - 1)) OF std_logic_vector(dataWidth - 1 DOWNTO 0);
    SIGNAL memory : memoryType := (others => (others => '0'));
	 
	 signal data_out_signal : std_logic_vector(15 downto 0) := (others => '0');
   
BEGIN

    process(memRead, memWrite, clk)
    begin
	  if rising_edge(clk) then 
        if memWrite = '1' then
            memory(to_integer(unsigned(address))) <= data_in;
            
        elsif memRead = '1' then
            data_out_signal <= memory(to_integer(unsigned(address))); 
        end if;
		end if;
    end process;
	 
	 data_out <= data_out_signal;

END DataMemoryArch;