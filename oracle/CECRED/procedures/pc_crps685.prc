CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS685 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                              ,pr_flgresta  IN PLS_INTEGER            --> Indicador para utilização de restart
                                              ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                              ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                              ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada

    BEGIN
    /*..............................................................................

     Programa: pc_crps685
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Carlos Rafael Tanholi
     Data    : Setembro/2014                       Ultima atualizacao: 26/09/2014

     Dados referentes ao programa:

     Frequencia: Mensal.

     Objetivo  : Calcula a provisao sobre o saldo das aplicacoes ativas mensalmente

    ...............................................................................*/

    DECLARE
    
      ------------------------------- VARIAVEIS -------------------------------    
    
      -- Código do programa
      vr_cdprogra crapprg.cdprogra%TYPE DEFAULT 'CRPS685';
      -- Tratamento de erros
      vr_exc_erro exception;
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);     
      -- descricao do arquivo
      vr_dsarquiv VARCHAR2(200) := '/rl/crrl678.lst';
      -- xml de dados
	    vr_clobxml CLOB;

      -- variaveis de retorno do calculo de provisao
      vr_idgravir NUMBER := 0; -- nenhuma imunidade do cooperado
      vr_idtipbas NUMBER := 2; -- tipo base de calculo
      vr_vlbascal NUMBER := 0; -- valor base de calculo
      vr_vlsldtot NUMBER := 0;
      vr_vlsldrgt NUMBER := 0;
      vr_vlultren NUMBER := 0;
      vr_vlrentot NUMBER := 0;
      vr_vlrevers NUMBER := 0;
      vr_vlrdirrf NUMBER := 0;
      vr_percirrf NUMBER := 0;
      
      -- variaveis para os totais de calculo de provisao
      vr_totqtdti NUMBER DEFAULT 0;
      vr_totsldre NUMBER (14,2) DEFAULT 0;
      vr_totajupr NUMBER (14,2) DEFAULT 0;
      vr_totaprov NUMBER (14,2) DEFAULT 0;
      
      vr_cdprodut crapcpc.cdprodut%TYPE;
      vr_nrdprazo NUMBER(4);
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_vlrvalac NUMBER(14,2) := 0;     
      
      vr_flgrgprb BOOLEAN; 
      
      -- valor de saldo anterior
      vr_vlsldant craprac.vlsldant%TYPE;
      -- data do saldo anterior
      vr_dtsldant craprac.dtsldant%TYPE;
      --data movimento
      vr_dtmvtolt crapdat.dtmvtolt%TYPE;

      ------------------------------- PLTABLE -------------------------------

      -- Tabela temporaria CRAPCPC
      TYPE typ_reg_crapcpc IS
       RECORD(cdprodut crapcpc.cdprodut%TYPE --> Codigo do Produto
             ,cddindex crapcpc.cddindex%TYPE --> Codigo do Indexador       
             ,nmprodut crapcpc.nmprodut%TYPE --> Nome do Produto
             ,idsitpro crapcpc.idsitpro%TYPE --> Situação
             ,idtippro crapcpc.idtippro%TYPE --> Tipo
             ,idtxfixa crapcpc.idtxfixa%TYPE --> Taxa Fixa
             ,idacumul crapcpc.idacumul%TYPE --> Taxa Cumulativa              
             ,cdhscacc crapcpc.cdhscacc%TYPE --> Débito Aplicação
             ,cdhsvrcc crapcpc.cdhsvrcc%TYPE --> Crédito Resgate/Vencimento Aplicação
             ,cdhsraap crapcpc.cdhsraap%TYPE --> Crédito Renovação Aplicação
             ,cdhsnrap crapcpc.cdhsnrap%TYPE --> Crédito Aplicação Recurso Novo
             ,cdhsprap crapcpc.cdhsprap%TYPE --> Crédito Atualização Juros
             ,cdhsrvap crapcpc.cdhsrvap%TYPE --> Débito Reversão Atualização Juros
             ,cdhsrdap crapcpc.cdhsrdap%TYPE --> Crédito Rendimento
             ,cdhsirap crapcpc.cdhsirap%TYPE --> Débito IRRF
             ,cdhsrgap crapcpc.cdhsrgap%TYPE --> Débito Resgate
             ,cdhsvtap crapcpc.cdhsvtap%TYPE); --> Débito Vencimento


      TYPE typ_tab_crapcpc IS
        TABLE OF typ_reg_crapcpc
          INDEX BY PLS_INTEGER;
      -- Vetor para armazenar os dados dos produtos de captacao
      vr_tab_crapcpc typ_tab_crapcpc;


      -- Definicao do tipo de registro do relatorio de resumo mensal das aplicacoes
      TYPE typ_res_men_apli IS RECORD (qtdtitat NUMBER DEFAULT 0  -- Quantidade de titulos ativos
                                      ,qtdtitap NUMBER DEFAULT 0  -- Quantidade de titulos aplicados no mes
                                      ,sldtitat NUMBER(14,2) DEFAULT 0  -- "zzz,zzz,zzz,zz9.99-"  Saldo total de titulos ativos
                                      ,vlrtotap NUMBER(14,2) DEFAULT 0  -- "zzz,zzz,zzz,zz9.99-"  Valor total aplicado no mes
                                      ,rencreme NUMBER(14,2) DEFAULT 0  -- "zzz,zzz,zzz,zz9.99-"  Redimento creditado no mes
                                      ,vlrtotpr NUMBER(14,2) DEFAULT 0  -- "zzz,zzz,zzz,zz9.99-"  Valor total provisao mes
                                      ,ajtprome NUMBER(14,2) DEFAULT 0  -- "zzz,zzz,zzz,zz9.99-"  Ajuste provisao mes 
                                      ,restitve NUMBER(14,2) DEFAULT 0  -- "zzz,zzz,zzz,zz9.99-"  Resgates dos titulos vencidos no mes
                                      ,saqsemre NUMBER(14,2) DEFAULT 0  -- "zzz,zzz,zzz,zz9.99-"  Saques sem rendimento
                                      ,saqcomre NUMBER(14,2) DEFAULT 0  -- "zzz,zzz,zzz,zz9.99-"  Saques com rendimento
                                      ,imprenrf NUMBER(14,2) DEFAULT 0); -- "zzz,zzz,zzz,zz9.99-"  Imposte de renda retido na fonte

      -- Definicao de registro de aplicacoes
      TYPE typ_prod_captacao IS  TABLE OF typ_res_men_apli INDEX BY PLS_INTEGER;
      vr_prod_captacao typ_prod_captacao;
      
      
	    -- Definicao do tipo de registro do relatorio detalhamento da provisao por cooperativa
      TYPE typ_det_pro_cop IS RECORD(nrdconta crapass.nrdconta%TYPE   -- numero da conta da cooperativa
                                    ,titconta crapcop.nmrescop%TYPE   -- Nome da cooperativa
                                    ,qtdtitul NUMBER DEFAULT 0        -- Quantidade de titulos por cooperativa
                                    ,sldrendi NUMBER(14,2) DEFAULT 0  -- "zzz,zzz,zzz,zz9.99-" Saldo total de rendimentos
                                    ,ajuprovi NUMBER(14,2) DEFAULT 0  -- "zzz,zzz,zzz,zz9.99-" ajuste de provisao
                                    ,totprovi NUMBER(14,2) DEFAULT 0);-- "zzz,zzz,zzz,zz9.99-" total provisao
                                     
      -- Definicao de registro de aplicacoes
      TYPE typ_prov_coopera IS  TABLE OF typ_det_pro_cop INDEX BY PLS_INTEGER;
      TYPE typ_mult_prov_array IS TABLE OF typ_prov_coopera INDEX BY PLS_INTEGER;            
      vr_prov_coopera typ_mult_prov_array;
            
     
      -- resumo do valor e qtd por prazo (90...5401 dias)
      TYPE typ_res_praz_apli IS RECORD (vlrvalor NUMBER(14,2) DEFAULT 0 -- Valor
                                       ,vlrvalac NUMBER(14,2) DEFAULT 0 -- Valor acumulado
                                       ,quantida NUMBER DEFAULT 0);     -- Quantidade
      
      TYPE typ_praz_captacao IS TABLE OF typ_res_praz_apli INDEX BY PLS_INTEGER;      
      TYPE typ_mult_praz_array IS TABLE OF typ_praz_captacao INDEX BY PLS_INTEGER;      
      -- variavel do tipo definido acima
      vr_prazcaptacao typ_mult_praz_array;  
     
    
      -- Vetor com a quantidade de dias para cada período de 1 a 19
      TYPE typ_reg_prazo IS VARRAY(19) OF NUMBER(4);
      vr_vet_prazo typ_reg_prazo := typ_reg_prazo(90,180,270,360,720,1080,1440
                                                 ,1800,2160,2520,2880,3240,3600
                                                 ,3960,4320,4680,5040,5400,5401);


      -- Tabela temporaria CRAPCOP
      TYPE typ_reg_crapcop IS RECORD(nmrescop crapcop.nmrescop%TYPE   --> Nome resumido da cooperativa
                                    ,nrctactl crapcop.nrctactl%TYPE); --> Numero da conta da cooperativa

      TYPE typ_tab_crapcop IS
        TABLE OF typ_reg_crapcop
          INDEX BY PLS_INTEGER;
      vr_tab_crapcop typ_tab_crapcop;


      ------------------------------- CURSORES ---------------------------------
      
      -- Busca aplicacoes ativas
      CURSOR cr_craprac(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT craprac.cdcooper
              ,craprac.cdprodut
              ,craprac.nrdconta
              ,craprac.nraplica
              ,craprac.dtmvtolt
              ,craprac.dtatlsld
              ,craprac.txaplica
              ,craprac.qtdiacar
              ,craprac.vlsldant
              ,craprac.dtsldant
              ,craprac.vlsldatl
              ,NVL(craprac.vlslfmes,0) vlslfmes
              ,craprac.qtdiaapl
              ,craprac.rowid
          FROM craprac 
         WHERE craprac.cdcooper = pr_cdcooper                 
           AND craprac.idsaqtot = 0; /* Ativa */

      rw_craprac cr_craprac%ROWTYPE;

      -- Valida cadastro da aplicacao
      CURSOR cr_craplac(pr_cdcooper IN craprac.cdcooper%TYPE
                       ,pr_nrdconta IN craprac.nrdconta%TYPE
                       ,pr_nraplica IN craprac.nraplica%TYPE
                       ,pr_dtmvtolt IN craprac.dtmvtolt%TYPE) IS
        SELECT lac.cdcooper
          FROM craplac lac
         WHERE lac.cdcooper = pr_cdcooper
           AND lac.nrdconta = pr_nrdconta
           AND lac.nraplica = pr_nraplica
           AND lac.dtmvtolt = pr_dtmvtolt;

      rw_craplac cr_craplac%ROWTYPE;

      -- valida a existencia de registros de provisao
      CURSOR cr_craplot(pr_cdcooper IN craprac.cdcooper%TYPE
                       ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
      SELECT lot.cdcooper
             ,lot.nrseqdig
             ,lot.qtinfoln
             ,lot.qtcompln
             ,lot.vlinfocr
             ,lot.vlcompcr  
             ,lot.nrdolote
             ,lot.cdbccxlt 
             ,lot.cdagenci
             ,lot.dtmvtolt 
             ,lot.rowid
             ,lot.tplotmov
        FROM craplot lot
       WHERE lot.cdcooper = pr_cdcooper
         AND lot.dtmvtolt = pr_dtmvtolt
         AND lot.cdagenci = 1
         AND lot.cdbccxlt = 100
         AND lot.nrdolote = 8506;

       rw_craplot cr_craplot%ROWTYPE;

       -- valida existencia de informacoes referentes a aplicacoes para o BNDES
      CURSOR cr_crapbnd(pr_cdcooper IN craprac.cdcooper%TYPE
                       ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                       ,pr_nrdconta IN craprac.nrdconta%TYPE) IS
      SELECT crapbnd.cdcooper
        FROM crapbnd
       WHERE cdcooper = pr_cdcooper
         AND dtmvtolt = pr_dtmvtolt
         AND nrdconta = pr_nrdconta;

       rw_crapbnd cr_crapbnd%ROWTYPE;

       -- cursor utilizado para armazenar dados da cooperativa
       CURSOR cr_crapcop IS
       SELECT cdcooper
             ,nmrescop
             ,nrctactl
         FROM crapcop;

       rw_crapcop cr_crapcop%ROWTYPE;
       
       
       -- cursor para obter campos de resumo do relatorio
       CURSOR cr_craplac_rel(pr_cdcooper IN craprac.cdcooper%TYPE
                            ,pr_dtmvtolt IN craplac.dtmvtolt%TYPE
                            ,pr_cdprodut IN crapcpc.cdprodut%TYPE) IS
                             
       SELECT lac.vllanmto
             ,NVL(lac.vlrendim, 0) vlrendim
             ,lac.cdhistor
             ,rac.cdprodut
         FROM craplac lac
             ,craprac rac     
        WHERE lac.cdcooper = rac.cdcooper
          AND lac.nrdconta = rac.nrdconta
          AND lac.nraplica = rac.nraplica
          AND lac.cdcooper = pr_cdcooper
          AND lac.dtmvtolt BETWEEN trunc(pr_dtmvtolt,'mm') AND pr_dtmvtolt
          AND (rac.cdprodut = pr_cdprodut OR pr_cdprodut = 0);      
       
      -- cursor usado para carregar dados de produtos de captacao na PLTABLE
      CURSOR cr_crapcpc IS
      SELECT cdprodut
            ,cddindex
            ,nmprodut
            ,idsitpro
            ,idtippro
            ,idtxfixa
            ,idacumul
            ,cdhscacc
            ,cdhsvrcc 
            ,cdhsraap
            ,cdhsnrap
            ,cdhsprap
            ,cdhsrvap
            ,cdhsrdap
            ,cdhsirap
            ,cdhsrgap
            ,cdhsvtap
        FROM crapcpc cpc;
      
       rw_crapcpc cr_crapcpc%ROWTYPE;    

       -- resource(row) para retorno de cursor externo(btch0001)
       rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      --------------------------- SUBROTINAS INTERNAS --------------------------

      -- REGISTRA O SALDO DA APLICACAO
      PROCEDURE pc_registra_saldo_aplicacao(pr_nrctactl IN crapcop.nrctactl%TYPE
                                           ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                                           ,pr_cddprazo IN NUMBER
                                           ,pr_vlslfmes IN craprac.vlslfmes%TYPE
                                           ,pr_cdprodut IN crapcpc.cdprodut%TYPE
                                           ,pr_cdcooper IN crapcop.cdcooper%TYPE
                                           ,pr_flgrgprb IN BOOLEAN) IS


        BEGIN

         /*..............................................................................

           Programa: pc_registra_saldo_aplicacao
           Sistema : Conta-Corrente - Cooperativa de Credito
           Sigla   : CRED
           Autor   : Carlos Rafael Tanholi
           Data    : Setembro/2014                       Ultima atualizacao: 12/09/2014

           Dados referentes ao programa:

           Frequencia: Mensal.

           Objetivo  : Registra saldo de aplicacoes dos cooperados das cooperativas
                       singulares para disponibilizar ao BNDES.

         ...............................................................................*/

        DECLARE

         CURSOR cr_crapprb(pr_nrctactl IN crapcop.nrctactl%TYPE
                          ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                          ,pr_cddprazo IN NUMBER
                          ,pr_cdcooper IN crapcop.cdcooper%TYPE) IS

          SELECT * FROM crapprb
                  WHERE cdcooper = pr_cdcooper
                    AND nrdconta = pr_nrctactl
                    AND dtmvtolt = pr_dtmvtolt
                    AND cdorigem = 10
                    AND cddprazo = pr_cddprazo;

         rw_crapprb cr_crapprb%ROWTYPE;

         BEGIN

          IF pr_flgrgprb THEN
            --consulta a existencia de um resgistro na crapprb
            OPEN cr_crapprb(pr_nrctactl => pr_nrctactl
                           ,pr_dtmvtolt => pr_dtmvtolt
                           ,pr_cddprazo => pr_cddprazo
                           ,pr_cdcooper => pr_cdcooper);

            FETCH cr_crapprb INTO rw_crapprb;
         
            IF cr_crapprb%NOTFOUND THEN
               BEGIN
                 INSERT INTO crapprb(cdcooper
                                    ,dtmvtolt
                                    ,nrdconta
                                    ,cdorigem
                                    ,cddprazo
                                    ,vlretorn)
                              VALUES(pr_cdcooper
                                    ,pr_dtmvtolt
                                    ,pr_nrctactl
                                    ,10
                                    ,pr_cddprazo
                                    ,pr_vlslfmes);

                 EXCEPTION 
                   WHEN OTHERS THEN
                     -- Gerar erro e fazer rollback
                     vr_dscritic := 'Erro ao inserir saldo das aplicacoes (crapprb). Detalhes: '||sqlerrm;
                     RAISE vr_exc_erro;
               END;          
            ELSE
               BEGIN

                 UPDATE crapprb SET vlretorn = vlretorn + pr_vlslfmes
                           WHERE cdcooper = pr_cdcooper
                             AND nrdconta = pr_nrctactl
                             AND dtmvtolt = pr_dtmvtolt
                             AND cdorigem = 10
                             AND cddprazo = pr_cddprazo;

                 EXCEPTION 
                   WHEN OTHERS THEN
                     -- Gerar erro e fazer rollback
                     vr_dscritic := 'Erro ao atualizar saldo das aplicacoes (crapprb). Detalhes: '||sqlerrm;
                     RAISE vr_exc_erro;
                 END;
            
            END IF;
          END IF;
          
          --zera a pltable que nao contem informacoes
          IF NOT vr_prazcaptacao.EXISTS(pr_cdprodut) THEN
            vr_prazcaptacao(pr_cdprodut)(pr_cddprazo).vlrvalor := 0;
            vr_prazcaptacao(pr_cdprodut)(pr_cddprazo).vlrvalac := 0;
            vr_prazcaptacao(pr_cdprodut)(pr_cddprazo).quantida := 0;
          ELSE
            IF NOT vr_prazcaptacao(pr_cdprodut).EXISTS(pr_cddprazo) THEN
            vr_prazcaptacao(pr_cdprodut)(pr_cddprazo).vlrvalor := 0;
            vr_prazcaptacao(pr_cdprodut)(pr_cddprazo).vlrvalac := 0;
            vr_prazcaptacao(pr_cdprodut)(pr_cddprazo).quantida := 0;
            END IF;
          END IF; 

          vr_prazcaptacao(pr_cdprodut)(pr_cddprazo).vlrvalor := NVL(vr_prazcaptacao(pr_cdprodut)(pr_cddprazo).vlrvalor,0) + pr_vlslfmes;
          vr_prazcaptacao(pr_cdprodut)(pr_cddprazo).vlrvalac := NVL(vr_prazcaptacao(pr_cdprodut)(pr_cddprazo).vlrvalac,0) + pr_vlslfmes;          
          vr_prazcaptacao(pr_cdprodut)(pr_cddprazo).quantida := NVL(vr_prazcaptacao(pr_cdprodut)(pr_cddprazo).quantida,0) + 1;
          
         END;

      END pc_registra_saldo_aplicacao;
    
      
      -- SUBROTINA PARA ESCREVER TEXTO NA VARIÁVEL CLOB DO XML
      PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS
      BEGIN
        -- ESCREVE DADOS NA VARIAVEL vr_clobxml QUE IRA CONTER OS DADOS DO XML
        dbms_lob.writeappend(vr_clobxml, length(pr_des_dados), pr_des_dados);
      END;    


	  BEGIN

	    --------------- VALIDACOES INICIAIS -----------------

      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => null);
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop;
      FETCH cr_crapcop
       INTO rw_crapcop;
      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;

      -- busca a ultima data de movimento
       OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;

      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
        RAISE vr_exc_erro;
      ELSE
        vr_dtmvtolt := rw_crapdat.dtmvtolt;
        CLOSE btch0001.cr_crapdat;
      END IF;


      -- Validações iniciais do programa
      BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                               ,pr_flgbatch => 1
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_cdcritic => vr_cdcritic);
      -- Se a variavel de erro é <> 0
      IF vr_cdcritic <> 0 THEN
        -- Envio centralizado de log de erro
        RAISE vr_exc_erro;
      END IF;
      
      -- ARQUIVO P/ GERACAO DO RELATORIO
      vr_dsarquiv := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                          ,pr_cdcooper => pr_cdcooper) || vr_dsarquiv;
      
      --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------      
      
      -- inicializar o clob (XML)
      dbms_lob.createtemporary(vr_clobxml, TRUE);
      dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);

      -- inicio do arquivo XML
      pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><raiz>');    


      -- carregamento pltable usadas
      FOR rw_crapcpc IN cr_crapcpc
       LOOP        
        
          vr_tab_crapcpc(rw_crapcpc.cdprodut).cddindex := rw_crapcpc.cddindex;
          vr_tab_crapcpc(rw_crapcpc.cdprodut).nmprodut := rw_crapcpc.nmprodut;   
          vr_tab_crapcpc(rw_crapcpc.cdprodut).idsitpro := rw_crapcpc.idsitpro;   
          vr_tab_crapcpc(rw_crapcpc.cdprodut).idtippro := rw_crapcpc.idtippro;   
          vr_tab_crapcpc(rw_crapcpc.cdprodut).idtxfixa := rw_crapcpc.idtxfixa;   
          vr_tab_crapcpc(rw_crapcpc.cdprodut).idacumul := rw_crapcpc.idacumul;   
          vr_tab_crapcpc(rw_crapcpc.cdprodut).cdhscacc := rw_crapcpc.cdhscacc;   
          vr_tab_crapcpc(rw_crapcpc.cdprodut).cdhsvrcc := rw_crapcpc.cdhsvrcc;   
          vr_tab_crapcpc(rw_crapcpc.cdprodut).cdhsraap := rw_crapcpc.cdhsraap;   
          vr_tab_crapcpc(rw_crapcpc.cdprodut).cdhsnrap := rw_crapcpc.cdhsnrap;   
          vr_tab_crapcpc(rw_crapcpc.cdprodut).cdhsprap := rw_crapcpc.cdhsprap;   
          vr_tab_crapcpc(rw_crapcpc.cdprodut).cdhsrvap := rw_crapcpc.cdhsrvap;
          vr_tab_crapcpc(rw_crapcpc.cdprodut).cdhsrdap := rw_crapcpc.cdhsrdap;
          vr_tab_crapcpc(rw_crapcpc.cdprodut).cdhsirap := rw_crapcpc.cdhsirap;
          vr_tab_crapcpc(rw_crapcpc.cdprodut).cdhsrgap := rw_crapcpc.cdhsrgap;
          vr_tab_crapcpc(rw_crapcpc.cdprodut).cdhsvtap := rw_crapcpc.cdhsvtap;    
                  
          -- inicializa a PLTABLE de totais por produto com zero
          vr_prod_captacao(rw_crapcpc.cdprodut).qtdtitat := 0;
          vr_prod_captacao(rw_crapcpc.cdprodut).qtdtitap := 0;
          vr_prod_captacao(rw_crapcpc.cdprodut).sldtitat := 0;
          vr_prod_captacao(rw_crapcpc.cdprodut).vlrtotap := 0;
          vr_prod_captacao(rw_crapcpc.cdprodut).rencreme := 0;
          vr_prod_captacao(rw_crapcpc.cdprodut).vlrtotpr := 0;
          vr_prod_captacao(rw_crapcpc.cdprodut).ajtprome := 0;
          vr_prod_captacao(rw_crapcpc.cdprodut).restitve := 0;
          vr_prod_captacao(rw_crapcpc.cdprodut).saqsemre := 0;
          vr_prod_captacao(rw_crapcpc.cdprodut).saqcomre := 0;
          vr_prod_captacao(rw_crapcpc.cdprodut).imprenrf := 0;       
       
      END LOOP;
      
      -- carrega os dados das cooperativas na PLTABLE
      FOR rw_crapcop IN cr_crapcop
       LOOP       

        vr_tab_crapcop(rw_crapcop.cdcooper).nmrescop := rw_crapcop.nmrescop;      
        vr_tab_crapcop(rw_crapcop.cdcooper).nrctactl := rw_crapcop.nrctactl;      
        
      END LOOP;
     
    
    
      -- VALIDA a existencia de um resgistro na craplot
      OPEN cr_craplot(pr_cdcooper => pr_cdcooper
                     ,pr_dtmvtolt => vr_dtmvtolt);

      FETCH cr_craplot INTO rw_craplot;
      
	    -- insere o registro obrigatorio
      IF cr_craplot%NOTFOUND THEN
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
                             ,vlcompcr)
                       VALUES(pr_cdcooper
                             ,vr_dtmvtolt
                             ,1
                             ,100
                             ,8506
                             ,9
                             ,0
                             ,0
                             ,0
                             ,0
                             ,0);

        EXCEPTION
          WHEN OTHERS THEN
            -- Gerar erro e fazer rollback
            vr_dscritic := 'Erro ao inserir capas de lotes (craplot). Detalhes: '||sqlerrm;
          RAISE vr_exc_erro;
        END;

      END IF;

      CLOSE cr_craplot;
      
      -- filtra as aplicacoes da cooperativa     
     FOR rw_craprac IN cr_craprac(pr_cdcooper => pr_cdcooper)
       LOOP      
       
       -- valida o cadastro do historico para o produto da aplicacao
       IF vr_tab_crapcpc(rw_craprac.cdprodut).cdhsprap <= 0 THEN
         
         -- Gerar log de erro
         btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                   ,pr_ind_tipo_log => 2 -- Erro tratato
                                   ,pr_des_log      => TO_CHAR(SYSDATE,'dd/mm/rrrr HH:mm:ss') || ' - crps685 --> ' ||
                                                       'Campo de historico (cdhsprap) nao informado. ' ||
                                                       'Conta: ' || trim(gene0002.fn_mask_conta(rw_craprac.nrdconta)) || 
                                                       ', Aplic.: ' || trim(gene0002.fn_mask(rw_craprac.nraplica,'zzz.zz9')) ||
                                                       ', Prod.: ' || trim(rw_craprac.cdprodut));                                                        
         CONTINUE;       
       
       END IF;
       
       -- consulta o lancamento de cadastro da aplicacao
       OPEN cr_craplac(pr_cdcooper => rw_craprac.cdcooper
                      ,pr_nrdconta => rw_craprac.nrdconta
                      ,pr_nraplica => rw_craprac.nraplica
                      ,pr_dtmvtolt => rw_craprac.dtmvtolt);

       FETCH cr_craplac INTO rw_craplac;
                
         -- Se não encontrar lancamento inicial da aplicacao
         IF cr_craplac%NOTFOUND THEN
           -- Gerar log 90 e concatenar conta e aplicação
           btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                     ,pr_ind_tipo_log => 2 -- Erro tratato
                                     ,pr_des_log      => TO_CHAR(SYSDATE,'dd/mm/rrrr HH:mm:ss') || ' - crps685 --> ' ||
                                                         gene0001.fn_busca_critica(pr_cdcritic => 90) ||       
                                                         'Conta: ' || trim(gene0002.fn_mask_conta(rw_craprac.nrdconta)) || 
                                                         ', Aplic.: ' || trim(gene0002.fn_mask(rw_craprac.nraplica,'zzz.zz9')));
           CLOSE cr_craplac;                                                         
           CONTINUE;
          ELSE

            CLOSE cr_craplac;

            IF vr_tab_crapcpc(rw_craprac.cdprodut).idtippro = 1 THEN
              -- procedures para criacao dos lancamentos
              APLI0006.pc_posicao_saldo_aplicacao_pre(pr_cdcooper => rw_craprac.cdcooper, 
                                                      pr_nrdconta => rw_craprac.nrdconta,
                                                      pr_nraplica => rw_craprac.nraplica, 
                                                      pr_dtiniapl => rw_craprac.dtmvtolt,
                                                      pr_txaplica => rw_craprac.txaplica, 
                                                      pr_idtxfixa => vr_tab_crapcpc(rw_craprac.cdprodut).idtxfixa,
                                                      pr_cddindex => vr_tab_crapcpc(rw_craprac.cdprodut).cddindex,
                                                      pr_qtdiacar => rw_craprac.qtdiacar,
                                                      pr_idgravir => vr_idgravir, 
                                                      pr_dtinical => rw_craprac.dtatlsld,
                                                      pr_dtfimcal => vr_dtmvtolt, 
                                                      pr_idtipbas => vr_idtipbas,
                                                      pr_vlbascal => vr_vlbascal, 
                                                      pr_vlsldtot => vr_vlsldtot,
                                                      pr_vlsldrgt => vr_vlsldrgt, 
                                                      pr_vlultren => vr_vlultren,
                                                      pr_vlrentot => vr_vlrentot, 
                                                      pr_vlrevers => vr_vlrevers,
                                                      pr_vlrdirrf => vr_vlrdirrf, 
                                                      pr_percirrf => vr_percirrf,
                                                      pr_cdcritic => vr_cdcritic, 
                                                      pr_dscritic => vr_dscritic);
                         
            ELSIF vr_tab_crapcpc(rw_craprac.cdprodut).idtippro = 2 THEN
              -- procedures para criacao dos lancamentos
              APLI0006.pc_posicao_saldo_aplicacao_pos(pr_cdcooper => rw_craprac.cdcooper, 
                                                      pr_nrdconta => rw_craprac.nrdconta,
                                                      pr_nraplica => rw_craprac.nraplica, 
                                                      pr_dtiniapl => rw_craprac.dtmvtolt,
                                                      pr_txaplica => rw_craprac.txaplica, 
                                                      pr_idtxfixa => vr_tab_crapcpc(rw_craprac.cdprodut).idtxfixa,
                                                      pr_cddindex => vr_tab_crapcpc(rw_craprac.cdprodut).cddindex, 
                                                      pr_qtdiacar => rw_craprac.qtdiacar,
                                                      pr_idgravir => vr_idgravir, 
                                                      pr_dtinical => rw_craprac.dtatlsld,
                                                      pr_dtfimcal => vr_dtmvtolt, 
                                                      pr_idtipbas => vr_idtipbas,
                                                      pr_vlbascal => vr_vlbascal, 
                                                      pr_vlsldtot => vr_vlsldtot,
                                                      pr_vlsldrgt => vr_vlsldrgt, 
                                                      pr_vlultren => vr_vlultren,
                                                      pr_vlrentot => vr_vlrentot, 
                                                      pr_vlrevers => vr_vlrevers,
                                                      pr_vlrdirrf => vr_vlrdirrf, 
                                                      pr_percirrf => vr_percirrf,
                                                      pr_cdcritic => vr_cdcritic, 
                                                      pr_dscritic => vr_dscritic);
                        
            END IF;

            -- tratamento para possiveis erros gerados pelas rotinas anteriores
            IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
               RAISE vr_exc_erro;
            END IF;

            -- armazena o saldo total de titulos ativos para o produto
            --vr_prod_captacao(rw_craprac.cdprodut).sldtitat := vr_prod_captacao(rw_craprac.cdprodut).sldtitat + vr_vlultren;

            -- valida o ultimo rendimento
            IF vr_vlultren > 0 THEN    

              OPEN cr_craplot(pr_cdcooper => pr_cdcooper, pr_dtmvtolt => vr_dtmvtolt);
              
              FETCH cr_craplot INTO rw_craplot;
              
              CLOSE cr_craplot;
              
              -- de acordo com o INSERT executado no inicio deste script 
              -- nao ha necessidade de verificacao de existencia do registro 
              -- na CRAPLOT entao atualiza o registro ja criado na CRAPLOT              
              BEGIN
                UPDATE craplot SET tplotmov = 9
                                  ,nrseqdig = rw_craplot.nrseqdig + 1
                                  ,qtinfoln = rw_craplot.qtinfoln + 1
                                  ,qtcompln = rw_craplot.qtcompln + 1
                                  ,vlinfocr = rw_craplot.vlinfocr + vr_vlultren
                                  ,vlcompcr = rw_craplot.vlcompcr + vr_vlultren
                             WHERE cdcooper = rw_craprac.cdcooper
                               AND dtmvtolt = vr_dtmvtolt
                               AND cdagenci = 1
                               AND cdbccxlt = 100
                               AND nrdolote = 8506 
                               AND craplot.rowid = rw_craplot.rowid
                         RETURNING tplotmov, nrseqdig, qtinfoln, qtcompln, vlinfocr, vlcompcr, ROWID
                              INTO rw_craplot.tplotmov, rw_craplot.nrseqdig, rw_craplot.qtinfoln,
                                   rw_craplot.qtcompln, rw_craplot.vlinfocr, rw_craplot.vlcompcr, rw_craplot.rowid;                                

              EXCEPTION 
                WHEN OTHERS THEN
                  -- Gerar erro e fazer rollback
                  vr_dscritic := 'Erro ao atualizar valores do lote(craplot). Detalhes: '||sqlerrm;
                  RAISE vr_exc_erro;
              END;
                      
              -- consulta dados recem-alterados acima
              OPEN cr_craplot(pr_cdcooper => pr_cdcooper, pr_dtmvtolt => vr_dtmvtolt);
              FETCH cr_craplot INTO rw_craplot;                        
              CLOSE cr_craplot;
                          
              -- armazena o lancamento de provisao
              BEGIN

                INSERT INTO craplac(cdcooper
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
                             VALUES(rw_craprac.cdcooper
                                   ,rw_craplot.dtmvtolt
                                   ,rw_craplot.cdagenci
                                   ,rw_craplot.cdbccxlt
                                   ,rw_craplot.nrdolote
                                   ,rw_craprac.nrdconta
                                   ,rw_craprac.nraplica
                                   ,rw_craplot.nrseqdig
                                   ,rw_craplot.nrseqdig
                                   ,vr_vlultren
                                   ,vr_tab_crapcpc(rw_craprac.cdprodut).cdhsprap);

              EXCEPTION 
                WHEN OTHERS THEN
                  -- Gerar erro e fazer rollback
                  vr_dscritic := 'Erro ao inserir lancamentos(craplac). Detalhes: '||sqlerrm;
                  RAISE vr_exc_erro;
              END;
            
            END IF;

            -- valida a execucao da ultima atualizacao da aplicacao
            IF rw_craprac.dtatlsld <> vr_dtmvtolt THEN
             -- atualiza os campos valor saldo anterior e data saldo anterior, com os dados atuais na craprac
              vr_vlsldant := rw_craprac.vlsldatl;
              vr_dtsldant := rw_craprac.dtatlsld;
            ELSE -- caso ja tenha atualizado no dia mantem os mesmos valores ja cadastrados
              vr_vlsldant := rw_craprac.vlsldant;
              vr_dtsldant := rw_craprac.dtsldant;
            END IF;

            -- atualiza valor atual da aplicacao e a data da ultima atualizacao
            BEGIN
              UPDATE craprac SET vlsldatl = rw_craprac.vlsldatl + vr_vlultren
                                ,dtatlsld = vr_dtmvtolt
                                ,vlslfmes = rw_craprac.vlsldatl + vr_vlultren
                                ,vlsldant = vr_vlsldant
                                ,dtsldant = vr_dtsldant
                           WHERE cdcooper = rw_craprac.cdcooper
                             AND nrdconta = rw_craprac.nrdconta
                             AND nraplica = rw_craprac.nraplica
                             AND craprac.rowid = rw_craprac.rowid
                       RETURNING vlsldatl, dtatlsld, vlslfmes, vlsldant, dtsldant, ROWID
                            INTO rw_craprac.vlsldatl, rw_craprac.dtatlsld, rw_craprac.vlslfmes,
                                 rw_craprac.vlsldant, rw_craprac.dtsldant, rw_craprac.rowid;                                                             

            EXCEPTION 
              WHEN OTHERS THEN
                -- Gerar erro e fazer rollback
                vr_dscritic := 'Erro ao atualizar aplicação(craprac). Detalhes: '||sqlerrm;
                RAISE vr_exc_erro;
            END;
           
            -- armazena a quantidade de titulos por produto
            vr_prod_captacao(rw_craprac.cdprodut).qtdtitat := vr_prod_captacao(rw_craprac.cdprodut).qtdtitat + 1;            

            -- armazena o valor da aplicacao
            vr_prod_captacao(rw_craprac.cdprodut).sldtitat := vr_prod_captacao(rw_craprac.cdprodut).sldtitat + rw_craprac.vlslfmes;


            -- Somente para a CECRED
            IF rw_craprac.cdcooper = 3 THEN -- armazena os saldo provisionado das aplicações das cooperativas singulares
              
              -- verifica a existencia de lancamentos
              OPEN cr_crapbnd(pr_cdcooper => rw_craprac.cdcooper
                             ,pr_dtmvtolt => vr_dtmvtolt
                             ,pr_nrdconta => rw_craprac.nrdconta);

              FETCH cr_crapbnd INTO rw_crapbnd;

                IF cr_crapbnd%NOTFOUND THEN
                  BEGIN
                   -- grava registro
                   INSERT INTO crapbnd (cdcooper
                                       ,dtmvtolt
                                       ,nrdconta
                                       ,vlaplprv)
                                VALUES (rw_craprac.cdcooper
                                       ,vr_dtmvtolt
                                       ,rw_craprac.nrdconta
                                       ,rw_craprac.vlslfmes);

                 EXCEPTION 
                   WHEN OTHERS THEN
                     CLOSE cr_crapbnd;
                     -- Gerar erro e fazer rollback
                     vr_dscritic := 'Erro ao inserir registro de aplicação(crapbnd). Detalhes: '||sqlerrm;
                     RAISE vr_exc_erro;
                 END;

                ELSE
                  BEGIN
                    -- atualiza registro
                    UPDATE crapbnd SET vlaplprv = vlaplprv + rw_craprac.vlslfmes
                     WHERE cdcooper = rw_craprac.cdcooper
                       AND dtmvtolt = rw_craprac.dtmvtolt
                       AND nrdconta = rw_craprac.nrdconta;

                  EXCEPTION 
                    WHEN OTHERS THEN
                      CLOSE cr_crapbnd;
                      -- Gerar erro e fazer rollback
                      vr_dscritic := 'Erro ao atualizar aplicação(craprac). Detalhes: '||sqlerrm;
                      RAISE vr_exc_erro;
                  END;

                END IF;

              CLOSE cr_crapbnd;  
              
              vr_flgrgprb := FALSE;            
            ELSE
              vr_flgrgprb := TRUE;  
            END IF;            

            -- grava os registros separados por conta do cooperado
            pc_registra_saldo_aplicacao(rw_craprac.nrdconta, vr_dtmvtolt, 0, rw_craprac.vlslfmes, rw_craprac.cdprodut, rw_craprac.cdcooper, TRUE);

            -- utliza esta variavel para registrar o saldo das aplicacoes 
            vr_cdcooper := 3;

            IF rw_craprac.qtdiaapl <= 90 THEN
              pc_registra_saldo_aplicacao(vr_tab_crapcop(rw_craprac.cdcooper).nrctactl,vr_dtmvtolt,90,rw_craprac.vlslfmes,rw_craprac.cdprodut,vr_cdcooper, vr_flgrgprb);
                
            ELSIF rw_craprac.qtdiaapl BETWEEN 91 AND 180  THEN
              pc_registra_saldo_aplicacao(vr_tab_crapcop(rw_craprac.cdcooper).nrctactl,vr_dtmvtolt,180,rw_craprac.vlslfmes,rw_craprac.cdprodut,vr_cdcooper, vr_flgrgprb);
                
            ELSIF rw_craprac.qtdiaapl BETWEEN 181 AND 270  THEN
              pc_registra_saldo_aplicacao(vr_tab_crapcop(rw_craprac.cdcooper).nrctactl,vr_dtmvtolt,270,rw_craprac.vlslfmes,rw_craprac.cdprodut,vr_cdcooper, vr_flgrgprb);
                
            ELSIF rw_craprac.qtdiaapl BETWEEN 271 AND 360  THEN
              pc_registra_saldo_aplicacao(vr_tab_crapcop(rw_craprac.cdcooper).nrctactl,vr_dtmvtolt,360,rw_craprac.vlslfmes,rw_craprac.cdprodut,vr_cdcooper, vr_flgrgprb);
                
            ELSIF rw_craprac.qtdiaapl BETWEEN 361 AND 720  THEN
              pc_registra_saldo_aplicacao(vr_tab_crapcop(rw_craprac.cdcooper).nrctactl,vr_dtmvtolt,720,rw_craprac.vlslfmes,rw_craprac.cdprodut,vr_cdcooper, vr_flgrgprb);
                
            ELSIF rw_craprac.qtdiaapl BETWEEN 721 AND 1080  THEN
              pc_registra_saldo_aplicacao(vr_tab_crapcop(rw_craprac.cdcooper).nrctactl,vr_dtmvtolt,1080,rw_craprac.vlslfmes,rw_craprac.cdprodut,vr_cdcooper, vr_flgrgprb);
                
            ELSIF rw_craprac.qtdiaapl BETWEEN 1081 AND 1440  THEN
              pc_registra_saldo_aplicacao(vr_tab_crapcop(rw_craprac.cdcooper).nrctactl,vr_dtmvtolt,1440,rw_craprac.vlslfmes,rw_craprac.cdprodut,vr_cdcooper, vr_flgrgprb);
                
            ELSIF rw_craprac.qtdiaapl BETWEEN 1441 AND 1800  THEN
              pc_registra_saldo_aplicacao(vr_tab_crapcop(rw_craprac.cdcooper).nrctactl,vr_dtmvtolt,1800,rw_craprac.vlslfmes,rw_craprac.cdprodut,vr_cdcooper, vr_flgrgprb);
                
            ELSIF rw_craprac.qtdiaapl BETWEEN 1801 AND 2160  THEN
              pc_registra_saldo_aplicacao(vr_tab_crapcop(rw_craprac.cdcooper).nrctactl,vr_dtmvtolt,2160,rw_craprac.vlslfmes,rw_craprac.cdprodut,vr_cdcooper, vr_flgrgprb);
                
            ELSIF rw_craprac.qtdiaapl BETWEEN 2161 AND 2520  THEN
              pc_registra_saldo_aplicacao(vr_tab_crapcop(rw_craprac.cdcooper).nrctactl,vr_dtmvtolt,2520,rw_craprac.vlslfmes,rw_craprac.cdprodut,vr_cdcooper, vr_flgrgprb);
                
            ELSIF rw_craprac.qtdiaapl BETWEEN 2521 AND 2880  THEN
              pc_registra_saldo_aplicacao(vr_tab_crapcop(rw_craprac.cdcooper).nrctactl,vr_dtmvtolt,2880,rw_craprac.vlslfmes,rw_craprac.cdprodut,vr_cdcooper, vr_flgrgprb);
                
            ELSIF rw_craprac.qtdiaapl BETWEEN 2881 AND 3240  THEN
              pc_registra_saldo_aplicacao(vr_tab_crapcop(rw_craprac.cdcooper).nrctactl,vr_dtmvtolt,3240,rw_craprac.vlslfmes,rw_craprac.cdprodut,vr_cdcooper, vr_flgrgprb);
                
            ELSIF rw_craprac.qtdiaapl BETWEEN 3241 AND 3600  THEN
              pc_registra_saldo_aplicacao(vr_tab_crapcop(rw_craprac.cdcooper).nrctactl,vr_dtmvtolt,3600,rw_craprac.vlslfmes,rw_craprac.cdprodut,vr_cdcooper, vr_flgrgprb);
                
            ELSIF rw_craprac.qtdiaapl BETWEEN 3961 AND 4320  THEN
              pc_registra_saldo_aplicacao(vr_tab_crapcop(rw_craprac.cdcooper).nrctactl,vr_dtmvtolt,4320,rw_craprac.vlslfmes,rw_craprac.cdprodut,vr_cdcooper, vr_flgrgprb);
                
            ELSIF rw_craprac.qtdiaapl BETWEEN 4321 AND 4680  THEN
              pc_registra_saldo_aplicacao(vr_tab_crapcop(rw_craprac.cdcooper).nrctactl,vr_dtmvtolt,4680,rw_craprac.vlslfmes,rw_craprac.cdprodut,vr_cdcooper, vr_flgrgprb);
                
            ELSIF rw_craprac.qtdiaapl BETWEEN 4681 AND 5400  THEN
              pc_registra_saldo_aplicacao(vr_tab_crapcop(rw_craprac.cdcooper).nrctactl,vr_dtmvtolt,5400,rw_craprac.vlslfmes,rw_craprac.cdprodut,vr_cdcooper, vr_flgrgprb);
                
            ELSIF rw_craprac.qtdiaapl >= 5401 THEN
              pc_registra_saldo_aplicacao(vr_tab_crapcop(rw_craprac.cdcooper).nrctactl,vr_dtmvtolt,5401,rw_craprac.vlslfmes,rw_craprac.cdprodut,vr_cdcooper, vr_flgrgprb);
            END IF;            
                      
          END IF;

    END LOOP;
    

    -- Verifica se há registros a processar
    IF vr_tab_crapcpc.COUNT() > 0 THEN
    
      -- pega o primeiro indice da pltable
      vr_cdprodut := vr_tab_crapcpc.first; -- recupera o codigo do produto
        
      LOOP    
      
        -- MONTA TOTALIZADORES DO RELATORIO: RESUMO MENSAL - NOVOS PRODUTOS CAPTACAO
        FOR rw_craplac_rel IN cr_craplac_rel(pr_cdcooper => pr_cdcooper, pr_dtmvtolt => vr_dtmvtolt, pr_cdprodut => vr_cdprodut)
          LOOP
            
             -- quantidade de titulos aplicados no mes, valor total aplicado no mes
             IF rw_craplac_rel.cdhistor = vr_tab_crapcpc(vr_cdprodut).cdhsraap OR rw_craplac_rel.cdhistor = vr_tab_crapcpc(vr_cdprodut).cdhsnrap THEN
                -- contabiliza quantidade
                vr_prod_captacao(vr_cdprodut).qtdtitap := vr_prod_captacao(vr_cdprodut).qtdtitap + 1;
                -- contabiliza valor
                vr_prod_captacao(vr_cdprodut).vlrtotap := vr_prod_captacao(vr_cdprodut).vlrtotap + rw_craplac_rel.vllanmto;            
             END IF;
             
             -- rendimento creditado no mes
             IF rw_craplac_rel.cdhistor = vr_tab_crapcpc(vr_cdprodut).cdhsrdap THEN
                vr_prod_captacao(vr_cdprodut).rencreme := vr_prod_captacao(vr_cdprodut).rencreme + rw_craplac_rel.vllanmto;                       
             END IF;
             
             -- valor total da provisao do mes
             IF rw_craplac_rel.cdhistor = vr_tab_crapcpc(vr_cdprodut).cdhsprap THEN
                vr_prod_captacao(vr_cdprodut).vlrtotpr := vr_prod_captacao(vr_cdprodut).vlrtotpr + rw_craplac_rel.vllanmto;                       
             END IF;
             
             -- ajuste de provisao no mes
             IF rw_craplac_rel.cdhistor = vr_tab_crapcpc(vr_cdprodut).cdhsrvap THEN
                vr_prod_captacao(vr_cdprodut).ajtprome := vr_prod_captacao(vr_cdprodut).ajtprome + rw_craplac_rel.vllanmto;                       
             END IF;
             
             -- resgates dos titulos vencidos no mes
             IF rw_craplac_rel.cdhistor = vr_tab_crapcpc(vr_cdprodut).cdhsvtap THEN
                vr_prod_captacao(vr_cdprodut).restitve := vr_prod_captacao(vr_cdprodut).restitve + rw_craplac_rel.vllanmto;                       
             END IF;
             
             -- saques
             IF rw_craplac_rel.cdhistor = vr_tab_crapcpc(vr_cdprodut).cdhsrgap THEN
                IF rw_craplac_rel.vlrendim > 0 THEN -- saques com rendimento
                   vr_prod_captacao(vr_cdprodut).saqcomre := vr_prod_captacao(vr_cdprodut).saqcomre + rw_craplac_rel.vllanmto;
                ELSIF rw_craplac_rel.vlrendim <= 0 THEN -- saques sem rendimento
                   vr_prod_captacao(vr_cdprodut).saqsemre := vr_prod_captacao(vr_cdprodut).saqsemre + rw_craplac_rel.vllanmto;
                END IF; 
             END IF;

             -- IPRF
             IF rw_craplac_rel.cdhistor = vr_tab_crapcpc(vr_cdprodut).cdhsirap THEN
                vr_prod_captacao(vr_cdprodut).imprenrf := vr_prod_captacao(vr_cdprodut).imprenrf + rw_craplac_rel.vllanmto;                       
             END IF;
          
        END LOOP;  
         
        -- Verifica se e o ultimo registro da pltable        
        IF vr_cdprodut = vr_prod_captacao.last THEN
          EXIT;
        ELSE
         vr_cdprodut := vr_prod_captacao.NEXT(vr_cdprodut);
         CONTINUE;
        END IF;    
          
      END LOOP;      
     
    END IF; -- valida registros da crapcpc  

    -- MONTA TOTALIZADORES DE DETALHAMENTO DA PROVISAO POR COOPERATIVA    
    IF pr_cdcooper = 3 THEN    
       
      -- Verifica se há registros para processar
      IF vr_tab_crapcpc.count() > 0 THEN    
        -- pega o primeiro indice da pltable
        vr_cdprodut := vr_tab_crapcpc.first; -- recupera o codigo do produto
        
        LOOP
          -- Se há registros para processar
          IF vr_tab_crapcop.count() > 0 THEN          
          
            -- pega o primeiro indice da pltable
            vr_cdcooper := vr_tab_crapcop.first; -- recupera o codigo da cooperativa  
              
            LOOP
              
              -- Listar somente singulares
              IF vr_cdcooper <> 3 THEN 
                -- armazena o numero da conta da cooperativa na CECRED
                vr_prov_coopera(vr_cdprodut)(vr_cdcooper).nrdconta := vr_tab_crapcop(vr_cdcooper).nrctactl;
                -- armazena o nome da cooperativa
                vr_prov_coopera(vr_cdprodut)(vr_cdcooper).titconta := vr_tab_crapcop(vr_cdcooper).nmrescop; 
          
                FOR rw_craplac_rel IN cr_craplac_rel(pr_cdcooper => vr_cdcooper, pr_dtmvtolt => vr_dtmvtolt, pr_cdprodut => vr_cdprodut)
                  LOOP
                            
                  -- contabiliza quantidade de titulos
                  vr_prov_coopera(vr_cdprodut)(vr_cdcooper).qtdtitul := NVL(vr_prov_coopera(vr_cdprodut)(vr_cdcooper).qtdtitul, 0) + 1;            
                  
                  -- rendimento creditado no mes
                  IF rw_craplac_rel.cdhistor = vr_tab_crapcpc(vr_cdprodut).cdhsrdap THEN
                     vr_prov_coopera(vr_cdprodut)(vr_cdcooper).sldrendi := NVL(vr_prov_coopera(vr_cdprodut)(vr_cdcooper).sldrendi,0) + rw_craplac_rel.vllanmto;
                  END IF;
                  
                  -- valor total da provisao do mes
                  IF rw_craplac_rel.cdhistor = vr_tab_crapcpc(vr_cdprodut).cdhsprap THEN
                     vr_prov_coopera(vr_cdprodut)(vr_cdcooper).totprovi := NVL(vr_prov_coopera(vr_cdprodut)(vr_cdcooper).totprovi,0) + rw_craplac_rel.vllanmto;                                                      
                  END IF;
				  
                  -- ajuste de provisao no mes
                  IF rw_craplac_rel.cdhistor = vr_tab_crapcpc(vr_cdprodut).cdhsrvap THEN
                     vr_prov_coopera(vr_cdprodut)(vr_cdcooper).ajuprovi := NVL(vr_prov_coopera(vr_cdprodut)(vr_cdcooper).ajuprovi,0) + rw_craplac_rel.vllanmto;
                  END IF;          
                  
                END LOOP;
              END IF;
              
              -- Verifica se e o ultimo registro da pltable        
              IF vr_cdcooper = vr_tab_crapcop.last THEN
                EXIT;
              ELSE
               vr_cdcooper := vr_tab_crapcop.NEXT(vr_cdcooper);
               CONTINUE;
              END IF;    
            
            END LOOP;
          
          END IF;
              
          -- Verifica se e o ultimo registro da pltable        
          IF vr_cdprodut = vr_tab_crapcpc.last THEN
            EXIT;
          ELSE
            vr_cdprodut := vr_tab_crapcpc.NEXT(vr_cdprodut);
            CONTINUE;
          END IF;    
          
        END LOOP;
        
      END IF; -- Se há registros na vr_tab_crapcpc          
                             
    END IF;  
      
    
    -- MONTA XML DE DADOS
    
    -- Se há dados
    IF vr_prod_captacao.count() > 0 THEN    
    
      -- pega o primeiro indice da pltable
      vr_cdprodut := vr_prod_captacao.first; -- recupera o codigo do produto

      pc_escreve_xml('<cooperativa id="'||pr_cdcooper||'">');  
            
      LOOP 
        
        IF vr_prod_captacao(vr_cdprodut).qtdtitat > 0 THEN      
        
          pc_escreve_xml('<produto id="'|| vr_cdprodut ||'" dsprodut="'||vr_tab_crapcpc(vr_cdprodut).nmprodut||'">');
          
          -- ESCREVE DADOS NO XML REFERENTE AOS VALORES TOTAIS
          pc_escreve_xml('<resumo>'||
                         '<qtdtitat>' || TO_CHAR(vr_prod_captacao(vr_cdprodut).qtdtitat, '') || '</qtdtitat>' ||
                         '<qtdtitap>' || TO_CHAR(vr_prod_captacao(vr_cdprodut).qtdtitap, '') || '</qtdtitap>' ||
                         '<sldtitat>' || TO_CHAR(vr_prod_captacao(vr_cdprodut).sldtitat, '999G999G990D00') || '</sldtitat>' ||
                         '<vlrtotap>' || TO_CHAR(vr_prod_captacao(vr_cdprodut).vlrtotap, '999G999G990D00') || '</vlrtotap>' ||
                         '<rencreme>' || TO_CHAR(vr_prod_captacao(vr_cdprodut).rencreme, '999G999G990D00') || '</rencreme>' ||
                         '<vlrtotpr>' || TO_CHAR(vr_prod_captacao(vr_cdprodut).vlrtotpr, '999G999G990D00') || '</vlrtotpr>' ||
                         '<ajtprome>' || TO_CHAR(vr_prod_captacao(vr_cdprodut).ajtprome, '999G999G990D00') || '</ajtprome>' ||
                         '<restitve>' || TO_CHAR(vr_prod_captacao(vr_cdprodut).restitve, '999G999G990D00') || '</restitve>' ||
                         '<saqsemre>' || TO_CHAR(vr_prod_captacao(vr_cdprodut).saqsemre, '999G999G990D00') || '</saqsemre>' ||
                         '<saqcomre>' || TO_CHAR(vr_prod_captacao(vr_cdprodut).saqcomre, '999G999G990D00') || '</saqcomre>' ||
                         '<imprenrf>' || TO_CHAR(vr_prod_captacao(vr_cdprodut).imprenrf, '999G999G990D00') || '</imprenrf></resumo>');
          

          pc_escreve_xml('<prazos>');
          
          -- Se há dados
          IF vr_vet_prazo.COUNT() > 0 THEN
            
            vr_nrdprazo := vr_vet_prazo.first;
            vr_vlrvalac := 0; 
            
            LOOP

              -- Verifica a existencia de registros
              IF vr_prazcaptacao(vr_cdprodut).exists(vr_vet_prazo(vr_nrdprazo)) THEN

                  vr_vlrvalac := vr_vlrvalac + vr_prazcaptacao(vr_cdprodut)(vr_vet_prazo(vr_nrdprazo)).vlrvalac;
                
                  pc_escreve_xml('<prazo mes_referencia="'||TRIM(TO_CHAR(SYSDATE,'Month','NLS_DATE_LANGUAGE=PORTUGUESE')||'/'||TO_CHAR(SYSDATE,'YYYY'))||'" id="' || TO_CHAR(vr_vet_prazo(vr_nrdprazo), 'FM9999') || '">' ||
                                 '<vlrvalor>' || TO_CHAR(vr_prazcaptacao(vr_cdprodut)(vr_vet_prazo(vr_nrdprazo)).vlrvalor, '999G999G990D00') || '</vlrvalor>' ||
                                 '<vlrvalac>' || TO_CHAR(vr_vlrvalac, '999G999G990D00') || '</vlrvalac>' ||                           
                                 '<quantida>' || TO_CHAR(vr_prazcaptacao(vr_cdprodut)(vr_vet_prazo(vr_nrdprazo)).quantida, 'FM9999') || '</quantida>' ||
                                 '</prazo>');         
              ELSE  
                  pc_escreve_xml('<prazo mes_referencia="'||TRIM(TO_CHAR(SYSDATE,'Month','NLS_DATE_LANGUAGE=PORTUGUESE')||'/'||TO_CHAR(SYSDATE,'YYYY'))||'" id="' || TO_CHAR(vr_vet_prazo(vr_nrdprazo), 'FM9999') || '">' ||
                                 '<vlrvalor>0,00</vlrvalor>' ||
                                 '<vlrvalac>' || TO_CHAR(vr_vlrvalac, '999G999G990D00') || '</vlrvalac>' ||                           
                                 '<quantida>0</quantida>' ||
                                 '</prazo>');
              END IF;
            
            
              EXIT WHEN vr_nrdprazo = vr_vet_prazo.last;
              vr_nrdprazo := vr_vet_prazo.NEXT(vr_nrdprazo);             
             
            END LOOP;
            
          END IF;        
          
          pc_escreve_xml('</prazos>');        
          
          IF pr_cdcooper = 3 THEN
            
            -- Verifica a existencia de registros
            IF vr_prov_coopera.exists(vr_cdprodut) THEN
                
              --Se há dados
              IF vr_prov_coopera(vr_cdprodut).COUNT() > 0 THEN          
            
                vr_cdcooper := vr_prov_coopera(vr_cdprodut).first; -- recupera o codigo da cooperativa

                pc_escreve_xml('<provisoes>');
                
                LOOP
                  
                  pc_escreve_xml('<provisao id="' || TO_CHAR(vr_cdcooper) || '">' ||              
                                 '<nrdconta>' || TO_CHAR(vr_prov_coopera(vr_cdprodut)(vr_cdcooper).nrdconta) || '</nrdconta>' ||
                                 '<titconta>' || TO_CHAR(vr_prov_coopera(vr_cdprodut)(vr_cdcooper).titconta) || '</titconta>' ||
                                 '<qtdtitul>' || TO_CHAR(vr_prov_coopera(vr_cdprodut)(vr_cdcooper).qtdtitul, 'FM9999') || '</qtdtitul>' ||
                                 '<sldrendi>' || TO_CHAR(vr_prov_coopera(vr_cdprodut)(vr_cdcooper).sldrendi, '999G999G990D00') || '</sldrendi>' ||
                                 '<ajuprovi>' || TO_CHAR(vr_prov_coopera(vr_cdprodut)(vr_cdcooper).ajuprovi, '999G999G990D00') || '</ajuprovi>' ||
                                 '<totprovi>' || TO_CHAR(vr_prov_coopera(vr_cdprodut)(vr_cdcooper).totprovi, '999G999G990D00') || '</totprovi>' ||                             
                                 '</provisao>');
                                   
                  vr_totqtdti := vr_totqtdti + vr_prov_coopera(vr_cdprodut)(vr_cdcooper).qtdtitul;
                  vr_totsldre := vr_totsldre + vr_prov_coopera(vr_cdprodut)(vr_cdcooper).sldrendi;
                  vr_totajupr := vr_totajupr + vr_prov_coopera(vr_cdprodut)(vr_cdcooper).ajuprovi;   
                  vr_totaprov := vr_totaprov + vr_prov_coopera(vr_cdprodut)(vr_cdcooper).totprovi;                         
                                 
                  -- Sai se e o ultimo registro da pltable
                  EXIT WHEN vr_cdcooper = vr_prov_coopera(vr_cdprodut).last;
                  vr_cdcooper := vr_prov_coopera(vr_cdprodut).NEXT(vr_cdcooper);     
                       
                END LOOP;

              END IF;         
              
              pc_escreve_xml('<totqtdti>'|| TO_CHAR(vr_totqtdti, 'FM99999') ||'</totqtdti>');
              pc_escreve_xml('<totsldre>'|| TO_CHAR(vr_totsldre, '999G999G990D00') ||'</totsldre>');
              pc_escreve_xml('<totajupr>'|| TO_CHAR(vr_totajupr, '999G999G990D00') ||'</totajupr>');
              pc_escreve_xml('<totaprov>'|| TO_CHAR(vr_totaprov, '999G999G990D00') ||'</totaprov>');
              
              pc_escreve_xml('</provisoes>');
              
            END IF;
            
          END IF;
    
          pc_escreve_xml('</produto>');
          
        END IF;
          
        -- Sai se e o ultimo registro da pltable        
        EXIT WHEN vr_cdprodut = vr_prod_captacao.last;
        vr_cdprodut := vr_prod_captacao.NEXT(vr_cdprodut);     
        
      END LOOP;    
      -- fecha a TAG de agrupamento por cooperativa
      pc_escreve_xml('</cooperativa>');

    END IF;    
    
    -- FECHA TAG PRINCIPAL DO ARQUIVO XML
    pc_escreve_xml('</raiz>');


    -- SOLICITACAO DO RELATORIO
    gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,         --> Cooperativa
                                pr_cdprogra  => vr_cdprogra,         --> Programa chamador
                                pr_dtmvtolt  => vr_dtmvtolt,         --> Data do movimento atual
                                pr_dsxml     => vr_clobxml,          --> Arquivo XML de dados
                                pr_dsxmlnode => '/raiz/cooperativa/produto', --> Nó do XML para iteração
                                pr_dsjasper  => 'crrl678.jasper',    --> Arquivo de layout do iReport
                                pr_dsparams  => '',                  --> Array de parametros diversos
                                pr_dsarqsaid => vr_dsarquiv,         --> Path/Nome do arquivo PDF gerado
                                pr_flg_gerar => 'N',                 --> Gerar o arquivo na hora*
                                pr_qtcoluna  => 132,                 --> Qtd colunas do relatório (80,132,234)
                                pr_sqcabrel  => 1,                   --> Indicado de seq do cabrel
                                pr_flg_impri => 'S',                 --> Chamar a impressão (Imprim.p)*
                                pr_nmformul  => '',                  --> Nome do formulário para impressão
                                pr_nrcopias  => 1,                   --> Qtd de cópias
                                pr_flappend  => 'N',                 --> Indica que a solicitação irá incrementar o arquivo
                                pr_des_erro  => vr_dscritic);        --> Saída com erro

    -- VERIFICA SE OCORREU UMA CRITICA */
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

                                     
    -- LIBERA A MEMORIA ALOCADA P/ VARIAVE CLOB
    dbms_lob.close(vr_clobxml);
    dbms_lob.freetemporary(vr_clobxml);
    

    ----------------- ENCERRAMENTO DO PROGRAMA -------------------

    -- Processo OK, devemos chamar a fimprg
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);    
   
    COMMIT;
    --ROLLBACK;
         
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 THEN
          -- Buscar a descrição
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        ELSE
          pr_cdcritic := 0;
          pr_dscritic := vr_dscritic;            
        END IF;
        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
        -- Efetuar rollback
        ROLLBACK;
    END;

END pc_crps685;
/

