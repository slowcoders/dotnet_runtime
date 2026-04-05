#ifndef _RTGC_H_
#define _RTGC_H_

class rtgc {
    struct RTGC_Header {
        uint8_t    m_flags;
        uint8_t    m_reserved;
        uint8_t    m_rc;
        uint8_t    m_stableRc;
    };

public:
    static FORCEINLINE RTGC_Header* rtgcHeaderOf(void* ref) {
        ASSERT(ref != nullptr);
        return reinterpret_cast<RTGC_Header*>((uint8_t*)ref - 8);
    }

    static FORCEINLINE bool is_in_old_heap(void* ref, void* old_heap_start) {
        return ref >= old_heap_start; // || (ref < g_ephemeral_low && ref != NULL);
    }

    static FORCEINLINE void increase_rc(void* ref) {
        // ASSERT(rtgcHeaderOf(ref)->m_rc < 128);
        RTGC_Header* h = rtgcHeaderOf(ref);
        if (h->m_rc < 128) {
            h->m_rc ++;
        }
    }

    static FORCEINLINE void decrease_rc(void* ref) {
        RTGC_Header* h = rtgcHeaderOf(ref);
        while (h->m_rc < 128) {
            RTGC_Header h0 = *h;
            uint16_t rc_old = *(uint16_t*)(void*)&h0.m_rc;
            uint16_t rc_new = rc_old;
            if (h0.m_stableRc > 0) {
                rc_new += 0x101;
            } else {
                rc_new += 0x100;
            }
            std::atomic<uint16_t>* p = reinterpret_cast<std::atomic<uint16_t>*>(&h->m_rc);
            if (rc_old == p->compare_exchange_strong(rc_old, rc_new, std::memory_order_seq_cst)) {
                break;
            }
        }
    }
};

#endif