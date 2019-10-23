UPDATE craptfc tfc
   SET tfc.nrtelefo = tfc.nrtelefo
 WHERE tfc.progress_recid IN
( SELECT tfc.progress_recid
FROM craptfc tfc, crapcop cop, crapass ass, tbcadast_pessoa tcp
WHERE cop.cdcooper = tfc.cdcooper
  AND ass.cdcooper = tfc.cdcooper
  AND ass.nrdconta = tfc.nrdconta
  AND ass.nrcpfcgc = tcp.nrcpfcgc
  AND ass.cdcooper <> 3
  AND tfc.idseqttl = 1
  AND tfc.tptelefo IS NOT NULL
  AND tfc.nrtelefo > 9999999
  AND NOT EXISTS (SELECT 1 FROM tbcadast_pessoa_telefone tpt WHERE tpt.idpessoa = tcp.idpessoa                                                               
                                                               AND tpt.nrtelefone = tfc.nrtelefo)
);

COMMIT;
