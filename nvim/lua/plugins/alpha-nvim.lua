--dashboard

return {
	"goolord/alpha-nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},

	config = function()
		local alpha = require("alpha")
		--		local dashboard = require("alpha.themes.startify")
		--
		--		dashboard.section.header.val = {
		--			[[                                                                       ]],
		--			[[                                                                       ]],
		--			[[                                                                       ]],
		--			[[                                                                       ]],
		--			[[                                                                     ]],
		--			[[       ████ ██████           █████      ██                     ]],
		--			[[      ███████████             █████                             ]],
		--			[[      █████████ ███████████████████ ███   ███████████   ]],
		--			[[     █████████  ███    █████████████ █████ ██████████████   ]],
		--			[[    █████████ ██████████ █████████ █████ █████ ████ █████   ]],
		--			[[  ███████████ ███    ███ █████████ █████ █████ ████ █████  ]],
		--			[[ ██████  █████████████████████ ████ █████ █████ ████ ██████ ]],
		--			[[                                                                       ]],
		--			[[                                                                       ]],
		--			[[                                                                       ]],
		--		}
		--		alpha.setup(dashboard.opts)
		--require'alpha'.setup(require'alpha.themes.dashboard'.config)

		local dashboard = require("alpha.themes.dashboard")

		math.randomseed(os.time())

		local function pick_color()
			local colors = { "String", "Identifier", "Keyword", "Number" }
			return colors[math.random(#colors)]
		end

		local logo1 = {
			"            :h-                                  Nhy`               ",
			"           -mh.                           h.    `Ndho               ",
			"           hmh+                          oNm.   oNdhh               ",
			"          `Nmhd`                        /NNmd  /NNhhd               ",
			"          -NNhhy                      `hMNmmm`+NNdhhh               ",
			"          .NNmhhs              ```....`..-:/./mNdhhh+               ",
			"           mNNdhhh-     `.-::///+++////++//:--.`-/sd`               ",
			"           oNNNdhhdo..://++//++++++/+++//++///++/-.`                ",
			"      y.   `mNNNmhhhdy+/++++//+/////++//+++///++////-` `/oos:       ",
			" .    Nmy:  :NNNNmhhhhdy+/++/+++///:.....--:////+++///:.`:s+        ",
			" h-   dNmNmy oNNNNNdhhhhy:/+/+++/-         ---:/+++//++//.`         ",
			" hd+` -NNNy`./dNNNNNhhhh+-://///    -+oo:`  ::-:+////++///:`        ",
			" /Nmhs+oss-:++/dNNNmhho:--::///    /mmmmmo  ../-///++///////.       ",
			"  oNNdhhhhhhhs//osso/:---:::///    /yyyyso  ..o+-//////////:/.      ",
			"   /mNNNmdhhhh/://+///::://////     -:::- ..+sy+:////////::/:/.     ",
			"     /hNNNdhhs--:/+++////++/////.      ..-/yhhs-/////////::/::/`    ",
			"       .ooo+/-::::/+///////++++//-/ossyyhhhhs/:///////:::/::::/:    ",
			"       -///:::::::////++///+++/////:/+ooo+/::///////.::://::---+`   ",
			"       /////+//++++/////+////-..//////////::-:::--`.:///:---:::/:   ",
			"       //+++//++++++////+++///::--                 .::::-------::   ",
			"       :/++++///////////++++//////.                -:/:----::../-   ",
			"       -/++++//++///+//////////////               .::::---:::-.+`   ",
			"       `////////////////////////////:.            --::-----...-/    ",
			"        -///://////////////////////::::-..      :-:-:-..-::.`.+`    ",
			"         :/://///:///::://::://::::::/:::::::-:---::-.-....``/- -   ",
			"           ::::://::://::::::::::::::----------..-:....`.../- -+oo/ ",
			"            -/:::-:::::---://:-::-::::----::---.-.......`-/.      ``",
			"           s-`::--:::------:////----:---.-:::...-.....`./:          ",
			"          yMNy.`::-.--::..-dmmhhhs-..-.-.......`.....-/:`           ",
			"         oMNNNh. `-::--...:NNNdhhh/.--.`..``.......:/-              ",
			"        :dy+:`      .-::-..NNNhhd+``..`...````.-::-`                ",
			"                        .-:mNdhh:.......--::::-`                    ",
			"                           yNh/..------..`                          ",
			"                                                                    ",
		}


		local logo2 = {
					[[                                                                       ]],
					[[                                                                       ]],
					[[                                                                       ]],
					[[                                                                       ]],
					[[                                                                     ]],
					[[       ████ ██████           █████      ██                     ]],
					[[      ███████████             █████                             ]],
					[[      █████████ ███████████████████ ███   ███████████   ]],
					[[     █████████  ███    █████████████ █████ ██████████████   ]],
					[[    █████████ ██████████ █████████ █████ █████ ████ █████   ]],
					[[  ███████████ ███    ███ █████████ █████ █████ ████ █████  ]],
					[[ ██████  █████████████████████ ████ █████ █████ ████ ██████ ]],
					[[                                                                       ]],
					[[                                                                       ]],
					[[                                                                       ]],
			}


		dashboard.section.header.val = logo2
		dashboard.section.header.opts.hl = pick_color()

		dashboard.section.buttons.val = {
			dashboard.button("e", "  New file", ":ene <BAR> startinsert <CR>"),
			dashboard.button("<C-p>", "  Find File"),
			dashboard.button("<Leader>fg", "  Find Word"),
			dashboard.button("<C-t>", "  File Tree"),
			--dashboard.button("<Leader>ps", "  Update plugins"),
			dashboard.button("r", "󰄉 Recently used files", ":Telescope oldfiles <CR>"),
			dashboard.button("p", "Python Workspace", ":cd ~/coding <CR>"),
			dashboard.button("c", "  Configuration", ":cd ~/.config/nvim <CR>"),
			dashboard.button("q", "  Quit", ":qa<CR>"),
		}

		alpha.setup(dashboard.opts)

		vim.cmd([[ autocmd FileType alpha setlocal nofoldenable ]])
	end,
}
