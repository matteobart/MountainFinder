# Mountain Finder iOS App
This is meant to be a companion app to the [Mountain Project](https://www.mountainproject.com/) website and mobile app. All data is being pulled from the Mountain Project [API](https://www.mountainproject.com/data). This app is different as it allows you to find the climbs closest to you and allow you to filter by type of climb.

## Setup
You will need your own API key to get this code to run. First signup or login for an account [here](https://www.mountainproject.com/). Then your private key can be found [here](https://www.mountainproject.com/data).  
To get this code running you will need to set one global variable somewhere in the code:
```
let apiKey = "YOUR_OWN_API_KEY"
```
 
## Use
### Main 
The app should be intuitive enough to use. However it may be worth explaining how it works. The idea is that you will use the map to find the closest climbs near a location. The blue circle is the max distance of the climbs that will be searched and shown in the list below. When clicking search, the nearby climbing locations will automatically be downloaded to your device for future use (once you searched in an area there is no reason to search there again). Any pins inside your blue circle will also show in the list below sorted by distance to you. By toggling the different types of climbs will hide/show them on both the map and list. 

### Detail
By tapping a pins info or tapping an item in the list will open the detail view. From here you can see more information about a climb and open the information in other apps. "Open in Safari" will open the corresponding Mountain Project page. 
"Open in Apple Maps" will open Apple Maps with the supplied coordinates. "Copy" will replace your clipboard's contents with the value `LATITUDE, LONGITUDE` both coordinates will have 4 decimals of precision.

## Screenshots
### Main Screen
![main screen](/imgs/main.png)
### Main Screen Filtered
![filtered screen](/imgs/mainFiltered.png)
### Detail View
![detail screen](/imgs/detail.png)