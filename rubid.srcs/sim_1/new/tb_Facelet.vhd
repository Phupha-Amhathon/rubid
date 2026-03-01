library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_Facelet is
-- Testbench ไม่มี Port
end tb_Facelet;

architecture sim of tb_Facelet is
    -- 1. ประกาศ Component ที่จะทดสอบ
    component Facelet
        Port ( 
            W2, W1, W0 : in STD_LOGIC_VECTOR (2 downto 0);
            Pre        : in STD_LOGIC_VECTOR (2 downto 0);
            S          : in STD_LOGIC_VECTOR (2 downto 0);
            Clk        : in STD_LOGIC;
            Q          : out STD_LOGIC_VECTOR (2 downto 0)
        );
    end component;

    -- 2. สัญญาณจำลอง (Internal Signals)
    signal t_W2, t_W1, t_W0 : std_logic_vector(2 downto 0) := "000";
    signal t_Pre            : std_logic_vector(2 downto 0) := "111"; -- สมมติสีขาว
    signal t_S              : std_logic_vector(2 downto 0) := "000";
    signal t_Clk            : std_logic := '0';
    signal t_Q              : std_logic_vector(2 downto 0);

    -- กำหนดความเร็ว Clock (เช่น 100MHz = 10ns)
    constant CLK_PERIOD : time := 10 ns;

begin
    -- 3. เชื่อมต่อ Component เข้ากับสัญญาณจำลอง (UUT: Unit Under Test)
    UUT: Facelet port map (
        W2 => t_W2, W1 => t_W1, W0 => t_W0,
        Pre => t_Pre, S => t_S, Clk => t_Clk, Q => t_Q
    );

    -- 4. สร้างสัญญาณ Clock (Oscillator)
    clk_process : process
    begin
        t_Clk <= '0';
        wait for CLK_PERIOD/2;
        t_Clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- 5. ขั้นตอนการทดสอบ (Stimulus)
    stim_proc: process
    begin		
        -- รอให้ระบบนิ่งแป๊บนึง
        wait for 20 ns;

        -- ทดสอบการ Hold ค่า (S=000): Q ควรจะยังนิ่งหรือเป็นค่าสุ่ม
        t_S <= "000";
        wait for 20 ns;

        -- ทดสอบ Load ค่าจาก W0 (S=001): สมมติให้ W0 เป็นสีแดง "001"
        t_W0 <= "001";
        t_S  <= "001";
        wait for 20 ns; -- หลัง Falling Edge, Q ควรกลายเป็น "001"

        -- ทดสอบเปลี่ยนกลับไป Hold (S=000): แม้ W0 จะเปลี่ยน แต่ Q ต้องนิ่ง
        t_S  <= "000";
        t_W0 <= "010"; -- เปลี่ยน W0 เล่นๆ
        wait for 20 ns;

        -- ทดสอบการ Preset (S=111): โหลดสีจาก Pre ("111")
        t_S <= "111";
        wait for 20 ns;

        -- จบการทดสอบ
        wait;
    end process;

end sim;