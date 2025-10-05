import { Database } from 'bun:sqlite';

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
  Type: 'Organizacja Pozarządowa' | 'Fundacja' | 'Szkoła' | 'Uniwersytet' | 'Instytucja Kultury' | 'Jednostka Miejska';
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
  Category: 'Środowisko' | 'Edukacja' | 'Zdrowie' | 'Społeczność' | 'Kultura' | 'Sport' | 'Zwierzęta' | 'Inne';
  Latitude: number;
  Longitude: number;
  StartTime: string; // Stored as DATETIME string
  EndTime: string;   // Stored as DATETIME string
  ApplicationDeadline: string; // Stored as DATETIME string
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
 * @returns The Bun.Database instance.
 */
export function initializeDb(dbPath: string = './db.sqlite'): Database {
  const db = new Database(dbPath);
  return db;
}

const db = initializeDb();

// --- Data Fetching Functions ---

/**
 * Fetches all events from the database.
 * @param db The connected Bun.Database instance.
 * @returns A promise that resolves to an array of all events with their organizer's name.
 */
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
  const statement = db.query(query);
  return statement.all() as EventWithOrganizer[];
}

/**
 * Fetches all events for a given organizer that start in less than a month from now.
 * @param db The connected Bun.Database instance.
 * @param organizationId The UserId of the organizer (OrganizationId in the Event table).
 * @returns A promise that resolves to an array of relevant events.
 */
export function getUpcomingEventsForOrganizer( organizationId: number): Event[] {
  // SQLite's 'datetime('now', '+1 month')' calculates one month from the current date.
  const query = `
    SELECT
      *
    FROM
      Event
    WHERE
      UserId = $organizationId
      AND StartTime < datetime('now', '+1 month')
      AND StartTime >= datetime('now'); -- Ensures only future events are returned
  `;
  const statement = db.query(query);
  return statement.all({ $organizationId: organizationId }) as Event[];
}

/**
 * Fetches all unread messages for a given receiving user.
 * @param db The connected Bun.Database instance.
 * @param receiverId The UserId of the receiving user.
 * @returns A promise that resolves to an array of unread messages.
 */
export function getUnreadMessagesForUser( receiverId: number): Message[] {
  const query = `
    SELECT
      *
    FROM
      Message
    WHERE
      ReceiverId = $receiverId
      AND read = 0
    ORDER BY
      time DESC;
  `;
  const statement = db.query(query);
  return statement.all({ $receiverId: receiverId }) as Message[];
}

/**
 * Fetches all messages between a specific sending user and a specific receiving user.
 * @param db The connected Bun.Database instance.
 * @param receiverId The UserId of the receiving user.
 * @param senderId The UserId of the sending user.
 * @returns A promise that resolves to an array of messages between the two users, ordered by time.
 */
export function getConversationMessages( receiverId: number, senderId: number): Message[] {
  const query = `
    SELECT
      *
    FROM
      Message
    WHERE
      (ReceiverId = $receiverId AND SenderId = $senderId)
      OR (ReceiverId = $senderId AND SenderId = $receiverId)
    ORDER BY
      time ASC;
  `;
  const statement = db.query(query);
  return statement.all({ $receiverId: receiverId, $senderId: senderId }) as Message[];
}

/**
 * Fetches the latest message for every unique sending user for a given receiving user.
 * This is typically used to populate an inbox/chat list view.
 * @param db The connected Bun.Database instance.
 * @param receiverId The UserId of the receiving user.
 * @returns A promise that resolves to an array of the latest messages with sender details.
 */
export function getLatestMessagesBySender( receiverId: number): LatestMessageWithSender[] {
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
          ReceiverId = $receiverId -- We are interested in messages where the current user is the receiver
        GROUP BY
          SenderId
      ) AS Latest
      ON M.SenderId = Latest.SenderId AND M.time = Latest.LatestTime
    JOIN
      User U ON M.SenderId = U.UserId
    WHERE
      M.ReceiverId = $receiverId -- Safety check
    ORDER BY
      M.time DESC;
  `;
  const statement = db.query(query);
  return statement.all({ $receiverId: receiverId }) as LatestMessageWithSender[];
}

export function getUser(username: string): { UserId: number; isOrg: boolean } | null {
  const org = db.query(`
    SELECT
    UserId
    FROM
    User JOIN Organization USING(UserId) WHERE Username = $username;
  `).get({ $username: username });
  if (org != null) {
    return {
      UserId: org.UserId,
      isOrg: true,
    }
  }
  const volunteer = db.query(`
    SELECT
    UserId
    FROM
    User JOIN Volunteer USING(UserId) WHERE Username = $username;
  `).get({ $username: username });
  if (volunteer != null) {
    return {
      UserId: volunteer.UserId,
      isOrg: false,
    }
  }
  return null;
}

