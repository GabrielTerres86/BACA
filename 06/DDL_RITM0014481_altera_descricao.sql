/*RITM0014481
Ana Lucia Volles - 25/08/2019

Alterar conte�do do campo "descri��o" da tela Atenda - Empr�stimos

Cooperativa cadastrou errado, diferente da escritura
*/

Begin
  
  update  CRAPBPR a 
  set     a.dsbemfin = 'COBERTURA LOC. NONO ANDAR DO COND. EDIF. VF'
  where   a.nrdconta = 1600 
  and     a.nrctrpro = 3500
  and     a.cdcooper = 10;

commit;

Exception
  when others then
    rollback;

End;
