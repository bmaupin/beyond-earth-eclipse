## Generate leader audio

#### Steps

1. Go to leader audio

   - /Sid Meier's Civilization Beyond Earth/steamassets/assets/sounds/speech/shared/
   - /Sid Meier's Civilization Beyond Earth/steamassets/assets/dlc/expansion1/sounds/speech/shared/

1. For any particular leader, listen to all of the audio and pick files that are in English (since that's the language the quotes are in)

1. Join the files using ffmpeg, e.g

   ```
   ffmpeg -i "concat:fieldingattacked.mp3|fieldinghatehello.mp3|fieldinghateletshearit01.mp3|fieldinghateletshearit02.mp3|fieldinghateletshearit03.mp3|fieldinghateno01.mp3|fieldinghateno02.mp3|fieldinghateno03.mp3|fieldinghateyes01.mp3|fieldingintro.mp3|fieldinglosewar.mp3|fieldingneutralhellob.mp3|fieldingneutralletshearit01.mp3|fieldingneutralletshearit02.mp3|fieldingneutralletshearit03.mp3|fieldingneutralno01.mp3|fieldingneutralno02.mp3|fieldingneutralyes01.mp3|fieldingneutralyes02.mp3|fieldingneutralyes03.mp3|fieldingrequest.mp3" -acodec copy fielding.mp3
   ```

#### Barre (People's African Union)

```
ffmpeg -i "concat:barreattacked.mp3|barredeclarewar.mp3|barredefeated.mp3|barrehatehello.mp3|barrehateletshearit01.mp3|barrehateletshearit02.mp3|barrehateletshearit03.mp3|barrehateno02.mp3|barrehateno03.mp3|barrehateyes01.mp3|barrehateyes02.mp3|barrehateyes03.mp3|barreneutralletshearit03.mp3|barreneutralno02.mp3|barreneutralno03.mp3|barreneutralyes03.mp3|barrepeaceful.mp3|barrerequest.mp3" -acodec copy barre.mp3
```

#### Fielding (ARC)

```
ffmpeg -i "concat:fieldingattacked.mp3|fieldinghatehello.mp3|fieldinghateletshearit01.mp3|fieldinghateletshearit02.mp3|fieldinghateletshearit03.mp3|fieldinghateno01.mp3|fieldinghateno02.mp3|fieldinghateno03.mp3|fieldinghateyes01.mp3|fieldingintro.mp3|fieldinglosewar.mp3|fieldingneutralhellob.mp3|fieldingneutralletshearit01.mp3|fieldingneutralletshearit02.mp3|fieldingneutralletshearit03.mp3|fieldingneutralno01.mp3|fieldingneutralno02.mp3|fieldingneutralyes01.mp3|fieldingneutralyes02.mp3|fieldingneutralyes03.mp3|fieldingrequest.mp3" -acodec copy fielding.mp3
```
