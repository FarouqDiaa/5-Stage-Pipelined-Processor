LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_unsigned.all;

entity Data_Mux is
    port( 
        selector      : in std_logic; -- Depending on the instruction
        data_1     : in std_logic_vector(15 downto 0);
        data_2     : in std_logic_vector(15 downto 0);
        data_out   : out std_logic_vector(15 downto 0)
    );
end Data_Mux;

architecture data_mux_architecture of Data_Mux is
    signal selected_data : std_logic_vector(15 downto 0);
begin

    selected_data <= data_1 when selector = '0' else data_2;

    data_out <= selected_data;

end data_mux_architecture;
