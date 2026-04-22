//
//  JFCommon.h
//  SCMusic
//
//  Created by feng on 2021/7/14.
//

#ifndef JFCommon_h
#define JFCommon_h

// 屏幕尺寸
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#define ADDRESS_MIN 0x100

typedef struct Vector2 {
    float x;
    float y;
    
    Vector2() {}
    Vector2(float _x, float _y) : x(_x), y(_y) {}
    
    float distance(Vector2 vec2)
    {
        float xDiff = x - vec2.x;
        float yDiff = y - vec2.y;
        return sqrtf(powf(xDiff, 2) + powf(yDiff, 2));
    }
    
} Vector2;

typedef struct Vector3 {
    float x;
    float y;
    float z;
    
    Vector3() {}
    Vector3(float _x, float _y, float _z) : x(_x), y(_y), z(_z) {}
    
    float distance(Vector3 vec3)
    {
        float xDiff = x - vec3.x;
        float yDiff = y - vec3.y;
        float zDiff = z - vec3.z;
        return sqrtf(powf(xDiff, 2) + powf(yDiff, 2) + powf(zDiff, 2));
    }
        
} Vector3;

typedef enum : NSUInteger {
    PlayerTypeMyself,
    PlayerTypeTeam,
    PlayerTypeEnemy
} PlayerType;

#endif /* JFCommon_h */
