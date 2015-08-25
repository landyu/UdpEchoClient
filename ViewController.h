#import <UIKit/UIKit.h>


@interface ViewController : UIViewController
{
	IBOutlet UITextField *addrField;
	IBOutlet UITextField *portField;
	IBOutlet UITextField *messageField;
	IBOutlet UIWebView *webView;
}

- (IBAction)send:(id)sender;
- (IBAction)connect:(id)sender;
- (IBAction)Disconnect:(id)sender;
- (IBAction)LightA:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *uibLightA;
- (IBAction)jsonAction:(id)sender;

@end
