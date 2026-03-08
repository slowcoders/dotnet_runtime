# rm -rf artifacts/obj/coreclr/osx.arm64.Debug
./build.sh -c Debug -arch arm64 -cmakeargs "-DCLR_CMAKE_APPLE_DYSM=TRUE -DCLR_CMAKE_RTGC=TRUE"
# ilc 를 제외한 ilc 파일 복사. 
cp ./artifacts/bin/coreclr/osx.arm64.Debug/ilc/*.* ./artifacts/bin/coreclr/osx.arm64.Debug/arm64/ilc/