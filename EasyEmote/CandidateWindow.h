#import <Cocoa/Cocoa.h>
#import <InputMethodKit/InputMethodKit.h>
#import <AppKit/AppKit.h>
#import "CandidateTableView.h"
@class EmoteInputController;

@interface CandidateWindow : NSWindow <NSTableViewDataSource, NSTableViewDelegate>
{
    EmoteInputController* _controller; //weak
    NSArray<NSAttributedString*>* _candidates;
    CandidateTableView* _table_view;
    NSScrollView* _scroll_view;
    NSMutableArray<NSAttributedString*>* _key_selection_candidates; //length = 9
}

+(instancetype)window;
-(void)show;
-(void)hide;
-(void)setCandidates:(NSArray<NSAttributedString*>*)arr;
-(void)handleEvent:(NSEvent*)event;
-(void)setInputController:(EmoteInputController*)controller;
-(void)boundsDidChange:(NSNotification*)notification;

@end
