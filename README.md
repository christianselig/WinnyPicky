<img src="https://i.imgur.com/be0EyGO.jpg" width="50%">

# WinnyPicky

Small iPhone app that powered the Apollo 2020 iPhone 12 giveaway. Slightly more fun than just a script because you can carry it around the house while it runs (since it takes awhile).

At a basic level it takes giveaway threads as input, spins up separate threads to collect all the comments from each (updating the progress to the screen), and once collected removes any users who commented multiple times, then draws a random comment from the resulting collection and outputs the result to the screen.

# How to Use

If you have the most recent version of Xcode installed, simply create a new project (File > New Project) and in the created `ViewController.swift`, swap out the contents with the contents of `ViewController.swift` in this repo. Then just run the project either on a simulator or on an iOS device and you're good to go! You should be able to use it to power a simple giveaway.

# Notes

- Thanks to the [PushShift](https://pushshift.io) API for powering the app, makes it easy to query Reddit at large for research purposes. The PushShift API is run by a very nice person out of his own pocket with donations so it's probably not wise to run this willy-nilly without a goal in mind as it uses the API a fair bit (or if you do, [send him a donation](https://pushshift.io/donations/)).
- Thanks to [u/The_White_Light](https://old.reddit.com/user/The_White_Light) on Reddit for suggesting PushShift for this as well as a cool Python script, as well as [@Smith_Jansen](https://twitter.com/Smith_Jansen2) on Twitter for showing me a [very cool Python library](https://github.com/lilfruini/CommentGathering-MillionaireMakers) for doing a similar thing and offering some pointers. 
- Don't use this library as a "best practices" tool. 😛 There's lots of quick things done (like `Data(contentsOf:)` for a remote resource, and force-unwrapped optionals) that shouldn't be done in a production app.
