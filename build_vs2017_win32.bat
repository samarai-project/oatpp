if not exist build_vs2017_win32 mkdir build_vs2017_win32
cd build_vs2017_win32
cmake -G "Visual Studio 15 2017" -DCMAKE_CXX_FLAGS="/MP /EHsc" ..
cmake --build ./ --config "Debug" 
cmake --build ./ --config "Release" 
cd ..