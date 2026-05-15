<script lang="ts">
	import { css } from '../styled-system/css';

	// Trigger: the `$props()` rune. Type annotation is optional —
	// `let props = $props();` (untyped) breaks the same way.
	let { x = false }: { x?: boolean } = $props();

	const probeClass = css({ color: 'red' });
</script>
