## Copyright (C) 1996, 1997, 2002, 2005, 2007, 2008 John W. Eaton
##
## This file is part of Octave.
##
## Octave is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## Octave is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {} is_vector (@var{a})
## This function has been deprecated.  Use isvector instead.
## @end deftypefn

## Author: jwe

## Deprecated in version 3.0

function retval = is_vector (varargin)

  persistent warned = false;
  if (! warned)
    warned = true;
    warning ("Octave:deprecated-function",
             "is_vector is obsolete and will be removed from a future version of Octave; please use isvector instead");
  endif

  retval = isvector (varargin{:});

endfunction
