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
    clicks: 4

@RUNNER_DECK = [
  _id: "sure-gamble-1"
  name: "Sure Gamble"
  src: "sure_gamble.png"
  cardType: "event"
  actions: [
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
  actions: 
    draw3Cards:
      click_cost: 1
      credit_cost: 0
      text: "Draw 3 cards."
,
  _id: "sure-gamble-2"
  name: "Sure Gamble"
  src: "sure_gamble.png"
  cardType: "event"
  actions: [
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
  actions: 
    draw3Cards:
      click_cost: 1
      credit_cost: 0
      text: "Draw 3 cards."
,
  _id: "sure-gamble-3"
  name: "Sure Gamble"
  src: "sure_gamble.png"
  cardType: "event"
  actions: [
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
  actions: 
    draw3Cards:
      click_cost: 1
      credit_cost: 0
      text: "Draw 3 cards."
]
