LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY fetch_stage IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;

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

        port_input : IN STD_LOGIC_VECTOR(15 DOWNTO 0); -- Input port
        port_output : OUT STD_LOGIC_VECTOR(15 DOWNTO 0); -- Output port

        immediate_value_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0); -- Immediate value
        pc_next : OUT STD_LOGIC_VECTOR(15 DOWNTO 0); -- Next PC value
        instruction : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) -- Instruction output
    );
END fetch_stage;

ARCHITECTURE fetch_stage_arch OF fetch_stage IS
    SIGNAL pc_internal : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0'); -- Internal PC signal
    SIGNAL pc_mux_1_output : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0'); -- Output of the first PC MUX
    SIGNAL pc_mux_1_output_b : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0'); -- Output of the first PC MUX

    SIGNAL pc_mux_2_output : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0'); -- Output of the second PC MUX

    SIGNAL mux_1_output : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0'); -- Output of the first MUX
    SIGNAL mux_2_output : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0'); -- Output of the second MUX

    SIGNAL fetched_instruction1 : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0'); -- Current instruction
    SIGNAL fetched_instruction2 : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0'); -- Next instruction
    SIGNAL fetched_instruction_final : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL fetched_instruction_final2 : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');

    SIGNAL immediate_value : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0'); -- Immediate Value
    SIGNAL epc : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0'); -- EPC Value

    SIGNAL interrupt_index_unsigned : STD_LOGIC := '0';

    SIGNAL next_pc_internal : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL exception_handler_address_internal : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL exception_signal_internal : STD_LOGIC := '0';
    SIGNAL exception_type_internal : STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0');

    SIGNAL effective_exception_signal : STD_LOGIC := '0';
    SIGNAL effective_exception_type : STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0');

    SIGNAL int_0 : STD_LOGIC_VECTOR(15 DOWNTO 0) := "0000100000000000"; -- IM [3]
    SIGNAL int_1 : STD_LOGIC_VECTOR(15 DOWNTO 0) := "0000101000000000"; -- IM [4]

    SIGNAL pc_exception : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');

    -- COMPONENT DECLARATIONS
    COMPONENT pc IS
        PORT (
            clk : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            freeze_signal : IN STD_LOGIC;
            hlt_signal : IN STD_LOGIC;
            address : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            counter : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT instruction_memory IS
        PORT (
            clk : IN STD_LOGIC;
            address : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
            instruction1 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            instruction2 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            interrupt_0 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            interrupt_1 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT exception_handler IS
        PORT (
            exception_type : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            reset : IN STD_LOGIC;
            next_pc : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            exception_handler_signal : IN STD_LOGIC;
            exception_address : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            epc : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT F_D_FF IS
        PORT (
            clk : IN STD_LOGIC;
            rst : IN STD_LOGIC;
            data_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            data_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
    END COMPONENT;

BEGIN

    -- PC ENTITY INSTANCE
    PC_Instance : pc
    PORT MAP(
        clk => clk,
        reset => reset,
        freeze_signal => freeze_signal,
        hlt_signal => hlt_signal,
        address => mux_2_output,
        counter => pc_internal
    );

    -- INSTRUCTION MEMORY ENTITY INSTANCE
    IM_Instance : instruction_memory
    PORT MAP(
        clk => clk,
        address => pc_internal(11 DOWNTO 0),
        instruction1 => fetched_instruction1,
        instruction2 => fetched_instruction2,
        interrupt_0 => int_0,
        interrupt_1 => int_1
    );

    -- EXCEPTION HANDLER ENTITY INSTANCE
    EXC_Handler : exception_handler
    PORT MAP(
        exception_type => effective_exception_type,
        reset => reset,
        next_pc => pc_exception,
        exception_handler_signal => effective_exception_signal,
        exception_address => exception_handler_address_internal,
        epc => epc
    );
    D_FF_Instance : F_D_FF
    PORT MAP(
        clk => clk,
        rst => reset,
        data_in => pc_mux_1_output,
        data_out => pc_mux_1_output_b
    );

    -- Combine internal and external exception signals and types
    -- Reset condition
    effective_exception_signal <= '0' WHEN reset = '1' ELSE
        '1' WHEN exception_signal = '1' ELSE
        '1' WHEN exception_signal_internal = '1' ELSE
        '0';

    effective_exception_type <= (OTHERS => '0') WHEN reset = '1' ELSE
        exception_type WHEN exception_signal = '1' ELSE
        exception_type_internal WHEN exception_signal_internal = '1' ELSE
        (OTHERS => '0');

    pc_exception <= next_pc_internal WHEN exception_signal_internal = '1' ELSE
        old_pc;

    -- PC MUX 1: Select between PC + 1 or PC + 2
    pc_mux_1_output <= STD_LOGIC_VECTOR(unsigned(pc_internal) + 2) WHEN fetched_instruction1(15 DOWNTO 14) = "01" ELSE
        STD_LOGIC_VECTOR(unsigned(pc_internal) + 1);

    next_pc_internal <= pc_mux_1_output_b;

    -- PC MUX 2: Select between Immediate or 0s
    pc_mux_2_output <= fetched_instruction2 WHEN fetched_instruction1(15 DOWNTO 14) = "01" ELSE
        (OTHERS => '0');

    immediate_value <= pc_mux_2_output;

    -- First MUX: Select between jump, call/return, or PC increment
    mux_1_output <= call_return_address WHEN call_return_signal = '1' ELSE
        jump_address WHEN jump_signal = '1' ELSE
        next_pc_internal;

    -- Second MUX: Handle exceptions and interrupts
    mux_2_output <= exception_handler_address_internal WHEN effective_exception_signal = '1' ELSE
        int_1 WHEN interrupt_signal = '1' AND interrupt_index_unsigned = '1' ELSE
        int_0 WHEN interrupt_signal = '1' AND interrupt_index_unsigned = '0' ELSE
        mux_1_output;

    -- Address overflow check
    exception_signal_internal <= '1' WHEN unsigned(pc_internal) > 4095 ELSE
        '0';

    exception_type_internal <= "11" WHEN unsigned(pc_internal) > 4095 ELSE
        (OTHERS => '0');

    -- Assign outputs
    pc_next <= pc_mux_1_output;
    PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF reset = '0' THEN
                fetched_instruction_final <= fetched_instruction1;
                fetched_instruction_final2 <= immediate_value;
            ELSE
                fetched_instruction_final <= (OTHERS => '0');
                fetched_instruction_final2 <= (OTHERS => '0');
            END IF;
        END IF;
    END PROCESS;

    instruction <= fetched_instruction_final;
    immediate_value_out <= fetched_instruction_final2;
    port_output <= port_input;
END fetch_stage_arch;