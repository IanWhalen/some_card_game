@RUNNER =
  identity:
    name: "Kate \"Mac\" McCaffrey"
    src: "runner_identity.png"
    gameLoc: 'runner'
    # actions: []
  cardBack:
    src: "runner-back.jpg"
    gameLoc: 'runner'
  stats:
    memory: 4
    link: 0
    score: 0
    credits: 5
    clicks: 4

@RUNNER_DECK = [
  _id: "access-to-globalsec-2"
  name: "Access To Globalsec"
  src: "access-to-globalsec.png"
  cardType: "Resource"
  addBenefit: "add1Link"
  handActions: [
    installResource:
      click_cost: 1
      credit_cost: 1
      text: "Install Access To Globalsec"
  ]
,
  _id: "access-to-globalsec-3"
  name: "Access To Globalsec"
  src: "access-to-globalsec.png"
  cardType: "Resource"
  addBenefit: "add1Link"
  handActions: [
    installResource:
      click_cost: 1
      credit_cost: 1
      text: "Install Access To Globalsec"
  ]
,
  _id: "sure-gamble-1"
  name: "Sure Gamble"
  src: "sure_gamble.png"
  cardType: "event"
  handActions: [
    add9Credits:
      click_cost: 1
      credit_cost: 5
      text: "Gain 9 credits."
  ]
,
  _id: "diesel-1"
  name: "Diesel"
  src: "diesel.png"
  cardType: "event"
  handActions: [
    draw3Cards:
      click_cost: 1
      credit_cost: 0
      text: "Draw 3 cards."
  ]
,
  _id: "sure-gamble-2"
  name: "Sure Gamble"
  src: "sure_gamble.png"
  cardType: "event"
  handActions: [
    add9Credits:
      click_cost: 1
      credit_cost: 5
      text: "Gain 9 credits."
  ]
,
  _id: "diesel-2"
  name: "Diesel"
  src: "diesel.png"
  cardType: "event"
  handActions: [
    draw3Cards:
      click_cost: 1
      credit_cost: 0
      text: "Draw 3 cards."
  ]
,
  _id: "sure-gamble-3"
  name: "Sure Gamble"
  src: "sure_gamble.png"
  cardType: "event"
  handActions: [
    add9Credits:
      click_cost: 1
      credit_cost: 5
      text: "Gain 9 credits."
  ]
,
  _id: "diesel-3"
  name: "Diesel"
  src: "diesel.png"
  cardType: "event"
  handActions: [
    draw3Cards:
      click_cost: 1
      credit_cost: 0
      text: "Draw 3 cards."
  ]
,
  _id: "access-to-globalsec-1"
  name: "Access To Globalsec"
  src: "access-to-globalsec.png"
  cardType: "Resource"
  addBenefit: "add1Link"
  handActions: [
    installResource:
      click_cost: 1
      credit_cost: 1
      text: "Install Access To Globalsec"
  ]
,
  _id: "armitage-codebusting-1"
  name: "Armitage Codebusting"
  src: "armitage-codebusting.png"
  cardType: "Resource"
  counters: 12
  trashIfNoCounters: true
  handActions: [
    installResource:
      click_cost: 1
      credit_cost: 1
      text: "Install Armitage Codebusting"
  ]
  boardActions: [
    useArmitageCodebusting:
      click_cost: 1
      credit_cost: 0
      text: "Use 1 click to gain 2 credits"
  ]
## Event
# Infiltration (Core) x3
# Modded (Core) x2
# The Maker's Eye (Core) x3
# Tinkering (Core) x3
## Hardware
# Akamatsu Mem Chip (Core) x2
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
