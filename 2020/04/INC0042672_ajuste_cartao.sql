BEGIN
  /*
    INCLUSÃO DE CARTÃO PARA COOPERADO
    
  */
  
  BEGIN
    DECLARE

      VR_NRCTRCRD    CRAWCRD.NRCTRCRD%TYPE := CECRED.FN_SEQUENCE('CRAPMAT', 'NRCTRCRD', 1);
      VR_NRSEQCRD    CRAWCRD.NRSEQCRD%TYPE := CECRED.CCRD0003.fn_sequence_nrseqcrd(1);
      
      VR_MSG         VARCHAR2(1000);
      ERRO           EXCEPTION;

    BEGIN
      
      BEGIN
        UPDATE CRAWCRD CRD
           SET CRD.INSITCRD = 6, -- CANCELADO
               CRD.DTCANCEL = TRUNC(SYSDATE),
               CRD.NRCCTITG = 7563239211092
         WHERE CRD.CDCOOPER = 1
           AND CRD.NRDCONTA = 7204922
           AND CRD.NRCTRCRD = 1359855;
      EXCEPTION
        WHEN OTHERS THEN
          VR_MSG := 'ERRO NA ALTERAÇÃO DA TABELA CRAWCRD => '||SQLERRM;
          RAISE ERRO;
      END;
      
      BEGIN
        INSERT INTO crawcrd
          (nrdconta,
           nrcrcard,
           nrcctitg,
           nrcpftit,
           cdoperad,
           insitcrd,
           nmempcrd,
           vllimcrd,
           flgctitg,
           dtmvtolt,
           nmextttl,
           flgprcrd,
           tpdpagto,
           flgdebcc,
           tpenvcrd,
           vlsalari,
           dddebito,
           cdlimcrd,
           tpcartao,
           dtnasccr,
           nrdoccrd,
           nmtitcrd,
           nrctrcrd,
           cdadmcrd,
           cdcooper,
           nrseqcrd,
           dtpropos,
           dtsolici,
           flgdebit)
        VALUES
          (7204922,
           6393500108081192,
           7563239211092,
           7067228921,
           '1',
           4,
           'BR TRANSPORTES LTDA ME',
           0,
           3,
           SYSDATE,
           'RAFAEL SGARIA',
           1,
           1,
           1,
           0,
           1,
           0,
           0,
           2,
           '06/11/1990',
           51881179,
           'RAFAEL SGARIA',
           VR_NRCTRCRD,
           17,
           1,
           VR_NRSEQCRD,
           TRUNC(SYSDATE),
           TRUNC(SYSDATE),
           1);
      EXCEPTION
        WHEN OTHERS THEN
          VR_MSG := 'ERRO NA INCLUSÃO DA TABELA CRAWCRD => '||SQLERRM;
          RAISE ERRO;
      END;
      
      BEGIN
        INSERT INTO crapcrd
          (cdcooper,
           nrdconta,
           nrcrcard,
           nrcpftit,
           nmtitcrd,
           dddebito,
           cdlimcrd,
           dtvalida,
           nrctrcrd,
           cdmotivo,
           nrprotoc,
           cdadmcrd,
           tpcartao,
           flgdebit,
           flgprovi)
        VALUES
          (1,
           7204922,
           6393500108081192,
           7067228921,
           'RAFAEL SGARIA',
           32,
           0,
           '30/11/2024',
           VR_NRCTRCRD,
           0,
           0,
           17,
           2,
           1,
           0);
      EXCEPTION
        WHEN OTHERS THEN
          VR_MSG := 'ERRO NA INCLUSÃO DA TABELA CRAPCRD => '||SQLERRM;
          RAISE ERRO;
      END;
      
      DBMS_OUTPUT.PUT_LINE('SCRIPT EXECUTADO COM SUCESSO !!!');
      
      COMMIT;

    EXCEPTION
      WHEN ERRO THEN
        DBMS_OUTPUT.PUT_LINE(VR_MSG);
      WHEN OTHERS THEN
       DBMS_OUTPUT.PUT_LINE('ERRO NA EXECUÇÃO DO SCRIPT => '||SQLERRM);
    END;
    
  END;
END;
