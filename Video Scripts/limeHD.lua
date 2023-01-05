-- видеоскрипт для плейлиста "LimeHD" https://limehd.tv (5/1/23)
-- Copyright © 2017-2023 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: LimeHD_pls.lua
-- расширение дополнения httptimeshift: limehd-timeshift_ext.lua
-- ## открывает подобные ссылки ##
-- https://infolink/1
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://infolink/%d') then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.infolink then
		m_simpleTV.User.infolink = {}
	end
	m_simpleTV.User.infolink.url_archive = nil
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:102.0) Gecko/20100101 Firefox/102.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local id = inAdr:match('%d+')
	local url = 'https://api.iptv2021.com/v1/streams/' .. id
	local headers = decode64('WC1BY2Nlc3MtS2V5OiAxMGFhMDkxMTQ1ODhhNWY3NTBlYWVkNWU5ZGU1MzcwNGM4NThlMTQ0')
	local rc, answer = m_simpleTV.Http.Request(session, {url = url, headers = headers})
		if rc ~= 200 then return end
	local retAdr = answer:match('"playlist_url":"([^"]+)')
		if not retAdr then return end
	m_simpleTV.User.infolink.url_archive = answer:match('"archive_url":"([^"]+)')
	local extOpt = '$OPT:adaptive-logic=highest$OPT:no-spu$OPT:adaptive-use-avdemux'
	retAdr = retAdr .. extOpt
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')
