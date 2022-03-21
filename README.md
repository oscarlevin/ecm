# Exploring Combinatorial Mathematics

A free and open source textbook by Richard Grassl and Oscar Levin, suitable for an upper level undergraduate or Master's level discrete math or combinatorics course, especially if the intended audience is pre-service or in-service secondary teachers. The text borrows material from Bogart's [Combinatorics through Guided Discovery](http://bogart.openmathbooks.org/) and Levin's [Discrete Mathematics: an Open Introduction](http://discrete.openmathbooks.org/), falling somewhere between these in terms of difficulty.

The book is [publicly available](http://www.openmathbooks.org/ecm/ecm.html) in html and pdf versions; an inexpensive paperback version is also available.

## Building from source

The book is written in [PreTeXt](https://pretextbook.org/).  The source is contained in the `source` folder.  To build this source into either html or pdf, first install PreTeXt as described in the [PreTeXt Guide](https://pretextbook.org/doc/guide/html/quickstart-example.html).  This requires python and latex to be installed as well as some other tools for building images.

Once you have PreTeXt installed, you will need to generate images using `pretext build -d -a` and compile the WeBWorK problems using `pretext build -w -a`.  After this, you can build the desired output formats using `pretext build html` or `pretext build pdf`.  Unless you modify any `<latex-image>` or `<webwork>` elements in the source, you won't need to rerun with the `-d` or `-w` flags again.
