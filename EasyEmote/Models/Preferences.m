#import "Preferences.h"

@implementation Preferences

-(Preferences*)initialize
{
    self = [super init];
    if (self)
    {
//        [self train_model];
    }
    return self;
}

-(YCFFN*)get_prediction_model
{
    return _prediction_model;
}

-(void)set_prediction_model:(YCFFN*)model
{
    if (_prediction_model != nil) [_prediction_model release];
    if (model == nil) return;
    _prediction_model = [model retain];
}

-(void)train_model
{
    NSLog(@"DEBUGMESSAGE: Training Model...");
    @autoreleasepool {
        Matrix* m = [self get_csv_data];
        if (m == nil)
        {
            [self set_prediction_model:nil];
            return;
        }
        Matrix* input = [m removeRow:4];
        Matrix* output = [m row:4];
        YCELMTrainer* trainer = [YCELMTrainer trainer];
        @try
        {
            YCFFN* model = (YCFFN* )[trainer train:nil inputMatrix:input outputMatrix:output];
            [self set_prediction_model:model];
        }
        @catch (NSException* e)
        {
            NSLog(@"DEBUGMESSAGE: Error training model %@", [e description]);
            [self set_prediction_model:nil];
        }
    }
    NSLog(@"DEBUGMESSAGE: Training Finished!");
}

- (Matrix *)matrixWithCSVName:(NSString *)path
{
    NSString* fileContents = [[NSString alloc]initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSMutableArray *arrays = [fileContents.CSVComponents mutableCopy];
    NSMutableArray *cols = [NSMutableArray array];
    for (NSArray *a in arrays)
    {
        [cols addObject:[Matrix matrixFromNSArray:a rows:(int)(a.count) columns:1]];
    }
    [fileContents release];
    return [Matrix matrixFromColumns:cols]; // Transpose to have one sample per column
}

-(Matrix*)get_csv_data
{
    NSString* path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"dataset.csv"];
    NSFileManager* filemanager = [NSFileManager defaultManager];
    if ([filemanager fileExistsAtPath:path]) return [self matrixWithCSVName:path];
    else return nil;
}

-(FMDatabase*)get_db
{
    NSString* path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"shistory.db"];
    if (_db == nil) _db = [FMDatabase databaseWithPath:path];
    return _db;
}

-(void)sort_based_on_history:(NSMutableArray<Pair*>*)arr
{
    YCFFN* model = [self get_prediction_model];
    if (model == nil) return;
    NSMutableArray<Pair*>* doublepair = [[NSMutableArray alloc]init];
    NSInteger cnt = [arr count];
    for (NSInteger i = 0; i < cnt; i++)
    {
        Record* r = [self get_record:arr[i] output:0];
        if (r == nil)
        {
            NSNumber* n = [NSNumber numberWithDouble:-1.0];
            Pair* obj = [[Pair alloc] initialize:arr[i] second:n];
            [doublepair addObject:obj];
            [obj release];
            [n release];
        }
        else
        {
            double* mat = malloc(sizeof(double)*4);
            mat[0] = [r total_select];
            mat[1] = [r mago_select];
            mat[2] = [r wago_select];
            mat[3] = [r ave_int];
            Matrix* input = [Matrix matrixFromArray:mat rows:4 columns:1];
            Matrix* output = [model activateWithMatrix:input];
            double pre = [output valueAtRow:0 column:0];
            NSNumber* n = [NSNumber numberWithDouble:pre];
            Pair* obj = [[Pair alloc]initialize:arr[i] second:n];
            [doublepair addObject:obj];
            free(mat);
            [obj release];
            [n release];
        }
    }
    [doublepair sortUsingComparator:^NSComparisonResult(id a, id b) {
        NSNumber* n1 = [(Pair*)a second];
        NSNumber* n2 = [(Pair*)b second];
        return [n2 compare:n1];
    }];
    for (NSInteger i = 0; i < [doublepair count]; i++) [arr setObject:[doublepair[i] first] atIndexedSubscript:i];
    [doublepair release];
}

-(Record*)get_record:(Pair*)p output:(double)res
{
    FMDatabase* db = [self get_db];
    if (![db open])
    {
        NSLog(@"DEBUGMESSAGE: failed to open sqlite database");
        return nil;
    }
    NSDate* curr = [NSDate date];
    NSTimeInterval timestamp = [curr timeIntervalSinceReferenceDate];
    NSInteger roundedtime = round(timestamp);
    NSInteger wago = roundedtime - 7*24*3600;
    NSInteger mago = roundedtime - 30*24*3600;
    int wago_select = 0;
    int mago_select = 0;
    int total_select = 0;
    double ave_int = -1.0;
    NSString* sql = [NSString stringWithFormat: @"CREATE TABLE if not exists `%@` (`id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, `timestamp` INTEGER NOT NULL);", [p first]];
    if (![db executeStatements:sql]) NSLog(@"DEBUGMESSAGE error = %@", [db lastErrorMessage]);
    sql = [NSString stringWithFormat: @"SELECT COUNT(*) FROM `%@` WHERE `timestamp`>=%ld;", [p first], wago];
    FMResultSet *s = [db executeQuery:sql];
    if ([s next]) wago_select = [s intForColumnIndex:0];
    [s close];
    sql = [NSString stringWithFormat: @"SELECT COUNT(*) FROM `%@` WHERE `timestamp`>=%ld;", [p first], mago];
    s = [db executeQuery:sql];
    if ([s next]) mago_select = [s intForColumnIndex:0];
    [s close];
    sql = [NSString stringWithFormat:@"SELECT ave_interval, numselection FROM `interval` WHERE emoji='%@'", [p first]];
    s = [db executeQuery:sql];
    if ([s next])
    {
        ave_int = [s doubleForColumn:@"ave_interval"];
        total_select = [s intForColumn:@"numselection"];
    }
    [s close];
    [db close];
    if (ave_int < 0) return nil;
    return [[Record alloc] initialize:res total_select:total_select mago_select:mago_select wago_select:wago_select ave_int:ave_int];
}

-(void)append_to_CSV:(Record*)r
{
    if (r == nil) return;
    NSLog(@"DEBUGMESSAGE: APPENDED");
    NSString* path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"dataset.csv"];
    NSString* s = [NSString stringWithFormat:@"%d,%d,%d,%.f,%.f\n", [r total_select], [r mago_select], [r wago_select], [r ave_int], [r res]];
    NSFileManager* filemanager = [NSFileManager defaultManager];
    if ([filemanager fileExistsAtPath:path])
    {
        NSFileHandle* fh = [NSFileHandle fileHandleForWritingAtPath:path];
        [fh seekToEndOfFile];
        NSData* data = [s dataUsingEncoding:NSUTF8StringEncoding];
        [fh writeData:data];
        [fh closeFile];
    }
    else [filemanager createFileAtPath:path contents:[s dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
}

-(void)insert_new_entry:(Pair*)entry candidates:(NSArray<Pair*>*)potential
{
    FMDatabase* db = [self get_db];
    if (![db open])
    {
        NSLog(@"DEBUGMESSAGE: failed to open sqlite database");
        return;
    }
    NSDate* curr = [NSDate date];
    NSTimeInterval timestamp = [curr timeIntervalSinceReferenceDate];
    NSInteger roundedtime = round(timestamp);
    NSString* sql = [NSString stringWithFormat:
                     @"CREATE TABLE if not exists `%@` (`id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, `timestamp` INTEGER NOT NULL);"
                     "CREATE TABLE if not exists `interval` (`id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, `emoji` TEXT NOT NULL UNIQUE, `ave_interval` REAL NOT NULL, `numselection` INTEGER NOT NULL, `last_seen` INTEGER NOT NULL);"
                     , [entry first]];
    if (![db executeStatements:sql]) NSLog(@"DEBUGMESSAGE: error = %@", [db lastErrorMessage]);
    [db close];
    
    bool did = false;
    for (NSInteger i = 0; i < [potential count]; i++)
    {
        double res = [[potential[i] first] isEqualToString:[entry first]] ? 1.0 : 0.0;
        Record* r = [self get_record:potential[i] output:res];
        if (r != nil) did = true;
        [self append_to_CSV:r];
        [r release];
    }
    
    if (![db open])
    {
        NSLog(@"DEBUGMESSAGE: failed to open sqlite database");
        return;
    }
    sql = [NSString stringWithFormat:
                     @"INSERT INTO `%@` (`timestamp`) VALUES (%ld);"
                     "INSERT INTO `interval` (`emoji`, `ave_interval`, `numselection`, `last_seen`) VALUES ('%@', -1.0, 1, %ld) ON CONFLICT(`emoji`) "
                     "DO UPDATE SET ave_interval=(ave_interval*(numselection-1)+(excluded.last_seen-last_seen))/numselection, numselection=numselection+1, last_seen=excluded.last_seen;"
                      , [entry first], roundedtime, [entry first], roundedtime];
    
    if (![db executeStatements:sql]) NSLog(@"DEBUGMESSAGE: error = %@", [db lastErrorMessage]);
    [db close];
//    if (did) [self train_model];
}

-(void)dealloc
{
    [_prediction_model release];
    [_db release];
    [super dealloc];
}

@end
