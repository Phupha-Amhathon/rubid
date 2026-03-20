-- code นี้มีไว้เเก้การปุ่มเบิ้ล สมมุติว่าเวลากดปุ่ม 1 ครั้ง ระบบจะคิดว่าเรากด 20 ครั้ง จากการที่ปุ่มมันสั่น
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
--D Flip-Flop ทำงานทุกครั้งที่มีจังหวะ Clock เเละรับค่าที่อยู่ตรงหน้า (ไม่ว่าจะเป็น 1 หรือ 0) แล้วส่งต่อไปให้กล่องถัดไปเรื่อยๆ
--If D flip flop จับสัญญาณสั่นเเล้ว 0 หลุดเข้ามา เเม้จะมีตัวเดียวระบบจะไม่ปล่อยไฟ เเล้วเริ่มใหม่
--รอจนกว่าให้สัญญาณ '1' ล้วนๆ ไหลเข้ามาเติมจนเต็มสายพานทั้ง 4 กล่องอีกครั้ง (ซึ่งก็ต้องใช้เวลา 4 จังหวะ Clock) ประตู AND Gate ถึงจะยอมปล่อยไฟ
   
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
