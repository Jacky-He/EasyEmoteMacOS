#import "CandidateWindow.h"

@implementation CandidateWindow

+(instancetype)window
{
    CandidateWindow* res = [CandidateWindow new];
    [res setStyleMask:NSWindowStyleMaskBorderless|NSWindowStyleMaskFullSizeContentView];
    [res setBackingType:NSBackingStoreBuffered];
    [res setBackgroundColor: [NSColor clearColor]];
    NSScrollView* scrollview = [res get_scroll_view];
    CandidateTableView* tableview = [res get_table_view];
    NSView* container = [res get_container_view];

    [container addSubview:scrollview];
    [scrollview setTranslatesAutoresizingMaskIntoConstraints:NO];
    [scrollview.topAnchor constraintEqualToAnchor:container.topAnchor].active = YES;
    [scrollview.bottomAnchor constraintEqualToAnchor:container.bottomAnchor].active = YES;
    [scrollview.leadingAnchor constraintEqualToAnchor:container.leadingAnchor].active = YES;
    [scrollview.trailingAnchor constraintEqualToAnchor:container.trailingAnchor].active = YES;
    
    [scrollview setDocumentView: tableview];
    [[scrollview contentView] setPostsBoundsChangedNotifications:YES];
    [[NSNotificationCenter defaultCenter] addObserver:res selector:@selector(boundsDidChange:) name:NSViewBoundsDidChangeNotification object:[scrollview contentView]];
    
    [res setContentView:container];
    [res setLevel:CGShieldingWindowLevel()+1];
    [res makeKeyAndOrderFront:NSApp];
    return res;
}

-(void)handleEvent:(NSEvent*)event
{
    unsigned short keycode = [event keyCode];
    NSString* s = [event characters];
    if (keycode == 36 || keycode == 76) //return/enter
    {
        CandidateTableView* tableview = [self get_table_view];
        NSInteger curr = [tableview selectedRow];
        if (0 <= curr && curr < [_candidates count]) [_controller candidateSelected:_candidates[curr]];
    }
    else if (keycode == 125) //arrow down
    {
        CandidateTableView* tableview = [self get_table_view];
        NSInteger curr = [tableview selectedRow];
        if (0 <= curr + 1 && curr + 1 < [_candidates count])
        {
            [tableview selectRowIndexes:[NSIndexSet indexSetWithIndex:curr+1] byExtendingSelection:NO];
            [tableview scrollRowToVisible:curr+1];
        }
    }
    else if (keycode == 126) //arrow up
    {
        CandidateTableView* tableview = [self get_table_view];
        NSInteger curr = [tableview selectedRow];
        if (0 <= curr - 1 && curr - 1 < [_candidates count])
        {
            [tableview selectRowIndexes:[NSIndexSet indexSetWithIndex:curr-1] byExtendingSelection:NO];
            [tableview scrollRowToVisible:curr-1];
        }
    }
    else if (s && [s intValue] != 0) //numbers
    {
        int val = [s intValue];
        if (1 <= val && val <= MIN(9, [_candidates count]) && _controller != nil) [_controller candidateSelected:_key_selection_candidates[val-1]];
    }
}

-(void)show:(id)sender
{
    NSRect rect;
    [sender attributesForCharacterIndex:0 lineHeightRectangle:&rect];
    CGFloat buffer = 3.0;
    NSPoint insertion_point = NSMakePoint(NSMinX(rect), NSMinY(rect) - buffer);
    
    NSRect mainframe = [[NSScreen mainScreen] visibleFrame];
    [self setFrameTopLeftPoint: insertion_point];
    if (!NSContainsRect(mainframe, self.frame))
    {
        NSRect intersect = NSIntersectionRect(mainframe, self.frame);
        //Check bottom intersection
        if (intersect.size.height < self.frame.size.height)
        {
            insertion_point = NSMakePoint(NSMinX(rect), MAX(NSMaxY(rect) + buffer, mainframe.origin.y));
            [self setFrameOrigin:insertion_point]; //origin = bottom left point
        }
        
        intersect = NSIntersectionRect(mainframe, self.frame);
        //Check left intersection
        if (self.frame.origin.x < intersect.origin.x)
        {
            NSRect tmp = self.frame;
            tmp.origin.x = intersect.origin.x + buffer;
            [self setFrameOrigin: tmp.origin];
        }
        
        intersect = NSIntersectionRect(mainframe, self.frame);
        //Check right intersection
        if (self.frame.origin.x + self.frame.size.width > intersect.origin.x + intersect.size.width)
        {
            NSRect tmp = self.frame;
            tmp.origin.x = intersect.origin.x + intersect.size.width - self.frame.size.width - buffer;
            [self setFrameOrigin: tmp.origin];
        }
    }
    [self setIsVisible:YES];
}

-(void)hide
{
    [self setIsVisible:NO];
}

-(CandidateTableView*)get_table_view
{
    if (_table_view == nil)
    {
        _table_view = [[CandidateTableView table] retain];
        [_table_view setDataSource:self];
        [_table_view setDelegate:self];
        [_table_view setEnabled:YES];
        [_table_view setHeaderView:nil];
        [_table_view setBackgroundColor:[NSColor clearColor]];
        [_table_view setTarget:self];
        [_table_view setDoubleAction:@selector(doubleClicked:)];
        NSTableColumn* col = [[[NSTableColumn alloc]initWithIdentifier:@"emotes"] autorelease];
        [_table_view addTableColumn:col];
    }
    return _table_view;
}

-(NSView*)get_container_view
{
    if (_container_view == nil)
    {
        _container_view = [[NSView new] retain];
        [_container_view setWantsLayer:YES];
        [_container_view.layer setBackgroundColor:[NSColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.9].CGColor];
        [_container_view.layer setCornerRadius:6.0];
    }
    return _container_view;
}

-(NSScrollView*)get_scroll_view
{
    if (_scroll_view == nil)
    {
        _scroll_view = [[NSScrollView new] retain];
        [_scroll_view setBackgroundColor:[NSColor clearColor]];
        [_scroll_view setDrawsBackground:NO];
    }
    return _scroll_view;
}

-(void)setCandidates:(NSArray<NSAttributedString*>*)arr
{
    [arr retain];
    [_candidates release];
    _candidates = arr;
    if (_key_selection_candidates == nil)
    {
        _key_selection_candidates = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < 9; i++)
        {
            NSAttributedString* str = [[NSAttributedString alloc]initWithString:@""];
            [_key_selection_candidates addObject:str];
            [str release];
        }
    }
    
    for (NSInteger i = 0; i < MIN(9, [_candidates count]); i++) [_key_selection_candidates setObject:[_candidates objectAtIndex:i] atIndexedSubscript:i];
    
    CandidateTableView* tableview = [self get_table_view];
    
    //resize window
    [tableview reloadData];
    CGSize maxsize = tableview.frame.size;
    maxsize.height = MIN(tableview.frame.size.height, 300.0);
    maxsize.width = [self get_tightest_width_of_rows:NSMakeRange(0, 10)];
    [self setContentSize: maxsize];
    
    if ([_candidates count] > 0) [tableview selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
}

-(void)setInputController:(IMKInputController*)controller
{
    _controller = controller;
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    if (_candidates == nil) return 0;
    return [_candidates count];
}

-(NSView*)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    CandidateTableCell* cell = [tableView makeViewWithIdentifier:@"niceview" owner:self];
    if (cell == nil)
    {
        cell = [CandidateTableCell cell];
        cell.identifier = @"niceview";
    }
    NSRect rect = [tableView visibleRect];
    NSRange rows = [tableView rowsInRect:rect];
    [cell set_text:[_candidates objectAtIndex:row]];
    NSScrollView* scroll = [self get_scroll_view];
    CGPoint p = scroll.contentView.bounds.origin;
    NSInteger inc = (fabs(p.y) < rows.location*25.0 + 12.5) ? 0 : 1;
    if (rows.location + inc <= row && row < rows.location + rows.length)
    {
        NSInteger tar = row - rows.location - inc + 1;
        [cell update_label:tar];
        if (1 <= tar && tar <= 9) [_key_selection_candidates setObject:[_candidates objectAtIndex:row] atIndexedSubscript:tar-1];
    }
    else [cell update_label:-1];
    return cell;
}

//-(CGFloat)tableView:(NSTableView *)tableView sizeToFitWidthOfColumn:(NSInteger)column

-(CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    return 25.0;
}

-(NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row
{
    return [CandidateTableRow new];
}

-(void)tableViewSelectionDidChange:(NSNotification *)notification
{
    
}

-(void)boundsDidChange:(NSNotification *)notification
{
    CandidateTableView* tableview = [self get_table_view];
    NSRect rect = [tableview visibleRect];
    NSRange rows = [tableview rowsInRect:rect];
    [tableview reloadDataForRowIndexes:[NSIndexSet indexSetWithIndexesInRange:rows] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
    CGSize maxsize = tableview.frame.size;
    maxsize.height = MIN(tableview.frame.size.height, 300.0);
    maxsize.width = [self get_tightest_width_of_rows:rows];
    [self setContentSize: maxsize];
}

-(CGFloat)get_width_of_row_with_str:(NSAttributedString*)str
{
    CGFloat res = 35;
    @autoreleasepool {
        NSTextField* temp = [NSTextField new];
        [temp setMaximumNumberOfLines:1];
        [temp setBezeled:NO];
        [temp setDrawsBackground:NO];
        [temp setEditable:NO];
        [temp setSelectable:NO];
        [temp setAlignment:NSTextAlignmentLeft];
        [temp setTextColor:[NSColor blackColor]];
        [temp setBackgroundColor:[NSColor clearColor]];
        [temp setTranslatesAutoresizingMaskIntoConstraints:NO];
        [temp setAttributedStringValue:str];
        res += temp.intrinsicContentSize.width;
    }
    return res;
}

-(CGFloat)get_tightest_width_of_rows:(NSRange)rows
{
    CGFloat res = 0.0;
    for (NSInteger i = rows.location; i < MIN([_candidates count], rows.location + rows.length); i++)
    {
        res = MAX(res, [self get_width_of_row_with_str:_candidates[i]]);
    }
    return res;
}

-(void)doubleClicked:(id)sender
{
    NSInteger row = [sender clickedRow];
    if (_controller != nil) [_controller candidateSelected:_candidates[row]];
}

-(void)dealloc
{
    [_key_selection_candidates release];
    [_scroll_view release];
    [_table_view release];
    [_candidates release];
    [_container_view release];
    [super dealloc];
}

@end
