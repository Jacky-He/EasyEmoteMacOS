#import "Triplet.h"
@implementation Triplet


-(Triplet*)initialize:(id)first second:(id)val2 third:(id)val3
{
    self = [super init];
    if (self)
    {
        _first = [first retain];
        _second = [val2 retain];
        _third = [val3 retain];
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

-(id)third
{
    return _third;
}

-(void)set_first:(id)first
{
    _first = first;
}

-(void)set_second:(id)second
{
    _second = second;
}

-(void)set_third:(id)third
{
    _third = third;
}

-(void)dealloc
{
    [_first release];
    [_second release];
    [_third release];
    [super dealloc];
}

@end
