//
//  Emoji.swift
//  Yellow
//
//  Created by Icey.Liao on 2022/11/23.
//

import Foundation

/**
 This enum contains the emoji categories that the native iOS
 emoji keyboard currently has.
 
 In native iOS keyboards, emojis flow from top to bottom and
 from leading to trailing. These lists use this flow as well.
 
 Since the `frequent` category should list the most frequent
 emojis, you can now register a static `recentEmojiProvider`.
 By default, a `MostRecentEmojiProvider` will be used.
*/
public enum EmojiCategory: String, CaseIterable, Codable, Identifiable, Equatable {

    case
    smileys,
    animals,
    foods,
    activities,
    travels,
    objects,
    symbols,
    flags
}

public extension EmojiCategory {
    
    /**
     The category's unique identifier.
     */
    var id: String { rawValue }
    
    /**
     An ordered list of all available categories.
     */
    static var all: [EmojiCategory] { allCases }
    
    /**
     An ordered list with all emojis in the category.
     */
    var emojis: [Emoji] {
        emojisString
            .replacingOccurrences(of: "\n", with: "")
            .compactMap { Emoji(String($0)) }
    }
    
    /**
     An ordered string with all emojis in the category.
     */
    var emojisString: String {
        switch self {
        case .smileys: return """
😀😃😄😁😆🥹😅😂🤣🥲
☺️😊😇🙂🙃😉😌😍🥰😘
😗😙😚😋😛😝😜🤪🤨🧐
🤓😎🥸🤩🥳😏😒😞😔😟
😕🙁☹️😣😖😫😩🥺😢😭
😤😠😡🤬🤯😳🥵🥶😶‍🌫️😱
😨😰😥😓🤗🤔🫣🤭🫢🫡
🤫🫠🤥😶🫥😐🫤😑😬🙄
😯😦😧😮😲🥱😴🤤😪😮‍💨
😵😵‍💫🤐🥴🤢🤮🤧😷🤒🤕
🤑🤠😈👿👹👺🤡💩👻💀
☠️👽👾🤖🎃😺😸😹😻😼
😽🙀😿😾🫶🤲👐🙌👏🤝
👍👎👊✊🤛🤜🤞✌️🫰🤟
🤘👌🤌🤏🫳🫴👈👉👆👇
☝️✋🤚🖐🖖👋🤙🫲🫱💪
🦾🖕✍️🙏🫵🦶🦵🦿💄💋
👄🫦🦷👅👂🦻👃👣👁👀
🫀🫁🧠🗣👤👥🫂👶👧🧒
👦👩🧑👨👩‍🦱🧑‍🦱👨‍🦱👩‍🦰🧑‍🦰👨‍🦰
👱‍♀️👱👱‍♂️👩‍🦳🧑‍🦳👨‍🦳👩‍🦲🧑‍🦲👨‍🦲🧔‍♀️
🧔🧔‍♂️👵🧓👴👲👳‍♀️👳👳‍♂️🧕
👮‍♀️👮👮‍♂️👷‍♀️👷👷‍♂️💂‍♀️💂💂‍♂️🕵️‍♀️
🕵️🕵️‍♂️👩‍⚕️🧑‍⚕️👨‍⚕️👩‍🌾🧑‍🌾👨‍🌾👩‍🍳🧑‍🍳
👨‍🍳👩‍🎓🧑‍🎓👨‍🎓👩‍🎤🧑‍🎤👨‍🎤👩‍🏫🧑‍🏫👨‍🏫
👩‍🏭🧑‍🏭👨‍🏭👩‍💻🧑‍💻👨‍💻👩‍💼🧑‍💼👨‍💼👩‍🔧
🧑‍🔧👨‍🔧👩‍🔬🧑‍🔬👨‍🔬👩‍🎨🧑‍🎨👨‍🎨👩‍🚒🧑‍🚒
👨‍🚒👩‍✈️🧑‍✈️👨‍✈️👩‍🚀🧑‍🚀👨‍🚀👩‍⚖️🧑‍⚖️👨‍⚖️
👰‍♀️👰👰‍♂️🤵‍♀️🤵🤵‍♂️👸🫅🤴🥷
🦸‍♀️🦸🦸‍♂️🦹‍♀️🦹🦹‍♂️🤶🧑‍🎄🎅🧙‍♀️
🧙🧙‍♂️🧝‍♀️🧝🧝‍♂️🧌🧛‍♀️🧛🧛‍♂️🧟‍♀️
🧟🧟‍♂️🧞‍♀️🧞🧞‍♂️🧜‍♀️🧜🧜‍♂️🧚‍♀️🧚
🧚‍♂️👼🤰🫄🫃🤱👩‍🍼🧑‍🍼👨‍🍼🙇‍♀️
🙇🙇‍♂️💁‍♀️💁💁‍♂️🙅‍♀️🙅🙅‍♂️🙆‍♀️🙆
🙆‍♂️🙋‍♀️🙋🙋‍♂️🧏‍♀️🧏🧏‍♂️🤦‍♀️🤦🤦‍♂️
🤷‍♀️🤷🤷‍♂️🙎‍♀️🙎🙎‍♂️🙍‍♀️🙍🙍‍♂️💇‍♀️
💇💇‍♂️💆‍♀️💆💆‍♂️🧖‍♀️🧖🧖‍♂️💅🤳
💃🕺👯‍♀️👯👯‍♂️🕴👩‍🦽🧑‍🦽👨‍🦽👩‍🦼
🧑‍🦼👨‍🦼🚶‍♀️🚶🚶‍♂️👩‍🦯🧑‍🦯👨‍🦯🧎‍♀️🧎
🧎‍♂️🏃‍♀️🏃🏃‍♂️🧍‍♀️🧍🧍‍♂️👫👭👬
👩‍❤️‍👨👩‍❤️‍👩💑👨‍❤️‍👨👩‍❤️‍💋‍👨👩‍❤️‍💋‍👩💏👨‍❤️‍💋‍👨👨‍👩‍👦👨‍👩‍👧
👨‍👩‍👧‍👦👨‍👩‍👦‍👦👨‍👩‍👧‍👧👩‍👩‍👦👩‍👩‍👧👩‍👩‍👧‍👦👩‍👩‍👦‍👦👩‍👩‍👧‍👧👨‍👨‍👦👨‍👨‍👧
👨‍👨‍👧‍👦👨‍👨‍👦‍👦👨‍👨‍👧‍👧👩‍👦👩‍👧👩‍👧‍👦👩‍👦‍👦👩‍👧‍👧👨‍👦👨‍👧
👨‍👧‍👦👨‍👦‍👦👨‍👧‍👧🪢🧶🧵🪡🧥🥼🦺
👚👕👖🩲🩳👔👗👙🩱👘
🥻🩴🥿👠👡👢👞👟🥾🧦
🧤🧣🎩🧢👒🎓⛑🪖👑💍
👝👛👜💼🎒🧳👓🕶🥽🌂
"""
        case .animals: return """
🐶🐱🐭🐹🐰🦊🐻🐼🐻‍❄️🐨
🐯🦁🐮🐷🐽🐸🐵🙈🙉🙊
🐒🐔🐧🐦🐤🐣🐥🦆🦅🦉
🦇🐺🐗🐴🦄🐝🪱🐛🦋🐌
🐞🐜🪰🪲🪳🦟🦗🕷🕸🦂
🐢🐍🦎🦖🦕🐙🦑🦐🦞🦀
🐡🐠🐟🐬🐳🐋🦈🦭🐊🐅
🐆🦓🦍🦧🦣🐘🦛🦏🐪🐫
🦒🦘🦬🐃🐂🐄🐎🐖🐏🐑
🦙🐐🦌🐕🐩🦮🐕‍🦺🐈🐈‍⬛🪶
🐓🦃🦤🦚🦜🦢🦩🕊🐇🦝
🦨🦡🦫🦦🦥🐁🐀🐿🦔🐾
🐉🐲🌵🎄🌲🌳🌴🪵🌱🌿
☘️🍀🎍🪴🎋🍃🍂🍁🪺🪹
🍄🐚🪸🪨🌾💐🌷🌹🥀🪷
🌺🌸🌼🌻🌞🌝🌛🌜🌚🌕
🌖🌗🌘🌑🌒🌓🌔🌙🌎🌍
🌏🪐💫⭐️🌟✨⚡️☄️💥🔥
🌪🌈☀️🌤⛅️🌥☁️🌦🌧⛈
🌩🌨❄️☃️⛄️🌬💨💧💦🫧
☔️☂️🌊🌫
"""
        case .foods: return """
🍏🍎🍐🍊🍋🍌🍉🍇🍓🫐
🍈🍒🍑🥭🍍🥥🥝🍅🍆🥑
🥦🥬🥒🌶🫑🌽🥕🫒🧄🧅
🥔🍠🥐🥯🍞🥖🥨🧀🥚🍳
🧈🥞🧇🥓🥩🍗🍖🦴🌭🍔
🍟🍕🫓🥪🥙🧆🌮🌯🫔🥗
🥘🫕🥫🫙🍝🍜🍲🍛🍣🍱
🥟🦪🍤🍙🍚🍘🍥🥠🥮🍢
🍡🍧🍨🍦🥧🧁🍰🎂🍮🍭
🍬🍫🍿🍩🍪🌰🥜🫘🍯🥛
🫗🍼🫖☕️🍵🧃🥤🧋🍶🍺
🍻🥂🍷🥃🍸🧉🍹🍾🧊🥄
🍴🍽🥣🥡🥢🧂
"""
        case .activities: return """
⚽️🏀🏈⚾️🥎🎾🏐🏉🥏🎱
🪀🏓🏸🏒🏑🥍🏏🪃🥅⛳️
🪁🛝🏹🎣🤿🥊🥋🎽🛹🛼
🛷⛸🥌🎿⛷🏂🪂🏋️‍♀️🏋️🏋️‍♂️
🤼‍♀️🤼🤼‍♂️🤸‍♀️🤸🤸‍♂️⛹️‍♀️⛹️⛹️‍♂️🤺
🤾‍♀️🤾🤾‍♂️🏌️‍♀️🏌️🏌️‍♂️🏇🧘‍♀️🧘🧘‍♂️
🏄‍♀️🏄🏄‍♂️🏊‍♀️🏊🏊‍♂️🤽‍♀️🤽🤽‍♂️🚣‍♀️
🚣🚣‍♂️🧗‍♀️🧗🏻🧗‍♂️🚵‍♀️🚵🚵‍♂️🚴‍♀️🚴
🚴‍♂️🏆🥇🥈🥉🏅🎖🏵🎗🎫
🎟🎪🤹‍♀️🤹🤹‍♂️🎭🩰🎨🎬🎤
🎧🎼🎹🥁🪘🎷🎺🪗🎸🪕
🎻🎲♟🎯🎳🎮🎰🧩
"""
        case .travels: return """
🚗🚕🚙🚌🚎🏎🚓🚑🚒🚐
🛻🚚🚛🚜🦯🦽🦼🩼🛴🚲
🛵🏍🛺🛞🚨🚔🚍🚘🚖🚡
🚠🚟🚃🚋🚞🚝🚄🚅🚈🚂
🚆🚇🚊🚉✈️🛫🛬🛩💺🛰
🚀🛸🚁🛶⛵️🚤🛥🛳⛴🚢
🛟⚓️🪝⛽️🚧🚦🚥🚏🗺🗿
🗽🗼🏰🏯🏟🎡🎢🎠⛲️⛱
🏖🏝🏜🌋⛰🏔🗻🏕⛺️🛖
🏠🏡🏘🏚🏗🏭🏢🏬🏣🏤
🏥🏦🏨🏪🏫🏩💒🏛⛪️🕌
🕍🛕🕋⛩🛤🛣🗾🎑🏞🌅
🌄🌠🎇🎆🌇🌆🏙🌃🌌🌉
🌁
"""
        case .objects: return """
⌚️📱📲💻⌨️🖥🖨🖱🖲🕹
🗜💽💾💿📀📼📷📸📹🎥
📽🎞📞☎️📟📠📺📻🎙🎚
🎛🧭⏱⏲⏰🕰⌛️⏳📡🔋
🔌💡🔦🕯🪔🧯🗑🛢💸💵
💴💶💷🪙💰💳🪪💎⚖️🪜
🧰🪛🔧🔨⚒🛠⛏🪚🔩⚙️
🪤🧱⛓🧲🔫💣🧨🪓🔪🗡
⚔️🛡🚬⚰️🪦⚱️🏺🔮📿🧿
🪬💈⚗️🔭🔬🕳🩻🩹🩺💊
💉🩸🧬🦠🧫🧪🌡🧹🪠🧺
🧻🚽🚰🚿🛁🛀🧼🪥🪒🧽
🪣🧴🛎🔑🗝🚪🪑🛋🛏🛌
🧸🪆🖼🪞🪟🛍🛒🎁🎈🎏
🎀🪄🪅🎊🎉🎎🏮🎐🪩🧧
✉️📩📨📧💌📥📤📦🏷🪧
📪📫📬📭📮📯📜📃📄📑
🧾📊📈📉🗒🗓📆📅🗑📇
🗃🗳🗄📋📁📂🗂🗞📰📓
📔📒📕📗📘📙📚📖🔖🧷
🔗📎🖇📐📏🧮📌📍✂️🖊
🖋✒️🖌🖍📝✏️🔍🔎🔏🔐
🔒🔓
"""
        case .symbols: return """
❤️🧡💛💚💙💜🖤🤍🤎💔
❤️‍🔥❤️‍🩹❣️💕💞💓💗💖💘💝
💟☮️✝️☪️🕉☸️✡️🔯🕎☯️
☦️🛐⛎♈️♉️♊️♋️♌️♍️♎️
♏️♐️♑️♒️♓️🆔⚛️🉑☢️☣️
📴📳🈶🈚️🈸🈺🈷️✴️🆚💮
🉐㊙️㊗️🈴🈵🈹🈲🅰️🅱️🆎
🆑🅾️🆘❌⭕️🛑⛔️📛🚫💯
💢♨️🚷🚯🚳🚱🔞📵🚭❗️
❕❓❔‼️⁉️🔅🔆〽️⚠️🚸
🔱⚜️🔰♻️✅🈯️💹❇️✳️❎
🌐💠Ⓜ️🌀💤🏧🚾♿️🅿️🛗
🈳🈂️🛂🛃🛄🛅🚹🚺🚼⚧
🚻🚮🎦📶🈁🔣ℹ️🔤🔡🔠
🆖🆗🆙🆒🆕🆓0️⃣1️⃣2️⃣3️⃣
4️⃣5️⃣6️⃣7️⃣8️⃣9️⃣🔟🔢#️⃣*️⃣
⏏️▶️⏸⏯⏹⏺⏭⏮⏩⏪
⏫⏬◀️🔼🔽➡️⬅️⬆️⬇️↗️
↘️↙️↖️↕️↔️↪️↩️⤴️⤵️🔀
🔁🔂🔄🔃🎵🎶➕➖➗✖️
🟰♾️💲💱™️©️®️👁‍🗨🔚🔙
🔛🔝🔜〰️➰➿✔️☑️🔘🔴
🟠🟡🟢🔵🟣⚫️⚪️🟤🔺🔻
🔸🔹🔶🔷🔳🔲▪️▫️◾️◽️
◼️◻️🟥🟧🟨🟩🟦🟪⬛️⬜️
🟫🔈🔇🔉🔊🔔🔕📣📢💬
💭🗯♠️♣️♥️♦️🃏🎴🀄️🕐
🕑🕒🕓🕔🕕🕖🕗🕘🕙🕚
🕛🕜🕝🕞🕟🕠🕡🕢🕣🕤
🕥🕦🕧
"""
        case .flags: return """
🏳️🏴🏴‍☠️🏁🚩🏳️‍🌈🏳️‍⚧️🇺🇳🇦🇫🇦🇱
🇩🇿🇻🇮🇦🇸🇦🇩🇦🇴🇦🇮🇦🇶🇦🇬🇦🇷🇦🇲
🇦🇼🇦🇺🇦🇿🇧🇸🇧🇭🇧🇩🇧🇧🇧🇪🇧🇿🇧🇯
🇧🇲🇧🇹🇧🇴🇧🇦🇧🇼🇧🇷🇻🇬🇧🇳🇧🇬🇧🇫
🇧🇮🇰🇾🇨🇫🇮🇴🇨🇱🇨🇴🇨🇰🇨🇷🇨🇼🇨🇾
🇨🇮🇩🇰🇩🇯🇩🇲🇩🇴🇪🇨🇪🇬🇬🇶🇸🇻🇪🇷
🇪🇪🇪🇹🇪🇺🇫🇰🇫🇯🇵🇭🇫🇮🇫🇷🇬🇫🇵🇫
🇹🇫🇫🇴🇦🇪🇬🇦🇬🇲🇬🇪🇬🇭🇬🇮🇬🇷🇬🇩
🇬🇱🇬🇵🇬🇺🇬🇹🇬🇬🇬🇳🇬🇼🇬🇾🇭🇹🇭🇳
🇭🇰🇮🇳🇮🇩🇮🇶🇮🇷🇮🇪🇮🇸🇮🇲🇮🇱🇮🇹
🇯🇲🇯🇵🎌🇾🇪🇯🇪🇯🇴🇨🇽🇰🇭🇨🇲🇨🇦
🇮🇨🇨🇻🇧🇶🇰🇿🇰🇪🇨🇳🇰🇬🇰🇮🇨🇨🇰🇲
🇨🇬🇨🇩🇽🇰🇭🇷🇨🇺🇰🇼🇱🇦🇱🇸🇱🇻🇱🇧
🇱🇷🇱🇾🇱🇮🇱🇹🇱🇺🇲🇴🇲🇬🇲🇼🇲🇾🇲🇻
🇲🇱🇲🇹🇲🇦🇲🇭🇲🇶🇲🇷🇲🇺🇾🇹🇲🇽🇫🇲
🇲🇿🇲🇩🇲🇨🇲🇳🇲🇪🇲🇸🇲🇲🇳🇦🇳🇷🇳🇱
🇳🇵🇳🇮🇳🇪🇳🇬🇳🇺🇰🇵🇲🇰🇲🇵🇳🇫🇳🇴
🇳🇨🇳🇿🇴🇲🇵🇰🇵🇼🇵🇸🇵🇦🇵🇬🇵🇾🇵🇪
🇵🇳🇵🇱🇵🇹🇵🇷🇶🇦🇷🇪🇷🇴🇷🇼🇷🇺🇧🇱
🇸🇭🇰🇳🇱🇨🇵🇲🇻🇨🇸🇧🇼🇸🇸🇲🇸🇹🇸🇦
🇨🇭🇸🇳🇷🇸🇸🇨🇸🇱🇸🇬🇸🇽🇸🇰🇸🇮🇸🇴
🇪🇸🇱🇰🇬🇧🏴󠁧󠁢󠁥󠁮󠁧󠁿🏴󠁧󠁢󠁳󠁣󠁴󠁿🏴󠁧󠁢󠁷󠁬󠁳󠁿🇸🇩🇸🇷🇸🇪🇸🇿
🇿🇦🇬🇸🇰🇷🇸🇸🇸🇾🇹🇯🇹🇼🇹🇿🇹🇩🇹🇭
🇨🇿🇹🇬🇹🇰🇹🇴🇹🇹🇹🇳🇹🇷🇹🇲🇹🇨🇹🇻
🇩🇪🇺🇬🇺🇦🇭🇺🇺🇾🇺🇸🇺🇿🇻🇺🇻🇦🇻🇪
🇻🇳🇧🇾🇪🇭🇼🇫🇿🇲🇿🇼🇦🇽🇦🇹🇹🇱
"""
        }
    }
    
    /**
     The fallback emoji string that can be used by the emoji
     category if the app doesn't provide a custom image.
     */
    var fallbackDisplayEmoji: Emoji {
        switch self {
        case .smileys: return Emoji("😀")
        case .animals: return Emoji("🐻")
        case .foods: return Emoji("🍔")
        case .activities: return Emoji("⚽️")
        case .travels: return Emoji("🚗")
        case .objects: return Emoji("💡")
        case .symbols: return Emoji("💱")
        case .flags: return Emoji("🏳️")
        }
    }
    
    /**
     The English title for the category. You can use this if
     your extension only supports English.
     */
    var title: String {
        switch self {
        case .smileys: return "Smileys & People"
        case .animals: return "Animals & Nature"
        case .foods: return "Food & Drink"
        case .activities: return "Activity"
        case .travels: return "Travel & Places"
        case .objects: return "Objects"
        case .symbols: return "Symbols"
        case .flags: return "Flags"
        }
    }
}

/**
 This struct is just a wrapper around a single character. It
 can be used to get a little bit of type safety, and to work
 more structured with emojis.
 */
public struct Emoji: Equatable, Codable, Identifiable {
    
    /**
     Create an emoji instance, using a certain emoji `char`.
     */
    public init(_ char: String) {
        self.char = char
    }
   
    /**
     The character that can be used to display the emoji.
     */
    public let char: String
}

public extension Emoji {

    /**
     Get all emojis from all categories.
     */
    static var all: [Emoji] {
        EmojiCategory.all.flatMap { $0.emojis }
    }
}

public extension Emoji {
    
    /**
     The emoji's unique identifier.
     */
    var id: String { char }

    /**
     The emoji's unique unicode identifier.
     */
    var unicodeIdentifier: String? {
        char.applyingTransform(.toUnicodeName, reverse: false)
    }
}
