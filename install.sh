rm -rf rm -rf ~/Library/Application\ Support/.burrito/
MIX_ENV=prod BURRITO_TARGET=macos_arm mix release
cp burrito_out/markdown_tools_macos_arm ~/bin/markdown-tools
