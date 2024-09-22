/*part 4.1 */
DROP FUNCTION   [Relative profit] 
CREATE FUNCTION   [Relative profit]  (@Model varchar(20))  /* Calculates the percentage of revenue per product*/
	RETURNS 	float
	AS
		BEGIN
		DECLARE	@Output float
					SELECT @Output = SUM(P.[Price]*D.[Quantity]) /
						(SELECT SUM(P.[Price]*D.[Quantity])
							FROM [dbo].[Details] AS D JOIN 
							[dbo].[Designs] AS DS	
								ON DS.[design_ID] = D.[design_ID] JOIN 
							[dbo].[Products] AS P 
								ON P.[Model] = DS.[Model] 
						)
					FROM [dbo].[Details] AS D JOIN 
						[dbo].[Designs] AS DS	
					ON DS.[design_ID] = D.[design_ID] JOIN 
						[dbo].[Products] AS P 
					ON P.[Model] = DS.[Model]
					WHERE P.Model = @Model
		RETURN 	@Output 
		End

/*1...........................................................................................................*/
SELECT LEFT(P.Model,2) AS [Cloth Type]    /* Divides the products according to the ABC model      */
	,P.[Model]							  /*and ranks each product group according to the profits */
	,[Type] = CASE  
		WHEN SUM(dbo.[Relative profit](P.[Model])) 
			OVER( ORDER BY dbo.[Relative profit](P.[Model])  DESC
			ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW )<0.8				
		THEN 'A'		/* A - They are responsible for 80% of the profits*/
		WHEN SUM(dbo.[Relative profit](P.[Model])) 
			OVER(ORDER BY dbo.[Relative profit](P.[Model]) DESC
			ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW )<0.95 
		THEN 'B'		/* B - They are responsible for 15% of the profits*/
		ELSE 'C'		/* A - They are responsible for 5% of the profits*/
	END
	,[Relative amount Rank] = RANK()OVER(PARTITION BY LEFT(P.Model,2) /*Rank the products by department name*/
								ORDER BY SUM(D.[Quantity]) DESC )   
	FROM [dbo].[Details] AS D JOIN 
				[dbo].[Designs] AS DS	
				ON DS.[design_ID] = D.[design_ID] JOIN 
				[dbo].[Products] AS P 
				ON P.[Model] = DS.[Model]
GROUP BY LEFT(P.Model,2),P.[Model]
ORDER BY [Type], [Cloth Type],dbo.[Relative Profit](P.[Model])

/*2........................................................................................................*/


SELECT P.[Model] /*Relative measurement of the importance of the product to the business*/
	,[Efficiency rating] = RANK()OVER(ORDER BY SUM(D.[Quantity])*P.[Price] DESC )*1.0/
						RANK()OVER(ORDER BY SUM(D.[Quantity]) DESC )
	,P.Price
	FROM [dbo].[Details] AS D JOIN 
				[dbo].[Designs] AS DS	
				ON DS.[design_ID] = D.[design_ID] JOIN 
				[dbo].[Products] AS P 
				ON P.[Model] = DS.[Model]
	where not (D.[Quantity])*P.[Price] = 0.0
	GROUP BY P.[Model],P.Price
	ORDER BY [Efficiency rating] DESC
