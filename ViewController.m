#import "ViewController.h"
#import "GCDAsyncUdpSocket.h"
#import "DDLog.h"
#import <netinet/in.h>
#import <arpa/inet.h>
//#import <sys/socket.h>
#import "NRJson.h"

// Log levels: off, error, warn, info, verbose
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
unsigned int CID = 0;
unsigned char SC = 0;
unsigned int connectStatus = 0;


NSTimer *udpHeartBeat;

#define FORMAT(format, ...) [NSString stringWithFormat:(format), ##__VA_ARGS__]

@interface ViewController ()
{
	long tag;
	GCDAsyncUdpSocket *udpSocket;
	
	NSMutableString *log;
}

@end


@implementation ViewController

@synthesize uibLightA;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
	{
		log = [[NSMutableString alloc] init];
	}
	return self;
}

- (void)setupSocket
{
	// Setup our socket.
	// The socket will invoke our delegate methods using the usual delegate paradigm.
	// However, it will invoke the delegate methods on a specified GCD delegate dispatch queue.
	// 
	// Now we can configure the delegate dispatch queues however we want.
	// We could simply use the main dispatc queue, so the delegate methods are invoked on the main thread.
	// Or we could use a dedicated dispatch queue, which could be helpful if we were doing a lot of processing.
	// 
	// The best approach for your application will depend upon convenience, requirements and performance.
	// 
	// For this simple example, we're just going to use the main thread.
	
	udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
	
	NSError *error = nil;
	
	if (![udpSocket bindToPort:57032 error:&error])
	{
		[self logError:FORMAT(@"Error binding: %@", error)];
		return;
	}
	if (![udpSocket beginReceiving:&error])
	{
		[self logError:FORMAT(@"Error receiving: %@", error)];
		return;
	}
    
    udpHeartBeat = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(udpHeartBeatTimerFired) userInfo:nil repeats:YES];
    [udpHeartBeat setFireDate:[NSDate distantFuture]];
    
//    struct sockaddr_in sa;
//    
//    memset(&sa, 0, sizeof(sa));
//    
//    sa.sin_family = AF_INET;
//    sa.sin_port = htons(3671);
//    sa.sin_addr.s_addr=inet_addr("224.0.23.12");
//    sa.sin_len = sizeof(sa);
//    
//    NSData *dsa = [[NSData alloc] initWithBytes:&sa length:sa.sin_len];
    
//    if (![udpSocket connectToAddress:dsa error:&error]) {
//        
//        [self logError:FORMAT(@"Error connectToAddress: %@", error)];
//        return;
//    }
    
//    if (![udpSocket joinMulticastGroup:@"224.0.23.12" error:&error]) {
//        
//        [self logError:FORMAT(@"Error joinMulticastGroup: %@", error)];
//        return;
//    }
//    
//    if (![udpSocket joinMulticastGroup:@"224.0.0.252" error:&error]) {
//        
//        [self logError:FORMAT(@"Error joinMulticastGroup: %@", error)];
//        return;
//    }
//
//    
//    if (![udpSocket joinMulticastGroup:@"224.0.0.251" error:&error]) {
//        
//        [self logError:FORMAT(@"Error joinMulticastGroup: %@", error)];
//        return;
//    }

//
//    //[udpSocket sendData:data toHost:@"224.0.23.12" withTimeout:-1 tag:tag];
//    [udpSocket sendData:nil withTimeout:1 tag:tag];
//    tag++;
    
    
//    Byte searchByte[] = {0x06,0x10,0x02,0x01,0x00,0x0e,0x08,0x01,0xc0,0xa8,0x01,0x66,0x0e,0x57};
//    NSMutableData *data = [[NSMutableData alloc] init];
//    
//    data = [NSMutableData dataWithBytes:searchByte length:14];
//
//
//    //NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding];
//
//    [udpSocket sendData:data toHost:@"224.0.23.12" port:3671 withTimeout:-1 tag:tag];
//    tag++;


	[self logInfo:@"Ready"];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	if (udpSocket == nil)
	{
		[self setupSocket];
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self
	                                         selector:@selector(keyboardWillShow:)
	                                             name:UIKeyboardWillShowNotification 
	                                           object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
	                                         selector:@selector(keyboardWillHide:)
	                                             name:UIKeyboardWillHideNotification
	                                           object:nil];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)getKeyboardHeight:(float *)keyboardHeightPtr
        animationDuration:(double *)animationDurationPtr
                     from:(NSNotification *)notification
{
	float keyboardHeight;
	double animationDuration;
	
	// UIKeyboardCenterBeginUserInfoKey:
	// The key for an NSValue object containing a CGRect
	// that identifies the start frame of the keyboard in screen coordinates.
	
	CGRect beginRect = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
	CGRect endRect   = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	
	if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
	{
		keyboardHeight = ABS(beginRect.origin.x - endRect.origin.x);
	}
	else
	{
		keyboardHeight = ABS(beginRect.origin.y - endRect.origin.y);
	}
	
	// UIKeyboardAnimationDurationUserInfoKey
	// The key for an NSValue object containing a double that identifies the duration of the animation in seconds.
	
	animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
	
	if (keyboardHeightPtr) *keyboardHeightPtr = keyboardHeight;
	if (animationDurationPtr) *animationDurationPtr = animationDuration;
}

- (void)keyboardWillShow:(NSNotification *)notification
{
	float keyboardHeight = 0.0F;
	double animationDuration = 0.0;
	
	[self getKeyboardHeight:&keyboardHeight animationDuration:&animationDuration from:notification];
	
	CGRect webViewFrame = webView.frame;
	webViewFrame.size.height -= keyboardHeight;
	
	void (^animationBlock)(void) = ^{
		
		webView.frame = webViewFrame;
	};
	
	UIViewAnimationOptions options = 0;
	
	[UIView animateWithDuration:animationDuration
	                      delay:0.0
	                    options:options
	                 animations:animationBlock
	                 completion:NULL];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
	float keyboardHeight = 0.0F;
	double animationDuration = 0.0;
	
	[self getKeyboardHeight:&keyboardHeight animationDuration:&animationDuration from:notification];
	
	CGRect webViewFrame = webView.frame;
	webViewFrame.size.height += keyboardHeight;
	
	void (^animationBlock)(void) = ^{
		
		webView.frame = webViewFrame;
	};
	
	UIViewAnimationOptions options = 0;
	
	[UIView animateWithDuration:animationDuration
	                      delay:0.0
	                    options:options
	                 animations:animationBlock
	                 completion:NULL];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	DDLogError(@"webView:didFailLoadWithError: %@", error);
}

- (void)webViewDidFinishLoad:(UIWebView *)sender
{
	NSString *scrollToBottom = @"window.scrollTo(document.body.scrollWidth, document.body.scrollHeight);";
	
    [sender stringByEvaluatingJavaScriptFromString:scrollToBottom];
}

- (void)logError:(NSString *)msg
{
	NSString *prefix = @"<font color=\"#B40404\">";
	NSString *suffix = @"</font><br/>";
	
	[log appendFormat:@"%@%@%@\n", prefix, msg, suffix];
	
	NSString *html = [NSString stringWithFormat:@"<html><body>\n%@\n</body></html>", log];
	[webView loadHTMLString:html baseURL:nil];
}

- (void)logInfo:(NSString *)msg
{
	NSString *prefix = @"<font color=\"#6A0888\">";
	NSString *suffix = @"</font><br/>";
	
	[log appendFormat:@"%@%@%@\n", prefix, msg, suffix];
	
	NSString *html = [NSString stringWithFormat:@"<html><body>\n%@\n</body></html>", log];
	[webView loadHTMLString:html baseURL:nil];
}

- (void)logMessage:(NSString *)msg
{
	NSString *prefix = @"<font color=\"#000000\">";
	NSString *suffix = @"</font><br/>";
	
	[log appendFormat:@"%@%@%@\n", prefix, msg, suffix];
	
	NSString *html = [NSString stringWithFormat:@"<html><body>%@</body></html>", log];
	[webView loadHTMLString:html baseURL:nil];
}

- (IBAction)send:(id)sender
{
	NSString *host = addrField.text;
    NSError *error = nil;
    
    //NSMutableArray * messages;
    Byte searchByte[] = {0x06,0x10,0x02,0x01,0x00,0x0e,0x08,0x01,192,168,1,107,0x0e,0x57};
    Byte testByte1[] = {0x06,0x10,0x02,0x05,0x00,0x1a,0x08,0x01,0xc0,0xa8,0x01,0x66,0xde,0xc8,0x08,0x01,0xc0,0xa8,0x01,0x66,0xde,0xc9,0x04,0x04,0x02,0x00};
    Byte testByte2[] = {0x06,0x10,0x02,0x09,0x00,0x10,0x07,0x00,0x08,0x01,0xc0,0xa8,0x01,0x66,0xde,0xc8};
    Byte connectByte[] = {0x06,0x10,0x02,0x05,0x00,0x1a,0x08,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x08,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x04,0x04,0x02,0x00};
    
    
    NSMutableData *data = [[NSMutableData alloc] init];
    
//	if ([host length] == 0)
//	{
//		[self logError:@"Address required"];
//		return;
//	}
	
	int port = [portField.text intValue];
//	if (port <= 0 || port > 65535)
//	{
//		[self logError:@"Valid port required"];
//		return;
//	}
	
	NSString *msg = messageField.text;
//	if ([msg length] == 0)
//	{
//		[self logError:@"Message required"];
//		return;
//	}
    
    if([msg compare:@"Search"] == NSOrderedSame)
    {
        //messages = [[NSMutableArray alloc] init];
        
        data = [NSMutableData dataWithBytes:searchByte length:14];
        
        [udpSocket sendData:data toHost:@"192.168.1.222" port:3671 withTimeout:4 tag:tag];
        [self logMessage:FORMAT(@"SENT (%i): %@", (int)tag, msg)];
        tag++;
    }
    else if([msg compare:@"Leave"] == NSOrderedSame)
    {
        if (![udpSocket leaveMulticastGroup:@"224.0.23.12" error:&error])
        {
            
            [self logError:FORMAT(@"Error leaveMulticastGroup: %@", error)];
            return;
        }
        
        [udpSocket sendData:nil withTimeout:1 tag:tag];
        tag++;


    }
    else if([msg compare:@"Test1"] == NSOrderedSame)
    {
        data = [NSMutableData dataWithBytes:testByte1 length:26];
        
        [udpSocket sendData:data toHost:@"192.168.1.222" port:3671 withTimeout:64 tag:tag];
        [self logMessage:FORMAT(@"SENT (%i): %@", (int)tag, msg)];
        tag++;
    }
    else if([msg compare:@"Test2"] == NSOrderedSame)
    {
        data = [NSMutableData dataWithBytes:testByte2 length:16];
        
        [udpSocket sendData:data toHost:@"192.168.1.222" port:3671 withTimeout:64 tag:tag];
        [self logMessage:FORMAT(@"SENT (%i): %@", (int)tag, msg)];
        tag++;
    }
    else if([msg compare:@"Connect"] == NSOrderedSame)
    {
        data = [NSMutableData dataWithBytes:connectByte length:26];
        
        [udpSocket sendData:data toHost:@"192.168.1.222" port:3671 withTimeout:64 tag:tag];
        [self logMessage:FORMAT(@"SENT (%i): %@", (int)tag, msg)];
        tag++;
    }
    else
    {
        return;
    }
	
	//NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding];
    
	//[udpSocket sendData:data toHost:host port:port withTimeout:-1 tag:tag];
	
	//[self logMessage:FORMAT(@"SENT (%i): %@", (int)tag, msg)];
	
	//tag++;
}

- (IBAction)connect:(id)sender
{
    Byte sendByte[] = {0x06,0x10,0x02,0x05,0x00,0x1a,0x08,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x08,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x04,0x04,0x02,0x00};
    
    NSMutableData *data = [[NSMutableData alloc] init];
    
    data = [NSMutableData dataWithBytes:sendByte length:26];
    
    [udpSocket sendData:data toHost:@"192.168.1.222" port:3671 withTimeout:64 tag:tag];
    [self logMessage:FORMAT(@"SENT (%i): Connect", (int)tag)];
    tag++;
}

- (IBAction)Disconnect:(id)sender
{
    Byte sendByte[] = {0x06,0x10,0x02,0x09,0x00,0x10,CID,0x00,0x08,0x01,0x00,0x00,0x00,0x00,0x00,0x00};
    
    if (connectStatus == 0)
    {
        return;
    }
    
    NSMutableData *data = [[NSMutableData alloc] init];
    
    data = [NSMutableData dataWithBytes:sendByte length:16];
    
    [udpSocket sendData:data toHost:@"192.168.1.222" port:3671 withTimeout:64 tag:tag];
    [self logMessage:FORMAT(@"SENT (%i): Disconnect CID %u", (int)tag, CID) ];
    tag++;

}

- (IBAction)LightA:(id)sender
{
    if (connectStatus == 0)
    {
        return;
    }
    
    Byte sendByte[] = {0x06,0x10,0x04,0x20,0x00,0x15,0x04,CID,SC,0x00,0x11,0x00,0xbc,0xd0,0x00,0x00,0x18,0x00,0x01,0x00,0x81};
    
    NSMutableData *data = [[NSMutableData alloc] init];
    
    if ([uibLightA isSelected])
    {
        sendByte[20] = 0x80;
    }
    else
    {
        sendByte[20] = 0x81;
    }
    
    SC++;
    data = [NSMutableData dataWithBytes:sendByte length:21];
    
    [udpSocket sendData:data toHost:@"192.168.1.222" port:3671 withTimeout:64 tag:tag];
    [self logMessage:FORMAT(@"SENT (%i): Set Light A %u", (int)tag, sendByte[20] & 0x01)];
    tag++;

    
    
    
}


- (void)udpHeartBeatTimerFired
{
    if (connectStatus == 0)
    {
        return;
    }
    
    Byte sendByte[] = {0x06,0x10,0x02,0x07,0x00,0x10,CID,0x00,0x08,0x01,0x00,0x00,0x00,0x00,0x00,0x00};
    
    NSMutableData *data = [[NSMutableData alloc] init];
    
    data = [NSMutableData dataWithBytes:sendByte length:16];
    
    [udpSocket sendData:data toHost:@"192.168.1.222" port:3671 withTimeout:64 tag:tag];
    //[self logMessage:FORMAT(@"SENT (%i): Connection State Request", (int)tag)];
    tag++;

    
}


- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
	// You could add checks here
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
	// You could add checks here
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
                                               fromAddress:(NSData *)address
                                         withFilterContext:(id)filterContext
{
	//NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    Byte *testByte = (Byte *)[data bytes];
    //atos();
    //NSString *msg = [[NSString alloc] initWithBytes:testByte length:[data length] encoding:NSUnicodeStringEncoding];
    
    NSString *hexStr=@"";
    for(int i=0;i<[data length];i++)
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",testByte[i]&0xff];///16进制数
        if([newHexStr length]==1)
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        else
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }

	if (hexStr)
	{
		//[self logMessage:FORMAT(@"RECV: %@", hexStr)];  //CID
        
        if ((testByte[0] == 0x06) && (testByte[1] == 0x10) && (testByte[2] == 0x02) && (testByte[3] == 0x06) && (testByte[7] == 0x00))
        {
            CID = testByte[6];
            connectStatus = 1;
            [udpHeartBeat setFireDate:[NSDate distantPast]];
            [self logMessage:FORMAT(@"Connect Sucess CID : %u", CID)];  //CID
            
            Byte sendByte[] = {0x06,0x10,0x04,0x20,0x00,0x15,0x04,CID,SC,0x00,0x11,0x00,0xbc,0xd0,0x00,0x00,0x18,0x0c,0x01,0x00,0x00}; //read
            SC++;
            NSMutableData *data = [[NSMutableData alloc] init];
            
            data = [NSMutableData dataWithBytes:sendByte length:21];
            
            [udpSocket sendData:data toHost:@"192.168.1.222" port:3671 withTimeout:64 tag:tag];
            [self logMessage:FORMAT(@"SENT (%i): Read Light A Status CID %u  SC %u", (int)tag, CID, SC)];
            tag++;

            
        }
        else if((testByte[0] == 0x06) && (testByte[1] == 0x10) && (testByte[2] == 0x02) && (testByte[3] == 0x06) && (testByte[7] == 0x24))
        {
            [self logMessage:FORMAT(@"Connect Failed  E_NO_MORE_CONNECTIONS")];  //CID
        }
        else if((testByte[0] == 0x06) && (testByte[1] == 0x10) && (testByte[2] == 0x02) && (testByte[3] == 0x0A))
        {
            if (testByte[6] == CID)
            {
                connectStatus = 0;
                SC = 0;
                [udpHeartBeat setFireDate:[NSDate distantFuture]];
                [self logMessage:FORMAT(@"Disconnect  CID : %u", CID)];  //CID
            }
        }
        else if((testByte[0] == 0x06) && (testByte[1] == 0x10) && (testByte[2] == 0x02) && (testByte[3] == 0x08))
        {
            if (testByte[6] == CID)
            {
                if (testByte[7] == 0x00) {
                    //[self logMessage:FORMAT(@"Connection State Response OK  CID : %u", CID)];  //CID
                    return;
                }
                else
                {
                    connectStatus = 0;
                    [udpHeartBeat setFireDate:[NSDate distantFuture]];
                    [self logMessage:FORMAT(@"Connection State Error  CID : %u", CID)];  //CID
                }
            }

        }
        else if ((testByte[0] == 0x06) && (testByte[1] == 0x10) && (testByte[2] == 0x04) && (testByte[3] == 0x20)) //request
        {
            //SC = testByte[8] + 1;
            
            Byte sendByte[] = {0x06,0x10,0x04,0x21,0x00,0x0a,0x04,CID,testByte[8],0x00};  //ack
            
            NSMutableData *data = [[NSMutableData alloc] init];
            
            data = [NSMutableData dataWithBytes:sendByte length:10];
            
            [udpSocket sendData:data toHost:@"192.168.1.222" port:3671 withTimeout:64 tag:tag];
            [self logMessage:FORMAT(@"SENT (%i): Connection ACK CID %u  SC %u", (int)tag, CID, SC)];
            tag++;
            
            if ((testByte[16] == 0x18) && (testByte[17] == 0x0c))  //Light A State Response
            {
                if ((testByte[20] & 0x01))  //ON
                {
                    [uibLightA setHighlighted:YES];
                    [uibLightA setSelected:YES];
                }
                else  //OFF
                {
                    [uibLightA setHighlighted:NO];
                    [uibLightA setSelected:NO];
                }
                
                [self logMessage:FORMAT(@"setHighlighted %u", (testByte[20] & 0x01))];
            }

            
        }
        else if((testByte[0] == 0x06) && (testByte[1] == 0x10) && (testByte[2] == 0x04) && (testByte[3] == 0x21))//ack
        {
            [self logMessage:FORMAT(@"RECV (%i): Connection ACK CID %u  SC %u  Status %u", (int)tag, testByte[7], testByte[8], testByte[9])];
        }
        
	}
	else
	{
		NSString *host = nil;
		uint16_t port = 0;
		[GCDAsyncUdpSocket getHost:&host port:&port fromAddress:address];
		
		[self logInfo:FORMAT(@"RECV: Unknown message from: %@:%hu", host, port)];
	}
}

- (IBAction)jsonAction:(id)sender
{
    NRJson *configJson = [[NRJson alloc] init];
    NSString *retString = [configJson getStringWithKey:@"title"];
    if(retString != Nil)
    NSLog(@"%@", retString);
}

@end
