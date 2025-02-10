LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY axram IS
    PORT (
        clk           : IN std_logic;
        we            : IN std_logic;
        rst           : IN std_logic;
        read1_addres  : IN std_logic_vector(2 downto 0);
        read2_addres  : IN std_logic_vector(2 downto 0);
        write_adress  : IN std_logic_vector(2 downto 0);
        datain        : IN std_logic_vector(15 DOWNTO 0);
        dataout1      : OUT std_logic_vector(15 DOWNTO 0);
        dataout2      : OUT std_logic_vector(15 DOWNTO 0)
    );
END ENTITY axram;

ARCHITECTURE axsync_ram_a OF axram IS
    TYPE ram_type IS ARRAY(0 TO 7) OF std_logic_vector(15 DOWNTO 0); -- 8 registers, each 16 bits wide
    SIGNAL ram : ram_type := (others => (others => '0'));           -- Initialize RAM to zeros
BEGIN
    PROCESS(clk)
    BEGIN
		  IF rst = '1' THEN
                ram <= (others => (others => '0')); -- Clear RAM on reset
					 
        --elsIF rising_edge(clk) THEN
         --   dataout1 <= ram(to_integer(unsigned(read1_addres)));
			--	dataout2 <= ram(to_integer(unsigned(read2_addres)));
				
        ELSIF falling_edge(clk) and we = '1' THEN
                ram(to_integer(unsigned(write_adress))) <= datain; -- Write data to RAM
        END IF;
    END PROCESS;

    -- Read Logic with Forwarding
    --dataout1 <= datain WHEN (we = '1' AND read1_addres = write_adress) ELSE
   --             ram(to_integer(unsigned(read1_addres)));
   -- dataout2 <= datain WHEN (we = '1' AND read2_addres = write_adress) ELSE
   --             ram(to_integer(unsigned(read2_addres)));
	
	dataout1 <= ram(to_integer(unsigned(read1_addres)));
	dataout2 <= ram(to_integer(unsigned(read2_addres)));
	
	
END axsync_ram_a;
