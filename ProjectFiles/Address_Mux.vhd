LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_unsigned.all;

entity Address_Mux is
    port( 
        selector      : in std_logic; -- Depending on the instruction
        address_1     : in std_logic_vector(15 downto 0);
        address_2     : in std_logic_vector(15 downto 0);
        address_out   : out std_logic_vector(11 downto 0);
        exception     : out std_logic;
        exception_type: out std_logic_vector(1 downto 0)
    );
end Address_Mux;

architecture address_mux_architecture of Address_Mux is
    signal selected_address : std_logic_vector(15 downto 0) := (others => '0');
    signal exception_type_signal: std_logic_vector(1 downto 0) := (others => '0');
    signal exception_signal : std_logic := '0';
    signal internal_address_out : std_logic_vector(11 downto 0) := (others => '0'); -- Internal signal for address
begin
    -- Select the full 16-bit address based on the selector
    selected_address <= address_1 when selector = '0' else address_2;
    
    -- Check if the selected address exceeds 12 bits and set the exception
    exception_signal <= '1' when (selected_address(15) = '1' or 
                       selected_address(14) = '1' or 
                       selected_address(13) = '1' or 
                       selected_address(12) = '1') else '0';

    -- Data memory address is 12 bits only
    internal_address_out <= internal_address_out when exception_signal = '1' else selected_address(11 downto 0); -- Don't change the address if new address is invalid

    -- Assign exception_type based on selector and exception_signal
    exception_type_signal <= "10" when (selector = '0' and exception_signal = '1') else
                             "01" when (selector = '1' and exception_signal = '1') else
                             "00"; -- Default case when no exception occurs

    exception <= exception_signal;
    exception_type <= exception_type_signal;
    address_out <= internal_address_out;

end address_mux_architecture;

