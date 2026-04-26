require('lualine').setup({
  options = {
    theme = 'auto',
    component_separators = { left = '|', right = '|'},
    section_separators = { left = '', right = ''},
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch'},
    lualine_c = {
      {
        'filename',
        path = 1,
        file_status = true,
      }
    },
    lualine_x = {'filetype'},
    lualine_y = {'progress'},
    lualine_z = {
      -- The Clock: %H:%M is time, %d-%b is date
      { 'datetime', style = '%H:%M | %d-%m-%Y' } 
    },
  },
})

