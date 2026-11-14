-- Procedure 1: Retrieves total bookings per show and returns total attendees for 2025 via output parameter

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
PRINT 'Total shows in 2025: ' + CAST(@total AS NVARCHAR);

go


-- Procedure 2: Retrieves all events booked by each customer
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

-- Function 1: Returns numbered artists per city ordered by show date
alter function GetCityMostArtists()
returns @outPutTable table
(city nvarchar(30),idArtist int ,firstName nvarchar(30),
lastName nvarchar(30),dateShow date,cityRow int)
as
begin
insert into @outPutTable
  select a.city,a.idArtist,a.firstName,a.lastName,
  MIN(s.dateShow) AS dateShow, -- Earliest show date for the artist in this city
  ROW_NUMBER () over(partition by a.city order by MIN(s.dateShow))as cityRow
  from artist a
  inner join shows s
  on a.idArtist=s.IdArtist 
  GROUP BY a.city, a.idArtist, a.firstName, a.lastName;
return
end

select * from dbo.GetCityMostArtists();
go

-- Function 2: Retrieves an artist who is also a customer
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
PRINT 'The artist who is also a customer is: ' + ISNULL(@res, 'No result found');







go

-- Procedure 3: Dynamic PIVOT table displaying artists per city ordered chronologically
create procedure pivotProc
as
begin
DECLARE @cols NVARCHAR(MAX);       
DECLARE @query NVARCHAR(MAX);

-- Inserts all unique cities into @cols with square brackets
SELECT @cols = STRING_AGG(QUOTENAME(city), ',')   
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

-- Executes the constructed query
EXEC sp_executesql @query; 
end


exec pivotProc

go
