-- видеоскрипт для сайта https://tele-sport.ru (17/11/21)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- видоскрипт: ok.lua
-- ## открывает подобные ссылки ##
-- https://tele-sport.ru/pryamaya-translyatsiya-telekanala-telesport
-- https://tele-sport.ru/football/russia/russiancup/baltika-khimki-bet-siti-kubok-rossii-3-tur
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://tele%-sport%.ru') then return end
	require 'json'
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local logo = 'https://tele-sport.ru/_nuxt/c64bef8f3f7b264c51fd4e2705116424.svg'
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = logo, UseLogo = 1, Once = 1})
	end
	local userAgent = 'Mozilla/5.0 (Windows NT 10.0; rv:94.0) Gecko/20100101 Firefox/94.0'
	local session = m_simpleTV.Http.New(userAgent)
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
		if rc ~= 200 then
			m_simpleTV.Http.Close(session)
		 return
		end
	answer = answer:gsub('<!%-.-%->', '')
	local title = answer:match('<title>(.-)</title>') or 'TELESPORT'
	if m_simpleTV.Control.MainMode == 0 then
		local poster = answer:match('"og:image" content="([^"]+)') or logo
		m_simpleTV.Control.ChangeChannelLogo(poster, m_simpleTV.Control.ChannelID)
		m_simpleTV.Control.ChangeChannelName(title, m_simpleTV.Control.ChannelID, false)
	end
	local url = answer:match('<iframe.-src="([^"]+)')
		if not url then return end
	url = url:gsub('^//', 'https://')
		if not url:match('tele%-sport') then
			m_simpleTV.Control.ChangeAddress = 'No'
			m_simpleTV.Control.CurrentAddress = url
			dofile(m_simpleTV.MainScriptDir .. 'user/video/video.lua')
		 return
		end
	url = url:gsub('/embedded', '/api/front')
	rc, answer = m_simpleTV.Http.Request(session, {url = url, headers = 'Referer: ' .. inAdr})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then return end
	answer = answer:match('"sources":(%[.+)')
		if not answer then return end
	answer = answer:gsub('%[%]', '""')
	answer = unescape3(answer)
	answer = answer:gsub('\\/', '/')
	local tab = json.decode(answer)
		if not tab then return end
	local extOpt = '$OPT:http-referrer=https://tele-sport.ru/$OPT:http-user-agent=' .. userAgent
	local t, i = {}, 1
		while tab[i] do
			local res = tab[i].resolution:match('(%d+)p')
			if res then
				t[#t + 1] = {}
				t[#t].Id = tonumber(res)
				t[#t].Name = res .. 'p'
				t[#t].Address = tab[i].playListUri:gsub('^/', 'https://player.tele-sport.ru/') .. extOpt
			end
			i = i + 1
		end
		if #t == 0 then return end
	table.sort(t, function(a, b) return a.Id < b.Id end)
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('teleSport_qlty') or 5000)
	local index = #t
	if #t > 1 then
		t[#t + 1] = {}
		t[#t].Id = 5000
		t[#t].Name = '▫ всегда высокое'
		t[#t].Address = t[#t - 1].Address
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
			t.ExtParams = {LuaOnOkFunName = 'teleSportSaveQuality'}
			m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128)
		end
	end
	m_simpleTV.Control.CurrentTitle_UTF8 = title
	m_simpleTV.Control.CurrentAddress = t[index].Address
	function teleSportSaveQuality(obj, id)
		m_simpleTV.Config.SetValue('teleSport_qlty', id)
	end
-- debug_in_file(t[index].Address .. '\n')
