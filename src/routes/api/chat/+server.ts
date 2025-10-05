import { 
    OPENAI_API_KEY, 
    OPENAI_CHAT_MODEL, 
    OPENAI_EMBEDDING_MODEL,
    CHROMA_API_KEY, 
    CHROMA_DATABASE_NAME, 
    CHROMA_TENANT_ID, 
    SQL_DATABASE_NAME 
} from '$env/static/private';

import { json } from '@sveltejs/kit';
import { Database } from "bun:sqlite";
import OpenAI from "openai";
import { CloudClient } from "chromadb";
import type { Collection } from "chromadb";

import { ChatOpenAI } from "@langchain/openai";
import { HumanMessage, AIMessage, SystemMessage } from "@langchain/core/messages";
import { ToolNode } from "@langchain/langgraph/prebuilt";
import { StateGraph, MessagesAnnotation } from "@langchain/langgraph";
import { tool } from "@langchain/core/tools";

import { z } from "zod";

type Category =
  | "Środowisko"
  | "Edukacja"
  | "Zdrowie"
  | "Społeczność"
  | "Kultura"
  | "Sport"
  | "Zwierzęta"
  | "Inne";

function toCategory(value: string): Category {
  if (
    value === "Środowisko" ||
    value === "Edukacja" ||
    value === "Zdrowie" ||
    value === "Społeczność" ||
    value === "Kultura" ||
    value === "Sport" ||
    value === "Zwierzęta" ||
    value === "Inne"
  ) {
    return value;
  }
  throw new Error(`Invalid category from DB: ${value}`);
}

interface Event {
  EventId: number;
  Name: string;
  Category: Category;
  Description: string;
  Latitude: number;
  Longitude: number;
  StartTime: string;
  EndTime: string;
  ApplicationDeadline: string;
  OrganizationId: number;
}

const db = new Database(`./${SQL_DATABASE_NAME || "volunteering.db"}`);
const openai = new OpenAI({ apiKey: OPENAI_API_KEY });
const embeddingModel = OPENAI_EMBEDDING_MODEL || "text-embedding-3-small"
const chromaClient = new CloudClient({
  apiKey: CHROMA_API_KEY,
  tenant: CHROMA_TENANT_ID,
  database: CHROMA_DATABASE_NAME
});

let collection: Collection | undefined;
// Use 'any' type to avoid type incompatibility errors
let app: any;

async function initializeAI() {
  if (!collection) {
    collection = await chromaClient.getOrCreateCollection({ name: "events" });
  }

  if (!app) {
    const searchEvents = tool(
      async ({ query }: { query: string }) => {
        console.log(`Searching events for query: ${query}`);
        const embeddingResp = await openai.embeddings.create({
          model: embeddingModel,
          input: query,
        });
        const queryEmbedding = embeddingResp.data?.[0]?.embedding;
        if (!queryEmbedding) {
          throw new Error("Failed to generate embedding for query.");
        }

        const results = await collection?.query({
          queryEmbeddings: [queryEmbedding],
          nResults: 5,
          include: ["metadatas", "documents", "distances"],
        });

        if (!results?.ids.length) return "No events found.";

        if (
          !results.ids[0] ||
          !results.metadatas?.[0] ||
          !results.distances?.[0]
        ) return "No events found.";

        return results.ids[0].map((id, idx) => {
          const metadata = results.metadatas[0]?.[idx];
          const distance = results.distances[0]?.[idx];
          const eventData = `EventId: ${id}, Name: ${metadata?.Name ?? "Unknown"}, Category: ${metadata?.Category ?? "Unknown"}, Score: ${distance !== undefined && distance !== null ? distance.toFixed(3) : "N/A"}`;
          console.log("Found event:", eventData);
          return eventData;
        }).join("\n");
      },
      {
        name: "searchEvents",
        description:
          "Search for events by name or description using semantic similarity.",
        schema: z.object({
          query: z.string().describe("Search query"),
        }),
      }
    );

    const getEventById = tool(
      async ({ eventId }: { eventId: number }) => {
        try {
          console.log(`Querying for EventId: ${eventId}`);
          const query = db.query("SELECT * FROM Event WHERE EventId = $eventId;").all({ $eventId: eventId });

          console.log("DB query result:", query);

          if (query.length === 0) {
            return `No event found with EventId ${eventId}`;
          }

          const event: Event = {
            ...query[0] as Event,
            Category: toCategory((query[0] as Event).Category), // cast to enum
          };
            
          const eventData = `EventId: ${event.EventId}, Name: ${event.Name}, Category: ${event.Category}, Description: ${event.Description}, Latitude: ${event.Latitude}, Longitude: ${event.Longitude}, StartTime: ${event.StartTime}, EndTime: ${event.EndTime}, ApplicationDeadline: ${event.ApplicationDeadline}, OrganizationId: ${event.OrganizationId}`;
          console.log("Found event:", eventData);
          return eventData;
        } catch (err) {
          console.error("Database error:", err);
          throw err; // rethrow so you see the error in the console
        }
      },
      {
        name: "getEvent",
        description: "Retrieve event details by EventId.",
        schema: z.object({
          eventId: z.number().describe("The ID of the event to retrieve."),
        }),
      }
    );

    const getEventsByCategory = tool(
      async ({ category }: { category: Category }) => {
        try {
          console.log(`Querying for Events from Category: ${category}`);
          const query = db.query("SELECT * FROM Event WHERE Category = $category;").all({ $category: category });
          console.log("DB query result:", query);
          if (query.length === 0) {
            return `No events found with Category ${category}`;
          }
          const events: Event[] = query.map((row) => ({
            ...row as Event,
            Category: toCategory((row as Event).Category),
          }));
          return events.map(event => {
            const eventData = `EventId: ${event.EventId}, Name: ${event.Name}, Category: ${event.Category}, Latitude: ${event.Latitude}, Longitude: ${event.Longitude}, StartTime: ${event.StartTime}, EndTime: ${event.EndTime}, ApplicationDeadline: ${event.ApplicationDeadline}, OrganizationId: ${event.OrganizationId}`;
            console.log("Found event:", eventData);
            return eventData;
          }).join("\n");
        } catch (err) {
          console.error("Database error:", err);
          throw err;
        }
      },
      {
        name: "getEventsByCategory",
        description: "Retrieve events by Category.",
        schema: z.object({
          category: z.enum(["Środowisko", "Edukacja", "Zdrowie", "Społeczność", "Kultura", "Sport", "Zwierzęta", "Inne"]).describe("The category of events to retrieve."),
        }),
      }
    );

    const tools = [getEventById, getEventsByCategory, searchEvents];
    const toolNode = new ToolNode(tools);

    const model = new ChatOpenAI({
      model: OPENAI_CHAT_MODEL || "gpt-4.1-nano",
      temperature: 0.3,
    }).bindTools(tools);

    function shouldContinue({ messages }: typeof MessagesAnnotation.State) {
      const lastMessage = messages[messages.length - 1] as AIMessage;

      if (lastMessage.tool_calls?.length) {
        return "tools";
      }
      return "__end__";
    }

    async function callModel(state: typeof MessagesAnnotation.State) {
      const response = await model.invoke(state.messages);
      return { messages: [response] };
    }

    const workflow = new StateGraph(MessagesAnnotation)
      .addNode("agent", callModel)
      .addEdge("__start__", "agent")
      .addNode("tools", toolNode)
      .addEdge("tools", "agent")
      .addConditionalEdges("agent", shouldContinue);

    app = workflow.compile();
  }
}

export async function POST({ request }: { request: Request }) {
  try {
    await initializeAI();
    
    const { message } = await request.json();
    
    const systemMessage = new SystemMessage(
      "Jesteś pomocnym asystentem, który pomaga znaleźć wydarzenia wolontariackie. Udzielaj odpowiedzi w języku polskim. W przypadku pytań o wydarzenia lub organizacje, najpierw wyszukaj je za pomocą dostępnych narzędzi, a następnie przedstaw skonsolidowane wyniki użytkownikowi. Jeśli użytkownik zadaje pytanie niezwiązane uczestnictewm w wolonatariacie, wydarzeniami lub organizacjami, uprzejmie poinformuj go, że nie możesz pomóc w tej kwestii."
    );
    
    const result = await app.invoke({
      messages: [systemMessage, new HumanMessage(message)]
    });
    
    const lastMessage = result.messages[result.messages.length - 1];
    
    return json({ 
      response: lastMessage.content 
    });
    
  } catch (error) {
    console.error('Chat API error:', error);
    return json({ 
      error: 'Failed to process message' 
    }, { status: 500 });
  }
}
