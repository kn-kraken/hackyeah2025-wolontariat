import { getLatestMessagesBySender, getUnreadMessagesForUser, getUpcomingEventsForOrganizer } from "$lib/queries";
import type { PageServerLoad } from "./$types";

export const load = (async (event) => {
  const { UserId } = await event.parent();

  const latestMessages = getLatestMessagesBySender(UserId);

  return {
    latestMessages,
  }
}) satisfies PageServerLoad;

