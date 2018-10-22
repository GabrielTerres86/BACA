CREATE OR REPLACE PACKAGE CECRED.PCPS0003 IS
  /* ---------------------------------------------------------------------------------------------------------------
  
      Programa : PCPS0003
      Sistema  : Rotinas referentes a PLATAFORMA CENTRALIZADA DE PORTABILIDADE DE SALÁRIO
      Sigla    : PCPS
      Autor    : Renato Darosci - Supero
      Data     : Setembro/2018.
  
      Dados referentes ao programa:
  
      Frequencia: -----
      Objetivo  : Rotinas genericas utilizadas na plataforma de portabilidade de salário
  ---------------------------------------------------------------------------------------------------------------*/

  PROCEDURE setkey(p_key IN VARCHAR2);
  
  PROCEDURE encrypt(p_data        IN CLOB
                   ,pr_dscritic  OUT VARCHAR2);
                   
  PROCEDURE decrypt(pr_dscritic  OUT VARCHAR2) ;

END PCPS0003;
/
CREATE OR REPLACE PACKAGE BODY CECRED.PCPS0003 IS
  /* ---------------------------------------------------------------------------------------------------------------
  
      Programa : PCPS0003
      Sistema  : Rotinas referentes a PLATAFORMA CENTRALIZADA DE PORTABILIDADE DE SALÁRIO
      Sigla    : PCPS
      Autor    : Renato Darosci - Supero
      Data     : Setembro/2018.
  
      Dados referentes ao programa:
  
      Frequencia: -----
      Objetivo  : Rotinas para criptografia utilizadas na plataforma de portabilidade de salário
  
      Alteracoes:
  
  ---------------------------------------------------------------------------------------------------------------*/

  ecryption_type CONSTANT PLS_INTEGER := SYS.DBMS_CRYPTO.DES3_CBC_PKCS5;
  --SYS.DBMS_CRYPTO.ENCRYPT_3DES + SYS.DBMS_CRYPTO.CHAIN_CBC + SYS.DBMS_CRYPTO.PAD_PKCS5;
  v_key          RAW(32000) := UTL_RAW.CAST_TO_RAW('4e5bf06417b0686a557ceaba8501c30c');

  PROCEDURE setkey(p_key IN VARCHAR2) IS
  BEGIN
    IF p_key IS NOT NULL THEN
      v_key := UTL_RAW.cast_to_raw(p_key);
      dbms_output.put_line(v_key);
    END IF;
  END setkey;

  FUNCTION c2b(c IN CLOB) RETURN BLOB
  -- typecasts CLOB to BLOB (binary conversion)
   IS
    pos     PLS_INTEGER := 1;
    buffer  RAW(32767);
    res     BLOB;
    lob_len PLS_INTEGER := DBMS_LOB.getLength(c);
  BEGIN
    DBMS_LOB.createTemporary(res, TRUE);
    DBMS_LOB.OPEN(res, DBMS_LOB.LOB_ReadWrite);

    LOOP
      buffer := UTL_RAW.cast_to_raw(DBMS_LOB.SUBSTR(c, 16000, pos));
    
      IF UTL_RAW.LENGTH(buffer) > 0 THEN
        DBMS_LOB.writeAppend(res, UTL_RAW.LENGTH(buffer), buffer);
      END IF;
    
      pos := pos + 16000;
      EXIT WHEN pos > lob_len;
    END LOOP;

    RETURN res; -- res is OPEN here
  END c2b;

  PROCEDURE encrypt(p_data        IN CLOB
                   ,pr_dscritic  OUT VARCHAR2)  IS

    --l_data      RAW(2048) := UTL_I18N.STRING_TO_RAW(p_data, 'AL32UTF8');
    l_encrypted BLOB := c2b(p_data);
    vr_dscritic VARCHAR2(1000);
    vr_exc_erro EXCEPTION;
    
  BEGIN

    -- Criptografar o volume do arquivo
    DBMS_CRYPTO.ENCRYPT(dst    => l_encrypted
                       ,src    => p_data
                       ,typ    => ecryption_type
                       ,key    => v_key);  
  
    -- Gravar o blob em um arquivo
    gene0002.pc_blob_para_arquivo(pr_blob    => l_encrypted
                                 ,pr_caminho => '/microsd/cecred/Renato'
                                 ,pr_arquivo => 'testeCripyo.txt'
                                 ,pr_des_erro => vr_dscritic);
    
    -- Se retornar erro
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- for the security reason I want to completely silence the error 
      -- stack that could reveal some technical details to imaginary attacker.
      -- Remember, such miss-use of WHEN OTHERS should be considered 
      -- as a bug in almost all other situations.
      pr_dscritic := 'Erro na rotina encrypt: '||SQLERRM;
  END encrypt;

  
  PROCEDURE decrypt(pr_dscritic  OUT VARCHAR2)  IS

    vr_blarquiv BLOB;
    vr_dsxmlarq CLOB;
    vr_dscritic VARCHAR2(1000);
    vr_exc_erro EXCEPTION;
    
  BEGIN

    -- blob do arquivo
    vr_blarquiv := gene0002.fn_arq_para_blob(pr_caminho => '/microsd/cecred/Renato'
                                            ,pr_arquivo => 'ASLC022_05463212_20171113_00008');
       
    -- Se retornar erro
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    dbms_lob.createtemporary(lob_loc => vr_dsxmlarq
                            ,cache   => TRUE);
    
        
    SYS.DBMS_CRYPTO.DECRYPT(dst => vr_dsxmlarq
                           ,src => vr_blarquiv
                           ,typ => ecryption_type
                           ,key => v_key);
    
    dbms_output.put_line(vr_dsxmlarq);

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- for the security reason I want to completely silence the error 
      -- stack that could reveal some technical details to imaginary attacker.
      -- Remember, such miss-use of WHEN OTHERS should be considered 
      -- as a bug in almost all other situations.
      pr_dscritic := 'Erro na rotina decrypt: '||SQLERRM;
  END decrypt;



END PCPS0003;
/
