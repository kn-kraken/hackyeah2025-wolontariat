import { getUnreadMessagesForUser, getUpcomingEventsForOrganizer } from "$lib/queries";
import type { PageServerLoad } from "./$types";

export const load = (async (event) => {
  const { UserId } = await event.parent();

  const upcomingEvents = getUpcomingEventsForOrganizer(UserId);
  const unreadMessages = getUnreadMessagesForUser(UserId);

  return {
    upcomingEvents,
    unreadMessages,
  }
}) satisfies PageServerLoad;
