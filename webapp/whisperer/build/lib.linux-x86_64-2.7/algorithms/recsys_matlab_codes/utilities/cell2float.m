function [M, Q] = cell2float(C, Filler)
% CELL2FLOAT - converts cell array into scalar float array
%    M = CELL2FLOAT(C) returns a float array M with the same size as the
%    cell array C. C can be any N-dimensional cell array. Cells of C that
%    contain a scalar float (single or double) are put in corresponding
%    locations of M. Cells that contain other datatypes (e.g., strings,
%    arrays, empty, integers, etc.) yield NaNs in the corresponding
%    locations of M. 
%
%    M = CELL2FLOAT(C,F) uses the value F instead of NaN to fill these
%    latter locations. F should be a scalar float (single or double).
%
%    [M,Q] = CELL2FLOAT(C, ..) returns a logical array Q with logical ones
%    (true) where the values of C are floats, and logical zeros (false)
%    elsewhere.
%
%    Example:
%      C = {single(1) 2 'x' [] ; 1:3 complex(1,2) uint8(1) Inf}
%      M = cell2float(C)
%      % -> [ 1.00  2.00          NaN  NaN ;         
%      %       NaN  1.00 + 2.00i  NaN  Inf  ]
%
%      cell2float({1 2 [] 3 [] 5},999)
%      % -> [ 1  2  999  3  999  5 ]
%
%    See also CELL2MAT, CELLFUN, NUM2CELL

% for Matlab R13+
% version 2.2 (may 2008)
% (c) Jos van der Geest
% email: jos@jasen.nl
%
% History
% 1.0 (sep 2007) created 
% 2.0 (apr 2008) added help and updated for the File Exchange
% 2.1 (apr 2008) fixed spelling errors
% 2.2 (may 2008) fixed spelling errors


% check the inputs
error(nargchk(1,2,nargin)) ;

% first input should be cell array
if ~iscell(C), 
   error('cell2float:BadInput','First input should be cell array') ; 
end

if nargin<2,    
    % default filler value: NaN
    Filler = NaN ;
elseif numel(Filler) ~= 1 || ~isfloat(Filler)
    % filler should be s scalar float
    error('cell2float:BadInput','Filler should be a scalar float') ;
end

% pre-allocate the matrix with the filler value
M = repmat(Filler,size(C)) ;  

% which cell elements are scalar doubles or singles?
Q = cellfun('prodofsize',C)==1 & ...
    (cellfun('isclass',C,'double') | cellfun('isclass',C,'single')) ;

% put these in M in the corresponding locations
M(Q) = [C{Q}] ;