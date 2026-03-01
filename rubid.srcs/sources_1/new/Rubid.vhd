----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/01/2026 04:49:44 PM
-- Design Name: 
-- Module Name: Rubid - structural
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Rubid is
    Port ( S : in STD_LOGIC_VECTOR (2 downto 0);
           Clk : in STD_LOGIC;
           Q_all : out STD_LOGIC_VECTOR (71 downto 0);
           -- for test
           out_U0, out_U3, out_U6, out_U9 : out std_logic_vector(2 downto 0);
            -- FRONT Face
            out_F0, out_F3, out_F6, out_F9 : out std_logic_vector(2 downto 0);
            -- LEFT Face
            out_L0, out_L3, out_L6, out_L9 : out std_logic_vector(2 downto 0);
            -- RIGHT Face
            out_R0, out_R3, out_R6, out_R9 : out std_logic_vector(2 downto 0);
            -- BACK Face
            out_B0, out_B3, out_B6, out_B9 : out std_logic_vector(2 downto 0);
            -- DOWN Face
            out_D0, out_D3, out_D6, out_D9 : out std_logic_vector(2 downto 0)
           );
end Rubid;

architecture structural of Rubid is
    component Facelet is
    Port ( 
        W3, W2, W1, W0 : in STD_LOGIC_VECTOR (2 downto 0);
        Pre : in std_logic_vector( 2 downto 0);
        S : in std_logic_vector(2 downto 0);
        Clk : in std_logic;
        Q : out std_logic_vector( 2 downto 0)
    );
    end component;
    signal up : std_logic_vector(2 downto 0):="000";
    signal front : std_logic_vector(2 downto 0):="001";
    signal left : std_logic_vector(2 downto 0):="010";
    signal right : std_logic_vector(2 downto 0):="011";
    signal down : std_logic_vector(2 downto 0):="100";
    signal back : std_logic_vector(2 downto 0):="101";

    signal s_u0, s_u3, s_u6, s_u9 : std_logic_vector(2 downto 0);
    signal s_f0, s_f3, s_f6, s_f9 : std_logic_vector(2 downto 0);
    signal s_l0, s_l3, s_l6, s_l9 : std_logic_vector(2 downto 0);
    signal s_r0, s_r3, s_r6, s_r9 : std_logic_vector(2 downto 0);
    signal s_b0, s_b3, s_b6, s_b9 : std_logic_vector(2 downto 0);
    signal s_d0, s_d3, s_d6, s_d9 : std_logic_vector(2 downto 0);

    
    
begin
    U0: Facelet port map(
        S => S, Clk => Clk, Pre => up,
        Q => s_u0,
        W0 => s_f0,
        W1 => s_u0,
        W2 => s_u9,
        W3 => s_u0 
    );
    U3: Facelet port map(
        S => S, Clk => Clk, Pre => up,
        Q => s_u3,
        W0 => s_u3,
        W1 => s_f3,
        W2 => s_u6, 
        W3 => s_u3     
    );
    U6: Facelet port map(
        S => S, Clk => Clk, Pre => up,
        Q => s_u6,
        W0 => s_f6,
        W1 => s_u6,
        W2 => s_u3, 
        W3 => s_u6     
    );
    U9: Facelet port map(
        S => S, Clk => Clk, Pre => up,
        Q => s_u9,
        W0 => s_u9,
        W1 => s_f9,
        W2 => s_u0,
        W3 => s_u9     
    );
    
    F0: Facelet port map(
        S => S, Clk => Clk, Pre => front,
        Q => s_f0,
        W0 => s_d0,
        W1 => s_f0,
        W2 => s_l0, 
        W3 => s_f0     
    );
    F3: Facelet port map(
        S => S, Clk => Clk, Pre => front,
        Q => s_f3,
        W0 => s_f3,
        W1 => s_d3,
        W2 => s_l3,
        W3 => s_f3         
    );
    F6: Facelet port map(
        S => S, Clk => Clk, Pre => front,
        Q => s_f6,
        W0 => s_d6,
        W1 => s_f6,
        W2 => s_f6,
        W3 => s_l6
    );
    F9: Facelet port map(
        S => S, Clk => Clk, Pre => front,
        Q => s_f9,
        W0 => s_f9,
        W1 => s_d9,
        W2 => s_f9,
        W3 => s_l9
    );
    
    D0: Facelet port map(
        S => S, Clk => Clk, Pre => down,
        Q => s_d0,
        W0 => s_b9,
        W1 => s_d0,
        W2 => s_d0,
        W3 => s_d9
    );
    D3: Facelet port map(
        S => S, Clk => Clk, Pre => down,
        Q => s_d3,
        W0 => s_d3,
        W1 => s_b6,
        W2 => s_d3,
        W3 => s_d6
    );
    D6: Facelet port map(
        S => S, Clk => Clk, Pre => down,
        Q => s_d6,
        W0 => s_b3,
        W1 => s_d6,
        W2 => s_d6,
        W3 => s_d3
    );
    D9: Facelet port map(
        S => S, Clk => Clk, Pre => down,
        Q => s_d9,
        W0 => s_d9,
        W1 => s_b0,
        W2 => s_d9,
        W3 => s_d0
    );
    
    L0: Facelet port map(
        S => S, Clk => Clk, Pre => left,
        Q => s_l0,
        W0 => s_l9,
        W1 => s_l0,
        W2 => s_b0,
        W3 => s_l0
    );
    L3: Facelet port map(
        S => S, Clk => Clk, Pre => left,
        Q => s_l3,
        W0 => s_l6,
        W1 => s_l3,
        W2 => s_b3,
        W3 => s_l3
    );
    L6: Facelet port map(
        S => S, Clk => Clk, Pre => left,
        Q => s_l6,
        W0 => s_l3,
        W1 => s_l6,
        W2 => s_l6,
        W3 => s_b6
    );
    L9: Facelet port map(
        S => S, Clk => Clk, Pre => left,
        Q => s_l9,
        W0 => s_l0,
        W1 => s_l9,
        W2 => s_l9,
        W3 => s_b9
    );
    
    R0: Facelet port map(
        S => S, Clk => Clk, Pre => right,
        Q => s_r0,
        W0 => s_r0,
        W1 => s_r9,
        W2 => s_f0,
        W3 => s_r0
    );
    R3: Facelet port map(
        S => S, Clk => Clk, Pre => right,
        Q => s_r3,
        W0 => s_r3,
        W1 => s_r6,
        W2 => s_f3,
        W3 => s_r3
    );
    R6: Facelet port map(
        S => S, Clk => Clk, Pre => right,
        Q => s_r6,
        W0 => s_r6,
        W1 => s_r3,
        W2 => s_r6,
        W3 => s_f6
    );
    R9: Facelet port map(
        S => S, Clk => Clk, Pre => right,
        Q => s_r9,
        W0 => s_r9,
        W1 => s_r0,
        W2 => s_r9,
        W3 => s_f9
    );
    
    B0: Facelet port map(
        S => S, Clk => Clk, Pre => back,
        Q => s_b0,
        W0 => s_b0,
        W1 => s_u9,
        W2 => s_r0,
        W3 => s_b0
    );
    B3: Facelet port map(
        S => S, Clk => Clk, Pre => back,
        Q => s_b3,
        W0 => s_u6,
        W1 => s_b3,
        W2 => s_r3,
        W3 => s_b3
    );
    B6: Facelet port map(
        S => S, Clk => Clk, Pre => back,
        Q => s_b6,
        W0 => s_b6,
        W1 => s_u3,
        W2 => s_b6,
        W3 => s_r6
    );
    B9: Facelet port map(
        S => S, Clk => Clk, Pre => back,
        Q => s_b9,
        W0 => s_u0,
        W1 => s_b9,
        W2 => s_b9,
        W3 => s_r9
    );
    
    Q_all <= s_u0 & s_u3 & s_u6 & s_u9 &   -- Up face
         s_f0 & s_f3 & s_f6 & s_f9 &   -- Front face
         s_l0 & s_l3 & s_l6 & s_l9 &   -- Left face
         s_r0 & s_r3 & s_r6 & s_r9 &   -- Right face
         s_b0 & s_b3 & s_b6 & s_b9 &   -- Back face
         s_d0 & s_d3 & s_d6 & s_d9;    -- Down face
         
     ---for testing 
    out_U0 <= s_u0; out_U3 <= s_u3; out_U6 <= s_u6; out_U9 <= s_u9;
    out_F0 <= s_f0; out_F3 <= s_f3; out_F6 <= s_f6; out_F9 <= s_f9;
    out_L0 <= s_l0; out_L3 <= s_l3; out_L6 <= s_l6; out_L9 <= s_l9;
    out_R0 <= s_r0; out_R3 <= s_r3; out_R6 <= s_r6; out_R9 <= s_r9; 
    out_B0 <= s_b0; out_B3 <= s_b3; out_B6 <= s_b6; out_B9 <= s_b9;
    out_D0 <= s_d0; out_D3 <= s_d3; out_D6 <= s_d6; out_D9 <= s_d9;
end structural;
