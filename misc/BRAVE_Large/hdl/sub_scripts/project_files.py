
def commun_files(p,sources_files_directory,option):
    p.addFile('work', sources_files_directory + '/common/common_functions_pkg.vhd')
    p.addFile('work', sources_files_directory + '/common/addr_decoder_pkg.vhd')
    p.addFile('work', sources_files_directory + '/common/compteur_addr.vhd')
    p.addFile('work', sources_files_directory + '/common/async_fifo.vhd')
    p.addFile('work', sources_files_directory + '/common/sync_fifo.vhd')

    p.addFile('work', sources_files_directory + '/axi/rtl/axi_pkg.vhd')
    p.addFile('work', sources_files_directory + '/axi/rtl/axi_master_if.vhd')
    p.addFile('work', sources_files_directory + '/axi/rtl/axi_master.vhd')
    p.addFile('work', sources_files_directory + '/axi/rtl/axi_slave_if.vhd')
    p.addFile('work', sources_files_directory + '/axi/rtl/axi_slave_err.vhd')
    p.addFile('work', sources_files_directory + '/axi/rtl/axi_demux.vhd')
    p.addFile('work', sources_files_directory + '/axi/rtl/axi_filter.vhd')
    p.addFile('work', sources_files_directory + '/axi/rtl/axi_slave.vhd')

    p.addFile('work', sources_files_directory + '/axi_interconnect_ip/rtl/axi_interconnect.vhd')
    p.addFile('work', sources_files_directory + '/axi_interconnect_ip/rtl/axi_interconnect_ip.vhd')

    p.addFile('work', sources_files_directory + '/axi_cdc_ip/rtl/axi_cdc_ip.vhd')
    p.addFile('work', sources_files_directory + '/axi_cdc_ip/rtl/axi_cdc.vhd')

    p.addFile('work', sources_files_directory + '/axi_sram_ip/rtl/sram_bus2ip.vhd')
    p.addFile('work', sources_files_directory + '/axi_sram_ip/rtl/axi_sram_ip.vhd')

    p.addFile('work', sources_files_directory + '/axi_bram_ip/rtl/bram.vhd')
    p.addFile('work', sources_files_directory + '/axi_bram_ip/rtl/bram_bus2ip.vhd')
    p.addFile('work', sources_files_directory + '/axi_bram_ip/rtl/axi_bram.vhd')
    p.addFile('work', sources_files_directory + '/axi_bram_ip/rtl/axi_bram_ip.vhd')

    p.addFile('work', sources_files_directory + '/apb/rtl/apb_pkg.vhd')
    p.addFile('work', sources_files_directory + '/apb/rtl/apb_master_if.vhd')
    p.addFile('work', sources_files_directory + '/apb/rtl/apb_slave_if.vhd')
    p.addFile('work', sources_files_directory + '/apb/rtl/apb_reg_slave.vhd')
    p.addFile('work', sources_files_directory + '/apb/rtl/apb_reg_ip.vhd')

    p.addFile('work', sources_files_directory + '/axi_apb_bridge_ip/rtl/axi_apb_ip.vhd')
    p.addFile('work', sources_files_directory + '/axi_apb_bridge_ip/rtl/axi_apb_bridge.vhd')

    p.addFile('work', sources_files_directory + '/apb_uart_ip/rtl/uart_rxtx.vhd')
    p.addFile('work', sources_files_directory + '/apb_uart_ip/rtl/uart_tx.vhd')
    p.addFile('work', sources_files_directory + '/apb_uart_ip/rtl/uart_rx.vhd')
    p.addFile('work', sources_files_directory + '/apb_uart_ip/rtl/apb_uart.vhd')
    p.addFile('work', sources_files_directory + '/apb_uart_ip/rtl/apb_uart_ip.vhd')

    # Timer IP
    p.addFile('work', sources_files_directory + '/apb_timer_ip/rtl/apb_timer.vhd')
    p.addFile('work', sources_files_directory + '/apb_timer_ip/rtl/apb_timer_ip.vhd')

    # LEDS IP
    p.addFile('work', sources_files_directory + '/apb_leds_ip/rtl/apb_leds.vhd')
    p.addFile('work', sources_files_directory + '/apb_leds_ip/rtl/apb_leds_ip.vhd')
    #p.addFile('work', sources_files_directory + '/apb_leds_ip/rtl/leds.vhd')

    # TASTE IP
    p.addFile('work', sources_files_directory + '/apb_taste_ip/rtl/adder_bambu.vhd')
    p.addFile('work', sources_files_directory + '/apb_taste_ip/rtl/apb_taste.vhd')
    p.addFile('work', sources_files_directory + '/apb_taste_ip/rtl/apb_taste_ip.vhd')

    p.addFile('work', sources_files_directory + '/ahb/rtl/ahb_reg_slave.vhd')
    p.addFile('work', sources_files_directory + '/axi_ahb_bridge_ip/rtl/axi_ahb_ip.vhd')

    p.addFile('work', sources_files_directory + '/reference_design/rtl/clkgen.vhd')
    p.addFile('work', sources_files_directory + '/reference_design/rtl/axi_system_ip.vhd')
    p.addFile('work', sources_files_directory + '/reference_design/rtl/r5_wrapper.vhd')
    p.addFile('work', sources_files_directory + '/reference_design/rtl/r5_ip.vhd')
    p.addFile('work', sources_files_directory + '/reference_design/rtl/top.vhd')

def NG_MEDIUM_files(p,sources_files_directory,option):
    commun_files(p,sources_files_directory,option)
    print("No specific Variant file")
    #p.addFiles('work',[
    #sources_files_directory + '.vhd',
    #])

def NG_LARGE_files(p,sources_files_directory,option):
    commun_files(p,sources_files_directory,option)
    print("No specific Variant file")
    #p.addFiles('work',[
    #sources_files_directory + '.vhd',
    #])

def NG_ULTRA_files(p,sources_files_directory,option):
    commun_files(p,sources_files_directory,option)
    print("No specific Variant file")
    #p.addFiles('work',[
    #sources_files_directory + '.vhd',
    #])
