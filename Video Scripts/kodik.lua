-- видеоскрипт для видеобазы "kodik" http://kodik.cc (20/10/20)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## открывает подобные ссылки ##
-- http://kodik.info/serial/19183/acbb94d039454b7584f1f29fdd05ae23/720p
-- https://hdrise.com/video/31756/445f20d7950d3df08f7574311e82521e/720p
-- http://kodik.info/serial/13166/dc6c81648d5b5173461756cf1f2cd0e4/720p
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
		if not inAdr then return end
		if not inAdr:match('^https?://kodik%.')
			and not inAdr:match('^https?://hdrise%.com')
			and not inAdr:match('^https?://hdlizor%.com')
			and not inAdr:match('^%$kodiks')
		then
		 return
		end
	m_simpleTV.OSD.ShowMessageT({text = '', showTime = 1000, id = 'channelName'})
	if inAdr:match('^%$kodiks') or not inAdr:match('&kinopoisk') then
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
	m_simpleTV.Control.CurrentAddress = ''
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3809.87 Safari/537.36')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.kodik then
		m_simpleTV.User.kodik = {}
	end
	if not m_simpleTV.User.kodik.qlty then
		m_simpleTV.User.kodik.qlty = tonumber(m_simpleTV.Config.GetValue('Kodik_qlty') or '10000')
	end
	local title
	local refer = 'http://the-cinema.fun/'
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
		local index
		for u = 1, #t do
				if t[u].qlty and m_simpleTV.User.kodik.qlty < t[u].qlty then break end
			index = u
		end
	 return index or 1
	end
	local function GetAddress(retAdr)
		retAdr = retAdr:gsub('^//', 'http://')
		local rc, answer = m_simpleTV.Http.Request(session, {url = retAdr, headers = 'Referer: ' .. refer})
			if rc ~= 200 then return end
		local domain = answer:match('domain = "(.-)"')
		local d_sign = answer:match('d_sign = "(.-)"')
		local pd = answer:match('pd = "(.-)"')
		local pd_sign = answer:match('pd_sign = "(.-)"')
		local ref = answer:match('ref = "(.-)"')
		-- local ref_sign = answer:match('ref_sign = "(.-)"')
		local typ = answer:match('videoInfo%.type = \'(.-)\'')
		local hash = answer:match('hash = \'(.-)\'')
		local id = answer:match('id = \'(.-)\'')
			if not domain
				or not d_sign
				or not pd
				or not pd_sign
				or not ref
				-- or not ref_sign
				or not typ
				or not hash
				or not id
			then
			 return
			end
		local script = answer:match('type="text/javascript" .-src="(.-)"')
			if not script then return end
		rc, answer = m_simpleTV.Http.Request(session, {url = 'http://' .. pd .. script, headers = 'Referer: ' .. refer})
		local url = answer:match('url:"(.-)"')
		local hash2 = answer:match('hash2:"(.-)"')
			if not url or not hash2 then return end
		local headers = 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8\nX-Requested-With: XMLHttpRequest\nReferer: ' .. refer
		local body = 'd=' .. domain
				.. '&d_sign=' .. d_sign
				.. '&pd=' .. pd
				..'&pd_sign=' .. pd_sign
				.. '&ref=' .. url_encode(ref)
				-- .. '&ref_sign=' .. ref_sign
				.. '&bad_user=false'
				.. '&type=' .. typ
				.. '&hash=' .. hash
				.. '&hash2=' .. hash2
				.. '&id=' .. id
		rc, answer = m_simpleTV.Http.Request(session, {url = 'http://' .. pd .. url, method = 'post', headers = headers, body = body})
			if rc ~= 200 then return end
	 return answer
	end
	local function GetkodikAddress(answer)
		answer = answer:gsub('%[', '')
		local t, i = {}, 1
		local qlty, adr
		local link = answer:match('"link":"(.-)"')
		if link then
			local rc, answer = m_simpleTV.Http.Request(session, {url = link})
				if rc ~= 200 then return end
			for w in link:gmatch('#EXT%-X%-STREAM%-INF:(.-m3u8)') do
				qlty = w:match('RESOLUTION=%d+x(%d+)')
				adr = w:match('(http.+)')
					if not qlty or not adr then break end
				t[i] = {}
				t[i].Address = adr .. '$OPT:NO-STIMESHIFT'
				t[i].qlty = qlty
				i = i + 1
			end
		else
			for w in answer:gmatch('"%d+":{"src":".-}') do
				qlty = w:match('"(%d+)"')
				adr = w:match('"src":"(.-)"')
					if not qlty or not adr then return end
				t[i] = {}
				if adr:match('kodik') then
					adr = adr:gsub('%.mp4.+', '.mp4') .. '$OPT:NO-STIMESHIFT'
				end
				t[i].qlty = qlty
				t[i].Address = adr:gsub('^//', 'http://'):gsub('manifest%.m3u8', 'index.m3u8')
				i = i + 1
			end
		end
			if i == 1 then return end
			for _, v in pairs(t) do
				v.qlty = tonumber(v.qlty)
				if v.qlty > 0 and v.qlty <= 180 then
					v.qlty = 144
				elseif v.qlty > 180 and v.qlty <= 300 then
					v.qlty = 240
				elseif v.qlty > 300 and v.qlty <= 400 then
					v.qlty = 360
				elseif v.qlty > 400 and v.qlty <= 500 then
					v.qlty = 480
				elseif v.qlty > 500 and v.qlty <= 780 then
					v.qlty = 720
				elseif v.qlty > 780 and v.qlty <= 1200 then
					v.qlty = 1080
				elseif v.qlty > 1200 and v.qlty <= 1500 then
					v.qlty = 1444
				elseif v.qlty > 1500 and v.qlty <= 2800 then
					v.qlty = 2160
				elseif v.qlty > 2800 and v.qlty <= 4500 then
					v.qlty = 4320
				end
				v.Name = v.qlty .. 'p'
			end
		table.sort(t, function(a, b) return a.qlty < b.qlty end)
		for i = 1, #t do
			t[i].Id = i
		end
		m_simpleTV.User.kodik.Table = t
		local index = GetMaxResolutionIndex(t)
		m_simpleTV.User.kodik.Index = index
	 return t[index].Address
	end
	function SavePlst_kodik()
		if m_simpleTV.User.kodik.Tabletitle and m_simpleTV.User.kodik.title then
			m_simpleTV.OSD.ShowMessageT({text = 'Сохранение плейлиста ...', color = 0xff9bffff, showTime = 1000 * 30, id = 'channelName'})
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
			local folder = m_simpleTV.Common.GetMainPath(2) .. m_simpleTV.Common.UTF8ToMultiByte('сохраненые плейлисты/')
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
			local ret, id = m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 1 + 4 + 2)
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
		local answer = GetAddress(Adr:gsub('^%$kodiks', ''))
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
		if inAdr:match('^%$kodik') then
			play(inAdr, title)
		 return
		end
	inAdr = inAdr:gsub('&kinopoisk', '')
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr, headers = 'Referer: ' .. refer})
		if rc ~= 200 then
			m_simpleTV.Http.Close(session)
		 return
		end
	local season_title = ''
	local seson = ''
	m_simpleTV.User.kodik.Tabletitle = nil
	m_simpleTV.User.kodik.isVideo = false
	title = m_simpleTV.Control.CurrentTitle_UTF8 or 'kodik'
	local transl = answer:match('%-translations%-box".-</div>')
	if transl and not psevdotv then
		local t, i = {}, 1
			for Adr, name in transl:gmatch('<option value="(.-)">(.-)<') do
				t[i] = {}
				t[i].Id = i
				t[i].Name = name
				t[i].Address = Adr:gsub('^//', 'http://'):gsub('%?.+', '')
				i = i + 1
			end
		if i > 2 then
			local _, id = m_simpleTV.OSD.ShowSelect_UTF8('Выберете перевод - ' .. title, 0, t, 5000, 1)
			if not id then id = 1 end
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
	local seasons = answer:match('<div class="series(.-)class="serial')
	if seasons then
		local t, i = {}, 1
			for seas in seasons:gmatch('<div class=(.-)</div>') do
				t[i] = {}
				t[i].Id = i
				t[i].Name = seas:match('"season%-(%d+)"') .. ' сезон'
				t[i].Address = seas:match('"season%-(%d+)"')
				i = i + 1
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
	local episodes = answer:match('season%-'.. seson .. '(.-)</div>')
	if episodes then
		local t, i = {}, 1
			for epis in episodes:gmatch('<option(.-)/option>') do
				t[i] = {}
				t[i].Id = i
				t[i].Name = epis:match('value=.->(.-)<')
				t[i].Address = '$kodiks' .. (epis:match('value="(.-)"'))
				i = i + 1
			end
		m_simpleTV.User.kodik.Tabletitle = t
		t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
		t.ExtButton0 = {ButtonEnable = true, ButtonName = '⚙', ButtonScript = 'Qlty_kodik()'}
		local p = 0
		if i == 2 then
			p = 32 + 128
			m_simpleTV.User.kodik.isVideo = true
		end
		t.ExtParams = {FilterType = 2}
		title = title .. season_title
		local _, id = m_simpleTV.OSD.ShowSelect_UTF8(title, 0, t, 5000, p)
		if not id then
			id = 1
		end
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