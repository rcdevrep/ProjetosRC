declare @p1 int
set @p1=737
declare @p22 char(1)
set @p22='1'
exec sp_prepexecrpc @p1 output,N'dbo.CTB020_01_01','1','1','1','  ','ZZ','20250901','20250930','0','00','1','1','1','0','1','01','01','0','0',' ',@p22 output
select @p1, @p22
