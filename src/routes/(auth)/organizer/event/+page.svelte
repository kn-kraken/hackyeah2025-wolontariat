<script lang="ts">
	import ReviewModal from '$lib/ReviewModal.svelte';
import { onMount } from 'svelte';

	// --- MOCK DATA ---
	// In a real app, you would fetch this event data based on the page's ID parameter.
	let event = {
		id: 1,
		title: 'Coroczny Maraton Fundacji',
		date: '2025-10-25',
		location: 'Tauron Arena',
		status: 'upcoming', // 'upcoming', 'active', 'finished'
		pendingParticipants: [
			{
				id: 101,
				name: 'David Lee',
				avatarUrl: 'https://i.pravatar.cc/150?u=david',
				skills: ['Logistyka', 'Komunikacja']
			},
			{
				id: 102,
				name: 'Sophia Chen',
				avatarUrl: 'https://i.pravatar.cc/150?u=sophia',
				skills: ['Certyfikat Pierwszej Pomocy', ]
			}
		],
		acceptedParticipants: [
			{
				id: 201,
				name: 'Michael Brown',
				avatarUrl: 'https://i.pravatar.cc/150?u=michael',
				status: 'confirmed' // 'confirmed', 'checked-in', 'checked-out'
			},
			{
				id: 202,
				name: 'Emily White',
				avatarUrl: 'https://i.pravatar.cc/150?u=emily',
				status: 'confirmed'
			}
		]
	};
	
	let isLoading = true;
	onMount(() => {
	    // Simulate API fetch delay
	    setTimeout(() => isLoading = false, 500);
	});

	// --- HELPER FUNCTIONS ---
	function getStatusClasses(status) {
		switch (status) {
			case 'active':
			case 'checked-in':
				return 'bg-green-100 text-green-800';
			case 'finished':
			case 'checked-out':
				return 'bg-gray-200 text-gray-700';
			case 'upcoming':
			case 'confirmed':
				return 'bg-blue-100 text-blue-800';
			default:
				return 'bg-gray-100 text-gray-800';
		}
	}
	function getStatusText(status) {
		switch (status) {
			case 'active':
				return 'zaakceptowany'
			case 'checked-in':
				return 'dolaczono';
			case 'finished':
				return 'zakonczono'
			case 'checked-out':
				return 'zakonczono';
			case 'upcoming':
			case 'confirmed':
				return 'zaakceptowany'
			default:
				return 'zaakceptowany'
		}
	}

	// --- ACTION HANDLERS ---
	// These functions manipulate the local 'event' object to simulate backend actions.
	function startEvent() {
		event.status = 'active';
	}

	function endEvent() {
		event.status = 'finished';
	}

	function acceptParticipant(participantId) {
		const participantIndex = event.pendingParticipants.findIndex((p) => p.id === participantId);
		if (participantIndex === -1) return;

		// Remove from pending and get the participant object
		const [participant] = event.pendingParticipants.splice(participantIndex, 1);
		
		// Add to accepted with 'confirmed' status
		participant.status = 'confirmed';
		event.acceptedParticipants.push(participant);

		// Trigger Svelte's reactivity
		event.pendingParticipants = event.pendingParticipants;
		event.acceptedParticipants = event.acceptedParticipants;
	}

	function rejectParticipant(participantId) {
		event.pendingParticipants = event.pendingParticipants.filter((p) => p.id !== participantId);
	}

	function checkInParticipant(participantId) {
		const participant = event.acceptedParticipants.find((p) => p.id === participantId);
		if (participant) {
			participant.status = 'checked-in';
			event.acceptedParticipants = event.acceptedParticipants; // Trigger reactivity
		}
	}

	function reviewParticipant(participantId) {
		const participant = event.acceptedParticipants.find((p) => p.id === participantId);
		if (participant) {
			reviewedVolunteer = {name: participant.name, id: participant.id};
			isReviewModalVisible = true;
			// participant.status = 'checked-out';
			// event.acceptedParticipants = event.acceptedParticipants; // Trigger reactivity
		}
	}

	function checkOutParticipant(participantId) {
		const participant = event.acceptedParticipants.find((p) => p.id === participantId);
		if (participant) {
			participant.status = 'checked-out';
			event.acceptedParticipants = event.acceptedParticipants; // Trigger reactivity
		}
	}

	let reviewedVolunteer = {name: "", id: 0};
	let isReviewModalVisible = false;
</script>

<div class="bg-gray-50 min-h-screen font-sans">
  <ReviewModal
    bind:isVisible={isReviewModalVisible}
    volunteerName={reviewedVolunteer.name}
    on:submitReview={(event) => {console.log(event.detail); checkOutParticipant(reviewedVolunteer.id)}}
  />
	<main class="container mx-auto px-4 py-8 md:py-12">
		{#if isLoading}
			<div class="text-center text-gray-500">Ładowanie szczegółów...</div>
		{:else}
			<section class="bg-white p-6 rounded-xl shadow-md mb-8">
				<div class="flex flex-col md:flex-row md:items-center md:justify-between">
					<div>
						<div class="flex items-center gap-3">
							<h1 class="text-3xl md:text-4xl font-bold text-gray-900">{event.title}</h1>
						</div>
						<p class="mt-2 text-lg text-gray-600">
							{new Date(event.date).toLocaleDateString('en-US', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })} &bull; {event.location}
						</p>
					</div>
					<div class="mt-4 md:mt-0 flex-shrink-0">
						{#if event.status === 'upcoming'}
							<button on:click={startEvent} class="w-full md:w-auto bg-green-600 text-white font-bold py-2 px-6 rounded-lg hover:bg-green-700 transition-colors flex items-center justify-center gap-2">
								<svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM9.555 7.168A1 1 0 008 8v4a1 1 0 001.555.832l3-2a1 1 0 000-1.664l-3-2z" clip-rule="evenodd" /></svg>
								Rozpocznij Wydarzenie
							</button>
						{:else if event.status === 'active'}
							<button on:click={endEvent} class="w-full md:w-auto bg-red-600 text-white font-bold py-2 px-6 rounded-lg hover:bg-red-700 transition-colors flex items-center justify-center gap-2">
								<svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8 7a1 1 0 00-1 1v4a1 1 0 001 1h4a1 1 0 001-1V8a1 1 0 00-1-1H8z" clip-rule="evenodd" /></svg>
								Zakończ Wydarzenie
							</button>
						{/if}
					</div>
				</div>
			</section>

			<div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
				<section>
					<h2 class="text-2xl font-bold text-gray-800 mb-4">Oczekujące zapytania ({event.pendingParticipants.length})</h2>
					<div class="space-y-4">
						{#each event.pendingParticipants as person (person.id)}
							<div class="bg-white rounded-lg shadow-md p-4 transition-all hover:shadow-lg">
								<div class="flex items-center justify-between">
									<div class="flex items-center gap-4">
										<img src={person.avatarUrl} alt={person.name} class="w-12 h-12 rounded-full" />
										<div>
											<p class="font-bold text-lg text-gray-900">{person.name}</p>
											<div class="flex gap-2 mt-1">
												{#each person.skills as skill}
													<span class="text-xs font-medium bg-gray-100 text-gray-600 px-2 py-0.5 rounded-full">{skill}</span>
												{/each}
											</div>
										</div>
									</div>
									<div class="flex gap-2">
										<button on:click={() => rejectParticipant(person.id)} class="p-2 rounded-full text-gray-500 hover:bg-red-100 hover:text-red-600 transition-colors">
											<svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd" /></svg>
										</button>
										<button on:click={() => acceptParticipant(person.id)} class="p-2 rounded-full text-gray-500 hover:bg-green-100 hover:text-green-600 transition-colors">
											<svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd" /></svg>
										</button>
									</div>
								</div>
							</div>
						{:else}
							<p class="text-gray-500 bg-white p-4 rounded-lg text-center">Brak oczekujacych zapytań.</p>
						{/each}
					</div>
				</section>

				<section>
					<h2 class="text-2xl font-bold text-gray-800 mb-4">Zaakceptowani Uczestnicy ({event.acceptedParticipants.length})</h2>
					<div class="space-y-4">
						{#each event.acceptedParticipants as person (person.id)}
							<div class="bg-white rounded-lg shadow-md p-4">
								<div class="flex items-center justify-between">
									<div class="flex items-center gap-4">
										<img src={person.avatarUrl} alt={person.name} class="w-12 h-12 rounded-full" />
										<div>
											<p class="font-bold text-lg text-gray-900">{person.name}</p>
											<span class="text-xs font-medium capitalize px-2 py-0.5 rounded-full {getStatusClasses(person.status)}">{getStatusText(person.status)}</span>
										</div>
									</div>
									<div class="flex-shrink-0">
										{#if person.status === 'confirmed'}
											<button on:click={() => checkInParticipant(person.id)} class="bg-blue-500 text-white font-semibold py-1 px-4 rounded-lg hover:bg-blue-600 text-sm transition-colors">Zamelduj się</button>
										{:else if person.status === 'checked-in'}
											<button on:click={() => reviewParticipant(person.id)} class="bg-yellow-500 text-white font-semibold py-1 px-4 rounded-lg hover:bg-yellow-600 text-sm transition-colors">Wymelduj się</button>
										{:else}
											<span class="text-gray-500 text-sm font-semibold">Ukończone</span>
										{/if}
									</div>
								</div>
							</div>
						{:else}
							<p class="text-gray-500 bg-white p-4 rounded-lg text-center">Brak zaakceptowanych uczestników.</p>
						{/each}
					</div>
				</section>
			</div>
		{/if}
	</main>
</div>
