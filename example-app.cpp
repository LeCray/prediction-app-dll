#include <windows.h>

#ifndef PCH_H
    #define PCH_H
    // add headers that you want to pre-compile here
    #pragma once
    #define WIN32_LEAN_AND_MEAN             // Exclude rarely-used stuff from Windows headers
    // Windows Header Files
    #include <windows.h>
#endif //PCH_H





extern "C" __declspec(dllexport) int __stdcall fnCalculateSpeed(int& res1, double& res2)
{
    //Yo
    int    res_int = 0;
    double res_double = 0.0;
    int    start = GetTickCount();
    //--- simple math calculations
    for (int i = 0;i <= 10000000;i++)
    {
        res_int += i * i;
        res_int++;
        res_double += i * i;
        res_double++;
    }
    //--- set calculation results
    res1 = res_int;
    res2 = res_double;
    //--- return calculation time
    return(GetTickCount() - start);
}
