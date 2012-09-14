" Vim plugin for GitHub integration
" Maintainer: Jon Tai <jon.tai@gmail.com>
" License: MIT License

if exists("githublink_loaded")
  finish
endif
let githublink_loaded = 1

if !exists("g:githublink_git_remote")
  let g:githublink_git_remote = "origin"
endif

" Change directories to the directory of the file we're editing, then execute a command
function s:Cd(command)
  return system("cd " . shellescape(expand("%:p:h")) . " && " . a:command)
endfunction

" Get the value of a git config option
function s:GitConfig(name)
  let value = s:Cd("git config " . shellescape(a:name))
  let value = substitute(value, "\n$", "", "")
  return value
endfunction

" Get the name of the current branch we're on
function s:GitBranch()
  let head = s:Cd("git symbolic-ref HEAD")
  let head = substitute(head, "^refs/heads/", "", "")
  let head = substitute(head, "\n$", "", "")
  return head
endfunction

" Get the root directory of the current repository
function s:GitRoot()
  let root = s:Cd("git rev-parse --show-toplevel")
  let root = substitute(root, "\n$", "", "")
  return root
endfunction

" Figure out the base URL on github.com for the current repository
function s:BaseUrl()
  let url = s:GitConfig("remote." . g:githublink_git_remote . ".url")
  let url = substitute(url, "^https://github.com/", "", "")
  let url = substitute(url, "^git@github.com:", "", "")
  let url = substitute(url, "\.git$", "", "")
  return "https://github.com/" . url
endfunction

" Figure out the URL of the file we're editing on github.com
function s:FileUrl()
  let path = expand("%:p")
  let path = substitute(path, "^" . s:GitRoot(), "", "")
  return s:BaseUrl() . "/blob/" . s:GitBranch() . path . "#L" . line(".")
endfunction

" Type backslash g in command mode to display the github.com URL of the current line
if !hasmapto("<Plug>GitHubLinkFileUrl")
  map <unique> <Leader>g <Plug>GitHubLinkFileUrl
endif

noremap <unique> <script> <Plug>GitHubLinkFileUrl <SID>FileUrl <SID>Copy
noremap <SID>FileUrl :redir @a <BAR> echo <SID>FileUrl() <BAR> redir END<CR>
noremap <SID>Copy :call system('pbcopy', @a) <BAR> echo @a <CR>
