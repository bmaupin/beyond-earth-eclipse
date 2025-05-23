# Beyond Earth: Eclipse

📌 [See my other Civ projects here](https://github.com/search?q=user%3Abmaupin+topic%3Acivilization&type=Repositories)

A small mod for Sid Meier's Civilization: Beyond Earth to give it more flavour. Features include:

- Tech and wonder quotes are now spoken by sponsors
- More distinct leader personalities
- New intro text for all leaders
- Tech tree affinities have been reverted to base game values
- Transcendence victory objective popups have been fixed
- Compatible with base game and Rising Tide

## Installation

⚠️ If you're playing on Linux, install the patch here to fix the crash when using mods: [https://github.com/bmaupin/civ-be-linux-fixes/](https://github.com/bmaupin/civ-be-linux-fixes/)

Install the mod from Steam here or see below for manual installation instructions:<br>
<a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3478662712">
<img src="assets/steam-store-badge.webp" alt="Available on Steam" width="200px">
</a>

## Usage

1. Install the mod
1. Start Beyond Earth and go to the _Mods_ menu
1. Check _Eclipse_ and any other desired mods

## Features

Sid Meier's Alpha Centauri was used as an inspiration for much of this; while it lacks the gameplay and user experience amenities of modern strategy games, it still has some of the best world building of any strategy game.

This mod was meant to bring out the world building that already exists in Beyond Earth but not to drastically change it. For mods that have a bigger gameplay impact, see:

- [Anchor Ceti](https://forums.civfanatics.com/threads/anchor-ceti-a-story-in-beyond-earth.664817/)
- [Ryika's mods](https://steamcommunity.com/id/ryika/myworkshopfiles/?appid=65980)

### Leaders

#### Tech and wonder quotes are now spoken by sponsors

All tech and wonder quotes from sponsors have had their audio overridden so that they're now spoken by the respective sponsor instead of the same narrator that narrates most of the rest of the game in order to add more variety to the spoken dialogue.

#### Stronger leader personalities

Leaders have been adjusted to have more distinct personalities:

- Stronger preference for a particular affinity
- More extreme values for leader traits (bold, loyal, guarded, deceptive, friendly, etc.)
- A strong focus on one or two aspects for each leader (growth, production, trade, espionage, military, culture, etc.)

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

## Manual installation

#### Linux

Download the repository source file from [Releases](https://github.com/bmaupin/beyond-earth-eclipse/releases), extract it, and then run the install script:

```
./scripts/install-mod.sh
```

Or:

1. Go to [Releases](https://github.com/bmaupin/beyond-earth-eclipse/releases) and download the `.civbemod` file
1. Create a new directory named `Eclipse (v 1)`
   - 👉 Update the value after `(v ` with the version from the filename
1. Extract the contents of the `.civbemod` file to the directory you created (it's compressed using 7zip)
1. Move the directory to the mods directory
   - Native: ~/.local/share/aspyr-media/Sid Meier's Civilization Beyond Earth/MODS/
   - Proton: ~/.steam/steam/steamapps/compatdata/65980/pfx/drive_c/users/steamuser/Documents/My Games/Sid Meier's Civilization Beyond Earth/MODS

#### Windows

1. Go to [Releases](https://github.com/bmaupin/beyond-earth-eclipse/releases) and download the `.civbemod` file
1. Copy it to Documents/My Games/Sid Meier's Civilization Beyond Earth/MODS

<!-- 🤷‍♂️

## Story

Darkness has fallen across the planet.

After the Great Mistake, Earth's leaders came together and put aside their petty differences in order to ensure humanity's survival. This new idealistic outlook persisted as the various sponsors sent groups of colonists across the starts to settle a new planet.

But something has changed. Has some kind of microscopic organism infected the population? Is it due to cosmic radiation or the subtle change in hue of their new star? Or have these brave new humans simply fallen into old habits and predjudices now that they have started to find a semblance of normality on this harsh alien planet?

Whatever the cause may be, it is clear that while some have held on to the same utopian ideals that boosted them from Earth to a new planet, for many more these ideals have been replaced with old tendencies of tribalism, selfishness, and suspicion.

Will humanity repeat the same failures that lead to the Great Mistake? Will they descend further into a dark distopia? Or will they rise above the new challenges they face?

Now is your time to help decide the fate of those who have left Earth and find themselves very far from home.

-->

## Other ideas/wishlist

### Leaders

#### Replace other leader quotes

It seems there are other leader quotes that haven't been replaced, such as affinity progress (see Harmony level 5 quote from Daoming Sochua, for example).

### Affinities

#### Make affinity bonuses more distinct

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
