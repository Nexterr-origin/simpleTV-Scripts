-- видеоскрипт для сайта http://promodj.com (27/12/19)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## открывает подобные ссылки ##
-- https://promodj.com/pdjlive/videos/4214028/Therr_Maitz_live_PDJTV_Joys
-- https://promodj.com/144330155140/tracks/7017395/Velial_Trillaz_Because_I_m_Black
-- https://promodj.com/dj-vartan/promos/6482899/Dj_Vartan_Mix_20_09_2017_Weekend_Update_Vol_52
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://promodj%.com') then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = ''
	local logo = 'http://cdn.promodj.com/legacy/i/logo_2x_white.png'
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = logo, UseLogo = 1, Once = 1})
	end
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.79 Safari/537.36')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local function unescape_html(str)
		str = str:gsub('&nbsp;', ' ')
		str = str:gsub('&rsquo;', 'e')
		str = str:gsub('&eacute;', "'")
		str = str:gsub('&#039;', "'")
		str = str:gsub('&ndash;', "-")
		str = str:gsub('&#8217;', "'")
		str = str:gsub('&raquo;', '"')
		str = str:gsub('&laquo;', '"')
		str = str:gsub('&lt;', '<')
		str = str:gsub('&gt;', '>')
		str = str:gsub('&quot;', '"')
		str = str:gsub('&apos;', "'")
		str = str:gsub('&#(%d+);', function(n) return string.char(n) end)
		str = str:gsub('&#x(%d+);', function(n) return string.char(tonumber(n, 16)) end)
		str = str:gsub('&amp;', '&') -- Be sure to do this after all others
	 return str
	end
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then return end
	local retAdr = answer:match('http[^\'"<>]+%.mp4') or answer:match('http[^\'"<>]+%.m3u8') or answer:match('href="(http[^\'"<>]+%.mp3)')
		if not retAdr then return end
	local title = answer:match('<title>([^<]+)') or 'promodj'
	title = unescape_html(title)
	m_simpleTV.Control.CurrentTitle_UTF8 = title
	logo = answer:match('"og:image" content="([^"]+)') or logo
	m_simpleTV.Control.ChangeChannelLogo(logo, m_simpleTV.Control.ChannelID)
	retAdr = retAdr:gsub('\\\\\\', '\\'):gsub('\\/', '/')
	retAdr = retAdr .. '$OPT:NO-STIMESHIFT'
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')