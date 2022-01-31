-------------------------------------------------------
--! @file       SRAM_64WV6416.vhd
--! @brief      SRAM model
--! @author     Régis Spadotti (Scalian) 
--! @author     Michel Francis (Scalian)
--! @author     F.Manni (Cnes)
--!
--!-----------------------------------------------------------------------------------------------
--! @copyright  CNES   
--! @verbatim
--! This File is licensed as MIT license
--! Permission is hereby granted, free of charge, to any person obtaining a copy
--! of this software and associated documentation files (the "Software"), to deal
--! in the Software without restriction, including without limitation the rights
--! to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--! copies of the Software, and to permit persons to whom the Software is
--! furnished to do so, subject to the following conditions:
--! 
--! The above copyright notice and this permission notice shall be included in all
--! copies or substantial portions of the Software.
--! 
--! THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--! IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--! FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--! AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--! LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--! OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
--! SOFTWARE.
--! @endverbatim
--!
--!-----------------------------------------------------------------------------------------------
--! * Version         : V1.1
--! * Version history : 
--!    * V1 :  2021-03-08 : Scalian : Creation
--!    * V2 :  2021-05-19 : F.Manni (CNES) : 
--!                         * Improve documentation
--! 
--!-----------------------------------------------------------------------------------------------
--! File Creation date : 2021-03-08
--! Project name       : R5 reference Design
--! 
--!-----------------------------------------------------------------------------------------------
--! Softwares             :  
--!     * PC          : Linux Ubuntu 20.04LTS 
--!     * Editor      : Visual studio code 2021-05 + Eclipse 2019-12
--!     * Synthetizer : Nxmap 3.5.0.4 (29th march 2021)
--!     * P&R         : Nxmap 3.5.0.4 (29th march 2021)
--! Automatic VHDL coding :  NO 
--! 
--!-----------------------------------------------------------------------------------------------
--! @details  
--!  
--! @todo provide a detailed description and comments tag for this entity for doxygen
--!
--! Limitations : None
--!
-------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_arith.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;

entity SRAM_64WV6416 is
	generic (
		Tpwe1 : time := 8 ns;
		Taw : time := 8 ns;
		Toha : time := 2 ns;
		Taa : time := 10 ns;
		Tba : time := 6.5 ns;
		Thzb : time := 6.5 ns;
		Tsd : time := 6 ns;
		Tpwb : time := 8 ns;
		Tlzwe : time := 2 ns
		);
    Port (
		SRAM_Addr : in std_logic_vector(15 downto 0);
		SRAM_Data : inout std_logic_vector(15 downto 0);
		SRAM_CEn : in std_logic;
		SRAM_OEn : in std_logic;
		SRAM_WEn : in std_logic;
		SRAM_LBn : in std_logic;
		SRAM_UBn : in std_logic
		);
end SRAM_64WV6416;

architecture Behavioral of SRAM_64WV6416 is

type MEM_TYPE is array(2**16-1 downto 0) of std_logic_vector(SRAM_Data'range);

shared variable MEM : MEM_TYPE := (others => (others => '0'));

signal s_SRAM_Data_Out,s_Data_valid : std_logic_vector(15 downto 0);
signal s_valid_w_addr : std_logic_vector(15 downto 0):=(others => '0');
signal s_SRAM_Data_Out_L,s_SRAM_Data_Out_H,Data_Out_L,Data_Out_H : std_logic_vector(7 downto 0);
signal s_Write,s_WEn,s_Write_L,s_Write_H : std_logic:='1';
signal LBn_R,UBn_R,LBn_W,UBn_W : std_logic:='1';

begin

SRAM_Data <= (others => 'Z') when (SRAM_CEn or SRAM_OEn)='1' else s_SRAM_Data_Out;

s_SRAM_Data_Out_L <= Data_Out_L when LBn_R='0' else (others => 'Z') when LBn_R='1' else (others => 'U');
s_SRAM_Data_Out_H <= Data_Out_H when UBn_R='0' else (others => 'Z') when UBn_R='1' else (others => 'U');
s_SRAM_Data_Out <= s_SRAM_Data_Out_H&s_SRAM_Data_Out_L;

s_Write <= SRAM_WEn or SRAM_CEn;
s_Write_L <= s_WEn or LBn_W;
s_Write_H <= s_WEn or UBn_W;

process
variable timeLw : time;
begin
	if SRAM_LBn='1' then
		LBn_W <= '1';
		wait until SRAM_LBn='0';
		timeLw:=now;
		while now<(timeLw+Tpwb) loop
			wait until falling_edge(SRAM_LBn) for Tpwb;
			if now<(timeLw+Tpwb) then timeLw:=now;
			end if;
		end loop;
	else
		LBn_W <= '0';
		wait until SRAM_LBn='1';
		wait for Tlzwe;
	end if;
end process;	
	
process
variable timeUw : time;
begin
	if SRAM_UBn='1' then
		UBn_W <= '1';
		wait until SRAM_UBn='0';
		timeUw:=now;
		while now<(timeUw+Tpwb) loop
			wait until falling_edge(SRAM_UBn) for Tpwb;
			if now<(timeUw+Tpwb) then timeUw:=now;
			end if;
		end loop;
	else
		UBn_W <= '0';
		wait until SRAM_UBn='1';
		wait for Tlzwe;
	end if;
end process;	

process
variable timed : time;
begin
	s_Data_valid <= SRAM_Data;
	wait until SRAM_Data'event;
	--s_Data_valid <= (others => 'U'); -- Donnée invalide tant que pas stabilisée
	timed:=now;
	while now<(timed+Tsd) loop
		wait until SRAM_Data'event for Tsd;
		if now<(timed+Tsd) then timed:=now;
		end if;
	end loop;
end process;
	
process
variable timeLr : time;
begin
	if SRAM_LBn='1' then
		LBn_R <= '1';
		wait until SRAM_LBn='0';
		LBn_R <= 'U';
		timeLr:=now;
		while now<(timeLr+Tba) loop
			wait until falling_edge(SRAM_LBn) for Tba;
			if now<(timeLr+Tba) then timeLr:=now;
			end if;			
		end loop;
	else
		LBn_R <= '0';
		wait until SRAM_LBn='1';
		if Thzb>0 ns then wait for Thzb;
		end if;
	end if;
end process;	

process
variable timeUr : time;
begin
	if SRAM_Ubn='1' then
		UBn_R <= '1';
		wait until SRAM_Ubn='0';
		UBn_R <= 'U';
		timeUr:=now;
		while now<(timeUr+Tba) loop
			wait until falling_edge(SRAM_Ubn) for Tba;
			if now<(timeUr+Tba) then timeUr:=now;
			end if;			
		end loop;
	else
		UBn_R <= '0';
		wait until SRAM_Ubn='1';
		if Thzb>0 ns then wait for Thzb;
		end if;
	end if;
end process;	

process
variable timer,timer0,deltat : time;
begin
	Data_Out_L <= MEM(conv_integer(SRAM_Addr))(7 downto 0);
	Data_Out_H <= MEM(conv_integer(SRAM_Addr))(15 downto 8);
	wait until SRAM_Addr'event;
	timer0:=now;
	timer:=now;
	deltat:=0 ns;
	while now<(timer0+Toha) loop
		wait until SRAM_Addr'event for Toha-deltat;
		if now<(timer0+Toha) then
			timer:=now;
			deltat:=now-timer0;
		end if;
	end loop;
	
	Data_Out_L <= (others => 'U'); -- Donnée invalide tant que pas stabilisée
	Data_Out_H <= (others => 'U');
	deltat:=now-timer;
	while now<(timer+Taa) loop
		wait until SRAM_Addr'event for Taa-deltat;
		if now<(timer+Taa) then
			timer:=now;
			deltat:=0 ns;
		end if;
	end loop;
end process;	

process
variable timeaw : time;
begin
	s_valid_w_addr <= SRAM_Addr;
	wait until SRAM_Addr'event;
	timeaw:=now;
	--s_valid_w_addr <= (others => 'U'); -- Adresse invalide tant que pas stabilitsée
	while now<(timeaw+Taw) loop
		wait until SRAM_Addr'event for Taw;
		if now<(timeaw+Taw) then timeaw:=now;
		end if;
	end loop;
end process;

process
variable timew : time;
begin
	if s_Write='1' then
		s_WEn <= '1';
		wait until s_Write='0';
		timew:=now+Tpwe1;
		wait until rising_edge(s_Write) for Tpwe1;
		if (now>=timew) and (s_Write='0') then s_WEn <= '0';
		end if;
	else
		s_WEn <= '0';
		wait until s_Write='1';
	end if;
end process;

process
begin
	if s_Write_L='0' then
		wait until rising_edge(s_Write_L);
		MEM(conv_integer(s_valid_w_addr))(7 downto 0) := s_Data_valid(7 downto 0);
	else wait until s_Write_L='0';
	end if;
end process;

process
begin
	if s_Write_H='0' then
		wait until rising_edge(s_Write_H);
		MEM(conv_integer(s_valid_w_addr))(15 downto 8) := s_Data_valid(15 downto 8);
	else wait until s_Write_H='0';
	end if;
end process;

end Behavioral;
