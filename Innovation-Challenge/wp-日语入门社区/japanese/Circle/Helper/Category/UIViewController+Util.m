//
//  UIViewController+Util.m
//  dxstudio
//
//  Created by XieYajie on 25/08/2017.
//  Copyright © 2017 dxstudio. All rights reserved.
//

#import "UIViewController+Util.h"

@implementation UIViewController (Util)

- (void)addPopBackLeftItem
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"back_left_black"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(popBackLeftItemAction)];
}

- (void)addPopBackLeftItemWithTarget:(id _Nullable )aTarget
                              action:(SEL _Nullable )aAction
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"back_left_black"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:aTarget action:aAction];
}

- (void)addKeyboardNotificationsWithShowSelector:(SEL)aShowSelector
                                    hideSelector:(SEL)aHideSelector
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:aShowSelector name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:aHideSelector name:UIKeyboardWillHideNotification object:nil];
}

- (void)removeKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)popBackLeftItemAction
{
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showAlertControllerWithMessage:(NSString *)aMsg title:(NSString *)title handler:(void (^ __nullable)(UIAlertAction *action))handler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:aMsg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", nil) style:UIAlertActionStyleCancel handler:handler];
    [alertController addAction:okAction];
    alertController.modalPresentationStyle = 0;
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
