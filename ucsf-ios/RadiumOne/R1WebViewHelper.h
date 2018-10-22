#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface R1WebViewHelper : NSObject

+ (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;

@end
