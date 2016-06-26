# AppImage
A Swift script that generates an enum based off of the contents of your Assets.xcassets folder.

## Usage

Simply run: `./AppImage.swift [/my/path/to/Assets.xcassets]`

You'll get a new `UIImage+AppImage.swift` file in the same directory that you called it from.

Now you can instantiate images in a more typesafe way by using `UIImage(named: AppImage.myCase.rawValue)`.

## Notes

- Supports **nested folders** inside of `Assets.xcassets`. You'll get nested enums.
- You might be asking why there is not an initializer like `UIImage(appImage: AppImage)`. This is because with nested enums we'd need a separate initializer for every single one, so I removed it for now. It's very possible to make that part of the script, but right now it's not supported. I'd love to see a PR with that though :)
- Does not currently support .imageset files with spaces in their names. You'll get spaces in your enum, which will show up as an error. Might consider replacing spaces with underscores in both the .imageset names and the enum cases, but as of right now we don't do that.
