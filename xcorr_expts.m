function XCR = xcorr_expts(prefix, uids, twin, thop, tlen)
% XCR = xcorr_expts(prefix, uids, twin, thop, tlen)
%
% Calculate full set of between-subject xcorrs; return single matrix
%
% 2014-04-01 Dan Ellis dpwe@ee.columbia.edu

% Where data is + filename prefix
if nargin < 1;  prefix = '../20140125/20140125_1352-'; end
% Users (to build full file names)
if nargin < 2;  uids = {'bm', 'cr', 'dl', 'de', 'hp', 'zc'};  end
% Cross-correlation parameters
% Window length
if nargin < 3; twin = 10.0; end
% Step between successive windows
if nargin < 4; thop = 2.0; end
% Total length of time to report on (30 mins)
if nargin < 5; tlen = 30.0 * 60; end

nusers = length(uids);

% How many cols in each time vector
tcols = round(tlen/thop);

recalc_xcorrs = 1;
if recalc_xcorrs
  XCR = zeros(nusers * nusers, tcols);
end

for i=1:nusers; 
  subplot(nusers,1,i);
  % rows for this user
  urows = (i-1)*nusers + [1:nusers];
  if recalc_xcorrs
    zmr = xcorr_peruser(i, twin, thop, tlen, uids, prefix);
    ncols = min(size(zmr, 2), tcols);
    XCR(urows, 1:ncols) = zmr(:, 1:ncols);
  end
  % plot
  imagesc([1:size(XCR, 2)]*thop/60,1:nusers, XCR(urows, :)); 
  caxis([0 0.3]);
  axis([0 tlen/60 0.5, nusers+0.5]); 
  title(uids{i});
  % Add xtick only on lowest plot
  if i < nusers
    set(gca, 'XTick', []); 
  else
    set(gca, 'XTick', 1:floor(tlen/60));
    xlabel('time / min');
  end
  % label ytick with user IDs
  set(gca,'YTick', 1:nusers); 
  set(gca, 'YTickLabel', uids); 
end

colormap(1-gray);
