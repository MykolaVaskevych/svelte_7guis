<script lang="ts">
    import ChallengeLayout from '$lib/components/ChallengeLayout.svelte';
    let c: number = $state(0);
    let f: number = $state(0);
    let cInput: string = $state('');
    let fInput: string = $state('');
    
    function c2f(event: Event) {
        const input = (event.target as HTMLInputElement).value;
        cInput = input;
        const num = parseFloat(input);
        if (!isNaN(num)) {
            c = num;
            f = Math.floor(c * (9 / 5) + 32);
            fInput = f.toString(); // Update the other input
        }
    }
    
    function f2c(event: Event) {
        const input = (event.target as HTMLInputElement).value;
        fInput = input;
        const num = parseFloat(input);
        if (!isNaN(num)) {
            f = num;
            c = Math.floor((f - 32) * (5 / 9));
            cInput = c.toString(); // Update the other input
        }
    }
    
    let cValid = $derived(!isNaN(parseFloat(cInput)) || cInput === '');
    let fValid = $derived(!isNaN(parseFloat(fInput)) || fInput === '');
</script>

<ChallengeLayout
    challenge="Challenges: bidirectional data flow, user-provided text input."
    title="Temperature Converter"
    image="tempconv.png"
    description="The task is to build a frame containing two textfields TC and TF representing the temperature in Celsius and Fahrenheit, respectively. Initially, both TC and TF are empty. When the user enters a numerical value into TC the corresponding value in TF is automatically updated and vice versa. When the user enters a non-numerical string into TC the value in TF is not updated and vice versa. The formula for converting a temperature C in Celsius into a temperature F in Fahrenheit is C = (F - 32) * (5/9) and the dual direction is F = C * (9/5) + 32.Temperature Converter increases the complexity of Counter by having bidirectional data flow between the Celsius and Fahrenheit inputs and the need to check the user input for validity. A good solution will make the bidirectional dependency very clear with minimal boilerplate code. Temperature Converter is inspired by the Celsius/Fahrenheit converter from the book Programming in Scala. It is such a widespread example—sometimes also in the form of a currency converter—that one could give a thousand references. The same is true for the Counter task."
>
    <div class="flex flex-col items-center gap-6">
        <div class="flex flex-col gap-1">
            <label class="flex items-center gap-4">
                <span class="font-mono text-xl font-bold">C:</span>
                <input
                    type="text"
                    bind:value={cInput}
                    oninput={c2f}
                    placeholder="Celsius"
                    class="input input-primary input-lg w-40"
                    class:input-error={!cValid}
                />
            </label>
            {#if !cValid}
                <p class="text-error text-sm">Must be a number</p>
            {/if}
        </div>
        <div class="flex flex-col gap-1">
            <label class="flex items-center gap-4">
                <span class="font-mono text-xl font-bold">F:</span>
                <input
                    type="text"
                    bind:value={fInput}
                    oninput={f2c}
                    placeholder="Fahrenheit"
                    class="input input-secondary input-lg w-40"
                    class:input-error={!fValid}
                />
            </label>
            {#if !fValid}
                <p class="text-error text-sm">Must be a number</p>
            {/if}
        </div>
    </div>
</ChallengeLayout>