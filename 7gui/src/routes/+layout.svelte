<script lang="ts">
	import '../app.css';
	import { page } from '$app/stores';
	import { goto } from '$app/navigation';

	let { children } = $props();

	// Define all 7GUIs challenges
	const challenges = [
		{ path: '/', name: 'Home', icon: '🏠' },
		{ path: '/counter', name: 'Counter', icon: '🔢' },
		{ path: '/temperature_converter', name: 'Temperature Converter', icon: '🌡️' },
		{ path: '/flight_booker', name: 'Flight Booker', icon: '✈️' },
		{ path: '/timer', name: 'Timer', icon: '⏱️' },
		{ path: '/crud', name: 'CRUD', icon: '📝' },
		{ path: '/circle_draw', name: 'Circle Drawer', icon: '⭕' },
		{ path: '/cells', name: 'Cells', icon: '📊' }
	];

	// Get current page index
	let currentIndex = $state(0);
	let isHomePage = $state(true);
	
	$effect(() => {
		currentIndex = challenges.findIndex(c => c.path === $page.url.pathname);
		isHomePage = $page.url.pathname === '/';
	});

	// Navigation functions
	function goToPrevious() {
		if (currentIndex > 0) {
			goto(challenges[currentIndex - 1].path);
		}
	}

	function goToNext() {
		if (currentIndex < challenges.length - 1) {
			goto(challenges[currentIndex + 1].path);
		}
	}
</script>

<div class="min-h-screen bg-base-200">
	<!-- Top Navigation Bar -->
	<div class="navbar bg-base-100 shadow-lg">
		<div class="navbar-start">
			<div class="dropdown">
				<div tabindex="0" role="button" class="btn btn-ghost lg:hidden">
					<svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
						<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h8m-8 6h16" />
					</svg>
				</div>
				<ul class="menu menu-sm dropdown-content mt-3 z-[1] p-2 shadow bg-base-100 rounded-box w-52">
					{#each challenges as challenge}
						<li>
							<a href={challenge.path} class:active={$page.url.pathname === challenge.path}>
								<span class="text-lg">{challenge.icon}</span>
								{challenge.name}
							</a>
						</li>
					{/each}
				</ul>
			</div>
			<a href="/" class="btn btn-ghost text-xl">7GUIs Svelte</a>
		</div>
		
		<div class="navbar-center hidden lg:flex">
			<ul class="menu menu-horizontal px-1">
				{#each challenges.slice(1) as challenge}
					<li>
						<a 
							href={challenge.path} 
							class="tooltip tooltip-bottom" 
							data-tip={challenge.name}
							class:active={$page.url.pathname === challenge.path}
						>
							<span class="text-xl">{challenge.icon}</span>
						</a>
					</li>
				{/each}
			</ul>
		</div>
		
		<div class="navbar-end">
			{#if !isHomePage}
				<div class="flex gap-2">
					<button 
						onclick={goToPrevious} 
						class="btn btn-sm btn-circle"
						disabled={currentIndex <= 1}
					>
						<svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
							<path fill-rule="evenodd" d="M12.707 5.293a1 1 0 010 1.414L9.414 10l3.293 3.293a1 1 0 01-1.414 1.414l-4-4a1 1 0 010-1.414l4-4a1 1 0 011.414 0z" clip-rule="evenodd" />
						</svg>
					</button>
					<button 
						onclick={goToNext} 
						class="btn btn-sm btn-circle"
						disabled={currentIndex >= challenges.length - 1}
					>
						<svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
							<path fill-rule="evenodd" d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z" clip-rule="evenodd" />
						</svg>
					</button>
				</div>
			{/if}
		</div>
	</div>

	<!-- Main Content -->
	<main class="min-h-[calc(100vh-4rem)] pb-20">
		{@render children()}
	</main>

	<!-- Bottom Navigation Bar (for non-home pages) -->
	{#if !isHomePage}
		<div class="fixed bottom-0 left-0 right-0 p-4 bg-base-100/80 backdrop-blur-md border-t border-base-300">
			<div class="max-w-sm mx-auto flex justify-between items-center gap-4">
				<button 
					onclick={goToPrevious}
					class="btn btn-circle btn-sm"
					disabled={currentIndex <= 1}
					title="Previous challenge"
				>
					<svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" viewBox="0 0 20 20" fill="currentColor">
						<path fill-rule="evenodd" d="M12.707 5.293a1 1 0 010 1.414L9.414 10l3.293 3.293a1 1 0 01-1.414 1.414l-4-4a1 1 0 010-1.414l4-4a1 1 0 011.414 0z" clip-rule="evenodd" />
					</svg>
				</button>
				
				<button 
					onclick={() => goto('/')}
					class="btn btn-ghost btn-sm gap-2"
				>
					<svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" viewBox="0 0 20 20" fill="currentColor">
						<path d="M10.707 2.293a1 1 0 00-1.414 0l-7 7a1 1 0 001.414 1.414L4 10.414V17a1 1 0 001 1h2a1 1 0 001-1v-2a1 1 0 011-1h2a1 1 0 011 1v2a1 1 0 001 1h2a1 1 0 001-1v-6.586l.293.293a1 1 0 001.414-1.414l-7-7z" />
					</svg>
					Home
				</button>
				
				<button 
					onclick={goToNext}
					class="btn btn-circle btn-sm"
					disabled={currentIndex >= challenges.length - 1}
					title="Next challenge"
				>
					<svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" viewBox="0 0 20 20" fill="currentColor">
						<path fill-rule="evenodd" d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z" clip-rule="evenodd" />
					</svg>
				</button>
			</div>
		</div>
	{/if}
</div>

<style>
	:global(.active) {
		background-color: oklch(var(--p));
		color: oklch(var(--pc));
	}
</style>