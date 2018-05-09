SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Create the stored procedure in the specified schema
CREATE PROCEDURE [dbo].[topThreeMonth]
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
                        AND Checkin_time >= DateAdd(Day, DateDiff(Day, 0, GetDate()), -90)) a 
                        LEFT JOIN Station_Info b ON a.Station_GUID = b.GUID 
                        GROUP BY Station_GUID, Name
        FETCH NEXT FROM MyCursor INTO @id
        END

CLOSE MyCursor
DEALLOCATE MyCursor

insert into Three_Month_Top
        select top 1 Station_GUID, Station_Name, Avage_Value, DateAdd(hour, 8, GETDATE()) as Update_Time 
        from @tbl ORDER BY Avage_Value DESC

GO

