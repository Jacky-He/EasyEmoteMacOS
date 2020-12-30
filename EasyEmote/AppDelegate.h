#import <Cocoa/Cocoa.h>
#import "CandidateWindow.h"
#import "Triplet.h"
#import "Trie.h"

@interface AppDelegate: NSObject <NSApplicationDelegate>
{
    CandidateWindow* _window;
}

-(CandidateWindow*)get_window;

@end
