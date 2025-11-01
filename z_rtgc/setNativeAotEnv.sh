export DOTNET_ROOT=/Users/zeedhoon/slowcoders/dotnet/dotnet_runtime/artifacts/bin/testhost/net10.0-osx-Debug-arm64
export PATH="$DOTNET_ROOT:$PATH"

export CORE_ROOT=/Users/zeedhoon/slowcoders/dotnet/dotnet_runtime/artifacts/bin/coreclr/osx.arm64.Debug

# corerun 실행시 native-lib 검색 folders
# export CORE_ROOT=/Users/zeedhoon/slowcoders/dotnet/dotnet_runtime/artifacts/bin/testhost/net10.0-osx-Debug-arm64/shared/Microsoft.NETCore.App/10.0.0
export CLRCustomTestLauncher=/Users/zeedhoon/slowcoders/dotnet/dotnet_runtime/src/tests/Common/scripts/nativeaottest.sh
# echo $CORE_ROOT
# echo $CLRCustomTestLauncher