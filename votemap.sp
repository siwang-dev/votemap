#include <sourcemod>
#include <sdktools>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "1.0.7"
#define MAX_MAPS 256

// 地图数据结构
enum struct MapInfo {
    char name[64];           // 地图代码名
    char displayName[128];   // 显示名称
    char campaign[64];       // 战役名
    int chapter;             // 章节号
    bool isOfficial;         // 是否官方地图
}

// 官方战役地图列表
char g_sOfficialCampaigns[][] = {
    "c1m1_hotel", "c1m2_streets", "c1m3_mall", "c1m4_atrium",
    "c2m1_highway", "c2m2_fairgrounds", "c2m3_coaster", "c2m4_barns", "c2m5_concert",
    "c3m1_plankcountry", "c3m2_swamp", "c3m3_shantytown", "c3m4_plantation",
    "c4m1_milltown_a", "c4m2_sugarmill_a", "c4m3_sugarmill_b", "c4m4_milltown_b", "c4m5_milltown_escape",
    "c5m1_waterfront", "c5m2_park", "c5m3_cemetery", "c5m4_quarter", "c5m5_bridge",
    "c6m1_riverbank", "c6m2_bedlam", "c6m3_port",
    "c7m1_docks", "c7m2_barge", "c7m3_port",
    "c8m1_apartment", "c8m2_subway", "c8m3_sewers", "c8m4_interior", "c8m5_rooftop",
    "c9m1_alleys", "c9m2_lots",
    "c10m1_caves", "c10m2_drainage", "c10m3_ranchhouse", "c10m4_mainstreet", "c10m5_houseboat",
    "c11m1_greenhouse", "c11m2_offices", "c11m3_garage", "c11m4_terminal", "c11m5_runway",
    "c12m1_hilltop", "c12m2_traintunnel", "c12m3_bridge", "c12m4_barn", "c12m5_cornfield",
    "c13m1_alpinecreek", "c13m2_southpinestream", "c13m3_memorialbridge", "c13m4_cutthroatcreek",
    "c14m1_junkyard", "c14m2_lighthouse"
};

// 官方战役显示名称
char g_sOfficialNames[][] = {
    "死亡中心 - 第一章: 酒店", "死亡中心 - 第二章: 街道", "死亡中心 - 第三章: 购物中心", "死亡中心 - 第四章: 中厅",
    "黑色嘉年华 - 第一章: 高速公路", "黑色嘉年华 - 第二章: 游乐场", "黑色嘉年华 - 第三章: 过山车", "黑色嘉年华 - 第四章: 谷仓", "黑色嘉年华 - 第五章: 音乐会",
    "沼泽激战 - 第一章: 乡村", "沼泽激战 - 第二章: 沼泽", "沼泽激战 - 第三章: 贫民窟", "沼泽激战 - 第四章: 种植园",
    "暴风骤雨 - 第一章: 密尔城", "暴风骤雨 - 第二章: 糖厂", "暴风骤雨 - 第三章: 逃离糖厂", "暴风骤雨 - 第四章: 重返小镇", "暴风骤雨 - 第五章: 逃离小镇",
    "教区 - 第一章: Waterfront", "教区 - 第二章: 公园", "教区 - 第三章: 墓地", "教区 - 第四章: French Quarter", "教区 - 第五章: 大桥",
    "消逝 - 第一章: 河岸", "消逝 - 第二章: 地下", "消逝 - 第三章: 港口",
    "牺牲 - 第一章: 码头", "牺牲 - 第二章: 驳船", "牺牲 - 第三章: 港口",
    "毫不留情 - 第一章: 公寓", "毫不留情 - 第二章: 地铁", "毫不留情 - 第三章: 下水道", "毫不留情 - 第四章: 医院", "毫不留情 - 第五章: 屋顶",
    "坠机险途 - 第一章: 小巷", "坠机险途 - 第二章: 卡车停车场",
    "死亡丧钟 - 第一章: 洞穴", "死亡丧钟 - 第二章: 排水沟", "死亡丧钟 - 第三章: 牧场", "死亡丧钟 - 第四章: 主街", "死亡丧钟 - 第五章: 船屋",
    "静寂时分 - 第一章: 花房", "静寂时分 - 第二章: 办公楼", "静寂时分 - 第三章: 车库", "静寂时分 - 第四章: 航站楼", "静寂时分 - 第五章: 跑道",
    "血腥收获 - 第一章: 山顶", "血腥收获 - 第二章: 火车隧道", "血腥收获 - 第三章: 桥梁", "血腥收获 - 第四章: 谷仓", "血腥收获 - 第五章: 玉米地",
    "刺骨寒溪 - 第一章: 高山溪流", "刺骨寒溪 - 第二章: 南松溪", "刺骨寒溪 - 第三章: 纪念大桥", "刺骨寒溪 - 第四章: 割喉溪",
    "临死一搏 - 第一章: 垃圾场", "临死一搏 - 第二章: 灯塔"
};

// 第三方地图配置文件路径
char g_sCustomMapsFile[PLATFORM_MAX_PATH];
ArrayList g_aCustomMaps;

// 投票相关
bool g_bVoteInProgress = false;
char g_sVoteMap[64];
char g_sVoteMapDisplay[128];
int g_iVoteYesCount = 0;
int g_iVoteNoCount = 0;

// ConVars
ConVar g_cvVoteTime;
ConVar g_cvVotePercentage;
ConVar g_cvAllowCustom;

public Plugin myinfo = {
    name = "L4D2 Map Changer",
    author = "Your Name",
    description = "Advanced map voting system with chapter selection for official and custom maps",
    version = PLUGIN_VERSION,
    url = ""
};

public void OnPluginStart() {
    RegConsoleCmd("sm_votemap", Command_VoteMap, "打开地图投票菜单");
    RegConsoleCmd("sm_mapvote", Command_VoteMap, "打开地图投票菜单 (别名)");
    
    RegAdminCmd("sm_forcemap", Command_ForceMap, ADMFLAG_CHANGEMAP, "强制更换地图 (无参数打开菜单)");
    RegAdminCmd("sm_fm", Command_ForceMap, ADMFLAG_CHANGEMAP, "强制更换地图快捷命令");
    RegAdminCmd("sm_amap", Command_AdminMapMenu, ADMFLAG_CHANGEMAP, "打开管理员地图菜单");
    
    g_cvVoteTime = CreateConVar("sm_votemap_time", "20", "投票持续时间(秒)", FCVAR_NOTIFY, true, 5.0, true, 60.0);
    g_cvVotePercentage = CreateConVar("sm_votemap_percentage", "0.6", "通过投票所需的百分比(0.0-1.0)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
    g_cvAllowCustom = CreateConVar("sm_votemap_allow_custom", "1", "允许投票第三方地图", FCVAR_NOTIFY, true, 0.0, true, 1.0);
    
    g_aCustomMaps = new ArrayList(sizeof(MapInfo));
    BuildPath(Path_SM, g_sCustomMapsFile, sizeof(g_sCustomMapsFile), "configs/l4d2_custom_maps.cfg");
    LoadCustomMaps();
    AutoExecConfig(true, "l4d2_votemap");
    
    PrintToServer("[VoteMap] 插件已加载 - 支持 %d 张官方地图", sizeof(g_sOfficialCampaigns));
}

public void OnPluginEnd() {
    delete g_aCustomMaps;
}

public void OnMapStart() {
    g_bVoteInProgress = false;
    g_sVoteMap[0] = '\0';
    g_sVoteMapDisplay[0] = '\0';
    g_iVoteYesCount = 0;
    g_iVoteNoCount = 0;
}

void LoadCustomMaps() {
    g_aCustomMaps.Clear();
    
    if (!FileExists(g_sCustomMapsFile)) {
        CreateExampleConfig();
        return;
    }
    
    KeyValues kv = new KeyValues("CustomMaps");
    if (!kv.ImportFromFile(g_sCustomMapsFile)) {
        LogError("无法加载自定义地图配置文件: %s", g_sCustomMapsFile);
        delete kv;
        return;
    }
    
    if (!kv.GotoFirstSubKey()) {
        delete kv;
        return;
    }
    
    do {
        MapInfo map;
        kv.GetSectionName(map.name, sizeof(map.name));
        kv.GetString("display", map.displayName, sizeof(map.displayName), map.name);
        kv.GetString("campaign", map.campaign, sizeof(map.campaign), "未知战役");
        map.chapter = kv.GetNum("chapter", 1);
        map.isOfficial = false;
        g_aCustomMaps.PushArray(map);
        PrintToServer("[VoteMap] 加载第三方地图: %s (%s)", map.name, map.displayName);
    } while (kv.GotoNextKey());
    
    delete kv;
    PrintToServer("[VoteMap] 已加载 %d 张第三方地图", g_aCustomMaps.Length);
}

void CreateExampleConfig() {
    File file = OpenFile(g_sCustomMapsFile, "w");
    if (file == null) {
        LogError("无法创建配置文件: %s", g_sCustomMapsFile);
        return;
    }
    
    file.WriteLine("// L4D2 第三方地图配置文件");
    file.WriteLine("\"CustomMaps\"");
    file.WriteLine("{");
    file.WriteLine("    \"custom_map_1m1\"");
    file.WriteLine("    {");
    file.WriteLine("        \"display\"   \"自定义战役 - 第一章: 起点\"");
    file.WriteLine("        \"campaign\"  \"自定义战役\"");
    file.WriteLine("        \"chapter\"   \"1\"");
    file.WriteLine("    }");
    file.WriteLine("}");
    delete file;
}

// ==================== 普通玩家投票系统 ====================

public Action Command_VoteMap(int client, int args) {
    if (client == 0) {
        ReplyToCommand(client, "[VoteMap] 此命令只能在游戏中使用");
        return Plugin_Handled;
    }
    
    if (g_bVoteInProgress) {
        PrintToChat(client, "\x04[VoteMap] \x01当前已有投票正在进行中!");
        return Plugin_Handled;
    }
    
    ShowMainMenu(client);
    return Plugin_Handled;
}

void ShowMainMenu(int client) {
    Menu menu = new Menu(MenuHandler_Main);
    menu.SetTitle("=== 地图投票系统 ===\n选择地图类型:");
    menu.AddItem("official", "官方地图");
    
    if (g_cvAllowCustom.BoolValue && g_aCustomMaps.Length > 0) {
        menu.AddItem("custom", "第三方地图");
    }
    
    menu.ExitButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler_Main(Menu menu, MenuAction action, int param1, int param2) {
    if (action == MenuAction_Select) {
        char info[32];
        menu.GetItem(param2, info, sizeof(info));
        
        if (StrEqual(info, "official")) {
            ShowOfficialCampaignMenu(param1, false);
        } else if (StrEqual(info, "custom")) {
            ShowCustomCampaignMenu(param1, false);
        }
    } else if (action == MenuAction_End) {
        delete menu;
    }
    return 0;
}

// ==================== 管理员系统 ====================

public Action Command_ForceMap(int client, int args) {
    if (client == 0 && args < 1) {
        ReplyToCommand(client, "[VoteMap] 控制台用法: sm_forcemap <地图名>");
        return Plugin_Handled;
    }
    
    if (args >= 1) {
        char mapName[64];
        GetCmdArg(1, mapName, sizeof(mapName));
        
        if (!IsMapValid(mapName)) {
            ReplyToCommand(client, "[VoteMap] 错误: 地图 '%s' 不存在", mapName);
            return Plugin_Handled;
        }
        
        ShowActivity(client, "强制更换地图到 %s", mapName);
        LogAction(client, -1, "\"%L\" 强制更换地图到 \"%s\"", client, mapName);
        ServerCommand("changelevel %s", mapName);
        return Plugin_Handled;
    }
    
    if (client == 0) {
        ReplyToCommand(client, "[VoteMap] 请在游戏中使用此命令打开菜单");
        return Plugin_Handled;
    }
    
    ShowAdminMainMenu(client);
    return Plugin_Handled;
}

public Action Command_AdminMapMenu(int client, int args) {
    if (client == 0) {
        ReplyToCommand(client, "[VoteMap] 此命令只能在游戏中使用");
        return Plugin_Handled;
    }
    
    ShowAdminMainMenu(client);
    return Plugin_Handled;
}

void ShowAdminMainMenu(int client) {
    Menu menu = new Menu(MenuHandler_AdminMain);
    menu.SetTitle("=== 管理员换图系统 ===\n选择操作:");
    menu.AddItem("official", "[换图] 官方地图");
    
    if (g_aCustomMaps.Length > 0) {
        menu.AddItem("custom", "[换图] 第三方地图");
    }
    
    menu.AddItem("", "", ITEMDRAW_SPACER);
    menu.AddItem("vote", "[发起投票] 官方地图");
    
    if (g_cvAllowCustom.BoolValue && g_aCustomMaps.Length > 0) {
        menu.AddItem("votecustom", "[发起投票] 第三方地图");
    }
    
    menu.ExitButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler_AdminMain(Menu menu, MenuAction action, int param1, int param2) {
    if (action == MenuAction_Select) {
        char info[32];
        menu.GetItem(param2, info, sizeof(info));
        
        if (StrEqual(info, "official")) {
            ShowOfficialCampaignMenu(param1, true);
        } else if (StrEqual(info, "custom")) {
            ShowCustomCampaignMenu(param1, true);
        } else if (StrEqual(info, "vote")) {
            if (g_bVoteInProgress) {
                PrintToChat(param1, "\x04[VoteMap] \x01当前已有投票正在进行中!");
                ShowAdminMainMenu(param1);
                return 0;
            }
            ShowOfficialCampaignMenu(param1, false);
        } else if (StrEqual(info, "votecustom")) {
            if (g_bVoteInProgress) {
                PrintToChat(param1, "\x04[VoteMap] \x01当前已有投票正在进行中!");
                ShowAdminMainMenu(param1);
                return 0;
            }
            ShowCustomCampaignMenu(param1, false);
        }
    } else if (action == MenuAction_End) {
        delete menu;
    }
    return 0;
}

// ==================== 官方地图菜单 ====================

void ShowOfficialCampaignMenu(int client, bool isAdmin) {
    Menu menu = new Menu(MenuHandler_OfficialCampaign);
    
    if (isAdmin) {
        menu.SetTitle("=== [管理员] 官方战役 ===\n选择要切换到的战役:");
    } else {
        menu.SetTitle("=== 官方战役 ===\n选择战役:");
    }
    
    char sIsAdmin[2];
    IntToString(isAdmin ? 1 : 0, sIsAdmin, sizeof(sIsAdmin));
    menu.AddItem(sIsAdmin, "", ITEMDRAW_IGNORE);
    
    menu.AddItem("c1", "死亡中心");
    menu.AddItem("c2", "黑色嘉年华");
    menu.AddItem("c3", "沼泽激战");
    menu.AddItem("c4", "暴风骤雨");
    menu.AddItem("c5", "教区");
    menu.AddItem("c6", "消逝");
    menu.AddItem("c7", "牺牲");
    menu.AddItem("c8", "毫不留情");
    menu.AddItem("c9", "坠机险途");
    menu.AddItem("c10", "死亡丧钟");
    menu.AddItem("c11", "静寂时分");
    menu.AddItem("c12", "血腥收获");
    menu.AddItem("c13", "刺骨寒溪");
    menu.AddItem("c14", "临死一搏");
    
    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler_OfficialCampaign(Menu menu, MenuAction action, int param1, int param2) {
    if (action == MenuAction_Select) {
        char sIsAdmin[2];
        menu.GetItem(0, sIsAdmin, sizeof(sIsAdmin));
        bool isAdmin = StringToInt(sIsAdmin) == 1;
        
        char info[8];
        menu.GetItem(param2, info, sizeof(info));
        
        ShowOfficialChapterMenu(param1, info, isAdmin);
    } else if (action == MenuAction_Cancel) {
        char sIsAdmin[2];
        menu.GetItem(0, sIsAdmin, sizeof(sIsAdmin));
        bool isAdmin = StringToInt(sIsAdmin) == 1;
        
        if (isAdmin) {
            ShowAdminMainMenu(param1);
        } else {
            ShowMainMenu(param1);
        }
    } else if (action == MenuAction_End) {
        delete menu;
    }
    return 0;
}

void ShowOfficialChapterMenu(int client, const char[] campaign, bool isAdmin) {
    Menu menu = new Menu(MenuHandler_OfficialChapter);
    char title[128];
    
    if (isAdmin) {
        Format(title, sizeof(title), "=== [管理员] %s ===\n选择要切换到的章节:", GetCampaignDisplayName(campaign));
    } else {
        Format(title, sizeof(title), "=== %s ===\n选择章节:", GetCampaignDisplayName(campaign));
    }
    menu.SetTitle(title);
    
    char sIsAdmin[2];
    IntToString(isAdmin ? 1 : 0, sIsAdmin, sizeof(sIsAdmin));
    menu.AddItem(sIsAdmin, "", ITEMDRAW_IGNORE);
    menu.AddItem(campaign, "", ITEMDRAW_IGNORE);
    
    for (int i = 0; i < sizeof(g_sOfficialCampaigns); i++) {
        if (StrContains(g_sOfficialCampaigns[i], campaign, false) == 0) {
            char chapter[4];
            Format(chapter, sizeof(chapter), "%c", g_sOfficialCampaigns[i][3]);
            char display[128];
            Format(display, sizeof(display), "第 %s 章: %s", chapter, GetChapterShortName(g_sOfficialNames[i]));
            menu.AddItem(g_sOfficialCampaigns[i], display);
        }
    }
    
    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler_OfficialChapter(Menu menu, MenuAction action, int param1, int param2) {
    if (action == MenuAction_Select) {
        char sIsAdmin[2];
        menu.GetItem(0, sIsAdmin, sizeof(sIsAdmin));
        bool isAdmin = StringToInt(sIsAdmin) == 1;
        
        char mapName[64];
        menu.GetItem(param2, mapName, sizeof(mapName));
        
        if (isAdmin) {
            PerformMapChange(param1, mapName, true);
        } else {
            StartMapVote(param1, mapName, true);
        }
    } else if (action == MenuAction_Cancel) {
        char sIsAdmin[2];
        menu.GetItem(0, sIsAdmin, sizeof(sIsAdmin));
        bool isAdmin = StringToInt(sIsAdmin) == 1;
        
        ShowOfficialCampaignMenu(param1, isAdmin);
    } else if (action == MenuAction_End) {
        delete menu;
    }
    return 0;
}

// ==================== 第三方地图菜单 ====================

void ShowCustomCampaignMenu(int client, bool isAdmin) {
    Menu menu = new Menu(MenuHandler_CustomCampaign);
    
    if (isAdmin) {
        menu.SetTitle("=== [管理员] 第三方战役 ===\n选择要切换到的战役:");
    } else {
        menu.SetTitle("=== 第三方战役 ===\n选择地图:");
    }
    
    char sIsAdmin[2];
    IntToString(isAdmin ? 1 : 0, sIsAdmin, sizeof(sIsAdmin));
    menu.AddItem(sIsAdmin, "", ITEMDRAW_IGNORE);
    
    StringMap campaigns = new StringMap();
    for (int i = 0; i < g_aCustomMaps.Length; i++) {
        MapInfo map;
        g_aCustomMaps.GetArray(i, map);
        bool exists;
        if (!campaigns.GetValue(map.campaign, exists)) {
            menu.AddItem(map.campaign, map.campaign);
            campaigns.SetValue(map.campaign, true);
        }
    }
    delete campaigns;
    
    if (menu.ItemCount <= 1) {
        PrintToChat(client, "\x04[VoteMap] \x01没有可用的第三方地图");
        delete menu;
        if (isAdmin) {
            ShowAdminMainMenu(client);
        } else {
            ShowMainMenu(client);
        }
        return;
    }
    
    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler_CustomCampaign(Menu menu, MenuAction action, int param1, int param2) {
    if (action == MenuAction_Select) {
        char sIsAdmin[2];
        menu.GetItem(0, sIsAdmin, sizeof(sIsAdmin));
        bool isAdmin = StringToInt(sIsAdmin) == 1;
        
        char campaign[64];
        menu.GetItem(param2, campaign, sizeof(campaign));
        
        ShowCustomChapterMenu(param1, campaign, isAdmin);
    } else if (action == MenuAction_Cancel) {
        char sIsAdmin[2];
        menu.GetItem(0, sIsAdmin, sizeof(sIsAdmin));
        bool isAdmin = StringToInt(sIsAdmin) == 1;
        
        if (isAdmin) {
            ShowAdminMainMenu(param1);
        } else {
            ShowMainMenu(param1);
        }
    } else if (action == MenuAction_End) {
        delete menu;
    }
    return 0;
}

void ShowCustomChapterMenu(int client, const char[] campaign, bool isAdmin) {
    Menu menu = new Menu(MenuHandler_CustomChapter);
    char title[128];
    
    if (isAdmin) {
        Format(title, sizeof(title), "=== [管理员] %s ===\n选择要切换到的章节:", campaign);
    } else {
        Format(title, sizeof(title), "=== %s ===\n选择章节:", campaign);
    }
    menu.SetTitle(title);
    
    char sIsAdmin[2];
    IntToString(isAdmin ? 1 : 0, sIsAdmin, sizeof(sIsAdmin));
    menu.AddItem(sIsAdmin, "", ITEMDRAW_IGNORE);
    
    for (int i = 0; i < g_aCustomMaps.Length; i++) {
        MapInfo map;
        g_aCustomMaps.GetArray(i, map);
        
        if (StrEqual(map.campaign, campaign)) {
            char info[8];
            IntToString(i, info, sizeof(info));
            
            char display[128];
            Format(display, sizeof(display), "第 %d 章: %s", map.chapter, GetChapterShortName(map.displayName));
            
            menu.AddItem(info, display);
        }
    }
    
    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler_CustomChapter(Menu menu, MenuAction action, int param1, int param2) {
    if (action == MenuAction_Select) {
        char sIsAdmin[2];
        menu.GetItem(0, sIsAdmin, sizeof(sIsAdmin));
        bool isAdmin = StringToInt(sIsAdmin) == 1;
        
        char info[8];
        menu.GetItem(param2, info, sizeof(info));
        int index = StringToInt(info);
        
        MapInfo map;
        g_aCustomMaps.GetArray(index, map);
        
        if (isAdmin) {
            PerformMapChange(param1, map.name, false);
        } else {
            StartMapVote(param1, map.name, false);
        }
    } else if (action == MenuAction_Cancel) {
        char sIsAdmin[2];
        menu.GetItem(0, sIsAdmin, sizeof(sIsAdmin));
        bool isAdmin = StringToInt(sIsAdmin) == 1;
        
        ShowCustomCampaignMenu(param1, isAdmin);
    } else if (action == MenuAction_End) {
        delete menu;
    }
    return 0;
}

// ==================== 地图切换执行 ====================

void PerformMapChange(int admin, const char[] mapName, bool isOfficial) {
    if (!IsMapValid(mapName)) {
        PrintToChat(admin, "\x04[VoteMap] \x01错误: 地图 '%s' 不存在!", mapName);
        return;
    }
    
    char displayName[128];
    if (isOfficial) {
        for (int i = 0; i < sizeof(g_sOfficialCampaigns); i++) {
            if (StrEqual(g_sOfficialCampaigns[i], mapName)) {
                strcopy(displayName, sizeof(displayName), g_sOfficialNames[i]);
                break;
            }
        }
    } else {
        for (int i = 0; i < g_aCustomMaps.Length; i++) {
            MapInfo map;
            g_aCustomMaps.GetArray(i, map);
            if (StrEqual(map.name, mapName)) {
                strcopy(displayName, sizeof(displayName), map.displayName);
                break;
            }
        }
    }
    
    if (displayName[0] == '\0') {
        strcopy(displayName, sizeof(displayName), mapName);
    }
    
    ShowActivity(admin, "强制更换地图到 %s", displayName);
    LogAction(admin, -1, "\"%L\" 强制更换地图到 \"%s\" (%s)", admin, displayName, mapName);
    
    PrintToChatAll("\x04[VoteMap] \x03%N \x01正在更换地图到 \x05%s...", admin, displayName);
    
    DataPack pack = new DataPack();
    pack.WriteString(mapName);
    CreateTimer(2.0, Timer_DelayedChangeMap, pack);
}

public Action Timer_DelayedChangeMap(Handle timer, DataPack pack) {
    pack.Reset();
    char mapName[64];
    pack.ReadString(mapName, sizeof(mapName));
    delete pack;
    
    ServerCommand("changelevel %s", mapName);
    return Plugin_Stop;
}

// ==================== 投票系统 (参考 Tank 插件) ====================

void StartMapVote(int initiator, const char[] mapName, bool isOfficial) {
    if (g_bVoteInProgress) {
        PrintToChat(initiator, "\x04[VoteMap] \x01已有投票正在进行!");
        return;
    }
    
    if (!IsMapValid(mapName)) {
        PrintToChat(initiator, "\x04[VoteMap] \x01错误: 地图 '%s' 不存在!", mapName);
        return;
    }
    
    // 获取显示名称
    strcopy(g_sVoteMap, sizeof(g_sVoteMap), mapName);
    if (isOfficial) {
        for (int i = 0; i < sizeof(g_sOfficialCampaigns); i++) {
            if (StrEqual(g_sOfficialCampaigns[i], mapName)) {
                strcopy(g_sVoteMapDisplay, sizeof(g_sVoteMapDisplay), g_sOfficialNames[i]);
                break;
            }
        }
    } else {
        for (int i = 0; i < g_aCustomMaps.Length; i++) {
            MapInfo map;
            g_aCustomMaps.GetArray(i, map);
            if (StrEqual(map.name, mapName)) {
                strcopy(g_sVoteMapDisplay, sizeof(g_sVoteMapDisplay), map.displayName);
                break;
            }
        }
    }
    
    if (g_sVoteMapDisplay[0] == '\0') {
        strcopy(g_sVoteMapDisplay, sizeof(g_sVoteMapDisplay), mapName);
    }
    
    // 准备玩家列表
    int[] players = new int[MaxClients];
    int playerCount = 0;
    
    for (int i = 1; i <= MaxClients; i++) {
        if (IsClientInGame(i) && !IsFakeClient(i)) {
            players[playerCount++] = i;
        }
    }
    
    if (playerCount == 0) {
        PrintToChat(initiator, "\x04[VoteMap] \x01没有玩家在线，无法开始投票");
        return;
    }
    
    // 重置投票计数
    g_iVoteYesCount = 0;
    g_iVoteNoCount = 0;
    
    // 创建投票菜单
    Menu voteMenu = new Menu(MapVoteHandler);
    voteMenu.SetTitle("更换地图到: %s ?", g_sVoteMapDisplay);
    voteMenu.AddItem("yes", "同意");
    voteMenu.AddItem("no", "反对");
    voteMenu.ExitButton = false;
    
    // 显示给所有玩家
    voteMenu.DisplayVote(players, playerCount, g_cvVoteTime.IntValue);
    
    g_bVoteInProgress = true;
    
    PrintToChatAll("\x04[VoteMap] \x03%N \x01发起了地图更换投票", initiator);
    PrintToChatAll("\x04[VoteMap] \x01目标地图: \x05%s", g_sVoteMapDisplay);
    PrintToChatAll("\x04[VoteMap] \x01按 F1 同意 / F2 反对 (\x03%d\x01 秒)", g_cvVoteTime.IntValue);
    EmitSoundToAll("buttons/blip1.wav");
}

public int MapVoteHandler(Menu menu, MenuAction action, int param1, int param2) {
    switch (action) {
        case MenuAction_Select: {
            // 玩家投票时触发
            char info[32];
            menu.GetItem(param2, info, sizeof(info));
            
            if (StrEqual(info, "yes")) {
                g_iVoteYesCount++;
                PrintToChat(param1, "\x04[VoteMap] \x01你已投票: \x03同意");
            } else if (StrEqual(info, "no")) {
                g_iVoteNoCount++;
                PrintToChat(param1, "\x04[VoteMap] \x01你已投票: \x03反对");
            }
        }
        
        case MenuAction_VoteEnd: {
            // 投票结束，使用我们自己统计的票数
            ProcessVoteResult();
        }
        
        case MenuAction_VoteCancel: {
            if (param1 == VoteCancel_NoVotes) {
                PrintToChatAll("\x04[VoteMap] \x01投票失败：无人参与投票");
            } else {
                PrintToChatAll("\x04[VoteMap] \x01投票被取消");
            }
            g_bVoteInProgress = false;
            g_sVoteMap[0] = '\0';
            g_sVoteMapDisplay[0] = '\0';
        }
        
        case MenuAction_End: {
            delete menu;
        }
    }
    return 0;
}

void ProcessVoteResult() {
    float requiredPercent = g_cvVotePercentage.FloatValue;
    int totalVotes = g_iVoteYesCount + g_iVoteNoCount;
    float yesPercent = (totalVotes > 0) ? float(g_iVoteYesCount) / float(totalVotes) : 0.0;
    
    PrintToChatAll("\x04[VoteMap] \x01投票结果: \x03%d \x01同意 / \x03%d \x01反对 (共\x03%d\x01票, 需要 \x03%.0f%%\x01)", 
        g_iVoteYesCount, g_iVoteNoCount, totalVotes, requiredPercent * 100);
    
    if (yesPercent >= requiredPercent && g_iVoteYesCount > 0) {
        PrintToChatAll("\x04[VoteMap] \x01投票通过! 正在更换地图到 \x05%s...", g_sVoteMapDisplay);
        EmitSoundToAll("buttons/button14.wav");
        
        DataPack pack = new DataPack();
        pack.WriteString(g_sVoteMap);
        CreateTimer(5.0, Timer_VoteChangeMap, pack);
    } else {
        PrintToChatAll("\x04[VoteMap] \x01投票未通过!");
        g_bVoteInProgress = false;
        g_sVoteMap[0] = '\0';
        g_sVoteMapDisplay[0] = '\0';
    }
}

public Action Timer_VoteChangeMap(Handle timer, DataPack pack) {
    pack.Reset();
    char mapName[64];
    pack.ReadString(mapName, sizeof(mapName));
    delete pack;
    
    if (mapName[0] != '\0') {
        ServerCommand("changelevel %s", mapName);
    }
    g_bVoteInProgress = false;
    return Plugin_Stop;
}

// ==================== 工具函数 ====================

char[] GetCampaignDisplayName(const char[] prefix) {
    char name[32];
    if (StrEqual(prefix, "c1")) Format(name, sizeof(name), "死亡中心");
    else if (StrEqual(prefix, "c2")) Format(name, sizeof(name), "黑色嘉年华");
    else if (StrEqual(prefix, "c3")) Format(name, sizeof(name), "沼泽激战");
    else if (StrEqual(prefix, "c4")) Format(name, sizeof(name), "暴风骤雨");
    else if (StrEqual(prefix, "c5")) Format(name, sizeof(name), "教区");
    else if (StrEqual(prefix, "c6")) Format(name, sizeof(name), "消逝");
    else if (StrEqual(prefix, "c7")) Format(name, sizeof(name), "牺牲");
    else if (StrEqual(prefix, "c8")) Format(name, sizeof(name), "毫不留情");
    else if (StrEqual(prefix, "c9")) Format(name, sizeof(name), "坠机险途");
    else if (StrEqual(prefix, "c10")) Format(name, sizeof(name), "死亡丧钟");
    else if (StrEqual(prefix, "c11")) Format(name, sizeof(name), "静寂时分");
    else if (StrEqual(prefix, "c12")) Format(name, sizeof(name), "血腥收获");
    else if (StrEqual(prefix, "c13")) Format(name, sizeof(name), "刺骨寒溪");
    else if (StrEqual(prefix, "c14")) Format(name, sizeof(name), "临死一搏");
    else Format(name, sizeof(name), "未知战役");
    return name;
}

char[] GetChapterShortName(const char[] fullName) {
    char shortName[64];
    int pos = StrContains(fullName, ": ");
    if (pos != -1) {
        strcopy(shortName, sizeof(shortName), fullName[pos + 2]);
    } else {
        strcopy(shortName, sizeof(shortName), fullName);
    }
    return shortName;
}