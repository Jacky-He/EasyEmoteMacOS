#import "CandidateTableCell.h"

@implementation CandidateTableCell

+(instancetype)cell
{
    CandidateTableCell* res = [CandidateTableCell new];
    @autoreleasepool {
        NSTextField* text_label = [res get_text_label];
        NSTextField* num_label = [res get_num_label];
        
        [res addSubview:num_label];
        [num_label.leadingAnchor constraintEqualToAnchor:res.leadingAnchor].active = YES;
        [num_label.centerYAnchor constraintEqualToAnchor:res.centerYAnchor].active = YES;
        [num_label.widthAnchor constraintEqualToConstant:18].active = YES;
        
        [res addSubview:text_label];
        [text_label.leadingAnchor constraintEqualToAnchor:num_label.trailingAnchor].active = YES;
        [text_label.trailingAnchor constraintEqualToAnchor:res.trailingAnchor constant:3].active = YES;
        [text_label.centerYAnchor constraintEqualToAnchor:res.centerYAnchor].active = YES;
    }
    return [res autorelease];
}

-(NSTextField*)get_num_label
{
    if (_num_label == nil)
    {
        _num_label = [NSTextField new];
        [_num_label setFont:[NSFont fontWithName:@"Chalkboard" size:15]];
        [_num_label setBezeled:NO];
        [_num_label setDrawsBackground:NO];
        [_num_label setEditable:NO];
        [_num_label setSelectable:NO];
        [_num_label setAlignment:NSTextAlignmentCenter];
        [_num_label setTextColor:[NSColor blackColor]];
        [_num_label setBackgroundColor:[NSColor clearColor]];
        [_num_label setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    return _num_label;
}

-(NSTextField*)get_text_label
{
    if (_text_label == nil)
    {
        _text_label = [NSTextField new];
        [_text_label setBezeled:NO];
        [_text_label setDrawsBackground:NO];
        [_text_label setEditable:NO];
        [_text_label setSelectable:NO];
        [_text_label setAlignment:NSTextAlignmentLeft];
        [_text_label setTextColor:[NSColor blackColor]];
        [_text_label setBackgroundColor:[NSColor clearColor]];
        [_text_label setMaximumNumberOfLines:1];
        [_text_label setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    return _text_label;
}

-(void)set_text:(NSAttributedString *)text
{
    NSTextField* text_label = [self get_text_label];
    [text_label setAttributedStringValue:text];
}

-(CGFloat)get_desired_width
{
    return 18 + _text_label.intrinsicContentSize.width + 10;
}

-(void)update_label:(NSUInteger)num
{
    NSTextField* num_label = [self get_num_label];
    NSString* s = (1 <= num && num <= 9 ? [NSString stringWithFormat:@"%lu", num] : @"");
    [num_label setStringValue:s];
}

-(void)dealloc
{
    [_num_label release];
    [_text_label release];
    [super dealloc];
}

@end
