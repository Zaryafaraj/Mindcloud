//
//  IdeaStockViewController.m
//  IdeaStock
//
//  Created by Ali Fathalian on 3/28/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "IdeaStockViewController.h"
#import <DropboxSDK/DropboxSDK.h>
#import "DropBoxAssociativeBulletinBoard.h"

/*-----------------------------------------------------------
                            For Demo Purposes Only
 -----------------------------------------------------------*/

@implementation IdeaStockViewController

@synthesize board = _board;


- (DropBoxAssociativeBulletinBoard *) board{
    if (!_board){
        
        _board  = [[DropBoxAssociativeBulletinBoard alloc] initBulletinBoardFromXoomlWithName:@"BulletinBoard"];
    }
    
    return _board;
}



- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath
              from:(NSString*)srcPath metadata:(DBMetadata*)metadata {
    
    NSLog(@"File uploaded successfully to path: %@", metadata.path);
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error {
    NSLog(@"File upload failed with error - %@", error);
}

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    if (metadata.isDirectory) {
        NSLog(@"Folder '%@' contains:", metadata.path);
        for (DBMetadata *file in metadata.contents) {
            NSLog(@"\t%@", file.filename);
        }
    }
}

- (void)restClient:(DBRestClient *)client
loadMetadataFailedWithError:(NSError *)error {
    
    NSLog(@"Error loading metadata: %@", error);
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    //setup dropbox
    if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] link];
    }
    
    
    
}
- (IBAction)buttonPressed:(id)sender {
    
    // id board = self.board;
}
- (IBAction)savePressed:(id)sender {
    [DropBoxAssociativeBulletinBoard saveBulletinBoard:self.board];
}
- (IBAction)addNewNote:(id)sender {
    [self.board demoAddNewNote];
}
- (IBAction)addNewBB:(id)sender {
    [self.board demoAddNewBulletinBoard];
}
- (IBAction)deleteBB:(id)sender {
    [self.board demoDeleteBB];
}
- (IBAction)deleteNote:(id)sender {
    [self.board demoDeleteNote];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
