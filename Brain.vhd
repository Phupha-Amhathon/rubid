library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Tangled_Chaos_Engine is
    Port (
        Clk, RESET : in std_logic;
        Live_Temp : in std_logic_vector(15 downto 0);
        F, R, U, L, B, D, Done : out std_logic
    );
end Tangled_Chaos_Engine;

architecture logic_matrix of Tangled_Chaos_Engine is
    signal chaos_reg : std_logic_vector(15 downto 0) := x"ACE1";
    signal next_val, p0, p1, p2, p3 : std_logic_vector(15 downto 0); 
    -- THE BRAIN: Selector wire
    signal mode : std_logic_vector(1 downto 0);
    signal count : integer range 0 to 20 := 20;
    signal sDone : std_logic := '1';
begin

    -- -----------------------------------------------------------------------
    -- THE SELF-DRIVING SELECTOR: This forces the machine to change every tick
    -- -----------------------------------------------------------------------
    mode <= chaos_reg(1 downto 0) xor Live_Temp(1 downto 0);

    -- MACHINE 0: Triple Jumper!
     p0 <= chaos_reg(12 downto 0) & chaos_reg(15 downto 13); 

    -- MACHINE 1: Chaos Cross Wire
p1 <= chaos_reg(0) & chaos_reg(8) & chaos_reg(1) & chaos_reg(9) & 
          chaos_reg(2) & chaos_reg(10) & chaos_reg(3) & chaos_reg(11) &
          chaos_reg(4) & chaos_reg(12) & chaos_reg(5) & chaos_reg(13) &
          chaos_reg(6) & chaos_reg(14) & chaos_reg(7) & chaos_reg(15);
    
    -- MACHINE 2: Thermal XOR Mixer (Gates)
    p2 <= chaos_reg xor Live_Temp; 

    -- Reverses the entire 16-bit string and flips the bits.
    p3 <= not (chaos_reg(0) & chaos_reg(1) & chaos_reg(2) & chaos_reg(3) & 
               chaos_reg(4) & chaos_reg(5) & chaos_reg(6) & chaos_reg(7) &
               chaos_reg(8) & chaos_reg(9) & chaos_reg(10) & chaos_reg(11) &
               chaos_reg(12) & chaos_reg(13) & chaos_reg(14) & chaos_reg(15)); 
    
    -- THE 4-to-1 TRAFFIC MUX
    next_val <= p0 when mode = "00" else
                p1 when mode = "01" else
                p2 when mode = "10" else 
                p3;

    process(Clk) begin
        -- CHANGE TO RISING_EDGE
        if rising_edge(Clk) then
            if RESET = '1' then 
                chaos_reg <= next_val; 
                count <= 0; 
                sDone <= '0';
            elsif sDone = '0' then
                chaos_reg <= next_val;
                if count = 19 then 
                    sDone <= '1'; 
                else 
                    count <= count + 1; 
                end if;
            end if;
        end if;
    end process;

    -- Deciding the Move based on the final 3 bits of the current chaotic state
    F <= '1' when (chaos_reg(2 downto 1) = "00" and sDone = '0') else '0';
    
    R <= '1' when (chaos_reg(2 downto 0) = "010" and sDone = '0') else '0';
    U <= '1' when (chaos_reg(2 downto 0) = "011" and sDone = '0') else '0';
    L <= '1' when (chaos_reg(2 downto 0) = "100" and sDone = '0') else '0';
    B <= '1' when (chaos_reg(2 downto 0) = "101" and sDone = '0') else '0';

    -- D is triggered by "110" and "111"
    D <= '1' when (chaos_reg(2 downto 1) = "11" and sDone = '0') else '0';
    Done <= sDone;
end logic_matrix;