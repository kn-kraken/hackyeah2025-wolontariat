import Database from 'better-sqlite3';

// --- Type Declarations for Database Rows ---

/** Represents a row from the 'User' table. */
export interface User {
  UserId: number;
  AvatarUrl: string;
}

/** Represents a row from the 'Message' table. */
export interface Message {
  SenderId: number;
  ReceiverId: number;
  body: string;
  read: 0 | 1; // SQLite BOOLEAN is stored as 0 or 1
  time: string; // Stored as DATETIME string
}

/** Represents a row from the 'Organization' table. */
export interface Organization {
  UserId: number;
  Name: string;
  Description: string;
  Type:
    | 'Organizacja Pozarządowa'
    | 'Fundacja'
    | 'Szkoła'
    | 'Uniwersytet'
    | 'Instytucja Kultury'
    | 'Jednostka Miejska';
}

/** Represents a row from the 'Volunteer' table. */
export interface Volunteer {
  UserId: number;
  Name: string;
  Surname: string;
  Age: number;
}

/** Represents a row from the 'Event' table. */
export interface Event {
  EventId: number;
  Name: string;
  Description: string;
  Category:
    | 'Środowisko'
    | 'Edukacja'
    | 'Zdrowie'
    | 'Społeczność'
    | 'Kultura'
    | 'Sport'
    | 'Zwierzęta'
    | 'Inne';
  Latitude: number;
  Longitude: number;
  StartTime: string; // DATETIME string
  EndTime: string; // DATETIME string
  ApplicationDeadline: string; // DATETIME string
  UserId: number;
}

/** Represents a combination of Event and Organization data. */
export interface EventWithOrganizer extends Event {
  OrganizationName: string;
}

/** Represents the latest message and the sender's details for a given receiver. */
export interface LatestMessageWithSender extends Message {
  SenderAvatarUrl: string;
}

// --- Database Connection ---

/**
 * Initializes and returns the SQLite database connection.
 * @param dbPath The path to the SQLite database file. Defaults to './db.sqlite'.
 * @returns The better-sqlite3 Database instance.
 */
export function initializeDb(dbPath: string = './db.sqlite'): Database.Database {
  const db = new Database(dbPath);
  return db;
}


const db = initializeDb();
// --- Data Fetching Functions ---

export function getAllEvents(): EventWithOrganizer[] {
  const query = `
    SELECT
      E.*,
      O.Name AS OrganizationName
    FROM
      Event E
    JOIN
      Organization O ON E.UserId = O.UserId;
  `;
  const statement = db.prepare(query);
  return statement.all() as EventWithOrganizer[];
}

export function getUpcomingEventsForOrganizer(organizationId: number): Event[] {
  const query = `
    SELECT
      *
    FROM
      Event
    WHERE
      UserId = @organizationId
      AND StartTime < datetime('now', '+1 month')
      AND StartTime >= datetime('now');
  `;
  const statement = db.prepare(query);
  return statement.all({ organizationId }) as Event[];
}

export function getUnreadMessagesForUser(receiverId: number): Message[] {
  const query = `
    SELECT
      *
    FROM
      Message
    WHERE
      ReceiverId = @receiverId
      AND read = 0
    ORDER BY
      time DESC;
  `;
  const statement = db.prepare(query);
  return statement.all({ receiverId }) as Message[];
}

export function getConversationMessages(receiverId: number, senderId: number): Message[] {
  const query = `
    SELECT
      *
    FROM
      Message
    WHERE
      (ReceiverId = @receiverId AND SenderId = @senderId)
      OR (ReceiverId = @senderId AND SenderId = @receiverId)
    ORDER BY
      time ASC;
  `;
  const statement = db.prepare(query);
  return statement.all({ receiverId, senderId }) as Message[];
}

export function getLatestMessagesBySender(receiverId: number): LatestMessageWithSender[] {
  const query = `
    SELECT
      M.SenderId,
      M.ReceiverId,
      M.body,
      M.read,
      M.time,
      U.AvatarUrl AS SenderAvatarUrl
    FROM
      Message M
    INNER JOIN
      (
        SELECT
          SenderId,
          MAX(time) AS LatestTime
        FROM
          Message
        WHERE
          ReceiverId = @receiverId
        GROUP BY
          SenderId
      ) AS Latest
      ON M.SenderId = Latest.SenderId AND M.time = Latest.LatestTime
    JOIN
      User U ON M.SenderId = U.UserId
    WHERE
      M.ReceiverId = @receiverId
    ORDER BY
      M.time DESC;
  `;
  const statement = db.prepare(query);
  return statement.all({ receiverId }) as LatestMessageWithSender[];
}

export function getUser(username: string): { UserId: number; isOrg: boolean } | null {
  const org = db
    .prepare(`
      SELECT UserId
      FROM User
      JOIN Organization USING(UserId)
      WHERE Username = @username;
    `)
    .get({ username });

  if (org) {
    return { UserId: org.UserId, isOrg: true };
  }

  const volunteer = db
    .prepare(`
      SELECT UserId
      FROM User
      JOIN Volunteer USING(UserId)
      WHERE Username = @username;
    `)
    .get({ username });

  if (volunteer) {
    return { UserId: volunteer.UserId, isOrg: false };
  }

  return null;
}
