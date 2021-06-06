library ieee;
use ieee.std_logic_1164.all;
--use ieee.math_real.all;
use ieee.numeric_std.all;
use std.textio.all;

entity myhello_vga is
    generic (
	 			 d_width  : INTEGER := 4;    --width of each data word
			 size     : INTEGER := 14400);  --number of data words the memory can store

    port (
        -- inputs
        MAX10_CLK1_50 : in std_logic;
        KEY            : in std_logic_vector(1 downto 0);

        -- outputs
        LEDR   : out std_logic_vector(9 downto 0);
        VGA_R  : out std_logic_vector(3 downto 0);
        VGA_G  : out std_logic_vector(3 downto 0);
        VGA_B  : out std_logic_vector(3 downto 0);
        VGA_HS : out std_logic;
        VGA_VS : out std_logic
    );
end entity;

architecture A of myhello_vga is
    -- pixel clock
	 constant w_mem : integer := 120 ; --- 1/4 of 480
	 --constant size     : INTEGER := w_mem * w_mem ; 
	 --constant d_width	:  integer := 4;
    component pll is
        port (
            areset : in std_logic  := '0';
            inclk0 : in std_logic  := '0';
            c0     : out std_logic ;
            locked : out std_logic
        );
    end component;

    -- vga controller
    component vga_controller is
        generic (
            -- resolution
            HORIZONTAL    : integer := 640;
            VERTICAL      : integer := 480;

            -- HSYNC specs
            H_FRONT_PORCH : integer := 16;
            H_SYNC_PULSE  : integer := 96;
            H_BACK_PORCH  : integer := 48;

            -- VSYNC specs
            V_FRONT_PORCH : integer := 10;
            V_SYNC_PULSE  : integer := 2;
            V_BACK_PORCH  : integer := 33;

            -- color spec
            COLOR_BITNESS : integer := 4;
			 d_width  : INTEGER := 4;    --width of each data word
			 size     : INTEGER := 14400);  --number of data words the memory can store
        port (
            -- inputs
            nreset : in std_logic; -- synchronous reset active low
            clk    : in std_logic; -- pixel clock input

            -- outputs
            HSYNC : out std_logic; -- horizontal sync
            VSYNC : out std_logic; -- vertical sync

            RED   : out std_logic_vector(COLOR_BITNESS-1 downto 0); -- red channel
            GREEN : out std_logic_vector(COLOR_BITNESS-1 downto 0); -- green channel
            BLUE  : out std_logic_vector(COLOR_BITNESS-1 downto 0);  -- blue channel
						  --- the new ones for ram --- remember the "should be missing ;"
			 --clk      : IN   STD_LOGIC;                             --system clock
			 wr_ena   : IN   STD_LOGIC;                             --write enable
			 addr     : IN   INTEGER RANGE 0 TO size-1;             --address to write/read
			 data_in  : IN   STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);  --input data to write
			 data_out : OUT  STD_LOGIC_VECTOR(d_width-1 DOWNTO 0) --output data read		  


				);
    end component;
    
    signal reset, areset, clk, wr_ena  : std_logic;
	 signal addr : INTEGER RANGE 0 TO size-1;
	 signal  data_in, data_out : STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);
begin
    reset <= KEY(0);
    areset <= not reset;

    pixel_clock : pll
    port map (areset => areset, inclk0 => MAX10_CLK1_50, c0 => clk, locked => LEDR(0));

    vga_ctrl : vga_controller
    port map (nreset => reset, clk => clk, HSYNC => VGA_HS, VSYNC => VGA_VS,
              RED => VGA_R, GREEN => VGA_G, BLUE => VGA_B,
				  --- new ports
				   wr_ena => wr_ena, addr => addr, data_in => data_in, data_out => data_out
				  );

process --initial fill of memory
				  
file rdptr: text open read_mode is "r.txt";
variable line_rd: line;
variable a: integer;	
variable x: std_logic_vector(7 downto 0) ;

begin

	while(not endfile(rdptr)) loop
		wr_ena<= '1';
		readline(rdptr, line_rd);
		read(line_rd, a);
		x	:= std_logic_vector(to_signed(a, 8));
		data_in(0) <=  x(0);
		--wait for 10 ns;
		clk		<= '1';
		---wait for 10 ns;
		clk		<= '0';

	end loop;			  
				  
end process;	--initial fill of memory			  
				  
--	 fill_vmemory: process(clk) --may be read from file???
--  --variable RandomVal : real ;
--  --variable DataSent : integer ;
--
--	 --variable DataSent_seed1 : positive := 7 ;
--  --variable DataSent_seed2 : positive := 1 ;
--	 begin  
--			 for i in 0 to w_mem * w_mem - 1 loop
--				-- Generate a value between 0.0 and 1.0 (non-inclusive)
--				-- uniform(DataSent_seed1, DataSent_seed2, RandomVal) ;
--				-- Convert to integer in range of 0 to 255
--				--DataSent := integer(trunc(RandomVal*16.0)) ;
--				addr <= i;
--				--wait for 10 ns;
--				wr_ena <= '1';
--				--data_in <= DataSent;
--				data_in <= "1111";
--				
--			 end loop;
--	 end process;
process(clk)
begin

end process;



end architecture A;
