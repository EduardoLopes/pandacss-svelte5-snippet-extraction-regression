<script lang="ts">
	import { css } from '../styled-system/css';

	// Not a Svelte rune — just a regular function whose name starts with `$`.
	function $myFn(n: number): number {
		return n * 2;
	}
	const result = $myFn(21);

	const probeClass = css({ color: 'red' });
</script>
