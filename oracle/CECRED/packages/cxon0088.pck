create or replace package cecred.CXON0088 is

  /*---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : CXON0088
  --  Sistema  : Estorno de Depositos Cheques Intercooperativas
  --  Sigla    : CRED
  --  Autor    : Guilherme/SUPERO
  --  Data     : Julho/2014                    Ultima atualizacao: 20/06/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Estorno de Depositos Cheques Intercooperativas
  --
  -- Alterações: 10/06/2016 - Ajuste para utilizar o UPPER em campos de indice que utilizam UPPER
  --                         (Adriano - SD 463762).     
  --
  --             20/06/2016 - Correcao para o uso da procedure fn_busca_dstextabem da TABE0001 em 
  --                          varias procedures desta package.(Carlos Rafael Tanholi). 
  --
  ---------------------------------------------------------------------------------------------------------------*/

  /* Retona o lancamento para exibir na tela conforme o nro do documento */
  TYPE typ_rec_lancamento IS
    RECORD(tpdocmto NUMBER(4)
          ,dtmvtolt DATE
          ,vllanmto NUMBER(13,2));

  /* Retona o lancamento para exibir na tela conforme o nro do documento */
  TYPE typ_tab_lancamento IS
    TABLE OF typ_rec_lancamento
    INDEX BY PLS_INTEGER;

  /* Procedure de validacao do documento que será estornado pela rotina 88 -- Procedure usada no Oracle */
  PROCEDURE pc_valida_chq_captura(pr_cooper         IN VARCHAR2    --> Coop. Origem
                                 ,pr_cod_agencia    IN INTEGER     --> Cod. Agencia
                                 ,pr_nro_caixa      IN INTEGER     --> Nro Caixa
                                 ,pr_cooper_dest    IN VARCHAR2    --> Coop. Destino
                                 ,pr_nro_conta      IN INTEGER     --> Nro Conta
                                 ,pr_nro_docmto     IN INTEGER     --> Nrd Documento
                                 ,pr_dsidenti       OUT VARCHAR2   --> Identificacao
                                 ,pr_nom_titular    OUT VARCHAR2   --> Nome do titular
                                 ,pr_poupanca       OUT INTEGER    --> Retorna se for Conta Poupanca
                                 ,pr_valor_coop     OUT NUMBER     --> Valor Coop
                                 ,pr_retorno        OUT VARCHAR2   --> Retorna OK/NOK
                                 ,pr_tab_lancamento OUT typ_tab_lancamento --> Retorna temp-table
                                 ,pr_cdcritic       OUT INTEGER    --> Cod. Critica
                                 ,pr_dscritic       OUT VARCHAR2); --> Des. da Critica

  /* Procedure de validacao do documento que será estornado pela rotina 88 -- Procedure usada no Progress */
  PROCEDURE pc_valida_chq_captura_wt(pr_cooper      IN VARCHAR2    --> Coop. Origem
                                    ,pr_cod_agencia IN INTEGER     --> Cod. Agencia
                                    ,pr_nro_caixa   IN INTEGER     --> Nro Caixa
                                    ,pr_cooper_dest IN VARCHAR2    --> Coop. Destino
                                    ,pr_nro_conta   IN INTEGER     --> Nro Conta
                                    ,pr_nro_docmto  IN INTEGER     --> Nrd Documento
                                    ,pr_dsidenti    OUT VARCHAR2   --> Identificacao
                                    ,pr_nom_titular OUT VARCHAR2   --> Nome do titular
                                    ,pr_poupanca    OUT INTEGER    --> Retorna se for Conta Poupanca
                                    ,pr_valor_coop  OUT NUMBER     --> Valor Coop
                                    ,pr_retorno     OUT VARCHAR2   --> Retorna OK/NOK
                                    ,pr_cdcritic    OUT INTEGER    --> Cod. Critica
                                    ,pr_dscritic    OUT VARCHAR2); --> Des. da Critica

  /* Procedure que Estorna de Depositos em Cheques Intercooperativas */
  PROCEDURE pc_estorna_dep_chq_captura(pr_cooper       IN VARCHAR2   --> Coop. Origem
                                      ,pr_cod_agencia  IN INTEGER    --> Cod. Agencia
                                      ,pr_nro_caixa    IN INTEGER    --> Nro Caixa
                                      ,pr_cod_operador IN VARCHAR2   --> Cod Operador
                                      ,pr_cooper_dest  IN VARCHAR2   --> Coop. Destino
                                      ,pr_nro_conta    IN INTEGER    --> Nro Conta
                                      ,pr_nro_docmto   IN INTEGER    --> Nrd Documento
                                      ,pr_valor_coop   IN NUMBER     --> Valor Coop
                                      ,pr_vestorno     IN INTEGER    --> Flag Estorno(1-TRUE/0-FALSE)
                                      ,pr_valor       OUT NUMBER     --> Valor do lancamento
                                      ,pr_retorno     OUT VARCHAR2   --> Retorna OK/NOK
                                      ,pr_cdcritic    OUT INTEGER    --> Cod. Critica
                                      ,pr_dscritic    OUT VARCHAR2); --> Des. da Critica

end CXON0088;
/
CREATE OR REPLACE PACKAGE BODY CECRED.CXON0088 IS

   /*---------------------------------------------------------------------------------------------------------------
   --
   --  Programa : CXON0088
   --  Sistema  : Estorno de Depositos Cheques Intercooperativas
   --  Sigla    : CRED
   --  Autor    : Guilherme/SUPERO
   --  Data     : Julho/2014                    Ultima atualizacao: 23/06/2016
   --
   -- Dados referentes ao programa:
   --
   -- Frequencia: -----
   -- Objetivo  : Estorno de Depositos Cheques Intercooperativas
   --
   -- Alterações: 10/06/2016 - Ajuste para utilizar o UPPER em campos de indice que utilizam UPPER
   --                         (Adriano - SD 463762).     
   --
  --              20/06/2016 - Correcao para o uso da procedure fn_busca_dstextab da TABE0001 em 
  --                           varias procedures desta package.(Carlos Rafael Tanholi). 
  --
  --              23/06/2016 - Correcao no cursor da crapbcx utilizando o indice correto
	--                         	 sobre o campo cdopecxa.(Carlos Rafael Tanholi). 				             
  --
  --              15/11/2016 - Correcao na agencia usada para buscar os lançamento de destino 
	--                         	 (Andre Bohn - Mout'S). 				             
  --
   ---------------------------------------------------------------------------------------------------------------*/

   PROCEDURE pc_valida_chq_captura(pr_cooper         IN VARCHAR2            --> Coop. Origem
                                  ,pr_cod_agencia    IN INTEGER             --> Cod. Agencia
                                  ,pr_nro_caixa      IN INTEGER             --> Nro Caixa
                                  ,pr_cooper_dest    IN VARCHAR2            --> Coop. Destino
                                  ,pr_nro_conta      IN INTEGER             --> Nro Conta
                                  ,pr_nro_docmto     IN INTEGER             --> Nrd Documento
                                  ,pr_dsidenti       OUT VARCHAR2           --> Identificacao
                                  ,pr_nom_titular    OUT VARCHAR2           --> Nome do titular
                                  ,pr_poupanca       OUT INTEGER            --> Retorna se for Conta Poupanca
                                  ,pr_valor_coop     OUT NUMBER             --> Valor Coop
                                  ,pr_retorno        OUT VARCHAR2           --> Retorna OK/NOK
                                  ,pr_tab_lancamento OUT typ_tab_lancamento --> Retorna temp-table
                                  ,pr_cdcritic       OUT INTEGER            --> Cod. Critica
                                  ,pr_dscritic       OUT VARCHAR2) IS       --> Des. da Critica
   ---------------------------------------------------------------------------------------------------------------
   --
   --  Programa : pc_valida_chq_captura Fonte: dbo/b1crap88.p/valida-cheque-com-captura
   --  Sistema  : Estorno de Depositos Cheques Intercooperativas
   --  Sigla    : CRED
   --  Autor    : Andre Santos - SUPERO
   --  Data     : Junho/2014.                   Ultima atualizacao:
   --
   -- Dados referentes ao programa:
   --
   -- Frequencia: -----
   -- Objetivo  :

   -- Alteracoes: 20/02/2018 - Alterada verificação de cdtipcta = 6 e 7 por modalidade = 3.
   --                          PRJ366 (Lombardi).
   --
   ---------------------------------------------------------------------------------------------------------------

   /* Busca o codigo da Coop. passando como parametro o nome resumido da Coop. */
   CURSOR cr_cod_coop_orig(p_nmrescop IN VARCHAR2) IS
     SELECT cop.cdcooper
           ,cop.cdagectl
           ,cop.cdagebcb
           ,cop.cdbcoctl
           ,cop.cdagedbb
           ,cop.nmrescop
           ,cop.nmextcop
       FROM crapcop cop
      WHERE UPPER(cop.nmrescop) = UPPER(p_nmrescop) ;
   rw_cod_coop_orig cr_cod_coop_orig%ROWTYPE;

   /* Busca o codigo da Coop. passando como parametro o nome resumido da Coop. */
   CURSOR cr_cod_coop_dest(p_nmrescop IN VARCHAR2) IS
     SELECT cop.cdcooper
           ,cop.cdagectl
           ,cop.cdagebcb
           ,cop.cdbcoctl
           ,cop.cdagedbb
           ,cop.nmrescop
       FROM crapcop cop
      WHERE UPPER(cop.nmrescop) = UPPER(p_nmrescop);

   rw_cod_coop_dest cr_cod_coop_dest%ROWTYPE;

   /* Busca a Data Conforme o Código da Cooperativa */
   CURSOR cr_dat_cop(p_coop IN INTEGER)IS
      SELECT dat.dtmvtolt
            ,dat.dtmvtocd
        FROM crapdat dat
       WHERE dat.cdcooper = p_coop;
   rw_dat_cop cr_dat_cop%ROWTYPE;

   /* Verifica Associado de Destino */
   CURSOR cr_verifica_ass(p_cdcooper IN INTEGER
                         ,p_nrdconta IN INTEGER)IS
      SELECT ass.nrdconta
            ,ass.nmprimtl
            ,tpcta.cdmodalidade_tipo cdmodali
        FROM crapass ass
            ,tbcc_tipo_conta tpcta
       WHERE ass.cdcooper = p_cdcooper
         AND ass.nrdconta = p_nrdconta
         AND tpcta.inpessoa = ass.inpessoa
         AND tpcta.cdtipo_conta = ass.cdtipcta;
   rw_verifica_ass cr_verifica_ass%ROWTYPE;

   /* Verifica se existe LCM de CREDITO / CHEQUE COOP */
   CURSOR cr_verifica_lcm1(p_cdcooper IN INTEGER
                         ,p_dtmvtolt IN DATE
                         ,p_cdagenci IN INTEGER
                         ,p_cdbccxlt IN INTEGER
                         ,p_nrdolote IN INTEGER
                         ,p_nrdctabb IN INTEGER
                         ,p_nrdocmto IN INTEGER) IS
      SELECT lcm.nrdocmto
            ,lcm.cdpesqbb
            ,lcm.dsidenti
            ,lcm.vllanmto
            ,lcm.dtmvtolt
            ,lcm.nrseqdig
        FROM craplcm lcm
       WHERE lcm.cdcooper = p_cdcooper
         AND lcm.dtmvtolt = p_dtmvtolt
         AND lcm.cdagenci = p_cdagenci
         AND lcm.cdbccxlt = p_cdbccxlt
         AND lcm.nrdolote = p_nrdolote
         AND lcm.nrdctabb = p_nrdctabb
         AND lcm.nrdocmto = p_nrdocmto;
   rw_verifica_lcm1 cr_verifica_lcm1%ROWTYPE;

   /* Verifica se existe LCM de CREDITO / CHEQUE FORA */
   CURSOR cr_verifica_lcm(p_cdcooper IN INTEGER
                         ,p_dtmvtolt IN DATE
                         ,p_cdagenci IN INTEGER
                         ,p_cdbccxlt IN INTEGER
                         ,p_nrdolote IN INTEGER
                         ,p_nrdctabb IN INTEGER) IS
      SELECT lcm.nrdocmto
            ,lcm.cdpesqbb
            ,lcm.dsidenti
            ,lcm.vllanmto
            ,lcm.dtmvtolt
            ,lcm.nrseqdig
            ,lcm.cdcooper
            ,lcm.nrdconta
            ,lcm.cdagenci
            ,lcm.cdbccxlt
            ,lcm.nrdolote
        FROM craplcm lcm
       WHERE lcm.cdcooper = p_cdcooper
         AND lcm.dtmvtolt = p_dtmvtolt
         AND lcm.cdagenci = p_cdagenci
         AND lcm.cdbccxlt = p_cdbccxlt
         AND lcm.nrdolote = p_nrdolote
         AND lcm.nrdctabb = p_nrdctabb;
   rw_verifica_lcm cr_verifica_lcm%ROWTYPE;

   /* Verifica Deposito Bloqueado */
   CURSOR cr_verifica_dpb(p_cdcooper IN INTEGER
                         ,p_dtmvtolt IN DATE
                         ,p_cdagenci IN INTEGER
                         ,p_cdbccxlt IN INTEGER
                         ,p_nrdolote IN INTEGER
                         ,p_nrdconta IN INTEGER
                         ,p_nrdocmto IN INTEGER) IS
     SELECT dpb.inlibera
           ,dpb.dtliblan
       FROM crapdpb dpb
      WHERE dpb.cdcooper = p_cdcooper
        AND dpb.dtmvtolt = p_dtmvtolt
        AND dpb.cdagenci = p_cdagenci
        AND dpb.cdbccxlt = p_cdbccxlt
        AND dpb.nrdolote = p_nrdolote
        AND dpb.nrdconta = p_nrdconta
        AND dpb.nrdocmto = p_nrdocmto;
   rw_verifica_dpb cr_verifica_dpb%ROWTYPE;

   CURSOR cr_verifica_chd(p_cdcooper IN INTEGER
                         ,p_dtmvtolt IN DATE
                         ,p_cdagenci IN INTEGER
                         ,p_cdbccxlt IN INTEGER
                         ,p_nrdolote IN INTEGER
                         ,p_nrdocmto IN INTEGER
                         ,p_nrseqdig IN INTEGER)IS
      SELECT chd.insitprv
        FROM crapchd chd
       WHERE chd.cdcooper = p_cdcooper
         AND chd.dtmvtolt = p_dtmvtolt
         AND chd.cdagenci = p_cdagenci
         AND chd.cdbccxlt = p_cdbccxlt
         AND chd.nrdolote = p_nrdolote
         AND chd.nrdocmto LIKE p_nrdocmto||'%'
         AND chd.nrseqdig = p_nrseqdig;
   rw_verifica_chd cr_verifica_chd%ROWTYPE;

   -- Variaveis Erro
   vr_cdcritic crapcri.cdcritic%TYPE;
   vr_dscritic VARCHAR2(4000);
   vr_exc_erro EXCEPTION;

   -- Variaveis
   vr_l_achou_horario_corte BOOLEAN := FALSE;
   vr_existe_reg            BOOLEAN := FALSE;
   vr_aux_lscontas VARCHAR2(200)    := '';
   vr_l_achou BOOLEAN               := FALSE;
   vr_c_docto VARCHAR2(200)         := '';
   vr_aux_cdcooper INTEGER          := 0;
   vr_aux_cdagenci INTEGER          := 0;
   vr_aux_cdbccxlt INTEGER          := 0;
   vr_i_nro_lote   INTEGER          := 0;
   vr_aux_cdpesqbb VARCHAR(100)     := 0;
   vr_flg_exetrunc BOOLEAN          := FALSE;
   vr_index        INTEGER          := 0;

   -- Guardar registro dstextab
   vr_dstextab craptab.dstextab%TYPE;

   BEGIN

      -- Busca Cod. Coop de ORIGEM
      OPEN cr_cod_coop_orig(pr_cooper);
      FETCH cr_cod_coop_orig INTO rw_cod_coop_orig;
      CLOSE cr_cod_coop_orig;

      -- Busca Cod. Coop de DESTINO
      OPEN cr_cod_coop_dest(pr_cooper_dest);
      FETCH cr_cod_coop_dest INTO rw_cod_coop_dest;
      CLOSE cr_cod_coop_dest;

      -- Inicializa variaveis
      pr_poupanca              := 0;
      pr_nom_titular           := '';
      pr_valor_coop            := 0;
      vr_l_achou_horario_corte := FALSE;

      -- Elimina os erros existentes do operador do caixa
      CXON0000.pc_elimina_erro(pr_cooper     => rw_cod_coop_orig.cdcooper
                             ,pr_cod_agencia => pr_cod_agencia
                             ,pr_nro_caixa   => pr_nro_caixa
                             ,pr_cdcritic    => vr_cdcritic
                             ,pr_dscritic    => vr_dscritic);
      -- Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
         cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                              ,pr_cdagenci => pr_cod_agencia
                              ,pr_nrdcaixa => pr_nro_caixa
                              ,pr_cod_erro => vr_cdcritic
                              ,pr_dsc_erro => vr_dscritic
                              ,pr_flg_erro => TRUE
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic);

         IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := vr_dscritic;
            RAISE vr_exc_erro;
         END IF;

         pr_cdcritic := vr_cdcritic;
         pr_dscritic := vr_dscritic;
         RAISE vr_exc_erro;

         RAISE vr_exc_erro;
      END IF;

      -- Busca Data do Sistema
      OPEN cr_dat_cop(rw_cod_coop_orig.cdcooper);
      FETCH cr_dat_cop INTO rw_dat_cop;
      CLOSE cr_dat_cop;

      -- Verifica se o numero do docmto foi informado
      IF NVL(pr_nro_docmto,0) = 0 OR LENGTH(pr_nro_docmto) <> 5 THEN
         pr_cdcritic := 22;  /* Documento deve ser Informado */
         pr_dscritic := '';
         cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                               ,pr_cdagenci => pr_cod_agencia
                               ,pr_nrdcaixa => pr_nro_caixa
                               ,pr_cod_erro => pr_cdcritic
                               ,pr_dsc_erro => pr_dscritic
                               ,pr_flg_erro => TRUE
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic);


         IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := vr_dscritic;
            RAISE vr_exc_erro;
         END IF;

         RAISE vr_exc_erro;

      END IF;

      -- Verifica se o numero da conta foi informado
      IF pr_nro_conta = 0 THEN
         pr_cdcritic := 0;
         pr_dscritic := 'Conta deve ser Informada';
         cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                              ,pr_cdagenci => pr_cod_agencia
                              ,pr_nrdcaixa => pr_nro_caixa
                              ,pr_cod_erro => pr_cdcritic
                              ,pr_dsc_erro => pr_cdcritic
                              ,pr_flg_erro => TRUE
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic);

         IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := vr_dscritic;
            RAISE vr_exc_erro;
         END IF;

         RAISE vr_exc_erro;
      END IF;

      vr_aux_lscontas := GENE0005.fn_busca_conta_centralizadora(rw_cod_coop_orig.cdcooper,0);

      IF NOT vr_aux_lscontas = TO_CHAR(pr_nro_conta) THEN

         -- Verifica Associado
         OPEN cr_verifica_ass(rw_cod_coop_dest.cdcooper
                             ,pr_nro_conta);
         FETCH cr_verifica_ass INTO rw_verifica_ass;
            IF cr_verifica_ass%NOTFOUND THEN
               pr_cdcritic := 9;
               pr_dscritic := '';
               cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                    ,pr_cdagenci => pr_cod_agencia
                                    ,pr_nrdcaixa => pr_nro_caixa
                                    ,pr_cod_erro => pr_cdcritic
                                    ,pr_dsc_erro => pr_cdcritic
                                    ,pr_flg_erro => TRUE
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic);
               IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                  pr_cdcritic := vr_cdcritic;
                  pr_dscritic := vr_dscritic;
                  RAISE vr_exc_erro;
               END IF;

               RAISE vr_exc_erro;
            ELSE

               pr_nom_titular := rw_verifica_ass.nmprimtl;

               IF rw_verifica_ass.cdmodali = 3 THEN /* Conta tipo Poupanca */
                  pr_poupanca := 1;
               END IF;

            END IF;
         CLOSE cr_verifica_ass;

      END IF;

      vr_l_achou := FALSE;
      vr_c_docto := TO_CHAR(pr_nro_docmto)||'012';

      /** Dados DESTINO/CREDITO **/
      vr_aux_cdcooper := rw_cod_coop_dest.cdcooper;
      vr_aux_cdagenci := 1;
      vr_aux_cdbccxlt := 100;
      vr_i_nro_lote   := 10118;

      /* Verifica se existe LCM de CREDITO / CHEQUE COOP */
      OPEN cr_verifica_lcm1(vr_aux_cdcooper
                           ,rw_dat_cop.dtmvtolt
                           ,vr_aux_cdagenci
                           ,vr_aux_cdbccxlt
                           ,vr_i_nro_lote
                           ,pr_nro_conta
                           ,TO_NUMBER(vr_c_docto));
      FETCH cr_verifica_lcm1 INTO rw_verifica_lcm1;
         IF cr_verifica_lcm1%FOUND THEN

            vr_aux_cdpesqbb := TO_CHAR(gene0002.fn_busca_entrada(1,rw_verifica_lcm1.cdpesqbb,','));
            IF vr_aux_cdpesqbb = 'CRAP22' THEN
               pr_dsidenti   := rw_verifica_lcm1.dsidenti;
               vr_l_achou    := TRUE;
               pr_valor_coop := rw_verifica_lcm1.vllanmto;
            END IF;

         END IF;
      CLOSE cr_verifica_lcm1;

      vr_c_docto := TO_CHAR(pr_nro_docmto);

      /* Verifica se existe LCM de CREDITO */
      FOR rw_verifica_lcm IN cr_verifica_lcm(vr_aux_cdcooper
                                            ,rw_dat_cop.dtmvtolt
                                            ,vr_aux_cdagenci
                                            ,vr_aux_cdbccxlt
                                            ,vr_i_nro_lote
                                            ,pr_nro_conta) LOOP


         /* Garantir que somente serao pegos os lancamentos corretos */
         vr_aux_cdpesqbb := TO_CHAR(gene0002.fn_busca_entrada(1,rw_verifica_lcm.cdpesqbb,','));
         IF TO_CHAR(rw_verifica_lcm.nrdocmto) LIKE TO_CHAR(vr_c_docto||'%') AND
            (gene0002.fn_existe_valor(pr_base => '2,3,4,5,6'
                              ,pr_busca       => SUBSTR(TO_CHAR(rw_verifica_lcm.nrdocmto),LENGTH(rw_verifica_lcm.nrdocmto),1)
                              ,pr_delimite    => ',')='S') AND vr_aux_cdpesqbb = 'CRAP22' THEN

            /* Chq prc. chq maior prc, chq fora prc, chq maior fora prc */
            IF (gene0002.fn_existe_valor(pr_base => '3,4,5,6'
                              ,pr_busca       => SUBSTR(TO_CHAR(rw_verifica_lcm.nrdocmto),LENGTH(rw_verifica_lcm.nrdocmto),1)
                              ,pr_delimite    => ',')='S') THEN
                pr_dsidenti              := rw_verifica_lcm.dsidenti;
                vr_l_achou_horario_corte := TRUE;
                vr_l_achou               := TRUE;

                OPEN cr_verifica_dpb(rw_verifica_lcm.cdcooper
                                    ,rw_verifica_lcm.dtmvtolt
                                    ,rw_verifica_lcm.cdagenci
                                    ,rw_verifica_lcm.cdbccxlt
                                    ,rw_verifica_lcm.nrdolote
                                    ,rw_verifica_lcm.nrdconta
                                    ,rw_verifica_lcm.nrdocmto);
                FETCH cr_verifica_dpb INTO rw_verifica_dpb;
                   IF cr_verifica_dpb%NOTFOUND THEN
                      pr_cdcritic := 82;
                      pr_dscritic := '';
                      cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                           ,pr_cdagenci => pr_cod_agencia
                                           ,pr_nrdcaixa => pr_nro_caixa
                                           ,pr_cod_erro => pr_cdcritic
                                           ,pr_dsc_erro => pr_cdcritic
                                           ,pr_flg_erro => TRUE
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);
                      RAISE vr_exc_erro;
                   ELSE
                      IF  rw_verifica_dpb.inlibera = 2 THEN
                          pr_cdcritic := 220;
                          pr_dscritic := '';
                          cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                               ,pr_cdagenci => pr_cod_agencia
                                               ,pr_nrdcaixa => pr_nro_caixa
                                               ,pr_cod_erro => pr_cdcritic
                                               ,pr_dsc_erro => pr_cdcritic
                                               ,pr_flg_erro => TRUE
                                               ,pr_cdcritic => vr_cdcritic
                                               ,pr_dscritic => vr_dscritic);
                          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                             pr_cdcritic := vr_cdcritic;
                             pr_dscritic := vr_dscritic;
                             RAISE vr_exc_erro;
                          END IF;

                          RAISE vr_exc_erro;
                      END IF;
                   END IF;

                   vr_existe_reg := TRUE;
                   vr_index := NVL(pr_tab_lancamento.COUNT(),0) + 1; -- Verifica se existe registro, se encontra soma + 1
                   pr_tab_lancamento(vr_index).tpdocmto := TO_NUMBER(SUBSTR(rw_verifica_lcm.nrdocmto,LENGTH(rw_verifica_lcm.nrdocmto),1));
                   pr_tab_lancamento(vr_index).dtmvtolt := rw_verifica_dpb.dtliblan;
                   pr_tab_lancamento(vr_index).vllanmto := rw_verifica_lcm.vllanmto;

                CLOSE cr_verifica_dpb;
            END IF;

            /*** Verifica se PA faz previa dos cheques ***/
            vr_flg_exetrunc := FALSE;
            
            -- Buscar configuração na tabela
            vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                                     ,pr_nmsistem => 'CRED'
                                                     ,pr_tptabela => 'GENERI'
                                                     ,pr_cdempres => 0
                                                     ,pr_cdacesso => 'EXETRUNCAGEM'
                                                     ,pr_tpregist => pr_cod_agencia);
            
            IF vr_dstextab = 'SIM' THEN
              vr_cdcritic     := 0;
              vr_flg_exetrunc := TRUE;

              /** Dados ORIGEM/DEBITO **/
              vr_aux_cdagenci := pr_cod_agencia;
              vr_aux_cdbccxlt := 11;
              vr_i_nro_lote   := 11000 + pr_nro_caixa;

              FOR rw_verifica_chd IN cr_verifica_chd(rw_cod_coop_orig.cdcooper
                                                    ,rw_verifica_lcm.dtmvtolt
                                                    ,vr_aux_cdagenci
                                                    ,vr_aux_cdbccxlt
                                                    ,vr_i_nro_lote
                                                    ,pr_nro_docmto
                                                    ,rw_verifica_lcm.nrseqdig) LOOP

                 IF rw_verifica_chd.insitprv > 0 THEN
                    vr_cdcritic := 9999;
                 END IF;

              END LOOP;

            END IF;

            IF vr_cdcritic > 0 THEN
               pr_cdcritic := 0;
               pr_dscritic := 'Estorno nao pode ser efetuado. '||
                              'Cheque ja enviado para previa.';
               cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                    ,pr_cdagenci => pr_cod_agencia
                                    ,pr_nrdcaixa => pr_nro_caixa
                                    ,pr_cod_erro => pr_cdcritic
                                    ,pr_dsc_erro => pr_dscritic
                                    ,pr_flg_erro => TRUE
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic);
               IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                  pr_cdcritic := vr_cdcritic;
                  pr_dscritic := vr_dscritic;
                  RAISE vr_exc_erro;
               END IF;

               RAISE vr_exc_erro;
            END IF;

         END IF;
      END LOOP; /* Fim do LCM de CREDITO */

      IF pr_tab_lancamento.COUNT() = 0 AND vr_existe_reg THEN
         pr_cdcritic := 90;
         pr_dscritic := '';

         cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                              ,pr_cdagenci => pr_cod_agencia
                              ,pr_nrdcaixa => pr_nro_caixa
                              ,pr_cod_erro => pr_cdcritic
                              ,pr_dsc_erro => pr_dscritic
                              ,pr_flg_erro => TRUE
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic);

         IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := vr_dscritic;
            RAISE vr_exc_erro;
         END IF;

         RAISE vr_exc_erro;
      END IF;

      pr_retorno  := 'OK';

   EXCEPTION
     WHEN vr_exc_erro THEN
          pr_retorno  := 'NOK';

     WHEN OTHERS THEN
         pr_retorno  := 'NOK';
         pr_cdcritic := 0;
         pr_dscritic := 'Erro na rotina CXON0088.pc_valida_chq_captura. '||SQLERRM;

         cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                              ,pr_cdagenci => pr_cod_agencia
                              ,pr_nrdcaixa => pr_nro_caixa
                              ,pr_cod_erro => vr_cdcritic
                              ,pr_dsc_erro => vr_dscritic
                              ,pr_flg_erro => TRUE
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic);

         IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := vr_dscritic;
         END IF;

   END pc_valida_chq_captura;


   PROCEDURE pc_valida_chq_captura_wt(pr_cooper      IN VARCHAR2      --> Coop. Origem
                                     ,pr_cod_agencia IN INTEGER       --> Cod. Agencia
                                     ,pr_nro_caixa   IN INTEGER       --> Nro Caixa
                                     ,pr_cooper_dest IN VARCHAR2      --> Coop. Destino
                                     ,pr_nro_conta   IN INTEGER       --> Nro Conta
                                     ,pr_nro_docmto  IN INTEGER       --> Nrd Documento
                                     ,pr_dsidenti    OUT VARCHAR2     --> Identificacao
                                     ,pr_nom_titular OUT VARCHAR2     --> Nome do titular
                                     ,pr_poupanca    OUT INTEGER      --> Retorna se for Conta Poupanca
                                     ,pr_valor_coop  OUT NUMBER       --> Valor Coop
                                     ,pr_retorno     OUT VARCHAR2     --> Retorna OK/NOK
                                     ,pr_cdcritic    OUT INTEGER      --> Cod. Critica
                                     ,pr_dscritic    OUT VARCHAR2) IS --> Des. da Critica
   ---------------------------------------------------------------------------------------------------------------
   --
   --  Programa : pc_valida_chq_captura_wt Fonte: dbo/b1crap88.p/valida-cheque-com-captura
   --  Sistema  : Estorno de Depositos Cheques Intercooperativas
   --  Sigla    : CRED
   --  Autor    : Andre Santos - SUPERO
   --  Data     : Julho/2014.                   Ultima atualizacao:
   --
   -- Dados referentes ao programa:
   --
   -- Frequencia: -----
   -- Objetivo  : Gera os Lancamentos e gravar retorno na work table, para conseguir
   --             utilizar no progress

   -- Alteracoes:
   ---------------------------------------------------------------------------------------------------------------
   vr_tab_lancamento cxon0088.typ_tab_lancamento;
   vr_ind            PLS_INTEGER;
   BEGIN
      -- Limpa a tabela temporaria de interface
      BEGIN
        DELETE wt_lancamento_proces;
      EXCEPTION
        WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Erro ao excluir wt_lancamento_proces: '||SQLERRM;
          RETURN;
      END;
      -- Valida Deposito com Captura
      CXON0088.pc_valida_chq_captura(pr_cooper         => pr_cooper         /* Coop. Origem  */
                                    ,pr_cod_agencia    => pr_cod_agencia    /* Cod. Agencia  */
                                    ,pr_nro_caixa      => pr_nro_caixa      /* Nro Caixa     */
                                    ,pr_cooper_dest    => pr_cooper_dest    /* Coop. Destino */
                                    ,pr_nro_conta      => pr_nro_conta      /* Nro Conta     */
                                    ,pr_nro_docmto     => pr_nro_docmto     /* Nrd Documento*/
                                    ,pr_dsidenti       => pr_dsidenti       /* Identificacao*/
                                    ,pr_nom_titular    => pr_nom_titular    /* Nome do titular*/
                                    ,pr_poupanca       => pr_poupanca       /* Poupanca*/
                                    ,pr_valor_coop     => pr_valor_coop     /* Valor Coop*/
                                    ,pr_retorno        => pr_retorno        /* Retorna OK/NOK*/
                                    ,pr_tab_lancamento => vr_tab_lancamento /* Retorna temp-table */
                                    ,pr_cdcritic       => pr_cdcritic       /* Cod. Critica*/
                                    ,pr_dscritic       => pr_dscritic);     /* Des. da Critica*/

      -- se não encontrar critica
      IF NVL(pr_cdcritic,0) = 0 AND
         TRIM(pr_dscritic) IS NULL THEN
         -- incluir os registros da tabela temporaria na work-table

         vr_ind := vr_tab_lancamento.first; -- Vai para o primeiro registro

         -- loop sobre a tabela de retorno
         WHILE vr_ind IS NOT NULL LOOP
            -- Insere na tabela de interface
            BEGIN
               INSERT INTO wt_lancamento_proces
                          (tpdocmto,
                           dtmvtolt,
                           vllanmto)
               VALUES(vr_tab_lancamento(vr_ind).tpdocmto,
                      vr_tab_lancamento(vr_ind).dtmvtolt,
                      vr_tab_lancamento(vr_ind).vllanmto);
            EXCEPTION
               WHEN OTHERS THEN
                  pr_cdcritic := 0;
                  pr_dscritic := 'Erro ao inserir na tabela wt_critica_proces: '||SQLERRM;
               RETURN;
            END;

            -- Vai para o proximo registro
            vr_ind := vr_tab_lancamento.next(vr_ind);
         END LOOP;

    END IF; -- Fim if critica não existe critica

  EXCEPTION
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := 'Erro no procedimento CXON0088.pc_valida_chq_captura_wt:'|| sqlerrm;
      ROLLBACK; -- rollback temporario até conclusão das validações

   END pc_valida_chq_captura_wt;


   PROCEDURE pc_verifica_crapchd_coop(pr_cdcooper     IN INTEGER      --> Coop. Origem
                                     ,pr_cod_agencia  IN INTEGER      --> Cod. Agencia
                                     ,pr_nro_caixa    IN INTEGER      --> Nro Caixa
                                     ,pr_cod_operador IN VARCHAR2     --> Cod Operador
                                     ,pr_nro_conta    IN INTEGER      --> Nro Conta
                                     ,pr_nro_lote     IN INTEGER      --> Nrd Documento
                                     ,pr_nro_docmto   IN INTEGER      --> Nrd Documento
                                     ,pr_dtmvtolt     IN DATE         --> Data de Lancamento
                                     ,pr_nrseqdig     IN INTEGER      --> Nro da Sequencia de Digito LCM
                                     ,pr_cdhistor     IN INTEGER      --> Codigo do Historico
                                     ,pr_cdbcoctl     IN INTEGER      -->
                                     ,pr_lsconta1     IN VARCHAR2     --> ''
                                     ,pr_lsconta3     IN VARCHAR2     --> ''
                                     ,pr_retorno     OUT VARCHAR2     --> Retorna OK/NOK
                                     ,pr_cdcritic    OUT INTEGER      --> Cod. Critica
                                     ,pr_dscritic    OUT VARCHAR2) IS --> Des. da Critica
   ---------------------------------------------------------------------------------------------------------------
   --
   --  Programa : pc_verifica_crapchd_coop Fonte: dbo/b1crap88.p/verifica-crapchd-coop
   --  Sistema  : Estorno de Depositos Cheques Intercooperativas
   --  Sigla    : CRED
   --  Autor    : Andre Santos - SUPERO
   --  Data     : Julho/2014.                   Ultima atualizacao: 10/06/2016
   --
   -- Dados referentes ao programa:
   --
   -- Frequencia: -----
   -- Objetivo  :

   -- Alteracoes: 10/06/2016 - Ajuste para utilizar o UPPER em campos de indice que utilizam UPPER
   --                          (Adriano - SD 463762).                               
   ---------------------------------------------------------------------------------------------------------------

   CURSOR cr_verifica_cop(p_cdcooper IN INTEGER) IS
      SELECT UPPER(cop.nmrescop) nmrescop
        FROM crapcop cop
       WHERE cop.cdcooper = p_cdcooper;
   rw_verifica_cop cr_verifica_cop%ROWTYPE;

   /* Lancamento de pagamento do cheque - DEBITO */
   CURSOR cr_verifica_lcm1(p_cdcooper IN INTEGER
                          ,p_dtmvtolt IN DATE
                          ,p_cdagenci IN INTEGER
                          ,p_cdbccxlt IN INTEGER
                          ,p_nrdolote IN INTEGER
                          ,p_nrctachq IN INTEGER
                          ,p_nrdocmto IN INTEGER) IS
      SELECT lcm.cdcooper
            ,lcm.dtmvtolt
            ,lcm.cdagenci
            ,lcm.cdbccxlt
            ,lcm.nrdolote
            ,lcm.nrdctabb
            ,lcm.nrdocmto
            ,lcm.vllanmto
            ,lcm.nrctachq
            ,lcm.cdagechq
            ,lcm.cdcmpchq
            ,lcm.cdbanchq
        FROM craplcm lcm
       WHERE lcm.cdcooper = p_cdcooper
         AND lcm.dtmvtolt = p_dtmvtolt
         AND lcm.cdagenci = p_cdagenci
         AND lcm.cdbccxlt = p_cdbccxlt
         AND lcm.nrdolote = p_nrdolote
         AND lcm.nrdctabb = p_nrctachq
         AND lcm.nrdocmto = p_nrdocmto;
   rw_verifica_lcm1 cr_verifica_lcm1%ROWTYPE;

   /* Verifica LOTE */
   CURSOR cr_consulta_lot (p_cdcooper IN craplot.cdcooper%TYPE
                          ,p_dtmvtolt IN craplot.dtmvtolt%TYPE
                          ,p_cdagenci IN craplot.cdagenci%TYPE
                          ,p_cdbccxlt IN craplot.cdbccxlt%TYPE
                          ,p_nrdolote IN craplot.nrdolote%TYPE) IS
      SELECT lot.cdcooper
            ,lot.dtmvtolt
            ,lot.cdagenci
            ,lot.cdbccxlt
            ,lot.nrdolote
            ,lot.vlcompdb
            ,lot.vlinfodb
            ,lot.vlcompcr
            ,lot.vlinfocr
        FROM craplot lot
       WHERE lot.cdcooper = p_cdcooper
         AND lot.dtmvtolt = p_dtmvtolt
         AND lot.cdagenci = p_cdagenci
         AND lot.cdbccxlt = p_cdbccxlt
         AND lot.nrdolote = p_nrdolote;
   rw_consulta_lot cr_consulta_lot%ROWTYPE;

   CURSOR cr_verifica_chd(p_cdcooper IN INTEGER
                         ,p_dtmvtolt IN DATE
                         ,p_cdagenci IN INTEGER
                         ,p_cdbccxlt IN INTEGER
                         ,p_nrdolote IN INTEGER
                         ,p_nrdocmto IN INTEGER
                         ,p_nrseqdig IN INTEGER)IS
      SELECT chd.cdcooper
            ,chd.dtmvtolt
            ,chd.cdcmpchq
            ,chd.cdbanchq
            ,chd.cdagechq
            ,chd.nrctachq
            ,chd.nrcheque
            ,chd.cdagenci
            ,chd.cdbccxlt
            ,chd.nrdocmto
            ,chd.cdoperad
            ,chd.cdsitatu
            ,chd.dsdocmc7
            ,chd.inchqcop
            ,chd.insitchq
            ,chd.cdtipchq
            ,chd.nrdconta
            ,chd.nrddigc1
            ,chd.nrddigc2
            ,chd.nrddigc3
            ,chd.nrddigv1
            ,chd.nrddigv2
            ,chd.nrddigv3
            ,chd.nrdolote
            ,chd.tpdmovto
            ,chd.nrterfin
            ,chd.vlcheque
            ,chd.cdagedst
            ,chd.nrctadst
        FROM crapchd chd
       WHERE chd.cdcooper = p_cdcooper
         AND chd.dtmvtolt = p_dtmvtolt
         AND chd.cdagenci = p_cdagenci
         AND chd.cdbccxlt = p_cdbccxlt
         AND chd.nrdolote = p_nrdolote
         AND chd.nrdocmto LIKE p_nrdocmto||'%'
         AND chd.nrseqdig = p_nrseqdig;
   rw_verifica_chd cr_verifica_chd%ROWTYPE;

   CURSOR cr_verifica_fdc (p_cdcooper IN crapfdc.cdcooper%TYPE
                          ,p_cdbanchq IN crapfdc.cdbanchq%TYPE
                          ,p_cdagechq IN crapfdc.cdcmpchq%TYPE
                          ,p_nrctachq IN crapfdc.cdbanchq%TYPE
                          ,p_nrcheque IN crapfdc.cdagechq%TYPE) IS
     SELECT fdc.incheque
           ,fdc.dtliqchq
           ,fdc.cdoperad
           ,fdc.vlcheque
           ,fdc.cdbanchq
           ,fdc.cdagechq
           ,fdc.nrctachq
           ,fdc.tpcheque
           ,fdc.nrcheque
           ,fdc.nrdigchq
       FROM crapfdc fdc
      WHERE fdc.cdcooper = p_cdcooper
        AND fdc.cdbanchq = p_cdbanchq
        AND fdc.cdagechq = p_cdagechq
        AND fdc.nrctachq = p_nrctachq
        AND fdc.nrcheque = p_nrcheque;
   rw_verifica_fdc cr_verifica_fdc%ROWTYPE;

   CURSOR cr_verifica_tco(p_cdcooper IN INTEGER
                         ,p_nrctaant IN INTEGER) IS
      SELECT tco.cdcopant
            ,tco.cdagenci
            ,tco.cdcooper
        FROM craptco tco
       WHERE tco.cdcooper = p_cdcooper
         AND tco.nrctaant = p_nrctaant
         AND tco.tpctatrf = 1
         AND tco.flgativo = 1;
   rw_verifica_tco cr_verifica_tco%ROWTYPE;

   CURSOR cr_verifica_tco_host(p_cdcopant IN INTEGER
                              ,p_nrctaant IN INTEGER) IS
      SELECT tco.cdcopant
            ,tco.cdagenci
            ,tco.cdcooper
        FROM craptco tco
       WHERE tco.cdcopant = p_cdcopant
         AND tco.nrctaant = p_nrctaant
         AND tco.tpctatrf = 1
         AND tco.flgativo = 1;
   rw_verifica_tco_host cr_verifica_tco_host%ROWTYPE;

   CURSOR cr_verifica_tco_itg(p_cdcooper IN INTEGER
                             ,p_nrdctitg IN INTEGER) IS
      SELECT tco.cdcopant
            ,tco.cdagenci
            ,tco.cdcooper
        FROM craptco tco
       WHERE tco.cdcopant = p_cdcooper
         AND UPPER(tco.nrdctitg) = UPPER(p_nrdctitg)
         AND tco.tpctatrf = 1
         AND tco.flgativo = 1;
   rw_verifica_tco_itg cr_verifica_tco_itg%ROWTYPE;

   CURSOR cr_verifica_bcx(p_cdcooper IN INTEGER
                         ,p_dtmvtolt IN DATE
                         ,p_cdagenci IN INTEGER
                         ,p_nrdcaixa IN INTEGER
                         ,p_cdopecxa IN VARCHAR2) IS
      SELECT bcx.cdcooper
        FROM crapbcx bcx
       WHERE bcx.cdcooper = p_cdcooper
         AND bcx.dtmvtolt = p_dtmvtolt
         AND bcx.cdagenci = p_cdagenci
         AND bcx.nrdcaixa = p_nrdcaixa
         AND UPPER(bcx.cdopecxa) = UPPER(p_cdopecxa)
         AND bcx.cdsitbcx = 1;
   rw_verifica_bcx cr_verifica_bcx%ROWTYPE;

   CURSOR cr_verifica_lcx(p_cdcooper IN PLS_INTEGER
                         ,p_dtmvtolt IN DATE
                         ,p_cdagenci IN PLS_INTEGER
                         ,p_nrdcaixa IN PLS_INTEGER
                         ,p_cdopecxa IN VARCHAR2
                         ,p_nrdocmto IN PLS_INTEGER
                         ,p_cdhistor IN PLS_INTEGER) IS
      SELECT lcx.cdcooper
        FROM craplcx lcx
       WHERE lcx.cdcooper = p_cdcooper
         AND lcx.dtmvtolt = p_dtmvtolt
         AND lcx.cdagenci = p_cdagenci
         AND lcx.nrdcaixa = p_nrdcaixa
         AND UPPER(lcx.cdopecxa) = UPPER(p_cdopecxa)
         AND lcx.nrdocmto = p_nrdocmto
         AND lcx.cdhistor = p_cdhistor;
   rw_verifica_lcx cr_verifica_lcx%ROWTYPE;

   -- Variaveis Erro
   vr_cdcritic crapcri.cdcritic%TYPE;
   vr_dscritic VARCHAR2(4000);
   vr_exc_erro EXCEPTION;

   -- Variaveis
   vr_aux_cdcooper INTEGER   := 0;
   vr_aux_cdagenci INTEGER   := 0;
   vr_aux_cdbccxlt INTEGER   := 0;
   vr_i_nro_lote   INTEGER   := 0;
   vr_i_nro_docto  INTEGER   := 0;
   vr_dsdctitg VARCHAR2(200) := '';
   vr_aux_nrctaass VARCHAR2(200)         := '';
   vr_stsnrcal INTEGER       := 0;
   vr_aux_nrdctitg crapass.nrdctitg%TYPE := '';
   vr_achou_fdc BOOLEAN      := FALSE;
   vr_achou_lcm BOOLEAN      := FALSE;
   vr_coop INTEGER           := 0;

   BEGIN

      -- Dados de ORIGEM
      vr_aux_cdcooper := pr_cdcooper;
      vr_aux_cdagenci := pr_cod_agencia;
      vr_aux_cdbccxlt := 11;
      vr_i_nro_lote   := pr_nro_lote;

      /** Posicionar no LOTE de ORIGEM */
      OPEN cr_consulta_lot(vr_aux_cdcooper
                          ,pr_dtmvtolt
                          ,vr_aux_cdagenci
                          ,vr_aux_cdbccxlt
                          ,vr_i_nro_lote);
      FETCH cr_consulta_lot INTO rw_consulta_lot;
         IF cr_consulta_lot%NOTFOUND THEN
            pr_cdcritic := 60;
            pr_dscritic := '';
            RAISE vr_exc_erro;
         ELSE
            NULL;
         END IF;
      CLOSE cr_consulta_lot;

      FOR rw_verifica_chd IN cr_verifica_chd(pr_cdcooper
                                            ,pr_dtmvtolt
                                            ,pr_cod_agencia
                                            ,11
                                            ,pr_nro_lote
                                            ,pr_nro_docmto
                                            ,pr_nrseqdig) LOOP

          -- Formata conta integracao
          GENE0005.pc_conta_itg_digito_x(pr_nrcalcul => rw_verifica_chd.nrctachq
                                        ,pr_dscalcul => vr_dsdctitg
                                        ,pr_stsnrcal => vr_stsnrcal
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic);
          -- Se ocorreu erro
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
             pr_cdcritic := vr_cdcritic;
             pr_dscritic := vr_dscritic;
             RAISE vr_exc_erro;
          END IF;

          vr_aux_nrdctitg := '';

          /**  Conta Integracao **/
          IF LENGTH(rw_verifica_chd.nrctachq) <= 8 THEN
             /* Verifica da conta integracão do associado */
             GENE0005.pc_existe_conta_integracao(pr_cdcooper => pr_cdcooper
                                                ,pr_ctpsqitg => rw_verifica_chd.nrctachq
                                                ,pr_nrdctitg => vr_aux_nrdctitg
                                                ,pr_nrctaass => vr_aux_nrctaass
                                                ,pr_des_erro => vr_dscritic);
             IF vr_dscritic IS NOT NULL THEN
                pr_cdcritic := 0;
                pr_dscritic := vr_dscritic;
                RAISE vr_exc_erro;
             END IF;
          END IF;

          IF pr_cdhistor = 1524 THEN -- CHEQUE COOP

             vr_i_nro_docto := TO_NUMBER(TO_CHAR(rw_verifica_chd.nrcheque)||
                                         TO_CHAR(rw_verifica_chd.nrddigc3));

             IF (rw_verifica_chd.cdbanchq = 1     AND
                 rw_verifica_chd.cdagechq = 3420) OR
                (vr_aux_nrdctitg <> ''            AND
                 (gene0002.fn_existe_valor(pr_base     => '3420'
                                          ,pr_busca    => TO_CHAR(rw_verifica_chd.cdagechq)
                                          ,pr_delimite => ',')='S')) THEN

                IF (gene0002.fn_existe_valor(pr_base     => pr_lsconta1
                                            ,pr_busca    => TO_CHAR(rw_verifica_chd.nrctachq)
                                            ,pr_delimite => ',')='S') OR
                   vr_aux_nrdctitg <> '' THEN

                   -- Verificando Folha de Cheque
                   OPEN cr_verifica_fdc(rw_verifica_chd.cdcooper
                                       ,rw_verifica_chd.cdbanchq
                                       ,rw_verifica_chd.cdagechq
                                       ,rw_verifica_chd.nrctachq
                                       ,rw_verifica_chd.nrcheque);
                   FETCH cr_verifica_fdc INTO rw_verifica_fdc;

                      vr_achou_fdc := TRUE; -- Inicializa como TRUE

                      -- Se nao encontrou
                      IF cr_verifica_fdc%NOTFOUND THEN

                         -- Formata conta integracao
                         GENE0005.pc_conta_itg_digito_x(pr_nrcalcul => TO_NUMBER(rw_verifica_chd.nrctachq)
                                                       ,pr_dscalcul => vr_dsdctitg
                                                       ,pr_stsnrcal => vr_stsnrcal
                                                       ,pr_cdcritic => vr_cdcritic
                                                       ,pr_dscritic => vr_dscritic);
                         -- Se ocorreu erro
                         IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                            pr_cdcritic := vr_cdcritic;
                            pr_dscritic := vr_dscritic;
                            RAISE vr_exc_erro;
                         END IF;

                         IF vr_stsnrcal <> 0 THEN
                            pr_cdcritic := 8;
                            pr_dscritic := '';
                            RAISE vr_exc_erro;
                         END IF;

                         IF cr_verifica_tco_itg%ISOPEN THEN
                            CLOSE cr_verifica_tco_itg;
                         END IF;

                         -- Localiza se o cheque é de uma conta migrada
                         OPEN cr_verifica_tco_itg(pr_cdcooper   /* coop nova */
                                             ,vr_dsdctitg); /* conta ITG */
                         FETCH cr_verifica_tco_itg INTO rw_verifica_tco_itg;

                            -- Se encontrou
                            IF cr_verifica_tco_itg%FOUND THEN

                               vr_achou_fdc := FALSE; -- Recebe Falso

                               IF cr_verifica_fdc%ISOPEN THEN
                                  CLOSE cr_verifica_fdc;
                               END IF;

                               OPEN cr_verifica_fdc(rw_verifica_tco_itg.cdcopant
                                                   ,rw_verifica_chd.cdbanchq
                                                   ,rw_verifica_chd.cdagechq
                                                   ,rw_verifica_chd.nrctachq
                                                   ,rw_verifica_chd.nrcheque);
                               FETCH cr_verifica_fdc INTO rw_verifica_fdc;
                                  -- Se nao encontrou, gera erro
                                  IF cr_verifica_fdc%NOTFOUND THEN
                                     pr_cdcritic := 108;
                                     pr_dscritic := '';
                                     RAISE vr_exc_erro;
                                  END IF;
                               IF cr_verifica_fdc%ISOPEN THEN
                                  CLOSE cr_verifica_fdc;
                               END IF;
                            ELSE -- Se nao encontrou, gera erro
                               pr_cdcritic := 108;
                               pr_dscritic := '';
                               RAISE vr_exc_erro;
                            END IF;
                         IF cr_verifica_tco_itg%ISOPEN THEN
                            CLOSE cr_verifica_tco_itg;
                         END IF;
                      END IF;

                      IF vr_achou_fdc THEN -- Conta Normal
                         vr_coop := rw_verifica_chd.cdcooper;
                      ELSE -- Conta Migrada
                         vr_coop := rw_verifica_tco_itg.cdcopant;
                      END IF;

                      BEGIN
                         UPDATE crapfdc fdc
                            SET fdc.incheque = 0
                               ,fdc.vlcheque = 0
                               ,fdc.cdoperad = NULL
                               ,fdc.dtliqchq = NULL
                               ,fdc.cdbandep = 0
                               ,fdc.cdagedep = 0
                               ,fdc.nrctadep = 0
                         WHERE fdc.cdcooper = vr_coop
                           AND fdc.cdbanchq = rw_verifica_chd.cdbanchq
                           AND fdc.cdagechq = rw_verifica_chd.cdagechq
                           AND fdc.nrctachq = rw_verifica_chd.nrctachq
                           AND fdc.nrcheque = rw_verifica_chd.nrcheque;
                      EXCEPTION
                         WHEN OTHERS THEN
                            pr_cdcritic := 0;
                            pr_dscritic := 'Erro ao atualizar CRAPFDC : '||sqlerrm;
                            RAISE vr_exc_erro;
                      END;

                   IF cr_verifica_fdc%ISOPEN THEN
                      CLOSE cr_verifica_fdc;
                   END IF;

                ELSE

                   IF (gene0002.fn_existe_valor(pr_base     => pr_lsconta3
                                               ,pr_busca    => TO_CHAR(rw_verifica_chd.nrctachq)
                                               ,pr_delimite => ',')='S') THEN

                      -- Verificando Folha de Cheque
                      OPEN cr_verifica_fdc(rw_verifica_chd.cdcooper
                                          ,rw_verifica_chd.cdbanchq
                                          ,rw_verifica_chd.cdagechq
                                          ,rw_verifica_chd.nrctachq
                                          ,rw_verifica_chd.nrcheque);
                      FETCH cr_verifica_fdc INTO rw_verifica_fdc;

                         vr_achou_fdc := TRUE; -- Inicializa como TRUE

                         -- Se nao encontrou
                         IF cr_verifica_fdc%NOTFOUND THEN

                            -- Formata conta integracao
                            GENE0005.pc_conta_itg_digito_x(pr_nrcalcul => rw_verifica_chd.nrctachq
                                                          ,pr_dscalcul => vr_dsdctitg
                                                          ,pr_stsnrcal => vr_stsnrcal
                                                          ,pr_cdcritic => vr_cdcritic
                                                          ,pr_dscritic => vr_dscritic);
                            -- Se ocorreu erro
                            IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                               pr_cdcritic := vr_cdcritic;
                               pr_dscritic := vr_dscritic;
                               RAISE vr_exc_erro;
                            END IF;

                            IF vr_stsnrcal != 0 THEN
                               pr_cdcritic := 8;
                               pr_dscritic := '';
                               RAISE vr_exc_erro;
                            END IF;

                            IF cr_verifica_tco_itg%ISOPEN THEN
                               CLOSE cr_verifica_tco_itg;
                            END IF;

                            -- Localiza se o cheque é de uma conta migrada
                            OPEN cr_verifica_tco_itg(pr_cdcooper   /* coop nova */
                                                    ,vr_dsdctitg); /* conta ITG */
                            FETCH cr_verifica_tco_itg INTO rw_verifica_tco_itg;

                               -- Se encontrou
                               IF cr_verifica_tco_itg%FOUND THEN

                                  IF cr_verifica_fdc%ISOPEN THEN
                                     CLOSE cr_verifica_fdc;
                                  END IF;

                                  vr_achou_fdc := FALSE; -- Recebe Falso

                                  OPEN cr_verifica_fdc(rw_verifica_tco_itg.cdcopant
                                                      ,rw_verifica_chd.cdbanchq
                                                      ,rw_verifica_chd.cdagechq
                                                      ,rw_verifica_chd.nrctachq
                                                      ,rw_verifica_chd.nrcheque);
                                  FETCH cr_verifica_fdc INTO rw_verifica_fdc;
                                     -- Se nao encontrou, gera erro
                                     IF cr_verifica_fdc%NOTFOUND THEN
                                        pr_cdcritic := 286;
                                        pr_dscritic := '';
                                        RAISE vr_exc_erro;
                                     END IF;
                                  IF cr_verifica_fdc%ISOPEN THEN
                                     CLOSE cr_verifica_fdc;
                                  END IF;
                               ELSE -- Se nao encontrou, gera erro
                                  pr_cdcritic := 286;
                                  pr_dscritic := '';
                                  RAISE vr_exc_erro;
                               END IF;
                            IF cr_verifica_tco_itg%ISOPEN THEN
                               CLOSE cr_verifica_tco_itg;
                            END IF;
                         END IF;

                         IF vr_achou_fdc THEN -- Conta Normal
                            vr_coop := rw_verifica_chd.cdcooper;
                         ELSE -- Conta Migrada
                            vr_coop := rw_verifica_tco_itg.cdcopant;
                         END IF;

                         BEGIN
                            UPDATE crapfdc fdc
                               SET fdc.incheque = 0
                                  ,fdc.vlcheque = 0
                                  ,fdc.cdoperad = NULL
                                  ,fdc.dtliqchq = NULL
                                  ,fdc.cdbandep = 0
                                  ,fdc.cdagedep = 0
                                  ,fdc.nrctadep = 0
                             WHERE fdc.cdcooper = vr_coop
                               AND fdc.cdbanchq = rw_verifica_chd.cdbanchq
                               AND fdc.cdagechq = rw_verifica_chd.cdagechq
                               AND fdc.nrctachq = rw_verifica_chd.nrctachq
                               AND fdc.nrcheque = rw_verifica_chd.nrcheque;
                         EXCEPTION
                            WHEN OTHERS THEN
                              pr_cdcritic := 0;
                              pr_dscritic := 'Erro ao atualizar CRAPFDC : '||sqlerrm;
                              RAISE vr_exc_erro;
                         END;

                      IF cr_verifica_fdc%ISOPEN THEN
                         CLOSE cr_verifica_fdc;
                      END IF;

                   END IF;
                END IF;

             ELSE

                IF rw_verifica_chd.cdbanchq = 756 OR
                   rw_verifica_chd.cdbanchq = pr_cdbcoctl THEN

                   IF (gene0002.fn_existe_valor(pr_base     => pr_lsconta3
                                               ,pr_busca    => TO_CHAR(rw_verifica_chd.nrctachq)
                                               ,pr_delimite => ',')='S') THEN

                      -- Verificando Folha de Cheque
                      OPEN cr_verifica_fdc(rw_verifica_chd.cdcooper
                                          ,rw_verifica_chd.cdbanchq
                                          ,rw_verifica_chd.cdagechq
                                          ,rw_verifica_chd.nrctachq
                                          ,rw_verifica_chd.nrcheque);
                      FETCH cr_verifica_fdc INTO rw_verifica_fdc;

                         vr_achou_fdc := TRUE; -- Inicializa como TRUE

                         -- Se nao encontrou
                         IF cr_verifica_fdc%NOTFOUND THEN

                            IF cr_verifica_tco%ISOPEN THEN
                               CLOSE cr_verifica_tco;
                            END IF;

                            -- Localiza se o cheque é de uma conta migrada
                            OPEN cr_verifica_tco(pr_cdcooper                            /* coop nova    */
                                                ,TO_NUMBER(rw_verifica_chd.nrctachq));  /* conta antiga */
                            FETCH cr_verifica_tco INTO rw_verifica_tco;

                               -- Se encontrou
                               IF cr_verifica_tco%FOUND THEN

                                  IF cr_verifica_fdc%ISOPEN THEN
                                     CLOSE cr_verifica_fdc;
                                  END IF;

                                  vr_achou_fdc := FALSE; -- Recebe Falso

                                  /* verifica se o cheque pertence a conta migrada */
                                  OPEN cr_verifica_fdc(rw_verifica_tco.cdcopant
                                                      ,rw_verifica_chd.cdbanchq
                                                      ,rw_verifica_chd.cdagechq
                                                      ,rw_verifica_chd.nrctachq
                                                      ,rw_verifica_chd.nrcheque);
                                  FETCH cr_verifica_fdc INTO rw_verifica_fdc;
                                     -- Se nao encontrou, gera erro
                                     IF cr_verifica_fdc%NOTFOUND THEN
                                        pr_cdcritic := 286;
                                        pr_dscritic := '';
                                        RAISE vr_exc_erro;
                                     END IF;

                                  IF cr_verifica_fdc%ISOPEN THEN
                                     CLOSE cr_verifica_fdc;
                                  END IF;
                               ELSE -- Se nao encontrou, gera erro
                                  pr_cdcritic := 286;
                                  pr_dscritic := '';
                                  RAISE vr_exc_erro;
                               END IF;
                            IF cr_verifica_tco%ISOPEN THEN
                               CLOSE cr_verifica_tco;
                            END IF;
                         END IF;

                         IF vr_achou_fdc THEN -- Conta Normal
                            vr_coop := rw_verifica_chd.cdcooper;
                         ELSE -- Conta Migrada
                            vr_coop := rw_verifica_tco.cdcopant;
                         END IF;

                         BEGIN
                            UPDATE crapfdc fdc
                               SET fdc.incheque = 0
                                  ,fdc.vlcheque = 0
                                  ,fdc.cdoperad = NULL
                                  ,fdc.dtliqchq = NULL
                                  ,fdc.cdbandep = 0
                                  ,fdc.cdagedep = 0
                                  ,fdc.nrctadep = 0
                             WHERE fdc.cdcooper = vr_coop
                               AND fdc.cdbanchq = rw_verifica_chd.cdbanchq
                               AND fdc.cdagechq = rw_verifica_chd.cdagechq
                               AND fdc.nrctachq = rw_verifica_chd.nrctachq
                               AND fdc.nrcheque = rw_verifica_chd.nrcheque;
                         EXCEPTION
                            WHEN OTHERS THEN
                               pr_cdcritic := 0;
                               pr_dscritic := 'Erro ao atualizar CRAPFDC : '||sqlerrm;
                               RAISE vr_exc_erro;
                      END;

                      IF cr_verifica_fdc%ISOPEN THEN
                         CLOSE cr_verifica_fdc;
                      END IF;

                   ELSE

                      OPEN cr_verifica_fdc(rw_verifica_chd.cdcooper
                                          ,rw_verifica_chd.cdbanchq
                                          ,rw_verifica_chd.cdagechq
                                          ,rw_verifica_chd.nrctachq
                                          ,rw_verifica_chd.nrcheque);
                      FETCH cr_verifica_fdc INTO rw_verifica_fdc;

                         vr_achou_fdc := TRUE; -- Inicializa como TRUE

                         -- Se nao encontrou
                         IF cr_verifica_fdc%NOTFOUND THEN

                            IF cr_verifica_tco%ISOPEN THEN
                               CLOSE cr_verifica_tco;
                            END IF;

                            -- Localiza se o cheque é de uma conta migrada
                            OPEN cr_verifica_tco(pr_cdcooper                           /* coop nova    */
                                                ,TO_NUMBER(rw_verifica_chd.nrctachq)); /* conta antiga */
                            FETCH cr_verifica_tco INTO rw_verifica_tco;

                               -- Se encontrou
                               IF cr_verifica_tco%FOUND THEN

                                  IF cr_verifica_fdc%ISOPEN THEN
                                     CLOSE cr_verifica_fdc;
                                  END IF;

                                  vr_achou_fdc := FALSE; -- Recebe Falso

                                  /* verifica se o cheque pertence a conta migrada */
                                  OPEN cr_verifica_fdc(rw_verifica_tco.cdcopant
                                                      ,rw_verifica_chd.cdbanchq
                                                      ,rw_verifica_chd.cdagechq
                                                      ,rw_verifica_chd.nrctachq
                                                      ,rw_verifica_chd.nrcheque);
                                  FETCH cr_verifica_fdc INTO rw_verifica_fdc;
                                     -- Se nao encontrou, gera erro
                                     IF cr_verifica_fdc%NOTFOUND THEN
                                        pr_cdcritic := 108;
                                        pr_dscritic := '';
                                        RAISE vr_exc_erro;
                                     END IF;
                                  IF cr_verifica_fdc%ISOPEN THEN
                                     CLOSE cr_verifica_fdc;
                                  END IF;
                               ELSE -- Se nao encontrou, gera erro
                                  pr_cdcritic := 108;
                                  pr_dscritic := '';
                                  RAISE vr_exc_erro;
                               END IF;
                            CLOSE cr_verifica_tco;
                         END IF;

                         IF vr_achou_fdc THEN -- Conta Normal
                            vr_coop := rw_verifica_chd.cdcooper;
                         ELSE -- Conta Migrada
                            vr_coop := rw_verifica_tco.cdcopant;
                         END IF;

                         BEGIN
                            UPDATE crapfdc fdc
                               SET fdc.incheque = 0
                                  ,fdc.vlcheque = 0
                                  ,fdc.cdoperad = NULL
                                  ,fdc.dtliqchq = NULL
                                  ,fdc.cdbandep = 0
                                  ,fdc.cdagedep = 0
                                  ,fdc.nrctadep = 0
                             WHERE fdc.cdcooper = vr_coop
                               AND fdc.cdbanchq = rw_verifica_chd.cdbanchq
                               AND fdc.cdagechq = rw_verifica_chd.cdagechq
                               AND fdc.nrctachq = rw_verifica_chd.nrctachq
                               AND fdc.nrcheque = rw_verifica_chd.nrcheque;
                         EXCEPTION
                            WHEN OTHERS THEN
                               pr_cdcritic := 0;
                               pr_dscritic := 'Erro ao atualizar CRAPFDC: '||sqlerrm;
                               RAISE vr_exc_erro;
                         END;

                      IF cr_verifica_fdc%ISOPEN THEN
                         CLOSE cr_verifica_fdc;
                      END IF;

                   END IF;
                END IF;
             END IF;

             IF cr_verifica_lcm1%ISOPEN THEN
                CLOSE cr_verifica_lcm1;
             END IF;

             /* Lancamento de pagamento do cheque - DEBITO */
             OPEN cr_verifica_lcm1(pr_cdcooper
                                  ,rw_verifica_chd.dtmvtolt
                                  ,rw_verifica_chd.cdagenci
                                  ,rw_verifica_chd.cdbccxlt
                                  ,rw_verifica_chd.nrdolote
                                  ,TO_NUMBER(rw_verifica_chd.nrctachq)
                                  ,vr_i_nro_docto);
             FETCH cr_verifica_lcm1 INTO rw_verifica_lcm1;

                IF cr_verifica_lcm1%NOTFOUND THEN
                   /* Caso nao encontrar, validar se eh de uma conta migrada */
                   /* Se for Bco Cecred ou Bancoob usa o nrctaant = crapchd.nrctachq na busca da conta */

                   IF rw_verifica_chd.cdbanchq = pr_cdbcoctl OR
                      rw_verifica_chd.cdbanchq = 756 THEN

                      /* Localiza se o cheque é de uma conta migrada host */
                      OPEN cr_verifica_tco_host(pr_cdcooper
                                               ,TO_NUMBER(rw_verifica_chd.nrctachq));
                      FETCH cr_verifica_tco_host INTO rw_verifica_tco_host;

                         -- Se encontrou
                         IF cr_verifica_tco_host%FOUND THEN

                            vr_achou_lcm := FALSE; -- Recebe Falso

                            IF cr_verifica_lcm1%ISOPEN THEN
                               CLOSE cr_verifica_lcm1;
                            END IF;

                            OPEN cr_verifica_lcm1(rw_verifica_tco_host.cdcooper
                                                 ,pr_dtmvtolt
                                                 ,rw_verifica_tco_host.cdagenci
                                                 ,100
                                                 ,205000 + rw_verifica_tco_host.cdagenci
                                                 ,TO_NUMBER(rw_verifica_chd.nrctachq)
                                                 ,vr_i_nro_docto);
                            FETCH cr_verifica_lcm1 INTO rw_verifica_lcm1;
                               IF cr_verifica_lcm1%NOTFOUND THEN
                                  pr_cdcritic := 90;
                                  pr_dscritic := '';
                                  RAISE vr_exc_erro;
                               ELSE
                                  /* Este lancamento soh existe quando o deposito eh feito na coop origem da migracao */
                                  /* Remover lancamento extra caixa de conta sobreposta */

                                  OPEN cr_verifica_bcx(pr_cdcooper
                                                      ,pr_dtmvtolt
                                                      ,pr_cod_agencia
                                                      ,pr_nro_caixa
                                                      ,pr_cod_operador);
                                  FETCH cr_verifica_bcx INTO rw_verifica_bcx;
                                      IF cr_verifica_bcx%NOTFOUND THEN
                                         pr_cdcritic := 698;
                                         pr_dscritic := '';
                                         RAISE vr_exc_erro;
                                      ELSE
                                         BEGIN -- Decrementando BCX
                                            UPDATE crapbcx bcx
                                               SET bcx.qtcompln = bcx.qtcompln - 1
                                             WHERE bcx.cdcooper = pr_cdcooper
                                               AND bcx.dtmvtolt = pr_dtmvtolt
                                               AND bcx.cdagenci = pr_cod_agencia
                                               AND bcx.nrdcaixa = pr_nro_caixa
                                               AND bcx.cdopecxa = pr_cod_operador
                                               AND bcx.cdsitbcx = 1;
                                          EXCEPTION
                                             WHEN OTHERS THEN
                                                pr_cdcritic := 0;
                                                pr_dscritic := 'Erro ao excluir registro da CRAPBCX : '||sqlerrm;
                                                RAISE vr_exc_erro;
                                          END;
                                      END IF;
                                  CLOSE cr_verifica_bcx;

                                  OPEN cr_verifica_lcx(pr_cdcooper
                                                      ,pr_dtmvtolt
                                                      ,pr_cod_agencia
                                                      ,pr_nro_caixa
                                                      ,pr_cod_operador
                                                      ,TO_NUMBER(TO_CHAR(rw_verifica_fdc.nrcheque)||
                                                                 TO_CHAR(rw_verifica_fdc.nrdigchq))
                                                      ,704);
                                  FETCH cr_verifica_lcx INTO rw_verifica_lcx;
                                     IF cr_verifica_lcx%NOTFOUND THEN
                                        pr_cdcritic := 90;
                                        pr_dscritic := '';
                                        RAISE vr_exc_erro;
                                     ELSE
                                        BEGIN -- Deletando LCX
                                           DELETE craplcx lcx
                                            WHERE lcx.cdcooper = pr_cdcooper
                                              AND lcx.dtmvtolt = pr_dtmvtolt
                                              AND lcx.cdagenci = pr_cod_agencia
                                              AND lcx.nrdcaixa = pr_nro_caixa
                                              AND lcx.cdopecxa = pr_cod_operador
                                              AND lcx.nrdocmto = TO_NUMBER(TO_CHAR(rw_verifica_fdc.nrcheque)||
                                                                           TO_CHAR(rw_verifica_fdc.nrdigchq))
                                              AND lcx.cdhistor = 704;
                                        EXCEPTION
                                           WHEN OTHERS THEN
                                               pr_cdcritic := 0;
                                               pr_dscritic := 'Erro ao excluir registro da CRAPLCX : '||sqlerrm;
                                               RAISE vr_exc_erro;
                                        END;
                                     END IF;
                                  CLOSE cr_verifica_lcx;

                                  BEGIN -- Decrementando LOTE
                                    UPDATE craplot lot
                                       SET lot.qtcompln = lot.qtcompln - 1
                                          ,lot.qtinfoln = lot.qtinfoln - 1
                                          ,lot.vlcompdb = lot.vlcompdb - rw_verifica_lcm1.vllanmto
                                          ,lot.vlinfodb = lot.vlinfodb - rw_verifica_lcm1.vllanmto
                                    WHERE lot.cdcooper = rw_verifica_tco_host.cdcooper
                                      AND lot.dtmvtolt = pr_dtmvtolt
                                      AND lot.cdagenci = rw_verifica_tco_host.cdagenci
                                      AND lot.cdbccxlt = 100
                                      AND lot.nrdolote = 205000 + rw_verifica_tco_host.cdagenci;
                                  EXCEPTION
                                     WHEN OTHERS THEN
                                        pr_cdcritic := 0;
                                        pr_dscritic := 'Erro ao atualizar registro de LOTE : '||sqlerrm;
                                        RAISE vr_exc_erro;
                                  END;

                                  BEGIN
                                    DELETE craplcm lcm
                                     WHERE lcm.cdcooper = rw_verifica_lcm1.cdcooper
                                       AND lcm.dtmvtolt = rw_verifica_lcm1.dtmvtolt
                                       AND lcm.cdagenci = rw_verifica_lcm1.cdagenci
                                       AND lcm.cdbccxlt = rw_verifica_lcm1.cdbccxlt
                                       AND lcm.nrdolote = rw_verifica_lcm1.nrdolote
                                       AND lcm.nrctachq = rw_verifica_lcm1.nrctachq
                                       AND lcm.nrdocmto = rw_verifica_lcm1.nrdocmto;
                                  EXCEPTION
                                     WHEN OTHERS THEN
                                        pr_cdcritic := 0;
                                        pr_dscritic := 'Erro ao deletar CRAPLCM : '||sqlerrm;

                                        cxon0000.pc_cria_erro(pr_cdcooper => pr_cdcooper
                                                             ,pr_cdagenci => pr_cod_agencia
                                                             ,pr_nrdcaixa => pr_nro_caixa
                                                             ,pr_cod_erro => pr_cdcritic
                                                             ,pr_dsc_erro => pr_dscritic
                                                             ,pr_flg_erro => TRUE
                                                             ,pr_cdcritic => vr_cdcritic
                                                             ,pr_dscritic => vr_dscritic);

                                        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                                           pr_cdcritic := vr_cdcritic;
                                           pr_dscritic := vr_dscritic;
                                           RAISE vr_exc_erro;
                                        END IF;

                                        RAISE vr_exc_erro;
                                  END;

                               END IF;
                            IF cr_verifica_lcm1%ISOPEN THEN
                               CLOSE cr_verifica_lcm1;
                            END IF;
                        END IF;
                      IF cr_verifica_tco_host%ISOPEN THEN
                         CLOSE cr_verifica_tco_host;
                      END IF;

                   ELSE

                      /* Se for BB usa a conta ITG para buscar conta migrada */
                      /* Usa o nrdctitg = p-nrctabdb na busca da conta */
                      IF  rw_verifica_chd.cdbanchq = 1 AND
                          rw_verifica_chd.cdagechq = 3420  THEN

                          -- Formata conta integracao
                          GENE0005.pc_conta_itg_digito_x(pr_nrcalcul => rw_verifica_chd.nrctachq
                                                        ,pr_dscalcul => vr_dsdctitg
                                                        ,pr_stsnrcal => vr_stsnrcal
                                                        ,pr_cdcritic => vr_cdcritic
                                                        ,pr_dscritic => vr_dscritic);
                          -- Se ocorreu erro
                          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                             pr_cdcritic := vr_cdcritic;
                             pr_dscritic := vr_dscritic;
                             RAISE vr_exc_erro;
                          END IF;

                          IF vr_stsnrcal <> 0 THEN
                             pr_cdcritic := 8;
                             pr_dscritic := '';
                             RAISE vr_exc_erro;
                          END IF;

                          IF cr_verifica_tco%ISOPEN THEN
                             CLOSE cr_verifica_tco;
                          END IF;

                          /* Localiza se o cheque é de uma conta migrada */
                          OPEN cr_verifica_tco(pr_cdcooper
                                              ,vr_dsdctitg);
                          FETCH cr_verifica_tco INTO rw_verifica_tco;

                             -- Se encontrou
                             IF cr_verifica_tco%FOUND THEN

                                vr_achou_lcm := FALSE; -- Recebe Falso

                                IF cr_verifica_lcm1%ISOPEN THEN
                                   CLOSE cr_verifica_lcm1;
                                END IF;

                                OPEN cr_verifica_lcm1(pr_cdcooper
                                                     ,pr_dtmvtolt
                                                     ,rw_verifica_tco.cdagenci
                                                     ,100
                                                     ,205000 + rw_verifica_tco.cdagenci
                                                     ,TO_NUMBER(rw_verifica_chd.nrctachq)
                                                     ,vr_i_nro_docto);
                                FETCH cr_verifica_lcm1 INTO rw_verifica_lcm1;
                                   IF cr_verifica_lcm1%NOTFOUND THEN
                                      pr_cdcritic := 90;
                                      pr_dscritic := '';
                                      RAISE vr_exc_erro;
                                   ELSE
                                      /* Este lancamento soh existe quando o deposito eh feito na coop origem da migracao */
                                      /* Remover lancamento extra caixa de conta sobreposta */

                                      OPEN cr_verifica_bcx(pr_cdcooper
                                                          ,pr_dtmvtolt
                                                          ,pr_cod_agencia
                                                          ,pr_nro_caixa
                                                          ,pr_cod_operador);
                                      FETCH cr_verifica_bcx INTO rw_verifica_bcx;
                                          IF cr_verifica_bcx%NOTFOUND THEN
                                             pr_cdcritic := 698;
                                             pr_dscritic := '';
                                             RAISE vr_exc_erro;
                                          ELSE
                                             BEGIN -- Deletando BCX
                                               DELETE crapbcx bcx
                                                WHERE bcx.cdcooper = pr_cdcooper
                                                  AND bcx.dtmvtolt = pr_dtmvtolt
                                                  AND bcx.cdagenci = pr_cod_agencia
                                                  AND bcx.nrdcaixa = pr_nro_caixa
                                                  AND bcx.cdopecxa = pr_cod_operador
                                                  AND bcx.cdsitbcx = 1;
                                             EXCEPTION
                                                WHEN OTHERS THEN
                                                   pr_cdcritic := 0;
                                                   pr_dscritic := 'Erro ao excluir registro da CRAPBCX : '||sqlerrm;
                                                   RAISE vr_exc_erro;
                                             END;
                                          END IF;
                                      CLOSE cr_verifica_bcx;

                                      OPEN cr_verifica_lcx(pr_cdcooper
                                                          ,pr_dtmvtolt
                                                          ,pr_cod_agencia
                                                          ,pr_nro_caixa
                                                          ,pr_cod_operador
                                                          ,TO_NUMBER(TO_CHAR(rw_verifica_fdc.nrcheque)||
                                                                     TO_CHAR(rw_verifica_fdc.nrdigchq))
                                                          ,704);
                                      FETCH cr_verifica_lcx INTO rw_verifica_lcx;
                                         IF cr_verifica_lcx%NOTFOUND THEN
                                            pr_cdcritic := 90;
                                            pr_dscritic := '';
                                            RAISE vr_exc_erro;
                                         ELSE
                                            BEGIN -- Deletando LCX
                                               DELETE craplcx lcx
                                                WHERE lcx.cdcooper = pr_cdcooper
                                                  AND lcx.dtmvtolt = pr_dtmvtolt
                                                  AND lcx.cdagenci = pr_cod_agencia
                                                  AND lcx.nrdcaixa = pr_nro_caixa
                                                  AND lcx.cdopecxa = pr_cod_operador
                                                  AND lcx.nrdocmto = TO_NUMBER(TO_CHAR(rw_verifica_fdc.nrcheque)||
                                                                               TO_CHAR(rw_verifica_fdc.nrdigchq))
                                                  AND lcx.cdhistor = 704;
                                            EXCEPTION
                                               WHEN OTHERS THEN
                                                  pr_cdcritic := 0;
                                                  pr_dscritic := 'Erro ao excluir registro da CRAPLCX : '||sqlerrm;
                                                  RAISE vr_exc_erro;
                                            END;
                                         END IF;
                                      CLOSE cr_verifica_lcx;

                                      BEGIN -- Decrementando LOTE
                                        UPDATE craplot lot
                                           SET lot.qtcompln = lot.qtcompln - 1
                                              ,lot.qtinfoln = lot.qtinfoln - 1
                                              ,lot.vlcompdb = lot.vlcompdb - rw_verifica_lcm1.vllanmto
                                              ,lot.vlinfodb = lot.vlinfodb - rw_verifica_lcm1.vllanmto
                                        WHERE lot.cdcooper = vr_aux_cdcooper
                                          AND lot.dtmvtolt = pr_dtmvtolt
                                          AND lot.cdagenci = vr_aux_cdagenci
                                          AND lot.cdbccxlt = vr_aux_cdbccxlt
                                          AND lot.nrdolote = vr_i_nro_lote;
                                      EXCEPTION
                                         WHEN OTHERS THEN
                                            pr_cdcritic := 0;
                                            pr_dscritic := 'Erro ao atualizar registro de LOTE : '||sqlerrm;
                                            RAISE vr_exc_erro;
                                      END;

                                      BEGIN
                                        DELETE craplcm lcm
                                         WHERE lcm.cdcooper = rw_verifica_lcm1.cdcooper
                                           AND lcm.dtmvtolt = rw_verifica_lcm1.dtmvtolt
                                           AND lcm.cdagenci = rw_verifica_lcm1.cdcmpchq
                                           AND lcm.cdbccxlt = rw_verifica_lcm1.cdbanchq
                                           AND lcm.nrdolote = rw_verifica_lcm1.cdagechq
                                           AND lcm.nrctachq = rw_verifica_lcm1.nrctachq
                                           AND lcm.nrdocmto = rw_verifica_lcm1.nrdocmto;
                                      EXCEPTION
                                         WHEN OTHERS THEN
                                            pr_cdcritic := 0;
                                            pr_dscritic := 'Erro ao atualizar CRAPCHD : '||sqlerrm;

                                            cxon0000.pc_cria_erro(pr_cdcooper => pr_cdcooper
                                                                 ,pr_cdagenci => pr_cod_agencia
                                                                 ,pr_nrdcaixa => pr_nro_caixa
                                                                 ,pr_cod_erro => pr_cdcritic
                                                                 ,pr_dsc_erro => pr_dscritic
                                                                 ,pr_flg_erro => TRUE
                                                                 ,pr_cdcritic => vr_cdcritic
                                                                 ,pr_dscritic => vr_dscritic);

                                            IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                                               pr_cdcritic := vr_cdcritic;
                                               pr_dscritic := vr_dscritic;
                                               RAISE vr_exc_erro;
                                            END IF;

                                            RAISE vr_exc_erro;
                                      END;

                                   END IF;
                                IF cr_verifica_lcm1%ISOPEN THEN
                                   CLOSE cr_verifica_lcm1;
                                END IF;
                             END IF;
                          IF cr_verifica_tco%ISOPEN THEN
                             CLOSE cr_verifica_tco;
                          END IF;

                      ELSE
                          pr_cdcritic := 90;
                          pr_dscritic := '';
                          RAISE vr_exc_erro;
                      END IF;
                   END IF;
                ELSE

                   BEGIN -- Decrementando LOTE
                      UPDATE craplot lot
                         SET lot.qtcompln = lot.qtcompln - 1
                            ,lot.qtinfoln = lot.qtinfoln - 1
                            ,lot.vlcompdb = lot.vlcompdb - rw_verifica_lcm1.vllanmto
                            ,lot.vlinfodb = lot.vlinfodb - rw_verifica_lcm1.vllanmto
                       WHERE lot.cdcooper = rw_verifica_lcm1.cdcooper
                         AND lot.dtmvtolt = rw_verifica_lcm1.dtmvtolt
                         AND lot.cdagenci = rw_verifica_lcm1.cdagenci
                         AND lot.cdbccxlt = rw_verifica_lcm1.cdbccxlt
                         AND lot.nrdolote = rw_verifica_lcm1.nrdolote;

                   EXCEPTION
                      WHEN OTHERS THEN
                         pr_cdcritic := 0;
                         pr_dscritic := 'Erro ao atualizar registro de LOTE : '||sqlerrm;
                         RAISE vr_exc_erro;
                   END;

                   BEGIN
                      DELETE craplcm lcm
                       WHERE lcm.cdcooper = rw_verifica_lcm1.cdcooper
                         AND lcm.dtmvtolt = rw_verifica_lcm1.dtmvtolt
                         AND lcm.cdagenci = rw_verifica_lcm1.cdagenci
                         AND lcm.cdbccxlt = rw_verifica_lcm1.cdbccxlt
                         AND lcm.nrdolote = rw_verifica_lcm1.nrdolote
                         AND lcm.nrdctabb = rw_verifica_lcm1.nrdctabb
                         AND lcm.nrdocmto = rw_verifica_lcm1.nrdocmto;
                    EXCEPTION
                       WHEN OTHERS THEN
                          pr_cdcritic := 0;
                          pr_dscritic := 'Erro ao atualizar CRAPCHD : '||sqlerrm;

                          cxon0000.pc_cria_erro(pr_cdcooper => pr_cdcooper
                                               ,pr_cdagenci => pr_cod_agencia
                                               ,pr_nrdcaixa => pr_nro_caixa
                                               ,pr_cod_erro => pr_cdcritic
                                               ,pr_dsc_erro => pr_dscritic
                                               ,pr_flg_erro => TRUE
                                               ,pr_cdcritic => vr_cdcritic
                                               ,pr_dscritic => vr_dscritic);

                          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                             pr_cdcritic := vr_cdcritic;
                             pr_dscritic := vr_dscritic;
                             RAISE vr_exc_erro;
                          END IF;

                          RAISE vr_exc_erro;
                    END;

                END IF;
             IF cr_verifica_lcm1%ISOPEN THEN
                CLOSE cr_verifica_lcm1;
             END IF;

          ELSE -- CHEQUE DE FORA

             OPEN cr_verifica_cop(pr_cdcooper);
             FETCH cr_verifica_cop INTO rw_verifica_cop;
             CLOSE cr_verifica_cop;

             /** Incrementa contagem de cheques para a previa **/
             CXON0000.pc_atualiza_previa_cxa(pr_cooper       => rw_verifica_cop.nmrescop
                                            ,pr_cod_agencia  => pr_cod_agencia
                                            ,pr_nro_caixa    => pr_nro_caixa
                                            ,pr_cod_operador => pr_cod_operador
                                            ,pr_dtmvtolt     => pr_dtmvtolt
                                            ,pr_operacao     => 2 -- Estorno
                                            ,pr_retorno      => pr_retorno
                                            ,pr_cdcritic     => vr_cdcritic
                                            ,pr_dscritic     => vr_dscritic);

             IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := vr_cdcritic;
                RAISE vr_exc_erro;
             END IF;

          END IF;

          BEGIN
            DELETE crapchd chd
             WHERE chd.cdcooper = rw_verifica_chd.cdcooper
               AND chd.dtmvtolt = rw_verifica_chd.dtmvtolt
               AND chd.cdcmpchq = rw_verifica_chd.cdcmpchq
               AND chd.cdbanchq = rw_verifica_chd.cdbanchq
               AND chd.cdagechq = rw_verifica_chd.cdagechq
               AND chd.nrctachq = rw_verifica_chd.nrctachq
               AND chd.nrcheque = rw_verifica_chd.nrcheque;
          EXCEPTION
             WHEN OTHERS THEN
                pr_cdcritic := 0;
                pr_dscritic := 'Erro ao atualizar CRAPCHD : '||sqlerrm;

                cxon0000.pc_cria_erro(pr_cdcooper => pr_cdcooper
                                     ,pr_cdagenci => pr_cod_agencia
                                     ,pr_nrdcaixa => pr_nro_caixa
                                     ,pr_cod_erro => pr_cdcritic
                                     ,pr_dsc_erro => pr_dscritic
                                     ,pr_flg_erro => TRUE
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);

                IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                   pr_cdcritic := vr_cdcritic;
                   pr_dscritic := vr_dscritic;
                   RAISE vr_exc_erro;
                END IF;

                RAISE vr_exc_erro;
          END;

      END LOOP; -- Fim do FOR CRAPCHD

      pr_retorno := 'OK';

   EXCEPTION
     WHEN vr_exc_erro THEN
          pr_retorno  := 'NOK';
          ROLLBACK; -- Desfaz as alterações

     WHEN OTHERS THEN
         pr_retorno  := 'NOK';
         pr_cdcritic := 0;
         pr_dscritic := 'Erro na rotina CXON0088.pc_verifica_crapchd_coop. '||SQLERRM;
         ROLLBACK; -- Desfaz as alterações
   END pc_verifica_crapchd_coop;

   PROCEDURE pc_verifica_crapchd(pr_cdcooper    IN INTEGER      --> Coop. Origem
                               ,pr_cod_agencia  IN INTEGER      --> Cod. Agencia
                               ,pr_nro_caixa    IN INTEGER      --> Nro Caixa
                               ,pr_cod_operador IN VARCHAR2     --> Cod Operador
                               ,pr_nro_conta    IN INTEGER      --> Nro Conta
                               ,pr_nro_lote     IN INTEGER      --> Nrd Documento
                               ,pr_nro_docmto   IN INTEGER      --> Nrd Documento
                               ,pr_dtmvtolt     IN DATE         --> Data de Lancamento
                               ,pr_nrseqdig     IN INTEGER      --> Nro da Sequencia de Digito LCM
                               ,pr_cdhistor     IN INTEGER      --> Codigo do Historico
                               ,pr_cdbcoctl     IN INTEGER      -->
                               ,pr_cdagectl     IN INTEGER      -->
                               ,pr_lsconta1     IN VARCHAR2     --> ''
                               ,pr_lsconta3     IN VARCHAR2     --> ''
                               ,pr_retorno     OUT VARCHAR2     --> Retorna OK/NOK
                               ,pr_cdcritic    OUT INTEGER      --> Cod. Critica
                               ,pr_dscritic    OUT VARCHAR2) IS --> Des. da Critica
   ---------------------------------------------------------------------------------------------------------------
   --
   --  Programa : pc_verifica_crapchd Fonte: dbo/b1crap88.p/verifica-crapchd
   --  Sistema  : Estorno de Depositos Cheques Intercooperativas
   --  Sigla    : CRED
   --  Autor    : Andre Santos - SUPERO
   --  Data     : Julho/2014.                   Ultima atualizacao:
   --
   -- Dados referentes ao programa:
   --
   -- Frequencia: -----
   -- Objetivo  :

   -- Alteracoes:
   ---------------------------------------------------------------------------------------------------------------

   CURSOR cr_verifica_cop(p_cdcooper IN INTEGER) IS
      SELECT UPPER(cop.nmrescop) nmrescop
        FROM crapcop cop
       WHERE cop.cdcooper = p_cdcooper;
   rw_verifica_cop cr_verifica_cop%ROWTYPE;

   /* Lancamento de pagamento do cheque - DEBITO */
   CURSOR cr_verifica_lcm1(p_cdcooper IN INTEGER
                          ,p_dtmvtolt IN DATE
                          ,p_cdagenci IN INTEGER
                          ,p_cdbccxlt IN INTEGER
                          ,p_nrdolote IN INTEGER
                          ,p_nrctachq IN INTEGER
                          ,p_nrdocmto IN INTEGER) IS
      SELECT lcm.cdcooper
            ,lcm.dtmvtolt
            ,lcm.cdagenci
            ,lcm.cdbccxlt
            ,lcm.nrdolote
            ,lcm.nrdctabb
            ,lcm.nrdocmto
            ,lcm.vllanmto
        FROM craplcm lcm
       WHERE lcm.cdcooper = p_cdcooper
         AND lcm.dtmvtolt = p_dtmvtolt
         AND lcm.cdagenci = p_cdagenci
         AND lcm.cdbccxlt = p_cdbccxlt
         AND lcm.nrdolote = p_nrdolote
         AND lcm.nrctachq = p_nrctachq
         AND lcm.nrdocmto = p_nrdocmto;
   rw_verifica_lcm1 cr_verifica_lcm1%ROWTYPE;

   /* Verifica LOTE */
   CURSOR cr_consulta_lot (p_cdcooper IN craplot.cdcooper%TYPE
                          ,p_dtmvtolt IN craplot.dtmvtolt%TYPE
                          ,p_cdagenci IN craplot.cdagenci%TYPE
                          ,p_cdbccxlt IN craplot.cdbccxlt%TYPE
                          ,p_nrdolote IN craplot.nrdolote%TYPE) IS
      SELECT lot.cdcooper
            ,lot.dtmvtolt
            ,lot.cdagenci
            ,lot.cdbccxlt
            ,lot.nrdolote
            ,lot.vlcompdb
            ,lot.vlinfodb
            ,lot.vlcompcr
            ,lot.vlinfocr
        FROM craplot lot
       WHERE lot.cdcooper = p_cdcooper
         AND lot.dtmvtolt = p_dtmvtolt
         AND lot.cdagenci = p_cdagenci
         AND lot.cdbccxlt = p_cdbccxlt
         AND lot.nrdolote = p_nrdolote;
   rw_consulta_lot cr_consulta_lot%ROWTYPE;

   CURSOR cr_verifica_chd(p_cdcooper IN INTEGER
                         ,p_dtmvtolt IN DATE
                         ,p_cdagenci IN INTEGER
                         ,p_cdbccxlt IN INTEGER
                         ,p_nrdolote IN INTEGER
                         ,p_nrdocmto IN INTEGER
                         ,p_nrseqdig IN INTEGER)IS
      SELECT chd.cdcooper
            ,chd.dtmvtolt
            ,chd.cdcmpchq
            ,chd.cdbanchq
            ,chd.cdagechq
            ,chd.nrctachq
            ,chd.nrcheque
            ,chd.cdagenci
            ,chd.cdbccxlt
            ,chd.nrdocmto
            ,chd.cdoperad
            ,chd.cdsitatu
            ,chd.dsdocmc7
            ,chd.inchqcop
            ,chd.insitchq
            ,chd.cdtipchq
            ,chd.nrdconta
            ,chd.nrddigc1
            ,chd.nrddigc2
            ,chd.nrddigc3
            ,chd.nrddigv1
            ,chd.nrddigv2
            ,chd.nrddigv3
            ,chd.nrdolote
            ,chd.tpdmovto
            ,chd.nrterfin
            ,chd.vlcheque
            ,chd.cdagedst
            ,chd.nrctadst
        FROM crapchd chd
       WHERE chd.cdcooper = p_cdcooper
         AND chd.dtmvtolt = p_dtmvtolt
         AND chd.cdagenci = p_cdagenci
         AND chd.cdbccxlt = p_cdbccxlt
         AND chd.nrdolote = p_nrdolote
         AND chd.nrdocmto LIKE p_nrdocmto||'%'
         AND chd.nrseqdig = p_nrseqdig;
   rw_verifica_chd cr_verifica_chd%ROWTYPE;

   CURSOR cr_verifica_fdc (p_cdcooper IN crapfdc.cdcooper%TYPE
                          ,p_cdbanchq IN crapfdc.cdbanchq%TYPE
                          ,p_cdagechq IN crapfdc.cdcmpchq%TYPE
                          ,p_nrctachq IN crapfdc.cdbanchq%TYPE
                          ,p_nrcheque IN crapfdc.cdagechq%TYPE) IS
     SELECT fdc.incheque
           ,fdc.dtliqchq
           ,fdc.cdoperad
           ,fdc.vlcheque
           ,fdc.cdbanchq
           ,fdc.cdagechq
           ,fdc.nrctachq
           ,fdc.tpcheque
           ,fdc.nrcheque
           ,fdc.nrdigchq
       FROM crapfdc fdc
      WHERE fdc.cdcooper = p_cdcooper
        AND fdc.cdbanchq = p_cdbanchq
        AND fdc.cdagechq = p_cdagechq
        AND fdc.nrctachq = p_nrctachq
        AND fdc.nrcheque = p_nrcheque;
   rw_verifica_fdc cr_verifica_fdc%ROWTYPE;

   CURSOR cr_verifica_tco(p_cdcooper IN INTEGER
                         ,p_nrctaant IN INTEGER) IS
      SELECT tco.cdcopant
            ,tco.cdagenci
            ,tco.cdcooper
        FROM craptco tco
       WHERE tco.cdcooper = p_cdcooper
         AND tco.nrctaant = p_nrctaant
         AND tco.tpctatrf = 1
         AND tco.flgativo = 1;
   rw_verifica_tco cr_verifica_tco%ROWTYPE;

   CURSOR cr_verifica_bcx(p_cdcooper IN INTEGER
                         ,p_dtmvtolt IN DATE
                         ,p_cdagenci IN INTEGER
                         ,p_nrdcaixa IN INTEGER
                         ,p_cdopecxa IN VARCHAR2) IS
      SELECT bcx.cdcooper
        FROM crapbcx bcx
       WHERE bcx.cdcooper = p_cdcooper
         AND bcx.dtmvtolt = p_dtmvtolt
         AND bcx.cdagenci = p_cdagenci
         AND bcx.nrdcaixa = p_nrdcaixa
         AND UPPER(bcx.cdopecxa) = UPPER(p_cdopecxa)
         AND bcx.cdsitbcx = 1;
   rw_verifica_bcx cr_verifica_bcx%ROWTYPE;

   -- Variaveis Erro
   vr_cdcritic crapcri.cdcritic%TYPE;
   vr_dscritic VARCHAR2(4000);
   vr_exc_erro EXCEPTION;

   -- Variaveis
   vr_aux_cdcooper INTEGER               := 0;
   vr_aux_cdagenci INTEGER               := 0;
   vr_aux_cdbccxlt INTEGER               := 0;
   vr_i_nro_lote   INTEGER               := 0;
   vr_i_nro_docto  INTEGER               := 0;
   vr_dsdctitg VARCHAR2(200)             := '';
   vr_aux_nrctaass VARCHAR2(200)         := '';
   vr_stsnrcal INTEGER                   := 0;
   vr_aux_nrdctitg crapass.nrdctitg%TYPE := '';
   vr_achou_fdc BOOLEAN      := FALSE;
   vr_achou_lcm BOOLEAN      := FALSE;
   vr_coop INTEGER           := 0;

   BEGIN

      -- Dados de ORIGEM
      vr_aux_cdcooper := pr_cdcooper;
      vr_aux_cdagenci := pr_cod_agencia;
      vr_aux_cdbccxlt := 11;
      vr_i_nro_lote   := 11000 + pr_nro_caixa;

      /** Posicionar no LOTE de ORIGEM */
      OPEN cr_consulta_lot(vr_aux_cdcooper
                          ,pr_dtmvtolt
                          ,vr_aux_cdagenci
                          ,vr_aux_cdbccxlt
                          ,vr_i_nro_lote);
      FETCH cr_consulta_lot INTO rw_consulta_lot;
         IF cr_consulta_lot%NOTFOUND THEN
            pr_cdcritic := 60;
            pr_dscritic := '';
            RAISE vr_exc_erro;
         END IF;
      CLOSE cr_consulta_lot;

      FOR rw_verifica_chd IN cr_verifica_chd(pr_cdcooper
                                            ,pr_dtmvtolt
                                            ,pr_cod_agencia
                                            ,11
                                            ,vr_i_nro_lote
                                            ,pr_nro_docmto
                                            ,pr_nrseqdig) LOOP

         -- Formata conta integracao
         GENE0005.pc_conta_itg_digito_x(pr_nrcalcul => rw_verifica_chd.nrctachq
                                       ,pr_dscalcul => vr_dsdctitg
                                       ,pr_stsnrcal => vr_stsnrcal
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic);
         -- Se ocorreu erro
         IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := vr_dscritic;
            RAISE vr_exc_erro;
         END IF;

         vr_aux_nrdctitg := '';

         /**  Conta Integracao **/
         IF LENGTH(rw_verifica_chd.nrctachq) <= 8 THEN
            /* Verifica da conta integracão do associado */
            GENE0005.pc_existe_conta_integracao(pr_cdcooper => pr_cdcooper
                                               ,pr_ctpsqitg => rw_verifica_chd.nrctachq
                                               ,pr_nrdctitg => vr_aux_nrdctitg
                                               ,pr_nrctaass => vr_aux_nrctaass
                                               ,pr_des_erro => vr_dscritic);
            IF vr_dscritic IS NOT NULL THEN
               pr_cdcritic := 0;
               pr_dscritic := vr_dscritic;
               RAISE vr_exc_erro;
            END IF;
         END IF;

         IF pr_cdhistor = 1524 THEN -- CHEQUE COOP

            IF (rw_verifica_chd.cdbanchq = 1     AND
                 rw_verifica_chd.cdagechq = 3420) OR
                (vr_aux_nrdctitg <> ''            AND
                 (gene0002.fn_existe_valor(pr_base     => '3420'
                                          ,pr_busca    => TO_CHAR(rw_verifica_chd.cdagechq)
                                          ,pr_delimite => ',')='S')) THEN

                IF (gene0002.fn_existe_valor(pr_base     => pr_lsconta1
                                            ,pr_busca    => TO_CHAR(rw_verifica_chd.nrctachq)
                                            ,pr_delimite => ',')='S') OR
                   vr_aux_nrdctitg <> '' THEN

                   -- Verificando Folha de Cheque
                   OPEN cr_verifica_fdc(rw_verifica_chd.cdcooper
                                       ,rw_verifica_chd.cdbanchq
                                       ,rw_verifica_chd.cdagechq
                                       ,rw_verifica_chd.nrctachq
                                       ,rw_verifica_chd.nrcheque);
                   FETCH cr_verifica_fdc INTO rw_verifica_fdc;

                      -- Se nao encontrou
                      IF cr_verifica_fdc%NOTFOUND THEN
                         pr_cdcritic := 108;
                         pr_dscritic := '';
                         RAISE vr_exc_erro;
                      END IF;

                      BEGIN
                         UPDATE crapfdc fdc
                            SET fdc.incheque = 0
                               ,fdc.vlcheque = 0
                               ,fdc.cdoperad = NULL
                               ,fdc.dtliqchq = NULL
                               ,fdc.cdbandep = 0
                               ,fdc.cdagedep = 0
                               ,fdc.nrctadep = 0
                          WHERE fdc.cdcooper = rw_verifica_chd.cdcooper
                            AND fdc.cdbanchq = rw_verifica_chd.cdbanchq
                            AND fdc.cdagechq = rw_verifica_chd.cdagechq
                            AND fdc.nrctachq = rw_verifica_chd.nrctachq
                            AND fdc.nrcheque = rw_verifica_chd.nrcheque;
                      EXCEPTION
                         WHEN OTHERS THEN
                            pr_cdcritic := 0;
                            pr_dscritic := 'Erro ao atualizar CRAPFDC : '||sqlerrm;
                            RAISE vr_exc_erro;
                      END;
                   CLOSE cr_verifica_fdc;

                ELSE

                   IF (gene0002.fn_existe_valor(pr_base     => pr_lsconta3
                                               ,pr_busca    => TO_CHAR(rw_verifica_chd.nrctachq)
                                               ,pr_delimite => ',')='S') THEN

                      -- Verificando Folha de Cheque
                      OPEN cr_verifica_fdc(rw_verifica_chd.cdcooper
                                          ,rw_verifica_chd.cdbanchq
                                          ,rw_verifica_chd.cdagechq
                                          ,rw_verifica_chd.nrctachq
                                          ,rw_verifica_chd.nrcheque);
                      FETCH cr_verifica_fdc INTO rw_verifica_fdc;

                         vr_achou_fdc := TRUE; -- Inicializa como TRUE

                         -- Se nao encontrou
                         IF cr_verifica_fdc%NOTFOUND THEN
                            pr_cdcritic := 286;
                            pr_dscritic := '';
                            RAISE vr_exc_erro;
                         END IF;

                         BEGIN
                            UPDATE crapfdc fdc
                               SET fdc.incheque = 0
                                  ,fdc.vlcheque = 0
                                  ,fdc.cdoperad = NULL
                                  ,fdc.dtliqchq = NULL
                                  ,fdc.cdbandep = 0
                                  ,fdc.cdagedep = 0
                                  ,fdc.nrctadep = 0
                             WHERE fdc.cdcooper = rw_verifica_chd.cdcooper
                               AND fdc.cdbanchq = rw_verifica_chd.cdbanchq
                               AND fdc.cdagechq = rw_verifica_chd.cdagechq
                               AND fdc.nrctachq = rw_verifica_chd.nrctachq
                               AND fdc.nrcheque = rw_verifica_chd.nrcheque;
                         EXCEPTION
                            WHEN OTHERS THEN
                              pr_cdcritic := 0;
                              pr_dscritic := 'Erro ao atualizar CRAPFDC : '||sqlerrm;
                              RAISE vr_exc_erro;
                         END;
                      CLOSE cr_verifica_fdc;
                   END IF;
                END IF;

             ELSE

                IF ((rw_verifica_chd.cdbanchq = 756 OR /* BANCOOB */
                   rw_verifica_chd.cdbanchq = pr_cdbcoctl)
                   OR /* IF CECRED */
                   (rw_verifica_chd.cdbanchq = pr_cdbcoctl AND
                    rw_verifica_chd.cdagechq = pr_cdagectl)) THEN

                   IF (gene0002.fn_existe_valor(pr_base     => pr_lsconta3
                                               ,pr_busca    => TO_CHAR(rw_verifica_chd.nrctachq)
                                               ,pr_delimite => ',')='S') THEN

                      -- Verificando Folha de Cheque
                      OPEN cr_verifica_fdc(rw_verifica_chd.cdcooper
                                          ,rw_verifica_chd.cdbanchq
                                          ,rw_verifica_chd.cdagechq
                                          ,rw_verifica_chd.nrctachq
                                          ,rw_verifica_chd.nrcheque);
                      FETCH cr_verifica_fdc INTO rw_verifica_fdc;

                         vr_achou_fdc := TRUE; -- Inicializa como TRUE

                         -- Se nao encontrou
                         IF cr_verifica_fdc%NOTFOUND THEN
                            pr_cdcritic := 286;
                            pr_dscritic := '';
                            RAISE vr_exc_erro;
                         END IF;

                         BEGIN
                            UPDATE crapfdc fdc
                               SET fdc.incheque = 0
                                  ,fdc.vlcheque = 0
                                  ,fdc.cdoperad = NULL
                                  ,fdc.dtliqchq = NULL
                                  ,fdc.cdbandep = 0
                                  ,fdc.cdagedep = 0
                                  ,fdc.nrctadep = 0
                             WHERE fdc.cdcooper = rw_verifica_chd.cdcooper
                               AND fdc.cdbanchq = rw_verifica_chd.cdbanchq
                               AND fdc.cdagechq = rw_verifica_chd.cdagechq
                               AND fdc.nrctachq = rw_verifica_chd.nrctachq
                               AND fdc.nrcheque = rw_verifica_chd.nrcheque;
                         EXCEPTION
                            WHEN OTHERS THEN
                               pr_cdcritic := 0;
                               pr_dscritic := 'Erro ao atualizar CRAPFDC : '||sqlerrm;
                               RAISE vr_exc_erro;
                      END;
                      CLOSE cr_verifica_fdc;

                   ELSE

                      OPEN cr_verifica_fdc(rw_verifica_chd.cdcooper
                                          ,rw_verifica_chd.cdbanchq
                                          ,rw_verifica_chd.cdagechq
                                          ,rw_verifica_chd.nrctachq
                                          ,rw_verifica_chd.nrcheque);
                      FETCH cr_verifica_fdc INTO rw_verifica_fdc;

                         vr_achou_fdc := TRUE; -- Inicializa como TRUE

                         -- Se nao encontrou
                         IF cr_verifica_fdc%NOTFOUND THEN
                            pr_cdcritic := 108;
                            pr_dscritic := '';
                            RAISE vr_exc_erro;
                         END IF;

                         BEGIN
                            UPDATE crapfdc fdc
                               SET fdc.incheque = 0
                                  ,fdc.vlcheque = 0
                                  ,fdc.cdoperad = NULL
                                  ,fdc.dtliqchq = NULL
                                  ,fdc.cdbandep = 0
                                  ,fdc.cdagedep = 0
                                  ,fdc.nrctadep = 0
                             WHERE fdc.cdcooper = rw_verifica_chd.cdcooper
                               AND fdc.cdbanchq = rw_verifica_chd.cdbanchq
                               AND fdc.cdagechq = rw_verifica_chd.cdagechq
                               AND fdc.nrctachq = rw_verifica_chd.nrctachq
                               AND fdc.nrcheque = rw_verifica_chd.nrcheque;
                         EXCEPTION
                            WHEN OTHERS THEN
                               pr_cdcritic := 0;
                               pr_dscritic := 'Erro ao atualizar CRAPFDC: '||sqlerrm;
                               RAISE vr_exc_erro;
                         END;
                      CLOSE cr_verifica_fdc;
                   END IF;
                END IF;
             END IF;

             /* Lancamento de pagamento do cheque - DEBITO */
             OPEN cr_verifica_lcm1(pr_cdcooper
                                  ,rw_verifica_chd.dtmvtolt
                                  ,rw_verifica_chd.cdagenci
                                  ,rw_verifica_chd.cdbccxlt
                                  ,rw_verifica_chd.nrdolote
                                  ,TO_NUMBER(rw_verifica_chd.nrctachq)
                                  ,vr_i_nro_docto);
             FETCH cr_verifica_lcm1 INTO rw_verifica_lcm1;

                IF cr_verifica_lcm1%NOTFOUND THEN
                   pr_cdcritic := 90;
                   pr_dscritic := '';
                   RAISE vr_exc_erro;
                END IF;

                BEGIN -- Decrementando LOTE
                  UPDATE craplot lot
                     SET lot.qtcompln = lot.qtcompln - 1
                        ,lot.qtinfoln = lot.qtinfoln - 1
                        ,lot.vlcompdb = lot.vlcompdb - rw_verifica_lcm1.vllanmto
                        ,lot.vlinfodb = lot.vlinfodb - rw_verifica_lcm1.vllanmto
                   WHERE lot.cdcooper = vr_aux_cdcooper
                     AND lot.dtmvtolt = pr_dtmvtolt
                     AND lot.cdagenci = vr_aux_cdagenci
                     AND lot.cdbccxlt = vr_aux_cdbccxlt
                     AND lot.nrdolote = vr_i_nro_lote;
                EXCEPTION
                   WHEN OTHERS THEN
                      pr_cdcritic := 0;
                      pr_dscritic := 'Erro ao atualizar registro de LOTE : '||sqlerrm;
                      RAISE vr_exc_erro;
                END;

                BEGIN -- Deletando LCM
                  DELETE craplcm lcm
                   WHERE lcm.cdcooper = pr_cdcooper
                     AND lcm.dtmvtolt = rw_verifica_chd.dtmvtolt
                     AND lcm.cdagenci = rw_verifica_chd.cdagenci
                     AND lcm.cdbccxlt = rw_verifica_chd.cdbccxlt
                     AND lcm.nrdolote = rw_verifica_chd.nrdolote
                     AND lcm.nrctachq = TO_NUMBER(rw_verifica_chd.nrctachq)
                     AND lcm.nrdocmto = vr_i_nro_docto;
                EXCEPTION
                   WHEN OTHERS THEN
                      pr_cdcritic := 0;
                      pr_dscritic := 'Erro ao excluir registro da CRAPLCM : '||sqlerrm;
                      RAISE vr_exc_erro;
                END;

             CLOSE cr_verifica_lcm1;

         ELSE -- Cheque Fora

            OPEN cr_verifica_cop(pr_cdcooper);
            FETCH cr_verifica_cop INTO rw_verifica_cop;
            CLOSE cr_verifica_cop;

            /** Incrementa contagem de cheques para a previa **/
            CXON0000.pc_atualiza_previa_cxa(pr_cooper       => rw_verifica_cop.nmrescop
                                           ,pr_cod_agencia  => pr_cod_agencia
                                           ,pr_nro_caixa    => pr_nro_caixa
                                           ,pr_cod_operador => pr_cod_operador
                                           ,pr_dtmvtolt     => pr_dtmvtolt
                                           ,pr_operacao     => 2 -- Estorno
                                           ,pr_retorno      => pr_retorno
                                           ,pr_cdcritic     => vr_cdcritic
                                           ,pr_dscritic     => vr_dscritic);

            IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
               pr_cdcritic := vr_cdcritic;
               pr_dscritic := vr_cdcritic;
               RAISE vr_exc_erro;
            END IF;

         END IF;

         BEGIN
            DELETE crapchd chd
             WHERE chd.cdcooper = rw_verifica_chd.cdcooper
               AND chd.dtmvtolt = rw_verifica_chd.dtmvtolt
               AND chd.cdcmpchq = rw_verifica_chd.cdcmpchq
               AND chd.cdbanchq = rw_verifica_chd.cdbanchq
               AND chd.cdagechq = rw_verifica_chd.cdagechq
               AND chd.nrctachq = rw_verifica_chd.nrctachq
               AND chd.nrcheque = rw_verifica_chd.nrcheque;
         EXCEPTION
            WHEN OTHERS THEN
               pr_cdcritic := 0;
               pr_dscritic := 'Erro ao atualizar CRAPCHD : '||sqlerrm;

               cxon0000.pc_cria_erro(pr_cdcooper => pr_cdcooper
                                    ,pr_cdagenci => pr_cod_agencia
                                    ,pr_nrdcaixa => pr_nro_caixa
                                    ,pr_cod_erro => pr_cdcritic
                                    ,pr_dsc_erro => pr_dscritic
                                    ,pr_flg_erro => TRUE
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic);

               IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                  pr_cdcritic := vr_cdcritic;
                  pr_dscritic := vr_dscritic;
                  RAISE vr_exc_erro;
               END IF;

               RAISE vr_exc_erro;
         END;

      END LOOP; -- FIM do For CRAPCHD

      pr_retorno := 'OK';

   EXCEPTION
     WHEN vr_exc_erro THEN
          pr_retorno  := 'NOK';
          ROLLBACK; -- Desfaz as alterações

     WHEN OTHERS THEN
         pr_retorno  := 'NOK';
         pr_cdcritic := 0;
         pr_dscritic := 'Erro na rotina CXON0088.pc_verifica_crapchd '||SQLERRM;
         ROLLBACK; -- Desfaz as alterações
   END pc_verifica_crapchd;


   PROCEDURE pc_estorna_dep_chq_captura(pr_cooper       IN VARCHAR2     --> Coop. Origem
                                       ,pr_cod_agencia  IN INTEGER      --> Cod. Agencia
                                       ,pr_nro_caixa    IN INTEGER      --> Nro Caixa
                                       ,pr_cod_operador IN VARCHAR2     --> Cod Operador
                                       ,pr_cooper_dest  IN VARCHAR2     --> Coop. Destino
                                       ,pr_nro_conta    IN INTEGER      --> Nro Conta
                                       ,pr_nro_docmto   IN INTEGER      --> Nrd Documento
                                       ,pr_valor_coop   IN NUMBER       --> Valor Coop
                                       ,pr_vestorno     IN INTEGER      --> Flag Estorno(1-TRUE/0-FALSE)
                                       ,pr_valor       OUT NUMBER       --> Valor do lancamento
                                       ,pr_retorno     OUT VARCHAR2     --> Retorna OK/NOK
                                       ,pr_cdcritic    OUT INTEGER      --> Cod. Critica
                                       ,pr_dscritic    OUT VARCHAR2) IS --> Des. da Critica
   ---------------------------------------------------------------------------------------------------------------
   --
   --  Programa : pc_valida_chq_captura Fonte: dbo/b1crap88.p/estorna-dep-cheque-com-captura
   --  Sistema  : Estorno de Depositos Cheques Intercooperativas
   --  Sigla    : CRED
   --  Autor    : Andre Santos - SUPERO
   --  Data     : Julho/2014.                   Ultima atualizacao:
   --
   -- Dados referentes ao programa:
   --
   -- Frequencia: -----
   -- Objetivo  :

   -- Alteracoes:
   ---------------------------------------------------------------------------------------------------------------

   /* Busca o codigo da Coop. passando como parametro o nome resumido da Coop. */
   CURSOR cr_cod_coop_orig(p_nmrescop IN VARCHAR2) IS
     SELECT cop.cdcooper
           ,cop.cdagectl
           ,cop.cdagebcb
           ,cop.cdbcoctl
           ,cop.cdagedbb
           ,cop.nmrescop
           ,cop.nmextcop
       FROM crapcop cop
      WHERE UPPER(cop.nmrescop) = UPPER(p_nmrescop);
   rw_cod_coop_orig cr_cod_coop_orig%ROWTYPE;

   /* Busca o codigo da Coop. passando como parametro o nome resumido da Coop. */
   CURSOR cr_cod_coop_dest(p_nmrescop IN VARCHAR2) IS
     SELECT cop.cdcooper
           ,cop.cdagectl
           ,cop.cdagebcb
           ,cop.cdbcoctl
           ,cop.cdagedbb
           ,cop.nmrescop
       FROM crapcop cop
      WHERE UPPER(cop.nmrescop) = UPPER(p_nmrescop);
   rw_cod_coop_dest cr_cod_coop_dest%ROWTYPE;

   /* Busca a Data Conforme o Código da Cooperativa */
   CURSOR cr_dat_cop(p_coop IN INTEGER)IS
      SELECT dat.dtmvtolt
            ,dat.dtmvtocd
        FROM crapdat dat
       WHERE dat.cdcooper = p_coop;
   rw_dat_cop cr_dat_cop%ROWTYPE;

   /* Verifica se existe LCM de CREDITO / CHEQUE FORA */
   CURSOR cr_verifica_lcm(p_cdcooper IN INTEGER
                         ,p_dtmvtolt IN DATE
                         ,p_cdagenci IN INTEGER
                         ,p_cdbccxlt IN INTEGER
                         ,p_nrdolote IN INTEGER
                         ,p_nrdctabb IN INTEGER) IS
      SELECT lcm.nrdocmto
            ,lcm.cdpesqbb
            ,lcm.dsidenti
            ,lcm.vllanmto
            ,lcm.dtmvtolt
            ,lcm.nrseqdig
            ,lcm.cdagenci
            ,lcm.cdbccxlt
            ,lcm.nrdolote
            ,lcm.cdcooper
            ,lcm.nrdctabb
            ,lcm.cdhistor
        FROM craplcm lcm
       WHERE lcm.cdcooper = p_cdcooper
         AND lcm.dtmvtolt = p_dtmvtolt
         AND lcm.cdagenci = p_cdagenci
         AND lcm.cdbccxlt = p_cdbccxlt
         AND lcm.nrdolote = p_nrdolote
         AND lcm.nrdctabb = p_nrdctabb;
   rw_verifica_lcm cr_verifica_lcm%ROWTYPE;

   /* Verifica Deposito Bloqueado */
   CURSOR cr_verifica_dpb(p_cdcooper IN INTEGER
                         ,p_dtmvtolt IN DATE
                         ,p_cdagenci IN INTEGER
                         ,p_cdbccxlt IN INTEGER
                         ,p_nrdolote IN INTEGER
                         ,p_nrdconta IN INTEGER
                         ,p_nrdocmto IN INTEGER) IS
     SELECT dpb.inlibera
           ,dpb.dtliblan
       FROM crapdpb dpb
      WHERE dpb.cdcooper = p_cdcooper
        AND dpb.dtmvtolt = p_dtmvtolt
        AND dpb.cdagenci = p_cdagenci
        AND dpb.cdbccxlt = p_cdbccxlt
        AND dpb.nrdolote = p_nrdolote
        AND dpb.nrdconta = p_nrdconta
        AND dpb.nrdocmto = p_nrdocmto;
   rw_verifica_dpb cr_verifica_dpb%ROWTYPE;


   /* Verifiva CHD - COOP ORIGEM */
   CURSOR cr_verifica_chd(p_cdcooper IN INTEGER
                         ,p_dtmvtolt IN DATE
                         ,p_cdagenci IN INTEGER
                         ,p_cdbccxlt IN INTEGER
                         ,p_nrdolote IN INTEGER
                         ,p_nrdocmto IN INTEGER
                         ,p_nrseqdig IN INTEGER)IS
      SELECT chd.insitprv
        FROM crapchd chd
       WHERE chd.cdcooper = p_cdcooper
         AND chd.dtmvtolt = p_dtmvtolt
         AND chd.cdagenci = p_cdagenci
         AND chd.cdbccxlt = p_cdbccxlt
         AND chd.nrdolote = p_nrdolote
         AND chd.nrdocmto LIKE p_nrdocmto||'%'
         AND chd.nrseqdig = p_nrseqdig;
   rw_verifica_chd cr_verifica_chd%ROWTYPE;

   /* Verifica LOTE */
   CURSOR cr_consulta_lot (p_cdcooper IN craplot.cdcooper%TYPE
                          ,p_dtmvtolt IN craplot.dtmvtolt%TYPE
                          ,p_cdagenci IN craplot.cdagenci%TYPE
                          ,p_cdbccxlt IN craplot.cdbccxlt%TYPE
                          ,p_nrdolote IN craplot.nrdolote%TYPE) IS
      SELECT lot.cdcooper
            ,lot.dtmvtolt
            ,lot.cdagenci
            ,lot.cdbccxlt
            ,lot.nrdolote
            ,lot.vlcompdb
            ,lot.vlinfodb
            ,lot.vlcompcr
            ,lot.vlinfocr
        FROM craplot lot
       WHERE lot.cdcooper = p_cdcooper
         AND lot.dtmvtolt = p_dtmvtolt
         AND lot.cdagenci = p_cdagenci
         AND lot.cdbccxlt = p_cdbccxlt
         AND lot.nrdolote = p_nrdolote;
   rw_consulta_lot cr_consulta_lot%ROWTYPE;

  /* Verifica se existe LCM */
  CURSOR cr_existe_lcm1(p_cdcooper INTEGER
                       ,p_dtmvtolt DATE
                       ,p_cdagenci INTEGER
                       ,p_cdbccxlt INTEGER
                       ,p_nrdolote INTEGER
                       ,p_nrdctabb INTEGER
                       ,p_nrdocmto INTEGER) IS
     SELECT lcm.cdcooper
           ,lcm.dtmvtolt
           ,lcm.cdagenci
           ,lcm.cdbccxlt
           ,lcm.nrdolote
           ,lcm.nrdctabb
           ,lcm.nrdocmto
           ,lcm.nrseqdig
           ,lcm.cdhistor
           ,lcm.vllanmto
       FROM craplcm lcm
      WHERE lcm.cdcooper = p_cdcooper
        AND lcm.dtmvtolt = p_dtmvtolt
        AND lcm.cdagenci = p_cdagenci
        AND lcm.cdbccxlt = p_cdbccxlt
        AND lcm.nrdolote = p_nrdolote
        AND lcm.nrdctabb = p_nrdctabb
        AND lcm.nrdocmto = p_nrdocmto;
  rw_existe_lcm1 cr_existe_lcm1%ROWTYPE;

  /* Verifica LOG */
  CURSOR cr_verifica_ldt(p_cdcooper IN NUMBER
                        ,p_cdoperad IN VARCHAR2
                        ,p_nrctadst IN NUMBER
                        ,p_dttransa IN DATE
                        ,p_nrdocmto IN NUMBER) IS
     SELECT ldt.flgestor
           ,ldt.cdcooper
           ,ldt.cdoperad
           ,ldt.nrctadst
           ,ldt.dttransa
           ,ldt.nrdocmto
       FROM crapldt ldt
      WHERE ldt.cdcooper = p_cdcooper
        AND ldt.cdoperad = p_cdoperad
        AND ldt.nrctadst = p_nrctadst
        AND ldt.dttransa = p_dttransa
        AND ldt.nrdocmto = p_nrdocmto
        AND ldt.tpoperac = 5;
  rw_verifica_ldt cr_verifica_ldt%ROWTYPE;

   -- Variaveis Erro
   vr_cdcritic crapcri.cdcritic%TYPE;
   vr_dscritic VARCHAR2(4000);
   vr_exc_erro EXCEPTION;

   -- Variaveis
   vr_flg_vhcorte BOOLEAN           := FALSE;
   vr_aux_cdcooper INTEGER          := 0;
   vr_aux_cdagenci INTEGER          := 0;
   vr_aux_cdbccxlt INTEGER          := 0;
   vr_i_nro_lote   INTEGER          := 0;
   vr_aux_lscontas VARCHAR2(200)    := '';
   vr_l_achou BOOLEAN               := FALSE;
   vr_c_docto VARCHAR2(200)         := '';
   vr_aux_cdpesqbb VARCHAR(100)     := 0;
   vr_flg_exetrunc BOOLEAN          := FALSE;
   vr_index        INTEGER          := 0;
   vr_p_literal VARCHAR2(32000)     := '';
   vr_p_ult_sequencia INTEGER       := 0;
   vr_existe_lcm BOOLEAN            := FALSE;
   vr_dstextab craptab.dstextab%TYPE;   

   BEGIN
      -- Busca Cod. Coop de ORIGEM
      OPEN cr_cod_coop_orig(pr_cooper);
      FETCH cr_cod_coop_orig INTO rw_cod_coop_orig;
      CLOSE cr_cod_coop_orig;

      -- Busca Cod. Coop de DESTINO
      OPEN cr_cod_coop_dest(pr_cooper_dest);
      FETCH cr_cod_coop_dest INTO rw_cod_coop_dest;
      CLOSE cr_cod_coop_dest;

      -- Busca Data do Sistema
      OPEN cr_dat_cop(rw_cod_coop_orig.cdcooper);
      FETCH cr_dat_cop INTO rw_dat_cop;
      CLOSE cr_dat_cop;

      -- Inicializa Variaveis
      vr_flg_vhcorte := FALSE;
      vr_existe_lcm  := FALSE;

      -- Dados de Destino
      vr_aux_cdcooper := rw_cod_coop_dest.cdcooper;
      vr_aux_cdagenci := 1;
      vr_aux_cdbccxlt := 100;
      vr_i_nro_lote   := 10118;
      vr_c_docto  := TO_CHAR(pr_nro_docmto);

      /* Verifica se ha lancamento de cheques fora coop [CREDITO]
      se sim faz a validacao do horario de corte */
      FOR rw_verifica_lcm IN cr_verifica_lcm(vr_aux_cdcooper
                                            ,rw_dat_cop.dtmvtolt
                                            ,vr_aux_cdagenci
                                            ,vr_aux_cdbccxlt
                                            ,vr_i_nro_lote
                                            ,pr_nro_conta) LOOP

         /* Garantir que somente serao pegos os lancamentos corretos */
         vr_aux_cdpesqbb := TO_CHAR(gene0002.fn_busca_entrada(1,rw_verifica_lcm.cdpesqbb,','));
         IF TO_CHAR(rw_verifica_lcm.nrdocmto) LIKE TO_CHAR(vr_c_docto||'%') AND
            (gene0002.fn_existe_valor(pr_base     => '2,3,4,5,6'
                                     ,pr_busca    => SUBSTR(TO_CHAR(rw_verifica_lcm.nrdocmto),LENGTH(rw_verifica_lcm.nrdocmto),1)
                                     ,pr_delimite => ',')='S') AND vr_aux_cdpesqbb = 'CRAP22' THEN

            -- Se existir os lancamentos com o documento informado
            vr_existe_lcm := TRUE;

            /* Chq prc. chq maior prc, chq fora prc, chq maior fora prc */
            IF (gene0002.fn_existe_valor(pr_base     => '3,4,5,6'
                                        ,pr_busca    => SUBSTR(TO_CHAR(rw_verifica_lcm.nrdocmto),LENGTH(rw_verifica_lcm.nrdocmto),1)
                                        ,pr_delimite => ',')='S') THEN
                vr_flg_vhcorte := TRUE; -- Horario de Corte
            END IF;

            /*** Verifica se PA faz previa dos cheques ***/
            vr_flg_exetrunc := FALSE;

            -- Buscar configuração na tabela
            vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                                     ,pr_nmsistem => 'CRED'
                                                     ,pr_tptabela => 'GENERI'
                                                     ,pr_cdempres => 0
                                                     ,pr_cdacesso => 'EXETRUNCAGEM'
                                                     ,pr_tpregist => pr_cod_agencia);            

            IF vr_dstextab = 'SIM' THEN

              vr_cdcritic     := 0;
              vr_flg_exetrunc := TRUE;

              /** Dados ORIGEM/DEBITO **/
              vr_aux_cdagenci := pr_cod_agencia;
              vr_aux_cdbccxlt := 11;
              vr_i_nro_lote   := 11000 + pr_nro_caixa;

              FOR rw_verifica_chd IN cr_verifica_chd(rw_cod_coop_orig.cdcooper
                                                    ,rw_verifica_lcm.dtmvtolt
                                                    ,vr_aux_cdagenci
                                                    ,vr_aux_cdbccxlt
                                                    ,vr_i_nro_lote
                                                    ,pr_nro_docmto
                                                    ,rw_verifica_lcm.nrseqdig) LOOP

                 IF rw_verifica_chd.insitprv > 0 THEN
                    vr_cdcritic := 9999;
                 END IF;
              END LOOP;
            END IF;

            -- Se houve corte
            IF vr_cdcritic > 0 THEN
               pr_cdcritic := 0;
               pr_dscritic := 'Estorno nao pode ser efetuado. '||
                              'Cheque ja enviado para previa.';
               cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                    ,pr_cdagenci => pr_cod_agencia
                                    ,pr_nrdcaixa => pr_nro_caixa
                                    ,pr_cod_erro => pr_cdcritic
                                    ,pr_dsc_erro => pr_dscritic
                                    ,pr_flg_erro => TRUE
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic);

               IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                  pr_cdcritic := vr_cdcritic;
                  pr_dscritic := vr_dscritic;
                  RAISE vr_exc_erro;
               END IF;

               RAISE vr_exc_erro;
            END IF;
         END IF;

      END LOOP; /* Fim do LCM de CREDITO */

      IF NOT vr_existe_lcm THEN
         pr_cdcritic := 90;
         pr_dscritic := '';

         cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                              ,pr_cdagenci => pr_cod_agencia
                              ,pr_nrdcaixa => pr_nro_caixa
                              ,pr_cod_erro => pr_cdcritic
                              ,pr_dsc_erro => pr_dscritic
                              ,pr_flg_erro => TRUE
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic);

         IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := vr_dscritic;
            RAISE vr_exc_erro;
         END IF;

         RAISE vr_exc_erro;
      END IF;

      IF vr_flg_vhcorte THEN
              
        -- Buscar configuração na tabela
        vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                                 ,pr_nmsistem => 'CRED'
                                                 ,pr_tptabela => 'GENERI'
                                                 ,pr_cdempres => 0
                                                 ,pr_cdacesso => 'HRTRCOMPEL'
                                                 ,pr_tpregist => pr_cod_agencia);            
         
        IF TRIM(vr_dstextab) IS NULL THEN 
           pr_cdcritic := 676;
           pr_dscritic := '';
           cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                ,pr_cdagenci => pr_cod_agencia
                                ,pr_nrdcaixa => pr_nro_caixa
                                ,pr_cod_erro => pr_cdcritic
                                ,pr_dsc_erro => pr_dscritic
                                ,pr_flg_erro => TRUE
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic);
           IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
              pr_cdcritic := vr_cdcritic;
              pr_dscritic := vr_dscritic;
              RAISE vr_exc_erro;
           END IF;

           RAISE vr_exc_erro;
        END IF;

        IF TO_NUMBER(SUBSTR(vr_dstextab,1,1)) <> 0 THEN
           pr_cdcritic := 677;
           pr_dscritic := '';
           cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                ,pr_cdagenci => pr_cod_agencia
                                ,pr_nrdcaixa => pr_nro_caixa
                                ,pr_cod_erro => pr_cdcritic
                                ,pr_dsc_erro => pr_dscritic
                                ,pr_flg_erro => TRUE
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic);
           IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
              pr_cdcritic := vr_cdcritic;
              pr_dscritic := vr_dscritic;
              RAISE vr_exc_erro;
           END IF;

           RAISE vr_exc_erro;
        END IF;

        IF TO_NUMBER(SUBSTR(vr_dstextab,3,5)) <= TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS')) THEN
           pr_cdcritic := 676;
           pr_dscritic := '';
           cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                ,pr_cdagenci => pr_cod_agencia
                                ,pr_nrdcaixa => pr_nro_caixa
                                ,pr_cod_erro => pr_cdcritic
                                ,pr_dsc_erro => pr_dscritic
                                ,pr_flg_erro => TRUE
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic);
           IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
              pr_cdcritic := vr_cdcritic;
              pr_dscritic := vr_dscritic;
              RAISE vr_exc_erro;
           END IF;

           RAISE vr_exc_erro;
        END IF;

      END IF; /* FIM Verifica Horario de Corte */

      /** CREDITO - CHEQUE COOP **/
      IF pr_valor_coop > 0 THEN

         -- Inicializa variaveis
         vr_cdcritic := 0;
         /** Dados DESTINO/CREDITO **/
         vr_aux_cdagenci := 1;--pr_cod_agencia;
         vr_aux_cdbccxlt := 100;
         vr_i_nro_lote   := 10118;
         vr_c_docto  := TO_CHAR(pr_nro_docmto)||'012';

         -- Verifica LCM de CREDITO
         OPEN cr_existe_lcm1(rw_cod_coop_dest.cdcooper
                            ,rw_dat_cop.dtmvtolt
                            ,vr_aux_cdagenci
                            ,vr_aux_cdbccxlt
                            ,vr_i_nro_lote
                            ,pr_nro_conta
                            ,TO_NUMBER(vr_c_docto));
         FETCH cr_existe_lcm1 INTO rw_existe_lcm1;
            IF cr_existe_lcm1%FOUND THEN

               CXON0051.pc_autentica_cheque(pr_cooper          => pr_cooper
                                           ,pr_cod_agencia     => pr_cod_agencia
                                           ,pr_nro_conta       => pr_nro_conta
                                           ,pr_vestorno        => pr_vestorno
                                           ,pr_nro_caixa       => pr_nro_caixa
                                           ,pr_cod_operador    => pr_cod_operador
                                           ,pr_dtmvtolt        => rw_dat_cop.dtmvtolt
                                           ,pr_nro_docmto      => pr_nro_docmto
                                           ,pr_rowid           => NULL
                                           ,pr_p_literal       => vr_p_literal
                                           ,pr_p_ult_sequencia => vr_p_ult_sequencia
                                           ,pr_retorno         => pr_retorno
                                           ,pr_cdcritic        => vr_cdcritic
                                           ,pr_dscritic        => vr_dscritic);

               IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                  pr_cdcritic := vr_cdcritic;
                  pr_dscritic := vr_dscritic;
                  RAISE vr_exc_erro;
               END IF;

               -- LOTE de DEBITO
               vr_i_nro_lote   := 11000 + pr_nro_caixa;
               vr_aux_cdbccxlt := 11;

               /* Nesta procedure está o tratamento
               de contas migradas e LCM de DEBITO */
               pc_verifica_crapchd_coop(pr_cdcooper     => rw_cod_coop_orig.cdcooper
                                       ,pr_cod_agencia  => pr_cod_agencia
                                       ,pr_nro_caixa    => pr_nro_caixa
                                       ,pr_cod_operador => pr_cod_operador
                                       ,pr_nro_conta    => pr_nro_conta
                                       ,pr_nro_lote     => vr_i_nro_lote
                                       ,pr_nro_docmto   => pr_nro_docmto
                                       ,pr_dtmvtolt     => rw_dat_cop.dtmvtolt
                                       ,pr_nrseqdig     => rw_existe_lcm1.nrseqdig
                                       ,pr_cdhistor     => rw_existe_lcm1.cdhistor
                                       ,pr_cdbcoctl     => rw_cod_coop_orig.cdbcoctl
                                       ,pr_lsconta1     => ''
                                       ,pr_lsconta3     => ''
                                       ,pr_retorno      => pr_retorno
                                       ,pr_cdcritic     => vr_cdcritic
                                       ,pr_dscritic     => vr_dscritic);

               -- Tratamento do retornou de erro
               IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                  pr_cdcritic := vr_cdcritic;
                  pr_dscritic := vr_dscritic;

                  cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                       ,pr_cdagenci => pr_cod_agencia
                                       ,pr_nrdcaixa => pr_nro_caixa
                                       ,pr_cod_erro => pr_cdcritic
                                       ,pr_dsc_erro => pr_dscritic
                                       ,pr_flg_erro => TRUE
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic);

                  IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                     pr_cdcritic := vr_cdcritic;
                     pr_dscritic := vr_dscritic;
                     RAISE vr_exc_erro;
                  END IF;

                  RAISE vr_exc_erro;
               END IF;

               -- Consultando LOTE
               OPEN cr_consulta_lot(rw_cod_coop_dest.cdcooper
                                   ,rw_dat_cop.dtmvtolt
                                   ,1
                                   ,100
                                   ,10118);
               FETCH cr_consulta_lot INTO rw_consulta_lot;
                  -- Nao encontrou o lote
                  IF cr_consulta_lot%NOTFOUND THEN
                     pr_cdcritic := 60;
                     pr_dscritic := '';

                     cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                          ,pr_cdagenci => pr_cod_agencia
                                          ,pr_nrdcaixa => pr_nro_caixa
                                          ,pr_cod_erro => pr_cdcritic
                                          ,pr_dsc_erro => pr_dscritic
                                          ,pr_flg_erro => TRUE
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic);

                     IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                        pr_cdcritic := vr_cdcritic;
                        pr_dscritic := vr_dscritic;
                        RAISE vr_exc_erro;
                     END IF;

                     RAISE vr_exc_erro;

                  ELSE -- Encontrou o Lote

                     BEGIN -- Decrementando o Lote
                        UPDATE craplot lot
                           SET lot.qtcompln = lot.qtcompln - 1
                              ,lot.qtinfoln = lot.qtinfoln - 1
                              ,lot.vlcompcr = lot.vlcompcr - rw_existe_lcm1.vllanmto
                              ,lot.vlinfocr = lot.vlinfocr - rw_existe_lcm1.vllanmto
                         WHERE lot.cdcooper = rw_cod_coop_dest.cdcooper
                           AND lot.dtmvtolt = rw_dat_cop.dtmvtolt
                           AND lot.cdagenci = 1
                           AND lot.cdbccxlt = 100
                           AND lot.nrdolote = 10118;
                     EXCEPTION
                        WHEN OTHERS THEN
                           pr_cdcritic := 0;
                           pr_dscritic := 'Erro ao atualizar CRAPLOT : '||sqlerrm;

                           cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                                ,pr_cdagenci => pr_cod_agencia
                                                ,pr_nrdcaixa => pr_nro_caixa
                                                ,pr_cod_erro => pr_cdcritic
                                                ,pr_dsc_erro => pr_dscritic
                                                ,pr_flg_erro => TRUE
                                                ,pr_cdcritic => vr_cdcritic
                                                ,pr_dscritic => vr_dscritic);

                           IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                              pr_cdcritic := vr_cdcritic;
                              pr_dscritic := vr_dscritic;
                              RAISE vr_exc_erro;
                           END IF;

                           RAISE vr_exc_erro;
                     END;
                  END IF;
               CLOSE cr_consulta_lot;

               BEGIN -- Deletando LCM
                  DELETE craplcm lcm
                   WHERE lcm.cdcooper = rw_cod_coop_dest.cdcooper
                     AND lcm.dtmvtolt = rw_existe_lcm1.dtmvtolt
                     AND lcm.cdagenci = rw_existe_lcm1.cdagenci
                     AND lcm.cdbccxlt = rw_existe_lcm1.cdbccxlt
                     AND lcm.nrdolote = rw_existe_lcm1.nrdolote
                     AND lcm.nrdctabb = rw_existe_lcm1.nrdctabb
                     AND lcm.nrdocmto = TO_NUMBER(vr_c_docto);
               EXCEPTION
                  WHEN OTHERS THEN
                     pr_cdcritic := 0;
                     pr_dscritic := 'Erro ao excluir registro da CRAPLCM : '||sqlerrm;

                     cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                          ,pr_cdagenci => pr_cod_agencia
                                          ,pr_nrdcaixa => pr_nro_caixa
                                          ,pr_cod_erro => pr_cdcritic
                                          ,pr_dsc_erro => pr_dscritic
                                          ,pr_flg_erro => TRUE
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic);

                     IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                        pr_cdcritic := vr_cdcritic;
                        pr_dscritic := vr_dscritic;
                        RAISE vr_exc_erro;
                     END IF;

                     RAISE vr_exc_erro;
               END;

            ELSE -- Nao encontrou Registro de LCM

                pr_cdcritic := 90;
                pr_dscritic := '';

                cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                     ,pr_cdagenci => pr_cod_agencia
                                     ,pr_nrdcaixa => pr_nro_caixa
                                     ,pr_cod_erro => pr_cdcritic
                                     ,pr_dsc_erro => pr_dscritic
                                     ,pr_flg_erro => TRUE
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);

                IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                   pr_cdcritic := vr_cdcritic;
                   pr_dscritic := vr_dscritic;
                   RAISE vr_exc_erro;
                END IF;

                RAISE vr_exc_erro;

            END IF; -- Fim da verificacao do LCM

         CLOSE cr_existe_lcm1;
      END IF; -- Fim do LCM de DESTINO

      pr_valor := pr_valor_coop;

      /** Tratamento Cheques Praca e Fora Praca */
      vr_c_docto := TO_CHAR(pr_nro_docmto);

      -- Dados de Destino
      vr_aux_cdcooper := rw_cod_coop_dest.cdcooper;
      vr_aux_cdagenci := 1;
      vr_aux_cdbccxlt := 100;
      vr_i_nro_lote   := 10118;

      FOR rw_verifica_lcm IN cr_verifica_lcm(vr_aux_cdcooper
                                            ,rw_dat_cop.dtmvtolt
                                            ,vr_aux_cdagenci
                                            ,vr_aux_cdbccxlt
                                            ,vr_i_nro_lote
                                            ,pr_nro_conta) LOOP

         /* Garantir que somente serao pegos os lancamentos corretos */
         vr_aux_cdpesqbb := TO_CHAR(gene0002.fn_busca_entrada(1,rw_verifica_lcm.cdpesqbb,','));
         IF TO_CHAR(rw_verifica_lcm.nrdocmto) LIKE TO_CHAR(vr_c_docto||'%')
         AND /* Chq prc. chq maior prc, chq fora prc, chq maior fora prc */
            (gene0002.fn_existe_valor(pr_base => '3,4,5,6'
                              ,pr_busca       => SUBSTR(TO_CHAR(rw_verifica_lcm.nrdocmto),LENGTH(rw_verifica_lcm.nrdocmto),1)
                              ,pr_delimite    => ',')='S') AND vr_aux_cdpesqbb = 'CRAP22' THEN

             vr_cdcritic := 0;

             CXON0088.pc_verifica_crapchd(pr_cdcooper     => rw_cod_coop_orig.cdcooper
                                         ,pr_cod_agencia  => pr_cod_agencia
                                         ,pr_nro_caixa    => pr_nro_caixa
                                         ,pr_cod_operador => pr_cod_operador
                                         ,pr_nro_conta    => pr_nro_conta
                                         ,pr_nro_lote     => vr_i_nro_lote
                                         ,pr_nro_docmto   => pr_nro_docmto
                                         ,pr_dtmvtolt     => rw_dat_cop.dtmvtolt
                                         ,pr_nrseqdig     => rw_verifica_lcm.nrseqdig
                                         ,pr_cdhistor     => rw_verifica_lcm.cdhistor
                                         ,pr_cdbcoctl     => rw_cod_coop_orig.cdbcoctl
                                         ,pr_cdagectl     => rw_cod_coop_orig.cdagectl
                                         ,pr_lsconta1     => ''
                                         ,pr_lsconta3     => ''
                                         ,pr_retorno      => pr_retorno
                                         ,pr_cdcritic     => vr_cdcritic
                                         ,pr_dscritic     => vr_dscritic);

             IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := vr_dscritic;
                RAISE vr_exc_erro;
             END IF;

             /* Eliminar registro deposito bloqueado - CRAPDPB */
             OPEN cr_verifica_dpb(rw_verifica_lcm.cdcooper
                                 ,rw_verifica_lcm.dtmvtolt
                                 ,rw_verifica_lcm.cdagenci
                                 ,rw_verifica_lcm.cdbccxlt
                                 ,rw_verifica_lcm.nrdolote
                                 ,rw_verifica_lcm.nrdctabb
                                 ,rw_verifica_lcm.nrdocmto);
             FETCH cr_verifica_dpb INTO rw_verifica_dpb;
                IF cr_verifica_dpb%FOUND THEN
                   BEGIN -- Deletando DPB
                      DELETE crapdpb dpb
                       WHERE dpb.cdcooper = rw_verifica_lcm.cdcooper
                         AND dpb.dtmvtolt = rw_verifica_lcm.dtmvtolt
                         AND dpb.cdagenci = rw_verifica_lcm.cdagenci
                         AND dpb.cdbccxlt = rw_verifica_lcm.cdbccxlt
                         AND dpb.nrdolote = rw_verifica_lcm.nrdolote
                         AND dpb.nrdconta = rw_verifica_lcm.nrdctabb
                         AND dpb.nrdocmto = rw_verifica_lcm.nrdocmto;
                   EXCEPTION
                      WHEN OTHERS THEN
                         pr_cdcritic := 0;
                         pr_dscritic := 'Erro ao excluir registro da CRAPLCM : '||sqlerrm;

                         cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                              ,pr_cdagenci => pr_cod_agencia
                                              ,pr_nrdcaixa => pr_nro_caixa
                                              ,pr_cod_erro => pr_cdcritic
                                              ,pr_dsc_erro => pr_dscritic
                                              ,pr_flg_erro => TRUE
                                              ,pr_cdcritic => vr_cdcritic
                                              ,pr_dscritic => vr_dscritic);

                         IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                            pr_cdcritic := vr_cdcritic;
                            pr_dscritic := vr_dscritic;
                            RAISE vr_exc_erro;
                         END IF;

                         RAISE vr_exc_erro;
                   END;
                END IF;
             CLOSE cr_verifica_dpb;

             -- Consultando LOTE
             OPEN cr_consulta_lot(vr_aux_cdcooper
                                 ,rw_dat_cop.dtmvtolt
                                 ,vr_aux_cdagenci
                                 ,vr_aux_cdbccxlt
                                 ,vr_i_nro_lote);
             FETCH cr_consulta_lot INTO rw_consulta_lot;
                -- Nao encontrou o lote
                IF cr_consulta_lot%NOTFOUND THEN
                   pr_cdcritic := 60;
                   pr_dscritic := '';

                   cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                        ,pr_cdagenci => pr_cod_agencia
                                        ,pr_nrdcaixa => pr_nro_caixa
                                        ,pr_cod_erro => pr_cdcritic
                                        ,pr_dsc_erro => pr_dscritic
                                        ,pr_flg_erro => TRUE
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic);

                   IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                      pr_cdcritic := vr_cdcritic;
                      pr_dscritic := vr_dscritic;
                      RAISE vr_exc_erro;
                   END IF;

                   RAISE vr_exc_erro;

                ELSE -- Encontrou o Lote

                   BEGIN -- Decrementando o Lote
                      UPDATE craplot lot
                         SET lot.qtcompln = lot.qtcompln - 1
                            ,lot.qtinfoln = lot.qtinfoln - 1
                            ,lot.vlcompcr = lot.vlcompcr - rw_verifica_lcm.vllanmto
                            ,lot.vlinfocr = lot.vlinfocr - rw_verifica_lcm.vllanmto
                       WHERE lot.cdcooper = vr_aux_cdcooper
                         AND lot.dtmvtolt = rw_dat_cop.dtmvtolt
                         AND lot.cdagenci = vr_aux_cdagenci
                         AND lot.cdbccxlt = vr_aux_cdbccxlt
                         AND lot.nrdolote = vr_i_nro_lote;
                   EXCEPTION
                      WHEN OTHERS THEN
                         pr_cdcritic := 0;
                         pr_dscritic := 'Erro ao atualizar CRAPLOT : '||sqlerrm;

                         cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                              ,pr_cdagenci => pr_cod_agencia
                                              ,pr_nrdcaixa => pr_nro_caixa
                                              ,pr_cod_erro => pr_cdcritic
                                              ,pr_dsc_erro => pr_dscritic
                                              ,pr_flg_erro => TRUE
                                              ,pr_cdcritic => vr_cdcritic
                                              ,pr_dscritic => vr_dscritic);

                         IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                            pr_cdcritic := vr_cdcritic;
                            pr_dscritic := vr_dscritic;
                            RAISE vr_exc_erro;
                         END IF;

                         RAISE vr_exc_erro;
                   END;
                END IF;
             CLOSE cr_consulta_lot;

             pr_valor := pr_valor + rw_verifica_lcm.vllanmto;

             BEGIN -- Deletando LCM
                DELETE craplcm lcm
                 WHERE lcm.cdcooper = rw_cod_coop_dest.cdcooper
                   AND lcm.dtmvtolt = rw_verifica_lcm.dtmvtolt
                   AND lcm.cdagenci = rw_verifica_lcm.cdagenci
                   AND lcm.cdbccxlt = rw_verifica_lcm.cdbccxlt
                   AND lcm.nrdolote = rw_verifica_lcm.nrdolote
                   AND lcm.nrdctabb = rw_verifica_lcm.nrdctabb
                   AND lcm.nrdocmto = rw_verifica_lcm.nrdocmto;
             EXCEPTION
                WHEN OTHERS THEN
                   pr_cdcritic := 0;
                   pr_dscritic := 'Erro ao excluir registro da CRAPLCM : '||sqlerrm;

                   cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                        ,pr_cdagenci => pr_cod_agencia
                                        ,pr_nrdcaixa => pr_nro_caixa
                                        ,pr_cod_erro => pr_cdcritic
                                        ,pr_dsc_erro => pr_dscritic
                                        ,pr_flg_erro => TRUE
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic);

                   IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                      pr_cdcritic := vr_cdcritic;
                      pr_dscritic := vr_dscritic;
                      RAISE vr_exc_erro;
                   END IF;

                   RAISE vr_exc_erro;
             END;
         END IF;
      END LOOP; -- Fim do Processo de LCM de DESTINO

      -- Consultando LOTE
      OPEN cr_consulta_lot(vr_aux_cdcooper
                          ,rw_dat_cop.dtmvtolt
                          ,vr_aux_cdagenci
                          ,vr_aux_cdbccxlt
                          ,vr_i_nro_lote);
      FETCH cr_consulta_lot INTO rw_consulta_lot;
         -- Nao encontrou o lote
         IF cr_consulta_lot%FOUND THEN

            -- Se o lote estiver zerado, deleta o lote
            IF rw_consulta_lot.vlcompdb = 0 AND
               rw_consulta_lot.vlinfodb = 0 AND
               rw_consulta_lot.vlcompcr = 0 AND
               rw_consulta_lot.vlinfocr = 0 THEN

               BEGIN
                  DELETE craplot lot
                   WHERE lot.cdcooper = vr_aux_cdcooper
                     AND lot.dtmvtolt = rw_dat_cop.dtmvtolt
                     AND lot.cdagenci = vr_aux_cdagenci
                     AND lot.cdbccxlt = vr_aux_cdbccxlt
                     AND lot.nrdolote = vr_i_nro_lote;
               EXCEPTION
                  WHEN OTHERS THEN
                     pr_cdcritic := 0;
                     pr_dscritic := 'Erro ao atualizar CRAPLOT : '||sqlerrm;

                     cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                          ,pr_cdagenci => pr_cod_agencia
                                          ,pr_nrdcaixa => pr_nro_caixa
                                          ,pr_cod_erro => pr_cdcritic
                                          ,pr_dsc_erro => pr_dscritic
                                          ,pr_flg_erro => TRUE
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic);

                     IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                        pr_cdcritic := vr_cdcritic;
                        pr_dscritic := vr_dscritic;
                        RAISE vr_exc_erro;
                     END IF;

                     RAISE vr_exc_erro;
               END;
            END IF;
         END IF;
      CLOSE cr_consulta_lot;

      BEGIN -- Deletando LCX
         DELETE craplcx lcx
          WHERE lcx.cdcooper = rw_cod_coop_orig.cdcooper
            AND lcx.dtmvtolt = rw_dat_cop.dtmvtolt
            AND lcx.cdagenci = pr_cod_agencia
            AND lcx.nrdcaixa = pr_nro_caixa
            AND UPPER(lcx.cdopecxa) = UPPER(pr_cod_operador)
            AND lcx.nrdocmto = TO_NUMBER(pr_nro_docmto);
      EXCEPTION
         WHEN OTHERS THEN
            pr_cdcritic := 0;
            pr_dscritic := 'Erro ao excluir registro da CRAPLCX : '||sqlerrm;
            RAISE vr_exc_erro;
      END;

      /** Deleta CRAPLDT - Estorno = TRUE **/
      OPEN cr_verifica_ldt(rw_cod_coop_orig.cdcooper
                          ,pr_cod_operador
                          ,pr_nro_conta
                          ,rw_dat_cop.dtmvtolt
                          ,TO_NUMBER(pr_nro_docmto));
      FETCH cr_verifica_ldt INTO rw_verifica_ldt;
         IF cr_verifica_ldt%NOTFOUND THEN
            pr_cdcritic := 0;
            pr_dscritic := 'Registro log de transferencia nao encontrado.';
            cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                 ,pr_cdagenci => pr_cod_agencia
                                 ,pr_nrdcaixa => pr_nro_caixa
                                 ,pr_cod_erro => vr_cdcritic
                                 ,pr_dsc_erro => vr_dscritic
                                 ,pr_flg_erro => TRUE
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);

            IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
               pr_cdcritic := vr_cdcritic;
               pr_dscritic := vr_dscritic;
               RAISE vr_exc_erro;
            END IF;

            RAISE vr_exc_erro;

         ELSE -- Encontrou registro de LOG

            BEGIN -- Deletando LDT
              DELETE crapldt ldt
               WHERE ldt.cdcooper = rw_verifica_ldt.cdcooper
                 AND ldt.cdoperad = rw_verifica_ldt.cdoperad
                 AND ldt.nrctadst = rw_verifica_ldt.nrctadst
                 AND ldt.dttransa = rw_verifica_ldt.dttransa
                 AND ldt.nrdocmto = rw_verifica_ldt.nrdocmto
                 AND ldt.tpoperac = 5;
            EXCEPTION
                WHEN OTHERS THEN
                   pr_cdcritic := 0;
                   pr_dscritic := 'Erro ao excluir registro da CRAPLDT : '||sqlerrm;

                   cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                        ,pr_cdagenci => pr_cod_agencia
                                        ,pr_nrdcaixa => pr_nro_caixa
                                        ,pr_cod_erro => pr_cdcritic
                                        ,pr_dsc_erro => pr_dscritic
                                        ,pr_flg_erro => TRUE
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic);

                   IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                      pr_cdcritic := vr_cdcritic;
                      pr_dscritic := vr_dscritic;
                      RAISE vr_exc_erro;
                   END IF;

                   RAISE vr_exc_erro;
            END;
         END IF;
      CLOSE cr_verifica_ldt;

      pr_retorno  := 'OK';
      COMMIT;

   EXCEPTION
     WHEN vr_exc_erro THEN
          ROLLBACK; -- Desfaz as alterações
          pr_retorno  := 'NOK';
          pr_valor    := 0;

     WHEN OTHERS THEN
         ROLLBACK; -- Desfaz as alterações
         pr_retorno  := 'NOK';
         pr_cdcritic := 0;
         pr_valor    := 0;
         pr_dscritic := 'Erro na rotina CXON0088.pc_estorna_dep_chq_captura. '||SQLERRM;

         cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                              ,pr_cdagenci => pr_cod_agencia
                              ,pr_nrdcaixa => pr_nro_caixa
                              ,pr_cod_erro => vr_cdcritic
                              ,pr_dsc_erro => vr_dscritic
                              ,pr_flg_erro => TRUE
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic);


   END pc_estorna_dep_chq_captura;

END CXON0088;
/
