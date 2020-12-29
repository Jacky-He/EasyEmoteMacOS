#import <Cocoa/Cocoa.h>
#import <InputMethodKit/InputMethodKit.h>
#import <AppKit/AppKit.h>

@interface CandidateWindow : NSWindow
{
    IMKInputController* _controller; //weak
    
}

+(instancetype)window;
//-(void)show;
//-(void)hide;
//-(bool)isVisible;
-(void)setCandidates:(NSArray<NSAttributedString*>*)arr;
-(void)interpretKeyEvents:(NSArray<NSEvent *>*)eventArray;
-(void)setInputController:(IMKInputController*)controller;

@end
