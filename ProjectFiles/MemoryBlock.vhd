LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_unsigned.all;

entity MemoryBlock is

	generic (
			  addressWidth : integer := 12;
			  dataWidth    : integer := 16
		 );
		 
	port(
		  
		  clk 								: in std_logic;
		  rst 								: in std_logic;
        memRead   						: in std_logic;
        memWrite  						: in std_logic;
	
		  wb_in_writeBack					: in std_logic;     -- Go to Mem/Wb register
		  wb_in_out_port_en 				: in std_logic;
		  wb_in_writeBack_selector 	: in std_logic; -- Write Back from Alu or from DM?
		  
		  -- Selectors for data and address muxes
		  address_mux_selector 			: in std_logic;
		  data_mux_selector   			: in std_logic;
		  
		  pc_update  			  			: in std_logic;  -- For Call, Ret and RTI to update PC
		  pc_update_selector   			: in std_logic; -- Chose which will update PC (DM[SP] or R[Src1])
		  
		  sp_update_selector   			: in std_logic_vector(1 downto 0); -- Chose SP, SP+1 or SP-1
		  
		  in_alu_result   				: in std_logic_vector(dataWidth - 1 downto 0);  -- To WB and Data_Mux
		  in_dest_address  				: in std_logic_vector(11 downto 0); -- Mem/WB Reg

		  pc_plus_one 						: in std_logic_vector(dataWidth - 1 downto 0);
		  r_src_1     						: in std_logic_vector(dataWidth - 1 downto 0); -- Also goes to pc update mux with DM[SP]
  
		  wb_out_writeBack				: out std_logic; -- Out from Mem/WB register
		  wb_out_out_port_en 			: out std_logic;
		  wb_out_writeBack_selector	: out std_logic; 
		  wb_out_alu_result   			: out std_logic_vector(dataWidth - 1 downto 0); -- To WB
		  wb_dm_data_out    				: out std_logic_vector(dataWidth - 1 downto 0); -- To WB
		  wb_out_dest_address  			: out std_logic_vector(11 downto 0);
		  
		  new_pc								: out std_logic_vector(15 downto 0); -- which will update PC (DM[SP] or R[Src1])	  
		  exception_flag 					: out std_logic -- If address exceeds 12-bit length
		  	  
	);
	
end MemoryBlock;

ARCHITECTURE memblock_arch OF MemoryBlock IS
	 
	 -- Data Memory
	 component DataMemory IS
		 generic (
			  addressWidth : inTEGER := 12;
			  dataWidth    : inTEGER := 16
		 );
		 port (
			   clk 		: in std_logic;
				memRead   : in std_logic;
				memWrite  : in std_logic;
				address   : in std_logic_vector(addressWidth - 1 downto 0); -- 12-bit address
				data_in  : in std_logic_vector(dataWidth - 1 downto 0);    -- 16-bit data
				data_out  : out std_logic_vector(dataWidth - 1 downto 0)    -- 16-bit data
		 );
	 end component;
	 
	 -- Stack Pointer
	 component SP is
		 port( 
			  clk: in std_logic;
			  rst: in std_logic;
			  sp_in : in std_logic_vector(15 downto 0);
			  sp_out : out std_logic_vector(15 downto 0)
		 );
	 end component;
	 
	 -- Mux for updating stack pointer
	 component SP_Mux is
    port( 
		  selector  : in std_logic_vector(1 downto 0);
		  sp_in 		: in std_logic_vector(15 downto 0);
        sp_dm_out : out std_logic_vector(15 downto 0);
		  sp_sp_out : out std_logic_vector(15 downto 0)
    );
	 end component;
	 
	 -- Mux For chosing the address source for Data Memory
	 component Address_Mux is
		 port( 
			  selector 		: in std_logic; -- Depending on the instruction
			  address_1 	: in std_logic_vector(15 downto 0);
			  address_2 	: in std_logic_vector(15 downto 0);		-- All Should be cut to 12 bits (data memory address size)
			  address_out  : out std_logic_vector(11 downto 0);
			  exception    : out std_logic
		 );
	 end component;
	 
	 -- Mux For chosing the data source for Data Memory ------- Also Used as mux for chosing between (DM[r_src_1](dm out) and R[r_src_1](come from pipeline)
	 component Data_Mux is
		 port( 
			   selector      : in std_logic; -- Depending on the instruction
				data_1     : in std_logic_vector(15 downto 0);
				data_2     : in std_logic_vector(15 downto 0);
				data_out   : out std_logic_vector(15 downto 0)
		 );
	 end component;
	 
	 component WriteBackReg is
		 port (
			   clock 				 : IN STD_LOGIC;
				reset 				 : IN STD_LOGIC;
				in_wb_enable     : IN STD_LOGIC; 
				out_wb_enable    : OUT STD_LOGIC;
				in_out_port_en   : IN STD_LOGIC;
				out_out_port_en  : out STD_LOGIC;
				in_wb_selector   : IN STD_LOGIC;
				out_wb_selector  : out STD_LOGIC;     					  
				in_alu_result 	 : IN STD_LOGIC_VECTOR(15 downto 0);
				out_alu_result 	 : OUT STD_LOGIC_VECTOR(15 downto 0); 
				in_dm_data 		 : IN STD_LOGIC_VECTOR(15 downto 0);
				out_dm_data 		 : OUT STD_LOGIC_VECTOR(15 downto 0); 
				in_dest_address  : IN STD_LOGIC_VECTOR(11 downto 0); 
				out_dest_address : OUT STD_LOGIC_VECTOR(11 downto 0)       
		 );
	 end component;
	 
	 component D_FF is 
		port (
        clk      : in std_logic;
		  rst      : in std_logic;
        data_in  : in std_logic_vector(15 downto 0);
        data_out : out std_logic_vector(15 downto 0)
		);
	end component;
		
	 -- Signals For Data Memory
	
		 -- Address Signal ( From the Address_Mux -> address port of DataMemory)
		 SIGNAL dm_address : std_logic_vector(11 downto 0);
		 -- Data Signal ( From the Data_Mux -> data_in port of DataMemory)
		 SIGNAL dm_data_in : std_logic_vector(dataWidth-1 downto 0);
		 -- Data Signal ( From data_out port of DataMemory to Mem/WB and Call or Return, Rti MUX)
		 SIGNAL dm_data_out : std_logic_vector(dataWidth-1 downto 0);	
		 
		-- Stack Pointer Register Signals
		signal sp_to_address_mux   : std_logic_vector(dataWidth-1 downto 0); -- SP_Mux -> DM Address
		signal current_sp 			: std_logic_vector(dataWidth-1 downto 0); -- From SP Register -> DFF
		signal dff_current_sp 		: std_logic_vector(dataWidth-1 downto 0); -- From DFF -> sp_mux
		signal new_sp   				: std_logic_vector(dataWidth-1 downto 0); -- SP_Mux -> SP Register

begin

	 -- Mux For Updating Stack Pointer Register
	 SP_Mux_init : SP_Mux PORT MAP (
            sp_update_selector,		-- 2 bits for +1, -1 or stay fixed
				dff_current_sp,             -- Current Value of SP
            sp_to_address_mux, 		-- Go to address mux
            new_sp					   -- Go to SP register
        );

	 -- Mux to chose address for DM
    AddressMux_init : Address_Mux PORT MAP (
            address_mux_selector,	-- One bit from control signal
            in_alu_result, 					-- First address	: output of ALU
            sp_to_address_mux,		-- Second address : output of SP Mux -> DM Address
				dm_address,					-- output of this mux. Go to address port of DataMemory
				exception_flag
        );
		  
	 -- Mux to chose data in for DM
	 DataMux_init : Data_Mux PORT MAP (
            data_mux_selector,		-- One bit from control signal
            r_src_1, 					-- First address	: R[Src1]
            pc_plus_one,				-- Second address : PC + 1
				dm_data_in					-- output of this mux. Go to address port of DataMemory
        );
	
	 -- Mux to chose which signal will update the pc (Call or Return, Rti?)
	 pc_update_mux_init : Data_Mux PORT MAP (
            pc_update_selector,		-- One bit from control signal
            r_src_1, 					-- First address	: R[Src1]
            dm_data_out,				-- Second address : PC + 1
				new_pc					   -- output of this mux. Go to address port of DataMemory
        );
		  
	
	 dm_init : DataMemory PORT MAP (
            clk,
				memRead, 
				memWrite, 
				dm_address,  -- output From Address_Mux
				dm_data_in,  -- output From Data_Mux
				dm_data_out -- Go to Mem/WB and to pc_update_mux
        );
		  
	 sp_init : SP PORT MAP (
            clk,
				rst,
				new_sp,    -- Come From SP Mux
				current_sp -- --> SP Mux
        );
		  
	 dff_init : D_FF PORT MAP (
				clk,
				rst,
				current_sp,    -- Come From SP Mux
				dff_current_sp -- --> SP Mux
    );
		  
	 wb_reg_init : WriteBackReg PORT MAP (
            clk,
				rst,
				wb_in_writeBack,
				wb_out_writeBack,
				wb_in_out_port_en,
				wb_out_out_port_en,											
				wb_in_writeBack_selector ,
				wb_out_writeBack_selector,    					  
				in_alu_result,
				wb_out_alu_result,
				dm_data_out,
				wb_dm_data_out,
				in_dest_address,
				wb_out_dest_address
        );
	

end	memblock_arch;