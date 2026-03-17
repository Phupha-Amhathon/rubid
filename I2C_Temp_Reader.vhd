library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity I2C_Temp_Reader is
    Port ( 
        Clk, RESET : in std_logic; 
        SCL        : out std_logic; 
        SDA        : inout std_logic; 
        Temp_Data  : out std_logic_vector(15 downto 0) 
    );
end I2C_Temp_Reader;

architecture Behavioral of I2C_Temp_Reader is
    signal clk_div : integer range 0 to 500 := 0;
    signal i2c_tick : std_logic := '0';
    type state_type is (IDLE, START1, ADDR_W, ACK1, REG, ACK2, START2, ADDR_R, ACK3, RD_MSB, ACK4, RD_LSB, NACK, STOP);
    signal state : state_type := IDLE;
    signal bit_cnt : integer range 0 to 7 := 7;
    signal saved : std_logic_vector(15 downto 0) := x"0640"; 
    signal sda_o, scl_o : std_logic := '1';

    -- These constants fix the "10010110 is not declared" error
    constant ADDR_W_BYTE : std_logic_vector(7 downto 0) := "10010110";
    constant ADDR_R_BYTE : std_logic_vector(7 downto 0) := "10010111";

begin
    process(Clk) begin
        if rising_edge(Clk) then
            if clk_div = 500 then clk_div <= 0; i2c_tick <= '1'; else clk_div <= clk_div + 1; i2c_tick <= '0'; end if;
        end if;
    end process;

    SDA <= '0' when sda_o = '0' else 'Z'; 
    SCL <= scl_o;

    process(Clk) begin
        if rising_edge(Clk) then
            if RESET = '1' then state <= IDLE; sda_o <= '1'; scl_o <= '1';
            elsif i2c_tick = '1' then
                case state is
                    when IDLE => sda_o <= '1'; scl_o <= '1'; state <= START1;
                    when START1 => sda_o <= '0'; state <= ADDR_W; bit_cnt <= 7;
                    when ADDR_W => 
                        scl_o <= not scl_o; 
                        if scl_o = '0' then 
                            sda_o <= ADDR_W_BYTE(bit_cnt);
                            if bit_cnt = 0 then state <= ACK1; else bit_cnt <= bit_cnt - 1; end if; 
                        end if;
                    when ACK1 => scl_o <= not scl_o; sda_o <= '1'; state <= REG; bit_cnt <= 7;
                    when REG => 
                        scl_o <= not scl_o; if scl_o = '0' then sda_o <= '0';
                        if bit_cnt = 0 then state <= ACK2; else bit_cnt <= bit_cnt - 1; end if; end if;
                    when ACK2 => scl_o <= not scl_o; sda_o <= '1'; state <= START2;
                    when START2 => sda_o <= '0'; state <= ADDR_R; bit_cnt <= 7;
                    when ADDR_R => 
                        scl_o <= not scl_o; if scl_o = '0' then sda_o <= ADDR_R_BYTE(bit_cnt);
                        if bit_cnt = 0 then state <= ACK3; else bit_cnt <= bit_cnt - 1; end if; end if;
                    when ACK3 => scl_o <= not scl_o; sda_o <= '1'; state <= RD_MSB; bit_cnt <= 7;
                    when RD_MSB => 
                        scl_o <= not scl_o; if scl_o = '1' then saved(bit_cnt+8) <= SDA;
                        if bit_cnt = 0 then state <= ACK4; else bit_cnt <= bit_cnt - 1; end if; end if;
                    when ACK4 => scl_o <= not scl_o; sda_o <= '0'; state <= RD_LSB; bit_cnt <= 7;
                    when RD_LSB => 
                        scl_o <= not scl_o; if scl_o = '1' then saved(bit_cnt) <= SDA;
                        if bit_cnt = 0 then state <= NACK; else bit_cnt <= bit_cnt - 1; end if; end if;
                    when NACK => scl_o <= not scl_o; sda_o <= '1'; state <= STOP;
                    when STOP => scl_o <= '1'; sda_o <= '0'; state <= IDLE; Temp_Data <= saved;
                    when others => state <= IDLE;
                end case;
            end if;
        end if;
    end process;
end Behavioral;