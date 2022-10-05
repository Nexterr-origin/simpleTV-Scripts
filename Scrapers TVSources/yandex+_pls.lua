-- скрапер TVS для загрузки плейлиста "Yandex+" https://yandex.ru (6/10/22)
-- Copyright © 2017-2022 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- видоскрипт: yandex.lua
-- расширение дополнения httptimeshift: yandex-timesift_ext.lua
-- ## переименовать каналы ##
local filter = {
	{'360° Новости', '360 Новости (Москва)'},
	{'National Geographic', 'TERRA'},
	}
	local function ProcessFilterTableLocal(t)
		if not type(t) == 'table' then return end
		for i = 1, #t do
			t[i].name = tvs_core.tvs_clear_double_space(t[i].name)
			for _, ff in ipairs(filter) do
				if (type(ff) == 'table' and t[i].name == ff[1]) then
					t[i].name = ff[2]
				end
			end
		end
	 return t
	end
	local function LoadPlst()
	 return
[[
#EXTM3U catchup="append" catchup-days="7" catchup-source="?start=${start}" catchup-record-source="?start=${start}&end=${end}"
#EXTINF:-1,Sony Channel
aHR0cHM6Ly9zdHJtLnlhbmRleC5ydS9rYWwvc29ueV9jaGFubmVsL21hbmlmZXN0Lm1wZCRPUFQ6YWRhcHRpdmUtdXNlLWF2ZGVtdXgkT1BUOmF2ZGVtdXgtb3B0aW9ucz17ZGVjcnlwdGlvbl9rZXk9NjBlNDRkN2IyNDNmNTg2N2UxNTA4YzJhMjBmYTVkZGR9JE9QVDphZGFwdGl2ZS1pbml0LW9uLWVhY2gtc2VnbWVudCRPUFQ6YWRhcHRpdmUtZGFzaC1hZGFwdGF0aW9uLWlkcz0wJE9QVDpJTlQtU0NSSVBULVBBUkFNUz15YW5kZXhfdHY
#EXTINF:-1,Sony Turbo
aHR0cHM6Ly9zdHJtLnlhbmRleC5ydS9rYWwvc29ueV90dXJiby9tYW5pZmVzdC5tcGQkT1BUOmFkYXB0aXZlLXVzZS1hdmRlbXV4JE9QVDphdmRlbXV4LW9wdGlvbnM9e2RlY3J5cHRpb25fa2V5PWM3NDg2ZDQ3MTE3ZmM3MWU5OWVjNTY4MmU4ZGMxOWI4fSRPUFQ6YWRhcHRpdmUtaW5pdC1vbi1lYWNoLXNlZ21lbnQkT1BUOmFkYXB0aXZlLWRhc2gtYWRhcHRhdGlvbi1pZHM9MCRPUFQ6SU5ULVNDUklQVC1QQVJBTVM9eWFuZGV4X3R2
#EXTINF:-1,Sony Sci-Fi
aHR0cHM6Ly9zdHJtLnlhbmRleC5ydS9rYWwvc29ueV9zY2lfZmkvbWFuaWZlc3QubXBkJE9QVDphZGFwdGl2ZS11c2UtYXZkZW11eCRPUFQ6YXZkZW11eC1vcHRpb25zPXtkZWNyeXB0aW9uX2tleT0xZTBiMzk2YzZhODU2MDkzYWJmZjc5YTExMDQyNWYxOX0kT1BUOmFkYXB0aXZlLWluaXQtb24tZWFjaC1zZWdtZW50JE9QVDphZGFwdGl2ZS1kYXNoLWFkYXB0YXRpb24taWRzPTAkT1BUOklOVC1TQ1JJUFQtUEFSQU1TPXlhbmRleF90dg
#EXTINF:-1,National Geographic
aHR0cHM6Ly9zdHJtLnlhbmRleC5ydS9rYWwvbmdjX2hkL21hbmlmZXN0Lm1wZCRPUFQ6YWRhcHRpdmUtdXNlLWF2ZGVtdXgkT1BUOmF2ZGVtdXgtb3B0aW9ucz17ZGVjcnlwdGlvbl9rZXk9YjM4YjBkNDc4YjQ5ZWE2YzJkNzYyOTFmYTk5NDMwMjB9JE9QVDphZGFwdGl2ZS1pbml0LW9uLWVhY2gtc2VnbWVudCRPUFQ6YWRhcHRpdmUtZGFzaC1hZGFwdGF0aW9uLWlkcz0yJE9QVDpJTlQtU0NSSVBULVBBUkFNUz15YW5kZXhfdHY
#EXTINF:-1,Viasat Sport
aHR0cHM6Ly9zdHJtLnlhbmRleC5ydS9rYWwvdmlhc2F0X3Nwb3J0L21hbmlmZXN0Lm1wZCRPUFQ6YWRhcHRpdmUtdXNlLWF2ZGVtdXgkT1BUOmF2ZGVtdXgtb3B0aW9ucz17ZGVjcnlwdGlvbl9rZXk9YTI2OGQ5N2JmODkyMTI3YTQ0ODM2ZjRhOThmYjI4ZmR9JE9QVDphZGFwdGl2ZS1pbml0LW9uLWVhY2gtc2VnbWVudCRPUFQ6YWRhcHRpdmUtZGFzaC1hZGFwdGF0aW9uLWlkcz0yJE9QVDpJTlQtU0NSSVBULVBBUkFNUz15YW5kZXhfdHY
#EXTINF:-1,Viasat History
aHR0cHM6Ly9zdHJtLnlhbmRleC5ydS9rYWwvdmlhc2F0X2hpc3RvcnkvbWFuaWZlc3QubXBkJE9QVDphZGFwdGl2ZS11c2UtYXZkZW11eCRPUFQ6YXZkZW11eC1vcHRpb25zPXtkZWNyeXB0aW9uX2tleT05Yzk1OTUyMjAzY2Q0MzhlMWEyY2FhNzJlMjFkYTNiM30kT1BUOmFkYXB0aXZlLWluaXQtb24tZWFjaC1zZWdtZW50JE9QVDphZGFwdGl2ZS1kYXNoLWFkYXB0YXRpb24taWRzPTIkT1BUOklOVC1TQ1JJUFQtUEFSQU1TPXlhbmRleF90dg
#EXTINF:-1,Viasat Nature
aHR0cHM6Ly9zdHJtLnlhbmRleC5ydS9rYWwvdmlhc2F0X25hdHVyZS9tYW5pZmVzdC5tcGQkT1BUOmFkYXB0aXZlLXVzZS1hdmRlbXV4JE9QVDphdmRlbXV4LW9wdGlvbnM9e2RlY3J5cHRpb25fa2V5PWM0ODkxM2M5ZmU4MGJjNWZjZWU1NDBmNDY2MTM5OTkwfSRPUFQ6YWRhcHRpdmUtaW5pdC1vbi1lYWNoLXNlZ21lbnQkT1BUOmFkYXB0aXZlLWRhc2gtYWRhcHRhdGlvbi1pZHM9MiRPUFQ6SU5ULVNDUklQVC1QQVJBTVM9eWFuZGV4X3R2
#EXTINF:-1,Viasat Explorer
aHR0cHM6Ly9zdHJtLnlhbmRleC5ydS9rYWwvdmlhc2F0X2V4cGxvcmUvbWFuaWZlc3QubXBkJE9QVDphZGFwdGl2ZS11c2UtYXZkZW11eCRPUFQ6YXZkZW11eC1vcHRpb25zPXtkZWNyeXB0aW9uX2tleT05NzBiYzBlZWJhNTlhZDkwMmE1NjZjMDFmMTE5ZDg3M30kT1BUOmFkYXB0aXZlLWluaXQtb24tZWFjaC1zZWdtZW50JE9QVDphZGFwdGl2ZS1kYXNoLWFkYXB0YXRpb24taWRzPTIkT1BUOklOVC1TQ1JJUFQtUEFSQU1TPXlhbmRleF90dg
#EXTINF:-1,Viasat Nature/History HD
aHR0cHM6Ly9zdHJtLnlhbmRleC5ydS9rYWwvdmlhc2F0X25hdHVyZV9oaXN0b3J5L21hbmlmZXN0Lm1wZCRPUFQ6YWRhcHRpdmUtdXNlLWF2ZGVtdXgkT1BUOmF2ZGVtdXgtb3B0aW9ucz17ZGVjcnlwdGlvbl9rZXk9YzZiMDRmZTJmNzM1ZWI2MDU3ZDQyODgyMmJiNTMxZmF9JE9QVDphZGFwdGl2ZS1pbml0LW9uLWVhY2gtc2VnbWVudCRPUFQ6YWRhcHRpdmUtZGFzaC1hZGFwdGF0aW9uLWlkcz0yJE9QVDpJTlQtU0NSSVBULVBBUkFNUz15YW5kZXhfdHY
#EXTINF:-1,Да Винчи
aHR0cHM6Ly9zdHJtLnlhbmRleC5ydS9rYWwvZGFfdmluY2kvbWFuaWZlc3QubXBkJE9QVDphZGFwdGl2ZS11c2UtYXZkZW11eCRPUFQ6YXZkZW11eC1vcHRpb25zPXtkZWNyeXB0aW9uX2tleT0yNGYxMDUzYmFjZDY1ODNiZmUzYWFiNTFjN2RkNTc4OX0kT1BUOmFkYXB0aXZlLWluaXQtb24tZWFjaC1zZWdtZW50JE9QVDphZGFwdGl2ZS1kYXNoLWFkYXB0YXRpb24taWRzPTIkT1BUOklOVC1TQ1JJUFQtUEFSQU1TPXlhbmRleF90dg
#EXTINF:-1,ViP Comedy
aHR0cHM6Ly9zdHJtLnlhbmRleC5ydS9rYWwvdmlwX2NvbWVkeS9tYW5pZmVzdC5tcGQkT1BUOmFkYXB0aXZlLXVzZS1hdmRlbXV4JE9QVDphdmRlbXV4LW9wdGlvbnM9e2RlY3J5cHRpb25fa2V5PTlmMDkzOTgxZmM2NWFhNWE2MjYyMTkzM2UyNWU5NWI4fSRPUFQ6YWRhcHRpdmUtaW5pdC1vbi1lYWNoLXNlZ21lbnQkT1BUOmFkYXB0aXZlLWRhc2gtYWRhcHRhdGlvbi1pZHM9MiRPUFQ6SU5ULVNDUklQVC1QQVJBTVM9eWFuZGV4X3R2
#EXTINF:-1,ViP Megahit
aHR0cHM6Ly9zdHJtLnlhbmRleC5ydS9rYWwvdmlwX21lZ2FoaXQvbWFuaWZlc3QubXBkJE9QVDphZGFwdGl2ZS11c2UtYXZkZW11eCRPUFQ6YXZkZW11eC1vcHRpb25zPXtkZWNyeXB0aW9uX2tleT1hMWFmYzRkZGU4Zjg0ZjQ0NTU0NGM5MjcyMTc0N2M4Y30kT1BUOmFkYXB0aXZlLWluaXQtb24tZWFjaC1zZWdtZW50JE9QVDphZGFwdGl2ZS1kYXNoLWFkYXB0YXRpb24taWRzPTIkT1BUOklOVC1TQ1JJUFQtUEFSQU1TPXlhbmRleF90dg
#EXTINF:-1,ViP Premiere
aHR0cHM6Ly9zdHJtLnlhbmRleC5ydS9rYWwvdmlwX3ByZW1pZXJlL21hbmlmZXN0Lm1wZCRPUFQ6YWRhcHRpdmUtdXNlLWF2ZGVtdXgkT1BUOmF2ZGVtdXgtb3B0aW9ucz17ZGVjcnlwdGlvbl9rZXk9OWRjMDQ0OWJmOTNjODViNjA0NWE2MzVmOThlZGY2ZWZ9JE9QVDphZGFwdGl2ZS1pbml0LW9uLWVhY2gtc2VnbWVudCRPUFQ6YWRhcHRpdmUtZGFzaC1hZGFwdGF0aW9uLWlkcz0yJE9QVDpJTlQtU0NSSVBULVBBUkFNUz15YW5kZXhfdHY
#EXTINF:-1,ViP SERIAL
aHR0cHM6Ly9zdHJtLnlhbmRleC5ydS9rYWwvdmlwX3NlcmlhbC9tYW5pZmVzdC5tcGQkT1BUOmFkYXB0aXZlLXVzZS1hdmRlbXV4JE9QVDphdmRlbXV4LW9wdGlvbnM9e2RlY3J5cHRpb25fa2V5PWNkNjkwZWQyOGRhZmVmZGY3N2NlMDRiYTQ0ZDMyODQ3fSRPUFQ6YWRhcHRpdmUtaW5pdC1vbi1lYWNoLXNlZ21lbnQkT1BUOmFkYXB0aXZlLWRhc2gtYWRhcHRhdGlvbi1pZHM9MiRPUFQ6SU5ULVNDUklQVC1QQVJBTVM9eWFuZGV4X3R2
#EXTINF:-1,ТВ1000 Action
aHR0cHM6Ly9zdHJtLnlhbmRleC5ydS9rYWwvdHYxMDAwX2FjdGlvbi9tYW5pZmVzdC5tcGQkT1BUOmFkYXB0aXZlLXVzZS1hdmRlbXV4JE9QVDphdmRlbXV4LW9wdGlvbnM9e2RlY3J5cHRpb25fa2V5PTlkNDM4OWM1MjUzMjg1NzM1MmIwZWM2NDYyYjAxMzdkfSRPUFQ6YWRhcHRpdmUtaW5pdC1vbi1lYWNoLXNlZ21lbnQkT1BUOmFkYXB0aXZlLWRhc2gtYWRhcHRhdGlvbi1pZHM9MiRPUFQ6SU5ULVNDUklQVC1QQVJBTVM9eWFuZGV4X3R2
#EXTINF:-1,ТВ1000 Русское кино
aHR0cHM6Ly9zdHJtLnlhbmRleC5ydS9rYWwvdHYxMDAwX3J1c3NpYW5fbW92aWVzL21hbmlmZXN0Lm1wZCRPUFQ6YWRhcHRpdmUtdXNlLWF2ZGVtdXgkT1BUOmF2ZGVtdXgtb3B0aW9ucz17ZGVjcnlwdGlvbl9rZXk9MzNkZmIzZTMwYjAzOTIzNmQzOTJlMDc3N2UyOGZkZTh9JE9QVDphZGFwdGl2ZS1pbml0LW9uLWVhY2gtc2VnbWVudCRPUFQ6YWRhcHRpdmUtZGFzaC1hZGFwdGF0aW9uLWlkcz0yJE9QVDpJTlQtU0NSSVBULVBBUkFNUz15YW5kZXhfdHY
#EXTINF:-1,ТВ1000
aHR0cHM6Ly9zdHJtLnlhbmRleC5ydS9rYWwvdHYxMDAwL21hbmlmZXN0Lm1wZCRPUFQ6YWRhcHRpdmUtdXNlLWF2ZGVtdXgkT1BUOmF2ZGVtdXgtb3B0aW9ucz17ZGVjcnlwdGlvbl9rZXk9YzQ0N2M3MmM2MWY4MGI0MmU4ZDQ2Y2IzNjE4YjhjNTN9JE9QVDphZGFwdGl2ZS1pbml0LW9uLWVhY2gtc2VnbWVudCRPUFQ6YWRhcHRpdmUtZGFzaC1hZGFwdGF0aW9uLWlkcz0yJE9QVDpJTlQtU0NSSVBULVBBUkFNUz15YW5kZXhfdHY
#EXTINF:-1,Bridge Classic
aHR0cHM6Ly9zdHJtLnlhbmRleC5ydS9rYWwvYnJpZGdldHZjbGFzc2ljL2JyaWRnZXR2Y2xhc3NpYzAubTN1OA
#EXTINF:-1,Ю
aHR0cHM6Ly9zdHJtLnlhbmRleC5ydS9rYWwvdXR2L3V0djAubTN1OA
#EXTINF:-1,Старт
aHR0cHM6Ly9zdHJtLnlhbmRleC5ydS9rYWwvc3RhcnQvc3RhcnQwLm0zdTg
#EXTINF:-1,Диалоги о Рыбалке
aHR0cHM6Ly9zdHJtLnlhbmRleC5ydS9rYWwvZGlhbG9naS9kaWFsb2dpMC5tM3U4
#EXTINF:-1,Совершенно секретно
aHR0cHM6Ly9zdHJtLnlhbmRleC5ydS9rYWwvc292c2VjL3NvdnNlYzAubTN1OA
#EXTINF:-1,360 Подмосковье (Москва)
aHR0cHM6Ly9zdHJtLnlhbmRleC5ydS9rYWwvMzYwdHYvMzYwdHYwLm0zdTg
#EXTINF:-1,Bridge Русский Хит
aHR0cHM6Ly9zdHJtLnlhbmRleC5ydS9rYWwvYnJpZGdldHZfcnVzc2tpeWhpdC9icmlkZ2V0dl9ydXNza2l5aGl0MC5tM3U4
#EXTINF:-1,RTG HD
aHR0cHM6Ly9zdHJtLnlhbmRleC5ydS9rYWwvcnRnL3J0ZzAubTN1OA
#EXTINF:-1,HITV
aHR0cHM6Ly9zdHJtLnlhbmRleC5ydS9rYWwvaGl0dHYvaGl0dHYwLm0zdTg
#EXTINF:-1,ТНТ Music
aHR0cHM6Ly9zdHJtLnlhbmRleC5ydS9rYWwvdG50bXVzaWMvdG50bXVzaWMwLm0zdTg
#EXTINF:-1,Music Box Gold
aHR0cHM6Ly9zdHJtLnlhbmRleC5ydS9rYWwvbXVzaWNib3hnb2xkL211c2ljYm94Z29sZDAubTN1OA
#EXTINF:-1,Bridge Deluxe
aHR0cHM6Ly9zdHJtLnlhbmRleC5ydS9rYWwvYnJpZGdldHZkZWx1eGUvYnJpZGdldHZkZWx1eGUwLm0zdTg
#EXTINF:-1,Москва 24 (Москва)
aHR0cHM6Ly9zdHJtLnlhbmRleC5ydS9rYWwvbXNrMjRfc3VwcmVzL21zazI0X3N1cHJlczAubTN1OA
#EXTINF:-1,360 Новости (Москва)
aHR0cHM6Ly9zdHJtLnlhbmRleC5ydS9rYWwvMzYwbmV3cy8zNjBuZXdzMC5tM3U4
#EXTINF:-1,Bridge
aHR0cHM6Ly9zdHJtLnlhbmRleC5ydS9rYWwvYnJpZGdldHYvYnJpZGdldHYwLm0zdTg
#EXTINF:-1,Мир 24
aHR0cHM6Ly9zdHJtLnlhbmRleC5ydS9rYWwvbWlyMjQvbWlyMjQwLm0zdTg
#EXTINF:-1,Bridge Hits
aHR0cHM6Ly9zdHJtLnlhbmRleC5ydS9rYWwvYnJpZGdldHZoaXRzL2JyaWRnZXR2aGl0czAubTN1OA
#EXTINF:-1,Bridge TV Фрэш
aHR0cHM6Ly9zdHJtLnlhbmRleC5ydS9rYWwvYnJpZGdlX3R2X2ZyZXNoL2JyaWRnZV90dl9mcmVzaDAubTN1OA
#EXTINF:-1,Bridge TV Шлягер
aHR0cHM6Ly9zdHJtLnlhbmRleC5ydS9rYWwvYnJpZGdldHZfc2hseWFnZXIvYnJpZGdldHZfc2hseWFnZXIwLm0zdTg
#EXTINF:-1,RU.TV HD
aHR0cHM6Ly9zdHJtLnlhbmRleC5ydS9rYWwvcnV0dl9jdi9ydXR2X2N2MC5tM3U4
#EXTINF:-1,Russian MusicBox
aHR0cHM6Ly9zdHJtLnlhbmRleC5ydS9rYWwvcm1ib3gvcm1ib3gwLm0zdTg
#EXTINF:-1,Удар
aHR0cHM6Ly9zdHJtLnlhbmRleC5ydS9rYWwvdWRhci91ZGFyMC5tM3U4
#EXTINF:-1,Наша сибирь HD
aHR0cHM6Ly9zdHJtLnlhbmRleC5ydS9rYWwvc2liaXIvc2liaXIwLm0zdTg
#EXTINF:-1,RT Doc
aHR0cHM6Ly9zdHJtLnlhbmRleC5ydS9rYWwvcnRkX2hkL3J0ZF9oZDAubTN1OA
]]
	end
	module('yandex+_pls', package.seeall)
	local my_src_name = 'Yandex+'
	function GetSettings()
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\yandex.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 1, show_progress = 0, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 1}, STV = {add = 1, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 0, AutoSearch = 1, AutoNumber = 0, NumberM3U = 0, GetSettings = 1, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0, RemoveDupCH = 1}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	function GetList(UpdateID, m3u_file)
			if not UpdateID then return end
			if not m3u_file then return end
			if not TVSources_var.tmp.source[UpdateID] then return end
		local Source = TVSources_var.tmp.source[UpdateID]
		local t_pls = tvs_core.GetPlsAsTable(LoadPlst())
			for _, v in pairs(t_pls) do
				v.address = decode64(v.address)
			end
		t_pls = ProcessFilterTableLocal(t_pls)
		local m3ustr = tvs_core.ProcessFilterTable(UpdateID, Source, t_pls)
		local handle = io.open(m3u_file, 'w+')
			if not handle then return end
		handle:write(m3ustr)
		handle:close()
	 return 'ok'
	end
-- debug_in_file(#t_pls .. '\n')
