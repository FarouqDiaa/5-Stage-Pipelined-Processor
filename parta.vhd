LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY parta IS
    PORT (
        A, B  : IN std_logic_vector(7 DOWNTO 0);  
        SEL   : IN std_logic_vector(3 DOWNTO 0);  
        Cin   : IN std_logic;                     
        F     : OUT std_logic_vector(7 DOWNTO 0); 
        Cout  : OUT std_logic                     
    );
END parta;

ARCHITECTURE arch_parta OF parta IS
    COMPONENT my_nadder IS
        GENERIC (n : integer := 8);
        PORT (
            a, b : IN std_logic_vector(n-1 DOWNTO 0);
            cin  : IN std_logic;
            s    : OUT std_logic_vector(n-1 DOWNTO 0);
            cout : OUT std_logic
        );
    END COMPONENT;

    SIGNAL B_inverted : std_logic_vector(7 DOWNTO 0);  
	 
    SIGNAL F_add      : std_logic_vector(7 DOWNTO 0);  -- A + B + Cin
    SIGNAL Cout_add   : std_logic;  						 

    SIGNAL F_acin     : std_logic_vector(7 DOWNTO 0);  -- A + Cin
    SIGNAL Cout_acin  : std_logic;  						 

    SIGNAL F_sub      : std_logic_vector(7 DOWNTO 0);  -- A - B -1 +Cin
    SIGNAL Cout_sub   : std_logic;  

    SIGNAL F_dec      : std_logic_vector(7 DOWNTO 0);  -- A - 1 + Cin
    SIGNAL Cout_dec   : std_logic;  

    SIGNAL all_ones   : std_logic_vector(7 DOWNTO 0) := (others => '1'); 
BEGIN
   
    B_inverted <= NOT B;

    U_acin: my_nadder PORT MAP(A, (others => '0'), Cin, F_acin, Cout_acin);

    U_add: my_nadder PORT MAP(A, B, Cin, F_add, Cout_add);

    U_sub: my_nadder PORT MAP(A, B_inverted, Cin, F_sub, Cout_sub);

    U_dec: my_nadder PORT MAP(A, all_ones, Cin, F_dec, Cout_dec);

   
    F <= F_acin WHEN SEL(1 DOWNTO 0) = "00" ELSE  
         F_add  WHEN SEL(1 DOWNTO 0) = "01" ELSE  
         F_sub  WHEN SEL(1 DOWNTO 0) = "10" ELSE  
         F_dec;                                   

    
    Cout <= Cout_acin WHEN SEL(1 DOWNTO 0) = "00" ELSE  
            Cout_add  WHEN SEL(1 DOWNTO 0) = "01" ELSE  
            Cout_sub  WHEN SEL(1 DOWNTO 0) = "10" ELSE  
            Cout_dec;                                   
END arch_parta;
