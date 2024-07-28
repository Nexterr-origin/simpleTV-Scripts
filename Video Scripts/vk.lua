-- видеоскрипт для сайта http://vk.com (28/7/24)
-- Copyright © 2017-2024 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- видоскрипт: YT.lua, vimeo.lua ...
-- ## открывает подобные ссылки ##
-- https://vk.com/video_ext.php?oid=-22186156&id=456239617&hd=2&autoplay=1
-- https://vk.com/video-33598391_456239036
-- http://vkontakte.ru/video-208344_73667683
-- https://vk.com/feed?z=video-101982925_456239539%2F1900258e458f45eccc%2Fpl_post_-101982925_3149238
-- https://vk.com/video_ext.php?oid=-24136539&id=456239830&hash=34e326ffb9cbb93e
-- https://vk.com/video-208344_456241847
-- https://vk.com/video-208344_456241842
-- https://vk.com/video/playlist/-121487680_216
-- https://vk.com/video-40535376_456239512
-- https://vk.com/video/@public216539463?z=video-216539463_456239289%2Fclub216539463%2Fpl_-216539463_-2
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://vk%.com/.+')
			and not m_simpleTV.Control.CurrentAddress:match('^https?://vkontakte%.ru/.+')
		then
		 return
		end
	htmlEntities = require 'htmlEntities'
	local logo = 'https://vk.com/images/icons/favicons/fav_vk_video_2x.ico'
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = logo, UseLogo = 1, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local userAgent = 'Mozilla/5.0 (Windows NT 10.0; rv:124.0) Gecko/20100101 Firefox/124.0'
	local session = m_simpleTV.Http.New(userAgent)
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 10000)
	inAdr = inAdr:gsub('&id=', '_')
	local vId = inAdr:match('[%a=](%-?%d+_%d+)')
	local listId = inAdr:match('list=([^&]+)')
	local playlist_id = inAdr:match('/playlist/(%-?%d+_%d+)')
		if not vId and not playlist_id then return end
	local body = 'act=show&al=1&claim=&dmcah=&hd=&list=' .. (listId or '') .. '&load_playlist=1&module=direct&playlist_id=' .. (playlist_id or '') .. '&show_original=&t=&video=' .. (vId or '')
	local headers = 'X-Requested-With: XMLHttpRequest\nReferer: ' .. inAdr
	local url = 'https://vk.com/al_video.php?act=show'
	local rc, answer = m_simpleTV.Http.Request(session, {url = url, method = 'post', body = body, headers = headers})
		if rc ~= 200 then return end
	answer = answer:gsub('\\/', '/')
	local retAdr = answer:match('"hls":"([^"]+)') or answer:match('"hls_ondemand":"([^"]+)') or answer:match('"hls_live":"([^"]+)')
		if not retAdr then
			answer = answer:gsub('\\"', '"')
			retAdr = answer:match('<iframe[^>]+src="([^"]+)')
				if not retAdr then return end
			retAdr = retAdr:gsub('^//', 'https://')
			m_simpleTV.Control.ChangeAddress = 'No'
			m_simpleTV.Control.CurrentAddress = retAdr
			dofile(m_simpleTV.MainScriptDir_UTF8 .. 'user/video/video.lua')
		 return
		end
	local addTitle = 'VK'
	local title = answer:match('"payload":%[%d+,%["([^"]+)')
	if not title then
		title = addTitle
	else
		title = m_simpleTV.Common.multiByteToUTF8(title)
		title = htmlEntities.decode(title)
		if m_simpleTV.Control.MainMode == 0 then
			m_simpleTV.Control.ChangeChannelName(title, m_simpleTV.Control.ChannelID, false)
			local poster = answer:match('background%-image:url%(([^)]+)') or logo
			m_simpleTV.Control.ChangeChannelLogo(poster, m_simpleTV.Control.ChannelID)
		end
		title = addTitle .. ' - ' .. title
	end
	local rc, answer = m_simpleTV.Http.Request(session, {url = retAdr})
		if rc ~= 200 then return end
	local extOpt = '$OPT:http-user-agent=' .. userAgent
	if not answer:match('RESOLUTION=') then
		answer = answer:gsub('QUALITY=lowest', 'RESOLUTION=1x240'):gsub('QUALITY=low', 'RESOLUTION=2x360'):gsub('QUALITY=sd', 'RESOLUTION=3x480'):gsub('QUALITY=hd', 'RESOLUTION=4x720')
	end
	local t = {}
		for w in answer:gmatch('EXT%-X%-STREAM%-INF(.-\n.-)\n') do
			adr = w:match('\n(.+)')
			name = w:match('RESOLUTION=%d+x(%d+)')
			if adr and name then
				t[#t + 1] = {}
				t[#t].Name = name .. 'p'
				if not adr:match('^https?://') then
					adr = retAdr:match('.+/') .. adr:gsub('^/', '')
				end
				t[#t].Address = adr .. extOpt
				t[#t].Id = tonumber(name)
			end
		end
	m_simpleTV.Control.CurrentTitle_UTF8 = title
			if #t ==0 then
				m_simpleTV.Control.CurrentAddress = retAdr .. extOpt
			 return
			end
	table.sort(t, function(a, b) return a.Id < b.Id end)
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('vk_qlty') or 1080)
	local index = #t
	if #t > 1 then
		t[#t + 1] = {}
		t[#t].Id = 5000
		t[#t].Name = '▫ всегда высокое'
		t[#t].Address = t[#t - 1].Address
		t[#t + 1] = {}
		t[#t].Id = 50000
		t[#t].Name = '▫ адаптивное'
		t[#t].Address = retAdr .. extOpt
		index = #t
			for i = 1, #t do
				if t[i].Id >= lastQuality then
					index = i
				 break
				end
			end
		if index > 1 then
			if t[index].Id > lastQuality then
				index = index - 1
			end
		end
		if m_simpleTV.Control.MainMode == 0 then
			t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
			t.ExtParams = {LuaOnOkFunName = 'vkSaveQuality'}
			m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128)
		end
	end
	m_simpleTV.Control.CurrentAddress = t[index].Address
	function vkSaveQuality(obj, id)
		m_simpleTV.Config.SetValue('vk_qlty', id)
	end
-- debug_in_file(t[index].Address .. '\n')
