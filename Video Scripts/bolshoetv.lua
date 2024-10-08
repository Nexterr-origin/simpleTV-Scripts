-- видеоскрипт для плейлиста "Большое ТВ" https://bolshoe.tv (9/10/24)
-- Copyright © 2017-2024 Nexterr, NEKTO666 | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: bolshoetv_pls.lua
-- ## открывает подобные ссылки ##
-- https://bolshoe.tv/promo/web/tv/6291/
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://bolshoe%.tv')
		then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:129.0) Gecko/20100101 Firefox/129.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 12000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cHM6Ly9hcGkuYm9sc2hvZS50di93ZWIvMS9hdXRoL3dlYg')})
		if rc ~= 200 then return end
	local token = answer:match('"access_token":"([^"]+)')
		if not token then return end
	local id = inAdr:match('(%d+)/$')
		if not id then return end
	local headers = 'Content-Type: application/json\n' ..
					'X-APP-PLATFORM: WEB\n' ..
					'X-APP-ACCESS-TOKEN: ' .. token
	local body = '{"stream_id":"' .. id .. '","dev_model":"ANDROID_TV"}'
	local rc, answer = m_simpleTV.Http.Request(session, {method = 'post', url = decode64('aHR0cHM6Ly9hcGkuYm9sc2hvZS50di92MS9hZ3JlZ2F0b3IvZ2V0UmVsZWFzZUNoYW5uZWw'), body = body, headers = headers})
		if rc ~= 200 then return end
	answer = answer:match('"stream_url":"([^"]+)')
	retAdr = answer:gsub('\\/', '/')
	if not retAdr:match('^https?') then 
		retAdr = 'http:' .. retAdr
	end
		if not retAdr then return end
	m_simpleTV.Control.CurrentAddress = retAdr
	
-- debug_in_file(m_simpleTV.Control.CurrentAddress .. '\n')