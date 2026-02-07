#./build.sh -c Debug -arch x64 clr+libs+packs -cmakeargs "-DCLR_CMAKE_APPLE_DYSM=TRUE"
./build.sh -c Debug -arch x64 -cmakeargs "-DCLR_CMAKE_APPLE_DYSM=TRUE"
cp ./artifacts/bin/coreclr/osx.x64.Debug/ilc/*.* ./artifacts/bin/coreclr/osx.x64.Debug/x64/ilc/


* Build CoreCLR for Linux x64 on Release configuration:
./build.sh clr -c release

* Build Debug libraries with a Release runtime for Linux x64.
./build.sh clr+libs -rc release

* Build Release libraries and their tests with a Checked runtime for Linux x64, and run the tests.
./build.sh clr+libs+libs.tests -rc checked -lc release -test

* Build CoreCLR for Linux x64 on Debug configuration using Clang 9.
./build.sh clr -clang9

* Build CoreCLR for Linux x64 on Debug configuration using GCC 8.4.
./build.sh clr -gcc8.4

* Build CoreCLR for Linux x64 using extra compiler flags (-fstack-clash-protection).
EXTRA_CFLAGS=-fstack-clash-protection EXTRA_CXXFLAGS=-fstack-clash-protection ./build.sh clr

* Cross-compile CoreCLR runtime for Linux ARM64 on Release configuration.
./build.sh clr.runtime -arch arm64 -c release -cross

However, for this example, you need to already have ROOTFS_DIR set up.
Further information on this can be found here:
https://github.com/dotnet/runtime/blob/main/docs/workflow/building/coreclr/cross-building.md

* Build Mono runtime for Linux x64 on Release configuration.
./build.sh mono -c release

* Build Release coreclr corelib, crossgen corelib and update Debug libraries testhost to run test on an updated corelib.
./build.sh clr.corelib+clr.nativecorelib+libs.pretest -rc release

* Build Debug mono corelib and update Release libraries testhost to run test on an updated corelib.
./build.sh mono.corelib+libs.pretest -rc debug -c release