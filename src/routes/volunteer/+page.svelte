<script lang="ts">
	import { onMount } from 'svelte';

	// --- MOCK DATA ---
	// In a real app, you would fetch this from an API.
	let allEvents = [
		{
			id: 1,
			title: 'Community Garden Cleanup',
			organizer: 'Green Thumbs Society',
			location: 'City Park, Downtown',
			duration: '4 hours',
			description:
				'Help us weed, plant, and beautify our beloved community garden. A great way to get your hands dirty and meet fellow nature lovers.',
			requirements: ['Age 16+', 'Gardening gloves recommended']
		},
		{
			id: 2,
			title: 'Local Animal Shelter Support',
			organizer: 'Paws & Friends',
			location: '123 Animal Lane',
			duration: '3 hours',
			description:
				'Assist with walking dogs, cleaning enclosures, and socializing with cats. Your help provides essential care for animals awaiting their forever homes.',
			requirements: ['Comfortable with animals', 'Age 18+']
		},
		{
			id: 3,
			title: 'Annual Charity Marathon',
			organizer: 'Run for Hope Foundation',
			location: 'Waterfront Path',
			duration: '6 hours (flexible shifts)',
			description:
				'We need volunteers to manage water stations, guide runners, and help with setup/teardown for our biggest fundraising event of the year.',
			requirements: ['Energetic attitude', 'First-Aid/CPR certification a plus']
		},
		{
			id: 4,
			title: 'Tech Workshop for Seniors',
			organizer: 'Digital Bridge Inc.',
			location: 'Community Center',
			duration: '2 hours',
			description:
				'Help seniors learn basic computer and smartphone skills. Patience and good communication are key to empowering our elderly community.',
			requirements: ['Proficient with smartphones/computers', 'Excellent communication skills']
		},
		{
			id: 5,
			title: 'Soup Kitchen Service',
			organizer: 'The Helping Hand',
			location: 'St. James Church Basement',
			duration: '3 hours',
			description:
				'Prepare and serve warm meals to those in need. A humbling and rewarding experience that directly impacts the community.',
			requirements: ['Food handler\'s permit preferred', 'Ability to stand for long periods']
		},
		{
			id: 6,
			title: 'Book Drive Sorting',
			organizer: 'Literacy for All',
			location: 'Public Library Warehouse',
			duration: 'Flexible',
			description:
				'Sort through donated books to help us organize them for distribution to schools and community centers. A quiet and impactful role.',
			requirements: ['Attention to detail']
		}
	];

	// --- STATE ---
	let isLoading = true;
	let events: any[] = [];
	let searchQuery = '';
	let locationFilter = '';

	// --- LIFECYCLE ---
	onMount(() => {
		// Simulate fetching data from an API
		setTimeout(() => {
			events = allEvents;
			isLoading = false;
		}, 800);
	});

	// --- REACTIVE LOGIC ---
	// This will re-run whenever the dependencies (events, searchQuery, locationFilter) change.
	$: filteredEvents = events.filter((event) => {
		const searchMatch =
			searchQuery.length < 2 || // Show all if search is short
			event.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
			event.description.toLowerCase().includes(searchQuery.toLowerCase()) ||
			event.organizer.toLowerCase().includes(searchQuery.toLowerCase());

		const locationMatch =
			locationFilter === '' || event.location.toLowerCase().includes(locationFilter.toLowerCase());

		return searchMatch && locationMatch;
	});

	// --- ACTIONS ---
	// These functions would contain logic to interact with your backend/API.
	function handleRequestParticipation(eventId: any) {
		console.log(`Requesting to join event with ID: ${eventId}`);
		// Example:
		// await fetch(`/api/events/${eventId}/request`, { method: 'POST' });
		// alert('Your request has been sent!');
		alert(`Request sent for event #${eventId}. (This is a demo)`);
	}

	// Helper to get unique locations for the filter dropdown
	$: uniqueLocations = [...new Set(allEvents.map((event) => event.location))];
</script>

<div class="bg-gray-50 min-h-screen font-sans text-gray-800">
	<nav>
		<a href="/volunteer">Wydarzenia</a>
		<a href="/volunteer/chat">Wydarzenia</a>
	</nav>
	<main class="container mx-auto px-4 py-8 md:py-12">
		<header class="text-center mb-8 md:mb-12">
			<h1 class="text-4xl md:text-5xl font-bold text-gray-900">Volunteer Opportunities</h1>
			<p class="mt-2 text-lg text-gray-600">Find and join events to make a difference in your community.</p>
		</header>

		<div class="bg-white p-4 sm:p-6 rounded-xl shadow-md mb-8 sticky top-4 z-10">
			<div class="grid grid-cols-1 md:grid-cols-3 gap-4">
				<div class="md:col-span-2">
					<label for="search" class="block text-sm font-medium text-gray-700 mb-1">Search Events</label>
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
							placeholder="Search by title, organizer, or keyword..."
							class="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition"
						/>
					</div>
				</div>
				<div>
					<label for="location" class="block text-sm font-medium text-gray-700 mb-1">Filter by Location</label>
					<select
						id="location"
						bind:value={locationFilter}
						class="w-full py-2 px-3 border border-gray-300 bg-white rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition"
					>
						<option value="">All Locations</option>
						{#each uniqueLocations as location}
							<option value={location}>{location}</option>
						{/each}
					</select>
				</div>
			</div>
		</div>

		{#if isLoading}
			<p class="text-center text-gray-500">Loading events...</p>
		{:else if filteredEvents.length > 0}
			<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
				{#each filteredEvents as event (event.id)}
					<div class="bg-white rounded-xl shadow-lg overflow-hidden flex flex-col transition-transform duration-300 hover:scale-105 hover:shadow-xl">
						<div class="p-6 flex-grow">
							<div class="mb-4">
								<p class="text-sm font-semibold text-blue-600">{event.organizer}</p>
								<h2 class="text-2xl font-bold text-gray-900 mt-1">{event.title}</h2>
							</div>

							<div class="space-y-3 text-gray-600 mb-4">
								<div class="flex items-center">
									<svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2 text-gray-400" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M5.05 4.05a7 7 0 119.9 9.9L10 18.9l-4.95-4.95a7 7 0 010-9.9zM10 11a2 2 0 100-4 2 2 0 000 4z" clip-rule="evenodd" /></svg>
									<span>{event.location}</span>
								</div>
								<div class="flex items-center">
									<svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2 text-gray-400" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-12a1 1 0 10-2 0v4a1 1 0 00.293.707l2.828 2.829a1 1 0 101.414-1.415L11 9.586V6z" clip-rule="evenodd" /></svg>
									<span>{event.duration}</span>
								</div>
							</div>

							<p class="text-gray-700 mb-4 text-sm leading-relaxed">{event.description}</p>

							<div>
								<h3 class="text-sm font-semibold text-gray-800 mb-2">Requirements:</h3>
								<ul class="list-disc list-inside space-y-1 text-sm text-gray-600">
									{#each event.requirements as req}
										<li>{req}</li>
									{/each}
								</ul>
							</div>
						</div>

						<div class="bg-gray-50 p-4">
							<button
								on:click={() => handleRequestParticipation(event.id)}
								class="w-full bg-blue-600 text-white font-bold py-2 px-4 rounded-lg hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition-colors duration-300"
							>
								Request to Join
							</button>
						</div>
					</div>
				{/each}
			</div>
		{:else}
			<div class="text-center bg-white p-8 rounded-lg shadow-md">
				<h3 class="text-xl font-semibold text-gray-800">No Events Found</h3>
				<p class="text-gray-500 mt-2">Try adjusting your search or filter criteria.</p>
			</div>
		{/if}
	</main>
</div>
