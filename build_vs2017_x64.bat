if not exist build_vs2017_x64 mkdir build_vs2017_x64
cd build_vs2017_x64
cmake -G "Visual Studio 15 2017" -A x64 -DCMAKE_CXX_FLAGS="/MP /EHsc" ..
cmake --build ./ --config "Debug"
cmake --build ./ --config "Release"
cd ..