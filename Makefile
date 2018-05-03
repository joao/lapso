run:
	ruby app.rb

install:
	gem install mini_magick

macos_install:
	brew install imagemagick
	brew install ffpmeg
	gem install mini_magick