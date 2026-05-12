#include <stdint.h>

/* ============================================================
 * MAPA DE MEMÓRIA DOS PERIFÉRICOS
 * ============================================================ */

 /* ---------------- GPIO ---------------- */
#define GPIO_BASE       0x10000000
#define GPIO_OUT        (*(volatile uint32_t*)(GPIO_BASE + 0x00))

/* ---------------- UART ---------------- */
#define UART_BASE       0x20000000

#define UART_TXDATA     (*(volatile uint32_t*)(UART_BASE + 0x00))
#define UART_RXDATA     (*(volatile uint32_t*)(UART_BASE + 0x04))
#define UART_STATUS     (*(volatile uint32_t*)(UART_BASE + 0x08))

#define UART_STATUS_TX_READY   0x01
#define UART_STATUS_RX_VALID   0x02

/* ---------------- SPI ---------------- */
#define SPI_BASE        0x30000000

#define SPI_DATA        (*(volatile uint32_t*)(SPI_BASE + 0x00))
#define SPI_STATUS      (*(volatile uint32_t*)(SPI_BASE + 0x04))

#define SPI_STATUS_BUSY 0x01


/* ---------------- I2C (AXI) ---------------- */
#define AXI_I2C_BASE    0x40000000
#define I2C_REG         (*(volatile uint32_t*)(AXI_I2C_BASE + 0x08))


/* ---------------- TIMER ---------------- */
#define TIMER_BASE      0x50000000

#define TIMER_CONTROL   (*(volatile uint32_t*)(TIMER_BASE + 0x00))
#define TIMER_RELOAD    (*(volatile uint32_t*)(TIMER_BASE + 0x04))
#define TIMER_STATUS    (*(volatile uint32_t*)(TIMER_BASE + 0x08))

#define TIMER_ENABLE    0x01
#define TIMER_STOP      0x02
#define TIMER_DONE      0x01

/* ---------------- mnist ---------------- */
#define MNIST_BASE          0x60000000

#define MNIST_CONTROL       (*(volatile uint32_t*)(MNIST_BASE + 0x00))
#define MNIST_STATUS        (*(volatile uint32_t*)(MNIST_BASE + 0x04))
#define MNIST_RESULT        (*(volatile uint32_t*)(MNIST_BASE + 0x08))

#define MNIST_CFG_NEURON    (*(volatile uint32_t*)(MNIST_BASE + 0x10))
#define MNIST_CFG_ADDR      (*(volatile uint32_t*)(MNIST_BASE + 0x14))
#define MNIST_CFG_WEIGHT    (*(volatile uint32_t*)(MNIST_BASE + 0x18))
#define MNIST_CFG_IS_BIAS   (*(volatile uint32_t*)(MNIST_BASE + 0x1C))

#define MNIST_PIXEL_DATA    (*(volatile uint32_t*)(MNIST_BASE + 0x20))
#define MNIST_PIXEL_LAST    (*(volatile uint32_t*)(MNIST_BASE + 0x24))


/* ============================================================
 * DRIVERS - UART
 * ============================================================ */

/**
 * Envia 1 caractere via UART (bloqueante).
 */
void uart_putc(char c)
{
    while (!(UART_STATUS & UART_STATUS_TX_READY));
    UART_TXDATA = (uint32_t)c;
}

/**
 * Envia string terminada em '\0'.
 */
void uart_print(const char *s)
{
    while (*s)
        uart_putc(*s++);
}

/**
 * Recebe 1 caractere via UART (bloqueante).
 */
char uart_getc(void)
{
    while (!(UART_STATUS & UART_STATUS_RX_VALID));
    return (char)(UART_RXDATA & 0xFF);
}


/* ============================================================
 * DRIVERS - SPI
 * ============================================================ */

/**
 * Envia 1 byte via SPI (bloqueante).
 */
void spi_send(uint8_t byte)
{
    while (SPI_STATUS & SPI_STATUS_BUSY);
    SPI_DATA = byte;
}

/**
 * Envia múltiplos bytes via SPI.
 */
void spi_send_bytes(const uint8_t *buffer, int length)
{
    for (int i = 0; i < length; i++)
        spi_send(buffer[i]);
}

void mnist_write_weight(
    uint32_t neuron,
    uint32_t addr,
    uint32_t value
)
{
    MNIST_CFG_NEURON  = neuron;
    MNIST_CFG_ADDR    = addr;
    MNIST_CFG_WEIGHT  = value;
    MNIST_CFG_IS_BIAS = 0;

    MNIST_CONTROL = 1;
}

void mnist_write_bias(
    uint32_t neuron,
    uint32_t value
)
{
    MNIST_CFG_NEURON  = neuron;
    MNIST_CFG_ADDR    = 0;
    MNIST_CFG_WEIGHT  = value;
    MNIST_CFG_IS_BIAS = 1;

    MNIST_CONTROL = 1;
}

void mnist_send_pixel(
    uint32_t pixel,
    uint32_t last
)
{
    MNIST_PIXEL_DATA = pixel;
    MNIST_PIXEL_LAST = last;
}

uint32_t mnist_run(void)
{
    MNIST_CONTROL = 2; // start

    while (!(MNIST_STATUS & 1));

    return MNIST_RESULT;
}


/* ============================================================
 * APLICAÇÃO PRINCIPAL
 * ============================================================ */

int main(void)
{
    uart_print("SOC IOT PICORV32");

    while (1)
    {
        char c = uart_getc();

        switch (c)
        {
            /* ------------------------------------------------ */
            case 'A':
                GPIO_OUT = 0xA;
                break;

            /* ------------------------------------------------ */
            case 'B':
            {
                GPIO_OUT = 0x5;

                uint8_t data[] = {
                    0x67, 0x6F, 0x6F, 0x64, 0x20,
                    0x6D, 0x6F, 0x72, 0x6E, 0x69,
                    0x6E, 0x67, 0x20, 0x77, 0x6F,
                    0x72, 0x6C, 0x64
                };

                spi_send_bytes(data, 18);
                break;
            }

            /* ------------------------------------------------ */
            case 'C':
            {
                GPIO_OUT = 0x8;

                uint8_t addr = (0x50 << 1);  // I2C write

                I2C_REG = (addr << 8) | 0x11;
                I2C_REG = (addr << 8) | 0x22;
                I2C_REG = (addr << 8) | 0x33;

                break;
            }

            /* ------------------------------------------------ */
            case 'D':
                GPIO_OUT = 0xF;
                uart_print("DD\n");
                break;

            /* ------------------------------------------------ */
            case 'E':
                GPIO_OUT = 0x1;

                TIMER_RELOAD  = 5000;
                TIMER_CONTROL = TIMER_ENABLE;

                while (!(TIMER_STATUS & TIMER_DONE));

                GPIO_OUT = 0xE;
                TIMER_CONTROL = TIMER_STOP;
                break;

            /* ------------------------------------------------ */
            case 'M':
            {
                GPIO_OUT = 0x9;
                // exemplo simples
                mnist_write_bias(0, 5);

                mnist_send_pixel(255, 0);
                mnist_send_pixel(128, 0);
                mnist_send_pixel(64, 1);

                uint32_t result = mnist_run();

                GPIO_OUT = result;

                break;
            }
            /* ------------------------------------------------ */
            default:
                GPIO_OUT = 0x0;
                break;
        }
    }
}