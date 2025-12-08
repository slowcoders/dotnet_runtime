./build.sh -rc Debug -lc Debug -arch arm64 -cmakeargs "-DFEATURE_USE_ASM_GC_WRITE_BARRIERS=FALSE -DCLR_CMAKE_APPLE_DYSM=TRUE"
# ilc 를 제외한 ilc 파일 복사. 
cp ./artifacts/bin/coreclr/osx.arm64.Debug/ilc/*.* ./artifacts/bin/coreclr/osx.arm64.Debug/arm64/ilc/