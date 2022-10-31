BEGIN
  
  INSERT INTO crapprm
                  (nmsistem
                  ,cdcooper
                  ,cdacesso
                  ,dstexprm
                  ,dsvlrprm)
           VALUES ('CRED'
                  ,0
                  ,'HISTORICOATMR'
                  ,'Historicos de movimentacoes do ATMR para serem considerados na composição do saldo'
                  ,'3458,3459,3460,3461,3639,3704');
                  
  COMMIT;
  
END;
