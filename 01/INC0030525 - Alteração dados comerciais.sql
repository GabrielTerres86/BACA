/* INC0030525 - Altera��o dados comerciais*/

/*Descri��o: Cooperado esteve no PA para solicitar a portabilidade do sal�rio. Por�m em consulta na tela CONTAS, 
verificou-se que o nome da empresa esta divergente do cart�o CNPJ. Esta empresa n�o possui conta na cooperativa e para tal precisamos fazer  a altera��o no nome da empresa para ficar certo sempre que usarmos esse CNPJ. 
Na imagem abaixo, conta o nome do CNPJ em destaque que precisa ser corrigido para HACO ETIQUETAS LTDA.
Cooperativa necessita  que seja feita a altera��o para solicitar a portabilidade e fidelizar o cooperado.

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
