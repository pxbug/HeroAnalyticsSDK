#include <JRMemory/MemScan.h>
#import "JFOverlayView.h"
#import "ImGuiView.h"
#import "JFPlayer.h"
#import "JFCommon.h"
#import "Color.h"
#import "imgui.h"
#import "imgui_internal.h"
#import "ImGuiWrapper.h"
#import "ImGuiStyleWrapper.h"
#import "TextEditorWrapper.h"
#import "GuiRenderer.h"
#import "baidu_font.h"

#define kWidth  [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height


#define 国服 @"com.lastdayrulessurvival.heroios"
#define 国际服 @"com.herogame.ios.lastdayrules"

@interface JFOverlayView () <GuiRendererDelegate> {
    ImFont *_espFont;
}

@property (nonatomic, strong) MTKView *mtkView;
@property (nonatomic, strong) GuiRenderer *renderer;
@property (nonatomic, assign) vector<void*> dundi3;
@end

@implementation JFOverlayView
int 按钮X=1,按钮Y=1;
float 升降按钮颜色[3]= {0,0,0};
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        self.总开关 = true;//总开关
        self.射线开关 = true;
        self.方框开关 = true;
        self.血量开关 = true;
        self.信息开关 = true;
        self.离线开关 = true;
        self.手持开关 = true;
        self.水下行走开关=true;
        self.锁定天气=true;
        
        self.无后开关 = true;
        self.聚点开关 = true;
        
        self.自瞄追踪范围大小 = 1000;
        self.绘制距离 = 3000;
        self.绘制帧率 = 120;
        self.飞天变化距离 = 4;
        self.追踪部位 = 0x98;
        
        按钮X = [[NSUserDefaults standardUserDefaults] floatForKey:@"文明重启_按钮X"];
        按钮Y = [[NSUserDefaults standardUserDefaults] floatForKey:@"文明重启_按钮Y"];
        升降按钮颜色[0] = [[NSUserDefaults standardUserDefaults] floatForKey:@"文明重启_配置按钮颜色0"];
        升降按钮颜色[1] = [[NSUserDefaults standardUserDefaults] floatForKey:@"文明重启_配置按钮颜色1"];
        升降按钮颜色[2] = [[NSUserDefaults standardUserDefaults] floatForKey:@"文明重启_配置按钮颜色2"];
        
        [self setupUI];
        [self paopaopao];
    }
    return self;
}

#pragma mark - UI
- (void)setupUI
{
    self.mtkView = [[MTKView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.mtkView.backgroundColor = [UIColor clearColor];
    [[UIApplication sharedApplication].keyWindow addSubview:self.mtkView];
    self.mtkView.device = MTLCreateSystemDefaultDevice();
    if (!self.mtkView.device) {
        return;
    }
    
    self.renderer = [[GuiRenderer alloc] initWithView:self.mtkView];
    self.renderer.delegate = self;
    self.mtkView.delegate = self.renderer;
    [self.renderer initializePlatform];
}

- (void)setup
{
    ImGuiIO &io = ImGui::GetIO();
    ImFontConfig config;
    config.FontDataOwnedByAtlas = false;
    _espFont = io.Fonts->AddFontFromMemoryTTF((void *)baidu_font_data, baidu_font_size, 16.0f, &config, io.Fonts->GetGlyphRangesChineseFull());
    ImGui::StyleColorsDarkMode();
}

- (void)draw
{
    [self drawOverlay];
    [self drawMenu];
}

const char* 瞄准部位items[] = { "头部", "裆部"};
int 瞄准部位选择=1;
- (void)drawMenu
{
    self.userInteractionEnabled = self.打开菜单;
    self.mtkView.userInteractionEnabled = self.打开菜单;
    if (!_打开菜单) {
        return;
    }
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGFloat width = SCREEN_WIDTH * 0.5;
        CGFloat height = SCREEN_HEIGHT * 0.5;
        if (SCREEN_WIDTH > SCREEN_HEIGHT) {
            height = SCREEN_HEIGHT * 0.8;
        } else {
            width = SCREEN_WIDTH * 0.8;
        }
        ImGuiIO & io = ImGui::GetIO();
        io.DisplaySize = ImVec2(width, height);
        ImGui::SetNextWindowPos(ImVec2((SCREEN_WIDTH - width) * 0.5, (SCREEN_HEIGHT - height) * 0.5), 0, ImVec2(0, 0));
        ImGui::SetNextWindowSize(ImVec2(io.DisplaySize.x, io.DisplaySize.y));
    });
    
    ImGui::Begin("文明重启绘制", &_打开菜单, ImGuiWindowFlags_NoCollapse);
    ImGui::Checkbox("总开关", &_总开关);ImGui::SameLine();
    
    if (ImGui::Button("解封设备")){ }
    
    if (ImGui::BeginTabBar("选项卡", ImGuiTabBarFlags_NoTooltip))
    {
        if (ImGui::BeginTabItem("透视自瞄"))
        {
            ImGui::Checkbox("方框", &_方框开关);ImGui::SameLine();
            ImGui::Checkbox("射线", &_射线开关);ImGui::SameLine();
            ImGui::Checkbox("血量", &_血量开关);ImGui::SameLine();
            ImGui::Checkbox("信息", &_信息开关);ImGui::SameLine();
            ImGui::Checkbox("离线", &_离线开关);ImGui::SameLine();
            ImGui::Checkbox("手持", &_手持开关);
            
            ImGui::Checkbox("自瞄", &_自瞄开关);ImGui::SameLine();
            ImGui::Checkbox("追踪", &_追踪开关);ImGui::SameLine();
            ImGui::Checkbox("穿山", &_穿山开关);ImGui::SameLine();
            ImGui::Checkbox("无后", &_无后开关);ImGui::SameLine();
            ImGui::Checkbox("聚点", &_聚点开关);
            ImGui::SetNextItemWidth(100);
            if (ImGui::Combo(" ", &瞄准部位选择, 瞄准部位items, IM_ARRAYSIZE(瞄准部位items))) {
                switch (瞄准部位选择) {
                    case 0:self.追踪部位=0x80; break;//头 public Transform HeadTop;
                    case 1:self.追踪部位=0x98; break;//裆 public Transform RootBone;
                    default:self.追踪部位=0x98; break;//裆
                }
            }
            
            ImGui::NewLine();
            if (ImGui::Checkbox("头部0.6", &_头部范围)) {
                if (self.头部范围) {
                    dispatch_queue_t queue = dispatch_queue_create("net.bujige.testQueue", DISPATCH_QUEUE_SERIAL);dispatch_async(queue, ^{
                        JRMemoryEngine engine = JRMemoryEngine(mach_task_self());
                        AddrRange range = (AddrRange){0x250000000,0x290000000};
                        float search = 0.11;
                        engine.JRScanMemory(range, &search, JR_Search_Type_Float);
                        vector<void*>results = engine.getAllResults();
                        float modify = 0.6;
                        for(int i = 0;i<results.size();i++){
                            engine.JRWriteMemory((unsigned long long)(results[i]),&modify,JR_Search_Type_Float);}
                    });}
            }
            ImGui::SameLine();
            if (ImGui::Checkbox("头部1.2", &_头部范围1)) {
                if (self.头部范围1) {
                    dispatch_queue_t queue = dispatch_queue_create("net.bujige.testQueue", DISPATCH_QUEUE_SERIAL);dispatch_async(queue, ^{
                        JRMemoryEngine engine = JRMemoryEngine(mach_task_self());
                        AddrRange range = (AddrRange){0x250000000,0x290000000};
                        float search = 0.11;
                        engine.JRScanMemory(range, &search, JR_Search_Type_Float);
                        vector<void*>results = engine.getAllResults();
                        float modify = 1.2;
                        for(int i = 0;i<results.size();i++){
                            engine.JRWriteMemory((unsigned long long)(results[i]),&modify,JR_Search_Type_Float);}
                    });}
            }
            ImGui::SameLine();
            if (ImGui::Checkbox("头部2.0", &_头部范围2)) {
                if (self.头部范围2) {
                    dispatch_queue_t queue = dispatch_queue_create("net.bujige.testQueue", DISPATCH_QUEUE_SERIAL);dispatch_async(queue, ^{
                        JRMemoryEngine engine = JRMemoryEngine(mach_task_self());
                        AddrRange range = (AddrRange){0x250000000,0x290000000};
                        float search = 0.11;
                        engine.JRScanMemory(range, &search, JR_Search_Type_Float);
                        vector<void*>results = engine.getAllResults();
                        float modify = 2.0;
                        for(int i = 0;i<results.size();i++){
                            engine.JRWriteMemory((unsigned long long)(results[i]),&modify,JR_Search_Type_Float);}
                    });}
            }
            if (ImGui::Checkbox("身体0.6", &_身体范围)) {
                if (self.身体范围) {
                    dispatch_queue_t queue = dispatch_queue_create("net.bujige.testQueue", DISPATCH_QUEUE_SERIAL);dispatch_async(queue, ^{
                        JRMemoryEngine engine = JRMemoryEngine(mach_task_self());
                        AddrRange range = (AddrRange){0x250000000,0x290000000};
                        float search = 0.16;
                        engine.JRScanMemory(range, &search, JR_Search_Type_Float);
                        vector<void*>results = engine.getAllResults();
                        float modify = 0.6;
                        for(int i = 0;i<results.size();i++){
                            engine.JRWriteMemory((unsigned long long)(results[i]),&modify,JR_Search_Type_Float);}
                    });}
            }
            ImGui::SameLine();
            if (ImGui::Checkbox("身体1.2", &_身体范围1)) {
                if (self.身体范围1) {
                    dispatch_queue_t queue = dispatch_queue_create("net.bujige.testQueue", DISPATCH_QUEUE_SERIAL);dispatch_async(queue, ^{
                        JRMemoryEngine engine = JRMemoryEngine(mach_task_self());
                        AddrRange range = (AddrRange){0x250000000,0x290000000};
                        float search = 0.16;
                        engine.JRScanMemory(range, &search, JR_Search_Type_Float);
                        vector<void*>results = engine.getAllResults();
                        float modify = 1.2;
                        for(int i = 0;i<results.size();i++){
                            engine.JRWriteMemory((unsigned long long)(results[i]),&modify,JR_Search_Type_Float);}
                    });}
            }
            ImGui::SameLine();
            if (ImGui::Checkbox("身体2.0", &_身体范围2)) {
                if (self.身体范围2) {
                    dispatch_queue_t queue = dispatch_queue_create("net.bujige.testQueue", DISPATCH_QUEUE_SERIAL);dispatch_async(queue, ^{
                        JRMemoryEngine engine = JRMemoryEngine(mach_task_self());
                        AddrRange range = (AddrRange){0x250000000,0x290000000};
                        float search = 0.16;
                        engine.JRScanMemory(range, &search, JR_Search_Type_Float);
                        vector<void*>results = engine.getAllResults();
                        float modify = 2;
                        for(int i = 0;i<results.size();i++){
                            engine.JRWriteMemory((unsigned long long)(results[i]),&modify,JR_Search_Type_Float);}
                    });}
            }
            
            ImGui::SliderInt("自瞄/追踪范围", &_自瞄追踪范围大小, 10, 1000);
            ImGui::EndTabItem();
        }
        
        if (ImGui::BeginTabItem("人物"))
        {
            ImGui::Checkbox("人物踏空", &_踏空开关);ImGui::SameLine();
            ImGui::Checkbox("灵魂穿墙", &_灵魂穿墙开关);ImGui::SameLine();
            ImGui::Checkbox("强制上锁", &_强制上锁开关);ImGui::SameLine();
            if (ImGui::Checkbox("穿卡房(配灵魂)", &_穿卡房)) {
                if (self.穿卡房) {
                    dispatch_queue_t queue = dispatch_queue_create("net.bujige.testQueue", DISPATCH_QUEUE_SERIAL);
                    dispatch_async(queue, ^{
                        JRMemoryEngine engine = JRMemoryEngine(mach_task_self());
                        AddrRange range = (AddrRange){0x100000000,0x290000000};
                        float search = 1.0e32;
                        engine.JRScanMemory(range, &search, JR_Search_Type_Float);
                        float Nearsearch = 0.005;
                        engine.JRNearBySearch(0x10,&Nearsearch,JR_Search_Type_Float);
                        float search1 = 1.0e32;
                        engine.JRScanMemory(range, &search1, JR_Search_Type_Float);
                        vector<void*>results = engine.getAllResults();
                        float modify = 8.8888;
                        for(int i =0;i<results.size();i++){
                            engine.JRWriteMemory((unsigned long long)(results[i]),&modify,JR_Search_Type_Float);
                        
                        }
                    });
                }else{
                    dispatch_queue_t queue = dispatch_queue_create("net.bujige.testQueue", DISPATCH_QUEUE_SERIAL);
                    dispatch_async(queue, ^{
                        JRMemoryEngine engine = JRMemoryEngine(mach_task_self());
                        AddrRange range = (AddrRange){0x100000000,0x290000000};
                        float search = 8.8888;
                        engine.JRScanMemory(range, &search, JR_Search_Type_Float);
                        vector<void*>results = engine.getAllResults();
                        float modify = 1.0e32;
                        for(int i =0;i<results.size();i++){
                            engine.JRWriteMemory((unsigned long long)(results[i]),&modify,JR_Search_Type_Float);
                        
                        }
                    });
                }
            }
            
            ImGui::Checkbox("滑翔翼", &_滑翔翼开关);
            if (ImGui::Checkbox("升降屏幕按钮", &_屏幕升降按钮开关)) {
                if (self.屏幕升降按钮开关) {[self 屏幕升降显示];} else {[self 屏幕升降隐藏];}
            }ImGui::SameLine();
            
            if (ImGui::ColorEdit3(" ", &*(float*)升降按钮颜色, ImGuiColorEditFlags_NoInputs)) {
                [self 刷新按钮位置];
            }
            ImGui::SliderInt("飞天变化高度", &_飞天变化距离, 1, 10);
            if (ImGui::SliderInt("按钮X", &按钮X, 1, kWidth-35)) { [self 刷新按钮位置]; }
            if (ImGui::SliderInt("按钮Y", &按钮Y, 1, kHeight-130)) { [self 刷新按钮位置]; }
            ImGui::EndTabItem();
        }
           
        if (ImGui::BeginTabItem("常用"))
        {
            ImGui::Checkbox("除草", &_除草开关);ImGui::SameLine(150);
            ImGui::Checkbox("除树", &_除树开关);ImGui::SameLine(300);
            ImGui::Checkbox("除石头与官方建筑",&_除石头与除建筑开关);
            ImGui::Checkbox("定怪", &_定怪开关);ImGui::SameLine(150);
            ImGui::Checkbox("定炮台", &_定炮台开关);ImGui::SameLine(300);
            ImGui::Checkbox("定坦克直升机", &_定坦克直升机开关);
            ImGui::Checkbox("水下行走", &_水下行走开关);ImGui::SameLine(150);
            ImGui::Checkbox("不会摔伤", &_不会摔伤开关);ImGui::SameLine(300);
            ImGui::Checkbox("锁定天气", &_锁定天气);
            if (ImGui::Button("全开")) {
                self.除草开关=true;self.除树开关=true;self.除石头与除建筑开关=true;self.定怪开关=true;self.定炮台开关=true;self.定坦克直升机开关=true;self.水下行走开关=true;self.不会摔伤开关=true;self.锁定天气=true;
            }
            ImGui::Checkbox("强制建筑", &_基址强建开关);
            
            ImGui::EndTabItem();
        }
        
        if (ImGui::BeginTabItem("混家"))
        {
            [self 混家功能];
            ImGui::EndTabItem();
        }
        if (ImGui::BeginTabItem("内存"))
        {
            [self 内存功能];
            ImGui::EndTabItem();
        }
        
        ImGui::EndTabBar();
    }
    ImGui::End();
}

UIButton *升,*锁,*降,*跑,*落,*追,*魂,*无,*碰;
- (void)屏幕升降显示{
    UIWindow *Window = [[[UIApplication sharedApplication] delegate] window];
    升 = [[UIButton alloc] initWithFrame:CGRectMake(按钮X, 按钮Y, 35, 35)];
    升.layer.cornerRadius = 10.0;//2.0是圆角的弧度，根据需求自己更改
    [升 setTitle:@"升" forState:UIControlStateNormal];
    [升 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];//p1颜色
    升.backgroundColor = [UIColor colorWithRed:升降按钮颜色[0] green:升降按钮颜色[1] blue:升降按钮颜色[2] alpha:1];
    升.layer.borderWidth = 0;//边框大小
    [升.titleLabel setFont:[UIFont systemFontOfSize:17]];//字体大小
    [升 addTarget:self action:@selector(sheng) forControlEvents:UIControlEventTouchUpInside];
    [Window addSubview:升];
    
    锁 = [[UIButton alloc] initWithFrame:CGRectMake(按钮X, 按钮Y+45*1, 35, 35)];
    锁.layer.cornerRadius = 10.0;//2.0是圆角的弧度，根据需求自己更改
    [锁 setTitle:@"锁" forState:UIControlStateNormal];
    [锁 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];//p1颜色
    锁.backgroundColor = [UIColor colorWithRed:升降按钮颜色[0] green:升降按钮颜色[1] blue:升降按钮颜色[2] alpha:1];
    锁.layer.borderWidth = 0;//边框大小
    [锁.titleLabel setFont:[UIFont systemFontOfSize:17]];//字体大小
    [锁 addTarget:self action:@selector(suo) forControlEvents:UIControlEventTouchUpInside];
    [Window addSubview:锁];
    
    降 = [[UIButton alloc] initWithFrame:CGRectMake(按钮X, 按钮Y+45*2, 35, 35)];
    降.layer.cornerRadius = 10.0;//2.0是圆角的弧度，根据需求自己更改
    [降 setTitle:@"降" forState:UIControlStateNormal];
    [降 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];//p1颜色
    降.backgroundColor = [UIColor colorWithRed:升降按钮颜色[0] green:升降按钮颜色[1] blue:升降按钮颜色[2] alpha:1];
    降.layer.borderWidth = 0;//边框大小
    [降.titleLabel setFont:[UIFont systemFontOfSize:17]];//字体大小
    [降 addTarget:self action:@selector(jiang) forControlEvents:UIControlEventTouchUpInside];
    [Window addSubview:降];
    
    跑 = [[UIButton alloc] initWithFrame:CGRectMake(按钮X, 按钮Y+45*3, 35, 35)];
    跑.layer.cornerRadius = 10.0;//2.0是圆角的弧度，根据需求自己更改
    [跑 setTitle:@"跑" forState:UIControlStateNormal];
    [跑 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];//p1颜色
    跑.backgroundColor = [UIColor colorWithRed:升降按钮颜色[0] green:升降按钮颜色[1] blue:升降按钮颜色[2] alpha:1];
    跑.layer.borderWidth = 0;//边框大小
    [跑.titleLabel setFont:[UIFont systemFontOfSize:17]];//字体大小
    [跑 addTarget:self action:@selector(pao) forControlEvents:UIControlEventTouchUpInside];
    [Window addSubview:跑];
    
    落 = [[UIButton alloc] initWithFrame:CGRectMake(按钮X, 按钮Y+45*4, 35, 35)];
    落.layer.cornerRadius = 10.0;//2.0是圆角的弧度，根据需求自己更改
    [落 setTitle:@"落" forState:UIControlStateNormal];
    [落 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];//p1颜色
    落.backgroundColor = [UIColor colorWithRed:升降按钮颜色[0] green:升降按钮颜色[1] blue:升降按钮颜色[2] alpha:1];
    落.layer.borderWidth = 0;//边框大小
    [落.titleLabel setFont:[UIFont systemFontOfSize:17]];//字体大小
    [落 addTarget:self action:@selector(luo) forControlEvents:UIControlEventTouchUpInside];
    [Window addSubview:落];
}


- (void)sheng{
    [[ImGuiView getInstance] modifyLocalPlayerPosX:0 y:1 z:0];
}
- (void)suo{
    self.踏空开关=!self.踏空开关;
}
- (void)jiang{
    [[ImGuiView getInstance] modifyLocalPlayerPosX:0 y:-1 z:0];
}
static NSTimer*dsq;
bool paolu=false,luodi=false;
- (void)pao{
    paolu = !paolu;
    luodi=false;
}
- (void)luo{
    luodi = !luodi;
    paolu=false;
}
- (void)paopaopao{
    dsq=[NSTimer scheduledTimerWithTimeInterval:跑定时器 repeats:YES block:^(NSTimer * _Nonnull timer) {
        if (paolu) {
            [[ImGuiView getInstance] modifyLocalPlayerPosX:0 y:1 z:0];
        }
        if (luodi) {
            [[ImGuiView getInstance] modifyLocalPlayerPosX:0 y:-1 z:0];
        }
    }];
    [[NSRunLoop currentRunLoop] addTimer:dsq forMode:NSRunLoopCommonModes];
    
    NSTimer* dsq2=[NSTimer scheduledTimerWithTimeInterval:0.5 repeats:YES block:^(NSTimer * _Nonnull timer) {
        if ([ImGuiView getInstance].overlayView.修改位置开关) {
            
        }
    }];
    [[NSRunLoop currentRunLoop] addTimer:dsq2 forMode:NSRunLoopCommonModes];
}
- (void)屏幕升降隐藏{
    升.hidden = !升.hidden;
    降.hidden = !降.hidden;
    锁.hidden = !锁.hidden;
    跑.hidden = !跑.hidden;
    落.hidden = !落.hidden;
    魂.hidden = !魂.hidden;
    无.hidden = !无.hidden;
}
- (void)刷新按钮位置{
    [[NSUserDefaults standardUserDefaults] setFloat:按钮X forKey:@"文明重启_按钮X"];
    [[NSUserDefaults standardUserDefaults] setFloat:按钮Y forKey:@"文明重启_按钮Y"];
    
    [[NSUserDefaults standardUserDefaults] setFloat:升降按钮颜色[0] forKey:@"文明重启_配置按钮颜色0"];
    [[NSUserDefaults standardUserDefaults] setFloat:升降按钮颜色[1] forKey:@"文明重启_配置按钮颜色1"];
    [[NSUserDefaults standardUserDefaults] setFloat:升降按钮颜色[2] forKey:@"文明重启_配置按钮颜色2"];
    if (self.屏幕升降按钮开关) {
        [self 屏幕升降隐藏];
        [self 屏幕升降显示];
    } else {
        [self 屏幕升降显示];
        self.屏幕升降按钮开关=true;
    }
}

- (void)混家功能
{
    if (ImGui::Checkbox("人物半遁", &_人物半遁)) {
        if (self.人物半遁) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    JRMemoryEngine engine_di = JRMemoryEngine(mach_task_self());
                    AddrRange range = (AddrRange){0x280000000,0x290000000};
                    float search = 1.0400390625;
                    engine_di.JRScanMemory(range, &search, JR_Search_Type_Float);
                    float Nearsearch = 1.401298e-45;
                    engine_di.JRNearBySearch(0x100,&Nearsearch,JR_Search_Type_Float);
                    float search1 = 1.0400390625;
                    engine_di.JRScanMemory(range, &search1, JR_Search_Type_Float);
                    vector<void*>results = engine_di.getAllResults();
                    float modify = 1.95456;
                    for(int ii =0;ii<999;ii++){
                        ii = 1;
                        for(int i =0;i<results.size();i++){
                            engine_di.JRWriteMemory((unsigned long long)(results[i]),&modify,JR_Search_Type_Float);
                        }
                  }
            });
        }
    }ImGui::SameLine();
    if (ImGui::Checkbox("人物半遁2", &_人物半遁2)) {
        if (self.人物半遁2) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    JRMemoryEngine engine_di = JRMemoryEngine(mach_task_self());
                    AddrRange range = (AddrRange){0x280000000,0x290000000};
                    float search = 1.0400390625;
                    engine_di.JRScanMemory(range, &search, JR_Search_Type_Float);
                    float Nearsearch = 1.401298e-45;
                    engine_di.JRNearBySearch(0x100,&Nearsearch,JR_Search_Type_Float);
                    float search1 = 1.0400390625;
                    engine_di.JRScanMemory(range, &search1, JR_Search_Type_Float);
                    vector<void*>results = engine_di.getAllResults();
                    float modify = 1.498;
                    for(int ii =0;ii<999;ii++){
                        ii = 1;
                        for(int i =0;i<results.size();i++){
                            engine_di.JRWriteMemory((unsigned long long)(results[i]),&modify,JR_Search_Type_Float);
                        }
                  }
            });
        }
    }
    
    if (ImGui::Checkbox("趴下状态男", &_男趴下)) {
        if (self.男趴下) {
           dispatch_queue_t queue = dispatch_queue_create("net.bujige.testQueue", DISPATCH_QUEUE_SERIAL);
             dispatch_async(queue, ^{
                 JRMemoryEngine engine = JRMemoryEngine(mach_task_self());
                 AddrRange range = (AddrRange){0x100000000,0x290000000};
                 float search = 6.375604601571521E-24;
                 engine.JRScanMemory(range, &search, JR_Search_Type_Float);
                 float Nearsearch = 1.3370429788205679E23;
                 engine.JRNearBySearch(0x20,&Nearsearch,JR_Search_Type_Float);
                 float Nearsearch2 = 0;
                 engine.JRNearBySearch(0x20,&Nearsearch2,JR_Search_Type_Float);
                 float search2 = 1.3370429788205679E23;
                 engine.JRScanMemory(range, &search2, JR_Search_Type_Float);
                 vector<void*>results = engine.getAllResults();
                 float modify = -1368660888;
                 for(int i =0;i<results.size();i++){
                     engine.JRWriteMemory((unsigned long long)(results[i]),&modify,JR_Search_Type_Float);
                 }
           });
        }
      }
    ImGui::SameLine();
    if (ImGui::Checkbox("趴下状态女", &_女趴下)) {
        if (self.女趴下) {
            dispatch_queue_t queue = dispatch_queue_create("net.bujige.testQueue", DISPATCH_QUEUE_SERIAL);
            dispatch_async(queue, ^{
                JRMemoryEngine engine = JRMemoryEngine(mach_task_self());
                AddrRange range = (AddrRange){0x100000000,0x2900000000};
                float search = 5.373936840947742E-18;
                engine.JRScanMemory(range, &search, JR_Search_Type_Float);
                float Nearsearch = 2.3057976669491783E-38;
                engine.JRNearBySearch(0x50,&Nearsearch,JR_Search_Type_Float);
                float search3 = 2.3057976669491783E-38;
                engine.JRScanMemory(range, &search3, JR_Search_Type_Float);
                vector<void*>results = engine.getAllResults();
                float modify = -1368660888;
                for(int i =0;i<results.size();i++){
                    engine.JRWriteMemory((unsigned long long)(results[i]),&modify,JR_Search_Type_Float);
                }
            });
        }
    }
    if (ImGui::Checkbox("驾驶状态男", &_男驾驶)) {
        if (self.男驾驶) {
           dispatch_queue_t queue = dispatch_queue_create("net.bujige.testQueue", DISPATCH_QUEUE_SERIAL);
             dispatch_async(queue, ^{
                 JRMemoryEngine engine = JRMemoryEngine(mach_task_self());
                 AddrRange range = (AddrRange){0x100000000,0x290000000};
                 float search = 6.375604601571521E-24;
                 engine.JRScanMemory(range, &search, JR_Search_Type_Float);
                 float Nearsearch = 1.3370429788205679E23;
                 engine.JRNearBySearch(0x20,&Nearsearch,JR_Search_Type_Float);
                 float Nearsearch2 = 0;
                 engine.JRNearBySearch(0x20,&Nearsearch2,JR_Search_Type_Float);
                 float search2 = 1.3370429788205679E23;
                 engine.JRScanMemory(range, &search2, JR_Search_Type_Float);
                 vector<void*>results = engine.getAllResults();
                 float modify = -3.7417599e30;
                 for(int i =0;i<results.size();i++){
                     engine.JRWriteMemory((unsigned long long)(results[i]),&modify,JR_Search_Type_Float);
                 }
           });
        }
      }
    ImGui::SameLine();
    if (ImGui::Checkbox("驾驶状态女", &_女驾驶)) {
        if (self.女驾驶) {
            dispatch_queue_t queue = dispatch_queue_create("net.bujige.testQueue", DISPATCH_QUEUE_SERIAL);
            dispatch_async(queue, ^{
                JRMemoryEngine engine = JRMemoryEngine(mach_task_self());
                AddrRange range = (AddrRange){0x100000000,0x2900000000};
                float search = 5.373936840947742E-18;
                engine.JRScanMemory(range, &search, JR_Search_Type_Float);
                float Nearsearch = 2.3057976669491783E-38;
                engine.JRNearBySearch(0x50,&Nearsearch,JR_Search_Type_Float);
                float search3 = 2.3057976669491783E-38;
                engine.JRScanMemory(range, &search3, JR_Search_Type_Float);
                vector<void*>results = engine.getAllResults();
                float modify = -3.7417599e30;
                for(int i =0;i<results.size();i++){
                    engine.JRWriteMemory((unsigned long long)(results[i]),&modify,JR_Search_Type_Float);
                }
            });
        }
    }
    if (ImGui::Checkbox("翻滚状态男", &_男翻滚)) {
        if (self.男翻滚) {
           dispatch_queue_t queue = dispatch_queue_create("net.bujige.testQueue", DISPATCH_QUEUE_SERIAL);
             dispatch_async(queue, ^{
                 JRMemoryEngine engine = JRMemoryEngine(mach_task_self());
                 AddrRange range = (AddrRange){0x100000000,0x290000000};
                 float search = 6.375604601571521E-24;
                 engine.JRScanMemory(range, &search, JR_Search_Type_Float);
                 float Nearsearch = 1.3370429788205679E23;
                 engine.JRNearBySearch(0x20,&Nearsearch,JR_Search_Type_Float);
                 float Nearsearch2 = 0;
                 engine.JRNearBySearch(0x20,&Nearsearch2,JR_Search_Type_Float);
                 float search2 = 1.3370429788205679E23;
                 engine.JRScanMemory(range, &search2, JR_Search_Type_Float);
                 vector<void*>results = engine.getAllResults();
                 float modify = -4.71139035e-23;
                 for(int i =0;i<results.size();i++){
                     engine.JRWriteMemory((unsigned long long)(results[i]),&modify,JR_Search_Type_Float);
                 }
           });
        }
    }
    ImGui::SameLine();
    if (ImGui::Checkbox("翻滚状态女", &_女翻滚)) {
        if (self.女翻滚) {
            dispatch_queue_t queue = dispatch_queue_create("net.bujige.testQueue", DISPATCH_QUEUE_SERIAL);
            dispatch_async(queue, ^{
                JRMemoryEngine engine = JRMemoryEngine(mach_task_self());
                AddrRange range = (AddrRange){0x100000000,0x2900000000};
                float search = 5.373936840947742E-18;
                engine.JRScanMemory(range, &search, JR_Search_Type_Float);
                float Nearsearch = 2.3057976669491783E-38;
                engine.JRNearBySearch(0x50,&Nearsearch,JR_Search_Type_Float);
                float search3 = 2.3057976669491783E-38;
                engine.JRScanMemory(range, &search3, JR_Search_Type_Float);
                vector<void*>results = engine.getAllResults();
                float modify = -4.71139035e-23;
                for(int i =0;i<results.size();i++){
                    engine.JRWriteMemory((unsigned long long)(results[i]),&modify,JR_Search_Type_Float);
                }
            });
        }
    }
    
}
- (void)内存功能
{
    if (ImGui::Checkbox("机瞄八倍", &_机瞄八倍)) {
        if (self.机瞄八倍) {
            dispatch_queue_t queue = dispatch_queue_create("net.bujige.testQueue", DISPATCH_QUEUE_SERIAL);
            dispatch_async(queue, ^{
                JRMemoryEngine engine = JRMemoryEngine(mach_task_self());
                AddrRange range = (AddrRange){0x100000000,0x200000000};
                float search = 48;
                engine.JRScanMemory(range, &search, JR_Search_Type_Float);
                float Nearsearch = 1.401298e-45;
                engine.JRNearBySearch(0x50,&Nearsearch,JR_Search_Type_Float);
                float search1 = 48;
                engine.JRScanMemory(range, &search1, JR_Search_Type_Float);
                vector<void*>results = engine.getAllResults();
                float modify = 10;
                for(int i =0;i<results.size();i++){
                    engine.JRWriteMemory((unsigned long long)(results[i]),&modify,JR_Search_Type_Float);
                }
            });
        }
    }
    ImGui::SameLine();
    if (ImGui::Checkbox("子弹穿图", &_子弹穿图)) {
        JRMemoryEngine zidanchuantu = JRMemoryEngine(mach_task_self());
        if (self.子弹穿图) {
                AddrRange range = (AddrRange){0x100000000,0x290000000};
                float search = 1.401298464324817E-41;
                zidanchuantu.JRScanMemory(range, &search, JR_Search_Type_Float);
                float Nearsearch = 1.401298464324817E-43;
                zidanchuantu.JRNearBySearch(0x20,&Nearsearch,JR_Search_Type_Float);
                vector<void*>results = zidanchuantu.getAllResults();
                float modify = 0;
                for(int i =0;i<results.size();i++){
                    zidanchuantu.JRWriteMemory((unsigned long long)(results[i]),&modify,JR_Search_Type_Float);
                }
        } else {
            vector<void*>results = zidanchuantu.getAllResults();
            float modify = 1.401298464324817E-41;
            for(int i =0;i<results.size();i++){
                zidanchuantu.JRWriteMemory((unsigned long long)(results[i]),&modify,JR_Search_Type_Float);
            }
        }
    }
    ImGui::SameLine();
    if (ImGui::Checkbox("昼夜交替", &_昼夜交替)) {
        if (self.昼夜交替) {
            dispatch_queue_t queue = dispatch_queue_create("net.bujige.testQueue", DISPATCH_QUEUE_SERIAL);
            dispatch_async(queue, ^{
                JRMemoryEngine engine = JRMemoryEngine(mach_task_self());
                AddrRange range = (AddrRange){0x100000000,0x200000000};
                float search = 0.0067;
                engine.JRScanMemory(range, &search, JR_Search_Type_Float);
                float search1 = 9.21942e-41;
                engine.JRNearBySearch(0x60,&search1,JR_Search_Type_Float);
                float search2 = 9.21942e-41;
                engine.JRScanMemory(range, &search2,JR_Search_Type_Float);
                vector<void*>results = engine.getAllResults();
                float modify = -999;
                for(int i =0;i<results.size();i++){
                    engine.JRWriteMemory((unsigned long long)(results[i]),&modify,JR_Search_Type_Float);
                }
            });
        } else {
        }
    }ImGui::SameLine();
    if (ImGui::Checkbox("飞天船", &_飞天船2)) {
        if (self.飞天船2) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                JRMemoryEngine engine = JRMemoryEngine(mach_task_self());
                AddrRange range = (AddrRange){0x100000000,0x200000000};
                float search1 = 10000;
                engine.JRScanMemory(range, &search1, JR_Search_Type_Float);
                float search2 = 10000.001953125;
                engine.JRNearBySearch(0x10, &search2, JR_Search_Type_Float);
                float search3 = 10000.001953125;
                engine.JRNearBySearch(0x10, &search3, JR_Search_Type_Float);
                float search4 = 0.05000001192;
                engine.JRNearBySearch(0x10, &search4, JR_Search_Type_Float);
                float search5 = 0.05000001192;
                engine.JRScanMemory(range, &search5, JR_Search_Type_Float);
                vector<void*>results = engine.getAllResults();
                float modify = 150.1234;
                for(int i =0;i<results.size();i++){
                    engine.JRWriteMemory((unsigned long long)(results[i]),&modify,JR_Search_Type_Float);
                }
            });
        } else {
        }
    }
    
    if (ImGui::Checkbox("强制建造", &_强制建筑)) {
        if (self.强制建筑) {
            dispatch_queue_t queue = dispatch_queue_create("net.bujige.testQueue", DISPATCH_QUEUE_SERIAL);
            dispatch_async(queue, ^{
                JRMemoryEngine engine_jz = JRMemoryEngine(mach_task_self());
                JRMemoryEngine engine = JRMemoryEngine(mach_task_self());
                AddrRange range = (AddrRange){0x100000000,0x500000000};
                int32_t search = 1113166849;
                engine_jz.JRScanMemory(range, &search, JR_Search_Type_SInt);
                int32_t Nearsearch = 16843008;
                engine_jz.JRNearBySearch(0x300,&Nearsearch,JR_Search_Type_SInt);
                int32_t search1 = 1113166849;
                engine_jz.JRScanMemory(range, &search1, JR_Search_Type_SInt);
                vector<void*>results = engine_jz.getAllResults();
                int32_t modify = 16843009;
                for(;;){
                    for(int i =0;i<results.size();i++){
                        engine_jz.JRWriteMemory((unsigned long long)(results[i])+204,&modify,JR_Search_Type_SInt);
                    }
                }
            });
        } else {
            JRMemoryEngine engine_jz = JRMemoryEngine(mach_task_self());
            vector<void*>results = engine_jz.getAllResults();
            float modify = 16843008;
            for(int i =0;i<results.size();i++){
                engine_jz.JRWriteMemory((unsigned long long)(results[i]),&modify,JR_Search_Type_SInt);
            }
        }
    }
    ImGui::SameLine();
    if (ImGui::Checkbox("地基领地", &_地基领地)) {
        if (self.地基领地) {
            dispatch_queue_t queue = dispatch_queue_create("net.bujige.testQueue", DISPATCH_QUEUE_SERIAL);
            dispatch_async(queue, ^{
                JRMemoryEngine engine_dift = JRMemoryEngine(mach_task_self());
                JRMemoryEngine engine = JRMemoryEngine(mach_task_self());
                AddrRange range = (AddrRange){0x100000000,0x10000000000};
                int32_t search = 1113166849;
                engine_dift.JRScanMemory(range, &search, JR_Search_Type_SInt);
                int32_t Nearsearch = 1113166849;
                engine_dift.JRNearBySearch(0x300,&Nearsearch,JR_Search_Type_SInt);
                int32_t search1 = 1113166849;
                engine_dift.JRScanMemory(range, &search1, JR_Search_Type_SInt);
                vector<void*>results = engine_dift.getAllResults();
                int32_t modify = 0;
                    for(int i =0;i<results.size();i++){
                        engine_dift.JRWriteMemory((unsigned long long)(results[i])+0,&modify,JR_Search_Type_SInt);
                }
            });
        } else {
            JRMemoryEngine engine_dift = JRMemoryEngine(mach_task_self());
            vector<void*>results = engine_dift.getAllResults();
            float modify = 1113166849;
            for(int i =0;i<results.size();i++){
                engine_dift.JRWriteMemory((unsigned long long)(results[i]),&modify,JR_Search_Type_SInt);
            }
        }
    }
    ImGui::SameLine();
    if (ImGui::Checkbox("下蹲视角", &_下蹲视角)) {
        if (self.下蹲视角) {
            dispatch_queue_t queue = dispatch_queue_create("net.bujige.testQueue", DISPATCH_QUEUE_SERIAL);
            dispatch_async(queue, ^{
                JRMemoryEngine engine_xdsj = JRMemoryEngine(mach_task_self());
                JRMemoryEngine engine = JRMemoryEngine(mach_task_self());
                AddrRange range = (AddrRange){0x110000000,0x500000000};
                float search = -360;
                engine_xdsj.JRScanMemory(range, &search, JR_Search_Type_Float);
                float Nearsearch = 1.5;
                engine_xdsj.JRNearBySearch(0x40,&Nearsearch,JR_Search_Type_Float);
                float Nearsearch1 = 360;
                engine_xdsj.JRNearBySearch(0x40,&Nearsearch1,JR_Search_Type_Float);
                float search4 = -360;
                engine_xdsj.JRScanMemory(range, &search4, JR_Search_Type_Float);
                vector<void*>results = engine_xdsj.getAllResults();
                float modify = -1.2;
                for(int i =0;i<results.size();i++){
                    engine_xdsj.JRWriteMemory((unsigned long long)(results[i])-28,&modify,JR_Search_Type_Float);
                }
            });
         }else{
             JRMemoryEngine engine_xdsj = JRMemoryEngine(mach_task_self());
             vector<void*>results = engine_xdsj.getAllResults();
             float modify = 1.5;
             for(int i =0;i<results.size();i++){
             engine_xdsj.JRWriteMemory((unsigned long long)(results[i])-28,&modify,JR_Search_Type_Float);
             }
         }
    }
    ImGui::SameLine();
    if (ImGui::Checkbox("浮空地基", &_浮空地基)) {
        if (self.浮空地基) {
            dispatch_queue_t queue = dispatch_queue_create("net.bujige.testQueue", DISPATCH_QUEUE_SERIAL);
            dispatch_async(queue, ^{
                JRMemoryEngine engine_dift = JRMemoryEngine(mach_task_self());
                JRMemoryEngine engine = JRMemoryEngine(mach_task_self());
                AddrRange range = (AddrRange){0x100000000,0x290000000};
                uint64_t search = 1125899906842625;
                engine.JRScanMemory(range, &search, JR_Search_Type_SLong);
                uint64_t Nearsearch = 4503600701112320;
                engine.JRNearBySearch(0x10,&Nearsearch,JR_Search_Type_SLong);
                uint64_t search1 = 1125899906842625;
                engine.JRScanMemory(range, &search1, JR_Search_Type_SLong);
                vector<void*>results = engine.getAllResults();
                uint64_t modify = 206403243343873;
                for(int i =0;i<results.size();i++){
                    engine.JRWriteMemory((unsigned long long)(results[i]),&modify,JR_Search_Type_SLong);
                    }
                });
            } else {
                JRMemoryEngine engine = JRMemoryEngine(mach_task_self());
                AddrRange range = (AddrRange){0x100000000,0x290000000};
                uint64_t search = 206403243343873;
                engine.JRScanMemory(range, &search, JR_Search_Type_SLong);
                uint64_t Nearsearch = 4503600701112320;
                engine.JRNearBySearch(0x10,&Nearsearch,JR_Search_Type_SLong);
                uint64_t search1 = 206403243343873;
                engine.JRScanMemory(range, &search1, JR_Search_Type_SLong);
                vector<void*>results = engine.getAllResults();
                uint64_t modify = 1125899906842625;
                for(int i =0;i<results.size();i++){
                    engine.JRWriteMemory((unsigned long long)(results[i]),&modify,JR_Search_Type_SLong);
                }
            }
        }
    if (ImGui::Checkbox("单车加速", &_单车)) {
        if (self.单车) {
            dispatch_queue_t queue = dispatch_queue_create("net.bujige.testQueue", DISPATCH_QUEUE_SERIAL);
            dispatch_async(queue, ^{
                JRMemoryEngine engine = JRMemoryEngine(mach_task_self());
                AddrRange range = (AddrRange){0x00000000,0x180000000};
                float  search1 = 30;                     //    搜索数值
                engine.JRScanMemory(range, &search1, JR_Search_Type_Float);    //精准搜索
                float search2 = 30;
                engine.JRNearBySearch(0x100,&search2,JR_Search_Type_Float);    //临近   临近范围100
                float search3 = 45;
                engine.JRScanMemory(range, &search3, JR_Search_Type_Float);   //临近修改
                vector<void*>results = engine.getAllResults();
                float  modify = 150;                         //修改结果
                for(int i =0;i<results.size();i++){
                    engine.JRWriteMemory((unsigned long long)(results[i]),&modify,JR_Search_Type_Float);  //全改
                }
            });
        }
    }
    ImGui::SameLine();
    if (ImGui::Checkbox("上色", &_上色)) {
        if (self.上色) {
            JRMemoryEngine engine = JRMemoryEngine(mach_task_self());
            AddrRange range = (AddrRange){0x00000000,0x180000000};
            SInt32 search = 75;
            engine.JRScanMemory(range, &search, JR_Search_Type_SInt);
            SInt32 search1 = 58;
            engine.JRNearBySearch(0x100, &search1, JR_Search_Type_SInt);
            float search2 = .75;
            engine.JRNearBySearch(0x100, &search2, JR_Search_Type_Float);
            float search3 = .75;
            engine.JRScanMemory(range, &search3, JR_Search_Type_Float);
            vector<void*>results = engine.getAllResults();
            float modify = 999;
            for(int i =0;i<results.size();i++){
                engine.JRWriteMemory((unsigned long long)(results[i]),&modify,JR_Search_Type_Float);
            }
        } else {
        }
    }
    ImGui::SameLine();
    if (ImGui::Checkbox("地图迷雾美化", &_地图迷雾美化)) {
        if (self.地图迷雾美化) {
            JRMemoryEngine engine = JRMemoryEngine(mach_task_self());
            AddrRange range = (AddrRange){0x00000000,0x180000000};
            SInt32 search = -27263215;
            engine.JRScanMemory(range, &search, JR_Search_Type_SInt);
            float search2 = 10;
            engine.JRNearBySearch(0x30, &search2, JR_Search_Type_Float);
            SInt32 search3 = 1;
            engine.JRNearBySearch(0x30, &search3, JR_Search_Type_SInt);
            SInt32 search4 = 1;
            engine.JRScanMemory(range, &search4, JR_Search_Type_SInt);
            vector<void*>results = engine.getAllResults();
            SInt32 modify = -999;
            for(int i =0;i<results.size();i++){
                engine.JRWriteMemory((unsigned long long)(results[i]),&modify,JR_Search_Type_SInt);
            }
        } else {
            JRMemoryEngine engine = JRMemoryEngine(mach_task_self());
            AddrRange range = (AddrRange){0x00000000,0x180000000};
            SInt32 search = -27263215;
            engine.JRScanMemory(range, &search, JR_Search_Type_SInt);
            float search2 = 10;
            engine.JRNearBySearch(0x30, &search2, JR_Search_Type_Float);
            SInt32 search3 = -999;
            engine.JRNearBySearch(0x30, &search3, JR_Search_Type_SInt);
            SInt32 search4 = -999;
            engine.JRScanMemory(range, &search4, JR_Search_Type_SInt);
            vector<void*>results = engine.getAllResults();
            SInt32 modify = 1;
            for(int i =0;i<results.size();i++){
                engine.JRWriteMemory((unsigned long long)(results[i]),&modify,JR_Search_Type_SInt);
            }
        }
    }
    
    ImGui::TextColored(ImColor(0, 191, 255), "");
    
    if (ImGui::Checkbox("SMG瞬击", &_SMG瞬击)) {
        if (self.SMG瞬击) {
            dispatch_queue_t queue = dispatch_queue_create("net.bujige.testQueue", DISPATCH_QUEUE_SERIAL);
            dispatch_async(queue, ^{
                JRMemoryEngine engine = JRMemoryEngine(mach_task_self());
                AddrRange range = (AddrRange){0x100000000,0x500000000};
                float search = 300;
                engine.JRScanMemory(range, &search, JR_Search_Type_Float);
                float Nearsearch = 3;
                engine.JRNearBySearch(0x150,&Nearsearch,JR_Search_Type_Float);
                float Nearsearch1 = 25;
                engine.JRNearBySearch(0x150,&Nearsearch1,JR_Search_Type_Float);
                float Nearsearch2 = 4;
                engine.JRNearBySearch(0x30,&Nearsearch2,JR_Search_Type_Float);
                float Nearsearch3 = 1;
                engine.JRNearBySearch(0x50,&Nearsearch3,JR_Search_Type_Float);
                float search3 = 300;
                engine.JRScanMemory(range, &search3, JR_Search_Type_Float);
                vector<void*>results = engine.getAllResults();
                float modify = 0.01;
                float modify11 = 9999;
                for(int i =0;i<results.size();i++){
                    engine.JRWriteMemory((unsigned long long)(results[i]),&modify11,JR_Search_Type_Float);
                    engine.JRWriteMemory((unsigned long long)(results[i])-136,&modify,JR_Search_Type_Float);
                    engine.JRWriteMemory((unsigned long long)(results[i])-120,&modify,JR_Search_Type_Float);
                }
            });
        }
    }
    ImGui::SameLine();
    if (ImGui::Checkbox("UZI瞬击", &_UZI瞬击)) {
        if (self.UZI瞬击) {
            dispatch_queue_t queue = dispatch_queue_create("net.bujige.testQueue", DISPATCH_QUEUE_SERIAL);
            dispatch_async(queue, ^{
                JRMemoryEngine engine = JRMemoryEngine(mach_task_self());
                AddrRange range = (AddrRange){0x100000000,0x500000000};
                float search = 320;
                engine.JRScanMemory(range, &search, JR_Search_Type_Float);
                float Nearsearch = 2;
                engine.JRNearBySearch(0x150,&Nearsearch,JR_Search_Type_Float);
                float Nearsearch1 = 30;
                engine.JRNearBySearch(0x150,&Nearsearch1,JR_Search_Type_Float);
                float Nearsearch2 = 4;
                engine.JRNearBySearch(0x80,&Nearsearch2,JR_Search_Type_Float);
                float Nearsearch3 = 5;
                engine.JRNearBySearch(0x50,&Nearsearch3,JR_Search_Type_Float);
                float search3 = 320;
                engine.JRScanMemory(range, &search3, JR_Search_Type_Float);
                vector<void*>results = engine.getAllResults();
                float modify = 0.01;
                float modify11 = 9999;
                for(int i =0;i<results.size();i++){
                    engine.JRWriteMemory((unsigned long long)(results[i]),&modify11,JR_Search_Type_Float);
                    engine.JRWriteMemory((unsigned long long)(results[i])-136,&modify,JR_Search_Type_Float);
                    engine.JRWriteMemory((unsigned long long)(results[i])-120,&modify,JR_Search_Type_Float);
                    engine.JRWriteMemory((unsigned long long)(results[i])-64,&modify,JR_Search_Type_Float);
                }
            });
        }
    }
    ImGui::SameLine();
    if (ImGui::Checkbox("FAMAS瞬击", &_FAMAS瞬击)) {
        if (self.FAMAS瞬击) {
            dispatch_queue_t queue = dispatch_queue_create("net.bujige.testQueue", DISPATCH_QUEUE_SERIAL);
            dispatch_async(queue, ^{
                JRMemoryEngine engine = JRMemoryEngine(mach_task_self());
                AddrRange range = (AddrRange){0x100000000,0x500000000};
                float search = 360;
                engine.JRScanMemory(range, &search, JR_Search_Type_Float);
                float Nearsearch = 3;
                engine.JRNearBySearch(0x150,&Nearsearch,JR_Search_Type_Float);
                float Nearsearch1 = 25;
                engine.JRNearBySearch(0x150,&Nearsearch1,JR_Search_Type_Float);
                float Nearsearch2 = 4;
                engine.JRNearBySearch(0x50,&Nearsearch2,JR_Search_Type_Float);
                float Nearsearch3 = 5;
                engine.JRNearBySearch(0x50,&Nearsearch3,JR_Search_Type_Float);
                float search3 = 360;
                engine.JRScanMemory(range, &search3, JR_Search_Type_Float);
                vector<void*>results = engine.getAllResults();
                float modify = 0.01;
                float modify11 = 9999;
                for(int i =0;i<results.size();i++){
                    engine.JRWriteMemory((unsigned long long)(results[i]),&modify11,JR_Search_Type_Float);
                    engine.JRWriteMemory((unsigned long long)(results[i])-136,&modify,JR_Search_Type_Float);
                    engine.JRWriteMemory((unsigned long long)(results[i])-120,&modify,JR_Search_Type_Float);
                }
            });
        }
    }
    
    if (ImGui::Checkbox("M4瞬击", &_M4瞬击)) {
        if (self.M4瞬击) {
            dispatch_queue_t queue = dispatch_queue_create("net.bujige.testQueue", DISPATCH_QUEUE_SERIAL);
            dispatch_async(queue, ^{
                JRMemoryEngine engine = JRMemoryEngine(mach_task_self());
                AddrRange range = (AddrRange){0x100000000,0x500000000};
                float search = 830;
                engine.JRScanMemory(range, &search, JR_Search_Type_Float);
                float Nearsearch = 6;
                engine.JRNearBySearch(0x150,&Nearsearch,JR_Search_Type_Float);
                float Nearsearch1 = 35;
                engine.JRNearBySearch(0x150,&Nearsearch1,JR_Search_Type_Float);
                float Nearsearch2 = 4;
                engine.JRNearBySearch(0x150,&Nearsearch2,JR_Search_Type_Float);
                float search3 = 830;
                engine.JRScanMemory(range, &search3, JR_Search_Type_Float);
                vector<void*>results = engine.getAllResults();
                float modify = 0.01;
                float modify11 = 9999;
                for(int i =0;i<results.size();i++){
                    engine.JRWriteMemory((unsigned long long)(results[i])-136,&modify,JR_Search_Type_Float);
                    engine.JRWriteMemory((unsigned long long)(results[i]),&modify11,JR_Search_Type_Float);
                    engine.JRWriteMemory((unsigned long long)(results[i])-120,&modify,JR_Search_Type_Float);
                }
            });
        }
    }
    ImGui::SameLine();
    if (ImGui::Checkbox("Ak瞬击", &_AK瞬击)) {
        if (self.AK瞬击) {
            dispatch_queue_t queue = dispatch_queue_create("net.bujige.testQueue", DISPATCH_QUEUE_SERIAL);
            dispatch_async(queue, ^{
                JRMemoryEngine engine = JRMemoryEngine(mach_task_self());
                AddrRange range = (AddrRange){0x110000000,0x500000000};
                float search = 735;
                engine.JRScanMemory(range, &search, JR_Search_Type_Float);
                float Nearsearch = 6;
                engine.JRNearBySearch(0x150,&Nearsearch,JR_Search_Type_Float);
                float Nearsearch1 = 40;
                engine.JRNearBySearch(0x150,&Nearsearch1,JR_Search_Type_Float);
                float Nearsearch2 = 4;
                engine.JRNearBySearch(0x50,&Nearsearch2,JR_Search_Type_Float);
                float Nearsearch3 = 8;
                engine.JRNearBySearch(0x50,&Nearsearch3,JR_Search_Type_Float);
                float search4 = 735;
                engine.JRScanMemory(range, &search4, JR_Search_Type_Float);
                vector<void*>results = engine.getAllResults();
                float modify = 0.01;
                float modify11 = 9999;
                for(int i =0;i<results.size();i++){
                    engine.JRWriteMemory((unsigned long long)(results[i])-136,&modify,JR_Search_Type_Float);
                    engine.JRWriteMemory((unsigned long long)(results[i]),&modify11,JR_Search_Type_Float);
                    engine.JRWriteMemory((unsigned long long)(results[i])-120,&modify,JR_Search_Type_Float);
                }
            });
        }
    }
    ImGui::SameLine();
    if (ImGui::Checkbox("QBZ瞬击", &_QBZ瞬击)) {
        if (self.QBZ瞬击) {
            dispatch_queue_t queue = dispatch_queue_create("net.bujige.testQueue", DISPATCH_QUEUE_SERIAL);
            dispatch_async(queue, ^{
                JRMemoryEngine engine = JRMemoryEngine(mach_task_self());
                AddrRange range = (AddrRange){0x100000000,0x500000000};
                float search = 790;
                engine.JRScanMemory(range, &search, JR_Search_Type_Float);
                float Nearsearch = 6;
                engine.JRNearBySearch(0x150,&Nearsearch,JR_Search_Type_Float);
                float Nearsearch1 = 35;
                engine.JRNearBySearch(0x150,&Nearsearch1,JR_Search_Type_Float);
                float Nearsearch2 = 4;
                engine.JRNearBySearch(0x50,&Nearsearch2,JR_Search_Type_Float);
                float Nearsearch3 = 8;
                engine.JRNearBySearch(0x50,&Nearsearch3,JR_Search_Type_Float);
                float search3 = 790;
                engine.JRScanMemory(range, &search3, JR_Search_Type_Float);
                vector<void*>results = engine.getAllResults();
                float modify = 0.01;
                float modify11 = 9999;
                for(int i =0;i<results.size();i++){
                    engine.JRWriteMemory((unsigned long long)(results[i])-136,&modify,JR_Search_Type_Float);
                    engine.JRWriteMemory((unsigned long long)(results[i]),&modify11,JR_Search_Type_Float);
                    engine.JRWriteMemory((unsigned long long)(results[i])-120,&modify,JR_Search_Type_Float);
                }
            });
        }
    }
    ImGui::SameLine();
    if (ImGui::Checkbox("M762瞬击", &_M762瞬击)) {
        if (self.M762瞬击) {
            dispatch_queue_t queue = dispatch_queue_create("net.bujige.testQueue", DISPATCH_QUEUE_SERIAL);
            dispatch_async(queue, ^{
                JRMemoryEngine engine = JRMemoryEngine(mach_task_self());
                AddrRange range = (AddrRange){0x100000000,0x500000000};
                float search = 735;
                engine.JRScanMemory(range, &search, JR_Search_Type_Float);
                float Nearsearch = 15;
                engine.JRNearBySearch(0x150,&Nearsearch,JR_Search_Type_Float);
                float Nearsearch1 = 33;
                engine.JRNearBySearch(0x150,&Nearsearch1,JR_Search_Type_Float);
                float Nearsearch2 = 6;
                engine.JRNearBySearch(0x150,&Nearsearch2,JR_Search_Type_Float);
                float Nearsearch3 = 10;
                engine.JRNearBySearch(0x150,&Nearsearch3,JR_Search_Type_Float);
                float Nearsearch4 = 4;
                engine.JRNearBySearch(0x50,&Nearsearch4,JR_Search_Type_Float);
                float search3 = 735;
                engine.JRScanMemory(range, &search3, JR_Search_Type_Float);
                vector<void*>results = engine.getAllResults();
                float modify = 0.01;
                float modify11 = 9999;
                for(int i =0;i<results.size();i++){
                    engine.JRWriteMemory((unsigned long long)(results[i])-144,&modify,JR_Search_Type_Float);
                    engine.JRWriteMemory((unsigned long long)(results[i])-148,&modify,JR_Search_Type_Float);
                    engine.JRWriteMemory((unsigned long long)(results[i]),&modify11,JR_Search_Type_Float);
                    engine.JRWriteMemory((unsigned long long)(results[i])-136,&modify,JR_Search_Type_Float);
                }
            });
        }
    }
    if (ImGui::Checkbox("散弹瞬击", &_散弹一套)) {
     if (self.散弹一套) {
         dispatch_queue_t queue = dispatch_queue_create("net.bujige.testQueue", DISPATCH_QUEUE_SERIAL);
         dispatch_async(queue, ^{
                 JRMemoryEngine engine = JRMemoryEngine(mach_task_self());
                 AddrRange range = (AddrRange){0x00000000,0x180000000};
                 float search = 300;
                 engine.JRScanMemory(range, &search, JR_Search_Type_Float);
                 float Nearsearch = 300;
                 engine.JRNearBySearch(0x100,&Nearsearch,JR_Search_Type_Float);
                 float Nearsearch1 = 15;
                 engine.JRNearBySearch(0x100,&Nearsearch1,JR_Search_Type_Float);
                 float Nearsearch2 = 3;
                 engine.JRNearBySearch(0x100,&Nearsearch2,JR_Search_Type_Float);
                 float Nearsearch3 = 8;
                 engine.JRNearBySearch(0x100,&Nearsearch3,JR_Search_Type_Float);
                 float search3 = 60;
                 engine.JRScanMemory(range, &search3, JR_Search_Type_Float);
                 vector<void*>results = engine.getAllResults();
                 float modify = 9999;
                 for(int i =0;i<results.size();i++){
                     engine.JRWriteMemory((unsigned long long)(results[i]),&modify,JR_Search_Type_Float);
                 }
             });
         }
    }ImGui::SameLine();
    if (ImGui::Checkbox("RPG瞬爆", &_RPG瞬爆)) {
        if (self.RPG瞬爆) {
            dispatch_queue_t queue = dispatch_queue_create("net.bujige.testQueue", DISPATCH_QUEUE_SERIAL);
            dispatch_async(queue, ^{
                JRMemoryEngine engine = JRMemoryEngine(mach_task_self());
                AddrRange range = (AddrRange){0x100000000,0x160000000};
                float search = 3;
                engine.JRScanMemory(range, &search, JR_Search_Type_Float);
                float Nearsearch = 35;
                engine.JRNearBySearch(0x10,&Nearsearch,JR_Search_Type_Float);
                float Nearsearch1 = 20;
                engine.JRNearBySearch(0x100,&Nearsearch1,JR_Search_Type_Float);
                vector<void*>results = engine.getAllResults();
                float modify = 0;
                for(int i =0;i<results.size();i++){
                    engine.JRWriteMemory((unsigned long long)(results[i]),&modify,JR_Search_Type_Float);
                }
                float Nearsearch2 = 40;
                engine.JRNearBySearch(0x100,&Nearsearch2,JR_Search_Type_Float);
                float search1 = 40;
                engine.JRScanMemory(range, &search1, JR_Search_Type_Float);
                vector<void*>results1 = engine.getAllResults();
                float modify1 = 99999;
                for(int i =0;i<results.size();i++){
                    engine.JRWriteMemory((unsigned long long)(results1[i]),&modify1,JR_Search_Type_Float);
                }
            });
        }
    }
    ImGui::SameLine();
    if (ImGui::Checkbox("榴弹瞬爆", &_榴弹瞬爆)) {
        if (self.榴弹瞬爆) {
            dispatch_queue_t queue = dispatch_queue_create("net.bujige.testQueue", DISPATCH_QUEUE_SERIAL);
            dispatch_async(queue, ^{
                JRMemoryEngine engine = JRMemoryEngine(mach_task_self());
                AddrRange range = (AddrRange){0x100000000,0x160000000};
                uint64_t search = 4728779609789274522;
                engine.JRScanMemory(range, &search, JR_Search_Type_SLong);
                vector<void*>results = engine.getAllResults();
                uint64_t modify = 1050253722;
                for(int i =0;i<results.size();i++){
                    engine.JRWriteMemory((unsigned long long)(results[i]),&modify,JR_Search_Type_SLong);
                }
                float Nearsearch2 = 25;
                engine.JRNearBySearch(0x100,&Nearsearch2,JR_Search_Type_Float);
                float search2 = 25;
                engine.JRScanMemory(range, &search2, JR_Search_Type_Float);
                vector<void*>results1 = engine.getAllResults();
                float modify1 = 99999;
                for(int i =0;i<results.size();i++){
                    engine.JRWriteMemory((unsigned long long)(results1[i]),&modify1,JR_Search_Type_Float);
                }
            });
        }
    }
    
    
}

/// 绘制透视
Color color = Color::白色;
- (void)drawOverlay
{
    if (!self.总开关) {
        return;
    }
    if (self.自瞄开关 || self.追踪开关) {
        [self drawCircleWithCenter:ImVec2(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5) radius:self.自瞄追踪范围大小 color:Color::浅绿色 numSegments:100 thicknes:1];
    }
    
    NSString *playerCount = [NSString stringWithFormat:@"%zd", [ImGuiView getInstance].playerList.count];
    [self drawTextWithText:playerCount pos:ImVec2(SCREEN_WIDTH * 0.5, 25) isCentered:true color:Color::红色 outline:true fontSize:30];

    if (![ImGuiView getInstance].playerList.count) {
        return;
    }
    
    for (JFPlayer *player in [ImGuiView getInstance].playerList) {
        if (player.roleId == [ImGuiView getInstance].localPlayer.roleId ||
            player.distance <= 0 ||
            player.distance >= self.绘制距离 ||
            player.hp <= 0) {
            continue;
        }
        
        if (!player.isVisible) {
            color = Color::酸橙绿;
        }else{
            color = Color::红色;
        }
        
        if ((self.自瞄开关 || self.追踪开关) && player.最佳目标) {
            [self drawCircleFilledWithCenter:ImVec2(player.box.origin.x + player.box.size.width * 0.5, player.box.origin.y + player.box.size.height * 0.5) radius:2 color:Color::红色 numSegments:20];
            
            [self drawLineWithStartPoint:ImVec2(SCREEN_WIDTH * 0.5,SCREEN_HEIGHT * 0.5)
                endPoint:ImVec2(player.box.origin.x + player.box.size.width * 0.5, player.box.origin.y + player.box.size.height * 0.5) color:Color::红色 thicknes:0.1];// 自瞄连线
                        
        }
        
        if (self.信息开关) {
            [self textEsp:player distanceColor:color];
        }
        
        if (self.血量开关) {
            [self hpBarEsp:player];
        }
        if (self.方框开关) {
            [self drawRectWithPos:ImVec2(player.box.origin.x, player.box.origin.y) size:ImVec2(player.box.size.width, player.box.size.height) color:color thicknes:1];
        }
        
        if (self.射线开关) {
            float offset = 0;
            if (self.信息开关 || self.血量开关) {
                offset += 10;
            }
            if (self.信息开关) {
                offset += 20;
            }
            
            [self drawLineWithStartPoint:ImVec2(SCREEN_WIDTH * 0.5, 55) endPoint:ImVec2(CGRectGetMidX(player.box), CGRectGetMinY(player.box) - offset) color:color thicknes:1];
        }
        
    }
    
}
- (void)hpBarEsp:(JFPlayer *)player
{
    float rate = 1.0f * player.hp / player.maxHp;
    rate = MIN(1.0f, rate);
    float width = 90;//宽度 长短数值越大越长反之越短
    float height = 3;//高度 粗细数值越大越粗反之越细
    float x = CGRectGetMidX(player.box) - width * 0.5;//左右
    float y = CGRectGetMinY(player.box) - height - 5;//上下 数值越大越往上反之越往下
    
    Color color = Color::浅绿色;
    if (rate < 0.35) {
        color = Color::红色;
    } else if (rate < 0.75) {
        color = Color::橙色;
    }

    //血条
    [self drawRectFilledWithPos:ImVec2(x, y) size:ImVec2(width * rate, height) color:color];//
        
    NSString *hp = [NSString stringWithFormat:@"%d  /  %d", player.hp, player.maxHp];
    [self drawTextWithText:hp
                       pos:ImVec2(CGRectGetMidX(player.box), y - 1)
                isCentered:true
                     color:Color::黄色
                   outline:false
                  fontSize:7.5];
    
}

- (void)textEsp:(JFPlayer *)player distanceColor:(Color)distanceColor
{
    float width = 90;
    float height = 12;
    float x = CGRectGetMidX(player.box) - width * 0.5;
    float y = CGRectGetMinY(player.box) - height - 8;
    
    float teamNoWidth = 15;
    [self drawRectFilledWithPos:ImVec2(x, y) size:ImVec2(width, height) color:Color(128,128,128,100)];//名字背景框
    [self drawRectFilledWithPos:ImVec2(x, y) size:ImVec2(teamNoWidth, height) color:Color::翠绿色];//ID背景框
    
    NSString *groupId = [NSString stringWithFormat:@"%d", player.groupId];
    [self drawTextWithText:groupId
                       pos:ImVec2(x + teamNoWidth * 0.5, y + 1.5)//队编位置调整
                isCentered:true
                     color:Color::白色//修改队编颜色
                   outline:false
                  fontSize:9];
       
    NSMutableString *name = [NSMutableString stringWithFormat:@"%@", player.name];
    if (player.offline) {
        [name appendString:@" [离线]"];
    }
    [self drawTextWithText:name
                       pos:ImVec2(x + teamNoWidth + 2, y + 1.5)//敌人名字位置调整
                isCentered:false
                     color:Color::绿色//修改名字颜色
                   outline:true
                  fontSize:9];
    
    
    NSString *distance;
    if (self.手持开关){
        distance = [NSString stringWithFormat:@"[ %dm ]    [ %@ ]", player.distance ,player.holdgunname];
    }else{
        distance = [NSString stringWithFormat:@"[ %dm ]", player.distance];
    }
    ImVec2 distanceSize = _espFont->CalcTextSizeA(15, MAXFLOAT, 0.0f, [distance UTF8String]);
    [self drawTextWithText:distance
                       pos:ImVec2(CGRectGetMidX(player.box), y - distanceSize.y +5)
                isCentered:true
                     color:Color::白色//修改距离颜色
                   outline:false
                  fontSize:9];
}

#pragma mark - 封装的绘制方法
- (void)drawLineWithStartPoint:(ImVec2)startPoint endPoint:(ImVec2)endPoint color:(Color)color thicknes:(float)thicknes
{
    ImGui::GetOverlayDrawList()->AddLine(startPoint, endPoint, [self getImU32:color], thicknes);
}

- (void)drawCircleWithCenter:(ImVec2)center radius:(float)radius color:(Color)color numSegments:(int)numSegments thicknes:(float)thicknes
{
    ImGui::GetOverlayDrawList()->AddCircle(center, radius, [self getImU32:color], numSegments, thicknes);
}

- (void)drawCircleFilledWithCenter:(ImVec2)center radius:(float)radius color:(Color)color numSegments:(int)numSegments
{
    ImGui::GetOverlayDrawList()->AddCircleFilled(center, radius, [self getImU32:color], numSegments);
}

- (void)drawTextWithText:(NSString *)text pos:(ImVec2)pos isCentered:(bool)isCentered color:(Color)color outline:(bool)outline fontSize:(float)fontSize
{
    const char *str = [text UTF8String];
    ImVec2 vec2 = pos;
    if (isCentered) {
        ImVec2 textSize = _espFont->CalcTextSizeA(fontSize, MAXFLOAT, 0.0f, str);
        vec2.x -= textSize.x * 0.5f;
    }
    if (outline)
    {
        ImU32 outlineColor = [self getImU32:Color::黑色];
        ImGui::GetOverlayDrawList()->AddText(_espFont, fontSize, ImVec2(vec2.x + 1, vec2.y + 1), outlineColor, str);
        ImGui::GetOverlayDrawList()->AddText(_espFont, fontSize, ImVec2(vec2.x - 1, vec2.y - 1), outlineColor, str);
        ImGui::GetOverlayDrawList()->AddText(_espFont, fontSize, ImVec2(vec2.x + 1, vec2.y - 1), outlineColor, str);
        ImGui::GetOverlayDrawList()->AddText(_espFont, fontSize, ImVec2(vec2.x - 1, vec2.y + 1), outlineColor, str);
    }
    ImGui::GetOverlayDrawList()->AddText(_espFont, fontSize, vec2, [self getImU32:color], str);
}

- (void)drawRectWithPos:(ImVec2)pos size:(ImVec2)size color:(Color)color thicknes:(float)thicknes
{
    ImGui::GetOverlayDrawList()->AddRect(pos, ImVec2(pos.x + size.x, pos.y + size.y), [self getImU32:color], 0, 0, thicknes);
}

- (void)drawRectFilledWithPos:(ImVec2)pos size:(ImVec2)size color:(Color)color
{
    ImGui::GetOverlayDrawList()->AddRectFilled(pos, ImVec2(pos.x + size.x, pos.y + size.y), [self getImU32:color], 0, 0);
}

- (ImU32)getImU32:(Color)color
{
    return ((color.a & 0xff) << 24) + ((color.b & 0xff) << 16) + ((color.g & 0xff) << 8) + (color.r & 0xff);
}

#pragma mark - Touch Event
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.renderer handleEvent:event view:self];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.renderer handleEvent:event view:self];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.renderer handleEvent:event view:self];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.renderer handleEvent:event view:self];
}

@end
