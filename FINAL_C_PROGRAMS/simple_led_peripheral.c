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


// lw bus offset for custom peripheral
// bytes 00 to 03 contain DATA, bytes 04 to 08 allow control
#define FPGA_LED_DATA_OFFSET 0x60
#define FPGA_LED_CONTROL_OFFSET 0x64

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
    volatile uint32_t* const led_data_write_ptr = (uint32_t *)((uint8_t *)virtual_lw_base_ptr + FPGA_LED_DATA_OFFSET); 
    volatile uint32_t* const led_control_write_ptr = (uint32_t *)((uint8_t *)virtual_lw_base_ptr + FPGA_LED_CONTROL_OFFSET); 

    *(led_data_write_ptr) = 0x55;
    *(led_control_write_ptr) = 1;
    sleep(2);
    *(led_control_write_ptr) = 0;
    printf("value in Data Reg: 0x%04x\n", *(led_data_write_ptr));    
}