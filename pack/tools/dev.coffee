# Dev
# True if we're in dev, false otherwise.
# We ignore IE because some of the stuff we want to do freaks it out.
Make "Dev", window.top.location.port is "3000" and not navigator.userAgent.match /Trident/
