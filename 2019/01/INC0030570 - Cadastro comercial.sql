/* INC0030570 - Cadastro comercial */

/*Descrição: Boa tarde,

   Em cadastro comercial de cnpj de empresa Casas da Agua ao inserir cnpj em cadastro e clicar ENTER sistema automaticamente preenche empresa como INSS sendo que CNPJ 13.501.187/0004-00 é de empresa Casas da Agua.
Esta situação já estava ocorrendo no ano passado e foi corrigido.
  Provavelmente, em alguma conta física de algum cooperado que trabalhava na Casas da água e agora está aposentado, foi informado no campo nome da empresa INSS, porém, não deve ter sido excluído o CNPJ da Casas da Água, e o sistema deve ter travado gravando esta informação.
Ao tentar alterar o cadastro desta conta, informando o CNPJ da empresa Casas da água, automaticamente é preenchido o campo nome da empresa como INSS.
Precisamos que seja verificado com urgência pois este cooperado deseja solicitar a portabilidade de seu salário.*/


begin

  UPDATE TBCADAST_PESSOA c
   SET c.NMPESSOA ='HACO ETIQUETAS LTDA'
 WHERE c.NRCPFCGC = 82645862000136 ;
  
  commit;

exception

  when others then
  
    rollback;
  
end;
