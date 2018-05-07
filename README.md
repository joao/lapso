![](lapso_logo.png)

[Presentation Video](https://youtu.be/45GLf49cI6w)

Requires:  
- imagemagick
- ffmpeg  
- mini_magick (Ruby gem)

To install the Ruby gem ``mini_magick``:  
``make gem_install``

To install everything in macOS:  
``make macos_install``

To run:  
``make run``

- settings are located in ``app.rb``.  
- if a website has thousands of entries in [Arquivo.pt](https://arquivo.pt), it will take a few hours to generate the video. You can keep an eye on the progress via the terminal output.  
The bottleneck is downloading the webpage's screenshots, as they are generated on demand.