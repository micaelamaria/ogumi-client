# Ogumi App

## Installation

### Install APK on Device

In Android, each app is an APK file (`.apk`). You can install apps from te marketplace or manually. This app is not on the marketplace since this app is under development, so you cannot install it this way. The manual install consists of three steps (see below).

**Warning:** Keep in mind that you can easily install malware. Download APKs only from sites you trust and check everytime the permissions of an app before install it.

#### Allow "Unknown Sources" on your Device

First you need to allow "Unknown Sources" on your device to be able to install APK files directly. Otherwise you are only allowed to install apps from the marketplace.

Open "Settings" and navigate to "Security". Check "Unknown Sources" in the subsection "Device administration" . Now your device is ready to install apps without using the marketplace.

#### Download the APK

Open a browser app (e.g. "Internet") and navigate to the URL where you can download the app. Save the file if you were asked to; otherwise it is saved automatically.

On some Samsung devices downloads are not possible. In this case you can either choose another browser like "Firefox" or download the file with your PC:

 - Connect your device with USB to your PC; it should be connected as "media device".
 - Open the URL in a browser on your PC and download the APK.
 - Save the file directly to your device or move the APK with your file manager from your PC to your device. You can choose the "Downloads" folder on your device for example.

#### Install the APK

Open the APK you have downloaded. Open "Downloads" or have a look in your "Downloads" folder and tap on the APK that should be installed. An installation dialog will be shown. Check the name and permissions and click "Install".

## Development

### Building

The following commands must be run first to install everything necessary for
this project:

```
npm install -g bower
npm install -g gulp
npm install
bower install
```

After that running the command `gulp war` will build a war file under
`/deploy/war/webclient.war` and `gulp package-app` will copy all necessary files
for the app to `/www`. The app needs further things to do before you should
execute `gulp package-app`, see section "App".

### Deployment

The command `gulp mvn-deploy` will deploy to the default repository.
This must be specified in `artifactory.json` like this:

```
{
	"url": "http://REPO-URL/REPO-NAME/",
	"user": "USERNAME",
	"password": "S3CRET"
}
```

The command `gulp tomcat-deploy` will deploy the war file to the tomcat server
defined in `tomcat.json`:

```
{
	"url": "http://TOMCAT/manager/text/deploy?path=/PATH",
	"user": "USERNAME",
	"password": "S3CRET"
}
```

### App

The app is built with the `cordova` CLI. For installation and usage, check
[this guide](http://docs.phonegap.com/en/edge/guide_cli_index.md.html#The%20Command-Line%20Interface).
Run `cordova create`, add the `android` platform and merge the project folders.
Keep the files of this project if asked, not the default ones created by cordova
(for example you have this conflict on `MainActivity.java`).

In short:

```
npm install -g cordova
cordova create ogumi-app com.naymspace.ogumi.app Ogumi
cd ogumi-app
cordova platform add android@5.1.0
cd ..
cp -r -n ogumi-app/* .
rm -r ogumi-app/
```

Add the required plugins with the `cordova` CLI:

```
cordova plugin add https://github.com/vstirbu/ZeroConf
cordova plugin add https://github.com/mkuklis/phonegap-websocket
cordova plugin add cordova-plugin-network-information
cordova plugin add https://github.com/crosswalk-project/cordova-plugin-crosswalk-webview\#2.1.0
cordova plugin add https://github.com/apache/cordova-plugin-whitelist
```


Run `gulp package-app && cordova build` to build the app.

#### Some Notes

Make sure you have run `gulp package-app` each time you made changes to your
code before running `cordova build`.

When testing the app in the android emulator and you are using a server on
`localhost` (pointing to your machine), you have to use `10.0.2.2` instead.

## License

The Ogumi App is distributed under Apache-2.0, see LICENSE for more details.

Have a look into [THIRD-PARTY.txt](./THIRD-PARTY.txt) for informations about
the licenses of the dependencies of the Ogumi App.

The [icon.png](./src/icon.png), [favicon.ico](./src/favicon.ico), 
[apple-touch-icon.png](./src/apple-touch-icon.png),
and [apple-touch-icon-retina.png](./src/apple-touch-icon-retina.png)
are licensed under CC0.

The Ogumi App uses [Glyphicons](http://glyphicons.com/).

