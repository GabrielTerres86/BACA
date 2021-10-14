DECLARE
  vr_nmpastacoop    VARCHAR2(500);
  CURSOR cr_crapcop IS
  SELECT *
    FROM CECRED.CRAPCOP
   WHERE CDCOOPER <> 3
     AND FLGATIVO = 1; 
BEGIN
  FOR rw_crapcop in cr_crapcop LOOP
    CASE rw_crapcop.cdcooper
      WHEN 5 THEN
        vr_nmpastacoop := 'Acentra';
      WHEN 2 THEN
        vr_nmpastacoop := 'Acredicoop';
      WHEN 16 THEN
        vr_nmpastacoop := 'Alto Vale';
      WHEN 13 THEN
        vr_nmpastacoop := 'Civia';
      WHEN 7 THEN
        vr_nmpastacoop := 'Credcrea';
      WHEN 8 THEN
        vr_nmpastacoop := 'Credelesc';
      WHEN 10 THEN
        vr_nmpastacoop := 'Credicomin';
      WHEN 11 THEN
        vr_nmpastacoop := 'Credifoz';
      WHEN 12 THEN
        vr_nmpastacoop := 'Crevisc';
      WHEN 14 THEN
        vr_nmpastacoop := 'Evolua';
      WHEN 9 THEN
        vr_nmpastacoop := 'Transpocred';
      WHEN 6 THEN
        vr_nmpastacoop := 'Unilos';
      WHEN 1 THEN
        vr_nmpastacoop := 'Viacredi';
      ELSE
        RAISE_APPLICATION_ERROR(-20500, 'Codigo de cooperativa nao valido!');
      END CASE;
      
    INSERT INTO CECRED.CRAPPRM (NMSISTEM,
                                CDCOOPER,
                                CDACESSO,
                                DSTEXPRM,
                                DSVLRPRM) VALUES
                               ('CRED'
                               ,rw_crapcop.cdcooper
                               ,'JURIDICO_ARQUIVOS_BC'
                               ,'Diretorio onde ficam os arquivos do setor Juridico, enviados ao Banco Central, separados por cooperativa'
                               ,'Juridico/Arquivos BC/Cooperativas/' || vr_nmpastacoop);
  END LOOP;
  
  COMMIT;                             
  
EXCEPTION
  WHEN others THEN
    RAISE_APPLICATION_ERROR(-20501, 'Erro: ' || SQLERRM);
END;
