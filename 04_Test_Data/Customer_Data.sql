USE EnterpriseDQFramework;

/* =====================================================
   CUSTOMER TEST DATA
   30 records
   Includes intentional DQ violations for:
   - NULL_CHECK
   - RANGE_CHECK
   - REGEX_CHECK
   - DUPLICATE_CHECK
   ===================================================== */

INSERT INTO Customer
(
    FirstName,
    LastName,
    Email,
    Age,
    PhoneNumber,
    City
)
VALUES

('Alice','Johnson','alice@gmail.com',25,'9876543201','New York'),
('Bob','Smith','bob@gmail.com',32,'9876543202','Chicago'),
(NULL,'Williams','charlie@gmail.com',28,'9876543203','Dallas'),
('David','Brown','david@gmail.com',40,'9876543204','Seattle'),
('Emma','Jones','emma@gmail.com',150,'9876543205','Boston'),
('Frank','Miller','frank@gmail.com',-5,'9876543206','Austin'),
('Grace','Wilson','alice@gmail.com',30,'9876543207','Miami'),
('Henry','Taylor','henry@gmail.com',45,'9876543208','Denver'),
('Ivy','Moore','ivy@gmaUSE EnterpriseDQFramework;il.com',29,'9876543209','Portland'),
('Jack','Thomas','jack@gmail.com',35,'9876543210','Phoenix'),
('Karen','Martin','karen.gmail.com',27,'9876543211','Atlanta'),
('Liam','Anderson','liam@',31,'9876543212','Houston'),
('Mia','Thomas','mia@gmail.com',24,'9876543213','Dallas'),
(NULL,'Jackson','noah@gmail.com',38,'9876543214','Boston'),
('Olivia','White','olivia@gmail.com',42,'9876543215','Seattle'),
('Peter','Harris','peter@gmail.com',-2,'9876543216','Austin'),
('Quinn','Martin','quinn@gmail.com',33,'9876543217','Denver'),
('Rachel','Thompson','alice@gmail.com',26,'9876543218','Miami'),
('Sam','Garcia','sam@gmail.com',41,'9876543219','Chicago'),
('Taylor','Martinez','taylorgmail.com',29,'9876543220','Phoenix'),
('Uma','Robinson','uma@gmail.com',36,'9876543221','Portland'),
('Victor','Clark','victor@gmail.com',52,'9876543222','Atlanta'),
(NULL,'Lewis','william@gmail.com',44,'9876543223','Houston'),
('Xavier','Lee','xavier@gmail.com',21,'9876543224','New York'),
('Yara','Walker','yara@gmail.com',121,'9876543225','Chicago'),
('Zach','Hall','zach@gmail.com',39,'9876543226','Dallas'),
('Amy','Allen','amy@gmail.com',23,'9876543227','Seattle'),
('Brian','Young','bob@gmail.com',34,'9876543228','Boston'),
('Cathy','King','cathy@gmail.com',48,'9876543229','Austin'),
('Daniel','Wright','daniel@gmail.com',27,'9876543230','Denver');
GO
