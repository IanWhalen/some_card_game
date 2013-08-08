@CORP =
  identity:
    name: "Haas-Bioroid"
    src: "corpIdentity.png"
    gameLoc: 'corp'
    actions: []
    gain1CreditOnFirstInstall: true
  cardBack:
    src: "corp-back.jpg"
    gameLoc: 'corp'
  stats:
    score: 0
    credits: 5
    clicks: 0
  remoteServers: []
  hand: []

@CORP_DECK = [
  _id: "hedge-fund-1"
  owner: 'corp'
  loc: 'deck'
  name: "Hedge Fund"
  src: "hedge_fund.png"
  cardType: "Operation"
  handActions: [
    action: 'useHedgeFund'
    click_cost: 1
    credit_cost: 5
    actionText: "Gain 9 credits."
  ]
,
  _id: "hedge-fund-2"
  owner: 'corp'
  loc: 'deck'
  name: "Hedge Fund"
  src: "hedge_fund.png"
  cardType: "Operation"
  handActions: [
    action: 'useHedgeFund'
    click_cost: 1
    credit_cost: 5
    actionText: "Gain 9 credits."
  ]
,
  _id: "hedge-fund-3"
  owner: 'corp'
  loc: 'deck'
  name: "Hedge Fund"
  src: "hedge_fund.png"
  cardType: "Operation"
  handActions: [
    action: 'useHedgeFund'
    click_cost: 1
    credit_cost: 5
    actionText: "Gain 9 credits."
  ]
,
  _id: "biotic-labor-1"
  owner: 'corp'
  loc: 'deck'
  name: "Biotic Labor"
  src: "biotic-labor.png"
  cardType: "Operation"
  handActions: [
    action: 'useBioticLabor'
    click_cost: 1
    credit_cost: 4
    actionText: "Gain 2 clicks."
  ]
,
  _id: "biotic-labor-2"
  owner: 'corp'
  loc: 'deck'
  name: "Biotic Labor"
  src: "biotic-labor.png"
  cardType: "Operation"
  handActions: [
    action: 'useBioticLabor'
    click_cost: 1
    credit_cost: 4
    actionText: "Gain 2 clicks."
  ]
,
  _id: "pad-campaign-1"
  owner: 'corp'
  loc: 'deck'
  name: "PAD Campaign"
  src: "pad-campaign.png"
  cardType: "Asset"
  addBenefit: 'gain1CreditEachTurn'
  unrezzedActions: [
    click_cost: 1
    credit_cost: 2
    actionText: 'Rez PAD Campaign'
    action: 'rezAsset'
  ]
  rezzedActions: []
  handActions: [
    click_cost: 1
    credit_cost: 0
    actionText: "Install PAD Campaign"
    action: 'installAsset'
  ]
]

## Agenda (9)
# Accelerated Beta Test (Core) x3
# Priority Requisition (Core) x3
# Private Security Force (Core) x3
## Asset (10)
# Adonis Campaign (Core) x3
# Aggressive Secretary (Core) x2
# Melange Mining Corp (Core) x2
# PAD Campaign (Core) x3
## ICE (17)
# Enigma (Core) x3
# Heimdall 1.0 (Core) x2
# Hunter (Core) x2
# Ichi 1.0 (Core) x3
# Rototurret (Core) x2
# Viktor 1.0 (Core) x2
# Wall of Static (Core) x3
## Operation (10)
# Archived Memories (Core) x2
# Biotic Labor (Core) x3
# Shipment from Mirrormorph (Core) x2
## Upgrade (3)
# Corporate Troubleshooter (Core) x1
# Experiential Data (Core) x2
