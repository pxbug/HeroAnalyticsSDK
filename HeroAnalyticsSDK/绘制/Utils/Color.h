//
//  Color.hpp
//  SCMusic
//
//  Created by feng on 2021/7/18.
//

#ifndef Color_hpp
#define Color_hpp

#include <stdio.h>

typedef struct Color {
    int a, r, g, b;
    
    Color(int _r, int _g, int _b) : r(_r), g(_g), b(_b) {
        a = 255;
    }
    
    Color(int _r, int _g, int _b, int _a) : r(_r), g(_g), b(_b), a(_a) { }
    
    static Color 黑色;
    static Color 白色;
    static Color 红色;
    static Color 绿色;
    static Color 蓝色;
    static Color 橙色;
    static Color 黄色;
    static Color 灰色;
    static Color 粉色;
    static Color 浅绿色;
    static Color 翠绿色;
    static Color 酸橙绿;
} Color;

#endif /* Color_hpp */
