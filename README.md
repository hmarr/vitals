# Vitals

A tiny macOS process monitor.

<p align="center">
<img width="454" alt="Vitals screenshot" src="https://user-images.githubusercontent.com/110275/111912121-1fcdb300-8a60-11eb-8eb8-35dc434a77e6.png">
</p>

Vitals lives in the menu bar, keeping track of resource usage in the background so you can summon it instantly at any time.

While other tools like Activity Monitor show you each process' _current_ CPU usage, Vitals shows a per-process CPU graph covering the last 60 seconds. This makes it much easier to track down apps that misbehave sporadically.

Read more about why this exists [in the introductory blog post](https://hmarr.com/blog/vitals/).

## Install

1. Download and extract the zip file from the [latest GitHub release](https://github.com/hmarr/vitals/releases/latest).
2. Drag the file called Vitals into your computer's Applications folder.
3. Within the Applications folder, right-click the app, then select “Open” from the menu that pops up. (It's not notarised, which is why you'll need to right-click.)


## Usage

Vitals runs in the background, and lives in your Mac's menu bar. The icon looks like a little "V" in a circle. Click that to open Vitals. To quit, right-click the menu bar icon and select "Quit Vitals" from the menu that appears.
