library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Cube_Core is
    Port ( S : in STD_LOGIC_VECTOR (2 downto 0);
           Clk : in STD_LOGIC;
           Q_all : out STD_LOGIC_VECTOR (71 downto 0)
           );
end Cube_Core;

architecture structural of Cube_Core is
    signal u0,u1,u2,u3, f0,f1,f2,f3, l0,l1,l2,l3, r0,r1,r2,r3, b0,b1,b2,b3, d0,d1,d2,d3 : std_logic_vector(2 downto 0);
    
    constant U_C : std_logic_vector(2 downto 0) := "000"; -- WHT
    constant F_C : std_logic_vector(2 downto 0) := "001"; -- GRN
    constant L_C : std_logic_vector(2 downto 0) := "010"; -- ORG
    constant R_C : std_logic_vector(2 downto 0) := "011"; -- RED
    constant D_C : std_logic_vector(2 downto 0) := "100"; -- YLW
    constant B_C : std_logic_vector(2 downto 0) := "101"; -- BLU
begin
 -- UP FACE (U-Turn Rotation)
    INST_U0: entity work.Facelet_Unit port map(S=>S, Clk=>Clk, Q=>u0, init=>U_C, MU=>u3, MF=>l3, MR=>f0, ML=>b3, MB=>r1, MD=>u0); 
    INST_U1: entity work.Facelet_Unit port map(S=>S, Clk=>Clk, Q=>u1, init=>U_C, 
             MU=>u0, MF=>l2, MR=>f1, ML=>b2, MB=>r0, MD=>u1); 
    INST_U2: entity work.Facelet_Unit port map(S=>S, Clk=>Clk, Q=>u2, init=>U_C, 
             MU=>u1, MF=>f2, MR=>f2, ML=>u2, MB=>u2, MD=>u2); 
    INST_U3: entity work.Facelet_Unit port map(S=>S, Clk=>Clk, Q=>u3, init=>U_C, 
             MU=>u2, MF=>f3, MR=>f3, ML=>u3, MB=>u3, MD=>u3);
             
    -- FRONT FACE (F-Turn Rotation)
    INST_F0: entity work.Facelet_Unit port map(S=>S, Clk=>Clk, Q=>f0, init=>F_C, MF=>f3, MU=>r0, MR=>f0, ML=>u3, MB=>f0, MD=>l2); 
    INST_F1: entity work.Facelet_Unit port map(S=>S, Clk=>Clk, Q=>f1, init=>F_C, MF=>f0, MU=>r1, MR=>d1, ML=>u2, MB=>f1, MD=>l3); 
    INST_F2: entity work.Facelet_Unit port map(S=>S, Clk=>Clk, Q=>f2, init=>F_C, MF=>f1, MU=>f2, MR=>d0, ML=>f2, MB=>f2, MD=>f2); 
    INST_F3: entity work.Facelet_Unit port map(S=>S, Clk=>Clk, Q=>f3, init=>F_C, MF=>f2, MU=>f3, MR=>f3, ML=>f3, MB=>f3, MD=>f3); 

    -- RIGHT FACE (R-Turn Rotation)
    INST_R0: entity work.Facelet_Unit port map(S=>S, Clk=>Clk, Q=>r0, init=>R_C, MR=>r3, MF=>d1, MU=>b3, ML=>r0, MB=>u1, MD=>f1);
    INST_R1: entity work.Facelet_Unit port map(S=>S, Clk=>Clk, Q=>r1, init=>R_C, MR=>r0, MF=>d2, MU=>b2, ML=>r1, MB=>u2, MD=>f2);
    INST_R2: entity work.Facelet_Unit port map(S=>S, Clk=>Clk, Q=>r2, init=>R_C, MR=>r1, MF=>r2, MU=>r2, ML=>r2, MB=>r2, MD=>r2);
    INST_R3: entity work.Facelet_Unit port map(S=>S, Clk=>Clk, Q=>r3, init=>R_C, MR=>r2, MF=>r3, MU=>r3, ML=>r3, MB=>r3, MD=>r3);

    -- BACK FACE
    INST_B0: entity work.Facelet_Unit port map(S=>S, Clk=>Clk, Q=>b0, init=>B_C, MB=>b3, MF=>b0, MU=>l0, ML=>u1, MR=>d2, MD=>b0);
    INST_B1: entity work.Facelet_Unit port map(S=>S, Clk=>Clk, Q=>b1, init=>B_C, MB=>b0, MF=>b1, MU=>l1, MD=>r3, ML=>u0, MR=>d3);
    INST_B2: entity work.Facelet_Unit port map(S=>S, Clk=>Clk, Q=>b2, init=>B_C, MB=>b1, MF=>b2, MU=>b2, ML=>b2, MR=>b2, MD=>b2);
    INST_B3: entity work.Facelet_Unit port map(S=>S, Clk=>Clk, Q=>b3, init=>B_C, MB=>b2, MF=>b3, MU=>b3, ML=>b3, MR=>b3, MD=>b3);

    -- LEFT FACE
    INST_L0: entity work.Facelet_Unit port map(S=>S, Clk=>Clk, Q=>l0, init=>L_C, ML=>l3, MF=>u0, MU=>f0, MD=>b0, MB=>d0, MR=>l0);
    INST_L1: entity work.Facelet_Unit port map(S=>S, Clk=>Clk, Q=>l1, init=>L_C, ML=>l0, MF=>u1, MU=>f1, MD=>b1, MB=>d1, MR=>l1);
    INST_L2: entity work.Facelet_Unit port map(S=>S, Clk=>Clk, Q=>l2, init=>L_C, ML=>l1, MF=>l2, MU=>l2, MD=>l2, MB=>l2, MR=>l2);
    INST_L3: entity work.Facelet_Unit port map(S=>S, Clk=>Clk, Q=>l3, init=>L_C, ML=>l2, MF=>l3, MU=>l3, MD=>l3, MB=>l3, MR=>l3);

    -- DOWN FACE
    INST_D0: entity work.Facelet_Unit port map(S=>S, Clk=>Clk, Q=>d0, init=>D_C, MD=>d3, MF=>r2, MR=>b2, ML=>f2, MB=>l2, MU=>d0);
    INST_D1: entity work.Facelet_Unit port map(S=>S, Clk=>Clk, Q=>d1, init=>D_C, MD=>d0, MF=>r3, MR=>b3, ML=>f3, MB=>l3, MU=>d1);
    INST_D2: entity work.Facelet_Unit port map(S=>S, Clk=>Clk, Q=>d2, init=>D_C, MD=>d1, MF=>d2, MR=>d2, ML=>d2, MB=>d2, MU=>d2);
    INST_D3: entity work.Facelet_Unit port map(S=>S, Clk=>Clk, Q=>d3, init=>D_C, MD=>d2, MF=>d3, MR=>d3, ML=>d3, MB=>d3, MU=>d3);

    Q_all <= u0 & u1 & u2 & u3 & f0 & f1 & f2 & f3 & l0 & l1 & l2 & l3 & r0 & r1 & r2 & r3 & b0 & b1 & b2 & b3 & d0 & d1 & d2 & d3;
end structural;