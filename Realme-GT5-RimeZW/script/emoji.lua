--[[

仿大厂样式的emoji键盘
作者：6486449j
版本：1.0

]]--
require "import"
import "android.widget.*"
import "android.view.*"
import "android.graphics.RectF"
import "android.graphics.drawable.StateListDrawable"
import "java.io.File"
import "java.math.BigInteger"

import "android.os.*"
import "com.osfans.trime.*"
import "yaml"
import "android.graphics.Typeface"
import "java.lang.String"
import "java.util.regex.*"

--键盘高度
local keyboard_height="300dp"
pcall(function()
  keyboard_height=service.getLastKeyboardHeight()
end)
--键盘宽度
local keyboard_width=service.getWidth()

--底部按键高度
local bomBtmHeight=150
local bomBtmWidth=250

--功能键区域宽度
local funbtnWidth=250

local symBtnBorder=true
local tabBtnBorder=true
local funBtnBorder=true

--功能键颜色与边框的默认颜色
local funBtnColor=0xffc4c9ca
local funBtnBorderColor=0xff777777

--底部按键边框的默认颜色
local tabBtnColor=0xffffffff
local tabBtnBorderColor=0xff777777
local cliedTabBtnColor=0xffc4c9ca

--符号列表的按键的默认颜色
local symBtnColor=0xffffffff
local symBtnBorderColor=0xff777777
local cliedSymbtnColor=0xffc4c9ca

local maxRntSymbol=20

--符号
local symbol_icons={"🕜", "😀", "🙇", "🤙🏿","💐", "🍓", "🛑", "🎉", "📱", "❤", "️🏁"}
local symbol_label={"最近", "表情", "人物","更多肤色", "自然", "饮食", "场所交通", "事物", "物体", "标志", "旗帜"}
local symbols={
  {{}},
  {[[😀😃😄😁😆😅😂🤣😭😉😗😙😚😘🥰😍🤩🥳🙃🙂🥲🥹😋😛😝😜🤪😇😊☺️😏😌😔😑😐😶🫡🤔🤫🫢🤭🥱🤗🫣😱🤨🧐😒🙄]],{"😮‍💨"},[[😤😠😡🤬🥺😟😥😢☹️🙁🫤😕🤐😰😨😧😦😮😯😲😳🤯😬😓😞😖😣😩😫😵😵‍💫🫥😴😪🤤🌛🌜🌚🌝🌞🫠]],{"😶‍🌫️"},[[🥴🥵🥶🤢🤮🤧🤒🤕😷🤠🤑😎🤓🥸🤥🤡👻💩👽🤖🎃😈👿👹👺🔥💫⭐🌟✨💥💯💢💨💦🫧💤🕳️🎉🎊🙈🙉🙊😺😸😹😻😼😽🙀😿😾❤️🧡💛💚💙💜🤎🖤🤍♥️💘💝💖💗💓💞💕💌💟]],{"❣️", "❤️‍🩹", "💔", "❤️‍🔥"},[[💋🫂👥👤🗣️👣🧠🫀🫁🩸🦠🦷🦴☠️💀👀👁️👄🫦👅👃👂🦻🦶🦵🦿🦾💪👍👎👏🫶🙌👐🤲🤝🤜🤛✊👊🫳🫴🫱🫲🤚👋🖐️🫵✍️🤳🙏💅]]},
  {[[🙇🙋💁🙆🙅🤷🤦🙍🙎🧏💆💇🧖🛀🛌🧘]],{"🧑‍🦯","🧑‍🦼","🧑‍🦽"},[[🧎🧍🚶🏃🤸🏋️⛹️🤾🚴🚵🧗🤼🤹🏌️🏇🤺⛷️🏂🪂🏄🚣🏊🤽🧜🧚🧞🧝🧙🧛🧟🧌🦸🦹🥷]],{"🧑‍🎄","👼","💂","🫅","🤵","👰","🧑‍🚀","👷","👮","🕵️","🧑‍✈️","🧑‍🔬","🧑‍⚕️","🧑‍🔧","🧑‍🏭","🧑‍🚒","🧑‍🌾","🧑‍🏫","🧑‍🎓","🧑‍💼","🧑‍⚖️","🧑‍💻","🧑‍🎤","🧑‍🎨","🧑‍🍳","👳","🧕","👲"},[[👶🧒🧑🧓]],{"🧑‍🦳","🧑‍🦰","👱","🧑‍🦱","🧑‍🦲"},[[🧔🕴️💃🕺👯]],{"🧑‍🤝‍🧑","👭","👬","👫","💏","👩‍❤️‍💋‍👨","👨‍❤️‍💋‍👨","👩‍❤️‍💋‍👩","💑","👩‍❤️‍👨","👨‍❤️‍👨","👩‍❤️‍👩","🫄","🤱","🧑‍🍼","👪"}},
  {{"👃🏻","👃🏼","👃🏽","👃🏾","👃🏿","👂🏻","👂🏼","👂🏽","👂🏾","👂🏿","🦻🏻","🦻🏼","🦻🏽","🦻🏾","🦻🏿","🦶🏻","🦶🏼","🦶🏽","🦶🏾","🦶🏿","🦵🏻","🦵🏼","🦵🏽","🦵🏾","🦵🏿","💪🏻","💪🏼","💪🏽","💪🏾","💪🏿","👍🏻","👍🏼","👍🏽","👍🏾","👍🏿","👎🏻","👎🏼","👎🏽","👎🏾","👎🏿","👏🏻","👏🏼","👏🏽","👏🏾","👏🏿","🫶🏻","🫶🏼","🫶🏽","🫶🏾","🫶🏿","🙌🏻","🙌🏼","🙌🏽","🙌🏾","🙌🏿","👐🏻","👐🏼","👐🏽","👐🏾","👐🏿","🤲🏻","🤲🏼","🤲🏽","🤲🏾","🤲🏿","🤝🏻","🫱🏻‍🫲🏼","🫱🏻‍🫲🏽","🫱🏻‍🫲🏿","🫱🏻‍🫲🏿","🫱🏼‍🫲🏻","🤝🏼","🫱🏼‍🫲🏽","🫱🏼‍🫲🏾","🫱🏼‍🫲🏿","🫱🏽‍🫲🏻","🫱🏽‍🫲🏼","🤝🏽","🫱🏽‍🫲🏾","🫱🏽‍🫲🏿","🫱🏾‍🫲🏻","🫱🏾‍🫲🏼","🫱🏾‍🫲🏽","🤝🏾","🫱🏾‍🫲🏿","🫱🏿‍🫲🏻","🫱🏿‍🫲🏼","🫱🏿‍🫲🏽","🫱🏿‍🫲🏾","🤝🏿","🤜🏻","🤜🏼","🤜🏽","🤜🏾","🤜🏿","🤛🏻","🤛🏼","🤛🏽","🤛🏾","🤛🏿","✊🏻","✊🏼","✊🏽","✊🏾","✊🏿","👊🏻","👊🏼","👊🏽","👊🏾","👊🏿","🫳🏻","🫳🏼","🫳🏽","🫳🏾","🫳🏿","🫴🏻","🫴🏼","🫴🏽","🫴🏾","🫴🏿","🫱🏻","🫱🏼","🫱🏽","🫱🏾","🫱🏿","🫲🏻","🫲🏼","🫲🏽","🫲🏾","🫲🏿","🤚🏻","🤚🏼","🤚🏽","🤚🏾","🤚🏿","👋🏻","👋🏼","👋🏽","👋🏾","👋🏿","🖐🏻","🖐🏼","🖐🏽","🖐🏾","🖐🏿","✋🏻","✋🏼","✋🏽","✋🏾","✋🏿","🖖🏻","🖖🏼","🖖🏽","🖖🏾","🖖🏿","🤟🏻","🤟🏼","🤟🏽","🤟🏾","🤟🏿","🤘🏻","🤘🏼","🤘🏽","🤘🏾","🤘🏿","✌🏻","✌🏼","✌🏽","✌🏾","✌🏿","🤞🏻","🤞🏼","🤞🏽","🤞🏾","🤞🏿","🫰🏻","🫰🏼","🫰🏽","🫰🏾","🫰🏿","🤙🏻","🤙🏼","🤙🏽","🤙🏾","🤙🏿","🤌🏻","🤌🏼","🤌🏽","🤌🏾","🤌🏿","🤏🏻","🤏🏼","🤏🏽","🤏🏾","🤏🏿","👌🏻","👌🏼","👌🏽","👌🏾","👌🏿","🖕🏻","🖕🏼","🖕🏽","🖕🏾","🖕🏿","☝🏻","☝🏼","☝🏽","☝🏾","☝🏿","👆🏻","👆🏼","👆🏽","👆🏾","👆🏿","👇🏻","👇🏼","👇🏽","👇🏾","👇🏿","👉🏻","👉🏼","👉🏽","👉🏾","👉🏿","👈🏻","👈🏼","👈🏽","👈🏾","👈🏿","🫵🏻","🫵🏼","🫵🏽","🫵🏾","🫵🏿","✍🏻","✍🏼","✍🏽","✍🏾","✍🏿","🤳🏻","🤳🏼","🤳🏽","🤳🏾","🤳🏿","🙏🏻","🙏🏼","🙏🏽","🙏🏾","🙏🏿","💅🏻","💅🏼","💅🏽","💅🏾","💅🏿","🙇🏻","🙇🏼","🙇🏽","🙇🏾","🙇🏿","🙇‍♀️","🙇🏻‍♀️","🙇🏼‍♀️","🙇🏽‍♀️","🙇🏾‍♀️","🙇🏿‍♀️","🙇‍♂️","🙇🏻‍♂️","🙇🏼‍♂️","🙇🏽‍♂️","🙇🏾‍♂️","🙇🏿‍♂️","🙋🏻","🙋🏼","🙋🏽","🙋🏾","🙋🏿","🙋‍♀️","🙋🏻‍♀️","🙋🏼‍♀️","🙋🏽‍♀️","🙋🏾‍♀️","🙋🏿‍♀️","🙋‍♂️","🙋🏻‍♂️","🙋🏼‍♂️","🙋🏽‍♂️","🙋🏾‍♂️","🙋🏿‍♂️","💁🏻","💁🏼","💁🏽","💁🏾","💁🏿","💁‍♀️","💁🏻‍♀️","💁🏼‍♀️","💁🏽‍♀️","💁🏾‍♀️","💁🏿‍♀️","💁‍♂️","💁🏻‍♂️","💁🏼‍♂️","💁🏽‍♂️","💁🏾‍♂️","💁🏿‍♂️","🙆🏻","🙆🏼","🙆🏽","🙆🏾","🙆🏿","🙆‍♀️","🙆🏻‍♀️","🙆🏼‍♀️","🙆🏽‍♀️","🙆🏾‍♀️","🙆🏿‍♀️","🙆‍♂️","🙆🏻‍♂️","🙆🏼‍♂️","🙆🏽‍♂️","🙆🏾‍♂️","🙆🏿‍♂️","🙅🏻","🙅🏼","🙅🏽","🙅🏾","🙅🏿","🙅‍♀️","🙅🏻‍♀️","🙅🏼‍♀️","🙅🏽‍♀️","🙅🏾‍♀️","🙅🏿‍♀️","🙅‍♂️","🙅🏻‍♂️","🙅🏼‍♂️","🙅🏽‍♂️","🙅🏾‍♂️","🙅🏿‍♂️","🤷🏻","🤷🏼","🤷🏽","🤷🏾","🤷🏿","🤷‍♀️","🤷🏻‍♀️","🤷🏼‍♀️","🤷🏽‍♀️","🤷🏾‍♀️","🤷🏿‍♀️","🤷‍♂️","🤷🏻‍♂️","🤷🏼‍♂️","🤷🏽‍♂️","🤷🏾‍♂️","🤷🏿‍♂️","🤦","🤦🏻","🤦🏼","🤦🏽","🤦🏾","🤦🏿","🤦‍♀️","🤦🏻‍♀️","🤦🏼‍♀️","🤦🏽‍♀️","🤦🏾‍♀️","🤦🏿‍♀️","🤦‍♂️","🤦🏻‍♂️","🤦🏼‍♂️","🤦🏽‍♂️","🤦🏾‍♂️","🤦🏿‍♂️","🙍","🙍🏻","🙍🏼","🙍🏽","🙍🏾","🙍🏿","🙍‍♀️","🙍🏻‍♀️","🙍🏼‍♀️","🙍🏽‍♀️","🙍🏾‍♀️","🙍🏿‍♀️","🙍‍♂️","🙍🏻‍♂️","🙍🏼‍♂️","🙍🏽‍♂️","🙍🏾‍♂️","🙍🏿‍♂️","🙎","🙎🏻","🙎🏼","🙎🏽","🙎🏾","🙎🏿","🙎‍♀️","🙎🏻‍♀️","🙎🏼‍♀️","🙎🏽‍♀️","🙎🏾‍♀️","🙎🏿‍♀️","🙎‍♂️","🙎🏻‍♂️","🙎🏼‍♂️","🙎🏽‍♂️","🙎🏾‍♂️","🙎🏿‍♂️"}},
  {[[💐🌹🥀🌺🌷🪷🌸💮🏵️🌻🌼🍂🍁🍄🌾🌱🌿🍃☘️🍀🪴🌵🌴🌳🌲🪹🪺🪵🪨⛰️🏔️❄️☃️⛄🌊🫧🌬️🌀🌪️🌁🌫️🌡️🔥🌋🏜️🏞️🏖️⛱️🌅🌄☀️🌤️⛅🌥️🌦️☁️🌨️⛈️🌩️🌧️💧☔⚡🌈⭐🌟💫✨🌙☄️🌠🌌🪐🌑🌒🌓🌔🌕🌖🌗🌘🌍🌎🌏🙈🙉🙊🐵🦁🐯🐱🐶🐺🐻🐻‍❄️🐨🐼🐹🐭🐰🦊🦝🐮🐷🐽🐗🦓🦄🐴🐸🐲🦎🐉🦖🦕🐢🐊🐍🐁🐀🐇🐈🐈‍⬛🐩🐕🦮🐕‍🦺🐅🐆🐎🐖🐄🐂🐃🦬🐏🐑🐐🦌🦙🦥🦘🐘🦣🦏🦛🦒🐒🦍🦧🐪🐫🐿️🦫🦨🦡🦔🦦🦇🪶🦅🦉🐓🐔🐣🐤🐥🐦🦜🕊️🦤🦢🦩🦚🦃🦆🐧🦭🦈🐬🐋🐳🐟🐠🐡🦐🦞🦀🦑🐙🦪🪸🦂🕷️🕸️🐚🐌🐜🦗🪲🦟🪳🪰🐝🐞🦋🐛🪱🦠🐾]]},
  {[[🍓🍒🍎🍉🍑🍊🥭🍍🍌🍋🍈🍏🍐🥝🫒🫐🍇🥥🍅🌶️🥕🍠🧅🌽🥦🥒🥬🫑🥑🍆🧄🥔🫘🌰🥜🍞🫓🥐🥖🥯🧇🥞🍳🥚🧀🥓🥩🍗🍖🍔🌭🥪🥨🍟🍕🫔🌮🌯🥙🧆🥘🍝🥫🫕🥣🥗🍲🍛🍜🦪🦞🍣🍤🥡🍚🍱🥟🍢🍙🍘🍥🍡🥠🥮🍧🍨🍦🥧🍰🍮🎂🧁🍭🍬🍫🍩🍪🍯🧂🧈🍿🧊🫙🥤🧋🧃🥛🍼🍵☕🫖🧉🍺🍻🥂🍾🍷🥃🫗🍸🍹🍶🥢🍴🥄🔪🍽️]]},
  {[[🛑🚧🚨⛽🛢️🧭🛞🛟⚓🚏🚇🚥🚦🛴🦽🦼🩼🚲🛵🏍️🚙🚗🛻🚐🚚🚛🚜🏎️🚒🚑🚓🚕🛺🚌🚈🚝🚅🚄🚂🚃🚋🚎🚞🚊🚉🚍🚔🚘🚖🚆🚢🛳️🛥️🚤⛴️⛵🛶🚟🚠🚡🚁🛸🚀✈️🛫🛬🛩️🛝🎢🎡🎠🎪🗼🗽🗿🗻🏛️💈⛲⛩️🕍🕌🕋🛕⛪💒🏩🏯🏰🏗️🏢🏭🏬🏪🏟️🏦🏫🏨🏣🏤🏥🏚️🏠🏡🏘️🛖⛺🏕️🏙️🌆🌇🌃🌉🌁🛤️🛣️🏝️🗾🗺️🌐💺🧳]]},
  {[[🎉🎊🎈🎂🎀🎁🎇🎆🧨🧧🪔🪅🪩🎐🎏🎎🎑🎍🎋🎄🎃🎗️🥇🥈🥉🏅🎖️🏆📢⚽⚾🥎🏀🏐🏈🏉🎾🥅🏸🥍🏏🏑🏒🥌🛷🎿⛸️🛼🩰🛹⛳🎯🏹🥏🪃🪁🎣🤿🩱🎽🥋🥊🎱🏓🎳♟️🪀🧩🎮🕹️👾🔫🎲🎰🎴🀄🃏🪄🎩📷📸🖼️🎨🖌️🖍️🪡🧵🧶🎹🎷🎺🎸🪕🎻🪘🥁🪗🎤🎧🎚️🎛️🎙️📻📺📼📹📽️🎥🎞️🎬🎭🎫🎟️]]},
  {[[📱☎️📞📟📠🔌🔋🪫🖲️💽💾💿📀🖥️💻⌨️🖨️🖱️🪙💸💵💴💶💷💳💰🧾🧮⚖️🛒🛍️🕯️💡🔦🏮🧱🪟🪞🚪🪑🛏️🛋️🚿🛁🚽🧻🪠🧸🪆🧷🪢🧹🧴🧽🧼🪥🪒🧺🧦🧤🧣👖👕🎽👚👔👗👘🥻🩱👙🩳🩲🧥🥼🦺⛑️🪖🎓🎩👒🧢👑🎒👝👛👜💼🧳☂️🌂💍💎💄👠👟👞🥿🩴👡👢🥾👓🕶️🦯🥽⚗️🧫🧪🌡️🧬💉💊🩹🩺🩻🔭🔬📡🛰️🧯🪓🪜🪣🪝🧲🧰🗜️🔩🪛🪚🔧🔨⚒️🛠️⛏️⚙️🔗⛓️📎🖇️📏📐✂️📌📍🗑️🖌️🖍️🖊️🖋️✒️✏️📝📒📔📕📓📗📘📙📚📖🔖🗒️📄📃📋📇📑🗃️🗄️🗂️📂📁📰🗞️📊📈📉🪧🪪🏷️📦📫📪📬📭📮✉️📧📩📨💌📤📥🗳️⏱️🕛🕧🕐🕜🕑🕝🕒🕞🕓🕟🕔🕠🕕🕡🕖🕢🕗🕣🕘🕤🕙🕥🕚🕦⌛⏳🕰️⌚⏲️⏰🗓️📅📆🛎️🔔📯📢📣🔍🔎🔮🧿🪬📿🏺⚱️⚰️🪦🚬💣🪤📜⚔️🗡️🛡️🗝️🔑🔐🔏🔒🔓]]},
  {[[❤️🧡💛💚💙💜🤎🖤🤍🔴🟠🟡🟢🔵🟣🟤⚫⚪🟥🟧🟨🟩🟦🟪🟫⬛⬜♈♉♊♋♌♍♎♏♐♑♒♓⛎♀️♂️⚧️🔻🔺❕❗❔❓⁉️‼️⭕❌🚫🚳🚭🚯🚱🚷📵🔞🔕🔇🅰️🆎🅱️🅾️🆑🆘🛑⛔📛♨️🉐㊙️㊗️🈴🈵🈹🈲🉑🈶🈚🈸🈺🈷️🔶🔸🔆🔅✴️🆚🎦📶🔁🔂🔀▶️⏩⏭️⏯️◀️⏪⏮️🔼⏫🔽⏬⏸️⏹️⏺️⏏️📴📳📲🔈🔉🔊🎼🎵🎶☢️☣️⚠️🚸⚜️🔱〽️🔰✳️❇️♻️💱💲💹🈯❎✅✔️☑️⬆️↗️➡️↘️⬇️↙️⬅️↖️↕️↔️↩️↪️⤴️⤵️🔃🔄🔙🔛🔝🔚🔜🆕🆓🆙🆗🆒🆖ℹ️🅿️🈁🈂️🈳🔣🔤🔠🔡🔢]],{"#️⃣️","*️⃣","0️⃣️","1️⃣","2️⃣️","3️⃣","4️⃣","5️⃣️","6️⃣","7️⃣","8️⃣","9️⃣","🔟"},[[💠🔷🔹🌐🏧Ⓜ️🚾🚻🚹🚺♿🚼🛗🚮🚰🛂🛃🛄🛅💟⚛️🛐🕉️☸️☮️☯️☪️✝️☦️✡️🔯🕎♾️🆔⚕️✖️➕➖➗🟰➰➿〰️©️®️™️♥️♦️♣️♠️🔘🔳◼️◾▪️🔲◻️◽▫️💭🗯️💬🗨️👁️‍🗨️]]},
  {{"🏁","🚩","🎌","🏴","🏳","️🏳️‍🌈","🏳️‍⚧️","🏴‍☠️","🇦🇨","🇦🇩","🇦🇪","🇦🇫","🇦🇬","🇦🇮","🇦🇱","🇦🇲","🇦🇴","🇦🇶","🇦🇷","🇦🇸","🇦🇹","🇦🇺","🇦🇼","🇦🇽","🇦🇿","🇧🇦","🇧🇧","🇧🇩","🇧🇪","🇧🇫","🇧🇬","🇧🇭","🇧🇮","🇧🇯","🇧🇱","🇧🇲","🇧🇳","🇧🇴","🇧🇶","🇧🇷","🇧🇸","🇧🇹","🇧🇻","🇧🇼","🇧🇾","🇧🇿","🇨🇦","🇨🇨","🇨🇩","🇨🇫","🇨🇬","🇨🇭","🇨🇮","🇨🇰","🇨🇱","🇨🇲","🇨🇳","🇨🇴","🇨🇵","🇨🇷","🇨🇺","🇨🇻","🇨🇼","🇨🇽","🇨🇾","🇨🇿","🇩🇪","🇩🇬","🇩🇯","🇩🇰","🇩🇲","🇩🇴","🇩🇿","🇪🇦","🇪🇨","🇪🇪","🇪🇬","🇪🇭","🇪🇷","🇪🇸","🇪🇹","🇪🇺","🇫🇮","🇫🇯","🇫🇰","🇫🇲","🇫🇴","🇫🇷","🇬🇦","🇬🇧","🇬🇩","🇬🇪","🇬🇫","🇬🇬","🇬🇭","🇬🇮","🇬🇱","🇬🇲","🇬🇳","🇬🇵","🇬🇶","🇬🇷","🇬🇸","🇬🇹","🇬🇺","🇬🇼","🇬🇾","🇭🇰","🇭🇲","🇭🇳","🇭🇷","🇭🇹","🇭🇺","🇮🇨","🇮🇩","🇮🇪","🇮🇱","🇮🇲","🇮🇳","🇮🇴","🇮🇶","🇮🇷","🇮🇸","🇮🇹","🇯🇪","🇯🇲","🇯🇴","🇯🇵","🇰🇪","🇰🇬","🇰🇭","🇰🇮","🇰🇲","🇰🇳","🇰🇵","🇰🇷","🇰🇼","🇰🇾","🇰🇿","🇱🇦","🇱🇧","🇱🇨","🇱🇮","🇱🇰","🇱🇷","🇱🇸","🇱🇹","🇱🇺","🇱🇻","🇱🇾","🇲🇦","🇲🇨","🇲🇩","🇲🇪","🇲🇫","🇲🇬","🇲🇭","🇲🇰","🇲🇱","🇲🇲","🇲🇳","🇲🇴","🇲🇵","🇲🇶","🇲🇷","🇲🇸","🇲🇹","🇲🇺","🇲🇻","🇲🇼","🇲🇽","🇲🇾","🇲🇿","🇳🇦","🇳🇨","🇳🇪","🇳🇫","🇳🇬","🇳🇮","🇳🇱","🇳🇴","🇳🇵","🇳🇷","🇳🇺","🇳🇿","🇴🇲","🇵🇦","🇵🇪","🇵🇫","🇵🇬","🇵🇭","🇵🇰","🇵🇱","🇵🇲","🇵🇳","🇵🇷","🇵🇸","🇵🇹","🇵🇼","🇵🇾","🇶🇦","🇷🇪","🇷🇪","🇷🇴","🇷🇸","🇷🇺","🇷🇼","🇷🇼","🇸🇦","🇸🇧","🇸🇨","🇸🇩","🇸🇪","🇸🇬","🇸🇭","🇸🇮","🇸🇯","🇸🇰","🇸🇱","🇸🇲","🇸🇳","🇸🇴","🇸🇷","🇸🇸","🇸🇹","🇸🇻","🇸🇽","🇸🇾","🇸🇿","🇹🇦","🇹🇨","🇹🇩","🇹🇫","🇹🇬","🇹🇭","🇹🇯","🇹🇰","🇹🇱","🇹🇲","🇹🇳","🇹🇴","🇹🇷","🇹🇷","🇹🇹","🇹🇻","🇹🇼","🇹🇿","🇺🇦","🇺🇬","🇺🇲","🇺🇳","🇺🇸","🇺🇾","🇺🇿","🇻🇦","🇻🇨","🇻🇪","🇻🇬","🇻🇮","🇻🇳","🇻🇺","🇼🇫","🇼🇸","🇽🇰","🇾🇪","🇾🇹","🇿🇦","🇿🇲","🇿🇼","🏴󠁧󠁢󠁥󠁮󠁧󠁿","🏴󠁧󠁢󠁳󠁣󠁴󠁿","🏴󠁧󠁢󠁷󠁬󠁳󠁿"}}
}
--输入法数据路径
local rimePath=tostring(service.getLuaExtDir("")).."/"

--转为整数
local function toint(n)
  local s = tostring(n)
  local i, j = s:find('%.')
  if i then
    return tonumber(s:sub(1, i-1))
   else
    return n
  end
end

local function toDexStr(n)
  n=toint(n)
  local str=""
  if n != nil then
    str = "0x" .. BigInteger(tostring(n), 10).toString(16)
  end
  return str
end

--传入十进制数，补全为十六进制八位数(填上F直到满八位)
local function completeCorVal(v)
  local vs=string.gsub(toDexStr(v), "0x", "")
  --print(vs)
  vs=string.upper(vs)
  while string.len(vs)<8
    vs="F" .. vs
  end
  vs="0x" .. vs
  --print(vs)
  return tonumber(vs, F)
end

local function transpColor(c)
  local str=string.gsub(tostring(c), "0xFF", "")
  str="0x88" .. str
  return(toint(str))

end

local 主题组=Config.get()
local 当前主题0=主题组.getTheme()
local 主题文件=rimePath.."build/"..当前主题0..".yaml"
local yaml组 = yaml.load(io.readall(主题文件))

local bgpic_path=rimePath.."bg.jpg"
local 当前配色ID=Config.get().getColorScheme()
local 当前配色背景 = yaml组["preset_color_schemes"][当前配色ID]["keyboard_back_color"]
if 当前配色背景==nil then
  当前配色背景 = yaml组["preset_color_schemes"][当前配色ID]["back_color"]
end
local 当前配色背景颜色 = completeCorVal(当前配色背景)

local 当前按键背景 = yaml组["preset_color_schemes"][当前配色ID]["key_back_color"]
if 当前按键背景==nil then
  当前按键背景 = yaml组["preset_color_schemes"][当前配色ID]["back_color"]
end
local 当前按键背景颜色 = completeCorVal(当前按键背景)

if 当前配色背景颜色 != nil then
  --背景颜色
  --print(toDexStr(当前按键背景颜色))
  symBtnColor=当前配色背景颜色
  tabBtnColor=当前按键背景颜色

  funBtnColor=当前按键背景颜色
  cliedTabBtnColor=当前配色背景颜色
 elseif 当前配色背景 != nil and File(bgpic_path).isFile()==false then
  --说明是背景图片
  bgpic_path = rimePath .. "backgrounds/" .. 当前配色背景
end

--[[
if File(bgpic_path).isFile() then
  symBtnColor=transpColor(symBtnColor)
  tabBtnColor=transpColor(tabBtnColor)

  funBtnColor=transpColor(funBtnColor)
  cliedTabBtnColor=transpColor(cliedTabBtnColor)
  
end
]]--

local fontColorConf=yaml组["preset_color_schemes"][当前配色ID]["key_text_color"]

if fontColorConf==nil then
  fontColorConf=yaml组["preset_color_schemes"][当前配色ID]["candidate_text_color"]
end

if fontColorConf==nil then
  fontColorConf=yaml组["preset_color_schemes"][当前配色ID]["text_color"]
end

if fontColorConf==nil then
  fontColorConf=0xffffffff
end

local fontColor=completeCorVal(fontColorConf)

--储存最近使用符号的文件路径
local recentSymbolPath=rimePath.."recent_emoji.txt"

local rntSymbol={}

--判断文件是否存在
if not File(recentSymbolPath).exists()
  File(recentSymbolPath).createNewFile()
end

local function revertTable(t)
  local tmp={}
  for i in ipairs(t)
    table.insert(tmp, i)
  end
  return tmp
end

--插入最近符号
local function insertRntSymbol(s)
  local j=0
  for i, k in ipairs(rntSymbol) do
    j=j+1
    if k==s
      table.remove(rntSymbol, j)
    end
  end
  table.insert(rntSymbol, 1, s)
end

--更新最近符号
local function genRntSymbol()
  symbols[1][1]=rntSymbol
end

--从文本文件中读取最近符号
for s in io.lines(recentSymbolPath) do
  table.insert(rntSymbol, tostring(s))
end

genRntSymbol()

--生成储存在文本文件里的带回车的字符串
local function genRntSybFileStr()
  local str=""
  for i,k in ipairs(rntSymbol) do
    str=str..k.."\n"
  end
  return str
end

local currSelect=1

local layout_ids={}

local curr_tab_id="tab"..tostring(currSelect)
local last_tab_id=""

--获取k功能图标，没有返回s
local function icon(k,s)
  k=Key.presetKeys[k]
  return k and k.label or s
end

--生成背景
local function background(color, borderColor)
  local background=LuaDrawable(function(canvas, paint, drawable)
    local b=drawable.bounds
    --paint.setColor(color)
    canvas.drawColor(color)
    paint.setColor(borderColor)
    paint.setStrokeWidth(2)
    canvas.drawLine(b.left, b.top, b.left, b.bottom, paint)
    canvas.drawLine(b.left, b.top, b.right, b.top, paint)
    canvas.drawLine(b.right, b.top, b.right, b.bottom, paint)
    canvas.drawLine(b.left, b.bottom, b.right, b.bottom, paint)
  end)

  return background
end

local function emoji_bg(color, borderColor)
  local background=LuaDrawable(function(canvas, paint, drawable)
    local b=drawable.bounds
    --paint.setColor(color)
    canvas.drawColor(color)
    paint.setColor(borderColor)
    paint.setStrokeWidth(10)
    canvas.drawLine(b.left, b.top+20, b.left, b.bottom-20, paint)
    --canvas.drawLine(b.left, b.top, b.right, b.top, paint)
    --canvas.drawLine(b.right, b.top+20, b.right, b.bottom-20, paint)
    --canvas.drawLine(b.left, b.bottom, b.right, b.bottom, paint)
  end)

  return background
end

local function bg_effect(color, clickedColor, borderColor)
  local state_1=background(color, borderColor)
  local state_2=background(clickedColor, borderColor)

  local bg=StateListDrawable()
  bg.addState({-android.R.attr.state_pressed},state_1)
  bg.addState({android.R.attr.state_pressed},state_2)
  return bg
end

--设置字体
local vibeFont=Typeface.DEFAULT
local 字体文件 = service.getLuaDir().."/fonts/emoji.ttf"
if File(字体文件).exists() then
  vibeFont=Typeface.createFromFile(字体文件)
end

local data={}
local item={
  LinearLayout,
  layout_height=150,
  layout_width=-1,
  gravity="center",
  {
    TextView,
    id="text",
    layout_width=-1,
    layout_height=-1,
    textColor=fontColor,
    gravity="center",
    textSize="22dp",
    Typeface=vibeFont,
    background=emoji_bg(symBtnColor,symBtnBorderColor)
}}
local adp=LuaAdapter(service, data, item)

--生成侧边功能键
local function getFunKeys()
  local funbtnHeight=(keyboard_height-bomBtmHeight)/4
  local layout={LinearLayout,
    Orientation=1,
    layout_padding=0,
    layout_width="fill",
    {Button,
      id="back",
      text=icon("Keyboard_default", "返回"),
      textColor=fontColor,
      layout_height=funbtnHeight,
      Typeface=vibeFont,
      onClick=function()
        local str=genRntSybFileStr()
        io.open(recentSymbolPath,"w"):write(str):close()
        service.sendEvent("Keyboard_default")
      end,
      background=background(funBtnColor,funBtnBorderColor)
    },
    {Button,
      text=icon("space", "空格"),
      textColor=fontColor,
      layout_height=funbtnHeight,
      Typeface=vibeFont,
      onClick=function()
        service.sendEvent("space")
      end,
      background=background(funBtnColor,funBtnBorderColor)
    },
    {Button,
      text=icon("BackSpace","退格"),
      textColor=fontColor,
      layout_height=funbtnHeight,
      Typeface=vibeFont,
      onClick=function()
        service.sendEvent("BackSpace")
      end,
      background=background(funBtnColor,funBtnBorderColor)
    },
    {Button,
      text=icon("Return", "回车"),
      textColor=fontColor,
      layout_height=funbtnHeight,
      Typeface=vibeFont,
      onClick=function()
        service.sendEvent("Return")
      end,
      background=background(funBtnColor,funBtnBorderColor)
    }
  }
  return layout
end

local emoji_match="([^\\u0000-\\uFFFF])"

--生成符号列表
local function genContentList()
  table.clear(data)
  local tmp_sym=symbols[currSelect]
  local tmps={}
  for i, j in ipairs(tmp_sym)
    if type(j)=="string" then
      local temp={}

      local pattern=Pattern.compile(emoji_match)
      local match=pattern.matcher(j)
      while match.find()
        local sym=match.group()
        table.insert(tmps,sym)
      end
    elseif type(j)=="table" then
      for k,l in ipairs(j)
        table.insert(tmps, l)
      end
    end
  end
  for i, j in ipairs(tmps)
    table.insert(data,{
      text={
        Text=tostring(j),
      },
    })
  end
end

--生成底部按键
local function getBottomKeys()
  local layout={HorizontalScrollView,
    scrollBarSize=0,
    {LinearLayout,
      Orientation=0,
      layout_padding=0
    }
  }
  for i in ipairs(symbol_icons)
    local btn={LinearLayout,
      Orientation=1,
      gravity="center",
      id="tab"..tostring(i),
      layout_padding=0,
      layout_width="fill",
      layout_width=bomBtmWidth,
      layout_height=bomBtmHeight,
      background=emoji_bg(tabBtnColor, tabBtnBorderColor),
      onClick=function()
        last_tab_id=curr_tab_id
        curr_tab_id="tab"..tostring(i)
        currSelect=i
        if i==1
          genRntSymbol()
        end
        genContentList()
        adp.notifyDataSetChanged()

        if curr_tab_id ~= last_tab_id then
          if curr_tab_id~="" then
            layout_ids[curr_tab_id].setBackground(emoji_bg(cliedTabBtnColor,tabBtnBorderColor))
          end
          if last_tab_id~="" then
            layout_ids[last_tab_id].setBackground(emoji_bg(tabBtnColor,tabBtnBorderColor))
          end
        end
        layout_ids.list.smoothScrollToPosition(0)
      end,

      {TextView,
        layout_gravity="center_horizontal",
        text=tostring(symbol_icons[i]),
        textColor=fontColor,
        layout_padding=0,
        Typeface=vibeFont,
      },
      {
        TextView,
        layout_gravity="center_horizontal",
        text=tostring(symbol_label[i]),
        textSize="10dp",
        textColor=fontColor
      }
    }

    table.insert(layout[2], btn)
  end

  return layout
end

--主布局
local layout = {
  FrameLayout,
  layout_height=keyboard_height,
  layout_width=-1,
  BackgroundColor=symBtnColor,
  {LinearLayout,
    id="main",
    orientation=1,
    {LinearLayout,
      id="se",
      orientation=1,
      layout_height=keyboard_height-bomBtmHeight,
      {LinearLayout,
        layout_width="match_parent",
        Orientation=0,
        {GridView,
          id="list",
          numColumns=6,
          scrollBarSize=0,
          layout_width=keyboard_width-funbtnWidth},
        getFunKeys()
      }
    },
    getBottomKeys()
  }
}
layout=loadlayout(layout, layout_ids)

genContentList()

layout_ids.list.Adapter=adp

layout_ids.list.onItemClick=function(l,v,p,i)
  local s=data[p+1].text.Text
  insertRntSymbol(s)
  service.commitText(s)
end

if curr_tab_id~="" then
  layout_ids[curr_tab_id].setBackground(emoji_bg(cliedTabBtnColor,tabBtnBorderColor))
end

service.setKeyboard(layout)

local function gradientDrawable(orientation,colors)
  import"android.graphics.drawable.GradientDrawable"
  return GradientDrawable(GradientDrawable.Orientation[orientation],colors)
end

local 脚本目录=tostring(service.getLuaExtDir("script")).."/"
local 脚本路径=debug.getinfo(1,"S").source:sub(2)--获取Lua脚本的完整路径
local 纯脚本名=File(脚本路径).getName()
local 目录=string.sub(脚本路径,1,#脚本路径-#纯脚本名)

--视频路径
local bgmv_path=rimePath.."bg.mp4"
--视频文件不存在则终止脚本
if File(bgmv_path).isFile()==true then
  pcall(function()
    local play=MediaPlayer()
    play.setDataSource(bgmv_path)
    --循环播放
    play.setLooping(true)
    play.prepare()
    --音量设为0
    play.setVolume(0,0)

    local video=loadlayout{SurfaceView,
      --添加背景色，避免看不清按键
      --BackgroundColor=0x55ffffff,
      --线性渐变，"TL_BR"为topleft bottomright
      backgroundDrawable=gradientDrawable("TL_BR",{0x99FBE0B5,0x99E5EED9,0x99F3F5F8}),--背景色
      layout_width=-1,
      layout_height=-1
    }
    layout.addView(video,0) --把视频布局放到layout的第一个，也就是显示在最底层

    video.getHolder().addCallback({
      surfaceCreated=function(holder)
        play.start()
        play.setDisplay(holder)
      end,
      surfaceDestroyed=function()
        --界面关闭，释放播放器
        play.release()
    end})
  end)
 elseif File(bgpic_path).isFile()==true then
  local pic=loadlayout{ImageView,
    --添加背景色，避免看不清按键
    --BackgroundColor=0x55ffffff,
    --线性渐变，"TL_BR"为topleft bottomright
    backgroundDrawable=gradientDrawable("TL_BR",{0x99FBE0B5,0x99E5EED9,0x99F3F5F8}),--背景色
    src=bgpic_path,
    --adjustViewBounds="true",--保持长宽比
    scaleType="fitXY",--横向纵向缩放
    layout_width=-1,
    layout_height=-1}
  layout.addView(pic,0) --把视频布局放到layout的第一个，也就是显示在最底层
end