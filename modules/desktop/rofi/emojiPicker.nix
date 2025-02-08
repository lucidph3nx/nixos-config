{
  config,
  lib,
  ...
}:
with config.theme; {
  config = lib.mkIf config.nx.desktop.rofi.enable {
    home-manager.users.ben.home = {
      file.".local/scripts/application.rofi.emojipicker" = {
        executable = true;
        text =
          /*
          bash
          */
          ''
            #!/bin/sh
            if [ "$XDG_SESSION_DESKTOP" = sway ]; then
              monitor="$(swaymsg -t get_outputs | jq -c '.[] | select(.focused) | select(.id)' | jq -c '.name')"
            elif [ "$XDG_SESSION_DESKTOP" = Hyprland ]; then
              monitor="$(hyprctl -j monitors | jq -c '.[] | select(.focused == true)' | jq -r '.name')"
            else
              monitor="DP-3"
            fi

            # rofi style
            rofi_style_emojipicker='inputbar { children: [entry]; border-color: ${blue};} entry { placeholder: "Select Emoji"; } element-icon { enabled: false; }'

            # emoji list with a bunch of things taken out to make it more manageable
            custom_emoji_list="/home/ben/.config/rofi-emoji/custom_emoji_list.txt"

            # start rofi with emoji args
            rofi -monitor "$monitor" -show emoji -emoji-file "$custom_emoji_list" -theme-str "$rofi_style_emojipicker"
          '';
      };
      # a custom emoji list for rofi-emoji
      file.".config/rofi-emoji/custom_emoji_list.txt" = {
        text = ''
          😀	Smileys & Emotion	face-smiling	grinning face	face | grin | grinning face
          😃	Smileys & Emotion	face-smiling	grinning face with big eyes	face | grinning face with big eyes | mouth | open | smile
          😄	Smileys & Emotion	face-smiling	grinning face with smiling eyes	eye | face | grinning face with smiling eyes | mouth | open | smile
          😁	Smileys & Emotion	face-smiling	beaming face with smiling eyes	beaming face with smiling eyes | eye | face | grin | smile
          😆	Smileys & Emotion	face-smiling	grinning squinting face	face | grinning squinting face | laugh | mouth | satisfied | smile
          😅	Smileys & Emotion	face-smiling	grinning face with sweat	cold | face | grinning face with sweat | open | smile | sweat
          🤣	Smileys & Emotion	face-smiling	rolling on the floor laughing	face | floor | laugh | rofl | rolling | rolling on the floor laughing | rotfl
          😂	Smileys & Emotion	face-smiling	face with tears of joy	face | face with tears of joy | joy | laugh | tear
          🙂	Smileys & Emotion	face-smiling	slightly smiling face	face | slightly smiling face | smile
          🙃	Smileys & Emotion	face-smiling	upside-down face	face | upside-down | upside down | upside-down face
          🫠	Smileys & Emotion	face-smiling	melting face	disappear | dissolve | liquid | melt | melting face
          😉	Smileys & Emotion	face-smiling	winking face	face | wink | winking face
          😊	Smileys & Emotion	face-smiling	smiling face with smiling eyes	blush | eye | face | smile | smiling face with smiling eyes
          😇	Smileys & Emotion	face-smiling	smiling face with halo	angel | face | fantasy | halo | innocent | smiling face with halo
          🥰	Smileys & Emotion	face-affection	smiling face with hearts	adore | crush | hearts | in love | smiling face with hearts
          😍	Smileys & Emotion	face-affection	smiling face with heart-eyes	eye | face | love | smile | smiling face with heart-eyes | smiling face with heart eyes
          🤩	Smileys & Emotion	face-affection	star-struck	eyes | face | grinning | star | star-struck
          😘	Smileys & Emotion	face-affection	face blowing a kiss	face | face blowing a kiss | kiss
          😗	Smileys & Emotion	face-affection	kissing face	face | kiss | kissing face
          ☺️	Smileys & Emotion	face-affection	smiling face
          ☺	Smileys & Emotion	face-affection	smiling face	face | outlined | relaxed | smile | smiling face
          😚	Smileys & Emotion	face-affection	kissing face with closed eyes	closed | eye | face | kiss | kissing face with closed eyes
          😙	Smileys & Emotion	face-affection	kissing face with smiling eyes	eye | face | kiss | kissing face with smiling eyes | smile
          🥲	Smileys & Emotion	face-affection	smiling face with tear	grateful | proud | relieved | smiling | smiling face with tear | tear | touched
          😋	Smileys & Emotion	face-tongue	face savoring food	delicious | face | face savoring food | savouring | smile | yum | face savouring food | savoring
          😛	Smileys & Emotion	face-tongue	face with tongue	face | face with tongue | tongue
          😜	Smileys & Emotion	face-tongue	winking face with tongue	eye | face | joke | tongue | wink | winking face with tongue
          🤪	Smileys & Emotion	face-tongue	zany face	eye | goofy | large | small | zany face
          😝	Smileys & Emotion	face-tongue	squinting face with tongue	eye | face | horrible | squinting face with tongue | taste | tongue
          🤑	Smileys & Emotion	face-tongue	money-mouth face	face | money | money-mouth face | mouth
          🤗	Smileys & Emotion	face-hand	smiling face with open hands	face | hug | hugging | open hands | smiling face | smiling face with open hands
          🤭	Smileys & Emotion	face-hand	face with hand over mouth	face with hand over mouth | whoops | embarrassed | oops
          🫣	Smileys & Emotion	face-hand	face with peeking eye	captivated | face with peeking eye | peep | stare
          🤫	Smileys & Emotion	face-hand	shushing face	quiet | shush | shushing face | shooshing face
          🤔	Smileys & Emotion	face-hand	thinking face	face | thinking
          🫡	Smileys & Emotion	face-hand	saluting face	OK | salute | saluting face | sunny | troops | yes
          🤐	Smileys & Emotion	face-neutral-skeptical	zipper-mouth face	face | mouth | zipper | zipper-mouth face
          🤨	Smileys & Emotion	face-neutral-skeptical	face with raised eyebrow	distrust | face with raised eyebrow | skeptic
          😐	Smileys & Emotion	face-neutral-skeptical	neutral face	deadpan | face | meh | neutral
          😑	Smileys & Emotion	face-neutral-skeptical	expressionless face	expressionless | face | inexpressive | meh | unexpressive
          😶	Smileys & Emotion	face-neutral-skeptical	face without mouth	face | face without mouth | mouth | quiet | silent
          🫥	Smileys & Emotion	face-neutral-skeptical	dotted line face	depressed | disappear | dotted line face | hide | introvert | invisible | dotted-line face
          😶‍🌫️	Smileys & Emotion	face-neutral-skeptical	face in clouds
          😶‍🌫	Smileys & Emotion	face-neutral-skeptical	face in clouds	absentminded | face in clouds | face in the fog | head in clouds | absent-minded
          😏	Smileys & Emotion	face-neutral-skeptical	smirking face	face | smirk | smirking face
          😒	Smileys & Emotion	face-neutral-skeptical	unamused face	face | unamused | unhappy
          🙄	Smileys & Emotion	face-neutral-skeptical	face with rolling eyes	eyeroll | eyes | face | face with rolling eyes | rolling
          😬	Smileys & Emotion	face-neutral-skeptical	grimacing face	face | grimace | grimacing face
          😮‍💨	Smileys & Emotion	face-neutral-skeptical	face exhaling	exhale | face exhaling | gasp | groan | relief | whisper | whistle
          🤥	Smileys & Emotion	face-neutral-skeptical	lying face	face | lie | lying face | pinocchio | Pinocchio
          🫨	Smileys & Emotion	face-neutral-skeptical	shaking face	earthquake | face | shaking | shock | vibrate
          😌	Smileys & Emotion	face-sleepy	relieved face	face | relieved
          😔	Smileys & Emotion	face-sleepy	pensive face	dejected | face | pensive
          😪	Smileys & Emotion	face-sleepy	sleepy face	face | good night | sleep | sleepy face
          🤤	Smileys & Emotion	face-sleepy	drooling face	drooling | face
          😴	Smileys & Emotion	face-sleepy	sleeping face	face | good night | sleep | sleeping face | ZZZ
          😷	Smileys & Emotion	face-unwell	face with medical mask	cold | doctor | face | face with medical mask | mask | sick | ill | medicine | poorly
          🤒	Smileys & Emotion	face-unwell	face with thermometer	face | face with thermometer | ill | sick | thermometer
          🤕	Smileys & Emotion	face-unwell	face with head-bandage	bandage | face | face with head-bandage | hurt | injury | face with head bandage
          🤢	Smileys & Emotion	face-unwell	nauseated face	face | nauseated | vomit
          🤮	Smileys & Emotion	face-unwell	face vomiting	face vomiting | puke | sick | vomit
          🤧	Smileys & Emotion	face-unwell	sneezing face	face | gesundheit | sneeze | sneezing face | bless you
          🥵	Smileys & Emotion	face-unwell	hot face	feverish | heat stroke | hot | hot face | red-faced | sweating | flushed
          🥶	Smileys & Emotion	face-unwell	cold face	blue-faced | cold | cold face | freezing | frostbite | icicles
          🥴	Smileys & Emotion	face-unwell	woozy face	dizzy | intoxicated | tipsy | uneven eyes | wavy mouth | woozy face
          😵	Smileys & Emotion	face-unwell	face with crossed-out eyes	crossed-out eyes | dead | face | face with crossed-out eyes | knocked out
          😵‍💫	Smileys & Emotion	face-unwell	face with spiral eyes	dizzy | face with spiral eyes | hypnotized | spiral | trouble | whoa | hypnotised
          🤯	Smileys & Emotion	face-unwell	exploding head	exploding head | mind blown | shocked
          🤠	Smileys & Emotion	face-hat	cowboy hat face	cowboy | cowgirl | face | hat | cowboy-hat face
          🥳	Smileys & Emotion	face-hat	partying face	celebration | hat | horn | party | partying face
          🥸	Smileys & Emotion	face-hat	disguised face	disguise | disguised face | face | glasses | incognito | nose
          😎	Smileys & Emotion	face-glasses	smiling face with sunglasses	bright | cool | face | smiling face with sunglasses | sun | sunglasses
          🤓	Smileys & Emotion	face-glasses	nerd face	face | geek | nerd
          🧐	Smileys & Emotion	face-glasses	face with monocle	face | face with monocle | monocle | stuffy
          😕	Smileys & Emotion	face-concerned	confused face	confused | face | meh
          🫤	Smileys & Emotion	face-concerned	face with diagonal mouth	disappointed | face with diagonal mouth | meh | skeptical | unsure | sceptical
          😟	Smileys & Emotion	face-concerned	worried face	face | worried
          🙁	Smileys & Emotion	face-concerned	slightly frowning face	face | frown | slightly frowning face
          ☹️	Smileys & Emotion	face-concerned	frowning face
          ☹	Smileys & Emotion	face-concerned	frowning face	face | frown | frowning face
          😮	Smileys & Emotion	face-concerned	face with open mouth	face | face with open mouth | mouth | open | sympathy
          😯	Smileys & Emotion	face-concerned	hushed face	face | hushed | stunned | surprised
          😲	Smileys & Emotion	face-concerned	astonished face	astonished | face | shocked | totally
          😳	Smileys & Emotion	face-concerned	flushed face	dazed | face | flushed
          🥺	Smileys & Emotion	face-concerned	pleading face	begging | mercy | pleading face | puppy eyes
          🥹	Smileys & Emotion	face-concerned	face holding back tears	angry | cry | face holding back tears | proud | resist | sad
          😦	Smileys & Emotion	face-concerned	frowning face with open mouth	face | frown | frowning face with open mouth | mouth | open
          😧	Smileys & Emotion	face-concerned	anguished face	anguished | face
          😨	Smileys & Emotion	face-concerned	fearful face	face | fear | fearful | scared
          😰	Smileys & Emotion	face-concerned	anxious face with sweat	anxious face with sweat | blue | cold | face | rushed | sweat
          😥	Smileys & Emotion	face-concerned	sad but relieved face	disappointed | face | relieved | sad but relieved face | whew
          😢	Smileys & Emotion	face-concerned	crying face	cry | crying face | face | sad | tear
          😭	Smileys & Emotion	face-concerned	loudly crying face	cry | face | loudly crying face | sad | sob | tear
          😱	Smileys & Emotion	face-concerned	face screaming in fear	face | face screaming in fear | fear | munch | scared | scream | Munch
          😖	Smileys & Emotion	face-concerned	confounded face	confounded | face
          😣	Smileys & Emotion	face-concerned	persevering face	face | persevere | persevering face
          😞	Smileys & Emotion	face-concerned	disappointed face	disappointed | face
          😓	Smileys & Emotion	face-concerned	downcast face with sweat	cold | downcast face with sweat | face | sweat
          😩	Smileys & Emotion	face-concerned	weary face	face | tired | weary
          😫	Smileys & Emotion	face-concerned	tired face	face | tired
          🥱	Smileys & Emotion	face-concerned	yawning face	bored | tired | yawn | yawning face
          😤	Smileys & Emotion	face-negative	face with steam from nose	face | face with steam from nose | triumph | won | angry | frustration
          😡	Smileys & Emotion	face-negative	enraged face	angry | enraged | face | mad | pouting | rage | red
          😠	Smileys & Emotion	face-negative	angry face	anger | angry | face | mad
          🤬	Smileys & Emotion	face-negative	face with symbols on mouth	face with symbols on mouth | swearing
          😈	Smileys & Emotion	face-negative	smiling face with horns	face | fairy tale | fantasy | horns | smile | smiling face with horns | devil
          👿	Smileys & Emotion	face-negative	angry face with horns	angry face with horns | demon | devil | face | fantasy | imp
          💀	Smileys & Emotion	face-negative	skull	death | face | fairy tale | monster | skull
          ☠️	Smileys & Emotion	face-negative	skull and crossbones
          ☠	Smileys & Emotion	face-negative	skull and crossbones	crossbones | death | face | monster | skull | skull and crossbones
          💩	Smileys & Emotion	face-costume	pile of poo	dung | face | monster | pile of poo | poo | poop
          🤡	Smileys & Emotion	face-costume	clown face	clown | face
          👹	Smileys & Emotion	face-costume	ogre	creature | face | fairy tale | fantasy | monster | ogre
          👺	Smileys & Emotion	face-costume	goblin	creature | face | fairy tale | fantasy | goblin | monster
          👻	Smileys & Emotion	face-costume	ghost	creature | face | fairy tale | fantasy | ghost | monster
          👽	Smileys & Emotion	face-costume	alien	alien | creature | extraterrestrial | face | fantasy | ufo | ET | UFO
          👾	Smileys & Emotion	face-costume	alien monster	alien | creature | extraterrestrial | face | monster | ufo | ET | UFO
          🤖	Smileys & Emotion	face-costume	robot	face | monster | robot
          😺	Smileys & Emotion	cat-face	grinning cat	cat | face | grinning | mouth | open | smile
          😸	Smileys & Emotion	cat-face	grinning cat with smiling eyes	cat | eye | face | grin | grinning cat with smiling eyes | smile
          😹	Smileys & Emotion	cat-face	cat with tears of joy	cat | cat with tears of joy | face | joy | tear
          😻	Smileys & Emotion	cat-face	smiling cat with heart-eyes	cat | eye | face | heart | love | smile | smiling cat with heart-eyes | smiling cat face with heart eyes
          😼	Smileys & Emotion	cat-face	cat with wry smile	cat | cat with wry smile | face | ironic | smile | wry
          😽	Smileys & Emotion	cat-face	kissing cat	cat | eye | face | kiss | kissing cat
          🙀	Smileys & Emotion	cat-face	weary cat	cat | face | oh | surprised | weary
          😿	Smileys & Emotion	cat-face	crying cat	cat | cry | crying cat | face | sad | tear
          😾	Smileys & Emotion	cat-face	pouting cat	cat | face | pouting
          🙈	Smileys & Emotion	monkey-face	see-no-evil monkey	evil | face | forbidden | monkey | see | see-no-evil monkey
          🙉	Smileys & Emotion	monkey-face	hear-no-evil monkey	evil | face | forbidden | hear | hear-no-evil monkey | monkey
          🙊	Smileys & Emotion	monkey-face	speak-no-evil monkey	evil | face | forbidden | monkey | speak | speak-no-evil monkey
          💌	Smileys & Emotion	heart	love letter	heart | letter | love | mail
          💘	Smileys & Emotion	heart	heart with arrow	arrow | cupid | heart with arrow
          💝	Smileys & Emotion	heart	heart with ribbon	heart with ribbon | ribbon | valentine
          💖	Smileys & Emotion	heart	sparkling heart	excited | sparkle | sparkling heart
          💗	Smileys & Emotion	heart	growing heart	excited | growing | growing heart | nervous | pulse
          💓	Smileys & Emotion	heart	beating heart	beating | beating heart | heartbeat | pulsating
          💞	Smileys & Emotion	heart	revolving hearts	revolving | revolving hearts
          💕	Smileys & Emotion	heart	two hearts	love | two hearts
          💟	Smileys & Emotion	heart	heart decoration	heart | heart decoration
          ❣️	Smileys & Emotion	heart	heart exclamation
          ❣	Smileys & Emotion	heart	heart exclamation	exclamation | heart exclamation | mark | punctuation
          💔	Smileys & Emotion	heart	broken heart	break | broken | broken heart
          ❤️‍🔥	Smileys & Emotion	heart	heart on fire
          ❤‍🔥	Smileys & Emotion	heart	heart on fire	burn | heart | heart on fire | love | lust | sacred heart
          ❤️	Smileys & Emotion	heart	red heart
          ❤	Smileys & Emotion	heart	red heart	heart | red heart
          🩷	Smileys & Emotion	heart	pink heart	cute | heart | like | love | pink
          🧡	Smileys & Emotion	heart	orange heart	orange | orange heart
          💛	Smileys & Emotion	heart	yellow heart	yellow | yellow heart
          💚	Smileys & Emotion	heart	green heart	green | green heart
          💙	Smileys & Emotion	heart	blue heart	blue | blue heart
          🩵	Smileys & Emotion	heart	light blue heart	cyan | heart | light blue | light blue heart | teal
          💜	Smileys & Emotion	heart	purple heart	purple | purple heart
          🤎	Smileys & Emotion	heart	brown heart	brown | heart
          🖤	Smileys & Emotion	heart	black heart	black | black heart | evil | wicked
          🩶	Smileys & Emotion	heart	grey heart	gray | grey heart | heart | silver | slate | grey
          🤍	Smileys & Emotion	heart	white heart	heart | white
          💋	Smileys & Emotion	emotion	kiss mark	kiss | kiss mark | lips
          💯	Smileys & Emotion	emotion	hundred points	100 | full | hundred | hundred points | score | hundred percent | one hundred
          💢	Smileys & Emotion	emotion	anger symbol	anger symbol | angry | comic | mad
          💥	Smileys & Emotion	emotion	collision	boom | collision | comic
          💫	Smileys & Emotion	emotion	dizzy	comic | dizzy | star
          💦	Smileys & Emotion	emotion	sweat droplets	comic | splashing | sweat | sweat droplets
          💨	Smileys & Emotion	emotion	dashing away	comic | dash | dashing away | running
          🕳️	Smileys & Emotion	emotion	hole
          🕳	Smileys & Emotion	emotion	hole	hole
          💬	Smileys & Emotion	emotion	speech balloon	balloon | bubble | comic | dialog | speech | dialogue
          👁️‍🗨️	Smileys & Emotion	emotion	eye in speech bubble
          👁‍🗨️	Smileys & Emotion	emotion	eye in speech bubble
          👁️‍🗨	Smileys & Emotion	emotion	eye in speech bubble
          👁‍🗨	Smileys & Emotion	emotion	eye in speech bubble	balloon | bubble | eye | eye in speech bubble | speech | witness
          🗨️	Smileys & Emotion	emotion	left speech bubble
          🗨	Smileys & Emotion	emotion	left speech bubble	balloon | bubble | dialog | left speech bubble | speech | dialogue
          🗯️	Smileys & Emotion	emotion	right anger bubble
          🗯	Smileys & Emotion	emotion	right anger bubble	angry | balloon | bubble | mad | right anger bubble
          💭	Smileys & Emotion	emotion	thought balloon	balloon | bubble | comic | thought
          💤	Smileys & Emotion	emotion	ZZZ	comic | good night | sleep | ZZZ
          👋	People & Body	hand-fingers-open	waving hand	hand | wave | waving
          🤚	People & Body	hand-fingers-open	raised back of hand	backhand | raised | raised back of hand
          🖐️	People & Body	hand-fingers-open	hand with fingers splayed
          🖐	People & Body	hand-fingers-open	hand with fingers splayed	finger | hand | hand with fingers splayed | splayed
          ✋	People & Body	hand-fingers-open	raised hand	hand | high 5 | high five | raised hand
          🖖	People & Body	hand-fingers-open	vulcan salute	finger | hand | spock | vulcan | vulcan salute | Vulcan salute | Spock | Vulcan
          🫱	People & Body	hand-fingers-open	rightwards hand	hand | right | rightward | rightwards hand | rightwards
          🫲	People & Body	hand-fingers-open	leftwards hand	hand | left | leftward | leftwards hand | leftwards
          🫳	People & Body	hand-fingers-open	palm down hand	dismiss | drop | palm down hand | shoo | palm-down hand
          🫴	People & Body	hand-fingers-open	palm up hand	beckon | catch | come | offer | palm up hand | palm-up hand
          🫷	People & Body	hand-fingers-open	leftwards pushing hand	high five | leftward | leftwards pushing hand | push | refuse | stop | wait | leftward pushing hand | leftward-pushing hand
          🫸	People & Body	hand-fingers-open	rightwards pushing hand	high five | push | refuse | rightward | rightwards pushing hand | stop | wait | rightward pushing hand | rightward-pushing hand
          👌	People & Body	hand-fingers-partial	OK hand	hand | OK | perfect
          🤌	People & Body	hand-fingers-partial	pinched fingers	fingers | hand gesture | interrogation | pinched | sarcastic
          🤏	People & Body	hand-fingers-partial	pinching hand	pinching hand | small amount
          ✌️	People & Body	hand-fingers-partial	victory hand
          🤞	People & Body	hand-fingers-partial	crossed fingers	cross | crossed fingers | finger | hand | luck | good luck
          🫰	People & Body	hand-fingers-partial	hand with index finger and thumb crossed	expensive | hand with index finger and thumb crossed | heart | love | money | snap
          🤟	People & Body	hand-fingers-partial	love-you gesture	hand | ILY | love-you gesture | love you gesture
          🤘	People & Body	hand-fingers-partial	sign of the horns	finger | hand | horns | rock-on | sign of the horns | rock on
          🤙	People & Body	hand-fingers-partial	call me hand	call | call me hand | hand | hang loose | Shaka | call-me hand | shaka
          👈	People & Body	hand-single-finger	backhand index pointing left	backhand | backhand index pointing left | finger | hand | index | point
          👉	People & Body	hand-single-finger	backhand index pointing right	backhand | backhand index pointing right | finger | hand | index | point
          👆	People & Body	hand-single-finger	backhand index pointing up	backhand | backhand index pointing up | finger | hand | point | up
          🖕	People & Body	hand-single-finger	middle finger	finger | hand | middle finger
          👇	People & Body	hand-single-finger	backhand index pointing down	backhand | backhand index pointing down | down | finger | hand | point
          ☝️	People & Body	hand-single-finger	index pointing up
          🫵	People & Body	hand-single-finger	index pointing at the viewer	index pointing at the viewer | point | you
          👍	People & Body	hand-fingers-closed	thumbs up	+1 | hand | thumb | thumbs up | up
          👎	People & Body	hand-fingers-closed	thumbs down	-1 | down | hand | thumb | thumbs down
          ✊	People & Body	hand-fingers-closed	raised fist	clenched | fist | hand | punch | raised fist
          👊	People & Body	hand-fingers-closed	oncoming fist	clenched | fist | hand | oncoming fist | punch
          🤛	People & Body	hand-fingers-closed	left-facing fist	fist | left-facing fist | leftwards | leftward
          🤜	People & Body	hand-fingers-closed	right-facing fist	fist | right-facing fist | rightwards | rightward
          👏	People & Body	hands	clapping hands	clap | clapping hands | hand
          🙌	People & Body	hands	raising hands	celebration | gesture | hand | hooray | raised | raising hands | woo hoo | yay
          🫶	People & Body	hands	heart hands	heart hands | love
          👐	People & Body	hands	open hands	hand | open | open hands
          🤲	People & Body	hands	palms up together	palms up together | prayer
          🙏	People & Body	hands	folded hands	ask | folded hands | hand | high 5 | high five | please | pray | thanks
          ✍️	People & Body	hand-prop	writing hand
          🤳	People & Body	hand-prop	selfie	camera | phone | selfie
          💪	People & Body	body-parts	flexed biceps	biceps | comic | flex | flexed biceps | muscle | flexed bicep
          🦾	People & Body	body-parts	mechanical arm	accessibility | mechanical arm | prosthetic
          🦿	People & Body	body-parts	mechanical leg	accessibility | mechanical leg | prosthetic
          🦵	People & Body	body-parts	leg	kick | leg | limb
          🦶	People & Body	body-parts	foot	foot | kick | stomp
          👂	People & Body	body-parts	ear	body | ear
          🦻	People & Body	body-parts	ear with hearing aid	accessibility | ear with hearing aid | hard of hearing | hearing impaired
          👃	People & Body	body-parts	nose	body | nose
          🧠	People & Body	body-parts	brain	brain | intelligent
          🫀	People & Body	body-parts	anatomical heart	anatomical | cardiology | heart | organ | pulse | anatomical heart
          🫁	People & Body	body-parts	lungs	breath | exhalation | inhalation | lungs | organ | respiration
          🦷	People & Body	body-parts	tooth	dentist | tooth
          🦴	People & Body	body-parts	bone	bone | skeleton
          👀	People & Body	body-parts	eyes	eye | eyes | face
          👁️	People & Body	body-parts	eye
          👁	People & Body	body-parts	eye	body | eye
          👅	People & Body	body-parts	tongue	body | tongue
          👄	People & Body	body-parts	mouth	lips | mouth
          🫦	People & Body	body-parts	biting lip	anxious | biting lip | fear | flirting | nervous | uncomfortable | worried
          👶	People & Body	person	baby	baby | young
          🧒	People & Body	person	child	child | gender-neutral | unspecified gender | young
          👦	People & Body	person	boy	boy | young | young person
          👧	People & Body	person	girl	girl | Virgo | young | zodiac | young person
          🧑	People & Body	person	person	adult | gender-neutral | person | unspecified gender
          👱	People & Body	person	person: blond hair	blond | blond-haired person | hair | person: blond hair
          🧔	People & Body	person	person: beard	beard | person | person: beard
          🧑‍🦰	People & Body	person	person: red hair	adult | gender-neutral | person | red hair | unspecified gender
          🧑‍🦱	People & Body	person	person: curly hair	adult | curly hair | gender-neutral | person | unspecified gender
          🧑‍🦳	People & Body	person	person: white hair	adult | gender-neutral | person | unspecified gender | white hair
          🧑‍🦲	People & Body	person	person: bald	adult | bald | gender-neutral | person | unspecified gender
          🧓	People & Body	person	older person	adult | gender-neutral | old | older person | unspecified gender
          🙍	People & Body	person-gesture	person frowning	frown | gesture | person frowning
          🙎	People & Body	person-gesture	person pouting	gesture | person pouting | pouting
          🙅	People & Body	person-gesture	person gesturing NO	forbidden | gesture | hand | person gesturing NO | prohibited
          🙆	People & Body	person-gesture	person gesturing OK	gesture | hand | OK | person gesturing OK
          💁	People & Body	person-gesture	person tipping hand	hand | help | information | person tipping hand | sassy | tipping
          🙋	People & Body	person-gesture	person raising hand	gesture | hand | happy | person raising hand | raised
          🧏	People & Body	person-gesture	deaf person	accessibility | deaf | deaf person | ear | hear | hearing impaired
          🙇	People & Body	person-gesture	person bowing	apology | bow | gesture | person bowing | sorry
          🤦	People & Body	person-gesture	person facepalming	disbelief | exasperation | face | palm | person facepalming
          🤷	People & Body	person-gesture	person shrugging	doubt | ignorance | indifference | person shrugging | shrug
          🧑‍⚕️	People & Body	person-role	health worker
          🧑‍⚕	People & Body	person-role	health worker	doctor | health worker | healthcare | nurse | therapist | care | health
          🧑‍🎓	People & Body	person-role	student	graduate | student
          🧑‍🏫	People & Body	person-role	teacher	instructor | professor | teacher | lecturer
          🧑‍⚖️	People & Body	person-role	judge
          🧑‍⚖	People & Body	person-role	judge	judge | justice | scales | law
          🧑‍🌾	People & Body	person-role	farmer	farmer | gardener | rancher
          🧑‍🍳	People & Body	person-role	cook	chef | cook
          🧑‍🔧	People & Body	person-role	mechanic	electrician | mechanic | plumber | tradesperson | tradie
          🧑‍🏭	People & Body	person-role	factory worker	assembly | factory | industrial | worker
          🧑‍🔬	People & Body	person-role	scientist	biologist | chemist | engineer | physicist | scientist
          🧑‍💻	People & Body	person-role	technologist	coder | developer | inventor | software | technologist
          🧑‍🎤	People & Body	person-role	singer	actor | entertainer | rock | singer | star
          🧑‍🎨	People & Body	person-role	artist	artist | palette
          🧑‍✈️	People & Body	person-role	pilot
          🧑‍✈	People & Body	person-role	pilot	pilot | plane
          🧑‍🚀	People & Body	person-role	astronaut	astronaut | rocket
          🧑‍🚒	People & Body	person-role	firefighter	firefighter | firetruck | fire engine | fire truck | engine | fire | truck
          👮	People & Body	person-role	police officer	cop | officer | police
          🕵️	People & Body	person-role	detective
          🕵	People & Body	person-role	detective	detective | sleuth | spy | investigator
          💂	People & Body	person-role	guard	guard
          🥷	People & Body	person-role	ninja	fighter | hidden | ninja | stealth
          👷	People & Body	person-role	construction worker	construction | hat | worker
          🫅	People & Body	person-role	person with crown	monarch | noble | person with crown | regal | royalty
          🤴	People & Body	person-role	prince	prince | fairy tale | fantasy
          👸	People & Body	person-role	princess	fairy tale | fantasy | princess
          👳	People & Body	person-role	person wearing turban	person wearing turban | turban
          👲	People & Body	person-role	person with skullcap	cap | gua pi mao | hat | person | person with skullcap | skullcap
          🤵	People & Body	person-role	person in tuxedo	groom | person | person in tuxedo | tuxedo | person in tux
          👰	People & Body	person-role	person with veil	bride | person | person with veil | veil | wedding
          🫄	People & Body	person-role	pregnant person	belly | bloated | full | pregnant | pregnant person
          🤱	People & Body	person-role	breast-feeding	baby | breast | breast-feeding | nursing
          🧑‍🍼	People & Body	person-role	person feeding baby	baby | feeding | nursing | person
          👼	People & Body	person-fantasy	baby angel	angel | baby | face | fairy tale | fantasy
          🎅	People & Body	person-fantasy	Santa Claus	celebration | Christmas | claus | father | santa | Santa Claus | Father Christmas | Santa | Claus | Father
          🤶	People & Body	person-fantasy	Mrs. Claus	celebration | Christmas | claus | mother | Mrs. | Mrs. Claus | Mrs Claus | Mrs Santa Claus | Claus | Mother
          🧑‍🎄	People & Body	person-fantasy	mx claus	Claus, christmas | mx claus | Claus, Christmas | Mx. Claus
          🦸	People & Body	person-fantasy	superhero	good | hero | heroine | superhero | superpower
          🦹	People & Body	person-fantasy	supervillain	criminal | evil | superpower | supervillain | villain
          🧙	People & Body	person-fantasy	mage	mage | sorcerer | sorceress | witch | wizard
          🧚	People & Body	person-fantasy	fairy	fairy | Oberon | Puck | Titania
          🧛	People & Body	person-fantasy	vampire	Dracula | undead | vampire
          🧜‍♀️	People & Body	person-fantasy	mermaid
          🧝	People & Body	person-fantasy	elf	elf | magical
          🧞	People & Body	person-fantasy	genie	djinn | genie
          🧟	People & Body	person-fantasy	zombie	undead | walking dead | zombie
          🧌	People & Body	person-fantasy	troll	fairy tale | fantasy | monster | troll
          💆	People & Body	person-activity	person getting massage	face | massage | person getting massage | salon
          💇	People & Body	person-activity	person getting haircut	barber | beauty | haircut | parlor | person getting haircut | parlour | salon
          🚶	People & Body	person-activity	person walking	hike | person walking | walk | walking
          🧍	People & Body	person-activity	person standing	person standing | stand | standing
          🧎	People & Body	person-activity	person kneeling	kneel | kneeling | person kneeling
          🧑‍🦯	People & Body	person-activity	person with white cane	accessibility | blind | person with white cane | person with guide cane | person with long mobility cane
          🧑‍🦼	People & Body	person-activity	person in motorized wheelchair	accessibility | person in motorized wheelchair | wheelchair | person in powered wheelchair | person in motorised wheelchair
          🏃	People & Body	person-activity	person running	marathon | person running | running
          🕴️	People & Body	person-activity	person in suit levitating
          🕴	People & Body	person-activity	person in suit levitating	business | person | person in suit levitating | suit
          👯	People & Body	person-activity	people with bunny ears	bunny ear | dancer | partying | people with bunny ears
          🧖	People & Body	person-activity	person in steamy room	person in steamy room | sauna | steam room
          🧗	People & Body	person-activity	person climbing	climber | person climbing
          🤺	People & Body	person-sport	person fencing	fencer | fencing | person fencing | sword
          🏇	People & Body	person-sport	horse racing	horse | jockey | racehorse | racing
          ⛷️	People & Body	person-sport	skier
          ⛷	People & Body	person-sport	skier	ski | skier | snow
          🏂	People & Body	person-sport	snowboarder	ski | snow | snowboard | snowboarder
          🏌️	People & Body	person-sport	person golfing
          🏌	People & Body	person-sport	person golfing	ball | golf | person golfing | golfer
          🏄	People & Body	person-sport	person surfing	person surfing | surfing | surfer
          🚣	People & Body	person-sport	person rowing boat	boat | person rowing boat | rowboat | person
          🏊	People & Body	person-sport	person swimming	person swimming | swim | swimmer
          ⛹️	People & Body	person-sport	person bouncing ball
          ⛹	People & Body	person-sport	person bouncing ball	ball | person bouncing ball
          🏋️	People & Body	person-sport	person lifting weights
          🏋	People & Body	person-sport	person lifting weights	lifter | person lifting weights | weight | weightlifter
          🚴	People & Body	person-sport	person biking	bicycle | biking | cyclist | person biking | person riding a bike
          🚵	People & Body	person-sport	person mountain biking	bicycle | bicyclist | bike | cyclist | mountain | person mountain biking
          🤸	People & Body	person-sport	person cartwheeling	cartwheel | gymnastics | person cartwheeling
          🤼	People & Body	person-sport	people wrestling	people wrestling | wrestle | wrestler
          🤽	People & Body	person-sport	person playing water polo	person playing water polo | polo | water
          🤾	People & Body	person-sport	person playing handball	ball | handball | person playing handball
          🤹	People & Body	person-sport	person juggling	balance | juggle | multitask | person juggling | skill | multi-task
          🧘	People & Body	person-resting	person in lotus position	meditation | person in lotus position | yoga
          🛀	People & Body	person-resting	person taking bath	bath | bathtub | person taking bath | tub
          🛌	People & Body	person-resting	person in bed	good night | hotel | person in bed | sleep | sleeping
          🧑‍🤝‍🧑	People & Body	family	people holding hands	couple | hand | hold | holding hands | people holding hands | person
          💏	People & Body	family	kiss	couple | kiss
          💑	People & Body	family	couple with heart	couple | couple with heart | love
          👪	People & Body	family	family	family
          🗣️	People & Body	person-symbol	speaking head
          🗣	People & Body	person-symbol	speaking head	face | head | silhouette | speak | speaking
          👤	People & Body	person-symbol	bust in silhouette	bust | bust in silhouette | silhouette
          👥	People & Body	person-symbol	busts in silhouette	bust | busts in silhouette | silhouette
          🫂	People & Body	person-symbol	people hugging	goodbye | hello | hug | people hugging | thanks
          👣	People & Body	person-symbol	footprints	clothing | footprint | footprints | print
          🦰	Component	hair-style	red hair	ginger | red hair | redhead
          🦱	Component	hair-style	curly hair	afro | curly | curly hair | ringlets
          🦳	Component	hair-style	white hair	gray | hair | old | white | grey
          🦲	Component	hair-style	bald	bald | chemotherapy | hairless | no hair | shaven
          🐵	Animals & Nature	animal-mammal	monkey face	face | monkey
          🐒	Animals & Nature	animal-mammal	monkey	monkey
          🦍	Animals & Nature	animal-mammal	gorilla	gorilla
          🦧	Animals & Nature	animal-mammal	orangutan	ape | orangutan
          🐶	Animals & Nature	animal-mammal	dog face	dog | face | pet
          🐕	Animals & Nature	animal-mammal	dog	dog | pet
          🦮	Animals & Nature	animal-mammal	guide dog	accessibility | blind | guide | guide dog
          🐕‍🦺	Animals & Nature	animal-mammal	service dog	accessibility | assistance | dog | service
          🐩	Animals & Nature	animal-mammal	poodle	dog | poodle
          🐺	Animals & Nature	animal-mammal	wolf	face | wolf
          🦊	Animals & Nature	animal-mammal	fox	face | fox
          🦝	Animals & Nature	animal-mammal	raccoon	curious | raccoon | sly
          🐱	Animals & Nature	animal-mammal	cat face	cat | face | pet
          🐈	Animals & Nature	animal-mammal	cat	cat | pet
          🐈‍⬛	Animals & Nature	animal-mammal	black cat	black | cat | unlucky
          🦁	Animals & Nature	animal-mammal	lion	face | Leo | lion | zodiac
          🐯	Animals & Nature	animal-mammal	tiger face	face | tiger
          🐅	Animals & Nature	animal-mammal	tiger	tiger
          🐆	Animals & Nature	animal-mammal	leopard	leopard
          🐴	Animals & Nature	animal-mammal	horse face	face | horse
          🫎	Animals & Nature	animal-mammal	moose	animal | antlers | elk | mammal | moose
          🫏	Animals & Nature	animal-mammal	donkey	animal | ass | burro | donkey | mammal | mule | stubborn
          🐎	Animals & Nature	animal-mammal	horse	equestrian | horse | racehorse | racing
          🦄	Animals & Nature	animal-mammal	unicorn	face | unicorn
          🦓	Animals & Nature	animal-mammal	zebra	stripe | zebra
          🦌	Animals & Nature	animal-mammal	deer	deer | stag
          🦬	Animals & Nature	animal-mammal	bison	bison | buffalo | herd | wisent
          🐮	Animals & Nature	animal-mammal	cow face	cow | face
          🐂	Animals & Nature	animal-mammal	ox	bull | ox | Taurus | zodiac
          🐃	Animals & Nature	animal-mammal	water buffalo	buffalo | water
          🐄	Animals & Nature	animal-mammal	cow	cow
          🐷	Animals & Nature	animal-mammal	pig face	face | pig
          🐖	Animals & Nature	animal-mammal	pig	pig | sow
          🐗	Animals & Nature	animal-mammal	boar	boar | pig
          🐽	Animals & Nature	animal-mammal	pig nose	face | nose | pig
          🐏	Animals & Nature	animal-mammal	ram	Aries | male | ram | sheep | zodiac
          🐑	Animals & Nature	animal-mammal	ewe	ewe | female | sheep
          🐐	Animals & Nature	animal-mammal	goat	Capricorn | goat | zodiac
          🐪	Animals & Nature	animal-mammal	camel	camel | dromedary | hump
          🐫	Animals & Nature	animal-mammal	two-hump camel	bactrian | camel | hump | two-hump camel | Bactrian
          🦙	Animals & Nature	animal-mammal	llama	alpaca | guanaco | llama | vicuña | wool
          🦒	Animals & Nature	animal-mammal	giraffe	giraffe | spots
          🐘	Animals & Nature	animal-mammal	elephant	elephant
          🦣	Animals & Nature	animal-mammal	mammoth	extinction | large | mammoth | tusk | woolly | extinct
          🦏	Animals & Nature	animal-mammal	rhinoceros	rhinoceros | rhino
          🦛	Animals & Nature	animal-mammal	hippopotamus	hippo | hippopotamus
          🐭	Animals & Nature	animal-mammal	mouse face	face | mouse | pet
          🐁	Animals & Nature	animal-mammal	mouse	mouse | pet | rodent
          🐀	Animals & Nature	animal-mammal	rat	rat | pet | rodent
          🐹	Animals & Nature	animal-mammal	hamster	face | hamster | pet
          🐰	Animals & Nature	animal-mammal	rabbit face	bunny | face | pet | rabbit
          🐇	Animals & Nature	animal-mammal	rabbit	bunny | pet | rabbit
          🐿️	Animals & Nature	animal-mammal	chipmunk
          🐿	Animals & Nature	animal-mammal	chipmunk	chipmunk | squirrel
          🦫	Animals & Nature	animal-mammal	beaver	beaver | dam
          🦔	Animals & Nature	animal-mammal	hedgehog	hedgehog | spiny
          🦇	Animals & Nature	animal-mammal	bat	bat | vampire
          🐻	Animals & Nature	animal-mammal	bear	bear | face
          🐻‍❄️	Animals & Nature	animal-mammal	polar bear
          🐻‍❄	Animals & Nature	animal-mammal	polar bear	arctic | bear | polar bear | white
          🐨	Animals & Nature	animal-mammal	koala	face | koala | marsupial
          🐼	Animals & Nature	animal-mammal	panda	face | panda
          🦥	Animals & Nature	animal-mammal	sloth	lazy | sloth | slow
          🦦	Animals & Nature	animal-mammal	otter	fishing | otter | playful
          🦨	Animals & Nature	animal-mammal	skunk	skunk | stink
          🦘	Animals & Nature	animal-mammal	kangaroo	joey | jump | kangaroo | marsupial
          🦡	Animals & Nature	animal-mammal	badger	badger | honey badger | pester
          🐾	Animals & Nature	animal-mammal	paw prints	feet | paw | paw prints | print
          🦃	Animals & Nature	animal-bird	turkey	bird | turkey | poultry
          🐔	Animals & Nature	animal-bird	chicken	bird | chicken | poultry
          🐓	Animals & Nature	animal-bird	rooster	bird | rooster
          🐣	Animals & Nature	animal-bird	hatching chick	baby | bird | chick | hatching
          🐤	Animals & Nature	animal-bird	baby chick	baby | bird | chick
          🐥	Animals & Nature	animal-bird	front-facing baby chick	baby | bird | chick | front-facing baby chick
          🐦	Animals & Nature	animal-bird	bird	bird
          🐧	Animals & Nature	animal-bird	penguin	bird | penguin
          🕊️	Animals & Nature	animal-bird	dove
          🕊	Animals & Nature	animal-bird	dove	bird | dove | fly | peace
          🦅	Animals & Nature	animal-bird	eagle	bird | eagle | bird of prey
          🦆	Animals & Nature	animal-bird	duck	bird | duck
          🦢	Animals & Nature	animal-bird	swan	bird | cygnet | swan | ugly duckling
          🦉	Animals & Nature	animal-bird	owl	bird | owl | wise | bird of prey
          🦤	Animals & Nature	animal-bird	dodo	dodo | extinction | large | Mauritius
          🪶	Animals & Nature	animal-bird	feather	bird | feather | flight | light | plumage
          🦩	Animals & Nature	animal-bird	flamingo	flamboyant | flamingo | tropical
          🦚	Animals & Nature	animal-bird	peacock	bird | ostentatious | peacock | peahen | proud
          🦜	Animals & Nature	animal-bird	parrot	bird | parrot | pirate | talk
          🪽	Animals & Nature	animal-bird	wing	angelic | aviation | bird | flying | mythology | wing
          🐦‍⬛	Animals & Nature	animal-bird	black bird	bird | black | crow | raven | rook
          🪿	Animals & Nature	animal-bird	goose	bird | fowl | goose | honk | silly
          🐸	Animals & Nature	animal-amphibian	frog	face | frog
          🐊	Animals & Nature	animal-reptile	crocodile	crocodile
          🐢	Animals & Nature	animal-reptile	turtle	terrapin | tortoise | turtle
          🦎	Animals & Nature	animal-reptile	lizard	lizard | reptile
          🐍	Animals & Nature	animal-reptile	snake	bearer | Ophiuchus | serpent | snake | zodiac
          🐲	Animals & Nature	animal-reptile	dragon face	dragon | face | fairy tale
          🐉	Animals & Nature	animal-reptile	dragon	dragon | fairy tale
          🦕	Animals & Nature	animal-reptile	sauropod	brachiosaurus | brontosaurus | diplodocus | sauropod
          🦖	Animals & Nature	animal-reptile	T-Rex	T-Rex | Tyrannosaurus Rex
          🐳	Animals & Nature	animal-marine	spouting whale	face | spouting | whale
          🐋	Animals & Nature	animal-marine	whale	whale
          🐬	Animals & Nature	animal-marine	dolphin	dolphin | flipper | porpoise
          🦭	Animals & Nature	animal-marine	seal	sea lion | seal
          🐟	Animals & Nature	animal-marine	fish	fish | Pisces | zodiac
          🐠	Animals & Nature	animal-marine	tropical fish	fish | tropical | reef fish
          🐡	Animals & Nature	animal-marine	blowfish	blowfish | fish
          🦈	Animals & Nature	animal-marine	shark	fish | shark
          🐙	Animals & Nature	animal-marine	octopus	octopus
          🐚	Animals & Nature	animal-marine	spiral shell	shell | spiral
          🪸	Animals & Nature	animal-marine	coral	coral | ocean | reef
          🪼	Animals & Nature	animal-marine	jellyfish	burn | invertebrate | jelly | jellyfish | marine | ouch | stinger
          🐌	Animals & Nature	animal-bug	snail	snail | mollusc
          🦋	Animals & Nature	animal-bug	butterfly	butterfly | insect | pretty | moth
          🐛	Animals & Nature	animal-bug	bug	bug | insect | caterpillar | worm
          🐜	Animals & Nature	animal-bug	ant	ant | insect
          🐝	Animals & Nature	animal-bug	honeybee	bee | honeybee | insect
          🪲	Animals & Nature	animal-bug	beetle	beetle | bug | insect
          🐞	Animals & Nature	animal-bug	lady beetle	beetle | insect | lady beetle | ladybird | ladybug
          🦗	Animals & Nature	animal-bug	cricket	cricket | grasshopper
          🪳	Animals & Nature	animal-bug	cockroach	cockroach | insect | pest | roach
          🕷️	Animals & Nature	animal-bug	spider
          🕷	Animals & Nature	animal-bug	spider	insect | spider | arachnid
          🕸️	Animals & Nature	animal-bug	spider web
          🕸	Animals & Nature	animal-bug	spider web	spider | web
          🦂	Animals & Nature	animal-bug	scorpion	scorpio | Scorpio | scorpion | zodiac
          🦟	Animals & Nature	animal-bug	mosquito	disease | fever | malaria | mosquito | pest | virus | dengue | insect | mozzie
          🪰	Animals & Nature	animal-bug	fly	disease | fly | maggot | pest | rotting
          🪱	Animals & Nature	animal-bug	worm	annelid | earthworm | parasite | worm
          🦠	Animals & Nature	animal-bug	microbe	amoeba | bacteria | microbe | virus
          💐	Animals & Nature	plant-flower	bouquet	bouquet | flower
          🌸	Animals & Nature	plant-flower	cherry blossom	blossom | cherry | flower
          💮	Animals & Nature	plant-flower	white flower	flower | white flower
          🪷	Animals & Nature	plant-flower	lotus	Buddhism | flower | Hinduism | lotus | purity
          🏵️	Animals & Nature	plant-flower	rosette
          🏵	Animals & Nature	plant-flower	rosette	plant | rosette
          🌹	Animals & Nature	plant-flower	rose	flower | rose
          🥀	Animals & Nature	plant-flower	wilted flower	flower | wilted
          🌺	Animals & Nature	plant-flower	hibiscus	flower | hibiscus
          🌻	Animals & Nature	plant-flower	sunflower	flower | sun | sunflower
          🌼	Animals & Nature	plant-flower	blossom	blossom | flower
          🌷	Animals & Nature	plant-flower	tulip	flower | tulip
          🪻	Animals & Nature	plant-flower	hyacinth	bluebonnet | flower | hyacinth | lavender | lupine | snapdragon
          🌱	Animals & Nature	plant-other	seedling	seedling | young
          🪴	Animals & Nature	plant-other	potted plant	boring | grow | house | nurturing | plant | potted plant | useless | pot plant
          🌲	Animals & Nature	plant-other	evergreen tree	evergreen tree | tree
          🌳	Animals & Nature	plant-other	deciduous tree	deciduous | shedding | tree
          🌴	Animals & Nature	plant-other	palm tree	palm | tree
          🌵	Animals & Nature	plant-other	cactus	cactus | plant
          🌾	Animals & Nature	plant-other	sheaf of rice	ear | grain | rice | sheaf of rice | sheaf
          🌿	Animals & Nature	plant-other	herb	herb | leaf
          ☘️	Animals & Nature	plant-other	shamrock
          ☘	Animals & Nature	plant-other	shamrock	plant | shamrock
          🍀	Animals & Nature	plant-other	four leaf clover	4 | clover | four | four-leaf clover | leaf
          🍁	Animals & Nature	plant-other	maple leaf	falling | leaf | maple
          🍂	Animals & Nature	plant-other	fallen leaf	fallen leaf | falling | leaf
          🍃	Animals & Nature	plant-other	leaf fluttering in wind	blow | flutter | leaf | leaf fluttering in wind | wind
          🪹	Animals & Nature	plant-other	empty nest	empty nest | nesting
          🪺	Animals & Nature	plant-other	nest with eggs	nest with eggs | nesting
          🍄	Animals & Nature	plant-other	mushroom	mushroom | toadstool
          🍇	Food & Drink	food-fruit	grapes	fruit | grape | grapes
          🍈	Food & Drink	food-fruit	melon	fruit | melon
          🍉	Food & Drink	food-fruit	watermelon	fruit | watermelon
          🍋	Food & Drink	food-fruit	lemon	citrus | fruit | lemon
          🍌	Food & Drink	food-fruit	banana	banana | fruit
          🍍	Food & Drink	food-fruit	pineapple	fruit | pineapple
          🍎	Food & Drink	food-fruit	red apple	apple | fruit | red
          🍏	Food & Drink	food-fruit	green apple	apple | fruit | green
          🍐	Food & Drink	food-fruit	pear	fruit | pear
          🍑	Food & Drink	food-fruit	peach	fruit | peach
          🍒	Food & Drink	food-fruit	cherries	berries | cherries | cherry | fruit | red
          🍓	Food & Drink	food-fruit	strawberry	berry | fruit | strawberry
          🫐	Food & Drink	food-fruit	blueberries	berry | bilberry | blue | blueberries | blueberry
          🥝	Food & Drink	food-fruit	kiwi fruit	food | fruit | kiwi | kiwi fruit
          🍅	Food & Drink	food-fruit	tomato	fruit | tomato | vegetable
          🫒	Food & Drink	food-fruit	olive	food | olive
          🥥	Food & Drink	food-fruit	coconut	coconut | palm | piña colada
          🥑	Food & Drink	food-vegetable	avocado	avocado | food | fruit
          🍆	Food & Drink	food-vegetable	eggplant	aubergine | eggplant | vegetable
          🥔	Food & Drink	food-vegetable	potato	food | potato | vegetable
          🥕	Food & Drink	food-vegetable	carrot	carrot | food | vegetable
          🌽	Food & Drink	food-vegetable	ear of corn	corn | ear | ear of corn | maize | maze | corn on the cob | sweetcorn
          🌶️	Food & Drink	food-vegetable	hot pepper
          🌶	Food & Drink	food-vegetable	hot pepper	hot | pepper | chilli | hot pepper
          🫑	Food & Drink	food-vegetable	bell pepper	bell pepper | capsicum | pepper | vegetable | sweet pepper
          🥒	Food & Drink	food-vegetable	cucumber	cucumber | food | pickle | vegetable
          🥬	Food & Drink	food-vegetable	leafy green	bok choy | cabbage | kale | leafy green | lettuce | pak choi
          🥦	Food & Drink	food-vegetable	broccoli	broccoli | wild cabbage
          🧄	Food & Drink	food-vegetable	garlic	flavoring | garlic | flavouring
          🧅	Food & Drink	food-vegetable	onion	flavoring | onion | flavouring
          🥜	Food & Drink	food-vegetable	peanuts	food | nut | peanut | peanuts | vegetable | nuts
          🫘	Food & Drink	food-vegetable	beans	beans | food | kidney | legume | kidney bean | kidney beans
          🌰	Food & Drink	food-vegetable	chestnut	chestnut | plant | nut
          🫚	Food & Drink	food-vegetable	ginger root	beer | ginger root | root | spice | ginger
          🫛	Food & Drink	food-vegetable	pea pod	beans | edamame | legume | pea | pod | vegetable
          🍞	Food & Drink	food-prepared	bread	bread | loaf
          🥐	Food & Drink	food-prepared	croissant	bread | breakfast | croissant | food | french | roll | crescent | French
          🥖	Food & Drink	food-prepared	baguette bread	baguette | bread | food | french | French stick | French
          🫓	Food & Drink	food-prepared	flatbread	arepa | flatbread | lavash | naan | pita
          🥨	Food & Drink	food-prepared	pretzel	pretzel | twisted
          🥯	Food & Drink	food-prepared	bagel	bagel | bakery | breakfast | schmear
          🥞	Food & Drink	food-prepared	pancakes	breakfast | crêpe | food | hotcake | pancake | pancakes | crepe
          🧇	Food & Drink	food-prepared	waffle	breakfast | indecisive | iron | waffle | unclear | vague | waffle with butter
          🧀	Food & Drink	food-prepared	cheese wedge	cheese | cheese wedge
          🍖	Food & Drink	food-prepared	meat on bone	bone | meat | meat on bone
          🍗	Food & Drink	food-prepared	poultry leg	bone | chicken | drumstick | leg | poultry
          🥩	Food & Drink	food-prepared	cut of meat	chop | cut of meat | lambchop | porkchop | steak | lamb chop | pork chop
          🥓	Food & Drink	food-prepared	bacon	bacon | breakfast | food | meat
          🍔	Food & Drink	food-prepared	hamburger	burger | hamburger | beefburger
          🍟	Food & Drink	food-prepared	french fries	french | fries | chips | french fries | French
          🍕	Food & Drink	food-prepared	pizza	cheese | pizza | slice
          🌭	Food & Drink	food-prepared	hot dog	frankfurter | hot dog | hotdog | sausage | frank
          🥪	Food & Drink	food-prepared	sandwich	bread | sandwich
          🌮	Food & Drink	food-prepared	taco	mexican | taco | Mexican
          🌯	Food & Drink	food-prepared	burrito	burrito | mexican | wrap | Mexican
          🫔	Food & Drink	food-prepared	tamale	mexican | tamale | wrapped | Mexican
          🥙	Food & Drink	food-prepared	stuffed flatbread	falafel | flatbread | food | gyro | kebab | stuffed | pita | pita roll
          🧆	Food & Drink	food-prepared	falafel	chickpea | falafel | meatball | chick pea
          🥚	Food & Drink	food-prepared	egg	breakfast | egg | food
          🍳	Food & Drink	food-prepared	cooking	breakfast | cooking | egg | frying | pan
          🥘	Food & Drink	food-prepared	shallow pan of food	casserole | food | paella | pan | shallow | shallow pan of food
          🍲	Food & Drink	food-prepared	pot of food	pot | pot of food | stew
          🫕	Food & Drink	food-prepared	fondue	cheese | chocolate | fondue | melted | pot | Swiss
          🥣	Food & Drink	food-prepared	bowl with spoon	bowl with spoon | breakfast | cereal | congee
          🥗	Food & Drink	food-prepared	green salad	food | green | salad | garden
          🍿	Food & Drink	food-prepared	popcorn	popcorn
          🧈	Food & Drink	food-prepared	butter	butter | dairy
          🥫	Food & Drink	food-prepared	canned food	can | canned food
          🍱	Food & Drink	food-asian	bento box	bento | box
          🍘	Food & Drink	food-asian	rice cracker	cracker | rice
          🍙	Food & Drink	food-asian	rice ball	ball | Japanese | rice
          🍚	Food & Drink	food-asian	cooked rice	cooked | rice
          🍛	Food & Drink	food-asian	curry rice	curry | rice
          🍝	Food & Drink	food-asian	spaghetti	pasta | spaghetti
          🍠	Food & Drink	food-asian	roasted sweet potato	potato | roasted | sweet
          🍢	Food & Drink	food-asian	oden	kebab | oden | seafood | skewer | stick
          🍣	Food & Drink	food-asian	sushi	sushi
          🍤	Food & Drink	food-asian	fried shrimp	fried | prawn | shrimp | tempura | battered
          🍥	Food & Drink	food-asian	fish cake with swirl	cake | fish | fish cake with swirl | pastry | swirl | narutomaki
          🥮	Food & Drink	food-asian	moon cake	autumn | festival | moon cake | yuèbǐng
          🍡	Food & Drink	food-asian	dango	dango | dessert | Japanese | skewer | stick | sweet
          🥟	Food & Drink	food-asian	dumpling	dumpling | empanada | gyōza | jiaozi | pierogi | potsticker | pastie | samosa
          🥠	Food & Drink	food-asian	fortune cookie	fortune cookie | prophecy
          🥡	Food & Drink	food-asian	takeout box	oyster pail | takeout box | takeaway box | takeaway container | takeout
          🦀	Food & Drink	food-marine	crab	Cancer | crab | zodiac | crustacean | seafood | shellfish
          🦞	Food & Drink	food-marine	lobster	bisque | claws | lobster | seafood | shellfish
          🦐	Food & Drink	food-marine	shrimp	food | shellfish | shrimp | small | prawn | seafood
          🦑	Food & Drink	food-marine	squid	food | molusc | squid | decapod | seafood
          🦪	Food & Drink	food-marine	oyster	diving | oyster | pearl
          🍦	Food & Drink	food-sweet	soft ice cream	cream | dessert | ice | icecream | soft | sweet | ice cream | soft serve | soft-serve ice cream
          🍧	Food & Drink	food-sweet	shaved ice	dessert | ice | shaved | sweet | granita
          🍨	Food & Drink	food-sweet	ice cream	cream | dessert | ice | sweet | ice cream
          🍩	Food & Drink	food-sweet	doughnut	breakfast | dessert | donut | doughnut | sweet
          🍪	Food & Drink	food-sweet	cookie	cookie | dessert | sweet | biscuit
          🎂	Food & Drink	food-sweet	birthday cake	birthday | cake | celebration | dessert | pastry | sweet
          🍰	Food & Drink	food-sweet	shortcake	cake | dessert | pastry | shortcake | slice | sweet
          🧁	Food & Drink	food-sweet	cupcake	bakery | cupcake | sweet
          🥧	Food & Drink	food-sweet	pie	filling | pastry | pie
          🍫	Food & Drink	food-sweet	chocolate bar	bar | chocolate | dessert | sweet
          🍬	Food & Drink	food-sweet	candy	candy | dessert | sweet | sweets
          🍭	Food & Drink	food-sweet	lollipop	candy | dessert | lollipop | sweet
          🍮	Food & Drink	food-sweet	custard	custard | dessert | pudding | sweet | baked custard
          🍯	Food & Drink	food-sweet	honey pot	honey | honeypot | pot | sweet
          🍼	Food & Drink	drink	baby bottle	baby | bottle | drink | milk
          🥛	Food & Drink	drink	glass of milk	drink | glass | glass of milk | milk
          ☕	Food & Drink	drink	hot beverage	beverage | coffee | drink | hot | steaming | tea
          🫖	Food & Drink	drink	teapot	drink | pot | tea | teapot
          🍵	Food & Drink	drink	teacup without handle	beverage | cup | drink | tea | teacup | teacup without handle
          🍶	Food & Drink	drink	sake	bar | beverage | bottle | cup | drink | sake | saké
          🍾	Food & Drink	drink	bottle with popping cork	bar | bottle | bottle with popping cork | cork | drink | popping | bubbly
          🍷	Food & Drink	drink	wine glass	bar | beverage | drink | glass | wine
          🍸	Food & Drink	drink	cocktail glass	bar | cocktail | drink | glass
          🍹	Food & Drink	drink	tropical drink	bar | drink | tropical
          🍺	Food & Drink	drink	beer mug	bar | beer | drink | mug
          🍻	Food & Drink	drink	clinking beer mugs	bar | beer | clink | clinking beer mugs | drink | mug | cheers
          🥂	Food & Drink	drink	clinking glasses	celebrate | clink | clinking glasses | drink | glass | cheers
          🥃	Food & Drink	drink	tumbler glass	glass | liquor | shot | tumbler | whisky | whiskey
          🫗	Food & Drink	drink	pouring liquid	drink | empty | glass | pouring liquid | spill
          🥤	Food & Drink	drink	cup with straw	cup with straw | juice | soda
          🧋	Food & Drink	drink	bubble tea	bubble | milk | pearl | tea | boba
          🧃	Food & Drink	drink	beverage box	beverage | box | juice | straw | sweet | drink carton | juice box | popper
          🧉	Food & Drink	drink	mate	drink | mate | maté
          🧊	Food & Drink	drink	ice	cold | ice | ice cube | iceberg
          🥢	Food & Drink	dishware	chopsticks	chopsticks | hashi | pair of chopsticks
          🍽️	Food & Drink	dishware	fork and knife with plate
          🍽	Food & Drink	dishware	fork and knife with plate	cooking | fork | fork and knife with plate | knife | plate
          🍴	Food & Drink	dishware	fork and knife	cooking | cutlery | fork | fork and knife | knife | knife and fork
          🥄	Food & Drink	dishware	spoon	spoon | tableware
          🔪	Food & Drink	dishware	kitchen knife	cooking | hocho | kitchen knife | knife | tool | weapon
          🏺	Food & Drink	dishware	amphora	amphora | Aquarius | cooking | drink | jug | zodiac | jar
          🌍	Travel & Places	place-map	globe showing Europe-Africa	Africa | earth | Europe | globe | globe showing Europe-Africa | world
          🌎	Travel & Places	place-map	globe showing Americas	Americas | earth | globe | globe showing Americas | world
          🌏	Travel & Places	place-map	globe showing Asia-Australia	Asia | Australia | earth | globe | globe showing Asia-Australia | world
          🌐	Travel & Places	place-map	globe with meridians	earth | globe | globe with meridians | meridians | world
          🗺️	Travel & Places	place-map	world map
          🗺	Travel & Places	place-map	world map	map | world
          🗾	Travel & Places	place-map	map of Japan	Japan | map | map of Japan
          🧭	Travel & Places	place-map	compass	compass | magnetic | navigation | orienteering
          🏔️	Travel & Places	place-geographic	snow-capped mountain
          🏔	Travel & Places	place-geographic	snow-capped mountain	cold | mountain | snow | snow-capped mountain
          ⛰️	Travel & Places	place-geographic	mountain
          ⛰	Travel & Places	place-geographic	mountain	mountain
          🌋	Travel & Places	place-geographic	volcano	eruption | mountain | volcano
          🗻	Travel & Places	place-geographic	mount fuji	fuji | mount fuji | mountain | Fuji | Mount Fuji | mount Fuji
          🏕️	Travel & Places	place-geographic	camping
          🏕	Travel & Places	place-geographic	camping	camping
          🏖️	Travel & Places	place-geographic	beach with umbrella
          🏖	Travel & Places	place-geographic	beach with umbrella	beach | beach with umbrella | umbrella
          🏜️	Travel & Places	place-geographic	desert
          🏜	Travel & Places	place-geographic	desert	desert
          🏝️	Travel & Places	place-geographic	desert island
          🏝	Travel & Places	place-geographic	desert island	desert | island
          🏞️	Travel & Places	place-geographic	national park
          🏞	Travel & Places	place-geographic	national park	national park | park
          🏟️	Travel & Places	place-building	stadium
          🏟	Travel & Places	place-building	stadium	stadium | arena
          🏛️	Travel & Places	place-building	classical building
          🏛	Travel & Places	place-building	classical building	classical | classical building | column
          🏗️	Travel & Places	place-building	building construction
          🏗	Travel & Places	place-building	building construction	building construction | construction
          🧱	Travel & Places	place-building	brick	brick | bricks | clay | mortar | wall
          🪨	Travel & Places	place-building	rock	boulder | heavy | rock | solid | stone
          🪵	Travel & Places	place-building	wood	log | lumber | timber | wood
          🛖	Travel & Places	place-building	hut	house | hut | roundhouse | yurt
          🏘️	Travel & Places	place-building	houses
          🏘	Travel & Places	place-building	houses	houses
          🏚️	Travel & Places	place-building	derelict house
          🏚	Travel & Places	place-building	derelict house	derelict | house
          🏠	Travel & Places	place-building	house	home | house
          🏡	Travel & Places	place-building	house with garden	garden | home | house | house with garden
          🏢	Travel & Places	place-building	office building	building | office building
          🏣	Travel & Places	place-building	Japanese post office	Japanese | Japanese post office | post
          🏤	Travel & Places	place-building	post office	European | post | post office
          🏥	Travel & Places	place-building	hospital	doctor | hospital | medicine
          🏦	Travel & Places	place-building	bank	bank | building
          🏨	Travel & Places	place-building	hotel	building | hotel
          🏩	Travel & Places	place-building	love hotel	hotel | love
          🏪	Travel & Places	place-building	convenience store	convenience | store | dépanneur
          🏫	Travel & Places	place-building	school	building | school
          🏭	Travel & Places	place-building	factory	building | factory
          🏯	Travel & Places	place-building	Japanese castle	castle | Japanese
          🏰	Travel & Places	place-building	castle	castle | European
          🗼	Travel & Places	place-building	Tokyo tower	Tokyo | tower | Tower
          🗽	Travel & Places	place-building	Statue of Liberty	liberty | statue | Statue of Liberty | Liberty | Statue
          ⛪	Travel & Places	place-religious	church	Christian | church | cross | religion
          🕌	Travel & Places	place-religious	mosque	islam | mosque | Muslim | religion | Islam
          🛕	Travel & Places	place-religious	hindu temple	hindu | temple | Hindu
          🕍	Travel & Places	place-religious	synagogue	Jew | Jewish | religion | synagogue | temple | shul
          ⛩️	Travel & Places	place-religious	shinto shrine
          ⛩	Travel & Places	place-religious	shinto shrine	religion | shinto | shrine | Shinto
          🕋	Travel & Places	place-religious	kaaba	islam | kaaba | Muslim | religion | Islam | Kaaba
          ⛲	Travel & Places	place-other	fountain	fountain
          ⛺	Travel & Places	place-other	tent	camping | tent
          🌁	Travel & Places	place-other	foggy	fog | foggy
          🌃	Travel & Places	place-other	night with stars	night | night with stars | star | starry night
          🏙️	Travel & Places	place-other	cityscape
          🏙	Travel & Places	place-other	cityscape	city | cityscape | skyline
          🌄	Travel & Places	place-other	sunrise over mountains	morning | mountain | sun | sunrise | sunrise over mountains
          🌅	Travel & Places	place-other	sunrise	morning | sun | sunrise
          🌆	Travel & Places	place-other	cityscape at dusk	city | cityscape at dusk | dusk | evening | landscape | sunset | skyline at dusk
          🌇	Travel & Places	place-other	sunset	dusk | sun | sunset
          🌉	Travel & Places	place-other	bridge at night	bridge | bridge at night | night
          ♨️	Travel & Places	place-other	hot springs
          ♨	Travel & Places	place-other	hot springs	hot | hotsprings | springs | steaming
          🎠	Travel & Places	place-other	carousel horse	carousel | horse | merry-go-round
          💈	Travel & Places	place-other	barber pole	barber | haircut | pole
          🎪	Travel & Places	place-other	circus tent	circus | tent | big top
          🚂	Travel & Places	transport-ground	locomotive	engine | locomotive | railway | steam | train
          🚃	Travel & Places	transport-ground	railway car	car | electric | railway | train | tram | trolleybus | railway carriage | train carriage | trolley bus
          🚄	Travel & Places	transport-ground	high-speed train	high-speed train | railway | shinkansen | speed | train | Shinkansen
          🚅	Travel & Places	transport-ground	bullet train	bullet | railway | shinkansen | speed | train | Shinkansen
          🚆	Travel & Places	transport-ground	train	railway | train
          🚇	Travel & Places	transport-ground	metro	metro | subway | tube | underground
          🚈	Travel & Places	transport-ground	light rail	light rail | railway
          🚉	Travel & Places	transport-ground	station	railway | station | train
          🚊	Travel & Places	transport-ground	tram	tram | trolleybus | light rail | oncoming | oncoming light rail | car | streetcar | tramcar | trolley | trolley bus
          🚝	Travel & Places	transport-ground	monorail	monorail | vehicle
          🚞	Travel & Places	transport-ground	mountain railway	car | mountain | railway
          🚋	Travel & Places	transport-ground	tram car	car | tram | trolleybus | trolley bus | streetcar | tramcar | trolley
          🚌	Travel & Places	transport-ground	bus	bus | vehicle
          🚍	Travel & Places	transport-ground	oncoming bus	bus | oncoming
          🚎	Travel & Places	transport-ground	trolleybus	bus | tram | trolley | trolleybus | streetcar
          🚐	Travel & Places	transport-ground	minibus	bus | minibus
          🚑	Travel & Places	transport-ground	ambulance	ambulance | vehicle
          🚒	Travel & Places	transport-ground	fire engine	engine | fire | truck
          🚓	Travel & Places	transport-ground	police car	car | patrol | police
          🚔	Travel & Places	transport-ground	oncoming police car	car | oncoming | police
          🚕	Travel & Places	transport-ground	taxi	taxi | vehicle
          🚖	Travel & Places	transport-ground	oncoming taxi	oncoming | taxi
          🚗	Travel & Places	transport-ground	automobile	automobile | car
          🚘	Travel & Places	transport-ground	oncoming automobile	automobile | car | oncoming
          🚙	Travel & Places	transport-ground	sport utility vehicle	recreational | sport utility | sport utility vehicle | 4x4 | off-road vehicle | 4WD | four-wheel drive | SUV
          🛻	Travel & Places	transport-ground	pickup truck	pick-up | pickup | truck | ute
          🚚	Travel & Places	transport-ground	delivery truck	delivery | truck
          🚛	Travel & Places	transport-ground	articulated lorry	articulated lorry | lorry | semi | truck | articulated truck
          🚜	Travel & Places	transport-ground	tractor	tractor | vehicle
          🏎️	Travel & Places	transport-ground	racing car
          🏎	Travel & Places	transport-ground	racing car	car | racing
          🏍️	Travel & Places	transport-ground	motorcycle
          🏍	Travel & Places	transport-ground	motorcycle	motorcycle | racing
          🛵	Travel & Places	transport-ground	motor scooter	motor | scooter
          🦼	Travel & Places	transport-ground	motorized wheelchair	accessibility | motorized wheelchair | powered wheelchair | mobility scooter
          🛺	Travel & Places	transport-ground	auto rickshaw	auto rickshaw | tuk tuk | tuk-tuk | tuktuk
          🚲	Travel & Places	transport-ground	bicycle	bicycle | bike
          🛴	Travel & Places	transport-ground	kick scooter	kick | scooter
          🛹	Travel & Places	transport-ground	skateboard	board | skateboard
          🛼	Travel & Places	transport-ground	roller skate	roller | skate | rollerskate
          🚏	Travel & Places	transport-ground	bus stop	bus | stop | busstop
          🛣️	Travel & Places	transport-ground	motorway
          🛣	Travel & Places	transport-ground	motorway	highway | motorway | road | freeway
          🛤️	Travel & Places	transport-ground	railway track
          🛤	Travel & Places	transport-ground	railway track	railway | railway track | train
          🛢️	Travel & Places	transport-ground	oil drum
          🛢	Travel & Places	transport-ground	oil drum	drum | oil
          ⛽	Travel & Places	transport-ground	fuel pump	diesel | fuel | fuelpump | gas | pump | station | petrol pump
          🛞	Travel & Places	transport-ground	wheel	circle | tire | turn | wheel | tyre
          🚨	Travel & Places	transport-ground	police car light	beacon | car | light | police | revolving
          🚥	Travel & Places	transport-ground	horizontal traffic light	horizontal traffic light | light | signal | traffic | horizontal traffic lights | lights
          🚦	Travel & Places	transport-ground	vertical traffic light	light | signal | traffic | vertical traffic light | lights | vertical traffic lights
          🛑	Travel & Places	transport-ground	stop sign	octagonal | sign | stop
          🚧	Travel & Places	transport-ground	construction	barrier | construction
          ⚓	Travel & Places	transport-water	anchor	anchor | ship | tool
          🛟	Travel & Places	transport-water	ring buoy	float | life preserver | life saver | rescue | ring buoy | safety | buoy
          ⛵	Travel & Places	transport-water	sailboat	boat | resort | sailboat | sea | yacht
          🛶	Travel & Places	transport-water	canoe	boat | canoe
          🚤	Travel & Places	transport-water	speedboat	boat | speedboat
          🛳️	Travel & Places	transport-water	passenger ship
          🛳	Travel & Places	transport-water	passenger ship	passenger | ship
          ⛴️	Travel & Places	transport-water	ferry
          ⛴	Travel & Places	transport-water	ferry	boat | ferry | passenger
          🛥️	Travel & Places	transport-water	motor boat
          🛥	Travel & Places	transport-water	motor boat	boat | motor boat | motorboat
          🚢	Travel & Places	transport-water	ship	boat | passenger | ship
          ✈️	Travel & Places	transport-air	airplane
          ✈	Travel & Places	transport-air	airplane	aeroplane | airplane | flight
          🛩️	Travel & Places	transport-air	small airplane
          🛩	Travel & Places	transport-air	small airplane	aeroplane | airplane | small airplane | small plane
          🛫	Travel & Places	transport-air	airplane departure	aeroplane | airplane | check-in | departure | departures | take-off | flight departure | plane departure
          🛬	Travel & Places	transport-air	airplane arrival	aeroplane | airplane | airplane arrival | arrivals | arriving | landing | flight arrival | plan arrival
          🪂	Travel & Places	transport-air	parachute	hang-glide | parachute | parasail | skydive | parascend
          💺	Travel & Places	transport-air	seat	chair | seat
          🚁	Travel & Places	transport-air	helicopter	helicopter | vehicle
          🚟	Travel & Places	transport-air	suspension railway	railway | suspension | cable
          🚠	Travel & Places	transport-air	mountain cableway	cable | gondola | mountain | mountain cableway | cableway
          🚡	Travel & Places	transport-air	aerial tramway	aerial | cable | car | gondola | tramway
          🛰️	Travel & Places	transport-air	satellite
          🛰	Travel & Places	transport-air	satellite	satellite | space
          🚀	Travel & Places	transport-air	rocket	rocket | space
          🛸	Travel & Places	transport-air	flying saucer	flying saucer | UFO | spaceship
          🛎️	Travel & Places	hotel	bellhop bell
          🛎	Travel & Places	hotel	bellhop bell	bell | bellhop | hotel | porter
          🧳	Travel & Places	hotel	luggage	luggage | packing | travel
          ⌛	Travel & Places	time	hourglass done	hourglass done | sand | timer | hourglass
          ⏳	Travel & Places	time	hourglass not done	hourglass | hourglass not done | sand | timer
          ⌚	Travel & Places	time	watch	clock | watch
          ⏰	Travel & Places	time	alarm clock	alarm | clock
          ⏱️	Travel & Places	time	stopwatch
          ⏱	Travel & Places	time	stopwatch	clock | stopwatch
          ⏲️	Travel & Places	time	timer clock
          ⏲	Travel & Places	time	timer clock	clock | timer
          🕛	Travel & Places	time	twelve o’clock	00 | 12 | 12:00 | clock | o’clock | twelve
          🕧	Travel & Places	time	twelve-thirty	12 | 12:30 | clock | thirty | twelve | twelve-thirty | 12.30 | half past twelve
          🕐	Travel & Places	time	one o’clock	00 | 1 | 1:00 | clock | o’clock | one
          🕜	Travel & Places	time	one-thirty	1 | 1:30 | clock | one | one-thirty | thirty | 1.30 | half past one
          🕑	Travel & Places	time	two o’clock	00 | 2 | 2:00 | clock | o’clock | two
          🕝	Travel & Places	time	two-thirty	2 | 2:30 | clock | thirty | two | two-thirty | 2.30 | half past two
          🕒	Travel & Places	time	three o’clock	00 | 3 | 3:00 | clock | o’clock | three
          🕞	Travel & Places	time	three-thirty	3 | 3:30 | clock | thirty | three | three-thirty | 3.30 | half past three
          🕓	Travel & Places	time	four o’clock	00 | 4 | 4:00 | clock | four | o’clock
          🕟	Travel & Places	time	four-thirty	4 | 4:30 | clock | four | four-thirty | thirty | 4.30 | half past four
          🕔	Travel & Places	time	five o’clock	00 | 5 | 5:00 | clock | five | o’clock
          🕠	Travel & Places	time	five-thirty	5 | 5:30 | clock | five | five-thirty | thirty | 5.30 | half past five
          🕕	Travel & Places	time	six o’clock	00 | 6 | 6:00 | clock | o’clock | six
          🕡	Travel & Places	time	six-thirty	6 | 6:30 | clock | six | six-thirty | thirty | 6.30 | half past six
          🕖	Travel & Places	time	seven o’clock	00 | 7 | 7:00 | clock | o’clock | seven
          🕢	Travel & Places	time	seven-thirty	7 | 7:30 | clock | seven | seven-thirty | thirty | 7.30 | half past seven
          🕗	Travel & Places	time	eight o’clock	00 | 8 | 8:00 | clock | eight | o’clock
          🕣	Travel & Places	time	eight-thirty	8 | 8:30 | clock | eight | eight-thirty | thirty | 8.30 | half past eight
          🕘	Travel & Places	time	nine o’clock	00 | 9 | 9:00 | clock | nine | o’clock
          🕤	Travel & Places	time	nine-thirty	9 | 9:30 | clock | nine | nine-thirty | thirty | 9.30 | half past nine
          🕙	Travel & Places	time	ten o’clock	00 | 10 | 10:00 | clock | o’clock | ten
          🕥	Travel & Places	time	ten-thirty	10 | 10:30 | clock | ten | ten-thirty | thirty | 10.30 | half past ten
          🕚	Travel & Places	time	eleven o’clock	00 | 11 | 11:00 | clock | eleven | o’clock
          🕦	Travel & Places	time	eleven-thirty	11 | 11:30 | clock | eleven | eleven-thirty | thirty | 11.30 | half past eleven
          🌑	Travel & Places	sky & weather	new moon	dark | moon | new moon
          🌒	Travel & Places	sky & weather	waxing crescent moon	crescent | moon | waxing
          🌓	Travel & Places	sky & weather	first quarter moon	first quarter moon | moon | quarter
          🌔	Travel & Places	sky & weather	waxing gibbous moon	gibbous | moon | waxing
          🌕	Travel & Places	sky & weather	full moon	full | moon
          🌖	Travel & Places	sky & weather	waning gibbous moon	gibbous | moon | waning
          🌗	Travel & Places	sky & weather	last quarter moon	last quarter moon | moon | quarter
          🌘	Travel & Places	sky & weather	waning crescent moon	crescent | moon | waning
          🌙	Travel & Places	sky & weather	crescent moon	crescent | moon
          🌚	Travel & Places	sky & weather	new moon face	face | moon | new moon face
          🌛	Travel & Places	sky & weather	first quarter moon face	face | first quarter moon face | moon | quarter
          🌜	Travel & Places	sky & weather	last quarter moon face	face | last quarter moon face | moon | quarter
          🌡️	Travel & Places	sky & weather	thermometer
          🌡	Travel & Places	sky & weather	thermometer	thermometer | weather
          ☀️	Travel & Places	sky & weather	sun
          ☀	Travel & Places	sky & weather	sun	bright | rays | sun | sunny
          🌝	Travel & Places	sky & weather	full moon face	bright | face | full | moon | full-moon face
          🌞	Travel & Places	sky & weather	sun with face	bright | face | sun | sun with face
          🪐	Travel & Places	sky & weather	ringed planet	ringed planet | saturn | saturnine
          ⭐	Travel & Places	sky & weather	star	star
          🌟	Travel & Places	sky & weather	glowing star	glittery | glow | glowing star | shining | sparkle | star
          🌠	Travel & Places	sky & weather	shooting star	falling | shooting | star
          🌌	Travel & Places	sky & weather	milky way	milky way | space | Milky Way | Milky | Way
          ☁️	Travel & Places	sky & weather	cloud
          ☁	Travel & Places	sky & weather	cloud	cloud | weather
          ⛅	Travel & Places	sky & weather	sun behind cloud	cloud | sun | sun behind cloud
          ⛈️	Travel & Places	sky & weather	cloud with lightning and rain
          ⛈	Travel & Places	sky & weather	cloud with lightning and rain	cloud | cloud with lightning and rain | rain | thunder
          🌤️	Travel & Places	sky & weather	sun behind small cloud
          🌤	Travel & Places	sky & weather	sun behind small cloud	cloud | sun | sun behind small cloud
          🌥️	Travel & Places	sky & weather	sun behind large cloud
          🌥	Travel & Places	sky & weather	sun behind large cloud	cloud | sun | sun behind large cloud
          🌦️	Travel & Places	sky & weather	sun behind rain cloud
          🌦	Travel & Places	sky & weather	sun behind rain cloud	cloud | rain | sun | sun behind rain cloud
          🌧️	Travel & Places	sky & weather	cloud with rain
          🌧	Travel & Places	sky & weather	cloud with rain	cloud | cloud with rain | rain
          🌨️	Travel & Places	sky & weather	cloud with snow
          🌨	Travel & Places	sky & weather	cloud with snow	cloud | cloud with snow | cold | snow
          🌩️	Travel & Places	sky & weather	cloud with lightning
          🌩	Travel & Places	sky & weather	cloud with lightning	cloud | cloud with lightning | lightning
          🌪️	Travel & Places	sky & weather	tornado
          🌪	Travel & Places	sky & weather	tornado	cloud | tornado | whirlwind
          🌫️	Travel & Places	sky & weather	fog
          🌫	Travel & Places	sky & weather	fog	cloud | fog
          🌬️	Travel & Places	sky & weather	wind face
          🌬	Travel & Places	sky & weather	wind face	blow | cloud | face | wind
          🌀	Travel & Places	sky & weather	cyclone	cyclone | dizzy | hurricane | twister | typhoon
          🌈	Travel & Places	sky & weather	rainbow	rain | rainbow
          🌂	Travel & Places	sky & weather	closed umbrella	closed umbrella | clothing | rain | umbrella
          ☂️	Travel & Places	sky & weather	umbrella
          ☂	Travel & Places	sky & weather	umbrella	clothing | rain | umbrella
          ☔	Travel & Places	sky & weather	umbrella with rain drops	clothing | drop | rain | umbrella | umbrella with rain drops
          ⛱️	Travel & Places	sky & weather	umbrella on ground
          ⛱	Travel & Places	sky & weather	umbrella on ground	rain | sun | umbrella | umbrella on ground | beach | sand
          ⚡	Travel & Places	sky & weather	high voltage	danger | electric | high voltage | lightning | voltage | zap
          ❄️	Travel & Places	sky & weather	snowflake
          ❄	Travel & Places	sky & weather	snowflake	cold | snow | snowflake
          ☄️	Travel & Places	sky & weather	comet
          ☄	Travel & Places	sky & weather	comet	comet | space
          🔥	Travel & Places	sky & weather	fire	fire | flame | tool
          💧	Travel & Places	sky & weather	droplet	cold | comic | drop | droplet | sweat
          🌊	Travel & Places	sky & weather	water wave	ocean | water | wave
          🎃	Activities	event	jack-o-lantern	celebration | halloween | jack | jack-o-lantern | lantern | Halloween | jack-o’-lantern
          🎄	Activities	event	Christmas tree	celebration | Christmas | tree
          🎆	Activities	event	fireworks	celebration | fireworks
          🎇	Activities	event	sparkler	celebration | fireworks | sparkle | sparkler
          🧨	Activities	event	firecracker	dynamite | explosive | firecracker | fireworks
          ✨	Activities	event	sparkles	* | sparkle | sparkles | star
          🎈	Activities	event	balloon	balloon | celebration
          🎉	Activities	event	party popper	celebration | party | popper | tada | ta-da
          🎊	Activities	event	confetti ball	ball | celebration | confetti
          🎋	Activities	event	tanabata tree	banner | celebration | Japanese | tanabata tree | tree | Tanabata tree
          🎍	Activities	event	pine decoration	bamboo | celebration | Japanese | pine | pine decoration | decoration
          🎎	Activities	event	Japanese dolls	celebration | doll | festival | Japanese | Japanese dolls
          🎏	Activities	event	carp streamer	carp | celebration | streamer | carp wind sock | Japanese wind socks | koinobori
          🎐	Activities	event	wind chime	bell | celebration | chime | wind
          🎑	Activities	event	moon viewing ceremony	celebration | ceremony | moon | moon viewing ceremony | moon-viewing ceremony
          🧧	Activities	event	red envelope	gift | good luck | hóngbāo | lai see | money | red envelope
          🎀	Activities	event	ribbon	celebration | ribbon
          🎁	Activities	event	wrapped gift	box | celebration | gift | present | wrapped
          🎗️	Activities	event	reminder ribbon
          🎗	Activities	event	reminder ribbon	celebration | reminder | ribbon
          🎟️	Activities	event	admission tickets
          🎟	Activities	event	admission tickets	admission | admission tickets | ticket | entry
          🎫	Activities	event	ticket	admission | ticket
          🎖️	Activities	award-medal	military medal
          🎖	Activities	award-medal	military medal	celebration | medal | military
          🏆	Activities	award-medal	trophy	prize | trophy | celebration
          🏅	Activities	award-medal	sports medal	medal | sports medal | celebration | sports
          🥇	Activities	award-medal	1st place medal	1st place medal | first | gold | medal
          🥈	Activities	award-medal	2nd place medal	2nd place medal | medal | second | silver
          🥉	Activities	award-medal	3rd place medal	3rd place medal | bronze | medal | third
          ⚽	Activities	sport	soccer ball	ball | football | soccer
          ⚾	Activities	sport	baseball	ball | baseball
          🥎	Activities	sport	softball	ball | glove | softball | underarm
          🏀	Activities	sport	basketball	ball | basketball | hoop
          🏐	Activities	sport	volleyball	ball | game | volleyball
          🏈	Activities	sport	american football	american | ball | football
          🏉	Activities	sport	rugby football	ball | football | rugby | australian football | rugby ball | rugby league | rugby union
          🎾	Activities	sport	tennis	ball | racquet | tennis
          🥏	Activities	sport	flying disc	flying disc | ultimate | frisbee | Frisbee
          🎳	Activities	sport	bowling	ball | bowling | game | tenpin bowling
          🏏	Activities	sport	cricket game	ball | bat | cricket game | game | cricket | cricket match
          🏑	Activities	sport	field hockey	ball | field | game | hockey | stick
          🏒	Activities	sport	ice hockey	game | hockey | ice | puck | stick
          🥍	Activities	sport	lacrosse	ball | goal | lacrosse | stick
          🏓	Activities	sport	ping pong	ball | bat | game | paddle | ping pong | table tennis | ping-pong
          🏸	Activities	sport	badminton	badminton | birdie | game | racquet | shuttlecock
          🥊	Activities	sport	boxing glove	boxing | glove
          🥋	Activities	sport	martial arts uniform	judo | karate | martial arts | martial arts uniform | taekwondo | uniform | MMA
          🥅	Activities	sport	goal net	goal | net | goal cage
          ⛳	Activities	sport	flag in hole	flag in hole | golf | hole | flag
          ⛸️	Activities	sport	ice skate
          ⛸	Activities	sport	ice skate	ice | skate | ice skating
          🎣	Activities	sport	fishing pole	fish | fishing pole | pole | fishing | rod | fishing rod
          🤿	Activities	sport	diving mask	diving | diving mask | scuba | snorkeling | snorkelling
          🎽	Activities	sport	running shirt	athletics | running | sash | shirt
          🎿	Activities	sport	skis	ski | skis | snow | skiing
          🛷	Activities	sport	sled	sled | sledge | sleigh
          🥌	Activities	sport	curling stone	curling stone | game | rock | curling | stone | curling rock
          🎯	Activities	game	bullseye	bullseye | dart | direct hit | game | hit | target | bull’s-eye
          🪀	Activities	game	yo-yo	fluctuate | toy | yo-yo
          🪁	Activities	game	kite	fly | kite | soar
          🔫	Activities	game	water pistol	gun | handgun | pistol | revolver | tool | water | weapon | toy | water pistol
          🎱	Activities	game	pool 8 ball	8 | ball | billiard | eight | game | pool 8 ball | magic 8 ball
          🔮	Activities	game	crystal ball	ball | crystal | fairy tale | fantasy | fortune | tool
          🪄	Activities	game	magic wand	magic | magic wand | witch | wizard
          🎮	Activities	game	video game	controller | game | video game
          🕹️	Activities	game	joystick
          🕹	Activities	game	joystick	game | joystick | video game
          🎰	Activities	game	slot machine	game | slot | slot machine | pokie | pokies
          🎲	Activities	game	game die	dice | die | game
          🧩	Activities	game	puzzle piece	clue | interlocking | jigsaw | piece | puzzle
          🧸	Activities	game	teddy bear	plaything | plush | stuffed | teddy bear | toy
          🪅	Activities	game	piñata	celebration | party | piñata
          🪩	Activities	game	mirror ball	dance | disco | glitter | mirror ball | party
          🪆	Activities	game	nesting dolls	doll | nesting | nesting dolls | russia | babushka | matryoshka | Russian dolls | Russia
          ♠️	Activities	game	spade suit
          ♠	Activities	game	spade suit	card | game | spade suit
          ♥️	Activities	game	heart suit
          ♥	Activities	game	heart suit	card | game | heart suit
          ♦️	Activities	game	diamond suit
          ♦	Activities	game	diamond suit	card | diamond suit | game | diamonds
          ♣️	Activities	game	club suit
          ♣	Activities	game	club suit	card | club suit | game | clubs
          ♟️	Activities	game	chess pawn
          ♟	Activities	game	chess pawn	chess | chess pawn | dupe | expendable
          🃏	Activities	game	joker	card | game | joker | wildcard
          🀄	Activities	game	mahjong red dragon	game | mahjong | mahjong red dragon | red | Mahjong | Mahjong red dragon
          🎴	Activities	game	flower playing cards	card | flower | flower playing cards | game | Japanese | playing
          🎭	Activities	arts & crafts	performing arts	art | mask | performing | performing arts | theater | theatre
          🖼️	Activities	arts & crafts	framed picture
          🖼	Activities	arts & crafts	framed picture	art | frame | framed picture | museum | painting | picture
          🎨	Activities	arts & crafts	artist palette	art | artist palette | museum | painting | palette
          🧵	Activities	arts & crafts	thread	needle | sewing | spool | string | thread
          🪡	Activities	arts & crafts	sewing needle	embroidery | needle | sewing | stitches | sutures | tailoring | needle and thread
          🧶	Activities	arts & crafts	yarn	ball | crochet | knit | yarn
          🪢	Activities	arts & crafts	knot	knot | rope | tangled | tie | twine | twist
          👓	Objects	clothing	glasses	clothing | eye | eyeglasses | eyewear | glasses
          🕶️	Objects	clothing	sunglasses
          🕶	Objects	clothing	sunglasses	dark | eye | eyewear | glasses | sunglasses | sunnies
          🥽	Objects	clothing	goggles	eye protection | goggles | swimming | welding
          🦺	Objects	clothing	safety vest	emergency | safety | vest | hi-vis | high-vis | jacket | life jacket
          👔	Objects	clothing	necktie	clothing | necktie | tie
          👕	Objects	clothing	t-shirt	clothing | shirt | t-shirt | tshirt | T-shirt | tee | tee-shirt
          👖	Objects	clothing	jeans	clothing | jeans | pants | trousers
          🧣	Objects	clothing	scarf	neck | scarf
          🧤	Objects	clothing	gloves	gloves | hand
          🧥	Objects	clothing	coat	coat | jacket
          🧦	Objects	clothing	socks	socks | stocking
          👘	Objects	clothing	kimono	clothing | kimono
          🥻	Objects	clothing	sari	clothing | dress | sari
          🩱	Objects	clothing	one-piece swimsuit	bathing suit | one-piece swimsuit | swimming costume
          🩲	Objects	clothing	briefs	bathing suit | briefs | one-piece | swimsuit | underwear | pants | bathers | speedos
          🩳	Objects	clothing	shorts	bathing suit | pants | shorts | underwear | boardshorts | swim shorts | boardies
          👙	Objects	clothing	bikini	bikini | clothing | swim | swim suit | two-piece
          🪭	Objects	clothing	folding hand fan	cooling | dance | fan | flutter | folding hand fan | hot | shy
          👛	Objects	clothing	purse	clothing | coin | purse | accessories
          👜	Objects	clothing	handbag	bag | clothing | handbag | purse | accessories | tote
          👝	Objects	clothing	clutch bag	bag | clothing | clutch bag | pouch | accessories
          🛍️	Objects	clothing	shopping bags
          🛍	Objects	clothing	shopping bags	bag | hotel | shopping | shopping bags
          🎒	Objects	clothing	backpack	backpack | bag | rucksack | satchel | school
          🩴	Objects	clothing	thong sandal	beach sandals | sandals | thong sandal | thong sandals | thongs | zōri | flip-flop | flipflop | zori | beach sandal | sandal | thong
          👟	Objects	clothing	running shoe	athletic | clothing | running shoe | shoe | sneaker | runners | trainer
          🥾	Objects	clothing	hiking boot	backpacking | boot | camping | hiking
          🥿	Objects	clothing	flat shoe	ballet flat | flat shoe | slip-on | slipper | pump
          🩰	Objects	clothing	ballet shoes	ballet | ballet shoes | dance
          🪮	Objects	clothing	hair pick	Afro | comb | hair | pick
          👑	Objects	clothing	crown	clothing | crown | king | queen
          🎩	Objects	clothing	top hat	clothing | hat | top | tophat
          🎓	Objects	clothing	graduation cap	cap | celebration | clothing | graduation | hat
          🧢	Objects	clothing	billed cap	baseball cap | billed cap
          🪖	Objects	clothing	military helmet	army | helmet | military | soldier | warrior
          ⛑️	Objects	clothing	rescue worker’s helmet
          ⛑	Objects	clothing	rescue worker’s helmet	aid | cross | face | hat | helmet | rescue worker’s helmet
          📿	Objects	clothing	prayer beads	beads | clothing | necklace | prayer | religion
          💄	Objects	clothing	lipstick	cosmetics | lipstick | makeup | make-up
          💍	Objects	clothing	ring	diamond | ring
          💎	Objects	clothing	gem stone	diamond | gem | gem stone | jewel | gemstone
          🔇	Objects	sound	muted speaker	mute | muted speaker | quiet | silent | speaker
          🔈	Objects	sound	speaker low volume	soft | speaker low volume | low | quiet | speaker | volume
          🔉	Objects	sound	speaker medium volume	medium | speaker medium volume
          🔊	Objects	sound	speaker high volume	loud | speaker high volume
          📢	Objects	sound	loudspeaker	loud | loudspeaker | public address
          📣	Objects	sound	megaphone	cheering | megaphone
          📯	Objects	sound	postal horn	horn | post | postal
          🔔	Objects	sound	bell	bell
          🔕	Objects	sound	bell with slash	bell | bell with slash | forbidden | mute | quiet | silent
          🎼	Objects	music	musical score	music | musical score | score
          🎵	Objects	music	musical note	music | musical note | note
          🎶	Objects	music	musical notes	music | musical notes | note | notes
          🎙️	Objects	music	studio microphone
          🎙	Objects	music	studio microphone	mic | microphone | music | studio
          🎚️	Objects	music	level slider
          🎚	Objects	music	level slider	level | music | slider
          🎛️	Objects	music	control knobs
          🎛	Objects	music	control knobs	control | knobs | music
          🎤	Objects	music	microphone	karaoke | mic | microphone
          🎧	Objects	music	headphone	earbud | headphone
          📻	Objects	music	radio	radio | video | AM | FM | wireless
          📱	Objects	phone	mobile phone	cell | mobile | phone | telephone
          📲	Objects	phone	mobile phone with arrow	arrow | cell | mobile | mobile phone with arrow | phone | receive
          ☎️	Objects	phone	telephone
          ☎	Objects	phone	telephone	phone | telephone | landline
          📞	Objects	phone	telephone receiver	phone | receiver | telephone
          📟	Objects	phone	pager	pager
          📠	Objects	phone	fax machine	fax | fax machine
          🔋	Objects	computer	battery	battery
          🪫	Objects	computer	low battery	electronic | low battery | low energy
          🔌	Objects	computer	electric plug	electric | electricity | plug
          💻	Objects	computer	laptop	computer | laptop | pc | personal | PC
          🖥️	Objects	computer	desktop computer
          🖥	Objects	computer	desktop computer	computer | desktop
          🖨️	Objects	computer	printer
          🖨	Objects	computer	printer	computer | printer
          ⌨️	Objects	computer	keyboard
          ⌨	Objects	computer	keyboard	computer | keyboard
          🖱️	Objects	computer	computer mouse
          🖱	Objects	computer	computer mouse	computer | computer mouse
          🖲️	Objects	computer	trackball
          🖲	Objects	computer	trackball	computer | trackball
          💽	Objects	computer	computer disk	computer | disk | minidisk | optical
          💾	Objects	computer	floppy disk	computer | disk | floppy | diskette
          💿	Objects	computer	optical disk	CD | computer | disk | optical
          📀	Objects	computer	dvd	Blu-ray | computer | disk | dvd | DVD | optical | blu-ray
          🧮	Objects	computer	abacus	abacus | calculation
          🎥	Objects	light & video	movie camera	camera | cinema | movie
          🎞️	Objects	light & video	film frames
          🎞	Objects	light & video	film frames	cinema | film | frames | movie
          📽️	Objects	light & video	film projector
          📽	Objects	light & video	film projector	cinema | film | movie | projector | video
          🎬	Objects	light & video	clapper board	clapper | clapper board | movie | clapperboard | film
          📺	Objects	light & video	television	television | tv | video | TV
          📷	Objects	light & video	camera	camera | video
          📸	Objects	light & video	camera with flash	camera | camera with flash | flash | video
          📹	Objects	light & video	video camera	camera | video
          📼	Objects	light & video	videocassette	tape | vhs | video | videocassette | VHS | videotape
          🔍	Objects	light & video	magnifying glass tilted left	glass | magnifying | magnifying glass tilted left | search | tool
          🔎	Objects	light & video	magnifying glass tilted right	glass | magnifying | magnifying glass tilted right | search | tool
          🕯️	Objects	light & video	candle
          🕯	Objects	light & video	candle	candle | light
          💡	Objects	light & video	light bulb	bulb | comic | electric | idea | light | globe
          🔦	Objects	light & video	flashlight	electric | flashlight | light | tool | torch
          🏮	Objects	light & video	red paper lantern	bar | lantern | light | red | red paper lantern
          🪔	Objects	light & video	diya lamp	diya | lamp | oil
          📔	Objects	book-paper	notebook with decorative cover	book | cover | decorated | notebook | notebook with decorative cover
          📕	Objects	book-paper	closed book	book | closed
          📖	Objects	book-paper	open book	book | open
          📗	Objects	book-paper	green book	book | green
          📘	Objects	book-paper	blue book	blue | book
          📙	Objects	book-paper	orange book	book | orange
          📚	Objects	book-paper	books	book | books
          📓	Objects	book-paper	notebook	notebook
          📒	Objects	book-paper	ledger	ledger | notebook
          📜	Objects	book-paper	scroll	paper | scroll
          📰	Objects	book-paper	newspaper	news | newspaper | paper
          🗞️	Objects	book-paper	rolled-up newspaper
          🗞	Objects	book-paper	rolled-up newspaper	news | newspaper | paper | rolled | rolled-up newspaper
          📑	Objects	book-paper	bookmark tabs	bookmark | mark | marker | tabs
          🔖	Objects	book-paper	bookmark	bookmark | mark
          🏷️	Objects	book-paper	label
          🏷	Objects	book-paper	label	label | tag
          💰	Objects	money	money bag	bag | dollar | money | moneybag
          🪙	Objects	money	coin	coin | gold | metal | money | silver | treasure
          💴	Objects	money	yen banknote	banknote | bill | currency | money | note | yen
          💵	Objects	money	dollar banknote	banknote | bill | currency | dollar | money | note
          💶	Objects	money	euro banknote	banknote | bill | currency | euro | money | note
          💷	Objects	money	pound banknote	banknote | bill | currency | money | note | pound | sterling
          💸	Objects	money	money with wings	banknote | bill | fly | money | money with wings | wings
          💳	Objects	money	credit card	card | credit | money
          🧾	Objects	money	receipt	accounting | bookkeeping | evidence | proof | receipt
          💹	Objects	money	chart increasing with yen	chart | chart increasing with yen | graph | growth | money | yen | graph increasing with yen
          ✉️	Objects	mail	envelope
          ✉	Objects	mail	envelope	email | envelope | letter | e-mail
          📧	Objects	mail	e-mail	e-mail | email | letter | mail
          📨	Objects	mail	incoming envelope	e-mail | email | envelope | incoming | letter | receive
          📩	Objects	mail	envelope with arrow	arrow | e-mail | email | envelope | envelope with arrow | outgoing
          📤	Objects	mail	outbox tray	box | letter | mail | outbox | sent | tray | out tray
          📥	Objects	mail	inbox tray	box | inbox | letter | mail | receive | tray | in tray
          📦	Objects	mail	package	box | package | parcel
          📫	Objects	mail	closed mailbox with raised flag	closed | closed mailbox with raised flag | mail | mailbox | postbox | closed postbox with raised flag | letterbox | post | post box | closed letterbox with raised flag
          📪	Objects	mail	closed mailbox with lowered flag	closed | closed mailbox with lowered flag | lowered | mail | mailbox | postbox | closed postbox with lowered flag | letterbox | post box | closed letterbox with lowered flag | post
          📬	Objects	mail	open mailbox with raised flag	mail | mailbox | open | open mailbox with raised flag | postbox | open postbox with raised flag | post | post box | open letterbox with raised flag
          📭	Objects	mail	open mailbox with lowered flag	lowered | mail | mailbox | open | open mailbox with lowered flag | postbox | open postbox with lowered flag | post | post box | open letterbox with lowered flag
          📮	Objects	mail	postbox	mail | mailbox | postbox | post | post box
          🗳️	Objects	mail	ballot box with ballot
          🗳	Objects	mail	ballot box with ballot	ballot | ballot box with ballot | box
          ✏️	Objects	writing	pencil
          ✏	Objects	writing	pencil	pencil
          ✒️	Objects	writing	black nib
          ✒	Objects	writing	black nib	black nib | nib | pen
          🖋️	Objects	writing	fountain pen
          🖋	Objects	writing	fountain pen	fountain | pen
          🖊️	Objects	writing	pen
          🖊	Objects	writing	pen	ballpoint | pen
          🖌️	Objects	writing	paintbrush
          🖌	Objects	writing	paintbrush	paintbrush | painting
          🖍️	Objects	writing	crayon
          🖍	Objects	writing	crayon	crayon
          📝	Objects	writing	memo	memo | pencil
          💼	Objects	office	briefcase	briefcase
          📁	Objects	office	file folder	file | folder
          📂	Objects	office	open file folder	file | folder | open
          🗂️	Objects	office	card index dividers
          🗂	Objects	office	card index dividers	card | dividers | index
          📅	Objects	office	calendar	calendar | date
          📆	Objects	office	tear-off calendar	calendar | tear-off calendar
          🗒️	Objects	office	spiral notepad
          🗒	Objects	office	spiral notepad	note | pad | spiral | spiral notepad
          🗓️	Objects	office	spiral calendar
          🗓	Objects	office	spiral calendar	calendar | pad | spiral
          📇	Objects	office	card index	card | index | rolodex
          📈	Objects	office	chart increasing	chart | chart increasing | graph | growth | trend | upward | graph increasing
          📉	Objects	office	chart decreasing	chart | chart decreasing | down | graph | trend | graph decreasing
          📊	Objects	office	bar chart	bar | chart | graph
          📋	Objects	office	clipboard	clipboard
          📌	Objects	office	pushpin	pin | pushpin | drawing-pin
          📍	Objects	office	round pushpin	pin | pushpin | round pushpin | round drawing-pin
          📎	Objects	office	paperclip	paperclip
          🖇️	Objects	office	linked paperclips
          🖇	Objects	office	linked paperclips	link | linked paperclips | paperclip
          📏	Objects	office	straight ruler	ruler | straight edge | straight ruler
          📐	Objects	office	triangular ruler	ruler | set | triangle | triangular ruler | set square
          ✂️	Objects	office	scissors
          ✂	Objects	office	scissors	cutting | scissors | tool
          🗃️	Objects	office	card file box
          🗃	Objects	office	card file box	box | card | file
          🗄️	Objects	office	file cabinet
          🗄	Objects	office	file cabinet	cabinet | file | filing
          🗑️	Objects	office	wastebasket
          🗑	Objects	office	wastebasket	wastebasket | rubbish bin | trash | waste paper basket
          🔒	Objects	lock	locked	closed | locked | padlock
          🔓	Objects	lock	unlocked	lock | open | unlock | unlocked | padlock
          🔏	Objects	lock	locked with pen	ink | lock | locked with pen | nib | pen | privacy
          🔐	Objects	lock	locked with key	closed | key | lock | locked with key | secure
          🔑	Objects	lock	key	key | lock | password
          🗝️	Objects	lock	old key
          🗝	Objects	lock	old key	clue | key | lock | old
          🔨	Objects	tool	hammer	hammer | tool
          🪓	Objects	tool	axe	axe | chop | hatchet | split | wood
          ⛏️	Objects	tool	pick
          ⛏	Objects	tool	pick	mining | pick | tool
          ⚒️	Objects	tool	hammer and pick
          ⚒	Objects	tool	hammer and pick	hammer | hammer and pick | pick | tool
          🛠️	Objects	tool	hammer and wrench
          🛠	Objects	tool	hammer and wrench	hammer | hammer and wrench | spanner | tool | wrench | hammer and spanner
          🗡️	Objects	tool	dagger
          🗡	Objects	tool	dagger	dagger | knife | weapon
          ⚔️	Objects	tool	crossed swords
          ⚔	Objects	tool	crossed swords	crossed | swords | weapon
          💣	Objects	tool	bomb	bomb | comic
          🪃	Objects	tool	boomerang	boomerang | rebound | repercussion
          🏹	Objects	tool	bow and arrow	archer | arrow | bow | bow and arrow | Sagittarius | zodiac
          🛡️	Objects	tool	shield
          🛡	Objects	tool	shield	shield | weapon
          🪚	Objects	tool	carpentry saw	carpenter | carpentry saw | lumber | saw | tool
          🔧	Objects	tool	wrench	spanner | tool | wrench
          🪛	Objects	tool	screwdriver	screw | screwdriver | tool
          🔩	Objects	tool	nut and bolt	bolt | nut | nut and bolt | tool
          ⚙️	Objects	tool	gear
          ⚙	Objects	tool	gear	cog | cogwheel | gear | tool
          🗜️	Objects	tool	clamp
          🗜	Objects	tool	clamp	clamp | compress | tool | vice
          ⚖️	Objects	tool	balance scale
          ⚖	Objects	tool	balance scale	balance | justice | Libra | scale | zodiac
          🦯	Objects	tool	white cane	accessibility | blind | white cane | guide cane | long mobility cane
          🔗	Objects	tool	link	link
          ⛓️	Objects	tool	chains
          ⛓	Objects	tool	chains	chain | chains
          🪝	Objects	tool	hook	catch | crook | curve | ensnare | hook | selling point | fishing
          🧰	Objects	tool	toolbox	chest | mechanic | tool | toolbox
          🧲	Objects	tool	magnet	attraction | horseshoe | magnet | magnetic
          🪜	Objects	tool	ladder	climb | ladder | rung | step
          ⚗️	Objects	science	alembic
          ⚗	Objects	science	alembic	alembic | chemistry | tool
          🧫	Objects	science	petri dish	bacteria | biologist | biology | culture | lab | petri dish
          🧬	Objects	science	dna	biologist | dna | evolution | gene | genetics | life | DNA
          🔬	Objects	science	microscope	microscope | science | tool
          🔭	Objects	science	telescope	science | telescope | tool
          📡	Objects	science	satellite antenna	antenna | dish | satellite
          💉	Objects	medical	syringe	medicine | needle | shot | sick | syringe | ill | injection
          💊	Objects	medical	pill	doctor | medicine | pill | sick | capsule
          🩹	Objects	medical	adhesive bandage	adhesive bandage | bandage | injury | plaster | sticking plaster | bandaid | dressing
          🩼	Objects	medical	crutch	cane | crutch | disability | hurt | mobility aid | stick
          🩺	Objects	medical	stethoscope	doctor | heart | medicine | stethoscope
          🩻	Objects	medical	x-ray	bones | doctor | medical | skeleton | x-ray | X-ray
          🚪	Objects	household	door	door
          🛗	Objects	household	elevator	accessibility | elevator | hoist | lift
          🪞	Objects	household	mirror	mirror | reflection | reflector | speculum | looking glass
          🪟	Objects	household	window	frame | fresh air | opening | transparent | view | window
          🛏️	Objects	household	bed
          🛏	Objects	household	bed	bed | hotel | sleep
          🛋️	Objects	household	couch and lamp
          🛋	Objects	household	couch and lamp	couch | couch and lamp | hotel | lamp | sofa | sofa and lamp
          🪑	Objects	household	chair	chair | seat | sit
          🚽	Objects	household	toilet	toilet | facilities | loo | WC | lavatory
          🪠	Objects	household	plunger	force cup | plumber | plunger | suction | toilet
          🚿	Objects	household	shower	shower | water
          🛁	Objects	household	bathtub	bath | bathtub
          🪤	Objects	household	mouse trap	bait | mouse trap | mousetrap | snare | trap | mouse
          🪒	Objects	household	razor	razor | sharp | shave | cut-throat
          🧴	Objects	household	lotion bottle	lotion | lotion bottle | moisturizer | shampoo | sunscreen | moisturiser
          🧷	Objects	household	safety pin	diaper | punk rock | safety pin | nappy
          🧹	Objects	household	broom	broom | cleaning | sweeping | witch
          🧺	Objects	household	basket	basket | farming | laundry | picnic
          🧻	Objects	household	roll of paper	paper towels | roll of paper | toilet paper | toilet roll
          🪣	Objects	household	bucket	bucket | cask | pail | vat
          🧼	Objects	household	soap	bar | bathing | cleaning | lather | soap | soapdish
          🫧	Objects	household	bubbles	bubbles | burp | clean | soap | underwater
          🪥	Objects	household	toothbrush	bathroom | brush | clean | dental | hygiene | teeth | toothbrush
          🧽	Objects	household	sponge	absorbing | cleaning | porous | sponge
          🧯	Objects	household	fire extinguisher	extinguish | fire | fire extinguisher | quench
          🛒	Objects	household	shopping cart	cart | shopping | trolley | basket
          🚬	Objects	other-object	cigarette	cigarette | smoking
          ⚰️	Objects	other-object	coffin
          ⚰	Objects	other-object	coffin	coffin | death | casket
          🪦	Objects	other-object	headstone	cemetery | grave | graveyard | headstone | tombstone
          ⚱️	Objects	other-object	funeral urn
          ⚱	Objects	other-object	funeral urn	ashes | death | funeral | urn
          🪬	Objects	other-object	hamsa	amulet | Fatima | hamsa | hand | Mary | Miriam | protection
          🗿	Objects	other-object	moai	face | moai | moyai | statue
          🪧	Objects	other-object	placard	demonstration | picket | placard | protest | sign
          🪪	Objects	other-object	identification card	credentials | ID | identification card | license | security | driving | licence
          🏧	Symbols	transport-sign	ATM sign	ATM | ATM sign | automated | bank | teller
          🚮	Symbols	transport-sign	litter in bin sign	litter | litter bin | litter in bin sign | garbage | trash
          🚰	Symbols	transport-sign	potable water	drinking | potable | water
          ♿	Symbols	transport-sign	wheelchair symbol	access | wheelchair symbol | disabled access
          🚻	Symbols	transport-sign	restroom	bathroom | lavatory | restroom | toilet | WC | washroom
          🚼	Symbols	transport-sign	baby symbol	baby | baby symbol | changing | change room
          🛂	Symbols	transport-sign	passport control	control | passport | border | security
          🛃	Symbols	transport-sign	customs	customs
          🛄	Symbols	transport-sign	baggage claim	baggage | claim
          🛅	Symbols	transport-sign	left luggage	baggage | left luggage | locker | luggage
          ⚠️	Symbols	warning	warning
          ⚠	Symbols	warning	warning	warning
          🚸	Symbols	warning	children crossing	child | children crossing | crossing | pedestrian | traffic
          ⛔	Symbols	warning	no entry	entry | forbidden | no | not | prohibited | traffic | denied
          🚫	Symbols	warning	prohibited	entry | forbidden | no | not | prohibited | denied
          🚳	Symbols	warning	no bicycles	bicycle | bike | forbidden | no | no bicycles | prohibited
          🚭	Symbols	warning	no smoking	forbidden | no | not | prohibited | smoking | denied
          🚯	Symbols	warning	no littering	forbidden | litter | no | no littering | not | prohibited | denied
          🚱	Symbols	warning	non-potable water	non-drinking | non-potable | water | non-drinkable water
          🚷	Symbols	warning	no pedestrians	forbidden | no | no pedestrians | not | pedestrian | prohibited | denied
          📵	Symbols	warning	no mobile phones	cell | forbidden | mobile | no | no mobile phones | phone
          🔞	Symbols	warning	no one under eighteen	18 | age restriction | eighteen | no one under eighteen | prohibited | underage
          ☢️	Symbols	warning	radioactive
          ☢	Symbols	warning	radioactive	radioactive | sign
          ☣️	Symbols	warning	biohazard
          ☣	Symbols	warning	biohazard	biohazard | sign
          ⬆️	Symbols	arrow	up arrow
          ⬆	Symbols	arrow	up arrow	arrow | cardinal | direction | north | up arrow | up
          ↗️	Symbols	arrow	up-right arrow
          ↗	Symbols	arrow	up-right arrow	arrow | direction | intercardinal | northeast | up-right arrow
          ➡️	Symbols	arrow	right arrow
          ➡	Symbols	arrow	right arrow	arrow | cardinal | direction | east | right arrow
          ↘️	Symbols	arrow	down-right arrow
          ↘	Symbols	arrow	down-right arrow	arrow | direction | down-right arrow | intercardinal | southeast
          ⬇️	Symbols	arrow	down arrow
          ⬇	Symbols	arrow	down arrow	arrow | cardinal | direction | down | south
          ↙️	Symbols	arrow	down-left arrow
          ↙	Symbols	arrow	down-left arrow	arrow | direction | down-left arrow | intercardinal | southwest
          ⬅️	Symbols	arrow	left arrow
          ⬅	Symbols	arrow	left arrow	arrow | cardinal | direction | left arrow | west
          ↖️	Symbols	arrow	up-left arrow
          ↖	Symbols	arrow	up-left arrow	arrow | direction | intercardinal | northwest | up-left arrow
          ↕️	Symbols	arrow	up-down arrow
          ↕	Symbols	arrow	up-down arrow	arrow | up-down arrow
          ↔️	Symbols	arrow	left-right arrow
          ↔	Symbols	arrow	left-right arrow	arrow | left-right arrow
          ↩️	Symbols	arrow	right arrow curving left
          ↩	Symbols	arrow	right arrow curving left	arrow | right arrow curving left
          ↪️	Symbols	arrow	left arrow curving right
          ↪	Symbols	arrow	left arrow curving right	arrow | left arrow curving right
          ⤴️	Symbols	arrow	right arrow curving up
          ⤴	Symbols	arrow	right arrow curving up	arrow | right arrow curving up
          ⤵️	Symbols	arrow	right arrow curving down
          ⤵	Symbols	arrow	right arrow curving down	arrow | down | right arrow curving down
          🔃	Symbols	arrow	clockwise vertical arrows	arrow | clockwise | clockwise vertical arrows | reload
          🔄	Symbols	arrow	counterclockwise arrows button	anticlockwise | arrow | counterclockwise | counterclockwise arrows button | withershins | anticlockwise arrows button
          🔙	Symbols	arrow	BACK arrow	arrow | BACK
          🔚	Symbols	arrow	END arrow	arrow | END
          🔛	Symbols	arrow	ON! arrow	arrow | mark | ON | ON!
          🔜	Symbols	arrow	SOON arrow	arrow | SOON
          🔝	Symbols	arrow	TOP arrow	arrow | TOP | up
          🛐	Symbols	religion	place of worship	place of worship | religion | worship
          ⚛️	Symbols	religion	atom symbol
          ⚛	Symbols	religion	atom symbol	atheist | atom | atom symbol
          🕉️	Symbols	religion	om
          🕉	Symbols	religion	om	Hindu | om | religion
          ✡️	Symbols	religion	star of David
          ✡	Symbols	religion	star of David	David | Jew | Jewish | religion | star | star of David | Judaism | Star of David
          ☸️	Symbols	religion	wheel of dharma
          ☸	Symbols	religion	wheel of dharma	Buddhist | dharma | religion | wheel | wheel of dharma
          ☯️	Symbols	religion	yin yang
          ☯	Symbols	religion	yin yang	religion | tao | taoist | yang | yin | Tao | Taoist
          ✝️	Symbols	religion	latin cross
          ✝	Symbols	religion	latin cross	Christian | cross | latin cross | religion | Latin cross
          ☦️	Symbols	religion	orthodox cross
          ☦	Symbols	religion	orthodox cross	Christian | cross | orthodox cross | religion | Orthodox cross
          ☪️	Symbols	religion	star and crescent
          ☪	Symbols	religion	star and crescent	islam | Muslim | religion | star and crescent | Islam
          ☮️	Symbols	religion	peace symbol
          ☮	Symbols	religion	peace symbol	peace | peace symbol
          🔯	Symbols	religion	dotted six-pointed star	dotted six-pointed star | fortune | star
          🪯	Symbols	religion	khanda	khanda | religion | Sikh
          ♈	Symbols	zodiac	Aries	Aries | ram | zodiac
          ♉	Symbols	zodiac	Taurus	bull | ox | Taurus | zodiac
          ♊	Symbols	zodiac	Gemini	Gemini | twins | zodiac
          ♋	Symbols	zodiac	Cancer	Cancer | crab | zodiac
          ♌	Symbols	zodiac	Leo	Leo | lion | zodiac
          ♍	Symbols	zodiac	Virgo	Virgo | zodiac | virgin
          ♎	Symbols	zodiac	Libra	balance | justice | Libra | scales | zodiac
          ♏	Symbols	zodiac	Scorpio	Scorpio | scorpion | scorpius | zodiac | Scorpius
          ♐	Symbols	zodiac	Sagittarius	archer | Sagittarius | zodiac | centaur
          ♑	Symbols	zodiac	Capricorn	Capricorn | goat | zodiac
          ♒	Symbols	zodiac	Aquarius	Aquarius | bearer | water | zodiac | water bearer
          ♓	Symbols	zodiac	Pisces	fish | Pisces | zodiac
          ⛎	Symbols	zodiac	Ophiuchus	bearer | Ophiuchus | serpent | snake | zodiac
          🔀	Symbols	av-symbol	shuffle tracks button	arrow | crossed | shuffle tracks button
          🔁	Symbols	av-symbol	repeat button	arrow | clockwise | repeat | repeat button
          🔂	Symbols	av-symbol	repeat single button	arrow | clockwise | once | repeat single button
          ▶️	Symbols	av-symbol	play button
          ▶	Symbols	av-symbol	play button	arrow | play | play button | right | triangle
          ⏩	Symbols	av-symbol	fast-forward button	arrow | double | fast | fast-forward button | forward | fast forward button
          ⏭️	Symbols	av-symbol	next track button
          ⏭	Symbols	av-symbol	next track button	arrow | next scene | next track | next track button | triangle
          ⏯️	Symbols	av-symbol	play or pause button
          ⏯	Symbols	av-symbol	play or pause button	arrow | pause | play | play or pause button | right | triangle
          ◀️	Symbols	av-symbol	reverse button
          ◀	Symbols	av-symbol	reverse button	arrow | left | reverse | reverse button | triangle
          ⏪	Symbols	av-symbol	fast reverse button	arrow | double | fast reverse button | rewind
          ⏮️	Symbols	av-symbol	last track button
          ⏮	Symbols	av-symbol	last track button	arrow | last track button | previous scene | previous track | triangle
          🔼	Symbols	av-symbol	upwards button	arrow | button | upwards button | red | upward button
          ⏫	Symbols	av-symbol	fast up button	arrow | double | fast up button
          🔽	Symbols	av-symbol	downwards button	arrow | button | down | downwards button | downward button | red
          ⏬	Symbols	av-symbol	fast down button	arrow | double | down | fast down button
          ⏸️	Symbols	av-symbol	pause button
          ⏸	Symbols	av-symbol	pause button	bar | double | pause | pause button | vertical
          ⏹️	Symbols	av-symbol	stop button
          ⏹	Symbols	av-symbol	stop button	square | stop | stop button
          ⏺️	Symbols	av-symbol	record button
          ⏺	Symbols	av-symbol	record button	circle | record | record button
          ⏏️	Symbols	av-symbol	eject button
          ⏏	Symbols	av-symbol	eject button	eject | eject button
          🎦	Symbols	av-symbol	cinema	camera | cinema | film | movie
          🔅	Symbols	av-symbol	dim button	brightness | dim | dim button | low
          🔆	Symbols	av-symbol	bright button	bright | bright button | brightness | brightness button
          📶	Symbols	av-symbol	antenna bars	antenna | antenna bars | bar | cell | mobile | phone
          🛜	Symbols	av-symbol	wireless	computer | internet | network | wireless | Wi-Fi | wifi
          📳	Symbols	av-symbol	vibration mode	cell | mobile | mode | phone | telephone | vibration | vibrate
          📴	Symbols	av-symbol	mobile phone off	cell | mobile | off | phone | telephone
          ♀️	Symbols	gender	female sign
          ♂️	Symbols	gender	male sign
          ⚧️	Symbols	gender	transgender symbol
          ⚧	Symbols	gender	transgender symbol	transgender | transgender symbol | trans
          ✖️	Symbols	math	multiply
          ✖	Symbols	math	multiply	× | cancel | multiplication | multiply | sign | x | heavy multiplication sign
          ➕	Symbols	math	plus	+ | math | plus | sign | maths | add | addition
          ➖	Symbols	math	minus	- | − | math | minus | sign | heavy minus sign | maths | – | subtraction
          ➗	Symbols	math	divide	÷ | divide | division | math | sign
          🟰	Symbols	math	heavy equals sign	equality | heavy equals sign | math | maths
          ♾️	Symbols	math	infinity
          ♾	Symbols	math	infinity	forever | infinity | unbounded | universal | eternal | unbound
          ‼️	Symbols	punctuation	double exclamation mark
          ‼	Symbols	punctuation	double exclamation mark	! | !! | bangbang | double exclamation mark | exclamation | mark | punctuation
          ⁉️	Symbols	punctuation	exclamation question mark
          ⁉	Symbols	punctuation	exclamation question mark	! | !? | ? | exclamation | interrobang | mark | punctuation | question | exclamation question mark
          ❓	Symbols	punctuation	red question mark	? | mark | punctuation | question | red question mark
          ❔	Symbols	punctuation	white question mark	? | mark | outlined | punctuation | question | white question mark
          ❕	Symbols	punctuation	white exclamation mark	! | exclamation | mark | outlined | punctuation | white exclamation mark
          ❗	Symbols	punctuation	red exclamation mark	! | exclamation | mark | punctuation | red exclamation mark
          〰️	Symbols	punctuation	wavy dash
          〰	Symbols	punctuation	wavy dash	dash | punctuation | wavy
          💱	Symbols	currency	currency exchange	bank | currency | exchange | money
          💲	Symbols	currency	heavy dollar sign	currency | dollar | heavy dollar sign | money
          ⚕️	Symbols	other-symbol	medical symbol
          ⚕	Symbols	other-symbol	medical symbol	aesculapius | medical symbol | medicine | staff
          ♻️	Symbols	other-symbol	recycling symbol
          ♻	Symbols	other-symbol	recycling symbol	recycle | recycling symbol
          ⚜️	Symbols	other-symbol	fleur-de-lis
          ⚜	Symbols	other-symbol	fleur-de-lis	fleur-de-lis
          🔱	Symbols	other-symbol	trident emblem	anchor | emblem | ship | tool | trident
          📛	Symbols	other-symbol	name badge	badge | name
          🔰	Symbols	other-symbol	Japanese symbol for beginner	beginner | chevron | Japanese | Japanese symbol for beginner | leaf
          ⭕	Symbols	other-symbol	hollow red circle	circle | hollow red circle | large | o | red
          ✅	Symbols	other-symbol	check mark button	✓ | button | check | mark | tick
          ☑️	Symbols	other-symbol	check box with check
          ☑	Symbols	other-symbol	check box with check	✓ | box | check | check box with check | tick | tick box with tick | ballot
          ✔️	Symbols	other-symbol	check mark
          ✔	Symbols	other-symbol	check mark	✓ | check | mark | tick | check mark | heavy tick mark
          ❌	Symbols	other-symbol	cross mark	× | cancel | cross | mark | multiplication | multiply | x
          ❎	Symbols	other-symbol	cross mark button	× | cross mark button | mark | square | x
          ➰	Symbols	other-symbol	curly loop	curl | curly loop | loop
          ➿	Symbols	other-symbol	double curly loop	curl | double | double curly loop | loop
          〽️	Symbols	other-symbol	part alternation mark
          〽	Symbols	other-symbol	part alternation mark	mark | part | part alternation mark
          ✳️	Symbols	other-symbol	eight-spoked asterisk
          ✳	Symbols	other-symbol	eight-spoked asterisk	* | asterisk | eight-spoked asterisk
          ✴️	Symbols	other-symbol	eight-pointed star
          ✴	Symbols	other-symbol	eight-pointed star	* | eight-pointed star | star
          ❇️	Symbols	other-symbol	sparkle
          ❇	Symbols	other-symbol	sparkle	* | sparkle
          ©️	Symbols	other-symbol	copyright
          ©	Symbols	other-symbol	copyright	C | copyright
          ®️	Symbols	other-symbol	registered
          ®	Symbols	other-symbol	registered	R | registered | r | trademark
          ™️	Symbols	other-symbol	trade mark
          ™	Symbols	other-symbol	trade mark	mark | TM | trade mark | trademark
          #️⃣	Symbols	keycap	keycap: #
          #⃣	Symbols	keycap	keycap: #	keycap
          *️⃣	Symbols	keycap	keycap: *
          *⃣	Symbols	keycap	keycap: *	keycap
          0️⃣	Symbols	keycap	keycap: 0
          0⃣	Symbols	keycap	keycap: 0	keycap
          1️⃣	Symbols	keycap	keycap: 1
          1⃣	Symbols	keycap	keycap: 1	keycap
          2️⃣	Symbols	keycap	keycap: 2
          2⃣	Symbols	keycap	keycap: 2	keycap
          3️⃣	Symbols	keycap	keycap: 3
          3⃣	Symbols	keycap	keycap: 3	keycap
          4️⃣	Symbols	keycap	keycap: 4
          4⃣	Symbols	keycap	keycap: 4	keycap
          5️⃣	Symbols	keycap	keycap: 5
          5⃣	Symbols	keycap	keycap: 5	keycap
          6️⃣	Symbols	keycap	keycap: 6
          6⃣	Symbols	keycap	keycap: 6	keycap
          7️⃣	Symbols	keycap	keycap: 7
          7⃣	Symbols	keycap	keycap: 7	keycap
          8️⃣	Symbols	keycap	keycap: 8
          8⃣	Symbols	keycap	keycap: 8	keycap
          9️⃣	Symbols	keycap	keycap: 9
          9⃣	Symbols	keycap	keycap: 9	keycap
          🔟	Symbols	keycap	keycap: 10	keycap
          🔠	Symbols	alphanum	input latin uppercase	ABCD | input | latin | letters | uppercase | input Latin uppercase | Latin
          🔡	Symbols	alphanum	input latin lowercase	abcd | input | latin | letters | lowercase | input Latin lowercase | Latin
          🔢	Symbols	alphanum	input numbers	1234 | input | numbers
          🔣	Symbols	alphanum	input symbols	〒♪&% | input | input symbols
          🔤	Symbols	alphanum	input latin letters	abc | alphabet | input | latin | letters | input Latin letters | Latin
          🅰️	Symbols	alphanum	A button (blood type)
          🅰	Symbols	alphanum	A button (blood type)	A | A button (blood type) | blood type
          🆎	Symbols	alphanum	AB button (blood type)	AB | AB button (blood type) | blood type
          🅱️	Symbols	alphanum	B button (blood type)
          🅱	Symbols	alphanum	B button (blood type)	B | B button (blood type) | blood type
          🆑	Symbols	alphanum	CL button	CL | CL button
          🆒	Symbols	alphanum	COOL button	COOL | COOL button
          🆓	Symbols	alphanum	FREE button	FREE | FREE button
          ℹ️	Symbols	alphanum	information
          ℹ	Symbols	alphanum	information	i | information
          🆔	Symbols	alphanum	ID button	ID | ID button | identity
          Ⓜ️	Symbols	alphanum	circled M
          Ⓜ	Symbols	alphanum	circled M	circle | circled M | M
          🆕	Symbols	alphanum	NEW button	NEW | NEW button
          🆖	Symbols	alphanum	NG button	NG | NG button
          🅾️	Symbols	alphanum	O button (blood type)
          🅾	Symbols	alphanum	O button (blood type)	blood type | O | O button (blood type)
          🆗	Symbols	alphanum	OK button	OK | OK button
          🅿️	Symbols	alphanum	P button
          🅿	Symbols	alphanum	P button	P | P button | parking | car park | carpark
          🆘	Symbols	alphanum	SOS button	help | SOS | SOS button
          🆙	Symbols	alphanum	UP! button	mark | UP | UP! | UP! button
          🆚	Symbols	alphanum	VS button	versus | VS | VS button
          🈁	Symbols	alphanum	Japanese “here” button	“here” | Japanese | Japanese “here” button | katakana | ココ
          🈂️	Symbols	alphanum	Japanese “service charge” button
          🈂	Symbols	alphanum	Japanese “service charge” button	“service charge” | Japanese | Japanese “service charge” button | katakana | サ
          🈷️	Symbols	alphanum	Japanese “monthly amount” button
          🈷	Symbols	alphanum	Japanese “monthly amount” button	“monthly amount” | ideograph | Japanese | Japanese “monthly amount” button | 月
          🈶	Symbols	alphanum	Japanese “not free of charge” button	“not free of charge” | ideograph | Japanese | Japanese “not free of charge” button | 有
          🈯	Symbols	alphanum	Japanese “reserved” button	“reserved” | ideograph | Japanese | Japanese “reserved” button | 指
          🉐	Symbols	alphanum	Japanese “bargain” button	“bargain” | ideograph | Japanese | Japanese “bargain” button | 得
          🈹	Symbols	alphanum	Japanese “discount” button	“discount” | ideograph | Japanese | Japanese “discount” button | 割
          🈚	Symbols	alphanum	Japanese “free of charge” button	“free of charge” | ideograph | Japanese | Japanese “free of charge” button | 無
          🈲	Symbols	alphanum	Japanese “prohibited” button	“prohibited” | ideograph | Japanese | Japanese “prohibited” button | 禁
          🉑	Symbols	alphanum	Japanese “acceptable” button	“acceptable” | ideograph | Japanese | Japanese “acceptable” button | 可
          🈸	Symbols	alphanum	Japanese “application” button	“application” | ideograph | Japanese | Japanese “application” button | 申
          🈴	Symbols	alphanum	Japanese “passing grade” button	“passing grade” | ideograph | Japanese | Japanese “passing grade” button | 合
          🈳	Symbols	alphanum	Japanese “vacancy” button	“vacancy” | ideograph | Japanese | Japanese “vacancy” button | 空
          ㊗️	Symbols	alphanum	Japanese “congratulations” button
          ㊗	Symbols	alphanum	Japanese “congratulations” button	“congratulations” | ideograph | Japanese | Japanese “congratulations” button | 祝
          ㊙️	Symbols	alphanum	Japanese “secret” button
          ㊙	Symbols	alphanum	Japanese “secret” button	“secret” | ideograph | Japanese | Japanese “secret” button | 秘
          🈺	Symbols	alphanum	Japanese “open for business” button	“open for business” | ideograph | Japanese | Japanese “open for business” button | 営
          🈵	Symbols	alphanum	Japanese “no vacancy” button	“no vacancy” | ideograph | Japanese | Japanese “no vacancy” button | 満
          🔴	Symbols	geometric	red circle	circle | geometric | red
          🟠	Symbols	geometric	orange circle	circle | orange
          🟡	Symbols	geometric	yellow circle	circle | yellow
          🟢	Symbols	geometric	green circle	circle | green
          🔵	Symbols	geometric	blue circle	blue | circle | geometric
          🟣	Symbols	geometric	purple circle	circle | purple
          🟤	Symbols	geometric	brown circle	brown | circle
          ⚫	Symbols	geometric	black circle	black circle | circle | geometric
          ⚪	Symbols	geometric	white circle	circle | geometric | white circle
          🟥	Symbols	geometric	red square	red | square
          🟧	Symbols	geometric	orange square	orange | square
          🟨	Symbols	geometric	yellow square	square | yellow
          🟩	Symbols	geometric	green square	green | square
          🟦	Symbols	geometric	blue square	blue | square
          🟪	Symbols	geometric	purple square	purple | square
          🟫	Symbols	geometric	brown square	brown | square
          ⬛	Symbols	geometric	black large square	black large square | geometric | square
          ⬜	Symbols	geometric	white large square	geometric | square | white large square
          ◼️	Symbols	geometric	black medium square
          ◼	Symbols	geometric	black medium square	black medium square | geometric | square
          ◻️	Symbols	geometric	white medium square
          ◻	Symbols	geometric	white medium square	geometric | square | white medium square
          ◾	Symbols	geometric	black medium-small square	black medium-small square | geometric | square
          ◽	Symbols	geometric	white medium-small square	geometric | square | white medium-small square
          ▪️	Symbols	geometric	black small square
          ▪	Symbols	geometric	black small square	black small square | geometric | square
          ▫️	Symbols	geometric	white small square
          ▫	Symbols	geometric	white small square	geometric | square | white small square
          🔶	Symbols	geometric	large orange diamond	diamond | geometric | large orange diamond | orange
          🔷	Symbols	geometric	large blue diamond	blue | diamond | geometric | large blue diamond
          🔸	Symbols	geometric	small orange diamond	diamond | geometric | orange | small orange diamond
          🔹	Symbols	geometric	small blue diamond	blue | diamond | geometric | small blue diamond
          🔺	Symbols	geometric	red triangle pointed up	geometric | red | red triangle pointed up
          🔻	Symbols	geometric	red triangle pointed down	down | geometric | red | red triangle pointed down
          💠	Symbols	geometric	diamond with a dot	comic | diamond | diamond with a dot | geometric | inside
          🔘	Symbols	geometric	radio button	button | geometric | radio
          🔳	Symbols	geometric	white square button	button | geometric | outlined | square | white square button
          🔲	Symbols	geometric	black square button	black square button | button | geometric | square
          🏁	Flags	flag	chequered flag	checkered | chequered | chequered flag | racing | checkered flag
          🚩	Flags	flag	triangular flag	post | triangular flag | red flag
          🎌	Flags	flag	crossed flags	celebration | cross | crossed | crossed flags | Japanese
          🏴	Flags	flag	black flag	black flag | waving
          🏳️	Flags	flag	white flag
          🏳	Flags	flag	white flag	waving | white flag | surrender
          🏳️‍🌈	Flags	flag	rainbow flag
          🏳‍🌈	Flags	flag	rainbow flag	pride | rainbow | rainbow flag
          🏳️‍⚧️	Flags	flag	transgender flag
          🏳‍⚧️	Flags	flag	transgender flag
          🏳️‍⚧	Flags	flag	transgender flag
          🏳‍⚧	Flags	flag	transgender flag	flag | light blue | pink | transgender | white | trans
          🏴‍☠️	Flags	flag	pirate flag
          🏴‍☠	Flags	flag	pirate flag	Jolly Roger | pirate | pirate flag | plunder | treasure
          🇦🇨	Flags	country-flag	flag: Ascension Island	flag
          🇦🇩	Flags	country-flag	flag: Andorra	flag
          🇦🇪	Flags	country-flag	flag: United Arab Emirates	flag
          🇦🇫	Flags	country-flag	flag: Afghanistan	flag
          🇦🇬	Flags	country-flag	flag: Antigua & Barbuda	flag
          🇦🇮	Flags	country-flag	flag: Anguilla	flag
          🇦🇱	Flags	country-flag	flag: Albania	flag
          🇦🇴	Flags	country-flag	flag: Angola	flag
          🇦🇶	Flags	country-flag	flag: Antarctica	flag
          🇦🇷	Flags	country-flag	flag: Argentina	flag
          🇦🇸	Flags	country-flag	flag: American Samoa	flag
          🇦🇹	Flags	country-flag	flag: Austria	flag
          🇦🇺	Flags	country-flag	flag: Australia	flag
          🇦🇼	Flags	country-flag	flag: Aruba	flag
          🇦🇽	Flags	country-flag	flag: Åland Islands	flag
          🇦🇿	Flags	country-flag	flag: Azerbaijan	flag
          🇧🇦	Flags	country-flag	flag: Bosnia & Herzegovina	flag
          🇧🇧	Flags	country-flag	flag: Barbados	flag
          🇧🇩	Flags	country-flag	flag: Bangladesh	flag
          🇧🇪	Flags	country-flag	flag: Belgium	flag
          🇧🇫	Flags	country-flag	flag: Burkina Faso	flag
          🇧🇬	Flags	country-flag	flag: Bulgaria	flag
          🇧🇭	Flags	country-flag	flag: Bahrain	flag
          🇧🇮	Flags	country-flag	flag: Burundi	flag
          🇧🇯	Flags	country-flag	flag: Benin	flag
          🇧🇱	Flags	country-flag	flag: St. Barthélemy	flag
          🇧🇲	Flags	country-flag	flag: Bermuda	flag
          🇧🇳	Flags	country-flag	flag: Brunei	flag
          🇧🇴	Flags	country-flag	flag: Bolivia	flag
          🇧🇶	Flags	country-flag	flag: Caribbean Netherlands	flag
          🇧🇷	Flags	country-flag	flag: Brazil	flag
          🇧🇸	Flags	country-flag	flag: Bahamas	flag
          🇧🇹	Flags	country-flag	flag: Bhutan	flag
          🇧🇻	Flags	country-flag	flag: Bouvet Island	flag
          🇧🇼	Flags	country-flag	flag: Botswana	flag
          🇧🇾	Flags	country-flag	flag: Belarus	flag
          🇧🇿	Flags	country-flag	flag: Belize	flag
          🇨🇦	Flags	country-flag	flag: Canada	flag
          🇨🇨	Flags	country-flag	flag: Cocos (Keeling) Islands	flag
          🇨🇩	Flags	country-flag	flag: Congo - Kinshasa	flag
          🇨🇫	Flags	country-flag	flag: Central African Republic	flag
          🇨🇬	Flags	country-flag	flag: Congo - Brazzaville	flag
          🇨🇭	Flags	country-flag	flag: Switzerland	flag
          🇨🇮	Flags	country-flag	flag: Côte d’Ivoire	flag
          🇨🇰	Flags	country-flag	flag: Cook Islands	flag
          🇨🇱	Flags	country-flag	flag: Chile	flag
          🇨🇲	Flags	country-flag	flag: Cameroon	flag
          🇨🇳	Flags	country-flag	flag: China	flag
          🇨🇴	Flags	country-flag	flag: Colombia	flag
          🇨🇵	Flags	country-flag	flag: Clipperton Island	flag
          🇨🇷	Flags	country-flag	flag: Costa Rica	flag
          🇨🇺	Flags	country-flag	flag: Cuba	flag
          🇨🇻	Flags	country-flag	flag: Cape Verde	flag
          🇨🇼	Flags	country-flag	flag: Curaçao	flag
          🇨🇽	Flags	country-flag	flag: Christmas Island	flag
          🇨🇾	Flags	country-flag	flag: Cyprus	flag
          🇨🇿	Flags	country-flag	flag: Czechia	flag
          🇩🇬	Flags	country-flag	flag: Diego Garcia	flag
          🇩🇯	Flags	country-flag	flag: Djibouti	flag
          🇩🇰	Flags	country-flag	flag: Denmark	flag
          🇩🇲	Flags	country-flag	flag: Dominica	flag
          🇩🇴	Flags	country-flag	flag: Dominican Republic	flag
          🇩🇿	Flags	country-flag	flag: Algeria	flag
          🇪🇦	Flags	country-flag	flag: Ceuta & Melilla	flag
          🇪🇨	Flags	country-flag	flag: Ecuador	flag
          🇪🇪	Flags	country-flag	flag: Estonia	flag
          🇪🇬	Flags	country-flag	flag: Egypt	flag
          🇪🇭	Flags	country-flag	flag: Western Sahara	flag
          🇪🇷	Flags	country-flag	flag: Eritrea	flag
          🇪🇸	Flags	country-flag	flag: Spain	flag
          🇪🇹	Flags	country-flag	flag: Ethiopia	flag
          🇪🇺	Flags	country-flag	flag: European Union	flag
          🇫🇮	Flags	country-flag	flag: Finland	flag
          🇫🇯	Flags	country-flag	flag: Fiji	flag
          🇫🇰	Flags	country-flag	flag: Falkland Islands	flag
          🇫🇲	Flags	country-flag	flag: Micronesia	flag
          🇫🇴	Flags	country-flag	flag: Faroe Islands	flag
          🇫🇷	Flags	country-flag	flag: France	flag
          🇬🇦	Flags	country-flag	flag: Gabon	flag
          🇬🇧	Flags	country-flag	flag: United Kingdom	flag
          🇬🇩	Flags	country-flag	flag: Grenada	flag
          🇬🇪	Flags	country-flag	flag: Georgia	flag
          🇬🇫	Flags	country-flag	flag: French Guiana	flag
          🇬🇬	Flags	country-flag	flag: Guernsey	flag
          🇬🇭	Flags	country-flag	flag: Ghana	flag
          🇬🇮	Flags	country-flag	flag: Gibraltar	flag
          🇬🇱	Flags	country-flag	flag: Greenland	flag
          🇬🇲	Flags	country-flag	flag: Gambia	flag
          🇬🇳	Flags	country-flag	flag: Guinea	flag
          🇬🇵	Flags	country-flag	flag: Guadeloupe	flag
          🇬🇶	Flags	country-flag	flag: Equatorial Guinea	flag
          🇬🇷	Flags	country-flag	flag: Greece	flag
          🇬🇸	Flags	country-flag	flag: South Georgia & South Sandwich Islands	flag
          🇬🇹	Flags	country-flag	flag: Guatemala	flag
          🇬🇺	Flags	country-flag	flag: Guam	flag
          🇬🇼	Flags	country-flag	flag: Guinea-Bissau	flag
          🇬🇾	Flags	country-flag	flag: Guyana	flag
          🇭🇰	Flags	country-flag	flag: Hong Kong SAR China	flag
          🇭🇲	Flags	country-flag	flag: Heard & McDonald Islands	flag
          🇭🇳	Flags	country-flag	flag: Honduras	flag
          🇭🇷	Flags	country-flag	flag: Croatia	flag
          🇭🇹	Flags	country-flag	flag: Haiti	flag
          🇭🇺	Flags	country-flag	flag: Hungary	flag
          🇮🇨	Flags	country-flag	flag: Canary Islands	flag
          🇮🇩	Flags	country-flag	flag: Indonesia	flag
          🇮🇪	Flags	country-flag	flag: Ireland	flag
          🇮🇱	Flags	country-flag	flag: Israel	flag
          🇮🇲	Flags	country-flag	flag: Isle of Man	flag
          🇮🇳	Flags	country-flag	flag: India	flag
          🇮🇴	Flags	country-flag	flag: British Indian Ocean Territory	flag
          🇮🇶	Flags	country-flag	flag: Iraq	flag
          🇮🇷	Flags	country-flag	flag: Iran	flag
          🇮🇸	Flags	country-flag	flag: Iceland	flag
          🇮🇹	Flags	country-flag	flag: Italy	flag
          🇯🇪	Flags	country-flag	flag: Jersey	flag
          🇯🇲	Flags	country-flag	flag: Jamaica	flag
          🇯🇴	Flags	country-flag	flag: Jordan	flag
          🇯🇵	Flags	country-flag	flag: Japan	flag
          🇰🇪	Flags	country-flag	flag: Kenya	flag
          🇰🇬	Flags	country-flag	flag: Kyrgyzstan	flag
          🇰🇭	Flags	country-flag	flag: Cambodia	flag
          🇰🇮	Flags	country-flag	flag: Kiribati	flag
          🇰🇲	Flags	country-flag	flag: Comoros	flag
          🇰🇳	Flags	country-flag	flag: St. Kitts & Nevis	flag
          🇰🇵	Flags	country-flag	flag: North Korea	flag
          🇰🇷	Flags	country-flag	flag: South Korea	flag
          🇰🇼	Flags	country-flag	flag: Kuwait	flag
          🇰🇿	Flags	country-flag	flag: Kazakhstan	flag
          🇱🇦	Flags	country-flag	flag: Laos	flag
          🇱🇧	Flags	country-flag	flag: Lebanon	flag
          🇱🇨	Flags	country-flag	flag: St. Lucia	flag
          🇱🇮	Flags	country-flag	flag: Liechtenstein	flag
          🇱🇰	Flags	country-flag	flag: Sri Lanka	flag
          🇱🇷	Flags	country-flag	flag: Liberia	flag
          🇱🇸	Flags	country-flag	flag: Lesotho	flag
          🇱🇹	Flags	country-flag	flag: Lithuania	flag
          🇱🇺	Flags	country-flag	flag: Luxembourg	flag
          🇱🇻	Flags	country-flag	flag: Latvia	flag
          🇱🇾	Flags	country-flag	flag: Libya	flag
          🇲🇦	Flags	country-flag	flag: Morocco	flag
          🇲🇨	Flags	country-flag	flag: Monaco	flag
          🇲🇩	Flags	country-flag	flag: Moldova	flag
          🇲🇪	Flags	country-flag	flag: Montenegro	flag
          🇲🇫	Flags	country-flag	flag: St. Martin	flag
          🇲🇬	Flags	country-flag	flag: Madagascar	flag
          🇲🇭	Flags	country-flag	flag: Marshall Islands	flag
          🇲🇰	Flags	country-flag	flag: North Macedonia	flag
          🇲🇱	Flags	country-flag	flag: Mali	flag
          🇲🇲	Flags	country-flag	flag: Myanmar (Burma)	flag
          🇲🇳	Flags	country-flag	flag: Mongolia	flag
          🇲🇴	Flags	country-flag	flag: Macao SAR China	flag
          🇲🇵	Flags	country-flag	flag: Northern Mariana Islands	flag
          🇲🇶	Flags	country-flag	flag: Martinique	flag
          🇲🇷	Flags	country-flag	flag: Mauritania	flag
          🇲🇸	Flags	country-flag	flag: Montserrat	flag
          🇲🇹	Flags	country-flag	flag: Malta	flag
          🇲🇺	Flags	country-flag	flag: Mauritius	flag
          🇲🇻	Flags	country-flag	flag: Maldives	flag
          🇲🇼	Flags	country-flag	flag: Malawi	flag
          🇲🇽	Flags	country-flag	flag: Mexico	flag
          🇲🇾	Flags	country-flag	flag: Malaysia	flag
          🇲🇿	Flags	country-flag	flag: Mozambique	flag
          🇳🇦	Flags	country-flag	flag: Namibia	flag
          🇳🇨	Flags	country-flag	flag: New Caledonia	flag
          🇳🇪	Flags	country-flag	flag: Niger	flag
          🇳🇫	Flags	country-flag	flag: Norfolk Island	flag
          🇳🇬	Flags	country-flag	flag: Nigeria	flag
          🇳🇮	Flags	country-flag	flag: Nicaragua	flag
          🇳🇱	Flags	country-flag	flag: Netherlands	flag
          🇳🇴	Flags	country-flag	flag: Norway	flag
          🇳🇵	Flags	country-flag	flag: Nepal	flag
          🇳🇷	Flags	country-flag	flag: Nauru	flag
          🇳🇺	Flags	country-flag	flag: Niue	flag
          🇳🇿	Flags	country-flag	flag: New Zealand	flag
          🇵🇦	Flags	country-flag	flag: Panama	flag
          🇵🇪	Flags	country-flag	flag: Peru	flag
          🇵🇫	Flags	country-flag	flag: French Polynesia	flag
          🇵🇬	Flags	country-flag	flag: Papua New Guinea	flag
          🇵🇭	Flags	country-flag	flag: Philippines	flag
          🇵🇰	Flags	country-flag	flag: Pakistan	flag
          🇵🇱	Flags	country-flag	flag: Poland	flag
          🇵🇲	Flags	country-flag	flag: St. Pierre & Miquelon	flag
          🇵🇳	Flags	country-flag	flag: Pitcairn Islands	flag
          🇵🇷	Flags	country-flag	flag: Puerto Rico	flag
          🇵🇸	Flags	country-flag	flag: Palestinian Territories	flag
          🇵🇹	Flags	country-flag	flag: Portugal	flag
          🇵🇼	Flags	country-flag	flag: Palau	flag
          🇵🇾	Flags	country-flag	flag: Paraguay	flag
          🇶🇦	Flags	country-flag	flag: Qatar	flag
          🇷🇪	Flags	country-flag	flag: Réunion	flag
          🇷🇸	Flags	country-flag	flag: Serbia	flag
          🇷🇺	Flags	country-flag	flag: Russia	flag
          🇷🇼	Flags	country-flag	flag: Rwanda	flag
          🇸🇦	Flags	country-flag	flag: Saudi Arabia	flag
          🇸🇧	Flags	country-flag	flag: Solomon Islands	flag
          🇸🇨	Flags	country-flag	flag: Seychelles	flag
          🇸🇩	Flags	country-flag	flag: Sudan	flag
          🇸🇪	Flags	country-flag	flag: Sweden	flag
          🇸🇬	Flags	country-flag	flag: Singapore	flag
          🇸🇭	Flags	country-flag	flag: St. Helena	flag
          🇸🇮	Flags	country-flag	flag: Slovenia	flag
          🇸🇯	Flags	country-flag	flag: Svalbard & Jan Mayen	flag
          🇸🇰	Flags	country-flag	flag: Slovakia	flag
          🇸🇱	Flags	country-flag	flag: Sierra Leone	flag
          🇸🇲	Flags	country-flag	flag: San Marino	flag
          🇸🇳	Flags	country-flag	flag: Senegal	flag
          🇸🇴	Flags	country-flag	flag: Somalia	flag
          🇸🇷	Flags	country-flag	flag: Suriname	flag
          🇸🇸	Flags	country-flag	flag: South Sudan	flag
          🇸🇹	Flags	country-flag	flag: São Tomé & Príncipe	flag
          🇸🇻	Flags	country-flag	flag: El Salvador	flag
          🇸🇽	Flags	country-flag	flag: Sint Maarten	flag
          🇸🇾	Flags	country-flag	flag: Syria	flag
          🇸🇿	Flags	country-flag	flag: Eswatini	flag
          🇹🇦	Flags	country-flag	flag: Tristan da Cunha	flag
          🇹🇨	Flags	country-flag	flag: Turks & Caicos Islands	flag
          🇹🇩	Flags	country-flag	flag: Chad	flag
          🇹🇫	Flags	country-flag	flag: French Southern Territories	flag
          🇹🇬	Flags	country-flag	flag: Togo	flag
          🇹🇭	Flags	country-flag	flag: Thailand	flag
          🇹🇯	Flags	country-flag	flag: Tajikistan	flag
          🇹🇰	Flags	country-flag	flag: Tokelau	flag
          🇹🇱	Flags	country-flag	flag: Timor-Leste	flag
          🇹🇳	Flags	country-flag	flag: Tunisia	flag
          🇹🇴	Flags	country-flag	flag: Tonga	flag
          🇹🇷	Flags	country-flag	flag: Turkey	flag
          🇹🇹	Flags	country-flag	flag: Trinidad & Tobago	flag
          🇹🇻	Flags	country-flag	flag: Tuvalu	flag
          🇹🇼	Flags	country-flag	flag: Taiwan	flag
          🇹🇿	Flags	country-flag	flag: Tanzania	flag
          🇺🇦	Flags	country-flag	flag: Ukraine	flag
          🇺🇬	Flags	country-flag	flag: Uganda	flag
          🇺🇲	Flags	country-flag	flag: U.S. Outlying Islands	flag
          🇺🇳	Flags	country-flag	flag: United Nations	flag
          🇺🇸	Flags	country-flag	flag: United States	flag
          🇺🇾	Flags	country-flag	flag: Uruguay	flag
          🇺🇿	Flags	country-flag	flag: Uzbekistan	flag
          🇻🇦	Flags	country-flag	flag: Vatican City	flag
          🇻🇨	Flags	country-flag	flag: St. Vincent & Grenadines	flag
          🇻🇪	Flags	country-flag	flag: Venezuela	flag
          🇻🇬	Flags	country-flag	flag: British Virgin Islands	flag
          🇻🇮	Flags	country-flag	flag: U.S. Virgin Islands	flag
          🇻🇳	Flags	country-flag	flag: Vietnam	flag
          🇻🇺	Flags	country-flag	flag: Vanuatu	flag
          🇼🇫	Flags	country-flag	flag: Wallis & Futuna	flag
          🇼🇸	Flags	country-flag	flag: Samoa	flag
          🇽🇰	Flags	country-flag	flag: Kosovo	flag
          🇾🇹	Flags	country-flag	flag: Mayotte	flag
          🇿🇦	Flags	country-flag	flag: South Africa	flag
          🇿🇲	Flags	country-flag	flag: Zambia	flag
          🇿🇼	Flags	country-flag	flag: Zimbabwe	flag
          🏴󠁧󠁢󠁥󠁮󠁧󠁿	Flags	subdivision-flag	flag: England	flag
          🏴󠁧󠁢󠁳󠁣󠁴󠁿	Flags	subdivision-flag	flag: Scotland	flag
          🏴󠁧󠁢󠁷󠁬󠁳󠁿	Flags	subdivision-flag	flag: Wales	flag
        '';
      };
    };
  };
}
