<script lang="ts">
	// that took me way longer than i expected, if prev. took me like 1+ hour, to google all html elements and figure out svelte/ts errors,
	// that task took me days.. well i googled and lerned a lot about svg and accessability things.. arial lables will be in my nightmares now. X_X
	// but i am happy with a result, and comparing to my prev. tasks  this one looks much more nicer

	import ChallengeLayout from '$lib/components/challengeLayout.svelte';

	type Circle = {
		r: number;
		cx: number;
		cy: number;
		id: string;
		color: string;
	};

	type Command =
		| { type: 'add'; circle: Circle }
		| { type: 'resize'; circleId: string; oldRadius: number; newRadius: number }
		| { type: 'clear'; circles: Circle[] };

	type HistoryEntry = {
		command: Command;
		timestamp: number;
	};

	const CANVAS_WIDTH = 600;
	const CANVAS_HEIGHT = 400;
	const DEFAULT_RADIUS = 15;
	const MIN_RADIUS = 5;
	const MAX_RADIUS = 50;
	const COLORS = ['#f87171', '#60a5fa', '#34d399', '#a78bfa', '#fbbf24'];

	let circles: Circle[] = $state([]);
	let nextCircleId = 1;
	let history: HistoryEntry[] = $state([]);
	let historyIndex = $state(-1);
	let mousePosition = $state({ x: 0, y: 0 });
	let svgMousePosition = $state({ x: 0, y: 0 });
	let isMouseOverCanvas = $state(false);
	let hoveredCircle: Circle | null = $state(null);
	let selectedCircle: Circle | null = $state(null);
	let isDiameterModalOpen = $state(false);
	let tempRadius = $state(DEFAULT_RADIUS);
	let svgElement: SVGSVGElement;

	// $inspect('Canvas State:', {
	// 	circles: circles.length,
	// 	history: history.length,
	// 	historyIndex,
	// 	canUndo: historyIndex >= 0,
	// 	canRedo: historyIndex < history.length - 1
	// });

	function getSvgCoordinates(event: MouseEvent): { x: number; y: number } | null {
		if (!svgElement) return null;

		const rect = svgElement.getBoundingClientRect();
		return {
			x: event.clientX - rect.left,
			y: event.clientY - rect.top
		};
	}

	function getDistance(x1: number, y1: number, x2: number, y2: number): number {
		const dx = x1 - x2;
		const dy = y1 - y2;
		return Math.sqrt(dx * dx + dy * dy);
	}

	function isPointInCircle(x: number, y: number, circle: Circle): boolean {
		const distance = getDistance(x, y, circle.cx, circle.cy);
		return distance <= circle.r;
	}

	function executeCommand(command: Command) {
		if (historyIndex < history.length - 1) {
			history = history.slice(0, historyIndex + 1);
		}

		switch (command.type) {
			case 'add':
				circles = [...circles, command.circle];
				break;

			case 'resize':
				circles = circles.map((c) =>
					c.id === command.circleId ? { ...c, r: command.newRadius } : c
				);
				break;
			case 'clear':
				circles = [];
				break;
		}

		history = [...history, { command, timestamp: Date.now() }];
		historyIndex = history.length - 1;
	}

	function undo() {
		if (historyIndex < 0) return;

		const entry = history[historyIndex];
		const command = entry.command;

		switch (command.type) {
			case 'add':
				circles = circles.filter((c) => c.id !== command.circle.id);
				break;

			case 'resize':
				circles = circles.map((c) =>
					c.id === command.circleId ? { ...c, r: command.oldRadius } : c
				);
				break;
			case 'clear':
				circles = command.circles;
				break;
		}

		historyIndex--;
	}

	function redo() {
		if (historyIndex >= history.length - 1) return;

		historyIndex++;
		const entry = history[historyIndex];
		const command = entry.command;

		switch (command.type) {
			case 'add':
				circles = [...circles, command.circle];
				break;

			case 'resize':
				circles = circles.map((c) =>
					c.id === command.circleId ? { ...c, r: command.newRadius } : c
				);
				break;
			case 'clear':
				circles = [];
				break;
		}
	}

	function handleMouseMove(event: MouseEvent) {
		mousePosition = { x: event.clientX, y: event.clientY };

		const coords = getSvgCoordinates(event);
		if (coords) {
			svgMousePosition = coords;
		}
	}

	function handleCanvasClick(event: MouseEvent) {
		if (hoveredCircle) return;

		const coords = getSvgCoordinates(event);
		if (coords) {
			const newCircle: Circle = {
				r: DEFAULT_RADIUS,
				cx: coords.x,
				cy: coords.y,
				id: `circle-${nextCircleId++}`,
				color: getRandomColor()
			};

			executeCommand({ type: 'add', circle: newCircle });
		}
	}

	function handleCanvasKeyDown(event: KeyboardEvent) {
		switch (event.key) {
			case 'Enter':
			case ' ':
				event.preventDefault();
				if (hoveredCircle) {
					openDiameterModal(hoveredCircle);
				} else {
					const x = isMouseOverCanvas ? svgMousePosition.x : CANVAS_WIDTH / 2;
					const y = isMouseOverCanvas ? svgMousePosition.y : CANVAS_HEIGHT / 2;
					createCircleAt(x, y);
				}
				break;
		}
	}

	function handleGlobalKeyDown(event: KeyboardEvent) {
		if ((event.ctrlKey || event.metaKey) && event.key.toLowerCase() === 'z') {
			event.preventDefault();
			event.shiftKey ? redo() : undo();
		}
	}

	function handleCanvasMouseEnter() {
		isMouseOverCanvas = true;
	}

	function handleCanvasMouseLeave() {
		isMouseOverCanvas = false;
	}

	function createCircleAt(x: number, y: number) {
		const newCircle: Circle = {
			r: DEFAULT_RADIUS,
			cx: x,
			cy: y,
			id: `circle-${nextCircleId++}`,
			color: getRandomColor()
		};
		executeCommand({ type: 'add', circle: newCircle });
	}

	function handleAddRandomCircle() {
		const x = Math.floor(Math.random() * CANVAS_WIDTH);
		const y = Math.floor(Math.random() * CANVAS_HEIGHT);
		createCircleAt(x, y);
	}

	function getRandomColor(): string {
		return COLORS[Math.floor(Math.random() * COLORS.length)];
	}

	function handleClearAll() {
		if (circles.length > 0) {
			executeCommand({ type: 'clear', circles: [...circles] });
		}
	}

	function handleContextMenu(event: MouseEvent) {
		event.preventDefault();

		const coords = getSvgCoordinates(event);
		if (coords) {
			for (let i = circles.length - 1; i >= 0; i--) {
				const circle = circles[i];
				if (isPointInCircle(coords.x, coords.y, circle)) {
					openDiameterModal(circle);
					return;
				}
			}
		}
	}

	function openDiameterModal(circle: Circle) {
		selectedCircle = circle;
		tempRadius = circle.r;
		isDiameterModalOpen = true;
	}

	function handleApplyDiameterChange() {
		if (selectedCircle) {
			const oldRadius = selectedCircle.r;
			executeCommand({
				type: 'resize',
				circleId: selectedCircle.id,
				oldRadius: oldRadius,
				newRadius: tempRadius
			});
		}
		closeDiameterModal();
	}

	function closeDiameterModal() {
		isDiameterModalOpen = false;
		selectedCircle = null;
	}

	function findCircleAt(x: number, y: number): Circle | null {
		for (let i = circles.length - 1; i >= 0; i--) {
			if (isPointInCircle(x, y, circles[i])) {
				return circles[i];
			}
		}
		return null;
	}
</script>

<svelte:window onmousemove={handleMouseMove} onkeydown={handleGlobalKeyDown} />

<ChallengeLayout
	title="Circle Drawer"
	challenge="Challenge: undo/redo, custom drawing, dialog control.*"
	description="The task is to build a frame containing an undo and redo button as well as a canvas area underneath. Left-clicking inside an empty area inside the canvas will create an unfilled circle with a fixed diameter whose center is the left-clicked point. The circle nearest to the mouse pointer such that the distance from its center to the pointer is less than its radius, if it exists, is filled with the color gray. The gray circle is the selected circle C. Right-clicking C will make a popup menu appear with one entry 'Adjust diameter..'. Clicking on this entry will open another frame with a slider inside that adjusts the diameter of C. Changes are applied immediately. Closing this frame will mark the last diameter as significant for the undo/redo history. Clicking undo will undo the last significant change (i.e. circle creation or diameter adjustment). Clicking redo will reapply the last undone change unless new changes were made by the user in the meantime."
	image="circledraw.png"
>
	<div class="relative flex flex-col items-center justify-center gap-4 p-4">
		<div class="stats bg-base-200 shadow">
			<div class="stat">
				<div class="stat-title">Mouse Position</div>
				<div class="stat-value text-lg">
					({Math.round(svgMousePosition.x)}, {Math.round(svgMousePosition.y)})
				</div>
				<div class="stat-desc">Canvas coordinates</div>
			</div>
			<div class="stat">
				<div class="stat-title">Circles</div>
				<div class="stat-value text-lg">{circles.length}</div>
				<div class="stat-desc">Total placed</div>
			</div>
			<div class="stat">
				<div class="stat-title">History</div>
				<div class="stat-value text-lg">{historyIndex + 1}/{history.length}</div>
				<div class="stat-desc">Commands</div>
			</div>
		</div>

		<div class="card card-bordered bg-base-100 shadow-lg">
			<button
				onclick={handleCanvasClick}
				oncontextmenu={handleContextMenu}
				onkeydown={handleCanvasKeyDown}
				onmouseenter={handleCanvasMouseEnter}
				onmouseleave={handleCanvasMouseLeave}
				class="focus:ring-primary cursor-crosshair rounded-lg p-0 focus:ring-2 focus:outline-none"
				aria-label={`Drawing canvas with ${circles.length} circles. ${hoveredCircle ? `Circle at ${Math.round(hoveredCircle.cx)}, ${Math.round(hoveredCircle.cy)} hovered` : 'Click to place a circle'}`}
				aria-describedby="canvas-instructions"
			>
				<svg
					bind:this={svgElement}
					height={CANVAS_HEIGHT}
					width={CANVAS_WIDTH}
					class="rounded-lg"
					style="box-shadow: inset 0 0 0 2px rgba(0, 0, 0, 0.1);"
				>
					<rect width="100%" height="100%" fill="white" class="rounded-lg" />

					{#if isMouseOverCanvas && !hoveredCircle}
						<circle
							cx={svgMousePosition.x}
							cy={svgMousePosition.y}
							r={DEFAULT_RADIUS}
							fill="gray"
							opacity="0.3"
							pointer-events="none"
						/>
					{/if}

					{#each circles as circle (circle.id)}
						<circle
							cx={circle.cx}
							cy={circle.cy}
							r={circle.r}
							fill={hoveredCircle?.id === circle.id ? '#9ca3af' : circle.color}
							stroke="#374151"
							stroke-width="2"
							class="cursor-pointer transition-all"
							role="button"
							tabindex="-1"
							aria-label={`Circle at position ${Math.round(circle.cx)}, ${Math.round(circle.cy)}`}
							onmouseenter={() => (hoveredCircle = circle)}
							onmouseleave={() => (hoveredCircle = null)}
						/>
					{/each}
				</svg>
			</button>
		</div>

		<div class="flex flex-wrap justify-center gap-2">
			<div class="join">
				<button onclick={undo} class="btn btn-outline join-item" disabled={historyIndex < 0}>
					<svg
						xmlns="http://www.w3.org/2000/svg"
						class="h-5 w-5"
						fill="none"
						viewBox="0 0 24 24"
						stroke="currentColor"
					>
						<path
							stroke-linecap="round"
							stroke-linejoin="round"
							stroke-width="2"
							d="M3 10h10a8 8 0 018 8v2M3 10l6 6m-6-6l6-6"
						/>
					</svg>
					Undo
				</button>
				<button
					onclick={redo}
					class="btn btn-outline join-item"
					disabled={historyIndex >= history.length - 1}
				>
					<svg
						xmlns="http://www.w3.org/2000/svg"
						class="h-5 w-5"
						fill="none"
						viewBox="0 0 24 24"
						stroke="currentColor"
					>
						<path
							stroke-linecap="round"
							stroke-linejoin="round"
							stroke-width="2"
							d="M21 10h-10a8 8 0 00-8 8v2M21 10l-6 6m6-6l-6-6"
						/>
					</svg>
					Redo
				</button>
			</div>

			<button onclick={handleAddRandomCircle} class="btn btn-primary">
				<svg
					xmlns="http://www.w3.org/2000/svg"
					class="h-5 w-5"
					fill="none"
					viewBox="0 0 24 24"
					stroke="currentColor"
				>
					<path
						stroke-linecap="round"
						stroke-linejoin="round"
						stroke-width="2"
						d="M12 4v16m8-8H4"
					/>
				</svg>
				Add Random
			</button>

			<button
				onclick={handleClearAll}
				class="btn btn-error btn-outline"
				disabled={circles.length === 0}
			>
				<svg
					xmlns="http://www.w3.org/2000/svg"
					class="h-5 w-5"
					fill="none"
					viewBox="0 0 24 24"
					stroke="currentColor"
				>
					<path
						stroke-linecap="round"
						stroke-linejoin="round"
						stroke-width="2"
						d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"
					/>
				</svg>
				Clear All
			</button>
		</div>

		{#if isDiameterModalOpen && selectedCircle}
			<dialog class="modal modal-open">
				<div class="modal-box">
					<h3 class="mb-4 text-lg font-bold">Adjust Circle Diameter</h3>

					<div class="mb-6 flex justify-center">
						<svg width="200" height="200" class="border-base-300 rounded-lg border">
							<rect fill="white" width="100%" height="100%" />
							<circle
								cx="100"
								cy="100"
								r={tempRadius}
								fill={selectedCircle.color}
								stroke="#374151"
								stroke-width="2"
							/>
						</svg>
					</div>

					<div class="form-control">
						<label for="radius-input" class="label">
							<span class="label-text">Diameter: {tempRadius * 2}px</span>
							<span class="label-text-alt">Radius: {tempRadius}px</span>
						</label>
						<input
							id="radius-input"
							type="range"
							min={MIN_RADIUS}
							max={MAX_RADIUS}
							step="1"
							bind:value={tempRadius}
							class="range range-primary w-full"
							aria-label="Circle radius"
						/>
						<div class="mt-1 flex w-full justify-between px-2 text-xs">
							<span>{MIN_RADIUS * 2}px</span>
							<span>{DEFAULT_RADIUS * 2}px</span>
							<span>{MAX_RADIUS * 2}px</span>
						</div>
					</div>

					<div class="modal-action">
						<button class="btn btn-ghost" onclick={closeDiameterModal}> Cancel </button>
						<button class="btn btn-primary" onclick={handleApplyDiameterChange}> Apply </button>
					</div>
				</div>

				<form method="dialog" class="modal-backdrop">
					<button type="button" onclick={closeDiameterModal}>close</button>
				</form>
			</dialog>
		{/if}

		<div id="canvas-instructions" class="alert alert-info max-w-lg">
			<svg
				xmlns="http://www.w3.org/2000/svg"
				fill="none"
				viewBox="0 0 24 24"
				class="h-6 w-6 shrink-0 stroke-current"
			>
				<path
					stroke-linecap="round"
					stroke-linejoin="round"
					stroke-width="2"
					d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
				></path>
			</svg>
			<div class="text-sm">
				<p>• Click to place circles</p>
				<p>• Right-click circles to adjust diameter</p>
				<p>• Ctrl+Z for undo, Ctrl+Shift+Z for redo</p>
			</div>
		</div>
	</div>
</ChallengeLayout>
