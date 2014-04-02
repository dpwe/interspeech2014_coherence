function FPR = fprint_expts(prefix, uids, dens, thop, tlen)
% FPR = fprint_expts(prefix, uids, dens, tlen)
%
% Calculate full set of between-subject fprint-based proximity
% scores; return single matrix
%
% 2014-04-01 Dan Ellis dpwe@ee.columbia.edu

% Where data is + filename prefix
if nargin < 1;  prefix = '../20140125/20140125_1352-'; end
% Users (to build full file names)
if nargin < 2;  uids = {'bm', 'cr', 'dl', 'de', 'hp', 'zc'};  end
% fprint parameters
% fprint target density
if nargin < 3; dens = 30; end
% Step between successive samples in return
if nargin < 4; thop = 2.0; end
% Total length of time to report on (30 mins)
if nargin < 5; tlen = 30.0 * 60; end

nusers = length(uids);

% How many cols in each time vector
tcols = round(tlen/thop);

% Other fingerprinter parameters
%dens = 30;
sr = 11025;
THOP = 256/sr; % 0.02322 s

% Options to run this time
rebuild_db = 1;
rerun_queries = 1;

% Array of audio file names
for i = 1:nusers
  dbtrks{i} = [prefix, uids{i},'.mp3'];
end

if rebuild_db
  % Build the database
  % More fingerprinter parameters
  % normal
  nhashbits = 20;
  nhashes = 2^nhashbits;
  maxnentries = 100;
  NOJENKINS = 1;
  % not normal - need a larger timesize to uniquely identify times
  % in very long recordings
  TIMESIZE = 2^18; % about 6000 secs at 23ms/tick
  % initialize new database
  ht_clear(nhashes, maxnentries,TIMESIZE,THOP,sr,NOJENKINS);

  % add each of tracks
  add_tracks_byname(dbtrks, 0, 0, dens, 0, THOP, sr);

end

% Query oversampling mode
OSAMP = 0;
% Target duration time in fingerprinter time frames
cmax = ceil(tlen/THOP);

if rerun_queries

  % Run queries for each user
  for i = 1:nusers
    disp(['Querying ', uids{i}]);
    dq = audioread(dbtrks{i}, sr);
    % build query
    [Lq,THOP] = find_landmarks(dq,sr, dens, THOP, OSAMP, sr);
    % add in quarter-hop offsets too for even better recall
    Lq = [Lq;find_landmarks(dq(round(THOP/4*sr):end),sr, ...
                            dens, THOP, OSAMP, sr)];
    Lq = [Lq;find_landmarks(dq(round(2*THOP/4*sr):end),sr, ...
                            dens, THOP, OSAMP, sr)];
    Lq = [Lq;find_landmarks(dq(round(3*THOP/4*sr):end),sr, ...
                            dens, THOP, OSAMP, sr)];
    % Actual hashes
    Hq = unique(landmark2hash(Lq), 'rows');
    % Get returns for each user
    %UFP{i} = zeros(nusers, cmax + cspread -1);
    UFP{i} = zeros(nusers, cmax);
    % Get the actual hits for each user, and return details for all
    % the hits at once, using new functionality added to ht_match
    USERAWCOUNTS = 0; MATCHWIDTH = 1; 
    [R,L,THOP] = ht_match(Hq,USERAWCOUNTS,MATCHWIDTH,[1:nusers]);
    % Inspect the details on each of the returns
    for j = 1:nusers
      % Only look at ~zero-skew matches
      goodL = find(abs(L{j}(:,5)-R(j,3)) < 3);
      % find the counts of each value (given that L{j}(:,4) is sorted)
      [C,IA] = unique(L{j}(goodL, 4));
      NC = diff([0,IA']);
      r = zeros(1,cmax);
      r(C) = NC;
      UFP{i}(R(j, 1),:) = r;
    end
  end
end

% Width of blurring to turn individual hits into an average match rate
tspread = 5.0;
cspread = ceil(tspread/THOP);
FPR = zeros(nusers * nusers, round(tlen/thop));

% Fill in the output array and plot the plot
for i=1:nusers; 
  subplot(nusers,1,i); 
  ufp = UFP{i};
  ufplen = length(ufp);
  % smooth over the window
  win = hanning(2*cspread + 1)'; % a row, so we spread in time (not user!)
  ufp = conv2(win/sum(win), ufp);
  % Downsample to one point every thop sec
  % buggy, quantized step gives same results as paper (EER=13.5%)
  %ufp = ufp(:, cspread+round(thop/THOP)*(-1+[1:round(tlen/thop)]));
  % Improved, nearest-frame sampling improves EER to 11.8%
  ufp = ufp(:, cspread+round([thop:thop:tlen]/THOP));
  imagesc([1:length(ufp)]*thop/60,1:nusers,ufp);
  caxis([0 0.05]); 
  axis([0 tlen/60 0.5, nusers+0.5]); 
  title(uids{i});
  FPR((i-1)*nusers + [1:nusers], :) = ufp;
  % Add time axis only on bottom plot
  if i < nusers
    set(gca, 'XTick', []); 
  else
    set(gca, 'XTick', 1:floor(tlen/60));
    xlabel('time / min');
  end
  set(gca,'YTick', 1:nusers); 
  set(gca, 'YTickLabel', uids); 
end

colormap(1-gray);
