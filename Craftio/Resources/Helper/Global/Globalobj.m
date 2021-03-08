
#define KGrayPlaceholderColor [UIColor colorWithHexString:@"4d4c4c"];
#define KRobotoLight @"ApercuPro-Bold"
#define KRobotoMedium @"ApercuPro-Medium"
#define KRobotoRegular @"ApercuPro"

#import "Globalobj.h"
#import <AVFoundation/AVFoundation.h>

#define KNetIsNotReachable ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus]==NotReachable)
#define KNetIsReachable ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] !=NotReachable)
#define KMSG_INTERNET_ISSUE @"Please turn on cellular data or correct wifi settings"
#define KMSG_server_is_not_responding @"The web server is not responding, Please try after some time!"


@implementation Globalobj
static Globalobj *sharedInstance = nil;

+ (Globalobj *)sharedCenter
{
    if (sharedInstance == nil)
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedInstance = [[super allocWithZone:NULL] init];
        });
    }
    return sharedInstance;
}


+ (void)callAPIwithURL_PostRequest:(NSString *)strURL completion:(void(^)(id responseObject, BOOL sucess))callback
{
    
}

+(NSAttributedString*)setTextFieldPlaceHolder:(NSString*)string{
    
//    UIColor *color = KGrayPlaceholderColor;
//    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:string
//                                                                           attributes:@{
//                                                                                        NSForegroundColorAttributeName: color,
//                                                                                        NSFontAttributeName : [UIFont fontWithName:KRobotoLight size:15.0]
//                                                                                        }
//                                            ];
//    return attributedString;
    return @"";
    
}

+ (void)showToast:(NSString *)strMessage{
    
}

#pragma mark -
#pragma mark EmailValidation

- (BOOL)validateEmailWithString:(NSString*)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9._-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

#pragma mark - Check InternetContectivity


- (BOOL)checkInternetConnectivity
{
   return FALSE;
}

+ (NSString *)timeFormatted:(int)totalSeconds{
    
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    
    if (hours == 0) {
        return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
    }
    
    return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
}

+(NSString *)setlabelasstring:(NSString*)strletter secondname:(NSString*)strsecondname
{
    NSString *strstring;
    if (strletter.length>0)
    {
        strstring = [[strletter substringToIndex:2]uppercaseString];
    }
    return strstring;
}

- (NSString*) createSHA512:(NSString *)source {
    
    const char *cstr = [source cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:source.length];
    uint8_t digest[CC_SHA512_DIGEST_LENGTH];
    CC_SHA512(data.bytes, (CC_LONG)data.length, digest);
    NSMutableString* output = [NSMutableString  stringWithCapacity:CC_SHA512_DIGEST_LENGTH * 2];

    for(int i = 0; i < CC_SHA512_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    NSString *hash =  [[[output stringByReplacingOccurrencesOfString:@"<" withString:@""]stringByReplacingOccurrencesOfString:@">" withString:@""]stringByReplacingOccurrencesOfString:@" " withString:@""];

    return hash;
}


@end
