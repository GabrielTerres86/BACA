/* INC0019000  -- rollback */
update crawlim x
   set x.insitlim = 9, x.dtanulac = to_date('25/06/2019', 'DD/MM/RRRR')
 where x.cdcooper = 1
   and x.nrdconta = 4035216
   and x.tpctrlim = 3
   and x.nrctrlim = 7482;

update crawlim x
   set x.insitapr = 8
 where x.cdcooper = 1
   and x.nrdconta = 4035216
   and x.tpctrlim = 3
   and x.nrctrlim = 9782

 insert into tbmotivo_anulacao(CDCOOPER,
                         NRDCONTA,
                         NRCTRATO,
                         TPCTRLIM,
                         DTCADASTRO,
                         CDMOTIVO,
                         DSMOTIVO,
                         DSOBSERVACAO,
                         CDOPERAD)
 values(1,
              4035216,
              7482,
              3,
              to_date('25-06-2019', 'dd-mm-yyyy'),
              8,
              'Outros',
              'aumento de limite',
              'f0011259');

commit;
