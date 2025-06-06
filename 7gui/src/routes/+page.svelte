<script lang="ts">
	import { goto } from '$app/navigation';

	const challenges = [
		{ path: '/counter', name: 'Counter', icon: '🔢', description: 'Basic ideas of a language/toolkit' },
		{ path: '/temperature_converter', name: 'Temperature Converter', icon: '🌡️', description: 'Bidirectional data flow' },
		{ path: '/flight_booker', name: 'Flight Booker', icon: '✈️', description: 'Constraints' },
		{ path: '/timer', name: 'Timer', icon: '⏱️', description: 'Concurrency' },
		{ path: '/crud', name: 'CRUD', icon: '📝', description: 'Separating domain and presentation logic' },
		{ path: '/circle_draw', name: 'Circle Drawer', icon: '⭕', description: 'Undo/redo' },
		{ path: '/cells', name: 'Cells', icon: '📊', description: 'Change propagation' }
	];
</script>

<div class="min-h-screen flex flex-col items-center justify-center p-8">
	<!-- Title -->
	<div class="text-center mb-12">
		<h1 class="text-6xl font-bold text-primary mb-4">7GUIs Challenge</h1>
		<p class="text-xl text-base-content/70 mb-2">
			A benchmark of GUI programming — implemented in Svelte 5
		</p>
		<p class="text-sm text-base-content/50">
			Built to learn Svelte through practical examples
		</p>
	</div>

	<!-- Challenge List -->
	<div class="w-full max-w-4xl mb-12">
		<div class="grid grid-cols-1 md:grid-cols-2 gap-3">
			{#each challenges as challenge, i}
				<button
					onclick={() => goto(challenge.path)}
					class="group flex items-center gap-4 p-4 rounded-lg bg-base-100 hover:bg-base-200 transition-all duration-200 text-left border border-base-300 hover:border-primary"
				>
					<span class="text-3xl group-hover:scale-110 transition-transform">{challenge.icon}</span>
					<div class="flex-1">
						<h3 class="font-semibold text-base-content">
							{i + 1}. {challenge.name}
						</h3>
						<p class="text-sm text-base-content/60">{challenge.description}</p>
					</div>
					<svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-base-content/40 group-hover:text-primary transition-colors" viewBox="0 0 20 20" fill="currentColor">
						<path fill-rule="evenodd" d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z" clip-rule="evenodd" />
					</svg>
				</button>
			{/each}
			
			<!-- GitHub Link -->
			<a
				href="https://github.com/MykolaVaskevych"
				target="_blank"
				class="group flex items-center gap-4 p-4 rounded-lg bg-base-100 hover:bg-base-200 transition-all duration-200 text-left border border-base-300 hover:border-primary"
			>
				<span class="text-3xl group-hover:scale-110 transition-transform">💻</span>
				<div class="flex-1">
					<h3 class="font-semibold text-base-content">
						My GitHub
					</h3>
					<p class="text-sm text-base-content/60">Check out my other projects</p>
				</div>
				<svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-base-content/40 group-hover:text-primary transition-colors" viewBox="0 0 20 20" fill="currentColor">
					<path d="M11 3a1 1 0 100 2h2.586l-6.293 6.293a1 1 0 101.414 1.414L15 6.414V9a1 1 0 102 0V4a1 1 0 00-1-1h-5z" />
					<path d="M5 5a2 2 0 00-2 2v8a2 2 0 002 2h8a2 2 0 002-2v-3a1 1 0 10-2 0v3H5V7h3a1 1 0 000-2H5z" />
				</svg>
			</a>
		</div>
	</div>

	<!-- About -->
	<div class="text-center max-w-2xl mb-8">
		<h2 class="text-2xl font-semibold text-base-content mb-3">What is 7GUIs?</h2>
		<p class="text-base-content/70 mb-4">
			7GUIs is a benchmark to compare different GUI programming approaches. 
			It consists of 7 tasks that represent typical challenges in GUI programming.
		</p>
		<a 
			href="https://eugenkiss.github.io/7guis/" 
			target="_blank"
			class="link link-primary text-sm"
		>
			Reference to 7GUIs →
		</a>
	</div>

	<!-- Oops Note -->
	<div class="alert max-w-2xl">
		<span class="text-2xl">😅</span>
		<div class="text-sm text-base-content/80">
			<p class="font-semibold mb-1">Ugh moment:</p>
			<p>
				After implementing all 7 tasks, I discovered they were already done in the 
				<a href="https://svelte.dev/playground/7guis-circles" target="_blank" class="link link-primary">official Svelte playground</a>.
				Oh well! Now you can compare my implementations with the official ones.
			</p>
		</div>
	</div>
</div>