# What is the point of this project?
I want to enforce an open-door policy in my room, and this is one way to do it. You can check to see if my doors are open at any time by going to [arebensdoorsopen.com](arebensdoorsopen.com).

## How is this project structured?

## What needs to be done now?
I need to return the timestamp and display it at a different part of the index.html file, for one. I also need to make styles.css nicer; I would like to make it as nice looking a text website as I can make it. Eventually I'd like to make it a webhook into a dynamodb table so the live internet isn't pinging my actual home assistant instance, but I'm not super concerned about that now. If I need to I can run `terraform destroy` if my HA instance gets DDOS'ed.
# What is the point of this project?
I want to enforce an open-door policy in my room, and this is one way to do it. You can check to see if my doors are open at any time by going to [arebensdoorsopen.com](arebensdoorsopen.com).

## What next?
A few updates I'd like to make:
- Add tests
- Return a timestamp for the last time the door was closed/opened
- Make the website styles not so ugly
- Make the backend a webhook

But those are unlikely to happen, because this website fulfills its purpose just fine the way it is.