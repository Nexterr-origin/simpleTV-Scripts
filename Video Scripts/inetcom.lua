-- видеоскрипт для плейлиста "Inetcom" https://inetcom.tv (9/12/23)
-- Copyright © 2017-2023 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: inetcom_pls.lua
-- ## открывает подобные ссылки ##
-- https://inetcom.tv/294
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://inetcom.tv/%d') then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local userAgent = 'Mozilla/5.0 (Linux; Android 7.1.2; A5010 Build/N2G48H; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/66.0.3359.158 Mobile Safari/537.36'
	local function getStream(id)
		local session = m_simpleTV.Http.New(userAgent)
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 8000)
		local headers = decode64('WC1DbGllbnQtSW5mbzogQW5kcm9pZFBob25lIDUwMzI3NTgyClgtQ2xpZW50LU1vZGVsOiBPbmVQbHVzIEE1MDEwClgtRGV2aWNlOiA0ClJlZmVyZXI6IGh0dHA6Ly9pcHR2LmluZXRjb20ucnUvcGhvbmVfYXBwX3YyL2luZGV4Lmh0bWw/cGxhdGZvcm09QW5kcm9pZFBob25lJnNlcmlhbD01MDMyNzU4MgpYLVJlcXVlc3RlZC1XaXRoOiB0di5pbmV0Y29tLnBob25lMg')
		local url = decode64('aHR0cDovL2FwaTQuaW5ldGNvbS50di9jaGFubmVsL2FsbA')
		local rc, answer = m_simpleTV.Http.Request(session, {url = url, headers = headers})
			if rc ~= 200 then return end
		require 'json'
		local err, tab = pcall(json.decode, answer)
			if not tab
				or not tab[1]
				or not tab[1].id
			then
			 return
			end
		local stream
			for i = 1, #tab do
				if tonumber(id) == tonumber(tab[i].id) then
					stream = tab[i].streams.hls
				 break
				end
			end
	 return stream
	end
	local id = inAdr:match('%d+')
	local retAdr = getStream(id)
		if not retAdr then return end
	local extOpt = '$OPT:http-user-agent=' .. userAgent
	retAdr = retAdr:gsub('//hls%d%.', '//hls1.')
	retAdr = retAdr .. extOpt
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')
