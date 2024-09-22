
DROP TABLE Searches_History  
CREATE TABLE Searches_History (/*Table for search history*/
	UserID		Varchar(20)	NOT NULL
	,DT			DateTime	NOT NULL
	,dDT_mcs	float		null
	,Choice		Varchar(6)	null
	,Products	Varchar(60) NOT NULL
	,minprice	money		NOT NULL
	,maxprice	money		NOT NULL
	,order_by	Varchar(20) NOT NULL
	PRIMARY KEY( DT,UserID) 
	)

/*............................................................................................................*/
DROP PROCEDURE SP_Searches			/*Search*/
CREATE  PROCEDURE SP_Searches(
	@Products Varchar(20) 
	,@minprice Varchar(20)
	,@maxprice Varchar(20)
	,@order_by Varchar(20))
AS 
BEGIN

DECLARE @TN  DATETIME 
SELECT @TN = SYSDATETIME ( ); /*Beginning of search time*/

SELECT [ModelDescription]FROM 
	[Products] AS P JOIN [Designs] AS DS
		ON P.[Model] = DS.[Model] JOIN
	[Details] AS D
		ON D.design_ID = DS.design_ID
	WHERE (P.Price  BETWEEN @minprice AND @maxprice AND                /*in the price range?*/
		LOWER([ModelDescription])LIKE '%' + LOWER(@Products)+'%') OR   /*Crosses the search word */
		@Products = 'Products'
	GROUP BY P.[Model],[ModelDescription],[Price]
	ORDER BY CASE														/*order by choice*/
		WHEN @order_by='Cheap to expensive' THEN   [Price]
		WHEN @order_by='expensive to Cheap' THEN   -[Price]
		ELSE -SUM(D.Quantity)
	END

	INSERT INTO [dbo].[Searches_History]			/*Saves search information*/
	VALUES (@@SPID,SYSDATETIME ( )
			, DATEDIFF ( mcs , @TN , SYSDATETIME ( ) )
			,null
			,@Products
			,CAST(@minprice AS money)
			,CAST(@maxprice AS money)
			,@order_by);
END

/*............................................................................................................*/

DROP  PROCEDURE SP_Searches_Ditails		/*choice*/
CREATE  PROCEDURE SP_Searches_Ditails(
	@Products Varchar(60) )
	AS
	BEGIN 

	SELECT p.[Model] ,[ModelDescription],[Price] ,SUM(D.Quantity) AS Sales  /*Displays the details*/
		FROM 
		[Products] AS P JOIN 
		[Designs] AS DS
			ON P.[Model] = DS.[Model] JOIN
		[Details] AS D
			ON D.design_ID = DS.design_ID
		WHERE [ModelDescription] = @Products
		GROUP BY P.[Model],[ModelDescription],[Price]

	DECLARE @model Varchar(6) 
	SELECT  @model = Model				/*Mediation*/
		FROM [Products]
		WHERE [ModelDescription] = @Products  
	 
	UPDATE Searches_History              /*Updates the search history selection*/
		SET Choice = @model
			WHERE UserID = @@SPID AND
			DT = (SELECT MAX(DT) 
				  FROM Searches_History 
				  WHERE UserID = @@SPID)

END
