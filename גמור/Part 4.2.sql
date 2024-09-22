

DROP FUNCTION   Order_Time
CREATE FUNCTION   Order_Time   (@Order_ID int )     /*Estimated production time for order*/
	RETURNS 	int
	AS
	BEGIN
	DECLARE	@Output	int 
		SELECT @Output = D.Quantity*DATEPART ( mi,'00:05:00') *COUNT(T.Location)  /* Time for Text 00:05:00*/
				OVER(PARTITION BY D.[design_ID],T.Location)+DATEPART ( mi,'00:10:00') *COUNT(I.Location)  /* Time for Immag 00:05:00*/
				OVER(PARTITION BY D.[design_ID],I.Location)
		FROM [Orders]AS O JOIN
			[Details] AS D 
				ON  O.Order_ID = D.Order_ID JOIN
			[Texts] AS T
				ON D.design_ID = T.design_ID JOIN
			[Images] AS I
				ON D.design_ID = I.design_ID
		WHERE O.Order_ID = @Order_ID
		RETURN 	@Output 
		End
/*............................................................................................................*/
DROP VIEW To_Proces
CREATE VIEW To_Proces   /*Table of production times for orders*/
AS    
SELECT O.Order_ID
	,O.Order_date 
	,D.design_ID
	,D.Quantity
	,dbo.Order_Time(O.[Order_ID])as Times
	,TOTtimes = sum( dbo.Order_Time(O.[Order_ID]))  /*instant sum of production times for orders*/
					OVER( ORDER BY O.Order_date
					ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW )
FROM [Orders]AS O JOIN
	[Details] AS D 
		ON  O.Order_ID = D.Order_ID 
WHERE O.Status = 'Waiting to proces'

/*............................................................................................................*/

DROP	PROCEDURE  Production
CREATE  PROCEDURE  Production  ( @Employees   int , @Start_H time, @End_H time) /*Builds a daily schedule and updates the tables*/
AS  		
BEGIN 

SELECT Schedule = TIMEFROMPARTS ((([TOTtimes]-[Times])/@Employees/60+8)%24 /*daily schedule*/
					,([TOTtimes]-[Times])/@Employees%60
					, 0, 0, 0 )
		,[Order_ID]
		,Time = [Times]*1.0/@Employees
FROM dbo.To_Proces
WHERE ([TOTtimes])/@Employees< (DATEPART (hh,@End_H)-DATEPART (hh,@Start_H))*60 
AND [Times] IS NOT NULL
/*......*/      /*......*/      /*......*/      /*......*/      /*......*/      /*......*/      /*......*/  
SELECT design_ID,Order_ID FROM dbo.To_Proces  /* Ready to ship*/
	WHERE Times IS NULL
/*......*/      /*......*/      /*......*/      /*......*/      /*......*/      /*......*/      /*......*/  
UPDATE [dbo].[Orders]					/*Updates the status of the finish products to on delivery*/
SET [Status] = 'on delivery'
WHERE [Order_ID] IN (SELECT [Order_ID] FROM dbo.To_Proces
						WHERE Times IS NULL)
/*......*/      /*......*/      /*......*/      /*......*/      /*......*/      /*......*/      /*......*/  
UPDATE [dbo].[Orders]		/*Updates the status of the treated products to 'in process'*/
SET [Status] = 'in process'
WHERE [Order_ID] IN (SELECT [Order_ID]
						FROM dbo.To_Proces
						where [TOTtimes]/@Employees< (DATEPART (hh,@End_H)-DATEPART (hh,@Start_H))*60)

END



EXECUTE Production @Employees = 4 , @Start_H = '08:00:00', @End_H ='16:00:00'

SELECT TIMEFROMPARTS(8,0,0,0,0)


