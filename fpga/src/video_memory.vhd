-- asynchronous video memory
library IEEE;
use IEEE.std_logic_1164.all;
--use IEEE.std_logic_arith.all; --very bad reputation!!!
use IEEE.std_logic_unsigned.all;
use IEEE.math_real.all;
use work.utils.all;
use IEEE.numeric_std.all;


entity video_memory is
    generic (
        -- resolution
        HORIZONTAL    : integer := 640;
        VERTICAL      : integer := 480;

        -- color spec
        COLOR_BITNESS : integer := 4;

        -- address width
        H_ADDR_WIDTH : integer;
        V_ADDR_WIDTH : integer;
		  ---- the new
		  -- w_mem : integer := 120 ; --- 1/4 of 480
		  d_width  : INTEGER := 4;    --width of each data word
		  size     : INTEGER := 3600 -- =w_mem * w_mem  --number of data words the memory can store
		  
    );
    port (
        -- pixel address inputs
        col_addr : in std_logic_vector(H_ADDR_WIDTH-1 downto 0);
        row_addr : in std_logic_vector(V_ADDR_WIDTH-1 downto 0);
        
        -- outputs
        RED   : out std_logic_vector(COLOR_BITNESS-1 downto 0); -- red channel
        GREEN : out std_logic_vector(COLOR_BITNESS-1 downto 0); -- green channel
        BLUE  : out std_logic_vector(COLOR_BITNESS-1 downto 0);  -- blue channel
		  
		  --- the new ones for ram --- remember the "should be missing ;"
			 clk      : IN   STD_LOGIC;                             --system clock
			 wr_ena   : IN   STD_LOGIC;                             --write enable
			 addr     : IN   INTEGER RANGE 0 TO size-1;             --address to write/read
			 data_in  : IN   STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);  --input data to write
			 data_out : buffer  STD_LOGIC_VECTOR(d_width-1 DOWNTO 0) --output data read		  
    );
end entity;

architecture A of video_memory is
    --- constant w : integer := integer(floor(real(VERTICAL)/2.0));
	 constant w_mem : integer := 60 ;
	 -- constant size     : INTEGER := w_mem * w_mem ;
	 --- constant d_width  : INTEGER := 4;
	 component ram IS
		  GENERIC(
			 d_width  : INTEGER := 4;    --width of each data word
			 size     : INTEGER := 3600);  --number of data words the memory can store
		  PORT(
			 clk      : IN   STD_LOGIC;                             --system clock
			 wr_ena   : IN   STD_LOGIC;                             --write enable
			 addr     : IN   INTEGER RANGE 0 TO size-1;             --address to write/read
			 data_in  : IN   STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);  --input data to write
			 data_out : buffer  STD_LOGIC_VECTOR(d_width-1 DOWNTO 0)); --output data read
END component;
    signal reset, areset  : std_logic;
	 signal maddr : INTEGER RANGE 0 TO size-1;
	 --signal  mdata_in, mdata_out : STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);
for for_ram: ram use entity  work.ram(logic);
begin
for_ram: ram port map (addr => maddr, data_out => data_out, clk => clk, wr_ena => wr_ena,
	data_in => data_in );

    scan_screen: process (col_addr, row_addr, data_in, clk, wr_ena, data_out, maddr)
        variable r, g, b: std_logic_vector(COLOR_BITNESS-1 downto 0);
		  variable tmp : integer;
    begin
        if (col_addr < w_mem ) then
				if (row_addr < w_mem) then -- 1
				--- Now the first hard case! here it's easy!
					tmp := to_integer(unsigned(row_addr)) * w_mem + 
					to_integer(unsigned(col_addr));
					maddr <= tmp;
					--wr_ena <= '0';
					r := (others => data_out(0));
					g := (others => data_out(1));
					b := (others => data_out(2));
					--r := (others => '1');
					--g := (others => '0');
					--b := (others => '0');
				elsif (row_addr < 2 * w_mem) then -- 2
					--r := (others => '1');
					r := "0111";
					g := (others => '1');
					b := (others => '0');				
				elsif (row_addr < 3 * w_mem) then -- 3
				--- Now the first hard case! alike case 1
					tmp := (to_integer(unsigned(row_addr)) - 2 * w_mem) * w_mem + 
					to_integer(unsigned(col_addr));
					maddr <= tmp;
					--wr_ena <= '0';
					
					r := (others => data_out(0));
					g := (others => data_out(1));
					b := (others => data_out(2));
				elsif (row_addr < 4 * w_mem) then -- 4
					r := (others => '1');
					g := (others => '1');
					b := (others => '1');			
				else
					r := (others => '0');
					g := (others => '0');
					b := (others => '0');			  

			   end if;	
			  elsif (col_addr < 2 * w_mem) then 
				if (row_addr < w_mem) then  -- 5
					r := (others => '1');
					g := (others => '0');
					b := (others => '1');
				elsif (row_addr < 2 * w_mem) then -- 6
					r := (others => '1');
					g := (others => '1');
					b := (others => '1');				
				elsif (row_addr < 3 * w_mem) then -- 7
					r := (others => '0');
					g := (others => '1');
					b := (others => '0');				
				elsif (row_addr < 4 * w_mem) then -- 8
					r := (others => '0');
					g := (others => '1');
					b := (others => '1');
				else
					r := (others => '0');
					g := (others => '0');
					b := (others => '0');			  
				
			   end if;	
			  
			  elsif (col_addr < 3 * w_mem) then
				if (row_addr < w_mem) then -- 9
					r := (others => '0');
					g := (others => '0');
					b := (others => '1');
				elsif (row_addr < 2 * w_mem) then -- 10
					r := (others => '0');
					g := (others => '1');
					b := (others => '1');				
				elsif (row_addr < 3 * w_mem) then -- 11
					r := (others => '0');
					g := (others => '0');
					b := (others => '1');				
				elsif (row_addr < 4* w_mem) then -- 12
					r := (others => '1');
					g := (others => '0');
					b := (others => '1');
	         else
					r := (others => '0');
					g := (others => '0');
					b := (others => '0');			  
			
			   end if;	
			  elsif (col_addr < 4 * w_mem) then
				if (row_addr < w_mem) then -- 13
					r := (others => '1');
					g := (others => '0');
					b := (others => '1');
				elsif (row_addr < 2 * w_mem) then  -- 14
					r := (others => '1');
					g := (others => '1');
					b := (others => '1');				
				elsif (row_addr < 3 * w_mem) then  -- 15
					r := (others => '0');
					g := (others => '1');
					b := (others => '0');				
				elsif (row_addr < 4 * w_mem) then --- 16
					r := (others => '0');
					g := (others => '1');
					b := (others => '1');			
				else
					r := (others => '0');
					g := (others => '0');
					b := (others => '0');			  
				
			   end if;	
			   
			  elsif (col_addr >= 240) then
            r := (others => '0');
            g := (others => '0');
            b := (others => '0');			  
        end if;
        RED <= r;
        GREEN <= g;
        BLUE <= b;
    end process;
end architecture A;
