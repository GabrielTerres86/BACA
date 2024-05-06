BEGIN

UPDATE crapope ope
   SET ope.dsimpres = '0301_laser_1'
 WHERE ope.cdcooper = 8
   AND ope.cdoperad = 'f0080089';

COMMIT;

END;