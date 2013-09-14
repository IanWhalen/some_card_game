@RUNNER =
  identity:
    name: "Kate \"Mac\" McCaffrey"
    src: "runner_identity.png"
    reduceFirstProgramOrHardwareInstallCostBy1: true
    owner: 'runner'
  cardBack:
    owner: 'runner'
    src: "runner-back.jpg"
  stats:
    memory: 4
    link: 0
    score: 0
    credits: 5
    clicks: 0
    handLimit: 5
  deck:
    cards: []
  hand: []
  resources: []
  hardware: []
  discard:
    cards: []

@RUNNER_DECK = [
  _id: "access-to-globalsec-2"
  owner: 'runner'
  loc: 'deck'
  name: "Access To Globalsec"
  src: "access-to-globalsec.png"
  cardType: "Resource"
  addBenefit: "add1Link"
  handActions: [
    action: 'installResource'
    click_cost: 1
    credit_cost: 1
    actionText: "Install Access To Globalsec"
  ]
,
  _id: "access-to-globalsec-3"
  owner: 'runner'
  loc: 'deck'
  name: "Access To Globalsec"
  src: "access-to-globalsec.png"
  cardType: "Resource"
  addBenefit: "add1Link"
  handActions: [
    action: 'installResource'
    click_cost: 1
    credit_cost: 1
    actionText: "Install Access To Globalsec"
  ]
,
  _id: "sure-gamble-1"
  owner: 'runner'
  loc: 'deck'
  name: "Sure Gamble"
  src: "sure_gamble.png"
  cardType: "Event"
  handActions: [
    action: 'useSureGamble'
    click_cost: 1
    credit_cost: 5
    actionText: "Gain 9 credits."
  ]
,
  _id: "diesel-1"
  owner: 'runner'
  loc: 'deck'
  name: "Diesel"
  src: "diesel.png"
  cardType: "Event"
  handActions: [
    action: 'useDiesel'
    click_cost: 1
    credit_cost: 0
    actionText: "Draw 3 cards."
  ]
,
  _id: "sure-gamble-2"
  owner: 'runner'
  loc: 'deck'
  name: "Sure Gamble"
  src: "sure_gamble.png"
  cardType: "Event"
  handActions: [
    action: 'useSureGamble'
    click_cost: 1
    credit_cost: 5
    actionText: "Gain 9 credits."
  ]
,
  _id: "diesel-2"
  owner: 'runner'
  loc: 'deck'
  name: "Diesel"
  src: "diesel.png"
  cardType: "Event"
  handActions: [
    action: 'useDiesel'
    click_cost: 1
    credit_cost: 0
    actionText: "Draw 3 cards."
  ]
,
  _id: "sure-gamble-3"
  owner: 'runner'
  loc: 'deck'
  name: "Sure Gamble"
  src: "sure_gamble.png"
  cardType: "Event"
  handActions: [
    action: 'useSureGamble'
    click_cost: 1
    credit_cost: 5
    actionText: "Gain 9 credits."
  ]
,
  _id: "diesel-3"
  owner: 'runner'
  loc: 'deck'
  name: "Diesel"
  src: "diesel.png"
  cardType: "Event"
  handActions: [
    action: 'useDiesel'
    click_cost: 1
    credit_cost: 0
    actionText: "Draw 3 cards."
  ]
,
  _id: "access-to-globalsec-1"
  owner: 'runner'
  loc: 'deck'
  name: "Access To Globalsec"
  src: "access-to-globalsec.png"
  cardType: "Resource"
  addBenefit: "add1Link"
  handActions: [
    action: 'installResource'
    click_cost: 1
    credit_cost: 1
    actionText: "Install Access To Globalsec"
  ]
,
  _id: "armitage-codebusting-1"
  owner: 'runner'
  loc: 'deck'
  name: "Armitage Codebusting"
  src: "armitage-codebusting.png"
  cardType: "Resource"
  counters: 12
  trashIfNoCounters: true
  handActions: [
    action: 'installResource'
    click_cost: 1
    credit_cost: 1
    actionText: "Install Armitage Codebusting"
  ]
  boardActions: [
    action: 'useArmitageCodebusting'
    click_cost: 1
    credit_cost: 0
    actionText: "Use 1 click to gain 2 credits"
  ]
,
  _id: "akamatsu-mem-chip-1"
  owner: 'runner'
  loc: 'deck'
  name: "Akamatsu Mem Chip"
  src: "akamatsu-mem-chip.png"
  cardType: "Hardware"
  addBenefit: "add1Memory"
  handActions: [
    action: 'installHardware'
    click_cost: 1
    credit_cost: 1
    actionText: "Install Akamatsu Mem Chip"
  ]
,
  _id: "akamatsu-mem-chip-2"
  owner: 'runner'
  loc: 'deck'
  name: "Akamatsu Mem Chip"
  src: "akamatsu-mem-chip.png"
  cardType: "Hardware"
  addBenefit: "add1Memory"
  handActions: [
    action: 'installHardware'
    click_cost: 1
    credit_cost: 1
    actionText: "Install Akamatsu Mem Chip"
  ]
,
  _id: "modded-1"
  owner: 'runner'
  loc: 'deck'
  name: "Modded"
  src: "modded.png"
  cardType: "Event"
  description: "Install a program or a piece of hardware, lowering the installation cost by 3."
  handActions: [
    action: 'useModded'
    click_cost: 1
    credit_cost: 0
    actionText: "Use Modded"
  ]
,
  _id: "modded-2"
  owner: 'runner'
  loc: 'deck'
  name: "Modded"
  src: "modded.png"
  cardType: "Event"
  description: "Install a program or a piece of hardware, lowering the installation cost by 3."
  handActions: [
    action: 'useModded'
    click_cost: 1
    credit_cost: 0
    actionText: "Use Modded"
  ]
## Event
# Infiltration (Core) x3
# Modded (Core) x2
# The Maker's Eye (Core) x3
# Tinkering (Core) x3
## Hardware
# Rabbit Hole (Core) x2
# The Personal Touch (Core) x2
# The Toolbox (Core) x1
## Program
# Battering Ram (Core) x2
# Crypsis (Core) x3
# Gordian Blade (Core) x3
# Magnum Opus (Core) x2
# Net Shield (Core) x2
# Pipeline (Core) x2
## Resource
# Aesop's Pawnshop (Core) x1
# Armitage Codebusting (Core) x3
# Sacrificial Construct (Core) x2
]
