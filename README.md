# Hue Experiment

Tweet me [@reddavis](http://twitter.com/reddavis)

Email me me@red.to

Hire me http://red.to

## Overview

Philips make this TV: [http://www.youtube.com/watch?v=J1zmiGtrPOo](http://www.youtube.com/watch?v=J1zmiGtrPOo). I don't own this TV but I do own a TV and some Hue lights. 

So I built this as a proof of concept: [http://www.youtube.com/watch?v=i7ObgN--NV4](http://www.youtube.com/watch?v=i7ObgN--NV4)

What you don't see is someone pointing the iPhone at the TV. The iPhone then calculates the average colour and luminosity, then updates the Hue lights appropriately.

## Experiments/TODO

- Play around with FPS we capture the image.
- Rather than looking at every pixel to calculate the average colour, try every nth pixel.
- Just look at the bordering pixels, they should provide us with with enough information to get the ambient colour. However, this does require the iPhone to have the full screen in shot and not move too much.

## Getting Started

- Own a TV
- Own Hue light(s)
- Have the means to power them
- In HUEHomeViewController set **HUEBridgeIPAddress** and **HUEBridgeMACAddress**. You can find your Hue bridge details by going to:
	- https://www.meethue.com
	- "My Settings"
	- "My Bridge"
	- "Show More"
- Compile the app onto your iPhone
- If all has worked, then it should ask you to push the button on your bridge
- Lights **should** start changing

## License

Copyright (c) Forever and ever Red Davis

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
