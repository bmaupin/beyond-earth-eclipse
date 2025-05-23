-- Delete all existing leader quotes at once, since this is easier than keeping track of
-- which ones need to be created before doing an insert
DELETE FROM Language_en_US
WHERE Tag IN (
    'TXT_KEY_CIV_INTRO_AFRICAN_UNION_TEXT_0',
    'TXT_KEY_CIV_INTRO_AFRICAN_UNION_TEXT_1',
    'TXT_KEY_CIV_INTRO_AFRICAN_UNION_TEXT_2',
    'TXT_KEY_CIV_INTRO_AFRICAN_UNION_TEXT_3',
    'TXT_KEY_CIV_INTRO_AFRICAN_UNION_TEXT_4',
    'TXT_KEY_CIV_INTRO_AFRICAN_UNION_TEXT_5',
    'TXT_KEY_CIV_INTRO_ARC_TEXT_0',
    'TXT_KEY_CIV_INTRO_ARC_TEXT_1',
    'TXT_KEY_CIV_INTRO_ARC_TEXT_2',
    'TXT_KEY_CIV_INTRO_ARC_TEXT_3',
    'TXT_KEY_CIV_INTRO_ARC_TEXT_4',
    'TXT_KEY_CIV_INTRO_ARC_TEXT_5',
    'TXT_KEY_CIV_INTRO_BRASILIA_TEXT_0',
    'TXT_KEY_CIV_INTRO_BRASILIA_TEXT_1',
    'TXT_KEY_CIV_INTRO_BRASILIA_TEXT_2',
    'TXT_KEY_CIV_INTRO_BRASILIA_TEXT_3',
    'TXT_KEY_CIV_INTRO_BRASILIA_TEXT_4',
    'TXT_KEY_CIV_INTRO_BRASILIA_TEXT_5',
    'TXT_KEY_CIV_INTRO_FRANCO_IBERIA_TEXT_0',
    'TXT_KEY_CIV_INTRO_FRANCO_IBERIA_TEXT_1',
    'TXT_KEY_CIV_INTRO_FRANCO_IBERIA_TEXT_2',
    'TXT_KEY_CIV_INTRO_FRANCO_IBERIA_TEXT_3',
    'TXT_KEY_CIV_INTRO_FRANCO_IBERIA_TEXT_4',
    'TXT_KEY_CIV_INTRO_FRANCO_IBERIA_TEXT_5',
    'TXT_KEY_CIV_INTRO_KAVITHAN_TEXT_0',
    'TXT_KEY_CIV_INTRO_KAVITHAN_TEXT_1',
    'TXT_KEY_CIV_INTRO_KAVITHAN_TEXT_2',
    'TXT_KEY_CIV_INTRO_KAVITHAN_TEXT_3',
    'TXT_KEY_CIV_INTRO_KAVITHAN_TEXT_4',
    'TXT_KEY_CIV_INTRO_KAVITHAN_TEXT_5',
    'TXT_KEY_CIV_INTRO_PAN_ASIA_TEXT_0',
    'TXT_KEY_CIV_INTRO_PAN_ASIA_TEXT_1',
    'TXT_KEY_CIV_INTRO_PAN_ASIA_TEXT_2',
    'TXT_KEY_CIV_INTRO_PAN_ASIA_TEXT_3',
    'TXT_KEY_CIV_INTRO_PAN_ASIA_TEXT_4',
    'TXT_KEY_CIV_INTRO_PAN_ASIA_TEXT_5',
    'TXT_KEY_CIV_INTRO_POLYSTRALIA_TEXT_0',
    'TXT_KEY_CIV_INTRO_POLYSTRALIA_TEXT_1',
    'TXT_KEY_CIV_INTRO_POLYSTRALIA_TEXT_2',
    'TXT_KEY_CIV_INTRO_POLYSTRALIA_TEXT_3',
    'TXT_KEY_CIV_INTRO_POLYSTRALIA_TEXT_4',
    'TXT_KEY_CIV_INTRO_POLYSTRALIA_TEXT_5',
    'TXT_KEY_CIV_INTRO_RUSSIA_TEXT_0',
    'TXT_KEY_CIV_INTRO_RUSSIA_TEXT_1',
    'TXT_KEY_CIV_INTRO_RUSSIA_TEXT_2',
    'TXT_KEY_CIV_INTRO_RUSSIA_TEXT_3',
    'TXT_KEY_CIV_INTRO_RUSSIA_TEXT_4',
    'TXT_KEY_CIV_INTRO_RUSSIA_TEXT_5',
    'TXT_KEY_INTRO_MESSAGE_AFRICAN_UNION_1',
    'TXT_KEY_INTRO_MESSAGE_AFRICAN_UNION_2',
    'TXT_KEY_INTRO_MESSAGE_AFRICAN_UNION_3',
    'TXT_KEY_INTRO_MESSAGE_AL_FALAH_1',
    'TXT_KEY_INTRO_MESSAGE_AL_FALAH_2',
    'TXT_KEY_INTRO_MESSAGE_AL_FALAH_3',
    'TXT_KEY_INTRO_MESSAGE_ARC_1',
    'TXT_KEY_INTRO_MESSAGE_ARC_2',
    'TXT_KEY_INTRO_MESSAGE_ARC_3',
    'TXT_KEY_INTRO_MESSAGE_BRASILIA_1',
    'TXT_KEY_INTRO_MESSAGE_BRASILIA_2',
    'TXT_KEY_INTRO_MESSAGE_BRASILIA_3',
    'TXT_KEY_INTRO_MESSAGE_CHUNGSU_1',
    'TXT_KEY_INTRO_MESSAGE_CHUNGSU_2',
    'TXT_KEY_INTRO_MESSAGE_CHUNGSU_3',
    'TXT_KEY_INTRO_MESSAGE_FRANCO_IBERIA_1',
    'TXT_KEY_INTRO_MESSAGE_FRANCO_IBERIA_2',
    'TXT_KEY_INTRO_MESSAGE_FRANCO_IBERIA_3',
    'TXT_KEY_INTRO_MESSAGE_INTEGR_1',
    'TXT_KEY_INTRO_MESSAGE_INTEGR_2',
    'TXT_KEY_INTRO_MESSAGE_INTEGR_3',
    'TXT_KEY_INTRO_MESSAGE_KAVITHAN_1',
    'TXT_KEY_INTRO_MESSAGE_KAVITHAN_2',
    'TXT_KEY_INTRO_MESSAGE_KAVITHAN_3',
    'TXT_KEY_INTRO_MESSAGE_NORTH_SEA_ALLIANCE_1',
    'TXT_KEY_INTRO_MESSAGE_NORTH_SEA_ALLIANCE_2',
    'TXT_KEY_INTRO_MESSAGE_NORTH_SEA_ALLIANCE_3',
    'TXT_KEY_INTRO_MESSAGE_NORTH_SEA_ALLIANCE_4',
    'TXT_KEY_INTRO_MESSAGE_PAN_ASIA_1',
    'TXT_KEY_INTRO_MESSAGE_PAN_ASIA_2',
    'TXT_KEY_INTRO_MESSAGE_PAN_ASIA_3',
    'TXT_KEY_INTRO_MESSAGE_POLYSTRALIA_1',
    'TXT_KEY_INTRO_MESSAGE_POLYSTRALIA_2',
    'TXT_KEY_INTRO_MESSAGE_POLYSTRALIA_3',
    'TXT_KEY_INTRO_MESSAGE_RUSSIA_1',
    'TXT_KEY_INTRO_MESSAGE_RUSSIA_2',
    'TXT_KEY_INTRO_MESSAGE_RUSSIA_3'
);

-- There are probably many ways to do this, but I picked inserting the rows first with a
-- dummy value, that way I can be sure which rows I'm updating (instead of using a null
-- value for Text and update with LIKE, or something else). I chose to use a dummy value
-- that way the actual text is only defined in one place in case I ever want to update it.

-- African Union
INSERT INTO Language_en_US (Tag, Text)
VALUES
    ('TXT_KEY_CIV_INTRO_AFRICAN_UNION_TEXT_1', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_ARC_TEXT_1', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_BRASILIA_TEXT_1', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_FRANCO_IBERIA_TEXT_1', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_KAVITHAN_TEXT_1', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_PAN_ASIA_TEXT_1', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_POLYSTRALIA_TEXT_1', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_RUSSIA_TEXT_1', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_AFRICAN_UNION_1', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_AL_FALAH_1', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_ARC_1', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_BRASILIA_1', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_CHUNGSU_1', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_FRANCO_IBERIA_1', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_INTEGR_1', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_KAVITHAN_1', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_NORTH_SEA_ALLIANCE_1', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_PAN_ASIA_1', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_POLYSTRALIA_1', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_RUSSIA_1', 'civbe-eclipse');
UPDATE Language_en_US
SET Text = 'The "People''s" African Union, led by Samatar Jama Barre, brought all of the various African countries together after The Great Mistake at a time when humanity as a whole found itself in a crisis big enough to finally put aside their differences. As all countries around the world began to prioritise humanitarian efforts, other priorities were necessarily shelved, and military budgets across the globe were slashed. The Union at its founding decided their budget would be better spent and decided not to invest in military expenditures. This same attitude continues to this day on the new planet.'
WHERE Text = 'civbe-eclipse';

INSERT INTO Language_en_US (Tag, Text)
VALUES
    ('TXT_KEY_CIV_INTRO_AFRICAN_UNION_TEXT_2', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_ARC_TEXT_2', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_BRASILIA_TEXT_2', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_FRANCO_IBERIA_TEXT_2', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_KAVITHAN_TEXT_2', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_PAN_ASIA_TEXT_2', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_POLYSTRALIA_TEXT_2', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_RUSSIA_TEXT_2', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_AFRICAN_UNION_2', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_AL_FALAH_2', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_ARC_2', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_BRASILIA_2', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_CHUNGSU_2', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_FRANCO_IBERIA_2', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_INTEGR_2', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_KAVITHAN_2', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_NORTH_SEA_ALLIANCE_2', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_PAN_ASIA_2', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_POLYSTRALIA_2', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_RUSSIA_2', 'civbe-eclipse');
UPDATE Language_en_US
SET Text = 'Seeing its own people as its greatest asset, the African Union spends most of its budget promoting the health and growth of its citizens. From birth to death, everyone is provided free health care, and the government carefully scrutinises all new products that enter the market for any potential safety risk. The agricultural industry and its output is occasionally subsidised as needed in order to ensure that the whims of the capitalist free market are unable to put farmers out of business as well as maintaining the price of most foods at a stable level within reach of the purchasing power of all within the Union.'
WHERE Text = 'civbe-eclipse';

INSERT INTO Language_en_US (Tag, Text)
VALUES
    ('TXT_KEY_CIV_INTRO_AFRICAN_UNION_TEXT_3', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_ARC_TEXT_3', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_BRASILIA_TEXT_3', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_FRANCO_IBERIA_TEXT_3', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_KAVITHAN_TEXT_3', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_PAN_ASIA_TEXT_3', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_POLYSTRALIA_TEXT_3', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_RUSSIA_TEXT_3', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_AFRICAN_UNION_3', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_AL_FALAH_3', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_ARC_3', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_BRASILIA_3', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_CHUNGSU_3', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_FRANCO_IBERIA_3', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_INTEGR_3', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_KAVITHAN_3', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_NORTH_SEA_ALLIANCE_3', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_PAN_ASIA_3', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_POLYSTRALIA_3', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_RUSSIA_3', 'civbe-eclipse');
UPDATE Language_en_US
SET Text = 'Given the African Union''s strong concern for the health and safety of its citizens, it has put in place vigorous restrictions when it comes to research and products of alien or technological origin that are designed to enable humans to surpass the limits placed upon them by their biology. Many such endeavours have been undertaken by other sponsors, and Samatar Barre wishes no part of it for his people. At the same time, he maintains a warm approach to all, even those who hold fundamentally different outlooks and values. The African Union was necessarily built on tolerance and understanding in order to bring together so many different groups of people, and these same values are extended even to those outside the Union.'
WHERE Text = 'civbe-eclipse';

-- ARC
INSERT INTO Language_en_US (Tag, Text)
VALUES
    ('TXT_KEY_CIV_INTRO_AFRICAN_UNION_TEXT_4', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_ARC_TEXT_4', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_BRASILIA_TEXT_4', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_FRANCO_IBERIA_TEXT_4', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_KAVITHAN_TEXT_4', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_PAN_ASIA_TEXT_4', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_POLYSTRALIA_TEXT_4', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_RUSSIA_TEXT_4', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_AFRICAN_UNION_4', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_AL_FALAH_4', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_ARC_4', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_BRASILIA_4', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_CHUNGSU_4', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_FRANCO_IBERIA_4', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_INTEGR_4', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_KAVITHAN_4', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_NORTH_SEA_ALLIANCE_4', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_PAN_ASIA_4', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_POLYSTRALIA_4', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_RUSSIA_4', 'civbe-eclipse');
UPDATE Language_en_US
SET Text = 'What many don''t realize about Suzanne Fielding''s take-no-prisoner approach to corporate growth is that it is the result of numerous failures and years of hardship. Over the years, she never gave up on the American dream, ascending the ranks of the American Reclamation Corporation even when it meant climbing on the backs of others in order to make her way to the top. Her relentless drive and strategic acumen have made ARC a dominant force on the new planet. As the years have passed, Suzanne''s ambitions to keep ARC at the top and herself at the top of ARC have only grown stronger, to the point that little remains of the scrappy intern that she once was.'
WHERE Text = 'civbe-eclipse';

INSERT INTO Language_en_US (Tag, Text)
VALUES
    ('TXT_KEY_CIV_INTRO_AFRICAN_UNION_TEXT_5', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_ARC_TEXT_5', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_BRASILIA_TEXT_5', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_FRANCO_IBERIA_TEXT_5', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_KAVITHAN_TEXT_5', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_PAN_ASIA_TEXT_5', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_POLYSTRALIA_TEXT_5', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_RUSSIA_TEXT_5', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_AFRICAN_UNION_5', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_AL_FALAH_5', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_ARC_5', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_BRASILIA_5', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_CHUNGSU_5', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_FRANCO_IBERIA_5', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_INTEGR_5', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_KAVITHAN_5', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_NORTH_SEA_ALLIANCE_5', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_PAN_ASIA_5', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_POLYSTRALIA_5', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_RUSSIA_5', 'civbe-eclipse');
UPDATE Language_en_US
SET Text = 'As one of the most easily recognized personalities on Old Earth, Suzanne Fielding is uniquely familiar with most, if not all of the other Sponsors. Natural relationships with other leaders have slowly turned into building blocks of ARC''s formidable intelligence behemoth. As corporations have evolved into governments, what could have been called customer relations have evolved into something else altogether: a vast secretive web of espionage that the ARC uses to keep an eye on both friend and foe. To what purposes, only Fielding may know.'
WHERE Text = 'civbe-eclipse';

INSERT INTO Language_en_US (Tag, Text)
VALUES
    ('TXT_KEY_CIV_INTRO_AFRICAN_UNION_TEXT_6', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_ARC_TEXT_6', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_BRASILIA_TEXT_6', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_FRANCO_IBERIA_TEXT_6', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_KAVITHAN_TEXT_6', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_PAN_ASIA_TEXT_6', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_POLYSTRALIA_TEXT_6', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_RUSSIA_TEXT_6', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_AFRICAN_UNION_6', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_AL_FALAH_6', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_ARC_6', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_BRASILIA_6', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_CHUNGSU_6', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_FRANCO_IBERIA_6', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_INTEGR_6', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_KAVITHAN_6', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_NORTH_SEA_ALLIANCE_6', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_PAN_ASIA_6', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_POLYSTRALIA_6', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_RUSSIA_6', 'civbe-eclipse');
UPDATE Language_en_US
SET Text = 'ARC, along with the other sponsors, was simply content to survive the vast journey across space and make planetfall, focusing solely on survival of itself and its citizens. As time has passed, the old itch of manifest destiny has slowly started to creap upon the body of the organisation. Natural growth as the ARC has acclimated to the planet and its ecosystem has started to give way to stronger feelings of expansionism. How much will be enough to satiate the ARC''s appetite for more territory and resources? And what will it sacrifice along the way?'
WHERE Text = 'civbe-eclipse';

-- Brasilia
INSERT INTO Language_en_US (Tag, Text)
VALUES
    ('TXT_KEY_CIV_INTRO_AFRICAN_UNION_TEXT_7', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_ARC_TEXT_7', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_BRASILIA_TEXT_7', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_FRANCO_IBERIA_TEXT_7', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_KAVITHAN_TEXT_7', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_PAN_ASIA_TEXT_7', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_POLYSTRALIA_TEXT_7', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_RUSSIA_TEXT_7', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_AFRICAN_UNION_7', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_AL_FALAH_7', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_ARC_7', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_BRASILIA_7', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_CHUNGSU_7', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_FRANCO_IBERIA_7', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_INTEGR_7', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_KAVITHAN_7', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_NORTH_SEA_ALLIANCE_7', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_PAN_ASIA_7', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_POLYSTRALIA_7', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_RUSSIA_7', 'civbe-eclipse');
UPDATE Language_en_US
SET Text = 'Rejinaldo Leonardo Pedro Bolivar de Alencar-Araripe, the leader of Brasilia, came from a long line of military heroes. A common saying among his people is that he was born wearing a uniform. The possibility of Rejinaldo entering into any career other than the military was never even considered in his household, and to even hint at such a thing would have been taboo. This same all-encompassing fixation with the military seeps through every facet of life for Brasilia on this new planet. Children are indoctrinated from a very young age, and education centres on how best to prepare children to either be in the military or help support it. As Brasilia looks across the new planet, they see little else besides a land to be conquered behind the barrel of a gun.'
WHERE Text = 'civbe-eclipse';

INSERT INTO Language_en_US (Tag, Text)
VALUES
    ('TXT_KEY_CIV_INTRO_AFRICAN_UNION_TEXT_8', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_ARC_TEXT_8', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_BRASILIA_TEXT_8', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_FRANCO_IBERIA_TEXT_8', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_KAVITHAN_TEXT_8', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_PAN_ASIA_TEXT_8', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_POLYSTRALIA_TEXT_8', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_RUSSIA_TEXT_8', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_AFRICAN_UNION_8', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_AL_FALAH_8', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_ARC_8', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_BRASILIA_8', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_CHUNGSU_8', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_FRANCO_IBERIA_8', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_INTEGR_8', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_KAVITHAN_8', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_NORTH_SEA_ALLIANCE_8', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_PAN_ASIA_8', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_POLYSTRALIA_8', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_RUSSIA_8', 'civbe-eclipse');
UPDATE Language_en_US
SET Text = 'For Rejinaldo de Alencar-Araripe, his humanity is defined in very narrow terms. While other sponsors have embraced unknown alien monstrosities or dangerous robotic augmentations, this is akin to turning one''s back on one''s own humanity as far as Rejinaldo is concerned. He has little tolerance for such creatures (for he does not even deign to use the term "human" in these cases). From his point of view, there is no possibility of cooperation or collaboration with those willing to give up what it means to be human. Their choice will only lead to extermination alongside anything else that does not qualify as human in his eyes.'
WHERE Text = 'civbe-eclipse';

INSERT INTO Language_en_US (Tag, Text)
VALUES
    ('TXT_KEY_CIV_INTRO_AFRICAN_UNION_TEXT_9', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_ARC_TEXT_9', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_BRASILIA_TEXT_9', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_FRANCO_IBERIA_TEXT_9', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_KAVITHAN_TEXT_9', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_PAN_ASIA_TEXT_9', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_POLYSTRALIA_TEXT_9', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_RUSSIA_TEXT_9', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_AFRICAN_UNION_9', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_AL_FALAH_9', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_ARC_9', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_BRASILIA_9', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_CHUNGSU_9', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_FRANCO_IBERIA_9', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_INTEGR_9', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_KAVITHAN_9', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_NORTH_SEA_ALLIANCE_9', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_PAN_ASIA_9', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_POLYSTRALIA_9', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_RUSSIA_9', 'civbe-eclipse');
UPDATE Language_en_US
SET Text = 'While on Earth, Brasilia used its nearly unmatched military might around the world to help those in need and eliminate abuse and oppression. With humanity''s very existence hanging in the balance, humanitarian needs trumped old ways of conquest and domination. However, now that Brasilia and the other sponsors have made planetfall on a new alien world, fears for their survival have given way to intolerance of the way of life chosen by much of the population of the new planet. Do they deserve to stand on an equal footing with the great Brasilia while chasing after at best frivolous pursuits such as art, luxury, or filling their stomachs? Not to mention those that have traded their own humanity to embrace ... alienness. They deserve what''s coming to them.'
WHERE Text = 'civbe-eclipse';

-- Franco-Iberia
INSERT INTO Language_en_US (Tag, Text)
VALUES
    ('TXT_KEY_CIV_INTRO_AFRICAN_UNION_TEXT_10', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_ARC_TEXT_10', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_BRASILIA_TEXT_10', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_FRANCO_IBERIA_TEXT_10', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_KAVITHAN_TEXT_10', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_PAN_ASIA_TEXT_10', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_POLYSTRALIA_TEXT_10', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_RUSSIA_TEXT_10', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_AFRICAN_UNION_10', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_AL_FALAH_10', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_ARC_10', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_BRASILIA_10', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_CHUNGSU_10', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_FRANCO_IBERIA_10', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_INTEGR_10', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_KAVITHAN_10', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_NORTH_SEA_ALLIANCE_10', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_PAN_ASIA_10', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_POLYSTRALIA_10', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_RUSSIA_10', 'civbe-eclipse');
UPDATE Language_en_US
SET Text = 'Élodie is considered one of, if not the most important art critic and historian of the past 300 years. While at the helm of Franco-Iberia, she made it her personal mission to accumulate a definitive collection of artistic work known as the Canon, which traveled across space along with the colonists. Notably, this resulted in less space on the ship for human passengers. This was merely a hint of Élodie''s true priorities, which began to surface more rapidly once her ship made planetfall. Holding her values as a banner, she sees herself as compelled to spread culture across the new planet by any means necessary. Resistance is seen as little more than unenlightenment, which for others may seem trivial but for Élodie must be corrected or eradicated.'
WHERE Text = 'civbe-eclipse';

INSERT INTO Language_en_US (Tag, Text)
VALUES
    ('TXT_KEY_CIV_INTRO_AFRICAN_UNION_TEXT_11', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_ARC_TEXT_11', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_BRASILIA_TEXT_11', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_FRANCO_IBERIA_TEXT_11', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_KAVITHAN_TEXT_11', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_PAN_ASIA_TEXT_11', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_POLYSTRALIA_TEXT_11', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_RUSSIA_TEXT_11', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_AFRICAN_UNION_11', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_AL_FALAH_11', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_ARC_11', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_BRASILIA_11', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_CHUNGSU_11', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_FRANCO_IBERIA_11', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_INTEGR_11', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_KAVITHAN_11', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_NORTH_SEA_ALLIANCE_11', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_PAN_ASIA_11', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_POLYSTRALIA_11', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_RUSSIA_11', 'civbe-eclipse');
UPDATE Language_en_US
SET Text = 'While it is clear that under Élodie''s lead, Franco-Iberia holds art and culture as its highest values, it is often less clear what Élodies true sentiments are towards others. She typically carries a casual disdain for those who she deems less enlightened, which in most cases is almost everyone else. However even to her closest friends she remains an enigma. Even in matters of state such as alliances or declarations of war, Élodie''s artistic whims shine through, often taking drastic actions for seemingly no reason. If her goal is to confound the other corporations, in this she can be seen as having had great success. If not, she may simply be mad. Either way, she is not to be trifled with.'
WHERE Text = 'civbe-eclipse';

INSERT INTO Language_en_US (Tag, Text)
VALUES
    ('TXT_KEY_CIV_INTRO_AFRICAN_UNION_TEXT_12', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_ARC_TEXT_12', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_BRASILIA_TEXT_12', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_FRANCO_IBERIA_TEXT_12', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_KAVITHAN_TEXT_12', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_PAN_ASIA_TEXT_12', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_POLYSTRALIA_TEXT_12', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_RUSSIA_TEXT_12', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_AFRICAN_UNION_12', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_AL_FALAH_12', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_ARC_12', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_BRASILIA_12', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_CHUNGSU_12', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_FRANCO_IBERIA_12', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_INTEGR_12', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_KAVITHAN_12', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_NORTH_SEA_ALLIANCE_12', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_PAN_ASIA_12', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_POLYSTRALIA_12', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_RUSSIA_12', 'civbe-eclipse');
UPDATE Language_en_US
SET Text = 'Despite Élodie''s own extremely high regard for the arts, her own dabblings in poetry and other arts have not been universally met with enthusiasm by critics. Perhaps as a way to detract from the negative attention her own art has received, Élodie has taken up a second banner, that of harmony with her new planet and all of its various plant and animal life. She takes it as a personal offence whenever the alien flora or fauna are disturbed in any way, and any kind of deliberate harm to either is quick to provoke her wrath. She sees Franco-Iberia''s modest military resources as a tool for protecting not only their precious cultural and artistic heritage (and the people necessary to maintain them), but also the native alien life. Some have said she values the alien life more than the lives of her own citizens.'
WHERE Text = 'civbe-eclipse';

-- Kavithan
INSERT INTO Language_en_US (Tag, Text)
VALUES
    ('TXT_KEY_CIV_INTRO_AFRICAN_UNION_TEXT_13', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_ARC_TEXT_13', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_BRASILIA_TEXT_13', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_FRANCO_IBERIA_TEXT_13', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_KAVITHAN_TEXT_13', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_PAN_ASIA_TEXT_13', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_POLYSTRALIA_TEXT_13', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_RUSSIA_TEXT_13', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_AFRICAN_UNION_13', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_AL_FALAH_13', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_ARC_13', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_BRASILIA_13', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_CHUNGSU_13', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_FRANCO_IBERIA_13', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_INTEGR_13', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_KAVITHAN_13', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_NORTH_SEA_ALLIANCE_13', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_PAN_ASIA_13', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_POLYSTRALIA_13', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_RUSSIA_13', 'civbe-eclipse');
UPDATE Language_en_US
SET Text = 'While not directly responsible for The Great Mistake, the proximity of its epicentre and the immediate and severe impact it had on the Indian subcontenent instilled in the Kavithan Protectorate a strong sense of responsibility in terms of spearheading humanitarian efforts and remediating the impact. Borne out of the ashes of the Mistake, the Protectorate''s own values were inextricably intertwined with those of the post-Mistake era. The extreme crisis that ensued forced the population which had known centuries of conflict to lay down their arms if they hoped to survive. This cooperative attitude became part of the identity of its citizens and to this day Kavitha Thakur and her people know they cannot be separated from it without giving up an essential part of themselves.'
WHERE Text = 'civbe-eclipse';

INSERT INTO Language_en_US (Tag, Text)
VALUES
    ('TXT_KEY_CIV_INTRO_AFRICAN_UNION_TEXT_14', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_ARC_TEXT_14', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_BRASILIA_TEXT_14', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_FRANCO_IBERIA_TEXT_14', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_KAVITHAN_TEXT_14', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_PAN_ASIA_TEXT_14', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_POLYSTRALIA_TEXT_14', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_RUSSIA_TEXT_14', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_AFRICAN_UNION_14', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_AL_FALAH_14', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_ARC_14', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_BRASILIA_14', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_CHUNGSU_14', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_FRANCO_IBERIA_14', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_INTEGR_14', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_KAVITHAN_14', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_NORTH_SEA_ALLIANCE_14', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_PAN_ASIA_14', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_POLYSTRALIA_14', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_RUSSIA_14', 'civbe-eclipse');
UPDATE Language_en_US
SET Text = 'As one of the regions of the world whose histories date back millenia, the various cultures of the Kavithan Protectorate place high value on keeping this heritage alive. Rather than a melting pot of disparate identies, the Protectorate values its diversity and is very protective of the many distinct peoples that make up its citizenry. Each group receives funding from the government to keep its cultural heritage not simply alive, but in order to continue to pass it down to future generations and even spread awareness among other groups both within the Protectorate and without.'
WHERE Text = 'civbe-eclipse';

INSERT INTO Language_en_US (Tag, Text)
VALUES
    ('TXT_KEY_CIV_INTRO_AFRICAN_UNION_TEXT_15', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_ARC_TEXT_15', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_BRASILIA_TEXT_15', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_FRANCO_IBERIA_TEXT_15', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_KAVITHAN_TEXT_15', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_PAN_ASIA_TEXT_15', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_POLYSTRALIA_TEXT_15', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_RUSSIA_TEXT_15', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_AFRICAN_UNION_15', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_AL_FALAH_15', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_ARC_15', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_BRASILIA_15', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_CHUNGSU_15', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_FRANCO_IBERIA_15', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_INTEGR_15', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_KAVITHAN_15', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_NORTH_SEA_ALLIANCE_15', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_PAN_ASIA_15', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_POLYSTRALIA_15', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_RUSSIA_15', 'civbe-eclipse');
UPDATE Language_en_US
SET Text = 'Unlike the other Sponsors, the Kavithan Protectorate is primarily concerned with the spirituality of its colonists. Now on a new planet, what is held as sacred has extended to embrace not only their own humanity, but also the alien life that now surrounds them in all its forms. Kavitha Thakur and her people extend an attitude of peace and kindness to all creatures. This extends to all of the citizens of the new planet, regardless of what sponsor they might happen to find themselves under. However, little patience is had for those who do not share this same high esteeem for human or alien life.'
WHERE Text = 'civbe-eclipse';

-- PAC
INSERT INTO Language_en_US (Tag, Text)
VALUES
    ('TXT_KEY_CIV_INTRO_AFRICAN_UNION_TEXT_16', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_ARC_TEXT_16', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_BRASILIA_TEXT_16', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_FRANCO_IBERIA_TEXT_16', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_KAVITHAN_TEXT_16', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_PAN_ASIA_TEXT_16', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_POLYSTRALIA_TEXT_16', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_RUSSIA_TEXT_16', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_AFRICAN_UNION_16', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_AL_FALAH_16', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_ARC_16', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_BRASILIA_16', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_CHUNGSU_16', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_FRANCO_IBERIA_16', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_INTEGR_16', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_KAVITHAN_16', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_NORTH_SEA_ALLIANCE_16', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_PAN_ASIA_16', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_POLYSTRALIA_16', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_RUSSIA_16', 'civbe-eclipse');
UPDATE Language_en_US
SET Text = 'Daoming Sochua was raised not make a name for herself, but instead to work hard and let her work show for itself. This strong work ethic pervades the Pan-Asian Cooperative, and those that dare to be idle stand out as a reed in the middle of a swiftly rushing current and are quickly pushed back down to their appropriate function in society. The effect of this is that the PAC functions as a well-oiled machine, a machine capable of dominating anything in its path, growing only larger in the process. All other sponsors would be wise to stay out of the way of the PAC or find themselves unintentionally becoming part of it.'
WHERE Text = 'civbe-eclipse';

INSERT INTO Language_en_US (Tag, Text)
VALUES
    ('TXT_KEY_CIV_INTRO_AFRICAN_UNION_TEXT_17', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_ARC_TEXT_17', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_BRASILIA_TEXT_17', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_FRANCO_IBERIA_TEXT_17', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_KAVITHAN_TEXT_17', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_PAN_ASIA_TEXT_17', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_POLYSTRALIA_TEXT_17', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_RUSSIA_TEXT_17', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_AFRICAN_UNION_17', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_AL_FALAH_17', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_ARC_17', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_BRASILIA_17', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_CHUNGSU_17', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_FRANCO_IBERIA_17', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_INTEGR_17', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_KAVITHAN_17', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_NORTH_SEA_ALLIANCE_17', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_PAN_ASIA_17', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_POLYSTRALIA_17', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_RUSSIA_17', 'civbe-eclipse');
UPDATE Language_en_US
SET Text = 'While innovation may seem out of place in a society where there is little place for the individual, Daoming has long held that without innovation, the PAC will not be able to surpass the other sponsors. While many may look at the abundant resources and untouched land of the new planet, Daoming dares not allow this to lull her into a sense of complacency. She knows that there will come a time when there will no longer be enough resources to go around, and those that fail to establish themselves in a position of greater power now will be at some point forced into arrangements at their own expense. In order to preclude this, Daoming has launched into an aggressive campaign of technological research and acquisition aimed at enhanching all levels of PAC society so that they might exceed the limits placed upon them even by virtue of their own biology.'
WHERE Text = 'civbe-eclipse';

INSERT INTO Language_en_US (Tag, Text)
VALUES
    ('TXT_KEY_CIV_INTRO_AFRICAN_UNION_TEXT_18', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_ARC_TEXT_18', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_BRASILIA_TEXT_18', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_FRANCO_IBERIA_TEXT_18', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_KAVITHAN_TEXT_18', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_PAN_ASIA_TEXT_18', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_POLYSTRALIA_TEXT_18', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_RUSSIA_TEXT_18', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_AFRICAN_UNION_18', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_AL_FALAH_18', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_ARC_18', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_BRASILIA_18', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_CHUNGSU_18', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_FRANCO_IBERIA_18', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_INTEGR_18', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_KAVITHAN_18', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_NORTH_SEA_ALLIANCE_18', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_PAN_ASIA_18', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_POLYSTRALIA_18', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_RUSSIA_18', 'civbe-eclipse');
UPDATE Language_en_US
SET Text = 'Even as the PAC expands quickly across the new planet, outsiders do not have an open window into the society that is forcefully vying for the top of the food chain. The PAC, while made up of a vast population, acts as one. Any openness that was genuine or feigned after The Great Mistake in order to propel humanity off of a dying planet has been cast aside. There is now little pretence that the PAC exists solely for its own interests. Other sponsors are wise to be cautious about entering into an agreement with PAC, given that it is widely believed PAC will only enter into such agreements when they believe they are able to extract all or most of the benefit, often at the expense of the other party. Such decisions should not be taken lightly.'
WHERE Text = 'civbe-eclipse';

-- Polystralia
INSERT INTO Language_en_US (Tag, Text)
VALUES
    ('TXT_KEY_CIV_INTRO_AFRICAN_UNION_TEXT_19', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_ARC_TEXT_19', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_BRASILIA_TEXT_19', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_FRANCO_IBERIA_TEXT_19', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_KAVITHAN_TEXT_19', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_PAN_ASIA_TEXT_19', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_POLYSTRALIA_TEXT_19', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_RUSSIA_TEXT_19', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_AFRICAN_UNION_19', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_AL_FALAH_19', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_ARC_19', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_BRASILIA_19', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_CHUNGSU_19', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_FRANCO_IBERIA_19', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_INTEGR_19', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_KAVITHAN_19', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_NORTH_SEA_ALLIANCE_19', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_PAN_ASIA_19', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_POLYSTRALIA_19', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_RUSSIA_19', 'civbe-eclipse');
UPDATE Language_en_US
SET Text = 'As a formerly disjointed collection of Pacific islands, the Commonwealth of the Pacific, also known as Polystralia, could never have worked as a collective entity had it not been for centuries of established trade between the disparate islands that joined to become something greater. Trade both within and without has long been the lifeblood of Polystralia, something Hutama understands without fault. He spent vast amounts of his own resources in order to become savvy in all things trade, which paid off as it strenghtened Polystralia''s economic and social bonds. Now on a new planet, Hutama sees a healthy inter-sponsor trade as being crucial for humanity''s chances of surviving and one day thriving on this new alien world so far from home.'
WHERE Text = 'civbe-eclipse';

INSERT INTO Language_en_US (Tag, Text)
VALUES
    ('TXT_KEY_CIV_INTRO_AFRICAN_UNION_TEXT_20', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_ARC_TEXT_20', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_BRASILIA_TEXT_20', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_FRANCO_IBERIA_TEXT_20', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_KAVITHAN_TEXT_20', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_PAN_ASIA_TEXT_20', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_POLYSTRALIA_TEXT_20', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_RUSSIA_TEXT_20', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_AFRICAN_UNION_20', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_AL_FALAH_20', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_ARC_20', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_BRASILIA_20', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_CHUNGSU_20', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_FRANCO_IBERIA_20', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_INTEGR_20', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_KAVITHAN_20', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_NORTH_SEA_ALLIANCE_20', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_PAN_ASIA_20', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_POLYSTRALIA_20', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_RUSSIA_20', 'civbe-eclipse');
UPDATE Language_en_US
SET Text = 'Even before The Great Mistake, global warming had impacted Polystralia more than many other countries as much of its territory is made up of islands. As a result, Polystralia has had a longstanding appreciation for the value of proper care for the planet. These same values have been carried across the stars to the new planet, where Polystralia has watched with concern as some of the other sponsors have flirted with nonchalant or even exploitative attitudes towards the land and its indigenous life. While Hutama is a patient man and not quick to enter conflict with other factions, even he has his limits, and needs must if it comes to protecting his people from a similar fate they faced at the hands of other careless nations on Earth.'
WHERE Text = 'civbe-eclipse';

INSERT INTO Language_en_US (Tag, Text)
VALUES
    ('TXT_KEY_CIV_INTRO_AFRICAN_UNION_TEXT_21', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_ARC_TEXT_21', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_BRASILIA_TEXT_21', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_FRANCO_IBERIA_TEXT_21', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_KAVITHAN_TEXT_21', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_PAN_ASIA_TEXT_21', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_POLYSTRALIA_TEXT_21', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_RUSSIA_TEXT_21', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_AFRICAN_UNION_21', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_AL_FALAH_21', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_ARC_21', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_BRASILIA_21', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_CHUNGSU_21', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_FRANCO_IBERIA_21', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_INTEGR_21', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_KAVITHAN_21', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_NORTH_SEA_ALLIANCE_21', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_PAN_ASIA_21', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_POLYSTRALIA_21', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_RUSSIA_21', 'civbe-eclipse');
UPDATE Language_en_US
SET Text = 'It has not gone past Hutama''s notice that there has been a change in many of the other leaders, in most cases not for the better. Deception, exploitation, and outright hostility have marred recent relations between some of the various leaders on the new planet. While some have been quick to give the benefit of the doubt, Hutama has seen his fair share of both passive and aggressive leaders come and go, and he is careful not to jump to any conclusions nor pass any judgement. While he needs to maintain healthy relationships with the other sponsors to keep the trade economy strong, he will not allow himself to be pushed around by those who wish to assert their own dominance on the new planet at the expensive of the other sponsors, Polystralia in particular.'
WHERE Text = 'civbe-eclipse';

-- Russia
INSERT INTO Language_en_US (Tag, Text)
VALUES
    ('TXT_KEY_CIV_INTRO_AFRICAN_UNION_TEXT_22', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_ARC_TEXT_22', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_BRASILIA_TEXT_22', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_FRANCO_IBERIA_TEXT_22', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_KAVITHAN_TEXT_22', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_PAN_ASIA_TEXT_22', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_POLYSTRALIA_TEXT_22', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_RUSSIA_TEXT_22', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_AFRICAN_UNION_22', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_AL_FALAH_22', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_ARC_22', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_BRASILIA_22', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_CHUNGSU_22', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_FRANCO_IBERIA_22', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_INTEGR_22', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_KAVITHAN_22', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_NORTH_SEA_ALLIANCE_22', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_PAN_ASIA_22', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_POLYSTRALIA_22', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_RUSSIA_22', 'civbe-eclipse');
UPDATE Language_en_US
SET Text = 'The Slavic Federation has a long heritage of looking to the stars. Their ancestors were among the first to put humans in orbit and since then they have placed high value and a not insignificant portion of their budget in space exploration. Exploitation of Earth''s atmosphere as a resource was seen not as a frivolity but as an investment, and so on a new planet it is of utmost importance to General Kozlov as he leads the Slavic Federation that they maintain dominance not only on planetside but also in the skies and beyond. By the time the other leaders remember to look up, Kozlov plans for their gaze to be filled with the might of the Slavic Federation.'
WHERE Text = 'civbe-eclipse';

INSERT INTO Language_en_US (Tag, Text)
VALUES
    ('TXT_KEY_CIV_INTRO_AFRICAN_UNION_TEXT_23', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_ARC_TEXT_23', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_BRASILIA_TEXT_23', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_FRANCO_IBERIA_TEXT_23', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_KAVITHAN_TEXT_23', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_PAN_ASIA_TEXT_23', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_POLYSTRALIA_TEXT_23', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_RUSSIA_TEXT_23', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_AFRICAN_UNION_23', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_AL_FALAH_23', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_ARC_23', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_BRASILIA_23', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_CHUNGSU_23', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_FRANCO_IBERIA_23', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_INTEGR_23', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_KAVITHAN_23', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_NORTH_SEA_ALLIANCE_23', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_PAN_ASIA_23', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_POLYSTRALIA_23', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_RUSSIA_23', 'civbe-eclipse');
UPDATE Language_en_US
SET Text = 'While General Kozlov first and foremost has prioritised dominance in the orbital domain, he has not neglected to stake his territorial claims down below. The Slavic Federation enjoys control of the largest expanse of land back on Earth and they have grown accustomed to having a strong advantage in the vast strategic and mineral resources this has brought. To settle for anything less on the new planet would be a humiliation they would not be able to tolerate, not to mention it would require an undesired reworking of their entire bureaucracy which has been optimised for a vast empire.'
WHERE Text = 'civbe-eclipse';

INSERT INTO Language_en_US (Tag, Text)
VALUES
    ('TXT_KEY_CIV_INTRO_AFRICAN_UNION_TEXT_24', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_ARC_TEXT_24', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_BRASILIA_TEXT_24', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_FRANCO_IBERIA_TEXT_24', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_KAVITHAN_TEXT_24', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_PAN_ASIA_TEXT_24', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_POLYSTRALIA_TEXT_24', 'civbe-eclipse'),
    ('TXT_KEY_CIV_INTRO_RUSSIA_TEXT_24', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_AFRICAN_UNION_24', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_AL_FALAH_24', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_ARC_24', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_BRASILIA_24', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_CHUNGSU_24', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_FRANCO_IBERIA_24', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_INTEGR_24', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_KAVITHAN_24', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_NORTH_SEA_ALLIANCE_24', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_PAN_ASIA_24', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_POLYSTRALIA_24', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_RUSSIA_24', 'civbe-eclipse');
UPDATE Language_en_US
SET Text = 'With one foot in the east and one in the west back on Earth, the Slavic Federation has long been wary of outside influences of both. They see the Slavic culture as not needing enhancement and instead needing protection from corruption from all sides. General Kozlov tolerates no interference with his government nor his people, who have long been proudly self-sufficient. Attempts by other sponsors at collaboration are seen as veiled attempts at control and will at best be met with scorn. Repeated attempts will be met with military deterrant.'
WHERE Text = 'civbe-eclipse';

-- NOTE: For the Rising Tide civs, only add intro text for Rising Tide

-- Al Falah
INSERT INTO Language_en_US (Tag, Text)
VALUES
    ('TXT_KEY_INTRO_MESSAGE_AFRICAN_UNION_25', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_AL_FALAH_25', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_ARC_25', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_BRASILIA_25', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_CHUNGSU_25', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_FRANCO_IBERIA_25', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_INTEGR_25', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_KAVITHAN_25', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_NORTH_SEA_ALLIANCE_25', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_PAN_ASIA_25', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_POLYSTRALIA_25', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_RUSSIA_25', 'civbe-eclipse');
UPDATE Language_en_US
SET Text = 'Unlike the other sponsors whose people spent the duration of the interstellar voyage to the new planet in cryogenic sleep, the people of Al Falah had no such luxury. The first generation who left Earth knew they would spend the rest of their lives on the ship in order to grant a better life to future generations. This made them a very hardy people, willing to sacrifice their individual comfort for the greater good. While having fewer economic resources than the other sponsors, Al Falah has more than enough character to make up for such shortcomings. While the other sponsors had their eyes closed, Al Falah''s eyes were open and ready for their new lives.'
WHERE Text = 'civbe-eclipse';

INSERT INTO Language_en_US (Tag, Text)
VALUES
    ('TXT_KEY_INTRO_MESSAGE_AFRICAN_UNION_26', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_AL_FALAH_26', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_ARC_26', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_BRASILIA_26', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_CHUNGSU_26', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_FRANCO_IBERIA_26', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_INTEGR_26', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_KAVITHAN_26', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_NORTH_SEA_ALLIANCE_26', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_PAN_ASIA_26', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_POLYSTRALIA_26', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_RUSSIA_26', 'civbe-eclipse');
UPDATE Language_en_US
SET Text = 'Before becoming pregnant with her daughter Nur, Arshia Kishk frequently spacewalked between Seedships. As the spacecraft were separated by long distances, these trips were considered a pilgrimage, and a chance to meditate upon the vastness of the universe. Only the bravest colonists attempted the dangerous trek, while most preferred small shuttles. Arshia''s influence and popularity were strengthened every time she arrived from the depths of space; a fearless leader sent to guide Al Falah through the stars. '
WHERE Text = 'civbe-eclipse';

INSERT INTO Language_en_US (Tag, Text)
VALUES
    ('TXT_KEY_INTRO_MESSAGE_AFRICAN_UNION_27', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_AL_FALAH_27', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_ARC_27', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_BRASILIA_27', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_CHUNGSU_27', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_FRANCO_IBERIA_27', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_INTEGR_27', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_KAVITHAN_27', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_NORTH_SEA_ALLIANCE_27', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_PAN_ASIA_27', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_POLYSTRALIA_27', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_RUSSIA_27', 'civbe-eclipse');
UPDATE Language_en_US
SET Text = 'While the journey to the new planet wasn''t spent in total discomfort, Al Falah had to resort to population control, food rationing, and other such restrictive measures due to limited space and resources aboard their ship. Now without these constraints, Arshia Kishk and her people are eager to live freely and spread out across their new home. A booming population has meant that Arshia has had to invest significantly into improving the land in order to support the rapidly increasing numbers of citizens of Al Falah.'
WHERE Text = 'civbe-eclipse';

-- Chungsu
INSERT INTO Language_en_US (Tag, Text)
VALUES
    ('TXT_KEY_INTRO_MESSAGE_AFRICAN_UNION_28', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_AL_FALAH_28', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_ARC_28', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_BRASILIA_28', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_CHUNGSU_28', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_FRANCO_IBERIA_28', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_INTEGR_28', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_KAVITHAN_28', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_NORTH_SEA_ALLIANCE_28', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_PAN_ASIA_28', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_POLYSTRALIA_28', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_RUSSIA_28', 'civbe-eclipse');
UPDATE Language_en_US
SET Text = 'There are multiple levels to Sub-Seoul''s Mireuk Bosal Dome. The lowest, publicly acknowledged level, Abyssopelagic-0, is home to deep-sea, scientific research, energy production and resource harvesting. What lies below is simply unknown. What is known is that many who enter the Chungsu academy, willingly or otherwise, are never heard from again. Have their memories been erased to take on new identities in Chungsu''s secretive intelligence forces? Or have they been forced to cut off all contact with friends and loved ones in order to avoid any attachment that may compromise the mission? What is known is that the names and history of all who enter cease to exist except in the memories of those who knew them but who dare not go looking for them. The same can be said for Han Jae Moon himself, about whom there seems to be no evidence of his existence before he formed Chunsu.'
WHERE Text = 'civbe-eclipse';

INSERT INTO Language_en_US (Tag, Text)
VALUES
    ('TXT_KEY_INTRO_MESSAGE_AFRICAN_UNION_29', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_AL_FALAH_29', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_ARC_29', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_BRASILIA_29', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_CHUNGSU_29', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_FRANCO_IBERIA_29', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_INTEGR_29', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_KAVITHAN_29', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_NORTH_SEA_ALLIANCE_29', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_PAN_ASIA_29', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_POLYSTRALIA_29', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_RUSSIA_29', 'civbe-eclipse');
UPDATE Language_en_US
SET Text = 'Anyone who has interacted with a representative from Chungsu is familiar with the eerie feeling that reality has been suspended around their persons. Truth, facts, and evidence all have a way of bending to the will of Chungsu, if not disappearing altogether. No one knows the extent to which Chungsu''s influence reaches. Some suspect even media critical of Chunsu has been carefully orchestrated by Chungsu itself so as to give the appearance that individuality and opposition is tolerated. However, anyone with a perceptive ear will note that such criticism never escapes the lips of the common citizen. If Han Jae Moon himself makes what sounds to an outsider like a contradictory statement, anyone among Chungsu who hears such a statement will question only their own memory of events. Whether this is due to some kind of ingrained cultural understanding or Han Jae Moon''s own incredible skills of manipulating the auditor is unknown.'
WHERE Text = 'civbe-eclipse';

INSERT INTO Language_en_US (Tag, Text)
VALUES
    ('TXT_KEY_INTRO_MESSAGE_AFRICAN_UNION_30', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_AL_FALAH_30', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_ARC_30', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_BRASILIA_30', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_CHUNGSU_30', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_FRANCO_IBERIA_30', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_INTEGR_30', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_KAVITHAN_30', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_NORTH_SEA_ALLIANCE_30', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_PAN_ASIA_30', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_POLYSTRALIA_30', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_RUSSIA_30', 'civbe-eclipse');
UPDATE Language_en_US
SET Text = 'While what goes on behind the closed doors of the Chungsu corporation is veiled in complete secrecy, there is a steady stream of technical innovation pouring out of Chungsu on a daily basis. All the way from the latest electronic toys and gadgets to personal and industrial robots and even including cybernetic implants. A careful observer will notice a growing trend in the cultural zeitgeist of a strong affinity towards upgrading the human experience through the liberal fusion of robotic augmentations with organic flesh. Chungsu''s military as a result has rapidly adopted robotic and cybernetic hardware, which when paired with Chungsu''s unparalleled intelligence services makes them a force to be reckoned with and wisely avoided.'
WHERE Text = 'civbe-eclipse';

-- INTEGR
INSERT INTO Language_en_US (Tag, Text)
VALUES
    ('TXT_KEY_INTRO_MESSAGE_AFRICAN_UNION_31', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_AL_FALAH_31', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_ARC_31', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_BRASILIA_31', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_CHUNGSU_31', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_FRANCO_IBERIA_31', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_INTEGR_31', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_KAVITHAN_31', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_NORTH_SEA_ALLIANCE_31', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_PAN_ASIA_31', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_POLYSTRALIA_31', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_RUSSIA_31', 'civbe-eclipse');
UPDATE Language_en_US
SET Text = 'Although relatively few people had heard of Lena Ebner before she took over leadership of INTEGR, she comes from a long line of hard-working industrialists. Like those before her, Lena prefers to keep her head down and let the results speak for themselves. Productivity and efficiency are held as high values both by Lena herself as well as INTEGR as a whole. Little acknowledgement nor approval are given to frivolity, and when possible any excess is sought out and curtailed with ruthless efficacy in order to prevent it from spreading like an infection. This same attitude has grown beyond just INTEGR''s own holdings to reflect its view on many of the other sponsors and their perceived wanton exhorbitance.'
WHERE Text = 'civbe-eclipse';

INSERT INTO Language_en_US (Tag, Text)
VALUES
    ('TXT_KEY_INTRO_MESSAGE_AFRICAN_UNION_32', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_AL_FALAH_32', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_ARC_32', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_BRASILIA_32', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_CHUNGSU_32', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_FRANCO_IBERIA_32', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_INTEGR_32', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_KAVITHAN_32', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_NORTH_SEA_ALLIANCE_32', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_PAN_ASIA_32', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_POLYSTRALIA_32', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_RUSSIA_32', 'civbe-eclipse');
UPDATE Language_en_US
SET Text = 'One of Lena Ebner''s first tasks as leader of INTEGR was to divert the majority of public funds to infrastructure. Having seen firsthand the massive and literal roadblocks that crippled industrial sectors, Lena could no longer allow crumbling infrastructure to be neglected. Many were the detractors who said the money would be better spent elsewhere: healthcare, social services, even the military. But she would not be swayed. Now on a new planet, Lena is determined not to repeat the same mistakes and to never allow infrastructure to be neglected. She holds this view so strongly that she has stated on more than one occasion that she would be willing to sacrifice her own personal standard of living if it came to it in order to keep the assembly lines running and the delivery of goods running smoothly from end to end.'
WHERE Text = 'civbe-eclipse';

INSERT INTO Language_en_US (Tag, Text)
VALUES
    ('TXT_KEY_INTRO_MESSAGE_AFRICAN_UNION_33', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_AL_FALAH_33', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_ARC_33', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_BRASILIA_33', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_CHUNGSU_33', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_FRANCO_IBERIA_33', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_INTEGR_33', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_KAVITHAN_33', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_NORTH_SEA_ALLIANCE_33', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_PAN_ASIA_33', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_POLYSTRALIA_33', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_RUSSIA_33', 'civbe-eclipse');
UPDATE Language_en_US
SET Text = 'As part of INTEGR''s commitment to eliminating all inefficiencies across the board, growing research into alien and technological discoveries and the alarming trends toward interest in using these discoveries to augment the human experience has been a growing concern. According to Lena Ebner, humans are already equipped with everything they need to be productive and functional, and she sees such investments of time and money as foolish and dangerous to the bottom line. INTEGR has no tolerance for such waste and is prepared to defend their point of view with force if that''s what it takes to protect its people from the wayward influences of those who would say otherwise.'
WHERE Text = 'civbe-eclipse';

-- North Sea Alliance
INSERT INTO Language_en_US (Tag, Text)
VALUES
    ('TXT_KEY_INTRO_MESSAGE_AFRICAN_UNION_34', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_AL_FALAH_34', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_ARC_34', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_BRASILIA_34', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_CHUNGSU_34', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_FRANCO_IBERIA_34', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_INTEGR_34', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_KAVITHAN_34', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_NORTH_SEA_ALLIANCE_34', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_PAN_ASIA_34', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_POLYSTRALIA_34', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_RUSSIA_34', 'civbe-eclipse');
UPDATE Language_en_US
SET Text = 'The inherent isolation that comes with living in a city floating on the water means that keeping a healthy population is of much greater importance. The citizens of the North Sea Alliance have learned to adopt a lifestyle that is centred on well-being, which is aided by a diet centred on water-based flora and fauna. When traveling to visit other sponsors, Duncan Hughes and his compatriots are often appalled to see how those living on land can be so careless in these matters that are of vital importance to the NSA.'
WHERE Text = 'civbe-eclipse';

INSERT INTO Language_en_US (Tag, Text)
VALUES
    ('TXT_KEY_INTRO_MESSAGE_AFRICAN_UNION_35', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_AL_FALAH_35', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_ARC_35', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_BRASILIA_35', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_CHUNGSU_35', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_FRANCO_IBERIA_35', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_INTEGR_35', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_KAVITHAN_35', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_NORTH_SEA_ALLIANCE_35', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_PAN_ASIA_35', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_POLYSTRALIA_35', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_RUSSIA_35', 'civbe-eclipse');
UPDATE Language_en_US
SET Text = 'After The Great Mistake, the nations in the North Sea found themselves with much less land to live on. This shared crisis caused them to come together to form the North Sea Alliance, and they naturally looked towards the vast seas that surrounded them for a solution. It was Duncan Hughes who developed the water-based, floating cities known as the ARKs. His experience as a longshoreman and naval engineer was instrumental in designing the concept, and it was his tireless commitment to the project that saw the first successful prototype go into production and eventual testing in the North Sea.'
WHERE Text = 'civbe-eclipse';

INSERT INTO Language_en_US (Tag, Text)
VALUES
    ('TXT_KEY_INTRO_MESSAGE_AFRICAN_UNION_36', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_AL_FALAH_36', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_ARC_36', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_BRASILIA_36', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_CHUNGSU_36', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_FRANCO_IBERIA_36', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_INTEGR_36', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_KAVITHAN_36', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_NORTH_SEA_ALLIANCE_36', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_PAN_ASIA_36', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_POLYSTRALIA_36', 'civbe-eclipse'),
    ('TXT_KEY_INTRO_MESSAGE_RUSSIA_36', 'civbe-eclipse');
UPDATE Language_en_US
SET Text = 'Being willing to live on a city floating on seas that are often anything but peaceful requires a strong reliance on and trust in technology. This has become an ingrained part of daily life in the North Sea Alliance, and Duncan Hughes has led his people by example. Constantly praising the benefits of technology, he often marvels out loud about the other sponsors who have a longstanding fear of adopting advancements that have grown to be an essential pillar of the thriving NSA society.'
WHERE Text = 'civbe-eclipse';
