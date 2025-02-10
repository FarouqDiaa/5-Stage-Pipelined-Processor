LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_unsigned.all;

entity SP_Mux is
    port( 
        selector  : in std_logic_vector(1 downto 0);
        sp_in     : in std_logic_vector(15 downto 0);
        sp_dm_out : out std_logic_vector(15 downto 0);
        sp_sp_out : out std_logic_vector(15 downto 0)
    );
end SP_Mux;

architecture sp_mux_arc of SP_Mux is
begin
    with selector select
        sp_dm_out <= sp_in + 1 when "01",     -- Return sp + 1 to DM address (pop, ret, tri)
                      sp_in when others;       -- Return sp to DM address (push, call, int)

    process(sp_in, selector)
    begin
        case selector is
            when "01" =>
                if sp_in + 1 <= 4095 then
                    sp_sp_out <= sp_in + 1;    -- Return sp + 1 to SP register if within range
                else
                    sp_sp_out <= sp_in;        -- Default to sp if condition not met
                end if;
            when "10" =>
                sp_sp_out <= sp_in - 1;        -- Return sp - 1 to SP register (push, call, int)
            when others =>
                sp_sp_out <= sp_in;            -- Default case: SP unchanged
        end case;
    end process;

END sp_mux_arc;
