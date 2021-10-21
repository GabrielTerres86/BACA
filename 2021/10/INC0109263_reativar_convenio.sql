begin
----------------------------
UPDATE crapatr atr
  SET atr.cdopeexc = ' ',
      atr.dtinsexc = NULL,
      atr.dtfimatr = NULL,
      atr.dtiniatr = TRUNC(SYSDATE+1)
WHERE progress_recid = 1248383;
----------------------------
INSERT INTO craplgm (CDCOOPER, NRDCONTA, IDSEQTTL, NRSEQUEN, DTTRANSA, HRTRANSA, DSTRANSA, DSORIGEM, NMDATELA, FLGTRANS, DSCRITIC, CDOPERAD, NMENDTER)
VALUES (1, 656526, 1, 1, to_date('21/10/2021', 'dd/mm/yyyy'), 60000, 'Reativação débito autorizado (INC0109263)', 'AIMARO WEB', 'CONTAS', 1, ' ', '1', ' '); 
----------------------------
COMMIT;

end;