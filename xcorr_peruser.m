function zmr = xcorr_peruser(srcuser, twin, thop, tlen, uids, prefix)
% zmar = xcorr_peruser(srcuser, twin, thop, tlen, uids, prefix)
%
% Run cross-correlation between coherence recordings.
% Return length(uids) rows as the cross-correlations between 
% uids{srcuser} and all the other users.
% # colums set as tlen/thop.
%
% 2014-03-22 Dan Ellis dpwe@ee.columbia.edu

if nargin < 2; twin = 10.0; end
if nargin < 3; thop = 2.0; end
if nargin < 4; tlen = 30.0*60.0; end
if nargin < 5; uids = {'bm', 'cr', 'dl', 'de', 'hp', 'zc'}; end
if nargin < 6; prefix = '../20140125/20140125_1352-'; end

nusers = length(uids);

xcorrwinsec = twin;
xcorrmaxlagsec = 1.0;
xcorrhopsec = thop;

xcorrpeakthresh = 0.2;

sr = 2000;

xcorrwin = round(sr * xcorrwinsec);
xcorrmaxlag = round(sr * xcorrmaxlagsec);
xcorrhop = round(sr * xcorrhopsec);

dr = audioread([prefix, uids{srcuser}, '.mp3'], sr);

nframes = round(tlen / thop);
zmr = zeros(nusers, nframes);

for i = 1:nusers
%  if i ~= srcuser
    % code borrowed from skewview.m
    dt = audioread([prefix, uids{i}, '.mp3'], sr);
    [Z,E] = new_stxcorr(dr,dt,xcorrwin,xcorrhop,xcorrmaxlag);
    % normalized xcorr
    ZN = Z.*repmat(1./E,size(Z,1),1);
    [zmax,zmaxpos] = max(ZN);
    %zmax = zmax/max(zmax);
    nactframes = min(length(zmax), nframes);
    zmr(i,1:nactframes) = zmax(1:nactframes);
    % remove points where correlation is much lower than peak
    %zmaxpos(find(zmax<(xcorrpeakthresh*max(zmax)))) = NaN;
end

% Make index of non-target users
xusers = ones(1,nusers);
xusers(srcuser) = 0;
xusers = find(xusers);

DISPLAY = 0;
if DISPLAY
  imgsc(zmr);
  title(uids{srcuser});

  set(gca, 'YTick', 1:nusers);
  set(gca, 'YTickLabel', uids);

  caxis([0 max(max(zmr(xusers,:)))]);
end


