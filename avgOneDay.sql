SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Create the stored procedure in the specified schema
CREATE PROCEDURE [dbo].[AvgOneDay]
-- add more stored procedure parameters here
AS
    -- body of the stored procedure
DECLARE @tbl TABLE
(
        Station_GUID varchar(20),
        Station_Name varchar(20),
        Avage_Value float
)

DECLARE MyCursor CURSOR FOR 
        SELECT DISTINCT(Station_GUID) from Fulltable
        
OPEN MyCursor
DECLARE @id VARCHAR(50)
FETCH NEXT FROM MyCursor INTO @id
WHILE @@FETCH_STATUS = 0
BEGIN
        
        insert into @tbl
                select Station_GUID, Name as Station_Name, AVG(a.Interval_sec) as Avage_Value FROM
                        (select * from Fulltable where Station_GUID = @id
                        AND Checkin_time < DateAdd(Day, DateDiff(Day, 0, GetDate())+1, 0)
                        AND Checkin_time >= DateAdd(Day, DateDiff(Day, 0, GetDate()), 0)) a 
                        LEFT JOIN Station_Info b ON a.Station_GUID = b.GUID
                        GROUP BY Station_GUID, Name       
        FETCH NEXT FROM MyCursor INTO @id
        END

CLOSE MyCursor
DEALLOCATE MyCursor

Update One_Day_Avg SET Avage_Value = b.Avage_Value, Update_Time = DateAdd(hour, 8, GETDATE()) FROM @tbl b
WHERE One_Day_Avg.Station_GUID = b.Station_GUID AND One_Day_Avg.Station_Name = b.Station_Name


GO
