BEGIN
UPDATE CECRED.TBCONV_CANALCOOP_LIBERADO CL
   SET CL.FLGLIBERADO = 1
 WHERE CL.CDCANAL = 2
   AND CL.IDSEQCONVELIB IN (SELECT LIB.IDSEQCONVELIB
                              FROM CECRED.TBCONV_LIBERACAO LIB
                             WHERE LIB.CDCOOPER = 12
                               AND LIB.CDEMPRES = 'D0100'
                               AND LIB.CDCONVEN = 0);
  COMMIT;
END;							   