<script lang="ts">
	import ChallengeLayout from '$lib/components/challengeLayout.svelte';

	class Temperature {
		#c: number = $state(0);
		#f: number = $state(0);
		#cInput: string = $state('');
		#fInput: string = $state('');

		get cInput() {
			return this.#cInput;
		}

		get fInput() {
			return this.#fInput;
		}

		set c(value: number) {
			this.#c = value;
			this.#f = value * (9 / 5) + 32;
		}

		set f(value: number) {
			this.#f = value;
			this.#c = (value - 32) * (5 / 9);
		}

		setCelsiusInput(value: string) {
			this.#cInput = value;
			const numValue = parseFloat(value);
			if (!isNaN(numValue) && value !== '') {
				this.c = numValue;
				this.#fInput = this.#f.toFixed(2).replace(/\.?0+$/, '');
			}
		}

		setFahrenheitInput(value: string) {
			this.#fInput = value;
			const numValue = parseFloat(value);
			if (!isNaN(numValue) && value !== '') {
				this.f = numValue;
				this.#cInput = this.#c.toFixed(2).replace(/\.?0+$/, '');
			}
		}
	}

	const temp = new Temperature();

	// i used firefox, maybe in chrome type="number" whould work but that should works everywhere.. i guess?
	function handleCelsiusInput(event: Event) {
		const target = event.target as HTMLInputElement;
		const cleaned = target.value.replace(/[^0-9.-]/g, '');
		target.value = cleaned;
		temp.setCelsiusInput(cleaned);
	}

	function handleFahrenheitInput(event: Event) {
		const target = event.target as HTMLInputElement;
		const cleaned = target.value.replace(/[^0-9.-]/g, '');
		target.value = cleaned;
		temp.setFahrenheitInput(cleaned);
	}
</script>

<ChallengeLayout
	title="Temperature Converter"
	challenge="Challenges: bidirectional data flow, user-provided text input."
	description="The task is to build a frame containing two textfields TC and TF representing the temperature in Celsius and Fahrenheit, respectively. Initially, both TC and TF are empty. When the user enters a numerical value into TC the corresponding value in TF is automatically updated and vice versa. When the user enters a non-numerical string into TC the value in TF is not updated and vice versa. The formula for converting a temperature C in Celsius into a temperature F in Fahrenheit is C = (F - 32) * (5/9) and the dual direction is F = C * (9/5) + 32.Temperature Converter increases the complexity of Counter by having bidirectional data flow between the Celsius and Fahrenheit inputs and the need to check the user input for validity. A good solution will make the bidirectional dependency very clear with minimal boilerplate code. Temperature Converter is inspired by the Celsius/Fahrenheit converter from the book Programming in Scala. It is such a widespread example—sometimes also in the form of a currency converter—that one could give a thousand references. The same is true for the Counter task."
	image="tempconv.png"
>
	<form action="">
		<label for="Celsius">C:</label>
		<input
			id="Celsius"
			type="text"
			placeholder="Celsius"
			value={temp.cInput}
			oninput={handleCelsiusInput}
		/>

		🟰🟰

		<label for="Fahrenheit">F:</label>
		<input
			type="text"
			id="Fahrenheit"
			placeholder="Fahrenheit"
			value={temp.fInput}
			oninput={handleFahrenheitInput}
		/>
	</form>
</ChallengeLayout>
