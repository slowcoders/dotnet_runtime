export DOTNET_ROOT=/Users/zeedhoon/slowcoders/dotnet/dotnet_runtime/artifacts/bin/osx-arm64.Debug/corehost
export PATH="$DOTNET_ROOT:$PATH"
export CORE_ROOT=/Users/zeedhoon/slowcoders/dotnet/dotnet_runtime/artifacts/tests/coreclrosx.x64.Debug/Tests/Core_Root
export CLRCustomTestLauncher=/Users/zeedhoon/slowcoders/dotnet/dotnet_runtime/src/tests/Common/scripts/nativeaottest.sh
echo $CORE_ROOT
echo $CLRCustomTestLauncher