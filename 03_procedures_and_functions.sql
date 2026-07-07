
--השתמשתי בכל הנושאים חוץ מunion 

--פרוצדורה 1
--פרוצדורה ששולפת את כמות המוזמנים בכל מופע ומציגה את שם המופע
--ומחזירה בoutput את כל המוזמנים שהיו ב2025
--השתמשתי פה בoutput,join,groupby,cte
alter procedure AmountShows(@sumShowInThisYear int output)
as
begin

;with cteSumInvited
as
(
   select o.IdShow,s.typeShow,s.dateShow,COUNT(*) as countInvited
   from shows s
   join orders o
   on s.IdShow=o.IdShow
   group by o.IdShow,s.typeShow,s.dateShow
)

select * from cteSumInvited;


;with cteSumInvited
as
(
   select o.IdShow,s.typeShow,s.dateShow,COUNT(*) as countInvited
   from shows s
   join orders o
   on s.IdShow=o.IdShow
   where year(dateShow) = 2025
   group by o.IdShow,s.typeShow,s.dateShow
)

select @sumShowInThisYear=sum(countInvited)
from cteSumInvited

end

declare @total int;
exec AmountShows @sumShowInThisYear=@total output
PRINT 'סה"כ מופעים בשנת 2025: ' + CAST(@total AS NVARCHAR);

go


--פרוצדורה 2
--פורצדורה ששולפת לכל מוזמן את האירועים שלו
--השתמשתי בפונקציית מערכת וselgjoin
alter procedure InvitedShow
as
begin
select o1.IdCustomer,STRING_AGG(CAST(o2.IdShow AS NVARCHAR), ', ') AS ShowsList
from orders o1
join orders o2
on o1.IdCustomer=o2.IdCustomer
where o1.IdShow<>o2.IdShow
GROUP BY o1.IdCustomer

ORDER BY o1.IdCustomer;
end

exec InvitedShow







go

--פונקציה 1
--פונקציה שמחזירה בכל עיר ממספרת את מספר האומנים לפי התאריך של המופע
--השתמשתי בrow-number
alter function GetCityMostArtists()
returns @outPutTable table
(city nvarchar(30),idArtist int ,firstName nvarchar(30),
lastName nvarchar(30),dateShow date,cityRow int)
as
begin
insert into @outPutTable
  select a.city,a.idArtist,a.firstName,a.lastName,
  MIN(s.dateShow) AS dateShow, -- התאריך המוקדם ביותר לאמן בעיר הזאת
  ROW_NUMBER () over(partition by a.city order by MIN(s.dateShow))as cityRow
  from artist a
  inner join shows s
  on a.idArtist=s.IdArtist 
  GROUP BY a.city, a.idArtist, a.firstName, a.lastName;
return
end

select * from dbo.GetCityMostArtists();
go

--פונקציה 2
--שולפת אומן שהוא גם קהל
--השתמשתי בחיתוך
alter FUNCTION GetFirstArtistCustomer()
RETURNS NVARCHAR(200)
AS
BEGIN
  DECLARE @artistCust NVARCHAR(200);

  SELECT TOP 1
    @artistCust = CONCAT(
      ' firstName: ', firstName,
      ' lastName: ', lastName
    )
  FROM (
    SELECT firstName, lastName
    FROM artist
    INTERSECT
    SELECT firstName, lastName
    FROM customers
  ) AS t;

  RETURN @artistCust;
END;

DECLARE @res NVARCHAR(200);
SET @res = dbo.GetFirstArtistCustomer();
PRINT 'האמנית שגם לקוחה היא: ' + ISNULL(@res, 'אין תוצאה');







go

--פורצדורה 3
--התוכנית מציגה טבלת Pivot דינמית שמראה לכל עיר את רשימת האמנים שלה לפי סדר התאריכים
--לפי הטבלה שקראתי לה מהפונקציה הראשונה שבה השתמשתי בrowNumber
--השתמשתי פה ב-Pivot Table וDynamic SQL  systamefunction וsubquery
create procedure pivotProc
as
begin
DECLARE @cols NVARCHAR(MAX);       
DECLARE @query NVARCHAR(MAX);

--מכניס את כל הערים ברשימה לcols
SELECT @cols = STRING_AGG(QUOTENAME(city), ',')   -- מחברים את שמות הערים עם פסיקים ומוסיפים סוגריים מרובעים לכל שם
from
(
  select distinct city
  FROM dbo.GetCityMostArtists()
)as c


SET @query = '
SELECT cityRow, ' + @cols + '  
FROM (
    SELECT city, firstName, cityRow             
    FROM dbo.GetCityMostArtists()
) AS src

PIVOT (
    MAX(firstName)                                
    for city IN (' + @cols + ')                  
) AS pvt
order BY cityRow;'; 

-- 3. מריצים את השאילתה שנבנתה
EXEC sp_executesql @query; 
end


exec pivotProc

go


