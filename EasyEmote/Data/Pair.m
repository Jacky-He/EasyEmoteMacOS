#import <Foundation/Foundation.h>
#import "Pair.h"
@implementation Pair


-(Pair*)initialize:(id)first second:(id)val2
{
    self = [super init];
    if (self)
    {
        _first = [first retain];
        _second = [val2 retain];
    }
    return self;
}

-(id)first
{
    return _first;
}

-(id)second
{
    return _second;
}

-(void)set_first:(id)first
{
    _first = first;
}

-(void)set_second:(id)second
{
    _second = second;
}

-(void)dealloc
{
    [_first release];
    [_second release];
    [super dealloc];
}

@end
