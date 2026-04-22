//
//  yz.m
//  PHPYZ
//
//  Created by 野望 on 2023/9/10.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#include <stdlib.h>
#include <sys/mount.h>
#include <iostream>
#include <string>
#include <chrono>
#include <sstream>

using namespace std;

#define appid "888101"//APPID
//yz.dcjhui.xyz
#define jihuourl "https://zhuihai.xyz/YanZhen/"//激活地址

#define host "zhuihai.xyz"//域名

#define pathee "/YanZhen/YanZhen.php"//Path

extern void sub_37734(std::string UDID,std::string path,std::string 验证地址,std::string APPID,std::string 激活地址);
extern int abcdefg;


static void* thread_running(void* arg)
{
    //等一秒, 等系统框架初始化完
    sleep(8);
    //通过主线程执行下面的代码
    dispatch_async(dispatch_get_main_queue(), ^{

                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    for(int a = 0; a<60;a++){
                        sleep(1);
                    if (abcdefg == 1)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                        //这里写验证成功执行的代码

                        });
                    }
                    }
                    });
                //======================================判断是否越狱 获取唯一识别码======================================
                    struct statfs buf;
                    statfs("/", &buf);
                    NSLog(@"%s", buf.f_mntfromname);
                    const char* prefix = "com.apple.os.update-";
                    if(strstr(buf.f_mntfromname, prefix)) {
                        //NSLog(@"未越狱, 设备唯一识别码=%s", buf.f_mntfromname+strlen(prefix));
                        NSArray *XULIE = [[NSString stringWithFormat:@"%s", buf.f_mntfromname+strlen(prefix)] componentsSeparatedByString:@"@"];
                        sub_37734([XULIE[0] UTF8String],pathee,host,appid,jihuourl);
                    } else {
                       // NSLog(@"已越狱, 没有设备唯一识别码");
                            NSFileManager *fileManager=[NSFileManager defaultManager];
                            NSData *data=[fileManager contentsAtPath:@"/var/mobile/Library/Logs/AppleSupport/general.log"];
                            NSMutableString *string = [[NSMutableString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                            NSString *regex = @"serial\":\"(.*?)\"";
                            NSError *error = nil;
                            NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:regex options:NSRegularExpressionCaseInsensitive error:&error];
                            NSArray *result = [re matchesInString:string options:0 range:NSMakeRange(0, string.length)];
                        if(result.count > 0){
                            for (NSTextCheckingResult *match in result) {
                                NSString *XULIE = [string substringWithRange:[match rangeAtIndex:1]];
                                sub_37734([XULIE UTF8String],pathee,host,appid,jihuourl);
                            }
                        }
                    }
                });

    });
    
    return 0;
}


//======================================系统自动加载函数======================================
static void __attribute__((constructor)) _init_()
{
    pthread_t thread;
    pthread_attr_t attr;
    pthread_attr_init(&attr);
    pthread_create(&thread, &attr, thread_running, nil);
}
