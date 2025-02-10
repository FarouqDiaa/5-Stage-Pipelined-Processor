LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

entity execute_memory_reg is

    port (
        clock 				   : in std_logic;
        reset 				   : in std_logic;
		  -- Instruction
        alu_result_in     : in std_logic_vector(15 downto 0);
		  alu_result_out    : out std_logic_vector(15 downto 0);
		  dest_address_in	  : in std_logic_vector(2 downto 0);
		  dest_address_out  : out std_logic_vector(2 downto 0);
		  -- Next PC
		  pc_next_in    		: in std_logic_vector(15 downto 0);
		  pc_next_out    		: out std_logic_vector(15 downto 0);
		  -- Rsrc1
		  r_src_1_in			: in std_logic_vector(15 downto 0);
		  r_src_1_out			: out std_logic_vector(15 downto 0);
		  memWrite_in : in std_logic;
		  memWrite_out : out std_logic;
		  memRead_in : in std_logic;
		  memRead_out : out std_logic;
		  wbEnable_in : in std_logic;
		  wbEnable_out : out std_logic;
		  outEnable_in : in std_logic;
		  outEnable_out : out std_logic;
		  dmAddressSel_in : in std_logic;
		  dmAddressSel_out : out std_logic;
		  dmDataSel_in : in std_logic;
		  dmDataSel_out : out std_logic;
		  wbSrcSel_in : in std_logic;
		  wbSrcSel_out : out std_logic;
		  pcUpdateEnable_in : in std_logic;
		  pcUpdateEnable_out : out std_logic;
		  pcUpdateSel_in : in std_logic;
		  pcUpdateSel_out : out std_logic;
		  spUpdateSel_in : in std_logic_vector(1 downto 0);
		  spUpdateSel_out : out std_logic_vector(1 downto 0);
		  rti_in				: in std_logic;
		  rti_out				: out std_logic
		  --flush				: in std_logic
		     
    );
end entity;

architecture execute_memory_reg_arch of execute_memory_reg is
    begin
        process (clock, reset)
        begin
            if reset = '1'  then
                alu_result_out <= (others => '0');
                dest_address_out <= (others => '0');
                pc_next_out <= (others => '0');
                r_src_1_out <= (others => '0');
                memWrite_out <= '0';
                memRead_out <= '0';
                wbEnable_out <= '0';
                outEnable_out <= '0';
                dmAddressSel_out <= '0';
                dmDataSel_out <= '0';
                wbSrcSel_out <= '0';
                pcUpdateEnable_out <= '0';
                pcUpdateSel_out <= '0';
                spUpdateSel_out <= (others => '0');
                rti_out <= '0';
            elsif (rising_edge(clock)) then
                alu_result_out <= alu_result_in;
                dest_address_out <= dest_address_in;
                pc_next_out <= pc_next_in;
                r_src_1_out <= r_src_1_in;
                memWrite_out <= memWrite_in;
                memRead_out <= memRead_in;
                wbEnable_out <= wbEnable_in;
                outEnable_out <= outEnable_in;
                dmAddressSel_out <= dmAddressSel_in;
                dmDataSel_out <= dmDataSel_in;
                wbSrcSel_out <= wbSrcSel_in;
                pcUpdateEnable_out <= pcUpdateEnable_in;
                pcUpdateSel_out <= pcUpdateSel_in;
                spUpdateSel_out <= spUpdateSel_in;
                rti_out <= rti_in;
            end if;
        end process;
END architecture;
