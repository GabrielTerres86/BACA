DECLARE
  CURSOR cr_parcelas IS
    SELECT p.cdcooper,p.nrdconta,p.nrctremp,p.nrparepr,p.vlsdvpar,e.vlsprojt,e.vlsdeved
      FROM crappep p
      JOIN crapepr e
        ON e.cdcooper = p.cdcooper
       AND e.nrdconta = p.nrdconta
       AND e.nrctremp = p.nrctremp
     WHERE e.tpemprst = 2
       AND p.vlsdvpar < 0
       AND p.inliquid = 0
  ORDER BY 1,2,3,4;

  vr_texto_completo  CLOB;
  vr_des_log         CLOB;   
  vr_dsdireto        VARCHAR2(1000);

BEGIN
  vr_texto_completo := NULL;
  vr_des_log        := NULL;
  vr_dsdireto       := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/jaison';

  dbms_lob.createtemporary(vr_des_log, TRUE);
  dbms_lob.open(vr_des_log, dbms_lob.lob_readwrite);

  GENE0002.pc_escreve_xml(vr_des_log, vr_texto_completo, 'Coop.;Conta;Contrato;Parcela;Saldo Antes Quitacao;Saldo Projetado;Saldo Devedor' || chr(10));

  FOR rw_parcelas IN cr_parcelas LOOP

    BEGIN
      UPDATE crappep
         SET inliquid = 1
           , vlmrapar = 0
           , vlsdvpar = 0
           , vlsdvatu = 0
           , vlsdvsji = 0
           , vljura60 = 0
           , vlmtapar = 0
           , vlpagpar = vlparepr
       WHERE cdcooper = rw_parcelas.cdcooper
         AND nrdconta = rw_parcelas.nrdconta
         AND nrctremp = rw_parcelas.nrctremp
         AND nrparepr = rw_parcelas.nrparepr;
    EXCEPTION
     WHEN OTHERS THEN
       gene0002.pc_escreve_xml(vr_des_log, vr_texto_completo, 'ERRO CRAPPEP: ' || rw_parcelas.cdcooper || ', ' || rw_parcelas.nrdconta || ', ' || rw_parcelas.nrctremp || ', ' || rw_parcelas.nrparepr || '. '  || SQLERRM || chr(10));
       CONTINUE;
    END;

    GENE0002.pc_escreve_xml(vr_des_log, vr_texto_completo, rw_parcelas.cdcooper || ';' || 
                                                           rw_parcelas.nrdconta || ';' ||
                                                           rw_parcelas.nrctremp || ';' ||
                                                           rw_parcelas.nrparepr || ';' ||
                                                           to_char(rw_parcelas.vlsdvpar
                                                                  ,'999999990D90'
                                                                  ,'NLS_NUMERIC_CHARACTERS = '',.''') || ';' ||
                                                           to_char(rw_parcelas.vlsprojt
                                                                  ,'999999990D90'
                                                                  ,'NLS_NUMERIC_CHARACTERS = '',.''') || ';' ||
                                                           to_char(rw_parcelas.vlsdeved
                                                                  ,'999999990D90'
                                                                  ,'NLS_NUMERIC_CHARACTERS = '',.''') || 
                                                           chr(10));
  END LOOP;
  
  GENE0002.pc_escreve_xml(vr_des_log, vr_texto_completo, ' ' || chr(10),TRUE);
  DBMS_XSLPROCESSOR.CLOB2FILE(vr_des_log, vr_dsdireto, 'pos_parcela_liquidada_' || to_char(SYSDATE,'ddmmrrrr') || '.csv', NLS_CHARSET_ID('UTF8'));
          
  dbms_lob.close(vr_des_log);
  dbms_lob.freetemporary(vr_des_log);

  COMMIT;
  dbms_output.put_line('Sucesso!');
END;
