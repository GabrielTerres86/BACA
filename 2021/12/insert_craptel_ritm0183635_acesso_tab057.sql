BEGIN
UPDATE craptel
SET CDOPPTEL = CDOPPTEL ||',V',
LSOPPTEL = LSOPPTEL ||',SEGUNDA VIA'
WHERE craptel.nmdatela = 'TAB057';
COMMIT;
END;