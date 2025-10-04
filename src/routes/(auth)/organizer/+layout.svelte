<script lang="ts">
	import Link from '$lib/Link.svelte';

	let { children } = $props();
</script>

<div class="flex flex-col bg-gray-50 min-h-screen font-sans text-gray-800">
	<nav class="flex bg-neutral-200 border-b border-neutral-400">
		<Link href="/organizer">Panel Glowny</Link>
		<Link href="/organizer/chat">Wiadomosci</Link>
	</nav>
  {@render children?.()}
</div>
