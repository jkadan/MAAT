function [A]=wget_ztf_phot(RA,Dec,Band,varargin)
% SHORT DESCRIPTION HERE
% Package: VO
% Description: 
% Input  : - 
%          * Arbitrary number of pairs of arguments: ...,keyword,value,...
%            where keyword are one of the followings:
% Output : - 
% License: GNU general public license version 3
%     By : Eran O. Ofek                    Sep 2019
%    URL : http://weizmann.ac.il/home/eofek/matlab/
% Example: 
% Reliable: 
%--------------------------------------------------------------------------

BandDic={'g','r','i'};

DefV.CooUnits             = 'deg';
DefV.Radius               = 5;
DefV.RadiusUnits          = 'arcsec';
DefV.User                 = {'/home/eran/matlab/passwords/ztfForced_ipac_pass'}; 
DefV.Pass                 = [];
DefV.wgetProg             = 'wget';   % 'wget' | 'curl'
DefV.BaseURL              = 'https://irsa.ipac.caltech.edu';
DefV.AccountURL           = '/account/signon/login.do';
DefV.CookiesFile          = 'cookies.txt';

DefV.Wait                 = 1;  % seconds
DefV.email                = 'eran.ofek@weizmann.ac.il'; % note that in this service the e-mail is copuled to user/pass!
DefV.BaseURL              = 'https://irsa.ipac.caltech.edu/cgi-bin/ZTF/nph_light_curves?';
InPar = InArg.populate_keyval(DefV,varargin,mfilename);

RadiusDeg = convert.angular(InPar.RadiusUnits,'deg',InPar.Radius);
RA    = convert.angular(InPar.CooUnits,'deg',RA);
Dec   = convert.angular(InPar.CooUnits,'deg',Dec);


if isnumeric(Band)
    Band = BandDic(Band);
elseif iscell(Band)
    Band = Band;
else
    error('Unknown Band option format');
end
Nband = numel(Band);


% get user/pass from passwords file
if (iscell(InPar.User))
    [InPar.User,InPar.Pass]=Util.files.read_user_pass_file(InPar.User{1});
end

% set up the IRSA cookies
[Stat,Res]=VO.ZTF.irsa_set_cookies('CookiesFile',InPar.CookiesFile,...
                                   'BaseURL',InPar.BaseURL,...
                                   'AccountURL',InPar.AccountURL,...
                                   'User',InPar.User,...
                                   'Pass',InPar.Pass,...
                                   'wgetProg',InPar.wgetProg);




% https://irsa.ipac.caltech.edu/cgi-bin/ZTF/nph_light_curves?POS=CIRCLE%20298.0025%2029.87147%200.0014&BANDNAME=g

Spacer = '%20';

N = numel(RA);
for I=1:1:N
    Ib = max(I,Nband);
    %&FORMAT=ipac_table',...
    URL = sprintf('%sPOS=CIRCLE %10.6f %10.6f %08.6f&BANDNAME=%s',... 
        InPar.BaseURL,RA(I),Dec(I),RadiusDeg,Band{Ib});
    URL = replace(URL,'   ',' ');
    URL = replace(URL,'  ',' ');

    %Options = weboptions('UserName',InPar.User,'Password',InPar.Pass);
    %webread(URL,Options);

    %CL = sprintf('wget --http-user=%s --http-passwd=%s -O %s "%s"',InPar.User,InPar.Pass,OutFile,URL);
    %[Stat,Res] = system(CL);
    %(URL)
    A=webread((URL));
    
    pause(InPar.Wait);
end

%ColNames = regexp(A,'<FIELD name="(?<name>\w+)" datatype="(?<datatype>\w+)"','names');
%Ncol = numel(ColNames)
