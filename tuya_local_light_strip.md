# How to add tuya lights to homeassistant

This is how you configure the lightstrip with homeassistant and the addon local\_tuya

0. Download HACS [Link](https://hacs.xyz/) 
1. Start by downloading local\_tuya in homeassistant [Link](https://github.com/rospogrigio/localtuya#readme)
2. Get device\_id using tuya developer iot for cloud by connecting with the tuya phone app 
3. Local\_key can be found at [Link](https://eu.iot.tuya.com/cloud/explorer?id=p1674299231471u4vpg4&groupId=group-1633641687672688668&interfaceId=1633017242343972900) using the device\_id
## __Config time__
4. Follow this config for a light with both color warmth and color:
```
platform: light
friendly_name: entity name
id: 20 # Usually 1 or 20
color_mode: 21 # Optional, usually 2 or 21, default: "none"
brightness: 22 # Optional, usually 3 or 22, default: "none"
color_temp: 23 # Optional, usually 4 or 23, default: "none"
color: 24 # Optional, usually 5 (RGB_HSV) or 24 (HSV), default: "none"
brightness_lower: 29 # Optional, usually 0 or 29, default: 29
brightness_upper: 1000 # Optional, usually 255 or 1000, default: 1000
color_temp_min_kelvin: 2700 # Optional, default: 2700
color_temp_max_kelvin: 6500 # Optional, default: 6500
scene: 25 # Optional, usually 6 (RGB_HSV) or 25 (HSV), default: "none"
```
taken from [This reddit post](https://www.reddit.com/r/homeassistant/comments/rjnm1m/need_help_setting_up_a_local_tuya_light_strip/)

5. Enjoy the light!
