# Carmine
A simple CTA and Pace bus tracker app for your menu bar. macOS 12.0+

CTA Bus Tracker API key is required. Apply for one at [https://www.ctabustracker.com/dev-account](https://www.ctabustracker.com/dev-account)

Once it is supplied, simply build and run the app.

By default it will hide routes that are not in service. To show them, change the CMHideOutOfServiceRoutes property in the app's Info.plist to false.
The app also auto-refreshes every 720 seconds by default, which can be changed by editing the CMRefreshInterval property.

New with 2.0: Pace support has been added! You can view the location of any stop or active vehicle on the route.

New with 3.0: Find My Bus has been added! Configure the default bus.plist within the app, or hold Option and click on the CTA or Pace menu entries to open a window to search for active buses.
