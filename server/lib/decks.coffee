@RUNNER_DECK = [
  _id: "sure-gamble-1"
  name: "Sure Gamble"
  src: "sure_gamble.png"
  cardType: "event"
  actions: [
    click_cost: 1
    credit_cost: 5
    text: "Gain 9 credits."
    action: "addCredits(myself(), 9)"
  ]
,
  _id: "diesel-1"
  name: "Diesel"
  src: "diesel.png"
  cardType: "event"
  actions: [
    click_cost: 1
    credit_cost: 0
    text: "Draw 3 cards."
    action: "drawCards(myself(), 3)"
  ]
,
  _id: "sure-gamble-2"
  name: "Sure Gamble"
  src: "sure_gamble.png"
  cardType: "event"
  actions: [
      click_cost: 1
      credit_cost: 5
      text: "Gain 9 credits."
      action: "addCredits(myself(), 9)"
  ]
,
  _id: "diesel-2"
  name: "Diesel"
  src: "diesel.png"
  cardType: "event"
  actions: [
    click_cost: 1
    credit_cost: 0
    text: "Draw 3 cards."
    action: "drawCards(myself(), 3)"
  ]
,
  _id: "sure-gamble-3"
  name: "Sure Gamble"
  src: "sure_gamble.png"
  cardType: "event"
  actions: [
      click_cost: 1
      credit_cost: 5
      text: "Gain 9 credits."
      action: "addCredits(myself(), 9)"
  ]
,
  _id: "diesel-3"
  name: "Diesel"
  src: "diesel.png"
  cardType: "event"
  actions: [
    click_cost: 1
    credit_cost: 0
    text: "Draw 3 cards."
    action: "drawCards(myself(), 3)"
  ]
]

@RUNNER =
  identity:
    name: "Kate \"Mac\" McCaffrey"
    src: "runner_identity.png"
    actions: []
  cardBack:
    src: "runner-back.jpg"
  stats:
    score: 0
    credits: 5
