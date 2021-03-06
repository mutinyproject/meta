name = mutiny
version = 20200703

prefix ?= /usr/local
datarootdir ?= ${prefix}/share
datadir ?= ${datarootdir}
docdir ?= ${datarootdir}/doc/${name}
htmldir ?= ${docdir}

ASCIIDOCTOR ?= asciidoctor

ASCIIDOCTOR_FLAGS += --failure-level=WARNING
ASCIIDOCTOR_FLAGS += -a manmanual="Mutineer's Guide"
ASCIIDOCTOR_FLAGS += -a mansource="Mutiny"
ASCIIDOCTOR_FLAGS += -a toc@
ASCIIDOCTOR_FLAGS += -a toclevels@=3
ASCIIDOCTOR_FLAGS += -a idprefix@
ASCIIDOCTOR_FLAGS += -a sectanchors@
ASCIIDOCTOR_FLAGS += -a sectlinks@

-include config.mk
-include site/config.mk

AUXS = \
    logo.svg \
    style.css

MAN7 = \
    mutiny.7 \
    software.7

MANS = ${MAN7}
HTMLS = ${MANS:=.html}

all: FRC man

man: FRC ${MANS}
html: FRC ${HTMLS}


site: FRC
	sh site.sh ${ASCIIDOCTOR_FLAGS} \
	    -a stylesheet@=./style.css \
	    -a linkcss@

.SUFFIXES:
.SUFFIXES: .adoc .html

.adoc.html: footer.adoc style.css
	${ASCIIDOCTOR} -b html5 ${ASCIIDOCTOR_FLAGS} -o $@ $<

.adoc: footer.adoc
	${ASCIIDOCTOR} -b manpage -d manpage ${ASCIIDOCTOR_FLAGS} -o $@ $<

install-man: ${MANS}
	install -d \
	    ${DESTDIR}${man7dir}

	for man7 in ${MAN7}; do install -m0644 $${man7} ${DESTDIR}${man7dir}; done

install-html: ${HTMLS} ${AUXS}
	install -d \
	    ${DESTDIR}${htmldir}

	for file in ${AUXS} ${HTMLS}; do install -m0644 $${file} ${DESTDIR}${htmldir}; done
	ln -sf mutiny.7.html ${DESTDIR}${htmldir}/index.html

install: install-man

clean: FRC
	rm -f ${HTMLS} ${MANS}

.DELETE_ON_ERROR: README
README: mutiny.7
	man ./$? | col -bx > $@

FRC:
