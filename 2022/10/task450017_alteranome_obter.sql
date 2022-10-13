BEGIN
   UPDATE cecred.crapaca
     SET NMDEACAO = 'OBTER_STATUS_GERACAO_CERC'
        ,NMPROCED = 'CREDITO.obterStatusGeracaoArqWeb'
   WHERE NMDEACAO = 'VALIDA_STATUS_GERACAO_CERC';
   
  COMMIT;
          
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      raise_application_error(-20500,SQLERRM);
END;
