LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity singleCycle is
	port(
		  clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
		  inPort : in std_logic_vector(15 downto 0);
		  outPort : out std_logic_vector(15 downto 0)
	);
end entity;


architecture single_cycle_arch of singleCycle is
	
	-- Fetch Stage
	component fetch_stage IS
    port (
        clk : IN STD_LOGIC; ------
        reset : IN STD_LOGIC;	-----

        call_return_signal : IN STD_LOGIC;
        call_return_address : IN STD_LOGIC_VECTOR(15 DOWNTO 0);

        jump_signal : IN STD_LOGIC;
        jump_address : IN STD_LOGIC_VECTOR(15 DOWNTO 0);

        -- Pc+1 used in exception handling
        old_pc : IN STD_LOGIC_VECTOR(15 DOWNTO 0);

        exception_signal : IN STD_LOGIC;
        exception_type : IN STD_LOGIC_VECTOR(1 DOWNTO 0); -- Exception type

        -- PC Signals
        freeze_signal : IN STD_LOGIC;
        hlt_signal : IN STD_LOGIC;

        interrupt_signal : IN STD_LOGIC; -- Interrupt
        interrupt_index : IN STD_LOGIC; -- Value of the interrupt either 1 or 0

        port_input : IN STD_LOGIC_VECTOR(15 DOWNTO 0); -- Input port	------
        port_output : OUT STD_LOGIC_VECTOR(15 DOWNTO 0); -- Output port

        immediate_value_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0); -- Immediate value
        pc_next : OUT STD_LOGIC_VECTOR(15 DOWNTO 0); -- Next PC value
        instruction : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) -- Instruction output
    );
	end component;
	
	-- Control Unit
	component controller is
    port (
        opcode : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		  rSrc1  : in std_logic_vector(2 downto 0);
        memWrite, memRead, wbEnable , resetF, int, hltFlush, hlt, unCondJump, jumpZero, jumpCarry, jumpNegative, callSig, inSignal, immSignal, rti, flagEnabe, ret, pop, push, outEnable, dmAddressSel, dmDataSel, wbSrcSel, pcUpdateEnable, pcUpdateSel : OUT STD_LOGIC;
        interrupt_index : out std_logic;
		  spUpdateSel : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		  baseop : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)

    );
	end component;
	
	-- Register File
	component regfile is
    port (
        clk          : IN std_logic;
        rst          : IN std_logic;
        write_en     : IN std_logic;
        read_addres1 : IN std_logic_vector(2 downto 0);
        read_addres2 : IN std_logic_vector(2 downto 0);
        write_adress : IN std_logic_vector(2 downto 0);
        read_data1   : OUT std_logic_vector(15 DOWNTO 0);
        read_data2   : OUT std_logic_vector(15 DOWNTO 0);
        write_data   : IN std_logic_vector(15 DOWNTO 0)
    );
	end component;
	
	
	-- Execute Block
	component ExecuteBlock is
    port (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        ImmSignal : IN STD_LOGIC;
        InSignal : IN STD_LOGIC;
        InData : IN STD_LOGIC_VECTOR(15 DOWNTO 0); --data of in port
        Rs : IN STD_LOGIC_VECTOR(2 DOWNTO 0); -- Source register 1
        Rt : IN STD_LOGIC_VECTOR(2 DOWNTO 0); -- Source register 2
        WBEX_M : IN STD_LOGIC; -- Write-back enable from EX/MEM
        WBM_WB : IN STD_LOGIC; -- Write-back enable from MEM/WB
        RegDesE_M : IN STD_LOGIC_VECTOR(2 DOWNTO 0); -- Destination register EX/MEM
        RegDesM_WB : IN STD_LOGIC_VECTOR(2 DOWNTO 0); -- Destination register MEM/WB
        MemToReg_M_WB : IN STD_LOGIC; -- Memory-to-register signal from MEM/WB
        ReadData1 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        ReadData2 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        Immediate : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        AluSelector : IN STD_LOGIC_VECTOR(4 DOWNTO 0); --(basecode+opcode)
        AluResExecuteMemory : IN STD_LOGIC_VECTOR(15 DOWNTO 0); --Alu result which is stored in exexute memory register(alu to alu)
        AluResMemoryWriteBack : IN STD_LOGIC_VECTOR(15 DOWNTO 0); --Same alu result but is stored in exexute memory writeback(memory to alu)
        MemOutMemoryWriteBack : IN STD_LOGIC_VECTOR(15 DOWNTO 0); -- it is the data output from memory
        ZeroFlag : OUT STD_LOGIC;
        NegativeFlag : OUT STD_LOGIC;
        CarryFlag : OUT STD_LOGIC;
        AluOut : OUT STD_LOGIC_VECTOR(15 DOWNTO 0); -- it is the data output from alu
        RsData : OUT STD_LOGIC_VECTOR(15 DOWNTO 0); -- it is the data output from first upper mux 
        call_signal_in : IN STD_LOGIC;
        call_signal_out : OUT STD_LOGIC;
        save_flags : IN STD_LOGIC; -- Save current flags (INT)      --------------control signal to be added 
        rti_instruction_in : in std_logic;
		  restore_flags : IN STD_LOGIC; -- Restore saved flags (RTI)  --------------control signal to be added 
        restored_flags : IN STD_LOGIC_VECTOR(2 DOWNTO 0); -- Flags to RESTORE FROM STACK
        update_flags : IN STD_LOGIC;
        ------------------branching
        PCPlus1 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); -- Next sequential PC address
        ConditionalJumpZero : IN STD_LOGIC; -- Indicates a conditional jump (JZ)
        ConditionalJumpNegative : IN STD_LOGIC; -- Indicates a conditional jump (JN)
        ConditionalJumpCarry : IN STD_LOGIC; -- Indicates a conditional jump (JC)
        UnconditionalJump : IN STD_LOGIC; -- Indicates an unconditional jump (e.g., JMP, CALL, RET)
        FlushDecode : OUT STD_LOGIC;
        FlushExecute : OUT STD_LOGIC;
        ChangePC : OUT STD_LOGIC;
        NewPC : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		  rti_instruction_out : out std_logic
    );
   end component;
	
	-- Memory Block
	component MemoryBlockSingleCycle is
		generic (
				  addressWidth : integer := 12;
				  dataWidth    : integer := 16
			 );
			 
		port(
			  
		  clk 								: in std_logic;
		  rst 								: in std_logic;
        memRead   						: in std_logic;
        memWrite  						: in std_logic;
		  
		  rti_instruction_flag_in 		: in std_logic;
	
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
		  in_dest_address  				: in std_logic_vector(2 downto 0); -- Mem/WB Reg

		  pc_plus_one 						: in std_logic_vector(dataWidth - 1 downto 0);
		  in_r_src_1     					: in std_logic_vector(dataWidth - 1 downto 0); -- Also goes to pc update mux with DM[SP]
  
		  wb_out_writeBack				: out std_logic; -- Out from Mem/WB register
		  wb_out_out_port_en 			: out std_logic;
		  wb_out_writeBack_selector	: out std_logic; 
		  wb_out_alu_result   			: out std_logic_vector(dataWidth - 1 downto 0); -- To WB
		  wb_out_dm_data    				: out std_logic_vector(dataWidth - 1 downto 0); -- To WB
		  wb_out_r_src_1    				: out std_logic_vector(dataWidth - 1 downto 0); -- To WB
		  wb_out_dest_address  			: out std_logic_vector(2 downto 0);
		  
		  pc_plus_one_out					: out std_logic_vector(15 downto 0); -- Go to fetch stage (exception)
		  
		  new_pc								: out std_logic_vector(15 downto 0); -- which will update PC (DM[SP] or R[Src1])	  
		  exception_flag 					: out std_logic; -- If address exceeds 12-bit length
		  
		  exception_type: out std_logic_vector(1 downto 0);
		  
		  flags									: out std_logic_vector(2 downto 0);
		  rti_instruction_flag_out 		: out std_logic;
		  
		  pc_update_out : out std_logic  ---- Enable Updateing PC (Call , Ret, Rti). Back to Fetch Stage 
				  
		);	
end component;

component Data_Mux is
    port( 
        selector     : in std_logic; -- Depending on the instruction
        data_1     : in std_logic_vector(15 downto 0);
        data_2     : in std_logic_vector(15 downto 0);
        data_out   : out std_logic_vector(15 downto 0)
    );
end component;


	signal fetch_stage_opcode_out 					: std_logic_vector(4 downto 0) := (OTHERS => '0'); -- output from fetch stage to control unit

	-- Fetch stage Signals
	signal fetch_port_output_signal 					: std_logic_vector(15 downto 0) := (OTHERS => '0');
	signal fetch_immediate_value_out_signal 		: std_logic_vector(15 downto 0) := (OTHERS => '0');
	signal fetch_pc_next_signal 						: std_logic_vector(15 downto 0) := (OTHERS => '0');
	signal fetch_instruction_signal 					: std_logic_vector(15 downto 0) := (OTHERS => '0');
	
	
	-- Decode Stage Signals
	signal decode_in_port_data_signal 				: std_logic_vector(15 downto 0) := (others => '0');
	signal decode_immediate_signal 					: std_logic_vector(15 downto 0) := (others => '0');
	signal decode_pc_plus_one_signal 				: std_logic_vector(15 downto 0) := (others => '0');
		
		-- Register File Signals
	signal reg_read_address_1_signal 				: std_logic_vector(2 downto 0) := (OTHERS => '0');	-- in to reg file (from current instruction)
	signal reg_read_address_2_signal					: std_logic_vector(2 downto 0) := (OTHERS => '0');
	signal reg_read_data_1_signal						: std_logic_vector(15 downto 0) := (OTHERS => '0'); -- out from reg file
	signal reg_read_data_2_signal 					: std_logic_vector(15 downto 0) := (OTHERS => '0');
	
	signal decode_r_dest_signal 						: std_logic_vector(2 downto 0) := (OTHERS => '0');
		
		-- Control unit Signals
	signal controller_op_code 							: std_logic_vector(4 downto 0) := (OTHERS => '0');
	signal control_memWrite,  control_memRead,  control_wbEnable ,  control_resetF,  control_int,  control_hltFlush,  control_hlt,  control_unCondJump,  control_jumpZero,  control_jumpCarry,  control_jumpNegative,  control_callSig,  control_inSignal,  control_immSignal,  control_rti,  control_flagEnabe,  control_ret,  control_pop,  control_push,  control_outEnable,  control_dmAddressSel,  control_dmDataSel,  control_wbSrcSel, control_pcUpdateEnable, control_pcUpdateSel : STD_LOGIC := '0';
	signal control_spUpdateSel 						: std_logic_vector(1 downto 0) := (others => '0');
	signal control_rSrc_1								: std_logic_vector(2 downto 0) := (others => '0'); -- for interrupt index
	signal control_interrupt_index					: std_logic := '0';	-- for interrupt index
	signal control_baseop 								: std_logic_vector(4 downto 0) := (others => '0'); -- Not Used ???
	
	-- Execute stage Signals
	signal exec_in_port_data_signal 					: std_logic_vector(15 downto 0) := (others => '0');
	signal exec_immediate_data_signal 				: std_logic_vector(15 downto 0) := (others => '0');
	signal exec_pc_plus_one_signal 					: std_logic_vector(15 downto 0) := (others => '0');
	
	signal exec_read_address_1_signal 				: std_logic_vector(2 downto 0) := (OTHERS => '0'); -- For forwarding unit
	signal exec_read_address_2_signal 				: std_logic_vector(2 downto 0) := (OTHERS => '0');
	signal exec_read_data_1_signal 					: std_logic_vector(15 downto 0) := (OTHERS => '0');
	signal exec_read_data_2_signal					: std_logic_vector(15 downto 0) := (OTHERS => '0');
	
	signal exec_r_dest_signal 							: std_logic_vector(2 downto 0) := (OTHERS => '0');

	signal exec_op_code 									: std_logic_vector(4 downto 0) := (OTHERS => '0');
	signal exec_memWrite, exec_memRead, exec_wbEnable, exec_resetF, exec_int, exec_hltFlush, exec_hlt, exec_unCondJump,  exec_jumpZero,  exec_jumpCarry,  exec_jumpNegative,  exec_callSig,  exec_inSignal,  exec_immSignal,  exec_rti,  exec_flagEnabe,  exec_ret,  exec_pop,  exec_push,  exec_outEnable,  exec_dmAddressSel,  exec_dmDataSel, exec_wbSrcSel, exec_pcUpdateEnable, exec_pcUpdateSel : STD_LOGIC := '0';
	signal exec_spUpdateSel 							: std_logic_vector(1 downto 0) := (others => '0');
	
	signal exec_FlushDecode, exec_FlushExecute 						: std_logic := '0'; -- ???
	signal exec_ChangePC 													: std_logic := '0'; -- Jump Signal ??
	signal exec_NewPC 														: std_logic_vector(15 downto 0) := (OTHERS => '0');
	signal exec_call_signal_out 											: std_logic := '0';
	signal exec_ZeroFlag, exec_NegativeFlag, exec_CarryFlag 		: std_logic := '0';
	signal exec_RsData, exec_AluOut										: std_logic_vector(15 downto 0) := (others => '0');
	
	signal exec_rti_out : std_logic := '0';
	
	-- Memory Stage Signals
	signal mem_alu_result, mem_alu_result_out	  						: std_logic_vector(15 downto 0) := (others => '0');
	signal mem_dest_address_in, mem_dest_address_out				: std_logic_vector(2 downto 0)  := (others => '0');
	signal mem_pc_plus_one_in, mem_pc_plus_one_out					: std_logic_vector(15 downto 0) := (others => '0');
	signal mem_r_src_1_in, mem_r_src_1_out								: std_logic_vector(15 downto 0) := (others => '0');
	signal mem_dm_data_out													: std_logic_vector(15 downto 0) := (others => '0');
	signal mem_new_pc															: std_logic_vector(15 downto 0) := (others => '0');
	signal mem_exception_flag												: std_logic := '0';
	signal mem_exception_type												: std_logic_vector(1 downto 0) := (others => '0');
	signal mem_writeBack_out 												: std_logic := '0';
	signal mem_out_port_en_out 											: std_logic := '0';
	signal wb_out_writeBack_selector 									: std_logic := '0';
	
	signal mem_memWrite, mem_memRead, mem_wbEnable, mem_outEnable, mem_dmAddressSel, mem_dmDataSel, mem_wbSrcSel, mem_pcUpdateEnable, mem_pcUpdateSel : std_logic := '0';
	signal mem_spUpdateSel 													: std_logic_vector(1 downto 0) := (others => '0');
	
	signal mem_pc_update_out : std_logic := '0';   -- Enable Updating pc (call, ret or rti). out from Memory block -> Fetch Stage
	
	signal mem_rti_in, mem_rti_out : std_logic := '0';	-- For RTI
	signal mem_restored_flags		 : std_logic_vector (2 downto 0) := (others => '0'); -- For RTI
	
	-- WB Stage Signals
	signal wb_data_memory_data, wb_alu_result, wb_mux_output, wb_r_src_1 : std_logic_vector(15 downto 0) := (others => '0'); -- Input to last mux
	signal wb_wb_selector : std_logic := '0'; -- select what to write back (from memory or alu)?
	signal wb_out_enable : std_logic := '0';  -- enable writing into out port
	signal wb_wb_enable : std_logic := '0'; -- Back to register file as write enable
	signal wb_dest_addres : std_logic_vector (2 downto 0) := (others => '0');
	
	signal temp_freeze_signal : std_logic := '0';  --- Temppp 3nd farouk
	signal temp_MemToReg_M_WB : std_logic := '0';  --- Tempp 3nd 7oda w maher
	
		begin
		
		-- From Fetch to Decode Stage (will be separated by pipeline)
		controller_op_code <= fetch_instruction_signal(15 downto 11);
		decode_pc_plus_one_signal <= fetch_pc_next_signal;
		decode_immediate_signal <= fetch_immediate_value_out_signal;
		
		reg_read_address_1_signal <= fetch_instruction_signal(7 downto 5) when controller_op_code = "01101"
			else fetch_instruction_signal(10 downto 8);  -- Condition for Store instruction
			
		reg_read_address_2_signal <= fetch_instruction_signal(10 downto 8) when controller_op_code = "01101"
			else fetch_instruction_signal(7 downto 5);	-- Condition for Store instruction
		
		decode_r_dest_signal <= fetch_instruction_signal(4 downto 2);
		
		control_rSrc_1 <= fetch_instruction_signal(10 downto 8);  -- Index of interrupt (back to fetch stage)
		
		decode_in_port_data_signal <= fetch_port_output_signal;
		
		-- From Decode to Execute Stage (will be separated with pipeline)
		exec_read_address_1_signal <= reg_read_address_1_signal;
		exec_read_address_2_signal <= reg_read_address_2_signal;
		
		exec_read_data_1_signal <= reg_read_data_1_signal;
		exec_read_data_2_signal <= reg_read_data_2_signal;
		exec_r_dest_signal <= decode_r_dest_signal;
		
		exec_in_port_data_signal <= decode_in_port_data_signal;
		exec_immediate_data_signal <= decode_immediate_signal;
		exec_pc_plus_one_signal <= decode_pc_plus_one_signal;
		
		exec_op_code <= controller_op_code;
		
		exec_memWrite <= control_memWrite;
		exec_memRead <= control_memRead;
		exec_wbEnable <= control_wbEnable;
		exec_resetF <= control_resetF;
		exec_int <= control_int;
		exec_hltFlush <= control_hltFlush;
		exec_hlt <= control_hlt;
		exec_unCondJump <= control_unCondJump;
		exec_jumpZero <= control_jumpZero;
		exec_jumpCarry <= control_jumpCarry;
		exec_jumpNegative <= control_jumpNegative;
		exec_callSig <= control_callSig;
		exec_inSignal <= control_inSignal;
		exec_immSignal <= control_immSignal;
		exec_rti <= control_rti;
		exec_flagEnabe <= control_flagEnabe;
		exec_ret <= control_ret;
		exec_pop <= control_pop;
		exec_push <= control_push;
		exec_outEnable <= control_outEnable;
		exec_dmAddressSel <= control_dmAddressSel;
		exec_dmDataSel <= control_dmDataSel;
		exec_wbSrcSel <= control_wbSrcSel;
		exec_pcUpdateEnable <= control_pcUpdateEnable;
		exec_pcUpdateSel <= control_pcUpdateSel;
		exec_spUpdateSel <= control_spUpdateSel;
		
		---------------------------------------------------------------------------
		-- From Execute to Memory Stage (will be separated with pipeline)
		mem_alu_result <= exec_AluOut;
		mem_dest_address_in <= exec_r_dest_signal;
		mem_pc_plus_one_in <= exec_pc_plus_one_signal;
		mem_r_src_1_in <= exec_RsData;   -- ????
		
		mem_memWrite <= exec_memWrite;
		mem_memRead <= exec_memRead;
		mem_wbEnable <= exec_wbEnable;
		mem_outEnable <= exec_outEnable;
		mem_dmAddressSel <= exec_dmAddressSel;
		mem_dmDataSel <= exec_dmDataSel;
		mem_wbSrcSel <= exec_wbSrcSel;
		mem_pcUpdateEnable <= exec_pcUpdateEnable;
		mem_pcUpdateSel <= exec_pcUpdateSel;
		mem_spUpdateSel <= exec_spUpdateSel;
		
		mem_rti_in <= exec_rti_out;
		
		----------------------------------------------------------------------------
		-- Write Back Stage
		wb_data_memory_data <= mem_dm_data_out;	--  Output From Memory Block
		wb_alu_result <= mem_alu_result_out;	--  Output From Memory Block
		wb_r_src_1 <= mem_r_src_1_out; -- For Output Port (wb_r_src_1 will go to the out port of the top entity) (ta7t fel akher maktoba)
		
		wb_wb_selector <= mem_wbSrcSel; -- select what to write back (from memory or alu)?
	   wb_out_enable <= mem_outEnable;  -- enable writing into out port
	   wb_wb_enable <= mem_wbEnable; -- Back to register file as write enable
		wb_dest_addres <= mem_dest_address_out; -- Write Back Address
		
		-- Fetch Stage
		fetch_stage_init : fetch_stage PORT MAP (
				clk => clk,
				reset => rst,	
				
				call_return_signal => mem_pc_update_out,
				call_return_address => mem_new_pc,
				
				jump_signal => exec_ChangePC,
				jump_address => exec_NewPC,
				
				exception_signal => mem_exception_flag,
				exception_type => mem_exception_type,
				
				old_pc => mem_pc_plus_one_out, -- From Memory Block? yes
				
				freeze_signal => temp_freeze_signal,
				hlt_signal => control_hlt,
				
				interrupt_signal => control_int,
			   interrupt_index => control_interrupt_index,

			   port_input => inPort,
			   port_output => fetch_port_output_signal,   			 -- output

			   immediate_value_out => fetch_immediate_value_out_signal,	-- output
			   pc_next => fetch_pc_next_signal,							-- output
			   instruction => fetch_instruction_signal				-- output
       );
		  
		  
		-- Fetch Stage
		control_unit_init : controller PORT MAP (
            opcode => controller_op_code,			-- input
				rSrc1 => control_rSrc_1,
				memWrite => control_memWrite,
				memRead => control_memRead,
				wbEnable => control_wbEnable,
				resetF => control_resetF,
				int => control_int,
				hltFlush => control_hltFlush,
				hlt => control_hlt,
				unCondJump => control_unCondJump,
				jumpZero => control_jumpZero,
				jumpCarry => control_jumpCarry,
				jumpNegative => control_jumpNegative,
				callSig => control_callSig,
				inSignal => control_inSignal,
				immSignal => control_immSignal,
				rti => control_rti,
				flagEnabe => control_flagEnabe,
				ret => control_ret,
				pop => control_pop,
				push => control_push,
				outEnable => control_outEnable,
				dmAddressSel => control_dmAddressSel,
				dmDataSel => control_dmDataSel,
				wbSrcSel => control_wbSrcSel,
				pcUpdateEnable => control_pcUpdateEnable,
				pcUpdateSel => control_pcUpdateSel,
				interrupt_index => control_interrupt_index,
				spUpdateSel => control_spUpdateSel,
				baseop => control_baseop

        );
		 
		  
		-- Register File 
		reg_file_init : regfile port map (
				clk => clk,
				rst => rst,
				write_en => wb_wb_enable, 							-- Come From WB (not from control unit directly)
				read_addres1 => reg_read_address_1_signal,   -- From current instruction
				read_addres2 => reg_read_address_2_signal,	-- From current instruction
				write_adress => wb_dest_addres, 					-- From WB
				read_data1 => reg_read_data_1_signal,			-- output
				read_data2 => reg_read_data_2_signal,			-- output
				write_data => wb_mux_output						-- From WB
		);
		
  
		-- Execute Block
		execute_block_init : ExecuteBlock port map (
			  clk => clk ,
			  reset => rst,
			  ImmSignal => exec_immSignal,				 -- From Control Unit
			  InSignal => exec_inSignal,
			  InData => exec_in_port_data_signal, 		   -- In port data ( from Fetch Stage )
			  Rs => exec_read_address_1_signal,
			  Rt => exec_read_address_2_signal,	
			  WBEX_M => mem_writeBack_out, 					-- Write-back enable from EX/MEM   -- WILL BE UPDATED
			  WBM_WB => mem_writeBack_out,					-- Write-back enable from MEM/WB	  -- WILL BE UPDATED
			  RegDesE_M => mem_dest_address_out,			-- Destination register EX/MEM     -- WILL BE UPDATED
			  RegDesM_WB => mem_dest_address_out,			-- Destination register MEM/WB     -- WILL BE UPDATED
			  MemToReg_M_WB => temp_MemToReg_M_WB,			-- TEMPPPPP	-- Memory-to-register signal from MEM/WB ---- TEMPPPP
			  ReadData1 => exec_read_data_1_signal,										
			  ReadData2 => exec_read_data_2_signal,
			  Immediate => exec_immediate_data_signal,
			  AluSelector => exec_op_code,
			  AluResExecuteMemory => mem_alu_result,			------- ??? -----
			  AluResMemoryWriteBack => wb_alu_result,			------- ??? -----
			  MemOutMemoryWriteBack => wb_data_memory_data,							----
			  ZeroFlag => exec_ZeroFlag,	-- out
			  NegativeFlag => exec_NegativeFlag,	-- out
			  CarryFlag => exec_CarryFlag, -- out
			  AluOut => exec_AluOut,	-- out
			  RsData => exec_RsData,	-- out
			  call_signal_in => exec_callSig,
			  call_signal_out => exec_call_signal_out,   -- output
			  save_flags => exec_int,
			  rti_instruction_in => exec_rti,
			  restore_flags => mem_rti_out,    ----------------------  Wrong ----------------------
			  restored_flags => mem_restored_flags,							--- ??
			  update_flags => exec_flagEnabe,			--- ??
			  PCPlus1 => exec_pc_plus_one_signal,
			  ConditionalJumpZero => exec_jumpZero,
			  ConditionalJumpNegative => exec_jumpNegative,
			  ConditionalJumpCarry => exec_jumpCarry,
			  UnconditionalJump => exec_unCondJump,
			  FlushDecode => exec_FlushDecode,	-- out
			  FlushExecute => exec_FlushExecute,-- out
			  ChangePC => exec_ChangePC,	-- OUT
			  NewPC => exec_NewPC,   -- out
			  rti_instruction_out => exec_rti_out
		);
		
	  -- Memory Block
	  mem_block_init : MemoryBlockSingleCycle port map (
			  clk => clk,
			  rst => rst,
			  memRead => mem_memRead,
			  memWrite => mem_memWrite,
			  
			  rti_instruction_flag_in => mem_rti_in,
		
			  wb_in_writeBack	=> mem_wbEnable,
			  wb_in_out_port_en => mem_outEnable,
			  wb_in_writeBack_selector => mem_wbSrcSel,
			  
			  -- Selectors for data and address muxes
			  address_mux_selector => mem_dmAddressSel,
			  data_mux_selector => mem_dmDataSel,
			  
			  pc_update => mem_pcUpdateEnable,
			  pc_update_selector => mem_pcUpdateSel,
			  
			  sp_update_selector => mem_spUpdateSel,
			  
			  in_alu_result => mem_alu_result,
			  in_dest_address => mem_dest_address_in,

			  pc_plus_one => mem_pc_plus_one_in,
			  in_r_src_1 => mem_r_src_1_in,
	  
			  wb_out_writeBack => mem_writeBack_out,
			  wb_out_out_port_en => mem_out_port_en_out,
			  wb_out_writeBack_selector => wb_out_writeBack_selector,
			  wb_out_alu_result => mem_alu_result_out,
			  wb_out_dm_data => mem_dm_data_out,
			  wb_out_r_src_1 => mem_r_src_1_out,
			  wb_out_dest_address => mem_dest_address_out,
			  
			  pc_plus_one_out	=> mem_pc_plus_one_out,
			  
			  new_pc	=> mem_new_pc,	  -- New PC (Rsrc1 or DM[SP]) Go to fetch
			  
			  exception_flag => mem_exception_flag,
			  exception_type => mem_exception_type,
			  flags => mem_restored_flags,
			  rti_instruction_flag_out => mem_rti_out,
			  
			  pc_update_out => mem_pc_update_out
	  );
		
		-- Mux to chose data in for DM
		wb_mux_init : Data_Mux PORT MAP (
            wb_wb_selector,					-- All here are signals of WB Stage
            wb_data_memory_data, 					
            wb_alu_result,				
				wb_mux_output					
        );


		
		outPort <= wb_r_src_1;


end architecture;



