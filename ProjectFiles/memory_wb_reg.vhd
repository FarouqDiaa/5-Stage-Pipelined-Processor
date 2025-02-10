LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

entity memory_wb_reg is

    port (
        clock 				   	: in std_logic;
        reset 				  		: in std_logic;
        data_memory_data_in   : in std_logic_vector(15 downto 0);
		  data_memory_data_out  : out std_logic_vector(15 downto 0);
		  alu_result_in	      : in std_logic_vector(15 downto 0);
		  alu_result_out        : out std_logic_vector(15 downto 0);
		  r_src_1_in			   : in std_logic_vector(15 downto 0);
		  r_src_1_out				: out std_logic_vector(15 downto 0);
		  wb_selector_in  		: in std_logic;
		  wb_selector_out 		: out std_logic;
		  out_enable_in 		   : in std_logic;
		  out_enable_out		   : out std_logic;
		  wb_enable_in  			: in std_logic;
		  wb_enable_out 			: out std_logic;
		  dest_addres_in 			: in std_logic_vector(2 downto 0);
		  dest_addres_out 		: out std_logic_vector(2 downto 0)   
    );
end entity;

architecture memory_wb_reg_arch of memory_wb_reg is
    begin
        process (clock, reset)
        begin
            if reset = '1' then
            data_memory_data_out <= (others => '0');
            alu_result_out <= (others => '0');
            r_src_1_out <= (others => '0');
            wb_selector_out <= '0';
            out_enable_out <= '0';
            wb_enable_out <= '0';
            dest_addres_out <= (others => '0');
        elsif (rising_edge(clock)) then
            data_memory_data_out <= data_memory_data_in;
            alu_result_out <= alu_result_in;
            r_src_1_out <= r_src_1_in;
            wb_selector_out <= wb_selector_in;
            out_enable_out <= out_enable_in;
            wb_enable_out <= wb_enable_in;
            dest_addres_out <= dest_addres_in;
        end if;
        end process;
END architecture;
