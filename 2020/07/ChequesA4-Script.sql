/*
  [INC0055795] Marcar folhas de cheque de formulário A4 (descontinuado) como canceladas,
  incluir data de liberação e de compensação.
*/
update crapfdc fdc
   set fdc.dtretchq = '21/07/2020',
       fdc.dtliqchq = '21/07/2020',
       fdc.incheque = 8
 where nvl(fdc.dtretchq, '01/01/0001') = '01/01/0001'
   and fdc.tpforchq = 'A4';
commit;
