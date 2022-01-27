-------------------------------------------------------
--! @file       uart_rx.vhd
--! @brief      RX part of UART
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
library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;


entity UART_Rx is
Generic (
   DIV_WIDTH : integer
);
Port (
   Clk          : in std_logic;
   Reset        : in std_logic;
   Enable       : in std_logic;

   Set_Divider_val : in std_logic_vector(DIV_WIDTH - 1 downto 0);

   Set_Data_7        : in std_logic;
   Set_Parity_Bit    : in std_logic;
   Set_Parity_Odd    : in std_logic;
   Set_Stop_Bit      : in std_logic;
   Set_Get_MSB_First : in std_logic;

   Idle : out std_logic;

   -- The output data: 8 bit - this is the UART receiver
   -- Data is enable when on Data_Out when Data_Out_En is high?
   -- Acknowledge the data with a pulse on Ack, which is confirmed by
   -- revoking Data_Out_En. Pulse on Ack erase error status.
   Data_Out     : out std_logic_vector(7 downto 0);
   Data_Out_En  : out std_logic := '0';
   Data_Out_Ack : in  std_logic;

   RxStart : out std_logic;

   Overflow_Error : out std_logic;
   Parity_Error   : out std_logic;
   Frame_Error    : out std_logic;

   RX    : in  std_logic
);
end UART_Rx;


architecture RTL of UART_Rx is

   component InputFilter
   generic (
      InitValue   :     std_logic                          := '0';
      Cpt_Size    :     integer range 0 to 7               := 2
   );
   Port (
      TempoFilter :     integer range 0 to (2**Cpt_Size)-1 := 1;
      sysClk      : in  std_logic;
      MasterReset : in  std_logic;
      Input       : in  std_logic;
      Output      : out STD_LOGIC
   );
   end component;

   signal Reset_Clk_Baud, Clk_baud            : std_logic;
   signal Cpt_baud, Divider_val               : std_logic_vector(DIV_WIDTH - 2 downto 0);
   signal rx_data, rx_data_0                  : std_logic;
   signal rx_bit_count                        : integer range 0 to 15;
   signal buffer_data, data_recv              : std_logic_vector(7 downto 0);
   signal parity_bit_in                       : std_logic;
   signal Data_7, Parity_Bit, Parity_Odd      : std_logic;
   signal Stop_Bit                            : std_logic;
   signal Get_MSB_First                       : std_logic;
   signal Overflow_Err, Parity_Err, Frame_Err : std_logic;
   signal Detect_Frame_Err                    : std_logic;
   signal data_final, data_en                 : std_logic;
   signal Etat1                               : integer range 0 to 9;

   signal msff : std_logic := '1';
   
begin

   ms : process(clk, reset)
   begin
      if reset = '1' then
         msff <= '1';
         rx_data <= '1';
      elsif rising_edge(clk) then
         msff <= rx;
         rx_data <= msff;
      end if;
   end process;
   
   Overflow_Error <= Overflow_Err;
   Parity_Error   <= Parity_Err;
   Frame_Error    <= Frame_Err;
   Data_Out_En    <= data_en;

   -- Génération de l'horloge série
   process(Reset_Clk_Baud, Clk)
   begin
      if Reset_Clk_Baud = '1' then
         Clk_baud <='0';
         Cpt_baud <= (others => '0');
      elsif rising_edge(clk) then
         if Cpt_baud >= Divider_val then
            Cpt_baud <= (others => '0');
            Clk_baud <= '1';
         else
            Cpt_baud <= Cpt_baud + 1;
            Clk_baud <= '0';
         end if;
      end if;
   end process;


   -- Récupération des données
   process (Reset,Clk)
   begin
      if Reset = '1' then
         Overflow_Err <= '0';
         Parity_Err   <= '0';
         Frame_Err    <= '0';
         data_en      <= '0';
         Data_Out     <= (others => '0');
      elsif rising_edge(Clk) then
         if Enable = '0' then
            data_en <= '0';
         elsif data_final = '1' then
            if Data_Out_Ack = '1' then
               Overflow_Err <= '0';
               Parity_Err   <= '0';
               Frame_Err    <= '0';
            else
               Overflow_Err <= data_en;
            end if;
            Frame_Err  <= Detect_Frame_Err;
            data_en    <= '1';
            if Data_7 = '1' then
               if Get_MSB_First = '1' then
                  Data_Out <= '0'&buffer_data(6 downto 0);					
                  Parity_Err <= (((buffer_data(0) xor buffer_data(1) xor buffer_data(2) xor buffer_data(3) xor buffer_data(4)
                                   xor buffer_data(5) xor buffer_data(6)) xor Parity_Odd) xor parity_bit_in) and Parity_Bit;
               else
                  Data_Out <= '0'&buffer_data(7 downto 1);
                  Parity_Err <= (((buffer_data(1) xor buffer_data(2) xor buffer_data(3) xor buffer_data(4) xor buffer_data(5)
                                   xor buffer_data(6) xor buffer_data(7)) xor Parity_Odd) xor parity_bit_in) and Parity_Bit;
               end if;
            else
               Data_Out <= buffer_data;
               Parity_Err <= (((buffer_data(0) xor buffer_data(1) xor buffer_data(2) xor buffer_data(3) xor buffer_data(4)
                                xor buffer_data(5) xor buffer_data(6) xor buffer_data(7)) xor Parity_Odd) xor parity_bit_in) and Parity_Bit;
            end if;
         elsif Data_Out_Ack = '1' then
            data_en      <= '0';
            Overflow_Err <= '0';
            Parity_Err   <= '0';
            Frame_Err    <= '0';
         end if;
      end if;
   end process;


   -- Gestion de la réception
   process (Reset,Clk)
   begin
      if Reset = '1' then
         Reset_Clk_Baud   <= '1';
         Etat1            <= 0;
         rx_bit_count     <= 0;
         rx_data_0        <= '0';
         Detect_Frame_Err <= '0';
         data_final       <= '0';
         buffer_data      <= (others => '0');
         data_recv        <= (others => '0');
         parity_bit_in    <= '0';
         RxStart          <= '0';
         Idle             <= '1';
      elsif rising_edge(clk) then
         rx_data_0 <= rx_data;
         case Etat1 is
            when 0 =>
               rx_bit_count     <= 0;
               Reset_Clk_Baud   <= '1';
               Detect_Frame_Err <= '0';
               data_final       <= '0';
               RxStart          <= '0';
               Idle             <= '1';
               if Enable = '1' then
                  Etat1         <= 1;
                  Data_7        <= Set_Data_7;
                  Parity_Bit    <= Set_Parity_Bit;
                  Stop_Bit      <= Set_Stop_Bit;
                  Get_MSB_First <= Set_Get_MSB_First;
                  Divider_val   <= Set_Divider_val(DIV_WIDTH - 1 downto 1) - 1;
                  Parity_Odd    <= Set_Parity_Odd;
               end if;							
            when 1 =>
               rx_bit_count <= 0;
               data_final   <= '0';
               Idle         <= '1';
               if Enable = '0' then
                  Reset_Clk_Baud <= '1';
                  RxStart        <= '0';
                  Etat1          <= 0;
               elsif (rx_data_0 and not rx_data) = '1' then
                  Reset_Clk_Baud   <= '0';
                  RxStart          <= '1';
                  Etat1            <= 2;
               else
                  RxStart        <= '0';
                  Reset_Clk_Baud <= '1';
               end if;
            when 2 =>
               Idle    <= '0';
               RxStart <= '0';
               if Clk_baud = '1' then
                  Etat1 <= 3;
               end if;
            when 3 =>
               if Clk_baud='1' then
                  if ((Data_7 = '1') and (rx_bit_count >= 7)) or ((Data_7 = '0') and (rx_bit_count >= 8)) then
                     if Parity_Bit = '1' then
                        Etat1 <= 5;
                     else
                        Etat1 <= 7;
                     end if;
                  else
                     Etat1 <= 4;
                  end if;
               end if;
            when 4 =>
               if Clk_baud = '1' then
                  rx_bit_count <= rx_bit_count + 1;
                  if Get_MSB_First = '1' then
                     data_recv <= data_recv(6 downto 0) & rx_data;
                  else
                     data_recv <= rx_data & data_recv(7 downto 1);
                  end if;
                  Etat1 <= 3;
               end if;
            when 5 =>
               if Clk_baud='1' then
                  parity_bit_in <= rx_data;
                  Etat1         <= 6;
               end if;
            when 6 =>
               if Clk_baud='1' then
                  Etat1 <= 7;
               end if;
            when 7 =>
               if Clk_baud = '1' then
                  Detect_Frame_Err <= not rx_data;
                  if Stop_Bit = '0' then
                     data_final     <= '1';
                     buffer_data    <= data_recv;
                     Etat1          <= 1;
                  else
                     Etat1 <= 8;						
                  end if;
               end if;
            when 8 =>
               if Clk_baud = '1' then
                  Etat1 <= 9;
               end if;
            when 9 =>
               if Clk_baud = '1' then
                  Detect_Frame_Err <= Detect_Frame_Err or not rx_data;
                  data_final       <= '1';
                  buffer_data      <= data_recv;
                  Etat1            <= 1;
               end if;
            when others =>
               rx_bit_count   <= 0;
               data_final     <= '0';
               Reset_Clk_Baud <= '1';
               Etat1          <= 0;
         end case;
      end if;
   end process;


end RTL;
