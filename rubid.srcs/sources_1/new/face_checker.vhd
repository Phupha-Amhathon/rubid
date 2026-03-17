library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity face_checker is
    Port ( 
        Face_In  : in STD_LOGIC_VECTOR (11 downto 0); -- The 12 bits (4 facelets x 3 bits) of one face
        Is_Solid : out STD_LOGIC                      -- Outputs '1' if the whole face matches
    );
end face_checker;

architecture Dataflow of face_checker is

    signal match_1_and_2 : STD_LOGIC;
    signal match_1_and_3 : STD_LOGIC;
    signal match_1_and_4 : STD_LOGIC;

begin

    match_1_and_2 <= (Face_In(11) xnor Face_In(8)) and 
                     (Face_In(10) xnor Face_In(7)) and 
                     (Face_In(9)  xnor Face_In(6));

    match_1_and_3 <= (Face_In(11) xnor Face_In(5)) and 
                     (Face_In(10) xnor Face_In(4)) and 
                     (Face_In(9)  xnor Face_In(3));

    match_1_and_4 <= (Face_In(11) xnor Face_In(2)) and 
                     (Face_In(10) xnor Face_In(1)) and 
                     (Face_In(9)  xnor Face_In(0));

    Is_Solid <= match_1_and_2 and match_1_and_3 and match_1_and_4;

end Dataflow;