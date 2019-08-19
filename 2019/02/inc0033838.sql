/********

     SCRIPT PARA ATUALIZAR A SITUAÇÃO DE CHEQUES E CRIAR HISTÓRICO DE DEVOLUÇÃO.



        Backup:

        update crapfdc f set f.incheque = -5, f.dtliqchq = null where f.progress_recid = 54373667;
        update crapfdc f set f.incheque = -5, f.dtliqchq = null where f.progress_recid = 53645034;
        update crapfdc f set f.incheque = -5, f.dtliqchq = null where f.progress_recid = 53304875;
        update crapfdc f set f.incheque = 5, f.dtliqchq = '19/02/19' where f.progress_recid = 54043750;
        update crapfdc f set f.incheque = 5, f.dtliqchq = '22/02/19' where f.progress_recid = 54043756;
        update crapfdc f set f.incheque = -5, f.dtliqchq = null where f.progress_recid = 53102283;


**********/
   
--Updates
update crapfdc f set f.incheque = 0, f.dtliqchq = null where f.progress_recid = 54373667;
update crapfdc f set f.incheque = 0, f.dtliqchq = null where f.progress_recid = 53645034;
update crapfdc f set f.incheque = 0, f.dtliqchq = null where f.progress_recid = 53304875;
update crapfdc f set f.incheque = 0, f.dtliqchq = null where f.progress_recid = 54043750;
update crapfdc f set f.incheque = 0, f.dtliqchq = null where f.progress_recid = 54043756;
update crapfdc f set f.incheque = 0, f.dtliqchq = null where f.progress_recid = 53102283;

--Inserts
insert into crapneg (NRDCONTA, NRSEQDIG, DTINIEST, CDHISEST, CDOBSERV, NRDCTABB, NRDOCMTO, VLESTOUR, QTDIAEST, VLLIMCRE, CDBANCHQ, CDTCTANT, CDAGECHQ, CDTCTATU, NRCTACHQ, DTFIMEST, CDOPERAD, CDCOOPER, FLGCTITG, DTECTITG, IDSEQTTL, DTIMPREG, CDOPEIMP)
values (160385, fn_sequence('CRAPNEG', 'NRSEQDIG', 5 || ';' || 160385), to_date('19-02-2019', 'dd-mm-yyyy'), 1, 11, 160385, 337, 9130, 0, 3000, 85, 0, 104, 0, 160385, null, '1', 5, 0, null, 0, null, ' ');

insert into crapneg (NRDCONTA, NRSEQDIG, DTINIEST, CDHISEST, CDOBSERV, NRDCTABB, NRDOCMTO, VLESTOUR, QTDIAEST, VLLIMCRE, CDBANCHQ, CDTCTANT, CDAGECHQ, CDTCTATU, NRCTACHQ, DTFIMEST, CDOPERAD, CDCOOPER, FLGCTITG, DTECTITG, IDSEQTTL, DTIMPREG, CDOPEIMP)
values (160385, fn_sequence('CRAPNEG', 'NRSEQDIG', 5 || ';' || 160385), to_date('22-02-2019', 'dd-mm-yyyy'), 1, 11, 160385, 396, 5000, 0, 3000, 85, 0, 104, 0, 160385, null, '1', 5, 0, null, 0, null, ' ');


COMMIT;
