Beepr
=========
Beepr HIPAA complient simple messenger.
It’s from github cloning of Hipaagram.

Prerequisites
-------------
Beepr uses cocoapods to manage the libraries it needs. You will need cocoapods installed to use this app. Check out their [docs](http://cocoapods.org/) or simply run `sudo gem install cocoapods` in a terminal window.

Getting Started
---------------
Beepr is an example app written to show the capabilities of the Catalyze HIPAA compliant APIs. An explanation of the following instructions can be found in both the [API Guide](https://docs.catalyze.io/guides/api/latest/) and the [blog post](https://blog.catalyze.io) explaining Beepr. In order to run this application you will have to follow these steps

* Head over to the [dashboard](https://dashboard.catalyze.io) and sign up for an account
* Create an Organization
* Create an Application to run this app (call it Beepr!)
* Create an API Key
* Insert the full 3 part API Key (<type> <identifier> <id>) in the `application:didFinishLaunchingWithOptions:` method in the AppDelegate.m file
* Insert the application ID from the dashboard in the `application:didFinishLaunchingWithOptions:` method in the AppDelegate.m file
* In `SignInViewController.m` you need to change the hardcoded email to an email address you can access. Change this line `return [NSString stringWithFormat:@"josh+%@@catalyze.io", randomString];` to be something such as `return [NSString stringWithFormat:@"me+%@@mydomain.com", randomString];`. Notice the `me` and `mydomain.com`.

Now that we have our org and app setup, we need to create a few custom classes and assign appropriate permissions. There are two ways to accomplish this, run a script or do it manually with cURL commands.

Run a Script
------------
From the root of the project you will see a folder called `Setup`. Open up terminal and navigate to this folder

```
cd Setup
```

This is a simple python script that will take care of everything for us, creating the appropriate custom classes and setting the correct read/write permissions on those classes. There is one dependency for this script, the python `Requests` library. To install this run

```
sudo pip install requests
```

Feel free to make this folder a [Virtual Env](https://virtualenv.pypa.io/en/latest/) and run the install that way as well. Now that we have the dependency installed let's run the script!

```
python BeeprSetup.py --username MY_EMAIL --password MY_PASSWORD --appId MY_APP_ID --apiKey MY_API_KEY
```

Be sure to replace the values of `MY_EMAIL`, `MY_PASSWORD`, `MY_APP_ID`, and `MY_API_KEY` with your specific values. The script will tell you once everything finishes and you're all set! There is no need to perform the manual commands if you run this script, skip on down to `iOS Project Setup`.

Manual Commands
---------------
Create a custom class named `conversations` with the following schema. Be sure to mark PHI as `true`.

```
{
"name":"conversations",
"schema":{
	"sender":"string",
	"recipient":"string",
	"sender_id":"string",
	"recipient_id":"string"
},
"phi":true
}
```

Create a custom class named `contacts` with the following schema. Be sure to mark PHI as `false`.

```
{
"name":"contacts",
"schema":{
	"user_username":"string",
	"user_usersId":"string"
},
"phi":false
}
```

Lastly, create a custom class named `messages` with the following schema. Be sure to mark PHI as `true`.

```
{
"name":"messages",
"schema":{
	"conversationsId":"string",
	"msgContent":"string",
	"toPhone":"string",
	"fromPhone":"string",
	"timestamp":"string",
	"isPhi":"boolean",
	"fileId":"string"
},
"phi":true
}
```

Now we need to set the appropriate permissions for these three classes. To learn about setting permissions, check out [this guide](https://resources.catalyze.io/baas/guides/permissions-and-acls/#granting-full-permissions-on-a-custom-class). You can run cURL commands or use the REST client of your choice to run these commands. For the `contacts` class we need to assign the following permissions

```
['create', 'retrieve']
```

For the `conversations` class assign the following permissions

```
['create']
```

For the `messages` class assign the following permissions

```
['create']
```

iOS Project Setup
-----------------
There is very little setup for the iOS project itself. Simply run

```
pod install
```

in the root of the project from a terminal window to install all the necessary dependencies. Open up `Beepr.xcworkspace` (do not open `Beepr.xcodeproj`) and you're all set to go!

Urban Airship
-------------
Beepr uses push notifications to alert recipients that they have a new message. No details about the message are sent in the notification. This is so the app remains HIPAA compliant. The notification is simply an alert to tell the recipient that they should query for new messages. In order to use this feature you will need to sign up for a trial account on [Urban Airship](http://urbanairship.com/). You will then need to fill in the appropriate keys in the `AirshipConfig.plist` file in the root of the project.

If you do not wish to use this feature, simply comment out the related Urban Airship lines in the `AppDelegate.m` file. 

License
--------

    Copyright 2014 Catalyze, Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
