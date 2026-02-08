#./build.sh -c Debug -arch x64 clr+libs+packs -cmakeargs "-DCLR_CMAKE_APPLE_DYSM=TRUE"
uname -m
./build.sh -c Debug -arch x64 -cmakeargs "-DCLR_CMAKE_APPLE_DYSM=TRUE"
cp ./artifacts/bin/coreclr/osx.x64.Debug/ilc/*.* ./artifacts/bin/coreclr/osx.x64.Debug/x64/ilc/

