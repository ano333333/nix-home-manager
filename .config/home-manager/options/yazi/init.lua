-- git.yazi
-- https://github.com/yazi-rs/plugins/tree/main/git.yazi
th.git = th.git or {}
th.git.modified_sign = "M"
th.git.added_sign = "A"
th.git.untracked_sign = "U"
th.git.ignored_sign = "I"
th.git.deleted_sign = "D"
th.git.updated_sign = "C"

require("git"):setup()

