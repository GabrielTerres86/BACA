insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'QT_REENVIO_SMARTSHARE', 'Quantidade de tentativas de reenvio da proposta para o FTP da SMARTSHARE', '3');

/*Par�metro do corpo do email para retentativas de envio para an�lise */
insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'MSG_REL_RETENTA_FTP', 
		'Corpo do e-mail que ser� enviado com os dados das propostas que excederam as tentativas de reenvio do contrato ao SMARTSHARE.', 
		'Cooperativa, Segue lista de propostas de empr�stimo/financiamento que n�o tiveram contrato enviado ao SMARTSHARE.  � necess�rio enviar manualmente.');

/*Par�metro do assunto do email para retentativas de envio para an�lise */
insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'ASS_REL_RETENTA_FTP', 'Assunto do e-mail que ser� enviado com os dados das propostas que excederam as tentativas de reenvio do contrato ao SMARTSHARE.', 'Contratos Pendentes de Digitaliza��o.');
  
insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 1, 'EMAIL_RETENTA_FTP', 'Email que ir� receber a lista de propostas com pendencia de digitaliza��o para o FTP da SMARTSHARE', 'simula��es@viacredi.coop.br');
insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 2, 'EMAIL_RETENTA_FTP', 'Email que ir� receber a lista de propostas com pendencia de digitaliza��o para o FTP da SMARTSHARE', 'tiago.comelli@acredi.coop.br');
insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 5, 'EMAIL_RETENTA_FTP', 'Email que ir� receber a lista de propostas com pendencia de digitaliza��o para o FTP da SMARTSHARE', 'carolini.santiago@acentra.coop.br;administrativo@acentra.coop.br');
insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 8, 'EMAIL_RETENTA_FTP', 'Email que ir� receber a lista de propostas com pendencia de digitaliza��o para o FTP da SMARTSHARE', 'pamela.morais@credelesc.coop.br');
insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 9, 'EMAIL_RETENTA_FTP', 'Email que ir� receber a lista de propostas com pendencia de digitaliza��o para o FTP da SMARTSHARE', 'kassia.machado@transpocred.coop.br');
insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 10, 'EMAIL_RETENTA_FTP', 'Email que ir� receber a lista de propostas com pendencia de digitaliza��o para o FTP da SMARTSHARE', 'Fabiano.sousa@credicomin.coop.br');
insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 11, 'EMAIL_RETENTA_FTP', 'Email que ir� receber a lista de propostas com pendencia de digitaliza��o para o FTP da SMARTSHARE', 'patricia.bonini@credifoz.coop.br;luciani.stankowski@credifoz.coop.br');
insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 12, 'EMAIL_RETENTA_FTP', 'Email que ir� receber a lista de propostas com pendencia de digitaliza��o para o FTP da SMARTSHARE', 'controlesinternos@crevisc.coop.br');
insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 13, 'EMAIL_RETENTA_FTP', 'Email que ir� receber a lista de propostas com pendencia de digitaliza��o para o FTP da SMARTSHARE', 'cadastro@civia.coop.br');
insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 14, 'EMAIL_RETENTA_FTP', 'Email que ir� receber a lista de propostas com pendencia de digitaliza��o para o FTP da SMARTSHARE', 'Jose.junior@evolua.coop.br');
insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 16, 'EMAIL_RETENTA_FTP', 'Email que ir� receber a lista de propostas com pendencia de digitaliza��o para o FTP da SMARTSHARE', 'daniel.klug@viacredialtovale.coop.br');

COMMIT;
