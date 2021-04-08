PL/SQL Developer Test script 3.0
506
DECLARE
    -- Cursores
    CURSOR cr_craprac IS
        SELECT rac.cdcooper
              ,rac.nrdconta
              ,rac.nraplica
              ,rac.dtmvtolt
              ,rac.idblqrgt
              ,rac.txaplica
              ,rac.qtdiacar
              ,rac.vlbasapl
              ,rac.vlsldatl
              ,rac.dtatlsld
              ,rac.qtdiaapl
              ,rac.qtdiaprz
              ,rac.dtaniver
              ,rac.vlaplica
              ,rac.vlsldant
              --,rac.rowid
              ,cpc.cdprodut
              ,cpc.idtippro
              ,cpc.cdhsprap
              ,cpc.cdhsrvap
              ,cpc.cdhsrdap
              ,cpc.cdhsirap
              ,cpc.cdhsvtap
              ,cpc.cdhsvrcc
              ,cpc.cdhsrnap
              ,cpc.idtxfixa
              ,cpc.cddindex
              ,cpc.indanive
          FROM craprac rac
              ,crapcpc cpc
         WHERE rac.cdprodut = cpc.cdprodut
           --AND rac.cdcooper = 1
           --AND rac.nrdconta IN (6308813,8992185) -- 6308813,8992185
           AND rac.idsaqtot = 0       -- 0 = Ativa / 1 = Encerrada
           AND cpc.cdprodut = 1057    -- RDC IPCA
           AND cpc.indanive = 1       -- Por aniversario
           AND(rac.dtmvtolt BETWEEN '09/12/2020' AND '11/12/2020' OR
               rac.dtmvtolt BETWEEN '09/01/2021' AND '11/01/2021');
    rw_craprac cr_craprac%ROWTYPE;

    -- Seleciona registros de lotes
    CURSOR cr_craplot(pr_cdcooper IN craplot.cdcooper%TYPE
                     ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                     ,pr_cdagenci IN craplot.cdagenci%TYPE
                     ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                     ,pr_nrdolote IN craplot.nrdolote%TYPE) IS
        SELECT lot.ROWID
              ,lot.nrseqdig
              ,lot.dtmvtolt
              ,lot.cdcooper
              ,lot.cdagenci
              ,lot.nrdolote
              ,lot.cdbccxlt
          FROM craplot lot
         WHERE lot.cdcooper = pr_cdcooper
           AND lot.dtmvtolt = pr_dtmvtolt
           AND lot.cdagenci = pr_cdagenci
           AND lot.cdbccxlt = pr_cdbccxlt
           AND lot.nrdolote = pr_nrdolote;
    rw_craplot cr_craplot%ROWTYPE;
    rw_craplot2 cr_craplot%ROWTYPE;

    -- cursor para registros com resgate
    CURSOR cr_resgate(pr_cdcooper IN craplac.cdcooper%TYPE
                     ,pr_nrdconta IN craplac.nrdconta%TYPE
                     ,pr_nraplica IN craplac.nraplica%TYPE) IS
        SELECT nvl(SUM(vllanmto), 0) vllanmto
          FROM craplac
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nraplica = pr_nraplica
           AND cdhistor = 3333;
    rw_resgate cr_resgate%ROWTYPE;

    -- Variaveis de erro
    vr_exc_saida EXCEPTION;
    vr_des_erro  VARCHAR2(3);
    vr_cdcritic  crapcri.cdcritic%TYPE := 0;
    vr_dscritic  crapcri.dscritic%TYPE := '';
    
    -- Variaveis para script de rollback
    vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
    vr_nmdireto        VARCHAR2(4000) := vr_rootmicros||'cpd/bacas/INC0082072_ipca'; 
    vr_nmarqimp        VARCHAR2(100)  := 'log1.txt';
    vr_nmarqimp2       VARCHAR2(100)  := 'sucesso1.txt';
    vr_nmarqimp3       VARCHAR2(100)  := 'falha1.txt';
    vr_nmarqimp4       VARCHAR2(100)  := 'backup1.txt';
    vr_ind_arquiv1     utl_file.file_type;
    vr_ind_arquiv2     utl_file.file_type;
    vr_ind_arquiv3     utl_file.file_type;
    vr_ind_arquiv4     utl_file.file_type;

    -- Valores
    vr_idgravir INTEGER := 1; -- Imunidade do cooperado
    vr_idtipbas INTEGER := 2; -- Tipo de base de calculo (1-Parcial / 2-Total)       
    vr_vlbascal NUMBER(20, 8) := 0; -- Valor para base de calculo de posicao do saldo
    vr_vlsldtot NUMBER(20, 8) := 0; -- Valor de saldo total
    vr_vlsldrgt NUMBER(20, 8) := 0; -- Valor de saldo de resgate
    vr_vlultren NUMBER(20, 8) := 0; -- Valor de ultimo rendimento
    vr_vlrentot NUMBER(20, 8) := 0; -- Valor de rendimento total
    vr_vlrevers NUMBER(20, 8) := 0; -- Valor de reversao
    vr_vlrdirrf NUMBER(20, 8) := 0; -- Valor de IRRF
    vr_percirrf NUMBER(20, 8) := 0; -- Valor percentual de IRRF
    vr_vlaplica NUMBER(20, 8) := 0; -- Saldo atualizado
    vr_vllanmto NUMBER(20, 8) := 0; -- Valor final de ajuste
    
    -- Variaveis locais
    rw_crapdat  btch0001.cr_crapdat%ROWTYPE;
    vr_dtinical craprac.dtatlsld%TYPE;
    vr_flgcaren PLS_INTEGER; --> Flag para ignorar a carencia (0 - nao ignora / 1 - sim ignora) 

    PROCEDURE loga(pr_msg VARCHAR2) IS
    BEGIN
      --dbms_output.put_line(pr_msg);
        gene0001.pc_escr_linha_arquivo(vr_ind_arquiv1,to_char(SYSDATE, 'ddmmyyyy_hh24miss') || ' - ' || pr_msg);
    END;

    PROCEDURE sucesso(pr_msg VARCHAR2) IS
    BEGIN
      --dbms_output.put_line(pr_msg);
        gene0001.pc_escr_linha_arquivo(vr_ind_arquiv2,to_char(SYSDATE, 'ddmmyyyy_hh24miss') || ' - ' || pr_msg);
    END;

    PROCEDURE falha(pr_msg VARCHAR2) IS
    BEGIN
      --dbms_output.put_line(pr_msg);
        gene0001.pc_escr_linha_arquivo(vr_ind_arquiv3,to_char(SYSDATE, 'ddmmyyyy_hh24miss') || ' - ' || pr_msg);
        loga(pr_msg);
    END;

    PROCEDURE backup(pr_msg VARCHAR2) IS
    BEGIN
      --dbms_output.put_line(pr_msg);
        gene0001.pc_escr_linha_arquivo(vr_ind_arquiv4, pr_msg);
    END;

    -- Procedure para gerar lançamento do valor
    PROCEDURE pc_gera_lancamento(pr_cdcooper IN craplot.cdcooper%TYPE
                                ,pr_nrdconta IN craprac.nrdconta%TYPE
                                ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                                ,pr_vllanmto IN craplot.vlcompdb%TYPE) IS
    
    BEGIN
        DECLARE
            vr_cdagenci craplot.cdagenci%TYPE := 1;
            vr_cdbccxlt craplot.cdbccxlt%TYPE := 100;
            vr_nrdolote craplot.nrdolote%TYPE := 558506;
        BEGIN
        
            IF nvl(pr_vllanmto, 0) <= 0 THEN
                RETURN;
            END IF;
            
            --Buscar o lote
            OPEN cr_craplot(pr_cdcooper => pr_cdcooper
                           ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                           ,pr_cdagenci => vr_cdagenci
                           ,pr_cdbccxlt => vr_cdbccxlt
                           ,pr_nrdolote => vr_nrdolote);
            FETCH cr_craplot INTO rw_craplot;
            
            IF cr_craplot%NOTFOUND THEN
                loga('Inserindo Lote: Cooper: '|| pr_cdcooper || ' Conta: ' || pr_nrdconta || ' Lote: ' || vr_nrdolote);

                -- Inserir lote
                BEGIN
                    INSERT INTO craplot(cdcooper
                                       ,dtmvtolt
                                       ,cdagenci
                                       ,cdbccxlt
                                       ,nrdolote
                                       ,tplotmov
                                       ,nrseqdig
                                       ,qtinfoln
                                       ,qtcompln
                                       ,vlinfocr
                                       ,vlcompcr
                                       ,vlinfodb
                                       ,vlcompdb)
                                 VALUES(pr_cdcooper
                                       ,rw_crapdat.dtmvtolt
                                       ,vr_cdagenci
                                       ,vr_cdbccxlt
                                       ,vr_nrdolote
                                       ,9
                                       ,1
                                       ,1
                                       ,1
                                       ,pr_vllanmto
                                       ,pr_vllanmto
                                       ,0 -- pr_vllanneg
                                       ,0)-- pr_vllanneg
                    RETURNING nrseqdig, cdcooper, dtmvtolt, cdagenci
                         INTO rw_craplot2.nrseqdig, rw_craplot2.cdcooper, rw_craplot2.dtmvtolt, rw_craplot2.cdagenci;
                EXCEPTION
                    WHEN OTHERS THEN
                        vr_dscritic := ' Erro ao Inserir Lote - Cooperativa: ' || pr_cdcooper ||
                                       ' - Conta: ' || pr_nrdconta || ' - Lote: ' || vr_nrdolote || ' SQLERRM: ' || SQLERRM;
                        falha(vr_dscritic);
                        RAISE vr_exc_saida;
                END;
            ELSE
                loga('Atualizando Lote: Cooper: '|| pr_cdcooper || ' Conta: ' || pr_nrdconta || ' Lote: ' || vr_nrdolote);
                
                /*
                backup('UPDATE craplot SET nrseqdig = ' || to_char(NVL(rw_craplot2.nrseqdig,0) - 1) ||
                       'WHERE cdcooper = ''' || to_char(rw_craplot2.cdcooper) || '' || ' AND dtmvtolt = ''' ||
                       to_char(rw_craplot2.dtmvtolt) || '' || 'AND cdagenci = ''' || to_char(rw_craplot2.cdagenci) || ''';');
                */

                -- Atualizar lote
                BEGIN
                    UPDATE craplot
                       SET craplot.nrseqdig = NVL(craplot.nrseqdig,0) + 1
                         , craplot.qtcompln = NVL(craplot.qtcompln,0) + 1
                         , craplot.qtinfoln = NVL(craplot.qtinfoln,0) + 1
                         , craplot.vlcompcr = NVL(craplot.vlcompcr,0) + pr_vllanmto
                         , craplot.vlinfocr = NVL(craplot.vlinfocr,0) + pr_vllanmto
                         --, craplot.vlcompdb = NVL(craplot.vlcompdb,0) + pr_vllanneg
                         --, craplot.vlinfodb = NVL(craplot.vlinfodb,0) + pr_vllanneg
                     WHERE craplot.cdcooper = pr_cdcooper
                       AND craplot.dtmvtolt = rw_crapdat.dtmvtolt
                       AND craplot.cdagenci = vr_cdagenci
                       AND craplot.cdbccxlt = vr_cdbccxlt
                       AND craplot.nrdolote = vr_nrdolote
                    RETURNING nrseqdig, cdcooper, dtmvtolt, cdagenci
                         INTO rw_craplot2.nrseqdig, rw_craplot2.cdcooper, rw_craplot2.dtmvtolt, rw_craplot2.cdagenci;
                EXCEPTION
                    WHEN OTHERS THEN
                        vr_dscritic := ' Erro ao Atualizar Lote - Cooperativa: ' || pr_cdcooper ||
                                       ' - Conta: ' || pr_nrdconta || ' - Lote: ' || vr_nrdolote || ' SQLERRM: ' || SQLERRM;
                        falha(vr_dscritic);
                        RAISE vr_exc_saida;
                END;
            END IF;
            
            CLOSE cr_craplot;
           
            backup('DELETE FROM craplac ' ||
                         'WHERE cdcooper = ''' || to_char(rw_craprac.cdcooper) || '' ||
                          ''' AND dtmvtolt = ''' || to_char(rw_craplot2.dtmvtolt) || '' ||
                          ''' AND cdagenci = ''' || to_char(vr_cdagenci) || '' ||
                          ''' AND cdbccxlt = ''' || to_char(vr_cdbccxlt) || '' ||
                          ''' AND nrdolote = ''' || to_char(vr_nrdolote) || '' ||
                          ''' AND nrdconta = ''' || to_char(rw_craprac.nrdconta) || '' ||
                          ''' AND nrseqdig = ''' || to_char(rw_craplot2.nrseqdig) || '' ||
                          ''' AND nrdocmto = ''' || to_char(rw_craplot2.nrseqdig) || ''';');

            -- Insere registro de lancamento de aplicacao
            loga('Inserindo Lancamento: Cooper: '|| rw_craprac.cdcooper || ' Conta: ' || rw_craprac.nrdconta ||
                 ' Lote: ' || vr_nrdolote || ' Seq.: ' || rw_craplot2.nrseqdig);

            BEGIN
                INSERT INTO craplac
                    (cdcooper
                    ,dtmvtolt
                    ,cdagenci
                    ,cdbccxlt
                    ,nrdolote
                    ,nrdconta
                    ,nraplica
                    ,nrdocmto
                    ,nrseqdig
                    ,vllanmto
                    ,cdhistor)
                VALUES
                    (rw_craprac.cdcooper
                    ,rw_craplot2.dtmvtolt
                    ,vr_cdagenci -- 1 -- Fixo -- rw_craplot.cdagenci
                    ,vr_cdbccxlt -- 100 -- Fixo -- rw_craplot.cdbccxlt
                    ,vr_nrdolote -- 558506 -- Fixo -- rw_craplot.nrdolote
                    ,rw_craprac.nrdconta
                    ,rw_craprac.nraplica
                    ,rw_craplot2.nrseqdig
                    ,rw_craplot2.nrseqdig
                    ,pr_vllanmto
                    ,3328); -- Fixo
            EXCEPTION
                WHEN OTHERS THEN
                    vr_dscritic := ' Erro ao Inserir Regsitro Lancamento - Cooperativa: ' || rw_craprac.cdcooper ||
                                   ' - Conta: ' || rw_craprac.nrdconta || ' - Aplic.: ' || rw_craprac.nraplica || ' SQLERRM: ' || SQLERRM;
                    falha(vr_dscritic);
                    RAISE vr_exc_saida;
            END;
            
            -- atualiza valor atual da aplicacao e a data da ultima atualizacao
            loga('Atualizando Aplicacao (CRAPRAC): Cooper: '|| rw_craprac.cdcooper || ' Conta: ' || rw_craprac.nrdconta ||
                 ' Lote: ' || vr_nrdolote || ' Seq.: ' || rw_craplot2.nrseqdig);
                 
            backup('UPDATE craprac SET vlsldant = ' || to_char(REPLACE(rw_craprac.vlsldant, ',', '.')) || 
                                     ',vlsldatl = ' || to_char(REPLACE(rw_craprac.vlsldatl, ',', '.')) ||
                   ' WHERE cdcooper = ''' || to_char(rw_craprac.cdcooper) || '' || 
                     ''' AND nrdconta = ''' || to_char(rw_craprac.nrdconta) || '' ||
                     ''' AND nraplica = ''' || rw_craprac.nraplica || ''';');
            
            BEGIN
              UPDATE craprac
                 SET vlsldatl = vlsldatl + vr_vllanmto
                    ,vlsldant = vlsldatl
               WHERE cdcooper = rw_craprac.cdcooper
                 AND nrdconta = rw_craprac.nrdconta
                 AND nraplica = rw_craprac.nraplica;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := ' Erro ao Atualizar Aplicacao (CRAPRAC) - Cooperativa: ' || rw_craprac.cdcooper ||
                               ' - Conta: ' || rw_craprac.nrdconta || ' - Aplic.: ' || rw_craprac.nraplica || ' SQLERRM: ' || SQLERRM;
                falha(vr_dscritic);
                RAISE vr_exc_saida;
            END;
            
        
        END;
    
    END pc_gera_lancamento;

BEGIN

    -- Criar arquivo
    gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto --> Diretorio do arquivo
                            ,pr_nmarquiv => vr_nmarqimp --> Nome do arquivo
                            ,pr_tipabert => 'W' --> modo de abertura (r,w,a)
                            ,pr_utlfileh => vr_ind_arquiv1 --> handle do arquivo aberto
                            ,pr_des_erro => vr_dscritic); --> erro
    -- em caso de crítica
    IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
    END IF;

    -- Criar arquivo
    gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto --> Diretorio do arquivo
                            ,pr_nmarquiv => vr_nmarqimp2 --> Nome do arquivo
                            ,pr_tipabert => 'W' --> modo de abertura (r,w,a)
                            ,pr_utlfileh => vr_ind_arquiv2 --> handle do arquivo aberto
                            ,pr_des_erro => vr_dscritic); --> erro
    -- em caso de crítica
    IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
    END IF;

    -- Criar arquivo
    gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto --> Diretorio do arquivo
                            ,pr_nmarquiv => vr_nmarqimp3 --> Nome do arquivo
                            ,pr_tipabert => 'W' --> modo de abertura (r,w,a)
                            ,pr_utlfileh => vr_ind_arquiv3 --> handle do arquivo aberto
                            ,pr_des_erro => vr_dscritic); --> erro
    -- em caso de crítica
    IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
    END IF;

    -- Criar arquivo
    gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto --> Diretorio do arquivo
                            ,pr_nmarquiv => vr_nmarqimp4 --> Nome do arquivo
                            ,pr_tipabert => 'W' --> modo de abertura (r,w,a)
                            ,pr_utlfileh => vr_ind_arquiv4 --> handle do arquivo aberto
                            ,pr_des_erro => vr_dscritic); --> erro
    -- em caso de crítica
    IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
    END IF;

    -- Leitura do calendário da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => 3);
    FETCH btch0001.cr_crapdat
     INTO rw_crapdat;
    -- Se não encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois efetuaremos raise
      CLOSE btch0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic := 1;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;

    loga('Inicio Processo');
    
    loga('Excluindo taxa');
    BEGIN
        DELETE
          FROM craptxi
         WHERE cddindex = 5
           AND dtiniper = '01/02/2021'
           AND dtfimper = '01/02/2021';
    EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := ' Erro ao Excluir Taxa (CRAPTXI) - Inicio: 01/02/2021 - Fim: 01/02/2021 - SQLERRM: ' || SQLERRM;
          falha(vr_dscritic);
          RAISE vr_exc_saida;
    END;
    
    OPEN cr_craprac;
    LOOP
        FETCH cr_craprac INTO rw_craprac;
        EXIT WHEN cr_craprac%NOTFOUND;
    
        -- tratamento para contas com resgate
        OPEN cr_resgate(rw_craprac.cdcooper, rw_craprac.nrdconta, rw_craprac.nraplica);
        FETCH cr_resgate INTO rw_resgate;
        CLOSE cr_resgate;

        -- Seta variaveis
        vr_vlaplica := rw_craprac.vlaplica - rw_resgate.vllanmto;
        vr_vlbascal := rw_craprac.vlbasapl;
        vr_dtinical := rw_craprac.dtmvtolt;
        
        loga('Buscando saldo: Cooper: '|| rw_craprac.cdcooper || ' Conta: ' ||rw_craprac.nrdconta || ' Plano: ' ||rw_craprac.nraplica);
    
        -- Chama procedure para produto com aniversario
        apli0006.pc_posicao_saldo_aplicacao_ani(pr_cdcooper => rw_craprac.cdcooper, --> Código da cooperativa
                                                pr_nrdconta => rw_craprac.nrdconta, --> Nr. da conta
                                                pr_nraplica => rw_craprac.nraplica, --> Nr. da aplicação
                                                pr_dtiniapl => rw_craprac.dtmvtolt, --> Data de inicio da aplicação
                                                pr_dtatlsld => vr_dtinical,         --> Data ultima atualizacao do saldo
                                                pr_vlaplica => vr_vlaplica,         --> Saldo atualizado
                                                pr_txaplica => rw_craprac.txaplica, --> Taxa da aplicação
                                                pr_idtxfixa => rw_craprac.idtxfixa, --> Taxa fixa (1 - Sim/ 2 - Não)
                                                pr_cddindex => rw_craprac.cddindex, --> Código do indexador
                                                pr_qtdiacar => rw_craprac.qtdiacar, --> Dias de carencia
                                                pr_idgravir => vr_idgravir,         --> Se deve gravar imunidade      
                                                pr_cdprodut => rw_craprac.cdprodut, --> Codigo do produto PCAPTA
                                                pr_dtfimcal => rw_craprac.dtatlsld, --> Data final cálculo
                                                pr_idtipbas => vr_idtipbas, --> Tipo Base Cálculo – 1-Parcial/2-Total)
                                                pr_flgcaren => vr_flgcaren, --> Flag para ignorar a carencia (0 - nao ignora / 1 - sim ignora) 
                                                pr_vlbascal => vr_vlbascal, --> Valor Base Cálculo
                                                -- OUT
                                                pr_vlsldtot => vr_vlsldtot, --> Valor saldo total da aplicação
                                                pr_vlsldrgt => vr_vlsldrgt, --> Valor saldo total para resgate
                                                pr_vlultren => vr_vlultren, --> Valor último rendimento
                                                pr_vlrentot => vr_vlrentot, --> Valor rendimento total
                                                pr_vlrevers => vr_vlrevers, --> Valor de reversão
                                                pr_vlrdirrf => vr_vlrdirrf, --> Valor do IRRF
                                                pr_percirrf => vr_percirrf, --> Percentual do IRRF
                                                pr_cdcritic => vr_cdcritic, --> Código da crítica
                                                pr_dscritic => vr_dscritic);--> Descrição da crítica
    
        IF vr_dscritic IS NOT NULL OR nvl(vr_cdcritic, 0) <> 0 THEN
            vr_dscritic := ' Erro ao Buscar Saldo Aplicacao ' || vr_dscritic || ' - Cooperativa: ' || rw_craprac.cdcooper ||
                           ' - ' || rw_craprac.nrdconta || ' - ' || rw_craprac.nraplica || ' SQLERRM: ' || SQLERRM;
            falha(vr_dscritic);
            RAISE vr_exc_saida;
        END IF;
        
        loga('Ajustando plano: Cooper: '|| rw_craprac.cdcooper || ' Conta: ' ||rw_craprac.nrdconta || ' Plano: ' ||rw_craprac.nraplica);
        
        vr_vllanmto := vr_vlsldtot - rw_craprac.vlsldatl;
        
        pc_gera_lancamento(pr_cdcooper => rw_craprac.cdcooper
                          ,pr_nrdconta => rw_craprac.nrdconta
                          ,pr_dtmvtolt => rw_craprac.dtatlsld
                          ,pr_vllanmto => vr_vllanmto);

        sucesso('Plano ajustado com sucesso: Cooper: '|| rw_craprac.cdcooper || ' Conta: ' ||rw_craprac.nrdconta || ' Plano: ' ||rw_craprac.nraplica);

        :vr_dscritic := 'SUCESSO';

    END LOOP;
    
    loga('Recadastrando taxa');
    BEGIN
        INSERT INTO craptxi
            (cddindex, dtiniper, dtfimper, vlrdtaxa, dtcadast)
        VALUES
            (5, '01/02/2021', '01/02/2021', 5622.43000000, '12/03/2021');
    EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := ' Erro ao Recadastrar Taxa (CRAPTXI) - Inicio: 01/02/2021 - Fim: 01/02/2021 - Valor: 5622.43000000 - SQLERRM: ' || SQLERRM;
          falha(vr_dscritic);
          RAISE vr_exc_saida;
    END;
    
    COMMIT;
    
    loga('Fim Processo');
    
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv1); --> Handle do arquivo aberto;  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv2); --> Handle do arquivo aberto;  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv3); --> Handle do arquivo aberto;  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv4); --> Handle do arquivo aberto;  
   

EXCEPTION
  WHEN vr_exc_saida then 
    :vr_dscritic := 'ERRO ' || vr_dscritic;
    ROLLBACK;
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv1); --> Handle do arquivo aberto;  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv2); --> Handle do arquivo aberto;  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv3); --> Handle do arquivo aberto;  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv4); --> Handle do arquivo aberto;
    
  WHEN OTHERS then
    loga(vr_dscritic);
    loga(SQLERRM);
    :vr_dscritic := 'ERRO ' || vr_dscritic;
    ROLLBACK;
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv1); --> Handle do arquivo aberto;  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv2); --> Handle do arquivo aberto;  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv3); --> Handle do arquivo aberto;  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv4); --> Handle do arquivo aberto;
END;
1
vr_dscritic
1
SUCESSO
5
7
vr_vlsldtot
pr_lancamento
rw_craprac.vlsldatl
vr_vlrentot
vr_vlultren
vr_nmdireto
vr_dscritic
