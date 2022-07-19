# unit test fail, lib is compiling
clear
rm -r build_x86_64
mkdir -p build_x86_64
cd build_x86_64
cmake -G Ninja -D APPLE_TARGET_ARCHITECTURE=x86_64 -D CMAKE_BUILD_TYPE=Release .. 
cmake --build ./
cd ..