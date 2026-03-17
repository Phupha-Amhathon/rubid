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

    SIGNAL q_internal : STD_LOGIC_VECTOR(71 DOWNTO 0);
    SIGNAL up_is_solid : STD_LOGIC;
    SIGNAL front_is_solid : STD_LOGIC;
    SIGNAL left_is_solid : STD_LOGIC;
    SIGNAL right_is_solid : STD_LOGIC;
    SIGNAL back_is_solid : STD_LOGIC;
    SIGNAL down_is_solid : STD_LOGIC;

BEGIN

    Core_Cube : Rubid PORT MAP(
        S => S,
        Clk => Clk,
        Q_all => q_internal
    );

    Q_all <= q_internal;

    -- 1. UP Face (Bits 71 to 60)
    up_is_solid <= '1' WHEN (q_internal(71 DOWNTO 69) = q_internal(68 DOWNTO 66)) AND
        (q_internal(71 DOWNTO 69) = q_internal(65 DOWNTO 63)) AND
        (q_internal(71 DOWNTO 69) = q_internal(62 DOWNTO 60)) ELSE
        '0';
    -- 2. FRONT Face (Bits 59 to 48)
    front_is_solid <= '1' WHEN (q_internal(59 DOWNTO 57) = q_internal(56 DOWNTO 54)) AND
        (q_internal(59 DOWNTO 57) = q_internal(53 DOWNTO 51)) AND
        (q_internal(59 DOWNTO 57) = q_internal(50 DOWNTO 48)) ELSE
        '0';
    -- 3. LEFT Face (Bits 47 to 36)
    left_is_solid <= '1' WHEN (q_internal(47 DOWNTO 45) = q_internal(44 DOWNTO 42)) AND
        (q_internal(47 DOWNTO 45) = q_internal(41 DOWNTO 39)) AND
        (q_internal(47 DOWNTO 45) = q_internal(38 DOWNTO 36)) ELSE
        '0';
    -- 4. RIGHT Face (Bits 35 to 24)
    right_is_solid <= '1' WHEN (q_internal(35 DOWNTO 33) = q_internal(32 DOWNTO 30)) AND
        (q_internal(35 DOWNTO 33) = q_internal(29 DOWNTO 27)) AND
        (q_internal(35 DOWNTO 33) = q_internal(26 DOWNTO 24)) ELSE
        '0';
    -- 5. BACK Face (Bits 23 to 12)
    back_is_solid <= '1' WHEN (q_internal(23 DOWNTO 21) = q_internal(20 DOWNTO 18)) AND
        (q_internal(23 DOWNTO 21) = q_internal(17 DOWNTO 15)) AND
        (q_internal(23 DOWNTO 21) = q_internal(14 DOWNTO 12)) ELSE
        '0';
    -- 6. DOWN Face (Bits 11 to 0)
    down_is_solid <= '1' WHEN (q_internal(11 DOWNTO 9) = q_internal(8 DOWNTO 6)) AND
        (q_internal(11 DOWNTO 9) = q_internal(5 DOWNTO 3)) AND
        (q_internal(11 DOWNTO 9) = q_internal(2 DOWNTO 0)) ELSE
        '0';
    is_solved <= up_is_solid AND front_is_solid AND left_is_solid AND
        right_is_solid AND back_is_solid AND down_is_solid;

END Behavioral;