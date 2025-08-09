-- видеоскрипт для плейлиста "Sarkor TV" https://sarkor.tv (14/7/25)
-- Copyright © 2017-2025 Nexterr, NEKTO666 | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: sarkortv_pls.lua
-- ## открывает подобные ссылки ##
-- https://sarkor.tv/03/80
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://sarkor%.tv')
		then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	local m = inAdr:match('([^/]%d*)$')
	local s = inAdr:match('^https://sarkor.tv/([^/]%d*)')
		if s ~= '0' then 
			s = 's' .. s .. '.' 
			p = '' 
		else 
			s = '' 
			p = ':443' 
		end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local retAdr = 'https://' .. s .. decode64('d2F0Y2hlci51eg') .. p .. '/' .. m .. decode64('L3ZpZGVvLm0zdTg/dG9rZW49ZXlKaGJHY2lPaUpJVXpJMU5pSXNJblI1Y0NJNklrcFhWQ0o5LmV5SmpiMjUwY21GamRGOXBaQ0k2TkRRM016VXpMQ0pzYjJkcGJpSTZJblIyTFRRME56TTFNeUlzSW5SbGJYQnZjbUZ5ZVNJNlptRnNjMlVzSW1selgyOWhkWFJvSWpwbVlXeHpaU3dpWTNKbFlYUmxaRjkwYVcxbElqb3hOelV5TkRBek5ETTJmUS50Zl9xUVhILUJ2MFRaWGRUdUs1Q0ptUUlqUFRNZk52azBXMldDdDF6elFnOjIw')
		if not retAdr then return end
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(m_simpleTV.Control.CurrentAddress .. '\n')
