LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

entity fetch_decode_reg is

    port (
        clock 				   : in std_logic;
        reset 				   : in std_logic;
		  -- Instruction
        instruction_in     : in std_logic_vector(15 downto 0);
		  instruction_out    : out std_logic_vector(15 downto 0);
		  -- Next PC
		  pc_next_in    		: in std_logic_vector(15 downto 0);
		  pc_next_out    		: out std_logic_vector(15 downto 0);
		  -- Immediate Value
		  immediate_in			: in std_logic_vector(15 downto 0);
		  immediate_out		: out std_logic_vector(15 downto 0);
		  -- Input Port Data
		  in_port_data_in		: in std_logic_vector(15 downto 0);
		  in_port_data_out	: out std_logic_vector(15 downto 0);
		  --
		  flush					: in std_logic;
		  stall					: in std_logic
		  
    );
end entity;

ARCHITECTURE fetch_decode_reg_arch OF fetch_decode_reg IS
    
	BEGIN
		PROCESS (clock, reset)
      BEGIN
		
        IF reset = '1' or flush ='1' THEN
		  
            instruction_out <= (others => '0');
				pc_next_out 	 <= (others => '0');  -- 0 or 0+1 ??
				immediate_out <= (others => '0');
				in_port_data_out <= (others => '0');	
				
        ELSIF stall = '0' and (rising_edge(clock)) THEN   -------- ???
		  
				instruction_out <= instruction_in;
				pc_next_out 	 <= pc_next_in;  -- 0 or 0+1 ??
				immediate_out <= immediate_in;
				in_port_data_out <= in_port_data_in;
				
        END IF;
		END PROCESS;
END fetch_decode_reg_arch;
