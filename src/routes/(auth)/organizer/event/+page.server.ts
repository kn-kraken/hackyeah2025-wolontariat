import { getUnreadMessagesForUser, getUpcomingEventsForOrganizer } from "$lib/queries";
import type { PageServerLoad } from "./$types";

export const load = (async (event) => {
  const { UserId } = await event.parent();
  return {}
}) satisfies PageServerLoad;

