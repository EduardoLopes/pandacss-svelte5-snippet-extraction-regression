<script lang="ts">
	import { css } from '../styled-system/css';

	// `$state` appears only inside a string — should not be parsed as a rune.
	const literal = 'let count = $state(0);';

	const probeClass = css({ color: 'red' });
</script>
