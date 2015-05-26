# Swipe Through
**Swipe Through** is a set of Adobe Flash components which allow you add quickly gesture based interactivity to your animations. They simply manage the playback of the timeline, back and forth.

Combined with Adobe AIR it is an ideal tool to prototype touch user interfaces on mobile devices.

![](https://github.com/nuthinking/swipe-through/blob/master/ide.png)

## Requirements ##
They have been tested with Adobe Flash Professional CS6 and CC. But they should work also with older versions as long as they support ActionScript 3.0.

## Installation ##
To use the components straight away:

 1. Double-click the package *swipe-through.zxp* in the distribution folder. This should launch *Adobe Extension Manager*.
 2. Accept the terms in *Adobe Extension Manager*.
 3. Start or restart *Adobe Flash Professional*.
 4. Create a new file or open an old one.
 5. Check the new components are available in the *Components* window (open it from *Menu>Window>Components*)

## Usage ##
Once the component is dragged on the timeline, fill the required fileds in the *Components Parameters*. Each component, depending on the gesture, has different requirements but generally you need to define the starting and ending point in the timeline the gesture should be mapped to.

Swipe Through components are invisible when the movie is running, but they can be shown briefly by double-clicking anywhere on the screen. To disable this functionality, add *hideArea = true;* at the root of the movie.

To quickly understand how everything works, have a look at the example project: *examples/all-components/all-components.xfl*

## Components ##
These are the parameters used by some of the components:

**enabled** and **visible**: These are default properties for Flash components. Swipe Through components are already not visible by default.

**\*Action**: Defines what to perform when triggered. In the *Action* fields you can use any standard Flash playback functions like *play* and *gotoAndPlay*. Only difference with ActionScript is that for simiplicity regardless if you are using as parameter for the *gotoAndPlay* a frame number or a lable name, you don't need quotes.  Example: *gotoAndPlay(32)* and *gotoAndPlay(labelName)* are correct.

**From Frame**: Frame where the gesture animation should start. This could be a number of a label name without quotes.

**To Frame**: Frame where the gesture animation should end. This could be a number of a label name without quotes.

**Hint Duration (fr)**: The number of frames which shouldn't be considered as part of the gesture but just as hint.

**Gesture Threshold (%)**: Define the point of the animation the gesture should succeed if released. Using 1, for instance, would mean that the gesture succeeds only if it reached the very last frame (1 is not recommended, default is 0.5).

**Return Home**: Defines if after the gesture animation is ended the playback should go back to the frame where th user was before initiating the gesture.

**Touches Required**: Not supported yet.

### TapArea ###
Use this to create a simple click-through. Default behavior is start playing the timeline from whenever it is.

Own parameters:  
**Taps Required**: Not supported yet.  

### LongPressArea ###
To enable a tap-and-hold gesture.  
It can handle also a tap gesture in the same area.

### PinchArea ###
To enable a pinch gesture.  

Own parameters:  
**Gesture Size (%)**: Defines the final size of the pinch. Using 2, for instance, would mean that whenever my pinch double its size the timeline will be at the of the gesture animation.  

### DragArea ###
To enable drag or swipe gestures.

Own parameters:  
**Direction**: To limit the gesture scope.

### Slider Area ###
To create a multi-state slider.

Own parameters:  
**Border margin**: To allow a larger active area but where the extreme positions are ignored.  
**Orientation**: To limit the gesture scope.  
**Snap Positions**: The array of positions where the slider can rest.

## Run on mobile devices ##
With Adobe AIR the SWF file generated can be packaged to a native application for Android and iOS.

See the example script *examples/all-components/package-ios.sh*

More information on how ADT works can be found [here](http://help.adobe.com/en_US/air/build/WS901d38e593cd1bac1e63e3d128cdca935b-8000.html).

## Support ##
If you encounter any problem, please open an issue here in GitHub. For smaller issues you can ping me on Twitter (@nuthinking).

## Contributions ##
Are obviously welcome. Please create a pull request.
