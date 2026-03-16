library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity RubidMark2 is
    Port ( 
        S         : in STD_LOGIC_VECTOR (2 downto 0);
        Clk       : in STD_LOGIC;
        Q_all     : out STD_LOGIC_VECTOR (71 downto 0);
        
        -- The brand new flag for the Game Controller
        is_solved : out STD_LOGIC
    );
end RubidMark2;

architecture Behavioral of RubidMark2 is

    -- 1. Declare your original working Rubid module as a component
    component Rubid is
        Port ( 
            S     : in STD_LOGIC_VECTOR (2 downto 0);
            Clk   : in STD_LOGIC;
            Q_all : out STD_LOGIC_VECTOR (71 downto 0)
        );
    end component;

    -- 2. Internal signal to catch the 72-bit output from the core cube
    signal q_internal : STD_LOGIC_VECTOR(71 downto 0);

    -- 3. Define the winning colors for each face (matching your Rubid init values)
    constant c_up    : std_logic_vector(2 downto 0) := "000";
    constant c_front : std_logic_vector(2 downto 0) := "001";
    constant c_left  : std_logic_vector(2 downto 0) := "010";
    constant c_right : std_logic_vector(2 downto 0) := "011";
    constant c_down  : std_logic_vector(2 downto 0) := "100";
    constant c_back  : std_logic_vector(2 downto 0) := "101";

begin

    -- ==========================================
    -- INSTANTIATE THE ORIGINAL CUBE
    -- ==========================================
    Core_Cube: Rubid port map(
        S     => S,
        Clk   => Clk,
        Q_all => q_internal  -- Catch the output in our internal wire
    );

    -- Pass the internal wire straight through to the outside world
    Q_all <= q_internal;

    -- ==========================================
    -- WIN CONDITION LOGIC (Combinatorial Slicing)
    -- ==========================================
    -- We concatenate the constant color 4 times to create a 12-bit expected block,
    -- and compare it directly to the 12-bit slice of the cube's output.
    is_solved <= '1' when (
        (q_internal(71 downto 60) = c_up & c_up & c_up & c_up)       and
        (q_internal(59 downto 48) = c_front & c_front & c_front & c_front) and
        (q_internal(47 downto 36) = c_left & c_left & c_left & c_left)     and
        (q_internal(35 downto 24) = c_right & c_right & c_right & c_right)   and
        (q_internal(23 downto 12) = c_back & c_back & c_back & c_back)     and
        (q_internal(11 downto  0) = c_down & c_down & c_down & c_down)
    ) else '0';

end Behavioral;