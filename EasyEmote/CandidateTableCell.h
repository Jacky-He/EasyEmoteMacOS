#import <Cocoa/Cocoa.h>
#import <AppKit/AppKit.h>

@interface CandidateTableCell: NSTableCellView
{
    NSTextField* _text_label;
    NSTextField* _num_label;
}

+(instancetype)cell;
-(void)set_text:(NSAttributedString*)text;
-(void)update_label:(NSUInteger)num;

@end
