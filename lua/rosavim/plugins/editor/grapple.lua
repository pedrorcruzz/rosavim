return {

  'cbochs/grapple.nvim',
  opts = {
    scope = 'git', -- also try out "git_branch"
    icons = false, -- setting to "true" requires "nvim-web-devicons"
    status = false,
  },
  keys = {
    { '<leader>oo', '<cmd>Grapple toggle<cr>', desc = 'Grapple: Tag a file' },
    { '<leader>oe', '<cmd>Grapple toggle_tags<cr>', desc = 'Grapple: Menu Tag' },

    { '<leader>o1', '<cmd>Grapple select index=1<cr>', desc = 'Grapple: First Tag' },
    { '<leader>o2', '<cmd>Grapple select index=2<cr>', desc = 'Grapple: Second Tag' },
    { '<leader>o3', '<cmd>Grapple select index=3<cr>', desc = 'Grapple: Third Tag' },
    { '<leader>o4', '<cmd>Grapple select index=4<cr>', desc = 'Grapple: Fourth Tag' },
    { '<leader>o5', '<cmd>Grapple select index=5<cr>', desc = 'Grapple: Fifth Tag' },
    { '<leader>o6', '<cmd>Grapple select index=6<cr>', desc = 'Grapple: Sixth Tag' },
    { '<leader>o7', '<cmd>Grapple select index=7<cr>', desc = 'Grapple: Seventh Tag' },
    { '<leader>o8', '<cmd>Grapple select index=8<cr>', desc = 'Grapple: Eighth Tag' },
    { '<leader>o9', '<cmd>Grapple select index=9<cr>', desc = 'Grapple: Ninth Tag' },
    { '<leader>o0', '<cmd>Grapple select index=10<cr>', desc = 'Grapple: Tenth Tag' },
    { '<leader>of', '<cmd>Telescope grapple tags<cr>', desc = 'Grapple: Telescope' },

    { '<leader>oa', '<cmd>Grapple cycle_tags prev<cr>', desc = 'Grapple: Previous Tag' },
    { '<leader>os', '<cmd>Grapple cycle_tags next<cr>', desc = 'Grapple: Next Tag' },
  },
}
