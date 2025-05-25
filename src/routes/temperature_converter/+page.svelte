<script lang="ts">
	import ChallengeLayout from '$lib/components/challengeLayout.svelte';

	let c: number = $state(0);
	let f: number = $state(0);

	function c2f() {
		f = Math.floor(c * (9 / 5) + 32);
	}

	function f2c() {
		c = Math.floor((f - 32) * (5 / 9));
	}
</script>

<ChallengeLayout
	challenge="Challenges: bidirectional data flow, user-provided text input."
	desription="The task is to build a frame containing two textfields TC and TF representing the temperature in Celsius and Fahrenheit, respectively. Initially, both TC and TF are empty. When the user enters a numerical value into TC the corresponding value in TF is automatically updated and vice versa. When the user enters a non-numerical string into TC the value in TF is not updated and vice versa. The formula for converting a temperature C in Celsius into a temperature F in Fahrenheit is C = (F - 32) * (5/9) and the dual direction is F = C * (9/5) + 32.Temperature Converter increases the complexity of Counter by having bidirectional data flow between the Celsius and Fahrenheit inputs and the need to check the user input for validity. A good solution will make the bidirectional dependency very clear with minimal boilerplate code. Temperature Converter is inspired by the Celsius/Fahrenheit converter from the book Programming in Scala. It is such a widespread example—sometimes also in the form of a currency converter—that one could give a thousand references. The same is true for the Counter task."
	image="tempconv.png"
	title="Temperature Converter"
><div class="flex flex-col gap-6 items-center">
    <label class="flex items-center gap-4">
        <span class="font-mono text-xl font-bold">C:</span>
        <input 
            type="number" 
            bind:value={c} 
            oninput={c2f}
            min="0"
            max="99999"
            placeholder="Celsius"
            class="input input-primary input-lg w-40"
        />
    </label>
    <label class="flex items-center gap-4">
        <span class="font-mono text-xl font-bold">F:</span>
        <input 
            type="number" 
            bind:value={f} 
            oninput={f2c}
            min="0"
            max="99999"
            placeholder="Fahrenheit"
            class="input input-secondary input-lg w-40"
        />
    </label>
</div>
</ChallengeLayout>
