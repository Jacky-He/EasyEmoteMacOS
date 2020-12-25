#import "Preferences.h"

@implementation Preferences

-(Preferences*)initialize
{
    self = [super init];
    if (self)
    {
        [self train_model];
        [self load_db];
    }
    return self;
}

-(void)train_model
{
    
}

-(void)load_db
{
    
}

-(void)sort_based_on_history:(NSArray<Pair*>*)arr
{
    
}

-(void)insert_new_entry:(Pair*)entry
{
    
}

-(void)dealloc
{
    [_prediction_model release];
    [db release];
    [super dealloc];
}

@end
