#import <Foundation/Foundation.h>
#import "Pair.h"
@implementation Pair


-(Pair*)initialize:(id)first second:(id)val2
{
    self = [super init];
    if (self)
    {
        _first = first;
        _second = val2;
    }
    return self;
}

-(id)first
{
    return [self first];
}

-(id)second
{
    return [self second];
}

-(void)set_first:(id)first
{
    _first = first;
}

-(void)set_second:(id)second
{
    _second = second;
}

@end
