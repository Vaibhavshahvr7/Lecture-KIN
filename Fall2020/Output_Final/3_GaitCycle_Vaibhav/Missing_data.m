 %missing value conunt select form the database
 function End=Missing_data(m1,m2,m3,Gmissingrow)
            
            if m1 > m2
                if m3 > m1
                    missing= m3;
                else
                    missing= m1;
                end
            elseif m3 > m2
                missing= m3;
            else
                missing= m2;
            end
            
            %missing data points
            End = Gmissingrow- missing; %End row
            if End > 100
                