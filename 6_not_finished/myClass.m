classdef myClass
   properties
       data
       nRow
       nCol
       type
   end
   methods
       function obj = myClass(inputData)
           if nargin > 0
               obj.data = inputData;
           else
               obj.data = [];
           end
           [obj.nRow, obj.nCol] = size(obj.data);
           if (obj.nRow>1)&&(obj.nCol>1)
               obj.type = 'matrix';
           else
               obj.type = 'vector';
           end
       end
   end
   methods
      function plot(obj)
         surf(obj.data); 
      end 
   end

end