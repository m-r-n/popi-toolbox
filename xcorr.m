## Copyright (C) 1999-2001 Paul Kienzle
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

## usage: [R, lag] = xcorr (X [, Y] [, maxlag] [, scale])
##
## Compute correlation of X and Y for various lags.  
## Returns R(m+maxlag+1)=Rxy(m) for lag m=[-maxlag:maxlag].
## Scale is one of:
##    'biased'   for correlation=raw/N, 
##    'unbiased' for correlation=raw/(N-|lag|), 
##    'coeff'    for correlation=raw/(correlation at lag 0),
##    'none'     for correlation=raw
## If Y is omitted, compute autocorrelation.  
## If maxlag is omitted, use N-1 where N=max(length(X),length(Y)).
## If scale is omitted, use 'none'.
##
## If X is a matrix, computes the cross correlation of each column
## against every other column for every lag.  The resulting matrix has
## 2*maxlag+1 rows and P^2 columns where P is columns(X). That is,
##    R(m+maxlag+1,P*(i-1)+j) == Rij(m) for lag m=[-maxlag:maxlag],
## so
##    R(:,P*(i-1)+j) == xcorr(X(:,i),X(:,j))
## and
##    reshape(R(m,:),P,P) is the cross-correlation matrix for X(m,:).
##
## Ref: Stearns, SD and David, RA (1988). Signal Processing Algorithms.
##      New Jersey: Prentice-Hall.

## 2000-03 pkienzle@kienzle.powernet.co.uk
##     - use fft instead of brute force to compute correlations
##     - allow row or column vectors as input, returning same
##     - compute cross-correlations on columns of matrix X
##     - compute complex correlations consitently with matlab
## 2000-04 pkienzle@kienzle.powernet.co.uk
##     - fix test for real return value
## 2001-02-24 Paul Kienzle
##     - remove all but one loop

function [R, lags] = xcorr (X, Y, maxlag, scale)
  
  if (nargin < 1 || nargin > 4)
    usage ("[c, lags] = xcorr(x [, y] [, h] [, scale])");
  endif

  ## assign arguments from list
  if nargin==1
    Y=[]; maxlag=[]; scale=[];
  elseif nargin==2
    maxlag=[]; scale=[];
    if isstr(Y), scale=Y; Y=[];
    elseif isscalar(Y), maxlag=Y; Y=[];
    endif
  elseif nargin==3
    scale=[];
    if isstr(maxlag), scale=maxlag; scale=[]; endif
    if isscalar(Y), maxlag=Y; Y=[]; endif
  endif

  ## assign defaults to arguments which were not passed in
  if isvector(X) 
    if isempty(Y), Y=X; endif
    N = max(length(X),length(Y));
  else
    N = rows(X);
  endif
  if isempty(maxlag), maxlag=N-1; endif
  if isempty(scale), scale='none'; endif

  ## check argument values
  if isscalar(X) || ischar(X) || isempty(X)
    error("xcorr: X must be a vector or matrix"); 
  endif
  if isscalar(Y) || ischar(Y) || (!isempty(Y) && !is_vector(Y))
    error("xcorr: Y must be a vector");
  endif
  if !isvector(X) && !isempty(Y)
    error("xcorr: X must be a vector if Y is specified");
  endif
  if !isscalar(maxlag) && !isempty(maxlag) 
    error("xcorr: maxlag must be a scalar"); 
  endif
  if maxlag>N-1, 
    error("xcorr: maxlag must be less than length(X)"); 
  endif
  if isvector(X) && isvector(Y) && length(X) != length(Y) &&	!strcmp(scale,'none')
    error("xcorr: scale must be 'none' if length(X) != length(Y)")
  endif
    
  P = columns(X);
  M = 2^nextpow2(N + maxlag);
  if !is_vector(X) 
    ## For matrix X, compute cross-correlation of all columns
    R = zeros(2*maxlag+1,P^2);

    ## Precompute the padded and transformed `X' vectors
    pre = fft (postpad (prepad (X, N+maxlag), M) ); 
    post = conj (fft (postpad (X, M)));

    ## For diagonal (i==j)
    cor = ifft (post .* pre);
    R(:, 1:P+1:P^2) = conj (cor (1:2*maxlag+1,:));

    ## For remaining i,j generate xcorr(i,j) and by symmetry xcorr(j,i).
    for i=1:P-1
      j = i+1:P;
      cor = ifft (post(:,i*ones(length(j),1)) .* pre(:,j));
      R(:,(i-1)*P+j) = conj (cor (1:2*maxlag+1, :));
      R(:,(j-1)*P+i) = flipud (cor (1:2*maxlag+1, :));
    endfor
  elseif isempty(Y)
    ## compute autocorrelation of a single vector
    post = fft (postpad(X,M));
    cor = ifft (conj(post(:)) .* post(:));
    R = [ conj(cor(maxlag+1:-1:2)) ; cor(1:maxlag+1) ];
  else 
    ## compute cross-correlation of X and Y
    post = fft (postpad(X,M));
    pre = fft (postpad(prepad(Y,N+maxlag),M));
    cor = conj (ifft (conj(post(:)) .* pre(:)));
    R = cor(1:2*maxlag+1);
  endif

  ## if inputs are real, outputs should be real, so ignore the
  ## insignificant complex portion left over from the FFT
  if isreal(X) && (isempty(Y) || isreal(Y))
    R=real(R); 
  endif

  ## correct for bias
  if strcmp(scale, 'biased')
    R = R ./ N;
  elseif strcmp(scale, 'unbiased')
    R = R ./ ( [ N-maxlag:N-1, N, N-1:-1:N-maxlag ]' * ones(1,columns(R)) );
  elseif strcmp(scale, 'coeff')
    R = R ./ ( ones(rows(R),1) * R(maxlag+1, :) );
  elseif !strcmp(scale, 'none')
    error("xcorr: scale must be 'biased', 'unbiased', 'coeff' or 'none'");
  endif
    
  ## correct the shape so that it is the same as the input vector
  if is_vector(X) && P > 1
    R = R'; 
  endif
  
  ## return the lag indices if desired
  if nargout == 2
    lags = -maxlag:maxlag;
  endif

endfunction

##------------ Use brute force to compute the correlation -------
##if !is_vector(X) 
##  ## For matrix X, compute cross-correlation of all columns
##  R = zeros(2*maxlag+1,P^2);
##  for i=1:P
##    for j=i:P
##      idx = (i-1)*P+j;
##      R(maxlag+1,idx) = X(i)*X(j)';
##      for k = 1:maxlag
##  	    R(maxlag+1-k,idx) = X(k+1:N,i) * X(1:N-k,j)';
##  	    R(maxlag+1+k,idx) = X(k:N-k,i) * X(k+1:N,j)';
##      endfor
##	if (i!=j), R(:,(j-1)*P+i) = conj(flipud(R(:,idx))); endif
##    endfor
##  endfor
##elseif isempty(Y)
##  ## reshape X so that dot product comes out right
##  X = reshape(X, 1, N);
##    
##  ## compute autocorrelation for 0:maxlag
##  R = zeros (2*maxlag + 1, 1);
##  for k=0:maxlag
##  	R(maxlag+1+k) = X(1:N-k) * X(k+1:N)';
##  endfor
##
##  ## use symmetry for -maxlag:-1
##  R(1:maxlag) = conj(R(2*maxlag+1:-1:maxlag+2));
##else
##  ## reshape and pad so X and Y are the same length
##  X = reshape(postpad(X,N), 1, N);
##  Y = reshape(postpad(Y,N), 1, N)';
##  
##  ## compute cross-correlation
##  R = zeros (2*maxlag + 1, 1);
##  R(maxlag+1) = X*Y;
##  for k=1:maxlag
##  	R(maxlag+1-i) = X(k+1:N) * Y(1:N-k);
##  	R(maxlag+1+i) = X(k:N-i) * Y(k+1:N);
##  endfor
##endif
##--------------------------------------------------------------
