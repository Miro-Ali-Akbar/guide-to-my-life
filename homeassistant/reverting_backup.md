# How to revert to a backup in homeassistant
You've broken and or bricked homeassistant - *oh no :(* 
It happens the the best of us but fret not i will show you the way to the light

0. Be smart and have a backup on your google drive using this [addon](https://github.com/sabeechen/hassio-google-drive-backup#readme)
1.  Remove sd card for the raspberry pi preferably after turning the power of
2. Use [Balenaetcher](https://etcher.balena.io/) to wipe and rewrite homeassistant to the sd card.
3. Restart homeassistant and wait for it to finish configuring.
4. Go to [homeassistant](http://homeassistant:8123)and select recover from backup using the backup you have
5. Wait a __long__ time for it to figure things out

Start using homeassistant without making the same mistake you did before!