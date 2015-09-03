function name = hostname()
%TB.HOSTNAME Attempts to return the computer/hostname
%   This function was imported to TimeBox from the MathWorks File Exchange.
%   The original may be found at
%   http://www.mathworks.com/matlabcentral/fileexchange/16450-get-computer-name-hostname/content/getComputerName.m
%   (link valid as of Sep 2nd, 2015)
%
%   Author information:
%   m j m a r i n j (at) y a h o o (dot) e s
%   (c) MJMJ/2007
%   MOD: MJMJ/2013
[ret, name] = system('hostname');   
if ret ~= 0,
   if ispc
      name = getenv('COMPUTERNAME');
   else      
      name = getenv('HOSTNAME');      
   end
end
name = strtrim(name);