DECLARE

  CURSOR cr_crapcop IS
    SELECT cop.cdcooper
      FROM crapcop cop
     WHERE cop.flgativo = 1;
  

  -- Variável de críticas
  vr_cdcritic      crapcri.cdcritic%TYPE;
  vr_dscritic      VARCHAR2(10000);
  vr_exc_saida     EXCEPTION;
  vr_qtdsuces      INTEGER := 0;
  vr_qtderror      INTEGER := 0;

BEGIN
  
  FOR rw_crapcop IN cr_crapcop LOOP
    BEGIN

      UPDATE craptab tab
         SET tab.dstextab = tab.dstextab || ' 000,00000000'
       WHERE tab.cdcooper = rw_crapcop.cdcooper
         AND tab.nmsistem = 'CRED'
         AND tab.tptabela = 'GENERI'
         AND tab.cdempres = 00
         AND tab.cdacesso = 'EXEICMIRET'
         AND tab.tpregist = 001;
  
      vr_qtdsuces := vr_qtdsuces + 1;

    EXCEPTION  -- exception handlers begin
      WHEN OTHERS THEN  -- handles all other errors
        vr_dscritic := 'Erro ao adicionar string ao final do campo craptab.dstextab para a cooperativa: '|| rw_crapcop.cdcooper ||', Error: (' || SQLERRM || ');';
        vr_qtderror := vr_qtderror + 1;
      END;

  END LOOP;
  
  COMMIT;

  dbms_output.put_line('Qtd de Sucesso: ' || vr_qtdsuces);
  dbms_output.put_line('Qtd de Erros: ' || vr_qtderror);

END;