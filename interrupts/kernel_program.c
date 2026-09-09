#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/interrupt.h>
#include <linux/io.h>

#define UART_PHYS_BASE  0xFF200080
#define UART_SPAN       0x20

/* CPU byte offsets */
#define UART_RX         0x00
#define UART_STATUS     0x08
#define UART_CONTROL    0x0C

/* LW UART status/control bits */
#define RRDY_BIT        (1 << 7)
#define IRRDY_BIT       (1 << 7)

#define UART_IRQ        75

static void __iomem *uart_base;


/*
 * Interrupt Service Routine
 */
static irqreturn_t lw_uart_irq_handler(int irq, void *dev_id)
{
    u32 status;
    u32 rx;

    status = ioread32(uart_base + UART_STATUS);

    /*
     * Make sure this really is an RX-ready interrupt.
     */
    if (!(status & RRDY_BIT))
        return IRQ_NONE;

    /*
     * Drain RX.
     *
     * Reading RX removes the received character. Once RX is empty,
     * RRDY falls and the UART interrupt should deassert.
     */
    while (ioread32(uart_base + UART_STATUS) & RRDY_BIT) {

        rx = ioread32(uart_base + UART_RX);

        printk(KERN_INFO
               "lw_uart_irq: received 0x%02x ('%c')\n",
               rx & 0xff,
               ((rx & 0xff) >= 32 && (rx & 0xff) <= 126)
                    ? (char)(rx & 0xff)
                    : '.');
    }

    return IRQ_HANDLED;
}


static int __init lw_uart_irq_init(void)
{
    int ret;
    u32 control;

    printk(KERN_INFO "lw_uart_irq: loading\n");

    /*
     * Map LW UART 1 registers into kernel virtual address space.
     */
    uart_base = ioremap(UART_PHYS_BASE, UART_SPAN);

    if (!uart_base) {
        printk(KERN_ERR "lw_uart_irq: ioremap failed\n");
        return -ENOMEM;
    }

    printk(KERN_INFO "lw_uart_irq: mapped UART at 0x%08x\n",
           UART_PHYS_BASE);

    /*
     * Register our interrupt handler.
     */
    ret = request_irq(
        UART_IRQ,
        lw_uart_irq_handler,
        0,
        "lw_uart_irq",
        NULL
    );

    if (ret) {
        printk(KERN_ERR
               "lw_uart_irq: request_irq(%d) failed: %d\n",
               UART_IRQ, ret);

        iounmap(uart_base);
        return ret;
    }

    /*
     * Enable receive-ready interrupts in the UART itself.
     */
    control = ioread32(uart_base + UART_CONTROL);

    printk(KERN_INFO
           "lw_uart_irq: control before = 0x%08x\n",
           control);

    control |= IRRDY_BIT;

    iowrite32(control, uart_base + UART_CONTROL);

    printk(KERN_INFO
           "lw_uart_irq: control after  = 0x%08x\n",
           ioread32(uart_base + UART_CONTROL));

    printk(KERN_INFO
           "lw_uart_irq: registered IRQ %d\n",
           UART_IRQ);

    return 0;
}


static void __exit lw_uart_irq_exit(void)
{
    u32 control;

    /*
     * Disable RX interrupts before removing handler.
     */
    control = ioread32(uart_base + UART_CONTROL);
    control &= ~IRRDY_BIT;
    iowrite32(control, uart_base + UART_CONTROL);

    free_irq(UART_IRQ, NULL);
    iounmap(uart_base);

    printk(KERN_INFO "lw_uart_irq: unloaded\n");
}


module_init(lw_uart_irq_init);
module_exit(lw_uart_irq_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Bhavyaa");
MODULE_DESCRIPTION("Minimal interrupt test for Intel LW UART");
