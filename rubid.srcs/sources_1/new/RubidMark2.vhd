LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY RubidMark2 IS
    PORT (
        S : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
        Clk : IN STD_LOGIC;
        Q_all : OUT STD_LOGIC_VECTOR (71 DOWNTO 0);
        is_solved : OUT STD_LOGIC
    );
END RubidMark2;

ARCHITECTURE Behavioral OF RubidMark2 IS

    COMPONENT Rubid IS
        PORT (
            S : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
            Clk : IN STD_LOGIC;
            Q_all : OUT STD_LOGIC_VECTOR (71 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT face_checker IS
        PORT (
            Face_In : IN STD_LOGIC_VECTOR (11 DOWNTO 0);
            Is_Solid : OUT STD_LOGIC
        );
    END COMPONENT;

    signal q_internal : STD_LOGIC_VECTOR(71 downto 0);
    signal solid_flags : STD_LOGIC_VECTOR(5 downto 0);

BEGIN

    Core_Cube : Rubid PORT MAP(
        S => S,
        Clk => Clk,
        Q_all => q_internal
    );
    Q_all <= q_internal;

    Check_UP    : face_checker port map (Face_In => q_internal(71 downto 60), Is_Solid => solid_flags(5));
    Check_FRONT : face_checker port map (Face_In => q_internal(59 downto 48), Is_Solid => solid_flags(4));
    Check_LEFT  : face_checker port map (Face_In => q_internal(47 downto 36), Is_Solid => solid_flags(3));
    Check_RIGHT : face_checker port map (Face_In => q_internal(35 downto 24), Is_Solid => solid_flags(2));
    Check_BACK  : face_checker port map (Face_In => q_internal(23 downto 12), Is_Solid => solid_flags(1));
    Check_DOWN  : face_checker port map (Face_In => q_internal(11 downto 0),  Is_Solid => solid_flags(0));

    is_solved <= solid_flags(5) and solid_flags(4) and solid_flags(3) and 
                 solid_flags(2) and solid_flags(1) and solid_flags(0) and (not S(2)) and (not S(1)) and (not S(0));

END Behavioral;