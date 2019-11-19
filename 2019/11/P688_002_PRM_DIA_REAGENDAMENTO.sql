--Baca para adicionar novo parametro no Ayllos e Web 
     
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
        ,'REAGEND_JOB_UTLZ_CRD_DIA'
        ,'Dia para enviar o email de reagendamento'
        ,'15');
  
  COMMIT;
  
END;
