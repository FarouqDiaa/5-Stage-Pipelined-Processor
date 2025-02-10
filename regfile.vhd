LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY regfile IS
    PORT (
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
END ENTITY;

ARCHITECTURE regfile_arch1 OF regfile IS
    COMPONENT axram IS
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
    END COMPONENT;

BEGIN
    -- Instantiate axram
    fx: axram PORT MAP (
        clk           => clk,
        we            => write_en,
        rst           => rst,
        read1_addres  => read_addres1,
        read2_addres  => read_addres2,
        write_adress  => write_adress,
        datain        => write_data,
        dataout1      => read_data1,
        dataout2      => read_data2
    );
END ARCHITECTURE regfile_arch1;
