-- видеоскрипт для плейлиста "PeersTV" http://peers.tv (27/05/21)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: peersTV_pls.lua
-- расширение дополнения httptimeshift: peerstv-timeshift_ext.lua
-- ## открывает подобные ссылки ##
-- http://hls.peers.tv/streaming/rentv/126/vh1w/playlist.m3u8
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://[%w%-]+%.peers%.tv/.+') then return end
		if m_simpleTV.Control.CurrentAddress:match('PARAMS=peers_tv') then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local userAgent = 'Dalvik/2.1.0 (Linux; U; Android 8.0.1;)'
	local ref = 'https://peers.tv/'
	local extopt = '$OPT:adaptive-logic=highest$OPT:demux=adaptive,any$OPT:adaptive-use-access'
				.. '$OPT:http-user-agent=' .. userAgent
				.. '$OPT:http-referrer=' .. ref
				.. '$OPT:no-ts-cc-check'
				.. '$OPT:INT-SCRIPT-PARAMS=peers_tv'
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.peerstv then
		m_simpleTV.User.peerstv = {}
	end
	m_simpleTV.User.peerstv.url_archive = nil
	local function getToken()
		local session = m_simpleTV.Http.New(userAgent)
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 8000)
		local rc, answer = m_simpleTV.Http.Request(session, {body = decode64('Z3JhbnRfdHlwZT1pbmV0cmElM0Fhbm9ueW1vdXMmY2xpZW50X2lkPTI5NzgzMDUxJmNsaWVudF9zZWNyZXQ9YjRkNGViNDM4ZDc2MGRhOTVmMGFjYjViYzZiNWM3NjA'), url = decode64('aHR0cDovL2FwaS5wZWVycy50di9hdXRoLzIvdG9rZW4='), method = 'post', headers = 'Content-Type: application/x-www-form-urlencoded'})
		m_simpleTV.Http.Close(session)
			if rc ~= 200 then return end
	 return	answer:match('"access_token":"([^"]+)')
	end
	local function url_archive()
		local session = m_simpleTV.Http.New(userAgent)
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 12000)
		local id = inAdr:match('id=(%d+)')
		local rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cHM6Ly9hcGkucGVlcnMudHYvbWVkaWFsb2NhdG9yLzEvdGltZXNoaWZ0Lmpzb24/b2Zmc2V0PTcyMDAmc3RyZWFtX2lkPQ') .. id, headers = decode64('QXV0aG9yaXphdGlvbjogQmVhcmVyIA') .. m_simpleTV.User.peerstv.token})
		m_simpleTV.Http.Close(session)
			if rc ~= 200 then return end
		local url = answer:match('"uri":"([^"]+)')
			if not url then return end
		url = url:gsub('\\/', '/'):gsub('offset=%d+&', '')
		m_simpleTV.User.peerstv.url_archive = url .. extopt
	end
	if not m_simpleTV.User.peerstv.token then
		local token = getToken()
			if not token then return end
		m_simpleTV.User.peerstv.token = token
	end
	if inAdr:match('id=%d') then
		url_archive()
	end
	if inAdr:match('?offset=1') then
		inAdr = inAdr:gsub('offset=1' , 'offset=10')
		local url = inAdr:gsub('offset=.+', 'token=' .. m_simpleTV.User.peerstv.token .. extopt)
		m_simpleTV.User.peerstv.url_archive = url .. extopt
	end
	inAdr = inAdr:gsub('/experimental/', '/streaming/'):gsub('$.-$', '')
	local retAdr = inAdr .. '?token=' .. m_simpleTV.User.peerstv.token
	retAdr = retAdr:gsub('^(.-)([%?&]offset=%d+)(.-)$' , '%1%3%2')
	retAdr = retAdr:gsub('[%?&]+' , '&')
	retAdr = retAdr:gsub('&' , '?', 1)
	retAdr = retAdr .. extopt
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')
