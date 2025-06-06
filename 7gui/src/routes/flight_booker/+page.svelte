<script lang="ts">
	import ChallengeLayout from '$lib/components/challengeLayout.svelte';
	let date1: string = $state(new Date().toISOString().split('T')[0]);
	let date2: string = $state(new Date().toISOString().split('T')[0]);
	// const minDate: string = new Date().toISOString().split('T')[0];
	let picked_option: string = $state('one-way flight');
	let success_message: string = $state('');
	function isValidDate(dateString: string) {
		let datetmp = new Date(dateString).toISOString().split('T')[0];
		let today = new Date().toISOString().split('T')[0];
		return dateString === datetmp && dateString >= today;
	}

	function handleSubmit() {
		if (picked_option === 'one-way flight') {
			success_message = `You have booked a one-way flight on ${date1}.`;
		} else {
			success_message = `You have booked a return flight departing on ${date1} and returning on ${date2}.`;
		}
	}

	let button_disabled = $derived.by(() => {
		if (!isValidDate(date1)) return true;

		if (picked_option === 'return flight') {
			if (!isValidDate(date2)) return true;

			if (new Date(date2) < new Date(date1)) return true;
		}

		return false;
	});

	let error_message = $derived.by(() => {
		if (!isValidDate(date1)) return 'Please select a valid flight date';
		if (picked_option === 'return flight' && !isValidDate(date2)) {
			return 'Please select a valid return date';
		}
		if (picked_option === 'return flight' && new Date(date2) < new Date(date1)) {
			return 'Return date must be after departure date';
		}
		return '';
	});

	function resetForm() {
		success_message = '';
		picked_option = 'one-way flight';
		date1 = new Date().toISOString().split('T')[0];
		date2 = new Date().toISOString().split('T')[0];
	}
</script>

<ChallengeLayout
	title="Flight Booker"
	challenge="Challenge: Constraints."
	description="The task is to build a frame containing a combobox C with the two options 'one-way flight' and 'return flight', two textfields T1 and T2 representing the start and return date, respectively, and a button B for submitting the selected flight. T2 is enabled iff C's value is 'return flight'. When C has the value 'return flight' and T2's date is strictly before T1's then B is disabled. When a non-disabled textfield T has an ill-formatted date then T is colored red and B is disabled. When clicking B a message is displayed informing the user of his selection (e.g. 'You have booked a one-way flight on 04.04.2014.'). Initially, C has the value 'one-way flight' and T1 as well as T2 have the same (arbitrary) date (it is implied that T2 is disabled). The focus of Flight Booker lies on modelling constraints between widgets on the one hand and modelling constraints within a widget on the other hand. Such constraints are very common in everyday interactions with GUI applications. A good solution for Flight Booker will make the constraints clear, succinct and explicit in the source code and not hidden behind a lot of scaffolding. Flight Booker is directly inspired by the Flight Booking Java example in Sodium with the simplification of using textfields for date input instead of specialized date picking widgets as the focus of Flight Booker is not on specialized/custom widgets."
	image="bookflight.png"
>
	<div class="flex flex-col items-center justify-center gap-4">
		{#if success_message}
			<p class="rounded p-2 text-green-600">{success_message}</p>
			<button class="btn" onclick={resetForm}>Book another flight</button>
		{:else}
			<select bind:value={picked_option} class="select">
				<option>one-way flight</option>
				<option>return flight</option>
			</select>

			<label for="date1">date of flight: </label>
			<input bind:value={date1} id="date1" type="date" class:bg-red-500={!isValidDate(date1)} />
			<!-- min={minDate} /> -->

			<label hidden={picked_option === 'one-way flight'} for="date2">dete of return flight:</label>
			<input
				hidden={picked_option === 'one-way flight'}
				bind:value={date2}
				id="date2"
				type="date"
				class:bg-red-500={picked_option === 'return flight' &&
					(!isValidDate(date2) || new Date(date2) < new Date(date1))}
			/>
			<!-- min={minDate} /> -->
			<button hidden={button_disabled} class="btn" onclick={handleSubmit}>Submit</button>
			{#if error_message}
				<p class="text-sm text-red-500">{error_message}</p>
			{/if}
		{/if}
	</div>
</ChallengeLayout>
