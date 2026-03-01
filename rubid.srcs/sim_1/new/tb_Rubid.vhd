library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_Rubid is
-- Testbench has no ports
end tb_Rubid;

architecture sim of tb_Rubid is
    -- 1. ประกาศ Component Rubid (ต้องตรงกับ Entity ที่คุณแก้ชื่อพอร์ต)
    component Rubid
        Port ( 
            S : in STD_LOGIC_VECTOR (2 downto 0);
            Clk : in STD_LOGIC;
            out_U0, out_U3, out_U6, out_U9 : out std_logic_vector(2 downto 0);
            out_F0, out_F3, out_F6, out_F9 : out std_logic_vector(2 downto 0);
            out_L0, out_L3, out_L6, out_L9 : out std_logic_vector(2 downto 0);
            out_R0, out_R3, out_R6, out_R9 : out std_logic_vector(2 downto 0);
            out_B0, out_B3, out_B6, out_B9 : out std_logic_vector(2 downto 0);
            out_D0, out_D3, out_D6, out_D9 : out std_logic_vector(2 downto 0);
            Q_all : out STD_LOGIC_VECTOR (71 downto 0)
        );
    end component;

    -- 2. สัญญาณจำลอง (Internal Signals)
    signal t_S   : std_logic_vector(2 downto 0) := "000";
    signal t_Clk : std_logic := '0';
    
    -- สัญญาณรับค่าแยกทุกหน้า (เพื่อดูใน Waveform และ Monitor)
    signal t_U0, t_U3, t_U6, t_U9 : std_logic_vector(2 downto 0);
    signal t_F0, t_F3, t_F6, t_F9 : std_logic_vector(2 downto 0);
    signal t_L0, t_L3, t_L6, t_L9 : std_logic_vector(2 downto 0);
    signal t_R0, t_R3, t_R6, t_R9 : std_logic_vector(2 downto 0);
    signal t_B0, t_B3, t_B6, t_B9 : std_logic_vector(2 downto 0);
    signal t_D0, t_D3, t_D6, t_D9 : std_logic_vector(2 downto 0);
    signal t_Q_all : std_logic_vector(71 downto 0);

    -- ฟังก์ชันช่วยแปลสี (Color Decoder)
    function get_color_name(val : std_logic_vector(2 downto 0)) return string is
    begin
        case val is
            when "000" => return "WHITE ";
            when "001" => return "ORANGE";
            when "010" => return "GREEN ";
            when "011" => return "RED   ";
            when "100" => return "YELLOW";
            when "101" => return "BLUE  ";
            when others => return "??    ";
        end case;
    end function;

    constant CLK_PERIOD : time := 10 ns;

begin
    -- 3. Port Map เชื่อมต่อทุกหน้าให้ครบ
    UUT: Rubid port map (
        S => t_S, Clk => t_Clk,
        out_U0 => t_U0, out_U3 => t_U3, out_U6 => t_U6, out_U9 => t_U9,
        out_F0 => t_F0, out_F3 => t_F3, out_F6 => t_F6, out_F9 => t_F9,
        out_L0 => t_L0, out_L3 => t_L3, out_L6 => t_L6, out_L9 => t_L9,
        out_R0 => t_R0, out_R3 => t_R3, out_R6 => t_R6, out_R9 => t_R9,
        out_B0 => t_B0, out_B3 => t_B3, out_B6 => t_B6, out_B9 => t_B9,
        out_D0 => t_D0, out_D3 => t_D3, out_D6 => t_D6, out_D9 => t_D9,
        Q_all => t_Q_all
    );

    -- 4. Clock Generator
    clk_process : process
    begin
        t_Clk <= '0'; wait for CLK_PERIOD/2;
        t_Clk <= '1'; wait for CLK_PERIOD/2;
    end process;

    -- 5. Multi-Case Stimulus
    stim_proc: process
    begin		
        wait for 20 ns;
        
        -- [CASE 1] PRESET: ตั้งค่าสีเริ่มต้น (ต้องเห็นสีครบ 6 หน้า)
        report ">>> CASE 1: PRESET ALL FACES <<<";
        t_S <= "111"; wait for CLK_PERIOD * 2;

        -- [CASE 2] HOLD: เช็คความเสถียร (สีต้องไม่เปลี่ยน)
        report ">>> CASE 2: HOLD STATE (S=000) <<<";
        t_S <= "000"; wait for CLK_PERIOD * 4;

        -- [CASE 3] ROTATION MODE 1: บิดครั้งที่ 1 (สมมติบิดหน้า Up 90 องศา)
        report ">>> CASE 3: FIRST ROTATION (S=001) <<<";
        t_S <= "001"; wait for CLK_PERIOD * 1; 
        t_S <= "000"; wait for CLK_PERIOD * 4;

        -- [CASE 4] ROTATION MODE 2: บิดครั้งที่ 2 (สมมติบิดหน้า Front 90 องศา)
        report ">>> CASE 4: SECOND ROTATION (S=010) <<<";
        t_S <= "010"; wait for CLK_PERIOD * 1;
        t_S <= "000"; wait for CLK_PERIOD * 4;

        -- [CASE 5] CONTINUOUS ROTATION: บิดต่อเนื่อง 2 ครั้ง
        report ">>> CASE 5: CONTINUOUS ROTATION (S=011) <<<";
        t_S <= "011"; wait for CLK_PERIOD * 2; -- หมุน 180 องศา (90x2)
        t_S <= "000"; wait for CLK_PERIOD * 4;

        report "--- ALL TEST CASES FINISHED ---";
        wait;
    end process;

    -- 6. Full Cube Monitor (พิมพ์สภาพรูบิกทั้งลูกลง Tcl Console)
    monitor: process(t_Q_all)
    begin
        report "--- CUBE STATUS UPDATE ---";
        report "   UP:    " & get_color_name(t_U0) & " | " & get_color_name(t_U3);
        report "          " & get_color_name(t_U6) & " | " & get_color_name(t_U9);
        report "   FRONT: " & get_color_name(t_F0) & " | " & get_color_name(t_F3);
        report "          " & get_color_name(t_F6) & " | " & get_color_name(t_F9);
        report "   LEFT:  " & get_color_name(t_L0) & " | " & get_color_name(t_L3);
        report "          " & get_color_name(t_L6) & " | " & get_color_name(t_L9);
        report "   RIGHT: " & get_color_name(t_R0) & " | " & get_color_name(t_R3);
        report "          " & get_color_name(t_R6) & " | " & get_color_name(t_R9);
        report "   BACK:  " & get_color_name(t_B0) & " | " & get_color_name(t_B3);
        report "          " & get_color_name(t_B6) & " | " & get_color_name(t_B9);
        report "   DOWN:  " & get_color_name(t_D0) & " | " & get_color_name(t_D3);
        report "          " & get_color_name(t_D6) & " | " & get_color_name(t_D9);
        report "--------------------------";
    end process;

end sim;