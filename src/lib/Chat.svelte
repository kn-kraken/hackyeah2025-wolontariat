<script>
	import { onMount } from 'svelte';

	// --- MOCK DATA ---
	// In a real app, this would come from an API.
	let conversations = [
		{
			id: 1,
			participantName: 'Alice Johnson',
			avatarUrl: 'https://i.pravatar.cc/150?u=alice',
			eventName: 'Annual Charity Marathon',
			lastMessage: "Hi! I'd love to help out at the marathon. Do you still need people for...",
			timestamp: '2 hours ago',
			unreadCount: 1,
			messages: [
				{ id: 101, sender: 'participant', text: 'Hi there!', timestamp: 'Yesterday' },
				{
					id: 102,
					sender: 'participant',
					text: "Hi! I'd love to help out at the marathon. Do you still need people for the morning shift at the water stations?",
					timestamp: '2 hours ago'
				}
			]
		},
		{
			id: 2,
			participantName: 'Ben Carter',
			avatarUrl: 'https://i.pravatar.cc/150?u=ben',
			eventName: 'Tech Workshop for Seniors',
			lastMessage: 'Perfect, thank you for the confirmation!',
			timestamp: '1 day ago',
			unreadCount: 0,
			messages: [
				{
					id: 201,
					sender: 'participant',
					text: 'I have experience in IT support and would be a great fit for the tech workshop.',
					timestamp: '2 days ago'
				},
				{
					id: 202,
					sender: 'me',
					text: 'That sounds great, Ben. We would be happy to have you. Please confirm your availability for next Saturday.',
					timestamp: '1 day ago'
				},
				{ id: 203, sender: 'participant', text: 'Perfect, thank you for the confirmation!', timestamp: '1 day ago' }
			]
		},
		{
			id: 3,
			participantName: 'Clara Davis',
			avatarUrl: 'https://i.pravatar.cc/150?u=clara',
			eventName: 'Annual Charity Marathon',
			lastMessage: 'Is there a place to store personal belongings securely during the event?',
			timestamp: '3 days ago',
			unreadCount: 3,
			messages: [
				{ id: 301, sender: 'participant', text: 'Is there a place to store personal belongings securely during the event?', timestamp: '3 days ago' },
                { id: 302, sender: 'participant', text: 'Just following up on my question.', timestamp: '1 day ago' },
                { id: 303, sender: 'participant', text: 'Any updates?', timestamp: '4 hours ago' }
			]
		}
	];

	// --- STATE ---
	let selectedConversationId = 1;
	let newMessageText = '';
	let chatContainer;

	// This state helps manage the view on small screens
	let mobileView = 'list'; // can be 'list' or 'chat'

	// --- REACTIVE DERIVED STATE ---
	// This automatically finds the correct conversation object when the ID changes.
	$: selectedConversation = conversations.find((c) => c.id === selectedConversationId);

	// --- FUNCTIONS ---
	function selectConversation(id) {
		selectedConversationId = id;
		mobileView = 'chat'; // Switch to chat view on mobile
		// Mark messages as read
		const conv = conversations.find(c => c.id === id);
		if (conv) conv.unreadCount = 0;
	}

	function handleSendMessage() {
		if (newMessageText.trim() === '' || !selectedConversation) return;

		const newMessage = {
			id: Date.now(),
			sender: 'me',
			text: newMessageText,
			timestamp: 'Just now'
		};

		// Add the message to the conversation
		selectedConversation.messages.push(newMessage);
		selectedConversation.messages = selectedConversation.messages; // Svelte reactivity trigger
		
		newMessageText = '';

		// Scroll to the bottom of the chat
		scrollToBottom();
	}

	function backToList() {
		mobileView = 'list';
	}
	
	function scrollToBottom() {
		// Use setTimeout to allow the DOM to update before scrolling
		setTimeout(() => {
			if (chatContainer) {
				chatContainer.scrollTop = chatContainer.scrollHeight;
			}
		}, 0);
	}

	// Scroll to bottom when a conversation is selected
	$: if (selectedConversationId && chatContainer) {
		scrollToBottom();
	}
</script>

	<div class="grow w-full flex items-strech overflow-hidden font-sans antialiased bg-gray-100 text-gray-800">
		<aside
			class="w-full md:w-1/3 lg:w-1/4 bg-white border-r border-gray-200 flex flex-col transition-transform duration-300"
			class:translate-x-0={mobileView === 'list'}
			class:-translate-x-full={mobileView === 'chat'}
			class:md:translate-x-0={true}
		>
			<div class="p-4 border-b border-gray-200 flex-shrink-0">
				<h1 class="text-xl font-bold">Conversations</h1>
			</div>

			<div class="flex-grow overflow-y-auto">
				{#each conversations as conv (conv.id)}
					<button
						on:click={() => selectConversation(conv.id)}
						class="w-full text-left p-4 flex items-center gap-4 hover:bg-gray-50 focus:outline-none focus:bg-blue-50 transition-colors"
						class:bg-blue-50={selectedConversationId === conv.id}
					>
						<img src={conv.avatarUrl} alt={conv.participantName} class="w-12 h-12 rounded-full flex-shrink-0" />
						<div class="flex-grow overflow-hidden">
							<div class="flex justify-between items-center">
								<p class="font-semibold truncate text-gray-900">{conv.participantName}</p>
								<p class="text-xs text-gray-500 flex-shrink-0 ml-2">{conv.timestamp}</p>
							</div>
							<p class="text-sm text-gray-600 truncate">{conv.eventName}</p>
							<div class="flex justify-between items-end mt-1">
								<p class="text-sm text-gray-500 truncate">{conv.lastMessage}</p>
								{#if conv.unreadCount > 0}
									<span class="bg-blue-600 text-white text-xs font-bold rounded-full h-5 w-5 flex items-center justify-center">
										{conv.unreadCount}
									</span>
								{/if}
							</div>
						</div>
					</button>
				{/each}
			</div>
		</aside>

		<main
			class="absolute top-0 left-0 w-full md:static bg-gray-50 flex flex-col transition-transform duration-300"
			class:translate-x-0={mobileView === 'chat'}
			class:translate-x-full={mobileView === 'list'}
			class:md:translate-x-0={true}
		>
			{#if selectedConversation}
				<header class="bg-white border-b border-gray-200 p-4 flex items-center flex-shrink-0">
					<button on:click={backToList} class="md:hidden mr-4 p-1 text-gray-600 hover:text-gray-900">
						<svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
						</svg>
					</button>
					<img src={selectedConversation.avatarUrl} alt={selectedConversation.participantName} class="w-10 h-10 rounded-full mr-3" />
					<div>
						<h2 class="text-lg font-bold text-gray-900">{selectedConversation.participantName}</h2>
						<p class="text-sm text-gray-500">RE: {selectedConversation.eventName}</p>
					</div>
				</header>

				<div bind:this={chatContainer} class="flex-grow p-4 md:p-6 overflow-y-auto">
					<div class="space-y-4">
						{#each selectedConversation.messages as msg (msg.id)}
							<div class="flex" class:justify-end={msg.sender === 'me'} class:justify-start={msg.sender === 'participant'}>
								<div
									class="max-w-md lg:max-w-lg px-4 py-2 rounded-xl"
									class:bg-blue-600={msg.sender === 'me'}
									class:text-white={msg.sender === 'me'}
									class:bg-gray-200={msg.sender === 'participant'}
									class:text-gray-800={msg.sender === 'participant'}
								>
									<p>{msg.text}</p>
									<p class="text-xs mt-1" class:text-blue-200={msg.sender === 'me'} class:text-gray-500={msg.sender === 'participant'}>
										{msg.timestamp}
									</p>
								</div>
							</div>
						{/each}
					</div>
				</div>

				<div class="bg-white border-t border-gray-200 p-4 flex-shrink-0">
					<form on:submit|preventDefault={handleSendMessage} class="flex items-center gap-3">
						<input
							type="text"
							bind:value={newMessageText}
							placeholder="Type your message..."
							class="w-full py-2 px-4 border border-gray-300 rounded-full focus:outline-none focus:ring-2 focus:ring-blue-500 transition"
						/>
						<button
							type="submit"
							class="bg-blue-600 hover:bg-blue-700 text-white rounded-full p-3 flex-shrink-0 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition-colors"
						>
							<svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" viewBox="0 0 20 20" fill="currentColor">
								<path d="M10.894 2.553a1 1 0 00-1.788 0l-7 14a1 1 0 001.169 1.409l5-1.428A1 1 0 009.05 16.57l4.122-4.122a1 1 0 000-1.414l-4.122-4.122a1 1 0 00-1.052-.092l-5 1.428a1 1 0 00-1.17 1.408l7 14a1 1 0 001.788 0l7-14a1 1 0 00-1.169-1.409l-5 1.428A1 1 0 0010.945 4.43l-4.122 4.122a1 1 0 000 1.414l4.122 4.122a1 1 0 001.052.092l5-1.428a1 1 0 001.17-1.408l-7-14z" />
							</svg>
						</button>
					</form>
				</div>
			{:else}
				<div class="h-full flex items-center justify-center text-gray-500">
					<p>Select a conversation to start chatting.</p>
				</div>
			{/if}
		</main>
	</div>
