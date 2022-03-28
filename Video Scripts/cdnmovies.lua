-- видеоскрипт для видеобалансера "CDN Movies" https://cdnmovies.net (29/3/22)
-- Copyright © 2017-2022 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- модуль: /core/playerjs.lua
-- ## открывает подобные ссылки ##
-- http://moonwalk.cam/movie/4514
-- http://moonwalk.cam/serial/5311
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://moonwalk%.cam')
			and not m_simpleTV.Control.CurrentAddress:match('^$cdnmovies')
		then
		 return
		end
	local inAdr = m_simpleTV.Control.CurrentAddress
	if not inAdr:match('&kinopoisk') then
		if m_simpleTV.Control.MainMode == 0 then
			m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
		end
	end
	require 'json'
	require 'playerjs'
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.cdnmovies then
		m_simpleTV.User.cdnmovies = {}
	end
	m_simpleTV.User.cdnmovies.DelayedAddress = nil
	m_simpleTV.User.cdnmovies.startAdr = inAdr
	local function showMsg(str)
		local t = {text = 'CDN Movies ошибка: ' .. str, showTime = 1000 * 8, color = ARGB(255, 255, 102, 0), id = 'channelName'}
		m_simpleTV.OSD.ShowMessageT(t)
	end
	local function getIndex(t)
		local lastQuality = tonumber(m_simpleTV.Config.GetValue('cdnmovies_qlty') or 5000)
		local index = #t
			for i = 1, #t do
				if t[i].qlty >= lastQuality then
					index = i
				 break
				end
			end
		if index > 1 then
			if t[index].qlty > lastQuality then
				index = index - 1
			end
		end
	 return index
	end
	local function getAdr(url)
			if not url then return end
		url = url:gsub('^$cdnmovies', '')
		local t, i = {}, 1
			for qlty, adr in url:gmatch('%[(%d+).-%]([^,]+)') do
				t[i] = {}
				t[i].Id = i
				t[i].qlty = tonumber(qlty)
				t[i].Address = adr:gsub('%.m3u8', '.mp4') .. '$OPT:NO-STIMESHIFT'
				t[i].Name = qlty .. 'p'
				i = i + 1
			end
			if #t == 0 then return end
		table.sort(t, function(a, b) return a.qlty < b.qlty end)
		m_simpleTV.User.cdnmovies.Tab = t
		local index = getIndex(t)
		m_simpleTV.User.cdnmovies.Index = index
	 return t[index].Address
	end
	local function trim(str)
		str = string.match(str,'^%s*(.-)%s*$')
	 return str
	end
	local function play(adr, title)
		local retAdr = getAdr(adr)
			if not retAdr then
				m_simpleTV.Control.CurrentAddress = 'http://wonky.lostcut.net/vids/error_getlink.avi'
			 return
			end
-- debug_in_file(retAdr .. '\n')
		m_simpleTV.Control.SetTitle(title)
		m_simpleTV.OSD.ShowMessageT({text = title, showTime = 1000 * 5, id = 'channelName'})
		m_simpleTV.Control.CurrentAddress = retAdr
	end
	local function transl()
		local tab = m_simpleTV.User.cdnmovies.tab
		local hash, t = {}, {}
			for i = 1, #tab do
				local title = trim(tab[i].title)
				if not hash[title] then
					t[#t + 1] = tab[i]
					hash[title] = true
				end
			end
		local selected = m_simpleTV.User.cdnmovies.tr
		local selected_dubl, selected_pro
			for i = 1, #t do
				t[i].Id = i
				t[i].Address = t[i].file
				local name = t[i].title
				t[i].Name = name
				if not selected then
					if not selected_dubl
						and (name:match('дублир') and not name:match('%[..%]'))
					then
						selected_dubl = i
					end
					if not selected_pro
						and (name:match('фессион') and not name:match('%[..%]'))
					then
						selected_pro = i
					end
				end
			end
		selected = selected or selected_dubl or selected_pro or #t
		t.ExtButton0 = {ButtonEnable = true, ButtonName = '🎞️'}
		if m_simpleTV.User.paramScriptForSkin_buttonOk then
			t.OkButton = {ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOk}
		end
		local ret, id = m_simpleTV.OSD.ShowSelect_UTF8('перевод: ' .. m_simpleTV.User.cdnmovies.title, selected - 1, t, 10000, 1 + 2 + 4 + 8)
			if ret == 2 then
				m_simpleTV.Control.Restart(-2.0, true)
			 return
			end
			if t[1].Address then
				id = id or selected
			elseif not id
				and m_simpleTV.Control.GetState() == 0
				and m_simpleTV.User.cdnmovies.DelayedAddress
			then
				m_simpleTV.Control.ExecuteAction(11)
			 return
			elseif not id
				and m_simpleTV.Control.GetState() == 0
			then
				id = id or selected
			elseif not id then
			 return
			end
		m_simpleTV.User.cdnmovies.tr = id
		m_simpleTV.User.cdnmovies.adr = t[id].Address
	 return true
	end
	local function seasons()
		local tab = m_simpleTV.User.cdnmovies.tab
		local title = m_simpleTV.User.cdnmovies.title
		local tr = m_simpleTV.User.cdnmovies.tr
		local t, i = {}, 1
			while tab[tr].folder[i] do
				t[i] = {}
				t[i].Id = i
				t[i].Name = trim(tab[tr].folder[i].title)
				i = i + 1
			end
			if #t == 0 then return end
		if m_simpleTV.User.paramScriptForSkin_buttonOk then
			t.OkButton = {ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOk}
		end
		if m_simpleTV.User.paramScriptForSkin_buttonPrev then
			t.ExtButton1 = {ButtonEnable = true, ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonPrev}
		else
			t.ExtButton1 = {ButtonEnable = true, ButtonName = '🢀'}
		end
		local ret, id = m_simpleTV.OSD.ShowSelect_UTF8('сезон: ' .. title, - 1, t, 10000, 1 + 2 + 4 + 8)
			if ret == 3 then
				if transl() then
					serials_cdnmovies()
				end
			 return
			end
			if not id
				and m_simpleTV.Control.GetState() == 0
				and m_simpleTV.User.cdnmovies.DelayedAddress
			then
				m_simpleTV.Control.ExecuteAction(11)
			 return
			elseif not id
				and m_simpleTV.Control.GetState() == 0
			then
				id = 1
			elseif not id then
			 return
			end
		m_simpleTV.User.cdnmovies.season = id
		m_simpleTV.User.cdnmovies.seasonName = ' (' .. t[id].Name .. ')'
	 return true
	end
	local function episodes()
		local tr = m_simpleTV.User.cdnmovies.tr
		local tab = m_simpleTV.User.cdnmovies.tab
		local season = m_simpleTV.User.cdnmovies.season
		local t, i = {}, 1
			while tab[tr].folder[season].folder[i] do
				t[i] = {}
				t[i].Id = i
				t[i].Name = tab[tr].folder[season].folder[i].title
				t[i].Address = '$cdnmovies' .. tab[tr].folder[season].folder[i].file
				i = i + 1
			end
			if #t == 0 then return end
		local retAdr = getAdr(t[1].Address)
			if not retAdr then
				m_simpleTV.Control.CurrentAddress = 'http://wonky.lostcut.net/vids/error_getlink.avi'
			 return
			end
		m_simpleTV.User.cdnmovies.DelayedAddress = retAdr
		local title = m_simpleTV.User.cdnmovies.title .. m_simpleTV.User.cdnmovies.seasonName
		m_simpleTV.Control.SetTitle(title)
		if m_simpleTV.User.paramScriptForSkin_buttonOptions then
			t.ExtButton0 = {ButtonEnable = true, ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOptions, ButtonScript = 'qlty_cdnmovies()'}
		else
			t.ExtButton0 = {ButtonEnable = true, ButtonName = '⚙', ButtonScript = 'qlty_cdnmovies()'}
		end
		if m_simpleTV.User.paramScriptForSkin_buttonOk then
			t.OkButton = {ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOk}
		end
		if m_simpleTV.User.paramScriptForSkin_buttonPrev then
			t.ExtButton1 = {ButtonEnable = true, ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonPrev, ButtonScript = 'serials_cdnmovies()'}
		else
			t.ExtButton1 = {ButtonEnable = true, ButtonName = '🢀', ButtonScript = 'serials_cdnmovies()'}
		end
		t.ExtParams = {}
		t.ExtParams.LuaOnCancelFunName = 'OnMultiAddressCancel_cdnmovies'
		t.ExtParams.LuaOnOkFunName = 'OnMultiAddressOk_cdnmovies'
		t.ExtParams.LuaOnTimeoutFunName = 'OnMultiAddressCancel_cdnmovies'
		t.ExtParams.StopOnError = 1
		t.ExtParams.StopAfterPlay = 1
		t.ExtParams.PlayMode = 1
		m_simpleTV.OSD.ShowSelect_UTF8(title, 0, t, 10000, 2 + 64)
		m_simpleTV.User.cdnmovies.episodeTitle = title .. ': ' .. t[1].Name
		m_simpleTV.Control.CurrentAddress = 'wait'
		m_simpleTV.Control.SetNewAddressT({address = m_simpleTV.Control.CurrentAddress})
	end
	local function movie()
		local title = m_simpleTV.User.cdnmovies.title
		local adr = m_simpleTV.User.cdnmovies.adr
		local t = {}
		t[1] = {}
		t[1].Id = 1
		t[1].Name = title
		if m_simpleTV.User.paramScriptForSkin_buttonOptions then
			t.ExtButton0 = {ButtonEnable = true, ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOptions, ButtonScript = 'qlty_cdnmovies()'}
		else
			t.ExtButton0 = {ButtonEnable = true, ButtonName = '⚙', ButtonScript = 'qlty_cdnmovies()'}
		end
		if m_simpleTV.User.paramScriptForSkin_buttonOk then
			t.OkButton = {ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOk}
		end
		m_simpleTV.OSD.ShowSelect_UTF8('CDN Movies', 0, t, 10000, 64 + 32 + 128)
		play(adr, title)
	end
	local function getData()
		local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:98.0) Gecko/20100101 Firefox/98.0')
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 8000)
		local url = inAdr:gsub('&kinopoisk.+', '')
		local rc, answer = m_simpleTV.Http.Request(session, {url = url, headers = 'Referer: https://cdnmovies.net/'})
		m_simpleTV.Http.Close(session)
			if rc ~= 200 then
			 return 'это видео удалено'
			end
		local file = answer:match('file:\'([^\']+)')
			if not file then return end
		local playerjs_url = answer:match('script src="([^"]+)')
			if not playerjs_url then return end
		local host = url:match('^https?://[^/]+')
		if not playerjs_url:match('^https?://') then
			playerjs_url = host .. playerjs_url
		end
		local file = playerjs.decode(file, playerjs_url)
			if not file or file == '' then return end
		file = m_simpleTV.Common.multiByteToUTF8(file)
		file = file:gsub('%[%]', '""')
		local err, tab = pcall(json.decode, file)
		local ser = file:match('folder')
	 return tab, ser
	end
	function serials_cdnmovies()
		if seasons() then
			episodes()
		end
	end
	function qlty_cdnmovies()
		local t = m_simpleTV.User.cdnmovies.Tab
			if not t then return end
		m_simpleTV.Control.ExecuteAction(37)
		local index = getIndex(t)
		if m_simpleTV.User.paramScriptForSkin_buttonOk then
			t.OkButton = {ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOk}
		end
		if m_simpleTV.User.paramScriptForSkin_buttonClose then
			t.ExtButton1 = {ButtonEnable = true, ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonClose, ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
		else
			t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
		end
		local ret, id = m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 10000, 1 + 2 + 4)
		if ret == 1 then
			m_simpleTV.Control.SetNewAddressT({address = t[id].Address, position = m_simpleTV.Control.GetPosition()})
			m_simpleTV.Config.SetValue('cdnmovies_qlty', t[id].qlty)
		end
	end
	function OnMultiAddressOk_cdnmovies(Object, id)
		if id == 1 then
			OnMultiAddressCancel_cdnmovies(Object)
		else
			m_simpleTV.User.cdnmovies.DelayedAddress = nil
		end
	end
	function OnMultiAddressCancel_cdnmovies(Object)
		if m_simpleTV.User.cdnmovies.DelayedAddress then
			if m_simpleTV.Control.GetState() == 0 then
				m_simpleTV.Control.SetNewAddressT({address = m_simpleTV.User.cdnmovies.DelayedAddress, position = 0})
				local title = m_simpleTV.User.cdnmovies.episodeTitle
				m_simpleTV.Control.SetTitle(title)
				m_simpleTV.OSD.ShowMessageT({text = title, showTime = 1000 * 5, id = 'channelName'})
			end
			m_simpleTV.User.cdnmovies.DelayedAddress = nil
		end
	end
		if inAdr:match('^$cdnmovies') then
			local title = ''
			local t = m_simpleTV.Control.GetCurrentChannelInfo()
			if t
				and t.MultiHeader
				and t.MultiName
			then
				title = t.MultiHeader .. ': ' .. t.MultiName
			end
			play(inAdr, title)
		 return
		end
	local tab, ser = getData()
		if type(tab) ~= 'table' then
			showMsg('нет данных')
		 return
		end
	local title = inAdr:match('&kinopoisk=(.+)')
	if title then
		title = m_simpleTV.Common.fromPercentEncoding(title)
	else
		title = 'CDN Movies'
	end
	m_simpleTV.User.cdnmovies.title = title
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Control.ChangeChannelName(title, m_simpleTV.Control.ChannelID, false)
	end
	m_simpleTV.User.cdnmovies.tab = tab
	m_simpleTV.User.cdnmovies.tr = nil
	if transl() then
		if ser then
			serials_cdnmovies()
		else
			if m_simpleTV.Control.MainMode == 0 then
				m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
			end
			movie()
		end
	end
