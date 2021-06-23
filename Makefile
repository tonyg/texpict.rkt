slides.pdf: main.rkt texpict.rkt
	slideshow --trust --pdf -o $@ $<

clean:
	rm -f slides.pdf

preview: main.rkt texpict.rkt
	slideshow --trust $<
