-- видеоскрипт для плейлиста "Россия ТВ" https://vgtrk.com (9/3/20)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## открывает подобные ссылки ##
-- https://player.vgtrk.com/iframe/datalive/id/19201/sid/kultura
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
		if not inAdr then return end
		if not inAdr:match('^https?://live%.russia%.tv/channel/%d')
			and not inAdr:match('^https?://player%.vgtrk%.com/iframe/[%a]*live/id/%d')
		then
		 return
		end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = '', UseLogo = 0, Once = 1})
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.122 Safari/537.36')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local id = inAdr:match('/channel/(%d+)')
	if id then
		inAdr = 'https://live.russia.tv/api/now/channel/' .. id
	end
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
		if rc ~= 200 then
			m_simpleTV.Http.Close(session)
		 return
		end
	local url
	local sid = answer:match('&sid=(%w+)') or answer:match('\\?/sid\\?/(%w+)')
	local live_id = answer:match('"live_id":(%d+)') or answer:match('datavideo/id/(%d+)')
		if not sid or not live_id then
			url = answer:match('"player_url":"([^"]+)')
				if not url or not live_id then return end
			url = url:gsub('\\/', '/')
			url = url:gsub('<live_id>', live_id)
			rc, answer = m_simpleTV.Http.Request(session, {url = url})
				if rc ~= 200 then
					m_simpleTV.Http.Close(session)
				 return
				end
			url = answer:match('window%.pl%.data%.dataUrl = \'([^\']+)')
				if not url then return end
			url = url:gsub('^//', 'https://')
			url = url:gsub('/datavideo/', '/datalive/')
		else
			url = 'https://player.vgtrk.com/iframe/datalive/id/'.. live_id .. '/sid/' .. sid
		end
	rc, answer = m_simpleTV.Http.Request(session, {url = url, headers = 'X-Requested-With: XMLHttpRequest\nReferer: ' .. url})
		if rc ~= 200 then
			m_simpleTV.Http.Close(session)
		 return
		end
	local retAdr = answer:match('"auto":"([^"]+)')
		if not retAdr then return end
	rc, answer = m_simpleTV.Http.Request(session, {url = retAdr})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then return end
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')