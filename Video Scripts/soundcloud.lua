-- видеоскрипт для сайта https://soundcloud.com (14/9/20)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## открывает подобные ссылки ##
-- https://soundcloud.com/octobersveryown/blocboy-jb-look-alive-ft-drake
-- https://w.soundcloud.com/player/?url=https://api.soundcloud.com/tracks/304789348&auto_play=false&hide_related=true&show_comments=false&show_user=true&show_reposts=false&visual=true
-- https://soundcloud.com/giovannisarani/mezzo-valzer
-- https://soundcloud.com/oriuplift/uponly-238-no-talking-wav/s-AyZUd
-- https://soundcloud.com/bi-s-n-3/sets/chilloutwithme
-- https://soundcloud.com/snbrn/ele
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('https?://[%w%.]*soundcloud%.com')
			and not m_simpleTV.Control.CurrentAddress:match('^%$soundcloud')
		then
		 return
		end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.OSD.ShowMessageT({text = '', showTime = 1000, id = 'channelName'})
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = '', UseLogo = 0, Once = 1})
	end
	local function showError(str)
		m_simpleTV.OSD.ShowMessageT({text = 'soundcloud ошибка: ' .. str, showTime = 5000, color = 0xffff1000, id = 'channelName'})
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = ''
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.soundcloud then
		m_simpleTV.User.soundcloud = {}
	end
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:81.0) Gecko/20100101 Firefox/81.0')
		if not session then
			showError('1')
		 return
		end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local function secondsToClock(sec)
			if not sec or sec == '' then return end
		sec = tonumber(sec)
		sec = sec / 1000
		sec = string.format('%01d:%02d:%02d',
									math.floor(sec / 3600),
									math.floor(sec / 60) % 60,
									math.floor(sec % 60))
	 return sec:gsub('^0[0:]+(.+:)', '%1' .. '')
	end
	local function GetClientId(answ)
		local client_id
			for js_script in answ:gmatch('crossorigin src="(http[^\'\"<>]+%.js)') do
					if not js_script then break end
				local rc, answer = m_simpleTV.Http.Request(session, {url = js_script})
				if rc ~= 200 then
					answer = ''
				end
				client_id = answer:match('{client_id:"([^"]+)') or answer:match('client_id:%a%?"([^"]+)')
					if client_id then break end
			end
	 return client_id
	end
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr:gsub('$soundcloud', '')})
		if rc ~= 200 and inAdr:match('^%$soundcloud') then
			showError('2\nнедоступно')
			m_simpleTV.Http.Close(session)
			m_simpleTV.Control.CurrentAddress = 'vlc://pause:3'
			m_simpleTV.Control.CurrentTitle_UTF8 = 'недоступно'
		 return
		end
		if rc ~= 200 then
			showError('3 - ' .. rc)
			m_simpleTV.Http.Close(session)
		 return
		end
	if not m_simpleTV.User.soundcloud.client_id then
		local client_id = GetClientId(answer)
			if not client_id then
				showError('4\nnot found client id')
			 return
			end
		m_simpleTV.User.soundcloud.client_id = client_id
	end
	if not inAdr:match('$soundcloud') then
		m_simpleTV.User.soundcloud.cover = answer:match('"og:image" content="([^"]+)') or 'https://a-v2.sndcdn.com/assets/images/errors/500-e5a180b7.png'
		if m_simpleTV.Control.MainMode == 0 then
			m_simpleTV.Control.ChangeChannelLogo('http://icons.iconarchive.com/icons/uiconstock/socialmedia/256/Soundcloud-icon.png', m_simpleTV.Control.ChannelID)
		end
		local plst = answer:match('soundcloud%.com/playlists/%d+')
		if plst then
			plst = 'http://api-v2.' .. plst .. '?client_id=' .. m_simpleTV.User.soundcloud.client_id
			rc, answer = m_simpleTV.Http.Request(session, {url = plst})
				if rc ~= 200 then
					showError('5 - ' .. rc)
					m_simpleTV.Http.Close(session)
					m_simpleTV.User.soundcloud.client_id = nil
				 return
				end
			require 'json'
			answer = answer:gsub(':%s*%[%]', ':""')
			answer = answer:gsub('%[%]', ' ')
			local tab = json.decode(answer)
				if not tab then
					showError('6')
					m_simpleTV.User.soundcloud.client_id = nil
				 return
				end
			m_simpleTV.Control.CurrentTitle_UTF8 = header
			local s = 0
			local z1, g = {}, 1
			local z, g = '#', 1
				while tab.tracks[g] do
					z1[g] = {}
					z1[g] = tab.tracks[g].id
					z = z .. tab.tracks[g].id .. ','
					if s == 49 then
						z = z .. '#'
						s = 0
						g = g - 1
					end
					s = s + 1
					g = g + 1
				end
			local header = tab.title .. ' [playlist]'
			if m_simpleTV.Control.MainMode == 0 then
				m_simpleTV.Control.ChangeChannelName(header, m_simpleTV.Control.ChannelID, false)
			end
			m_simpleTV.Control.CurrentTitle_UTF8 = header
			answer = ''
				for w in z:gmatch('[^#]+') do
					local url = 'https://api-v2.soundcloud.com/tracks?ids=' .. w .. '&client_id=' .. m_simpleTV.User.soundcloud.client_id
					rc, answer0 = m_simpleTV.Http.Request(session, {url = url})
					answer = answer .. answer0
				end
				if answer == '' then
					showError('7 - ' .. rc)
					m_simpleTV.Http.Close(session)
					m_simpleTV.User.soundcloud.client_id = nil
				 return
				end
			answer = answer:gsub(':%s*%[%]', ':""')
			answer = answer:gsub('%[%]', ' ')
			answer = answer:gsub('%]%[', ',')
			local tab = json.decode(answer)
				if not tab then
					showError('8')
					m_simpleTV.User.soundcloud.client_id = nil
				 return
				end
			local t, i = {}, 1
			local g = 1
			local name, desc, duration
				while tab[i] do
					name = tab[i].title
					t[i] = {}
					t[i].Id = i
					t[i].iid = tab[i].id
					t[i].Name = name
					t[i].Address = '$soundcloudhttps://w.soundcloud.com/player/?url=' .. tab[i].uri
					t[i].InfoPanelName = name
					t[i].InfoPanelShowTime = 8000
					t[i].InfoPanelLogo = tab[i].artwork_url or 'https://a-v2.sndcdn.com/assets/images/errors/500-e5a180b7.png'
					desc = tab[i].description
					if desc and #desc > 50 then
						t[i].InfoPanelDesc = desc:gsub('\\n', '\r'):gsub('%s+', ' ')
						desc = ' описание'
					else
						desc = nil
					end
					duration = secondsToClock(tab[i].duration)
					if duration and desc then
						t[i].InfoPanelTitle = desc .. ' | ' .. duration
					else
						t[i].InfoPanelTitle = desc or duration or ''
					end
					i = i + 1
				end
				if i == 1 then
					showError('9')
					m_simpleTV.User.soundcloud.client_id = nil
				 return
				end
			local sort, s = {}, 1
				for x = 1, #z1 do
					for y = 1, #t do
						if z1[x] == t[y].iid then
							sort[s] = t[y]
							s = s + 1
						 break
						end
					end
				end
			local FilterType, AutoNumberFormat
			if #t > 3 then
				FilterType = 1
				AutoNumberFormat = '%1. %2'
			else
				FilterType = 2
				AutoNumberFormat = ''
			end
			sort.ExtParams = {FilterType = FilterType, AutoNumberFormat = AutoNumberFormat}
			if i > 2 then
				local _, id = m_simpleTV.OSD.ShowSelect_UTF8(header, 0, sort, 10000)
				id = id or 1
				inAdr = sort[id].Address
			else
				inAdr = sort[1].Address
			end
			rc, answer = m_simpleTV.Http.Request(session, {url = inAdr:gsub('$soundcloud', '')})
				if rc ~= 200 then
					showError('10\nнедоступно')
					m_simpleTV.Http.Close(session)
					m_simpleTV.Control.CurrentAddress = 'vlc://pause:3'
					m_simpleTV.Control.CurrentTitle_UTF8 = header
				 return
				end
		end
	end
	local embedUrl = answer:match('itemprop="embedUrl" content="([^"]+)')
	if embedUrl then
		embedUrl = embedUrl:gsub('&amp;', '&')
		embedUrl = embedUrl:gsub('&#x3D;', '=')
		embedUrl = embedUrl:gsub('^//', 'https://')
		rc, answer = m_simpleTV.Http.Request(session, {url = embedUrl})
			if rc ~= 200 then
				showError('11 - ' .. rc)
				m_simpleTV.Http.Close(session)
				m_simpleTV.User.soundcloud.client_id = nil
			 return
			end
	end
	local url = answer:match('http[^\'\"<>]+/progressive[^\'\"<>]*') or answer:match('http[^\'\"<>]+/stream/hls[^\'\"<>]*')
		if not url then
			showError('12')
			m_simpleTV.User.soundcloud.client_id = nil
		 return
		end
	answer = answer:gsub('\\"', '%%22')
	local title = answer:match('"title":"([^"]+)') or answer:match('<title>([^<]+)') or 'soundcloud'
	title = title:gsub('| Free.+', '')
	title = title:gsub('\\u0026', '&')
	title = title:gsub('%%22', '"')
	if url:match('secret_token') then
		url = url .. '&client_id=' .. m_simpleTV.User.soundcloud.client_id
	else
		url = url .. '?client_id=' .. m_simpleTV.User.soundcloud.client_id
	end
	rc, answer = m_simpleTV.Http.Request(session, {url = url})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then
			showError('13 - ' .. rc)
			m_simpleTV.User.soundcloud.client_id = nil
		 return
		end
	local retAdr = answer:match('"url":"([^"]+)')
		if not retAdr then
			showError('14')
			m_simpleTV.User.soundcloud.client_id = nil
		 return
		end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Control.SetBackground({BackColor = 0, BackColorEnd = 255, PictFileName = m_simpleTV.User.soundcloud.cover, TypeBackColor = 0, UseLogo = 3, Once = 1})
		if not inAdr:match('$soundcloud') then
			m_simpleTV.Control.ChangeChannelName(title, m_simpleTV.Control.ChannelID, false)
		end
	end
	if not inAdr:match('$soundcloud') then
		m_simpleTV.Control.CurrentTitle_UTF8 = title
	else
		m_simpleTV.Control.SetTitle(title)
	end
	m_simpleTV.OSD.ShowMessageT({text = title, color = 0xff9999ff, showTime = 1000 * 5, id = 'channelName'})
	retAdr = retAdr:gsub('u0026', '&') .. '$OPT:NO-STIMESHIFT$OPT:POSITIONTOCONTINUE=0'
	if retAdr:match('playlist%.m3u8') then
		retAdr = retAdr .. '$OPT:demux=avcodec,any'
	end
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')