library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity I2C_Reader is
    Port (
        Clk       : in  std_logic;  
        RESET     : in  std_logic;
        SCL       : inout std_logic;
        SDA       : inout std_logic;
        temp_data : out std_logic_vector(15 downto 0)
    );
end I2C_Reader;

architecture Behavioral of I2C_Reader is
    -- Divide 100MHz clock down to 100kHz for standard I2C speed
    signal clk_cnt : integer range 0 to 999 := 0;
    signal tick_0, tick_250, tick_500 : boolean;
    
    type state_type is (IDLE, START_COND, SEND_ADDR, WAIT_ACK1, READ_MSB, SEND_ACK, READ_LSB, SEND_NACK, STOP_COND, DELAY);
    signal state : state_type := IDLE;
    
    signal bit_cnt   : integer range 0 to 7 := 0;
    signal shift_reg : std_logic_vector(7 downto 0);
    signal data_reg  : std_logic_vector(15 downto 0) := (others => '0');
    
    -- Open-Drain Control Signals
    signal sda_dir : std_logic := '0'; 
    signal sda_out : std_logic := '1';
    signal scl_dir : std_logic := '0';
    signal scl_out : std_logic := '1';
begin
    -- CRITICAL FIX: True I2C Open-Drain Logic. 
    -- '0' pulls the line to ground, 'Z' lets it float high safely.
    SDA <= '0' when (sda_dir = '1' and sda_out = '0') else 'Z';
    SCL <= '0' when (scl_dir = '1' and scl_out = '0') else 'Z';

    temp_data <= data_reg;

    tick_0   <= (clk_cnt = 0);
    tick_250 <= (clk_cnt = 250);
    tick_500 <= (clk_cnt = 500);

    process(Clk)
    begin
        if rising_edge(Clk) then
            if RESET = '1' then
                clk_cnt <= 0;
                state <= IDLE;
                bit_cnt <= 0;
                shift_reg <= (others => '0');
                data_reg <= (others => '0');
                sda_dir <= '0';
                sda_out <= '1';
                scl_dir <= '0';
                scl_out <= '1';
            else
                if clk_cnt = 999 then
                    clk_cnt <= 0;
                else
                    clk_cnt <= clk_cnt + 1;
                end if;
                
                -- Phase 1: Change Data
                if tick_0 then 
                    case state is
                        when IDLE =>       sda_dir <= '0'; scl_dir <= '0';
                        when START_COND => sda_dir <= '1'; sda_out <= '0'; scl_dir <= '0';
                        when SEND_ADDR =>  scl_dir <= '1'; scl_out <= '0'; sda_dir <= '1'; sda_out <= shift_reg(7);
                        when WAIT_ACK1 =>  scl_dir <= '1'; scl_out <= '0'; sda_dir <= '0'; 
                        when READ_MSB =>   scl_dir <= '1'; scl_out <= '0'; sda_dir <= '0'; 
                        when SEND_ACK =>   scl_dir <= '1'; scl_out <= '0'; sda_dir <= '1'; sda_out <= '0'; 
                        when READ_LSB =>   scl_dir <= '1'; scl_out <= '0'; sda_dir <= '0'; 
                        when SEND_NACK =>  scl_dir <= '1'; scl_out <= '0'; sda_dir <= '1'; sda_out <= '1'; 
                        when STOP_COND =>  scl_dir <= '1'; scl_out <= '0'; sda_dir <= '1'; sda_out <= '0'; 
                        when DELAY =>      sda_dir <= '0'; scl_dir <= '0'; 
                    end case;
                end if;

                -- Phase 2: Raise Clock
                if tick_250 then
                    case state is
                        when SEND_ADDR | WAIT_ACK1 | READ_MSB | SEND_ACK | READ_LSB | SEND_NACK | STOP_COND =>
                            scl_dir <= '0'; 
                        when others => null;
                    end case;
                end if;

                -- Phase 3: Sample Data / State Transitions
                if tick_500 then
                    case state is
                        when IDLE =>
                            state <= START_COND;
                        when START_COND =>
                            shift_reg <= "10010111"; -- 0x4B (ADT7420 Address) + Read bit
                            bit_cnt <= 7;
                            state <= SEND_ADDR;
                        when SEND_ADDR =>
                            if bit_cnt = 0 then state <= WAIT_ACK1;
                            else bit_cnt <= bit_cnt - 1; shift_reg <= shift_reg(6 downto 0) & '0'; end if;
                        when WAIT_ACK1 =>
                            bit_cnt <= 7; state <= READ_MSB;
                        when READ_MSB =>
                            data_reg(bit_cnt + 8) <= to_X01(SDA);
                            if bit_cnt = 0 then state <= SEND_ACK; else bit_cnt <= bit_cnt - 1; end if;
                        when SEND_ACK =>
                            bit_cnt <= 7; state <= READ_LSB;
                        when READ_LSB =>
                            data_reg(bit_cnt) <= to_X01(SDA);
                            if bit_cnt = 0 then state <= SEND_NACK; else bit_cnt <= bit_cnt - 1; end if;
                        when SEND_NACK =>
                            state <= STOP_COND;
                        when STOP_COND =>
                            sda_dir <= '0'; state <= DELAY;
                        when DELAY =>
                            if bit_cnt = 7 then state <= IDLE; else bit_cnt <= bit_cnt + 1; end if;
                    end case;
                end if;
            end if;
        end if;
    end process;
end Behavioral;
