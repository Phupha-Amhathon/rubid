library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-- Moors machine
entity move_controller is
    Port ( 
           Clk          : in STD_LOGIC;
           BTN_Execute  : in STD_LOGIC;                      
           SW_Direction : in STD_LOGIC;                   
           RESET, F, R, U, L, B, D : in std_logic;
           S_Out        : out STD_LOGIC_VECTOR (2 downto 0); -- sent to rubid 
           Face_For_Seq : out STD_LOGIC_VECTOR (2 downto 0)  -- Sent to the Sequence Detector
           );
end move_controller;

architecture Behavioral of move_controller is

    component moveEncoder is
      Port (
        RESET, F, R, U, L, B, D : in std_logic;
        Y : out std_logic_vector(2 downto 0) --  000 means hold , 111 means reset 
      );
    end component;

    component DFlipFlop is
    Port ( 
        D   : in  std_logic;
        Clk : in  std_logic;
        Q   : out std_logic;
        nQ  : out std_logic;
        Pre, Clr: in std_logic --active high pai lei
    );
    end component;
    
    -- state
    -- 000 = idle
    -- 001 = ex1
    -- 010 = ex2
    -- 011 = ex3
    -- 100 = waiting for 0 execution 
    -- for cur state
    signal q2, q1, q0 : std_logic;
    signal nq2, nq1, nq0 : std_logic;
    -- for next state 
    signal d2, d1, d0 : std_logic;
    -- for output 
    -- Internal Logic Wires
    signal SW_Face : std_logic_vector(2 downto 0);
    signal n_SW_Direction : std_logic;
    signal n_BTN_Execute : std_logic;
    signal out_enable : std_logic;

begin

    EN: moveEncoder port map(
      RESET => RESET, F => F, R => R, U => U, L => L, B => B, D => D, Y => SW_Face
    );

    U_Q2: DFlipFlop port map(
        D   => d2,
        Clk => Clk,
        Q   =>  q2, 
        nQ  => open, 
        Pre => '0',
        Clr => RESET
    );
    
    U_Q1: DFlipFlop port map(
        D   => d1,
        Clk => Clk,
        Q   =>  q1, 
        nQ  => open, 
        Pre => '0',
        Clr => RESET
    );

    U_Q0: DFlipFlop port map(
        D   => d0,
        Clk => Clk,
        Q   =>  q0, 
        nQ  => open, 
        Pre => '0',
        Clr => RESET
    );

    nq2 <= not q2;
    nq1 <= not q1;
    nq0 <= not q0;
    n_SW_Direction <= not SW_Direction;
    n_BTN_Execute <= not BTN_Execute;
    d2 <= (nq2 and nq1 and q0 and n_SW_Direction) or (nq2 and q1 and q0) or (q2 and nq1 and nq0 and BTN_Execute);
    d1 <= (nq2 and nq1 and q0 and SW_Direction) or (nq2 and q1 and nq0);
    d0 <= (nq2 and nq1 and nq0 and BTN_Execute) or (nq2 and q1 and nq0);

    Face_For_Seq <= SW_Face; -- output to sequence detector regardless of state
    --001 010 011 
    out_enable <= (nq2 and nq1 and q0) or (nq2 and q1 and nq0) or (nq2 and q1 and q0);

    -- asynchronous rest 
    S_Out(2) <= SW_Face(2) and (out_enable or RESET);
    S_Out(1) <= SW_Face(1) and (out_enable or RESET);
    S_Out(0) <= SW_Face(0) and (out_enable or RESET);

end Behavioral;