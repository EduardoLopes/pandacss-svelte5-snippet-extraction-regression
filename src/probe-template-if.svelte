<script lang="ts">
	import { css } from '../styled-system/css';

	// No `$`-prefixed identifiers. Template uses `{#if}`.
	const show = true;
	const probeClass = css({ color: 'red' });
</script>

{#if show}
	<p class={probeClass}>visible</p>
{/if}
