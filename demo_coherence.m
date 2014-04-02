%% COHERENCE - Evaluating proximity by comparing personal audio recordings
%
% This script performs some experiments on detecting personal
% proximity by measuring similarity between "personal audio"
% recordings made by body-worn recorders (e.g., smartphones).
% It runs some experiments on a set of 6 time-aligned 30
% minute personal audio recordings made during a "poster session"
% held at Columbia on 2014-01-25.  The idea is that similarity
% between the signals (measured by short-time cross-correlation, or
% by acoustic landmark-based fingerprinting) will tell us when the
% users are close together - and this can be checked by looking at
% a video shot at the same time.  In the end, we compare the two
% methods by thresholding the cross-correlation method to get a
% "truth", then seeing how well the fingerprint-derived measure can
% recover it by plotting a detection-error tradeoff curve.
%
% This code actually generates the plots presented in our
% Interspeech 2014 paper, 
% <http://www.ee.columbia.edu/~dpwe/pubs/EllisSC14-proximity.pdf Detecting proximity from personal audio recordings>
% Daniel P. W. Ellis, Hiroyuki Satoh, Zhuo Chen.
%
% It relies on the cross-correlation functions from 
% <http://labrosa.ee.columbia.edu/projects/skewview/ skewview> 
% (version 0.90), 
% and the landmark-based fingerprinting functions from 
% <http://labrosa.ee.columbia.edu/matlab/audfprint/ audfprint>
% (version 0.9), which you will need to download also.
%
% You can download all the code specific to this experiment in
% <coherence-v@VER@.zip> .
%
% 2014-03-30 Dan Ellis dpwe@ee.columbia.edu

if ~exist('Compute_DET')
  % need to find the NIST DETware tools
  % I got them as 
  % http://www.itl.nist.gov/iad/mig//tools/DETware_v2.1.targz.htm
  % and installed it as a subdirectory
  addpath('DETware_v2.1')
end
% Make sure we have the skewview functions available
if ~exist('new_stxcorr')
  addpath(fullfile(getenv('HOME'), 'projects', 'skewview'));
end
% Make sure we have the audfprint functions
if ~exist('audfprint')
  addpath(fullfile(getenv('HOME'), 'projects', 'audfprint'));
end

% Do we need to recalculate everything?
recalc_xcorr = 1;
recalc_fprint = 1;

%% Alignment of the raw recordings
% 
% The recordings were made on separate recorders.  They started at
% different times, and there was slight clock drift between them. 
% To simplify the later processing, we first aligned them.  This is
% a function provided by the main skewview routine

datadir = '../20140125';
skewview(fullfile(datadir, '100_1198.mp3'), ...
         fullfile(datadir, '20140125 134129.m4a'), ...
         '-win', 30, '-hop', 15, ...
         '-end', 2400, ...
         '-samplerate', 1000, '-minspread', 1);
% Print figure 2 from the paper
%print -depsc skewview-out.eps

%% Calculate cross-correlation measures

if recalc_xcorr
  % Calculate xcorr results matrix
  disp('Calculating XCORR...')
  tic; XCR = xcorr_expts(); toc
  % Elapsed time is 425.051387 seconds.
  % Print figure 3 from the paper
  %orient landscape
  %print -depsc xcorrs-6way-2.eps
end

%% Calculate fingerprint-based measures

if recalc_fprint
  % Calculate fprint results matrix
  disp('Calculating FPRINT...')
  tic; FPR = fprint_expts(); toc
  % Elapsed time is 303.999075 seconds.
  % Print figure 4 from the paper
  %orient landscape
  %print -depsc fprints-6way-2.eps
end

%% Evaluate fingerprint measures against cross-correlation "truth"

% Select only the unique, non-self rows from the nusers^2 results
% rows.  That's everything *below* the self-row in each block
nusers = sqrt(size(XCR, 1));
rr = [];
for i = 1:nusers
  % unique rows are the ones below the self-row in this block
  rr = [rr, (i-1)*nusers + [(i+1):nusers]];
end

% Unique rows in FP and XC
xcrr = XCR(rr,:);
fprr = FPR(rr,:);

% Threshold for near/far on xcorr
xct = 0.15;

% Do the DET calculation using this threshold
[pmiss, pfa] = Compute_DET(fprr(xcrr(:)>xct),fprr(xcrr(:)<=xct));

% Figure equal error rate - point where parametric lines cross
EER = pmiss(min(find(pmiss > pfa)));
disp(['Equal Error Rate = ', sprintf('%.1f', EER*100), '%']);

% Plot the results
subplot(111)
Plot_DET(pmiss, pfa, 'r');
title(['Detection Error Tradeoff for XC threshold ',num2str(xct)])
% Print figure 5 from the paper
%print -depsc fp_DET_curve.eps

%% Changelog
%

% 2014-04-01 v0.1 Initial release
%

%% Acknowledgment
%
% This work was supported in part by IARPA under the ALADDIN
% program via a subcontract from the IBM-led team VOLUME.  
%
% Last updated: $Date: 2014/04/01 22:33:46 $
% Dan Ellis <dpwe@ee.columbia.edu>
