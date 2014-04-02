interspeech2014_coherence
=========================

Code for Interspeech 2014 paper "Detecting proximity from personal audio recordings"
http://www.ee.columbia.edu/~dpwe/pubs/EllisSC14-proximity.pdf

To recreate figs 2-5 from the paper:

 - Get the data, or something like it.  You'll have to edit the prefix and uids 
   variables at the top of xcorr_expts.m and fprint_expts.m to find them.
   Unfortunately we don't share the data, as it is somewhat personal and 
   sensitive (individual discussions during a poster session).

 - Download skewview
   http://labrosa.ee.columbia.edu/projects/skewview/
   By default, the script expects to find it in ~/projects/skewview, but you can 
   simply modify the add_path in demo_coherence.m

 - Download audfprint
   http://labrosa.ee.columbia.edu/matlab/audfprint/
   By default, the script expects to find it in ~/projects/audfprint, but you can 
   simply modify the add_path in demo_coherence.m

 - Run demo_coherence in Matlab.
   You can see the results at:
   http://labrosa.ee.columbia.edu/projects/coherence/

2014-04-01 Dan Ellis dpwe@ee.columbia.edu
