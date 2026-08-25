![Shatterdome logo](https://raw.githubusercontent.com/hmhalvorsen/Shatterdome/master/resources/logo_full.png)

Started as a cross-platform, open-source "clone" of [Artemis Spaceship Bridge Simulator](https://www.artemisspaceshipbridge.com/), **Shatterdome** has already deviated from Artemis with new features and gameplay, including a Game Master mode and multiple AI factions. We strive to get Shatterdome working on several platforms, and Windows, Linux, and Android are fully supported.

The game is written in C++ with the [SeriousProton](https://github.com/daid/SeriousProton) engine and uses [SDL2](http://www.libsdl.org/) for most of the heavy lifting.

## Download and install

Official releases for Windows, Linux (as a .deb package), and Android (beta quality) are available from the [Shatterdome website](https://github.com/hmhalvorsen/Shatterdome/#tabs=5) or [GitHub releases](https://github.com/hmhalvorsen/Shatterdome/releases). Make sure the host and all players run the same version number of Shatterdome; otherwise, players won't be able to connect.

-   Windows releases are distributed as self-contained ZIP archives that don't need installation. You can expand the ZIP archive and launch Shatterdome directly from the expanded folder.
-   The .deb package requires freetype and SDL2 packages to be installed on your Linux distribution.
-   The Android APK is built for the `armeabi-v7a` ABI and should launch on most Android phones and tablets with ARM processors. (For ARM v8, see [the wiki](https://github.com/hmhalvorsen/Shatterdome/wiki/Build%5CAndroid#build-for-64-bit-arm-v8).) The official ARM APK won't install on Intel x86 or x86_64 devices running Android, but is compatible with [Android Emulator system images that support ARM ABIs](https://android-developers.googleblog.com/2020/03/run-arm-apps-on-android-emulator.html). To build a 32- or 64-bit x86 APK, see [the wiki](https://github.com/hmhalvorsen/Shatterdome/wiki/Build%5CAndroid#build-for-x86).

### Configuration files

Shatterdome settings are stored in an `options.ini` file located in either the `.shatterdome` directory of your user home or the same directory as the Shatterdome launcher. For details, see [this repository's wiki](https://github.com/hmhalvorsen/Shatterdome/wiki/Preferences-file).

### Build from source

See this repository's wiki for guidance on [building Shatterdome from source](https://github.com/hmhalvorsen/Shatterdome/wiki/Build). Several Build subpages on the wiki provide steps for building on specific operating systems, distributions, or hardware.

## Community

For information on Shatterdome's Discord and forums communities, and regularly planned hosted game sessions, see the [Shatterdome website](https://github.com/hmhalvorsen/Shatterdome/#tabs=6). If you run public Shatterdome games or use it in your gaming projects, [file an issue](https://github.com/hmhalvorsen/Shatterdome/issues) to request to be added to that page.

## Contribute

If you want to contribute, we're mostly looking for awesome models, sound effects, and music. The game is tested regulary by some of our trusty colleagues.

Some general contribution rules:

1.  This project is a dictatorship. Yes, it's open source, but we'd much rather spend time on building what we like than arguing with people.

2.  Be precise when filing issues. Explain why you posted the issue, what you expect, what is happening, why is your feature worth the time to develop it, what operating system is affected, etc. Unclear issues are subject to rule 1 with extreme prejudice.

3.  Despite the above two, we very much value input, feedback, and suggestions from people playing Shatterdome. If you have ideas or want to donate beer, drop us a line.

### Donate

If you don't have the skills to help code or create models but want to give something back, you can always donate a bit. All donations go directly toward buying better assets for the game (in this case, more and better 3D models). You can find the instructions on the [Shatterdome website](http://github.com/hmhalvorsen/Shatterdome/).

### Write code

If you are a coder and want to contribute, there are a few things to take into account.

1.  The code is a undocumented mess at this point. We're working on fixing that.

2.  We use the following conventions:

    -   Member values use underscores to separate words (`zoom_level`).
    -   Classes use HighCamelCase (`GuiSlider`).
    -   Functions use lowCamelCase (`getZoomLevel`).

3.  Use a single pull request to change a single thing. Want to change multiple things? File multiple requests.

### Provide art

There is no clear goal where this game is going. This means that there is no formal game, art, or asset design. If you have something that you would like to see in this game (or want to make something), drop us a line. We'd love to see what you can do and how you can help improve the game.

For details on how Shatterdome uses 3D models, see [this repository's wiki](https://github.com/hmhalvorsen/Shatterdome/wiki/Adding-3D-models).

### Translate and localize

For a guide to translating Shatterdome and its scenarios, see [this repository's wiki](https://github.com/hmhalvorsen/Shatterdome/wiki/Translation-and-Localization).

## Documentation

Basic documentation for setting up and running games is available on the [Shatterdome website](https://github.com/hmhalvorsen/Shatterdome/#tabs=2).

To learn Shatterdome gameplay fundamentals, read the [website's stations profiles](https://github.com/hmhalvorsen/Shatterdome/#tabs=3) and play through the game's built-in tutorial mode available from the main menu, which covers each crew member's interface and responsibilities.

For guidance in scripting scenarios, see the [website's mission scripting guide](https://github.com/hmhalvorsen/Shatterdome/#tabs=4). For a scripting API reference, open the `script_reference.html` file included in your version's downloaded archive, which is specific to that version of Shatterdome.

For documentation on the game's preferences file and command-line options, hardware and DMX support, more complex internet play configurations like headless and proxy servers, enabling and using Shatterdome's HTTP API server, or adding ship templates and models, see [this repository's wiki](https://github.com/hmhalvorsen/Shatterdome/wiki).
