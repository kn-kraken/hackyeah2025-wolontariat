<script lang="ts">
	import Chatbot from '$lib/Chatbot.svelte';
	import { onMount } from 'svelte';

	export let data;

	let allEvents = data.allEvents;
	let isLoading = true;
	let events: typeof allEvents = [];
	let searchQuery = '';
	let locationFilter = '';

	let mapContainer: HTMLDivElement;
	let map: any;
	let L: any;

	onMount(async () => {
		// Import Leaflet tylko po stronie klienta
		const leaflet = await import('leaflet');
		L = leaflet;

		// Styl Leaflet (musi być dołączony, żeby kafelki się renderowały!)
		import('leaflet/dist/leaflet.css');

		// Ustawienie wymiarów kontenera mapy
		mapContainer.style.width = '100%';
		mapContainer.style.height = '400px';

		map = L.map(mapContainer, {
			center: [50.0650,19.9350], // Warszawa
			zoom: 12,
		});

		L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
			attribution: '&copy; OpenStreetMap contributors'
		}).addTo(map);

		// Symulacja pobrania danych
		setTimeout(() => {
			events = allEvents;
			isLoading = false;
			map.invalidateSize(); // <<< kluczowy moment, odświeża rozmiar mapy po załadowaniu
		}, 500);
	});

	// --- Filtr wydarzeń ---
	$: filteredEvents = events.filter((event) => {
		const searchMatch =
			searchQuery.length < 2 ||
			event.Name.toLowerCase().includes(searchQuery.toLowerCase()) ||
			event.Description.toLowerCase().includes(searchQuery.toLowerCase()) ||
			event.OrganizationName.toLowerCase().includes(searchQuery.toLowerCase());

		const locationMatch =
			locationFilter === '' ||
			event.Latitude.toString().toLowerCase().includes(locationFilter.toLowerCase());

		return searchMatch && locationMatch;
	});

	// --- Unikalne lokalizacje ---
	$: uniqueLocations = [...new Set(allEvents.map((event) => event.Latitude))];

	// --- Aktualizacja markerów ---
	async function updateMarkers() {
		if (!map || !L) return;

		// usuń stare markery
		map.eachLayer((layer) => {
			if (!(layer instanceof L.TileLayer)) map.removeLayer(layer);
		});

		// dodaj nowe
		filteredEvents.forEach(event => {
			if (event.Latitude && event.Longitude) {
				L.marker([event.Latitude, event.Longitude])
					.addTo(map)
					.bindPopup(`<b>${event.Name}</b><br>${event.OrganizationName}`);
			}
		});
	}

	// --- Reaktywne odświeżanie mapy ---
	$: if (map && filteredEvents) {
		updateMarkers();
	}

	function handleRequestParticipation(eventId: any) {
		alert(`Request sent for event #${eventId}. (This is a demo)`);
	}
</script>

<div class="flex">
	<div class="grow">
		<main class="container mx-auto px-4 py-8 md:py-12">
			<header class="text-center mb-8 md:mb-12">
				<h1 class="text-4xl md:text-5xl font-bold text-gray-900">Nadchodzące Wolontariaty</h1>
				<p class="mt-2 text-lg text-gray-600">
					Znajdź i dołącz do wolontariatów wpływając pozytywnie na swoją lokalną społeczność
				</p>
			</header>

			<!-- FILTRY -->
			<div class="bg-white p-4 sm:p-6 rounded-xl red-shadow mb-8 sticky top-4 z-10">
				<div class="grid grid-cols-1 md:grid-cols-3 gap-4">
					<div class="md:col-span-2">
						<label for="search" class="block text-sm font-medium text-gray-700 mb-1">Wyszukaj Wydarzenia</label>
						<input
							type="search"
							id="search"
							bind:value={searchQuery}
							placeholder="Szukaj po nazwie, organizatorze, lub słowach kluczowych..."
							class="w-full pl-3 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-light outline-none transition"
						/>
					</div>
					<div>
						<label for="location" class="block text-sm font-medium text-gray-700 mb-1">Filtruj po Lokalizacji</label>
						<select
							id="location"
							bind:value={locationFilter}
							class="w-full py-2 px-3 border border-gray-300 bg-white rounded-lg focus:ring-2 focus:ring-red-light transition"
						>
							<option value="">Wszystkie Lokalizacje</option>
							{#each uniqueLocations as location}
								<option value={location}>{location}</option>
							{/each}
						</select>
					</div>
				</div>
			</div>

			<!-- MAPA -->
			<div class="bg-white rounded-xl shadow p-4 mb-8">
				<h2 class="text-lg font-semibold mb-2">Mapa wydarzeń</h2>
				<div
					bind:this={mapContainer}
					class="w-full h-[400px] rounded-lg border border-gray-300 overflow-hidden"
				></div>
			</div>

			<!-- LISTA WYDARZEŃ -->
			{#if isLoading}
				<p class="text-center text-gray-500">Ładowanie wydarzeń...</p>
			{:else if filteredEvents.length > 0}
				<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
					{#each filteredEvents as event (event.EventId)}
						<div class="bg-white rounded-xl shadow-lg overflow-hidden flex flex-col hover:scale-105 hover:shadow-xl transition">
							<div class="p-6 flex-grow">
								<p class="text-sm font-semibold text-blue-light">{event.OrganizationName}</p>
								<h2 class="text-2xl font-bold text-gray-900 mt-1">{event.Name}</h2>
								<p class="text-gray-700 mb-4 text-sm leading-relaxed">{event.Description}</p>
							</div>
							<div class="bg-gray-50 p-4">
								<button
									on:click={() => handleRequestParticipation(event.UserId)}
									class="w-full bg-gradient-to-r from-blue-light to-blue-dark text-white font-bold py-2 px-4 rounded-lg hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 transition"
								>
									Dołącz do wydarzenia
								</button>
							</div>
						</div>
					{/each}
				</div>
			{:else}
				<div class="text-center bg-white p-8 rounded-lg shadow-md">
					<h3 class="text-xl font-semibold text-gray-800">Nie znaleziono wydarzeń</h3>
					<p class="text-gray-500 mt-2">Spróbuj poprawić kryteria filtrowania.</p>
				</div>
			{/if}
		</main>
	</div>

	<!-- CHATBOT -->
	<div class="w-[200px]"><Chatbot/></div>
</div>
