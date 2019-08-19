/* INC0030525 - Alteração dados comerciais*/

/*Descrição: Cooperado esteve no PA para solicitar a portabilidade do salário. Porém em consulta na tela CONTAS, 
verificou-se que o nome da empresa esta divergente do cartão CNPJ. Esta empresa não possui conta na cooperativa e para tal precisamos fazer  a alteração no nome da empresa para ficar certo sempre que usarmos esse CNPJ. 
Na imagem abaixo, conta o nome do CNPJ em destaque que precisa ser corrigido para HACO ETIQUETAS LTDA.
Cooperativa necessita  que seja feita a alteração para solicitar a portabilidade e fidelizar o cooperado.

Atenciosamente, */

begin

  UPDATE TBCADAST_PESSOA c
   SET c.NMPESSOA ='HACO ETIQUETAS LTDA'
 WHERE c.NRCPFCGC = 82645862000136 ;
  
  commit;

exception

  when others then
  
    rollback;
  
end;
