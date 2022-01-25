-- видеоскрипт для плейлиста "bluepoint" http://bptv.info (25/1/22)
-- Copyright © 2017-2022 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: bluepoint_pls.lua
-- расширение дополнения httptimeshift: bluepoint_pls.lua
-- открывает подобные ссылки:
-- http://bluepoint/2349
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^http://bluepoint/%d') then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.bluepoint then
		m_simpleTV.User.bluepoint = {}
	end
	m_simpleTV.User.bluepoint.url_archive = nil
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'erorr'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (QtEmbedded; U; Linux; C) AppleWebKit/533.3 (KHTML, like Gecko) MAG200 stbapp ver: 2 rev: 234 Safari/533.3')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 16000)
	local cid = inAdr:match('%d+')
	local function Get_Address()
		local url = decode64('PXlla2h0dWEmMD15ZWtfc3NlcyZ1cj1nbmFsTnJyZ25JcGJ3anVyMTZIZnZxeVhmWnQ2SjFiTHJVSlVobFRoWVB1QXBrM1VJb1JpRkJpcnJRRFZGdkY0eU5JWD15ZWtfaXBhJjE9ZGlfdG5laWxjJmdhbT1lY2l2ZWQmMD10Zmloc2VtaXQmNTE9ZW5vemVtaXQmMD10Y2VyaWRlcj8vbHJ1L2xlbm5haGMvaXBhL2VyYXdlbGRkaW12dC9pcGEvbW9jLnZ0dG5pb3BldWxiLnl0cmFtcy8vOnB0dGg')
		local rc, answer = m_simpleTV.Http.Request(session, {url = string.reverse(url) .. m_simpleTV.User.bluepoint.authkey .. '&cid=' .. cid})
			if rc ~= 200 then return end
		 return answer:match('<uri>([^<]+)')
		end
	local function url_archive()
		local url = decode64('PXlla2h0dWEmMD15ZWtfc3NlcyZ1cj1nbmFsTnJyZ25JcGJ3anVyMTZIZnZxeVhmWnQ2SjFiTHJVSlVobFRoWVB1QXBrM1VJb1JpRkJpcnJRRFZGdkY0eU5JWD15ZWtfaXBhJjE9ZGlfdG5laWxjJmdhbT1lY2l2ZWQmMD10Y2VyaWRlcj8vbHJ1L21hcmdvcnAvaXBhL2VyYXdlbGRkaW12dC9pcGEvbW9jLnZ0dG5pb3BldWxiLnl0cmFtcy8vOnB0dGg')
		local rc, answer = m_simpleTV.Http.Request(session, {url = string.reverse(url) .. m_simpleTV.User.bluepoint.authkey .. '&cid=' .. cid .. '&time=' .. os.time() - 3600})
			if rc ~= 200 then return end
		local url_archive = answer:match('<uri>([^<]+)')
			if not url_archive then return end
		url_archive = url_archive:gsub('amp;', ''):gsub('&timestamp=%d+', '')
		m_simpleTV.User.bluepoint.url_archive = url_archive
	end
	local function Get_authkey()
		local url = decode64('TnJyZ25JcGJ3anVyMTZIZnZxeVhmWnQ2SjFiTHJVSlVobFRoWVB1QXBrM1VJb1JpRkJpcnJRRFZGdkY0eU5JWD15ZWtfaXBhJjE9ZGlfdG5laWxjJj8vbmlnb2wvaXBhL2VyYXdlbGRkaW12dC9tb2MudnR0bmlvcGV1bGIueXRyYW1zLy86cHR0aA')
		local rc, answer = m_simpleTV.Http.Request(session, {url = string.reverse(url)})
			if rc ~= 200 then return end
		local authkey = answer:match('"authkey":"([^"]+)')
			if not authkey then return end
	 return	authkey
	end
	if not m_simpleTV.User.bluepoint.authkey then
		m_simpleTV.User.bluepoint.authkey = Get_authkey()
	end
		if not m_simpleTV.User.bluepoint.authkey then return end
	local retAdr = Get_Address()
	if not retAdr then
		m_simpleTV.User.bluepoint.authkey = Get_authkey()
		if m_simpleTV.User.bluepoint.authkey then
			retAdr = Get_Address()
		end
	end
		if not retAdr then
			m_simpleTV.User.bluepoint.authkey = nil
		 return
		end
	retAdr = retAdr:gsub('amp;', '')
	m_simpleTV.Control.CurrentAddress = retAdr
	if inAdr:match('archive=true') then
		url_archive()
	end
	m_simpleTV.Http.Close(session)
-- debug_in_file(retAdr .. '\n')