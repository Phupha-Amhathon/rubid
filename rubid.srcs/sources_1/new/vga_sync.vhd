LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY vga_sync IS
    PORT (
        clk : IN STD_LOGIC; --100MHz clock from board
        reset : IN STD_LOGIC;
        hsync : OUT STD_LOGIC; -- Horizontal sync signal for VGA
        vsync : OUT STD_LOGIC; -- vertical sync signal for VGA
        video_on : OUT STD_LOGIC; -- 1 when inside the visible screen 
        p_tick : OUT STD_LOGIC; -- the 25MHz pixel clock 
        x : OUT STD_LOGIC_VECTOR(9 DOWNTO 0); -- current X coordinate
        y : OUT STD_LOGIC_VECTOR(9 DOWNTO 0) -- current Y coordinate 
    );
END vga_sync;

ARCHITECTURE Behavioral OF vga_sync IS
    SIGNAL clk_2 : STD_LOGIC := '0';
    SIGNAL pix_clock : STD_LOGIC := '0';

    SIGNAL h_cnt : unsigned(9 DOWNTO 0) := (OTHERS => '0');
    SIGNAL v_cnt : unsigned(9 DOWNTO 0) := (OTHERS => '0');

BEGIN
    -- divides 100MHz by 2 -> 50MHz
    clk_div_2 : PROCESS (clk, reset)
    BEGIN
        IF (reset = '1') THEN
            clk_2 <= '0';
        ELSIF rising_edge(clk) THEN
            clk_2 <= NOT clk_2;
        END IF;
    END PROCESS;

    -- Divides 50MHz by 2 -> 25MHz (The required VGA pixel frequency)
    pix_clk_gen : PROCESS (clk_2, reset)
    BEGIN
        IF (reset = '1') THEN
            pix_clock <= '0';
        ELSIF rising_edge(clk_2) THEN
            pix_clock <= NOT pix_clock;
        END IF;
    END PROCESS;

    p_tick <= pix_clock; -- Send the 25MHz clock out to the main video module

    -- VGA Timing Standards for 640x480@60Hz:
    -- H-Sync goes low during the horizontal "retrace" period (pixels 656 to 751)
    hsync <= '0' WHEN h_cnt >= 656 AND h_cnt < 752 ELSE
        '1';
    -- V-Sync goes low during the vertical "retrace" period (lines 490 to 491)
    vsync <= '0' WHEN v_cnt = 490 OR v_cnt = 491 ELSE
        '1';

    -- We only draw colors when we are within the actual 640x480 resolution
    video_on <= '1' WHEN h_cnt < 640 AND v_cnt < 480 ELSE
        '0';

    -- Export the current scan coordinates
    x <= STD_LOGIC_VECTOR(h_cnt);
    y <= STD_LOGIC_VECTOR(v_cnt);

    control : PROCESS (pix_clock, reset)
    BEGIN
        IF (reset = '1') THEN
            h_cnt <= (OTHERS => '0');
            v_cnt <= (OTHERS => '0');
        ELSIF rising_edge(pix_clock) THEN
            -- Scan right across the line (0 to 799 total ticks per line)
            IF (h_cnt < 799) THEN
                h_cnt <= h_cnt + 1;
            ELSE
                h_cnt <= (OTHERS => '0'); -- Hit the end of the line, carriage return to X=0
                IF (v_cnt < 524) THEN -- Move down to the next line (0 to 524 total lines per frame)
                    v_cnt <= v_cnt + 1;
                ELSE
                    v_cnt <= (OTHERS => '0'); -- Hit the bottom, return to the top-left corner
                END IF;
            END IF;
        END IF;
    END PROCESS;

END Behavioral;