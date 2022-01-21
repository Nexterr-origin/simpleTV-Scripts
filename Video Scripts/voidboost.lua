-- видеоскрипт для видеобалансера "voidboost" (21/1/22)
-- Copyright © 2017-2022 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- модуль: /core/playerjs.lua
-- ## открывает подобные ссылки ##
-- https://voidboost.net/serial/019c13f13f6455b96df66f6933ed7bc2/iframe?h=voidboost.net
-- https://voidboost.net/embed/5928
-- ## прокси ##
local proxy = ''
-- '' - нет
-- например 'http://proxy-nossl.antizapret.prostovpn.org:29976'
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://voidboost%.net/.+')
			and not m_simpleTV.Control.CurrentAddress:match('^$voidboost')
		then
		 return
		end
	require 'playerjs'
	local inAdr = m_simpleTV.Control.CurrentAddress
	if not inAdr:match('&kinopoisk') then
		if m_simpleTV.Control.MainMode == 0 then
			m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
		end
	end
	local function showError(str)
		local t = {text = 'voidboost ошибка: ' .. str, showTime = 1000 * 8, color = ARGB(255, 255, 102, 0), id = 'channelName'}
		m_simpleTV.OSD.ShowMessageT(t)
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:96.0) Gecko/20100101 Firefox/96.0', proxy, false)
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 16000)
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.voidboost then
		m_simpleTV.User.voidboost = {}
	end
	m_simpleTV.User.voidboost.DelayedAddress = nil
	local title
	if m_simpleTV.User.voidboost.titleTab then
		local index = m_simpleTV.Control.GetMultiAddressIndex()
		if index then
			title = m_simpleTV.User.voidboost.title .. ' - ' .. m_simpleTV.User.voidboost.titleTab[index].Name
		end
	end
	local function voidboostDeSex(url)
		url = url:gsub('\\/', '/')
		url = url:match(': \'(#[^\']+)')
			if not url then
			 return url
			end
	 return playerjs.decode(url, m_simpleTV.User.voidboost.playerjs_url)
	end
	local function voidboostIndex(t)
		local lastQuality = tonumber(m_simpleTV.Config.GetValue('voidboost_qlty') or 5000)
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
	local function GetAdr(urls)
		local t = {}
			for qlty, adr in urls:gmatch('%[(.-)](https?://[^%s]+)') do
				t[#t + 1] = {}
				t[#t].Address = adr
				t[#t].Name = qlty
				if qlty == '1080p Ultra' then
					qlty = '1100'
				end
				t[#t].qlty = tonumber(qlty:match('%d+'))
			end
			if #t == 0 then return end
		table.sort(t, function(a, b) return a.qlty < b.qlty end)
			for i = 1, #t do
				t[i].Id = i
				t[i].Address = t[i].Address:gsub('^https://', 'http://'):gsub(':hls:manifest%.m3u8', '')
			end
		m_simpleTV.User.voidboost.Tab = t
		local index = voidboostIndex(t)
	 return t[index].Address
	end
	local function voidboostISubt(url)
		local subt = url:match('\'subtitle\':%s*\'[^{]+')
		if subt then
			subt = subt:gsub('\\/', '/')
			local s = {}
			for w in subt:gmatch('http.-%.vtt') do
				s[#s + 1] = w:gsub('://', '/webvtt://')
			end
			subt = '$OPT:sub-track=0$OPT:input-slave=' .. table.concat(s, '#')
		end
	 return subt
	end
	function OnMultiAddressOk_voidboost(Object, id)
		if id == 0 then
			OnMultiAddressCancel_voidboost(Object)
		else
			m_simpleTV.User.voidboost.DelayedAddress = nil
		end
	end
	function OnMultiAddressCancel_voidboost(Object)
		if m_simpleTV.User.voidboost.DelayedAddress then
			local state = m_simpleTV.Control.GetState()
			if state == 0 then
				m_simpleTV.Control.SetNewAddress(m_simpleTV.User.voidboost.DelayedAddress)
			end
			m_simpleTV.User.voidboost.DelayedAddress = nil
		end
		m_simpleTV.Control.ExecuteAction(36, 0)
	end
	function Qlty_voidboost()
		m_simpleTV.Control.ExecuteAction(36, 0)
		local t = m_simpleTV.User.voidboost.Tab
			if not t then return end
		local index = voidboostIndex(t)
		if m_simpleTV.User.paramScriptForSkin_buttonOk then
			t.OkButton = {ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOk}
		end
		if m_simpleTV.User.paramScriptForSkin_buttonClose then
			t.ExtButton1 = {ButtonEnable = true, ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonClose}
		else
			t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
		end
		local ret, id = m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 10000, 1 + 4 + 2)
		if m_simpleTV.User.voidboost.isVideo == false then
			if m_simpleTV.User.voidboost.DelayedAddress then
				m_simpleTV.Control.ExecuteAction(108)
			else
				m_simpleTV.Control.ExecuteAction(37)
			end
		else
			m_simpleTV.Control.ExecuteAction(37)
		end
		if ret == 1 then
			m_simpleTV.Control.SetNewAddress(t[id].Address, m_simpleTV.Control.GetPosition())
			m_simpleTV.Config.SetValue('voidboost_qlty', t[id].qlty)
		end
	end
	local function play(retAdr, title)
		if retAdr:match('^$voidboost') then
			retAdr = GetStream(retAdr)
				if not retAdr then
					showError('2')
				 return
				end
		end
		local subt = voidboostISubt(retAdr)
		retAdr = voidboostDeSex(retAdr)
			if not retAdr or retAdr == '' then
				showError('2.01')
			 return
			end
		retAdr = GetAdr(retAdr)
			if not retAdr then
				showError('3')
			 return
			end
		m_simpleTV.Control.CurrentTitle_UTF8 = title
		m_simpleTV.OSD.ShowMessageT({text = title, color = 0xff9999ff, showTime = 1000 * 5, id = 'channelName'})
		retAdr = retAdr .. (subt or '')
		m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')
	end
		if inAdr:match('^$voidboost') then
			local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr:gsub('$voidboost', '')})
				if rc ~= 200 then
					showError('8.1')
				 return
				end
			play(answer, title)
		 return
		end
	m_simpleTV.User.voidboost.isVideo = nil
	m_simpleTV.User.voidboost.titleTab = nil
	m_simpleTV.User.voidboost.host = inAdr:match('^https?://[^/]+')
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
		if rc ~= 200 then
			showError('4')
		 return
		end
	answer = answer:gsub('<!%-%-.-%-%->', ''):gsub('/%*.-%*/', '')
	local playerjs_url = answer:match('[^"\']+/playerjs[^"\']+')
		if not playerjs_url then
			showError('no playerjs_url')
		return end
	m_simpleTV.User.voidboost.playerjs_url = playerjs_url
	local title = m_simpleTV.Control.CurrentTitle_UTF8
	m_simpleTV.Control.SetTitle(title)
	local serial = answer:match('name="season"')
	local trType
	if serial then
		trType = '/serial/'
	else
		trType = '/movie/'
	end
	local tr = answer:match('<select name="translator".-</select>')
	if tr then
		local t = {}
			for w in tr:gmatch('<option data.-</option>') do
				local name = w:match('">([^<]+)')
				local token = w:match('token="([^"]+)')
				if name and token then
					t[#t + 1] = {}
					t[#t].Id = #t
					t[#t].Name = name
					t[#t].Address = m_simpleTV.User.voidboost.host .. trType .. token .. '/iframe?h=voidboost.net'
				end
			end
		if #t > 1 then
			if m_simpleTV.User.paramScriptForSkin_buttonOk then
				t.OkButton = {ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOk}
			end
			local _, id = m_simpleTV.OSD.ShowSelect_UTF8('Выберете перевод - ' .. title, 0, t, 5000, 1 + 2)
			id = id or 1
			tr = t[id].Address
			rc, answer = m_simpleTV.Http.Request(session, {url = tr})
				if rc ~= 200 then
					showError('5.4')
				 return
				end
			inAdr = tr
		elseif #t == 1 then
			tr = t[1].Address
			inAdr = tr
		end
	end
	if serial then
		local season_title = ''
		local ses = answer:match('<select name="season".-</select>')
		if ses then
			local t = {}
				for w in ses:gmatch('<option.-</option>') do
					local name = w:match('>([^<]+)')
					local season = w:match('value="(%d+)')
					if name and season then
						t[#t +1] = {}
						t[#t].Id = #t
						t[#t].Name = name
						t[#t].Address = inAdr .. '&s=' .. season
					end
				end
			if #t > 1 then
				local _, id = m_simpleTV.OSD.ShowSelect_UTF8(title .. ' - выберите сезон', 0, t, 10000, 1)
				id = id or 1
				inAdr = t[id].Address
				season_title = ' (' .. t[id].Name .. ')'
				rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
					if rc ~= 200 then
						showError('6.1')
					 return
					end
			elseif #t == 1	then
				season_title = ' (' .. t[1].Name .. ')'
			end
		end
		local epi = answer:match('<select name="episode".-</select>')
		if epi then
			local t1 = {}
				for w in epi:gmatch('<option.-</option>') do
					local name = w:match('">([^<]+)')
					local epi = w:match('value="(%d+)')
					if name and epi then
						t1[#t1 +1] = {}
						t1[#t1].Id = #t1
						t1[#t1].Name = name
						t1[#t1].Address = '$voidboost' .. inAdr .. '&e=' .. epi
					end
				end
				if #t1 == 0 then
					showError('6.2')
				 return
				end
		m_simpleTV.User.voidboost.titleTab = t1
		if m_simpleTV.User.paramScriptForSkin_buttonOptions then
			t1.ExtButton0 = {ButtonEnable = true, ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOptions, ButtonScript = 'Qlty_voidboost()'}
		else
			t1.ExtButton0 = {ButtonEnable = true, ButtonName = '⚙', ButtonScript = 'Qlty_voidboost()'}
		end
		if m_simpleTV.User.paramScriptForSkin_buttonOk then
			t1.OkButton = {ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOk}
		end
		if m_simpleTV.User.paramScriptForSkin_buttonClose then
			t1.ExtButton1 = {ButtonEnable = true, ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonClose, ButtonScript = 'OnMultiAddressCancel_voidboost()'}
		else
			t1.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'OnMultiAddressCancel_voidboost()'}
		end
		t1.ExtParams = {}
		t1.ExtParams.LuaOnCancelFunName = 'OnMultiAddressCancel_voidboost'
		t1.ExtParams.LuaOnOkFunName = 'OnMultiAddressOk_voidboost'
		t1.ExtParams.LuaOnTimeoutFunName = 'OnMultiAddressCancel_voidboost'
		local pl
		if #t1 > 1 then
			pl = 0
		else
			pl = 32
		end
		title = title .. season_title
		m_simpleTV.OSD.ShowSelect_UTF8(title, 0, t1, 10000, 2 + 64 + pl)
		local rc, answer = m_simpleTV.Http.Request(session, {url = t1[1].Address:gsub('$voidboost', '')})
			if rc ~= 200 then
				showError('7')
			 return
			end
		local subt = voidboostISubt(answer)
		local retAdr = voidboostDeSex(answer)
			if not retAdr or retAdr == '' then
				showError('7.1')
			 return
			end
		retAdr = GetAdr(retAdr)
			if not retAdr then
				showError('7.2')
			 return
			end
		m_simpleTV.User.voidboost.DelayedAddress = retAdr .. (subt or '')
		m_simpleTV.User.voidboost.title = title
		if #t1 > 1 then
			inAdr = 'wait'
			m_simpleTV.User.voidboost.isVideo = false
		else
			inAdr = retAdr .. (subt or '')
		end
		m_simpleTV.Control.CurrentTitle_UTF8 = title
		m_simpleTV.OSD.ShowMessageT({text = title .. ' - ' .. m_simpleTV.User.voidboost.titleTab[1].Name, color = 0xff9999ff, showTime = 1000 * 5, id = 'channelName'})
		m_simpleTV.Control.CurrentAddress = inAdr
	 return
	end
	else
		local t = {}
		t[1] = {}
		t[1].Id = 1
		t[1].Name = title
		if m_simpleTV.User.paramScriptForSkin_buttonOptions then
			t.ExtButton0 = {ButtonEnable = true, ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOptions, ButtonScript = 'Qlty_voidboost()'}
		else
			t.ExtButton0 = {ButtonEnable = true, ButtonName = '⚙', ButtonScript = 'Qlty_voidboost()'}
		end
		if m_simpleTV.User.paramScriptForSkin_buttonOk then
			t.OkButton = {ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOk}
		end
		if m_simpleTV.User.paramScriptForSkin_buttonClose then
			t.ExtButton1 = {ButtonEnable = true, ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonClose, ButtonScript = 'OnMultiAddressCancel_voidboost()'}
		else
			t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'OnMultiAddressCancel_voidboost()'}
		end
		if m_simpleTV.User.paramScriptForSkin_buttonOk then
			t.OkButton = {ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOk}
		end
		m_simpleTV.OSD.ShowSelect_UTF8('Voidboost', 0, t, 8000, 32 + 64 + 128)
	end
	play(answer, title)
