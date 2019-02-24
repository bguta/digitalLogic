library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity Clock is

	port
	(
		-- ports
		reset,setH,setM,setS,clk 	: in std_logic;
		t		: in std_logic_vector(7 downto 0);

		DIS0,DIS1,DIS2,DIS3,DIS4,DIS5 : out STD_LOGIC_VECTOR(0 to 6)		-- ports
		
	);
end Clock;

architecture a of Clock is
	signal flag : std_logic;
	signal count : std_logic_vector(28 downto 0);
	signal D3,D2,D1,D0 : std_logic_vector(3 downto 0) := "0000";
	signal D4 : std_logic_vector(3 downto 0) := "0010";
	signal D5 : std_logic_vector(3 downto 0) := "0001";
	


	function BCD2Seg(signal bcd_in : STD_LOGIC_VECTOR(3 downto 0))
	return std_logic_vector is
	begin
		case bcd_in is
			when "0000" =>
				 return"0000001";
			when "0001" =>
				 return"1001111";
			when "0010" =>
				 return"0010010";
			when "0011" =>
				 return"0000110";
			when "0100" =>
				 return"1001100";
			when "0101" =>
				 return"0100100";
			when "0110" =>
				 return"0100000";
			when "0111" =>
				 return"0001111";
			when "1000" =>
				 return"0000000";
			when "1001" =>
				 return"0000100";
			when others =>
				 return"1111111";
		end case;
	end BCD2Seg;

	begin	
		process(clk)
		begin
			if (clk'event and clk='1') then
				if count < 25000000 then
					count <= count + 1;
				else
					count <= (others => '0');
					flag <= not flag;
				end if;
			end if;
		end process;

		process(reset,flag,setS,setM,setH)
		begin
			if reset = '0' then 
				D0 <= "0000";
				D1 <= "0000";
				D2 <= "0000";
				D3 <= "0000";
				D4 <= "0010";
				D5 <= "0001";

			elsif setS = '0' then 
				D0 <= t(3 downto 0);
				D1 <=  t(7 downto 4);
			elsif setM = '0' then 
				D2 <= t(3 downto 0);
				D3 <=  t(7 downto 4);
			elsif setH = '0' then 
				D4 <= t(3 downto 0);
				D5 <=  t(7 downto 4);

			elsif (flag'event and flag='1') then
				if(D0 = 9) then
					D0 <= "0000";
					if(D1 = 5) then
						D1 <= "0000";
						if(D2 = 9) then
							D2 <= "0000";
							if(D3 = 5) then
								D3 <= "0000";							
								if(D4 = 2 and D5 = 1) then
									D4 <= "0001";
									D5 <= "0000";
								elsif(D5 = 0 and D4 = 9) then
									D4 <= "0000";
									D5 <= "0001";	
								else D4 <= D4 + 1;
								end if;
							else D3 <= D3 + 1;
							end if;
						else D2 <= D2 + 1;
						end if;
					else D1 <= D1 + 1;
					end if;
				else D0 <= D0 + 1;
				end if;
			end if;
		end process;

		process(D5,D4,D3,D2,D1,D0)
		begin
		DIS0 <= BCD2Seg(D0);
		DIS1 <= BCD2Seg(D1);
		DIS2 <= BCD2Seg(D2);
		DIS3 <= BCD2Seg(D3);
		DIS4 <= BCD2Seg(D4);
		DIS5 <= BCD2Seg(D5);
		end process;
end a;
