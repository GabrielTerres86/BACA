-- Script gerador de borderos com emitentes unicos

DECLARE
  vr_aux_coop crapcop.cdcooper%TYPE := 1; --Viacredi
  vr_aux_nremit VARCHAR2(200) := '120|50|20|10'; -- Numero de emitentes unicos por bordero
  
  vr_vlcheque NUMBER;
  vr_dtlibera DATE; --Data boa
  vr_dscheque VARCHAR2(200);
  vr_nrborder crapbdc.nrborder%TYPE;
  vr_nrdolote crapbdc.nrdolote%TYPE;
  vr_tab_cheq dscc0001.typ_tab_cheques;
  vr_aux_chqemit gene0002.typ_split;
  
  -- Contadores
  vr_contador INTEGER;
  vr_contcheq INTEGER;
  vr_contcheqbom INTEGER;
  vr_indexemit INTEGER;
  vr_idx1 INTEGER;
  vr_idx2 INTEGER;
 
  vr_tab_custodia_erro   cust0001.typ_erro_custodia;
  vr_tab_cheque_custodia cust0001.typ_cheque_custodia;

  -- Vetor para armazenar as chaves do emitente e evitar duplicidade
  TYPE typ_reg_hash_emit IS TABLE OF PLS_INTEGER INDEX BY VARCHAR2(1000);
  vr_tab_hash_emit  typ_reg_hash_emit;
  vr_hash_emit VARCHAR2(1000);
  vr_idx_emite PLS_INTEGER;
  
  vr_tab_cheques  dscc0001.typ_tab_cheques;
  vr_index_cheque NUMBER;
  
  -- Numero Remessa/Retorno
  vr_nrremret craphcc.nrremret%TYPE;
  
   -- Variável de críticas
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic crapcri.dscritic%TYPE;
  vr_exc_erro EXCEPTION; 


  -- 10 contas com maior valor disponivel para contratar bordero de cheque
  CURSOR cr_craplim(pr_cdcooper IN craplim.cdcooper%TYPE) IS      
        SELECT cdcooper
              ,nrdconta
              ,vllimite
              ,vlutiliz
              ,disponivel
              ,dtmvtolt
          FROM (SELECT a.cdcooper
                      ,a.nrdconta
                      ,a.vllimite
                      ,a.vlutiliz
                      ,(a.vllimite - a.vlutiliz) disponivel
                      ,a.dtmvtolt
                  FROM (SELECT lim.cdcooper
                              ,lim.nrdconta
                              ,lim.vllimite
                              ,(SELECT NVL(SUM(cdb.vlcheque),0)
                                  FROM crapcdb cdb
                                 WHERE cdb.cdcooper = lim.cdcooper
                                   AND cdb.nrdconta = lim.nrdconta
                                   AND cdb.insitchq = 2
                                   AND cdb.dtlibera > dat.dtmvtolt) AS vlutiliz
                               ,dat.dtmvtolt    
                          FROM craplim lim,
                               crapdat dat
                         WHERE lim.cdcooper = dat.cdcooper
                           AND lim.cdcooper = pr_cdcooper
                           AND lim.tpctrlim = 2
                           AND lim.insitlim = 2
                           AND lim.insitblq = 0
                           AND lim.vllimite >= 200000
                           AND lim.dtfimvig > dat.dtmvtolt) a
                 ORDER BY disponivel DESC)
         WHERE ROWNUM <= 10;
    
  
  
       CURSOR cr_crapcdb(pr_cdcooper IN craplim.cdcooper%TYPE) IS 
         SELECT tmp.dsdocmc7
               ,tmp.nrcpfcgc
           FROM (SELECT cst.dsdocmc7
                       ,cec.nrcpfcgc
                       ,ROW_NUMBER() OVER(PARTITION BY cec.nrcpfcgc ORDER BY cec.nrcpfcgc) AS nrseq
                       ,COUNT(1) OVER(PARTITION BY cec.nrcpfcgc) AS qtreg
                   FROM crapcst cst
                       ,crapcec cec
                       ,crapcop cop
                  WHERE cec.cdcooper = cst.cdcooper
                    AND cec.cdcmpchq = cst.cdcmpchq
                    AND cec.cdbanchq = cst.cdbanchq
                    AND cec.cdagechq = cst.cdagechq
                    AND cec.nrctachq = cst.nrctachq
                    AND cst.cdcooper = cop.cdcooper
                    AND cst.dtmvtolt >= '01/01/2021'
                    AND cop.flgativo = 1
                    AND cop.cdcooper = 16
                    AND NOT EXISTS (SELECT 1
                           FROM crapcdb cdb
                          WHERE cdb.cdcooper = 1
                            AND cdb.cdcmpchq = cst.cdcmpchq
                            AND cdb.cdbanchq = cst.cdbanchq
                            AND cdb.cdagechq = cst.cdagechq
                            AND cdb.nrctachq = cst.nrctachq
                            AND cdb.nrcheque = cst.nrcheque)
                  ORDER BY cec.nrcpfcgc) tmp
          WHERE tmp.nrseq = 1;
              
   
  --Buscar cheques validos de outras cooperativas que nao estao custodiados 
  /*CURSOR cr_crapcdb(pr_cdcooper IN craplim.cdcooper%TYPE) IS          
        SELECT a.dsdocmc7
              ,a.nrcpfcgc
          FROM crapcdb a
              ,crapcec c -- Cadastro de emitentes de cheques
              ,crapcop b
         WHERE c.cdcooper = a.cdcooper
           AND c.cdcmpchq = a.cdcmpchq
           AND c.cdbanchq = a.cdbanchq
           AND c.cdagechq = a.cdagechq
           AND c.nrctachq = a.nrctachq
           AND c.nrcpfcgc = a.nrcpfcgc 
           AND b.cdcooper = a.cdcooper
           AND b.flgativo = 1 
           AND a.insitchq = 0
           AND a.insitana = 0
           AND a.cdcooper <> pr_cdcooper
           AND NOT EXISTS (SELECT 1
                            FROM crapcst crapcst
                           WHERE crapcst.cdcmpchq = a.cdcmpchq
                             AND crapcst.cdbanchq = a.cdbanchq
                             AND crapcst.cdagechq = a.cdagechq
                             AND crapcst.nrctachq = a.nrctachq
                             AND crapcst.nrcheque = a.nrcheque
                             AND crapcst.dtdevolu IS NULL)
           AND NOT EXISTS(SELECT 1
                           FROM crapcdb b
                           WHERE b.cdcooper = pr_cdcooper 
                             AND b.cdcmpchq = a.cdcmpchq
                             AND b.cdbanchq = a.cdbanchq
                             AND b.cdagechq = a.cdagechq
                             AND b.nrctachq = a.nrctachq
                             AND b.nrcheque = a.nrcheque)
            ORDER BY a.nrcpfcgc;*/
            
          
    --Buscar dados do novo bordero
    CURSOR cr_crapbdc(pr_cdcooper IN crapbdc.cdcooper%TYPE,
                      pr_nrdconta IN crapbdc.nrdconta%TYPE,
                      pr_nrborder IN crapbdc.nrborder%TYPE) IS       
      SELECT bdc.cdagenci
        FROM crapbdc bdc
       WHERE bdc.cdcooper = pr_cdcooper
         AND bdc.nrdconta = pr_nrdconta
         AND bdc.nrborder = pr_nrborder;
      rw_crapbdc cr_crapbdc%ROWTYPE; 
      
      
    --Buscar emitente
    CURSOR cr_crapcec(pr_cdcooper crapcec.cdcooper%TYPE
                     ,pr_cdcmpchq crapcec.cdcmpchq%TYPE
                     ,pr_cdbanchq crapcec.cdbanchq%TYPE
                     ,pr_cdagechq crapcec.cdagechq%TYPE
                     ,pr_nrctachq crapcec.nrctachq%TYPE
                     ,pr_nrcpfcgc crapcec.nrcpfcgc%TYPE) IS
      SELECT cec.nmcheque
            ,cec.nrcpfcgc
        FROM crapcec cec
       WHERE cec.cdcooper = pr_cdcooper
         AND cec.cdcmpchq = pr_cdcmpchq
         AND cec.cdbanchq = pr_cdbanchq
         AND cec.cdagechq = pr_cdagechq
         AND cec.nrctachq = pr_nrctachq
         AND cec.nrcpfcgc = pr_nrcpfcgc;
    rw_crapcec cr_crapcec%ROWTYPE;
   
  
    -- Header do Arquivo de Custódia de Cheques
    CURSOR cr_craphcc(pr_cdcooper IN craphcc.cdcooper%TYPE     --> Código da cooperativa
                     ,pr_nrdconta IN craphcc.nrdconta%TYPE) IS --> Numero da Conta
        SELECT NVL(MAX(nrremret),0) nrremret
          FROM craphcc
         WHERE craphcc.cdcooper = pr_cdcooper 
           AND craphcc.nrdconta = pr_nrdconta
           AND craphcc.nrconven = 1 -- Fixo
           AND craphcc.intipmvt = 3 -- Manual
         ORDER BY craphcc.cdcooper,
                  craphcc.nrdconta,
                  craphcc.nrconven,
                  craphcc.intipmvt;              
      rw_craphcc cr_craphcc%ROWTYPE;   
      
  -- Procedure para gerar borderos
  PROCEDURE pc_gerador_borderos(pr_cdcooper  IN crapcop.cdcooper%TYPE, --Cooperativa
                                pr_ttlemite  IN NUMBER,                --Numero de emitentes unicos que deve add no bordero
                                pr_ordemloop IN NUMBER)IS              --Ordem do contador no loop de maiores limites, quanto menor o numero maior o limite disponivel                               

    BEGIN 
       vr_contador := 0;
       vr_contcheq := 0;
       vr_contcheqbom := 0;
 
       FOR rw_craplim IN cr_craplim (pr_cdcooper => pr_cdcooper) LOOP      
        vr_contador := NVL(vr_contador,0) + 1;
        vr_dtlibera := (to_date(rw_craplim.dtmvtolt, 'dd/mm/rrrr') + 30); --Data boa 
        

        -- Utilizar um loop especifico, quanto menor o valor(pr_ordemloop) maior o limite disponivel
        IF vr_contador = pr_ordemloop THEN 
          
           -- Adicionar bordero
           dscc0001.pc_criar_bordero_cheques(pr_cdcooper => rw_craplim.cdcooper,
                                             pr_nrdconta => rw_craplim.nrdconta,
                                             pr_cdagenci => 0,
                                             pr_idorigem => 5,
                                             pr_cdoperad => 1,
                                             pr_nrdolote => vr_nrdolote,
                                             pr_nrborder => vr_nrborder,
                                             pr_cdcritic => vr_cdcritic,
                                             pr_dscritic => vr_dscritic);                       
          IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;          
          --dbms_output.put_line(' Conta: ' || rw_craplim.nrdconta || ' - Bordero criado: ' || vr_nrborder);   
          
          OPEN cr_craphcc(pr_cdcooper => rw_craplim.cdcooper
                         ,pr_nrdconta => rw_craplim.nrdconta);
          FETCH cr_craphcc INTO rw_craphcc;

          -- Verifica se a retornou registro
          IF cr_craphcc%NOTFOUND THEN
            -- Numero de Retorno
            vr_nrremret := 1; 
          ELSE
             vr_nrremret := rw_craphcc.nrremret + 1;
          END IF;
          -- Fechar cursor
          CLOSE cr_craphcc;
                                  
              
          
          -- Buscar cheques validos 
          FOR rw_crapcdb IN cr_crapcdb (pr_cdcooper => pr_cdcooper) LOOP
              vr_contcheq := NVL(vr_contcheq,0) + 1;
              vr_vlcheque := to_char(ROUND(DBMS_RANDOM.VALUE(10,100)),'fm99999g999g990d00','NLS_NUMERIC_CHARACTERS='',.'''); --Gerar valor randomico para o cheque
              

               -- Cria uma chave para evitar de repetir o emitente
               vr_hash_emit := to_char(rw_crapcdb.nrcpfcgc || '-' || pr_ordemloop);
                   
               -- Se nao encontrar uma chave igual
               IF NOT vr_tab_hash_emit.exists(vr_hash_emit) THEN 
                  vr_tab_hash_emit(vr_hash_emit) := vr_contcheq;
                  --vr_idx_emite := vr_contcheq;


                  -- Montar dscheque  
                  vr_dscheque := vr_dtlibera || ';' || --Data boa
                                 (to_date(rw_craplim.dtmvtolt, 'dd/mm/rrrr') - 10) || ';' || -- Data emissao
                                 vr_vlcheque || ';' || -- Valor do cheque
                                 REPLACE(REPLACE(REPLACE(rw_crapcdb.dsdocmc7, '>', ''), '<', ''),':','');

                  -- Valida custódia
                  cust0001.pc_valida_custodia_manual(pr_cdcooper => pr_cdcooper                  --> Cooperativa
                                                    ,pr_nrdconta => rw_craplim.nrdconta          --> Número da conta
                                                    ,pr_dscheque => vr_dscheque                  --> Codigo do Indexador 
                                                    ,pr_tab_cust_cheq => vr_tab_cheque_custodia  --> Tabela com cheques para custódia
                                                    ,pr_tab_erro_cust => vr_tab_custodia_erro    --> Tabela de cheques com erros
                                                    ,pr_cdcritic => vr_cdcritic                  --> Código da crítica
                                                    ,pr_dscritic => vr_dscritic);                --> Descrição da crítica 
                  -- Se teve críticas pc_valida_custodia_manual
                  IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL OR vr_tab_custodia_erro.count > 0 THEN
                     IF vr_tab_custodia_erro.count > 0 THEN
                        vr_dscritic := 'Cheque ' || vr_tab_custodia_erro(vr_tab_custodia_erro.first).dsdocmc7 || 
                                       ' apresentou erro. Erro: ' || vr_tab_custodia_erro(vr_tab_custodia_erro.first).dscritic;
                     END IF;
                     --dbms_output.put_line(vr_dscritic);
                  ELSE 
                      
                        FOR vr_idx1 IN vr_tab_cheque_custodia.first .. vr_tab_cheque_custodia.last LOOP
                            IF vr_tab_cheque_custodia.exists(vr_idx1) THEN

                               vr_contcheqbom := NVL(vr_contcheqbom,0) + 1;
                               IF vr_contcheqbom <= pr_ttlemite THEN
                                  --dbms_output.put_line(vr_contcheqbom || ' - cpf emitente: ' || vr_hash_emit || ' - cmc7: ' || vr_tab_cheque_custodia(vr_idx1).dsdocmc7);
                                  
                                  OPEN cr_crapbdc(pr_cdcooper => pr_cdcooper
                                                 ,pr_nrdconta => rw_craplim.nrdconta
                                                 ,pr_nrborder => vr_nrborder);
                                  FETCH cr_crapbdc INTO rw_crapbdc;
                                  CLOSE cr_crapbdc;
                                  
                                  
                                  BEGIN
                                    INSERT INTO crapdcc
                                      (cdcooper,
                                       nrdconta,
                                       nrconven,
                                       intipmvt,
                                       nrremret,
                                       nrseqarq,
                                       cdtipmvt,
                                       cdfinmvt,
                                       cdentdad,
                                       dsdocmc7,
                                       cdcmpchq,
                                       cdbanchq,
                                       cdagechq,
                                       nrctachq,
                                       nrcheque,
                                       vlcheque,
                                       dtlibera,
                                       cdocorre,
                                       inconcil,
                                       inchqcop,
                                       dtdcaptu,
                                       nrinsemi,
                                       cdtipemi,
                                       nrborder)
                                    VALUES
                                      (pr_cdcooper,
                                       rw_craplim.nrdconta,
                                       1, -- nrconven -> Fixo 1
                                       3, -- intipmvt -> 3 - Retorno
                                       vr_nrremret,
                                       vr_contcheqbom, -- nrseqarq -> Contador
                                       1, -- cdtipmvt -> 1 - Inclusão
                                       1, -- cdfinmvt -> 1 - Custódia Simples,
                                       1, -- cdentdad -> 1 - CMC-7
                                       vr_tab_cheque_custodia(vr_idx1).dsdocmc7,
                                       vr_tab_cheque_custodia(vr_idx1).cdcmpchq,
                                       vr_tab_cheque_custodia(vr_idx1).cdbanchq,
                                       vr_tab_cheque_custodia(vr_idx1).cdagechq,
                                       vr_tab_cheque_custodia(vr_idx1).nrctachq,
                                       vr_tab_cheque_custodia(vr_idx1).nrcheque,
                                       vr_tab_cheque_custodia(vr_idx1).vlcheque,
                                       vr_tab_cheque_custodia(vr_idx1).dtlibera, 
                                       ' ', -- cdocorre-> Vazio, pois não é gerado enquanto possuir erros
                                       0,   -- inconcil -> Fixo 0,
                                       vr_tab_cheque_custodia(vr_idx1).inchqcop,
                                       vr_tab_cheque_custodia(vr_idx1).dtdcaptu,
                                       vr_tab_cheque_custodia(vr_idx1).nrinsemi,
                                       vr_tab_cheque_custodia(vr_idx1).cdtipemi,
                                       vr_nrborder);
                                  EXCEPTION
                                    WHEN OTHERS THEN
                                      vr_cdcritic := 0;
                                      vr_dscritic := 'Erro ao inserir CRAPDCC: '||SQLERRM;
                                      RAISE vr_exc_erro;
                                  END;
                                  
                                  -- Verificar existencia de emitente
                                  OPEN cr_crapcec(pr_cdcooper => pr_cdcooper,
                                                  pr_cdcmpchq => vr_tab_cheque_custodia(vr_idx1).cdcmpchq,
                                                  pr_cdbanchq => vr_tab_cheque_custodia(vr_idx1).cdbanchq,
                                                  pr_cdagechq => vr_tab_cheque_custodia(vr_idx1).cdagechq,
                                                  pr_nrctachq => vr_tab_cheque_custodia(vr_idx1).nrctachq,
                                                  pr_nrcpfcgc => rw_crapcdb.nrcpfcgc);
                                  FETCH cr_crapcec INTO rw_crapcec;
                                
                                  -- Se nao encontrar inclui
                                  IF cr_crapcec%NOTFOUND THEN
                                    BEGIN
                                      INSERT INTO crapcec
                                        (NRCPFCGC
                                        ,NMCHEQUE
                                        ,CDSITEMI
                                        ,QTCHQDEV
                                        ,NRCTACHQ
                                        ,CDAGECHQ
                                        ,CDBANCHQ
                                        ,CDCMPCHQ
                                        ,DTULTDEV
                                        ,NRDCONTA
                                        ,DTABTCCT
                                        ,NMSEGNTL
                                        ,NRCPFSTL
                                        ,NRCPFTTL
                                        ,NMTERCTL
                                        ,CDCOOPER)
                                        (SELECT c.nrcpfcgc
                                               ,c.nmcheque
                                               ,c.cdsitemi
                                               ,c.qtchqdev
                                               ,c.nrctachq
                                               ,c.cdagechq
                                               ,c.cdbanchq
                                               ,c.cdcmpchq
                                               ,c.dtultdev
                                               ,c.nrdconta
                                               ,c.dtabtcct
                                               ,c.nmsegntl
                                               ,c.nrcpfstl
                                               ,c.nrcpfttl
                                               ,c.nmterctl
                                               ,pr_cdcooper
                                           FROM crapcec c
                                          WHERE c.cdcmpchq = vr_tab_cheque_custodia(vr_idx1).cdcmpchq
                                            AND c.cdbanchq = vr_tab_cheque_custodia(vr_idx1).cdbanchq
                                            AND c.cdagechq = vr_tab_cheque_custodia(vr_idx1).cdagechq
                                            AND c.nrctachq = vr_tab_cheque_custodia(vr_idx1).nrctachq
                                            AND c.nrcpfcgc = rw_crapcdb.nrcpfcgc);
                                    EXCEPTION
                                      WHEN OTHERS THEN
                                        CLOSE cr_crapcec;
                                        dbms_output.put_line(vr_contcheqbom || ' - ' ||
                                                             'Erro ao inserir na tabela crapcec. ' ||
                                                             ' - EmitenteCPF: ' || rw_crapcdb.nrcpfcgc ||
                                                             ' - cdcmpchq: ' || vr_tab_cheque_custodia(vr_idx1).cdcmpchq ||
                                                             ' - cdbanchq: ' || vr_tab_cheque_custodia(vr_idx1).cdbanchq ||
                                                             ' - cdagechq: ' || vr_tab_cheque_custodia(vr_idx1).cdagechq ||
                                                             ' - nrctachq: ' || vr_tab_cheque_custodia(vr_idx1).nrctachq ||
                                                             ' - pr_cdcooper: ' || pr_cdcooper || ' - SQLERRM: ' ||
                                                             SQLERRM);
                                        CONTINUE;
                                    END;
                                  END IF;
                                  CLOSE cr_crapcec;
                  
                                    
                                  vr_index_cheque := nvl(vr_index_cheque,0) + 1;
                                  vr_tab_cheques(vr_index_cheque).cdcooper := pr_cdcooper;
                                  vr_tab_cheques(vr_index_cheque).nrdconta := rw_craplim.nrdconta;
                                  vr_tab_cheques(vr_index_cheque).dtlibera := vr_dtlibera;
                                  vr_tab_cheques(vr_index_cheque).dsdocmc7 := vr_tab_cheque_custodia(vr_idx1).dsdocmc7;
                                  vr_tab_cheques(vr_index_cheque).cdcmpchq := vr_tab_cheque_custodia(vr_idx1).cdcmpchq;
                                  vr_tab_cheques(vr_index_cheque).cdbanchq := vr_tab_cheque_custodia(vr_idx1).cdbanchq;
                                  vr_tab_cheques(vr_index_cheque).cdagechq := vr_tab_cheque_custodia(vr_idx1).cdagechq;
                                  vr_tab_cheques(vr_index_cheque).nrctachq := vr_tab_cheque_custodia(vr_idx1).nrctachq;
                                  vr_tab_cheques(vr_index_cheque).nrcheque := vr_tab_cheque_custodia(vr_idx1).nrcheque;
                                  vr_tab_cheques(vr_index_cheque).vlcheque := vr_tab_cheque_custodia(vr_idx1).vlcheque;                              
                                  vr_tab_cheques(vr_index_cheque).cdagenci := rw_crapbdc.cdagenci;
                                  vr_tab_cheques(vr_index_cheque).dtmvtolt := rw_craplim.dtmvtolt;
                                  vr_tab_cheques(vr_index_cheque).dtdcaptu := vr_tab_cheque_custodia(vr_idx1).dtdcaptu;
                                  vr_tab_cheques(vr_index_cheque).nrcpfcgc := rw_crapcdb.nrcpfcgc;                        
                               END IF;
                            END IF;  
                        END LOOP;
                     
                  END IF; -- Fecha Se teve críticas pc_valida_custodia_manual 
              
               END IF;-- Fecha Se nao encontrar uma chave igual
              
          END LOOP; -- Fecha Buscar cheques validos 
          
          --dbms_output.put_line(': ####################################################');

          -- Adicionar cheques ao bordero
          DSCC0001.pc_adicionar_cheques_bordero(pr_cdcooper => rw_craplim.cdcooper
                                               ,pr_nrdconta => rw_craplim.nrdconta
                                               ,pr_cdagenci => 0
                                               ,pr_idorigem => 5
                                               ,pr_cdoperad => 1
                                               ,pr_nrborder => vr_nrborder
                                               ,pr_nrdolote => vr_nrdolote
                                               ,pr_tab_cheques => vr_tab_cheques
                                               ,pr_cdcritic => vr_cdcritic
                                               ,pr_dscritic => vr_dscritic);
          -- Se houve críticas                           
          IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF; 
          
          --Limpar tab para o proximo loop
          vr_tab_cheques.DELETE; 

        END IF; -- Fecha Utilizar um loop especifico
        
    END LOOP;
  END pc_gerador_borderos;        
                               
BEGIN

    vr_aux_chqemit := gene0002.fn_quebra_string(vr_aux_nremit,'|');
     
    FOR vr_indexemit IN 1..vr_aux_chqemit.COUNT LOOP
        pc_gerador_borderos(pr_cdcooper  => vr_aux_coop                  --> Cooperativa
                           ,pr_ttlemite  => vr_aux_chqemit(vr_indexemit) --> Numero de emitentes unicos que deve add no bordero
                           ,pr_ordemloop => vr_indexemit);               --> Numero do loop a buscar     
    END LOOP;
    
    COMMIT;
EXCEPTION
    WHEN vr_exc_erro THEN
    dbms_output.put_line('Erro: ' || vr_dscritic);
    ROLLBACK;  
  WHEN OTHERS THEN
    dbms_output.put_line('Erro geral: ' || ' SQLERRM: ' || SQLERRM);
    ROLLBACK;
END;
