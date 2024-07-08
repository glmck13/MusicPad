#!/usr/bin/env python3

import evdev, time, os

plugged_in = True

while True:
	device = None
	while not device:
		for device in [evdev.InputDevice(path) for path in evdev.list_devices()]:
			name = device.name.lower()
			if "keypad" in name or "bluetooth key" in name:
				if not plugged_in:
					print("MSG_WELCOME", flush=True)
				plugged_in = True
				device.grab()
				break
		else:
			plugged_in = False
			device = None
			time.sleep(3)

	try:
		for event in device.read_loop():
			if event.type == evdev.ecodes.EV_KEY and event.code != evdev.ecodes.KEY_NUMLOCK and not event.value:
				print(evdev.categorize(event), flush=True)
	except:
		#break
		pass
