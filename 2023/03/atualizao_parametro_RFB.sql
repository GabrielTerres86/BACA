BEGIN
UPDATE CECRED.TBCONV_CANALCOOP_LIBERADO CL
   SET CL.FLGLIBERADO = 1  --ativar
 WHERE CL.CDCANAL = 2   --apenas caixa
   AND CL.IDSEQCONVELIB IN (SELECT LIB.IDSEQCONVELIB
                              FROM CECRED.TBCONV_LIBERACAO LIB
                             WHERE LIB.CDCOOPER = 5
                               AND LIB.CDEMPRES = 'D0100'
                               AND LIB.CDCONVEN = 0);
  COMMIT;
END;							   