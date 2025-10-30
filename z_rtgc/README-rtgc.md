### init repo
- on 2025-09-26
- Forks https://github.com/dotnet/runtime.git —> dotnet_runtime
- git clone  --depth=1024 https://9e70dd93abc19a3a7cf43b477a84d194ee09035a@github.com/slowcoders/dotnet_runtime.git

### Build 
```sh    
    ./eng/common/native/install-dependencies.sh
    ./build.sh -subset clr+libs+host+packs -configuration Debug -cmakeargs "-DCLR_CMAKE_APPLE_DYSM=TRUE"
    ./build.sh --framework net10.0 -c Debug
```

### test & debug
https://github.com/dotnet/runtime/blob/main/docs/workflow/README.md
```sh    
    # build nativeaot clr
    ./build.sh clr.aot+libs -rc Debug -lc Release
    # build tool chains
    ./build.sh -c Release
    # add cofig to nuget.config
    <add key="local" value="/Users/zeedhoon/slowcoders/dotnet/dotnet_runtime/artifacts/packages/Release/Shipping" />
    # run to add package
    dotnet add package Microsoft.DotNet.ILCompiler -v 10.0.0-dev
    # publish project
    dotnet publish --packages pkg -r osx-64 -c Debug

    #set env for nativeaot test.
    CORE_ROOT=/Users/zeedhoon/slowcoders/dotnet/dotnet_runtime/artifacts/tests/coreclrosx.x64.Debug/Tests/Core_Root
    CLRCustomTestLauncher=/Users/zeedhoon/slowcoders/dotnet/dotnet_runtime/src/tests/Common/scripts/nativeaottest.sh
    # build nativeaot test
    src/tests/build.sh -nativeaot Debug -tree:nativeaot
    # run all nativeaot test
    src/tests/run.sh runnativeaottests Debug

    ./build.sh --test
    # /Users/zeedhoon/slowcoders/dotnet/dotnet_runtime/.dotnet/dotnet
    # ./artifacts/bin/osx-arm64.Debug/corehost/dotnet
```
###

### Debug
```sh
    ./dotnet.sh build src/libraries/System.Text.Json/tests/System.Text.Json.Tests.csproj -c Debug
    ./dotnet.sh test src/libraries/System.Text.Json/tests/System.Text.Json.Tests.csproj -c Debug
```


### Hints
- INT_STIND_O
- SetObjectReferenceUnchecked
- ErectWriteBarrier → gchelpers.cpp : 기본 WriteBarrier. 실제 사용 시엔 Assembly??<br>
현재는 RememberedSet Card 관리 기능만 있음.
- Thread::ObjectRefAssign → logging: 해당 코드를 찾으면 모든 WriteBarrier 를 찾을 수 있음.
- InlineBulkWriteBarrier → WriteBarrier for Array

