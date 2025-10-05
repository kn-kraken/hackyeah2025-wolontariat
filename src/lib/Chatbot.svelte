<script>
	let messages = [];
	let inputValue = '';
  let isLoading = false;

	async function sendMessage() {
		if (inputValue.trim() && !isLoading) {
			const userMessage = inputValue;
			
			// Add user message
			messages = [...messages, { text: userMessage, sender: 'user' }];
			inputValue = '';
			isLoading = true;

			try {
				const response = await fetch('/api/chat', {
					method: 'POST',
					headers: {
						'Content-Type': 'application/json',
					},
					body: JSON.stringify({ 
						message: userMessage,
						history: messages.slice(-10)
					})
				});

				const data = await response.json();
				
				if (data.error) {
					messages = [...messages, { 
						text: "Przepraszam, wystąpił błąd. Spróbuj ponownie.", 
						sender: 'bot' 
					}];
				} else {
					messages = [...messages, { 
						text: data.response, 
						sender: 'bot' 
					}];
				}
			} catch (error) {
				messages = [...messages, { 
					text: "Przepraszam, wystąpił błąd połączenia.", 
					sender: 'bot' 
				}];
			} finally {
				isLoading = false;
			}
		}
	}

	function handleKeydown(event) {
		if (event.key === 'Enter') {
			sendMessage();
		}
	}
	let open = false;
</script>

<div class="chatbot-container h-full {open ? 'w-[500px]' : 'w-[40px]'} z-30">
	<div class="bg-gray-100 p-3 text-xl border-b border-gray-400" on:click={() => open = !open}>{open ? '>' : '<'}</div>
	{#if open}
	<div class="messages-container">
		{#each messages as message}
			<div class="message {message.sender}">
				<span class="message-text">{message.text}</span>
			</div>
		{/each}
	</div>
	
	<div class="input-container">
		<input 
			bind:value={inputValue}
			on:keydown={handleKeydown}
			placeholder="Type your message..."
			class="message-input"
		/>
		<button on:click={sendMessage} class="send-button">Send</button>
	</div>
	{/if}
</div>

<style>
	.chatbot-container {
		border: 1px solid #ddd;
		display: flex;
		flex-direction: column;
		background: white;
	}

	.messages-container {
		flex: 1;
		overflow-y: auto;
		padding: 16px;
		display: flex;
		flex-direction: column;
		gap: 12px;
	}

	.message {
		display: flex;
		max-width: 80%;
	}

	.message.user {
		align-self: flex-end;
	}

	.message.bot {
		align-self: flex-start;
	}

	.message-text {
		padding: 8px 12px;
		border-radius: 16px;
		word-wrap: break-word;
	}

	.user .message-text {
		background: var(--colors-blue-dark);
		color: white;
	}

	.bot .message-text {
		background: #f1f1f1;
		color: black;
	}

	.input-container {
		display: flex;
		padding: 16px;
		border-top: 1px solid #eee;
		gap: 8px;
	}

	.message-input {
		flex: 1;
		padding: 8px 12px;
		border: 1px solid #ddd;
		border-radius: 20px;
		outline: none;
	}

	.message-input:focus {
		border-color: var(--color-blue-dark);
	}

	.send-button {
		padding: 8px 16px;
		background: var(--color-blue-dark);
		color: white;
		border: none;
		border-radius: 20px;
		cursor: pointer;
	}
</style>
