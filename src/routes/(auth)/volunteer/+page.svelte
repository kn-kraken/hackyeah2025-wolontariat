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
	let map: L.Map;

	onMount(async () => {
    	const L = await import('leaflet'); // <- dynamiczny import
    	map = L.map(mapContainer).setView([50.0650,19.9350], 13);

    	L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        	attribution: '&copy; OpenStreetMap contributors'
    	}).addTo(map);

		map.invalidateSize();
	});

	$: filteredEvents = events.filter((event) => {
		const searchMatch =
			searchQuery.length < 2 ||
			event.Name.toLowerCase().includes(searchQuery.toLowerCase()) ||
			event.Description.toLowerCase().includes(searchQuery.toLowerCase()) ||
			event.OrganizationName.toLowerCase().includes(searchQuery.toLowerCase());

		const locationMatch =
			locationFilter === '' || event.Latitude.toString().toLowerCase().includes(locationFilter.toLowerCase());

		return searchMatch && locationMatch;
	});
	function handleRequestParticipation(eventId: any) {
		console.log(`Requesting to join event with ID: ${eventId}`);
		alert(`Request sent for event #${eventId}. (This is a demo)`);
	}

	$: uniqueLocations = [...new Set(allEvents.map((event) => event.Latitude))];
	async function initializeMap() {
		if (!map) {
			map = L.map(mapContainer).setView([52.237, 21.017], 6);

			L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
				attribution: '&copy; OpenStreetMap contributors'
			}).addTo(map);
		} else {
			map.eachLayer((layer) => {
				if (!(layer instanceof L.TileLayer)) map.removeLayer(layer);
			});
		}

		// Dodawanie markerów dla filteredEvents
		filteredEvents.forEach(event => {
			if (event.Latitude && event.Longitude) {
				L.marker([event.Latitude, event.Longitude])
					.addTo(map)
					.bindPopup(`<b>${event.Name}</b><br>${event.OrganizationName}`);
			}
		});
	}

	// Aktualizujemy markery za każdym razem, gdy zmienia się filteredEvents
	$: if (map && !isLoading) {
		initializeMap();
	}
</script>

<div class="flex">
	<div class="grow">
		<main class="container mx-auto px-4 py-8 md:py-12">
			<header class="text-center mb-8 md:mb-12">
				<h1 class="text-4xl md:text-5xl font-bold text-gray-900">Nadchodzące Wolontariaty</h1>
				<p class="mt-2 text-lg text-gray-600">Znajdź i dołącz do wolontariatów wplywając pozytywnie na swoją lokalną społeczność</p>
			</header>

			<div class="bg-white p-4 sm:p-6 rounded-xl red-shadow mb-8 sticky top-4 z-10">
				<div class="grid grid-cols-1 md:grid-cols-3 gap-4">
					<div class="md:col-span-2">
						<label for="search" class="block text-sm font-medium text-gray-700 mb-1">Wyszukaj Wydarzenia</label>
						<div class="relative">
							<div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
								<svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-gray-400" viewBox="0 0 20 20" fill="currentColor">
									<path fill-rule="evenodd" d="M8 4a4 4 0 100 8 4 4 0 000-8zM2 8a6 6 0 1110.89 3.476l4.817 4.817a1 1 0 01-1.414 1.414l-4.816-4.816A6 6 0 012 8z" clip-rule="evenodd" />
								</svg>
							</div>
							<input
								type="search"
								id="search"
								bind:value={searchQuery}
								placeholder="Szukaj po nazwie, organizatorze, lub slowach kluczowych..."
								class="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 outline-none focus:ring-red-light focus:border-red-light transition"
							/>
						</div>
					</div>
					<div>
						<label for="location" class="block text-sm font-medium text-gray-700 mb-1">Filtruj po Lokalizacji</label>
						<select
							id="location"
							bind:value={locationFilter}
							class="w-full py-2 px-3 border border-gray-300 bg-white rounded-lg focus:ring-2 focus:ring-red-light focus:border-red-light transition"
						>
							<option value="">Wszystkie Lokalizacje</option>
							{#each uniqueLocations as location}
								<option value={location}>{location}</option>
							{/each}
						</select>
					</div>
				</div>
			</div>

			<!-- Miejsce na mapę -->
			<div class="bg-white rounded-xl shadow p-4 mb-8">
				<h2 class="text-lg font-semibold mb-2">Mapa wydarzeń</h2>
				<div 
					bind:this={mapContainer} 
					class="w-full h-64 rounded-lg border border-gray-300 overflow-hidden"
				></div>
			</div>

			{#if isLoading}
				<p class="text-center text-gray-500">Ładowanie wydarzeń...</p>
			{:else if filteredEvents.length > 0}
				<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
					{#each filteredEvents as event (event.EventId)}
						<div class="bg-white rounded-xl shadow-lg overflow-hidden flex flex-col transition-transform duration-300 hover:scale-105 hover:shadow-xl">
							<div class="p-6 flex-grow">
								<div class="mb-4">
									<p class="text-sm font-semibold text-blue-light">{event.OrganizationName}</p>
									<h2 class="text-2xl font-bold text-gray-900 mt-1">{event.Name}</h2>
								</div>

								<div class="space-y-3 text-gray-600 mb-4">
									<div class="flex items-center">
										<svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2 text-gray-400" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M5.05 4.05a7 7 0 119.9 9.9L10 18.9l-4.95-4.95a7 7 0 010-9.9zM10 11a2 2 0 100-4 2 2 0 000 4z" clip-rule="evenodd" /></svg>
										<span>{event.Latitude}</span>
									</div>
									<div class="flex items-center">
										<svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2 text-gray-400" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-12a1 1 0 10-2 0v4a1 1 0 00.293.707l2.828 2.829a1 1 0 101.414-1.415L11 9.586V6z" clip-rule="evenodd" /></svg>
										<span>{event.StartTime} - {event.EndTime}</span>
									</div>
								</div>

								<p class="text-gray-700 mb-4 text-sm leading-relaxed">{event.Description}</p>

								<div>
									<h3 class="text-sm font-semibold text-gray-800 mb-2">Wymagania:</h3>
									<ul class="list-disc list-inside space-y-1 text-sm text-gray-600">
										{#each event.requirements as req}
											<li>{req}</li>
										{/each}
									</ul>
								</div>
							</div>

							<div class="bg-gray-50 p-4">
								<button
									on:click={() => handleRequestParticipation(event.UserId)}
									class="w-full bg-linear-to-r from-blue-light to-blue-dark text-white font-bold py-2 px-4 rounded-lg hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 transition-colors duration-300"
								>
									Dolacz do wydarzenia
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
	<div class="w-[200px]"><Chatbot/></div>
</div>
