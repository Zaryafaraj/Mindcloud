//
//  MockDropBoxDatamodel.m
//  IdeaStock
//
//  Created by Ali Fathalian on 4/11/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "MockDropBoxDatamodel.h"
#import "DropBoxAssociativeBulletinBoard.h"
#import "FileSystemHelper.h"

@interface MockDropBoxDatamodel()

@property (nonatomic, strong) NSData * bulletinBoardXoomlContent;
@property (nonatomic, strong) NSData * noteXoomlContent; 


@end

@implementation MockDropBoxDatamodel

@synthesize bulletinBoardXoomlContent  = _bulletinBoardXoomlContent;
@synthesize noteXoomlContent = _noteXoomlContent;

-(NSData *)bulletinBoardXoomlContent{
    if(!_bulletinBoardXoomlContent){
            NSString * bulletinBoardXooml = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?> <xooml:fragment xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"xmlns:xooml=\"http://kftf.ischool.washington.edu/xmlns/xooml\" xmlns:is=\"http://ischool.uw.edu/xmlns/ideastock\" xsi:schemaLocation=\"http://kftf.ischool.washington.edu/xmlns/xooml http://kftf.ischool.washington.edu/XMLschema/0.41/XooML.xsd\" schemaVersion=\"0.41\" defaultApplication=\"\" relatedItem=\"\\\\students.ischool.washington.edu\\home\\zaryaf\\Projects\\57b4075e-1eef-431a-90e5-b460ec05d19d\\\"> <xooml:association ID=\"d391c321-4f25-4128-8a82-13dd5f268034\" associatedItem=\"Note1\" associatedIcon=\"\" associatedXooMLFragment=\"\" levelOfSynchronization=\"1\" displayText=\"Note1\" openWithDefault=\"\" createdBy=\"IdeaStock\" createdOn=\"3/29/2012 5:05 PM\" modifiedBy=\"\" modifiedOn=\"3/29/2012 5:06 PM\"> <xooml:associationToolAttributes xmlns=\"http://ischool.uw.edu/xmlns/ideastock\" ID=\"d391c321-4f25-4128-8a82-13dd5f268134\" type=\"position\" toolName=\"IdeaStock\" toolVersion=\"0.1\"><is:position positionX=\"200\" positionY=\"200\" isVisible=\"true\"/></xooml:associationToolAttributes> <xooml:associationToolAttributes xmlns=\"http://ischool.uw.edu/xmlns/ideastock\" ID=\"d391c321-4f25-4128-8a82-13dd5f268035\" type=\"linkage\" name=\"link1\" toolName=\"IdeaStock\" toolVersion=\"0.1\"><is:note refID=\"859dab04-ac93-4ccc-a3fb-a226a2ac4d93\"/></xooml:associationToolAttributes> </xooml:association> <xooml:association ID=\"859dab04-ac93-4ccc-a3fb-a226a2ac4d93\" associatedItem=\"Note2\" associatedIcon=\"\" associatedXooMLFragment=\"\" levelOfSynchronization=\"1\" displayText=\"Note2\" openWithDefault=\"\" createdBy=\"IdeaStock\" createdOn=\"3/29/2012 5:05 PM\" modifiedBy=\"\" modifiedOn=\"3/29/2012 5:07 PM\"> <xooml:associationToolAttributes xmlns=\"http://ischool.uw.edu/xmlns/ideastock\" id=\"d391c321-4f25-4128-8a82-13dd5f263134\" type=\"position\" toolName=\"IdeaStock\" toolVersion=\"0.1\"><is:position positionX=\"300\" positionY=\"400\" isVisible=\"true\"/></xooml:associationToolAttributes> <xooml:associationToolAttributes xmlns=\"http://ischool.uw.edu/xmlns/ideastock\" ID=\"d391c321-4f25-4128-8a82-13dd5f269035\" type=\"linkage\" name=\"link1\" toolName=\"IdeaStock\" toolVersion=\"0.1\"><is:note refID=\"d391c321-4f25-4128-8a82-13dd5f268034\"/></xooml:associationToolAttributes> </xooml:association> <xooml:fragmentToolAttributes xmlns=\"http://ischool.uw.edu/xmlns/IdeaStuck\" id=\"859ccc04-ac93-4ccc-a3fb-a226a2ac4d93\" type=\"stacking\" name=\"Stacking1\" toolName=\"IdeaStock\" toolVersion=\"0.1\"><is:note refID=\"d391c321-4f25-4128-8a82-13dd5f268034\"/><is:note refID=\"859dab04-ac93-4ccc-a3fb-a226a2ac4d93\"/></xooml:fragmentToolAttributes> <xooml:fragmentToolAttributes xmlns=\"http://ischool.uw.edu/xmlns/IdeaStuck\" id=\"859ccc04-ac93-4ccc-a3fb-a226a2a33d93\" type=\"stacking\" name=\"Stacking2\" toolName=\"IdeaStock\" toolVersion=\"0.1\"><is:note refID=\"d391c321-4f25-4128-8a82-13dd5f268034\"/><is:note refID=\"859dab04-ac93-4ccc-a3fb-a226a2ac4d93\"/></xooml:fragmentToolAttributes> <xooml:fragmentToolAttributes xmlns=\"http://ischool.uw.edu/xmlns/IdeaStuck\" id=\"859ccc04-ac93-4ccc-a3fb-a226a2ag4d94\" type=\"grouping\" name=\"Grouping1\" toolName=\"IdeaStock\" toolVersion=\"0.1\"><is:note refID=\"d391c321-4f25-4128-8a82-13dd5f268034\"/><is:note refID=\"859dab04-ac93-4ccc-a3fb-a226a2ac4d93\"/></xooml:fragmentToolAttributes> <xooml:fragmentToolAttributes xmlns=\"http://ischool.uw.edu/xmlns/IdeaStuck\" id=\"859ccc04-ac93-4ccc-a3fb-a226a2aa4d95\" type=\"grouping\" name=\"Grouping2\" toolName=\"IdeaStock\" toolVersion=\"0.1\"><is:note refID=\"d391c321-4f25-4128-8a82-13dd5f268034\" /><is:note refID=\"859dab04-ac93-4ccc-a3fb-a226a2ac4d93\"/></xooml:fragmentToolAttributes></xooml:fragment>";
        _bulletinBoardXoomlContent = [bulletinBoardXooml dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    return _bulletinBoardXoomlContent;
}


- (NSData*) noteXoomlContent{
    if(!_noteXoomlContent){
        NSString * noteXooml = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?> <xooml:fragment xsi:schemaLocation=\"http://kftf.ischool.washington.edu/xmlns/xooml http://kftf.ischool.washington.edu/XMLschema/0.41/XooML.xsd\" schemaVersion=\"0.41\" defaultApplication=\"\" relatedItem=\"C:\\Users\\Zoso\\Projects\\0c8966ef-0571-4935-b931-5bca1818bed6\\\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xooml=\"http://kftf.ischool.washington.edu/xmlns/xooml\"> <xooml:fragmentToolAttributes xmlns=\"http://kftf.ischool.washington.edu/xmlns/planz\" toolVersion=\"1.0.7\" toolName=\"Planz\" startDate=\"1/1/0001 12:00 AM\" dueDate=\"1/1/0001 12:00 AM\" showAssociationMarkedDone=\"False\" showAssociationMarkedDefer=\"False\" /> <xooml:association ID=\"074fddec-fb84-46bf-839c-9e859675b1d3\" associatedItem=\"\" associatedIcon=\"\" associatedXooMLFragment=\"\" levelOfSynchronization=\"0\" displayText=\"Note1Text1\" openWithDefault=\"\" createdBy=\"planz\" createdOn=\"3/28/2012 12:43 PM\" modifiedBy=\"\" modifiedOn=\"3/28/2012 12:44 PM\"> <xooml:associationToolAttributes xmlns=\"http://kftf.ischool.washington.edu/xmlns/planz\" type=\"Note\" associatedItemType=\"None\" isVisible=\"True\" isCollapsed=\"True\" status=\"Normal\" powerDStatus=\"None\" powerDTimeStamp=\"3/28/2012 12:43 PM\" fontColor=\"Black\" flagStatus=\"Normal\" /> </xooml:association> </xooml:fragment>";
        _noteXoomlContent = [noteXooml dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    return  _noteXoomlContent;
    
}

-(void) addBulletinBoardWithName:
(NSString *)bulletinBoardName 
            andBulletinBoardInfo:(NSData *)content{
       
    NSLog(@"bulletin board added to mock dropbox");
}

-(void) getBulletinBoardAsynch:(NSString *)bulletinBoardName{
    NSString * tempDir = [NSTemporaryDirectory() stringByDeletingPathExtension];
    NSError * err;
    NSFileManager * fileManager =  [NSFileManager defaultManager];
    
    
    NSString * path = [NSString stringWithFormat: @"/%@/note1",bulletinBoardName];
    NSString *dir = [tempDir stringByAppendingString:path];
    BOOL didCreate = [fileManager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:&err];
    if (!didCreate){
        NSLog(@"Error in creating Dir: %@",err);
        return;
    }
    
    path = [NSString stringWithFormat: @"/%@/note2",bulletinBoardName];
    dir = [tempDir stringByAppendingString:path];
    didCreate = [fileManager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:&err];
    if (!didCreate){
        NSLog(@"Error in creating Dir: %@",err);
        return;
    }
    
    path = [NSString stringWithFormat: @"/%@/xooml.xml",bulletinBoardName];
    path = [tempDir stringByAppendingString:path];
    BOOL didWrite = [self.bulletinBoardXoomlContent writeToFile:path options:NSDataWritingAtomic error:&err];
    if (!didWrite){
        NSLog(@"Error in writing to file system: %@", err);
        return;
    }
    
    path = [NSString stringWithFormat: @"/%@/note1/xooml.xml",bulletinBoardName];
    path = [tempDir stringByAppendingString:path];
    didWrite = [self.noteXoomlContent writeToFile:path options:NSDataWritingAtomic error:&err];
    if (!didWrite){
        NSLog(@"Error in writing to file system: %@", err);
        return;
    }
    
    path = [NSString stringWithFormat: @"/%@/note2/xooml.xml",bulletinBoardName];
    path = [tempDir stringByAppendingString:path];
    didWrite = [self.noteXoomlContent writeToFile:path options:NSDataWritingAtomic error:&err];
    if (!didWrite){
        NSLog(@"Error in writing to file system: %@", err);
        return;
    }
    
    [self.delegate initiateBulletinBoad];
}
    

@end
