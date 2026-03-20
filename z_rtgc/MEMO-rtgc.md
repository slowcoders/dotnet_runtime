### Hints
- SetObjectReferenceUnchecked
- ErectWriteBarrier → gchelpers.cpp : 기본 WriteBarrier. 실제 사용 시엔 Assembly??<br>
현재는 RememberedSet Card 관리 기능만 있음.
- Thread::ObjectRefAssign → logging: 해당 코드를 찾으면 모든 WriteBarrier 를 찾을 수 있음.
- RhBulkMoveWithWriteBarrier -> InlinedBulkWriteBarrier → WriteBarrier for Array

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

    src/coreclr/nativeaot/Runtime/GCMemoryHelpers.inl
        void InlineWriteBarrier
        void InlineCheckedWriteBarrier -> heap 내부 check. (stack object 처리??)

* nativeaot debug point
    RhpGcAlloc --> nativeaot 전용 runtime 이다.
    InternalCalls.RhpAssignRef --> Rhp call wrapper
    src/coreclr/nativeaot/Runtime.Base/src/System/Runtime/InternalCalls.cs
        [RuntimeImport(RuntimeLibrary, "RhpAssignRef")]
    src/coreclr/nativeaot/Runtime/GCHelpers.cpp

* InWriteBarrierHelper 의 용도와 의미.
   1) WriteBarrier 사용 시 location 에 대한 null check 를 생락한다.
   2) WriteBarrier 내에서 발생한 npe 는 무시한다?
   
* LoadBarrier 구현??
    src/coreclr/tools/Common/TypeSystem/IL/Stubs/UnsafeIntrinsics.cs
        MethodIL EmitReadWrite
            codeStream.Emit(write ? ILOpcode.stobj : ILOpcode.ldobj,

* RhpAssignRef or WriteBarrier
    JIT_WriteBarrier(Object **dst, Object *ref)

    src/coreclr/tools/aot/ILCompiler.Compiler/Compiler/JitHelper.cs
        case ReadyToRunHelper.WriteBarrier:
            ->  RhpAssignRefArm64 호출. (주의. x0, x1 사용 안함!!)

    src/coreclr/System.Private.CoreLib/src/System/Runtime/CompilerServices/CastHelpers.cs
        void WriteBarrier 

    src/coreclr/tools/aot/ILCompiler.ReadyToRun/JitInterface/CorInfoImpl.ReadyToRun.cs
                case CorInfoHelpFunc.CORINFO_HELP_ASSIGN_REF:
                    id = ReadyToRunHelper.WriteBarrier; --> 이 코드를 Volatile 로 변경할 수 있다???

    src/coreclr/tools/aot/ILCompiler.RyuJit/JitInterface/CorInfoImpl.RyuJit.cs
                case CorInfoHelpFunc.CORINFO_HELP_ASSIGN_REF:
                    id = ReadyToRunHelper.WriteBarrier;

    src/coreclr/tools/Common/Internal/Runtime/ReadyToRunConstants.cs
        // Write barriers
        WriteBarrier                = 0x30,
        CheckedWriteBarrier         = 0x31,
        ByRefWriteBarrier           = 0x32,
        BulkWriteBarrier            = 0x33,

        // Array helpers
        Stelem_Ref                  = 0x38,
        Ldelema_Ref                 = 0x39,


CObjectHeader::void SetMarked()
mark_object_simple1.cpp
    go_through_object 를 통해 ref field interation??


#### dest가 Ephemeral 세대라도 Write Barrier를 생략하지 않는 이유:
    1. 객체 승격으로 인한 미래 참조 추적 필요
    2. 구현 단순성과 안전성 우선
    3. Ephemeral card table의 빈번한 초기화로 인한 영향 최소화
이는 GC의 정확성과 단순성 사이의 타협점입니다. Ephemeral 세대의 Write Barrier는 상대적으로 저비용이므로 생략하지 않습니다.



### 메모리 Segment
1. Gen0, 1, 2 및 POH, SOH 를 담는 단위
2. Server GC 시에는 CPU 코어 개수만큼 Segment 생성됨.
3. g_lowest_address 는 모든 가장 하단 segment 의 시작 주소값
4. 각 Segment 의 가장 하단부터 Gen2, Gen1, Gen0 순으로 메모리 할당.
   - 각 Gen 영역의 크기 변경될 수 있음.
   - LOH(Large Object Heap), POH(Pinned Object Heap) 은 Gen2 영역의 앞 또는 중간, 뒤에 배치될 수 있다.