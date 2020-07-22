DECLARE
BEGIN
  FOR rw_crapcop IN (SELECT c.cdcooper FROM crapcop c WHERE c.flgativo = 1 AND c.cdcooper <> 3) LOOP   
    -- PERC_HONORARIOS_RECUP
    INSERT INTO CRAPPRM
      (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    VALUES
      ('CRED',
        rw_crapcop.cdcooper,
       'PERC_HONORARIOS_RECUP',
       'Percentual de honorarios utilizado para recuperação',
       '10');
  
    -- COBEMP_INSTR_LINHA_5
    INSERT INTO CRAPPRM
      (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    VALUES
      ('CRED',
        rw_crapcop.cdcooper,
       'COBEMP_INSTR_LINHA_5',
       'Mensagem de informação do boleto - linha 5',
       'Ao valor do boleto foi incluso #HONORARIO#% de honorarios advocaticios');      
  END LOOP;
  
  -- crapaca pc_gravar_web 
  UPDATE crapaca
    SET lstparam = lstparam || ',pr_perchono,pr_dslinha5'
  WHERE crapaca.nmpackag = 'TELA_TAB096'
    AND crapaca.nmproced = 'pc_gravar_web';
  
  COMMIT;
END;
