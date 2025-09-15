# Leader personalities

#### Default personalities

[CBE leader personalities](https://docs.google.com/spreadsheets/d/1rKgPRnXtAhYZ5JGsSHxbaAGWie52tFAyWI5JbsF7A8U/edit?gid=473300739#gid=473300739)

Compare to Civ 5: [CIV V Interactive AI Bias Value Chart](http://civdata.com/)

#### Ideas for more unique personalities

- Barre (AFRICAN_UNION): peaceful (strong), growth (strong), purity, friendly
- Daoming (PAN_ASIA): production (strong), expansion (moderate), supremacy, closed/guarded
- Élodie (FRANCO_IBERIA): culture (strong), pro-alien (strong), harmony, untrustworthy
- Fielding (ARC): espionage (strong), expansionist (strong), supremacy, aggressive/warlike (strong)
- Hutama (POLYSTRALIA): trade (strong), Harmony, balanced
- Kavitha (INDIA): growth (strong), culture (moderate-strong), pro-alien (strong), HARMONY, FRIENDLY
- Koslov (RUSSIA): orbital (strong), expansionist (strong), anti-alien (strong), purity, closed/guarded
- Rejinaldo (BRASILIA): military (strong), anti-alien (strong), purity, AGGRESSIVE/warlike (strong)
- Arshia (AL_FALAH): land/tile improvements (strong), expansion/growth (moderate), Harmony, friendly
- Hughes (NORTH_SEA_ALLIANCE): ocean/naval (strong), health (moderate), supremacy, balanced
- Lena (INTEGR): infrastructure/production (strong), energy/science (moderate), Purity, untrustworthy
- Moon (CHUNGSU): espionage (strong), science (moderate), SUPREMACY, untrustworthy

#### How AI leader flavours work

- Valid leader flavour values seem to be 1 to 10
  - Other flavours can go as high as 100 (e.g. technologies)
- The game randomises this value at runtime
  - This seems to be controlled by `FLAVOR_RANDOMIZATION_RANGE` in globalaidefines.xml
  - This defaults to 2
    - So if a value is set to 5, it could range from 3-7
    - A value of 10 could range from 8-10
    - A value of 12 would be always 10
- These values only seem to be taken into account at certain points in the AI decision-making process, so even a value of 12 may lead to unexpected AI behaviour if the AI is programmed to act a certain way in certain circumstances without consulting flavours

For more information, see:

- [Community Ideas: Diplomacy Flavors for AI Leaders](https://forums.civfanatics.com/threads/community-ideas-diplomacy-flavors-for-ai-leaders.666737/)
- [CivilizationV: The guide of leader flavors!](https://forums.civfanatics.com/threads/civilizationv-the-guide-of-leader-flavors.401897/)
- [What does modifying <FLAVOR> do](https://forums.civfanatics.com/threads/what-does-modifying-flavor-do.430701/)
