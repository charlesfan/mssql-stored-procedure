SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Create the stored procedure in the specified schema
CREATE PROCEDURE [dbo].[InsertRowData]
(
    @dev_id VARCHAR(50),
    @working_time FLOAT,
    @card_id VARCHAR(50),
    @checkin_time DATETIME,
    @checkout_time DATETIME
)
-- add more stored procedure parameters here
AS
    -- body of the stored procedure
DECLARE @avg FLOAT
SELECT @avg = Avage_Value From Three_Month_Avg WHERE Station_GUID = @dev_id

UPDATE One_Day_Efficiency
    SET Efficiency_Up = 
        (CASE 
            WHEN @working_time < @avg*0.7 THEN Efficiency_Up+1
            ELSE Efficiency_Up
        END),
        Efficiency_Down = 
        (CASE 
            WHEN @working_time > @avg*1.3 THEN Efficiency_Down+1
            ELSE Efficiency_Down
        END),
        Efficiency_Middle = 
        (CASE
            WHEN @working_time >= @avg*0.7 AND @working_time <= @avg*1.3 THEN Efficiency_Middle+1
            ELSE Efficiency_Middle
        END), Update_Time = DateAdd(hour, 8, GETDATE())
WHERE Station_GUID = @dev_id

INSERT INTO Fulltable (Station_GUID, Checkin_time, Checkout_time, Interval_sec, RFID_ID) VALUES
(@dev_id, @checkin_time, @checkout_time, @working_time, @card_id)


GO

