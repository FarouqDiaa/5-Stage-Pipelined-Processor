LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY WriteBackReg IS

    PORT (
        clock 				 : IN STD_LOGIC;
        reset 				 : IN STD_LOGIC;
		  
		  -- 1- Reg file write enable | 2- Forwarding unit
        in_wb_enable     : IN STD_LOGIC; 
		  out_wb_enable    : OUT STD_LOGIC;
		  
		  -- not sure
		  in_out_port_en   : IN STD_LOGIC;
		  out_out_port_en  : out STD_LOGIC;
		  
		  -- Chose what to write back (DM[] or ALU result?)												
		  in_wb_selector   : IN STD_LOGIC;
		  out_wb_selector  : out STD_LOGIC;     					  
			
		  -- Result of alu operation (Goes back to Register File)
		  in_alu_result 	 : IN STD_LOGIC_VECTOR(15 downto 0);
		  out_alu_result 	 : OUT STD_LOGIC_VECTOR(15 downto 0); 
		  
		  -- (Muxed with Alu Out and Goes back to Register File)
		  in_dm_data 		 : IN STD_LOGIC_VECTOR(15 downto 0);
		  out_dm_data 		 : OUT STD_LOGIC_VECTOR(15 downto 0); 
		  
		  -- Goes back to Register File
		  in_dest_address  : IN STD_LOGIC_VECTOR(11 downto 0); 
		  out_dest_address : OUT STD_LOGIC_VECTOR(11 downto 0)       
    );
END WriteBackReg;

ARCHITECTURE write_back_arch OF WriteBackReg IS
    
	BEGIN
		PROCESS (clock, reset)
      BEGIN
		
        IF reset = '1' THEN
		  
            out_wb_enable <= '0';
				out_wb_selector <= '0';
				out_out_port_en <= '0';
				out_alu_result <= (OTHERS => '0');
				out_dm_data <= (OTHERS => '0');
				out_dest_address <= (OTHERS => '0');	
				
        ELSIF (rising_edge(clock)) THEN
		  
				out_wb_enable <= in_wb_enable;
				out_wb_selector <= in_wb_selector;
				out_out_port_en <= in_out_port_en;
				out_alu_result <= in_alu_result;
				out_dm_data <= in_dm_data;
				out_dest_address <= in_dest_address;
				
        END IF;
		END PROCESS;
END write_back_arch;
