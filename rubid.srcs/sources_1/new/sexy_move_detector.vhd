library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity sexy_move_detector is
    Port (
        Clk          : in STD_LOGIC;
        BTN_Execute  : in STD_LOGIC;                      
        SW_Face      : in STD_LOGIC_VECTOR(2 downto 0);   
        SW_Direction : in STD_LOGIC;                      
        RESET        : in STD_LOGIC;
        Time_Bonus   : out STD_LOGIC;                     
        -- for debugging 
        Debug_State  : out STD_LOGIC_VECTOR(5 downto 0)   
    );
end sexy_move_detector;

architecture gate_level of sexy_move_detector is

    -- ==========================================
    -- การประกาศ Signal สำหรับระบบ Gate-Level
    -- ==========================================
    
    -- Signals สำหรับ D-Flip Flops (Q = Current State, D = Next State)
    signal Q0, Q1, Q2 : STD_LOGIC := '0'; 
    signal D0, D1, D2 : STD_LOGIC;

    -- Signals สำหรับวงจร Edge Detector ตรวจจับขอบขาขึ้นของปุ่มกด
    signal btn_prev_Q : STD_LOGIC := '0';
    signal btn_prev_D : STD_LOGIC;
    signal move_tick  : STD_LOGIC;

    -- Signals ภายในสำหรับ Inverter (NOT gates) 
    signal not_F2, not_F0, not_D : STD_LOGIC;
    signal not_Q2, not_Q1, not_Q0 : STD_LOGIC;

    -- Signals สำหรับวงจรเช็ค Input (Pattern Matchers)
    signal match_R, match_U, match_Rp, match_Up : STD_LOGIC;

    -- Signals สำหรับถอดรหัสสถานะปัจจุบัน (State Decoders)
    signal is_IDLE, is_GOT_R, is_GOT_U, is_GOT_R_PRIME, is_GOT_U_PRIME : STD_LOGIC;

    -- Signals สำหรับวงจรคำนวณ Next State (Combinational Logic)
    signal to_GOT_R, to_GOT_U, to_GOT_R_P, to_GOT_U_P, stay : STD_LOGIC;
    signal stay_Q0, stay_Q1, stay_Q2 : STD_LOGIC;

begin

    -- ==========================================
    -- 1. Inverters (NOT Gates) 
    -- ==========================================
    -- สลับค่า Input เพื่อเตรียมใช้ร่วมกับ AND gate
    not_F2 <= not SW_Face(2);
    not_F0 <= not SW_Face(0);
    not_D  <= not SW_Direction;

    -- สลับค่า State เพื่อใช้ในวงจรถอดรหัส
    not_Q2 <= not Q2;
    not_Q1 <= not Q1;
    not_Q0 <= not Q0;

    -- ==========================================
    -- 2. Input Pattern Matchers (AND Gates)
    -- ==========================================
    -- เช็คเงื่อนไขท่า R: Face="010", Dir='0'
    match_R  <= not_F2 and SW_Face(1) and not_F0 and not_D;
    
    -- เช็คเงื่อนไขท่า U: Face="011", Dir='0'
    match_U  <= not_F2 and SW_Face(1) and SW_Face(0) and not_D;
    
    -- เช็คเงื่อนไขท่า R': Face="010", Dir='1'
    match_Rp <= not_F2 and SW_Face(1) and not_F0 and SW_Direction;
    
    -- เช็คเงื่อนไขท่า U': Face="011", Dir='1'
    match_Up <= not_F2 and SW_Face(1) and SW_Face(0) and SW_Direction;

    -- ==========================================
    -- 3. Move Tick Generator (Edge Detector Logic)
    -- ==========================================
    btn_prev_D <= BTN_Execute;  -- ต่อสายตรงเข้า D-FF สำหรับจำค่าปุ่ม
    
    -- สัญญาณ Tick จะเป็น 1 เมื่อกดปุ่มปัจจุบัน (1) AND กับค่าปุ่มในอดีต (0)
    move_tick  <= BTN_Execute and (not btn_prev_Q);

    -- ==========================================
    -- 4. State Decoders (AND Gates)
    -- ==========================================
    -- แยกสถานะปัจจุบันเพื่อความง่ายในการเขียนสมการ 
    is_IDLE        <= not_Q2 and not_Q1 and not_Q0;  -- 000
    is_GOT_R       <= not_Q2 and not_Q1 and Q0;      -- 001
    is_GOT_U       <= not_Q2 and Q1     and not_Q0;  -- 010
    is_GOT_R_PRIME <= not_Q2 and Q1     and Q0;      -- 011
    is_GOT_U_PRIME <= Q2     and not_Q1 and not_Q0;  -- 100

    -- ==========================================
    -- 5. Next State Combinational Logic (AND/OR Gates)
    -- ==========================================
    -- สร้างสมการเงื่อนไขในการ "ข้าม" ไปยังสถานะใหม่ (เมื่อมี Tick ขาขึ้น)
    
    -- ไปที่ GOT_R (001) ได้จากทุกสถานะยกเว้น U_PRIME ถ้า input ถูกต้อง
    to_GOT_R   <= move_tick and match_R and (not is_GOT_U_PRIME);
    
    -- ไปที่ GOT_U (010) ได้จาก GOT_R เท่านั้น
    to_GOT_U   <= is_GOT_R and move_tick and match_U;
    
    -- ไปที่ GOT_R' (011) ได้จาก GOT_U เท่านั้น
    to_GOT_R_P <= is_GOT_U and move_tick and match_Rp;
    
    -- ไปที่ GOT_U' (100) ได้จาก GOT_R' เท่านั้น
    to_GOT_U_P <= is_GOT_R_PRIME and move_tick and match_Up;

    -- เงื่อนไขการ "อยู่กับที่" (Stay) คือไม่มีการกดปุ่ม (no move_tick) 
    -- และไม่ได้อยู่ใน State สุดท้ายที่ต้องเด้งกลับอัตโนมัติ (U_PRIME)
    stay       <= (not move_tick) and (not is_GOT_U_PRIME);

    stay_Q0    <= stay and Q0;
    stay_Q1    <= stay and Q1;
    stay_Q2    <= stay and Q2;

    -- สมการสำหรับ D-Flip Flop แต่ละบิต (Next State Logic)
    -- D0 จะเป็น 1 เมื่อต้องไปสถานะ 001(R), 011(R') หรือค้างค่าเดิมที่เป็น 1
    D0 <= to_GOT_R or to_GOT_R_P or stay_Q0;
    
    -- D1 จะเป็น 1 เมื่อต้องไปสถานะ 010(U), 011(R') หรือค้างค่าเดิมที่เป็น 1
    D1 <= to_GOT_U or to_GOT_R_P or stay_Q1;
    
    -- D2 จะเป็น 1 เมื่อต้องไปสถานะ 100(U') หรือค้างค่าเดิมที่เป็น 1
    D2 <= to_GOT_U_P or stay_Q2;

    -- ==========================================
    -- 6. Outputs Logic
    -- ==========================================
    -- Time Bonus จะเป็น 1 ได้แค่เมื่ออยู่สถานะ U_PRIME
    Time_Bonus <= is_GOT_U_PRIME;

    -- ต่อไฟ LED ตามสถานะ
    Debug_State(0) <= is_IDLE;
    Debug_State(1) <= is_GOT_R;
    Debug_State(2) <= is_GOT_U;
    Debug_State(3) <= is_GOT_R_PRIME;
    Debug_State(4) <= is_GOT_U_PRIME;
    -- LED 5 จะติดเมื่อหลุดไป State อื่นที่ไม่มีในระบบ (NOR Gate)
    Debug_State(5) <= not (is_IDLE or is_GOT_R or is_GOT_U or is_GOT_R_PRIME or is_GOT_U_PRIME);

    -- ==========================================
    -- 7. Flip-Flops (Sequential Elements)
    -- ==========================================
    -- ใน VHDL ระดับ Gate-Level เรายังจำเป็นต้องใช้ Process พื้นฐานเพื่อสร้าง
    -- D-Flip Flop ที่ตอบสนองต่อสัญญาณนาฬิกา (Clock) ในวงจรจริง
    process(Clk)
    begin
        if falling_edge(Clk) then
            if RESET = '1' then 
                -- เมื่อ Reset เป็น 1 ให้รีเซ็ตสถานะทั้งหมดกลับไป IDLE (000)
                Q0 <= '0';
                Q1 <= '0';
                Q2 <= '0';
                btn_prev_Q <= '0'; -- รีเซ็ตค่าปุ่มเก่า
            else
                -- อัปเดตสถานะปัจจุบันด้วยค่าที่คำนวณได้จาก Next State Logic
                btn_prev_Q <= btn_prev_D; -- อัปเดตค่าปุ่มกดเก่า
                Q0 <= D0;                 -- อัปเดต State บิตที่ 0
                Q1 <= D1;                 -- อัปเดต State บิตที่ 1
                Q2 <= D2;                 -- อัปเดต State บิตที่ 2
            end if;
        end if;
    end process;

end gate_level;