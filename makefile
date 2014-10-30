VLOG	=	ncverilog
SRC	=	lzc.v\
		lzc_t.v
VLOGARG	=	+access+r

TEPFILE	=	*.log	\
		ncverilog.key	\
		nWaveLog	\
		INCA_libs
DBFILE	=       *.fsdb  *.vcd   *.bak
RM	=	-rm	-rf

all :: sim

sim :
	$(VLOG)	$(SRC)	$(VLOGARG)

clean :
	$(RM)	$(TMPFILE)

veryclean :
	$(RM)	$(TMPFILE)	$(DBFILE)
