import { getUser } from "$lib/queries";
import { redirect } from "@sveltejs/kit";
import type {Actions} from "./$types";

export const actions = {
  default:async (event) => {
    const data = await event.request.formData();
    const username = data.get("username");
    if (!username) return;

    const user = getUser(username.toString());
    if (!user) return;

    event.cookies.set("user_id", user.UserId.toString(), {secure: true, path: '/'});
    if (user.isOrg) {
      throw redirect(303, "/organizer");
    } else {
      throw redirect(303, "/volunteer");
    }
  }
} satisfies Actions;
