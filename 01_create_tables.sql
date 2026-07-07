
create database Auditorium_sari
go
use Auditorium_sari;
--אומן 
create table artist
(
   idArtist int primary key,
   firstName nvarchar(30),
   lastName nvarchar(30),
   city nvarchar(30),
   phone nvarchar(30)
)
CREATE INDEX idx_artist_city ON artist(city);

--מופעים-אירועים
create table shows
(
   IdShow int identity(100,1) primary key,
   typeShow nvarchar(50) not null,
   IdArtist int,
   startTime time,
   durationTime time,
   dateShow date,
   foreign key(IdArtist) references artist(IdArtist)
)
CREATE INDEX idx_shows_IdArtist ON shows(IdArtist);
CREATE INDEX idx_shows_dateShow ON shows(dateShow);
--כרטיסים
create table cards
(
   idCards int primary key,
   IdShow int,
   price money,
   qty int,
   typeCard nvarchar(30),
   foreign key(IdShow) references shows(IdShow)
)
create index idx_cards_IdShow on cards(IdShow)

--לקוחות
create table customers
(
   IdCustomer int primary key,
   firstName nvarchar(30),
   lastName nvarchar(30),
   phone nvarchar(30),
   city nvarchar(30)
)
create index idx_customers_city on customers(city)
--הזמנות
create table orders
(
  IdOrder int identity(1,1) primary key,
  IdCustomer int,-- ת.ז. של לקוח
  IdShow int,
  codeCardWelcome int,--קוד כרטיס מוזמן
  orderDate date,
  foreign key(IdCustomer) references customers(IdCustomer),
  foreign key(IdShow) references shows(IdShow),
  foreign key(codeCardWelcome) references cards(idCards)
)
CREATE INDEX idx_orders_IdCustomer ON orders(IdCustomer);
CREATE INDEX idx_orders_IdShow ON orders(IdShow);
CREATE INDEX idx_orders_codeCardWelcome ON orders(codeCardWelcome);








