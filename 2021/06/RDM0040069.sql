DECLARE
  pr_cdcooper INTEGER;

  CURSOR cr_crapcop IS
    SELECT cop.cdcooper
      FROM crapcop cop;
  rw_crapcop cr_crapcop%ROWTYPE;

  vr_aux2 INTEGER := 0;
  vr_erro PLS_INTEGER := 0;
  vr_correto PLS_INTEGER := 0;


BEGIN

  FOR rw_crapcop in cr_crapcop LOOP
 
     BEGIN
       INSERT INTO craptab 
        (NMSISTEM,
         TPTABELA,
         CDEMPRES,
         CDACESSO,
         TPREGIST,
         DSTEXTAB,
         CDCOOPER)
       VALUES
        ('CRED',
         'GENERI',
         0,
         'HRPGAILOS', 
         90,
         '21600 64800 65400',
         rw_crapcop.cdcooper);
      EXCEPTION
        WHEN dup_val_on_index THEN
          vr_erro := vr_erro + 1;
          vr_correto := vr_correto - 1;
        WHEN OTHERS THEN
          dbms_output.put_line(SQLERRM);
          vr_erro := vr_erro + 1;
          vr_correto := vr_correto - 1;
     END;
  END LOOP;


  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 0, 'FGTS_COMPR_RODAPE', 'Parametro para rodape de comprovantes do fgts mobile (Ailos)', 'SAC 0800 647 2200;Atendimento todos os dias das 06:00 às 22:00;OUVIDORIA 0800 644 1100;Atendimento todos os dias das 08:00 às 17:00');

  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 0, 'FGTS_COMPR_CABECALHO', 'Parametro para cabeçalho de comprovantes do fgts mobile (Bancoob)', 'Convênio - Banco Cooperativo do Brasil - Bancoob');

  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 0, 'FGTS_COMPR_RODAPEBANCOOB', 'Parametro para rodape de comprovantes do fgts mobile Bancoob)', 'OUVIDORIA BANCOOB 0800-646-4001;SAC 0800-123-4567');

  commit; 

end; 
/