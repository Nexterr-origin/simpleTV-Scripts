-- видеоскрипт для сайта https://www.superyacht.tv (24/11/21)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## открывает подобные ссылки ##
-- https://www.superyacht.tv/en/superyacht-tv-en
-- https://www.superyacht.tv/en/the-yachts/moonstone
-- https://superyacht.tv/en/barcelona-superyacht-show-2019/jonathan-zwaans-of-y-co
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://[%a%.]*superyacht%.tv/.+') then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
	local logo = 'https://www.superyacht.tv/media/cache/header_main_logo/bundles/app/img/logo.png'
	if m_simpleTV.Control.MainMode == 0 then
		local UseLogo
		if m_simpleTV.Control.ChannelID == 268435455 then
			UseLogo = 1
			m_simpleTV.OSD.ShowMessageT({text = '', showTime = 1000, id = 'channelName'})
		else
			UseLogo = 0
		end
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = logo, UseLogo = UseLogo, Once = 1})
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:94.0) Gecko/20100101 Firefox/94.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
		if rc ~= 200 then
			m_simpleTV.Http.Close(session)
		 return
		end
	local retAdr = answer:match('https://[^\'"<>]+%.m3u8[^\'"<>]*')
		if not retAdr then return end
	if not answer:match('\'Live%-Player\'') then
		local title = answer:match('<h2 class="bold">([^<]+)')
		if not title then
			title = 'Superyacht TV'
		else
			if m_simpleTV.Control.MainMode == 0 then
				m_simpleTV.Control.ChangeChannelName(title, m_simpleTV.Control.ChannelID, false)
				m_simpleTV.Control.ChangeChannelLogo(logo, m_simpleTV.Control.ChannelID)
			end
		end
		m_simpleTV.Control.CurrentTitle_UTF8 = title
		m_simpleTV.OSD.ShowMessageT({text = title, showTime = 5000, id = 'channelName'})
	end
	rc, answer = m_simpleTV.Http.Request(session, {url = retAdr})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then return end
	local host = retAdr:match('^https?://[^/]+')
	answer = answer .. '\n'
	local t = {}
		for w in answer:gmatch('EXT%-X%-STREAM%-INF.-\n.-\n') do
			local adr = w:match('\n(.-)\n')
			local name = w:match('BANDWIDTH=(%d+)')
			if adr and name then
				name = tonumber(name)
				t[#t + 1] = {}
				t[#t].Id = name
				t[#t].Name = name / 1000 .. ' кбит/с'
				t[#t].Address = host .. adr
			end
		end
		if #t == 0 then
			m_simpleTV.Control.CurrentAddress = retAdr
		 return
		end
	table.sort(t, function(a, b) return a.Id < b.Id end)
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('superyacht_qlty') or 10000000)
	local index = #t
	if #t > 1 then
		t[#t + 1] = {}
		t[#t].Id = 10000000
		t[#t].Name = '▫ всегда высокое'
		t[#t].Address = t[#t - 1].Address
		t[#t + 1] = {}
		t[#t].Id = 500000000
		t[#t].Name = '▫ адаптивное'
		t[#t].Address = retAdr
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
			t.ExtParams = {LuaOnOkFunName = 'superyachtSaveQuality'}
			m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128)
		end
	end
	m_simpleTV.Control.CurrentAddress = t[index].Address
	function superyachtSaveQuality(obj, id)
		m_simpleTV.Config.SetValue('superyacht_qlty', tostring(id))
	end
-- debug_in_file(m_simpleTV.Control.CurrentAddress .. '\n')
