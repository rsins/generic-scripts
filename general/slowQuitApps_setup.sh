#!/bin/bash
# --------------------------------------------------------------------------------
# This is SlowQuitApps - https://github.com/dteoh/SlowQuitApps
# --------------------------------------------------------------------------------

echo "Deleting preferences."
defaults delete com.dteoh.SlowQuitApps

echo "Enabling the inverted list for slow quiting."
defaults write com.dteoh.SlowQuitApps invertList -bool YES

echo "Updating new preferences."
defaults write com.dteoh.SlowQuitApps delay -int 1000
defaults write com.dteoh.SlowQuitApps whitelist -array-add `osascript -e 'id of app "Firefox" '`
defaults write com.dteoh.SlowQuitApps whitelist -array-add `osascript -e 'id of app "Chrome"  '`
defaults write com.dteoh.SlowQuitApps whitelist -array-add `osascript -e 'id of app "Opera"   '`
defaults write com.dteoh.SlowQuitApps whitelist -array-add `osascript -e 'id of app "iTerm2"  '`
defaults read com.dteoh.SlowQuitApps

echo "Restarting the SlowQuitApps."
killall SlowQuitApps
open -a SlowQuitApps

echo "Done...."

