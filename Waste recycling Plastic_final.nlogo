;; Defining global variables
globals [
  recycle-percent-target ; recycle percent target defined by the municipality
  tick-counter ; to stop the model
  target-update-counter ; Used to update the recycle percent target
  initiative-tick ; Used to keep track of municipal initiative based ticks
]

;;Defining different agents for the model
breed [households household]
breed [municipalities municipality]
breed [firms firm]
undirected-link-breed [contracts contract]

;; Household attributes
households-own [
  base-waste-function ;  base waste function as per the formula given in the problem description
  household-type ; assigning household types
  waste-factor ; multiplication factor per household type
  base-waste ; Ideal Base waste value given the households collect all the possible plastic
  is-awareness-training? ; proxy for awareness training
  infrastructure-effect ; Multiplication factor to account for motivation based on centralized and decentralized infrastructure.
  perception-to-recycle ; stores the current perception value towards recycling
  awareness-effectiveness ; stores the awareness training effectiveness value
  recyclable-waste ; the recylable waste produced based on the perception value
  is-knowledge-training? ; proxy for knowledge training
  pre-separate-percent ; stores the currest post separation percent value
  knowledge-effectiveness ; stores the knowledge training effectiveness value
  pre-separated-waste ; the pre-separated waste per households
  municipality-belong ; proxy to assign municipality to each household
]

;; municipality attributes
municipalities-own [
  collection-infra ; the type of collection infrastructure of a municipality
  total-base-waste ; total base waste collected
  possible-recyclable-waste ; the maximum amount of waste that can be recycled under perfect conditions
  actual-recyclable-waste ; actual waste collected
  total-pre-separated-waste ; actual pre-separated waste
  contracted-waste ; waste under contracts
  non-contracted-waste ; waste not under contracts
  awareness-program ; counter for number of awareness programs
  awareness-cost ; total cost of awareness program
  knowledge-program ; counter for number of knowledge programs
  fine? ; proxy to see applicablity of firxne
  municipal-fine ; value of fine
  municipal-fines-total ; total value of fines
  total-fines ; counter for number of fines
  knowledge-cost ; total cost of knowledge program
  education-program-cost ; cost for combined knowledge and awareness programs
  education-cost ; cost per education activity
  total-recycled-waste-municipality ; total waste recycled
  recycling-rate-achieved ; recycling rate actually achieved
  municipal-expenditure ; municipal expenditure
  municipality-singles-belong ; household of singles per municipality
  municipality-old-belong ; household of old per municipality
  municipality-couples-belong ; household of couples per municipality
  municipality-family-belong ; household of families per municipality
  municipality-population ; total municipal population
  running-contracts ; running contracts
  total-efficiency-received ; total efficiency of the running contract firms, used as a proxy to calculate municipal recycling rates
]

;; firms attributes
firms-own [
  offer-recycled-post ; offer value of recycled post-separated
  capacity ; cuurent capacity of firms
  efficiency ; current efficiency of firms
  operate-cost ; current cost of operations of firms
  tech-improve-time ; counter to check the efficiency improvement
  capacity-improve-time ; counter to check capacity improvements
  capacity-utilized ; total utilized capacity of firms
  waste-collect-cost ; collection cost for waste
  can-bid? ; proxy to check bidding ability of firms
  tech-improve? ; proxy to check need for efficiency improvement
  factory-cash-balance ; total cash balance of firms
  capacity-improve? ; proxy to check need for capacity improvement
  capacity-effect-operate-cost ; effect of capacity improvement on operating cost
  capacity-effect-tech ; effect of capacity improvement on efficiency improvement
  total-waste-post-separated ; total waste post separated by firms
  total-waste-received-firm ; total waste recieved by firms
  total-waste-recycled-firm ; total waste recycled by firms
  tech-effect-operate-cost ; effect of efficiency improvement on operating cost
  sell-price-pre ; selling price of pre-separated plastic
  sell-price-post ; selling price of post-separated plastics
  fine-earnings ; earnings from fines
  total-sell-earning ; earnings from selling plastic
  total-collect-cost ; total collection costs
  total-operating-cost ; total operating costs
  offer-non-contracted-received ; offer quantity of plastic recieved
  offer-cost ; offer cost submitted
  offer-recycled ; offer for recycled quantity submitted
  offer-recycle-percent ; offer recycle percentage quoted
  investment-capacity ; cost for a cacity investment
  investment-tech ; cost for efficiency investement
  total-pre-separated-received ; total preseparated plastic recieved
]

;; contracts attributes
contracts-own [
  fine-cost ; fines cost agreed in contracts
  recycle-percentage-agreed ; recycle percentage agreed in negotiations
  contracted-waste-agreed ; waste quanitity agreed
  contract-period ; contract period
  contract-time-running ; proxy to check contract running time
  contract-price ; price of the contract based on offer price
  present-post-separation-rate ; post separation rate agreed
  contract-efficiency ; efficiency value of the firm
]

;;;;;;;;;;;;;;;;;;;;;;;
;;; Setup Functions ;;;
;;;;;;;;;;;;;;;;;;;;;;;

to setup
  clear-all
  setup-globals
  setup-municipalities
  setup-households
  setup-firms
  setup-municipal-population-counter
  reset-ticks
end

;; to setup all the globals in the model
to setup-globals
  Set recycle-percent-target initial-recycle-percent-target
  set tick-counter 0
  Set target-update-counter 0
  Set initiative-tick 0
end

;; to assign the initial municipal parameters
to setup-municipalities
  create-municipalities total-municipalities
  ask municipalities [
    setxy (min-pxcor + 1) (random-float -25 + 12) ; ensuring that the municipalities are always on the left corner of the world view
    set shape "house ranch"
    set size 3
    Set color violet - 2 + random 5 ; set the color of the municipality on different shades of violet

    ;;setting the initial value to attributes
    Set total-base-waste 0
    Set possible-recyclable-waste 0
    Set actual-recyclable-waste 0
    Set total-pre-separated-waste 0
    Set contracted-waste 0
    Set non-contracted-waste 0
    Set awareness-program 0
    Set fine? False
    set municipal-fine 0
    set municipal-fines-total 0
    Set total-fines 0
    Set awareness-cost 0
    Set knowledge-program 0
    Set knowledge-cost 0
    Set education-program-cost 15
    Set education-cost 0
    Set total-recycled-waste-municipality 0; sum of all recycled-waste-municipality
    Set recycling-rate-achieved 0
    Set municipal-expenditure 0
;; assigning collection infrastructure based on global probability
    if-else random-float 1 < percent-centralized-infra
    [
      Set collection-infra "centralised"
    ]
    [
      Set collection-infra "decentralised"
    ]
  ]
end

;; to assign the initial household parameters
to setup-households
  create-households random-normal (26 * total-municipalities)  2 ; assign population distribution
  ask households [
    setxy random-float -25 + 13 random-float -25 + 12 ; ensure that households are in the middle area of the world view
    Set municipality-belong one-of municipalities ; assign households to municipalities
    set size 1
    set shape "house"
    Set base-waste-function (40 - (0.04 * tick-counter - (e ^ (-0.01 * tick-counter)) * sin(0.3 * tick-counter * 57.2957795) ) / 12) ; 1 radian = 57.2957795 degrees
    Set base-waste 0
    Set is-awareness-training? False
    ;; assigning the distribution of knowledge and perception to households
    Set perception-to-recycle random-normal init-perception-to-recycle 0.06
    Set awareness-effectiveness random-normal init-awareness-effectiveness 0.02
    Set recyclable-waste 0
    Set is-knowledge-training? False
    Set pre-separate-percent random-normal init-pre-separate-percent 0.05
    Set knowledge-effectiveness random-normal init-knowledge-effectiveness 0.02
    Set pre-separated-waste 0
;; assigning the waste factor and color based on type of household
    let type-setter random-float 1 ; proxy for setting type of household, will be a assigned a random number from 0 -100
    if type-setter <= percentage-old
    [set household-type "old"
      set color blue
      Set waste-factor 0.75
    ]
    if type-setter > percentage-old and type-setter <= (percentage-single + percentage-old)
    [ set household-type "single"
      set color red
      Set waste-factor 1
    ]
    if type-setter > (percentage-single + percentage-old) and type-setter <= (percentage-single + percentage-old + percentage-couples)
    [ set household-type "couples"
      set color green
      Set waste-factor 2
    ]
    if type-setter > (percentage-single + percentage-old + percentage-couples)
    [ set household-type "family"
      set color yellow
      Set waste-factor 3
    ]
  ]
end

;; to assign the initial firm parameters
to setup-firms
  create-firms 4 [
    set color brown - 2 + random 5 ; all firms are different shades of brown
    set shape "factory"
    set size 2
    setxy (random-float -25 + 12) (max-pycor - 1) ; ensure that firms are always on the top on the world view
  ]
  ;; setting other attributes
  ask firms [
    Set capacity random-normal init-capacity 8500 ; capacity distribution
    Set efficiency random-normal init-efficiency 0.02 ; efficiency distribution
    Set operate-cost random-normal 0.35 0.05 ; operation cost distribution
    Set tech-effect-operate-cost 0.02
    Set sell-price-pre 0.43
    Set sell-price-post 0.87
    Set fine-earnings 0
    Set waste-collect-cost 0.1
    Set total-sell-earning 0
    Set total-operating-cost 0
    Set total-collect-cost 0
    Set offer-non-contracted-received 0
    Set offer-cost 0
    Set offer-recycled 0
    Set offer-recycle-percent 0
    Set investment-capacity 500000
    Set can-bid? True
    Set investment-tech 200000
    Set total-pre-separated-received 0
    Set total-waste-received-firm 0
    Set total-waste-post-separated 0
    Set total-waste-recycled-firm 0
    Set tech-improve? false
    Set capacity-improve? false
    Set capacity-effect-tech 0.04
    Set capacity-effect-operate-cost 0.05
    Set factory-cash-balance 10000000
    Set capacity-improve-time 0
    Set tech-improve-time 0
    set capacity-utilized 0
  ]
end

;; to setup up counters for eac type of household per municipality
to setup-municipal-population-counter
  ask municipalities[
    set municipality-singles-belong count households with [ municipality-belong = myself and household-type = "single" ] * 1000 ; 1000 households representation per agent
    set municipality-old-belong count households with [ municipality-belong = myself and household-type = "old" ] * 1000
    set municipality-couples-belong count households with [ municipality-belong = myself and household-type = "couples" ] * 1000
    set municipality-family-belong count households with [ municipality-belong = myself and household-type = "family" ] * 1000
    set municipality-population municipality-singles-belong + municipality-old-belong + municipality-couples-belong + municipality-family-belong
  ]
end

;;;;;;;;;;;;;;;;;;;
;;; Go Function ;;;
;;;;;;;;;;;;;;;;;;;

to go
  ;; update globals
  If-else target-update-counter < 11
  [
    set target-update-counter (target-update-counter + 1)
  ]
  [
    Set target-update-counter 0
    Set recycle-percent-target (recycle-percent-target + (percent-increase-target * recycle-percent-target))
  ]
  set initiative-tick (initiative-tick + 1)

  ;See if the contracts are running
  check-running-contracts
  check-facility-improve

  ;;ask households to start generating waste and raising awareness if any municipal intiatives are running
  improve-education
  generate-waste

  ;;Ask municipalities to start collecting the wastes and send requests for tender offers
  ask municipalities [
    accumulate-waste
    release-tender
  ]

  ;; ask municipality to
  settle-contract-prices ; and
  fine-check ; to pay fines, if any


  ;; ask firms to process the waste that is collected and therefore compute the expenditure
  ask firms [
    collect-waste
    compute-firm-expenditure
  ]

  ;;lastly asking the municipalities to do awareness programs if the national targets are not being met and raise awareness, if requred.
  ask municipalities [
    awareness-programs
    compute-municipal-expenditure
  ]

  ;; ensuring model stops at 20 years
  Set tick-counter (tick-counter + 1)
  if-else tick-counter < 240
  [ Tick ]
  [ stop ]

  ;; plotting the results that are needed
  plot-results
end

;; to schek the running contracts and release the tenders if the contracts are finished
to check-running-contracts
  ask contracts [
    if-else contract-time-running < contract-period
    [
      set contract-time-running contract-time-running + 1
    ]
    [
      die
    ]
  ]

  ask municipalities [
        set contracted-waste sum [contracted-waste-agreed] of my-contracts ; make corrections for the new contracted sum
        release-tender
      if my-contracts = 0
          [
            set contracted-waste 0 ; if there are no contarcts, there is no contracted sum
            release-tender
      ]
      ]
      ask firms [
        update-firm-processing ;; to ensure, no municipality is without contracts
      ]
end

;; to check for running awareness or knowledge programs and update the households. This is important before households collect waste fpr the given month
to improve-education
  ask households [
    If is-awareness-training? = True
    [
      Set awareness-effectiveness random-normal init-awareness-effectiveness 0.02 ; to ensure different effectiveness for each training
      Set perception-to-recycle (perception-to-recycle + awareness-effectiveness * perception-to-recycle)
      Set is-awareness-training? False
    ]

    If is-knowledge-training? = True
    [
      Set knowledge-effectiveness random-normal init-knowledge-effectiveness 0.02 ; to ensure different effectiveness for each training
      Set pre-separate-percent (pre-separate-percent + knowledge-effectiveness * pre-separate-percent)
      Set is-knowledge-training? False
    ]
  ]
end

;; actual waste generation and post separation by households
to generate-waste
  ask households [
    let infra [ collection-infra ] of municipality-belong ; proxy to set type of infrastructure
    if-else infra = "centralised" ; different motivation fators for centralised and decentralised infra
    [
      set infrastructure-effect 1
    ]
    [
      set infrastructure-effect 1.1
    ]
    Set base-waste-function (40 - (0.04 * tick-counter - (e ^ (-0.01 * tick-counter)) * sin(0.3 * tick-counter) )) / 12
    Set base-waste (base-waste-function * waste-factor * 1000) ; 1000 households per agent representation
    Set recyclable-waste (base-waste * perception-to-recycle)
    Set pre-separated-waste (recyclable-waste * pre-separate-percent * infrastructure-effect) ; motivation to pre-separate is dependant on infrastructure of the municipality
  ]
end

;; function of the municipality to accumulate the waste
to accumulate-waste
  Set total-base-waste sum [ base-waste ] of households with [ municipality-belong = myself ]
  Set possible-recyclable-waste total-base-waste * possible-recycle-percent
  Set actual-recyclable-waste sum [ recyclable-waste ] of households with [ municipality-belong = myself ]
  Set total-pre-separated-waste sum [ pre-separated-waste ] of households with [ municipality-belong = myself ]
end

;; release new tenders if the waste collected for the tick is more than contracted waste
to release-tender
  if actual-recyclable-waste > contracted-waste
  [
    Set non-contracted-waste (actual-recyclable-waste - contracted-waste)
    ;; to use the non-contracted-waste as input in link-context
    let non-contracted-volume non-contracted-waste ; proxy to be used in the functions ahead
    request-bid non-contracted-volume ; function to request for firm offers
    Set contracted-waste sum [ contracted-waste-agreed ] of my-contracts ; update contracted value once contract is made
  ]
end

;; this function is where the magic happens
to request-bid [ non-contracted-volume ]
  ask firms [
    submit-offer non-contracted-volume ; firms submit offers, after chencking whether they can bid based on capacity and efficiency
  ]
  ;; make a  contract with waste management firm with cheapest offer if they can bid
  ifelse count firms with [ can-bid? ] > 0
  [
    create-contract-with min-one-of firms [offer-cost]
    [
      set-contract-settings non-contracted-volume ; update the contract properties to make it binding. Some properties do not change per contract and some do
    ]
    ask firms [
      update-firm-processing ; firms update their capacity since new waste values are assigned. This means they might need to invest in capacity as well
    ]
  ]
  [
    ;; if there is no waste management firm that can make a contract, make a contract with the waste management firm that has the highest efficiency
    create-contract-with max-one-of firms [ efficiency ]
    [
      set-contract-settings non-contracted-volume ; same as above
    ]
    ask firms [
      update-firm-processing ; same as above
    ]
  ]
end

;; contract values are set here and are used as reference for calculations
to set-contract-settings [ non-contracted-volume ]
  set contract-period init-contract-period
  set contracted-waste-agreed non-contracted-volume
  set recycle-percentage-agreed [ offer-recycle-percent ] of other-end
  set fine-cost 500000
  set contract-price (  [ offer-cost ] of other-end )
  ;; if the collection infrastructure is decentralised, then the firms have spend more time and money on the collection of waste, so the price of a contract is increased
  if [ collection-infra ] of myself = "decentralised"  [
    set contract-price contract-price * 1.01
  ]
  ;; at the start of a contract the month variable is set to 0
  set contract-time-running 1
  set present-post-separation-rate [offer-recycled-post] of other-end
end

;; Firms calculate and submit offers when municipalities release tenders
to submit-offer [ non-contracted-volume ]
  Set offer-non-contracted-received non-contracted-volume
  let pre-separate-percent-req mean [pre-separate-percent] of households ; proxy to account for pre-separated waste that will be received
  Set offer-cost ((offer-non-contracted-received * waste-collect-cost) + (offer-non-contracted-received - (offer-non-contracted-received * pre-separate-percent-req))* operate-cost) ;; Calculating offer cost.
  Set offer-recycled-post ((offer-non-contracted-received - (offer-non-contracted-received * pre-separate-percent-req)) * efficiency)
  Set offer-recycled (offer-recycled-post + ((offer-non-contracted-received * pre-separate-percent-req )))
  Set offer-recycle-percent (offer-recycled / offer-non-contracted-received)
  firm-offer ; this is to check if the firm has enough spare capacity to actually make the bid
end

;; checking if firms can bid based on capacity and efficiency
to firm-offer
  ;; nested functions to check if firms can achieve target recycling percent followed by if they can actually process followed by whether they have cash-balance to invest
  If-else offer-recycle-percent >= recycle-percent-target
    [
      if-else capacity-utilized < 0.9 * capacity
      [
        if factory-cash-balance > 0
        [
          Set can-bid? True
        ]
      ]
      [
        Set can-bid? False ; if cannot bid due to capacity, then check for cash balance and invest in capacity
        if factory-cash-balance > 0
        [
          if capacity-improve? = False
          [
            Set capacity-improve? True
            Set factory-cash-balance (factory-cash-balance - investment-capacity)
            Set operate-cost (operate-cost + (capacity-effect-operate-cost * operate-cost))
            Set capacity-improve-time 1
          ]
        ]
      ]
  ]
  [
    Set can-bid? False ; if not due to recycling target, then check cash-balance and ivenst in efficiency
    if factory-cash-balance > 0
      [
        if tech-improve? = False
        [
          Set tech-improve? True
          Set factory-cash-balance (factory-cash-balance - investment-tech)
          Set operate-cost (operate-cost + (tech-effect-operate-cost * operate-cost))
          Set tech-improve-time 1
        ]
    ]
  ]
end

;; check for already running capacity or technology improvements and update the firms capacity or efficiency
to check-facility-improve
  ask firms
  [
    if capacity-improve? = True
    [
      if-else capacity-improve-time <= 12
      [
        Set capacity-improve-time (capacity-improve-time + 1)
      ]
      [
        Set capacity-improve-time 0
        Set capacity (capacity + (capacity-improve-percent * capacity))
        Set efficiency (efficiency + (capacity-effect-tech * efficiency)) ; capacity improvement effects efficiency as well
        Set capacity-improve? False
      ]
    ]
    if tech-improve? = True
    [
      if-else tech-improve-time < 12
      [
        Set tech-improve-time (tech-improve-time + 1)
      ]
      [
        Set tech-improve-time 0
        Set efficiency (efficiency + (tech-improve-percent * efficiency)) ; efficiency improvement has no effect on capacity
        Set tech-improve? False
      ]
    ]
  ]
end

;; update the utilized capacity once the contracts have been made
to update-firm-processing
  set capacity-utilized sum [ contracted-waste-agreed ] of my-contracts
  firm-offer ; go through investment cycle if required.
end

; municipality has to settle the expenditure from contracts
to settle-contract-prices
  ask municipalities [
    Set municipal-expenditure (municipal-expenditure + sum [ contract-price ] of my-contracts)
  ]
  ask firms [
    set factory-cash-balance (factory-cash-balance + sum [ contract-price ] of my-contracts) ; firms add to their cash balance the payments from municipality
  ]
end

;; Firms collect waste based on the contracts
to collect-waste
  let total-waste-received-central sum [ actual-recyclable-waste ] of contract-neighbors with [ collection-infra = "centralised" ] ; proxy for all centralized waste collection since cost is different
  let total-waste-received-decentral sum [ actual-recyclable-waste ] of contract-neighbors with [ collection-infra = "decentralised" ] ; proxy for all decentralized waste collection since cost is different
  Set total-waste-received-firm (total-waste-received-central + total-waste-received-decentral)
  Set total-pre-separated-received (total-waste-received-firm * (mean [pre-separate-percent] of households)) ; to see the applicability of fine
  Set total-waste-post-separated ((total-waste-received-firm - total-pre-separated-received) * efficiency)
  Set total-waste-recycled-firm (total-waste-post-separated + total-pre-separated-received)
  ask my-contracts [
    Set contract-efficiency [efficiency] of myself  ; contracts update the recent efficiency value since this is required by the municipalities to update their recycling targets.
  ]
  Set total-operating-cost ((total-waste-received-firm - total-pre-separated-received) * operate-cost)
  Set total-collect-cost ((total-waste-received-central * waste-collect-cost) + (total-waste-received-decentral * waste-collect-cost * 1.01))
  Set total-sell-earning ((sell-price-pre * total-pre-separated-received) + (sell-price-post * total-waste-post-separated)) ; calculate total earnings and expenditures of processing
end

to fine-check
  ask municipalities [
    ;    ;; municipalities can only pay fines if they have contracts
    if count my-contracts > 0 [
      let contract-value-difference 0
      let fine-of-contract 0
      ;
      ;      ;; determine if there is a difference between the amount of waste and the amount of waste in the contract
      ask my-contracts [
        set contract-value-difference (([ total-pre-separated-waste ] of myself ) - (( [actual-recyclable-waste] of myself ) * pre-separated-promised))
        set fine-of-contract fine-cost
      ]
      ;      ;; if there is not enough waste, pay the fine
      if contract-value-difference < 0 [
        ;
        set fine? true
        set municipal-fine fine-of-contract
        set municipal-fines-total municipal-fines-total + municipal-fine
        set municipal-expenditure municipal-expenditure + municipal-fine
        set total-fines total-fines + 1
        ask contract-neighbors [
          set factory-cash-balance factory-cash-balance + [ municipal-fine ] of myself ; allocate fine to the respective firms
          set fine-earnings fine-earnings + [ municipal-fine ] of myself
        ]
      ]
    ]
  ]
end

;; Update the final cash balance
to compute-firm-expenditure
  Set factory-cash-balance (factory-cash-balance + total-sell-earning - total-operating-cost + total-collect-cost)
end

;; run awareness programs if the national targets are not beine met
to awareness-programs
  Set total-efficiency-received sum [contract-efficiency] of my-contracts
  Set running-contracts count my-contracts
  Let actual-efficiency-received (total-efficiency-received / (running-contracts)) ;; calculate the mean efficiency of all the contarcts to get aggregate overview
  Set total-recycled-waste-municipality (((actual-recyclable-waste - total-pre-separated-waste) * (actual-efficiency-received)) + total-pre-separated-waste)
  Set recycling-rate-achieved (total-recycled-waste-municipality / possible-recyclable-waste)

;; check the procativeness of the municipalities
  if municipal-initiative-frequency <= initiative-tick
      [
        If recycling-rate-achieved < recycle-percent-target ; check if actual recycling rates are less than target to start awareness programs
        [
          set initiative-tick 0
          if random-float 1 < Act-towards-recycling-target
          [
            ask households with [ municipality-belong = myself ]
            [
              Set is-awareness-training? True
              Set is-knowledge-training? True
            ]
            ;; update the municipal exenditure after awareness programs
            Set awareness-cost (education-program-cost * (count households with [ municipality-belong = myself ]) * 1000)
            Set awareness-program awareness-program  + 1
            Set knowledge-cost (education-program-cost * (count households with [ municipality-belong = myself ]) * 1000)
            Set knowledge-program knowledge-program  + 1
            Set education-cost knowledge-cost + awareness-cost
          ]
        ]
  ]
;; knowledge increase if not enough fines have been collected
  If fine? = True
  [
     ask households with [ municipality-belong = myself ]
    [
      Set is-knowledge-training? True
    ]
    Set knowledge-cost (education-program-cost * (count households with [ municipality-belong = myself ]) * 1000)
    Set knowledge-program knowledge-program  + 1
    Set education-cost (education-cost + knowledge-cost)
    Set fine? False
  ]
end

;;Compute final expenditures.
to compute-municipal-expenditure
  Set municipal-expenditure (municipal-expenditure + education-cost)
end

;;;;;;;;;;;;;;;;;;;;;;
;;; Plot functions ;;;
;;;;;;;;;;;;;;;;;;;;;;

to plot-results

  set-current-plot "Capacity Utilized for Firms"
  ask firms [
    create-temporary-plot-pen ( word who )
    set-plot-pen-color color
    plot capacity-utilized
  ]

  set-current-plot "Capacity of Firms"
  ask firms [
    create-temporary-plot-pen ( word who )
    set-plot-pen-color color
    plot capacity
  ]

  set-current-plot "Awareness Increase"
  ask municipalities [
    create-temporary-plot-pen ( word who )
    set-plot-pen-color color
    plot mean [perception-to-recycle] of households with [ municipality-belong = myself ]
  ]

  set-current-plot "Operating Efficiency of Firms"
  ask firms [
    create-temporary-plot-pen ( word who )
    set-plot-pen-color color
    plot efficiency
  ]

  set-current-plot "Operation Cost for Firms"
  ask firms [
    create-temporary-plot-pen ( word who )
    set-plot-pen-color color
    plot operate-cost
  ]

  set-current-plot "Cash Balance Firms"
  ask firms [
    create-temporary-plot-pen ( word who )
    set-plot-pen-color color
    plot factory-cash-balance
  ]

  set-current-plot "Municipal Expenditure"
  ask municipalities [
    create-temporary-plot-pen ( word who )
    set-plot-pen-color color
    plot municipal-expenditure
  ]

  set-current-plot "Recycling Rate Achieved per Municipality"
  ask municipalities [
    create-temporary-plot-pen ( word who )
    set-plot-pen-color color
    plot recycling-rate-achieved
  ]

  set-current-plot "Fines Payed"
  ask municipalities [
    create-temporary-plot-pen ( word who )
    set-plot-pen-color color
    plot municipal-fines-total
  ]

  set-current-plot "Running Contracts per Municipality"
  ask municipalities [
    create-temporary-plot-pen ( word who )
    set-plot-pen-color color
    plot running-contracts
  ]

  set-current-plot "Actual Waste produced per Municipality"
  ask municipalities [
    create-temporary-plot-pen ( word who )
    set-plot-pen-color color
    plot actual-recyclable-waste
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
374
291
892
810
-1
-1
15.455
1
10
1
1
1
0
0
0
1
-16
16
-16
16
0
0
1
ticks
30.0

SLIDER
8
52
184
85
init-capacity
init-capacity
20000
100000
75000.0
5000
1
NIL
HORIZONTAL

SLIDER
8
88
184
121
init-efficiency
init-efficiency
0
1
0.2
0.01
1
NIL
HORIZONTAL

SLIDER
9
124
184
157
capacity-improve-percent
capacity-improve-percent
0
0.5
0.1
0.05
1
NIL
HORIZONTAL

SLIDER
9
160
185
193
tech-improve-percent
tech-improve-percent
0
0.5
0.06
0.01
1
NIL
HORIZONTAL

SLIDER
575
50
759
83
initial-recycle-percent-target
initial-recycle-percent-target
0
1
0.5
0.05
1
NIL
HORIZONTAL

SLIDER
575
121
760
154
possible-recycle-percent
possible-recycle-percent
0
0.8
0.8
0.1
1
NIL
HORIZONTAL

SLIDER
380
50
564
83
total-municipalities
total-municipalities
1
60
6.0
1
1
NIL
HORIZONTAL

SLIDER
382
160
565
193
percent-centralized-infra
percent-centralized-infra
0
1
0.5
0.1
1
NIL
HORIZONTAL

SLIDER
195
51
373
84
init-perception-to-recycle
init-perception-to-recycle
0
0.8
0.3
0.01
1
NIL
HORIZONTAL

SLIDER
195
125
376
158
init-awareness-effectiveness
init-awareness-effectiveness
0
0.2
0.02
0.01
1
NIL
HORIZONTAL

SLIDER
196
88
375
121
init-pre-separate-percent
init-pre-separate-percent
0
1
0.4
0.01
1
NIL
HORIZONTAL

SLIDER
195
160
376
193
init-knowledge-effectiveness
init-knowledge-effectiveness
0
0.2
0.01
0.01
1
NIL
HORIZONTAL

SLIDER
381
123
564
156
init-contract-period
init-contract-period
0
50
36.0
1
1
NIL
HORIZONTAL

SLIDER
380
87
564
120
pre-separated-promised
pre-separated-promised
0
1
0.25
0.05
1
NIL
HORIZONTAL

BUTTON
575
161
630
194
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
634
161
689
194
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
10
214
80
259
Old- Blue
(count households with [household-type = \"old\"] / count households) * 100
2
1
11

MONITOR
106
260
185
305
Single - Red
(count households with [household-type = \"single\"] / count households) * 100
2
1
11

MONITOR
82
214
184
259
Couples - Green
(count households with [household-type = \"couples\"] / count households) * 100
2
1
11

MONITOR
11
260
105
305
Family - Yellow
(count households with [household-type = \"family\"] / count households) * 100
2
1
11

MONITOR
11
307
185
352
Total Households
count households
17
1
11

SLIDER
575
85
759
118
percent-increase-target
percent-increase-target
0
0.2
0.03
0.01
1
NIL
HORIZONTAL

SLIDER
195
215
367
248
percentage-old
percentage-old
0
1
0.08
0.01
1
NIL
HORIZONTAL

SLIDER
196
250
368
283
percentage-single
percentage-single
0
1
0.32
0.01
1
NIL
HORIZONTAL

SLIDER
196
285
368
318
percentage-couples
percentage-couples
0
1
0.31
0.01
1
NIL
HORIZONTAL

SLIDER
196
320
368
353
percentage-family
percentage-family
0
1
0.29
0.01
1
NIL
HORIZONTAL

BUTTON
692
161
760
194
go-once
go\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
576
213
762
258
recycle-percentage-target
recycle-percent-target
2
1
11

PLOT
744
813
1101
1034
Capacity Utilized for Firms
Time(months)
Capacity Utilized
0.0
240.0
0.0
200000.0
true
true
"" ""
PENS

PLOT
14
606
369
810
Capacity of Firms
Time(months)
Capacity
0.0
240.0
0.0
200000.0
true
true
"" ""
PENS

PLOT
1336
31
1758
267
Awareness Increase
Time(months)
Awareness
0.0
240.0
0.0
1.0
true
true
"" ""
PENS

PLOT
14
387
366
601
Operating Efficiency of Firms
Time (months)
Efficiency
0.0
240.0
0.0
0.5
true
true
"" ""
PENS

PLOT
14
814
370
1034
Operation Cost for Firms
Time(months)
Operation Cost
0.0
240.0
0.0
1.0
true
true
"" ""
PENS

PLOT
378
814
737
1034
Cash Balance Firms
Time(months)
Cash Balance
0.0
240.0
0.0
1000000.0
true
true
"" ""
PENS

PLOT
1337
270
1757
538
Municipal Expenditure
Time(months)
Municipal Expenditure
0.0
240.0
0.0
1000000.0
true
true
"" ""
PENS

PLOT
909
30
1331
265
Recycling Rate Achieved per Municipality
Time(months)
Recycling rate 
0.0
240.0
0.0
1.0
true
true
"" ""
PENS
"Government target" 1.0 0 -2674135 true "" "plot recycle-percent-target"

SLIDER
383
214
565
247
Act-towards-recycling-target
Act-towards-recycling-target
0
1
0.8
0.05
1
NIL
HORIZONTAL

TEXTBOX
383
198
533
216
Pro-activeness of municipality
11
0.0
1

PLOT
1336
544
1758
803
Fines Payed
Time(months)
Fines Payed
0.0
240.0
0.0
1000000.0
true
false
"" ""
PENS

SLIDER
382
248
566
281
municipal-initiative-frequency
municipal-initiative-frequency
0
12
1.0
1
1
NIL
HORIZONTAL

PLOT
910
543
1333
801
Running Contracts per Municipality
Time(months)
contracts
0.0
240.0
0.0
10.0
true
true
"" ""
PENS

TEXTBOX
89
21
239
39
FIRMS
11
35.0
1

TEXTBOX
215
22
365
40
HOUSEHOLDS
11
0.0
1

TEXTBOX
382
23
532
41
MUNICIPALITIES\n
11
115.0
1

TEXTBOX
577
23
727
41
GLOBALS\n
11
0.0
1

TEXTBOX
198
200
348
218
Household Distribution
11
0.0
1

PLOT
910
269
1332
537
Actual Waste produced per Municipality
Time(months)
Waste produced
0.0
240.0
0.0
100.0
true
true
"" ""
PENS
"Possible waste" 1.0 0 -2674135 true "" "plot mean [possible-recyclable-waste] of municipalities"

TEXTBOX
975
8
1125
26
MUNICIPAL PLOTS
11
0.0
1

TEXTBOX
36
369
186
387
FIRMS PLOTS
11
0.0
1

@#$#@#$#@
## WHAT IS IT?

This model demonstrates the collection and processing of waste by a group of waste management firms, made by households, in different municipalities. It was made to show the policy space municipalities have with their waste.

## HOW IT WORKS

In every tick, households will produce certain amount of waste. Households will check: their degree of perception and knowledge, and the type of collection infrastructure in their municipality. The plastic waste not pre-separated by households makes up total amount of waste in need to be post-separated by firms to improve recycling rate of the municipalities. , the municipalities will demand for contracts offered by waste-processing companies by tender mechanism and will choose contracts that has highest overall recycling rate and lowest monthly price offer. If no companies can comply with the necessary capacity, the municipality will look for companies with highest efficiency and give the contract to them.

Companies will collect waste from the collection infrastructures and incur collection cost accordingly. For waste already pre-separated by households, companies will just collect the pre-separated recyclable waste. For waste not pre-separated, companies will have to collect the combined the whole municipal plastic waste and post-separate them.

Municipalities will check if: percentage of pre-separated waste of households is lower than what is specified in the contract, and whether total recycling rate is lower than the Ministry target; on either/both ways, they will commit perception and knowledge-stimulating activities. Lastly municipalities will pay fines if they do not provide the agreed pre-separated amount of wastes

## HOW TO USE IT

There are different sliders for chaning parameter values for each agent and globals. Play with the values to see when the municipalities reach their targets. Setup button creates the initial model and you can vary the population distribution among municipalities. The number of firms is fixed but their capacity can be adjusted to make the model realistic. 

The Go button starts the model and each tick represents a month. The contracts are made for additional collected waste and the duration of the contracts can be changed to exhibit different emergent behaviours in terms of competition and the rate of improvement of recycling. One can also hypothesize the effect of certain slider on the municipal expenditure and recycling rates and perform parameter sweeps to to exploration.

## THINGS TO NOTICE

Notice how the different municipal numbers change the competition within the firms to make offers. Municipalities can have educational activities to improve the recycle knowledge and perception of their households. Notice what difference this makes in their recycle percentage.

Notice how duration of contracts affects the innovation level of the firms and how having more centralized or decentralized effects the recycling rate of the households.

## THINGS TO TRY

Try to run the model at full centralized vs full decentralized collection infrastructure.

Also try to understand the competition of firms when there is just one municipality compared to when there are multiple municipalities. 

What value of procativeness facilitates the municipalities to reac their targets. 

## EXTENDING THE MODEL

Add a profit and retrun of investment forecast function for the firms. 
try to add different incentive mechanisms for firms to innovate other than price. 
What happens if the contracts are made on a multi-criteria analysis including, duration, cost and recycling rate?


## CREDITS AND REFERENCES

Gurvinder Arora (4617479)
Rizky Januar (4614267)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

factory
false
0
Rectangle -7500403 true true 76 194 285 270
Rectangle -7500403 true true 36 95 59 231
Rectangle -16777216 true false 90 210 270 240
Line -7500403 true 90 195 90 255
Line -7500403 true 120 195 120 255
Line -7500403 true 150 195 150 240
Line -7500403 true 180 195 180 255
Line -7500403 true 210 210 210 240
Line -7500403 true 240 210 240 240
Line -7500403 true 90 225 270 225
Circle -1 true false 37 73 32
Circle -1 true false 55 38 54
Circle -1 true false 96 21 42
Circle -1 true false 105 40 32
Circle -1 true false 129 19 42
Rectangle -7500403 true true 14 228 78 270

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

house ranch
false
0
Rectangle -7500403 true true 270 120 285 255
Rectangle -7500403 true true 15 180 270 255
Polygon -7500403 true true 0 180 300 180 240 135 60 135 0 180
Rectangle -16777216 true false 120 195 180 255
Line -7500403 true 150 195 150 255
Rectangle -16777216 true false 45 195 105 240
Rectangle -16777216 true false 195 195 255 240
Line -7500403 true 75 195 75 240
Line -7500403 true 225 195 225 240
Line -16777216 false 270 180 270 255
Line -16777216 false 0 180 300 180

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="30" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>recycling-rate-achieved</metric>
    <metric>municipal-expenditure</metric>
    <enumeratedValueSet variable="percentage-old">
      <value value="0.08"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percentage-single">
      <value value="0.32"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="init-efficiency">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="init-pre-separate-percent">
      <value value="0.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percentage-couples">
      <value value="0.31"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="total-municipalities">
      <value value="11"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Act-towards-recycling-target">
      <value value="0.9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-centralized-infra">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="possible-recycle-percent">
      <value value="0.75"/>
      <value value="0.85"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percentage-family">
      <value value="0.29"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="init-contract-period">
      <value value="36"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-increase-target">
      <value value="0.02"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="municipal-initiative-frequency">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="init-knowledge-effectiveness">
      <value value="0.04"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tech-improve-percent">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-recycle-percent-target">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="init-perception-to-recycle">
      <value value="0.31"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="capacity-improve-percent">
      <value value="0.15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="init-capacity">
      <value value="85000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="init-awareness-effectiveness">
      <value value="0.04"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pre-separated-promised">
      <value value="0.25"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
