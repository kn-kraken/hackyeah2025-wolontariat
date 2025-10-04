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
    body TEXT NOT NULL,
    read BOOLEAN NOT NULL,
    time DATETIME NOT NULL,
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
    Type TEXT CHECK(Type IN ('NGO','Foundation','School','University','Cultural Institution','Public Institution')) NOT NULL,
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
    Category TEXT CHECK(Category IN ('Environment','Education','Health','Community','Culture','Sports','Animal Welfare')),
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

