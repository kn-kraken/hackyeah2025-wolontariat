import { redirect } from "@sveltejs/kit";
import type { LayoutServerLoad } from "./$types";

export const load = ((event) => {
  // dummy auth
  const UserId = event.cookies.get("user_id");
  if (!UserId) {
    throw redirect(303, "/login")
  }
  return {
    UserId: +UserId
  }
}) satisfies LayoutServerLoad;
