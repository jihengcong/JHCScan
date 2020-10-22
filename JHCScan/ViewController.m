//
//  ViewController.m
//  JHCScan
//
//  Created by mac on 2020/10/21.
//

#import "ViewController.h"
#import "JHCScanViewController.h"
#import "JHCToastHud.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 89, self.view.bounds.size.width, 400)];
    [self.view addSubview:view];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(50, 100, self.view.bounds.size.width - 100, 50)];
    button.backgroundColor = [UIColor redColor];
    [button setTitle:@"扫描" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    
    UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake(50, CGRectGetMaxY(view.frame) + 50, self.view.bounds.size.width - 100, 50)];
    button1.backgroundColor = [UIColor redColor];
    [button1 setTitle:@"停止" forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(button1Action) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button1];
}

- (void)buttonAction:(UIButton *)button
{
//    [JHCToastHud showLoadingWithMsg:@"加载中..." inView:button.superview];
//    return;
    
    
    JHCScanViewController *vc = [[JHCScanViewController alloc] init];
//    vc.modalPresentationStyle = UIModalPresentationFullScreen;
//    [self presentViewController:vc animated:YES completion:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)button1Action
{
    [JHCToastHud hideAnimated:YES];
}


@end
