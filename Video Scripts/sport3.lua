-- видеоскрипт для сайта https://sport3.tv (10/11/22)
-- Copyright © 2017-2022 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## открывает подобные ссылки ##
-- https://sport3.tv/kubok-afl/202607
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://sport3%.tv/.+') then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
	local logo = 'https://sport3.tv/logo.svg'
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = logo, TypeBackColor = 0, UseLogo = 1, Once = 1})
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local userAgent = 'Mozilla/5.0 (Windows NT 10.0; rv:102) Gecko/20100101 Firefox/102'
	local session = m_simpleTV.Http.New(userAgent)
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local url = inAdr:gsub('https://sport3.tv/', 'https://player.sport3.tv/api/proxy-zfront/')
	local rc, answer = m_simpleTV.Http.Request(session, {url = url})
		if rc ~= 200 then return end
	local retAdr
	if answer:match('"type":"live"') then
		retAdr = answer:match('"playListUri":"([^"]+/adaptive[^"]+)')
	else
		retAdr = answer:match('"playListUri":"\\/(master%?uri=[^"]+)')
		if retAdr then
			retAdr = 'https://player.sport3.tv/' .. retAdr
		end
	end
		if not retAdr then return end
	retAdr = retAdr:gsub('\\/', '/'):gsub('\\u0026', '&')
	local title = answer:match('"title":"([^"]+)') or 'sport3'
	title = unescape3(title)
	if m_simpleTV.Control.MainMode == 0 then
		local thumbnail = answer:match('"thumbnailUri":"([^"]+)') or logo
		m_simpleTV.Control.ChangeChannelLogo(thumbnail, m_simpleTV.Control.ChannelID)
		m_simpleTV.Control.ChangeChannelName(title, m_simpleTV.Control.ChannelID, false)
	end
	local rc, answer = m_simpleTV.Http.Request(session, {url = retAdr})
		if rc ~= 200 then return end
	local extOpt = '$OPT:adaptive-hls-ignore-discontinuity$OPT:http-referrer=https://player.sport3.tv/$OPT:http-user-agent=' .. userAgent
	local host = retAdr:match('https?://[^/]+/')
	local t = {}
		for w in string.gmatch(answer,'EXT%-X%-STREAM%-INF(.-\n.-)\n') do
			local name = w:match('RESOLUTION=%d+x(%d+)')
			local adr = w:match('\n(.+)')
			if name and adr then
				name = tonumber(name)
				if not adr:match('^http') then
					adr = host .. adr
				end
				t[#t +1] = {}
				t[#t].Address = adr .. extOpt
				t[#t].Id = name
				t[#t].Name = name .. 'p'
			end
		end
	m_simpleTV.Control.CurrentTitle_UTF8 = title
		if #t == 0 then
			m_simpleTV.Control.CurrentAddress = retAdr .. extOpt
		 return
		end
	table.sort(t, function(a, b) return a.Id < b.Id end)
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('sport3_qlty') or 1080)
	local index = #t
	if #t > 1 then
		t[#t + 1] = {}
		t[#t].Id = 20000
		t[#t].Name = '▫ всегда высокое'
		t[#t].Address = t[#t - 1].Address
		t[#t + 1] = {}
		t[#t].Id = 30000
		t[#t].Name = '▫ адаптивное'
		t[#t].Address = retAdr .. extOpt
		index = #t
			for i = 1, #t do
				if t[i].Id >= lastQuality then
					index = i
				 break
				end
			end
		if index > 1 then
			if t[index].Id > lastQuality then
				index = index - 1
			end
		end
		if m_simpleTV.Control.MainMode == 0 then
			t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
			t.ExtParams = {LuaOnOkFunName = 'sport3SaveQuality'}
			m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 10000, 32 + 64 + 128)
		end
	end
	m_simpleTV.Control.CurrentAddress = t[index].Address
	function sport3SaveQuality(obj, id)
		m_simpleTV.Config.SetValue('sport3_qlty', id)
	end
-- debug_in_file(t[index].Address .. '\n')