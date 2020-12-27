#import <Foundation/Foundation.h>
@interface Pair: NSObject
{
    id _first;
    id _second;
}

+(instancetype)pair:(id)first second:(id)val2;
-(id)first;
-(id)second;
-(void)set_first:(id)first;
-(void)set_second:(id)second;

@end
