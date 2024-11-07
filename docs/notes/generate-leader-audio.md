## Generate leader audio

#### Steps

1. Go to leader audio

   - /Sid Meier's Civilization Beyond Earth/steamassets/assets/sounds/speech/shared/
   - /Sid Meier's Civilization Beyond Earth/steamassets/assets/dlc/expansion1/sounds/speech/shared/

1. For any particular leader, listen to all of the audio and pick files that are in English (since that's the language the quotes are in)

   ```
   for filename in *.mp3; do echo $filename; mpv $filename; read -n 1 -s -r -p "Press any key to continue to next file"; echo; done
   ```

1. Join the files using ffmpeg, e.g.

   ```
   ffmpeg -i "concat:fieldingattacked.mp3|fieldinghatehello.mp3|fieldinghateletshearit01.mp3|fieldinghateletshearit02.mp3|fieldinghateletshearit03.mp3|fieldinghateno01.mp3|fieldinghateno02.mp3|fieldinghateno03.mp3|fieldinghateyes01.mp3|fieldingintro.mp3|fieldinglosewar.mp3|fieldingneutralhellob.mp3|fieldingneutralletshearit01.mp3|fieldingneutralletshearit02.mp3|fieldingneutralletshearit03.mp3|fieldingneutralno01.mp3|fieldingneutralno02.mp3|fieldingneutralyes01.mp3|fieldingneutralyes02.mp3|fieldingneutralyes03.mp3|fieldingrequest.mp3" -acodec copy fielding.mp3
   ```

1. Generate new audio

1. Encode using ffmpeg

   ```
   for file in *.wav; do
     ffmpeg -i "$file" -codec:a libmp3lame -b:a 128k -ac 1 "${file%.wav}.mp3"
   done
   ```

1. Copy to src/ using the exact same path and filename as the game

   💡 To make this easier, in the filter box on SteamDB type `english/tech/tech` or `english/wonders/` to show only the files we want

   - Base game: https://steamdb.info/depot/65981/
   - Rising Tide: https://steamdb.info/depot/353830/

   e.g.

   ```
   mv ~/Desktop/Your\ most\ valuable\ human\ 1.mp3 src/Assets/Sounds/Speech/English/Wonders/MarkovEclipse.mp3
   ```

1. Generate the list of audio files and add them to .modinfo

   ```
   cd src; find Assets/ -type f | sort >> Eclipse.modinfo; cd ..
   ```

1. Reformat .modinfo as needed

1. Package mod to regenerate checksums

   ```
   ./scripts/package-mod.sh
   ```

#### Arshia

TODO: no English audio

#### ~~Barre (People's African Union)~~

```
ffmpeg -i "concat:barreattacked.mp3|barredeclarewar.mp3|barredefeated.mp3|barrehatehello.mp3|barrehateletshearit01.mp3|barrehateletshearit02.mp3|barrehateletshearit03.mp3|barrehateno02.mp3|barrehateno03.mp3|barrehateyes01.mp3|barrehateyes02.mp3|barrehateyes03.mp3|barreneutralletshearit03.mp3|barreneutralno02.mp3|barreneutralno03.mp3|barreneutralyes03.mp3|barrepeaceful.mp3|barrerequest.mp3" -acodec copy barre.mp3
```

#### ~~Élodie~~

(French)

```
ffmpeg -i "concat:elodiedefeated.mp3|elodiehatehello.mp3|elodiehateletshearit02.mp3|elodiehateletshearit03.mp3|elodiehateno01.mp3|elodiehateno02.mp3|elodiehateno03.mp3|elodiehateyes02.mp3|elodiehateyes02.mp3|elodieintro.mp3|elodieneutralhello.mp3|elodieneutralletshearit01.mp3|elodieneutralletshearit03.mp3|elodieneutralno02.mp3|elodieneutralno03.mp3|elodieneutralyes01.mp3|elodiepeaceful.mp3|elodierequest.mp3" -acodec copy elodie.mp3
```

(English)

- elodiehateletshearit01.mp3
- elodieneutralno01.mp3

Modified text for better pronunciation:

- Within the Drone Sfeer I am reminded of nothing less than the apex of versai, with each man and woman a Sun King or Queen, surrounded by fawning courtiers.
- I cannot dislike the bite geist, because despite its insufferable chirpy ubiquity, it is entirely too helpful to be without.
- We have discovered alien life on our new world. Unsurprisingly, it grows, reproduces, daiz, and cannot understand French.

#### ~~Fielding (ARC)~~

```
ffmpeg -i "concat:fieldingattacked.mp3|fieldinghatehello.mp3|fieldinghateletshearit01.mp3|fieldinghateletshearit02.mp3|fieldinghateletshearit03.mp3|fieldinghateno01.mp3|fieldinghateno02.mp3|fieldinghateno03.mp3|fieldinghateyes01.mp3|fieldingintro.mp3|fieldinglosewar.mp3|fieldingneutralhellob.mp3|fieldingneutralletshearit01.mp3|fieldingneutralletshearit02.mp3|fieldingneutralletshearit03.mp3|fieldingneutralno01.mp3|fieldingneutralno02.mp3|fieldingneutralyes01.mp3|fieldingneutralyes02.mp3|fieldingneutralyes03.mp3|fieldingrequest.mp3" -acodec copy fielding.mp3
```

#### Hughes

```
ffmpeg -i "concat:hughesattacked.mp3|hughesdeclarewar.mp3|hughesdefeated.mp3|hugheshatehello.mp3|hugheshateletshearit01.mp3|hugheshateletshearit02.mp3|hugheshateletshearit03.mp3|hugheshateno01.mp3|hugheshateno02.mp3|hugheshateno03.mp3|hugheshateyes01.mp3|hugheshateyes02.mp3|hugheshateyes03.mp3|hughesintro.mp3|hughesneutralhello.mp3|hughesneutralletshearit01.mp3|hughesneutralletshearit02.mp3|hughesneutralletshearit03.mp3|hughesneutralno01.mp3|hughesneutralno02.mp3|hughesneutralno03.mp3|hughesneutralyes01.mp3|hughesneutralyes02.mp3|hughesneutralyes03.mp3|hughespeaceful.mp3|hughesrequest.mp3" -acodec copy hughes.mp3
```

#### ~~Hutama~~

```
ffmpeg -i "concat:hutamaattacked.mp3|hutamadeclarewar.mp3|hutamadefeated.mp3|hutamahateletshearit01.mp3|hutamahateletshearit02.mp3|hutamahateletshearit03.mp3|hutamahateno01.mp3|hutamahateno02.mp3|hutamahateno03.mp3|hutamahateyes01.mp3|hutamahateyes02.mp3|hutamahateyes03.mp3|hutamaneutralhello.mp3|hutamaneutralletshearit01.mp3|hutamaneutralletshearit02.mp3|hutamaneutralletshearit03.mp3|hutamaneutralno01.mp3|hutamaneutralno02.mp3|hutamaneutralno03.mp3|hutamaneutralyes01.mp3|hutamaneutralyes03.mp3|hutamapeaceful.mp3|hutamarequest.mp3" -acodec copy hutama.mp3
```

#### ~~Kavitha~~

```
ffmpeg -i "concat:kavithaattacked.mp3|kavithadeclarewar.mp3|kavithadefeated.mp3|kavithahatehello.mp3|kavithahateletshearit01.mp3|kavithahateno02.mp3|kavithahateno03.mp3|kavithahateyes01.mp3|kavithahateyes02.mp3|kavithahateyes03.mp3|kavithaintro.mp3|kavithaneutralletshearit01.mp3|kavithaneutralletshearit02.mp3|kavithaneutralno02.mp3|kavithaneutralno03.mp3|kavithaneutralyes01.mp3|kavithaneutralyes02.mp3|kavithapeaceful.mp3" -acodec copy kavitha.mp3
```

Modified text for better pronunciation:

- Behold unsleeping sainosure, the golem whose minds span kalpa.

#### ~~Koslov~~

(Ukrainian/Russian with Polish accent)

```
ffmpeg -i "concat:kozlovattacked.mp3|kozlovdeclarewar.mp3|kozlovdefeated.mp3|kozlovhatehello.mp3|kozlovhateletshearit01.mp3|kozlovhateletshearit02.mp3|kozlovhateletshearit03.mp3|kozlovhateno01.mp3|kozlovhateno02.mp3|kozlovhateno03.mp3|kozlovhateyes01.mp3|kozlovhateyes02.mp3|kozlovhateyes03.mp3|kozlovintro.mp3|kozlovneutralhello.mp3|kozlovneutralletshearit01.mp3|kozlovneutralletshearit02.mp3|kozlovneutralletshearit03.mp3|kozlovneutralno01.mp3|kozlovneutralno02.mp3|kozlovneutralno03.mp3|kozlovneutralyes01.mp3|kozlovneutralyes02.mp3|kozlovneutralyes03.mp3|kozlovpeaceful.mp3|kozlovrequest.mp3" -acodec copy kozlov.mp3
```

#### Lena

TODO: no English audio

#### Moon

TODO: no English audio

#### ~~Rejinaldo~~

(Spanish?)

```
ffmpeg -i "concat:rejinaldodefeated.mp3|rejinaldohateletshearit01.mp3|rejinaldohateletshearit03.mp3|rejinaldohateno01.mp3|rejinaldohateno02.mp3|rejinaldohateno03.mp3|rejinaldohateyes01.mp3|rejinaldohateyes02.mp3|rejinaldointro.mp3|rejinaldoneutralhello.mp3|rejinaldoneutralletshearit03.mp3|rejinaldoneutralno02.mp3|rejinaldoneutralno03.mp3|rejinaldoneutralyes01.mp3|rejinaldoneutralyes02.mp3|rejinaldoneutralyes03.mp3|rejinaldorequest.mp3" -acodec copy rejinaldo.mp3
```

Modified text for better pronunciation:

- There's an old soldier's axiom, "You can't kill what you can't see". The inverse is also true.
- Do not assume the battleground is impahrshel or in your favor.
- It has been said, 'The point of war is not to dai for your country, but to make your enemy dai for theirs'. A goal which is more readily accomplished if your side never has to take the field.
- The best way to survaive a firefight is to be elsewhere when your enemy starts one.
- Advokayts of maneuver warfare must not fall into the trap of loving maneuver for its own sake.

#### ~~Sochua~~

(Mandarin?)

```
ffmpeg -i "concat:sochuaattacked.mp3|sochuadeclarewar.mp3|sochuadefeated.mp3|sochuahatehello.mp3|sochuahateletshearit01.mp3|sochuahateletshearit02.mp3|sochuahateletshearit03.mp3|sochuahateno01.mp3|sochuahateno02.mp3|sochuahateno03.mp3|sochuahateyes01.mp3|sochuahateyes02.mp3|sochuahateyes03.mp3|sochuaintro.mp3|sochuaneutralhello.mp3|sochuaneutralletshearit01.mp3|sochuaneutralletshearit02.mp3|sochuaneutralletshearit03.mp3|sochuaneutralno01.mp3|sochuaneutralno02.mp3|sochuaneutralno03.mp3|sochuaneutralyes01.mp3|sochuaneutralyes02.mp3|sochuaneutralyes03.mp3|sochuapeaceful.mp3|sochuarequest.mp3" -acodec copy sochua.mp3
```

Modified text for better pronunciation:

- Good ei eye prevents bad operators from using computers to conduct useless tasks at high speeds to many degrees of vacuous precision.
