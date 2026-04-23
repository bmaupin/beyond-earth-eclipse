-- The discover signal ("Transcendental Equation") project is needed for the contact
-- victory. Its normal prereq is TECH_TRANSCENDENTAL_MATH, but that's only available to
-- purity. So set it to a tech with the same cost available to all affinities.
UPDATE Projects
SET TechPrereq = 'TECH_ARTIFICIAL_INTELLIGENCE'
WHERE Type = 'PROJECT_DISCOVER_SIGNAL';
