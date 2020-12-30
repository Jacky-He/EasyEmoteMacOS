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
//    NSMutableArray<NSAttributedString*>* test = [NSMutableArray array];
//    NSMutableArray<Triplet*>* res = [dict subsequence_search:@"ye"];
//    for (NSInteger i = 0; i < [res count]; i++)
//    {
//        NSLog(@"DEBUGMESSAGE: %@ %@", [res[i] first], [res[i] second]);
//        NSString* s = [[[res[i] second] stringByAppendingString:@" "] stringByAppendingString:[res[i] first]];
//        NSFont* font = [NSFont fontWithName:@"Chalkboard" size:15];
//        NSMutableDictionary* attributes = [NSMutableDictionary dictionary];
//        [attributes setObject:font forKey:NSFontAttributeName];
//        NSAttributedString* temp = [[NSAttributedString alloc]initWithString:s attributes:attributes];
//        [test addObject:temp];
//        [temp release];
//    }
//    [_window setCandidates:test];
    NSLog(@"DEBUGMESSAGE: Window set");
}

-(void)applicationWillTerminate:(NSNotification *)notification
{
    
}

@end
