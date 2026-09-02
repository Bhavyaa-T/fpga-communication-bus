module quartus_test (

    // Clock pins
    input  logic        CLOCK_50,
    input  logic        CLOCK2_50,
    input  logic        CLOCK3_50,
    input  logic        CLOCK4_50,

    // ADC
    inout  wire         ADC_CS_N,
    output logic        ADC_DIN,
    input  logic        ADC_DOUT,
    output logic        ADC_SCLK,

    // Audio
    input  logic        AUD_ADCDAT,
    inout  wire         AUD_ADCLRCK,
    inout  wire         AUD_BCLK,
    output logic        AUD_DACDAT,
    inout  wire         AUD_DACLRCK,
    output logic        AUD_XCK,

    // FPGA-side SDRAM
    output logic [12:0] DRAM_ADDR,
    output logic [1:0]  DRAM_BA,
    output logic        DRAM_CAS_N,
    output logic        DRAM_CKE,
    output logic        DRAM_CLK,
    output logic        DRAM_CS_N,
    inout  wire  [15:0] DRAM_DQ,
    output logic        DRAM_LDQM,
    output logic        DRAM_RAS_N,
    output logic        DRAM_UDQM,
    output logic        DRAM_WE_N,

    // I2C for audio and video-input configuration
    output logic        FPGA_I2C_SCLK,
    inout  wire         FPGA_I2C_SDAT,

    // 40-pin headers
    inout  wire  [35:0] GPIO_0,
    inout  wire  [35:0] GPIO_1,

    // Seven-segment displays
    output logic [6:0]  HEX0,
    output logic [6:0]  HEX1,
    output logic [6:0]  HEX2,
    output logic [6:0]  HEX3,
    output logic [6:0]  HEX4,
    output logic [6:0]  HEX5,

    // Infrared
    input  logic        IRDA_RXD,
    output logic        IRDA_TXD,

    // Pushbuttons
    input  logic [3:0]  KEY,

    // LEDs
    output logic [9:0]  LEDR,

    // PS/2 ports
    inout  wire         PS2_CLK,
    inout  wire         PS2_DAT,
    inout  wire         PS2_CLK2,
    inout  wire         PS2_DAT2,

    // Slider switches
    input  logic [9:0]  SW,

    // Video input
    input  logic        TD_CLK27,
    input  logic [7:0]  TD_DATA,
    input  logic        TD_HS,
    output logic        TD_RESET_N,
    input  logic        TD_VS,

    // VGA
    output logic [7:0]  VGA_B,
    output logic        VGA_BLANK_N,
    output logic        VGA_CLK,
    output logic [7:0]  VGA_G,
    output logic        VGA_HS,
    output logic [7:0]  VGA_R,
    output logic        VGA_SYNC_N,
    output logic        VGA_VS,

    // HPS DDR3
    output logic [14:0] HPS_DDR3_ADDR,
    output logic [2:0]  HPS_DDR3_BA,
    output logic        HPS_DDR3_CAS_N,
    output logic        HPS_DDR3_CKE,
    output logic        HPS_DDR3_CK_N,
    output logic        HPS_DDR3_CK_P,
    output logic        HPS_DDR3_CS_N,
    output logic [3:0]  HPS_DDR3_DM,
    inout  wire  [31:0] HPS_DDR3_DQ,
    inout  wire  [3:0]  HPS_DDR3_DQS_N,
    inout  wire  [3:0]  HPS_DDR3_DQS_P,
    output logic        HPS_DDR3_ODT,
    output logic        HPS_DDR3_RAS_N,
    output logic        HPS_DDR3_RESET_N,
    input  logic        HPS_DDR3_RZQ,
    output logic        HPS_DDR3_WE_N,

    // Ethernet
    output logic        HPS_ENET_GTX_CLK,
    inout  wire         HPS_ENET_INT_N,
    output logic        HPS_ENET_MDC,
    inout  wire         HPS_ENET_MDIO,
    input  logic        HPS_ENET_RX_CLK,
    input  logic [3:0]  HPS_ENET_RX_DATA,
    input  logic        HPS_ENET_RX_DV,
    output logic [3:0]  HPS_ENET_TX_DATA,
    output logic        HPS_ENET_TX_EN,

    // Flash
    inout  wire  [3:0]  HPS_FLASH_DATA,
    output logic        HPS_FLASH_DCLK,
    output logic        HPS_FLASH_NCSO,

    // Accelerometer
    inout  wire         HPS_GSENSOR_INT,

    // General-purpose I/O
    inout  wire  [1:0]  HPS_GPIO,

    // I2C
    inout  wire         HPS_I2C_CONTROL,
    inout  wire         HPS_I2C1_SCLK,
    inout  wire         HPS_I2C1_SDAT,
    inout  wire         HPS_I2C2_SCLK,
    inout  wire         HPS_I2C2_SDAT,

    // HPS pushbutton and LED
    inout  wire         HPS_KEY,
    inout  wire         HPS_LED,

    // SD card
    output logic        HPS_SD_CLK,
    inout  wire         HPS_SD_CMD,
    inout  wire  [3:0]  HPS_SD_DATA,

    // SPI
    output logic        HPS_SPIM_CLK,
    input  logic        HPS_SPIM_MISO,
    output logic        HPS_SPIM_MOSI,
    inout  wire         HPS_SPIM_SS,

    // UART
    input  logic        HPS_UART_RX,
    output logic        HPS_UART_TX,

    // USB
    inout  wire         HPS_CONV_USB_N,
    input  logic        HPS_USB_CLKOUT,
    inout  wire  [7:0]  HPS_USB_DATA,
    input  logic        HPS_USB_DIR,
    input  logic        HPS_USB_NXT,
    output logic        HPS_USB_STP
);


	platform_designer_module instance1 (
		
		///// HPS SIDE /////
		
		// Ethernet
		.hps_io_hps_io_gpio_inst_GPIO35  (HPS_ENET_INT_N),    
		.hps_io_hps_io_emac1_inst_TX_CLK	(HPS_ENET_GTX_CLK),
		.hps_io_hps_io_emac1_inst_TXD0	(HPS_ENET_TX_DATA[0]),
		.hps_io_hps_io_emac1_inst_TXD1	(HPS_ENET_TX_DATA[1]),
		.hps_io_hps_io_emac1_inst_TXD2	(HPS_ENET_TX_DATA[2]),
		.hps_io_hps_io_emac1_inst_TXD3	(HPS_ENET_TX_DATA[3]),
		.hps_io_hps_io_emac1_inst_RXD0	(HPS_ENET_RX_DATA[0]),
		.hps_io_hps_io_emac1_inst_MDIO	(HPS_ENET_MDIO),
		.hps_io_hps_io_emac1_inst_MDC		(HPS_ENET_MDC),
		.hps_io_hps_io_emac1_inst_RX_CTL	(HPS_ENET_RX_DV),
		.hps_io_hps_io_emac1_inst_TX_CTL	(HPS_ENET_TX_EN),
		.hps_io_hps_io_emac1_inst_RX_CLK	(HPS_ENET_RX_CLK),
		.hps_io_hps_io_emac1_inst_RXD1	(HPS_ENET_RX_DATA[1]),
		.hps_io_hps_io_emac1_inst_RXD2	(HPS_ENET_RX_DATA[2]),
		.hps_io_hps_io_emac1_inst_RXD3	(HPS_ENET_RX_DATA[3]),
			
		// Flash
		.hps_io_hps_io_qspi_inst_IO0	(HPS_FLASH_DATA[0]),
		.hps_io_hps_io_qspi_inst_IO1	(HPS_FLASH_DATA[1]),
		.hps_io_hps_io_qspi_inst_IO2	(HPS_FLASH_DATA[2]),
		.hps_io_hps_io_qspi_inst_IO3	(HPS_FLASH_DATA[3]),
		.hps_io_hps_io_qspi_inst_SS0	(HPS_FLASH_NCSO),
		.hps_io_hps_io_qspi_inst_CLK	(HPS_FLASH_DCLK),
			
		// SD Card
		.hps_io_hps_io_sdio_inst_CMD	(HPS_SD_CMD),
		.hps_io_hps_io_sdio_inst_D0	(HPS_SD_DATA[0]),
		.hps_io_hps_io_sdio_inst_D1	(HPS_SD_DATA[1]),
		.hps_io_hps_io_sdio_inst_CLK	(HPS_SD_CLK),
		.hps_io_hps_io_sdio_inst_D2	(HPS_SD_DATA[2]),
		.hps_io_hps_io_sdio_inst_D3	(HPS_SD_DATA[3]),
		
		// USB
		.hps_io_hps_io_gpio_inst_GPIO09  (HPS_CONV_USB_N),
		.hps_io_hps_io_usb1_inst_D0		(HPS_USB_DATA[0]),
		.hps_io_hps_io_usb1_inst_D1		(HPS_USB_DATA[1]),
		.hps_io_hps_io_usb1_inst_D2		(HPS_USB_DATA[2]),
		.hps_io_hps_io_usb1_inst_D3		(HPS_USB_DATA[3]),
		.hps_io_hps_io_usb1_inst_D4		(HPS_USB_DATA[4]),
		.hps_io_hps_io_usb1_inst_D5		(HPS_USB_DATA[5]),
		.hps_io_hps_io_usb1_inst_D6		(HPS_USB_DATA[6]),
		.hps_io_hps_io_usb1_inst_D7		(HPS_USB_DATA[7]),
		.hps_io_hps_io_usb1_inst_CLK		(HPS_USB_CLKOUT),
		.hps_io_hps_io_usb1_inst_STP		(HPS_USB_STP),
		.hps_io_hps_io_usb1_inst_DIR		(HPS_USB_DIR),
		.hps_io_hps_io_usb1_inst_NXT		(HPS_USB_NXT),
		
		// SPI
		.hps_io_hps_io_spim1_inst_CLK		(HPS_SPIM_CLK),
		.hps_io_hps_io_spim1_inst_MOSI	(HPS_SPIM_MOSI),
		.hps_io_hps_io_spim1_inst_MISO	(HPS_SPIM_MISO),
		.hps_io_hps_io_spim1_inst_SS0		(HPS_SPIM_SS),

		// UART
		.hps_io_hps_io_uart0_inst_RX	(HPS_UART_RX),
		.hps_io_hps_io_uart0_inst_TX	(HPS_UART_TX),
		
		
		// I2C
		.hps_io_hps_io_gpio_inst_GPIO48  (HPS_I2C_CONTROL), 
		.hps_io_hps_io_i2c0_inst_SDA		(HPS_I2C1_SDAT),
		.hps_io_hps_io_i2c0_inst_SCL		(HPS_I2C1_SCLK),
		.hps_io_hps_io_i2c1_inst_SDA		(HPS_I2C2_SDAT),
		.hps_io_hps_io_i2c1_inst_SCL		(HPS_I2C2_SCLK),
		
		
		// GPIO
		.hps_io_hps_io_gpio_inst_GPIO40     (HPS_GPIO[0]),     
		.hps_io_hps_io_gpio_inst_GPIO41     (HPS_GPIO[1]),     
		
		// LED
		.hps_io_hps_io_gpio_inst_GPIO53     (HPS_LED),   
		
		// pushbutton
		.hps_io_hps_io_gpio_inst_GPIO54     (HPS_KEY),     
		
		// Accelerometer
		.hps_io_hps_io_gpio_inst_GPIO61     (HPS_GSENSOR_INT),     
		
		// DDR3 SRAM
		.memory_mem_a			(HPS_DDR3_ADDR),
		.memory_mem_ba			(HPS_DDR3_BA),
		.memory_mem_ck			(HPS_DDR3_CK_P),
		.memory_mem_ck_n		(HPS_DDR3_CK_N),
		.memory_mem_cke		(HPS_DDR3_CKE),
		.memory_mem_cs_n		(HPS_DDR3_CS_N),
		.memory_mem_ras_n		(HPS_DDR3_RAS_N),
		.memory_mem_cas_n		(HPS_DDR3_CAS_N),
		.memory_mem_we_n		(HPS_DDR3_WE_N),
		.memory_mem_reset_n	(HPS_DDR3_RESET_N),
		.memory_mem_dq			(HPS_DDR3_DQ),
		.memory_mem_dqs		(HPS_DDR3_DQS_P),
		.memory_mem_dqs_n		(HPS_DDR3_DQS_N),
		.memory_mem_odt		(HPS_DDR3_ODT),
		.memory_mem_dm			(HPS_DDR3_DM),
		.memory_oct_rzqin		(HPS_DDR3_RZQ),
		
		///// FPGA SIDE /////
		
		.system_pll_ref_clk_clk             (CLOCK_50),             //          system_pll_ref_clk.clk
		.system_pll_ref_reset_reset         (1'b0),         //        system_pll_ref_reset.reset
		
		.led_pio_external_connection_in_port  (SW),  // led_pio_external_connection.in_port
		.led_pio_external_connection_out_port (LEDR) //                            .out_port
	);
	


endmodule 