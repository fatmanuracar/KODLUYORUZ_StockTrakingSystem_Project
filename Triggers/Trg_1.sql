CREATE TRIGGER TRG_UPDATESTOK
ON SALES_SALES
AFTER INSERT
AS
BEGIN

DECLARE @PRODUCTID INT
DECLARE @CUSTOMERID INT
DECLARE @STOCKPIECE INT
DECLARE @DEALERID INT
DECLARE @EMPLOYEEID INT
DECLARE @AMOUNT INT--SATIN ALINACAK ÜRÜN ADEDÝ
DECLARE @DATE DATETIME=GETDATE()


SELECT @PRODUCTID=PRODUCTID, @CUSTOMERID=CUSTOMERID, @DEALERID=DEALERID, @DATE=DATE_, @EMPLOYEEID=EMPLOYEEID FROM INSERTED

SELECT @STOCKPIECE=STOCKPIECE FROM COMPANY_PRODUCTDEALER WHERE PRODUCTID=@PRODUCTID



IF @STOCKPIECE <= 2
BEGIN
	DECLARE @message nvarchar(max)
declare @mail varchar(100)
DECLARE @fullname nvarchar(100)
DECLARE @PRODUCTNAME NVARCHAR(100)


SELECT @mail=EMAIL, @fullname=concat_ws(' ', FIRSTNAME, LASTNAME) FROM SALES_CUSTOMERS WHERE ID=@CUSTOMERID

SELECT @PRODUCTNAME=PRODUCTNAME FROM COMPANY_PRODUCTDEALER CP
	INNER JOIN PRODUCT_PRODUCT P ON P.ID=CP.PRODUCTID



set @message = concat('<html><head><style> body { font-size:18px; } .username{ color: red; font-size:18px;}</style></head><body> Sayýn <strong class="username">', @fullname, ';</strong><br/><br/>',
'<b>Ürün kritik seviyededir</b>',  '</b><br><br/>',
'En kýsa sürede stok eklemesi yapmalýsýnýz!!!<br><br>',
'Stoðu tükenen ürünler aþaðýdaki gibidir:<br><ul><li><u><mark>',
@PRODUCTNAME , '</u></mark></li></ul>'
,

'<a href="http://medium.com/@mervekucukdogru" target="_blank"><center><img 
src="https://www.bosch-home.com.tr/store/medias/sys_master/root/h15/h35/9828799512606/Turkish-165px.jpg" alt="Torku" title="Torku" width="300px" style="margin:auto; margin-top:50px; left:15px;"></center></a>'
)

exec msdb.dbo.sp_send_dbmail
		@profile_name = 'Genel Mail',
		@recipients=@mail,
		@body=@message,
		@subject='Kritik Seviye Ürün Bilgilendirme',
		@body_format = 'HTML'
END

ELSE 
BEGIN 
DECLARE @SALESDETAILID INT


SET @SALESDETAILID= IDENT_CURRENT('SALES_SALESDETAILS')
SELECT @SALESDETAILID

SELECT @AMOUNT=SD.QUANTITY FROM  SALES_SALESDETAILS SD 
WHERE SD.ID=@SALESDETAILID
SELECT @AMOUNT


	UPDATE COMPANY_PRODUCTDEALER SET STOCKPIECE=STOCKPIECE-@AMOUNT WHERE PRODUCTID=@PRODUCTID AND DEALERID=@DEALERID
END


END