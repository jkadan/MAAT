function URL=wget_obsid(ObsID,varargin)
% Get all the files associated with a Chandra ObsID
% Package: VO.Chandra
% Description: Get all the files associated with a Chandra ObsID
%              The Chandra observations catalog is stored in
%              cats.X.ChandraObs.
%              Use VO.Chandra.build_obsid_cat to build catalog.
% Input  : - ObsID
%          * Arbitrary number of pairs of arguments: ...,keyword,value,...
%            where keyword are one of the followings:
%            'Download' - Indicating what to download:
%                         'all' - all data (default).
%                         'primary' - only data in primary directory.
%                         'secondary' - only data in secondary directory.
%            'Output'   - Output data in a 'flat' structure' or
%                         'dir' (directory) structure.
%                         'none' - do not copy.
%                         Default is 'dir'.
%            'Ungzip'   - ungzip data {true|false}. Default is true.
%            'CopyTo'   - Directory in which to cd before copying data.
%            'ReGet'    - Get files again if 'primary' dir exist 
%                         in directory {true|false}. Default is false.
%            'Extra'    - Extra parameters for wget.
%            'MaxGet'   - Maximum number of files for parallel get
%                         (see www.pwget.m). Default is 10.
% Output : null
% Tested : Matlab R2014a
%     By : Eran O. Ofek                    Jan 2015
%    URL : http://weizmann.ac.il/home/eofek/matlab/
% Example: VO.Chandra.wget_obsid(366)
% Reliable: 2
%--------------------------------------------------------------------------

%DefV.ChandraCat    = [];
DefV.Download      = 'all';   % {'all'|'primary'|'evt'}
DefV.Output        = 'dir_full';   % {'dir_full'|'dir_obsid'|'flat'}
DefV.Ungzip        = true;
DefV.CopyTo        = [];
DefV.UnGzip        = true;
DefV.ReGet         = false;
DefV.Extra         = '';
DefV.MaxGet        = 10;
DefV.BaseURL       = 'https://cxc.cfa.harvard.edu/cdaftp/science/';
InPar = InArg.populate_keyval(DefV,varargin,mfilename);


% if (isempty(InPar.ChandraCat))
%     Cat = VO.Chandra.build_obsid_cat('GetInfo',false,'Verbose',false);
% else
%     if (ischar(InPar.ChandraCat))
%         Cat = load2(InPar.ChandraCat);
%     else
%         Cat = InPar.ChandraCat;
%     end
% end

Cat = cats.X.ChandraObs;

% Search ObsID
%Iobs = find([Cat.ObsID]==ObsID);
Iobs  = find(Cat.Cat.ObsID==ObsID);
%URL  = Cat(Iobs).URL;
URL   = Cat.Cat.URL{Iobs};


PWD = pwd;
if (InPar.CopyTo)
    cd(InPar.CopyTo);
end

% check if directory is populated
if (exist('primary','dir')>0 && ~InPar.ReGet)
    % do not get files again
else

    % get file names
    [List,IsDir,FileName]=www.r_files_url(URL);
    switch lower(InPar.Download)
        case 'evt'
            Flag = ~Util.cell.isempty_cell(regexp(List,'_evt2.fits','match'));
            List = List(Flag);
        case 'primary'
            Flag1 = ~Util.cell.isempty_cell(regexp(List,'/primary/','match'));
            Flag2 = ~Util.cell.isempty_cell(regexp(List,'/oif.fits','match'));
            Flag  = Flag1 | Flag2;
            List = List(Flag);
        case 'all'
            % keep List as is
        otherwise
            error('Unknown Download option');
    end

    Nl = numel(List);
    ObsIDstr = sprintf('%d',ObsID);
    
    % download
    switch lower(InPar.Output)
        case 'none'
            % do nothing
            
        case 'flat'
            www.pwget({List.URL},InPar.Extra,InPar.MaxGet);        
            if (InPar.Ungzip)
                system('gzip -d *.gz');
            end
        case {'dir_obsid','dir_full'}
            
            switch lower(InPar.Output)
                case 'dir_obsid'
                    if exist(ObsIDstr,'dir')==0
                        mkdir(ObsIDstr);
                        cd(ObsIDstr);
                        DirExist = false;
                    else
                        DirExist = true;
                    end
                    
                case 'dir_full'
                    ListTmp = regexprep(List,InPar.BaseURL,'');
                    SplitTmp = regexp(ListTmp,'/','split');
                    DirAO = SplitTmp{1}{1};
                    DirCat = SplitTmp{1}{2};
                    
                    mkdir(DirAO);
                    cd(DirAO);
                    mkdir(DirCat);
                    cd(DirCat);
                    if exist(ObsIDstr,'dir')==0
                        mkdir(ObsIDstr);
                        cd(ObsIDstr);
                        DirExist = false;
                    else
                        DirExist = true;
                    end    
                    
                otherwise
                    error('Impossible error');
            end
            
            
            if ~DirExist
                % only if ObsIDstr dir doesn't exist
                MatchP = sprintf('%sao\\d\\d/cat\\d/\\d.{1,5}/primary/*',InPar.BaseURL);
                MatchS = sprintf('%sao\\d\\d/cat\\d/\\d.{1,5}/secondary/*',InPar.BaseURL);
                Fp     = ~Util.cell.isempty_cell(regexp(List,MatchP,'match'));
                Fs     = ~Util.cell.isempty_cell(regexp(List,MatchS,'match'));
                Ff     = ~Fp & ~Fs;
                if (sum(Ff)>0)
                    www.pwget(List(Ff),InPar.Extra,InPar.MaxGet);
                    if InPar.UnGzip
                        system('gzip -d *.gz');
                    end
                end
                if (sum(Fp)>0)
                    mkdir('primary');
                    cd('primary');
                    www.pwget(List(Fp),InPar.Extra,InPar.MaxGet);
                    if InPar.UnGzip
                        system('gzip -d *.gz');
                    end
                    cd ..
                end
                if (sum(Fs)>0)
                    mkdir('secondary');
                    cd('secondary');
                    www.pwget(List(Fs),InPar.Extra,InPar.MaxGet);
                    if InPar.UnGzip
                        system('gzip -d *.gz');
                    end
                    cd ..
                end

            end
            
       otherwise
            error('Unknown Output option');
    end

end  
cd(PWD);                        