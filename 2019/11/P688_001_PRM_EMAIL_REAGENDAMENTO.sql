BEGIN

     INSERT INTO crapprm (
        nmsistem
        , cdcooper
        , cdacesso
        , dstexprm
        , dsvlrprm
        ) values (
		 'CRED'
        ,0
        ,'REAGEND_JOB_UTLZ_CRD_EML'
        ,'Salvar email de notificacao de reagendamento do JOB jbcrd_importa_utlz_cartao'
        ,'cartoes@ailos.coop.br, nayara.cestari@ailos.coop.br, crislaine.souza@ailos.coop.br');
    
  COMMIT;
  
END;
