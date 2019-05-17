# path-ios-master

## Features we have done currently
We have linked to the Yelp API, Google Maps and Google Places API. (Note that Google Routes is not implemented)
We have created a function onCoord that runs the getStart and getEnd methods to find coordinate values from physical addresses that are inputed by the user and cast them into CLLocationCoordinate2D objects (loc1, loc2). These physical addresses must be full addresses (i.e 101 East 10th Street New York, NY 10003)
Once this onCoord(Get Coordinate on the UI) is pressed, then the user presses the onGo(Go on the UI) to retrieve a route (MUST BE A WALKING ROUTE) from the start and end points. 
Right now, we have a simple fetchRoute function that is supposed to draw a route from the two CLLocationCoordinate2D objects that we created, but it does not work as expected. 


## Features we want done by 11:30 AM May 6 EST if possible (please let us know beforehand if you don't think this is possible)
We want this app to be limited to just the state of New York, thereby enhancing the use of only walking routes
We want to fix the fetchRoute function, or create a new one, that displays the walking route between the two CLLocationCoordinate2D Objects. 

## Later features by evening May 7
We want to display restaurants using the Google Places API to only show restaurants along the route path

