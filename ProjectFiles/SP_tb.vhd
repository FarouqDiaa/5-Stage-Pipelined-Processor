LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.NUMERIC_STD.ALL; -- Include this library for comparison operatiops

ENTITY SP_tb IS
END SP_tb;

ARCHITECTURE behavior OF SP_tb IS
    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT SP
        PORT(
            clk     : IN std_logic;
            rst     : IN std_logic;
            sp_in   : IN std_logic_vector(15 DOWNTO 0);
            sp_out  : OUT std_logic_vector(15 DOWNTO 0)
        );
    END COMPONENT;

    -- Signals to connect to the UUT
    signal clk     : std_logic := '0';
    signal rst     : std_logic := '0';
    signal sp_in   : std_logic_vector(15 DOWNTO 0) := (others => '0');
    signal sp_out  : std_logic_vector(15 DOWNTO 0);
    
    -- Clock period definition
    constant clk_period : time := 10 ps;

BEGIN
    -- Ipstantiate the Unit Under Test (UUT)
    uut: SP PORT MAP (
        clk     => clk,
        rst     => rst,
        sp_in   => sp_in,
        sp_out  => sp_out
    );

    -- Clock generation process
    clock_process: PROCESS
    BEGIN
        -- Generate clock with 50% duty cycle
        while TRUE loop
            clk <= '0';
            wait for clk_period/2;
            clk <= '1';
            wait for clk_period/2;
        end loop;
    END PROCESS;

    -- Test sequence process
    test_process: PROCESS
    BEGIN
        -- Reset
        rst <= '1';
        sp_in <= (others => '0');
        wait for 20 ps; -- Hold reset for 20 ps
        ASSERT (sp_out = x"0FFF") -- Use hex literal to match reset value
            REPORT "error in Reset"
            SEVERITY error;

        rst <= '0'; -- Release reset
        sp_in <= x"1234";
        wait for clk_period * 2;
        ASSERT (sp_out = x"1234")
            REPORT "error in First Case"
            SEVERITY error;

        sp_in <= x"ABCD";
        wait for clk_period * 2;
        ASSERT (sp_out = x"ABCD")
            REPORT "error in Second Case"
            SEVERITY error;

        sp_in <= x"FFFF";
        wait for clk_period * 2;
        ASSERT (sp_out = x"FFFF")
            REPORT "error in Third Case"
            SEVERITY error;

        -- Simulation end
        ASSERT FALSE REPORT "Simulation finished successfully" SEVERITY NOTE;
        wait;
    END PROCESS;

END behavior;
