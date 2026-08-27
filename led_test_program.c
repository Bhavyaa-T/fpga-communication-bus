#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h> // defines requests and arguments for open()
#include <sys/mman.h> // defines requests and arguments for mmap()
#include <unistd.h> // defines requests and arguments for close()

// lw axi bus physical address and span
#define FPGA_LW_BUS_BASE 0xff200000
#define FPGA_LW_BUS_SPAN 0x00001000

// pointer to virtual memory address of lw axi bus base. type void* to match return type of mmap()
void *virtual_lw_base_ptr;


// write pointer to virtual memory address of led pio (set up in platform designer)
// volatile ensures intermediate writes are not optimised away by the compiler
volatile unsigned int* led_pio_write_ptr = NULL;

// lw bus offset for led pio
#define FPGA_LED_WRITE_OFFSET 0x00

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

    led_pio_write_ptr = (unsigned int *)((char *)virtual_lw_base_ptr + FPGA_LED_WRITE_OFFSET); //ensures correct offset since sizeof(char) is one byte

    while(1)
    {
        int num = 4;
        *(led_pio_write_ptr) = num;
    }

}









