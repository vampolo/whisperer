function dispmat(file)      %       Display variables in *.mat file(s)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   DISPMAT.M   2006-10-14  %
%       (c)     M. Balda    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  The function serves for displaying selected variables from mat-files.
%  It needs the function inp.m, #9033 from the File Exchange. 
%
%  EXAMPLES:
%  
%  dispmat(file)
%     enables to view stored variables in a mat-file from a current 
%     directory, whose name is in the argument. 
%     The function displays global information on variables (names, sizes, 
%     bytes, classes) and prompts a user to enter a variable name to be 
%     displayed after the output 'var = '. The user may enter in a cycle:
%       an existing variable name in the list -> display its content, or
%       any character different from variable names -> break displaying.
%     
%  dispmat
%    finds and displays names of all mat-files in the current dictionary 
%    and enables to view contents of stored variables.
%    The function starts a cycle, in which prompts a mat-file names. 
%    A user may 
%       accept it by pushing ENTER key for viewing the mat-file or
%       insert a single character and pushing ENTER for next cycle loop or
%       insert * character for exiting the function.
%    If the mat-file name is accepted, the function displays a list of
%    stored variables and their properties, and prompts the user to insert
%    his decision after the output 'var = '. It can be one of
%       a name of the selected variable -> display it, or
%       a nonexisting name of variable  -> repeat input 'var = ', or
%       the character '.' to continue with next file name, or
%       the character '*' to exit the function.
%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp(' ')
if nargin>0
    if ~strcmp('mat',file(end-2:end))
        file = [file '.mat'];
    end
    if exist(file,'file')==2
        load(file)
        whos('-file',file)
        while 1
            var = input('var = ','s');
            if ~isletter(var(1)), break, end
            eval(var)
        end
    end
else
    D = dir('*.mat');
    for k = 1:length(D)
        disp(D(k).name)
    end
    disp(' ')
    for k = 1:length(D)
        file = inp('file',D(k).name);
        if exist(file,'file')==2
            disp('          ----------------')
            load(file)
            disp(' ')
            whos('-file',file)
            while 1
                var = input('var = ','s');
                if  isempty(var), var ='.'; end
                if ~isletter(var(1)), break, end
                if exist(var)==1, eval(var), end
            end
            if var(1)=='*', break, end
        end
        if file=='*', break, end
    end
end
