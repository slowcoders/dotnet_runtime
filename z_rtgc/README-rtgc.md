### init repo
- on 2025-09-26
- Forks https://github.com/dotnet/runtime.git —> dotnet_runtime
- git clone  --depth=1024 https://9e70dd93abc19a3a7cf43b477a84d194ee09035a@github.com/slowcoders/dotnet_runtime.git


## patch sources to enable debugging on macosx x64
### src/coreclr/hosts/corerun/CMakeLists.txt:78
```text
    if(CLR_CMAKE_TARGET_ARCH_ARM64)
        target_link_libraries(corerun PRIVATE
        coreclr_static
        gcinfo
        System.IO.Compression.Native-Static
        System.Globalization.Native-Static
        System.Native-Static)
    endif()
```
### src/coreclr/hosts/corerun/corerun.cpp:399
```cpp
#if 1
    // static link to coreclr(for debugging)
    coreclr_initialize_ptr coreclr_init_func = coreclr_initialize;
    coreclr_execute_assembly_ptr coreclr_execute_func = coreclr_execute_assembly;
    coreclr_set_error_writer_ptr coreclr_set_error_writer_func = coreclr_set_error_writer;
    coreclr_shutdown_2_ptr coreclr_shutdown2_func = coreclr_shutdown_2;
#else
```
### .vscode/launch.json
```js
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Launch lldb",
            "type": "lldb",
            // "type": "coreclr",
            "request": "launch",

            "program": "${workspaceFolder}/artifacts/bin/coreclr/osx.x64.Debug/corerun",
            "args": ["${workspaceRoot}/artifacts/tests/host/osx.x64.Debug/HelloWorld/HelloWorld.dll"],
            "breakpointMode": "file",  // 참고) file 모드에서는 assembly breakpoint 가 동작하지 않는다.
            // "stopOnEntry": true,  // 참고) type 이 gdb, cppdb 인 경우엔 stopAtEntry 를 사용.

            // "sourceMap": {
            //     "/home/helixbot/runtime": "${workspaceFolder}"
            // },            
            
            "env": {
                "DOTNET_ROOT": "${workspaceFolder}/artifacts/bin/coreclr/osx.x64.Debug",
                "CORE_ROOT": "${workspaceRoot}/artifacts/bin/coreclr-pack/Debug/net10.0/osx-x64",

                "COMPlus_ZapDisable": "1", // JIT Cache 비활성화
                "COMPlus_ReadyToRun": "0", // # R2R 비활성화
                "COMPlus_TieredCompilation": "0",
                "COMPlus_DbgEnableMiniDump": "1"
            },
        },
    ]
}
```

### Build 
https://github.com/dotnet/runtime/blob/main/docs/workflow/README.md
https://github.com/dotnet/runtime/blob/main/docs/workflow/debugging/coreclr/debugging-runtime.md#debugging-coreclr-on-linux-and-macos
```sh 
    # install xcode tools first. And...   
    ./eng/common/native/install-dependencies.sh

    # dlopen(libjitinterface_arm64) 오류 발생 시 clean 실행 필요!!
    ./build.sh --clean

    # rm -rf artifacts/obj/coreclr/osx.x64.Debug/jit
    # Xxx.dll not 오류 발생 시에는 clr 먼저 build.
    # ./build.sh clr -rc Debug -lc Debug -arch x64 -cmakeargs "-DCLR_CMAKE_APPLE_DYSM=TRUE"
    ./build.sh -rc Debug -lc Debug -arch x64 -cmakeargs "-DCLR_CMAKE_APPLE_DYSM=TRUE"
    # ilc 를 제외한 ilc 파일 복사. 
    cp ./artifacts/bin/coreclr/osx.x64.Debug/ilc/*.* ./artifacts/bin/coreclr/osx.x64.Debug/x64/ilc/

    # ~/.zprofile  -- set debugger runtime.  
    export DOTNET_ROOT=${workspaceFolder}/artifacts/bin/coreclr/osx.x64.Debug
    export CORE_ROOT=${workspaceRoot}/artifacts/bin/coreclr/osx.x64.Debug
    export PATH="$DOTNET_ROOT:$PATH"

    # # add cofig to nuget.config
    # <add key="local" value="/Users/zeedhoon/slowcoders/dotnet/dotnet_runtime/artifacts/packages/Debug/Shipping" />
    # # run to add package
    # ./.dotnet/dotnet add package Microsoft.DotNet.ILCompiler -v 10.0.0-dev
    # # publish project
    # ./.dotnet/dotnet publish --packages pkg -r osx-64 -c Debug

    # ./build.sh --framework net10.0 -c Debug
    # ./build.sh clr.aot+libs -rc Debug -lc Debug -cmakeargs "-DFEATURE_USE_ASM_GC_WRITE_BARRIERS=FALSE -DCLR_CMAKE_APPLE_DYSM=TRUE"
```

### LLBD plugin 설정
Lldb > Launch Init: Commands [Add Item]
    pro hand -p true -s false SIGUSR1
    pro hand -p true -s false SIGSEGV

### test 
https://github.com/dotnet/runtime/blob/main/docs/workflow/testing/coreclr/testing.md
```sh    

    ## nativeaot test build
    src/tests/build.sh -nativeaot Debug -tree:nativeaot /p:LibrariesConfiguration=Debug
    ## run all nativeaot tests
    src/tests/run.sh --runnativeaottests Debug


    ## Build Core_Root for tests => artifacts/tests/coreclr/osx.x64.Debug/Tests/Core_Root/**
    src/tests/build.sh generatelayoutonly /p:LibrariesConfiguration=Debug
    ## Build native libraries for tests.
    src/tests/build.sh skipmanaged /p:LibrariesConfiguration=Debug
    ## 전체 coreclr Test 실행
    ./build.sh -c Debug --test

    ## 개별 coreclr test build
    ./dotnet.sh build -c Debug src/tests/GC/Performance/Tests/GCPerf.csproj
    ./dotnet.sh build -c Debug src/tests/GC/Performance/Tests/XMLReader.csproj

```
