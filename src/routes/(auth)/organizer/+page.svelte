<script>
	// --- MOCK DATA ---
	// In a real application, this data would be fetched from your backend API.
	export let data;

	let upcomingEvents = data.upcomingEvents;

	let messages = data.unreadMessages;

	// --- FORM STATE ---
	let newEvent = {
		title: '',
		location: '',
		duration: '',
		description: '',
		requirements: ''
	};

	// --- ACTIONS ---
	// Placeholder functions for form submissions and button clicks.
	// In a real app, these would make API calls.
	async function handleRegisterEvent() {
		console.log('Registering new event:', newEvent);
		// Example API call:
		// const response = await fetch('/api/events', { method: 'POST', body: JSON.stringify(newEvent) });
		alert('New event registered successfully! (This is a demo)');
		// Clear form after submission
		newEvent = { title: '', location: '', duration: '', description: '', requirements: '' };
	}

	function handleEditEvent(eventId) {
		alert(`Editing event #${eventId}. (This is a demo)`);
	}

	function handleViewApplicants(eventId) {
		alert(`Viewing applicants for event #${eventId}. (This is a demo)`);
	}
</script>

<div class="bg-gray-100 min-h-screen font-sans text-gray-800">
	<main class="container mx-auto px-4 py-8 md:py-12">
		<header class="mb-8 md:mb-12">
			<h1 class="text-4xl md:text-5xl font-bold text-gray-900">Organizer Dashboard</h1>
			<p class="mt-2 text-lg text-gray-600">Manage your events and connect with volunteers.</p>
		</header>

		<section class="mb-12 bg-white p-6 md:p-8 rounded-xl shadow-lg">
			<h2 class="text-2xl font-bold text-gray-900 mb-6 flex items-center">
				<svg xmlns="http://www.w3.org/2000/svg" class="h-7 w-7 mr-2 text-blue-600" viewBox="0 0 20 20" fill="currentColor">
					<path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-11a1 1 0 10-2 0v2H7a1 1 0 100 2h2v2a1 1 0 102 0v-2h2a1 1 0 100-2h-2V7z" clip-rule="evenodd"/>
				</svg>
				Register a New Event
			</h2>
			<form on:submit|preventDefault={handleRegisterEvent} class="grid grid-cols-1 md:grid-cols-2 gap-6">
				<div class="md:col-span-2">
					<label for="title" class="block text-sm font-medium text-gray-700">Event Title</label>
					<input type="text" id="title" bind:value={newEvent.title} required class="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 focus:ring-blue-500 focus:border-blue-500"/>
				</div>
				<div>
					<label for="location" class="block text-sm font-medium text-gray-700">Location</label>
					<input type="text" id="location" bind:value={newEvent.location} required class="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 focus:ring-blue-500 focus:border-blue-500"/>
				</div>
				<div>
					<label for="duration" class="block text-sm font-medium text-gray-700">Duration (e.g., 4 hours)</label>
					<input type="text" id="duration" bind:value={newEvent.duration} required class="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 focus:ring-blue-500 focus:border-blue-500"/>
				</div>
				<div class="md:col-span-2">
					<label for="description" class="block text-sm font-medium text-gray-700">Description</label>
					<textarea id="description" rows="4" bind:value={newEvent.description} required class="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 focus:ring-blue-500 focus:border-blue-500"></textarea>
				</div>
				<div class="md:col-span-2">
					<label for="requirements" class="block text-sm font-medium text-gray-700">Requirements (comma-separated)</label>
					<input type="text" id="requirements" bind:value={newEvent.requirements} placeholder="e.g., Age 18+, First-Aid certified" required class="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 focus:ring-blue-500 focus:border-blue-500"/>
				</div>
				<div class="md:col-span-2 text-right">
					<button type="submit" class="inline-flex justify-center py-2 px-6 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition-colors">
						Create Event
					</button>
				</div>
			</form>
		</section>

		<div class="grid grid-cols-1 lg:grid-cols-3 lg:gap-12 gap-8">
			<section class="lg:col-span-2">
				<h2 class="text-2xl font-bold text-gray-900 mb-4">Your Upcoming Events</h2>
				<div class="space-y-4">
					{#if upcomingEvents.length > 0}
						{#each upcomingEvents as event (event.id)}
							<div class="bg-white rounded-lg shadow-md p-4 flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
								<div class="flex-grow">
									<p class="text-sm text-gray-500">{new Date(event.date).toLocaleDateString('en-US', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })}</p>
									<h3 class="text-xl font-semibold text-gray-800">{event.title}</h3>
									<p class="text-sm text-gray-600">{event.location}</p>
									<div class="mt-2">
										<span class="text-sm font-medium text-blue-800 bg-blue-100 rounded-full px-3 py-1">
											{event.participants} / {event.capacity} participants
										</span>
									</div>
								</div>
								<div class="flex-shrink-0 flex sm:flex-col justify-start gap-2">
									<button on:click={() => handleViewApplicants(event.id)} class="text-sm bg-gray-200 hover:bg-gray-300 text-gray-800 font-semibold py-2 px-4 rounded-lg transition-colors">Applicants</button>
									<button on:click={() => handleEditEvent(event.id)} class="text-sm bg-gray-200 hover:bg-gray-300 text-gray-800 font-semibold py-2 px-4 rounded-lg transition-colors">Edit</button>
								</div>
							</div>
						{/each}
					{:else}
						<p class="text-gray-500 bg-white p-4 rounded-lg shadow-md">You have no upcoming events.</p>
					{/if}
				</div>
			</section>

			<section>
				<h2 class="text-2xl font-bold text-gray-900 mb-4">Recent Messages</h2>
				<div class="space-y-4">
					{#if messages.length > 0}
						{#each messages as msg (msg.id)}
							<div class="bg-white rounded-lg shadow-md p-4">
								<div class="flex justify-between items-start">
									<div>
										<p class="font-bold text-gray-800">{msg.senderName}</p>
										<p class="text-xs text-blue-600 font-semibold">{msg.eventName}</p>
									</div>
									<p class="text-xs text-gray-500 flex-shrink-0 ml-2">{msg.timestamp}</p>
								</div>
								<p class="text-gray-700 mt-2 text-sm">{msg.message}</p>
								<button class="text-sm font-semibold text-blue-600 hover:text-blue-800 mt-3">Reply</button>
							</div>
						{/each}
					{:else}
						<p class="text-gray-500 bg-white p-4 rounded-lg shadow-md">You have no new messages.</p>
					{/if}
				</div>
			</section>
		</div>
	</main>
</div>
