#import "CoeusToggleListController.h"

@implementation CoeusToggleListController

- (id)specifiers {

	return _specifiers;
}

- (void)viewDidAppear:(BOOL)animated {

	[super viewDidAppear:animated];

	[self.navigationController.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
}

- (void)viewWillAppear:(BOOL)animated {

	[super viewWillAppear:animated];

	UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular];
	UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blur];
	[blurView setFrame:self.view.bounds];
	[blurView setAlpha:1.0];
	[self.view addSubview:blurView];

	[UIView animateWithDuration:.4 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
		[blurView setAlpha:0.0];
	} completion:nil];
}

- (void)loadFromSpecifier:(PSSpecifier *)specifier {

	NSString *sub = [specifier propertyForKey:@"CoeusSub"];
	NSString *title = [specifier name];
	NSMutableArray *toggleList = [[[HBPreferences alloc] initWithIdentifier:@"com.azzou.coeusprefs"] objectForKey:@"toggleList"];

	_specifiers = [[self loadSpecifiersFromPlistName:sub target:self] retain];

	for (NSArray *toggle in toggleList) {
		[self addSpecifier:[self createSpec:[toggle objectAtIndex:0]]];
	}

	[self setTitle:title];
	[self.navigationItem setTitle:title];
}

- (void)setSpecifier:(PSSpecifier *)specifier {

	[self loadFromSpecifier:specifier];
	[super setSpecifier:specifier];
}

- (BOOL)shouldReloadSpecifiersOnResume {

	return false;
}

- (void)addToggle {

	UIAlertController *addAlert = [UIAlertController alertControllerWithTitle:@"Add Toggle"
	message:@"Choose a name for your toggle"
	preferredStyle:UIAlertControllerStyleAlert];
	
	[addAlert addTextFieldWithConfigurationHandler:^(UITextField *tf){}];
	
	UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
	UIAlertAction *addAction = [UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
		PSSpecifier *toggleSpec = [self createSpec:[addAlert.textFields[0] text]];
		[self saveToggle:toggleSpec];
		[self addSpecifier:toggleSpec];
		[self reload];
	}];

	[addAlert addAction:addAction];
	[addAlert addAction:cancelAction];

	[self presentViewController:addAlert animated:YES completion:nil];
}

- (PSSpecifier *)createSpec:(NSString *)name {

	PSSpecifier *newToggle = [PSSpecifier preferenceSpecifierNamed:name
	target:self
	set:NULL
	get:NULL
	detail:Nil
	cell:PSTitleValueCell
	edit:Nil];

	[newToggle setProperty:NSStringFromSelector(@selector(removeToggle:)) forKey:PSDeletionActionKey];

	return newToggle;
}

- (NSArray *)getToggle:(PSSpecifier *)spec {

	NSString *name = [spec name];
	NSNumber *index = [NSNumber numberWithInteger:[[prefs objectForKey:@"toggleList"] count]];

	return [[NSArray alloc] initWithObjects:name, index, nil];
}

- (void)saveToggle:(PSSpecifier *)spec {

	prefs = [[HBPreferences alloc] initWithIdentifier:@"com.azzou.coeusprefs"];
	NSMutableArray *toggleList = [[prefs objectForKey:@"toggleList"] mutableCopy];
	if (!(toggleList)) {
		toggleList = [[NSMutableArray alloc] init];
	}

	[toggleList addObject:[self getToggle:spec]];

	[prefs setObject:toggleList forKey:@"toggleList"];
}

- (void)removeToggle:(PSSpecifier *)spec {

	prefs = [[HBPreferences alloc] initWithIdentifier:@"com.azzou.coeusprefs"];
	NSMutableArray *toggleList = [[prefs objectForKey:@"toggleList"] mutableCopy];

	[toggleList removeObject:[self getToggle:spec]];

	[prefs setObject:toggleList forKey:@"toggleList"];
}

@end