--【改动任何内容都请单独改动每个分支下的配置文件条目，禁止偷懒直接将整个文件从一个分支复制到另外一个分支！】
--【配置表下按类别拆分，新内容如有必要则按格式重建一个配置表单独对应！】

ServerGame.ToyDoll = {
  Body = {{1, 8}, {11, 16}, {19, 24}, {27, 32}, {35, 40}},
  Head = {{45001,45016}, {45018,45031}, {45033,45034}, {45036,45038}, {45040,45058}},
  Hair = {{1, 20}, {998,999}},
  HairColor = {{1, 8}},
  Eye = {{1, 2}},
  time = 150,

  birth_emoji = {odds=100, value={2,27}},  -----出生时表情
  birth_dialog = {odds=100, value={1312203}}, -----出生时对话
  disp_emoji = {odds=100, value={1,18,24}},   -----消亡时表情
  disp_dialog = {odds=100, value={1312204}},  -----消亡时对话
  normal_emoji = {odds=80, value={4,25,26}},  -----平时表情
  normal_dialog = {odds=60, value={1312207,1312208,1312209}}, -----平时对话
  attack_emoji = {odds=80, value={20,23,30}},  -----主人攻击时表情
  attack_dialog = {odds=60, value={1312205,1312206}}, -----主人攻击时对话
  emoji_interval = 6,    ------------------------表情间隔时间
  dialog_interval = 10,   ------------------------对话间隔时间
}
