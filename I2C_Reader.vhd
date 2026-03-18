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
                Temp_Data <= x"0640"; -- Legacy startup default kept until first valid sensor read
            elsif i2c_tick = '1' then
                
                case state is
                    when IDLE =>
                        sda_out <= '1'; scl_out <= '1';
                        state <= START1;

                    -- START CONDITION: SDA goes low while SCL is high
                    when START1 =>
                        sda_out <= '0';
                        bit_cnt <= 7;
                        scl_out <= '0';
                        state <= ADDR_W;

                    -- Send Device Address + Write Bit (0x4B)
                    when ADDR_W =>
                        if scl_out = '0' then
                            sda_out <= DEV_ADDR_W(bit_cnt);
                            scl_out <= '1';
                        else
                            scl_out <= '0';
                            if bit_cnt = 0 then state <= ACK1; else bit_cnt <= bit_cnt - 1; end if;
                        end if;

                    -- Wait for ACK from Sensor
                    when ACK1 =>
                        if scl_out = '0' then
                            sda_out <= '1'; -- Release SDA line
                            scl_out <= '1';
                        else
                            scl_out <= '0';
                            bit_cnt <= 7;
                            state <= REG_ADDR;
                        end if;

                    -- Send Register Address (0x00 for Temp)
                    when REG_ADDR =>
                        if scl_out = '0' then
                            sda_out <= TEMP_REG(bit_cnt);
                            scl_out <= '1';
                        else
                            scl_out <= '0';
                            if bit_cnt = 0 then state <= ACK2; else bit_cnt <= bit_cnt - 1; end if;
                        end if;

                    when ACK2 =>
                        if scl_out = '0' then
                            sda_out <= '1'; -- Release SDA
                            scl_out <= '1';
                        else
                            scl_out <= '0';
                            state <= START2;
                        end if;

                    -- REPEATED START for Read Operation
                    when START2 =>
                        sda_out <= '0';
                        bit_cnt <= 7;
                        scl_out <= '0';
                        state <= ADDR_R;

                    -- Send Device Address + Read Bit (0x4B + 1)
                    when ADDR_R =>
                        if scl_out = '0' then
                            sda_out <= DEV_ADDR_R(bit_cnt);
                            scl_out <= '1';
                        else
                            scl_out <= '0';
                            if bit_cnt = 0 then state <= ACK3; else bit_cnt <= bit_cnt - 1; end if;
                        end if;

                    -- Wait for ACK from Sensor
                    when ACK3 =>
                        if scl_out = '0' then
                            sda_out <= '1'; -- Release SDA
                            scl_out <= '1';
                        else
                            scl_out <= '0';
                            bit_cnt <= 7;
                            state <= RD_MSB;
                        end if;

                    -- Read MSB (First 8 bits of Temp)
                    when RD_MSB =>
                        if scl_out = '0' then
                            sda_out <= '1'; -- Let slave drive SDA
                            scl_out <= '1';
                        else
                            -- Sample on the SCL 1->0 transition, after data was stable during SCL='1'.
                            saved_temp(bit_cnt + 8) <= SDA;
                            scl_out <= '0';
                            if bit_cnt = 0 then state <= ACK4; else bit_cnt <= bit_cnt - 1; end if;
                        end if;

                    -- Master Acknowledges MSB
                    when ACK4 =>
                        if scl_out = '0' then
                            sda_out <= '0'; -- Master sends ACK
                            scl_out <= '1';
                        else
                            scl_out <= '0';
                            bit_cnt <= 7;
                            state <= RD_LSB;
                        end if;

                    -- Read LSB (Second 8 bits of Temp)
                    when RD_LSB =>
                        if scl_out = '0' then
                            sda_out <= '1'; -- Let slave drive SDA
                            scl_out <= '1';
                        else
                            saved_temp(bit_cnt) <= SDA;
                            scl_out <= '0';
                            if bit_cnt = 0 then state <= NACK; else bit_cnt <= bit_cnt - 1; end if;
                        end if;

                    -- Master NACKs (Tells sensor to stop sending)
                    when NACK =>
                        if scl_out = '0' then
                            sda_out <= '1';
                            scl_out <= '1';
                        else
                            scl_out <= '0';
                            state <= STOP;
                        end if;

                    -- STOP Condition
                    when STOP =>
                        sda_out <= '1'; scl_out <= '1';
                        -- 0xFF7F / 0xFFFF are common pull-up-only patterns when sensor read fails.
                        if saved_temp /= x"FF7F" and saved_temp /= x"FFFF" then
                            Temp_Data <= saved_temp; -- Output the final 16-bit value
                        end if;
                        state <= IDLE; 

                    when others => state <= IDLE;
                end case;
            end if;
        end if;
    end process;

end Behavioral;
