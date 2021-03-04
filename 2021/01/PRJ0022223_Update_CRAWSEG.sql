----updates   CHUBB para Icatu
update crapseg set cdsegura = 514 where cdsegura = 5011 and cdsitseg = 1 and TPSEGURO = 4  ; 

update crawseg set cdsegura = 514 where cdsegura = 5011 
 and exists (select 1 FROM crapseg se
                          WHERE crawseg.cdcooper = se.cdcooper
                            AND crawseg.nrdconta = se.nrdconta
                            AND crawseg.nrctrseg = se.nrctrseg
                            AND se.cdsegura = 514  )
; 
commit;
