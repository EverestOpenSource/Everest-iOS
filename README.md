# Everest iOS

Everest was an app for documenting your life through journeys and individual moments within each journey. We decided to open source the iOS client in order to let others learn from our work rather than just abandoning it forever in a new Swift world.

We stopped work on the app around June 2014 so there are probably a lot of iOS 8 related UI bugs that need ironing out.

## Setup

You should have the latest stable version of Xcode installed and then clone the Everest Github repo to your local machine.  The main branch we are using is the `master` branch.

### Dependencies

Everest now uses [CocoaPods](http://cocoapods.org) for code dependency management so you'll need to follow these steps to get all the dependencies setup.

```shell
$ cd ~/PathToClonedEverestRepo

// Install CocoaPods if necessary (or run update on it)
$ sudo gem install cocoapods

// Run the pod file install script
$ pod install
```

### Fonts

Everest uses Proxima Nova and Trump fonts internally, but these are not open license fonts so unfortunately they could not be added to the Github repo.

Feel free to fork this repo and replace them with your own fonts or if you happen to have these fonts on your local machine, just put the required font files into a directory like so:

### Keys

Most access keys are in the EvstConstants.m file or you can just do a project-wide search for the string `key-goes-here` to find where you need to put your access tokens and secret keys. You should also check out [https://github.com/orta/cocoapods-keys](https://github.com/orta/cocoapods-keys) for secure storage of app keys in your Mac's Keychain Access Tool.

### Build Errors

If you are still having build errors after running these commands, you are probably using the wrong scheme within Xcode (switch to `Production`) or you need to let Xcode index the huge amount of code before trying to build and run.

## Contributing Code

1. Create a branch off of the `master` branch to add your changes, making sure to commit in logical groups that can be easily reviewed together or cherry picked.
2. Be sure to publish your branch to the server.  This allows you to reset using `git reset HEAD^ --hard` if something goes wrong with future merges.
3. When you're ready and if necessary, merge the `master` branch into your local branch and resolve any conflicts before submitting a pull request.  
4. If there were conflicts, carefully verify that you did not delete someone else's important changes.
5. Submit a pull request for your branch and wait for someone to review it and merge it into `master` for you.

**Note:** Each branch you create should be a small amount of changes that can easily be reviewed together.

## Testing

We are using [KIF](https://github.com/kif-framework/KIF) for all functional tests, which essentially runs the simulator or your device and executes a gambit of tests in front of your eyes while reporting results via Xcode.

To mock out HTTP requests, we are using [OHHTTPStubs](https://github.com/AliSoftware/OHHTTPStubs).

### Setup

Currently there are some pre-requisites when running tests:

1. There needs to be at least one contact created in the simulator.
2. The user must approve access to contacts, photos, Twitter and Facebook accounts.

### Running Tests

When you're ready to run the tests, select the `Testing` scheme and then `Cmd + U` (Product > Test) or press the play icon on the Test Nav Panel via `Cmd + 5`.

## License ##

Essentially, this code is free to use in commercial and non-commercial projects with no attribution necessary.

See the `LICENSE` file for more details.

## Thank You ##

A HUGE thank you to all of the open source software that came before us that allowed us to move quickly and test theories rather than building boilerplate all day.

## Team ##

Credits for this code base:

* Rob Phillips: [https://www.linkedin.com/in/iwasrobbed](https://www.linkedin.com/in/iwasrobbed)
* Chris Cornelis: [https://www.linkedin.com/in/ccornelis](https://www.linkedin.com/in/ccornelis)
