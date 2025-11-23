### Hints
- INT_STIND_O
- SetObjectReferenceUnchecked
- ErectWriteBarrier → gchelpers.cpp : 기본 WriteBarrier. 실제 사용 시엔 Assembly??<br>
현재는 RememberedSet Card 관리 기능만 있음.
- Thread::ObjectRefAssign → logging: 해당 코드를 찾으면 모든 WriteBarrier 를 찾을 수 있음.
- InlineBulkWriteBarrier → WriteBarrier for Array

- write barrier generation in JIT
    CodeGen::genGCWriteBarrier

- nativeaot runtime gc barrier
    RhpAssignRef 를 통해 InlineWriteBarrier 호출!!
    HndWriteBarrier 는 HANDLE 관리를 위한 것.
* src/coreclr/nativeaot/Runtime/gcenv.ee.cpp 참조.
    GCToEEInterface::StompWriteBarrier    
* src/coreclr/vm/syncblk.h
    class ObjHeader
        - 숨겨진 객체 Header (CG, Hashcode, Lock)

* build config 참조 파일
  src/coreclr/clrdefinitions.cmake
  src/coreclr/clr.featuredefines.props
  -cmakeargs "-DFEATURE_USE_ASM_GC_WRITE_BARRIERS=FALSE"
    gchelpers.cpp:1425
    HCIMPL2_RAW(VOID, JIT_CheckedWriteBarrier 함수가 inline 처리된다.

* 주요 debug-pointer
    BYTE* GetWriteBarrierCodeLocation
    WriteBarrierManager::Initialize()
    void RunMainInternal
    void CallDescrWorkerWithHandler
    RhpNewObject(AllocFast.s)
        -> RhpGcAlloc(gcelpers.cppp)
            -> GCHeap::Alloc(gc_alloc_context*   (gc.cppp)
    RhpAssignRef
        -> RhpAssignRefArm64
    src/coreclr/tools/aot/ILCompiler.Compiler/Compiler/JitHelper.cs
        TargetArchitecture.ARM64 => "RhpAssignRefArm64",

* nativeaot debug point
    RhpGcAlloc --> nativeaot 전용 runtime 이다.
    InternalCalls.RhpAssignRef --> Rhp call wrapper
    src/coreclr/nativeaot/Runtime.Base/src/System/Runtime/InternalCalls.cs
        [RuntimeImport(RuntimeLibrary, "RhpAssignRef")]
    src/coreclr/nativeaot/Runtime/GCHelpers.cpp