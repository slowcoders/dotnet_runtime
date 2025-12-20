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