-- FNV Dialogs: localization + game language detection
FNV_LANG = FNV_LANG or {}
local L = {}
FNV_LANG.L = L

L.english = {
    hello = "Hello, wanderer. What brings you here?",
    pass = "Just passing through.",
    fine = "How are you?",
    nojob = "Got any work for me?",
    bye = "Goodbye.",
    safe = "Safe travels, then.",
    good = "Doing well, thanks. And you?",
    later = "Nothing right now. Come back later.",
    threat = "You're not welcome here. Turn around.",
    leave = "I don't want any trouble.",
    surrender = "Surrender!",
    regret = "You'll regret this.",
    out = "Then get out of here.",
    never = "Never!",
    asked = "You asked for it!",
    hint = "[E] Talk",
    controls = "W/S - select    E - answer    ESC - leave",
    dialog = "DIALOG",
    friendly_name = "Wanderer",
    enemy_name = "Raider",
}

L.russian = {
    hello = "Здравствуй, странник. Что привело тебя сюда?",
    pass = "Просто прохожу мимо.",
    fine = "Как у тебя дела?",
    nojob = "Есть для меня работа?",
    bye = "До свидания.",
    safe = "Тогда доброго пути.",
    good = "Всё хорошо, спасибо. А у тебя?",
    later = "Сейчас работы нет. Заходи позже.",
    threat = "Тебе здесь не место. Разворачивайся.",
    leave = "Я не хочу проблем.",
    surrender = "Сдавайся!",
    regret = "Ты об этом пожалеешь.",
    out = "Тогда убирайся отсюда.",
    never = "Никогда!",
    asked = "Сам напросился!",
    hint = "[E] Поговорить",
    controls = "W/S - выбор    E - ответ    ESC - выйти",
    dialog = "ДИАЛОГ",
    friendly_name = "Странник",
    enemy_name = "Рейдер",
}

L.german = {
    hello = "Hallo, Wanderer. Was führt dich hierher?",
    pass = "Ich bin nur auf der Durchreise.",
    fine = "Wie geht es dir?",
    nojob = "Hast du Arbeit für mich?",
    bye = "Auf Wiedersehen.",
    safe = "Dann gute Reise.",
    good = "Gut, danke. Und dir?",
    later = "Im Moment gibt es nichts. Komm später wieder.",
    threat = "Du bist hier nicht willkommen. Dreh um.",
    leave = "Ich will keinen Ärger.",
    surrender = "Ergib dich!",
    regret = "Das wirst du bereuen.",
    out = "Dann verschwinde von hier.",
    never = "Niemals!",
    asked = "Das hast du dir selbst zuzuschreiben!",
    hint = "[E] Sprechen",
    controls = "W/S - Auswahl    E - Antwort    ESC - verlassen",
    dialog = "GESPRÄCH",
    friendly_name = "Wanderer",
    enemy_name = "Räuber",
}

L.french = {
    hello = "Bonjour, voyageur. Qu'est-ce qui t'amène ici ?",
    pass = "Je ne fais que passer.",
    fine = "Comment vas-tu ?",
    nojob = "Tu as du travail pour moi ?",
    bye = "Au revoir.",
    safe = "Bonne route, alors.",
    good = "Bien, merci. Et toi ?",
    later = "Rien pour le moment. Reviens plus tard.",
    threat = "Tu n'es pas le bienvenu ici. Fais demi-tour.",
    leave = "Je ne veux pas d'ennuis.",
    surrender = "Rends-toi !",
    regret = "Tu vas le regretter.",
    out = "Alors dégage d'ici.",
    never = "Jamais !",
    asked = "Tu l'as bien cherché !",
    hint = "[E] Parler",
    controls = "W/S - choisir    E - répondre    Échap - sortir",
    dialog = "DIALOGUE",
    friendly_name = "Voyageur",
    enemy_name = "Pillard",
}

L.spanish = {
    hello = "Hola, viajero. ¿Qué te trae por aquí?",
    pass = "Solo estoy de paso.",
    fine = "¿Cómo estás?",
    nojob = "¿Tienes trabajo para mí?",
    bye = "Adiós.",
    safe = "Buen viaje, entonces.",
    good = "Bien, gracias. ¿Y tú?",
    later = "Ahora no hay nada. Vuelve más tarde.",
    threat = "Aquí no eres bienvenido. Da media vuelta.",
    leave = "No quiero problemas.",
    surrender = "¡Ríndete!",
    regret = "Te vas a arrepentir.",
    out = "Entonces largo de aquí.",
    never = "¡Jamás!",
    asked = "¡Te lo has buscado!",
    hint = "[E] Hablar",
    controls = "W/S - elegir    E - responder    ESC - salir",
    dialog = "DIÁLOGO",
    friendly_name = "Viajero",
    enemy_name = "Saqueador",
}

L.italian = {
    hello = "Ciao, viandante. Cosa ti porta qui?",
    pass = "Sto solo passando.",
    fine = "Come stai?",
    nojob = "Hai un lavoro per me?",
    bye = "Arrivederci.",
    safe = "Buon viaggio, allora.",
    good = "Bene, grazie. E tu?",
    later = "Niente per ora. Torna più tardi.",
    threat = "Qui non sei il benvenuto. Girati e vattene.",
    leave = "Non voglio guai.",
    surrender = "Arrenditi!",
    regret = "Te ne pentirai.",
    out = "Allora levati di qui.",
    never = "Mai!",
    asked = "Te la sei cercata!",
    hint = "[E] Parlare",
    controls = "W/S - scegli    E - rispondi    ESC - esci",
    dialog = "DIALOGO",
    friendly_name = "Viandante",
    enemy_name = "Predone",
}

L.polish = {
    hello = "Witaj, wędrowcze. Co cię tu sprowadza?",
    pass = "Jestem tylko przejazdem.",
    fine = "Jak się masz?",
    nojob = "Masz dla mnie jakąś robotę?",
    bye = "Do widzenia.",
    safe = "Więc szerokiej drogi.",
    good = "Dobrze, dziękuję. A ty?",
    later = "Na razie nic. Wróć później.",
    threat = "Nie jesteś tu mile widziany. Zawracaj.",
    leave = "Nie chcę kłopotów.",
    surrender = "Poddaj się!",
    regret = "Pożałujesz tego.",
    out = "To wynocha stąd.",
    never = "Nigdy!",
    asked = "Sam się o to prosiłeś!",
    hint = "[E] Rozmawiaj",
    controls = "W/S - wybór    E - odpowiedź    ESC - wyjście",
    dialog = "ROZMOWA",
    friendly_name = "Wędrowiec",
    enemy_name = "Zbir",
}

L.ukrainian = {
    hello = "Вітаю, мандрівнику. Що привело тебе сюди?",
    pass = "Я просто проходжу повз.",
    fine = "Як у тебе справи?",
    nojob = "Є для мене робота?",
    bye = "До побачення.",
    safe = "Тоді щасливої дороги.",
    good = "Усе добре, дякую. А в тебе?",
    later = "Зараз роботи немає. Заходь пізніше.",
    threat = "Тобі тут не місце. Розвертайся.",
    leave = "Я не хочу проблем.",
    surrender = "Здавайся!",
    regret = "Ти про це пошкодуєш.",
    out = "Тоді забирайся звідси.",
    never = "Ніколи!",
    asked = "Сам напросився!",
    hint = "[E] Поговорити",
    controls = "W/S - вибір    E - відповідь    ESC - вийти",
    dialog = "ДІАЛОГ",
    friendly_name = "Мандрівник",
    enemy_name = "Рейдер",
}

L.chinese = {
    hello = "你好，旅人。什么风把你吹来了？",
    pass = "我只是路过。",
    fine = "你好吗？",
    nojob = "有活给我干吗？",
    bye = "再见。",
    safe = "那就一路顺风。",
    good = "很好，谢谢。你呢？",
    later = "现在没什么活。以后再来吧。",
    threat = "这里不欢迎你。转身离开。",
    leave = "我不想惹麻烦。",
    surrender = "投降吧！",
    regret = "你会后悔的。",
    out = "那就滚出去。",
    never = "绝不！",
    asked = "这是你自找的！",
    hint = "[E] 交谈",
    controls = "W/S - 选择    E - 回答    ESC - 离开",
    dialog = "对话",
    friendly_name = "旅人",
    enemy_name = "掠夺者",
}

L.japanese = {
    hello = "こんにちは、旅人。ここへ何の用ですか？",
    pass = "通りがかっただけです。",
    fine = "お元気ですか？",
    nojob = "何か仕事はありますか？",
    bye = "さようなら。",
    safe = "では、道中お気をつけて。",
    good = "元気です、ありがとう。そちらは？",
    later = "今は何もありません。また後で来てください。",
    threat = "ここはお前の来る場所じゃない。引き返せ。",
    leave = "面倒はごめんです。",
    surrender = "降伏しろ！",
    regret = "後悔するぞ。",
    out = "なら、出て行け。",
    never = "断る！",
    asked = "自業自得だ！",
    hint = "[E] 話す",
    controls = "W/S - 選択    E - 回答    ESC - 終了",
    dialog = "会話",
    friendly_name = "旅人",
    enemy_name = "略奪者",
}

local ALIASES = {
    en = "english", eng = "english", english = "english",
    ru = "russian", rus = "russian", russian = "russian",
    de = "german", ger = "german", german = "german", deutsch = "german",
    fr = "french", fre = "french", french = "french", franais = "french",
    es = "spanish", spa = "spanish", spanish = "spanish", espaol = "spanish",
    it = "italian", ita = "italian", italian = "italian", italiano = "italian",
    pl = "polish", pol = "polish", polish = "polish", polski = "polish",
    uk = "ukrainian", ukr = "ukrainian", ukrainian = "ukrainian", ukrainski = "ukrainian",
    zh = "chinese", chi = "chinese", chinese = "chinese", zhongwen = "chinese",
    ja = "japanese", jpn = "japanese", japanese = "japanese", nihongo = "japanese",
}

function FNV_LANG.Detect()
    local raw = ""
    if CLIENT and GetConVar then
        local cv = GetConVar("gmod_language")
        if cv then raw = cv:GetString() end
    end
    raw = tostring(raw or ""):lower():gsub("[^%a]", "")
    return ALIASES[raw] or ALIASES[raw:sub(1, 2)] or "english"
end

function FNV_LANG.Get(lang, key)
    local tab = L[lang] or L.english
    return tab[key] or L.english[key] or key
end
