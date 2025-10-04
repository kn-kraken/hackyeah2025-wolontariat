import { getAllEvents, } from "$lib/queries";
import type { PageServerLoad } from "./$types";

export const load = (async () => {
  const allEvents = getAllEvents();

  return {
    allEvents,
  }
}) satisfies PageServerLoad;

