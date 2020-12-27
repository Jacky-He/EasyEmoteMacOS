#import <Foundation/Foundation.h>
@interface Triplet: NSObject
{
    id _first;
    id _second;
    id _third;
}

+(instancetype)triplet:(id)first second:(id)val2 third:(id)val3;
-(id)first;
-(id)second;
-(id)third;
-(void)set_first:(id)first;
-(void)set_second:(id)second;
-(void)set_third:(id)third;

@end
