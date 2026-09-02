#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h> // defines requests and arguments for open()
#include <sys/mman.h> // defines requests and arguments for mmap()
#include <unistd.h> // defines requests and arguments for close() and usleep()
#include <stdint.h>

// lw axi bus physical address and span
#define FPGA_LW_BUS_BASE 0xff200000
#define FPGA_LW_BUS_SPAN 0x00001000

// pointer to virtual memory address of lw axi bus base. type void* to match return type of mmap()
void *virtual_lw_base_ptr;


/////      PIOS       /////

// rdwr pointer to virtual memory address of led pio (set up in platform designer)
// volatile ensures intermediate reads/writes are not optimised away by the compiler
volatile unsigned int* led_pio_rd_wr_ptr = NULL;

// rdwr pointer to virtual memory address of seg pio
volatile unsigned int* seg_pio_rd_wr_ptr = NULL;

/////      UART       /////

// rd pointer to virtual memory address of RX register
volatile unsigned int* uart_rx_rd_ptr = NULL;

// wr pointer to virtual memory address of TX register
volatile unsigned int* uart_tx_wr_ptr = NULL;

// rd pointer to virtual memory address of status register
volatile unsigned int* uart_status_rd_ptr = NULL;

// wr pointer to virtual memory address of control register
volatile unsigned int* uart_control_wr_ptr = NULL;


// lw bus offset for led pio
#define FPGA_LED_RD_WR_OFFSET 0x00

//lw bus offset for seg pio
#define FPGA_SEG_RD_WR_OFFSET 0x10

//lw bus offset for uart rx, tx, status and control registers
#define FPGA_UART_RX_OFFSET 0x20
#define FPGA_UART_TX_OFFSET 0x24
#define FPGA_UART_STATUS_OFFSET 0x28
#define FPGA_UART_CONTROL_OFFSET 0x2c

// /dev/mem file id
int fd;

int main(void)
{

    if ((fd = open("/dev/mem", (O_RDWR | O_SYNC))) == -1) // bitwise OR combines flags
    {
        printf("Error: could not open \"/dev/mem\"\n");
        return 1;
    }

    virtual_lw_base_ptr = mmap(NULL, FPGA_LW_BUS_SPAN, (PROT_READ | PROT_WRITE), MAP_SHARED, fd, FPGA_LW_BUS_BASE);

    if (virtual_lw_base_ptr == MAP_FAILED) 
    {
        printf( "ERROR: lw bus mmap() failed\n");
        close(fd);
        return 1;
    }
    
    //ensures correct offset since sizeof(char) is one byte
    led_pio_rd_wr_ptr = (unsigned int *)((char *)virtual_lw_base_ptr + FPGA_LED_RD_WR_OFFSET); 
    seg_pio_rd_wr_ptr = (unsigned int *)((char *)virtual_lw_base_ptr + FPGA_SEG_RD_WR_OFFSET);

    // UART
    uart_rx_rd_ptr = (unsigned int *)((char *)virtual_lw_base_ptr + FPGA_UART_RX_OFFSET);
    uart_tx_wr_ptr = (unsigned int *)((char *)virtual_lw_base_ptr + FPGA_UART_TX_OFFSET);
    uart_status_rd_ptr = (unsigned int *)((char *)virtual_lw_base_ptr + FPGA_UART_STATUS_OFFSET);
    uart_control_wr_ptr = (unsigned int *)((char *)virtual_lw_base_ptr + FPGA_UART_CONTROL_OFFSET);


    // enable interrupts in control register
    // uart_control_wr_ptr & (1 << 6) = 1;
    // uart_control_wr_ptr & (1 << 7) = 1;

    while (1) {

        printf("STATUS = 0x%04x\n", *uart_status_rd_ptr);

        // poll the transmit ready status bit, waiting until TRDY
        while (!(*(uart_status_rd_ptr) & (1 << 6))) {
            // wait
        }

        char character;
        printf("Character :");
        scanf(" %c", &character);

        *(uart_tx_wr_ptr) = character;

        printf("STATUS = 0x%04x\n", *uart_status_rd_ptr);

        // poll the read ready status bit, waiting until RRDY
        while (!(*(uart_status_rd_ptr) & (1 << 7))) {
            // wait
        }

        printf("Received: %c\n", (char)*(uart_rx_rd_ptr));

    }
}

