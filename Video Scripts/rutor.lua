-- видеоскрипт для сайта http://rutor.info (10/3/21)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- Acestream
-- ## открывает подобные ссылки ##
-- http://rutor.info/torrent/734402/shestero-vne-zakona_6-underground-2019-web-dlrip-ot-megapeer-pifagor
-- http://6tor.net/torrent/742142/1917_1917-2019-screener-hdrezka-studio
-- ## прокси ##
local proxy = ''
-- '' - нет
-- 'https://proxy-nossl.antizapret.prostovpn.org:29976' (пример)
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://rutor%.is/.+')
			and not m_simpleTV.Control.CurrentAddress:match('^https?://rutor%.info/.+')
			and not m_simpleTV.Control.CurrentAddress:match('^https?://6tor%.net/.+')
			and not m_simpleTV.Control.CurrentAddress:match('^https?://mega%-pro%.xyz/.+')
			and not m_simpleTV.Control.CurrentAddress:match('torrent_rutor_')
		then
		 return
		end
	local inAdr = m_simpleTV.Control.CurrentAddress
	if inAdr:match('^https?://6tor%.net/') then
		proxy = ''
	end
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = ''
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.rutor then
		m_simpleTV.User.rutor = {}
	end
		if inAdr:match('^torrent://') then
			local index = inAdr:match('%$TORRENTINDEX=(%d+)')
			if not index or (m_simpleTV.User.rutor.id
				and m_simpleTV.User.rutor.id ~= inAdr:match('%d+'))
			then
				m_simpleTV.User.rutor.posterUrl = 'https://raw.githubusercontent.com/Nexterr-origin/simpleTV-Images/main/rutor.png'
				m_simpleTV.User.rutor.title = nil
			end
			if m_simpleTV.Control.ChannelID == 268435455 then
				local title = 'rutor'
				if index then
					title = (m_simpleTV.User.rutor.title or title) .. ' (' .. (index + 1) .. ')'
				end
				m_simpleTV.Control.CurrentTitle_UTF8 = title
			end
			if m_simpleTV.Control.MainMode == 0 then
				m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = (m_simpleTV.User.rutor.posterUrl or 'https://raw.githubusercontent.com/Nexterr-origin/simpleTV-Images/main/rutor.png'), TypeBackColor = 0, UseLogo = 3, Once = 1})
			end
			m_simpleTV.Control.CurrentAddress = inAdr .. '$OPT:POSITIONTOCONTINUE=0'
		 return
		end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, BackColorEnd = 255, PictFileName = '', TypeBackColor = 0, UseLogo = 3, Once = 1})
	end
	local id = inAdr:match('/download/(%d+)') or inAdr:match('/torrent/(%d+)')
		if not id then return end
	m_simpleTV.User.rutor.id = id
	local host = inAdr:match('^(https?://.-)/')
	inAdr = host .. '/download/' .. id
	local url = host .. '/torrent/' .. id
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:81.0) Gecko/20100101 Firefox/81.0', proxy, false)
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 16000)
	local function GetImdbPoster(d)
			if not d then return end
		local sessionThemoviedb = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML,like Gecko) Chrome/79.0.3785.143 Safari/537.36')
			if not sessionThemoviedb then return end
		m_simpleTV.Http.SetTimeout(sessionThemoviedb, 8000)
		local url = 'https://api.themoviedb.org/3/find/' .. d .. decode64('P2FwaV9rZXk9ZDU2ZTUxZmI3N2IwODFhOWNiNTE5MmVhYWE3ODIzYWQmbGFuZ3VhZ2U9cnUmZXh0ZXJuYWxfc291cmNlPWltZGJfaWQ')
		local rc, answer = m_simpleTV.Http.Request(sessionThemoviedb, {url = url})
		m_simpleTV.Http.Close(sessionThemoviedb)
			if rc ~= 200 then return end
		local poster = answer:match('"poster_path":"([^"]+)')
			if not poster or poster == '' then return end
	 return 'http://image.tmdb.org/t/p/w500' .. poster
	end
	m_simpleTV.User.rutor.posterUrl = nil
	local rc, torFile = m_simpleTV.Http.Request(session, {url = inAdr, writeinfile = true, filename = 'torrent_rutor_' .. id .. '.torrent'})
		if rc ~= 200 then return end
	local rc, answer = m_simpleTV.Http.Request(session, {url = url})
	local title = answer:match('<title>([^<]+)') or 'rutor'
	title = title:gsub('.+:: ', ''):gsub('&amp;', '&')
	m_simpleTV.User.rutor.title = title
	m_simpleTV.Control.CurrentTitle_UTF8 = title
	m_simpleTV.Control.CurrentAddress = 'torrent://' .. torFile
	local id_imdb = answer:match('imdb%.com/title/(%w+)')
	local adr = GetImdbPoster(id_imdb)
	if not adr then
		local answer0 = answer:match('<table id="details">.-</a>(.-)<u>') or ''
		answer0 = answer0:gsub('href="https?://vk%.com.-" target="_blank"><img src="[^"]+', '')
		adr = answer0:match('<img src="(http[^\'"<>]+%.[jpegpng]+)')
		if adr then
			rc = m_simpleTV.Http.Request(session, {url = adr})
			if rc == - 1 or rc == 404 then
				adr = nil
			end
		end
	end
	m_simpleTV.Http.Close(session)
	if not adr then
		adr = answer:match('kinopoisk%.ru/rating/(%d+)')
		if adr then
			adr = 'https://st.kp.yandex.net/images/film_iphone/iphone360_' .. adr .. '.jpg'
		end
	end
	adr = adr or 'https://raw.githubusercontent.com/Nexterr-origin/simpleTV-Images/main/rutor.png'
	m_simpleTV.User.rutor.posterUrl = adr
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = adr, TypeBackColor = 0, UseLogo = 3, Once = 1})
		m_simpleTV.Control.ChangeChannelLogo('https://m.polit.ru/media/photolib/2013/08/26/rutor_1444831134.png', m_simpleTV.Control.ChannelID)
		m_simpleTV.Control.ChangeChannelName(title, m_simpleTV.Control.ChannelID, false)
	end
-- debug_in_file(retAdr .. '\n')