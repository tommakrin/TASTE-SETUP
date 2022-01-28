-------------------------------------------------------
--! @file       uart_tx.vhd
--! @brief      TX part of UART IP
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

entity UART_Tx is
Generic (
   DIV_WIDTH : integer
);
Port (
   Clk          : in std_logic;
   Reset        : in std_logic;
   Enable       : in std_logic;

   Set_Divider_val : in std_logic_vector(DIV_WIDTH - 1 downto 0);

   Set_Data_7         : in std_logic;
   Set_Parity_Bit     : in std_logic;
   Set_Parity_Odd     : in std_logic;
   Set_Stop_Bit       : in std_logic;
   Set_Send_MSB_First : in std_logic;

   Idle : out std_logic;

   -- The input data: 8 bit - this is the UART sender
   -- Provide data on Data_In and set In_W to high
   Data_In    : in  std_logic_vector(7 downto 0);
   Data_In_W  : in  std_logic;
   Data_W_En  : out std_logic;
   Data_empty : out std_logic;

   TxEnd : out std_logic;

   TX : out std_logic
);
end UART_Tx;

architecture RTL of UART_Tx is

   signal Reset_Clk_Baud, Clk_baud     : std_logic;
   signal Cpt_baud, Divider_val        : std_logic_vector(DIV_WIDTH - 1 downto 0);
   signal tx_data                      : std_logic;
   signal tx_bit_count                 : integer range 0 to 15;
   signal data_send, buffer_data       : std_logic_vector(7 downto 0);
   signal data_avaible, data_get       : std_logic;
   signal parity_bit_out               : std_logic;
   signal Empty, data_w                : std_logic;
   signal Data_7, Parity_Bit, Stop_Bit : std_logic;
   signal Send_MSB_First               : std_logic;
   signal Parity_Odd                   : std_logic;
   signal Etat1                        : integer range 0 to 6;


begin

   TX <= tx_data;
   Data_empty <= Empty and data_w;
   Data_W_En <= data_w and Enable;

   -- Génération de l'horloge série
   process(Reset_Clk_Baud,Clk)
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


   -- Gestion des données d'entrée
   process (Reset,Clk)
   begin
      if Reset='1' then
         data_w <= '1';
         data_avaible <= '0';
         buffer_data <= (others => '0');
      elsif rising_edge(Clk) then
         if data_get='1' then
            if (Data_In_W and data_w and Enable)='1'  then
               buffer_data <= Data_In;
               data_avaible <= '1';
               data_w <= '0';
            else
               data_avaible <= '0';
               data_w <= '1';
            end if;
         elsif (Data_In_W and data_w and Enable)='1'  then
            buffer_data <= Data_In;
            data_avaible <= '1';
            data_w <= '0';
         end if;
      end if;
   end process;


   -- Gestion de l'émission
   process (Reset,Clk)
   begin
      if Reset='1' then
         Reset_Clk_Baud <= '1';
         tx_data        <= '1';
         Etat1          <= 0;
         tx_bit_count   <= 0;
         data_get       <= '0';
         Empty          <= '1';
         data_send      <= (others => '0');
         TxEnd          <= '0';
         Idle           <= '1';
      elsif rising_edge(clk) then
         case Etat1 is
            when 0 =>
               tx_bit_count   <= 0;
               tx_data        <= '1';
               Reset_Clk_Baud <= '1';
               Empty          <= '1';
               data_get       <= '0';
               TxEnd          <= '0';
               Idle           <= '1';
               if Enable = '1' then
                  Etat1          <= 1;
                  Data_7         <= Set_Data_7;
                  Parity_Bit     <= Set_Parity_Bit;
                  Stop_Bit       <= Set_Stop_Bit;
                  Send_MSB_First <= Set_Send_MSB_First;
                  Divider_val    <= Set_Divider_val - 1;
                  Parity_Odd     <= Set_Parity_Odd;
               end if;
            when 1 =>
               tx_bit_count <= 0;
               tx_data      <= '1';
               TxEnd        <= '0';
               if Enable = '0' then
                  Reset_Clk_Baud <= '1';
                  Empty          <= '1';
                  data_get       <= '1';
                  Idle           <= '1';
                  Etat1          <= 0;
               elsif data_avaible='1' then
                  if Data_7='1' then
                     if Send_MSB_First='1' then
                        data_send <= buffer_data(6 downto 0)&'0';
                     else
                        data_send <= '0'&buffer_data(6 downto 0);
                     end if;
                     parity_bit_out <= (buffer_data(0) xor buffer_data(1) xor buffer_data(2) xor buffer_data(3)
                                        xor buffer_data(4) xor buffer_data(5) xor buffer_data(6)) xor Parity_Odd;
                  else
                     data_send <= buffer_data;
                     parity_bit_out <= (buffer_data(0) xor buffer_data(1) xor buffer_data(2) xor
                                        buffer_data(3) xor buffer_data(4) xor buffer_data(5) xor
                                        buffer_data(6) xor buffer_data(7)) xor Parity_Odd;
                  end if;
                  Reset_Clk_Baud <= '0';
                  Empty          <= '0';
                  Idle           <= '0';
                  data_get       <= '1';
                  Etat1          <= 2;
               else
                  Reset_Clk_Baud <= '1';
                  Empty <= '1';
                  data_get <= '0';
                  Idle <= '1';
               end if;
            when 2 =>
               TxEnd <= '0';
               if Enable='0' then
                  Reset_Clk_Baud <= '1';
                  Empty <= '1';
                  data_get <= '1';
                  Etat1 <= 0;
               elsif Clk_baud='1' then
                  data_get <= '0';
                  Etat1 <= 3;
                  tx_bit_count <= tx_bit_count + 1;
                  if Send_MSB_First='1' then
                     tx_data <= data_send(7);
                     data_send <= data_send(6 downto 0)&'0';
                  else
                     tx_data <= data_send(0);
                     data_send <= '0'&data_send(7 downto 1);
                  end if;
               else
                  tx_data <= '0';
                  data_get <= '0';
               end if;
            when 3 =>
               if Enable='0' then
                  Reset_Clk_Baud <= '1';
                  Empty <= '1';
                  data_get <= '1';
                  Etat1 <= 0;
               elsif Clk_baud='1' then
                  if ((Data_7='1') and (tx_bit_count>=7)) or ((Data_7='0') and (tx_bit_count>=8)) then
                     if Parity_Bit='1' then
                        tx_data <= parity_bit_out;
                        Etat1 <= 4;
                     else
                        tx_data <= '1';
                        Etat1 <= 5;
                     end if;
                  else
                     tx_bit_count <= tx_bit_count + 1;
                     if Send_MSB_First='1' then
                        tx_data <= data_send(7);
                        data_send <= data_send(6 downto 0)&'0';
                     else
                        tx_data <= data_send(0);
                        data_send <= '0'&data_send(7 downto 1);
                     end if;
                  end if;
               end if;
            when 4 =>
               if Enable='0' then
                  Reset_Clk_Baud <= '1';
                  Empty <= '1';
                  data_get <= '1';
                  Etat1 <= 0;
               elsif Clk_baud='1' then
                  tx_data <= '1';
                  Etat1 <= 5;
               end if;
            when 5 =>
               if Enable='0' then
                  Reset_Clk_Baud <= '1';
                  Empty <= '1';
                  data_get <= '1';
                  Etat1 <= 0;
               elsif Clk_baud='1' then
                  if Stop_Bit='1' then
                     tx_data <= '1';
                     Etat1 <= 6;
                  elsif data_avaible='1' then
                     tx_bit_count <= 0;
                     if Data_7='1' then
                        if Send_MSB_First='1' then
                           data_send <= buffer_data(6 downto 0)&'0';
                        else
                           data_send <= '0'&buffer_data(6 downto 0);
                        end if;
                        parity_bit_out <= (buffer_data(0) xor buffer_data(1) xor buffer_data(2) xor buffer_data(3)
                                           xor buffer_data(4) xor buffer_data(5) xor buffer_data(6)) xor Parity_Odd;
                     else
                        data_send <= buffer_data;
                        parity_bit_out <= (buffer_data(0) xor buffer_data(1) xor buffer_data(2) xor buffer_data(3)
                                           xor buffer_data(4) xor buffer_data(5) xor buffer_data(6) xor buffer_data(7)) xor Parity_Odd;
                     end if;
                     data_get <= '1';
                     tx_data <= '0';
                     TxEnd <= '1';
                     Etat1 <= 2;
                  else
                     tx_data <= '1';
                     TxEnd <= '1';
                     Etat1 <= 1;
                  end if;
               else
                  tx_data <= '1';
               end if;
            when 6 =>
               if Enable='0' then
                  Reset_Clk_Baud <= '1';
                  Empty <= '1';
                  data_get <= '1';
                  Etat1 <= 0;
               elsif Clk_baud='1' then
                  if data_avaible='1' then
                     tx_bit_count <= 0;
                     if Data_7='1' then
                        if Send_MSB_First='1' then
                           data_send <= buffer_data(6 downto 0)&'0';
                        else
                           data_send <= '0'&buffer_data(6 downto 0);
                        end if;
                        parity_bit_out <= (buffer_data(0) xor buffer_data(1) xor buffer_data(2) xor buffer_data(3)
                                           xor buffer_data(4) xor buffer_data(5) xor buffer_data(6)) xor Parity_Odd;
                     else
                        data_send <= buffer_data;
                        parity_bit_out <= (buffer_data(0) xor buffer_data(1) xor buffer_data(2) xor buffer_data(3)
                                           xor buffer_data(4) xor buffer_data(5) xor buffer_data(6) xor buffer_data(7)) xor Parity_Odd;
                     end if;
                     data_get   <= '1';
                     tx_data    <= '0';
                     TxEnd      <= '1';
                     Etat1      <= 2;
                  else
                     tx_data  <= '1';
                     TxEnd    <= '1';
                     Etat1    <= 1;
                  end if;
               else
                  tx_data <= '1';
               end if;
            when others =>
               Reset_Clk_Baud <= '1';
               tx_bit_count   <= 0;
               tx_data        <= '1';
               Empty          <= '0';
               data_get       <= '0';
               Etat1          <= 0;
         end case;
      end if;
   end process;


end RTL;
