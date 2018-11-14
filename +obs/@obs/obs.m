%--------------------------------------------------------------------------
% AstCat class                                                       class
% Description: A class of structure array of catalogs (AstCat).
%              Note that this class is a subset of the SIM class.
% Input  : null
% Output : null
% Tested : Matlab R2015b
%     By : Eran O. Ofek                    Feb 2016
%    URL : http://weizmann.ac.il/home/eofek/matlab/
% Reliable: 2
%--------------------------------------------------------------------------

classdef obs < handle
    properties (SetAccess = public)
        State             % CantObserve | Twilight | Idle | Pointing | Observing
        
        DomeOpen          % {true | false}
        TelTracking       % {true | false}
        TelTrackingRate  
        CameraStatus      % {Non responsive | idle | exposing}
        Guiding           % {true | false}
        CanObs            % {true | false}
        WeatherOk         % {true | false}
        LightsOn          % {true | false}
        AirCondOn         % {true | false}
        
        
    
    end
    
    properties (Constant = true)
        
    end
    
    properties (Hidden = true)
        
        
    end
    
    properties (SetAccess = immutable)
        % property can be set only in the constructor.
        
        Name   % observatory name
        Lon    % observatory longitude [rad]
        Lat    % observatory latitute [rad]
        Height % observatory height [m]
        
        SunPar      % Sun parameters for obs % MaxSunAltObs
                                             % MaxSunAltOpen 
        MoonPar     % Moon parameters for obs
        WeatherPar  % weather parameters for obs % struct
        LightSensePar 
        
        
        funTelescopeStatus   % [TelComOK, TelStatus] = @()  
        funTelescopeFocus    % [TelFocComOK, TelFocStatus]     = @(rel/abs,motion) Stat.FocCommOK, Pos
        funTelescopeGuide    % [TelGuideComOK, TelGuideStatus] = @(Parameters)   Stat.TelGuideComOK, GuideOn, Rate, LastMotion
        funTelescopeHeaters  %       = @(on/off)
        funMountStatus       %       = @()
        funMountMove         %       = @('Tracking','SetRA','SetDec','MoveRA','MoveDec','SetHA')
        funCamStatus         %       = @()
        funCamObs            %       = @(parameters)
        funDomeStatus
        funDomeSet
        funLightSet
        funACSet
        funAlarmStatus
        funWeatherStatus
        
        
    end
    
    
    %-------------------
    %--- Constractor ---
    %-------------------
    methods
        
        function ObsC=obs(varargin)
            % obs class constractor
            
            
            
            
            DefV.ObsName       = 'W-FAST1';
            
            
            InPar = InArg.populate_keyval(DefV,varargin,mfilename);

            [ObsPar,ObsTable] = ocs.obs.getObsPar(InPar.ObsName);
            
            
            % in each cycle
            % check all status and decide on action
  
            % construct timer object 
            
            
          
            
        end
        

    end
    
    methods (Static)
        
        function [ObsTable]=getObsParAll
            % get a database of all observatory parameters
            % Package: ocs.obs
            % Description: Return observatories parameters
            % Input  : *
            % Output : - A table of all observatories in DB.
            
             ObsTableColNameType  = {'ObsName','string';...
                                    'Lon','double';...
                                    'Lat','double';...
                                    'Hight','double';...
                                    'SunAltDomeOpen','double';...
                                    'SunAltObs','double';...
                                    'MaxHumidity','double';...
                                    'MaxTemp','double';...
                                    'MinTemp','double';...
                                    'MaxPressure','double';...
                                    'MinPressure','double';...
                                    'MaxWind','double';...
                                    'CommTimeOut','double'};
               
            ObsTableNcol = size(ObsTableColNameType,1);
            ObsTable = table('size',[100 ObsTableNcol],'VariableNames',ObsTableColNameType(:,1),'VariableTypes',ObsTableColNameType(:,2));    
            
            %
            Ind = 0;
            Ind = Ind + 1;
            ObsTable.ObsName(Ind)         = 'W-FAST1';
            ObsTable.Lon(Ind)             = 34.9;        % [deg]
            ObsTable.Lat(Ind)             = 31.5;        % [deg]
            ObsTable.Height(Ind)          = 900;         % [m]
            ObsTable.SunAltDomeOpen(Ind)  = 1;           % [deg]
            ObsTable.SunAltObs(Ind)       = -11;         % [deg]
            ObsTable.MaxHumidity(Ind)     = 0.92;        % [frac]
            ObsTable.MaxTemp(Ind)         = 30;          % [C]
            ObsTable.MinTemp(Ind)         = -10;         % [C]
            ObsTable.MaxPressure(Ind)     = 1200;        % [mbar]
            ObsTable.MinPressure(Ind)     = 800;         % [mbar]
            ObsTable.MaxWind(Ind)         = 60;          % [km/h]
            ObsTable.MaxWindDirect(Ind)   = 40;          % [km/h]
            ObsTable.CommTimeOut(Ind)     = 1;           % [s]
            
            ObsTable = ObsTable(1:Ind,:);
            
        end
        
        
        function [ObsPar,ObsTable]=getObsPar(ObsName)
            % get observatory parameters
            % Package: ocs.obs
            % Description: Return observatories parameters
            % Input  : - Observatory name (e.g., 'W-FAST1').
            % Output : - A structure array of selected observatory
            %            parameters.
            %        : - A table of all observatories in DB.
            
            [ObsTable] = ocs.obs.getObsParAll;
            
            Flag          = strcmp(ObsTable.ObsName(:,1),ObsName);
            SelectedTable = ObsTable(Flag,:);
            ObsPar        = table2struct(SelectedTable);
               
            
        end
        
        function [JD,MJD,StringUTC]=julday
            % get JD, MJD and UTC string at current time
            % Package: +obs.@ocs
            % Input  : *
            % Output : - JD
            %          - MJD
            %          - UTC date and time string
           
            JD        = celestial.time.julday;
            if (nargout>1)
                MJD       = celestial.time.jd2mjd(JD);
                if (nargout>2)
                    StringUTC = convert.time(JD,'JD','StrDate');
                    StringUTC = StringUTC{1};
                end
            end
        end
        
        
        
        
    end
    
    methods
%         function 
%             
%             
%             
%         end
%         
        function ObsC=getDomeStatus(ObsC)
            % Get dome status
            
            
        end
        
        
        function ObsC=UpdateProp(ObsC)
            % update properties of obs object
            
            
        end
    end
    
    % UpdateProp
    
    % getWeather
    % getMountStatus
    % getTelStatus
    % getDomeStatus
    % getAlarmStatus
    
    % CanObsTarget
    
    % JD
    % RA
    % Dec
    % HA
    % ParAng
    % AirMass
    % Az
    % Alt
    % SunAz
    % SunAlt
    % MoonAz
    % MoonAlt
    % MoonIllum
    % MoonDist
    
    
end

            
