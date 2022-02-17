-- видеоскрипт для плейлиста "viksTV" http://online.viks.tv (18/2/22)
-- Copyright © 2017-2022 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: viksTV_pls.lua
-- ## открывает подобные ссылки ##
-- http://online.viks.tv/421-1000-russkoe-kino.html
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://online%.viks%.tv') then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:98.0) Gecko/20100101 Firefox/98.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then return end
	answer = answer:gsub('%s+', '')
	answer = answer:gsub('<!%-%-.-%-%->', ''):gsub('/%*.-%*/', '')
	local retAdr = answer:match('file:"([^"]+)')
		if not retAdr then return end
	local function DeCipher(url)
		url = url:gsub('^%#%d', '')
		url = url:gsub('\\/', '/')
		local sep = url:match('//')
			if not sep then
			 return decode64(url)
			end
		local m
			while true do
				m = url:match(sep .. string.rep('%w', 48))
					if not m then break end
				url = url:gsub(m, '')
			end
			if url:match(sep) then return end
	 return decode64(url)
	end
	retAdr = DeCipher(retAdr)
	local v1 = answer:match('varhelloBoyzzzOne=atob%(\'([^\']+)') or ''
	local v2 = answer:match('varhelloBoyzzzTwo=atob%(\'([^\']+)') or ''
	v1 = decode64(v1)
	v2 = decode64(v2)
	local v3 = answer:match('portProtect=\'([^\']+)') or ''
	retAdr = retAdr:gsub('{v1}', v1):gsub('{v2}', v2):gsub('{v3}', v3):gsub('\n', '')
	local v3 = answer:match('portProtect=\'([^\']+)') or ''
	retAdr = retAdr:gsub('{v1}', v1):gsub('{v2}', v2):gsub('{v3}', v3)
	retAdr = retAdr .. '$OPT:http-referrer=' .. inAdr
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')
