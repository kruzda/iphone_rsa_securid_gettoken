#!/usr/bin/env bash
app_pid=$(ps ax -o pid,comm | grep "SecurID$" | awk '{print $1}')
pin=$(grep pin $HOME/.gettoken | cut -d'=' -f 2)
if [ -z $app_pid ]; then
	activator send com.rsa.securid.iphone.SecurID
	sleep 3
	app_pid=$(ps ax -o pid,comm | grep "SecurID$" | cut -f 1 -d' ')
fi
current_state=$(cynject $app_pid /usr/lib/libcycript.dylib -e 'UIApp.keyWindow.rootViewController.visibleViewController')
if echo $current_state | grep -o RsaSecViewControllerPin >/dev/null; then
	cynject $app_pid /usr/lib/libcycript.dylib -e 'objc_msgSend(objc_msgSend(objc_msgSend(UIApp, "keyWindow"), "rootViewController"), "visibleViewController").mPinTextField.text = "'$pin'"' >/dev/null
	cynject $app_pid /usr/lib/libcycript.dylib -e 'objc_msgSend(objc_msgSend(objc_msgSend(objc_msgSend(UIApp, "keyWindow"), "rootViewController"), "visibleViewController"), "handleSubmitButton:", 64)'
	sleep 1
fi
current_state=$(cynject $app_pid /usr/lib/libcycript.dylib -e 'UIApp.keyWindow.rootViewController.visibleViewController')
if echo $current_state | grep -o RsaSecViewControllerOtp >/dev/null; then
	remaining=$(cynject $app_pid /usr/lib/libcycript.dylib -e 'objc_msgSend(objc_msgSend(objc_msgSend(UIApp, "keyWindow"), "rootViewController"), "visibleViewController").mSecsRemainingLabel.text.toString()' | tr -d '"')
	token=$(cynject $app_pid /usr/lib/libcycript.dylib -e 'objc_msgSend(objc_msgSend(objc_msgSend(UIApp, "keyWindow"), "rootViewController"), "visibleViewController").mTokenInfo.mOtp.toString()')
	echo "{\"token\": $token, \"valid_for_seconds\": $remaining}"
else
	echo "app_pid: $app_pid"
	echo "unrecognised state: $current_state"
fi
