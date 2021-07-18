# Releasing Vitals

1. Bump the version in Xcode: click the project → General → Identity → Version.
2. Build, archive, and export the app: Product → Archive → Distribute App → Copy App.
3. Create a zip file for the new .app file: `script/create-release-zip`, select the most recent export.
4. Make sure you've pushed the commit that bumps the version to GitHub.
5. Create a new [GitHub release](https://github.com/hmarr/vitals/releases), attaching the newly-generated zip file.
6. Update the [homebrew cask](https://github.com/hmarr/homebrew-tap/blob/master/Casks/vitals.rb) by bumping the version number and the sha256 digest. The `sha256` value is just the output of running `sha256sum` on the zip file.
