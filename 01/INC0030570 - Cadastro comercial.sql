/* INC0030570 - Cadastro comercial */

/*Descri��o: Boa tarde,

   Em cadastro comercial de cnpj de empresa Casas da Agua ao inserir cnpj em cadastro e clicar ENTER sistema automaticamente preenche empresa como INSS sendo que CNPJ 13.501.187/0004-00 � de empresa Casas da Agua.
Esta situa��o j� estava ocorrendo no ano passado e foi corrigido.
  Provavelmente, em alguma conta f�sica de algum cooperado que trabalhava na Casas da �gua e agora est� aposentado, foi informado no campo nome da empresa INSS, por�m, n�o deve ter sido exclu�do o CNPJ da Casas da �gua, e o sistema deve ter travado gravando esta informa��o.
Ao tentar alterar o cadastro desta conta, informando o CNPJ da empresa Casas da �gua, automaticamente � preenchido o campo nome da empresa como INSS.
Precisamos que seja verificado com urg�ncia pois este cooperado deseja solicitar a portabilidade de seu sal�rio.*/


begin

  UPDATE TBCADAST_PESSOA c
   SET c.NMPESSOA ='HACO ETIQUETAS LTDA'
 WHERE c.NRCPFCGC = 82645862000136 ;
  
  commit;

exception

  when others then
  
    rollback;
  
end;
