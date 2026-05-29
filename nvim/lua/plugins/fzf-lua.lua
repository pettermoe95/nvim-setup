return {
	"ibhagwan/fzf-lua",
	opts = {
		winopts = {
			width = 0.90,

			preview = {
				layout = "horizontal",
				horizontal = "right:45%",
			},
		},
		files = {
			-- fn_transform = function(item)
			-- 	item = item:gsub("src/main/kotlin/", "")
			--
			-- 	-- item = item:gsub("no/brilliantview/", "")
			--
			-- 	return item
			-- end,
			formatter = "path.filename_first",
		},
	},
}
