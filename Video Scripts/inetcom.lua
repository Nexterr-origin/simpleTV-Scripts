-- видеоскрипт для плейлиста "Inetcom" https://inetcom.tv (3/1/23)
-- Copyright © 2017-2023 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: inetcom_pls.lua
-- ## открывает подобные ссылки ##
-- http://inetcom.tv/294
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://inetcom.tv/%d') then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local function getStream(id)
		local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:102.0) Gecko/20100101 Firefox/102.0')
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 8000)
		local url = decode64('aHR0cDovL2FwaTQuaW5ldGNvbS50di9jaGFubmVsL2FsbA')
		local rc, answer = m_simpleTV.Http.Request(session, {url = url})
			if rc ~= 200 then return end
		require 'json'
		local err, tab = pcall(json.decode, answer)
			if not tab then return end
		local stream
		local t = {}
			for i = 1, #tab do
				if tonumber(id) == tab[i].id then
					stream = tab[i].streams.hls
				 break
				end
			end
	 return stream
	end
	local id = inAdr:match('%d+')
	local retAdr = getStream(id)
		if not retAdr then return end
	local extOpt = ''
	retAdr = retAdr .. extOpt
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')