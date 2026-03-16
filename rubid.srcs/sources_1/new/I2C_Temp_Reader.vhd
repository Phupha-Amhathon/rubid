library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity I2C_Temp_Reader is
    Port (
        Clk        : in    std_logic;
        RESET      : in    std_logic;
        SCL        : out   std_logic;
        SDA        : inout std_logic;
        Temp_Noise : out   std_logic_vector(15 downto 0) -- Changed to 15 downto 0
    );
end I2C_Temp_Reader;

architecture Behavioral of I2C_Temp_Reader is
    signal noise_reg : unsigned(15 downto 0) := x"A5A5"; -- 16-bit counter
    signal clk_div   : unsigned(15 downto 0) := (others => '0');
begin
    process(Clk)
    begin
        if rising_edge(Clk) then
            noise_reg <= noise_reg + 1; -- Spinning at 100MHz
            noise_reg(0) <= noise_reg(0) xor SDA; -- Mixing in Thermal Jitter
            clk_div <= clk_div + 1;
        end if;
    end process;

    SCL <= clk_div(9); 
    SDA <= 'Z'; 
    Temp_Noise <= std_logic_vector(noise_reg);
end Behavioral;