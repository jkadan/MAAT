classdef nexstar <handle
   properties
      port % The serial port object.
      Alt_Az
      Ra_Dec
      home
   end
   
   
   methods
% Initializing      
       function A=Set_Port(A)
% Set and open the sirial port.
          if isempty(instrfind)==0
              fclose(instrfind);
              delete(instrfind);
          end
          A.port=serial('/dev/ttyUSB0');
          set(A.port,'Terminator','#');
          fopen(A.port);
          A.Set_Home
       end
       function A=Set_Home(A)
        A.Get_Alt_Az
        A.home=mod(round(A.Alt_Az),180);
       end      
%% Position
      function A =Get_Alt_Az(A)
% Give back the current location in Alt-Az.         
        A.Alt_Az=[1,1];
        fprintf(A.port,'Z');
        out=fscanf(A.port);
        out=out(1:(end-1));
        out=split(out,',');
        A.Alt_Az(1)=hex2dec(out(1))/16^4*360;
        A.Alt_Az(2)=hex2dec(out(2))/16^4*360;
      end
      function A =Get_Ra_Dec(A)
% Give back the current location in Ra-Dec.         
        A.Ra_Dec=[1,1];
        fprintf(A.port,'E');
        out=fscanf(A.port);
        out=out(1:(end-1));
        out=split(out,',');
        A.Ra_Dec(1)=hex2dec(out(1))/16^4*360;
        A.Ra_Dec(2)=hex2dec(out(2))/16^4*360;
      end
%% Moving
      function A =Go_To_Alt_Az(A,Alt,Az)
% Move to Alt-Az.
        command=['B',dec2hex(round(Alt/360*16^4),4),',',dec2hex(round(Az/360*16^4),4),'#'];
        fprintf(A.port,command);
        fscanf(A.port);
      end   
      function A =Go_To_RA_Dec(A,Ra,Dec)
% Move to Ra-Dec.
        command=['R',dec2hex(round(Ra/360*16^4),4),',',dec2hex(round(Dec/360*16^4),4),'#'];
        fprintf(A.port,command); 
        fscanf(A.port);
      end    
      function A =Go_To_Alt_Az_Syn(A,Alt,Az)
% Move to Alt-Az synchronic
        temp=onCleanup(@A.Stop);
        A.Go_To_Alt_Az(Alt,Az);
        while str2double(A.Is_Moving)==1
            pause(1)
            disp('moving')
        end
        A.Get_Alt_Az
      end
      function A =Go_To_RA_Dec_Syn(A,Ra,Dec)
% Move to Ra-Dec.
        A.Go_To_RA_Dec(Ra,Dec)
        temp=onCleanup(@A.Stop);
        
        while str2double(A.Is_Moving)==1
            pause(1)
            disp('moving')
        end
        A.Get_Ra_Dec
       end      
      function Go_Home(A)
% Going Home          
            A.Go_To_Alt_Az(A.home(1),A.home(2))
      end  
      function binary=Is_Moving(A)
            fprintf(A.port,'L');
            out=fscanf(A.port);
            binary=out(1);
      end  
      function Stop(A)
% Stop Go To proccess           
            fprintf(A.port,'M');
            fscanf(A.port);
      end 
   end
    
end
