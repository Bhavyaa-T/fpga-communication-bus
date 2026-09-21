#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>    // defines requests and arguments for open()
#include <sys/mman.h> // defines requests and arguments for mmap()
#include <unistd.h>   // defines requests and arguments for close() and usleep()
#include <stdint.h>   // defines uint types

// lw axi bus physical address and span
#define FPGA_LW_BUS_BASE 0xff200000
#define FPGA_LW_BUS_SPAN 0x00001000

// lw bus offset for led pio
#define FPGA_PIO_OFFSET 0x00

int main(void) {
    int fd = open("/dev/mem", O_RDWR | O_SYNC);
    if (fd == -1) {
        printf("Error: could not open \"/dev/mem\"\n");
        return 1;
    }

    void *virtual_lw_base_ptr = mmap(NULL, FPGA_LW_BUS_SPAN,
        PROT_READ | PROT_WRITE, MAP_SHARED, fd, FPGA_LW_BUS_BASE);
        
    if (virtual_lw_base_ptr == MAP_FAILED) {
        printf("ERROR: lw bus mmap() failed\n");
        close(fd);
        return 1;
    }

    // volatile ensures intermediate reads are not optimised away by the compiler;
    // casting to uint8_t ensures the offset is interpreted in bytes
    volatile uint32_t *const pio_rdwr_ptr =
        (uint32_t *)((uint8_t *)virtual_lw_base_ptr + FPGA_PIO_OFFSET);

    while (1) {
        int command;
        printf("Command :");
        if (scanf("%d", &command) != 1) {
            // not a number: discard the bad input up to the next newline
            // so it doesn't get re-read forever, and re-prompt
            int c;
            while ((c = getchar()) != '\n' && c != EOF);
            printf("Invalid input, please enter a number.\n");
            continue;
        }
        *(pio_rdwr_ptr) = command;
        printf("%i\n", *(pio_rdwr_ptr));
    }
}