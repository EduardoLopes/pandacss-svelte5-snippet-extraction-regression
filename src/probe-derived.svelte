<script lang="ts">
	import { css } from '../styled-system/css';

	let n = 1;
	let doubled = $derived(n * 2);

	const probeClass = css({ color: 'red' });
</script>
