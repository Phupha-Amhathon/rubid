library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity face_checker is
    Port ( 
        Face_In  : in STD_LOGIC_VECTOR (11 downto 0); -- The 12 bits (4 facelets x 3 bits) of one face
        Is_Solid : out STD_LOGIC                      -- Outputs '1' if the whole face matches
    );
end face_checker;

architecture Dataflow of face_checker is

    signal match_1bit : STD_LOGIC;
    signal match_2bit : STD_LOGIC;
    signal match_3bit : STD_LOGIC;

begin
    --0 1 2 | 3 4 5 
    --6 7 8 | 9 10 11 
    match_1bit <= (Face_In(0) xnor Face_In(3)) and 
                     (Face_In(0) xnor Face_In(6)) and 
                     (Face_In(0)  xnor Face_In(9));

    match_2bit <= (Face_In(1) xnor Face_In(4)) and 
                     (Face_In(1) xnor Face_In(7)) and 
                     (Face_In(1)  xnor Face_In(10));

    match_3bit <= (Face_In(2) xnor Face_In(5)) and 
                     (Face_In(2) xnor Face_In(8)) and 
                     (Face_In(2)  xnor Face_In(11));

    Is_Solid <= match_1bit and match_2bit and match_3bit;

end Dataflow;