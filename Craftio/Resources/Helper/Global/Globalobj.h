
#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

@interface Globalobj : NSObject
+(Globalobj*)sharedCenter;
+ (void)callAPIwithURL_PostRequest:(NSString *)strURL completion:(void(^)(id responseObject, BOOL sucess))callback;
+(NSAttributedString*)setTextFieldPlaceHolder:(NSString*)string;
- (BOOL)validateEmailWithString:(NSString*)email;
+ (void)showToast:(NSString *)strMessage;
-(BOOL)checkInternetConnectivity;
+ (NSString *)timeFormatted:(int)totalSeconds;
+(NSString *)setlabelasstring:(NSString*)strletter secondname:(NSString*)strsecondname;
- (NSString*) createSHA512:(NSString *)source;

@property (nonatomic, assign) BOOL isLoggedIn;
@property (strong, nonatomic) NSString *strDeviceID;
@property (strong, nonatomic) NSString *strUserID;

@property (strong, nonatomic) NSString *strCroppedVideoPath;
@property (strong, nonatomic) NSString *strCroppedAudioPath;

@property (nonatomic, assign) BOOL isComingFromFacebook;
@property (nonatomic, assign) BOOL isVideoInProcess;
@property (nonatomic, assign) BOOL isVideoLandscape;


@end
