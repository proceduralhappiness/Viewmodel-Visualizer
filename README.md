Set up
--

There are 2 options:

1. Download the .lua file and drop it in the local plugins folder (C:\Users\User\AppData\Local\Roblox\Plugins)

2. Copy the source code on GitHub, paste it in an empty script anywhere on a Roblox Studio place, right-click it, and select "save as local plugin"

Usage
--
Follow the steps I made in this video:

https://www.youtube.com/watch?v=GHpcyVA9wvM

Important notes:

1. **PAY ATTENTION ON THE OUTPUT**, I was too lazy to add some GUI and also wanted to keep things simple, errors and notifications will only be displayed there.

2. On the animation editor, make sure every part that moves has its keys set up properly

3. The CFrame of the camera inside the viewport will be the CFrame of your "subject" in the workspace, make sure the "subject" part is positioned properly, where your camera will be in-game, usually where the rig head is.

4. Verify the script `SLOWMOTION_MODIFIER` variable, I created it because my animations were way too fast, I wanted to visualize them better, the default is 1, if you want normal animation speed set it to 0.

Know issues / downsides
--

1. Every time you want to visualize it you'll have to save the animation

2. I didn't make a timeline so if you want to visualize a pose individually you'll either have to go to `ServerStorage>RBX_ANIMSAVES>yourViewmodelName>Automatic Save` and delete all keyframes except the one with the pose you want to visualize **or** fix the issue 1, or code a timeline on your local plugin.

----

I know that animating in Blender is an option but in Roblox also has its advantages, see the first link in this topic.

This local plugin was made in around 5 hours as a temporary solution for previewing my viewmodel animations, however, my code is quite improvised and lacks polishing (e.g. issues 1 and 2), if you know a better resource please link it to this topic, it will help not only me but also anyone searching for something similar, I couldn't find one.

If you see anything you can improve in the source code feel free to fork the repository.

Update 05/06/2024
Code readability changes

Now when you click the start button if your camera subject and ViewModel are already set up you just have to save the animation on the editor, the plugin now auto-detects saves. (local, not uploading to Roblox)

The changes are already committed to the repository.
