library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

Library UNISIM;
use UNISIM.vcomponents.all;

entity button_debouncer is
   
    Generic (
        CLK_FREQ    : integer := 100_000_000;
        DEBOUNCE_MS : integer := 10           
    );
    Port ( 
        Clk      : in  STD_LOGIC;
        BTN_In   : in  STD_LOGIC;
        BTN_Out  : out STD_LOGIC 
    );
end button_debouncer;


architecture Gate_Level of button_debouncer is

    -- 1. ประกาศสายไฟ 4 เส้น เพื่อเอาไว้เชื่อมระหว่างกล่อง D Flip-Flop
    signal q0, q1, q2, q3 : STD_LOGIC;

begin

    -- 2. วางกล่อง D Flip-Flop 4 ตัว (ใช้ชิ้นส่วนชื่อ FDRE ที่มีอยู่แล้วใน Vivado)
   
    FF0: FDRE port map (C => Clk, CE => '1', R => '0', D => BTN_In, Q => q0);
    FF1: FDRE port map (C => Clk, CE => '1', R => '0', D => q0,     Q => q1);
    FF2: FDRE port map (C => Clk, CE => '1', R => '0', D => q1,     Q => q2);
    FF3: FDRE port map (C => Clk, CE => '1', R => '0', D => q2,     Q => q3);

    -- วาง AND Gate เช็คว่าไฟติดครบ 4 กล่องหรือยัง (ถ้านิ่งจริง ไฟต้องออกเป็น 1 ทั้งหมด)
    BTN_Out <= q0 and q1 and q2 and q3;

end Gate_Level;