PROG=coherence
# version number from changelog in demo file
DEMOFILE=demo_${PROG}
VER=$(shell grep ' v[0-9]' ${DEMOFILE}.m | head -1 | sed -e 's/.* v\([.0-9][.0-9]*\).*/\1/')
DST=${PROG}-v${VER}
#TAR=${DST}.tgz
ZIP=${DST}.zip

SRCDSTDIR=projects/${PROG}/code
WEBDSTDIR=LabROSA/projects

MATLAB=/usr/bin/Matlab

DEMOFILE=demo_${PROG}

SRCS=${DEMOFILE}.m fprint_expts.m xcorr_expts.m xcorr_peruser.m Makefile

DATA=

EXTRABINS=

DEMOHTML=html/${DEMOFILE}.html
DEMOINDEX=html/index.html

all: dist

${DEMOHTML}: ${SRCS} ${DATA} 
	${MATLAB} -r "publish ${DEMOFILE}; exit"

${DEMOINDEX}: ${DEMOHTML}
	sed -e 's@<div class="content">@<a href="http://labrosa.ee.columbia.edu/">LabROSA</a> : <a href="http://labrosa.ee.columbia.edu/projects/">Projects</a> : <div class="content"> @' -e 's/amp;auml;/auml;/g' -e 's/@VER@/${VER}/g' < ${DEMOHTML} > ${DEMOINDEX}

sync:
	rsync -avz ${SRCS} ${DATA} Makefile hog.ee.columbia.edu:${SRCDSTDIR}/

dist: ${SRCS} ${DATA} ${DEMOINDEX}
	rm -rf ${PROG}
	rm -rf ${DST}
	mkdir ${DST}
	cp -pr html/* ${DST}
	rm ${DST}/${DEMOFILE}.html
	cp -p ${SRCS} ${DATA} ${EXTRABINS} ${FORCOMPILE} ${DST}
	rm -f ${DST}/*~
	-rm-extended-attribs.sh ${DST}
#	tar cfz ${TAR} ${DST}
	zip -r ${ZIP} ${DST}
# needs to be called PROG (no ver number) not DST on server
	mv ${DST} ${PROG}
	cp -p ${ZIP} ${PROG}
	scp -pr ${PROG} hog.ee.columbia.edu:public_html/${WEBDSTDIR}/
	scp -pr ${PROG} fac1.ee.columbia.edu:/q/www/www-h1/dpwe/${WEBDSTDIR}/
	scp -pr ${PROG} labrosa.ee.columbia.edu:/var/www/dpwe/${WEBDSTDIR}/

