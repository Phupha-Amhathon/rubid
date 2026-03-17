library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity videoRubik is
    Port (
        clk     : in  STD_LOGIC;
        reset   : in  STD_LOGIC;
        Q_all   : in  STD_LOGIC_VECTOR(71 downto 0);
        hsync   : out STD_LOGIC;
        vsync   : out STD_LOGIC;
        rgb     : out STD_LOGIC_VECTOR(11 downto 0) -- 12-bit color output for Nexys A7 VGA
    );
end videoRubik;

architecture Behavioral of videoRubik is
    -- Internal wiring from vga_sync
    signal hsync_int, vsync_int, video_on, p_tick : STD_LOGIC;
    signal hPos, vPos : STD_LOGIC_VECTOR(9 downto 0);
    
    -- Graphic Constants: Each facelet is 50x50 pixels, with a 4-pixel border/gap
    constant sqSize : integer := 50;
    constant gap : integer := 4;
    constant faceSize : integer := 104; -- (50 * 2) + 4
    
    -- ROW 0: [ x, U, x, x ]
    constant uStartX : integer := 214;
    constant uStartY : integer := 80;
    
    -- ROW 1: [ L, F, R, B ]
    constant lStartX : integer := 106;
    constant lStartY : integer := 188;
    
    constant fStartX : integer := 214; -- Matches U and D perfectly!
    constant fStartY : integer := 188;
    
    constant rStartX : integer := 322;
    constant rStartY : integer := 188;
    
    constant bStartX : integer := 430;
    constant bStartY : integer := 188;
    
    -- ROW 2: [ x, D, x, x ]
    constant dStartX : integer := 214;
    constant dStartY : integer := 296;

    component vga_sync is
        Port (
            clk     : in  STD_LOGIC;
            reset   : in  STD_LOGIC;
            hsync   : out STD_LOGIC;
            vsync   : out STD_LOGIC;
            video_on : out STD_LOGIC;
            p_tick  : out STD_LOGIC;
            x       : out STD_LOGIC_VECTOR(9 downto 0);
            y       : out STD_LOGIC_VECTOR(9 downto 0)
        );
    end component;
    
    -- Converts  3-bit binary memory into physical 12-bit HEX colors
    function get_color(color_code : std_logic_vector(2 downto 0)) return std_logic_vector is
    begin
        case color_code is
            when "000" => return X"0DE"; -- yellow  (up)
            when "001" => return X"5D9"; -- green   (front)
            when "010" => return X"53A"; -- red     (left)
            when "011" => return X"B63"; -- blue    (right)
            when "100" => return X"FFF"; -- white   (down)
            when "101" => return X"49E"; -- orange  (back)
            when others => return X"666"; -- Default to dark gray
        end case;
    end function;
    
begin
    -- Drop the driver chip onto the board
    vga_sync_inst : vga_sync
        port map (
            clk => clk,
            reset => reset,
            hsync => hsync_int,
            vsync => vsync_int,
            video_on => video_on,
            p_tick => p_tick,
            x => hPos,
            y => vPos
        );
    
    -- Route sync signals to output pins
    hsync <= hsync_int;
    vsync <= vsync_int;
    
    -- The Painting Process
    process(p_tick)
        variable h, v : integer;
        variable sqX, sqY : integer;
        variable localX, localY : integer;
        variable facelet_idx : integer;
    begin
        -- Only update the color exactly when the 25MHz pixel clock ticks
        if rising_edge(p_tick) then
            if video_on = '0' then
                rgb <= (others => '0');
            else
                h := to_integer(unsigned(hPos));
                v := to_integer(unsigned(vPos));
                
                rgb <= X"222"; -- Background color (black)

                -- =========================================================
                -- COLLISION DETECTION: UP FACE
                -- =========================================================
                -- Check if the current pixel is inside the UP face boundary
                if h >= uStartX and h < uStartX + faceSize and
                   v >= uStartY and v < uStartY + faceSize then
                    localX := h - uStartX;
                    localY := v - uStartY;
                    sqX := localX / (sqSize + gap);
                    sqY := localY / (sqSize + gap);
                    if localX < sqX * (sqSize + gap) + sqSize and localY < sqY * (sqSize + gap) + sqSize then
                        facelet_idx := sqY * 2 + sqX;
                        rgb <= get_color(Q_all(71 - facelet_idx * 3 downto 69 - facelet_idx * 3));
                    end if;
                
                elsif h >= lStartX and h < lStartX + faceSize and
                      v >= lStartY and v < lStartY + faceSize then
                    localX := h - lStartX;
                    localY := v - lStartY;
                    sqX := localX / (sqSize + gap);
                    sqY := localY / (sqSize + gap);
                    if localX < sqX * (sqSize + gap) + sqSize and localY < sqY * (sqSize + gap) + sqSize then
                        facelet_idx := 8 + sqY * 2 + sqX;
                        rgb <= get_color(Q_all(71 - facelet_idx * 3 downto 69 - facelet_idx * 3));
                    end if;
                
                elsif h >= fStartX and h < fStartX + faceSize and
                      v >= fStartY and v < fStartY + faceSize then
                    localX := h - fStartX;
                    localY := v - fStartY;
                    sqX := localX / (sqSize + gap);
                    sqY := localY / (sqSize + gap);
                    if localX < sqX * (sqSize + gap) + sqSize and localY < sqY * (sqSize + gap) + sqSize then
                        facelet_idx := 4 + sqY * 2 + sqX;
                        rgb <= get_color(Q_all(71 - facelet_idx * 3 downto 69 - facelet_idx * 3));
                    end if;
                
                elsif h >= rStartX and h < rStartX + faceSize and
                      v >= rStartY and v < rStartY + faceSize then
                    localX := h - rStartX;
                    localY := v - rStartY;
                    sqX := localX / (sqSize + gap);
                    sqY := localY / (sqSize + gap);
                    if localX < sqX * (sqSize + gap) + sqSize and localY < sqY * (sqSize + gap) + sqSize then
                        facelet_idx := 12 + sqY * 2 + sqX;
                        rgb <= get_color(Q_all(71 - facelet_idx * 3 downto 69 - facelet_idx * 3));
                    end if;
                
                elsif h >= bStartX and h < bStartX + faceSize and
                      v >= bStartY and v < bStartY + faceSize then
                    localX := h - bStartX;
                    localY := v - bStartY;
                    sqX := localX / (sqSize + gap);
                    sqY := localY / (sqSize + gap);
                    if localX < sqX * (sqSize + gap) + sqSize and localY < sqY * (sqSize + gap) + sqSize then
                        facelet_idx := 16 + sqY * 2 + sqX;
                        rgb <= get_color(Q_all(71 - facelet_idx * 3 downto 69 - facelet_idx * 3));
                    end if;
                
                elsif h >= dStartX and h < dStartX + faceSize and
                      v >= dStartY and v < dStartY + faceSize then
                    localX := h - dStartX;
                    localY := v - dStartY;
                    sqX := localX / (sqSize + gap);
                    sqY := localY / (sqSize + gap);
                    if localX < sqX * (sqSize + gap) + sqSize and localY < sqY * (sqSize + gap) + sqSize then
                        facelet_idx := 20 + sqY * 2 + sqX;
                        rgb <= get_color(Q_all(71 - facelet_idx * 3 downto 69 - facelet_idx * 3));
                    end if;
                end if;
            end if;
        end if;
    end process;
    
end Behavioral;