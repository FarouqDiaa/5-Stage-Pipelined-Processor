LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

entity decode_execute_reg is

    port (
        clock 				   : in std_logic;
        reset 				   : in std_logic;
		  
		  -- Read Addresses
        read_address_1_in     : in std_logic_vector(2 downto 0);
		  read_address_1_out    : out std_logic_vector(2 downto 0);
		  read_address_2_in     : in std_logic_vector(2 downto 0);
		  read_address_2_out    : out std_logic_vector(2 downto 0);
		  
		  -- Read Data
		  read_data_1_in			: in std_logic_vector(15 downto 0);
		  read_data_1_out			: out std_logic_vector(15 downto 0);
		  read_data_2_in			: in std_logic_vector(15 downto 0);
		  read_data_2_out			: out std_logic_vector(15 downto 0);
		  
		  -- R Destination
		  r_dest_in					: in std_logic_vector(2 downto 0);
		  r_dest_out					: out std_logic_vector(2 downto 0);
		  
		  -- Input Port Data
		  in_port_data_in		: in std_logic_vector(15 downto 0);
		  in_port_data_out	: out std_logic_vector(15 downto 0);
		  
		  -- Immediate Value
		  immediate_in			: in std_logic_vector(15 downto 0);
		  immediate_out		: out std_logic_vector(15 downto 0);
		  
		  -- Next PC
		  pc_next_in    		: in std_logic_vector(15 downto 0);
		  pc_next_out    		: out std_logic_vector(15 downto 0);
		  
		  -- Opcode
		  op_code_in 			: in std_logic_vector(4 downto 0);
		  op_code_out 			: out std_logic_vector(4 downto 0);
		  
		  memWrite_in 			: in std_logic;
		  memWrite_out 		: out std_logic;
		  
		  memRead_in 			: in std_logic;
		  memRead_out 			: out std_logic;
		  
		  wbEnable_in			: in std_logic;
		  wbEnable_out			: out std_logic;
		  
		  resetF_in				: in std_logic;
		  resetF_out			: out std_logic;
		  
		  interrupt_in 		: in std_logic;
		  interrupt_out 		: out std_logic;
		 
		  hltFlush_in 		   : in std_logic;
		  hltFlush_out 		: out std_logic;
			
		  hlt_in 				: in std_logic;
		  hlt_out 				: out std_logic;

        unCondJump_in       : in std_logic;
        unCondJump_out      : out std_logic;
		  
        jumpZero_in         : in std_logic;
        jumpZero_out        : out std_logic;
		  
        jumpCarry_in        : in std_logic;
        jumpCarry_out       : out std_logic;
		  
        jumpNegative_in     : in std_logic;
        jumpNegative_out    : out std_logic;
		  
        callSig_in          : in std_logic;
        callSig_out         : out std_logic;
		  
        inSignal_in         : in std_logic;
        inSignal_out        : out std_logic;
		 
        immSignal_in        : in std_logic;
        immSignal_out       : out std_logic;
		 
        rti_in              : in std_logic;
        rti_out             : out std_logic;
		  
        flagEnabe_in        : in std_logic;
        flagEnabe_out       : out std_logic;
		  
        ret_in              : in std_logic;
        ret_out             : out std_logic;
		  
        pop_in              : in std_logic;
        pop_out             : out std_logic;
		  
        push_in             : in std_logic;
        push_out            : out std_logic;
		  
        outEnable_in        : in std_logic;
        outEnable_out       : out std_logic;
		  
        dmAddressSel_in     : in std_logic;
        dmAddressSel_out    : out std_logic;
		  
        dmDataSel_in        : in std_logic;
        dmDataSel_out       : out std_logic;
		  
        wbSrcSel_in         : in std_logic;
        wbSrcSel_out        : out std_logic;
		  
        pcUpdateEnable_in   : in std_logic;
        pcUpdateEnable_out  : out std_logic;
		  
        pcUpdateSel_in      : in std_logic;
        pcUpdateSel_out     : out std_logic;
		  
        spUpdateSel_in      : in std_logic_vector(1 downto 0);
        spUpdateSel_out     : out std_logic_vector(1 downto 0);
		  
		  flush					 : in std_logic;
		 -- load_use_flush		 : in std_logic;
		  
		  store_in				 : in std_logic;
		  store_out				 : out std_logic
		  	    
    );
end entity;

ARCHITECTURE decode_execute_reg_arch OF decode_execute_reg IS
    
	BEGIN
		PROCESS (clock, reset)
      BEGIN
		
        IF reset = '1' or flush ='1'THEN
			
         read_address_1_out <= (others => '0');
			read_address_2_out <= (others => '0');
			read_data_1_out <= (others => '0');
			read_data_2_out <= (others => '0');
			r_dest_out <= (others => '0');
			in_port_data_out <= (others => '0');
			immediate_out <= (others => '0');
			pc_next_out <= (others => '0');
			op_code_out <= (others => '0');
			memWrite_out <= '0';
			memRead_out <= '0';
			wbEnable_out <= '0';
			resetF_out <= '0';
			interrupt_out <= '0';
			hltFlush_out <= '0';
			hlt_out <= '0';
			unCondJump_out <= '0';
			jumpZero_out <= '0';
			jumpCarry_out <= '0';
			jumpNegative_out <= '0';
			callSig_out <= '0';
			inSignal_out <= '0';
			immSignal_out <= '0';
			rti_out <= '0';
			flagEnabe_out <= '0';
			ret_out <= '0';
			pop_out <= '0';
			push_out <= '0';
			outEnable_out <= '0';
			dmAddressSel_out <= '0';
			dmDataSel_out <= '0';
			wbSrcSel_out <= '0';
			pcUpdateEnable_out <= '0';
			pcUpdateSel_out <= '0';
			spUpdateSel_out <= (others => '0');
			store_out <= '0';
			
        ELSIF (rising_edge(clock)) THEN
			
			read_address_1_out <= read_address_1_in;
			read_address_2_out <= read_address_2_in;
			read_data_1_out <= read_data_1_in;
			read_data_2_out <= read_data_2_in;
			r_dest_out <= r_dest_in;
			in_port_data_out <= in_port_data_in;
			immediate_out <= immediate_in;
			pc_next_out <= pc_next_in;
			op_code_out <= op_code_in;
			memWrite_out <= memWrite_in;
			memRead_out <= memRead_in;
			wbEnable_out <= wbEnable_in;
			resetF_out <= resetF_in;
			interrupt_out <= interrupt_in;
			hltFlush_out <= hltFlush_in;
			hlt_out <= hlt_in;
			unCondJump_out <= unCondJump_in;
			jumpZero_out <= jumpZero_in;
			jumpCarry_out <= jumpCarry_in;
			jumpNegative_out <= jumpNegative_in;
			callSig_out <= callSig_in;
			inSignal_out <= inSignal_in;
			immSignal_out <= immSignal_in;
			rti_out <= rti_in;
			flagEnabe_out <= flagEnabe_in;
			ret_out <= ret_in;
			pop_out <= pop_in;
			push_out <= push_in;
			outEnable_out <= outEnable_in;
			dmAddressSel_out <= dmAddressSel_in;
			dmDataSel_out <= dmDataSel_in;
			wbSrcSel_out <= wbSrcSel_in;
			pcUpdateEnable_out <= pcUpdateEnable_in;
			pcUpdateSel_out <= pcUpdateSel_in;
			spUpdateSel_out <= spUpdateSel_in;
			store_out <= store_in;
			
        END IF;
		END PROCESS;
END decode_execute_reg_arch;

