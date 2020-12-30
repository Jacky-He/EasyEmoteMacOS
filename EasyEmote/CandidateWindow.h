#import <Cocoa/Cocoa.h>
#import <InputMethodKit/InputMethodKit.h>
#import <AppKit/AppKit.h>
#import "CandidateTableView.h"

@interface CandidateWindow : NSWindow <NSTableViewDataSource, NSTableViewDelegate>
{
    IMKInputController* _controller; //weak
    NSArray<NSAttributedString*>* _candidates;
    CandidateTableView* _table_view;
    NSScrollView* _scroll_view;
    CGFloat _desired_width;
    NSView* _container_view;
    NSMutableArray<NSAttributedString*>* _key_selection_candidates; //length = 9
}

+(instancetype)window;
-(void)show:(id)sender;
-(void)hide;
-(void)setCandidates:(NSArray<NSAttributedString*>*)arr;
-(void)handleEvent:(NSEvent*)event;
-(void)setInputController:(IMKInputController*)controller;
-(void)boundsDidChange:(NSNotification*)notification;

@end


