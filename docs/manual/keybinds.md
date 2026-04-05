# Keybindings Reference

> Leader key: `<Space>` | Modes: **n** = normal, **i** = insert, **v** = visual, **x** = visual block, **t** = terminal, **o** = operator-pending, **c** = command

## Table of Contents

- [Core](#core)
- [File & Project Navigation](#file--project-navigation)
- [Search & Find](#search--find)
- [LSP](#lsp)
- [Window Management](#window-management)
- [Tabs & Buffers](#tabs--buffers)
- [Git](#git)
- [Testing](#testing)
- [Debugging](#debugging)
- [Formatting & Code Actions](#formatting--code-actions)
- [Refactoring](#refactoring)
- [Terminal](#terminal)
- [AI (Copilot & Sidekick)](#ai-copilot--sidekick)
- [File Operations](#file-operations)
- [Rosapoon (Bookmarks)](#rosapoon-bookmarks)
- [Flash (Motion)](#flash-motion)
- [Yank & Paste (Yanky)](#yank--paste-yanky)
- [UI & Appearance](#ui--appearance)
- [Diagnostics (Trouble)](#diagnostics-trouble)
- [Database (Dadbod)](#database-dadbod)
- [Search & Replace (GrugFar)](#search--replace-grugfar)
- [Obsidian (Notes)](#obsidian-notes)
- [Laravel](#laravel)
- [Spelling](#spelling)
- [Lazy (Plugin Manager)](#lazy-plugin-manager)
- [Miscellaneous](#miscellaneous)

---

## Core

| Mode | Key | Action | Example |
|:----:|:----|:-------|:--------|
| i | `kj` | Exit insert mode | Type `kj` quickly instead of reaching for `<Esc>` |
| n | `<BS>` | Switch to last buffer | Press backspace to toggle between your two most recent files |
| x | `<C-j>` | Move selection down | Select lines in visual mode, then `Ctrl+j` to move them down |
| x | `<C-k>` | Move selection up | Select lines in visual mode, then `Ctrl+k` to move them up |
| n | `<A-Down>` | Move current line down | Press `Alt+Down` to swap the current line with the one below |
| n | `<leader>w` | Save file | `Space w` to quick-save |
| n | `<leader>W` | Save without formatting | `Space Shift+w` to save without triggering format-on-save |
| n | `<leader>h` | Clear search highlight | `Space h` after a search to remove all highlights |
| n | `<leader>q` | Quit | `Space q` to close with confirmation |

---

## File & Project Navigation

| Mode | Key | Action | Example |
|:----:|:----|:-------|:--------|
| n | `<leader>e` | File Explorer | `Space e` opens the sidebar file tree — navigate with `j/k`, open with `<CR>` |
| n | `<leader>y` | Yazi file manager | `Space y` opens Yazi in a floating window for full file management |
| n | `<leader><space>` | Find files | `Space Space` then type part of a filename to fuzzy-find it |
| n | `<leader>fs` | Smart find | `Space f s` uses smart context to find the most relevant files |
| n | `<leader>ff` | Find files | `Space f f` opens the file picker |
| n | `<leader>fb` | Find buffers | `Space f b` to switch between open buffers |
| n | `<leader>fg` | Find git files | `Space f g` to search only git-tracked files |
| n | `<leader>fr` | Recent files | `Space f r` to open recently edited files |
| n | `<leader>fc` | Find config file | `Space f c` to quickly jump to a Rosavim config file |
| n | `<leader>fp` | Discover projects | `Space f p` to browse and switch between projects |
| n | `<leader>;` | Dashboard | `Space ;` returns to the Rosavim dashboard |

---

## Search & Find

| Mode | Key | Action | Example |
|:----:|:----|:-------|:--------|
| n | `<leader>sg` | Grep | `Space s g` then type a pattern — searches across all project files |
| n | `<leader>sb` | Grep buffers | `Space s b` to search only within open buffers |
| n,x | `<leader>sw` | Grep word | `Space s w` greps the word under cursor or visual selection |
| n | `<leader>/` | Buffer lines | `Space /` to fuzzy-search within the current buffer |
| n | `<leader>:` | Command history | `Space :` to browse and re-run previous commands |
| n | `<leader>s/` | Search history | `Space s /` to browse previous search patterns |
| n | `<leader>sc` | Command history | `Space s c` as an alternative to access command history |
| n | `<leader>sC` | Commands | `Space s Shift+c` to browse all available commands |
| n | `<leader>sd` | Diagnostics | `Space s d` to search all project diagnostics |
| n | `<leader>sD` | Buffer diagnostics | `Space s Shift+d` for current buffer diagnostics only |
| n | `<leader>sH` | Help pages | `Space s Shift+h` to search Neovim help documentation |
| n | `<leader>sh` | Highlights | `Space s h` to browse highlight groups |
| n | `<leader>si` | Icons | `Space s i` to search and insert icons |
| n | `<leader>sj` | Jumps | `Space s j` to browse the jump list |
| n | `<leader>sk` | Keymaps | `Space s k` to search all keybindings |
| n | `<leader>sl` | Location list | `Space s l` to browse the location list |
| n | `<leader>sm` | Marks | `Space s m` to browse marks |
| n | `<leader>sM` | Man pages | `Space s Shift+m` to search man pages |
| n | `<leader>sp` | Plugin spec | `Space s p` to search lazy.nvim plugin specs |
| n | `<leader>sq` | Registers | `Space s q` to browse register contents |
| n | `<leader>sR` | Quickfix list | `Space s Shift+r` to browse the quickfix list |
| n | `<leader>su` | Undo history | `Space s u` to browse and restore from undo tree |
| n | `<leader>ss` | LSP symbols | `Space s s` to search symbols in the current buffer |
| n | `<leader>sS` | Workspace symbols | `Space s Shift+s` to search symbols across the workspace |

---

## LSP

| Mode | Key | Action | Example |
|:----:|:----|:-------|:--------|
| n | `gd` | Go to definition | On a function call, press `gd` to jump to where it's defined |
| n | `gD` | Go to declaration | Press `gD` to jump to the symbol's declaration |
| n | `gr` | References | On a function name, press `gr` to see all usages across the project |
| n | `gI` | Go to implementation | On an interface method, press `gI` to find its implementations |
| n | `gy` | Go to type definition | Press `gy` to jump to the type definition of the symbol |
| n | `gp` | Rosapreview: Definition | Press `gp` to see the definition in a floating preview window |
| n | `gP` | Rosapreview: Close All | Press `gP` to close all preview windows |
| n | `<leader>lr` | Rename symbol | `Space l r` on a variable, type the new name — renames across the project |
| n | `<leader>la` | Code action | `Space l a` to see available code actions (imports, fixes, refactors) |
| n | `<leader>lv` | Rename file | `Space l v` to rename the current file and update all imports |
| n | `<leader>lo` | Toggle outline | `Space l o` to open/close a code outline sidebar |
| n | `<leader>Q` | Rosapreview: Expand Vsplit | Open the preview definition in a vertical split |
| n | `<leader>M` | Rosapreview: Replace Window | Open the preview definition replacing the current window |

---

## Window Management

| Mode | Key | Action | Example |
|:----:|:----|:-------|:--------|
| n | `<C-h>` | Move to left split | `Ctrl+h` to move focus to the window on the left |
| n | `<C-j>` | Move to below split | `Ctrl+j` to move focus to the window below |
| n | `<C-k>` | Move to above split | `Ctrl+k` to move focus to the window above |
| n | `<C-l>` | Move to right split | `Ctrl+l` to move focus to the window on the right |
| n | `<left>` | Resize left | Arrow left to shrink/grow the split horizontally |
| n | `<down>` | Resize down | Arrow down to adjust split height |
| n | `<up>` | Resize up | Arrow up to adjust split height |
| n | `<right>` | Resize right | Arrow right to shrink/grow the split horizontally |
| n | `<leader>cq` | Split vertical | `Space c q` to create a vertical split |
| n | `<leader>ce` | Split horizontal | `Space c e` to create a horizontal split |
| n | `<leader>cc` | Close window | `Space c c` to close the current window |
| n | `<leader>cC` | Close all others | `Space c Shift+c` to close all windows except the current one |
| n | `<leader>ch` | Swap left | `Space c h` to swap the current window to the left |
| n | `<leader>cl` | Swap right | `Space c l` to swap the current window to the right |
| n | `<leader>ck` | Swap up | `Space c k` to swap the current window up |
| n | `<leader>cj` | Swap down | `Space c j` to swap the current window down |
| n | `<leader>c1` | Resize left 1/3 | Resize the current window to occupy 1/3 from the left |
| n | `<leader>c2` | Resize right 2/3 | Resize the current window to occupy 2/3 from the right |
| n | `<leader>c3` | Resize up 1/3 | Resize the current window to occupy 1/3 from the top |
| n | `<leader>c4` | Resize down 2/3 | Resize the current window to occupy 2/3 from the bottom |
| n | `<leader>cr` | Reset window sizes | Reset all windows to equal sizes |
| n | `<leader>1` | Focus left window | `Space 1` to jump to the left window |
| n | `<leader>2` | Focus right window | `Space 2` to jump to the right window |
| n | `<leader>3` | Focus bottom window | `Space 3` to jump to the bottom window |
| n | `<leader>4` | Focus top window | `Space 4` to jump to the top window |
| n | `<leader>m` | Pick a window | `Space m` to visually pick which window to focus |

---

## Tabs & Buffers

| Mode | Key | Action | Example |
|:----:|:----|:-------|:--------|
| n | `<leader>J` | Previous buffer | `Space Shift+j` to go to the previous buffer |
| n | `<leader>K` | Next buffer | `Space Shift+k` to go to the next buffer |
| n | `<leader>tt` | New tab | `Space t t` to create a new tab |
| n | `<leader>tj` | Previous tab | `Space t j` to go to the previous tab |
| n | `<leader>tk` | Next tab | `Space t k` to go to the next tab |
| n | `<leader>tc` | Close tab | `Space t c` to close the current tab |
| n | `<leader>tC` | Close other tabs | `Space t Shift+c` to close all tabs except the current one |
| n | `<leader>t1`-`t0` | Go to tab N | `Space t 1` through `t 0` to jump to tab 1-10 |
| n | `<leader>tf` | Pick tab (Snacks) | `Space t f` to open a tab picker and switch tabs |
| n | `<leader>st` | Pick tab (Snacks) | `Space s t` to open a tab picker and switch tabs |
| n | `<leader>fw` | Pick tab (Snacks) | `Space f w` to open a tab picker and switch tabs |

---

## Git

| Mode | Key | Action | Example |
|:----:|:----|:-------|:--------|
| n | `<leader>gt` | Toggle line blame | `Space g t` to show/hide inline blame on the current line |
| n | `<leader>gl` | Blame line (float) | `Space g l` to see blame info in a floating window |
| n | `<leader>gg` | Lazygit | `Space g g` to open lazygit in a floating terminal |
| n | `<leader>gc` | Git log | `Space g c` to browse the commit log |
| n | `<leader>gb` | Git branches | `Space g b` to browse and switch branches |
| n | `<leader>gs` | Git status | `Space g s` to see the current git status |
| n | `<leader>gS` | Git stash | `Space g Shift+s` to browse stashed changes |
| n | `<leader>gd` | Git diff (hunks) | `Space g d` to browse diff hunks |
| n | `<leader>gf` | Git log (file) | `Space g f` to see the git log for the current file |
| n | `<leader>gL` | Git log (line) | `Space g Shift+l` to see the git log for the current line |

---

## Testing

| Mode | Key | Action | Example |
|:----:|:----|:-------|:--------|
| n | `<leader>nn` | Rosatest menu | `Space n n` with cursor inside a test function to run just that test |
| n | `<leader>nf` | Run file tests | `Space n f` to run all tests in the current file |
| n | `<leader>nl` | Run last test | `Space n l` to re-run the last executed test |
| n | `<leader>ns` | Stop tests | `Space n s` to stop currently running tests |
| n | `<leader>no` | Test output | `Space n o` to see the output of the last test run |
| n | `<leader>np` | Output panel | `Space n p` to open the test output panel |
| n | `<leader>nt` | Test summary | `Space n t` to toggle the test summary sidebar |
| n | `<leader>nw` | Watch file | `Space n w` to watch the file and re-run tests on save |
| n | `<leader>nga` | Go: Add test | `Space n g a` to generate a test for the current Go function |
| n | `<leader>ngA` | Go: Add all tests | `Space n g Shift+a` to generate tests for all Go functions in the file |

---

## Debugging

| Mode | Key | Action | Example |
|:----:|:----|:-------|:--------|
| n | `<leader>ds` | Start / Continue | `Space d s` to start the debugger or continue execution |
| n | `<leader>dq` | Terminate | `Space d q` to stop the debug session |
| n | `<leader>db` | Toggle breakpoint | `Space d b` on any line to set/remove a breakpoint |
| n | `<leader>dc` | Clear breakpoints | `Space d c` to remove all breakpoints |
| n | `<leader>dt` | Toggle DAP UI | `Space d t` to open/close the debug UI panels |
| n | `<leader>df` | DAP UI float | `Space d f` to open the debug UI in a floating window |
| n | `<leader>dd` | Step over | `Space d d` to execute the current line and move to the next |
| n | `<leader>di` | Step into | `Space d i` to step into a function call |
| n | `<leader>do` | Step out | `Space d o` to step out of the current function |
| n | `<leader>dp` | Pause | `Space d p` to pause a running debug session |
| n | `<leader>dr` | Rerun | `Space d r` to restart the debug session |
| n | `<leader>dR` | Restart frame | `Space d Shift+r` to restart the current stack frame |
| n | `<leader>dn` | New session | `Space d n` to start a new debug configuration |
| n | `<leader>de` | Eval expression | `Space d e` to evaluate an expression in the debug context |
| n | `<leader>dD` | Disconnect | `Space d Shift+d` to disconnect from the debug adapter |

---

## Formatting & Code Actions

| Mode | Key | Action | Example |
|:----:|:----|:-------|:--------|
| n,v | `<leader>lf` | Format file/selection | `Space l f` to format the current file — or select lines first to format only those |

---

## Refactoring

| Mode | Key | Action | Example |
|:----:|:----|:-------|:--------|
| n,x | `<leader>rr` | Select refactor | `Space r r` to open the refactoring menu |
| v | `<leader>rs` | Select refactor (visual) | Select code, then `Space r s` to pick a refactoring action |
| n,v | `<leader>ri` | Inline variable | `Space r i` on a variable to inline its value everywhere |
| n | `<leader>rb` | Extract block | `Space r b` to extract the current block into a new function |
| n | `<leader>rf` | Extract block to file | `Space r f` to extract the block into a new file |
| v | `<leader>rf` | Extract function | Select code, `Space r f` to extract into a new function |
| v | `<leader>rF` | Extract function to file | Select code, `Space r Shift+f` to extract into a new file |
| v | `<leader>rx` | Extract variable | Select an expression, `Space r x` to extract into a variable |
| n | `<leader>rP` | Debug print | `Space r Shift+p` to insert a debug print statement |
| n,v | `<leader>rp` | Debug print variable | `Space r p` to print the value of the variable under cursor |
| n | `<leader>rc` | Debug cleanup | `Space r c` to remove all debug print statements |

---

## Terminal

| Mode | Key | Action | Example |
|:----:|:----|:-------|:--------|
| n,t | `<C-\>` | Toggle terminal | `Ctrl+\` to open/close a floating terminal |
| n,t | `<S-x>` | Horizontal terminal | `Shift+x` to toggle a horizontal split terminal |
| n,t | `<S-z>` | Float terminal | `Shift+z` to toggle a floating terminal |
| n | `<leader>cii` | Horizontal split | `Space c i i` to open a horizontal terminal split |
| n | `<leader>cie` | Vertical split | `Space c i e` to open a vertical terminal split |

---

## AI (Copilot & Sidekick)

### Copilot

| Mode | Key | Action | Example |
|:----:|:----|:-------|:--------|
| i | `<Tab>` | Accept suggestion | While typing, press `Tab` to accept the Copilot suggestion |
| i | `<C-l>` | Next suggestion | `Ctrl+l` to cycle to the next Copilot suggestion |
| i | `<C-h>` | Previous suggestion | `Ctrl+h` to cycle to the previous Copilot suggestion |
| i | `<C-d>` | Dismiss suggestion | `Ctrl+d` to dismiss the current Copilot suggestion |
| n | `<leader>aia` | Auth | `Space a i a` to authenticate with GitHub Copilot |
| n | `<leader>aii` | Toggle | `Space a i i` to toggle Copilot on/off (persisted) |
| n | `<leader>aip` | Panel | `Space a i p` to open the Copilot suggestions panel |

### Sidekick

| Mode | Key | Action | Example |
|:----:|:----|:-------|:--------|
| n,t,i,x | `<C-.>` | Focus Sidekick | `Ctrl+.` to focus the Sidekick chat window |
| n | `<leader>aa` | Toggle CLI | `Space a a` to toggle the Sidekick CLI |
| x | `<leader>aa` | Ask AI (selection) | Select code, `Space a a` to type a question and send it with file context |
| n | `<leader>as` | Select CLI | `Space a s` to select which CLI backend to use |
| n | `<leader>ad` | Detach session | `Space a d` to close the current CLI session |
| n,x | `<leader>at` | Send this | `Space a t` to send the current context to Sidekick |
| n | `<leader>af` | Send file | `Space a f` to send the entire file to Sidekick |
| x | `<leader>av` | Send selection | Select code, `Space a v` to send it to Sidekick |
| n,x | `<leader>ap` | Select prompt | `Space a p` to pick from saved prompts |
| n | `<leader>ac` | Toggle Claude | `Space a c` to use Claude as the Sidekick backend |
| n | `<leader>ag` | Toggle Cursor | `Space a g` to use Cursor as the Sidekick backend |

---

## File Operations

| Mode | Key | Action | Example |
|:----:|:----|:-------|:--------|
| n | `<leader>xx` | Rosafile menu | `Space x x` to open the file operations popup |
| n | `<leader>xa` | Create file here | `Space x a` to create a file in the current directory |
| n | `<leader>xd` | Delete file | `Space x d` to delete the current file |
| n | `<leader>xn` | Rename file | `Space x n` to rename the current file |
| n | `<leader>xc` | Duplicate file | `Space x c` to duplicate the current file |
| n | `<leader>xi` | File info | `Space x i` to show current file information |
| n | `<leader>xr` | Create from root | `Space x r` to create a file from project root |

---

## Rosapoon (Bookmarks)

| Mode | Key | Action | Example |
|:----:|:----|:-------|:--------|
| n | `<leader>oo` | Pin | `Space o o` to pin/unpin the current file |
| n | `<leader>oe` | Menu | `Space o e` to manage pinned files (jump, delete, reorder) |
| n | `dd` (in menu) | Remove pin | In the Rosapoon menu, `dd` on a tag to remove it |
| v | `d` (in menu) | Remove selected | In the Rosapoon menu, select tags in visual mode and `d` to remove them |
| n | `DD` (in menu) | Remove all | In the Rosapoon menu, `DD` to remove all tags at once |
| n | `<leader>o1`-`o0` | Jump 1-10 | `Space o 1` to instantly jump to your first pinned file |
| n | `<leader>of` | Search | `Space o f` to fuzzy-search pinned files |
| n | `<leader>oj` | Prev | `Space o j` to cycle to the previous pin |
| n | `<leader>ok` | Next | `Space o k` to cycle to the next pin |

---

## Flash (Motion)

| Mode | Key | Action | Example |
|:----:|:----|:-------|:--------|
| n,x,o | `s` | Flash jump | Press `s` then type characters — labels appear for instant jumping |
| n,x,o | `S` | Flash treesitter | Press `Shift+s` to select treesitter nodes with labels |
| o | `r` | Remote flash | In operator-pending mode, `r` to flash-jump to a remote location |
| o,x | `R` | Treesitter search | `Shift+r` to search and select treesitter nodes |
| c | `<C-s>` | Toggle flash search | `Ctrl+s` in command mode to toggle flash for `/` searches |

---

## Yank & Paste (Yanky)

| Mode | Key | Action | Example |
|:----:|:----|:-------|:--------|
| n,x | `<leader>p` | Yank history | `Space p` to browse and paste from yank history |
| n,x | `y` | Yank | Works like normal `y` but saves to Yanky history |
| n,x | `p` | Put after | Paste after cursor with Yanky tracking |
| n,x | `P` | Put before | Paste before cursor with Yanky tracking |
| n | `[y` | Cycle forward | After pasting, `[y` to cycle through older yanks |
| n | `]y` | Cycle backward | After pasting, `]y` to cycle through newer yanks |
| n | `]p` | Put indented after | Paste after with automatic indentation |
| n | `[p` | Put indented before | Paste before with automatic indentation |
| n | `>p` | Put indent right | Paste and shift right |
| n | `<p` | Put indent left | Paste and shift left |
| n | `=p` | Put filtered after | Paste after applying a filter |
| n | `=P` | Put filtered before | Paste before applying a filter |

---

## UI & Appearance

| Mode | Key | Action | Example |
|:----:|:----|:-------|:--------|
| n | `<leader>lqt` | Toggle dark/light | `Space l q t` to switch between dark and light mode |
| n | `<leader>lqs` | Search colorscheme | `Space l q s` to pick a colorscheme from the list |
| n | `<leader>lqe` | Toggle transparent | `Space l q e` to toggle background transparency |
| n | `<leader>lw` | Toggle wrap | `Space l w` to toggle line wrapping |
| n | `<leader>lg` | Toggle relative numbers | `Space l g` to toggle relative line numbers |
| n | `<leader>ln` | Toggle line numbers | `Space l n` to toggle line numbers on/off |
| n | `<leader>lz` | Toggle zen mode | `Space l z` to enter distraction-free zen mode |
| n | `<leader>li` | Toggle indent guides | `Space l i` to toggle indent guide lines |
| n | `<leader>lk` | Toggle dim | `Space l k` to dim inactive code |
| n | `<leader>ll` | Toggle lualine | `Space l l` to show/hide the statusline |
| n | `<leader>lb` | Toggle dropbar | `Space l b` to show/hide the breadcrumb bar |
| n | `<leader>lt` | Toggle TSContext | `Space l t` to show/hide the treesitter context header |
| n | `<leader>lc` | Toggle Incline | `Space l c` to show/hide the floating filename indicator |
| n | `<leader>ls` | Toggle auto-save | `Space l s` to enable/disable auto-save |
| n | `<leader>lm` | Image preview | `Space l m` to preview an image in a floating window |
| n | `<leader>ut` | Toggle Markview | `Space u t` to toggle enhanced markdown rendering |
| n | `<leader>ua` | Markdown preview | `Space u a` to open markdown preview in the browser |
| n | `<leader>zz` | Pick winbar symbol | `Space z z` to pick a symbol from the breadcrumb bar |

---

## Diagnostics (Trouble)

| Mode | Key | Action | Example |
|:----:|:----|:-------|:--------|
| n | `<leader>,,` | Diagnostics | `Space , ,` to open the diagnostics panel for the whole project |
| n | `<leader>,x` | Buffer diagnostics | `Space , x` to see diagnostics for the current buffer only |
| n | `<leader>,s` | Symbols | `Space , s` to browse document symbols in Trouble |
| n | `<leader>,l` | LSP references | `Space , l` to see LSP definitions and references |
| n | `<leader>,g` | Location list | `Space , g` to browse the location list |
| n | `<leader>,q` | Quickfix list | `Space , q` to browse the quickfix list |

---

## Database (Dadbod)

| Mode | Key | Action | Example |
|:----:|:----|:-------|:--------|
| n | `<leader>vb` | Toggle DBUI | `Space v b` to open the database UI |
| n | `<leader>va` | Add connection | `Space v a` to add a new database connection string |
| n | `<leader>vf` | Find buffer | `Space v f` to find a specific query buffer |

---

## Search & Replace (GrugFar)

| Mode | Key | Action | Example |
|:----:|:----|:-------|:--------|
| n | `<leader>lee` | GrugFar | `Space l e e` to open the search & replace panel |
| n | `<leader>lei` | GrugFar (current file) | `Space l e i` to search & replace in the current file only |
| v | `<leader>lev` | GrugFar (selection) | Select text, `Space l e v` to search & replace the selection |
| n | `<leader>lew` | GrugFar (word) | `Space l e w` to search & replace the word under cursor |

---

## Todo Comments

| Mode | Key | Action | Example |
|:----:|:----|:-------|:--------|
| n | `]t` | Next todo | `]t` to jump to the next TODO/FIXME/HACK comment |
| n | `[t` | Previous todo | `[t` to jump to the previous TODO comment |
| n | `<leader>ftt` | Find all todos | `Space f t t` to search all TODO comments in the project |
| n | `<leader>ftf` | Find FIX | `Space f t f` to find all FIX/FIXME comments |
| n | `<leader>fte` | Find TODO | `Space f t e` to find all TODO comments |
| n | `<leader>ftn` | Find NOTE | `Space f t n` to find all NOTE comments |
| n | `<leader>fti` | Find INFO | `Space f t i` to find all INFO comments |
| n | `<leader>fth` | Find HACK | `Space f t h` to find all HACK comments |
| n | `<leader>ftw` | Find WARN | `Space f t w` to find all WARN comments |

---

## CodeSnap (Screenshots)

| Mode | Key | Action | Example |
|:----:|:----|:-------|:--------|
| x | `<leader>lP` | Snap to clipboard | Select code, `Space l Shift+p` to copy a screenshot to clipboard |
| x | `<leader>lp` | Snap to file | Select code, `Space l p` to save a screenshot |
| x | `<leader>lH` | Highlight to clipboard | Select code, `Space l Shift+h` for a highlighted screenshot |
| x | `<leader>lh` | Highlight to file | Select code, `Space l h` to save a highlighted screenshot |
| x | `<leader>la` | ASCII snap | Select code, `Space l a` for an ASCII art screenshot |

---

## Obsidian (Notes)

| Mode | Key | Action | Example |
|:----:|:----|:-------|:--------|
| n | `<leader>jj` | Search notes | `Space j j` to fuzzy-search all notes in your vault |
| n | `<leader>jo` | Open Obsidian | `Space j o` to open the Obsidian app |
| n | `<leader>jd` | Daily note | `Space j d` to open/create today's daily note |
| n | `<leader>jy` | Yesterday's note | `Space j y` to open yesterday's daily note |
| n | `<leader>jt` | Tomorrow's note | `Space j t` to open tomorrow's daily note |
| n | `<leader>jg` | List dailies | `Space j g` to browse all daily notes |
| n | `<leader>js` | Search (Obsidian) | `Space j s` to search notes using Obsidian's search |
| n | `<leader>jr` | Rename note | `Space j r` to rename the current note |
| n | `<leader>je` | Extract note | `Space j e` to extract a section into a new note |
| n | `<leader>jl` | Link new note | `Space j l` to create and link a new note |
| n | `<leader>ja` | From template | `Space j a` to create a note from a template |
| n | `<leader>jz` | New note | `Space j z` to create a blank note |
| n | `<leader>jb` | Backlinks | `Space j b` to see all notes linking to this one |
| n | `<leader>jp` | Paste image | `Space j p` to paste an image from clipboard |
| n | `<leader>jc` | Toggle checkbox | `Space j c` to toggle a checkbox in a markdown list |
| n | `<leader>jm` | Toggle checkbox (alt) | `Space j m` alternative checkbox toggle |

---

## Rosakit (Language Tools)

| Mode | Key | Action | Example |
|:----:|:----|:-------|:--------|
| n | `<leader>kk` | Rosakit menu | `Space k k` to open the language tools popup |
| n | `<leader>ka` | LSP Actions | `Space k a` to open LSP code actions |

---

## Spelling

| Mode | Key | Action | Example |
|:----:|:----|:-------|:--------|
| n | `<leader>ljj` | Toggle spell | `Space l j j` to enable/disable spell checking |
| n | `<leader>ljp` | Set Portuguese | `Space l j p` to switch spell checking to Portuguese |
| n | `<leader>lje` | Set English | `Space l j e` to switch spell checking to English |
| n | `<leader>ljl` | Spell suggestions | `Space l j l` to see spelling suggestions for the word under cursor |

---

## Lazy (Plugin Manager)

| Mode | Key | Action | Example |
|:----:|:----|:-------|:--------|
| n | `<leader>Ll` | Lazy | `Space Shift+l l` to open the Lazy plugin manager UI |
| n | `<leader>Lp` | Profile | `Space Shift+l p` to see plugin load times |
| n | `<leader>Lh` | Health | `Space Shift+l h` to run a health check |
| n | `<leader>LH` | Help | `Space Shift+l Shift+h` to open Lazy help |
| n | `<leader>Lb` | Build | `Space Shift+l b` to rebuild plugins |
| n | `<leader>Lc` | Clean | `Space Shift+l c` to remove unused plugins |
| n | `<leader>LC` | Clear | `Space Shift+l Shift+c` to clear the Lazy cache |
| n | `<leader>Lu` | Update | `Space Shift+l u` to update all plugins |
| n | `<leader>Ls` | Sync | `Space Shift+l s` to sync all plugins |

---

## Miscellaneous

| Mode | Key | Action | Example |
|:----:|:----|:-------|:--------|
| n | `<leader>R` | Rosavim | `Space Shift+r` to run the Rosavim command |
| n | `<leader>N` | Notification history | `Space Shift+n` to browse past notifications |
| n | `<leader>.` | Dismiss notification | `Space .` to dismiss the current notification |
| n | `<leader>lxs` | Select Python venv | `Space l x s` to pick a Python virtual environment |
