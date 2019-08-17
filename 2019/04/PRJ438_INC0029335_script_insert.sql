/*Gerar prestamista referente ao incidente
INC0029335
Paulo Martins - Mouts
*/

insert into crapseg(nrdconta, 
                   nrctrseg, 
                   dtinivig, 
                   dtfimvig, 
                   dtmvtolt, 
                   dtdebito, 
                   dtiniseg, 
                   vlpreseg, 
                   tpseguro, 
                   tpplaseg, 
                   cdsegura, 
                   lsctrant, 
                   nrctratu, 
                   flgunica, 
                   dtprideb, 
                   vldifseg, 
                   vlpremio, 
                   qtparcel, 
                   tpdpagto, 
                   cdcooper, 
                   flgconve,
                   cdsitseg)
select nrdconta, 
       nrctrseg, 
       dtinivig, 
       dtfimvig, 
       dtmvtolt, 
       dtdebito, 
       dtiniseg, 
       vlpreseg, 
       tpseguro, 
       tpplaseg, 
       cdsegura, 
       lsctrant, 
       nrctratu, 
       flgunica, 
       dtprideb, 
       vldifseg, 
       vlpremio, 
       qtparcel, 
       tpdpagto, 
       cdcooper, 
       flgconve,
       1
  from crawseg g
 where g.nrdconta = 85391
   and g.cdcooper = 10
   and g.nrctrseg = 5181;
   --
   commit;
