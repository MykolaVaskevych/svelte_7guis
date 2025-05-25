<script lang="ts">
	import ChallengeLayout from '$lib/components/challengeLayout.svelte';
	let count: number = $state(0);

	function increment() {
		count += 1;
	}
</script>



<ChallengeLayout
	title="#1 Counter"
	challenge="Challenge: Understanding the basic ideas of a language/toolkit."
	image="counter.png"
	description="The task is to build a frame containing a label or read-only textfield T and a button B.
				Initially, the value in T is '0' and each click of B increases the value in T by one.
				Counter serves as a gentle introduction to the basics of the language, paradigm and toolkit
				for one of the simplest GUI applications imaginable. Thus, Counter reveals the required
				scaffolding and how the very basic features work together to build a GUI application. A good
				solution will have almost no scaffolding."
>
	<div class="font-mono text-6xl font-bold">
		{count}
		<button class="btn btn-xl" onclick={increment}>+</button>
	</div>
</ChallengeLayout>
