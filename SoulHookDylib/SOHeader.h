//
//  SOHeader.h
//  SoulHook
//
//  Created by 月成 on 2019/6/24.
//  Copyright © 2019 fancy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <AVFoundation/AVFoundation.h>
#import "SOHookSettingController.h"
#import <objc/runtime.h>

#define SO_THEME_COLOR  [UIColor colorWithRed:37/255.0 green:212/255.0 blue:208/255.0 alpha:1]

CG_INLINE BOOL
ExchangeImplementationsInTwoClasses(Class _fromClass, SEL _originSelector, Class _toClass, SEL _newSelector) {
    if (!_fromClass || !_toClass) {
        return NO;
    }
    
    Method oriMethod = class_getInstanceMethod(_fromClass, _originSelector);
    Method newMethod = class_getInstanceMethod(_toClass, _newSelector);
    if (!newMethod) {
        return NO;
    }
    
    BOOL isAddedMethod = class_addMethod(_fromClass, _originSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));
    if (isAddedMethod) {
        // 如果 class_addMethod 成功了，说明之前 fromClass 里并不存在 originSelector，所以要用一个空的方法代替它，以避免 class_replaceMethod 后，后续 toClass 的这个方法被调用时可能会 crash
        IMP oriMethodIMP = method_getImplementation(oriMethod) ?: imp_implementationWithBlock(^(id selfObject) {});
        const char *oriMethodTypeEncoding = method_getTypeEncoding(oriMethod) ?: "v@:";
        class_replaceMethod(_toClass, _newSelector, oriMethodIMP, oriMethodTypeEncoding);
    } else {
        method_exchangeImplementations(oriMethod, newMethod);
    }
    return YES;
}

/// 交换同一个 class 里的 originSelector 和 newSelector 的实现，如果原本不存在 originSelector，则相当于给 class 新增一个叫做 originSelector 的方法
CG_INLINE BOOL
ExchangeImplementations(Class _class, SEL _originSelector, SEL _newSelector) {
    return ExchangeImplementationsInTwoClasses(_class, _originSelector, _class, _newSelector);
}


NS_ASSUME_NONNULL_BEGIN

//统计埋点
@interface TalkingData: NSObject
//AppId:A52B96856DC**********1B583A45945 channelId:AppStore
+ (void)sessionStarted:(NSString *)appKey withChannelId:(NSString *)channelId;

@end

//统计埋点
@interface KochavaTracker: NSObject
//appGUIDString = "kosoul-ios-********";
- (void)configureWithParametersDictionary:(NSDictionary *)dic delegate:(id)delegate;

@end

@interface AvatarModifyViewController: UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (copy, nonatomic) NSString *avatarOriginName;
@property (copy, nonatomic) NSString *avatarName;
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong, nullable) UIImage *customImage;

- (void)updateUserInfWithAvatarName:(NSString *)arg1 originAvatarName:(NSString *)arg2 image:(UIImage *)arg3 originImage:(UIImage *)arg4 svgInfo:(NSString *)arg5;

//上传
- (void)uploadToQiniu:(UIImage *)arg1 svginfo:(id)arg2 token:(NSDictionary *)arg3 imageName:(NSString *)arg4 completion:(dispatch_block_t)arg5;
- (void)uploadOriginAvatar:(UIImage *)arg1 avatarSVGInfo:(id)arg2;
- (void)uploadAvatar:(UIImage *)arg1 avatarSVGInfo:(id)arg2;
- (void)viewDidLoad;

//add
- (void)customAction:(UIButton *)sender;
- (void)cancelAction:(UIButton *)sender;
- (void)confirmAction:(UIButton *)sender;
- (UIImage *)resizeImage:(CGSize)size;

@end

@interface IMPTextMsg : NSObject

@property(copy, nonatomic) NSString *text;

@end


@interface IMPMsgCommand : NSObject

@property (strong, nonatomic) id commonMessage;
@property (strong, nonatomic) id expressionMessage;
@property (strong, nonatomic) id extChatMessage;
@property (strong, nonatomic) NSMutableDictionary *extMap;
@property (readonly, nonatomic) unsigned long long extMap_Count;
@property (strong, nonatomic) id fingerGuessMessage;
@property (copy, nonatomic) NSString *from;
@property (readonly, nonatomic) int msgOneOfCase;
@property (strong, nonatomic) id musicMessage;
@property (copy, nonatomic) NSString *notice;
@property (strong, nonatomic) id picMessage;
@property (strong, nonatomic) id picMessages;
@property (strong, nonatomic) id positionMessage;
@property (strong, nonatomic) id repostMessge;
@property (strong, nonatomic) id rollDiceMessage;
@property (strong, nonatomic) id sensitiveWordMessage;
@property (strong, nonatomic) id shareTagMessage;
@property (nonatomic) int snapChat;
@property (strong, nonatomic) id snapChatMessage;
@property (strong, nonatomic) id soulmateCardMessage;
@property (strong, nonatomic) IMPTextMsg *textMsg;
@property (nonatomic) long long timestamp;
@property (copy, nonatomic) NSString *to;
@property (nonatomic) int type;
@property (strong, nonatomic) id unReadCountMessage;
@property (strong, nonatomic) id userCardMessage;
@property (strong, nonatomic) id userExpressionMessage;
@property (strong, nonatomic) id videoMessage;
@property (strong, nonatomic) id voiceChatMessage;
@property (strong, nonatomic) id voiceMessage;

@end


@interface IMPCommandMessage : NSObject

@property (copy, nonatomic) NSString *acceptedMsgId;
@property (strong, nonatomic) id ackCommand;
@property (strong, nonatomic) id chatRoomCommand;
@property (nonatomic) int clientType;
@property (copy, nonatomic) NSString *cmdId;
@property (readonly, nonatomic) int cmdOneOfCase;
@property (copy, nonatomic) NSString *crc;
@property (copy, nonatomic) NSString *encryptedUserId;
@property (strong, nonatomic) id finCommand;
@property (strong, nonatomic) IMPMsgCommand *msgCommand;
@property (strong, nonatomic) id msgFin;
@property (strong, nonatomic) id notifyCommand;
@property (strong, nonatomic) id orderCommand;
@property (strong, nonatomic) id pshCommand;
@property (strong, nonatomic) id pushMessage;
@property (strong, nonatomic) id reportCommand;
@property (strong, nonatomic) id respCommand;
@property (copy, nonatomic) NSString *soulId;
@property (strong, nonatomic) id syncCommand;
@property (strong, nonatomic) id syncFin;
@property (strong, nonatomic) id transCommand;
@property (nonatomic) int type;


@end

//SoulSocket -> SocketService -> ChatTransCenter (deliverMessageListToIMService:)
//-> NBIMService(deliverMessageListToIMService:)
//收到消息 先走 pushMessageToExtor 再走 receiveMessage，hook后者 cmdmsg.type = 8(recall)时 将此cmd置空
@interface ChatTransCenter : NSObject

- (void)receiveMessage:(NSArray *)arg1;
- (void)pushMessageToExtor:(NSArray *)arg1;
- (void)sendCommandsMessage:(id)arg1 completion:(id)arg2;

@end

@interface ImageIMModel : NSObject

@property (nonatomic) long long mark;
@property (nonatomic, copy) NSString *url;

@end

@interface VoiceIMModel : NSObject

@property (nonatomic, copy) NSString *remoteURL;

@end

@interface VideoIMModel : NSObject

@property (nonatomic) long long mark;
@property (nonatomic, copy) NSString *url;

@end

@interface SOChatMessageModel : NSObject

@property (nonatomic) BOOL snap; //flash
@property (strong, nonatomic) ImageIMModel *imageIMModel;
@property (strong, nonatomic) VoiceIMModel *voiceIMModel;
@property (strong, nonatomic) VideoIMModel *videoIMModel;

@end

@interface SOPrivateChatTableViewCell : UITableViewCell

@property (nonatomic, strong) SOChatMessageModel *model;

@end

@interface SOUserDefinedEmoticonTableViewCell : SOPrivateChatTableViewCell

- (void)tapIamge;

@end


@interface SOChatFlashPhotoMessageTableViewCell : SOPrivateChatTableViewCell
{
    UIImageView *imageView;
    UIVisualEffectView *lookBeforeBgView;
    UIView *lookAferBgView;
    UIImageView *iconImage;
    UILabel *titleLabel;
    UILabel *photoMarklabel;
}

- (void)tapFlashPhoto;

@end

@interface SOChatPhotoMessageTableViewCell : SOPrivateChatTableViewCell

- (void)tapIamge;

@end

@interface SOChatAudioMessageTableViewCell : SOPrivateChatTableViewCell

- (void)run;

@end

@interface SOChatVideoMessageTableViewCell : SOPrivateChatTableViewCell

- (void)tap;
- (void)UpdateSubclassingUIWithChatMessageModel:(id)arg1;

@end

@interface SOLookFlashPhotoView : UIView

- (id)initWithFrame:(CGRect)arg1 WithImage:(NSData *)arg2 andIsSelf:(BOOL)arg3;
- (void)tapImage:(id)arg1;
- (void)longPressBgView:(UILongPressGestureRecognizer *)arg1;
- (void)tapbgView:(UITapGestureRecognizer *)arg1;

@end

//表情键盘
@interface SOCollectEmoticonView : UIView

@property (nonatomic, copy) void (^diceBlock)(void);
@property (nonatomic, copy) void (^fingerBlock)(void);

- (void)fingerAction:(UIButton *)sender;
- (void)diceAction:(UIButton *)sender;

- (void)collectionView:(UICollectionView *)arg1 didSelectItemAtIndexPath:(NSIndexPath *)arg2;

@end

//设置页
@interface MoveViewController : UIViewController

@property (nonatomic, strong) UITableView *tableView;

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface SOBuildMessageManager : NSObject

+ (id)buildRollDiceMessageTo:(NSString *)arg1 info:(NSString *)arg2;
+ (id)buildFingerGuessMessageTo:(NSString *)arg1 info:(NSString *)arg2;
+ (id)buildTextIMMessage:(NSString *)text to:(NSString *)toId senstive:(int)arg3 messageExt:(id)arg4;

@end


@interface SOUserInfoViewController : UIViewController

//@property (nonatomic) BOOL isMySoulmate;
@property (nonatomic) BOOL isCanCreatSoulMate;
//@property (nonatomic, copy) void (^intiveSoulmateBlock)(void);
//@property (nonatomic, copy) void (^cancelSoulmateBlock)(void);

- (void)cancelSoulMate;
- (void)tableView:(UITableView *)arg1 didSelectRowAtIndexPath:(NSIndexPath *)arg2;

@end


@interface AppDelegate : NSObject

- (void)showAdvert;
- (void)displayAdvert;

@end

@interface HeaderTwoViewController : UIViewController

@property (nonatomic, copy) NSString *headImageName;

- (void)confirmClick:(id)arg1;

@end

@interface SOHTTPSessionManager : NSObject

- (void)handleRequestSuccess:(id)arg1 task:(id)arg2 withSuccessHandler:(dispatch_block_t)arg3 withFailureHandler:(dispatch_block_t)arg4 withFinishHandler:(dispatch_block_t)arg5;

@end

@interface SOReleaseViewController : UIViewController

- (void)tagEditContainerViewDidLocationItemClick:(id)arg1;

@end

@interface SoulIMMessage : NSObject

@property (copy, nonatomic) NSArray *imageArray;
@property (copy, nonatomic) NSString *media;
@property (strong, nonatomic) id textIMModel;//TextIMModel
@property (nonatomic) BOOL fromMine;
@property (strong, nonatomic) NSError *error;
@property (copy, nonatomic) NSString *notice;
@property (copy, nonatomic) NSString *sessionId;
@property (copy, nonatomic) NSDictionary *extMap;
@property (strong, nonatomic) id unreadModel;//UnReadIMModel
@property (strong, nonatomic) id commenModel;//CommonIMModel
@property (strong, nonatomic) id musicShareModel; //MusicShareIMModel
@property (strong, nonatomic) id loationshareModel; //LocationShareIMModel
@property (strong, nonatomic) id shareTagModel; //ShareTagModel
@property (strong, nonatomic) id extModel; // ExtModel
@property (strong, nonatomic) id callVoiceIMModel; // CallVoiceIMModel
@property (strong, nonatomic) id fingerDiceIMModel; // FingerDiceIMModel
@property (strong, nonatomic) id voiceIMModel; // VoiceIMModel
@property (strong, nonatomic) id imageModel; // ImageIMModel
@property (strong, nonatomic) id videoModel; // VideoIMModel
@property (nonatomic) long long snap;
@property (nonatomic) long long isTagetRcDone;
@property (nonatomic) long long localId;
@property (copy, nonatomic) NSString *targetId;
@property (copy, nonatomic) NSString *msgId;
@property (copy, nonatomic) NSString *fromUid;
@property (copy, nonatomic) NSString *toUid;
@property (copy, nonatomic) NSDictionary *data;
@property (nonatomic) int type;

@end

@interface SOChatListViewController : UIViewController

@property (strong, nonatomic) NSMutableArray *dataArr;

@end

@interface SOChatListModel : NSObject

@property (nonatomic) BOOL isChatManuscript;
@property (nonatomic) BOOL isSelectedShare;
@property (nonatomic) BOOL isSelected;
@property (copy, nonatomic) NSString *birthday;
@property (nonatomic) BOOL isMutualFollow;
@property (copy, nonatomic) NSString *signatrue;
@property (copy, nonatomic) NSString *comeFromStr;
@property (copy, nonatomic) NSString *birthDay;
@property (nonatomic) long long lastMessageTime;
@property (nonatomic) int unreadMessagesCount;
@property (copy, nonatomic) NSString *soulmateStr;
@property (copy, nonatomic) NSString *contentStr;
@property (copy, nonatomic) NSString *alicsStr;
@property (copy, nonatomic) NSString *headIcon;
@property (copy, nonatomic) NSString *headBGColor;
@property (copy, nonatomic) NSString *userID;

@end

@interface SOMovieVC : UIViewController

@property (nonatomic) BOOL isFlashVideo;

@end

@interface ScrollerWebController : UIViewController <UIWebViewDelegate>

@property (strong, nonatomic) UIWebView *webView;
@property (copy, nonatomic) NSString *url;

- (void)actionForStartNetworkRequst:(id)arg1 callBack:(dispatch_block_t)arg2;
- (void)webViewDidFinishLoad:(UIWebView *)webView;
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error;

@end

@interface NBIMService : NSObject

+ (id)sharedInstance;
@property (strong, nonatomic) ChatTransCenter *chatCenter;

@end


@interface TextIMModel : NSObject

@property(nonatomic) long long sensitive;
@property(copy, nonatomic) NSString *text;

@end


typedef void (^progressBlock)(NSProgress *downloadProgress);
typedef void (^successBlock)(NSURLSessionDataTask *task, id _Nullable responseObject);
typedef void (^failureBlock)(NSURLSessionDataTask * _Nullable task, NSError *error);

@interface AFHTTPSessionManager : NSObject

- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
                                       URLString:(NSString *)URLString
                                      parameters:(id)parameters
                                  uploadProgress:(nullable progressBlock) uploadProgress
                                downloadProgress:(nullable progressBlock) downloadProgress
                                         success:(successBlock)success
                                         failure:(failureBlock)failure;

@end

@interface SOPrivateChatViewController : UIViewController
{
    UIMenuItem *_revokeflagMenuItem;
}
@property (nonatomic, copy)   NSString *chatId; //对方id
@property (nonatomic, strong) UIView *customNavBar; //SAPrivateChatNavBar
@property (nonatomic, strong) UIMenuController *menuController;

- (void)_showMenuViewIndexPath:(id)arg1;
- (void)boomAction:(UIButton *)sender;

@end

@interface NewTabBarController : UITabBarController

@end

@interface SoulUtils : NSObject

+ (id)makeWatermarkPhotoImageWithImage:(id)arg1 watermark:(id)arg2;
+ (id)makeWatermarkPhotoImageWithImage:(id)arg1;

@end

@interface FeelingViewController : UIViewController

@property (nonatomic, strong) UITableView *tableView;

- (void)scrollViewDidScroll:(UITableView *)scrollView;

- (void)myMeetingViewDidTap;
- (void)kuakuaWellDidTap;
- (void)clickHiddenTag;
- (void)updateMeSignature:(nullable UIButton *)arg1;
- (void)updateHeadImageView:(nullable UIImageView *)arg1 bgHeadColor:(nullable UIImageView *)arg2;
- (void)updateBgImageView:(nullable UIImageView *)arg1;

@end

@interface StrangerViewController : UIViewController

@property (nonatomic, strong) id nav; //SOCustomNav;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSDictionary *avatarModel;  //暂存数据用
@property (nonatomic, copy)   NSString *userID;

- (void)filterAction:(UIButton *)sender;
- (void)endRefresh;

@end

@interface SOWebItemModel : NSObject

@property(nonatomic, copy) NSString *url;
@property(nonatomic, strong) NSMutableDictionary *params;
@property(nonatomic, assign) long long urlType;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *userId;

//@property(nonatomic, copy) void (^avatarChangeBlock)(void);
//@property(nonatomic, copy) void (^avatarRegisterChangeBlock)(void);
//@property(nonatomic, copy) void (^makeFaceFinishNotPayBlock)(void);

@end

@interface SOUserBridgeManager : NSObject

@property(nonatomic, strong, nullable) UIImage *customImage;
- (UIImage *)resizeImage:(UIImage *)img size:(CGSize)size;

@end

@interface SOWebItemViewController : UIViewController <UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property(strong, nonatomic) SOWebItemModel *model;
@property(strong, nonatomic) UIView *webView;
@property(strong, nonatomic) SOUserBridgeManager *userBridge;

- (void)customAction:(UIButton *)sender;
- (UIImage *)resizeImage:(UIImage *)img size:(CGSize)size;

@end

@interface SOPersonalInfoVC : UIViewController

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface SoulChatLimitGiftViewController : UIViewController

@property(nonatomic, copy) void (^cancelBlock)(void);
- (void)clickCancelButtonAction:(id)arg1;

@end

@interface SOPost : NSObject

@property (nonatomic, assign) long long officialTag;
@property (nonatomic, copy)   NSString *content;

@end

@interface SOTopicInfoViewController : UIViewController

@property(nonatomic, copy) void (^deletePostBlock)(void);

@end

NS_ASSUME_NONNULL_END
