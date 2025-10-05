import { getAllEvents, getUnreadMessagesForUser, getUpcomingEventsForOrganizer } from "$lib/queries";
import type { PageServerLoad } from "./$types";

export const load = (async (event) => {
  const { UserId } = await event.parent();

  const upcomingEvents = getAllEvents().slice(0, 4);
  const unreadMessages = getUnreadMessagesForUser(UserId);

  return {
    upcomingEvents,
    unreadMessages,
  }
}) satisfies PageServerLoad;
