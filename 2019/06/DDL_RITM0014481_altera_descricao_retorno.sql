/*RITM0014481
Ana Lucia Volles - 25/06/2019

Alterar conteúdo do campo "descrição" da tela Atenda - Empréstimos - Retorno Baca

Cooperativa cadastrou errado, diferente da escritura

select a.dsbemfin , a.* from CRAPBPR a where a.nrdconta = 1600 and a.nrctrpro = 3500 and a.cdcooper = 10;
*/

Begin
  
  update  CRAPBPR a 
  set     a.dsbemfin = 'IMOVEL LOCALIZADO SETIMO ANDAR COND VF 284,10M2'
  where   a.nrdconta = 1600 
  and     a.nrctrpro = 3500
  and     a.cdcooper = 10;

commit;

Exception
  when others then
    rollback;

End;
