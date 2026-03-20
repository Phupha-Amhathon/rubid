library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity adt7420_i2c_reader is
    Port (
        clk        : in  STD_LOGIC;                    -- 100 MHz System Clock
        reset_n    : in  STD_LOGIC;                    -- Active-low reset
        SDA        : inout STD_LOGIC;                  -- I2C Serial Data
        SCL        : out STD_LOGIC;                    -- I2C Serial Clock
        temp_data  : out STD_LOGIC_VECTOR(15 downto 0);-- 16-bit Temp Output
        busy       : out STD_LOGIC;                    -- Busy status
        error_flag : out STD_LOGIC                     -- Error status
    );
end adt7420_i2c_reader;

architecture Behavioral of adt7420_i2c_reader is
    -- ตัวหารคล็อกเพื่อสร้างความถี่ 400kHz
    constant CLK_DIV : integer := 250; 
    signal tick_cnt : integer range 0 to CLK_DIV := 0;
    signal tick : std_logic := '0';

    type state_type is (
        IDLE, START,
        SEND_ADDR_W, ACK1,
        SEND_REG, ACK2,
        RESTART,
        SEND_ADDR_R, ACK3,
        READ_MSB, ACK_MASTER,
        READ_LSB, NACK_MASTER,
        STOP, DELAY_WAIT
    );
    signal state : state_type := IDLE;
    
    signal bit_cnt : integer range 0 to 7 := 7;
    signal phase   : integer range 0 to 3 := 0;
    signal delay_cnt : integer := 0;

    signal shift_tx : std_logic_vector(7 downto 0);
    signal shift_rx : std_logic_vector(15 downto 0);

    signal sda_out : std_logic := '1';
    signal scl_out : std_logic := '1';

    -- คำสั่งสำหรับเซนเซอร์ ADT7420
    constant ADDR_W   : std_logic_vector(7 downto 0) := "10010110"; -- 0x4B + Write(0)
    constant ADDR_R   : std_logic_vector(7 downto 0) := "10010111"; -- 0x4B + Read(1)
    constant REG_TEMP : std_logic_vector(7 downto 0) := x"00";      -- Temp Register

begin
    -- I2C Open-Drain Configuration 
    SCL <= 'Z' when scl_out = '1' else '0';
    SDA <= 'Z' when sda_out = '1' else '0';
    
    error_flag <= '0';

    -- สร้างสัญญาณ Tick ความถี่ 400kHz
    process(clk)
    begin
        if rising_edge(clk) then
            if tick_cnt = CLK_DIV - 1 then
                tick_cnt <= 0;
                tick <= '1';
            else
                tick_cnt <= tick_cnt + 1;
                tick <= '0';
            end if;
        end if;
    end process;

    -- I2C Main State Machine แบบ 4-Phase สมบูรณ์แบบ
    process(clk)
    begin
        if rising_edge(clk) then
            if reset_n = '0' then
                state <= IDLE;
                sda_out <= '1';
                scl_out <= '1';
                busy <= '0';
                phase <= 0;
            elsif tick = '1' then
                case state is
                    when IDLE =>
                        sda_out <= '1'; scl_out <= '1'; phase <= 0;
                        state <= START; 
                        busy <= '1';

                    when START =>
                        if phase = 0 then sda_out <= '0'; scl_out <= '1'; phase <= 1;
                        elsif phase = 1 then sda_out <= '0'; scl_out <= '0'; phase <= 0;
                            shift_tx <= ADDR_W; bit_cnt <= 7; state <= SEND_ADDR_W;
                        end if;

                    when SEND_ADDR_W =>
                        if phase = 0 then sda_out <= shift_tx(bit_cnt); scl_out <= '0'; phase <= 1;
                        elsif phase = 1 then scl_out <= '1'; phase <= 2;
                        elsif phase = 2 then scl_out <= '1'; phase <= 3;
                        elsif phase = 3 then scl_out <= '0'; phase <= 0;
                            if bit_cnt = 0 then state <= ACK1; else bit_cnt <= bit_cnt - 1; end if;
                        end if;

                    when ACK1 =>
                        if phase = 0 then sda_out <= '1'; scl_out <= '0'; phase <= 1;
                        elsif phase = 1 then scl_out <= '1'; phase <= 2;
                        elsif phase = 2 then scl_out <= '1'; phase <= 3;
                        elsif phase = 3 then scl_out <= '0'; phase <= 0;
                            shift_tx <= REG_TEMP; bit_cnt <= 7; state <= SEND_REG;
                        end if;

                    when SEND_REG =>
                        if phase = 0 then sda_out <= shift_tx(bit_cnt); scl_out <= '0'; phase <= 1;
                        elsif phase = 1 then scl_out <= '1'; phase <= 2;
                        elsif phase = 2 then scl_out <= '1'; phase <= 3;
                        elsif phase = 3 then scl_out <= '0'; phase <= 0;
                            if bit_cnt = 0 then state <= ACK2; else bit_cnt <= bit_cnt - 1; end if;
                        end if;

                    when ACK2 =>
                        if phase = 0 then sda_out <= '1'; scl_out <= '0'; phase <= 1;
                        elsif phase = 1 then scl_out <= '1'; phase <= 2;
                        elsif phase = 2 then scl_out <= '1'; phase <= 3;
                        elsif phase = 3 then scl_out <= '0'; phase <= 0;
                            state <= RESTART;
                        end if;

                    when RESTART =>
                        if phase = 0 then sda_out <= '1'; scl_out <= '0'; phase <= 1;
                        elsif phase = 1 then sda_out <= '1'; scl_out <= '1'; phase <= 2;
                        elsif phase = 2 then sda_out <= '0'; scl_out <= '1'; phase <= 3;
                        elsif phase = 3 then sda_out <= '0'; scl_out <= '0'; phase <= 0;
                            shift_tx <= ADDR_R; bit_cnt <= 7; state <= SEND_ADDR_R;
                        end if;

                    when SEND_ADDR_R =>
                        if phase = 0 then sda_out <= shift_tx(bit_cnt); scl_out <= '0'; phase <= 1;
                        elsif phase = 1 then scl_out <= '1'; phase <= 2;
                        elsif phase = 2 then scl_out <= '1'; phase <= 3;
                        elsif phase = 3 then scl_out <= '0'; phase <= 0;
                            if bit_cnt = 0 then state <= ACK3; else bit_cnt <= bit_cnt - 1; end if;
                        end if;

                    when ACK3 =>
                        if phase = 0 then sda_out <= '1'; scl_out <= '0'; phase <= 1;
                        elsif phase = 1 then scl_out <= '1'; phase <= 2;
                        elsif phase = 2 then scl_out <= '1'; phase <= 3;
                        elsif phase = 3 then scl_out <= '0'; phase <= 0;
                            bit_cnt <= 7; state <= READ_MSB;
                        end if;

                    when READ_MSB =>
                        if phase = 0 then sda_out <= '1'; scl_out <= '0'; phase <= 1;
                        elsif phase = 1 then scl_out <= '1'; phase <= 2;
                        elsif phase = 2 then shift_rx(8 + bit_cnt) <= SDA; scl_out <= '1'; phase <= 3;
                        elsif phase = 3 then scl_out <= '0'; phase <= 0;
                            if bit_cnt = 0 then state <= ACK_MASTER; else bit_cnt <= bit_cnt - 1; end if;
                        end if;

                    when ACK_MASTER =>
                        if phase = 0 then sda_out <= '0'; scl_out <= '0'; phase <= 1; 
                        elsif phase = 1 then scl_out <= '1'; phase <= 2;
                        elsif phase = 2 then scl_out <= '1'; phase <= 3;
                        elsif phase = 3 then scl_out <= '0'; phase <= 0;
                            bit_cnt <= 7; state <= READ_LSB;
                        end if;

                    when READ_LSB =>
                        if phase = 0 then sda_out <= '1'; scl_out <= '0'; phase <= 1;
                        elsif phase = 1 then scl_out <= '1'; phase <= 2;
                        elsif phase = 2 then shift_rx(bit_cnt) <= SDA; scl_out <= '1'; phase <= 3;
                        elsif phase = 3 then scl_out <= '0'; phase <= 0;
                            if bit_cnt = 0 then state <= NACK_MASTER; else bit_cnt <= bit_cnt - 1; end if;
                        end if;

                    when NACK_MASTER =>
                        if phase = 0 then sda_out <= '1'; scl_out <= '0'; phase <= 1; 
                        elsif phase = 1 then scl_out <= '1'; phase <= 2;
                        elsif phase = 2 then scl_out <= '1'; phase <= 3;
                        elsif phase = 3 then scl_out <= '0'; phase <= 0;
                            state <= STOP;
                        end if;

                    when STOP =>
                        if phase = 0 then sda_out <= '0'; scl_out <= '0'; phase <= 1;
                        elsif phase = 1 then sda_out <= '0'; scl_out <= '1'; phase <= 2;
                        elsif phase = 2 then sda_out <= '1'; scl_out <= '1'; phase <= 3;
                            temp_data <= shift_rx; 
                            busy <= '0';
                        elsif phase = 3 then phase <= 0;
                            delay_cnt <= 0;
                            state <= DELAY_WAIT; 
                        end if;
                        
                    when DELAY_WAIT =>
                        if delay_cnt < 5000 then 
                            delay_cnt <= delay_cnt + 1;
                        else
                            state <= IDLE;
                        end if;
                end case;
            end if;
        end if;
    end process;
end Behavioral;