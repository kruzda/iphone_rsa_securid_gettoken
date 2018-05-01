# iphone_rsa_securid_gettoken
a shell script using cynject to grab the current token shown from an RSA SecurID iPhone app

Requirements:
* a jailbroken iphone - see https://www.reddit.com/r/jailbreak
* openssh server - https://www.reddit.com/r/jailbreak/comments/5r2mwr/tutorial_how_to_use_dropbear_ssh_via_usb_on/
* cynject - from https://github.com/simpzan/cycript
* Clutch to decrypt the SecurID app - http://digitalforensicstips.com/2015/05/a-quick-guide-to-using-clutch-2-0-to-decrypt-ios-apps/
* activator so the app can be launched by the script - http://cydia.saurik.com/package/libactivator/
* a file containing the pin to be entered to the app - stored in $HOME/.gettoken using the format "pin=1234"

Optional:
* a script using jq and pbcopy on the receiving end, for example:
```
#!/usr/bin/env bash
if [ -z $(idevice_id -l) ]; then
    read -p "Phone not found. Connect it and press any key."
fi
ssh -p 2222 root@localhost /private/var/root/gettoken.sh | jq -j .token | pbcopy
```
