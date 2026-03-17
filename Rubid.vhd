
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Rubid is
    Port ( S : in STD_LOGIC_VECTOR (2 downto 0);
           Clk : in STD_LOGIC;
           Q_all : out STD_LOGIC_VECTOR (71 downto 0)
           );
end Rubid;

architecture structural of Rubid is
    component Facelet is
    Port ( 
        MD, MB, ML, MU, MR, MF : in STD_LOGIC_VECTOR (2 downto 0); --cndidate entry line, eg move R (MR) shift value from MR line
        load_init : in std_logic_vector( 2 downto 0); --set init color
        S : in std_logic_vector(2 downto 0); -- selector
        Clk : in std_logic; 
        Q : out std_logic_vector( 2 downto 0) --3bit output represent cur color
    );
    end component;
    signal up : std_logic_vector(2 downto 0):="000";
    signal front : std_logic_vector(2 downto 0):="001";
    signal left : std_logic_vector(2 downto 0):="010";
    signal right : std_logic_vector(2 downto 0):="011";
    signal down : std_logic_vector(2 downto 0):="100";
    signal back : std_logic_vector(2 downto 0):="101";

    signal s_u0, s_u1, s_u2, s_u3 : std_logic_vector(2 downto 0);
    signal s_f0, s_f1, s_f2, s_f3 : std_logic_vector(2 downto 0);
    signal s_l0, s_l1, s_l2, s_l3 : std_logic_vector(2 downto 0);
    signal s_r0, s_r1, s_r2, s_r3 : std_logic_vector(2 downto 0);
    signal s_b0, s_b1, s_b2, s_b3 : std_logic_vector(2 downto 0);
    signal s_d0, s_d1, s_d2, s_d3 : std_logic_vector(2 downto 0);

    --fortesteing 
    -- 1. Declare the ILA Component
    signal s_q_all: STD_LOGIC_VECTOR (71 downto 0);
--    component ila_0
--    PORT (
--        clk : IN STD_LOGIC;
--        probe0 : IN STD_LOGIC_VECTOR(2 DOWNTO 0); 
--        probe1 : IN STD_LOGIC_VECTOR(71 DOWNTO 0)
--    );
--    end component;    
    
begin
    -- UP FACE
    U0: Facelet port map(
        S=>S, Clk=>Clk, 
        Q=>s_u0, MF=>s_u0, MR=>s_u0, MU=>s_u3, ML=>s_b3, MB=>s_r1, MD=>s_u0, load_init=>up
    ); 
    U1: Facelet port map(
        S=>S, Clk=>Clk,
        Q=>s_u1, MF=>s_u1, MR=>s_f1, MU=>s_u2, ML=>s_u1, MB=>s_r3, MD=>s_u1, load_init=>up
    ); 
    U2: Facelet port map(
        S=>S, Clk=>Clk, 
        Q=>s_u2, MF=>s_l3, MR=>s_u2, MU=>s_u1, ML=>s_b1, MB=>s_u2, MD=>s_u2, load_init=>up
    ); 
    U3: Facelet port map(
        S=>S, Clk=>Clk, 
        Q=>s_u3, MF=>s_l1, MR=>s_f3, MU=>s_u0, ML=>s_u3, MB=>s_u3, MD=>s_u3, load_init=>up
    ); 

    -- FRONT FACE 
    F0: Facelet port map(
        S=>S, Clk=>Clk,
        Q=>s_f0, MF=>s_f3, MR=>s_f0, MU=>s_r0, ML=>s_u0, MB=>s_f0, MD=>s_f0, load_init=>front
    ); 
    F1: Facelet port map(
        S=>S, Clk=>Clk, 
        Q=>s_f1, MF=>s_f2, MR=>s_d1, MU=>s_r1, ML=>s_f1, MB=>s_f1, MD=>s_f1, load_init=>front
    ); 
    F2: Facelet port map(
        S=>S, Clk=>Clk, 
        Q=>s_f2, MF=>s_f1, MR=>s_f2, MU=>s_f2, ML=>s_u2, MB=>s_f2, MD=>s_l2, load_init=>front
    ); 
    F3: Facelet port map(
        S=>S, Clk=>Clk, 
        Q=>s_f3, MF=>s_f0, MR=>s_d3, MU=>s_f3, ML=>s_f3, MB=>s_f3, MD=>s_l3, load_init=>front
    ); 

    -- DOWN FACE
    D0: Facelet port map(
        S=>S, Clk=>Clk, 
        Q=>s_d0, MF=>s_r2, MR=>s_d0, MU=>s_d0, ML=>s_f0, MB=>s_d0, MD=>s_d3, load_init=>down
    ); 
    D1: Facelet port map(
        S=>S, Clk=>Clk, 
        Q=>s_d1, MF=>s_r0, MR=>s_b2, MU=>s_d1, ML=>s_d1, MB=>s_d1, MD=>s_d2, load_init=>down
    ); 
    D2: Facelet port map(
        S=>S, Clk=>Clk, 
        Q=>s_d2, MF=>s_d2, MR=>s_d2, MU=>s_d2, ML=>s_f2, MB=>s_l0, MD=>s_d1, load_init=>down
    ); 
    D3: Facelet port map(
        S=>S, Clk=>Clk, 
        Q=>s_d3, MF=>s_d3, MR=>s_b0, MU=>s_d3, ML=>s_d3, MB=>s_l2, MD=>s_d0, load_init=>down
    ); 

    -- LEFT FACE (011)
    L0: Facelet port map(
        S=>S, Clk=>Clk, 
        Q=>s_l0, MF=>s_l0, MR=>s_l0, MU=>s_f0, ML=>s_l3, MB=>s_u1, MD=>s_l0, load_init=>left
    ); 
    L1: Facelet port map(
        S=>S, Clk=>Clk, 
        Q=>s_l1, MF=>s_d0, MR=>s_l1, MU=>s_f1, ML=>s_l2, MB=>s_l1, MD=>s_l1, load_init=>left
    ); 
    L2: Facelet port map(
        S=>S, Clk=>Clk, 
        Q=>s_l2, MF=>s_l2, MR=>s_l2, MU=>s_l2, ML=>s_l1, MB=>s_u0, MD=>s_b2, load_init=>left
    ); 
    L3: Facelet port map(
        S=>S, Clk=>Clk, 
        Q=>s_l3, MF=>s_d1, MR=>s_l3, MU=>s_l3, ML=>s_l0, MB=>s_l3, MD=>s_b3, load_init=>left
    ); 

    -- RIGHT FACE (100)
    R0: Facelet port map(
        S=>S, Clk=>Clk, 
        Q=>s_r0, MF=>s_u2, MR=>s_r3, MU=>s_b0, ML=>s_r0, MB=>s_r0, MD=>s_r0, load_init=>right
    ); 
    R1: Facelet port map(
        S=>S, Clk=>Clk, 
        Q=>s_r1, MF=>s_r1, MR=>s_r2, MU=>s_b1, ML=>s_r1, MB=>s_d3, MD=>s_r1, load_init=>right
    ); 
    R2: Facelet port map(
        S=>S, Clk=>Clk, 
        Q=>s_r2, MF=>s_u3, MR=>s_r1, MU=>s_r2, ML=>s_r2, MB=>s_r2, MD=>s_f2, load_init=>right
    ); 
    R3: Facelet port map(
        S=>S, Clk=>Clk, 
        Q=>s_r3, MF=>s_r3, MR=>s_r0, MU=>s_r3, ML=>s_r3, MB=>s_d2, MD=>s_f3, load_init=>right
    ); 

    -- BACK FACE
    B0: Facelet port map(
        S=>S, Clk=>Clk, 
        Q=>s_b0, MF=>s_b0, MR=>s_u3, MU=>s_l0, ML=>s_b0, MB=>s_b3, MD=>s_b0, load_init=>back
    ); 
    B1: Facelet port map(
        S=>S, Clk=>Clk, 
        Q=>s_b1, MF=>s_b1, MR=>s_b1, MU=>s_l1, ML=>s_d2, MB=>s_b2, MD=>s_b1, load_init=>back
    ); 
    B2: Facelet port map(
        S=>S, Clk=>Clk, 
        Q=>s_b2, MF=>s_b2, MR=>s_u1, MU=>s_b2, ML=>s_b2, MB=>s_b1, MD=>s_r2, load_init=>back
    ); 
    B3: Facelet port map(
        S=>S, Clk=>Clk, 
        Q=>s_b3, MF=>s_b3, MR=>s_b3, MU=>s_b3, ML=>s_d0, MB=>s_b0, MD=>s_r3, load_init=>back
    );
    
    -- Concatenate for Output and ILA
    s_q_all <= s_u0 & s_u1 & s_u2 & s_u3 &   -- Up face
               s_f0 & s_f1 & s_f2 & s_f3 &   -- Front face
               s_l0 & s_l1 & s_l2 & s_l3 &   -- Left face
               s_r0 & s_r1 & s_r2 & s_r3 &   -- Right face
               s_b0 & s_b1 & s_b2 & s_b3 &   -- Back face
               s_d0 & s_d1 & s_d2 & s_d3;    -- Down face

    Q_all <= s_q_all; 
--    your_ila_instance : ila_0
--    port map (
--        clk => Clk,      -- Connect to your system clock
--        probe0 => S,     -- Monitor your switches
--        probe1 => s_q_all  -- Monitor your 72-bit output
--    );    
end structural;