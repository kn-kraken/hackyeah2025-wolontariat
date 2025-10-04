-- Clean up old schema if it exists
DROP TABLE IF EXISTS User;
DROP TABLE IF EXISTS Message;
DROP TABLE IF EXISTS Opinion;
DROP TABLE IF EXISTS Application;
DROP TABLE IF EXISTS Event;
DROP TABLE IF EXISTS Volunteer;
DROP TABLE IF EXISTS School;
DROP TABLE IF EXISTS Organization;

-------------------------------------------------------
-- User
-------------------------------------------------------
CREATE TABLE User (
    UserId INTEGER PRIMARY KEY AUTOINCREMENT,
    Username TEXT NOT NULL,
    AvatarUrl TEXT NOT NULL
);

-------------------------------------------------------
-- User
-------------------------------------------------------
CREATE TABLE Message (
    SenderId INTEGER,
    ReceiverId INTEGER,
    Body TEXT NOT NULL,
    Read BOOLEAN NOT NULL,
    Time DATETIME NOT NULL,
    FOREIGN KEY (SenderId) REFERENCES User(UserId),
    FOREIGN KEY (ReceiverId) REFERENCES User(UserId)
);

-------------------------------------------------------
-- Organization
-------------------------------------------------------
CREATE TABLE Organization (
    UserId INTEGER PRIMARY KEY,  
    Name TEXT NOT NULL,
    Description TEXT NOT NULL,
    Type TEXT CHECK(Type IN ('Organizacja Pozarządowa','Fundacja','Szkoła','Uniwersytet','Instytucja Kultury','Jednostka Miejska')) NOT NULL,
    FOREIGN KEY (UserId) REFERENCES User(UserId)
);

-------------------------------------------------------
-- Volunteer
-------------------------------------------------------
CREATE TABLE Volunteer (
    UserId INTEGER PRIMARY KEY,  
    Name TEXT NOT NULL,
    Surname TEXT NOT NULL,
    Age INTEGER NOT NULL,
    FOREIGN KEY (UserId) REFERENCES User(UserId)
);

-------------------------------------------------------
-- Event
-------------------------------------------------------
CREATE TABLE Event (
    EventId INTEGER PRIMARY KEY AUTOINCREMENT,
    Name TEXT NOT NULL,
    Category TEXT CHECK(Category IN ('Środowisko','Edukacja','Zdrowie','Społeczność','Kultura','Sport','Zwierzęta','Inne')),
    Description TEXT NOT NULL,
    Requirements TEXT NOT NULL,
    Location TEXT NOT NULL,
    Latitude REAL NOT NULL,
    Longitude REAL NOT NULL,
    StartTime DATETIME NOT NULL,
    EndTime DATETIME NOT NULL,
    ApplicationDeadline DATETIME NOT NULL,
    UserId INTEGER NOT NULL,
    FOREIGN KEY (UserId) REFERENCES Organization(UserId)
);

-------------------------------------------------------
-- Application (many-to-many: Volunteer <-> Event)
-------------------------------------------------------
CREATE TABLE Application (
    ApplicationId INTEGER PRIMARY KEY AUTOINCREMENT,
    VolunteerId INTEGER NOT NULL,
    EventId INTEGER NOT NULL,
    TimeOfApplication DATETIME NOT NULL,
    ApplicationAccepted BOOLEAN NOT NULL,
    TimeOfReview DATETIME,
    FOREIGN KEY (VolunteerId) REFERENCES Volunteer(VolunteerId),
    FOREIGN KEY (EventId) REFERENCES Event(EventId),
    UNIQUE(VolunteerId, EventId)
);

-------------------------------------------------------
-- Opinion (Organization leaves opinion about a volunteer after an event)
-------------------------------------------------------
CREATE TABLE Opinion (
    OpinionId INTEGER PRIMARY KEY AUTOINCREMENT,
    VolunteerId INTEGER NOT NULL,
    EventId INTEGER NOT NULL,
    OpinionText TEXT NOT NULL,
    FOREIGN KEY (VolunteerId) REFERENCES Volunteer(VolunteerId),
    FOREIGN KEY (EventId) REFERENCES Event(EventId),
    UNIQUE(VolunteerId, EventId) -- 1 opinion per volunteer per event
);


-------------------------------------------------------
-- Sample Data Inserts
-------------------------------------------------------

-- Users (15 volunteers + 10 organizations = 25 users)
INSERT INTO User (Username, AvatarUrl) VALUES
('jan.kowalski',        'https://i.pravatar.cc/150?u=david'),
('anna.nowak',          'https://i.pravatar.cc/150?u=anna'),
('piotr.wisniewski',    'https://i.pravatar.cc/150?u=piotr'),
('katarzyna.kowalczyk', 'https://i.pravatar.cc/150?u=katarzyna'),
('tomasz.lewandowski',  'https://i.pravatar.cc/150?u=tomasz'),
('agnieszka.wozniak',   'https://i.pravatar.cc/150?u=agnieszka'),
('michal.zielinski',    'https://i.pravatar.cc/150?u=michal'),
('magdalena.szymanska', 'https://i.pravatar.cc/150?u=magdalena'),
('pawel.dabrowski',     'https://i.pravatar.cc/150?u=pawel'),
('alicja.krawczyk',     'https://i.pravatar.cc/150?u=alicja'),
('fundacja.krakow',     'https://i.pravatar.cc/150?u=fundacja'),
('szkola.nr1',          'https://i.pravatar.cc/150?u=szkola1'),
('uniwersytet.krakowski','https://i.pravatar.cc/150?u=uniwersytet'),
('stowarzyszenie.mlodzi','https://i.pravatar.cc/150?u=stowarzyszenie'),
('fundacja.zdrowie',    'https://i.pravatar.cc/150?u=fundacja'),
('centrum.kultury',     'https://i.pravatar.cc/150?u=centrum'),
('biblioteka.miejska',  'https://i.pravatar.cc/150?u=biblioteka'),
('szkola.nr2',          'https://i.pravatar.cc/150?u=szkola2'),
('teatr.krakowski',     'https://i.pravatar.cc/150?u=teatr'),
('szkola.nr3',          'https://i.pravatar.cc/150?u=szkola3'),
('szkola.nr4',          'https://i.pravatar.cc/150?u=szkola4'),
('szkola.nr5',          'https://i.pravatar.cc/150?u=szkola5'),
('fundacja.zwierzak',   'https://i.pravatar.cc/150?u=fundacja'),
('sport.krakow',        'https://i.pravatar.cc/150?u=sport'),
('instytut.edukacji',   'https://i.pravatar.cc/150?u=instytut'),
('organizacja.pozarzadowa','https://i.pravatar.cc/150?u=organizacja');

-------------------------------------------------------
-- Volunteers (UserId 1–15)
-------------------------------------------------------
INSERT INTO Volunteer (UserId, Name, Surname, Age) VALUES
(1,  'Jan',       'Kowalski',     22),
(2,  'Anna',      'Nowak',        25),
(3,  'Piotr',     'Wiśniewski',   19),
(4,  'Katarzyna', 'Kowalczyk',    30),
(5,  'Tomasz',    'Lewandowski',  28),
(6,  'Agnieszka', 'Woźniak',      26),
(7,  'Michał',    'Zieliński',    21),
(8,  'Magdalena', 'Szymańska',    24),
(9,  'Paweł',     'Dąbrowski',    29),
(10, 'Alicja',    'Krawczyk',     23),
(11, 'Ewa',       'Mazur',        27),
(12, 'Jakub',     'Pawlak',       20),
(13, 'Dorota',    'Król',         22),
(14, 'Mateusz',   'Wojciechowski',18),
(15, 'Karolina',  'Piotrowska',   31);

-------------------------------------------------------
-- Organizations (UserId 16–25)
-------------------------------------------------------
INSERT INTO Organization (UserId, Name, Description, Type) VALUES
(16,'Fundacja Kraków','Fundacja wspierająca lokalne inicjatywy społeczne.','Fundacja'),
(17,'Szkoła Podstawowa nr 1','Szkoła publiczna w centrum Krakowa.','Szkoła'),
(18,'Uniwersytet Krakowski','Najstarsza uczelnia w Polsce.','Uniwersytet'),
(19,'Stowarzyszenie Młodzi','Organizacja wspierająca młodzież.','Organizacja Pozarządowa'),
(20,'Fundacja Zdrowie','Fundacja promująca zdrowy styl życia.','Fundacja'),
(21,'Centrum Kultury','Instytucja kultury organizująca wydarzenia artystyczne.','Instytucja Kultury'),
(22,'Biblioteka Miejska','Biblioteka publiczna w Krakowie.','Jednostka Miejska'),
(23,'Teatr Krakowski','Teatr organizujący spektakle dla mieszkańców.','Instytucja Kultury'),
(24,'Fundacja Zwierzak','Fundacja zajmująca się pomocą zwierzętom.','Fundacja'),
(25,'Sport Kraków','Miejska jednostka sportowa.','Jednostka Miejska');

-------------------------------------------------------
-- Events (30 examples)
-------------------------------------------------------
INSERT INTO Event (Name, Category, Description, Requirements, Location, Latitude, Longitude, StartTime, EndTime, ApplicationDeadline, UserId) VALUES 
('Sprzątanie bulwarów','Środowisko','Wolontariusze sprzątają bulwary wiślane. Udział otwarty.', 'Aktywność fizyczna', 'Bulwary Wiślane', 50.0614,19.9383,'2025-10-10 10:00','2025-10-10 14:00','2025-10-08 23:59',16), 
('Warsztaty teatralne','Kultura','Warsztaty dla dzieci w teatrze.', 'Znajomość teatru, Doświadczenie z dziećmi', 'Teatr Krakowski', 50.0620,19.9400,'2025-11-05 15:00','2025-11-05 18:00','2025-11-02 23:59',23), 
('Zbiórka żywności','Społeczność','Zbieramy produkty dla potrzebujących rodzin.', 'Aktywność fizyczna', 'Centrum Krakowa', 50.0630,19.9360,'2025-10-20 09:00','2025-10-20 17:00','2025-10-18 23:59',16), 
('Bieg dla zdrowia','Sport','Charytatywny bieg w parku Jordana.','Aktywność fizyczna', 'Park Jordana', 50.0650,19.9350,'2025-09-15 08:00','2025-09-15 12:00','2025-09-10 23:59',25), 
('Lekcje angielskiego','Edukacja','Zajęcia dla seniorów w bibliotece.','Język angielski, Prowadzenie zajęć', 'Biblioteka Miejska', 50.0660,19.9390,'2025-12-01 17:00','2025-12-01 19:00','2025-11-28 23:59',22), 
('Koncert młodych talentów','Kultura','Występy uczniów lokalnych szkół.','Aktywność fizyczna, Doświadczenie z dziećmi', 'Centrum Krakowa', 50.0615,19.9420,'2025-12-10 18:00','2025-12-10 21:00','2025-12-05 23:59',21), 
('Warsztaty plastyczne','Kultura','Warsztaty malarskie dla dzieci i młodzieży.','Doświadczenie z dziećmi, Umiejętności artystyczne', 'Centrum Krakowa', 50.0600,19.9340,'2025-09-22 14:00','2025-09-22 16:00','2025-09-19 23:59',17), 
('Pomoc w schronisku','Zwierzęta','Opieka nad psami i kotami w schronisku.','Aktywność fizyczna', 'Schronisko dla zwierząt', 50.0635,19.9370,'2025-10-12 10:00','2025-10-12 14:00','2025-10-10 23:59',24), 
('Kurs komputerowy','Edukacja','Bezpłatne szkolenie z obsługi komputera.','Aktywność fizyczna', 'Centrum Krakowa', 50.0625,19.9410,'2025-11-20 16:00','2025-11-20 19:00','2025-11-17 23:59',18), 
('Akcja krwiodawstwa','Zdrowie','Zachęcamy do oddawania krwi.','Aktywność fizyczna', 'Centrum Krakowa', 50.0640,19.9365,'2025-10-25 09:00','2025-10-25 14:00','2025-10-22 23:59',20), 
('Turniej piłki nożnej','Sport','Turniej dla młodzieży szkolnej.','Aktywność fizyczna', 'Boisko szkolne', 50.0612,19.9395,'2025-09-30 09:00','2025-09-30 15:00','2025-09-27 23:59',25), 
('Warsztaty kulinarne','Społeczność','Nauka zdrowego gotowania.','Aktywność fizyczna', 'Centrum Krakowa', 50.0638,19.9388,'2025-10-15 12:00','2025-10-15 15:00','2025-10-12 23:59',20), 
('Spektakl dla dzieci','Kultura','Przedstawienie teatralne dla najmłodszych.','Aktywność fizyczna', 'Teatr Krakowski', 50.0628,19.9405,'2025-09-18 10:00','2025-09-18 12:00','2025-09-15 23:59',23), 
('Sadzenie drzew','Środowisko','Wspólne sadzenie drzew w parku.','Aktywność fizyczna', 'Park Jordana', 50.0645,19.9345,'2025-11-02 09:00','2025-11-02 13:00','2025-10-30 23:59',16), 
('Zajęcia sportowe','Sport','Ćwiczenia dla seniorów na świeżym powietrzu.','Aktywność fizyczna', 'Park Jordana', 50.0618,19.9372,'2025-10-05 09:00','2025-10-05 11:00','2025-10-02 23:59',25), 
('Kurs pierwszej pomocy','Zdrowie','Szkolenie z udzielania pierwszej pomocy.','Aktywność fizyczna', 'Centrum Krakowa', 50.0652,19.9381,'2025-12-02 10:00','2025-12-02 14:00','2025-11-28 23:59',20), 
('Gra terenowa','Społeczność','Integracyjna gra miejska w centrum Krakowa.','Aktywność fizyczna', 'Centrum Krakowa', 50.0622,19.9399,'2025-09-25 12:00','2025-09-25 16:00','2025-09-22 23:59',19), 
('Warsztaty literackie','Kultura','Spotkanie z młodymi pisarzami.','Aktywność fizyczna', 'Centrum Krakowa', 50.0617,19.9411,'2025-11-18 17:00','2025-11-18 20:00','2025-11-15 23:59',22), 
('Zbiórka ubrań','Społeczność','Zbieramy ubrania dla potrzebujących.','Aktywność fizyczna', 'Centrum Krakowa', 50.0609,19.9362,'2025-10-28 09:00','2025-10-28 18:00','2025-10-25 23:59',16), 
('Maraton taneczny','Kultura','Całodniowe warsztaty taneczne.','Aktywność fizyczna', 'Centrum Krakowa', 50.0631,19.9359,'2025-12-12 10:00','2025-12-12 18:00','2025-12-09 23:59',21), 
('Kiermasz książek','Społeczność','Sprzedaż i wymiana książek w bibliotece.','Aktywność fizyczna', 'Centrum Krakowa', 50.0629,19.9377,'2025-09-20 09:00','2025-09-20 17:00','2025-09-17 23:59',22), 
('Festyn rodzinny','Społeczność','Impreza plenerowa dla rodzin.','Aktywność fizyczna', 'Centrum Krakowa', 50.0611,19.9392,'2025-09-29 12:00','2025-09-29 18:00','2025-09-25 23:59',19), 
('Spotkanie chóru','Kultura','Otwarte próby chóru.','Aktywność fizyczna', 'Centrum Krakowa', 50.0619,19.9367,'2025-10-07 17:00','2025-10-07 19:00','2025-10-04 23:59',21), 
('Wycieczka edukacyjna','Edukacja','Zwiedzanie zabytków Krakowa z przewodnikiem.','Aktywność fizyczna', 'Centrum Krakowa', 50.0634,19.9391,'2025-11-22 10:00','2025-11-22 15:00','2025-11-19 23:59',18), 
('Sprzątanie parku','Środowisko','Akcja sprzątania Parku Jordana.','Aktywność fizyczna', 'Centrum Krakowa', 50.0641,19.9386,'2025-09-12 09:00','2025-09-12 13:00','2025-09-09 23:59',16), 
('Pokaz filmowy','Kultura','Seans filmowy z dyskusją.','Aktywność fizyczna', 'Centrum Krakowa', 50.0626,19.9408,'2025-10-18 18:00','2025-10-18 21:00','2025-10-15 23:59',21), 
('Zajęcia matematyczne','Edukacja','Korepetycje dla uczniów szkoły podstawowej.','Aktywność fizyczna', 'Centrum Krakowa', 50.0607,19.9351,'2025-12-04 15:00','2025-12-04 17:00','2025-12-01 23:59',17), 
('Spotkanie seniorów','Społeczność','Klub dyskusyjny dla seniorów.','Aktywność fizyczna', 'Centrum Krakowa', 50.0613,19.9375,'2025-11-12 11:00','2025-11-12 13:00','2025-11-09 23:59',19), 
('Konferencja naukowa','Edukacja','Wykłady i prezentacje dla studentów.','Aktywność fizyczna', 'Centrum Krakowa', 50.0624,19.9384,'2025-12-08 09:00','2025-12-08 17:00','2025-12-05 23:59',18), 
('Zbiórka karmy','Zwierzęta','Zbieramy karmę dla psów i kotów.','Aktywność fizyczna', 'Centrum Krakowa', 50.0633,19.9371,'2025-09-19 10:00','2025-09-19 16:00','2025-09-16 23:59',24);

-------------------------------------------------------
-- Applications (20)
-------------------------------------------------------
INSERT INTO Application (VolunteerId, EventId, TimeOfApplication,
                         ApplicationAccepted, TimeOfReview)
VALUES
(1,1,'2025-09-01 12:00',1,'2025-09-02 10:00'), 
(2,2,'2025-09-05 15:00',1,'2025-09-06 09:00'), 
(3,3,'2025-09-07 18:00',0,'2025-09-08 11:00'), 
(4,4,'2025-09-09 14:00',1,'2025-09-10 08:30'), 
(5,5,'2025-09-11 16:00',1,'2025-09-12 09:00'), 
(6,6,'2025-09-12 17:00',1,'2025-09-13 08:00'), 
(7,7,'2025-09-13 10:00',0,'2025-09-14 09:00'), 
(8,8,'2025-09-14 12:00',1,'2025-09-15 08:00'), 
(9,9,'2025-09-15 14:00',1,'2025-09-16 10:00'), 
(10,10,'2025-09-16 15:00',0,'2025-09-17 09:30'), 
(11,11,'2025-09-17 18:00',1,'2025-09-18 08:45'), 
(12,12,'2025-09-18 19:00',1,'2025-09-19 10:00'), 
(13,13,'2025-09-19 20:00',0,'2025-09-20 09:00'), 
(14,14,'2025-09-20 21:00',1,'2025-09-21 10:00'), 
(15,15,'2025-09-21 22:00',1,'2025-09-22 09:00'), 
(1,16,'2025-09-22 12:00',1,'2025-09-23 08:00'), 
(2,17,'2025-09-23 14:00',0,'2025-09-24 09:30'), 
(3,18,'2025-09-24 16:00',1,'2025-09-25 10:00'), 
(4,19,'2025-09-25 18:00',1,'2025-09-26 08:00'), 
(5,20,'2025-09-26 20:00',1,'2025-09-27 09:00');
-------------------------------------------------------
-- Opinions (10)
-------------------------------------------------------
INSERT INTO Opinion (VolunteerId, EventId, OpinionText) VALUES
(1, 1,'Jan był bardzo zaangażowany i pomocny.'),
(2, 2,'Anna świetnie współpracowała z dziećmi.'),
(4, 4,'Katarzyna z entuzjazmem wspierała uczestników.'),
(5, 5,'Tomasz wykazał się cierpliwością i wiedzą.'), 
(6, 6,'Agnieszka przygotowała atrakcyjne zajęcia.'), 
(8, 8,'Magdalena doskonale opiekowała się zwierzętami.'), 
(9, 9,'Paweł wykazał się dużą odpowiedzialnością.'), 
(11, 11,'Ewa aktywnie pomagała w organizacji turnieju.'), 
(12, 12,'Jakub był bardzo punktualny i sumienny.'), 
(14, 14,'Mateusz z dużym zaangażowaniem wspierał młodzież.');

INSERT INTO Message (SenderId, ReceiverId, Body, Read, Time) VALUES
(1, 16, 'Dzień dobry, chciałbym potwierdzić swoją obecność na sprzątaniu bulwarów.', 1, '2025-09-01 12:30'),
(16, 1, 'Cześć Jan, dziękujemy za zgłoszenie! Do zobaczenia na miejscu.', 0, '2025-09-01 13:00'),
(2, 16, 'Cześć, czy mogę zabrać ze sobą kolegów na sprzątanie bulwarów?', 0, '2025-09-02 14:00'),
(5, 16, 'Witam, czy są jeszcze miejsca na sprzątanie bulwarów?', 0, '2025-09-03 10:00'),
(12, 16, 'Dzień dobry, chciałbym wziąć udział w zbiórce ubrań.', 0, '2025-09-04 11:30'),
(2, 23, 'Witam, czy mogę zabrać ze sobą kolegów na warsztaty teatralne?', 1, '2025-09-05 15:30'),
(23, 2, 'Cześć Anno, oczywiście! Im więcej osób, tym lepiej.', 0, '2025-09-05 16:00'),
(3, 16, 'Czy mogę jeszcze dołączyć do zbiórki żywności?', 1, '2025-09-07 18:30'),
(16, 3, 'Cześć Piotrze, tak! Zapraszamy serdecznie.', 1, '2025-09-07 19:00'),
(4, 25, 'Dzień dobry, czy są jeszcze miejsca na bieg dla zdrowia?', 1, '2025-09-09 14:30'),
(25, 4, 'Cześć Katarzyno, tak! Możesz się jeszcze zapisać.', 1, '2025-09-09 15:00'),
(5, 22, 'Witam, chciałbym się zapisać na lekcje angielskiego dla seniorów.', 1, '2025-09-11 16:30'),
(22, 5, 'Cześć Tomaszu, świetnie! Zapraszamy do biblioteki.', 0, '2025-09-11 17:00');
