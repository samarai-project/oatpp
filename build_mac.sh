# unit test fail, lib is compiling
clear
rm -r build
mkdir -p build
cd build
cmake -G Ninja -D CMAKE_BUILD_TYPE=Release .. 
cmake --build ./
cd ..