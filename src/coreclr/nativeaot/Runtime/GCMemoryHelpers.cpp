// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

//
// Unmanaged GC memory helpers
//

#include "common.h"
#include "gcenv.h"
#include "PalLimitedContext.h"
#include "CommonMacros.inl"
#include "GCMemoryHelpers.inl"

// This function clears a piece of memory in a GC safe way.
// Object-aligned memory is zeroed with no smaller than pointer-size granularity.
// We must make this guarantee whenever we clear memory in the GC heap that could contain object
// references.  The GC or other user threads can read object references at any time, clearing them bytewise can result
// in a read on another thread getting incorrect data.
// Unaligned memory at the beginning and remaining bytes at the end are written bytewise.
// USAGE:  The caller is responsible for null-checking the reference.
FCIMPL2(void *, RhpGcSafeZeroMemory, void * mem, size_t size)
{
    // The caller must do the null-check because we cannot take an AV in the runtime and translate it to managed.
    ASSERT(mem != nullptr);

    InlineGcSafeZeroMemory(mem, size);

    // memset returns the destination buffer
    return mem;
}
FCIMPLEND

#if defined(TARGET_X86) || defined(TARGET_AMD64)
    //
    // Memory writes are already ordered
    //
    #define GCHeapMemoryBarrier()
#else
    #define GCHeapMemoryBarrier() MemoryBarrier()
#endif

// Move memory, in a way that is compatible with a move onto the heap, but
// does not require the destination pointer to be on the heap.

FCIMPL3(void, RhBulkMoveWithWriteBarrier, uint8_t* pDest, uint8_t* pSrc, size_t cbDest)
{
    if (cbDest == 0 || pDest == pSrc)
        return;

    const bool notInHeap = pDest < g_lowest_address || pDest >= g_highest_address;

    if (!notInHeap)
    {
        // It is possible that the bulk write is publishing object references accessible so far only
        // by the current thread to shared memory.
        // The memory model requires that writes performed by current thread are observable no later
        // than the writes that will actually publish the references.
        GCHeapMemoryBarrier();
    }

    if (pDest <= pSrc || pSrc + cbDest <= pDest)
        InlineForwardGCSafeCopy(pDest, pSrc, cbDest);
    else
        InlineBackwardGCSafeCopy(pDest, pSrc, cbDest);

    if (!notInHeap)
    {
        InlinedBulkWriteBarrier(pDest, cbDest);
    }
}
FCIMPLEND

// ***********************************************
// --- RTGC brrriers ---
//

FORCEINLINE void rtgc_InlineWriteBarrier(Object ** dst, Object * ref) {
    *dst = ref;
    InlineWriteBarrier(dst, ref);
}


FCDECL2(void, RhpAssignRef, Object **dst, Object *ref);
FCDECL2(void, RhpCheckedAssignRef_rtgc_s, Object **dst, Object *ref);
FCDECL2(void, RhpByRefAssignRefArm64, Object **dst, Object *ref);

volatile bool call_rhp_assign_ref = true;
int cnt = 0;
// EXTERN_C void F_CALL_CONV 
FCIMPL3(void*, RhpAssignRefArm64_rtgc_2, Object **dst, Object *ref, Object *owner)
{
    rtgc_InlineWriteBarrier(dst, ref);
    return dst + 1;
}
FCIMPLEND


FCIMPL3(void*, RhpAssignRefArm64_rtgc, Object **dst, Object *ref, Object *owner)
{
    rtgc_InlineWriteBarrier(dst, ref);
    return dst + 1;
}
FCIMPLEND

// EXTERN_C void F_CALL_CONV 
FCIMPL3(void*, RhpCheckedAssignRefArm64_rtgc, Object **dst, Object *ref, Object *owner)
{
    if (((uint8_t*)dst < g_lowest_address) || ((uint8_t*)dst >= g_highest_address)) {
        *dst = ref;
        return dst + 1;
    }
    rtgc_InlineWriteBarrier(dst, ref);
    return dst + 1;
}
FCIMPLEND

// EXTERN_C void F_CALL_CONV 
struct byRef_Res {
    intptr_t dst; intptr_t src;
};

FCIMPL3(byRef_Res, RhpByRefAssignRefArm64_rtgc, Object **dst, Object **src, Object *owner)
{
    // rtgc_InlineWriteBarrier(dst, *src);
    byRef_Res res;
    res.dst = (intptr_t)RhpCheckedAssignRefArm64_rtgc(dst, *src, owner);
    res.src = (intptr_t)src + sizeof(Object*);
    return res;
}
FCIMPLEND

extern "C" void _rtgc_debug_trap()
{
    GCToOSInterface::DebugBreak();
}
