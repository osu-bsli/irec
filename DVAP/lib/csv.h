#ifndef CSV_H
#define CSV_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#if _WIN32

#else

#endif

typedef struct {
    const char** headers;  // Array of const chars
    unsigned int headers_amount;
    double** data;
    unsigned int data_rows;     // How many lines are in the csv file
    unsigned int data_columns;  // Amount per row
} CSV_file;
CSV_file csv_init();

void csv_read(CSV_file*, const char*);
void csv_getColumn(const char*, double*);

CSV_file csv_init() {
    CSV_file c = {0};

    // c.headers = {0};
    // c.headers_amount = 0;

    // c.data = {0};
    // c.data_rows = 0;
    // c.data_columns = 0;
    // Each row has the same number of columns

    return c;
}

void CSV_file_cleanup(CSV_file* csv) {
    if (csv->headers != NULL) {
        for (unsigned int i = 0; i < csv->headers_amount; ++i) {
            free(csv->headers[i]);
            csv->headers = NULL;
        }
    }

    if (csv->data != NULL) {
        for (unsigned int i = 0; i < csv->data_rows; ++i) {
            free(csv->data[i]);
            csv->data[i] = NULL;
        }
    }
}

// ONLY USED FOR THE 256 CHAR BUFFER FROM CSV_READ
void clear_buffer(char* buffer) {
    for (int i = 0; i < 256; ++i) {
        buffer[i] = '\0';
    }
}

void csv_read(CSV_file* csv, const char* file_path) {
    FILE* file = fopen(file_path, "r");  // Open file
    if (file == NULL) {
        printf("Error: In function csv_read: Unable to find file\n");
        return;
    }

    // Line 1 -- the names for the data
    int line_separater_count = 0;

    int fgetc_in;  // Bc fetc returns int to handle -1 for EOF

    // Loop through the first time for line length
    while ((fgetc_in = fgetc(file)) != EOF) {  // Read first line -- stop when we reach the newline character
        char current_char = (char)fgetc_in;
        if (current_char == '\n') break;  // Temmp -- dont read whole file
        // printf("Reading character %c\n", current_char);

        if (current_char == ',') {
            ++line_separater_count;
        }
    }
    line_separater_count += 1;  // Because this is keeping track of the columns in the csv and there is another column not finishing with a comma ath the end

    csv->data_columns = line_separater_count;
    csv->data_rows = 0;

    char* fscanf_string = (char*)malloc(sizeof(char) * (line_separater_count * 4) + 1);
    printf("Line separators: %d\n", line_separater_count);

    for (int i = 0; i < line_separater_count; i += 4) {
        fscanf_string[i] = '%';
        fscanf_string[i + 1] = 'l';
        fscanf_string[i + 2] = 'd';
        fscanf_string[i + 3] = ',';
        // "%ld,"
    }
    fscanf_string[line_separater_count * 4] = '\0';
    printf("scanf string: %s\n", fscanf_string);
    // Loop through the second time for copying data to the csv struct
    // while (fscanf("%ld,%ld,"))

    free(fscanf_string);
    fscanf_string = NULL;
    fclose(file);  // Close file
}

void csv_getColumn(const char* identifier, double* out) {
    (void)identifier;
    (void)out;
}

#endif  // CSV_H