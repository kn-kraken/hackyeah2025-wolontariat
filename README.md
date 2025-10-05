# Aplikacja Krakowskiego Cyfrowego Centrum Wolontariatu

By **Krakenteers**, HackYeah 2025

## Opis projektu

Platforma łącząca **młodzież**, **szkoły** i **organizacje** - wszystko prosto i wygodnie.

## Funkcjonalności

- Widok wolontariusza:
  - Dashboard z ofertami wolontariatu
  - Interaktywna mapa
  - Filtrowanie ofert
  - Chatbot AI pomagający w wyszukiwaniu eventów
  - Aplikowanie na oferty
  - Czat z organizatorem
- Widok organizacji:
  - Tworzenie nowej oferty wolontariatu
  - Przeglądanie i akceptowanie aplikacji
  - Czat z wolontariuszami

## Stos technologiczny

- Aplikacja została zaimplementowana przy użyciu [SvelteKit](https://svelte.dev/docs/kit/introduction).
- Baza danych SQLite3
- Wektorowa baza danych ChromaDB
- Integracja z modelami LLM OpenAI poprzez [LangGraph.js](https://langchain-ai.github.io/langgraphjs/).
- Moduł do generacji zaświadczeń uczesnictwa w PDF zaimplementowany w Pythonie

## Uruchomianie aplikacji

1. Zainstaluj zależności

```
bun i
```

2. Uruchm serwer developerski

```
bun --bun run dev
```
