import { defineConfig } from '@pandacss/dev';

export default defineConfig({
	preflight: true,
	include: ['./src/**/*.{ts,svelte}'],
	exclude: [],
	jsxFramework: 'svelte',
	outdir: 'styled-system'
});
