function [statusFile] = fileExist (fileName)
    if (exist(fileName,'file'))
        display(['loaded ', fileName]);
        statusFile=true;
    else
	   display([fileName,' not exist']);
       statusFile=false;
    end
end