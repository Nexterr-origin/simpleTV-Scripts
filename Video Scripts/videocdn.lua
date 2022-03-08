-- видеоскрипт для видеобалансера "videocdn" https://videocdn.tv (8/3/22)
-- Copyright © 2017-2022 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## открывает подобные ссылки ##
-- https://32.svetacdn.in/fnXOUDB9nNSO?kp_id=5928
-- https://32.tvmovies.in/fnXOUDB9nNSO/tv-series/92
-- https://32.tvmovies.in/fnXOUDB9nNSO/movie/22080
-- http://32.svetacdn.in/fnXOUDB9nNSO/movie/36905
-- ## прокси ##
local proxy = ''
-- '' - нет
-- 'https://proxy-nossl.antizapret.prostovpn.org:29976' (пример)
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://[%w%.]*videocdn%.')
			and not m_simpleTV.Control.CurrentAddress:match('^https?://.-/fnXOUDB9nNSO')
			and not m_simpleTV.Control.CurrentAddress:match('^https?://[%w%.]*svetacdn%.')
			and not m_simpleTV.Control.CurrentAddress:match('^$videocdn')
		then
		 return
		end
	local inAdr = m_simpleTV.Control.CurrentAddress
	htmlEntities = require 'htmlEntities'
	m_simpleTV.OSD.ShowMessageT({text = '', showTime = 1000, id = 'channelName'})
	if inAdr:match('^$videocdn') or not inAdr:match('&kinopoisk') then
		if m_simpleTV.Control.MainMode == 0 then
			m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
		end
	end
	local psevdotv
	if inAdr:match('PARAMS=psevdotv') then
		psevdotv = true
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = ''
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:96.0) Gecko/20100101 Firefox/96.0', proxy, false)
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 12000)
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.Videocdn then
		m_simpleTV.User.Videocdn = {}
	end
	if not m_simpleTV.User.Videocdn.qlty then
		m_simpleTV.User.Videocdn.qlty = tonumber(m_simpleTV.Config.GetValue('Videocdn_qlty') or '10000')
	end
	local title
	if m_simpleTV.User.Videocdn.Tabletitle then
		local index = m_simpleTV.Control.GetMultiAddressIndex()
		if index then
			title = m_simpleTV.User.Videocdn.title .. ' - ' .. m_simpleTV.User.Videocdn.Tabletitle[index].Name
		end
	end
	local function ShowInfo(s)
		local q = {}
			q.once = 1
			q.zorder = 0
			q.cx = 0
			q.cy = 0
			q.id = 'AK_INFO_TEXT'
			q.class = 'TEXT'
			q.align = 0x0202
			q.top = 0
			q.color = 0xFFFFFFF0
			q.font_italic = 0
			q.font_addheight = 6
			q.padding = 20
			q.textparam = 1 + 4
			q.text = s
			q.background = 0
			q.backcolor0 = 0x90000000
		m_simpleTV.OSD.AddElement(q)
		if m_simpleTV.Common.WaitUserInput(5000) == 1 then
			m_simpleTV.OSD.RemoveElement('AK_INFO_TEXT')
		end
		if m_simpleTV.Common.WaitUserInput(5000) == 1 then
			m_simpleTV.OSD.RemoveElement('AK_INFO_TEXT')
		end
		if m_simpleTV.Common.WaitUserInput(5000) == 1 then
			m_simpleTV.OSD.RemoveElement('AK_INFO_TEXT')
		end
		m_simpleTV.OSD.RemoveElement('AK_INFO_TEXT')
	end
	local function GetMaxResolutionIndex(t)
		local index
		for u = 1, #t do
				if t[u].qlty and m_simpleTV.User.Videocdn.qlty < t[u].qlty then break end
			index = u
		end
	 return index or 1
	end
	local function decodeUrl(n)
		local t, j = {}, 1
			for i = 1, #n, 3 do
				t[j] = {}
				t[j] = n:sub(i, i + 2)
				j = j + 1
			end
		n = '\\u0' .. table.concat(t, '\\u0')
	 return	unescape3(n)
	end
	local function GetQualityFromAddress(url, title)
		url = url:gsub('^$videocdn', '')
		local du = url:match('#(%w+)')
		if du then
			url = decodeUrl(du)
		else
			url = url:gsub('^%[', '')
		end
		url = url:gsub('%.m3u8', '.mp4')
		local t = {}
			for adr in url:gmatch('%](//[^%s]+%.mp4)') do
				local qlty = adr:match('/(%d+)%.mp4')
				if qlty then
					t[#t + 1] = {}
					t[#t].qlty = tonumber(qlty)
					t[#t].Address = adr:gsub('^//', 'http://')
					t[#t].Name = qlty .. 'p'
				end
			end
			if #t == 0 then return end
		local adr1080 = t[1].Address:gsub('/%d+.mp4', '/1080.mp4')
		local rc, answer = m_simpleTV.Http.Request(session, {url = adr1080, method = 'head'})
		if rc == 200 then
			t[#t + 1] = {}
			t[#t].qlty = 1080
			t[#t].Address = adr1080
			t[#t].Name = '1080p'
		end
		table.sort(t, function(a, b) return a.qlty < b.qlty end)
		local hash, tab = {}, {}
			for i = 1, #t do
				if not hash[t[i].qlty] then
					tab[#tab + 1] = t[i]
					hash[t[i].qlty] = true
				end
			end
			for i = 1, #tab do
				tab[i].Id = i
				tab[i].Address = tab[i].Address .. '$OPT:NO-STIMESHIFT$OPT:meta-description=https://github.com/Nexterr-origin/simpleTV-Scripts'
				if psevdotv then
					local videoTitle = title:gsub('.-:', '')
					local k = tab[i].qlty
					tab[i].Address = tab[i].Address .. '$OPT:NO-SEEKABLE$OPT:sub-source=marq$OPT:marq-opacity=70$OPT:marq-size=' .. (0.03 * k) .. '$OPT:marq-position=6$OPT:marq-x=' .. (0.02 * k) .. '$OPT:marq-y=' .. (0.01 * k) .. '$OPT:marq-marquee=' .. m_simpleTV.Common.UTF8ToMultiByte(videoTitle)
				end
			end
		m_simpleTV.User.Videocdn.Table = tab
		local index = GetMaxResolutionIndex(tab)
		m_simpleTV.User.Videocdn.Index = index
	 return tab[index].Address
	end
	local function SaveVideocdnPlaylist()
		if m_simpleTV.User.Videocdn.Tabletitle then
			local t = m_simpleTV.User.Videocdn.Tabletitle
			if #t > 250 then
				m_simpleTV.OSD.ShowMessageT({text = 'Сохранение плейлиста ...', color = 0xff9bffff, showTime = 1000 * 30, id = 'channelName'})
			end
			local header = m_simpleTV.User.Videocdn.title
			local adr, name
			local m3ustr = '#EXTM3U $ExtFilter="Videocdn" $BorpasFileFormat="1"\n'
				for i = 1, #t do
					name = t[i].Name
					adr = t[i].Address:gsub('^$videocdn', '')
					adr = GetQualityFromAddress(adr)
					m3ustr = m3ustr .. '#EXTINF:-1 group-title="' .. header .. '",' .. name .. '\n' .. adr:gsub('$OPT:.+', '') .. '\n'
				end
			header = m_simpleTV.Common.UTF8ToMultiByte(header)
			header = header:gsub('%c', ''):gsub('[\\/"%*:<>%|%?]+', ' '):gsub('%s+', ' '):gsub('^%s*', ''):gsub('%s*$', '')
			local fileEnd = ' (Videocdn ' .. os.date('%d.%m.%y') ..').m3u'
			local folder = m_simpleTV.Common.GetMainPath(1) .. m_simpleTV.Common.UTF8ToMultiByte('сохраненые плейлисты/')
			lfs.mkdir(folder)
			local folderAk = folder .. 'Videocdn/'
			lfs.mkdir(folderAk)
			local filePath = folderAk .. header .. fileEnd
			local fhandle = io.open(filePath, 'w+')
			m_simpleTV.OSD.ShowMessageT({text = '', showTime = 1000 * 1, id = 'channelName'})
			if fhandle then
				fhandle:write(m3ustr)
				fhandle:close()
				ShowInfo('плейлист сохранен в файл\n' .. m_simpleTV.Common.multiByteToUTF8(header) .. '\nв папку\n' .. m_simpleTV.Common.multiByteToUTF8(folderAk))
			else
				ShowInfo('невозможно сохранить плейлист')
			end
		end
	end
	local function play(retAdr, title)
		retAdr = GetQualityFromAddress(retAdr, title)
			if not retAdr then return end
		local extOpt
		if psevdotv then
			m_simpleTV.OSD.ShowMessageT({text = title, showTime = 1000 * 5, id = 'channelName'})
			m_simpleTV.Control.SetTitle(title)
		else
			m_simpleTV.OSD.ShowMessageT({text = title, color = 0xff9999ff, showTime = 1000 * 5, id = 'channelName'})
			m_simpleTV.Control.CurrentTitle_UTF8 = title
		end
		m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')
	end
	function Qlty_Videocdn()
		local t = m_simpleTV.User.Videocdn.Table
			if not t then return end
		local index = m_simpleTV.User.Videocdn.Index
		if not m_simpleTV.User.Videocdn.isVideo then
			t.ExtButton0 = {ButtonEnable = true, ButtonName = '💾', ButtonScript = 'SaveVideocdnPlaylist()'}
		end
		if m_simpleTV.User.paramScriptForSkin_buttonOk then
			t.OkButton = {ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOk}
		end
		if m_simpleTV.User.paramScriptForSkin_buttonClose then
			t.ExtButton1 = {ButtonEnable = true, ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonClose}
		else
			t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
		end
		if #t > 0 then
			local ret, id = m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 10000, 1 + 4 + 2)
			if ret == 1 then
				m_simpleTV.User.Videocdn.Index = id
				m_simpleTV.Control.SetNewAddress(t[id].Address, m_simpleTV.Control.GetPosition())
				m_simpleTV.Config.SetValue('Videocdn_qlty', t[id].qlty)
				m_simpleTV.User.Videocdn.qlty = t[id].qlty
			end
			if ret == 2 then
				SaveVideocdnPlaylist()
			end
		end
	end
	m_simpleTV.User.Videocdn.isVideo = false
		if inAdr:match('^$videocdn') then
			play(inAdr, title)
		 return
		end
	local url = inAdr:gsub('&kinopoisk.+', ''):gsub('%?block=%w+', ''):gsub('$OPT:.+', '')
	m_simpleTV.User.Videocdn.Tabletitle = nil
	local rc, answer = m_simpleTV.Http.Request(session, {url = url})
		if rc ~= 200 then return end
	answer = htmlEntities.decode(answer)
	answer = answer:gsub('\\\\\\/', '/')
	answer = answer:gsub('\\"', '"')
	answer = unescape3(answer)
	answer = answer:gsub('\\', '')
	title = inAdr:match('&kinopoisk=(.+)')
	if title then
		title = m_simpleTV.Common.fromPercentEncoding(title)
	else
		title = 'Videocdn'
	end
	m_simpleTV.Control.SetTitle(title)
	local tv_series = answer:match('value="tv_series"')
	local transl
	local tr = answer:match('<div class="translations".-</div>')
	if tr then
		tr = tr:gsub('<template class="__cf_email__" data%-cfemail="%x+">%[email.-%]</template>', 'MUZOBOZ@')
		local t = {}
		local selected
			for w in tr:gmatch('<option.-</option>') do
				local adr = w:match('value="([^"]+)')
				local name = w:match('>([^<]+)')
				if adr and name and not name:match('^%s*@%s*$') then
					t[#t + 1] = {}
					t[#t].Name = name:gsub('<template.-template>', 'неизвестно'):gsub('&amp;', '&')
					t[#t].Address = adr
					if w:match('"selected"') then
						selected = #t - 1
					end
				end
			end
			if #t == 0 then return end
		if not selected or selected < 0 then
			selected = 0
		end
		if tv_series and #t > 1 then
			table.remove(t, 1)
		end
			for i = 1, #t do
				t[i].Id = i
			end
		if #t > 1 then
			local _, id
			if not psevdotv then
				if m_simpleTV.User.paramScriptForSkin_buttonOk then
					t.OkButton = {ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOk}
				end
				_, id = m_simpleTV.OSD.ShowSelect_UTF8('Выберете перевод - ' .. title, selected, t, 10000, 1 + 2 + 4 + 8)
			end
			id = id or selected + 1
			transl = t[id].Address
		else
			transl = t[1].Address
		end
	end
	transl = transl or '%d+'
	local answer = answer:match('id="files" value="(.+)')
		if not answer then return end
	if tv_series then
		answer = answer:match('"' .. transl .. '":"(.-)">')
			if not answer then return end
		require 'json'
		local du = answer:match('#(%w+)')
		if du then
			answer = decodeUrl(du)
		end
		answer = answer:gsub('%[%]', '""')
		local tab = json.decode(answer)
			if not tab then return end
		local season_title = ''
		local t, i = {}, 1
		if tab[1].folder then
			local s, j, seson = {}, 1
				while true do
						if not tab[j] then break end
					s[j] = {}
					s[j].Id = j
					s[j].Name = unescape3(tab[j].comment)
					s[j].Address = j
					j = j + 1
				end
				if j == 1 then return end
			if j > 2 then
				local _, id = m_simpleTV.OSD.ShowSelect_UTF8(title, 0, s, 10000, 1)
				id = id or 1
				seson = s[id].Address
				season_title = ' (' .. s[id].Name .. ')'
			else
				seson = s[1].Address
				local ses = s[1].Name:match('%d+') or '0'
				if tonumber(ses) > 1 then
					season_title = ' (' .. s[1].Name .. ')'
				end
			end
				while true do
						if not tab[seson].folder[i] then break end
					t[i] = {}
					t[i].Id = i
					t[i].Name = tab[seson].folder[i].comment:gsub('<i>.-</i>', ''):gsub('<br>', '')
					t[i].Address = '$videocdn' .. tab[seson].folder[i].file
					i = i + 1
				end
				if i == 1 then return end
		else
				while true do
						if not tab[i] then break end
					t[i] = {}
					t[i].Id = i
					t[i].Name = tab[i].comment:gsub('<i>.-</i>', ''):gsub('<br>', '')
					t[i].Address = '$videocdn' .. tab[i].file
					i = i + 1
				end
				if i == 1 then return end
		end
		m_simpleTV.User.Videocdn.Tabletitle = t
		if m_simpleTV.User.paramScriptForSkin_buttonClose then
			t.ExtButton1 = {ButtonEnable = true, ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonClose, ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
		else
			t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
		end
		if m_simpleTV.User.paramScriptForSkin_buttonOk then
			t.OkButton = {ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOk}
		end
		if m_simpleTV.User.paramScriptForSkin_buttonOptions then
			t.ExtButton0 = {ButtonEnable = true, ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOptions, ButtonScript = 'Qlty_Videocdn()'}
		else
			t.ExtButton0 = {ButtonEnable = true, ButtonName = '⚙', ButtonScript = 'Qlty_Videocdn()'}
		end
		t.ExtParams = {FilterType = 2, StopOnError = 1, StopAfterPlay = 1, PlayMode = 0}
		local p = 0
		if i == 2 then
			p = 32
			m_simpleTV.User.Videocdn.isVideo = true
		end
		title = title .. season_title
		m_simpleTV.OSD.ShowSelect_UTF8(title, 0, t, 15000, p + 64)
		inAdr = t[1].Address
		m_simpleTV.User.Videocdn.title = title
		title = title .. ' - ' .. m_simpleTV.User.Videocdn.Tabletitle[1].Name
	else
		inAdr = answer:match('"' .. transl .. '":"([^"]+)')
			if not inAdr then return end
		if psevdotv then
			local t = m_simpleTV.Control.GetCurrentChannelInfo()
			if t
				and t.MultiHeader
				and t.MultiName
			then
				title = t.MultiHeader .. ': ' .. t.MultiName
			end
		end
		local t1 = {}
		t1[1] = {}
		t1[1].Id = 1
		t1[1].Name = title
		t1[1].Address = inAdr
		if not psevdotv then
			if m_simpleTV.User.paramScriptForSkin_buttonClose then
				t1.ExtButton1 = {ButtonEnable = true, ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonClose, ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
			else
				t1.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
			end
			if m_simpleTV.User.paramScriptForSkin_buttonOk then
				t1.OkButton = {ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOk}
			end
			if m_simpleTV.User.paramScriptForSkin_buttonOptions then
				t1.ExtButton0 = {ButtonEnable = true, ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOptions, ButtonScript = 'Qlty_Videocdn()'}
			else
				t1.ExtButton0 = {ButtonEnable = true, ButtonName = '⚙', ButtonScript = 'Qlty_Videocdn()'}
			end
			m_simpleTV.OSD.ShowSelect_UTF8('Videocdn', 0, t1, 10000, 32 + 64 + 128)
		end
		m_simpleTV.User.Videocdn.isVideo = true
	end
	play(inAdr, title)
