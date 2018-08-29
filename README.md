# Robozonky dockerized #
## WARNING ##
* This container image was not fully tested on live data, be sure to understand how robozonky works before using this container.

## Project page ##
* Official website or RoboZonky: <http://www.robozonky.cz>
* This work is based on official docker container: <https://hub.docker.com/r/robozonky/robozonky/>

## How to deploy docker image
* pull latest image from hub

```
docker pull quoing/robozonky
  ```
* create keystore (in case you need one), don't forget to change keystore filename, keystore password and email, password. For more details see robozonky CLI documentation.

```
docker run -ti --rm 
  -v $(PWD)/var:/var/robozonky 
  -v $(PWD)/etc:/etc/robozonky 
  quoing/robozonky 
  robozonky-cli zonky-credentials -k default.keystore -s testovaci -u muj@example.com -p nejtajnejsi
```
* if you didn't use installer you will need to create:
  * robozonky.properties file in etc directory (it might be empty)
  * strategy file in etc directory
* start the container
  * available parameters:
    * DRY - dry-run, no money will be used, good for testing, to disable dry-mode omit this parameter
    * KEYSTORE - name of keystore file to use
    * KEYSTORE_PASSWORD - keystore password
    * STRATEGY - strategy filename (full path required eg. /etc/robozonky/default.txt)

```
docker run -ti --rm 
  -v $(PWD)/var:/var/robozonky 
  -v $(PWD)/etc:/etc/robozonky 
  -e "DRY=yes"
  -e "KEYSTORE=default.keystore"
  -e "KEYSTORE_PASSWORD=testovaci"
  -e "STRATEGY=/etc/robozonky/default.txt"
  quoing/robozonky
```

## Report bugs ##
* To report problems with robozonky **container image** please use GitHub <https://github.com/quoing/robozonky>.
