UPDATE crapprg
SET crapprg.nrsolici = 999
,crapprg.nrordprg =
(SELECT MAX(g.nrordprg) ordem
FROM crapprg g
WHERE g.cdcooper = 1
AND g.nrsolici = 999) + 1
WHERE cdcooper = 1
AND cdprogra = 'CRPS639';

UPDATE crapprg
SET crapprg.nrsolici = 999
,crapprg.nrordprg =
(SELECT MAX(g.nrordprg) ordem
FROM crapprg g
WHERE g.cdcooper = 2
AND g.nrsolici = 999) + 1
WHERE cdcooper = 2
AND cdprogra = 'CRPS639';

UPDATE crapprg
SET crapprg.nrsolici = 999
,crapprg.nrordprg =
(SELECT MAX(g.nrordprg) ordem
FROM crapprg g
WHERE g.cdcooper = 3
AND g.nrsolici = 999) + 1
WHERE cdcooper = 3
AND cdprogra = 'CRPS639';

UPDATE crapprg
SET crapprg.nrsolici = 999
,crapprg.nrordprg =
(SELECT MAX(g.nrordprg) ordem
FROM crapprg g
WHERE g.cdcooper = 5
AND g.nrsolici = 999) + 1
WHERE cdcooper = 5
AND cdprogra = 'CRPS639';

UPDATE crapprg
SET crapprg.nrsolici = 999
,crapprg.nrordprg =
(SELECT MAX(g.nrordprg) ordem
FROM crapprg g
WHERE g.cdcooper = 6
AND g.nrsolici = 999) + 1
WHERE cdcooper = 6
AND cdprogra = 'CRPS639';

UPDATE crapprg
SET crapprg.nrsolici = 999
,crapprg.nrordprg =
(SELECT MAX(g.nrordprg) ordem
FROM crapprg g
WHERE g.cdcooper = 7
AND g.nrsolici = 999) + 1
WHERE cdcooper = 7
AND cdprogra = 'CRPS639';

UPDATE crapprg
SET crapprg.nrsolici = 999
,crapprg.nrordprg =
(SELECT MAX(g.nrordprg) ordem
FROM crapprg g
WHERE g.cdcooper = 8
AND g.nrsolici = 999) + 1
WHERE cdcooper = 8
AND cdprogra = 'CRPS639';

UPDATE crapprg
SET crapprg.nrsolici = 999
,crapprg.nrordprg =
(SELECT MAX(g.nrordprg) ordem
FROM crapprg g
WHERE g.cdcooper = 9
AND g.nrsolici = 999) + 1
WHERE cdcooper = 9
AND cdprogra = 'CRPS639';

UPDATE crapprg
SET crapprg.nrsolici = 999
,crapprg.nrordprg =
(SELECT MAX(g.nrordprg) ordem
FROM crapprg g
WHERE g.cdcooper = 10
AND g.nrsolici = 999) + 1
WHERE cdcooper = 10
AND cdprogra = 'CRPS639';

UPDATE crapprg
SET crapprg.nrsolici = 999
,crapprg.nrordprg =
(SELECT MAX(g.nrordprg) ordem
FROM crapprg g
WHERE g.cdcooper = 11
AND g.nrsolici = 999) + 1
WHERE cdcooper = 11
AND cdprogra = 'CRPS639';

UPDATE crapprg
SET crapprg.nrsolici = 999
,crapprg.nrordprg =
(SELECT MAX(g.nrordprg) ordem
FROM crapprg g
WHERE g.cdcooper = 12
AND g.nrsolici = 999) + 1
WHERE cdcooper = 12
AND cdprogra = 'CRPS639';

UPDATE crapprg
SET crapprg.nrsolici = 999
,crapprg.nrordprg =
(SELECT MAX(g.nrordprg) ordem
FROM crapprg g
WHERE g.cdcooper = 13
AND g.nrsolici = 999) + 1
WHERE cdcooper = 13
AND cdprogra = 'CRPS639';

UPDATE crapprg
SET crapprg.nrsolici = 999
,crapprg.nrordprg =
(SELECT MAX(g.nrordprg) ordem
FROM crapprg g
WHERE g.cdcooper = 14
AND g.nrsolici = 999) + 1
WHERE cdcooper = 14
AND cdprogra = 'CRPS639';

UPDATE crapprg
SET crapprg.nrsolici = 999
,crapprg.nrordprg =
(SELECT MAX(g.nrordprg) ordem
FROM crapprg g
WHERE g.cdcooper = 16
AND g.nrsolici = 999) + 1
WHERE cdcooper = 16
AND cdprogra = 'CRPS639';

commit;
