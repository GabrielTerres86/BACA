PL/SQL Developer Test script 3.0
239
  /********************************************************************************************************
                 Script para gerar os registros na crapchd, dos cheques devolvidos automaticamente.
                 
   - O arquivo dos registros gerados será gravado em: \\pkgprod\micros\cpd\bacas\INC0032364
                
   
  ********************************************************************************************************/
DECLARE 

    vr_nmdireto          VARCHAR2(100) := '/micros/cpd/bacas/INC0032364/';

    vr_nrdconta          craprda.nrdconta%TYPE;
    vr_cdcooper          crapcop.cdcooper%TYPE;
    vr_nraplica          craprda.nraplica%TYPE;
    vr_contador          NUMBER;
        
    vr_arq_path          VARCHAR2(1000);        --> Diretorio que sera criado o relatorio       
    vr_des_xml           CLOB;
    vr_texto_completo    VARCHAR2(32600);        
    vr_comando           VARCHAR(200);
  
    vr_nrddigv1          crapchd.nrddigv1%TYPE;
    vr_nrddigv2          crapchd.nrddigv2%TYPE;
    vr_nrddigv3          crapchd.nrddigv3%TYPE;
    
    vr_rowidchd          ROWID;
    vr_dstextab          craptab.dstextab%TYPE;
    vr_dstextab2         craptab.dstextab%TYPE;
    tab_vlchqmai         NUMBER;
    tab_incrdcta         pls_integer;
    tab_intracst         pls_integer; 
    tab_inchqcop         pls_integer; 
    vr_temcdb            pls_integer;
  
    vr_inserir           BOOLEAN;
    vr_nrdcampo          NUMBER;
    vr_lsdigctr          VARCHAR2(2000);
    aux_tpdmovto         crapchd.tpdmovto%TYPE;
 
    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
    END;
    
  BEGIN
    -- Iniciar Variáveis     
    vr_arq_path := vr_nmdireto; 

    -- Inicializar o CLOB
    vr_des_xml := NULL;
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
    vr_texto_completo := NULL;
    
    vr_cdcooper := 0;
    vr_nrdconta := 0;
  
    -- Laco para leitura de linhas do arquivo
    FOR rw_crapcst IN (SELECT * FROM CRAPCST a
                        WHERE insitchq = 3
                        AND NOT EXISTS (SELECT 1 FROM crapchd b
                                WHERE a.cdcmpchq = b.cdcmpchq
                                  AND a.cdbanchq = b.cdbanchq
                                  AND a.nrctachq = b.nrctachq
                                  AND a.nrcheque = b.nrcheque
                                  AND a.vlcheque = b.vlcheque)
                        AND dtlibera >= '16/01/2019'
                        order by cdcooper) LOOP 
            
       vr_nrdconta := rw_crapcst.nrdconta;
       IF vr_cdcooper <> rw_crapcst.cdcooper THEN
         vr_cdcooper := rw_crapcst.cdcooper;
         vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => vr_cdcooper
                 ,pr_nmsistem => 'CRED'
                 ,pr_tptabela => 'USUARI'
                 ,pr_cdempres => 11
                 ,pr_cdacesso => 'MAIORESCHQ'
                 ,pr_tpregist => 001);
        tab_vlchqmai := to_number(SUBSTR(vr_dstextab,1,15));
       END IF;
        
       vr_inserir := TRUE;
       IF rw_crapcst.nrborder <> 0 THEN
            /*Se estiver em um bordero de descto efetivado nao 
              considerar para a custodia*/
          BEGIN 
            SELECT 1
              INTO  vr_temcdb
              FROM  crapcdb
              WHERE crapcdb.cdcooper = rw_crapcst.cdcooper
                AND crapcdb.nrdconta = rw_crapcst.nrdconta
                AND crapcdb.dtlibera = rw_crapcst.dtlibera
                AND crapcdb.dtlibbdc IS NOT NULL
                AND crapcdb.cdcmpchq = rw_crapcst.cdcmpchq
                AND crapcdb.cdbanchq = rw_crapcst.cdbanchq
                AND crapcdb.cdagechq = rw_crapcst.cdagechq
                AND crapcdb.nrctachq = rw_crapcst.nrctachq
                AND crapcdb.nrcheque = rw_crapcst.nrcheque
                AND crapcdb.dtdevolu IS NULL  
                AND crapcdb.nrborder = rw_crapcst.nrborder;
            
          vr_inserir := FALSE;  
            EXCEPTION
         WHEN NO_DATA_FOUND THEN
           NULL;
            END;    
      END IF;   

      vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => vr_cdcooper
                 ,pr_nmsistem => 'CRED'
                 ,pr_tptabela => 'CUSTOD'
                 ,pr_cdempres => 00
                 ,pr_cdacesso => to_char(rw_crapcst.nrdconta)
                 ,pr_tpregist => 0);

      IF vr_dstextab IS NULL   THEN
         tab_incrdcta := 1;
         tab_intracst := 1;            /*  Tratamento comp. CREDIHERING  */
         tab_inchqcop := 1;
      ELSE
         tab_incrdcta := TO_NUMBER(SUBSTR(vr_dstextab,05,01));
         tab_intracst := TO_NUMBER(SUBSTR(vr_dstextab,07,01));
         tab_inchqcop := TO_NUMBER(SUBSTR(vr_dstextab,09,01));
      END IF;   

      IF rw_crapcst.inchqcop = 1   THEN            /*  Cheque CREDIHERING  */
        IF tab_incrdcta = 2   THEN           /*  Nao Credita em CC  */
          IF tab_intracst = 2   THEN      /*  Comp. Terceiros  */
             IF tab_inchqcop = 1   THEN /*  Nao trata chq CREDIHERING */
              vr_inserir := FALSE; 
             END IF;
          ELSE
            vr_inserir := FALSE; 
          END IF; 
        END IF;   
      END IF;       
   
   
      if vr_inserir then
     
        cheq0001.pc_dig_cmc7(rw_crapcst.dsdocmc7, vr_nrdcampo, vr_lsdigctr);  
         vr_nrddigv1 := TO_NUMBER(TO_CHAR(gene0002.fn_busca_entrada(1,vr_lsdigctr,',')));   
         vr_nrddigv2 := TO_NUMBER(TO_CHAR(gene0002.fn_busca_entrada(2,vr_lsdigctr,','))); 
         vr_nrddigv3 := TO_NUMBER(TO_CHAR(gene0002.fn_busca_entrada(3,vr_lsdigctr,','))); 
       
         IF   tab_vlchqmai <= rw_crapcst.vlcheque THEN
           aux_tpdmovto := 1;
        ELSE        
           aux_tpdmovto := 2;
        END IF;  
        
      
     INSERT INTO crapchd (cdagechq, 
              cdagenci, 
              cdbanchq, 
              cdbccxlt, 
              cdcmpchq, 
              cdoperad, 
              cdsitatu, 
              dsdocmc7,
              dtmvtolt, 
              inchqcop, 
              cdcooper, 
              insitchq, 
              nrcheque, 
              nrctachq, 
              nrdconta, 
              nrddigc1,
              nrddigc2, 
              nrddigc3, 
              nrddigv1, 
              nrddigv2, 
              nrddigv3, 
              nrdocmto, 
              nrdolote, 
              nrseqdig,
              nrterfin, 
              cdtipchq, 
              tpdmovto, 
              vlcheque, 
              insitprv)
            VALUES
               (rw_crapcst.cdagechq,
                1,
                rw_crapcst.cdbanchq,
                rw_crapcst.cdbccxlt,
                rw_crapcst.cdcmpchq,
                rw_crapcst.cdoperad,
                1,
                rw_crapcst.dsdocmc7,
                gene0005.fn_valida_dia_util(rw_crapcst.cdcooper, rw_crapcst.dtlibera),
                rw_crapcst.inchqcop,
                rw_crapcst.cdcooper,
                decode(tab_intracst, 2, decode(rw_crapcst.inchqcop, 1, decode(tab_inchqcop, 1, rw_crapcst.insitchq,3),3), rw_crapcst.insitchq),
                rw_crapcst.nrcheque,
                decode(rw_crapcst.cdbanchq, 1, SUBSTR(rw_crapcst.dsdocmc7,23,10),rw_crapcst.nrctachq),
                rw_crapcst.nrdconta,
                rw_crapcst.nrddigc1,
                rw_crapcst.nrddigc2,
                rw_crapcst.nrddigc3,
                vr_nrddigv1,
                vr_nrddigv2,
                vr_nrddigv3,
                rw_crapcst.nrdocmto, 
                999999, 
                rw_crapcst.nrseqdig,
                0, 
                TO_NUMBER(SUBSTR(rw_crapcst.dsdocmc7,20,1)), 
                aux_tpdmovto, 
                rw_crapcst.vlcheque, 
                rw_crapcst.insitprv) RETURNING ROWID INTO vr_rowidchd; 
                    
      vr_comando := 'DELETE crapchd where rowid = ''' || vr_rowidchd || ''';'; 
      
      pc_escreve_xml(vr_comando || chr(10));
    end if;

     -- exit;
    END LOOP; -- Loop Arquivo
    
    pc_escreve_xml(' ',TRUE);
    DBMS_XSLPROCESSOR.CLOB2FILE(vr_des_xml, vr_arq_path, 'Rollback_crapchd_'||to_char(sysdate,'ddmmyyyy_hh24miss')|| '.txt', NLS_CHARSET_ID('UTF8'));
    
    -- Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_des_xml);
    dbms_lob.freetemporary(vr_des_xml);
    
    COMMIT ;
    
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      dbms_output.put_line('Erro ao executar script. nrdconta: ' || vr_nrdconta ||
                          ' cdcooper: ' || vr_cdcooper ||
                          ' Erro: ' || SQLERRM);
                               
  END;
0
0
