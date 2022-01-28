-------------------------------------------------------
--! @file       apb_taste.vhd
--! @brief      PoC APB interface to a simple TASTE IP
--! @author     Thomas Makryniotis (ESA) 
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
use ieee.numeric_std.all;

use work.ApbPkg.all;

entity apb_taste is
  port (
    pclk : in std_logic;
    presetn : in std_logic;

    s_apb_master : in ApbMasterType;
    s_apb_slave : out ApbSlaveType;

    LEDS_N_O : out std_logic;

    DBGDONE : out std_logic;
    DONEBLDBG : out std_logic;
    STARTDBG : out std_logic
  );
end apb_taste;

architecture struct of apb_taste is

  type state is (IDLE,
    WORKING,
    FIN);

  signal current_state, next_state : state;

  -- register index
  constant START : integer := 0;
  constant INPUT0 : integer := 1;
  constant INPUT1 : integer := 2;
  constant OUTPUT0 : integer := 3;
  constant OUTPUT1 : integer := 4;
  constant DONE : integer := 5;
  constant TEST : integer := 6;

  signal int_start : std_logic;
  signal start_reg : std_logic; -- Register for incoming start signal

  signal int_done, reg_done : std_logic; -- Internal done and registered done signals. The latter one is software accessible.

  signal inp0_reg_d, inp0_reg_q : std_logic_vector(31 downto 0);
  signal inp1_reg_d, inp1_reg_q : std_logic_vector(31 downto 0);

  signal outp_reg_d, outp_reg_q : std_logic_vector(63 downto 0);
  signal int_outp : std_logic_vector(63 downto 0);  

  signal led_reg_d, led_reg_q : std_logic; -- Test led, to be used to see whether IP is alive

  signal equals : std_logic;

  signal swreset : std_logic;

begin --Begin architecture 'struct'

  bambu_inst : entity work.adder_bambu
    port map(
      inp => X"00000000" & inp0_reg_q,
      outp => int_outp,
      start_adder => int_start,
      finish_adder => int_done,
      clock_adder => pclk,
      reset_adder => presetn
    );

  -- Split the following process into two processes, one solely for the registers
  -- and one for the combinational logic
  proc_apb_access : process (all)
  begin

    if presetn = '0' then
      s_apb_slave <= C_APB_SLAVE_INIT;

    elsif rising_edge(pclk) then

      -- Begin default assignments
      inp0_reg_d <= inp0_reg_q;
      inp1_reg_d <= inp1_reg_q;
      led_reg_d <= led_reg_q;
      start_reg <= '0';

      s_apb_slave.pready <= '0';
      s_apb_slave.pslverr <= '0';
      s_apb_slave.prdata <= (others => '0');

      if (s_apb_master.psel and s_apb_master.penable) then
        s_apb_slave.pready <= '1';

        -- Write
        if (s_apb_master.pwrite) = '1' then
          case to_integer(unsigned(s_apb_master.paddr(5 downto 2))) is
            when START =>
              start_reg <= s_apb_master.pwdata(0);
            when INPUT0 =>
              inp0_reg_d <= s_apb_master.pwdata;
            when INPUT1 =>
              inp1_reg_d <= s_apb_master.pwdata;
            when TEST =>
              led_reg_d <= s_apb_master.pwdata(0);
            when others =>
              s_apb_slave.pslverr <= '1';
          end case;
        else
          --Read
          case to_integer(unsigned(s_apb_master.paddr(5 downto 2))) is
            when START =>
              s_apb_slave.prdata <= X"000000" & "0000000" & start_reg; -- Doesn't work but will fix it
            when INPUT0 =>
              s_apb_slave.prdata <= inp0_reg_q;
            when INPUT1 =>
              s_apb_slave.prdata <= inp1_reg_q;
            when OUTPUT0 =>
              s_apb_slave.prdata <= outp_reg_q(31 downto 0);
            when OUTPUT1 =>
              s_apb_slave.prdata <= outp_reg_q(63 downto 32);
            when DONE =>
              s_apb_slave.prdata <= X"000000" & "0000000" & reg_done;
            when TEST =>
              s_apb_slave.prdata <= X"0000000" & "000" & led_reg_q;
            when others =>
              s_apb_slave.pslverr <= '1';
          end case;
        end if;
      end if;
    end if;
  end process;

  --! Next state logic
  process (presetn, pclk)
  begin
    if (presetn = '0') then
      current_state <= IDLE;
    elsif (rising_edge(pclk)) then
      current_state <= next_state;
    end if;
  end process;

  --! Current state logic
  process (all)
  begin

    next_state <= current_state;

    case current_state is

      when IDLE =>
        if (start_reg = '1' and int_done = '0') then
          next_state <= WORKING;
        end if;

      when WORKING =>
        if (int_done = '1') then
          next_state <= FIN;
        end if;

      when FIN =>
        -- We are here because of int_done. But now it's off again, so we need to keep it in a register.
        reg_done <= '1';
        outp_reg_d <= int_outp;
        if (int_start = '1') then
          reg_done <= '0';
          next_state <= WORKING;
        end if;

    end case;

  end process;

  --! Start register process
  start_reg_proc : process (presetn, pclk)
  begin
    if presetn = '0' then
      int_start <= '0';
    elsif rising_edge(pclk) then
      int_start <= start_reg;
      if (int_start = '1' and start_reg = '1') then
        int_start <= '0';
      end if;

    end if;
  end process;

  proc_reg : process (pclk, presetn)
  begin
    if presetn = '0' then
      inp0_reg_q <= X"00000000";
      inp1_reg_q <= X"00000000";
      outp_reg_q <= X"0000000000000000";
      led_reg_q <= '1';
    elsif rising_edge(pclk) then
      inp0_reg_q <= inp0_reg_d;
      inp1_reg_q <= inp1_reg_d;
      outp_reg_q <= outp_reg_d;
      led_reg_q <= led_reg_d;
    end if;
  end process;

  -- Debug process
  eq_proc : process (all)
  begin
    if presetn = '0' then
      equals <= '0';
    elsif rising_edge(pclk) then
      if(reg_done = '1') then
        if((X"00000000" & inp0_reg_q) = int_outp) then
          equals <= '1';
        else
          equals <= '0';
        end if;
      end if;
    end if;
  end process;

  LEDS_N_O <= led_reg_q;
  DBGDONE <= reg_done;
  DONEBLDBG <= equals;
  STARTDBG <= int_start;

end struct;