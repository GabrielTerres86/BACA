--Atualizar email da tabela crapprm conforme solicitado através do ticket RITM0041223
 
update crapprm
   set dsvlrprm = 'fernanda.eccher@ailos.coop.br;marcelo.silva@ailos.coop.br;maxsuell.duranti@ailos.coop.br'
 where cdcooper = 0 
   and cdacesso = 'CRPS408_EMAIL_RRD' 
   and nmsistem = 'CRED';
   
 COMMIT;   
