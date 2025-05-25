<script lang="ts">

    let {children, title, challenge, description, image} = $props();

</script>

<div class="flex h-screen w-screen flex-row">
    <div class="bg-base-100 flex flex-1 flex-col items-center justify-center gap-4">
        {@render children()}
    </div>


    <div class="bg-base-200 flex flex-1 flex-col items-center justify-center p-8">
        <div class="max-w-2xl space-y-4">
            <p class="text-2xl font-bold">{title}</p>
            <p class="text-secondary text-lg font-semibold">{challenge}</p>
            {#if image}
                <img src={image} alt="example" class="mx-auto">            
            {/if}
            <p class="text-base leading-relaxed">{description}</p>
        </div>
    </div>
</div>