<script lang="ts">
	import ChallengeLayout from '$lib/components/challengeLayout.svelte';

	const ROWS: number = 100;
	const COLS: number = 26;
	const LETTERS = [...Array(26)].map((_, i) => String.fromCharCode(65 + i));

	type Cell = {
		value: string;
		formula: string;
		isEditing: boolean;
	};

	let cells = $state(
		Array.from({ length: ROWS }, () =>
			Array.from({ length: COLS }, () => ({
				value: '',
				formula: '',
				isEditing: false
			}))
		)
	);

	let selectedCell = $state<{ row: number; col: number } | null>(null);

	const excelFunctions = [
		{ name: 'SUM', example: '=SUM(A1:A5)' },
		{ name: 'AVERAGE', example: '=AVERAGE(B1:B10)' },
		{ name: 'MAX', example: '=MAX(A1:C3)' },
		{ name: 'MIN', example: '=MIN(D1:D5)' },
		{ name: 'COUNT', example: '=COUNT(A1:B10)' },
		{ name: 'PRODUCT', example: '=PRODUCT(A1:A3)' },
		{ name: 'MEDIAN', example: '=MEDIAN(A1:A5)' },
		{ name: 'STDEV', example: '=STDEV(B1:B10)' }
	];

	function getColumnLetter(index: number): string {
		if (index < 26) return LETTERS[index];
		return LETTERS[Math.floor(index / 26) - 1] + LETTERS[index % 26];
	}

	function parseCellRef(ref: string): { col: number; row: number } | null {
		const match = ref.match(/^([A-Z]+)(\d+)$/);
		if (!match) return null;

		const col = match[1].split('').reduce((acc, char) => acc * 26 + char.charCodeAt(0) - 64, 0) - 1;
		const row = parseInt(match[2]) - 1;

		return col >= 0 && col < COLS && row >= 0 && row < ROWS ? { col, row } : null;
	}

	function parseRange(range: string): Array<{ col: number; row: number }> {
		const parts = range.split(':');
		if (parts.length !== 2) return [];

		const start = parseCellRef(parts[0].trim());
		const end = parseCellRef(parts[1].trim());

		if (!start || !end) return [];

		const cells: Array<{ col: number; row: number }> = [];
		for (let row = start.row; row <= end.row; row++) {
			for (let col = start.col; col <= end.col; col++) {
				cells.push({ col, row });
			}
		}
		return cells;
	}

	function parseCellReferences(str: string): string[] {
		const regex = /([A-Z]+\d+(?::[A-Z]+\d+)?)/g;
		const matches = str.match(regex) || [];
		return matches;
	}

	function extractValues(args: string): number[] {
		const values: number[] = [];
		const parts = args.split(',');

		for (const part of parts) {
			const trimmed = part.trim();

			if (trimmed.includes(':')) {
				const rangeCells = parseRange(trimmed);
				for (const cell of rangeCells) {
					const value = cells[cell.row][cell.col].value;
					const num = parseFloat(value);
					if (!isNaN(num)) values.push(num);
				}
			} else if (/^[A-Z]+\d+$/.test(trimmed)) {
				const ref = parseCellRef(trimmed);
				if (ref) {
					const value = cells[ref.row][ref.col].value;
					const num = parseFloat(value);
					if (!isNaN(num)) values.push(num);
				}
			} else {
				const num = parseFloat(trimmed);
				if (!isNaN(num)) values.push(num);
			}
		}

		return values;
	}

	function applyFunction(funcName: string, values: number[]): number {
		switch (funcName.toUpperCase()) {
			case 'SUM':
				return values.reduce((a, b) => a + b, 0);

			case 'AVERAGE':
			case 'AVG':
				return values.length > 0 ? values.reduce((a, b) => a + b, 0) / values.length : 0;

			case 'MAX':
				return values.length > 0 ? Math.max(...values) : 0;

			case 'MIN':
				return values.length > 0 ? Math.min(...values) : 0;

			case 'COUNT':
				return values.length;

			case 'PRODUCT':
				return values.reduce((a, b) => a * b, 1);

			case 'MEDIAN':
				if (values.length === 0) return 0;
				const sorted = [...values].sort((a, b) => a - b);
				const mid = Math.floor(sorted.length / 2);
				return sorted.length % 2 ? sorted[mid] : (sorted[mid - 1] + sorted[mid]) / 2;

			case 'STDEV':
				if (values.length === 0) return 0;
				const avg = values.reduce((a, b) => a + b, 0) / values.length;
				const squareDiffs = values.map((v) => Math.pow(v - avg, 2));
				const avgSquareDiff = squareDiffs.reduce((a, b) => a + b, 0) / values.length;
				return Math.sqrt(avgSquareDiff);

			default:
				throw new Error(`Unknown function: ${funcName}`);
		}
	}

	function evaluateFormula(formula: string): string {
		if (!formula.startsWith('=')) return formula;

		try {
			let expr = formula.slice(1).trim();

			const funcMatch = expr.match(/^([A-Z]+)\s*\((.*)\)$/i);
			if (funcMatch) {
				const funcName = funcMatch[1];
				const args = funcMatch[2];

				const values = extractValues(args);

				const result = applyFunction(funcName, values);
				return String(result);
			}

			expr = expr.replace(/([A-Z]+\d+)/gi, (match) => {
				const ref = parseCellRef(match.toUpperCase());
				if (ref) {
					const cellValue = cells[ref.row][ref.col].value;
					return isNaN(Number(cellValue)) ? '0' : cellValue;
				}
				return '0';
			});

			// This allows things like =A1+B1*2 or =Math.sqrt(A1)
			const result = Function('"use strict"; return (' + expr + ')')();
			return String(result);
		} catch (e) {
			return '#ERROR';
		}
	}

	function getCellKey(row: number, col: number): string {
		return `${getColumnLetter(col)}${row + 1}`;
	}

	function extractDependencies(formula: string): string[] {
		const deps: string[] = [];
		if (!formula.startsWith('=')) return deps;

		const regex = /([A-Z]+\d+)/gi;
		const matches = formula.match(regex) || [];

		for (const match of matches) {
			const ref = parseCellRef(match.toUpperCase());
			if (ref) {
				deps.push(getCellKey(ref.row, ref.col));
			}
		}

		return deps;
	}

	function updateDependencies(row: number, col: number, formula: string) {
		const cellKey = getCellKey(row, col);

		for (const [key, deps] of dependencies) {
			deps.delete(cellKey);
		}

		const deps = extractDependencies(formula);
		for (const dep of deps) {
			if (!dependencies.has(dep)) {
				dependencies.set(dep, new Set());
			}
			dependencies.get(dep)!.add(cellKey);
		}
	}

	function getDependentCells(row: number, col: number): Array<{ row: number; col: number }> {
		const cellKey = getCellKey(row, col);
		const dependents = dependencies.get(cellKey) || new Set();
		const result: Array<{ row: number; col: number }> = [];

		for (const dep of dependents) {
			const ref = parseCellRef(dep);
			if (ref) {
				result.push(ref);
			}
		}

		return result;
	}

	function recalculateCell(row: number, col: number, visited = new Set<string>()) {
		const cellKey = getCellKey(row, col);

		if (visited.has(cellKey)) {
			cells[row][col].value = '#CIRCULAR';
			return;
		}

		visited.add(cellKey);

		if (cells[row][col].formula.startsWith('=')) {
			cells[row][col].value = evaluateFormula(cells[row][col].formula);
		}

		const dependents = getDependentCells(row, col);
		for (const dep of dependents) {
			recalculateCell(dep.row, dep.col, visited);
		}
	}

	let dependencies = new Map<string, Set<string>>();

	function handleCellClick(row: number, col: number) {
		if (selectedCell) {
			cells[selectedCell.row][selectedCell.col].isEditing = false;
		}
		selectedCell = { row, col };
	}

	function handleCellDoubleClick(row: number, col: number) {
		selectedCell = { row, col };
		cells[row][col].isEditing = true;
		setTimeout(() => {
			const input = document.querySelector(`#cell-${row}-${col}`) as HTMLInputElement;
			if (input) {
				input.focus();
				input.select();
			}
		}, 0);
	}

	function handleInputChange(row: number, col: number, value: string) {
		cells[row][col].formula = value;

		updateDependencies(row, col, value);

		if (value.startsWith('=')) {
			cells[row][col].value = evaluateFormula(value);
		} else {
			cells[row][col].value = value;
		}

		recalculateCell(row, col);
	}

	function insertFunction(funcName: string) {
		if (selectedCell) {
			const { row, col } = selectedCell;
			cells[row][col].isEditing = true;
			cells[row][col].formula = `=${funcName}()`;
			setTimeout(() => {
				const input = document.querySelector(`#cell-${row}-${col}`) as HTMLInputElement;
				if (input) {
					input.focus();
					input.setSelectionRange(input.value.length - 1, input.value.length - 1);
				}
			}, 0);
		}
	}
</script>

<ChallengeLayout
	title="#7 Cells"
	challenge="Challenges: change propagation, widget customization, implementing a more authentic/involved GUI application."
	image="cells.png"
	description="The task is to create a simple but usable spreadsheet application. The spreadsheet should be
				scrollable. The rows should be numbered from 0 to 99 and the columns from A to Z. Double-clicking
				a cell C lets the user change C's formula. After having finished editing the formula is parsed
				and evaluated and its updated value is shown in C. In addition, all cells which depend on C must
				be reevaluated. This process repeats until there are no more changes in the values of any cell
				(change propagation). Note that one should not just recompute the value of every cell but only
				of those cells that depend on another cell's changed value. If there is an already provided
				spreadsheet widget it should not be used. Instead, another similar widget (like JTable in Swing)
				should be customized to become a reusable spreadsheet widget.
				Cells is a more authentic and involved task that tests if a particular approach also scales to a
				somewhat bigger application. The two primary GUI-related challenges are intelligent propagation
				of changes and widget customization. Admittedly, there is a substantial part that is not
				necessarily very GUI-related but that is just the nature of a more authentic challenge. A good
				solution's change propagation will not involve much effort and the customization of a widget
				should not prove too difficult. The domain-specific code is clearly separated from the
				GUI-specific code. The resulting spreadsheet widget is reusable.
				Cells is directly inspired by the SCells spreadsheet example from the book Programming in Scala.
				Please refer to the book (or the implementations in this repository) for more details especially
				with respect to the not directly GUI-related concerns like parsing and evaluating formulas and
				the precise syntax and semantics of the spreadsheet language."
>
	<div class="mx-auto w-full max-w-6xl p-6">
		<div class="mb-6 flex items-center gap-4">
			<div class="dropdown dropdown-bottom">
				<div
					tabindex="0"
					role="button"
					class="btn btn-sm gap-2 border-0 bg-slate-900 text-white hover:bg-slate-800"
				>
					<svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
						<path
							stroke-linecap="round"
							stroke-linejoin="round"
							stroke-width="2"
							d="M12 6v6m0 0v6m0-6h6m-6 0H6"
						></path>
					</svg>
					<span class="text-sm font-medium">Insert Function</span>
				</div>
				<ul
					class="dropdown-content menu z-10 w-64 rounded-lg border border-gray-200 bg-white p-1 shadow-lg"
				>
					{#each excelFunctions as func}
						<li>
							<button
								onclick={() => insertFunction(func.name)}
								class="flex justify-between rounded px-3 py-2 text-sm hover:bg-gray-100"
							>
								<span class="font-medium text-gray-900">{func.name}</span>
								<span class="ml-4 font-mono text-xs text-gray-500">{func.example}</span>
							</button>
						</li>
					{/each}
				</ul>
			</div>

			{#if selectedCell}
				<div class="flex items-center gap-2">
					<div class="rounded bg-gray-100 px-3 py-1 text-sm font-medium text-gray-700">
						{getColumnLetter(selectedCell.col)}{selectedCell.row + 1}
					</div>
					{#if cells[selectedCell.row][selectedCell.col].isEditing}
						<span class="text-xs text-gray-500">Editing...</span>
					{:else}
						<span class="text-xs text-gray-500">Double-click to edit</span>
					{/if}
				</div>
			{/if}
		</div>

		<div class="overflow-hidden rounded-lg border border-gray-200 bg-white">
			<div class="relative overflow-auto" style="max-height: 600px;">
				<table class="border-collapse" style="min-width: max-content;">
					<thead>
						<tr class="sticky top-0 z-20 border-b border-gray-200 bg-gray-50">
							<th
								class="sticky left-0 z-30 h-10 w-16 border-r border-gray-200 bg-gray-50 text-xs font-medium text-gray-600"
							>
							</th>
							{#each Array(COLS) as _, colIndex}
								<th class="h-10 w-28 border-r border-gray-200 text-xs font-medium text-gray-600">
									{getColumnLetter(colIndex)}
								</th>
							{/each}
						</tr>
					</thead>

					<tbody>
						{#each cells as row, rowIndex}
							<tr>
								<td
									class="sticky left-0 z-10 h-10 w-16 border-r border-b border-gray-200 bg-gray-50 text-center text-xs font-medium text-gray-600"
								>
									{rowIndex + 1}
								</td>

								{#each row as cell, colIndex}
									<td class="h-10 w-28 border-r border-b border-gray-200 p-0">
										<input
											id="cell-{rowIndex}-{colIndex}"
											type="text"
											value={cell.isEditing ? cell.formula : cell.value}
											onclick={() => handleCellClick(rowIndex, colIndex)}
											ondblclick={() => handleCellDoubleClick(rowIndex, colIndex)}
											oninput={(e) =>
												handleInputChange(rowIndex, colIndex, (e.target as HTMLInputElement).value)}
											onblur={() => (cell.isEditing = false)}
											readonly={!cell.isEditing}
											class="h-full w-full border-none px-2 font-mono text-sm outline-none
												   {selectedCell?.row === rowIndex && selectedCell?.col === colIndex
												? 'bg-blue-50 text-gray-900 ring-2 ring-blue-500 ring-inset'
												: 'text-gray-800 hover:bg-gray-50'}
												   {cell.value.startsWith('#ERROR') || cell.value.startsWith('#CIRCULAR')
												? 'bg-red-50 text-red-600'
												: ''}
												   {!cell.isEditing ? 'cursor-cell' : 'cursor-text'}
												   placeholder:text-gray-400"
											placeholder=""
										/>
									</td>
								{/each}
							</tr>
						{/each}
					</tbody>
				</table>
			</div>
		</div>

		{#if selectedCell}
			<div class="mt-6 flex items-center gap-3 rounded-lg border border-gray-200 bg-gray-50 p-3">
				<span class="min-w-[60px] text-sm font-medium text-gray-700">
					{getColumnLetter(selectedCell.col)}{selectedCell.row + 1}:
				</span>
				<input
					type="text"
					value={cells[selectedCell!.row][selectedCell!.col].formula ||
						cells[selectedCell!.row][selectedCell!.col].value}
					oninput={(e) =>
						handleInputChange(
							selectedCell!.row,
							selectedCell!.col,
							(e.target as HTMLInputElement).value
						)}
					class="flex-1 rounded border border-gray-300 bg-white px-3 py-2 font-mono text-sm text-gray-900 placeholder:text-gray-400 focus:border-transparent focus:ring-2 focus:ring-blue-500 focus:outline-none"
					placeholder="Enter value or formula (e.g., =SUM(A1:A3))"
				/>
			</div>
		{/if}
	</div>
</ChallengeLayout>

<style>
	input:focus {
		outline: none;
	}

	input {
		color: rgb(31, 41, 55);
	}

	input::placeholder {
		color: rgb(156, 163, 175);
		font-style: italic;
	}

	.overflow-auto::-webkit-scrollbar {
		width: 12px;
		height: 12px;
	}

	.overflow-auto::-webkit-scrollbar-track {
		background: #f3f4f6;
		border-radius: 6px;
	}

	.overflow-auto::-webkit-scrollbar-thumb {
		background: #9ca3af;
		border-radius: 6px;
	}

	.overflow-auto::-webkit-scrollbar-thumb:hover {
		background: #6b7280;
	}

	.cursor-cell {
		cursor: cell;
	}
</style>
