# unit test fail, lib is compiling
clear
rm -r build_arm64
mkdir -p build_arm64
cd build_arm64
cmake -G Ninja -D APPLE_TARGET_ARCHITECTURE=arm64 -D CMAKE_BUILD_TYPE=Release .. 
cmake --build ./
cd ..