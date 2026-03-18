library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity I2C_Reader is
    Port (
        Clk        : in    std_logic; -- 100 MHz System Clock
        RESET      : in    std_logic; -- Button Press to reset logic
        SCL        : out   std_logic;
        SDA        : inout std_logic;
        Temp_Data  : out   std_logic_vector(15 downto 0) -- The 16-bit temperature value
    );
end I2C_Reader;

architecture Behavioral of I2C_Reader is

    -- Clock Divider to create the I2C clock (approx 400kHz)
    signal clk_div : integer range 0 to 400 := 0;
    signal i2c_tick : std_logic := '0';

    -- I2C State Machine Definition
    type state_type is (
        IDLE, START1, ADDR_W, ACK1, REG_ADDR, ACK2, 
        START2, ADDR_R, ACK3, RD_MSB, ACK4, RD_LSB, NACK, STOP
    );
    signal state : state_type := IDLE;

    signal bit_cnt : integer range 0 to 7 := 7;
    signal saved_temp : std_logic_vector(15 downto 0) := x"0640"; -- Default to 25.0 C
    
    -- SDA driving logic (Open Drain behavior)
    signal sda_out : std_logic := '1';
    signal scl_out : std_logic := '1';

    -- I2C Constants (Address 0x4B)
    constant DEV_ADDR_W : std_logic_vector(7 downto 0) := "10010110"; -- 0x4B + Write Bit
    constant DEV_ADDR_R : std_logic_vector(7 downto 0) := "10010111"; -- 0x4B Read Bit
    constant TEMP_REG   : std_logic_vector(7 downto 0) := "00000000"; -- Register 0x00

begin
    
    -- 1. 100MHz Clock Divider for I2C Timing
    process(Clk)
    begin
        if rising_edge(Clk) then
            if clk_div = 400 then
                clk_div <= 0;
                i2c_tick <= '1';
            else
                clk_div <= clk_div + 1;
                i2c_tick <= '0';
            end if;
        end if;
    end process;

    -- Drive the physical pins according to I2C standard (SDA must be tri-state)
    SCL <= scl_out;
    SDA <= '0' when sda_out = '0' else 'Z'; 

    -- 2. I2C Master State Machine (Executes on every I2C tick)
    process(Clk)
    begin
        if rising_edge(Clk) then
            if RESET = '1' then 
                state <= IDLE;
                sda_out <= '1';
                scl_out <= '1';
                bit_cnt <= 7;
            elsif i2c_tick = '1' then
                
                case state is
                    when IDLE =>
                        sda_out <= '1'; scl_out <= '1';
                        state <= START1;

                    -- START CONDITION: SDA goes low while SCL is high
                    when START1 =>
                        sda_out <= '0'; scl_out <= '1';
                        bit_cnt <= 7;
                        state <= ADDR_W;

                    -- Send Device Address + Write Bit (0x4B)
                    when ADDR_W =>
                        scl_out <= '0';
                        sda_out <= DEV_ADDR_W(bit_cnt);
                        if bit_cnt = 0 then state <= ACK1; else bit_cnt <= bit_cnt - 1; end if;

                    -- Wait for ACK from Sensor
                    when ACK1 =>
                        scl_out <= '1';
                        sda_out <= '1'; -- Release SDA line
                        bit_cnt <= 7;
                        state <= REG_ADDR;

                    -- Send Register Address (0x00 for Temp)
                    when REG_ADDR =>
                        scl_out <= '0';
                        sda_out <= TEMP_REG(bit_cnt);
                        if bit_cnt = 0 then state <= ACK2; else bit_cnt <= bit_cnt - 1; end if;

                    when ACK2 =>
                        scl_out <= '1';
                        sda_out <= '1'; -- Release SDA
                        state <= START2;

                    -- REPEATED START for Read Operation
                    when START2 =>
                        sda_out <= '0'; scl_out <= '1';
                        bit_cnt <= 7;
                        state <= ADDR_R;

                    -- Send Device Address + Read Bit (0x4B + 1)
                    when ADDR_R =>
                        scl_out <= '0';
                        sda_out <= DEV_ADDR_R(bit_cnt);
                        if bit_cnt = 0 then state <= ACK3; else bit_cnt <= bit_cnt - 1; end if;

                    -- Wait for ACK from Sensor
                    when ACK3 =>
                        scl_out <= '1';
                        sda_out <= '1'; -- Release SDA
                        bit_cnt <= 7;
                        state <= RD_MSB;

                    -- Read MSB (First 8 bits of Temp)
                    when RD_MSB =>
                        scl_out <= '0';
                        sda_out <= '1'; -- Let slave drive SDA
                        saved_temp(bit_cnt + 8) <= SDA; -- Sample data on falling edge of SCL
                        if bit_cnt = 0 then state <= ACK4; else bit_cnt <= bit_cnt - 1; end if;

                    -- Master Acknowledges MSB
                    when ACK4 =>
                        scl_out <= '1';
                        sda_out <= '0'; -- Master sends ACK
                        bit_cnt <= 7;
                        state <= RD_LSB;

                    -- Read LSB (Second 8 bits of Temp)
                    when RD_LSB =>
                        scl_out <= '0';
                        sda_out <= '1'; -- Let slave drive SDA
                        saved_temp(bit_cnt) <= SDA; -- Sample data
                        if bit_cnt = 0 then state <= NACK; else bit_cnt <= bit_cnt - 1; end if;

                    -- Master NACKs (Tells sensor to stop sending)
                    when NACK =>
                        scl_out <= '1';
                        sda_out <= '1'; 
                        state <= STOP;

                    -- STOP Condition
                    when STOP =>
                        sda_out <= '1'; scl_out <= '1';
                        Temp_Data <= saved_temp; -- Output the final 16-bit value
                        state <= IDLE; 

                    when others => state <= IDLE;
                end case;
            end if;
        end if;
    end process;

end Behavioral;