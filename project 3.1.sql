/* Reboot of the system*/
USE [tempdb]
DROP TABLE Details
DROP TABLE DesignNames
DROP TABLE Texts
DROP TABLE Images
DROP TABLE Design_Colors
DROP TABLE Credit_Cards
DROP TABLE Orders
DROP TABLE Designs
DROP TABLE Searches
DROP TABLE Products 
DROP TABLE Customers
DROP TABLE Countries
DROP TABLE Statuses
DROP TABLE Colors
DROP TABLE Sizes
DROP TABLE Locations 
/**tables**/
/**lookup**/
CREATE TABLE Locations (
	Location	Varchar(20) NOT NULL,/*PK*/
	CONSTRAINT PK_Locations PRIMARY KEY(Location ) 
)
CREATE TABLE Countries (
	Country	Varchar(40) NOT NULL,/*PK*/
	CONSTRAINT PK_Countries PRIMARY KEY(Country ) 
)
CREATE TABLE Statuses (
	[status]		Varchar(20) NOT NULL,/*PK*/
	CONSTRAINT PK_statuses PRIMARY KEY([status]) 
)
CREATE TABLE Colors (
	Color			Varchar(20)	NOT NULL,/*PK*/
	CONSTRAINT PK_Colors PRIMARY KEY(Color) 
)
CREATE TABLE Sizes (
	Size			Varchar(10)	NOT NULL,/*PK*/
	CONSTRAINT PK_Sizes PRIMARY KEY(Size) 
)
/**main objects**/
CREATE TABLE Customers (
	Customer_ID		Varchar(20) NOT NULL,/*PK*/
	[Frst-name]		Varchar(20)	NOT NULL,
	[Last-name]		Varchar(20)	NOT NULL,
	Email			Varchar(40)	NOT NULL,/*CHK*/
	Postal_Code		Varchar(20) NULL, 
	Country			Varchar(40) NULL,	 /*LOOKUP*/
	City			Varchar(40) NULL,
	DesignName		Varchar(20) NULL, 
	[Rank]			int			NOT NULL,/*LOOKUP*/

	CONSTRAINT PK_Customers PRIMARY KEY(Customer_ID ),
	CONSTRAINT FK_Countries  FOREIGN KEY(Country) 
		REFERENCES Countries (Country),
	CONSTRAINT CK_@  CHECK (Email LIKE'%@%'),
	CONSTRAINT [CK_CustomersRank]  CHECK ([Rank] between  1 and 3)
	)

CREATE TABLE Products(
	Model			Varchar(20)	NOT NULL,/*PK*/
	Discription Varchar(100)		NOT NULL,
	Price			money		NOT NULL,/*CHK*/

	CONSTRAINT PK_Products PRIMARY KEY(Model),
	CONSTRAINT CK_ProductsPrice  CHECK (Price >=0)
	)

CREATE TABLE Searches	(
	Search_DT		smalldatetime	,/*PK*/ 
	IP_address		Varchar(20)	NOT NULL,/*PK*/
	Content			Varchar(20) NOT NULL,
	SearcheBy		Varchar(20)	NULL	,/*FK(Customers)*/
	[Led To]		Varchar(20)	NULL	,/*FK(Products)*/

	CONSTRAINT PK_Searches PRIMARY KEY(Search_DT,IP_address),
	CONSTRAINT FK_SearcheBy  FOREIGN KEY(SearcheBy) 
		REFERENCES Customers (Customer_ID),
	CONSTRAINT FK_LedTo  FOREIGN KEY([Led To]) 
		REFERENCES Products (Model)
	)

CREATE TABLE Designs	(
	design_ID		int			NOT NULL,/*PK*/
	Model			Varchar(20) NOT NULL,/*FK(Products)*/ 
	Size			Varchar(10)	NOT NULL,/*LOOKUO*/
	Price			money		NOT NULL,/*CHK*/  
	DesigineBy		Varchar(20)	NULL	,/*FK(Customers)*/

	CONSTRAINT PK_Designs PRIMARY KEY(design_ID),
	CONSTRAINT FK_DesigineFrom  FOREIGN KEY(Model) 
		REFERENCES Products (Model),
	CONSTRAINT FK_DesigineBy FOREIGN KEY(DesigineBy) 
		REFERENCES Customers (Customer_ID),
	CONSTRAINT FK_Sizes FOREIGN KEY(Size) 
		REFERENCES Sizes (Size),
	CONSTRAINT CK_DesignsPrice  CHECK (Price >=0)
	)
	
CREATE TABLE Orders	(
	Order_ID		int   		NOT NULL, /*PK*/
	[Order_date]	date		NOT NULL,
	[Status]		Varchar(20) NOT NULL,/*LOOKUP*/
	DesigineBy		Varchar(20)	NOT NULL, /*FK(Customers)*/

	CONSTRAINT PK_Orders PRIMARY KEY(Order_ID),
	CONSTRAINT FK_OrderBy  FOREIGN KEY(DesigineBy) 
		REFERENCES Customers (Customer_ID),
	CONSTRAINT FK_Statuses  FOREIGN KEY([Status]) 
		REFERENCES Statuses ([Status])
	)

CREATE TABLE Credit_Cards	(
	Order_ID		int   		NOT NULL, /*PK*//*FK(Orders)*/
	[CC-number]		Varchar(16) NOT NULL, /*PK*/
	[CC-type]		Varchar(20) NOT NULL,
	[CC-Expiration-Year]int	NOT NULL,/*CHK*/
	[CC-Expiration-Month]int	NOT NULL,/*CHK*/
	[CC-cvv]		Varchar(3)  NOT NULL,
	
	CONSTRAINT PK_Credit_Cards PRIMARY KEY(Order_ID,[CC-number]),
	CONSTRAINT FK_PayOn  FOREIGN KEY(Order_ID) 
		REFERENCES Orders (Order_ID),
	CONSTRAINT [CK_Expiration-Month]  CHECK ([CC-Expiration-Month] between  1 and 12),
	CONSTRAINT [CK_Expiration-Year]  CHECK ([CC-Expiration-Year] >= 23)
	)

/**[Multi-valued fields]**/
CREATE TABLE Design_Colors(	
	design_ID		int			NOT NULL,/*FK(Designs)*//*PK*/	
	Color			Varchar(20)	NOT NULL,/*Lookup*//*PK*/

	CONSTRAINT PK_Designs_Colors PRIMARY KEY(design_ID,color),
	CONSTRAINT FK_Designs_Colors  FOREIGN KEY(design_ID) 
		REFERENCES Designs (design_ID),
	CONSTRAINT FK_Colors  FOREIGN KEY(Color) 
		REFERENCES Colors (Color)
	)

CREATE TABLE [Texts](
	design_ID		int	NOT NULL,/*FK(Designs*//*PK*/
	[Location]		Varchar(20)	NOT NULL,/*PK*/
	[Text]			Varchar(20)	NULL,

	CONSTRAINT PK_Texts PRIMARY KEY(design_ID,[location]),
	CONSTRAINT FK_Texts  FOREIGN KEY(design_ID) 
		REFERENCES Designs (design_ID),
	CONSTRAINT FK_LocationsTexts  FOREIGN KEY([Location]) 
		REFERENCES Locations ([Location])
	)

CREATE TABLE [Images](
	design_ID		int			NOT NULL,/*FK(Designs*//*PK*/
	[Location]		Varchar(20)	NOT NULL,/*PK*/
	[Image]			Varchar(20)	NULL,	

	CONSTRAINT PK_Images PRIMARY KEY(design_ID,[location]),
	CONSTRAINT FK_Images  FOREIGN KEY(design_ID) 
		REFERENCES Designs (design_ID),
	CONSTRAINT FK_LocationsImages  FOREIGN KEY([Location]) 
		REFERENCES Locations ([Location])
	)

/**Connections n to n**/
CREATE TABLE DesignNames(
	Customer_ID		Varchar(20)	NOT NULL, /*FK(Customers)*//*PK*/
	DesignName		Varchar(20)	NOT NULL, /*PK*/
	design_ID		int	NOT NULL,/*FK(Designs)*/

	CONSTRAINT PK_DesignNames PRIMARY KEY(Customer_ID,DesignName),
	CONSTRAINT FK_NamedBy  FOREIGN KEY(Customer_ID) 
		REFERENCES Customers (Customer_ID),
	CONSTRAINT FK_NamedOf  FOREIGN KEY(design_ID) 
		REFERENCES Designs (design_ID)
	)

CREATE TABLE Details(
	
	
	design_ID		int	NOT NULL,/*FK(Designs)*/ 
	Order_ID		int	NOT NULL,/*FK(Order)*//*PK*/
	Quantity		int			NOT NULL,/*PK*//*CHK*/

	CONSTRAINT PK_Details PRIMARY KEY(Order_ID,design_ID),
	CONSTRAINT FK_OrderQuantity  FOREIGN KEY(Order_ID) 
		REFERENCES Orders (Order_ID),
	CONSTRAINT FK_designQuantity  FOREIGN KEY(design_ID) 
		REFERENCES designs (design_ID),
	CONSTRAINT CK_Quantity  CHECK (Quantity >=1)
	)