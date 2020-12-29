#import "AppDelegate.h"

@implementation AppDelegate

-(void)set_window:(CandidateWindow*) window
{
    [window retain];
    [_window release];
    _window = window;
}

-(NSWindow*)get_window
{
    return _window;
}

-(void)applicationDidFinishLaunching:(NSNotification *)notification
{
    [self set_window:[CandidateWindow window]];
    NSLog(@"DEBUGMESSAGE: Window set");
}

-(void)applicationWillTerminate:(NSNotification *)notification
{
    
}

@end
