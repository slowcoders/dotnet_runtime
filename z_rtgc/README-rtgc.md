### init repo
- on 2025-09-26
- Forks https://github.com/dotnet/runtime.git —> dotnet_runtime
- git clone  --depth=1024 https://9e70dd93abc19a3a7cf43b477a84d194ee09035a@github.com/slowcoders/dotnet_runtime.git

### Build 
```sh 
    # install xcode tools first. And...   
    ./eng/common/native/install-dependencies.sh
    # ./build.sh -c Debug -arch arm64 -cmakeargs "-DCLR_CMAKE_APPLE_DYSM=TRUE"
    ./build.sh -rc Debug -lc Debug -arch arm64 -cmakeargs "-DCLR_CMAKE_APPLE_DYSM=TRUE"

    # set debugger runtime.
    export DOTNET_ROOT=/Users/zeedhoon/slowcoders/dotnet/dotnet_runtime/artifacts/bin/testhost/net10.0-osx-Debug-arm64
    export CORE_ROOT=/Users/zeedhoon/slowcoders/dotnet/dotnet_runtime/artifacts/bin/testhost/net10.0-osx-Debug-arm64/shared/Microsoft.NETCore.App/10.0.0
    export PATH="$DOTNET_ROOT:$PATH"

    # ./build.sh --framework net10.0 -c Debug
    # ./build.sh clr.aot+libs -rc Debug -lc Release
    #./build.sh -c Release
```

### test & debug
https://github.com/dotnet/runtime/blob/main/docs/workflow/README.md
```sh    
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

