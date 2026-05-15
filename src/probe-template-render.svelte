<script lang="ts">
	import { css } from '../styled-system/css';

	// No `$`-prefixed identifiers. Template uses `{@render}`.
	const fallback = () => 'hi';
	const probeClass = css({ color: 'red' });
</script>

<div class={probeClass}>
	{@render fallback()}
</div>
