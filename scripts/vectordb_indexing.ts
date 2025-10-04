import "dotenv/config";
import { Database } from "bun:sqlite";
import OpenAI from "openai";
import { CloudClient } from "chromadb";

type Category =
| "Środowisko"
| "Edukacja"
| "Zdrowie"
| "Społeczność"
| "Kultura"
| "Sport"
| "Zwierzęta"
| "Inne";

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

const db = new Database(`./${process.env.SQL_DATABASE_NAME || "volunteering.db"}`);
const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });
const embeddingModel = process.env.OPENAI_EMBEDDING_MODEL || "text-embedding-3-small";

const chromaClient = new CloudClient({
  apiKey: process.env.CHROMA_API_KEY,
  tenant: process.env.CHROMA_TENANT_ID,
  database: process.env.CHROMA_DATABASE_NAME,
});
const collection = await chromaClient.getOrCreateCollection({ name: "events" });

const existingEventIds = new Set(
  (await collection.get({ include: ["metadatas"] })).ids.map((id) => Number(id))
);

console.log("Existing event IDs in ChromaDB:", existingEventIds);

const events = db.query("SELECT * FROM Event").all();

console.log(`Fetched ${events.length} events from the database.`);

for (const rawEvent of events) {
  const event = rawEvent as Event;
  if (!existingEventIds.has(event.EventId)) {
    const embeddingResp = await openai.embeddings.create({
      model: embeddingModel,
      input: event.Name + " " + event.Category + " " + event.Description,
    });
    const embedding = embeddingResp.data?.[0]?.embedding;
    if (!embedding) {
      console.error("Embedding not found for event:", event.EventId);
      continue;
    }

    await collection.add({
      ids: [String(event.EventId)],
      embeddings: [embedding],
      metadatas: [{ Name: event.Name, Category: event.Category }],
    });
  }
}

console.log("Indexing complete.");
