# export DOTNET_ROOT=/Users/zeedhoon/slowcoders/dotnet/dotnet_runtime/artifacts/bin/testhost/net10.0-osx-Debug-arm64
export DOTNET_ROOT=/Users/zeedhoon/slowcoders/dotnet/dotnet_runtime/artifacts/bin/coreclr/osx.arm64.Debug
export PATH="$DOTNET_ROOT:$PATH"
# export DYLD_LIBRARY_PATH=/Users/zeedhoon/slowcoders/dotnet/dotnet_runtime/artifacts/bin/coreclr/osx.arm64.Debug
# export LD_LIBRARY_PATH=/Users/zeedhoon/slowcoders/dotnet/dotnet_runtime/artifacts/bin/coreclr/osx.arm64.Debug
# export DYLD_PRINT_LIBRARIES=/Users/zeedhoon/slowcoders/dotnet/dotnet_runtime/artifacts/bin/coreclr/osx.arm64.Debug
# export CORE_ROOT=/Users/zeedhoon/slowcoders/dotnet/dotnet_runtime/artifacts/bin/coreclr/osx.arm64.Debug


# corerun 실행시 native-lib 검색 folders
# export CORE_ROOT=/Users/zeedhoon/slowcoders/dotnet/dotnet_runtime/artifacts/tests/coreclr/osx.arm64.Debug/Tests/Core_Root
export CORE_ROOT=/Users/zeedhoon/slowcoders/dotnet/dotnet_runtime/artifacts/bin/coreclr/osx.arm64.Debug
# export CORE_ROOT=/Users/zeedhoon/slowcoders/dotnet/dotnet_runtime/artifacts/bin/testhost/net10.0-osx-Debug-arm64/shared/Microsoft.NETCore.App/10.0.0
# export CLRCustomTestLauncher=/Users/zeedhoon/slowcoders/dotnet/dotnet_runtime/src/tests/Common/scripts/nativeaottest.sh
# echo $CORE_ROOT
# echo $CLRCustomTestLauncher