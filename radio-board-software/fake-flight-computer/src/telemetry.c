#include "telemetry.h"
#include "string.h"

void telemetry_packet_make_header(struct telemetry_packet *p)
{
  // Copy in magic
  memcpy(p->magic, TELEMETRY_PACKET_MAGIC, sizeof(p->magic));
}

