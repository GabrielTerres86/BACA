insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'QT_REENVIO_SMARTSHARE', 'Quantidade de tentativas de reenvio da proposta para o FTP da SMARTSHARE', '3');

/*Parâmetro do corpo do email para retentativas de envio para análise */
insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'MSG_REL_RETENTA_FTP', 
		'Corpo do e-mail que será enviado com os dados das propostas que excederam as tentativas de reenvio do contrato ao SMARTSHARE.', 
		'Cooperativa, Segue lista de propostas de empréstimo/financiamento que não tiveram contrato enviado ao SMARTSHARE.  É necessário enviar manualmente.');

/*Parâmetro do assunto do email para retentativas de envio para análise */
insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'ASS_REL_RETENTA_FTP', 'Assunto do e-mail que será enviado com os dados das propostas que excederam as tentativas de reenvio do contrato ao SMARTSHARE.', 'Contratos Pendentes de Digitalização.');
  
insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'EMAIL_RETENTA_FTP', 'Email que irá receber a lista de propostas com pendencia de digitalização para o FTP da SMARTSHARE', 'teste@cooperativa.coop.br');

COMMIT;
