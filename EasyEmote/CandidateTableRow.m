#import "CandidateTableRow.h"

@implementation CandidateTableRow

-(void)drawSelectionInRect:(NSRect)dirtyRect
{
    if (self.selectionHighlightStyle != NSTableViewSelectionHighlightStyleNone)
    {
        NSRect selectionRect = NSInsetRect(self.bounds, 2.5, 2.5);
        [[NSColor colorWithCalibratedWhite:.65 alpha:1.0] setStroke];
        [[NSColor colorWithCalibratedWhite:.82 alpha:1.0] setFill];
        NSBezierPath* selectionPath = [NSBezierPath bezierPathWithRoundedRect:selectionRect xRadius:6 yRadius:6];
        [selectionPath fill];
        [selectionPath stroke];
    }
}

@end

