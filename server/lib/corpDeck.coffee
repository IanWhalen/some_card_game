@CORP =
  identity:
    name: "Haas-Bioroid"
    src: "corpIdentity.png"
    actions: []
  cardBack:
    src: "corp-back.jpg"
  stats:
    score: 0
    credits: 5
    clicks: 4

@CORP_DECK = [
  _id: "hedge-fund-1"
  name: "Hedge Fund"
  src: "hedge_fund.png"
  cardType: "operation"
  actions: [
    add9Credits:
      click_cost: 1
      credit_cost: 5
      text: "Gain 9 credits."
  ]
,
  _id: "hedge-fund-2"
  name: "Hedge Fund"
  src: "hedge_fund.png"
  cardType: "operation"
  actions: [
    add9Credits:
      click_cost: 1
      credit_cost: 5
      text: "Gain 9 credits."
  ]
,
  _id: "hedge-fund-3"
  name: "Hedge Fund"
  src: "hedge_fund.png"
  cardType: "operation"
  actions: [
    add9Credits:
      click_cost: 1
      credit_cost: 5
      text: "Gain 9 credits."
  ]
]