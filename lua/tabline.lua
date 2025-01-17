-- nvim-tabline
-- David Zhang <https://github.com/crispgm>

local M = {}
local fn = vim.fn
local api = vim.api

M.options = {
    show_index = true,
    show_modify = true,
    show_icon = false,
    brackets = { '[', ']' },
    no_name = 'No Name',
    modify_indicator = '[+]',
    nvimtree_side = 'none'
}

local function NvimTreeSpace()
    local nvimTreeWidth = 0
    for _, win in pairs(api.nvim_tabpage_list_wins(0)) do
        if vim.bo[api.nvim_win_get_buf(win)].ft == 'NvimTree' then
            nvimTreeWidth = api.nvim_win_get_width(win) + 1
            return '%#NvimTreeNormal#' .. string.rep(' ', nvimTreeWidth)
        end
    end
    return ''
end

local function tabline(options)
    local s = ''
    for index = 1, fn.tabpagenr('$') do
        local winnr = fn.tabpagewinnr(index)
        local buflist = fn.tabpagebuflist(index)
        local bufnr = buflist[winnr]
        local bufname = fn.bufname(bufnr)
        local bufmodified = fn.getbufvar(bufnr, '&mod')

        s = s .. '%' .. index .. 'T'
        if index == fn.tabpagenr() then
            s = s .. '%#TabLineSel#'
        else
            s = s .. '%#TabLine#'
        end
        -- tab index
        s = s .. ' '
        -- index
        if options.show_index then
            s = s .. index .. ':'
        end
        -- icon
        local icon = ''
        if options.show_icon and M.has_devicons then
            local ext = fn.fnamemodify(bufname, ':e')
            icon = M.devicons.get_icon(bufname, ext, { default = true }) .. ' '
        end
        -- buf name
        s = s .. options.brackets[1]
        if bufname ~= '' then
            s = s .. icon .. fn.fnamemodify(bufname, ':t')
        else
            s = s .. options.no_name
        end
        s = s .. options.brackets[2] .. ' '
        -- modify indicator
        if
            bufmodified == 1
            and options.show_modify
            and options.modify_indicator ~= nil
        then
            s = s .. options.modify_indicator .. ' '
        end
    end

    s = s .. '%#TabLineFill#'

    if options.nvimtree_side == 'left' or options.nvimtree_side == 'right' then
        s = (options.nvimtree_side == 'left') and NvimTreeSpace() .. s or s.. NvimTreeSpace()
    end

    return s
end

function M.setup(user_options)
    M.options = vim.tbl_extend('force', M.options, user_options)
    M.has_devicons, M.devicons = pcall(require, 'nvim-web-devicons')

    function _G.nvim_tabline()
        return tabline(M.options)
    end

    vim.o.showtabline = 2
    vim.o.tabline = '%!v:lua.nvim_tabline()'

    vim.g.loaded_nvim_tabline = 1
end

return M
