# WFC-Luau

This is a Luau implementation of the WFC algorithm.

**Warning: This is an experimental implementation and is not guaranteed to work without bugs.**

## Features & Limitations

### Features

- Supports infinite and finite grids
- Supports easy to use callbacks for customizing the algorithm
- Supports automatic ruleset generation from a sample map
- Supports custom rulesets
- Resolves contradictions(a.k.a. "dead ends") by DFS random walks

### Limitations

- Only supports orthogonal grids
- Only supports 2D grids currently (Please refer to Issues)
- Does not provide entropy calculation (Please refer to Issues again)
- Does not support custom weights for tiles

## Usage

### Installation

Recommended method: Git Submodule

```bash
git submodule add https://algasami/wfc-luau.git path/to/wfc-luau
```

### Example

to be added

## Issues

### 1. 2D grids only

- [ ] Support 3D grids
  - [ ] Permutations of 3D grids
  - [ ] 3D grid ruleset generation
  - [ ] Clean 3D grid DFS random walk

The algorithm is currently only implemented for 2D grids. This is because it is implemented recursively, and the recursion depth is limited by the stack size. This can be fixed by using a loop instead of recursion, but I haven't done that yet.
This is also an NP-hard problem, so it is likely that the algorithm will be slow for graphes with a large number of max edge combinations per node.

### 2. No entropy calculation

- [ ] Specify rendering agents
  - [ ] Entropy formula for 2D/3D grids
  - [ ] Calculate entropy of the chunk the rendering agents are resolving

Since the algorithm can work with infinitely large grids, it is not possible to calculate the entropy of the grid. This is because the entropy is defined as the number of possible states of the grid, and the number of possible states of an
infinitely large grid is undefined. However, it is possible to calculate the entropy of a finite grid(a.k.a the chunk the rendering agents are resolving), and this is something that I plan to implement in the future.

### 3. No custom weights

- [ ] Support custom weights for tiles
  - [ ] Specify weights for tiles in the ruleset
  - [ ] Add to the entropy formula

The algorithm currently does not support custom weights for tiles. I will add this feature in the future.

## License

MIT License
