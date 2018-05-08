![](lapso_logo.png)  
### 🇵🇹🎬 Timelapser for Arquivo.pt

Built for [Prémio Arquivo.pt 2018](http://sobre.arquivo.pt/pt/colabore/candidatura-aos-premios-arquivo-pt-2018/), with [Journalism++ Porto](http://jplusplus.org/en/).  
Watch the [Presentation video](https://youtu.be/45GLf49cI6w) (in portuguese).  

Timelapse examples:
- [sapo.pt](https://youtu.be/CR7ZyXg0Nr4)
- [publico.pt](https://youtu.be/hrva9ieJMSE)
- [presidencia.pt](https://youtu.be/NrsCsWwzeAc)
- [portugal.gov.pt](https://youtu.be/ARKPhSnN588)
- [psd.pt](https://youtu.be/3pgul52EFSE)
- [dns.pt](https://youtu.be/UPay7KM9YeQ)
- [ist.utl.pt](https://youtu.be/-lngjRoECL4)

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