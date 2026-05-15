<script lang="ts">
	import { css } from '../styled-system/css';

	$effect(() => {
		console.log('mounted');
	});

	const probeClass = css({ color: 'red' });
</script>
