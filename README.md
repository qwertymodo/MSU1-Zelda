# MSU1-Zelda

ASM hack to implement MSU-1 functionality in Zelda 3, enabling playback of CD-quality soundtracks.

This hack requires you to provide the audio tracks which will be used for audio playback.  See the [Audio Files](https://github.com/qwertymodo/MSU1-Zelda/wiki/Audio-Files) page on the wiki

This patch was originally written by [Conn79](https://github.com/Conn79).  He wrote the patch directly in hex, so I disassembled it, and he then commented the disassembly.  2 minor changes were made to accommodate for the limitations of anonymous labels in bass, but neither affects the functionality of the original patch, so this is (as of the initial commit) 100% functionally equivalent to Conn79's patch.

Beyond the initial commit, further changes may be made to address a few remaining minor issues, as well as to clean up the code and possibly relocate it so it doesn't require expanding the ROM to 12Mbit.  In case my edits start breaking things, you can always refer to [this commit](https://github.com/qwertymodo/MSU1-Zelda/commit/57015c5479761544601527f9cef557200f418a15) for Conn79's final version, which should be considered functionally complete.