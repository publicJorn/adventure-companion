# Database related

- Using sqflite plugin

## How to inspect the db on your device

> Only tested so far on android emulator, but should also work for real android phones

- Download [DB Browser for sqlite](https://sqlitebrowser.org/dl/)
- Open this project in Android Studio
   > Working on another project? See below to set it up
- Open: View -> Tool Windows -> Device File Explorer
- Browse to: `/data/data/com.frontrain.adventure_companion/app_flutter/db`
- Right click on `db` and Save as.. All files are needed for DB Browser
- Open `adventure_companion.db` in DB Browser

### Setup Android Studio for using Device File Explorer

This goes for any flutter app. It took me a while to figure this out, so I'll leave this explanation in.

- You may get a warning like: **Android Debug Bridge not found**
- If you have the menu option **File -> Project Settings..** skip the next bullet
- The project should have been created with Android Studio. If not, it will miss config files in `.idea` folder
   - If you created your project using another IDE (like vscode), create a new empty project with Android Studio and compare the `.idea/` folder contents. It may miss a `misc.xml` file
   - If you synced the `.idea` folders restart Android Studio.
- Now in **File -> Project Settings..** in **Project**, make sure you have a **Project SDK** selected
- In the left bar click **Modules** and check if the same SDK shows up next to **Module SDK:**
- Restart Android Studio. The Device File Explorer should work
