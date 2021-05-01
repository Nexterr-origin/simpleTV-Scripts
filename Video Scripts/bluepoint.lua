-- видеоскрипт для плейлиста "bluepoint" http://bptv.info (13/9/20)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: bluepoint_pls.lua
-- расширение дополнения httptimeshift: bluepoint_pls.lua
-- открывает подобные ссылки:
-- http://bluepoint/2349
-- ##
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
	local session = m_simpleTV.Http.New('mag')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 20000)
	local cid = inAdr:match('%d+')
	local function Get_Address()
		local rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cDovL2lwdHYuYmx1ZXBvaW50dHYuY29tL2FwaS90dm1pZGRsZXdhcmUvYXBpL2NoYW5uZWwvdXJsLz9yZWRpcmVjdD0wJnRpbWV6b25lPTE1JnRpbWVzaGlmdD0wJmRldmljZT1tYWcmY2xpZW50X2lkPTEmYXBpX2tleT1YSU55NEZ2RlZEUXJyaUJGaVJvSVUza3BBdVBZaFRsaFVKVXJMYjFKNnRaZlh5cXZmSDYxcnVqd2JwSW5ncnJObGFuZz1ydSZzZXNzX2tleT0wJmF1dGhrZXk9') .. m_simpleTV.User.bluepoint.authkey .. '&cid=' .. cid})
			if rc ~= 200 then return end
		 return answer:match('<uri>([^<]+)')
		end
	local function url_archive()
		local rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cDovL2lwdHYuYmx1ZXBvaW50dHYuY29tL2FwaS90dm1pZGRsZXdhcmUvYXBpL3Byb2dyYW0vdXJsLz9yZWRpcmVjdD0wJmRldmljZT1tYWcmY2xpZW50X2lkPTEmYXBpX2tleT1YSU55NEZ2RlZEUXJyaUJGaVJvSVUza3BBdVBZaFRsaFVKVXJMYjFKNnRaZlh5cXZmSDYxcnVqd2JwSW5ncnJObGFuZz1ydSZzZXNzX2tleT0wJmF1dGhrZXk9') .. m_simpleTV.User.bluepoint.authkey .. '&cid=' .. cid .. '&time=' .. os.time() - 3600})
			if rc ~= 200 then return end
		local url_archive = answer:match('<uri>([^<]+)')
			if not url_archive then return end
		url_archive = url_archive:gsub('amp;', ''):gsub('&timestamp=%d+', '')
		m_simpleTV.User.bluepoint.url_archive = url_archive
	end
	local function Get_authkey()
		local rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cDovL2lwdHYuYmx1ZXBvaW50dHYuY29tL2FwaS90dm1pZGRsZXdhcmUvYXBpL2xvZ2luLz9kZXZpY2VfdWlkPWEwOmIxOmMyOmQzOmU0OmY1JmRldmljZV9tb2RlbD1Nb2RlbCUyMEEmZGV2aWNlX3NlcmlhbD1TTjowMTAxMTk3MCZkZXZpY2U9bWFnJmNsaWVudF9pZD0xJmFwaV9rZXk9WElOeTRGdkZWRFFycmlCRmlSb0lVM2twQXVQWWhUbGhVSlVyTGIxSjZ0WmZYeXF2Zkg2MXJ1andicEluZ3JyTiZzZXNzX2tleT0mbGFuZz1ydSZhdXRoa2V5PTAmYWJvbmVtZW50PSZwYXNzd29yZD0')})
			if rc ~= 200 then return end
		local authkey = answer:match('<authkey>([^<]+)')
			if not authkey then return end
	 return	authkey
	end
	if not m_simpleTV.User.bluepoint.authkey then
		m_simpleTV.User.bluepoint.authkey = Get_authkey()
	end
		if not m_simpleTV.User.bluepoint.authkey then
			m_simpleTV.Http.Close(session)
		 return
		end
	local retAdr = Get_Address()
	if not retAdr then
		m_simpleTV.User.bluepoint.authkey = Get_authkey()
		if m_simpleTV.User.bluepoint.authkey then
			retAdr = Get_Address()
		end
	end
		if not retAdr then
			m_simpleTV.Http.Close(session)
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