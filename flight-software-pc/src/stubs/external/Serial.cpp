#include "Serial.h"

static struct termios original_termios;

static void reset_terminal() {
    // Restore the original terminal settings
    tcsetattr(STDIN_FILENO, TCSAFLUSH, &original_termios);
}

void SerialClass::begin() {
    /* 
     * Make terminal feel like Arduino serial:
     * - Disable ICANON: Terminal will process input character-by-character.
     * - Disable ECHO: Terminal will not echo characters.
     */

    // Get current terminal attributes
    tcgetattr(STDIN_FILENO, &original_termios);
    atexit(reset_terminal); // Ensure settings are restored on exit

    struct termios raw = original_termios;

    // Disable ICANON and ECHO flags
    raw.c_lflag &= ~(ICANON | ECHO);

    // Apply the new settings immediately
    tcsetattr(STDIN_FILENO, TCSAFLUSH, &raw);
}