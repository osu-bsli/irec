#include <WinbondW25N.h>
#include <cstdint>

#include "pins.h"
#include "telemetry.h"
#include <FS.h>
#include <error.h>
#include <SD.h>
#include <checksum.h>

static W25N flash;

/* Physical information about the flash*/
#define FLASH_NUM_PAGES (W25N04KV_MAX_PAGE + 1)
#define PAGE_SIZE 2048
#define ERASE_BLOCK_NUM_PAGES 64

/* Flash will be divided into partitions of equal size,
one partition will be used each time the flight computer is turned on. */
#define CONFIG_NUM_PARTITIONS 4

#define PAGES_PER_PARTITION (FLASH_NUM_PAGES / CONFIG_NUM_PARTITIONS)
#define PARTITION_SIZE (FLASH_NUM_PAGES * PAGE_SIZE) / CONFIG_NUM_PARTITIONS
#define PACKETS_PER_PARTITION PARTITION_SIZE / (sizeof(log_packet_v3))

/* Check that the pages divide evenly into number of configured partitions */
static_assert(PAGES_PER_PARTITION * CONFIG_NUM_PARTITIONS == FLASH_NUM_PAGES);

/* Check that partition size is multiple of 64 pages, since 64 pages is the erase block size */
static_assert(PAGES_PER_PARTITION / 64 * 64 == PAGES_PER_PARTITION);

static int32_t partition_i = -1;

static int32_t page_i = -1;
static uint8_t write_buf[PAGE_SIZE];
static uint16_t write_buf_i;

/*
 * Returns num of bytes successfully placed in buffer or written
 */
uint8_t logging_flash_push_byte(uint8_t val)
{
    if (page_i != -1 && page_i < PAGES_PER_PARTITION)
    {
        write_buf[write_buf_i] = val;
        write_buf_i++;
        if (write_buf_i == PAGE_SIZE)
        {
            write_buf_i = 0;

            flash.loadProgData(0, (char *)write_buf, PAGE_SIZE);
            flash.ProgramExecute(page_i);
            page_i++;
        }

        return 1;
    }
    else
    {
        return 0;
    }
}

/*
 * Returns -1 if no partitions are free.
 */
static int32_t flash_find_first_free_partition_index()
{
    for (int i = 0; i < CONFIG_NUM_PARTITIONS; i++)
    {
        uint32_t page_i = i * PAGES_PER_PARTITION;
        flash.pageDataRead(page_i);
        uint8_t first_byte_of_page;
        flash.read(0, (char *)&first_byte_of_page, 1);

        if (first_byte_of_page != LOG_PACKET_MAGIC[0])
        {
            return i;
        }
    }

    return -1;
}

// TODO explicitly pass in the SPI bus
/// Initialize state for writing to the SD card
/*
 * Preconditions: SPI1 is initialized and its pins are set
 */
FSError sdcard_init(fs::File *fileOut)
{
    SPI1.setMISO(PIN_FS_SPI_MISO);
    SPI1.setMOSI(PIN_FS_SPI_MOSI);
    SPI1.setSCK(PIN_FS_SPI_SCK);
    SPI1.begin();

    if (SD.begin(PIN_SD_CS, SPI1))
    {
        Serial.printf("[SD] SD card initialized\n\r");
    }
    else
    {
        return SD_CARD_INIT_FAILURE;
    }

    // Find a %d filename that is free to use
    char file_name[16];
    int file_num = 0;
    do
    {
        snprintf(file_name, 16, "/%d", file_num);
        file_num++;
    } while (SD.exists(file_name));

    // Open the file
    auto file = SD.open(file_name, FILE_WRITE);
    if (file)
    {
        Serial.print("[SD] Opened file \"");
        Serial.print(file_name);
        Serial.println("\" for telemetry logging\n");
    }
    else
    {
        Serial.print("[SD] Failed to open file \"");
        Serial.print(file_name);
        Serial.println("\" for telemetry logging\n");
        return SD_CARD_FILE_OPEN_FAILURE;
    }

    *fileOut = file;
    return SUCCESS;
}

static void sdcard_deinit()
{
    SD.end();
}

static void flash_erase_partition(int partition_i)
{
    for (int i = 0; i < PAGES_PER_PARTITION; i += ERASE_BLOCK_NUM_PAGES)
    {
        flash.blockErase(partition_i * PAGES_PER_PARTITION + i);
    }
}

void logging_move_flash_files_onto_sdcard()
{
    Serial.println("Moving logs on flash to SD card...");

    for (int i = 0; i < CONFIG_NUM_PARTITIONS; i++)
    {
        uint32_t page_i = i * PAGES_PER_PARTITION;
        flash.pageDataRead(page_i);
        uint8_t first_byte_of_page;
        flash.read(0, (char *)&first_byte_of_page, 1);

        if (first_byte_of_page == LOG_PACKET_MAGIC[0])
        {
            /* We've found a partition with data logs in it */
            Serial.printf("Partition %d has a data log on it\n", i);

            fs::File file;
            FSError sd_card_status = sdcard_init(&file);
            if (sd_card_status != SUCCESS)
            {
                while (true)
                {
                    Serial.printf("%s\n\r", FCError__strings[sd_card_status]);
                }
                // TODO handle sd card failure
            }

            Serial.printf("Transferring data from flash to SD card...\n");
            uint8_t flash_data_crc16 = 0;
            for (int j = 0; j < PAGES_PER_PARTITION; j++)
            {
                // tell the chip to read page j into internal buffer
                flash.pageDataRead(j);
                uint8_t page_read_buf[PAGE_SIZE];
                // read from chip internal buffer into MCU buffer
                flash.read(0, (char *)&page_read_buf, PAGE_SIZE);
                // calculate CRC of data
                for (int k = 0; k < PAGE_SIZE; k++)
                {
                    update_crc_16(flash_data_crc16, page_read_buf[k]);
                }
                file.write(page_read_buf, PAGE_SIZE);
            }

            file.flush();

            Serial.printf("Reading back SD card data and verifying integrity...\n");

            // Read file and make sure crc16 matches what we got from flash
            file.seek(0);

            uint8_t sd_readback_crc16 = 0;
            while (file.available())
            {
                uint8_t data = file.read();
                update_crc_16(sd_readback_crc16, data);
            }

            if (flash_data_crc16 == sd_readback_crc16)
            {
                Serial.printf("Readback matches, erasing flash partition");
                flash_erase_partition(i);
            }
            else
            {
                Serial.printf("Readback CRC does not match, flash data CRC: %04X, SD readback CRC: %04X\n", flash_data_crc16, sd_readback_crc16);
            }

            file.close();
            sdcard_deinit();
        }
    }
}

void logging_setup()
{
    SPI1.setSCK(PIN_FS_SPI_SCK);
    SPI1.setMOSI(PIN_FS_SPI_MOSI);
    SPI1.setMISO(PIN_FS_SPI_MISO);
    flash.begin(&SPI1, PIN_FLASH_CS);

    logging_move_flash_files_onto_sdcard();
    partition_i = flash_find_first_free_partition_index();
}
