/* 
SCRIPT DE ROLLBACK
Objetivo   : Volta o conteúdo das colunas CRAPASS.NMPRIMTL e TBCADAST_PESSOA.NMPESSOA para seu estado original,
             em relação ao incidente.
Autor: Edmar
*/


update CRAPASS a
   set a.nmprimtl = ' '
 where a.progress_recid in (110049,
                            824090,
                            587805,
                            436983,
                            965156,
                            604094,
                            461548,
                            560346,
                            76258,
                            12424);
                            
update TBCADAST_PESSOA p
   set p.nmpessoa = ' '
 where p.idpessoa in (155576,
                      155576,
                      155576,
                      155576,
                      8020014,
                      2480817,
                      442642,
                      1133973,
                      1418431,
                      1126938);
                      
COMMIT;