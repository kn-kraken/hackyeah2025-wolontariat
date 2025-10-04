-- Clean up old schema if it exists
DROP TABLE IF EXISTS Opinion;
DROP TABLE IF EXISTS Application;
DROP TABLE IF EXISTS Event;
DROP TABLE IF EXISTS Volunteer;
DROP TABLE IF EXISTS School;
DROP TABLE IF EXISTS Organization;

-------------------------------------------------------
-- School
-------------------------------------------------------
CREATE TABLE School (
    SchoolId INTEGER PRIMARY KEY AUTOINCREMENT,
    Name TEXT NOT NULL,
    Address TEXT NOT NULL
);

-------------------------------------------------------
-- Organization
-------------------------------------------------------
CREATE TABLE Organization (
    OrganizationId INTEGER PRIMARY KEY AUTOINCREMENT,
    Name TEXT NOT NULL,
    Description TEXT,
    Type TEXT CHECK(Type IN ('NGO','Foundation','School','University','Cultural Institution','Public Institution')) NOT NULL
);

-------------------------------------------------------
-- Volunteer
-------------------------------------------------------
CREATE TABLE Volunteer (
    VolunteerId INTEGER PRIMARY KEY AUTOINCREMENT,
    Name TEXT NOT NULL,
    Surname TEXT NOT NULL,
    Age INTEGER,
    AvatarUrl TEXT,
    SchoolId INTEGER,
    FOREIGN KEY (SchoolId) REFERENCES School(SchoolId)
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
    OrganizationId INTEGER NOT NULL,
    FOREIGN KEY (OrganizationId) REFERENCES Organization(OrganizationId)
);

-------------------------------------------------------
-- Application (many-to-many: Volunteer <-> Event)
-------------------------------------------------------
CREATE TABLE Application (
    ApplicationId INTEGER PRIMARY KEY AUTOINCREMENT,
    VolunteerId INTEGER NOT NULL,
    EventId INTEGER NOT NULL,
    TimeOfApplication DATETIME NOT NULL,
    ApplicationAccepted BOOLEAN,
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
-- Sample Data
-------------------------------------------------------

-- Schools (4)
INSERT INTO School (Name, Address) VALUES
('High School No. 5', '123 Main St, Springfield'),
('Technical School of IT', '45 Tech Rd, Springfield'),
('Community Arts School', '22 Art Ln, Springfield'),
('Medical Preparatory School', '89 Health Ave, Springfield');

-- Organizations (6)
INSERT INTO Organization (Name, Description, Type) VALUES
('Green Earth NGO', 'Focused on environmental protection.', 'NGO'),
('Cultural House Foundation', 'Promotes cultural activities and workshops.', 'Foundation'),
('City Public Library', 'Offers education services.', 'Public Institution'),
('Animal Rescue Group', 'Supports animal shelters.', 'NGO'),
('University of Springfield', 'Organizes academic events.', 'University'),
('Springfield Hospital', 'Hosts health awareness campaigns.', 'Public Institution');

-- Volunteers (10)
INSERT INTO Volunteer (Name, Surname, Age, AvatarUrl, SchoolId) VALUES
('Alice','Johnson',17,'https://i.pravatar.cc/150?u=david',1),
('Bob','Smith',18,'https://i.pravatar.cc/150?u=bob',1),
('Charlie','Davis',19,'https://i.pravatar.cc/150?u=charlie',2),
('Diana','Brown',20,'https://i.pravatar.cc/150?u=diana',2),
('Ethan','Miller',17,'https://i.pravatar.cc/150?u=ethan',1),
('Fiona','Wilson',21,'https://i.pravatar.cc/150?u=fiona',3),
('George','Taylor',22,'https://i.pravatar.cc/150?u=sophia',3),
('Hannah','Anderson',18,'https://i.pravatar.cc/150?u=hannah',4),
('Ian','Thomas',19,'https://i.pravatar.cc/150?u=ian',4),
('Julia','Martinez',20,'https://i.pravatar.cc/150?u=julia',2);

-- Events (20)
INSERT INTO Event (Name, Category, Latitude, Longitude, StartTime, EndTime, ApplicationDeadline, OrganizationId) VALUES
('Park Clean-up','Environment',40.7128,-74.0060,'2025-11-10 09:00','2025-11-10 13:00','2025-11-05 23:59',1),
('Recycling Workshop','Education',40.7139,-74.0055,'2025-11-15 10:00','2025-11-15 14:00','2025-11-12 23:59',1),
('Tree Planting','Environment',40.7140,-74.0070,'2025-11-20 08:00','2025-11-20 12:00','2025-11-18 23:59',1),
('Art Exhibition Helpers','Culture',40.7200,-74.0000,'2025-11-08 16:00','2025-11-08 20:00','2025-11-06 23:59',2),
('Theatre Event Support','Culture',40.7210,-74.0020,'2025-11-12 18:00','2025-11-12 22:00','2025-11-10 23:59',2),
('Music Festival Staff','Culture',40.7220,-74.0040,'2025-12-01 15:00','2025-12-01 23:00','2025-11-28 23:59',2),
('Library Reading Hour','Education',40.7250,-74.0030,'2025-11-07 14:00','2025-11-07 16:00','2025-11-06 23:59',3),
('Homework Help','Education',40.7260,-74.0045,'2025-11-14 15:00','2025-11-14 17:00','2025-11-12 23:59',3),
('Book Fair Support','Community',40.7270,-74.0050,'2025-11-18 09:00','2025-11-18 17:00','2025-11-15 23:59',3),
('Sports Day Assistants','Sports',40.7280,-74.0065,'2025-11-22 08:00','2025-11-22 18:00','2025-11-19 23:59',1),
('Health Awareness Booth','Health',40.7290,-74.0075,'2025-11-25 10:00','2025-11-25 16:00','2025-11-22 23:59',6),
('Animal Shelter Visit','Animal Welfare',40.7300,-74.0080,'2025-11-30 10:00','2025-11-30 14:00','2025-11-28 23:59',4),
('Dog Adoption Fair','Animal Welfare',40.7310,-74.0090,'2025-12-05 09:00','2025-12-05 15:00','2025-12-01 23:59',4),
('Cat Care Workshop','Animal Welfare',40.7320,-74.0100,'2025-12-08 12:00','2025-12-08 16:00','2025-12-05 23:59',4),
('Medical Volunteer Day','Health',40.7330,-74.0110,'2025-11-27 08:00','2025-11-27 18:00','2025-11-24 23:59',6),
('Blood Donation Drive','Health',40.7340,-74.0120,'2025-11-29 09:00','2025-11-29 15:00','2025-11-26 23:59',6),
('Student Science Fair','Education',40.7350,-74.0130,'2025-12-02 10:00','2025-12-02 16:00','2025-11-28 23:59',5),
('Cultural Dance Night','Culture',40.7360,-74.0140,'2025-12-03 18:00','2025-12-03 22:00','2025-11-30 23:59',2),
('Historical Lecture','Education',40.7370,-74.0150,'2025-12-04 17:00','2025-12-04 19:00','2025-12-01 23:59',5),
('Winter Sports Tournament','Sports',40.7380,-74.0160,'2025-12-06 09:00','2025-12-06 20:00','2025-12-02 23:59',5);

-- Applications (12)
INSERT INTO Application (VolunteerId, EventId, TimeOfApplication, ApplicationAccepted, TimeOfReview) VALUES
(1,1,'2025-10-01 10:00',1,'2025-10-02 09:00'),
(2,2,'2025-10-02 11:00',0,'2025-10-03 12:00'),
(3,3,'2025-10-03 14:00',1,'2025-10-04 10:00'),
(4,4,'2025-10-04 15:00',NULL,NULL),
(5,5,'2025-10-05 09:00',1,'2025-10-06 09:30'),
(6,6,'2025-10-06 11:00',1,'2025-10-07 14:00'),
(7,7,'2025-10-07 12:00',NULL,NULL),
(8,8,'2025-10-08 13:00',1,'2025-10-09 15:00'),
(9,9,'2025-10-09 14:00',NULL,NULL),
(10,10,'2025-10-10 15:00',1,'2025-10-11 11:00'),
(1,11,'2025-10-11 16:00',1,'2025-10-12 12:00'),
(2,12,'2025-10-12 17:00',1,'2025-10-13 12:00');

-- Opinions (6)
INSERT INTO Opinion (VolunteerId, EventId, OpinionText) VALUES
(1,1,'Very dedicated and hardworking volunteer.'),
(2,2,'Arrived late and did not follow instructions well.'),
(3,3,'Excellent initiative and teamwork.'),
(5,5,'Great support during the event, very reliable.'),
(8,8,'Friendly and helpful with participants.'),
(10,10,'Showed leadership skills and responsibility.');
