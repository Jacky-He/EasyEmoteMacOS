#import "CandidateWindow.h"

@implementation CandidateWindow

+(instancetype)window
{
    NSRect frame = NSMakeRect(0, 0, 200, 200);
    CandidateWindow* res = [[CandidateWindow alloc] initWithContentRect:frame styleMask:NSWindowStyleMaskBorderless backing:NSBackingStoreBuffered defer:NO];
    [res setBackgroundColor: [NSColor blueColor]];
    [res setLevel:CGShieldingWindowLevel()+1];
    return [res autorelease];
}

-(void)interpretKeyEvents:(NSArray<NSEvent *> *)eventArray
{
    
}

-(void)show
{
    [self setIsVisible:YES];
}

-(void)hide
{
    [self setIsVisible:NO];
}

-(void)setCandidates:(NSArray<NSAttributedString*>*)arr
{
    
}

-(void)setInputController:(IMKInputController*)controller
{
    _controller = controller;
}

@end
