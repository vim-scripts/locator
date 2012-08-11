
" TODO: кешировать все найденные элементы для конкретного буфера (но, видимо,
"       кеш придется сбрасывать при любом изменении буфера. Может, и вообще не
"       стОит заморачиваться.)
"
"  *) Issue: Если в файле есть folds, то после выполнения gl номер самой
"  верхней строки может отличаться. 
"  
"  *) сделать так, чтобы выводом каждого типа занималась польз. ф-ция
"  *) добавить sections, сортировать sections
"  *) customizable highlights
"




" **********************************************************************************
"  DATA
" **********************************************************************************


         "\        'get_end__eval' : 'call search("\\v\\{\\{\\{", "cW") | normal %',
                  "\        'get_end__eval' : 'let _iTmp = foldclosedend(".") | if _iTmp == -1 | normal! ]z | else | exe "normal "._iTmp."gg" | endif | unlet _iTmp ',

let s:dItem_fold = {
         \     'detect_type' : 'matchable',
         \     'detect_data' : {
         \        'start_regexp'  : '\v\{\{\{',
         \        'get_end__eval' : 'call Locator_GoToFoldEnd()',
         \     },
         \     'echo_type'   : 'func',
         \     'echo_data' : {
         \        'func_name' : 'Locator_EchoItem_Fold',
         \     },
         \     'flags'   : 'c',
         \  }

let s:dItem_java_class = {
         \     'detect_type' : 'matchable',
         \     'detect_data' : {
         \        'start_regexp'  : '\v^(\s*([a-z]))*\s*(class|interface)[ \t\n]+[_a-zA-Z0-9]+([ \t\n]*[a-zA-Z0-9_.,:])*[ \t\n]*\{',
         \        'get_end__eval' : 'call search("\\v\\{", "cW") | normal %',
         \     },
         \     'echo_type'   : 'func',
         \     'echo_data' : {
         \        'func_name' : 'Locator_EchoItem_JavaClass',
         \     },
         \     'flags'   : 'C',
         \  }

let s:dItem_C_func = {
         \     'detect_type' : 'matchable',
         \     'detect_data' : {
         \        'start_regexp' : '\v^(\s*([a-z]))*\s*[_a-zA-Z0-9*.\[\]:<>]+[ \t\n]+[_a-zA-Z0-9*:]+[ \t\n]*\([^{]+[ \t\n]*\{',
         \        'get_end__eval' : 'call search("\\v\\{", "cW") | normal %',
         \     },
         \     'echo_type'   : 'func',
         \     'echo_data' : {
         \        'func_name' : 'Locator_EchoItem_C_Func',
         \     },
         \     'flags'   : 'C',
         \  }

let s:dItem_vim_function = {
         \     'detect_type' : 'matchable',
         \     'detect_data' : {
         \        'start_regexp' : '\v^\s*<fu%[nction]>\!{0,1}\s+[^(]+\([^)]*\)',
         \        'get_end__eval' : 'normal g%',
         \     },
         \     'echo_type'   : 'func',
         \     'echo_data' : {
         \        'func_name' : 'Locator_EchoItem_VimFunc',
         \     },
         \     'flags'   : 'C',
         \  }

let s:dItem_asterisk_section = {
         \     'detect_type' : 'section',
         \     'detect_data' : {
         \        'regexp' : '\v\s{0,5}\*{10,}\n[^{]+\n\s*\"*\s*\*\s{0,5}\*{10,}',
         \     },
         \     'echo_type'   : 'func',
         \     'echo_data' : {
         \        'func_name' : 'Locator_EchoItem_AsteriskSection',
         \     },
         \     'flags'   : 'c',
         \  }

let s:dItem_dash_1line_section = {
         \     'detect_type' : 'section',
         \     'detect_data' : {
         \        'regexp' : '\v\-{10,}[^-]+\-{10,}',
         \     },
         \     'echo_type'   : 'func',
         \     'echo_data' : {
         \        'func_name' : 'Locator_EchoItem_Fold',
         \     },
         \     'flags'   : 'c',
         \  }

let g:locator_items = {
         \     '*' : {
         \        'items' : [
         \           {
         \              'name' : 'fold',
         \              'data' : s:dItem_fold,
         \           },
         \           {
         \              'name' : 'asterisk_section',
         \              'data' : s:dItem_asterisk_section,
         \           },
         \        ]
         \     },
         \     'java' : {
         \        'items' : [
         \           {
         \              'name' : 'java_class',
         \              'data' : s:dItem_java_class,
         \           },
         \           {
         \              'name' : 'func',
         \              'data' : s:dItem_C_func,
         \           },
         \        ]
         \     },
         \     'c' : {
         \        'items' : [
         \           {
         \              'name' : 'func',
         \              'data' : s:dItem_C_func,
         \           },
         \        ]
         \     },
         \     'cpp' : {
         \        'items' : [
         \           {
         \              'name' : 'java_class',
         \              'data' : s:dItem_java_class,
         \           },
         \           {
         \              'name' : 'func',
         \              'data' : s:dItem_C_func,
         \           },
         \        ]
         \     },
         \     'vim' : {
         \        'items' : [
         \           {
         \              'name' : 'func',
         \              'data' : s:dItem_vim_function,
         \           },
         \        ]
         \     },
         \  }


         "\           {
         "\              'name' : 'dash_section',
         "\              'data' : s:dItem_dash_1line_section,
         "\           },


let s:cur_items = []


" **********************************************************************************
"  EVENT HANDLERS
" **********************************************************************************

function! <SID>OnBufEnter()
   let s:cur_items = []

   for dCurItem in g:locator_items['*']['items']
      call add(s:cur_items, dCurItem)
   endfor

   if exists('g:locator_items["'.&ft.'"]["items"]')
      for dCurItem in g:locator_items[&ft]['items']
         call add(s:cur_items, dCurItem)
      endfor
   endif

endfunction




" **********************************************************************************
"  ECHO ITEM FUNCTIONS
" **********************************************************************************

function! Locator_GoToFoldEnd()
   let _iTmp = foldclosedend(".")
   if _iTmp == -1
      normal! ]z
   else
      exe "normal "._iTmp."gg"
   endif
   "unlet _iTmp 
endfunction

function! Locator_EchoItem_Fold(iLineNum)

   let sLine = getline(a:iLineNum)
   let lMatchList = matchlist(sLine, '\v[^a-zA-Z0-9_]*(.{-})\s*\{\{\{')
   if len(lMatchList) > 0
      call <SID>SetHL(g:locator_hl_fold)
      echon ' --- '.lMatchList[1].' --- '
      call <SID>SetHL("None")
   endif
  

endfunction

function! Locator_EchoItem_JavaClass(iLineNum)
   call <SID>SetHL(g:locator_hl_class)
   echon substitute(
            \     getline(a:iLineNum),
            \     '\v\s*(.*)',
            \     '\1',
            \     ''
            \  )
   call <SID>SetHL("None")
endfunction

function! Locator_EchoItem_C_Func(iLineNum)
   "call <SID>SetHL("WarningMsg")
   let sLine = getline(a:iLineNum)

   let myMatch = matchlist(sLine, '\v(\s*)(.*\s+)(\S+\s*)(\(.*)')

   if len(myMatch) > 0
      call <SID>SetHL(g:locator_hl_func_the_rest)
      echon myMatch[2]
      call <SID>SetHL(g:locator_hl_func_name)
      echon myMatch[3]
      call <SID>SetHL(g:locator_hl_func_the_rest)
      echon myMatch[4]
      call <SID>SetHL("None")

   endif

   "echon substitute(
   "\     sLine,
   "\     '\v\s*(.*)',
   "\     '\1',
   "\     ''
   "\  )
   "call <SID>SetHL("None")
endfunction

function! Locator_EchoItem_VimFunc(iLineNum)
   let sLine = getline(a:iLineNum)

   let myMatch = matchlist(sLine, '\v(\s*)(.*\s+)(\S+\s*)(\(.*)')

   if len(myMatch) > 0
      call <SID>SetHL(g:locator_hl_func_the_rest)
      echon myMatch[2]
      call <SID>SetHL(g:locator_hl_func_name)
      echon myMatch[3]
      call <SID>SetHL(g:locator_hl_func_the_rest)
      echon myMatch[4]
      call <SID>SetHL("None")

   endif

endfunction

function! Locator_EchoItem_AsteriskSection(iLineNum)
   let iLineNum = a:iLineNum + 1
   let sLine = getline(iLineNum)
   let sSectName = substitute(sLine, '\v^[^A-Za-z0-9_]*(.*)', '\1', '')
   call <SID>SetHL(g:locator_hl_section)
   echon "*** [ ".sSectName." ] ***"
   call <SID>SetHL("None")
endfunction



" **********************************************************************************
"  UTILITY FUNCTIONS
" **********************************************************************************

function! <SID>SetHL(sHL)
   exe "echohl ".a:sHL
endfunction

function! <SID>FillString(sPaint, iCnt)
   let sRet = ""

   for i in range(a:iCnt)
      let sRet = sRet.a:sPaint
   endfor

   return sRet
endfunction


" Check if the cursor is in comment or string
function! IsInComment(line, col)
   return match(synIDattr(synID(a:line, a:col, 1), "name"), '\v\Comment')>=0
endfunc


" Ranges

function! <SID>RemoveEmptyRanges(lSrc, iStart, iEnd)

   let lSrc = a:lSrc
   let i = a:iStart
   let max = a:iEnd

   while i <= max
      if lSrc[i][0] > lSrc[i][1]
         call remove(lSrc, i)
         let max = max - 1
         let i = i - 1
      endif
      let i = i + 1
   endwhile

endfunction

" @param iFieldIndex this is needed for performance. The first index of field
"                    to start search from.
function! <SID>AddHole(lSrc, lHole, iFieldIndex)
   let lSrc = a:lSrc
   let lHole = a:lHole
   let iFieldIndex = a:iFieldIndex

   for i in range(iFieldIndex, len(lSrc) - 1)

      "if lHole[1] < lSrc[i][0]
      "continue
      "endif

      if lHole[0] >= lSrc[i][0]

         if lHole[1] <= lSrc[i][1]
            " need to add hole in this field

            call insert(lSrc, [ lHole[1] + 1, lSrc[i][1] ], i + 1)
            let lSrc[i][1] = lHole[0] - 1

            "echo i
            call <SID>RemoveEmptyRanges(lSrc, i, i + 1)

            return i

         elseif lHole[0] <= lSrc[i][1]
            for j in range(i + 1, len(lSrc) - 1)
               if lHole[1] >= lSrc[j][0] && lHole[1] <= lSrc[j][1]
                  " need to remove [ (i + 1) , (j - 1) ] items
                  " and change limits of i-th and j-th fields.
                  " TODO

                  let lSrc[i][1] = lHole[0] - 1
                  let lSrc[j][0] = lHole[1] + 1

                  if (j - 1) >= (i + 1)
                     call remove(lSrc, (i + 1), (j - 1))
                  endif

                  call <SID>RemoveEmptyRanges(lSrc, i, i + 1)

                  return i

               endif
            endfor
         endif
      endif

   endfor

endfunction






" **********************************************************************************
"  PRIVATE FUNCTIONS
" **********************************************************************************

function! <SID>CheckComment(flags, line, col)
   let boolOK = 1

   if !empty(&syntax) 
      if stridx(a:flags, 'c') >= 0
         if !IsInComment(a:line, a:col)
            let boolOK = 0
         endif
      elseif stridx(a:flags, 'C') >= 0
         if IsInComment(a:line, a:col)
            let boolOK = 0
         endif
      endif
   endif

   return boolOK
endfunction

function! <SID>ItemsCompare(i1, i2)
   return a:i1['pos'][0] == a:i2['pos'][0]
            \     ? (a:i1['pos'][1] == a:i2['pos'][1] ? 0 : a:i1['pos'][1] > a:i2['pos'][1] ? 1 : -1)
            \     : a:i1['pos'][0] > a:i2['pos'][0] ? 1 : -1

endfunction

function! <SID>MoveToNextChar()
   let buf_whichwrap = &whichwrap
   set whichwrap+=l
   normal l
   let &whichwrap = buf_whichwrap

   "exe "normal! \<space>"
endfunction

function! <SID>SetCursor(lineNum, col, boolNextChar)
   let lTmpPos    = getpos('.')
   let lTmpPos[1] = a:lineNum " lnum
   let lTmpPos[2] = a:col     " col
   call setpos('.', lTmpPos)

   if a:boolNextChar
      call <SID>MoveToNextChar()
   endif

endfunction

function! <SID>SearchPosFields(sPattern, sFlags, iStopLine, lFields)
   let boolBackward       = stridx(a:sFlags, 'b') >= 0
   let boolDontMoveCursor = stridx(a:sFlags, 'n') >= 0

   let lRet = [0, 0]

   let lSrcPos = getpos('.')
   let iCurLineNum = lSrcPos[1]

   "echo "fields: ".len(a:lFields)." "
   "echo a:lFields
   "echo "iCurLineNum=".iCurLineNum

   " get start position
   let iFieldIndex = -1
   if !boolBackward
      for i in range(0, len(a:lFields) - 1)
         "if iCurLineNum >= a:lFields[i][0] && iCurLineNum <= a:lFields[i][1]
         if iCurLineNum <= a:lFields[i][1]
            let iFieldIndex = i
            break
         endif
      endfor
   else
      let i = len(a:lFields) - 1
      while i >= 0
         "if iCurLineNum >= a:lFields[i][0] && iCurLineNum <= a:lFields[i][1]
         if iCurLineNum >= a:lFields[i][0]
            let iFieldIndex = i
            break
         endif
         let i = i - 1
      endwhile
   endif

   "echo "iFieldIndex=".iFieldIndex

   if !boolBackward
      let iFieldStartIdx = 0
      let iFieldEndIdx   = 1
   else
      let iFieldStartIdx = 1
      let iFieldEndIdx   = 0
   endif

   if iFieldIndex >= 0
      let boolFirst = 1

      while lRet[0] == 0 && ((!boolBackward && iFieldIndex < len(a:lFields)) || (boolBackward && iFieldIndex >= 0))
         if !boolFirst
            call <SID>SetCursor(a:lFields[iFieldIndex][ iFieldStartIdx ], 0, 0)
         endif

         if a:iStopLine > 0
            if !boolBackward
               let iCurStopLine = a:lFields[iFieldIndex][ iFieldEndIdx ] < a:iStopLine
                        \  ? a:lFields[iFieldIndex][ iFieldEndIdx ]
                        \  : a:iStopLine
            else
               let iCurStopLine = a:lFields[iFieldIndex][ iFieldEndIdx ] > a:iStopLine
                        \  ? a:lFields[iFieldIndex][ iFieldEndIdx ]
                        \  : a:iStopLine
            endif
         else
            let iCurStopLine = a:lFields[iFieldIndex][ iFieldEndIdx ]
         endif




         "echo "search cursor pos"
         "echo getpos('.')
         let lRet = searchpos(a:sPattern, a:sFlags, iCurStopLine)

         if iCurStopLine == a:iStopLine
            break
         endif

         let boolFirst = 0
         if !boolBackward
            let iFieldIndex = iFieldIndex + 1
         else
            let iFieldIndex = iFieldIndex - 1
         endif
      endwhile

   endif

   if boolDontMoveCursor
      call <SID>SetCursor(lSrcPos[1], lSrcPos[2], 0)
   endif

   return lRet

endfunction

function! <SID>GetMatchablesList(lFields, iStopLine)

   "echo a:iStopLine
   let lSrcPos = getpos('.')
   let lFields = a:lFields

   call <SID>SetCursor(0, 0, 0)

   let lRet = []

   for dItemType in s:cur_items
      if dItemType['data']['detect_type'] == 'matchable'
         "echo "----------------- name=".dItemType['name']
         call setpos('.', lSrcPos)

         let iFieldIndex = 0
         while (1)
            "let lCurSearchPos = searchpos(dItemType['data']['detect_data']['start_regexp'], 'cW', a:iStopLine)
            let lCurSearchPos = <SID>SearchPosFields(dItemType['data']['detect_data']['start_regexp'], 'cW', 0, lFields)
            "echo lCurSearchPos
            if lCurSearchPos[0] != 0

               let boolAdd = <SID>CheckComment(dItemType['data']['flags'], lCurSearchPos[0], lCurSearchPos[1])
               if !boolAdd
                  normal! j
                  continue
               endif

               exec dItemType['data']['detect_data']['get_end__eval']
               let lLowerPos = getpos('.')
               "echo lLowerPos
               if lLowerPos[1] > a:iStopLine
                  "echo "saving"
                  " we need to save this item

                  let dFoundItem = {
                           \     'itemType' : 'matchable',
                           \     'edgeType' : 'matchable_start',
                           \     'pos'      : lCurSearchPos,
                           \     'dItemType': dItemType,
                           \  }

                           "\     'end_pos'  : [ lLowerPos[1], lLowerPos[2] ],
                  call add(lRet, dFoundItem)

                  call <SID>SetCursor(lCurSearchPos[0], lCurSearchPos[1], 0)
                  call searchpos(dItemType['data']['detect_data']['start_regexp'], 'ceW')
                  normal! j
                  "call <SID>MoveToNextChar()
               else
                  " this item is before cursor, so, let's look for the next one
                  " of the same type

                  if g:locator_parseSections
                     let iFieldIndex = <SID>AddHole(lFields, [ lCurSearchPos[0], lLowerPos[1] ], iFieldIndex)
                  endif

               endif
            else
               break
            endif
         endwhile

      endif
   endfor

   " sort lRet
   let lRet = sort(lRet, "<SID>ItemsCompare") " not use 'function(..)' to not to break %

   call setpos('.', lSrcPos)
   return lRet

endfunction


function! <SID>GetSectionsForOneRegion(lItems, iIndex, iLineNum, iCol, iStopLine, lFields)
   "echo "iStopLine:".a:iStopLine
   "echo "iLineNum:".a:iLineNum

   let iAddedCnt = 0

   for dItemType in s:cur_items

      if dItemType['data']['detect_type'] == 'section'

         call <SID>SetCursor( a:iLineNum, a:iCol, 0 )

         "let lCurSearchPos = searchpos(dItemType['data']['detect_data']['regexp'], 'bnW', a:iStopLine)
         let lCurSearchPos = <SID>SearchPosFields(dItemType['data']['detect_data']['regexp'], 'bnW', a:iStopLine, a:lFields)

         if lCurSearchPos[0] > 0
            "echo "match! stopline=".a:iStopLine
            "echo getline(lCurSearchPos[0] + 1)

            let boolAdd = <SID>CheckComment(dItemType['data']['flags'], lCurSearchPos[0], lCurSearchPos[1])

            if boolAdd
               let dFoundItem = {
                        \     'itemType' : 'section',
                        \     'edgeType' : 'section_start',
                        \     'pos'      : lCurSearchPos,
                        \     'dItemType': dItemType,
                        \  }

               let dFoundItem['pos'][0] = lCurSearchPos[0]


               call insert(a:lItems, dFoundItem, a:iIndex)
               let iAddedCnt = iAddedCnt + 1
            else
               "TODO: search again
            endif

         endif
      endif

   endfor

   "echo "added:".iAddedCnt
   return iAddedCnt
endfunction

function! <SID>GetSections(lItems, iCursorLineNum, lFields)
   let lItems = a:lItems

   "echo lItems

   let iPrevEdgeLineNum = 0
   "for i in range(len(lItems))

   let i = 0
   while i < len(lItems)
      let dItem = lItems[ i ]

      if dItem['itemType'] == 'matchable'
         "echo dItem
         let i = i + <SID>GetSectionsForOneRegion( lItems, i, dItem['pos'][0], dItem['pos'][1], iPrevEdgeLineNum , a:lFields)
         let iPrevEdgeLineNum = dItem['pos'][0]
      endif

      let i = i + 1
   endwhile

   let i = i + <SID>GetSectionsForOneRegion( lItems, len(lItems), a:iCursorLineNum, 0, iPrevEdgeLineNum, a:lFields)

endfunction



function! <SID>GetLocationPathList()

   let lSrcPos = getpos('.')
   let iSrcFirstVisibleLine = line('w0')

   call <SID>SetCursor(0, 0, 0)

   let lFields = [ [1, lSrcPos[1] ] ]

   let lItems = []


   " get matchables list
   let lItems = <SID>GetMatchablesList(lFields, lSrcPos[1])

   " get sections
   if g:locator_parseSections
      call <SID>GetSections(lItems, lSrcPos[1], lFields)
   endif

   call setpos('.', lSrcPos)

   " restore scroll position
   let iCurFirstVisibleLine = line('w0')
   "echo "cur_vis_line: ".line('w0')
   "echo "needed: ".iSrcFirstVisibleLine
   if iCurFirstVisibleLine > iSrcFirstVisibleLine
      exe "normal! ".(iCurFirstVisibleLine - iSrcFirstVisibleLine)."\<C-Y>"
      "echo "normal! ".(iCurFirstVisibleLine - iSrcFirstVisibleLine)."\<C-Y>"
   elseif iCurFirstVisibleLine < iSrcFirstVisibleLine
      exe "normal! ".(iSrcFirstVisibleLine - iCurFirstVisibleLine)."\<C-E>"
      "echo "normal! ".(iSrcFirstVisibleLine - iCurFirstVisibleLine)."\<C-E>"
   endif
   "echo "cur_vis_line: ".line('w0')

   " restore cursor position
   call setpos('.', lSrcPos)

   return lItems

endfunction




" **********************************************************************************
"  PUBLIC FUNCTIONS
" **********************************************************************************

function! EchoLocationPath()

   let sSpaces = ' '

   let lPathList = <SID>GetLocationPathList()

   if len(lPathList) > 0
      " get max linenum (we actually need its strlen())
      let iMaxLineNum = 0
      for dItem in lPathList
         if dItem['pos'][0] > iMaxLineNum
            let iMaxLineNum = dItem['pos'][0]
         endif
      endfor

      let iMaxLen = strlen(iMaxLineNum)

      for dItem in lPathList

         let dItemTypeData = dItem['dItemType']['data']

         let iLocalSpacesCnt = iMaxLen - strlen(dItem['pos'][0])
         let sLocalSpaces = <SID>FillString(' ', iLocalSpacesCnt)

         echo ""

         echon sLocalSpaces
         echon dItem['pos'][0].':'
         echon sSpaces
         exe "call ".dItemTypeData['echo_data']['func_name']."(".dItem['pos'][0].")"

         let sSpaces = sSpaces.'  '


      endfor
   else
      call <SID>SetHL(g:locator_hl_section)
      echon "[No items]"
      call <SID>SetHL("None")
   endif

endfunction


if !exists('g:locator_parseSections')
   let g:locator_parseSections = 1
endif

if !exists('g:locator_hl_fold')
   let g:locator_hl_fold = "Folded"
endif

if !exists('g:locator_hl_class')
   let g:locator_hl_class = "NonText"
endif

if !exists('g:locator_hl_func_name')
   let g:locator_hl_func_name = "Directory"
endif

if !exists('g:locator_hl_func_the_rest')
   let g:locator_hl_func_the_rest = "Normal"
endif

if !exists('g:locator_hl_section')
   let g:locator_hl_section = "ModeMsg"
endif

if !exists('g:locator_disable_mappings')
   let g:locator_disable_mappings = 0
endif


if !g:locator_disable_mappings
   nnoremap gl :call EchoLocationPath()<CR>
endif

autocmd FileType * call <SID>OnBufEnter()
autocmd BufEnter * call <SID>OnBufEnter()

