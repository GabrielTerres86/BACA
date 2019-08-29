update crawepr w
   set w.dtulteml = sysdate
 where w.rowid in
       (SELECT epr.rowid
          FROM crawepr epr, crapope c
         WHERE epr.insitest = 3 -- Situacao Analise Finalizada
           AND epr.insitapr = 1 -- Decisao aprovada
           AND epr.dtaprova IS NOT NULL -- Ter data de 
           AND epr.cdcooper = c.cdcooper
           AND epr.cdopeste = c.cdoperad
           AND TRIM(c.dsdemail) is not null
           AND epr.dtaprova < sysdate - 15
           AND NOT EXISTS ( SELECT 1
                              FROM crapepr epr2
                             WHERE epr2.cdcooper = epr.cdcooper
                               AND epr2.nrdconta = epr.nrdconta
                               AND epr2.nrctremp = epr.nrctremp));
/                               
--commit;
/                               
BEGIN
  --/
  INSERT INTO CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  VALUES ('CRED', 0, 'QT_RETENTATIVAS_ANALISE', 'Quantidade de tentativas de reenvio da proposta de credito para analise', '3');
  --/
  INSERT INTO CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM) 
  VALUES ('CRED', 0, 'QT_MINUTOS_RETENTATIVAS', 'Quantidade de minutos que o sistema ter� de esperar para iniciar nova tentativa de reenvio da proposta de credito para analise', 1);
  --/
  INSERT INTO CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM) 
  VALUES ('CRED', 0, 'METODO_REENVIO_ATIVO', 'Indica se o metodo do reenvio das propostas de credito para analise esta ativo (0/1)', 1); 
  --/
  INSERT INTO CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM) 
  VALUES ('CRED', 0, 'METODO_REENVIO_TPEMPRST', 'Contem os tipos de emprestimos que participam do metodo de reenvio das propostas de credito para analise', 1); 
  --/ 
  INSERT INTO CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM) 
  VALUES ('CRED', 0, 'METODO_REENVIO_MSG', 'Contem a mensagem direcionada ao operador caso o mesmo esteja tentando enviar uma proposta para analise junto com o JOB este0001.pc_job_reenvio_analise', 'Ja existe um reenvio para analise, iniciado pelo sistema, em andamento. Aguarde.'); 
  
  /*Par�metro do corpo do email para retentativas de envio para an�lise */
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 0, 'MSG_REL_RETENTA_ANALISE', 
      'Corpo do e-mail que ser� enviado com os dados das propostas que excederam as tentativas de reenvio para an�lise.', 
      'Cooperativa, Segue lista de propostas de empr�stimo/financiamento que foram enviadas ao motor de cr�dito e houve erro no retorno.  � necess�rio enviar novamente essas propostas para an�lise do motor, atrav�s do bot�o analisar em Atenda>Empr�stimo.');

  /*Par�metro do assunto do email para retentativas de envio para an�lise */
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 0, 'ASS_REL_RETENTA_ANALISE', 'Assunto do e-mail que ser� enviado com os dados das propostas que excederam as tentativas de reenvio para an�lise.', 'Propostas Pendentes de An�lise.');
                                              
  /*Par�metro de dias para relat�rio de retentativas de envio para an�lise */
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 0, 'DIAS_REL_RETENTA_ANALISE', 'Quantidade m�xima de dias que a proposta deve estar pendente para que entre no relat�rio das que excederam as tentativas de reenvio para an�lise.', '30');

  /*Par�metro do endere�o de email para retentativas de envio para an�lise */
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 11, 'EMAIL_RETENTA_ANALISE', 
      'Endere�o do e-mail que ser� enviado com os dados das propostas que excederam as tentativas de reenvio para an�lise.', 
      'credito@credifoz.coop.br');

  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 9, 'EMAIL_RETENTA_ANALISE', 
      'Endere�o do e-mail que ser� enviado com os dados das propostas que excederam as tentativas de reenvio para an�lise.', 
      'credito@transpocred.coop.br');
      
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 8, 'EMAIL_RETENTA_ANALISE', 
      'Endere�o do e-mail que ser� enviado com os dados das propostas que excederam as tentativas de reenvio para an�lise.', 
      'fabiane@credelesc.coop.br');  

  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 7, 'EMAIL_RETENTA_ANALISE', 
      'Endere�o do e-mail que ser� enviado com os dados das propostas que excederam as tentativas de reenvio para an�lise.', 
      'credito@credcrea.coop.br');    
      
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 5, 'EMAIL_RETENTA_ANALISE', 
      'Endere�o do e-mail que ser� enviado com os dados das propostas que excederam as tentativas de reenvio para an�lise.', 
      'credito@acentra.coop.br');      
      
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 10, 'EMAIL_RETENTA_ANALISE', 
      'Endere�o do e-mail que ser� enviado com os dados das propostas que excederam as tentativas de reenvio para an�lise.', 
      'silvana.morais@credicomin.coop.br');	

  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 14, 'EMAIL_RETENTA_ANALISE', 
      'Endere�o do e-mail que ser� enviado com os dados das propostas que excederam as tentativas de reenvio para an�lise.', 
      'gestaodecredito@evolua.coop.br');
  		
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 12, 'EMAIL_RETENTA_ANALISE', 
      'Endere�o do e-mail que ser� enviado com os dados das propostas que excederam as tentativas de reenvio para an�lise.', 
      'crevisc@crevisc.coop.br');		
  		
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 1, 'EMAIL_RETENTA_ANALISE', 
      'Endere�o do e-mail que ser� enviado com os dados das propostas que excederam as tentativas de reenvio para an�lise.', 
      'credito@viacredi.coop.br');				
  		
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 16, 'EMAIL_RETENTA_ANALISE', 
      'Endere�o do e-mail que ser� enviado com os dados das propostas que excederam as tentativas de reenvio para an�lise.', 
      'credito@viacredialtovale.coop.br');			
  		
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 6, 'EMAIL_RETENTA_ANALISE', 
      'Endere�o do e-mail que ser� enviado com os dados das propostas que excederam as tentativas de reenvio para an�lise.', 
      'credito@credifiesc.coop.br');			
  		
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 13, 'EMAIL_RETENTA_ANALISE', 
      'Endere�o do e-mail que ser� enviado com os dados das propostas que excederam as tentativas de reenvio para an�lise.', 
      'comitedecredito@civia.coop.br');					
  		
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 2, 'EMAIL_RETENTA_ANALISE', 
      'Endere�o do e-mail que ser� enviado com os dados das propostas que excederam as tentativas de reenvio para an�lise.', 
      'comitedecredito@acredi.coop.br');	

   --/
  INSERT INTO tbepr_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  VALUES ('INSITRNV', '0', 'Nao enviado');
  --/
  INSERT INTO tbepr_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  VALUES ('INSITRNV', '1', 'Agendado');
  --/
  INSERT INTO tbepr_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  VALUES ('INSITRNV', '3', 'Em execucao');
  --/
  INSERT INTO tbepr_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  VALUES ('INSITRNV', '4', 'Concluido');
  --/
  INSERT INTO tbepr_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  VALUES ('INSITRNV', '5', 'Cancelado');
  --/
 --/
-- COMMIT;
 --/
END;
                               
