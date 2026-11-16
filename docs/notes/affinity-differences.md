# Effects of differing affinities

## Ways to adjust

#### Make leaders care about affinity differences

Increase leader `AffinityDevotion` value to 7 or higher, otherwise they will be less likely to care about affinity differences.

#### Make affinity differences matter sooner

Decrease `OPINION_WEIGHT_AFFINITY_DIFFERS_MIN_PERCENT_TOWARDS_MAX_LEVEL` in (in GlobalDiplomacyAIDefines.xml)

This represents the affinity percentage of the max above which affinity differences matter. The default value is 25, and max affinity is 18, so that's affinity level 4.5.

So this means both player's affinities would have to be > 4.5 by default for affinity differences to matter.

A value of `10` would mean affinity differences would start to matter as soon as each player had affinity level ~2 or greater.

#### Decrease the amount of affinity difference that triggers a decrease to respect

Increase `OPINION_WEIGHT_AFFINITY_DIFFERS` in (in GlobalDiplomacyAIDefines.xml)

The default value is 20

TODO: fill this out

#### Increase the impact affinity differences have

- For warnings, decrease `RespectChange` for `REACTION_AFFINITY_DIFFERS_WARNING` in CivBEReactions.xml
- For confrontations, decrease `RespectChange` for `REACTION_AFFINITY_DIFFERS_CONFRONTATION` in CivBEReactions.xml

#### Change the frequency that different affinities will impact respect

Change `MinTurnsBetween` and/or `ThrottleTurns` for `REACTION_AFFINITY_DIFFERS_WARNING` or `REACTION_AFFINITY_DIFFERS_CONFRONTATION` in CivBEReactions.xml

## Details

#### Generating score

ⓘ See [CvDiplomacyAI::GetAffinityDiffersScore](https://github.com/bmaupin/beyond-earth-recomp/blob/main/src/CvDiplomacyAI.cpp)

The score is 0 in these conditions:

- One of the players has no affinity or no dominant affinity
- Dominant affinity of both players is the same
- Either player's affinity is less than a minimum percentage of possible max affinity
  - `OPINION_WEIGHT_AFFINITY_DIFFERS_MIN_PERCENT_TOWARDS_MAX_LEVEL`
  - The default value is 25 (in GlobalDiplomacyAIDefines.xml)
  - Max affinity is 18, so that's affinity level 4.5

If none of those conditions are matched, the score is calculated like this:

1. Take the highest affinity of the "target player" (e.g. the human player if you are considering how AI players' respect will change towards you)
1. Then get the highest affinity of the requesting player (the AI), double it, and add that to the score
1. Then reduce it by multiplying it by a multiplier based on affinity devotion
   - AffinityDevotion (see Leaders table) of 7 or higher is 100%, so no effect
   - Lower than that can be 50% or 75%
1. Finally, add the value of `OPINION_WEIGHT_AFFINITY_DIFFERS` as a base score
   - The default value is 20 (in GlobalDiplomacyAIDefines.xml)

## Effect

If affinity differs, respect will be negatively impacted. Thresholds are hard-coded in DefaultReactionHelpers.lua:

- Score > 25: warning
- Score > 50: confrontation

#### Warnings

- Respect change of -10
  - See `REACTION_AFFINITY_DIFFERS_WARNING` in CivBEReactions.xml

#### Confrontation

- Respect change of -15
  - See `REACTION_AFFINITY_DIFFERS_CONFRONTATION` in CivBEReactions.xml
