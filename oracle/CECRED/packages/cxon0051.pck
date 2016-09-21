create or replace package cecred.CXON0051 is

/* .............................................................................

   Programa: siscaixa/web/b1crap51.p
   Sistema : Caixa On-line
   Sigla   : CRED
   Autor   : Mirtes.
   Data    : Marco/2001                      Ultima atualizacao: 20/06/2014

   Dados referentes ao programa:

   Frequencia: Diario (Caixa Online).
   Objetivo  : Depositos com Captura

   Alteracoes: 11/08/2005 - Tratamentos para unificacao dos bancos, passar
                            codigo da cooperativa como parametro para as
                            procedure (Julio)

               08/11/2005 - Alteracao de crapchq e crapchs p/ crapfdc(SQLWorks)

               17/11/2005 - Adequacao ao padrao, analise de performance e dos
                            itens convertidos (SQLWorks - Andre)

               23/02/2006 - Unificacao dos bancos - SQLWorks - Eder

               23/02/2007 - Alteracao dos FINDs da crapfdc e crapcor;
                          - Alimentacao dos campos "crapfdc.cdbandep",
                            "crapfdc.cdagedep" e "crapfdc.nrctadep" (Evandro).

               10/09/2007 - Conversao de rotina ver_capital para BO
                            (Sidnei/Precise)

               29/01/2008 - Incluido o PAC do cooperado na autenticacao
                            (Elton).

               23/12/2008 - Incluido campo "capital" na temp-table tt-conta
                            (Elton).

               10/03/2009 - Ajuste para unificacao dos bancos de dados
                            (Evandro).

               25/05/2009 - Alteracao CDOPERAD (Kbase).

               14/08/2009 - Alterado para pedir senha quando a soma dos cheques
                            depositados de uma mesma conta excederem o seu
                            saldo disponivel (Elton).

               07/10/2009 - Adaptacoes projeto IF CECRED
                            Adaptacoes para o CAF (Guilherme).

               24/02/2010 - Ajuste para criacao da crapchd (Guilherme/Evandro).

               29/10/2010 - Chama rotina atualiza-previa-caixa (Elton).

               28/12/2010 - Tratamento para cheques de contas migradas
                            (Guilherme).
                          - Chama rotina atualiza-previa-caixa somente para
                            cheques de fora (Elton).

               14/02/2011 - Quando o cheque for de uma cooperativa migrada
                            e o cheque estiver sendo pago na "nova" cooperativa
                            efetuar o lancamento de pagamento com historico 21
                            (Guilherme).

               15/02/2011 - Alimentar ":" ao fim do CMC7 somente se ele possuir
                            LENGTH 34 (Guilherme).

               09/12/2011 - Sustação provisória (André R./Supero).

               27/03/2012 - Controle de LOCK no craplot (Guilherme).

               02/05/2012 - Inclusão da procedure autentica_cheques.
                            (David Kruger).

               31/05/2012 - Corrigido procedure acima para, no estorno, apenas
                            autenticar cheques da cooperativa  (Guilherme).

               18/06/2012 - Alteracao na leitura da craptco (David Kruger).

               20/06/2012 - substituição do FIND craptab para os registros
                            CONTACONVE pela chamada do fontes ver_ctace.p
                            (Lucas R.).

               23/08/2012 - Procedures critica-contra-ordem e
                            critica-contra-ordem-migradotratamento cheques
                            custodia - Projeto Tic (Richard/Supero).

               26/10/2012 - Retirado PAUSE 20 indevido. (Diego)
                          - Alteracao da logica para migracao de PAC
                            devido a migracao da AltoVale (Guilherme).

               04/01/2013 - Acerto migracao Alto Vale (Elton).

               08/01/2013 - Acerto migracao Alto Vale na procedure
                            atualiza-deposito-com-captura-migrado-host (Elton).

               10/01/2013 - Critica para nao permitir que se pague cheques de
                            contas migradas, com cheques de contas nao migradas
                            ou de outros bancos ao mesmo tempo (Elton).

               14/01/2013 - Permite pagar cheques de contas migradas para Alto
                            Vale no caixa da Viacredi solicitando a senha do
                            coordenador (Elton).

               16/01/2013 - Ajuste migracao Alto Vale (Elton).

               21/06/2013 - Ajustado processo para chamar tela liberacao supervisor
                            na rotina 61 (Jean Michel).

               25/10/2013 - Tratamento para migracao dos PA's da Acredi para
                            Viacredi (Elton).

               16/12/2013 - Adicionado validate para as tabelas crapdpb,
                            craplcm, crapchd, cra2lcm, craplcx, cra2fdc,
                            cra2lot, crapmrw (Tiago).

               19/02/2014 - Ajuste leitura craptco (Daniel).

               11/06/2014 - Somente emitir a crítica 950 apenas se a
                            crapfdc.dtlibtic >= data do movimento
                            (SD. 163588 - Lunelli)

               20/06/2014 - Deposito Intercooperativas
                            - Novo parametro "Coop Destino"
                              -- valida-deposito-com-captura
                              -- valida-deposito-com-captura-migrado
                              -- valida-deposito-com-captura-migrado-host
                            Corrigida procedure autentica_cheques pois estava
                            posicionando na tabela crapmdw sendo que esta
                            utilizando a buffer (erro progress 91)
                            (Guilherme/SUPERO)

               16/07/2014 - Conversao de procedure autentica_cheque do fonte b1crap51
                            para pc_autentica_cheque do pacote CXON0051.
                            (Andre Santos - SUPERO)

............................................................................. */

   /* Rotina de processamento automatico das autenticacoes, deposito e estorno   */
   PROCEDURE pc_autentica_cheque(pr_cooper            IN VARCHAR2    --> Nome resumido da Coop
                                ,pr_cod_agencia       IN INTEGER     --> Codigo Agencia
                                ,pr_nro_conta         IN INTEGER     --> Nro da Conta
                                ,pr_vestorno          IN INTEGER     --> Estorno (1-Verdadeiro/0-Falso)
                                ,pr_nro_caixa         IN INTEGER     --> Codigo do Caixa
                                ,pr_cod_operador      IN VARCHAR2    --> Codigo Operador
                                ,pr_dtmvtolt          IN DATE        --> Data
                                ,pr_nro_docmto        IN NUMBER      --> Nro do Documento
                                ,pr_rowid             IN ROWID       --> Rowid da CRAPMDW
                                ,pr_p_literal         OUT VARCHAR2   --> Valor do rolo de impressao
                                ,pr_p_ult_sequencia   OUT INTEGER    --> Ultima seq. autenticacao
                                ,pr_retorno           OUT VARCHAR2   --> Retorna OK/NOK
                                ,pr_cdcritic          OUT INTEGER    --> Codigo da Critica
                                ,pr_dscritic          OUT VARCHAR2); --> Descricao da Critica

end CXON0051;
/

create or replace package body cecred.CXON0051 is
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : CXON0051
  --  Sistema  : Depositos com Captura
  --  Sigla    : CRED
  --  Autor    : Andre Santos - SUPERO
  --  Data     : Julho/2014.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Depositos com Captura

  -- Alteracoes:
  ---------------------------------------------------------------------------------------------------------------

   PROCEDURE pc_autentica_cheque(pr_cooper            IN VARCHAR2      --> Nome resumido da Coop
                                ,pr_cod_agencia       IN INTEGER       --> Codigo Agencia
                                ,pr_nro_conta         IN INTEGER       --> Nro da Conta
                                ,pr_vestorno          IN INTEGER       --> Estorno (1-Verdadeiro/0-Falso)
                                ,pr_nro_caixa         IN INTEGER       --> Codigo do Caixa
                                ,pr_cod_operador      IN VARCHAR2      --> Codigo Operador
                                ,pr_dtmvtolt          IN DATE          --> Data
                                ,pr_nro_docmto        IN NUMBER        --> Nro do Documento
                                ,pr_rowid             IN ROWID       --> Rowid da CRAPMDW
                                ,pr_p_literal         OUT VARCHAR2     --> Valor do rolo de impressao
                                ,pr_p_ult_sequencia   OUT INTEGER      --> Ultima seq. autenticacao
                                ,pr_retorno           OUT VARCHAR2     --> Retorna OK/NOK
                                ,pr_cdcritic          OUT INTEGER      --> Codigo da Critica
                                ,pr_dscritic          OUT VARCHAR2) IS --> Descricao da Critica
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_autentica_cheque Fonte: dbo/b1crap51.p/autentica_cheques
  --  Sistema  : Procedure de processamento automatico das autenticacoes, deposito e estorno
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
      FROM crapcop cop
     WHERE UPPER(cop.nmrescop) = UPPER(p_nmrescop);
  rw_cod_coop_orig cr_cod_coop_orig%ROWTYPE;

  /* Busca a Data Conforme o Código da Cooperativa */
  CURSOR cr_dat_cop(p_coop IN INTEGER)IS
     SELECT dat.dtmvtolt
           ,dat.dtmvtocd
       FROM crapdat dat
      WHERE dat.cdcooper = p_coop;
  rw_dat_cop cr_dat_cop%ROWTYPE;

  CURSOR cr_consulta_chd (p_cdcooper IN crapchd.cdcooper%TYPE
                         ,p_dtmvtolt IN crapchd.dtmvtolt%TYPE
                         ,p_cdagenci IN crapchd.cdagenci%TYPE
                         ,p_nrdolote IN crapchd.nrdolote%TYPE
                         ,p_nrdconta IN crapchd.nrdconta%TYPE) IS
    SELECT chd.nrdocmto
          ,chd.nrcheque
          ,chd.nrddigc3
          ,chd.vlcheque
      FROM crapchd chd
     WHERE chd.cdcooper = p_cdcooper
       AND chd.dtmvtolt = p_dtmvtolt
       AND chd.cdagenci = p_cdagenci
       AND chd.cdbccxlt = 11
       AND chd.nrdolote = p_nrdolote
       AND chd.nrdconta = p_nrdconta
       AND chd.inchqcop = 1;
  rw_consulta_chd cr_consulta_chd%ROWTYPE;

  /* Verifica tabela de Lancamentos Depositos */
  CURSOR cr_verifica_mdw(p_coop IN INTEGER
                        ,p_cdagenci IN INTEGER
                        ,p_nrocaixa IN INTEGER
                        ,p_rowid IN ROWID)IS
      SELECT mdw.vlcompel
            ,mdw.nrcheque
            ,mdw.nrddigc3
            ,mdw.rowid
        FROM crapmdw mdw
       WHERE mdw.cdcooper = p_coop
         AND mdw.cdagenci = p_cdagenci
         AND mdw.nrdcaixa = p_nrocaixa
         AND rowid = DECODE(p_rowid,null,rowid,p_rowid);
  rw_verifica_mdw cr_verifica_mdw%ROWTYPE;

  -- Variaveis Erro
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(4000);
  vr_exc_erro EXCEPTION;

  -- Variavel
  vr_retorno  VARCHAR2(10);
  vr_nrcheque NUMBER;
  vr_p_registro ROWID;

  BEGIN

     -- Busca Cod. Coop de ORIGEM
     OPEN cr_cod_coop_orig(pr_cooper);
     FETCH cr_cod_coop_orig INTO rw_cod_coop_orig;
        IF cr_cod_coop_orig%NOTFOUND THEN
           pr_cdcritic := 794;
           pr_dscritic := '';

           cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                ,pr_cdagenci => pr_cod_agencia
                                ,pr_nrdcaixa => pr_nro_caixa
                                ,pr_cod_erro => pr_cdcritic
                                ,pr_dsc_erro => pr_dscritic
                                ,pr_flg_erro => TRUE
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic);

           -- Se ocorreu algum erro interno
           IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
              pr_cdcritic := vr_cdcritic;
              pr_dscritic := vr_dscritic;
              RAISE vr_exc_erro;
           END IF;

           RAISE vr_exc_erro;
        END IF;
     CLOSE cr_cod_coop_orig;

     OPEN cr_dat_cop(rw_cod_coop_orig.cdcooper);
     FETCH cr_dat_cop INTO rw_dat_cop;
     CLOSE cr_dat_cop;

     IF pr_vestorno = 0 THEN

        OPEN cr_verifica_mdw(rw_cod_coop_orig.cdcooper
                            ,pr_cod_agencia
                            ,pr_nro_caixa
                            ,pr_rowid);
        FETCH cr_verifica_mdw INTO rw_verifica_mdw;

           IF cr_verifica_mdw%FOUND THEN
              vr_nrcheque := TO_NUMBER(TO_CHAR(rw_verifica_mdw.nrcheque)||
                                       TO_CHAR(rw_verifica_mdw.nrddigc3));

              -- Grava Autenticacao Arquivo/Spool
              CXON0000.pc_grava_autenticacao(pr_cooper       => rw_cod_coop_orig.cdcooper
                                            ,pr_cod_agencia  => pr_cod_agencia
                                            ,pr_nro_caixa    => pr_nro_caixa
                                            ,pr_cod_operador => pr_cod_operador
                                            ,pr_valor        => rw_verifica_mdw.vlcompel
                                            ,pr_docto        => vr_nrcheque
                                            ,pr_operacao     => TRUE -- YES (PG), NO (RC)
                                            ,pr_status       => '1' -- On-line
                                            ,pr_estorno      => FALSE -- Nao estorno
                                            ,pr_histor       => 386
                                            ,pr_data_off     => NULL
                                            ,pr_sequen_off   => 0 -- Seq. off-line
                                            ,pr_hora_off     => 0 -- hora off-line
                                            ,pr_seq_aut_off  => 0 -- Seq.orig.Off-line
                                            ,pr_literal      => pr_p_literal
                                            ,pr_sequencia    => pr_p_ult_sequencia
                                            ,pr_registro     => vr_p_registro
                                            ,pr_cdcritic     => vr_cdcritic
                                            ,pr_dscritic     => vr_dscritic);

              -- Se ocorreu erro
              IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                 pr_cdcritic := 0;
                 pr_dscritic := 'Erro na Autenticacao';

                 cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                      ,pr_cdagenci => pr_cod_agencia
                                      ,pr_nrdcaixa => pr_nro_caixa
                                      ,pr_cod_erro => pr_cdcritic
                                      ,pr_dsc_erro => pr_dscritic
                                      ,pr_flg_erro => TRUE
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic);


                 -- Se ocorreu algum erro interno
                 IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                    pr_cdcritic := vr_cdcritic;
                    pr_dscritic := vr_dscritic;
                    RAISE vr_exc_erro;
                 END IF;

                 RAISE vr_exc_erro;
              END IF;

              BEGIN
                  UPDATE crapmdw mdw
                     SET mdw.nrautdoc = pr_p_ult_sequencia
                   WHERE mdw.ROWID = rw_verifica_mdw.rowid;
                EXCEPTION
                   WHEN OTHERS THEN
                      pr_cdcritic := 0;
                      pr_dscritic := 'Erro ao atualizar registro de CRAPMDW : '||sqlerrm;
                      RAISE vr_exc_erro;
                END;

           END IF;
        CLOSE cr_verifica_mdw;

     ELSE

        FOR rw_consulta_chd IN cr_consulta_chd(rw_cod_coop_orig.cdcooper
                                              ,rw_dat_cop.dtmvtolt
                                              ,pr_cod_agencia
                                              ,11000 + pr_nro_caixa
                                              ,pr_nro_conta) LOOP


           IF TO_CHAR(rw_consulta_chd.nrdocmto) LIKE TO_CHAR(pr_nro_docmto||'%') THEN

              vr_nrcheque := TO_NUMBER(TO_CHAR(rw_consulta_chd.nrcheque)||
                                       TO_CHAR(rw_consulta_chd.nrddigc3));

              -- Grava Autenticacao Arquivo/Spool
              CXON0000.pc_grava_autenticacao(pr_cooper       => rw_cod_coop_orig.cdcooper
                                            ,pr_cod_agencia  => pr_cod_agencia
                                            ,pr_nro_caixa    => pr_nro_caixa
                                            ,pr_cod_operador => pr_cod_operador
                                            ,pr_valor        => rw_consulta_chd.vlcheque
                                            ,pr_docto        => vr_nrcheque
                                            ,pr_operacao     => TRUE -- YES (PG), NO (RC)
                                            ,pr_status       => '1' -- On-line
                                            ,pr_estorno      => TRUE -- estorno
                                            ,pr_histor       => 386
                                            ,pr_data_off     => NULL
                                            ,pr_sequen_off   => 0 -- Seq. off-line
                                            ,pr_hora_off     => 0 -- hora off-line
                                            ,pr_seq_aut_off  => 0 -- Seq.orig.Off-line
                                            ,pr_literal      => pr_p_literal
                                            ,pr_sequencia    => pr_p_ult_sequencia
                                            ,pr_registro     => vr_p_registro
                                            ,pr_cdcritic     => vr_cdcritic
                                            ,pr_dscritic     => vr_dscritic);

              -- Se ocorreu erro
              IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                 pr_cdcritic := 0;
                 pr_dscritic := 'Erro na Autenticacao';

                 cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                                      ,pr_cdagenci => pr_cod_agencia
                                      ,pr_nrdcaixa => pr_nro_caixa
                                      ,pr_cod_erro => pr_cdcritic
                                      ,pr_dsc_erro => pr_dscritic
                                      ,pr_flg_erro => TRUE
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic);


                 -- Se ocorreu algum erro interno
                 IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                    pr_cdcritic := vr_cdcritic;
                    pr_dscritic := vr_dscritic;
                    RAISE vr_exc_erro;
                 END IF;
              END IF;

           END IF;

        END LOOP;

     END IF;

     pr_retorno  := 'OK';

  EXCEPTION
     WHEN vr_exc_erro THEN
        pr_retorno  := 'NOK';
        ROLLBACK; -- Desfazer a operacao

     WHEN OTHERS THEN
         ROLLBACK; -- Desfazer a operacao
         pr_retorno  := 'NOK';
         pr_cdcritic := 0;
         pr_dscritic := 'Erro na rotina CXON0000.pc_autentica_cheque: '||SQLERRM;

         cxon0000.pc_cria_erro(pr_cdcooper => rw_cod_coop_orig.cdcooper
                              ,pr_cdagenci => pr_cod_agencia
                              ,pr_nrdcaixa => pr_nro_caixa
                              ,pr_cod_erro => vr_cdcritic
                              ,pr_dsc_erro => vr_dscritic
                              ,pr_flg_erro => TRUE
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic);

         -- Se ocorreu algum erro interno
         IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := vr_dscritic;
         END IF;

  END pc_autentica_cheque;

end CXON0051;
/

