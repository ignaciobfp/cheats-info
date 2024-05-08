# Introduction
Until now, I have been running my mount and cameras directly from a Windows 10 laptop. While that has worked fine, it has always meant needing to set up my laptop pretty near the telescope assembly to allow all the cables to connect. More importantly, it also means that I have to keep a Windows laptop around instead of my normal Linux daily driver. (I use a celestron mount and use CPWI). So, I finally decided to buy a small Windows mini-PC to run the mount and camera. I settled on a [Mele Quieter3C mini-PC](https://www.amazon.com/dp/B0B773V4K3).

My desire is to keep the equipment that I need to haul around with my setup to a minimum, so I wanted to avoid the need for any sort of router in the setup. Ideally, the mini-PC should host a hotspot that I can connect to and then use RDP to access the mini-PC. Sounds simple enough, except that it seems that Windows 11 doesn't have the ability to host a wireless network if it isn't sharing an already existing wifi or ethernet connection. Why Microsoft makes such decisions is beyond me; it seems that the two capabilities, while often useful together, are completely independent.

Since it took me about 3 days to find a solution (finally found the key information on [this superuser question](https://superuser.com/a/1620860/1836426)), I thought I would provide a write-up in hopes that others will find it more readily than I found that answer.

## Hosting a hotspot with Windows 11 without another network to share:

### 1. Create a loopback interface

In order to create a hotspot, Windows 11 needs to create a tether to an existing network connection. Presumably, Microsoft developers couldn't imagine a use for a hotspot except for sharing an internet connection. For those of us who set up equipment far from civilization, this isn't the use case. So, in order to allow us to create the hotspot, we need to create a network that can be shared.

1. Open Device Manager
   - This can be done by right-clicking on the start menu and clicking Device Manager.
2. Select the computer name at the top of the list
3. In the Action menu, select "Add legacy hardware"
4. Click the "Next" button
5. Select "Install the hardware that I manually select from a list"
6. Select "Network Adapters"
7. Click the "Next" button
8. On the left side, select "Microsoft"
   - Note: It may take a moment for these lists to appear and populate, depending on the speed of your mini-PC
9. On the right side, select "Microsoft KM-TEST Loopback Adapter"
10. Click the "Next" button
11. Click the "Next" button
12. Open the Control Panel This can be done by opening the start menu and searching for "Control Panel"
13. Click "Network and Internet"
14. Click "Network and Sharing Center"
15. Click " Change adapter settings" on the left
16. Rename the KM-TEST loopback adapter to "Loopback"
   - For me, it didn't work to right-click and select "Rename". I had to select the device, press the F2 key, then type the new name
17. Restart the mini-PC
   - The rename did not propagate through the system until I restarted. There may be another way to force propagation, but restarting is easy enough.

### 2. Create a start-up script to start a hotspot bound to the loopback interface at boot time

Because I want this to run headless and won't have a way to start it manually, this needs to start automatically at boot time. To do this, I have set my user to automatically log in and then created a batch script to start the hotspot at startup.

1. If not already done, set up automatic login. Instructions for this can be found at [this Microsoft answer](https://answers.microsoft.com/en-us/windows/forum/all/how-to-login-automatically-to-windows-11/c0e9301e-392e-445a-a5cb-f44d00289715)
2. Open Windows run command (Keyboard shortcut: `Win+r`)
3. Type `shell:startup` and click okay
4. Create a new batch script in the startup location with the following contents:

powershell -ExecutionPolicy -ByPass "$profile = [Windows.Networking.Connectivity.NetworkInformation,Windows.Networking.Connectivity,ContentType=WindowsRuntime]::GetConnectionProfiles() | where {$_.profilename -eq 'loopback'}; $tether = [Windows.Networking.NetworkOperators.NetworkOperatorTetheringManager,Windows.Networking.NetworkOperators,ContentType=WindowsRuntime]::CreateFromConnectionProfile($profile); $tether.StartTetheringAsync()"


I saved this as `StartMobileHotspot.bat`

### 3. Change keep the mobile hotspot active

Windows 11 power saving features default to disable the hotspot when nothing is connected. Because I want to be able to connect at any time through the night and not necessarily remain connected, I disabled these settings. I found these steps at [this Beebom site](https://beebom.com/windows-10-mobile-hotspot-keeps-turning-off-fix/#:~:text=Press%20Windows%20%2B%20I%20to%20open,Saving%E2%80%9D%20located%20at%20the%20bottom)

1. Start your hotspot, if not already started, by running the script from Section 2.
2. Disable power saving from the hotspot
   - Open Settings (keyboard shortcut: `Win+i`)
   - Click "Network & Internet"
   - Click "Mobile Hotspot" (not the toggle)
   - Set the toggle for "Power Saving: When no devices are connected, automatically turn off mobile hotspot" to "Off"
   - Change the power management settings to prevent it from turning off the wireless adapter
   - Open Device Manager
   - Expand "Network Adapters" in the list
   - Right-click on your wireless adapter and select "Properties"
   - Click on the "Power Management" tab
   - Deselect the "Allow the computer to turn off this device to save power" check box
   - Click "OK"

### 4. Enable remote desktop

In order to remote from my laptop or tablet, I needed to allow remote desktop connections on the mini-PC

1. Open Settings (shortcut `Win+i`)
2. Click on "System"
3. Click on "Remote Desktop"
4. Set the "Remote Desktop" toggle switch to "On"

This was all I needed to do to set up a hotspot using Windows 11 mini-PC to allow me to connect and remotely control the computer from my laptop while out in the field.
