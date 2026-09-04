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

//lw bus offset for uart rx, tx, status and control registers
#define FPGA_UART_RX_OFFSET 0x80
#define FPGA_UART_TX_OFFSET 0x84
#define FPGA_UART_STATUS_OFFSET 0x88
#define FPGA_UART_CONTROL_OFFSET 0x8c

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

    // 32 bits since each register is 4 bytes wide

    // rd pointer to virtual memory address of RX register
    volatile const uint32_t* const uart_rx_rd_ptr = (uint32_t *)((char *)virtual_lw_base_ptr + FPGA_UART_RX_OFFSET);

    // wr pointer to virtual memory address of TX register
    volatile uint32_t* const uart_tx_wr_ptr = (uint32_t *)((char *)virtual_lw_base_ptr + FPGA_UART_TX_OFFSET);

    // rdwr pointer to virtual memory address of status register
    volatile uint32_t* const uart_status_rdwr_ptr = (uint32_t *)((char *)virtual_lw_base_ptr + FPGA_UART_STATUS_OFFSET);

    // wr pointer to virtual memory address of control register
    volatile uint32_t* const uart_control_wr_ptr = (uint32_t *)((char *)virtual_lw_base_ptr + FPGA_UART_CONTROL_OFFSET);
    

    // enable interrupts in control register
    // uart_control_wr_ptr & (1 << 6) = 1;
    // uart_control_wr_ptr & (1 << 7) = 1;

    while (1) {

        printf("STATUS = 0x%x\n", *uart_status_rdwr_ptr);
        
        // poll the read ready status bit, waiting until RRDY
        while (!(*(uart_status_rdwr_ptr) & (1 << 7))) {
            // wait
        }

        printf("STATUS = 0x%04x\n", *uart_status_rdwr_ptr);

        printf("Received: %c\n", (char)*(uart_rx_rd_ptr));

        // poll the transmit ready status bit, waiting until TRDY
        while (!(*(uart_status_rdwr_ptr) & (1 << 6))) {
            // wait
        }

        char character;
        printf("Character :");
        scanf(" %c", &character);

        *(uart_tx_wr_ptr) = character;

    }
}

