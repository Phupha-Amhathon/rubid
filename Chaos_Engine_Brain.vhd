library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Chaos_Engine is
    Port (
        Clk, RESET : in std_logic;
        Temp       : in std_logic_vector(15 downto 0);
        F, R, U, L, B, D, Done : out std_logic
    );
end Chaos_Engine;

architecture logic_matrix of Chaos_Engine is
    signal reg   : std_logic_vector(15 downto 0) := x"B2A9";
    signal count : integer range 0 to 20 := 20;
    signal sDone : std_logic := '1';
    
    signal mode   : std_logic_vector(1 downto 0);
    signal p0, p1, p2, p3 : std_logic_vector(15 downto 0);
    signal next_v : std_logic_vector(15 downto 0);
    
    -- Entropy Source
    signal entropy_reg : std_logic_vector(15 downto 0) := x"FACE";
    signal entropy_fb  : std_logic;
begin

    -- Instantiate the 4 Chaos Machines
    INST_M0: entity work.Chaos_Machine_0 port map(Reg_In => reg, Reg_Out => p0);
    INST_M1: entity work.Chaos_Machine_1 port map(Reg_In => reg, Reg_Out => p1);
    INST_M2: entity work.Chaos_Machine_2 port map(Reg_In => reg, Temp => Temp, Reg_Out => p2);
    
    -- UPDATED: Now calling the renamed InvertBit machine
    INST_M3: entity work.Chaos_Machine_3_InvertBit port map(Reg_In => reg, Reg_Out => p3);

    -- MODE SELECTOR: XORing register bits and Temp bits
    mode(0) <= (reg(0) xor reg(4) xor reg(8) xor reg(12)) xor Temp(0) xor entropy_reg(0);
    mode(1) <= (reg(2) xor reg(6) xor reg(10) xor reg(14)) xor Temp(1) xor entropy_reg(7);

    -- Machine MUXes
    next_v <= p0 when mode = "00" else 
              p1 when mode = "01" else 
              p2 when mode = "10" else 
              p3;

    process(Clk) begin
        if rising_edge(Clk) then
            -- Entropy Generator (Runs every tick)
            entropy_fb <= entropy_reg(15) xor entropy_reg(14) xor entropy_reg(12) xor entropy_reg(3);
            entropy_reg <= entropy_reg(14 downto 0) & entropy_fb;
            
            if RESET = '1' then 
                reg <= next_v; 
                count <= 0; 
                sDone <= '0';
            elsif sDone = '0' then
                reg <= next_v;
                if count = 19 then 
                    sDone <= '1'; 
                else 
                    count <= count + 1; 
                end if;
            end if;
        end if;
    end process;

    -- MOVE DECODER (Ensures all 8 states result in a move)
    F <= '1' when (reg(2 downto 1) = "00" and sDone = '0') else '0';
    R <= '1' when (reg(2 downto 0) = "010" and sDone = '0') else '0';
    U <= '1' when (reg(2 downto 0) = "011" and sDone = '0') else '0';
    L <= '1' when (reg(2 downto 0) = "100" and sDone = '0') else '0';
    B <= '1' when (reg(2 downto 0) = "101" and sDone = '0') else '0';
    D <= '1' when (reg(2 downto 1) = "11"  and sDone = '0') else '0';
    
    Done <= sDone;
end logic_matrix;