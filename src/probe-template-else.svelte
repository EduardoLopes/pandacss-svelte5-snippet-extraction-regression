<script lang="ts">
	import { css } from '../styled-system/css';

	// No `$`-prefixed identifiers. Template uses `{#if}...{:else}`.
	const show = false;
	const probeClass = css({ color: 'red' });
</script>

{#if show}
	<p>shown</p>
{:else}
	<p class={probeClass}>fallback</p>
{/if}
