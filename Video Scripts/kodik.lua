-- видеоскрипт для видеобалансера "kodik" http://kodik.cc (9/4/23)
-- Copyright © 2017-2023 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## открывает подобные ссылки ##
-- https://hdrise.com/video/31756/445f20d7950d3df08f7574311e82521e/720p
-- http://kodik.info/video/27565/0f93e7a7ce4c247c3b66b47b1b8910b2/720p
-- http://kodik.cc/serial/37405/ab75ddfb810d744aae16eb202f3a5330/720
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://kodik%.')
			and not m_simpleTV.Control.CurrentAddress:match('^https?://hdrise%.com')
			and not m_simpleTV.Control.CurrentAddress:match('^https?://hdlizor%.com')
			and not m_simpleTV.Control.CurrentAddress:match('^$kodiks')
		then
		 return
		end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.OSD.ShowMessageT({text = '', showTime = 1000, id = 'channelName'})
	if inAdr:match('^$kodiks') or not inAdr:match('&kinopoisk') then
		if m_simpleTV.Control.MainMode == 0 then
			m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
		end
	end
	local psevdotv
	if inAdr:match('PARAMS=psevdotv') then
		psevdotv = true
	end
	inAdr = inAdr:gsub('/$', '')
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:102.0) Gecko/20100101 Firefox/102.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.kodik then
		m_simpleTV.User.kodik = {}
	end
	local title
	local refer = 'https://the-cinema.online/'
	if m_simpleTV.User.kodik.Tabletitle and not psevdotv then
		local index = m_simpleTV.Control.GetMultiAddressIndex()
		if index then
			title = m_simpleTV.User.kodik.title .. ' - ' .. m_simpleTV.User.kodik.Tabletitle[index].Name
		end
	end
	local function ShowInfo(s)
		local q = {}
			q.once = 1
			q.zorder = 0
			q.cx = 0
			q.cy = 0
			q.id = 'K_INFO_TEXT'
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
			m_simpleTV.OSD.RemoveElement('K_INFO_TEXT')
		end
		if m_simpleTV.Common.WaitUserInput(5000) == 1 then
			m_simpleTV.OSD.RemoveElement('K_INFO_TEXT')
		end
		if m_simpleTV.Common.WaitUserInput(5000) == 1 then
			m_simpleTV.OSD.RemoveElement('K_INFO_TEXT')
		end
		m_simpleTV.OSD.RemoveElement('K_INFO_TEXT')
	end
	local function GetMaxResolutionIndex(t)
		local lastQuality = tonumber(m_simpleTV.Config.GetValue('Kodik_qlty') or 5000)
		local index = #t
			for i = 1, #t do
				if t[i].qlty >= lastQuality then
					index = i
				 break
				end
			end
		if index > 1 then
			if t[index].qlty > lastQuality then
				index = index - 1
			end
		end
	 return index
	end
	local function decode_kodik(data)
		local t = {}
			for i = 1, #data do
				local s = data:sub(i, i)
				s = string.byte(s)
				if s >= 65 and s <= 77 then
					s = s + 13
				elseif s >= 78 and s <= 90 then
					s = s - 13
				elseif s >= 97 and s <= 109 then
					s = s + 13
				elseif s >= 110 and s <= 122 then
					s = s - 13
				end
				t[i] = string.char(s)
			end
		data = table.concat(t)
		data = decode64(data)
	 return data
	end
	local function GetAddress(retAdr)
		retAdr = retAdr:gsub('^//', 'https://')
		local rc, answer = m_simpleTV.Http.Request(session, {url = retAdr, headers = 'Referer: ' .. refer})
			if rc ~= 200 then return end
		answer = answer:gsub('<!%-%-.-%-%->', '')
		local domain = answer:match('domain = "([^"]+)')
		local d_sign = answer:match('d_sign = "([^"]+)')
		local pd = answer:match('pd = "([^"]+)')
		local pd_sign = answer:match('pd_sign = "([^"]+)')
		local ref = answer:match('ref = "([^"]+)')
		local typ = answer:match('videoInfo%.type = \'(.-)\'')
		local hash = answer:match('hash = \'(.-)\'')
		local id = answer:match('id = \'(.-)\'')
			if not domain
				or not d_sign
				or not pd
				or not pd_sign
				or not ref
				or not typ
				or not hash
				or not id
			then
			 return
			end
		if not m_simpleTV.User.kodik.url then
			local script = answer:match('type="text/javascript".-src="([^"]+)')
				if not script then return end
			if not script:match('^http') then
				script = 'https://' .. pd .. script
			end
			rc, answer = m_simpleTV.Http.Request(session, {url = script, headers = 'Referer: ' .. refer})
			local url = answer:match('url:atob%("([^"]+)')
				if not url then return end
			url = decode64(url)
			m_simpleTV.User.kodik.url = url
		end
		local headers = 'X-Requested-With: XMLHttpRequest\nReferer: ' .. refer
		local body = 'd=' .. domain
				.. '&d_sign=' .. d_sign
				.. '&pd=' .. pd
				.. '&pd_sign=' .. pd_sign
				.. '&ref=' .. m_simpleTV.Common.toPercentEncoding(ref)
				.. '&bad_user=false'
				.. '&type=' .. typ
				.. '&hash=' .. hash
				.. '&id=' .. id
		rc, answer = m_simpleTV.Http.Request(session, {url = 'https://' .. pd .. m_simpleTV.User.kodik.url, method = 'post', headers = headers, body = body})
			if rc ~= 200 then return end
	 return answer
	end
	local function GetkodikAddress(answer)
		local t = {}
			for qlty, adr in answer:gmatch('"(%d+)":%[{"src":"([^"]+)') do
				if qlty and adr then
					t[#t +1] = {}
					adr = decode_kodik(adr)
					qlty = adr:match('/(%d+)%.mp4') or qlty
					t[#t].qlty = tonumber(qlty)
					t[#t].Name = qlty .. 'p'
					t[#t].Address = adr:gsub('^//', 'https://')
				end
			end
			if #t == 0 then return end
		local hash, t1 = {}, {}
			for i = 1, #t do
				if not hash[t[i].Address] then
					t1[#t1 + 1] = t[i]
					hash[t[i].Address] = true
				end
			end
		table.sort(t1, function(a, b) return a.qlty < b.qlty end)
		if #t1 > 2 then
			if not t1[#t1].Address:match('/720%.mp4') then
				local adr = t1[#t1].Address:gsub('/%d+%.mp4', '/720.mp4')
				local rc, answer = m_simpleTV.Http.Request(session, {url = adr, method = 'HEAD'})
				if rc == 200 then
					t1[#t1 + 1] = {qlty = 1080, Name = '720p', Address = adr}
				end
			end
			if t1[#t1].Address:match('/720%.mp4') then
				local adr = t1[#t1].Address:gsub('/720%.mp4', '/1080.mp4')
				local rc, answer = m_simpleTV.Http.Request(session, {url = adr, method = 'HEAD'})
				if rc == 200 then
					t1[#t1 + 1] = {qlty = 1080, Name = '1080p', Address = adr}
				end
			end
		end
		for i = 1, #t1 do
			t1[i].Id = i
		end
		m_simpleTV.User.kodik.Table = t1
		local index = GetMaxResolutionIndex(t1)
		m_simpleTV.User.kodik.Index = index
	 return t1[index].Address
	end
	function SavePlst_kodik()
		if m_simpleTV.User.kodik.Tabletitle and m_simpleTV.User.kodik.title then
			m_simpleTV.OSD.ShowMessageT({text = 'Сохранение плейлиста ...', color = 0xff9bffff, showTime = 1000 * 30, id = 'channelName'})
			require 'lfs'
			local t = m_simpleTV.User.kodik.Tabletitle
			local header = m_simpleTV.User.kodik.title
			local adr, name
			local m3ustr = '#EXTM3U $ExtFilter="Kodik" $BorpasFileFormat="1"\n'
				for i = 1, #t do
					name = t[i].Name
					adr = t[i].Address:gsub('%$kodiks', '')
					local answer = GetAddress(adr)
					adr = GetkodikAddress(answer)
					m3ustr = m3ustr .. '#EXTINF:-1 group-title="' .. header .. '",' .. name .. '\n' .. adr:gsub('%$.+', '') .. '\n'
				end
			header = m_simpleTV.Common.UTF8ToMultiByte(header)
			header = header:gsub('%c', ''):gsub('[\\/"%*:<>%|%?]+', ' '):gsub('%s+', ' '):gsub('^%s*', ''):gsub('%s*$', '')
			local fileEnd = ' (Kodik ' .. os.date('%d.%m.%y') ..').m3u'
			local folder = m_simpleTV.Common.GetMainPath(1) .. m_simpleTV.Common.UTF8ToMultiByte('сохраненые плейлисты/')
			lfs.mkdir(folder)
			local folderAk = folder .. 'Kodik/'
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
	function Qlty_kodik()
		local t = m_simpleTV.User.kodik.Table
			if not t then return end
		local index = m_simpleTV.User.kodik.Index
		if not m_simpleTV.User.kodik.isVideo then
			t.ExtButton0 = {ButtonEnable = true, ButtonName = '💾', ButtonScript = 'SavePlst_kodik()'}
		end
		t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
		if #t > 0 then
			local ret, id = m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 1 + 4 + 2 + 8)
			if ret == 1 then
				m_simpleTV.User.kodik.Index = id
				m_simpleTV.User.kodik.qlty = t[id].qlty
				m_simpleTV.Control.SetNewAddress(t[id].Address, m_simpleTV.Control.GetPosition())
				m_simpleTV.Config.SetValue('Kodik_qlty', t[id].qlty)
			end
			if ret == 2 then
				SavePlst_kodik()
			end
		end
	end
	local function play(Adr, title)
		local answer = GetAddress(Adr:gsub('^$kodiks', ''))
			if not answer then
				m_simpleTV.Http.Close(session)
			 return
			end
		local retAdr = GetkodikAddress(answer)
			if not retAdr then return end
		local extOpt
		if psevdotv then
			extOpt = '$OPT:NO-SEEKABLE'
			m_simpleTV.OSD.ShowMessageT({text = title, showTime = 1000 * 5, id = 'channelName'})
			m_simpleTV.Control.SetTitle(title)
		else
			extOpt = ''
			m_simpleTV.OSD.ShowMessageT({text = title, color = 0xff9999ff, showTime = 1000 * 5, id = 'channelName'})
			m_simpleTV.Control.CurrentTitle_UTF8 = title
		end
		m_simpleTV.Control.CurrentAddress = retAdr .. extOpt
-- debug_in_file(retAdr .. '\n')
	end
		if inAdr:match('^$kodik') then
			play(inAdr, title)
		 return
		end
	m_simpleTV.User.kodik.url = nil
	local url = inAdr:gsub('&kinopoisk.+', '')
	local rc, answer = m_simpleTV.Http.Request(session, {url = url, headers = 'Referer: ' .. refer})
		if rc ~= 200 then return end
	local season_title = ''
	local seson = ''
	m_simpleTV.User.kodik.Tabletitle = nil
	m_simpleTV.User.kodik.isVideo = false
	title = inAdr:match('&kinopoisk=(.+)')
	if title then
		title = m_simpleTV.Common.fromPercentEncoding(title)
	else
		title = answer:match('<title>([^<]+)') or 'Kodik'
	end
	local transl = answer:match('%-translations%-box".-</div>')
	if transl and not psevdotv then
		local url = inAdr:match('^https?://[^/]+/[^/]+/')
		local t, i = {}, 1
			for w in transl:gmatch('<option.-</option>') do
				local name = w:match('>(.-)</option>')
				local hash = w:match('data%-media%-hash="([^"]+)')
				local id = w:match('data%-media%-id="([^"]+)')
				if name and hash and id then
					t[i] = {}
					t[i].Id = i
					t[i].Name = name
					t[i].Address = url .. id .. '/' .. hash .. '/720p'
					i = i + 1
				end
			end
		if i > 2 then
			local _, id = m_simpleTV.OSD.ShowSelect_UTF8('Выберете перевод - ' .. title, 0, t, 5000, 1)
			id = id or 1
		 	inAdr = t[id].Address
		else
			inAdr = t[1].Address
		end
		rc, answer = m_simpleTV.Http.Request(session, {url = inAdr, headers = 'Referer: ' .. refer})
			if rc ~= 200 then
				m_simpleTV.Http.Close(session)
				m_simpleTV.OSD.ShowMessageT({text = 'kodik ошибка[2]-' .. rc, color = 0xff99ff99, showTime = 1000 * 5, id = 'channelName'})
			 return
			end
	end
	local seasons = answer:match('<div class="serial%-panel".-</div>')
	if seasons then
		local t, i = {}, 1
			for w in seasons:gmatch('<option.-</option>') do
				local value = w:match('value="([^"]+)')
				local name = w:match('>(.-)</option>')
				if value and name then
					t[i] = {}
					t[i].Id = i
					t[i].Name = name
					t[i].Address = value
					i = i + 1
				end
			end
		if i > 2 then
			local _, id = m_simpleTV.OSD.ShowSelect_UTF8('Выберете сезон ' .. title, 0, t, 5000, 1)
			if not id then id = 1 end
		 	seson = t[id].Address
			season_title = ' (' .. t[id].Name .. ')'
		else
			seson = t[1].Address
			local ses = t[1].Name:match('%d+') or '0'
			if tonumber(ses) > 1 then
				season_title = ' (' .. t[1].Name .. ')'
			end
		end
	end
	local episodes = answer:match('<div class="series%-options".-</div>')
	if episodes then
		local t, i = {}, 1
			for w in episodes:gmatch('<option.-</option>') do
				local value = w:match('value="([^"]+)')
				local name = w:match('>(.-)</option>')
				if value and name then
					t[i] = {}
					t[i].Id = i
					t[i].Name = name
					t[i].Address = '$kodiks' .. inAdr .. '?season=' .. seson .. '&episode=' .. value
					i = i + 1
				end
			end
		m_simpleTV.User.kodik.Tabletitle = t
		t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
		t.ExtButton0 = {ButtonEnable = true, ButtonName = '⚙', ButtonScript = 'Qlty_kodik()'}
		local p = 0
		if i == 2 then
			p = 32 + 128
			m_simpleTV.User.kodik.isVideo = true
		end
		t.ExtParams = {FilterType = 2, PlayMode = 1}
		title = title .. season_title
		local _, id = m_simpleTV.OSD.ShowSelect_UTF8(title, 0, t, 5000, p)
		id = id or 1
		inAdr = t[id].Address
		m_simpleTV.User.kodik.title = title
		title = title .. ' - ' .. m_simpleTV.User.kodik.Tabletitle[1].Name
	else
		inAdr = answer:match('<iframe src="(.-)"') or answer:match('iframe.src = "(.-)"')
			if not inAdr then
				m_simpleTV.Http.Close(session)
			 return
			end
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
			t1.ExtButton0 = {ButtonEnable = true, ButtonName = '⚙', ButtonScript = 'Qlty_kodik()'}
			t1.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
			m_simpleTV.OSD.ShowSelect_UTF8('Kodik', 0, t1, 5000, 64 + 32 + 128)
		end
		m_simpleTV.User.kodik.isVideo = true
	end
	play(inAdr, title)
