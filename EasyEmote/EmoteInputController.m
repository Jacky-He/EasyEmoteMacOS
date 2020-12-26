#import "EmoteInputController.h"

@implementation EmoteInputController


-(BOOL)handleEvent:(NSEvent *)event client:(id)sender
{
    extern IMKCandidates* candidates;
    _currentClient = sender;
    if ([event type] == keyUp) return false;
    unsigned short keycode = [event keyCode];
    NSString* s = [event characters];
    NSLog(@"DEBUGMESSAGE: %@, %d", s, keycode);
    if ([s containsString:@":"])
    {
        _starting = !_starting;
        _doConvert = YES;
        if (!_starting) return [self convert:s client:sender];
    }
    if (!_starting) return false;
    if (keycode == 36) [candidates interpretKeyEvents:[NSArray arrayWithObject:event]];
    else if (keycode == 51) [self handle_backspace:sender];
    else if (keycode == 49) [self handle_space:sender];
    else if (123 <= keycode && keycode <= 126) [candidates interpretKeyEvents:[NSArray arrayWithObject:event]]; //arrow keys
    else if (!s) [candidates interpretKeyEvents:[NSArray arrayWithObject:event]];
    else if ([s intValue] == 0) [self originalBufferAppend:s client:sender];
    else [candidates interpretKeyEvents:[NSArray arrayWithObject:event]];
//        [self handle_number:s client:sender];
    return true;
}

-(void)activateServer:(id)sender
{
    _currentClient = sender;
    extern Preferences* preferences;
//    [preferences train_model];
}

-(void)deactivateServer:(id)sender
{
    extern IMKCandidates* candidates;
    [candidates hide];
}

-(void)commitComposition:(id)sender
{
    NSString* text = [self composedBuffer];
    if (text == nil || [text length] == 0) text = [self originalBuffer];
    [sender insertText:text replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
    [self setComposedBuffer:@""];
    [self setOriginalBuffer:@""];
    _insertionIndex = 0;
    _starting = NO;
    [self updateCandidatesWindow];
}

-(NSMutableString*)composedBuffer
{
    if (_composedBuffer == nil) _composedBuffer = [[NSMutableString alloc] init];
    return _composedBuffer;
}

-(void)setComposedBuffer:(NSString *)string
{
    NSMutableString* buffer = [self composedBuffer];
    [buffer setString:string];
}

-(NSMutableString*)originalBuffer
{
    if (_originalBuffer == nil) _originalBuffer = [[NSMutableString alloc] init];
    return _originalBuffer;
}

-(void)originalBufferAppend:(NSString *)string client:(id)sender
{
    NSMutableString* buffer = [self originalBuffer];
    [buffer appendString: string];
    _insertionIndex++;
    [sender setMarkedText:buffer selectionRange:NSMakeRange(0, [buffer length]) replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
    [self updateCandidatesWindow];
}

-(void)setOriginalBuffer:(NSString *)string
{
    NSMutableString* buffer = [self originalBuffer];
    [buffer setString:string];
}

//converts the things in the originalBuffer and commits it if possible
//ensures that both buffers end up empty and insertion index is at 0
-(BOOL)convert:(NSString*)trigger client:(id)sender
{
    _starting = NO;
    extern IMKCandidates* candidates;
    extern Preferences* preferences;
    NSMutableString* original = [self originalBuffer];
    NSMutableString* composed = [self composedBuffer];

    if ([_curr_candidates count] > 0 && _doConvert)
    {
        [self setComposedBuffer:[_curr_candidates[0] second]];
        [preferences insert_new_entry:_curr_candidates[0] candidates:_curr_candidates];
        [self commitComposition:sender];
    }
    else
    {
        [original appendString:trigger];
        [composed setString:original];
        [self commitComposition:sender];
    }
    return YES;
}

-(void)handle_number:(NSString*)trigger client:(id)sender
{
    extern Preferences* preferences;
    NSInteger val = [trigger intValue];
    if (val < 1 || val > 9) return;
    val--;
    NSInteger target = _curr_page*9 + val;
    if (0 <= target && target < [_curr_candidates count])
    {
        [self setComposedBuffer:[_curr_candidates[target] second]];
        [preferences insert_new_entry:_curr_candidates[target] candidates:_curr_candidates];
        [self commitComposition:sender];
    }
}

-(void)handle_space:(id)sender
{
    _doConvert = NO;
    [self convert:@" " client:sender];
}

-(void)handle_newline:(id)sender
{
//    _doConvert = YES;
//    [self convert:@"\n" client:sender];
}

-(void)handle_backspace:(id)sender
{
    NSMutableString* originalText = [self originalBuffer];
    if (_insertionIndex > 0 && _insertionIndex <= [originalText length])
    {
        _insertionIndex--;
        [originalText deleteCharactersInRange:NSMakeRange(_insertionIndex, 1)];
        [sender setMarkedText:originalText selectionRange:NSMakeRange(0, [originalText length]) replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
    }
    if ([originalText length] == 0) _starting = NO;
    [self updateCandidatesWindow];
}

-(void)candidateSelectionChanged:(NSAttributedString *)candidateString
{
    NSLog(@"DEBUGMESSAGE: Changed");
    NSString* str = [candidateString string];
    NSLog(@"DEBUGMESSAGE: MARK1");
    _curr_index = [self get_index:str];
    NSLog(@"DEBUGMESSAGE: MARK2");
    _curr_page = [self get_page_with_index:_curr_index];
    NSLog(@"DEBUGMESSAGE: curr_index: %ld, curr_page: %ld", _curr_index, _curr_page);
}

-(void)updateCandidatesWindow
{
    extern IMKCandidates* candidates;
    if (!candidates)
    {
        NSLog(@"DEBUGMESSAGE: No Candidates?!");
        return;
    }
    NSLog(@"DEBUGMESSAGE: updateCandidates?");
    if (!_starting) [candidates hide];
    else
    {
        [candidates setPanelType:kIMKSingleColumnScrollingCandidatePanel];
      
//        [dict setValue:[NSNumber numberWithFloat:0.5] forKey:IMKCandidatesOpacityAttributeName];
//        [candidates setAttributes:dict];
        //@assert that original buffer is not empty
        NSLog(@"DEBUGMESSAGE: MARK");
        [self update_curr_candidates];
        if ([_curr_candidates count] == 0)
        {
            NSString* text = [self originalBuffer];
            [_currentClient insertText:text replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
            [self setComposedBuffer:@""];
            [self setOriginalBuffer:@""];
            _insertionIndex = 0;
            _starting = NO;
            [candidates hide];
        }
        else
        {
            NSArray* dict = [candidates attributeKeys];
            for (NSInteger i = 0; i < [dict count]; i++) NSLog(@"DEBUGMESSAGE: %@", dict[i]);
//            [candidates updateCandidates];
            [candidates setCandidateData:_candidate_strings];
            [candidates show:kIMKLocateCandidatesBelowHint];
        }
    }
}

-(void)update_curr_candidates
{
    extern Trie* dict;
    extern Preferences* preferences;
    if (_curr_candidates != nil) [_curr_candidates release];
    _curr_candidates = [[dict subsequence_search:[[self originalBuffer] substringFromIndex:1]] retain];
    [preferences sort_based_on_history:_curr_candidates];
    if (_candidate_strings != nil) [_candidate_strings release];
    _candidate_strings = [[NSMutableArray alloc]init];
    for (NSInteger i = 0; i < [_curr_candidates count]; i++) [_candidate_strings addObject:[[NSString alloc] initWithFormat:@"%@ %@", [_curr_candidates[i] second], [_curr_candidates[i] first]]];
}

-(NSArray*)candidates:(id)sender
{
    _currentClient = sender;
    return _candidate_strings;
}

-(void)candidateSelected:(NSAttributedString *)candidateString
{
    extern Preferences* preferences;
    NSString* tmp = [candidateString string];
    NSArray<NSString*>* line = [tmp componentsSeparatedByString:@" "];
    [self setComposedBuffer:line[0]];
    Triplet* obj = [[Triplet alloc]initialize:line[1] second:line[0] third:line[0]];
    [preferences insert_new_entry:obj candidates:_curr_candidates];
    [obj release];
    [self commitComposition:_currentClient];
}

-(NSInteger)get_page_with_index:(NSInteger)candidateIdentifier // zero indexed
{
    return candidateIdentifier/9;
}

-(NSInteger)get_index:(id)candidateString // zero indexed
{
    NSString* s = candidateString;
    NSArray<NSString*>* arr = _candidate_strings;
    for (NSInteger i = 0; i < [arr count]; i++)
    {
        if ([arr[i] isEqualToString:s]) return i;
    }
    return NSNotFound;
}

-(void)dealloc
{
    [_originalBuffer release];
    [_composedBuffer release];
    [_curr_candidates release];
    [super dealloc];
}

@end
