<script lang="ts">
	import ChallengeLayout from '$lib/components/challengeLayout.svelte';
	type Person = {
		name: string;
		surname: string;
	};
	let people = $state([
		{ name: 'John', surname: 'Smith' },
		{ name: 'Mykola', surname: 'Vaskevych' },
		{ name: 'Rich', surname: 'Harris' }
	]);
	let selected = $state<Person>();
	let person = $state({ name: '', surname: '' });

	function clear() {
		person = { name: '', surname: '' };
	}

	function createPerson() {
		people.push(person);
		clear();
	}
	function updatePerson() {
		const index = people.indexOf(selected!);
		people[index] = { name: person.name, surname: person.surname };
	}

	$effect(() => {
		person = {
			name: selected?.name ?? '',
			surname: selected?.surname ?? ''
		};
	});
	function deletePerson() {
		const index = people.indexOf(selected!);
		people.splice(index, 1);
		clear();
	}

	let search: string = $state('');
	let filtered = $derived(
		search
			? people.filter((person) => person.surname.toLocaleLowerCase().startsWith(search))
			: people
	);
</script>

<ChallengeLayout
	title="CRUD"
	challenge="separating the domain and presentation logic, managing mutation, building a non-trivial layout."
	image="crud.png"
	description="The task is to build a frame containing the following elements: a textfield Tprefix, a pair of textfields Tname and Tsurname, a listbox L, buttons BC, BU and BD and the three labels as seen in the screenshot. L presents a view of the data in the database that consists of a list of names. At most one entry can be selected in L at a time. By entering a string into Tprefix the user can filter the names whose surname start with the entered prefix—this should happen immediately without having to submit the prefix with enter. Clicking BC will append the resulting name from concatenating the strings in Tname and Tsurname to L. BU and BD are enabled iff an entry in L is selected. In contrast to BC, BU will not append the resulting name but instead replace the selected entry with the new name. BD will remove the selected entry. The layout is to be done like suggested in the screenshot. In particular, L must occupy all the remaining space.

CRUD (Create, Read, Update and Delete) represents a typical graphical business application. The primary challenge is the separation of domain and presentation logic in the source code that is more or less forced on the implementer due to the ability to filter the view by a prefix. Traditionally, some form of MVC pattern is used to achieve the separation of domain and presentation logic. Also, the approach to managing the mutation of the list of names is tested. A good solution will have a good separation between the domain and presentation logic without much overhead (e.g. in the form of toolkit specific concepts or language/paradigm concepts), a mutation management that is fast but not error-prone and a natural representation of the layout (layout builders are allowed, of course, but would increase the overhead)."
>
	<div class="space-y-4 p-4">
		<div class="flex items-center gap-2">
			<span class="text-sm">Filter prefix:</span>
			<input type="text" bind:value={search} class="input border px-2 py-1 text-sm" />
		</div>

		<div class="flex gap-4">
			<div class="flex-shrink-0">
				<select bind:value={selected} size="7" class="w-48 border text-sm">
					{#each filtered as person}
						<option value={person}>{person.surname}, {person.name}</option>
					{/each}
				</select>
			</div>

			<div class="flex-1 space-y-3">
				<div class="flex items-center gap-2">
					<span class="w-16 text-sm">Name:</span>
					<input
						type="text"
						bind:value={person.name}
						class="input flex-1 border px-2 py-1 text-sm"
					/>
				</div>
				<div class="flex items-center gap-2">
					<span class="w-16 text-sm">Surname:</span>
					<input
						type="text"
						bind:value={person.surname}
						class="input flex-1 border px-2 py-1 text-sm"
					/>
				</div>
			</div>
		</div>

		<div class="flex gap-2">
			<button onclick={createPerson} class="btn btn-primary border px-4 py-1 text-sm">Create</button
			>
			<button onclick={updatePerson} class="btn-info btn border px-4 py-1 text-sm">Update</button>
			<button onclick={deletePerson} class="btn-secondary btn border px-4 py-1 text-sm"
				>Delete</button
			>
		</div>
	</div>
</ChallengeLayout>
