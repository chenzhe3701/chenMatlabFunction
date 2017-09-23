% this allows for call by reference ...

classdef myFloat < handle
   properties
       data
   end
   methods
       function obj = myFloat(inputValue)
           if nargin > 0
               obj.data = inputValue;
           else
               obj.data = 0;
           end
       end
   end

end