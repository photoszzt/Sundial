#include "log.h"
#include "manager.h"
#if USE_CXLALLOC
#include "cxlalloc.h"
#endif

LogManager::LogManager()
{
    _buffer_size = 64 * 1024 * 1024;
#if USE_CXLALLOC
    _buffer = (char*)cxlalloc_malloc(_buffer_size);
#else
    _buffer = new char[_buffer_size]; // 64 MB
#endif
    _lsn = 0;
}

void
LogManager::log(uint32_t size, char * record)
{
    uint32_t lsn = ATOM_ADD(_lsn, size);
    uint32_t start = lsn % _buffer_size;
    if (lsn / _buffer_size == (lsn + size) / _buffer_size) {
        memcpy(_buffer + start, record, size);
    } else {
        uint32_t tail_size = _buffer_size - start;
        memcpy(_buffer + start, record, tail_size);
        memcpy(_buffer, record + tail_size, size - tail_size);
    }
    INC_FLOAT_STATS(log_size, size);
    // TODO should write buffer to disk. For now, assume NVP or battery backed DRAM.
}
