library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux_3bit_2to1 is
    Port ( 
        Sel : in STD_LOGIC;                               
        In0 : in STD_LOGIC_VECTOR(2 downto 0);            
        In1 : in STD_LOGIC_VECTOR(2 downto 0);            
        Y   : out STD_LOGIC_VECTOR(2 downto 0)            
    );
end mux_3bit_2to1;

architecture Structural of mux_3bit_2to1 is

    component MUX2To1 is
        Port (
            I1, I0, S : in std_logic;
            Y         : out std_logic 
        );
    end component;

begin

    MUX_Bit0: MUX2To1 port map(
        I1 => In1(0),
        I0 => In0(0),
        S  => Sel,
        Y  => Y(0)
    );

    MUX_Bit1: MUX2To1 port map(
        I1 => In1(1),
        I0 => In0(1),
        S  => Sel,
        Y  => Y(1)
    );

    MUX_Bit2: MUX2To1 port map(
        I1 => In1(2),
        I0 => In0(2),
        S  => Sel,
        Y  => Y(2)
    );

end Structural;