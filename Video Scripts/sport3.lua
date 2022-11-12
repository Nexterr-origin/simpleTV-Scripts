-- видеоскрипт для сайта https://sport3.tv (12/11/22)
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
	require 'json'
	answer = answer:gsub('null', '""')
	answer = answer:gsub('%[%]', '""')
	answer = answer:gsub('\\', '\\\\')
	local tab = json.decode(answer)
		if not tab
			or not tab.data
			or not tab.data.sources
			or not tab.data.sources[1]
		then
			if tab and tab.data then
				local beginAt = tab.data.beginAt
				if beginAt and beginAt ~= '' then
					local title = tab.title or 'sport3'
					title = unescape3(title) .. '\n\nначало ' .. beginAt
					m_simpleTV.OSD.ShowMessageT({text = title, showTime = 8000, color = ARGB(255, 153, 255, 153), id = 'channelName'})
				end
			end
		 return
		end
	local title = tab.title or 'sport3'
	title = unescape3(title)
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Control.ChangeChannelLogo(logo, m_simpleTV.Control.ChannelID)
		m_simpleTV.Control.ChangeChannelName(title, m_simpleTV.Control.ChannelID, false)
	end
	local extOpt = '$OPT:adaptive-hls-ignore-discontinuity$OPT:http-referrer=https://player.sport3.tv/$OPT:http-user-agent=' .. userAgent
	local t = {}
		for i = 1, #tab.data.sources do
			local adr = tab.data.sources[i].playListUri
			local resolution = tab.data.sources[i].resolution
				if adr and resolution then
					resolution = resolution:gsub('p', ''):gsub('Auto', 30000)
					local res = tonumber(resolution)
					adr = adr:gsub('\\/', '/'):gsub('\\u0026', '&')
					if not adr:match('^https?://') then
						adr = 'https://player.sport3.tv' .. adr
					end
					t[#t + 1] = {}
					t[#t].Id = res
					t[#t].Address = adr .. extOpt
					t[#t].Name = tab.data.sources[i].resolution
				end
			end
			if #t == 0 then return end
	table.sort(t, function(a, b) return a.Id < b.Id end)
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('sport3_qlty') or 1080)
	local index = #t
	if #t > 1 then
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
	m_simpleTV.Control.CurrentTitle_UTF8 = title
	function sport3SaveQuality(obj, id)
		m_simpleTV.Config.SetValue('sport3_qlty', id)
	end
-- debug_in_file(t[index].Address .. '\n')
