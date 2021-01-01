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
    extern Trie* dict;
    [self set_window:[CandidateWindow window]];
    NSLog(@"DEBUGMESSAGE: Window set");
}

-(void)applicationWillTerminate:(NSNotification *)notification
{
    [_window release];
}

@end

