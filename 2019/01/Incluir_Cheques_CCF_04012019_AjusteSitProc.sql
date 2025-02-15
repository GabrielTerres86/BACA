/*
-- validar apos execução.
SELECT *
FROM crapneg a
WHERE a.nrdconta IN (8751587,135119,8686955,7950934)
AND a.cdobserv = 12
AND a.nrdocmto IN (604,345,396,35)
AND a.dtiniest >= '20/11/2018';
*/	

-- SCTASK0038350        
insert into crapneg (NRDCONTA, NRSEQDIG, DTINIEST, CDHISEST, CDOBSERV, NRDCTABB, NRDOCMTO, VLESTOUR, QTDIAEST, VLLIMCRE, CDBANCHQ, CDTCTANT, CDAGECHQ, CDTCTATU, NRCTACHQ, DTFIMEST, CDOPERAD, CDCOOPER, FLGCTITG, DTECTITG, IDSEQTTL, DTIMPREG, CDOPEIMP)
values (8751587, fn_sequence('CRAPNEG', 'NRSEQDIG', 1 || ';' || 8751587), to_date('20-11-2018', 'dd-mm-yyyy'), 1, 12, 8751587, 604, 316.28, 0, 0.00, 85, 0, 101, 0, 8751587, null, '1', 1, 0, null, 0, null, ' ');

-- SCTASK0041664
insert into crapneg (NRDCONTA, NRSEQDIG, DTINIEST, CDHISEST, CDOBSERV, NRDCTABB, NRDOCMTO, VLESTOUR, QTDIAEST, VLLIMCRE, CDBANCHQ, CDTCTANT, CDAGECHQ, CDTCTATU, NRCTACHQ, DTFIMEST, CDOPERAD, CDCOOPER, FLGCTITG, DTECTITG, IDSEQTTL, DTIMPREG, CDOPEIMP)
values (135119, fn_sequence('CRAPNEG', 'NRSEQDIG', 7 || ';' || 135119), to_date('28-12-2018', 'dd-mm-yyyy'), 1, 12, 135119, 345, 804.03, 0, 0.00, 85, 0, 106, 0, 135119, null, '1', 7, 0, null, 0, null, ' ');

-- SCTASK0041663
insert into crapneg (NRDCONTA, NRSEQDIG, DTINIEST, CDHISEST, CDOBSERV, NRDCTABB, NRDOCMTO, VLESTOUR, QTDIAEST, VLLIMCRE, CDBANCHQ, CDTCTANT, CDAGECHQ, CDTCTATU, NRCTACHQ, DTFIMEST, CDOPERAD, CDCOOPER, FLGCTITG, DTECTITG, IDSEQTTL, DTIMPREG, CDOPEIMP)
values (8686955, fn_sequence('CRAPNEG', 'NRSEQDIG', 1 || ';' || 8686955), to_date('19-12-2018', 'dd-mm-yyyy'), 1, 12, 8686955, 396, 1193.74, 0, 2500.00, 85, 0, 101, 0, 8686955, null, '1', 1, 0, null, 0, null, ' ');

-- SCTASK0041662
insert into crapneg (NRDCONTA, NRSEQDIG, DTINIEST, CDHISEST, CDOBSERV, NRDCTABB, NRDOCMTO, VLESTOUR, QTDIAEST, VLLIMCRE, CDBANCHQ, CDTCTANT, CDAGECHQ, CDTCTATU, NRCTACHQ, DTFIMEST, CDOPERAD, CDCOOPER, FLGCTITG, DTECTITG, IDSEQTTL, DTIMPREG, CDOPEIMP)
values (7950934, fn_sequence('CRAPNEG', 'NRSEQDIG', 1 || ';' || 7950934), to_date('19-12-2018', 'dd-mm-yyyy'), 1, 12, 7950934, 35, 369.96, 0, 1000.00, 85, 0, 101, 0, 7950934, null, '1', 1, 0, null, 0, null, ' ');
    
COMMIT;


-- Ajustar cheques já inclusos no CCF devido ao furo que iremos corrgiir no processamento do retorno no dia 15/01
-- SCTASK0038351 -- 
-- SCTASK0038347 -- 
-- SCTASK0038343 -- 

UPDATE crapneg a
   SET a.flgctitg = 2
 WHERE a.dtiniest >= '01/11/2018'
   AND a.flgctitg = 1
   and a.nrdconta IN (8686955,7950934);

COMMIT;


