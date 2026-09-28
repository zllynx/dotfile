require("git"):setup()

-- yamb 书签：书签数据存 ~/.config/yazi/bookmark（运行时数据，已 gitignore）
require("yamb"):setup {
	bookmarks = {},
	jump_notify = true,
	cli = "fzf",
}
