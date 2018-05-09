SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Create the stored procedure in the specified schema
CREATE PROCEDURE [dbo].[getStatistics]
(
    @people int
)
-- add more stored procedure parameters here
AS
    -- body of the stored procedure
DECLARE @tbl2 TABLE
(
        Station_GUID varchar(20),
        Station_Name varchar(20),
        AVG_TIME float
)
DECLARE @tUPH TABLE
(
    UPH float
)

DECLARE MyCursor CURSOR FOR 
        SELECT DISTINCT(Station_GUID) from Fulltable
        
OPEN MyCursor
DECLARE @id VARCHAR(50)
FETCH NEXT FROM MyCursor INTO @id
WHILE @@FETCH_STATUS = 0
BEGIN
        insert into @tbl2 
                select Station_GUID, Name as Station_Name, AVG(a.Interval_sec) as AVG_TIME FROM
                        (select top 20 * from Fulltable where Station_GUID = @id
                        AND Checkin_time < DateAdd(Day, DateDiff(Day, 0, GetDate())+1, 0)
                        AND Checkin_time >= DateAdd(Day, DateDiff(Day, 0, GetDate()), 0)
                        ORDER BY Checkin_time DESC) a 
                        LEFT JOIN Station_Info b ON a.Station_GUID = b.GUID 
                        GROUP BY Station_GUID, Name
        FETCH NEXT FROM MyCursor INTO @id
END

CLOSE MyCursor
DEALLOCATE MyCursor

-- Get triangle
SELECT Station_GUID, Station_Name, Efficiency_Up, Efficiency_Middle, Efficiency_Down FROM One_Day_Efficiency

select * from @tbl2
-- Get indexFor3MonthTop
select top 1 Station_GUID, Station_Name from Three_Month_Top ORDER BY Update_Time DESC
-- Get dailyAverageTop3
SELECT top 3 Station_GUID, Station_Name, RANK() OVER(ORDER BY Avage_Value DESC) as Rank from One_Day_Avg where Avage_Value > 0

-- Get LBR
select 'LBR' as title, avg(AVG_TIME)/max(AVG_TIME)*100 as value from @tbl2
-- Get UPH
insert into @tUPH
    select COUNT(*) as UPH FROM Fulltable WHERE datediff(minute, Checkout_time, DateAdd(hour, 8, GETDATE())) <= 60 AND
    Station_GUID IN  
        (SELECT TOP 1 GUID as Station_GUID FROM Station_Info ORDER BY station DESC)
SELECT 'UPH' as title, UPH as value from @tUPH
-- Get EFF
SELECT 'EFF' as title, (UPH/(3600/40))*100 as value FROM @tUPH
-- Get OUTPUT
SELECT 'OUTPUT' as title, COUNT(*) as value FROM Fulltable 
WHERE Checkout_time < DateAdd(Day, DateDiff(Day, 0, GetDate())+1, 0)
AND Checkout_time >= DateAdd(Day, DateDiff(Day, 0, GetDate()), 0)
AND Station_GUID IN 
    (SELECT TOP 1 GUID as Station_GUID FROM Station_Info ORDER BY station DESC)
-- Get PPH
SELECT 'PPH' as title, UPH/@people as value FROM @tUPH


GO

