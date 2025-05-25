<script lang="ts">
	let count: number = $state(0);

	function increment() {
		count += 1;
	}
</script>

<div class="flex h-screen w-screen flex-row">
	<div class="bg-base-100 flex flex-1 flex-col items-center justify-center gap-4">
		<div class="font-mono text-6xl font-bold">{count}</div>
		<button class="btn btn-xl" onclick={increment}>+</button>
	</div>
	<div class="bg-base-200 flex flex-1 flex-col items-center justify-center p-8">
		<div class="max-w-2xl space-y-4">
			<p class="text-primary text-2xl font-bold">#1: Counter</p>
			<p class="text-secondary text-lg font-semibold">
				Challenge: Understanding the basic ideas of a language/toolkit.
			</p>
			<img src="counter.png" alt="example" class = "mx-auto">
			<p class="text-base leading-relaxed">
				The task is to build a frame containing a label or read-only textfield T and a button B.
				Initially, the value in T is "0" and each click of B increases the value in T by one.
				Counter serves as a gentle introduction to the basics of the language, paradigm and toolkit
				for one of the simplest GUI applications imaginable. Thus, Counter reveals the required
				scaffolding and how the very basic features work together to build a GUI application. A good
				solution will have almost no scaffolding.
			</p>
		</div>
	</div>
</div>
