LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_unsigned.all;

entity D_FF is
    port (
        clk      : in std_logic;
		  rst      : in std_logic;
        data_in  : in std_logic_vector(15 downto 0);
        data_out : out std_logic_vector(15 downto 0)
    );
end entity;

architecture dff_arch of D_FF is
begin
    process(clk)
    begin
        if rst = '1' then
            data_out <= x"0FFF";
        elsif falling_edge(clk) then
            data_out <= data_in;
        end if;
    end process;
end architecture;
