BEGIN 

    UPDATE TBGEN_NOTIF_MANUAL_PRM
       SET CDSITUACAO_MENSAGEM = 3
	     , DHENVIO_MENSAGEM = TO_DATE('21/12/2022 10:00:00','DD/MM/YYYY HH24:MI:SS')
     WHERE CDMENSAGEM = 7720;

    COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500,SQLERRM);
    ROLLBACK;

END;