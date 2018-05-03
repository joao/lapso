# Lapso
  
Requires:  
- imagemagick  
- ffmpeg  
- mini_magick (Ruby gem)

To install the Ruby gem ``mini_magick``:  
``make gem_install``

To install everything in macOS:  
``make macOS install``

To run:  
``make run``

Settings are located in ``app.rb``.  
If a website has thousands of entries in [Arquivo.pt](https://arquivo.pt), it will take a few hours to generate the video. You can keep tabs on the progress via the terminal output. The bottleneck is downloading the webpage's screenshots, as they are generated on demand.