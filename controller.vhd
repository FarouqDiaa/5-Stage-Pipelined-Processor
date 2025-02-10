
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE IEEE.std_logic_unsigned.ALL;

ENTITY controller IS
    PORT (
		  additional_bit : in std_logic;
        opcode : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		  rSrc1  : in std_logic_vector(2 downto 0);
        memWrite, memRead, wbEnable , resetF, int, hltFlush, hlt, unCondJump, jumpZero, jumpCarry, jumpNegative, callSig, inSignal, immSignal, rti, flagEnabe, ret, pop, push, outEnable, dmAddressSel, dmDataSel, wbSrcSel, pcUpdateEnable, pcUpdateSel, store : OUT STD_LOGIC;
        interrupt_index : out std_logic;
		  spUpdateSel : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		  baseop : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)

    );
END ENTITY;

ARCHITECTURE controllerFlow OF controller IS
BEGIN
    baseop <= opcode;
    PROCESS (opcode)
    BEGIN
        IF (opcode = "00000") THEN --NOP--
            memWrite <= '0';
            memRead <= '0';
            wbEnable <= '0';
            resetF <= '0';
            int <='0';
				hltFlush <='0';
				hlt <='0';
				
				rti <= '0';
				flagEnabe <= '0';
				
				unCondJump <= '0';
				jumpZero <='0';
				jumpCarry <='0';
				jumpNegative <='0';
				
				callSig <= '0';
				inSignal <= '0';
            immSignal <='0';
				
				ret <='0';
				pop <='0';
				push <='0';
				outEnable <= '0';		-- Added
				dmAddressSel <= '0'; -- Added
				dmDataSel <= '0'; 	-- Added
				pcUpdateEnable <= '0';-- Added
				pcUpdateSel <= '0';  -- Added
				wbSrcSel <= '0';
				spUpdateSel <= "00"; -- Added
				
				interrupt_index <= '0';
				store <= '0';
		 
        ELSIF (opcode = "00001") THEN --hlt--
            
            memWrite <= '0';
            memRead <= '0';
            wbEnable <= '0';
            resetF <= '0';
            int <='0';
				hltFlush <='1';
				hlt <='1';
				
				rti <= '0';
				flagEnabe <= '0';
				
				unCondJump <= '0';
				jumpZero <='0';
				jumpCarry <='0';
				jumpNegative <='0';
				
				callSig <= '0';
				inSignal <= '0';
            immSignal <='0';
				
				ret <='0';
				pop <='0';
				push <='0';
				outEnable <= '0';		-- Added
				dmAddressSel <= '0'; -- Added
				dmDataSel <= '0'; 	-- Added
				pcUpdateEnable <= '0';-- Added
				pcUpdateSel <= '0';  -- Added
				wbSrcSel <= '0';
				spUpdateSel <= "00"; -- Added
				interrupt_index <= '0';
				store <= '0';
				
        ELSIF (opcode = "00010") THEN --SETC--
            
            memWrite <= '0';
            memRead <= '0';
            wbEnable <= '0';
            resetF <= '0';
            int <='0';
				hltFlush <='0';
				hlt <='0';
				
				rti <= '0';
				flagEnabe <= '0';
				
				unCondJump <= '0';
				jumpZero <='0';
				jumpCarry <='0';
				jumpNegative <='0';
				
				callSig <= '0';
				inSignal <= '0';
            immSignal <='0';
				
				ret <='0';
				pop <='0';
				push <='0';
				outEnable <= '0';		-- Added
				dmAddressSel <= '0'; -- Added
				dmDataSel <= '0'; 	-- Added
				pcUpdateEnable <= '0';-- Added
				pcUpdateSel <= '0';  -- Added
				wbSrcSel <= '0';
				spUpdateSel <= "00"; -- Added
				interrupt_index <= '0';
				store <= '0';
				
        ELSIF (opcode = "00011") THEN --out--
            
            memWrite <= '0';
            memRead <= '0';
            wbEnable <= '0';
            resetF <= '0';
            int <='0';
				hltFlush <='0';
				hlt <='0';
				
				rti <= '0';
				flagEnabe <= '0';
				
				unCondJump <= '0';
				jumpZero <='0';
				jumpCarry <='0';
				jumpNegative <='0';
				
				callSig <= '0';
				inSignal <= '0';
            immSignal <='0';
				
				ret <='0';
				pop <='0';
				push <='0';
				outEnable <= '1'; -- Added
				dmAddressSel <= '0'; -- Added
				dmDataSel <= '0'; 	-- Added
				pcUpdateEnable <= '0';-- Added
				pcUpdateSel <= '0';  -- Added
				wbSrcSel <= '0';
				spUpdateSel <= "00"; -- Added
				interrupt_index <= '0';
				store <= '0';
				
        ELSIF (opcode = "00100") THEN --in--
		  
            memWrite <= '0';
            memRead <= '0';
            wbEnable <= '1';
            resetF <= '0';
            int <='0';
				hltFlush <='0';
				hlt <='0';
				
				rti <= '0';
				flagEnabe <= '0';
				
				unCondJump <= '0';
				jumpZero <='0';
				jumpCarry <='0';
				jumpNegative <='0';
				
				callSig <= '0';
				inSignal <= '1';
            immSignal <='0';
				
				ret <='0';
				pop <='0';
				push <='0';
				outEnable <= '0';		-- Added
				dmAddressSel <= '0'; -- Added
				dmDataSel <= '0'; 	-- Added
				pcUpdateEnable <= '0';-- Added
				pcUpdateSel <= '0';  -- Added
				wbSrcSel <= '1';
				spUpdateSel <= "00"; -- Added
				interrupt_index <= '0';
				store <= '0';
				
        ELSIF (opcode = "00101") THEN  --INT--
       
            memWrite <= '1';
            memRead <= '0';
            wbEnable <= '0';
            resetF <= '0';
            int <='1';
				hltFlush <='0';
				hlt <='0';
				
				rti <= '0';
				flagEnabe <= '0';
				
				unCondJump <= '0';
				jumpZero <='0';
				jumpCarry <='0';
				jumpNegative <='0';
				
				callSig <= '0';
				inSignal <= '0';
            immSignal <='0';
				
				ret <='0';
				pop <='0';
				push <='0';
				outEnable <= '0';		-- Added
				dmAddressSel <= '1'; -- Added
				dmDataSel <= '1'; 	-- Added -- Write PC+1 in DM[SP]
				pcUpdateEnable <= '0';-- Added
				pcUpdateSel <= '0';  -- Added
				wbSrcSel <= '0';
				spUpdateSel <= "10"; -- Added
				interrupt_index <= additional_bit;
				store <= '0';
				
        ELSIF (opcode = "00110") THEN --RTI--
       
            memWrite <= '0';
            memRead <= '1';
            wbEnable <= '0';
            resetF <= '0';
            int <='0';
				hltFlush <='0';
				hlt <='0';
				
				rti <= '1';
				flagEnabe <= '0';
				
				unCondJump <= '0';
				jumpZero <='0';
				jumpCarry <='0';
				jumpNegative <='0';
				
				callSig <= '0';
				inSignal <= '0';
            immSignal <='0';
				
				ret <='0';
				pop <='0';
				push <='0';
				outEnable <= '0';		-- Added
				dmAddressSel <= '1'; -- Added
				dmDataSel <= '0'; 	-- Added
				pcUpdateEnable <= '1';-- Added
				pcUpdateSel <= '1';  -- Added -- PC <= DM[SP]
				wbSrcSel <= '0';
				spUpdateSel <= "01"; -- Added
				interrupt_index <= '0';
				store <= '0';
				
-----------------------------------------------------      
		ELSIF (opcode = "01000") THEN --IADD--

            memWrite <= '0';
            memRead <= '0';
            wbEnable <= '1';
            resetF <= '0';
            int <='0';
				hltFlush <='0';
				hlt <='0';
				
				rti <= '0';
				flagEnabe <= '1';
				
				unCondJump <= '0';
				jumpZero <='0';
				jumpCarry <='0';
				jumpNegative <='0';
				
				callSig <= '0';
				inSignal <= '0';
            immSignal <='1';
				
				ret <='0';
				pop <='0';
				push <='0';	
				outEnable <= '0';		-- Added	
				dmAddressSel <= '0'; -- Added
				dmDataSel <= '0'; 	-- Added
				pcUpdateEnable <= '0';-- Added
				pcUpdateSel <= '0';  -- Added
				wbSrcSel <= '1';
				spUpdateSel <= "00"; -- Added
				interrupt_index <= '0';
				store <= '0';
				
	ELSIF (opcode = "01001") THEN --PUSH--
          
            memWrite <= '1';
            memRead <= '0';
            wbEnable <= '0';
            resetF <= '0';
            int <='0';
				hltFlush <='0';
				hlt <='0';
				
				rti <= '0';
				flagEnabe <= '0';
				
				unCondJump <= '0';
				jumpZero <='0';
				jumpCarry <='0';
				jumpNegative <='0';
				
				callSig <= '0';
				inSignal <= '0';
            immSignal <='0';
				
				ret <='0';
				pop <='0';
				push <='0'; 
				outEnable <= '0';		-- Added
				dmAddressSel <= '1'; -- Added
				dmDataSel <= '0'; 	-- Added  -- Write R[Src1] in DM[SP]
				pcUpdateEnable <= '0';-- Added
				pcUpdateSel <= '0';  -- Added
				wbSrcSel <= '0';
				spUpdateSel <= "10"; -- Added
				interrupt_index <= '0';
				store <= '0';
				
	ELSIF (opcode = "01010") THEN --POP--
	
            memWrite <= '0';
            memRead <= '1';
            wbEnable <= '1';
            resetF <= '0';
            int <='0';
				hltFlush <='0';
				hlt <='0';
				
				rti <= '0';
				flagEnabe <= '0';
				
				unCondJump <= '0';
				jumpZero <='0';
				jumpCarry <='0';
				jumpNegative <='0';
				
				callSig <= '0';
				inSignal <= '0';
            immSignal <='0';
				
				ret <='0';
				pop <='0';
				push <='0';
				outEnable <= '0';		-- Added
				dmAddressSel <= '1'; -- Added
				dmDataSel <= '0'; 	-- Added
				pcUpdateEnable <= '0';-- Added
				pcUpdateSel <= '0';  -- Added
				wbSrcSel <= '0';
				spUpdateSel <= "01"; -- Added
				interrupt_index <= '0';
				store <= '0';
				
	ELSIF (opcode = "01011") THEN --LDM--
            
            memWrite <= '0';
            memRead <= '1';
            wbEnable <= '1';
            resetF <= '0';
            int <='0';
				hltFlush <='0';
				hlt <='0';
				
				rti <= '0';
				flagEnabe <= '0';
				
				unCondJump <= '0';
				jumpZero <='0';
				jumpCarry <='0';
				jumpNegative <='0';
				
				callSig <= '0';
				inSignal <= '0';
            immSignal <='1';
				
				ret <='0';
				pop <='0';
				push <='0';
				outEnable <= '0';		-- Added
				dmAddressSel <= '0'; -- Added
				dmDataSel <= '0'; 	-- Added
				pcUpdateEnable <= '0';-- Added
				pcUpdateSel <= '0';  -- Added
				wbSrcSel <= '1';
				spUpdateSel <= "00"; -- Added
				interrupt_index <= '0';
				store <= '0';
				
        ELSIF (opcode = "01100") THEN --LDD--
            
            memWrite <= '0';
            memRead <= '1';
            wbEnable <= '1';
            resetF <= '0';
            int <='0';
				hltFlush <='0';
				hlt <='0';
				
				rti <= '0';
				flagEnabe <= '0';
				
				unCondJump <= '0';
				jumpZero <='0';
				jumpCarry <='0';
				jumpNegative <='0';
				
				callSig <= '0';
				inSignal <= '0';
            immSignal <='1';
				
				ret <='0';
				pop <='0';
				push <='0';
				outEnable <= '0';		-- Added
				dmAddressSel <= '0'; -- Added
				dmDataSel <= '0'; 	-- Added
				pcUpdateEnable <= '0';-- Added
				pcUpdateSel <= '0';  -- Added
				wbSrcSel <= '0';
				spUpdateSel <= "00"; -- Added
				interrupt_index <= '0';
				store <= '0';
				
        ELSIF (opcode = "01101") THEN --STD--
            
            memWrite <= '1';
            memRead <= '0';
            wbEnable <= '0';
            resetF <= '0';
            int <='0';
				hltFlush <='0';
				hlt <='0';
				
				rti <= '0';
				flagEnabe <= '0';
				
				unCondJump <= '0';
				jumpZero <='0';
				jumpCarry <='0';
				jumpNegative <='0';
				
				callSig <= '0';
				inSignal <= '0';
            immSignal <='1';
				
				ret <='0';
				pop <='0';
				push <='0';
				outEnable <= '0';		-- Added
				dmAddressSel <= '0'; -- Added
				dmDataSel <= '0'; 	-- Added  -- Write R[Src1] in DM[SP]
				pcUpdateEnable <= '0';-- Added
				pcUpdateSel <= '0';  -- Added
				wbSrcSel <= '0';
				spUpdateSel <= "00"; -- Added
				interrupt_index <= '0';
				store <= '1';
				
-------------------------------------------------		 
		ELSIF (opcode = "11000") THEN --NOT--

            memWrite <= '0';
            memRead <= '0';
            wbEnable <= '1';
            resetF <= '0';
            int <='0';
				hltFlush <='0';
				hlt <='0';
				
				rti <= '0';
				flagEnabe <= '1';
				
				unCondJump <= '0';
				jumpZero <='0';
				jumpCarry <='0';
				jumpNegative <='0';
				
				callSig <= '0';
				inSignal <= '0';
            immSignal <='0';
				
				ret <='0';
				pop <='0';
				push <='0';
				outEnable <= '0';		-- Added
				dmAddressSel <= '0'; -- Added
				dmDataSel <= '0'; 	-- Added
				pcUpdateEnable <= '0';-- Added
				pcUpdateSel <= '0';  -- Added
				wbSrcSel <= '1';
				spUpdateSel <= "00"; -- Added
				interrupt_index <= '0';
				store <= '0';
		
        ELSIF (opcode = "11001") THEN --INC--
		  
            memWrite <= '0';
            memRead <= '0';
            wbEnable <= '1';
            resetF <= '0';
            int <='0';
				hltFlush <='0';
				hlt <='0';
				
				rti <= '0';
				flagEnabe <= '1';
				
				unCondJump <= '0';
				jumpZero <='0';
				jumpCarry <='0';
				jumpNegative <='0';
				
				callSig <= '0';
				inSignal <= '0';
            immSignal <='0';
				
				ret <='0';
				pop <='0';
				push <='0';
				outEnable <= '0';		-- Added
				dmAddressSel <= '0'; -- Added
				dmDataSel <= '0'; 	-- Added
				pcUpdateEnable <= '0';-- Added
				pcUpdateSel <= '0';  -- Added
				wbSrcSel <= '1';
				spUpdateSel <= "00"; -- Added
				interrupt_index <= '0';
				store <= '0';
			
		 ELSIF (opcode = "11010") THEN --MOV--
		 
            memWrite <= '0';
            memRead <= '0';
            wbEnable <= '1';
            resetF <= '0';
            int <='0';
				hltFlush <='0';
				hlt <='0';
				
				rti <= '0';
				flagEnabe <= '0';
				
				unCondJump <= '0';
				jumpZero <='0';
				jumpCarry <='0';
				jumpNegative <='0';
				
				callSig <= '0';
				inSignal <= '0';
            immSignal <='0';
				
				ret <='0';
				pop <='0';
				push <='0';
				outEnable <= '0';		-- Added
				dmAddressSel <= '0'; -- Added
				dmDataSel <= '0'; 	-- Added
				pcUpdateEnable <= '0';-- Added
				pcUpdateSel <= '0';  -- Added
				wbSrcSel <= '1';
				spUpdateSel <= "00"; -- Added
				interrupt_index <= '0';
				store <= '0';

		 ELSIF (opcode = "11011") THEN --ADD--

            memWrite <= '0';
            memRead <= '0';
            wbEnable <= '1';
            resetF <= '0';
            int <='0';
				hltFlush <='0';
				hlt <='0';
				
				rti <= '0';
				flagEnabe <= '1';
				
				unCondJump <= '0';
				jumpZero <='0';
				jumpCarry <='0';
				jumpNegative <='0';
				
				callSig <= '0';
				inSignal <= '0';
            immSignal <='0';
				
				ret <='0';
				pop <='0';
				push <='0';
				outEnable <= '0';		-- Added
				dmAddressSel <= '0'; -- Added
				dmDataSel <= '0'; 	-- Added
				pcUpdateEnable <= '0';-- Added
				pcUpdateSel <= '0';  -- Added
				wbSrcSel <= '1';
				spUpdateSel <= "00"; -- Added
				interrupt_index <= '0';
				store <= '0';
       
        ELSIF (opcode = "11100") THEN --SUB--
		  
            memWrite <= '0';
            memRead <= '0';
            wbEnable <= '1';
            resetF <= '0';
            int <='0';
				hltFlush <='0';
				hlt <='0';
				
				rti <= '0';
				flagEnabe <= '1';
				
				unCondJump <= '0';
				jumpZero <='0';
				jumpCarry <='0';
				jumpNegative <='0';
				
				callSig <= '0';
				inSignal <= '0';
            immSignal <='0';
				
				ret <='0';
				pop <='0';
				push <='0';
				outEnable <= '0';		-- Added
				dmAddressSel <= '0'; -- Added
				dmDataSel <= '0'; 	-- Added
				pcUpdateEnable <= '0';-- Added
				pcUpdateSel <= '0';  -- Added
				wbSrcSel <= '1';
				spUpdateSel <= "00"; -- Added
				interrupt_index <= '0';
				store <= '0';
      
		 ELSIF (opcode = "11101") THEN --AND--
		 
            memWrite <= '0';
            memRead <= '0';
            wbEnable <= '1';
            resetF <= '0';
            int <='0';
				hltFlush <='0';
				hlt <='0';
				
				rti <= '0';
				flagEnabe <= '1';
				
				unCondJump <= '0';
				jumpZero <='0';
				jumpCarry <='0';
				jumpNegative <='0';
				
				callSig <= '0';
				inSignal <= '0';
            immSignal <='0';
				
				ret <='0';
				pop <='0';
				push <='0';
				outEnable <= '0';		-- Added
				dmAddressSel <= '0'; -- Added
				dmDataSel <= '0'; 	-- Added
				pcUpdateEnable <= '0';-- Added
				pcUpdateSel <= '0';  -- Added
				wbSrcSel <= '1';
				spUpdateSel <= "00"; -- Added
				interrupt_index <= '0';
				store <= '0';
				
--------------------------------------------------
		 
	ELSIF (opcode = "10000") THEN --JZ--
	
            memWrite <= '0';
            memRead <= '0';
            wbEnable <= '0';
            resetF <= '1';
            int <='0';
				hltFlush <='0';
				hlt <='0';
				
				rti <= '0';
				flagEnabe <= '0';
				
				unCondJump <= '0';
				jumpZero <='1';
				jumpCarry <='0';
				jumpNegative <='0';
				
				callSig <= '0';
				inSignal <= '0';
            immSignal <='0';
				
				ret <='0';
				pop <='0';
				push <='0';
				outEnable <= '0';		-- Added
				dmAddressSel <= '0'; -- Added
				dmDataSel <= '0'; 	-- Added
				pcUpdateEnable <= '0';-- Added
				pcUpdateSel <= '0';  -- Added
				wbSrcSel <= '0';
				spUpdateSel <= "00"; -- Added
				interrupt_index <= '0';
				store <= '0';
	
	ELSIF (opcode = "10001") THEN --JN--
	
            memWrite <= '0';
            memRead <= '0';
            wbEnable <= '0';
            resetF <= '1';
            int <='0';
				hltFlush <='0';
				hlt <='0';
				
				rti <= '0';
				flagEnabe <= '0';
				
				unCondJump <= '0';
				jumpZero <='0';
				jumpCarry <='0';
				jumpNegative <='1';
				
				callSig <= '0';
				inSignal <= '0';
            immSignal <='0';
				
				ret <='0';
				pop <='0';
				push <='0';
				outEnable <= '0';		-- Added
				dmAddressSel <= '0'; -- Added
				dmDataSel <= '0'; 	-- Added
				pcUpdateEnable <= '0';-- Added
				pcUpdateSel <= '0';  -- Added
				wbSrcSel <= '0';
				spUpdateSel <= "00"; -- Added
				interrupt_index <= '0';
				store <= '0';
		 		 
	ELSIF (opcode = "10010") THEN --JC--
            
            memWrite <= '0';
            memRead <= '0';
            wbEnable <= '0';
            resetF <= '1';
            int <='0';
				hltFlush <='0';
				hlt <='0';
				
				rti <= '0';
				flagEnabe <= '0';
				
				unCondJump <= '0';
				jumpZero <='0';
				jumpCarry <='1';
				jumpNegative <='0';
				
				callSig <= '0';
				inSignal <= '0';
            immSignal <='0';
				
				ret <='0';
				pop <='0';
				push <='0';
				outEnable <= '0';		-- Added
				dmAddressSel <= '0'; -- Added
				dmDataSel <= '0'; 	-- Added
				pcUpdateEnable <= '0';-- Added
				pcUpdateSel <= '0';  -- Added
				wbSrcSel <= '0';
				spUpdateSel <= "00"; -- Added
				interrupt_index <= '0';
				store <= '0';
		 
	ELSIF (opcode = "10011") THEN --JMP-- //need to check the document for aluEnable in jmp
       
            memWrite <= '0';
            memRead <= '0';
            wbEnable <= '0';
            resetF <= '0';
            int <='0';
				hltFlush <='0';
				hlt <='0';
				
				rti <= '0';
				flagEnabe <= '0';
				
				unCondJump <= '1';
				jumpZero <='0';
				jumpCarry <='0';
				jumpNegative <='0';
				
				callSig <= '0';
				inSignal <= '0';
            immSignal <='0';
				
				ret <='0';
				pop <='0';
				push <='0';
				outEnable <= '0';		-- Added
				dmAddressSel <= '0'; -- Added
				dmDataSel <= '0'; 	-- Added
				pcUpdateEnable <= '0';-- Added
				pcUpdateSel <= '0';  -- Added
				wbSrcSel <= '0';
				spUpdateSel <= "00"; -- Added
				interrupt_index <= '0';
				store <= '0';
				
	ELSIF (opcode = "10100") THEN --CALL-- //need to ask sth from document
	
            memWrite <= '1';
            memRead <= '0';
            wbEnable <= '0';
            resetF <= '0';
            int <='0';
				hltFlush <='0';
				hlt <='0';
				
				rti <= '0';
				flagEnabe <= '0';
				
				unCondJump <= '0';
				jumpZero <='0';
				jumpCarry <='0';
				jumpNegative <='0';
				
				callSig <= '1';
				inSignal <= '0';
            immSignal <='0';
				
				ret <='0';
				pop <='0';
				push <='0';
				outEnable <= '0';		-- Added
				dmAddressSel <= '1'; -- Added
				dmDataSel <= '1'; 	-- Added	-- Write PC+1 to DM[SP]
				pcUpdateEnable <= '1';-- Added
				pcUpdateSel <= '0';  -- Added -- PC <- R[Rsrc1]
				wbSrcSel <= '0';
				spUpdateSel <= "10"; -- Added
				interrupt_index <= '0';
				store <= '0';
				
	ELSIF (opcode = "10101") THEN --RET--

            memWrite <= '0';
            memRead <= '1';
            wbEnable <= '0';
            resetF <= '0';
            int <='0';
				hltFlush <='0';
				hlt <='0';
				
				rti <= '0';
				flagEnabe <= '0';
				
				unCondJump <= '0';
				jumpZero <='0';
				jumpCarry <='0';
				jumpNegative <='0';
				
				callSig <= '0';
				inSignal <= '0';
            immSignal <='0';
				
				ret <='0';
				pop <='0';
				push <='0';
				outEnable <= '0';		-- Added
				dmAddressSel <= '1'; -- Added
				dmDataSel <= '0'; 	-- Added
				pcUpdateEnable <= '1';-- Added
				pcUpdateSel <= '1';  -- Added -- PC <= DM[SP]
				wbSrcSel <= '0';
				spUpdateSel <= "01"; -- Added
				interrupt_index <= '0';
				store <= '0';
				
        END IF;
    END PROCESS;

END controllerFlow;
