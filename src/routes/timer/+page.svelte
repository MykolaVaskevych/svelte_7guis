<script lang="ts">
	import ChallengeLayout from '$lib/components/challengeLayout.svelte';
	let elapsed_time = $state(0);
	let duration = $state(10);
	let timer_running = $state(true);

	setInterval(() => {
		if (timer_running && parseFloat(elapsed_time.toFixed(1)) < duration) {
			elapsed_time += 0.1;
		} else {
			timer_running = false;
		}
	}, 100);

	function reset() {
		elapsed_time = 0;
		timer_running = true;
	}
</script>

<ChallengeLayout
	title="Timer"
	challenge="Challenges: concurrency, competing user/signal interactions, responsiveness."
	description="The task is to build a frame containing a gauge G for the elapsed time e, a label which shows the elapsed time as a numerical value, a slider S by which the duration d of the timer can be adjusted while the timer is running and a reset button R. Adjusting S must immediately reflect on d and not only when S is released. It follows that while moving S the filled amount of G will (usually) change immediately. When e ≥ d is true then the timer stops (and G will be full). If, thereafter, d is increased such that d > e will be true then the timer restarts to tick until e ≥ d is true again. Clicking R will reset e to zero. Timer deals with concurrency in the sense that a timer process that updates the elapsed time runs concurrently to the user's interactions with the GUI application. This also means that the solution to competing user and signal interactions is tested. The fact that slider adjustments must be reflected immediately moreover tests the responsiveness of the solution. A good solution will make it clear that the signal is a timer tick and, as always, has not much scaffolding. Timer is directly inspired by the timer example in the paper Crossing State Lines: Adapting Object-Oriented Frameworks to Functional Reactive Languages."
	image="timer.png"
>
	<div class="flex flex-col items-center justify-center gap-4">
		<p>Elapsed Time: {elapsed_time.toFixed(1)}</p>
		<progress value={elapsed_time} max={duration}></progress>
		<label for="range">Duration: {duration} seconds</label>
		<input id="range" type="range" min="1" max="30" bind:value={duration} />
		<button onclick={reset} class="btn">Reset</button>
	</div>
</ChallengeLayout>
