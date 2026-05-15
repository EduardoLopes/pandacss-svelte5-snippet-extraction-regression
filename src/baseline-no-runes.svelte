<script lang="ts">
	import { css } from '../styled-system/css';

	// No Svelte 5 runes in this file. Used as the control case.
	const probeClass = css({ color: 'green' });
</script>

<p class={probeClass}>baseline</p>
