## To do

- [x] Overwrite all leader tech/wonder audio
- [x] Remove hybrid affinities from all techs; hybrid affinity should be a choice, not an accident
- [x] Adjust all leader traits to have stronger personalities
- [x] Add new leader intro text for all leaders to reflect darker theme
  - [x] Modify all leader intro text
  - [x] Modify `IntroductionQuote` for all leaders to use any available intro text? Instead of just for that leader
- [x] Find a way to bring text from victory dialogue to the front; it's interesting
- [ ] Test with base game

<!--

# Beyond Earth: Eclipse

📌 [See my other Civ projects here](https://github.com/search?q=user%3Abmaupin+topic%3Acivilization&type=Repositories)

A small mod for Sid Meier's Civilization: Beyond Earth to give it more flavour. This mod was meant to bring out the world building that already exists in the game but not to drastically change it. For mods that have a bigger gameplay impact, see:

- [Anchor Ceti](https://forums.civfanatics.com/threads/anchor-ceti-a-story-in-beyond-earth.664817/)
- [Ryika's mods](https://steamcommunity.com/id/ryika/myworkshopfiles/?appid=65980)
- [Codex](https://steamcommunity.com/sharedfiles/filedetails/?id=780912351) is another massive mod but has been delisted as its complexity can lead to stability issues

## Installation

TODO

## Features

### Leaders

#### Tech and wonder quotes are now spoken by sponsors

All tech and wonder quotes from sponsors have had their audio overridden so that they're now spoken by the respective sponsor instead of the same narrator that narrates most of the rest of the game in order to add more variety to the spoken dialogue.

ⓘ This was inspired by Alpha Centauri, in which quotes are spoken by the various faction leaders in the game and not by the narrator.

#### Stronger leader personalities

Leaders have been adjusted to have more distinct personalities:

- Stronger preference for a particular affinity
- More extreme values for leader traits (bold, loyal, guarded, deceptive, friendly, etc.)
- A strong focus on one or two aspects for each leader (growth, production, trade, espionage, military, culture, etc.)

ⓘ This was also inspired by Alpha Centauri. Instead of blank-slate faction leaders, each leader has a strong personality. Rather than making the game boring and predictable, Alpha Centauri was lauded for its memorable and interesting factions.

#### New intro text for all leaders

Leaders have been given new intro text to align with the personality changes as well as fit the new story premise of the mod.

In addition, the intro text for any leader may show when the game is started, not just the currently selected leader. This helps increase world building, especially in the case for players who typically only play as certain factions.

### Affinities

#### Tech tree affinities have been reverted to base game values

Rising Tide added affinity values to techs that previously didn't have any (like many branch techs) and also added multiple affinities to many techs. This was possibly to ensure players were more likely to interact with hybrid affinities in the game, but it made acquiring any particular affinity less intentional.

These changes have been reverted in this mod, so that acquiring any particular affinity once again is an intentional choice the player can make rather something they fall into as a result of progressing through the tech web.

### Victories

#### Transcendence victory objective popups have been fixed

Each victory has different objectives that can contain some interesting world building. In Rising Tide, functionality was added to show these objectives in popups except for the transcendence (harmony) victory. This mod fixes those popups.

## Usage

TODO

## Manual installation

TODO

## Other ideas/wishlist

### Leaders

#### Replace other leader quotes

It seems there are other leader quotes that haven't been replaced, such as affinity progress (see Harmony level 5 quote from Daoming Sochua, for example).

### Affinities

#### Make affinity bonuses more disctinct

Right now the unit promotion bonuses across the different affinities aren't differentiated enough. While this makes the game fairly well balanced, this results in a bit of "ludonarrative" dissonance in which the gameplay of each affinity does not necessarily match the world building.

It would be more interesting if, for example, harmony was given bonuses related to their harmonious relationship with the planet, so for example health and movement. Purity could be given bonuses of strength and attack. And supremacy could be given bonuses to technology and range.

#### Make affinity choice more impactful

One current problem with the affinities (and other game systems) is that there are few tradeoffs other than opportunity cost. Specifically, the player can max out all affinities if she wishes to do so. Instead, as the player progresses in one affinity I think it could be more interesting to gradually reduce the maximum level of the other affinities in such a way that only one affinity victory condition could be achieved.

For example, the max affinity level in Rising Tide is 18 and affinity victories need a minimum affinity of 15. If the player reaches affinity level 9 in one affinity, for every level after that, the maximum level of the other affinities could be reduced by 1. This would allow the player to reach level 18 in only one affinity (capping the others at level 9), or alternatively the player could reach level 15 in one affinity to fulfill its victory conditions while still reaching level 10 in at least one other affinity in order to take advantage of hybrid bonuses.

This could even be extended to include blocking higher level affinity technologies to make specialising in one affinity more of an interesting choice.

#### Affinity progress should be more dependant on player actions

Affinity progress is almost entirely made through researching technologies. This isn't bad in and of itself, but it means that player actions have little impact on choice of affinity, potentially leading to bizarre outcomes such as a player who chooses the harmony affinity and proceeds to wipe out all alien life. Instead, it would be much more interesting if player action had a greater impact on affinity. For example, a player could receive harmony affinity points for every alien in her borders at the end of each turn that she does not attack, or every tile of miasma in her borders left untouched.

Quests do give some affinity points, but this could also likewise be given more weight.

### Victories

#### Show victory prologue text

The game has interesting story-building text for each victory as a prologue. This mod has code to show this prologue text in a popup, but in the end it got too complicated and messy to sort out. It might still be worth showing this text to add to the world building.

-->
