CREATE OR REPLACE PACKAGE CECRED.EMPR0012 IS
  PROCEDURE pc_processa_perda_aprov(pr_cdcooper        IN crapdat.cdcooper%TYPE     --> Codigo da Cooperativa
                                   ,pr_nrdconta        IN crapass.nrdconta%TYPE     --> Numero da conta
                                   ,pr_nrctremp        IN crawepr.nrctremp%TYPE     --> Numero do contrato de emprestimo
                                   ,pr_tipoacao        IN VARCHAR2                  --> C - Consulta ou P - Processo de perda                                       
                                   -- Parâmteros necessários para chamada da rotina de cálculo do rating
                                   ,pr_cdagenci        IN crapass.cdagenci%TYPE      --> Codigo Agencia
                                   ,pr_nrdcaixa        IN craperr.nrdcaixa%TYPE      --> Numero Caixa
                                   ,pr_cdoperad        IN crapnrc.cdoperad%TYPE      --> Codigo Operador
                                   ,pr_tpctrato        IN crapnrc.tpctrrat%TYPE      --> Tipo Contrato Rating
                                   ,pr_flgcriar        IN OUT INTEGER                --> Indicado se deve criar o rating
                                   ,pr_flgcalcu        IN INTEGER                    --> Indicador de calculo
                                   ,pr_idseqttl        IN crapttl.idseqttl%TYPE      --> Sequencial do Titular
                                   ,pr_idorigem        IN INTEGER                    --> Identificador Origem
                                   ,pr_nmdatela        IN craptel.nmdatela%TYPE      --> Nome da tela
                                   ,pr_flgerlog        IN VARCHAR2                   --> Identificador de geração de log
                                   ,pr_flghisto        IN INTEGER                    --> Indicador se deve gerar historico
                                   ,pr_dsorigem        IN craplgm.dsorigem%TYPE      --> Descrição da origem                                       
                                   ,pr_idpeapro        OUT INTEGER                   --> 0 - Não perdeu aprovação e 1 - Perdeu aprovação                                   
                                   ,pr_dserro          OUT crapcri.dscritic%TYPE     --> OK - se processar e NOK - se erro
                                   ,pr_cdcritic        OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                   ,pr_dscritic        OUT crapcri.dscritic%TYPE);   --> Descricao da critica
                                      
  PROCEDURE pc_processa_perda_aprov_web(pr_cdcooper        IN crapdat.cdcooper%TYPE  --> Codigo da Cooperativa
                                       ,pr_nrdconta        IN crapass.nrdconta%TYPE  --> Numero da conta
                                       ,pr_nrctremp        IN crawepr.nrctremp%TYPE  --> Numero do contrato de emprestimo
                                       ,pr_tipoacao        IN VARCHAR2               --> C - Consulta ou P - Processo de perda
                                       -- Parâmteros necessários para chamada da rotina de cálculo do rating
                                       ,pr_cdagenci        IN crapass.cdagenci%TYPE  --> Codigo Agencia
                                       ,pr_nrdcaixa        IN craperr.nrdcaixa%TYPE  --> Numero Caixa
                                       ,pr_cdoperad        IN crapnrc.cdoperad%TYPE  --> Codigo Operador
                                       ,pr_tpctrato        IN crapnrc.tpctrrat%TYPE  --> Tipo Contrato Rating
                                       ,pr_flgcriar        IN OUT INTEGER            --> Indicado se deve criar o rating
                                       ,pr_flgcalcu        IN INTEGER                --> Indicador de calculo
                                       ,pr_idseqttl        IN crapttl.idseqttl%TYPE  --> Sequencial do Titular
                                       ,pr_idorigem        IN INTEGER                --> Identificador Origem
                                       ,pr_nmdatela        IN craptel.nmdatela%TYPE  --> Nome da tela
                                       ,pr_flgerlog        IN VARCHAR2               --> Identificador de geração de log
                                       ,pr_flghisto        IN INTEGER                --> Indicador se deve gerar historico
                                       ,pr_dsorigem        IN craplgm.dsorigem%TYPE  --> Descrição da origem
                                       ,pr_xmllog          IN VARCHAR2               --> XML com informações de LOG
                                       ,pr_cdcritic        OUT PLS_INTEGER           --> Código da crítica
                                       ,pr_dscritic        OUT VARCHAR2              --> Descrição da crítica
                                       ,pr_retxml          IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                       ,pr_nmdcampo        OUT VARCHAR2              --> Nome do campo com erro
                                       ,pr_des_erro        OUT VARCHAR2
                                       );                                       

  PROCEDURE pc_processa_prop_empr_expirada(pr_cdcooper     IN crapdat.cdcooper%TYPE     --> Codigo da Cooperativa
                                          ,pr_nrdconta     IN crapass.nrdconta%TYPE     --> Numero da conta
                                          ,pr_nrctremp     IN crawepr.nrctremp%TYPE     --> Numero do contrato de emprestimo
                                          ,pr_dserro       OUT crapcri.dscritic%TYPE     --> OK - se processar e NOK - se erro
                                          ,pr_cdcritic     OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                          ,pr_dscritic     OUT crapcri.dscritic%TYPE);            --> Erros do processo

END EMPR0012;
/
CREATE OR REPLACE PACKAGE BODY CECRED.EMPR0012 IS
  ---------------------------------------------------------------------------
  --
  --  Programa : EMPR0012
  --  Sistema  : Crédito - Cooperativa de Credito
  --  Sigla    : CRED
  --  Autor    : Márcio Carvalho - Mouts
  --  Data     : Julho - 2018                 Ultima atualizacao: 
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Centralizar rotinas para perda de aprovação da proposta do empréstimo.
  --
  -- Alteracoes: 
  --
  ---------------------------------------------------------------------------
  PROCEDURE pc_processa_perda_aprov(pr_cdcooper        IN crapdat.cdcooper%TYPE     --> Codigo da Cooperativa
                                   ,pr_nrdconta        IN crapass.nrdconta%TYPE     --> Numero da conta
                                   ,pr_nrctremp        IN crawepr.nrctremp%TYPE     --> Numero do contrato de emprestimo
                                   ,pr_tipoacao        IN VARCHAR2                  --> C - Consulta ou P - Processo de perda
                                   -- Parâmteros necessários para chamada da rotina de cálculo do rating
                                   ,pr_cdagenci        IN crapass.cdagenci%TYPE      --> Codigo Agencia
                                   ,pr_nrdcaixa        IN craperr.nrdcaixa%TYPE      --> Numero Caixa
                                   ,pr_cdoperad        IN crapnrc.cdoperad%TYPE      --> Codigo Operador
                                   ,pr_tpctrato        IN crapnrc.tpctrrat%TYPE      --> Tipo Contrato Rating
                                   ,pr_flgcriar        IN OUT INTEGER                --> Indicado se deve criar o rating
                                   ,pr_flgcalcu        IN INTEGER                    --> Indicador de calculo
                                   ,pr_idseqttl        IN crapttl.idseqttl%TYPE      --> Sequencial do Titular
                                   ,pr_idorigem        IN INTEGER                    --> Identificador Origem
                                   ,pr_nmdatela        IN craptel.nmdatela%TYPE      --> Nome da tela
                                   ,pr_flgerlog        IN VARCHAR2                   --> Identificador de geração de log
                                   ,pr_flghisto        IN INTEGER                    --> Indicador se deve gerar historico
                                   ,pr_dsorigem        IN craplgm.dsorigem%TYPE      --> Descrição da origem
                                    --
                                   ,pr_idpeapro        OUT INTEGER                   --> 0 - Não perdeu aprovação e 1 - Perdeu aprovação
                                   ,pr_dserro          OUT crapcri.dscritic%TYPE     --> OK - se processar e NOK - se erro
                                   ,pr_cdcritic        OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                   ,pr_dscritic        OUT crapcri.dscritic%TYPE) IS --> Descricao da critica
  BEGIN
    /* .............................................................................

       Programa: pc_processa_perda_aprovacao
       Sistema : Crédito - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Márcio Carvalho
       Data    : Julho/2018                         Ultima atualizacao: 

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para processaer as regras para perda da aprovação da proposta de empréstimo.
                   Para realizar a alteração da proposta sem perder a aprovação da esteira, os três parâmetros 
                   cadastrados acima deverão ter os resultados como verdadeiro.
                   Entende-se como resultado “VERDADEIRO” quando o Ayllos faz as validações e os valores estão 
                   dentro do permitido e o rating não foi piorado.
                   Entende-se como “FALSO” quando qualquer uma das validações ultrapassaram os parâmetros 
                   cadastrados ou o rating foi piorado.    
       Alterações: 
    ............................................................................. */

    DECLARE
      CURSOR
        cr_crawepr is
        SELECT
               c.vlemprst,
               c.vlpreemp,
               c.vlempori,
               c.vlpreori,
               c.dsratori,
               c.rowid
          FROM
               crawepr c
         WHERE
               c.cdcooper = pr_cdcooper
           and c.nrdconta = pr_nrdconta
           and c.nrctremp = pr_nrctremp;
        
      -- Variaveis tratamento de erros
      vr_cdcritic             crapcri.cdcritic%TYPE;
      vr_dscritic             VARCHAR2(4000);
      vr_exc_erro             EXCEPTION;
      vr_tab_erro             GENE0001.typ_tab_erro;
      
      vr_diferenca_valor      NUMBER;
      vr_diferenca_parcela    NUMBER;      
      vr_dstextab             craptab.dstextab%TYPE;  
      vr_vltolemp             NUMBER  :=0;          
      vr_pcaltpar             NUMBER  :=0;      
      vr_des_erro             VARCHAR2(4000);    
      vr_ind                  PLS_INTEGER; --> Indice da tabela de retorno  
      vr_pontos               PLS_INTEGER; --> Indice da tabela de retorno  
      vr_rating               VARCHAR2(2);
      vr_nrdrowid             ROWID;                  
      
      --PL tables
      vr_tab_rating_sing      RATI0001.typ_tab_crapras;
      vr_tab_impress_coop     RATI0001.typ_tab_impress_coop;
      vr_tab_impress_rating   RATI0001.typ_tab_impress_rating;
      vr_tab_impress_risco_cl RATI0001.typ_tab_impress_risco;
      vr_tab_impress_risco_tl RATI0001.typ_tab_impress_risco;      
      vr_tab_impress_assina   RATI0001.typ_tab_impress_assina;
      vr_tab_efetivacao       RATI0001.typ_tab_efetivacao;
      vr_tab_ratings          RATI0001.typ_tab_ratings;
      vr_tab_crapras          RATI0001.typ_tab_crapras;

    BEGIN
      pr_idpeapro :=0;
      --1ª Regra: Valor Emprestado
      --O Ayllos deverá pegar o valor da proposta alterada e subtrair do valor da proposta original aprovada,
      --essa subtração irá gerar uma diferença, o valor dessa diferença deverá ser verificado com o valor 
      --cadastrado no parâmetro “tolerância por valor de empréstimo”. Se a diferença entre as propostas
      --for menor ou igual ao parâmetro denominado “tolerância por valor de empréstimo” o Ayllos deverá
      --seguir com as demais verificações. Caso contrário a proposta irá perder a aprovação e não será 
      --necessário verificar a próxima regra.      
      FOR C1 in cr_crawepr LOOP
        vr_diferenca_valor:= c1.vlemprst - c1.vlempori;
        -- Buscar dados da TAB089

        vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                 ,pr_nmsistem => 'CRED'
                                                 ,pr_tptabela => 'USUARI'
                                                 ,pr_cdempres => 11
                                                 ,pr_cdacesso => 'PAREMPREST'
                                                 ,pr_tpregist => 01);
        vr_vltolemp := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,60,12)),0);     
        --Aproveitar a leitura da tab089 e puscar o percentual de tolerância da prestação também
        vr_pcaltpar := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,53,6)),0);        
        IF vr_diferenca_valor >  vr_vltolemp THEN -- Perde a aprovação
          pr_idpeapro :=1;
          -- Se a ação for de processo de perda de aprovação 
          IF pr_tipoacao = 'P' THEN
            BEGIN
              UPDATE
                   crawepr c
                 SET
                    c.insitapr = 0,
                    c.cdopeapr = null,
                    c.dtaprova = null,
                    c.hraprova = 0,
                    c.insitest = 0          
               WHERE
                    c.rowid = c1.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar tabela crawemp. ' || SQLERRM;
                --Sair do programa
                RAISE vr_exc_erro;
            END;
            GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                                ,pr_cdoperad => pr_cdoperad
                                ,pr_dscritic => ''
                                ,pr_dsorigem => pr_dsorigem
                                ,pr_dstransa => 'A proposta :'||pr_nrctremp
                                             ||' Perdeu a aprovação por Tolerância por valor de empréstimo. Valor original do empréstimo:'  ||c1.vlempori
                                             ||' Valor atual:'||c1.vlemprst
                                             ||' Diferença:'  ||vr_diferenca_valor
                                             ||' Tolerância:' ||vr_vltolemp
                                ,pr_dttransa => TRUNC(SYSDATE)
                                ,pr_flgtrans => (CASE WHEN vr_dscritic IS NULL THEN 1
                                                 ELSE 0 
                                                 END )
                                ,pr_hrtransa => gene0002.fn_busca_time
                                ,pr_idseqttl => pr_idseqttl
                                ,pr_nmdatela => pr_nmdatela
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_nrdrowid => vr_nrdrowid);              
          END IF;
        ELSE -- 2ª Regra: Valor de Parcela 
          vr_dstextab:= '';
          --O Ayllos deverá verificar o valor da prestação contratada na proposta original aprovada 
          --e verificar se o novo valor fica dentro do % de tolerância do parâmetro, o Ayllos deverá seguir com a 
          --próxima validação. Caso contrário a proposta irá perder a aprovação e não será necessário verificar a próxima regra.
          vr_diferenca_parcela:= ((c1.vlpreemp/c1.vlpreori)-1)*100;
          
          IF vr_diferenca_parcela > vr_pcaltpar THEN -- Perde a aprovação
            pr_idpeapro :=1;            
            -- Se a ação for de processo de perda de aprovação 
            IF pr_tipoacao = 'P' THEN
              BEGIN
                UPDATE
                     crawepr c
                   SET
                      c.insitapr = 0,
                      c.cdopeapr = null,
                      c.dtaprova = null,
                      c.hraprova = 0,
                      c.insitest = 0          
                 WHERE
                      c.rowid = c1.rowid;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao atualizar tabela crawemp. ' || SQLERRM;
                  --Sair do programa
                  RAISE vr_exc_erro;
              END;
              GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                                  ,pr_cdoperad => pr_cdoperad
                                  ,pr_dscritic => ''
                                  ,pr_dsorigem => pr_dsorigem
                                  ,pr_dstransa => 'A proposta :'||pr_nrctremp
                                               ||' Perdeu a aprovação por Alteração de parcela. Valor original da parcela:'  ||c1.vlpreori
                                               ||' Valor atual:'    ||c1.vlpreemp
                                               ||' % da Diferença:' ||vr_diferenca_parcela
                                               ||' % de Tolerância:'||vr_pcaltpar
                                  ,pr_dttransa => TRUNC(SYSDATE)
                                  ,pr_flgtrans => (CASE WHEN vr_dscritic IS NULL THEN 1
                                                   ELSE 0 
                                                   END )
                                  ,pr_hrtransa => gene0002.fn_busca_time
                                  ,pr_idseqttl => pr_idseqttl
                                  ,pr_nmdatela => pr_nmdatela
                                  ,pr_nrdconta => pr_nrdconta
                                 ,pr_nrdrowid => vr_nrdrowid);              
            END IF;
          ELSE -- 3ª Regra: Rating
            --O Ayllos deverá verificar se com a alteração do valor da proposta, houve alteração no rating
            --(para pior), gerado da proposta original aprovada para a proposta alterada
            --(Recalcular o rating para efetuar a comparação).  Se o rating piorar a proposta deve perder a aprovação
           
            RATI0001.pc_calcula_rating(pr_cdcooper => pr_cdcooper   --> Codigo Cooperativa
                                      ,pr_cdagenci => pr_cdagenci   --> Codigo Agencia
                                      ,pr_nrdcaixa => pr_nrdcaixa   --> Numero Caixa
                                      ,pr_cdoperad => pr_cdoperad   --> Codigo Operador
                                      ,pr_nrdconta => pr_nrdconta   --> Numero da Conta
                                      ,pr_tpctrato => pr_tpctrato   --> Tipo Contrato Rating
                                      ,pr_nrctrato => pr_nrctremp   --> Numero Contrato Rating
                                      ,pr_flgcriar => pr_flgcriar   --> Indicado se deve criar o rating
                                      ,pr_flgcalcu => pr_flgcalcu   --> Indicador de calculo
                                      ,pr_idseqttl => pr_idseqttl   --> Sequencial do Titular
                                      ,pr_idorigem => pr_idorigem   --> Identificador Origem
                                      ,pr_nmdatela => pr_nmdatela   --> Nome da tela
                                      ,pr_flgerlog => pr_flgerlog   --> Identificador de geração de log
                                      ,pr_tab_rating_sing      => vr_tab_rating_sing      --> Registros gravados para rati
                                      ,pr_flghisto => pr_flghisto
                                      -- OUT
                                      ,pr_tab_impress_coop     => vr_tab_impress_coop     --> Registro impressão da Cooper
                                      ,pr_tab_impress_rating   => vr_tab_impress_rating   --> Registro itens do Rating
                                      ,pr_tab_impress_risco_cl => vr_tab_impress_risco_cl --> Registro Nota e risco do coo
                                      ,pr_tab_impress_risco_tl => vr_tab_impress_risco_tl --> Registro Nota e risco do coo
                                      ,pr_tab_impress_assina   => vr_tab_impress_assina   --> Assinatura na impressao do R
                                      ,pr_tab_efetivacao       => vr_tab_efetivacao       --> Registro dos itens da efetiv
                                      ,pr_tab_ratings          => vr_tab_ratings          --> Informacoes com os Ratings d
                                      ,pr_tab_crapras          => vr_tab_crapras          --> Tabela com os registros proc
                                      ,pr_tab_erro             => vr_tab_erro             --> Tabela de retorno de erro
                                      ,pr_des_reto             => vr_des_erro);           --> Ind. de retorno OK/NOK
            -- Em caso de erro
            IF vr_des_erro <> 'OK' THEN
              --Se não tem erro na tabela
              IF vr_tab_erro.COUNT = 0 THEN
                vr_cdcritic:= 0;
                vr_dscritic:= 'Erro ao calcular rating.';
              END IF;
              -- Sair
              RAISE vr_exc_erro;
            END IF;
            vr_ind := vr_tab_impress_risco_cl.first; -- Vai para o primeiro registro            
            -- loop sobre a tabela de retorno
            WHILE vr_ind IS NOT NULL LOOP
              vr_pontos:= vr_tab_impress_risco_cl(vr_ind).vlrtotal;
              vr_rating:= vr_tab_impress_risco_cl(vr_ind).dsdrisco;
              -- Vai para o proximo registro
              vr_ind := vr_tab_impress_risco_cl.next(vr_ind);
            END LOOP;    
            IF vr_rating > c1.dsratori THEN
              pr_idpeapro :=1;
              -- Se a ação for de processo de perda de aprovação 
              IF pr_tipoacao = 'P' THEN              
                BEGIN
                  UPDATE
                       crawepr c
                     SET
                        c.insitapr = 0,
                        c.cdopeapr = null,
                        c.dtaprova = null,
                        c.hraprova = 0,
                        c.insitest = 0          
                   WHERE
                        c.rowid = c1.rowid;
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'Erro ao atualizar tabela crawemp. ' || SQLERRM;
                    --Sair do programa
                    RAISE vr_exc_erro;
                END;  
                GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                                    ,pr_cdoperad => pr_cdoperad
                                    ,pr_dscritic => ''
                                    ,pr_dsorigem => pr_dsorigem
                                    ,pr_dstransa => 'A proposta :'||pr_nrctremp
                                                 ||' Perdeu a aprovação por Alteração do Rating para pior. Rating original:'  ||c1.dsratori
                                                 ||' Rating atual : '||vr_rating
                                    ,pr_dttransa => TRUNC(SYSDATE)
                                    ,pr_flgtrans => (CASE WHEN vr_dscritic IS NULL THEN 1
                                                     ELSE 0 
                                                     END )
                                    ,pr_hrtransa => gene0002.fn_busca_time
                                    ,pr_idseqttl => pr_idseqttl
                                    ,pr_nmdatela => pr_nmdatela
                                    ,pr_nrdconta => pr_nrdconta
                                   ,pr_nrdrowid => vr_nrdrowid);              
              END IF;                
            END IF;
          END IF; 
        END IF;  
        -- Se não é consulta e chegou ao final do processo sem perder a aprovação, grava um log
        IF pr_idpeapro = 0 and pr_tipoacao = 'P' THEN
          GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => ''
                              ,pr_dsorigem => pr_dsorigem
                              ,pr_dstransa => 'A proposta :'||pr_nrctremp
                                           ||' Foi validad pela rotina EMPR0012.PC_PROCESSA_PERDA_APROVACAO e teve a sua aprovação mantida.'
                                           ||' Valor original do empréstimo:'||c1.vlempori
                                           ||' Valor atual:'                 ||c1.vlemprst
                                           ||' Diferença:'                   ||vr_diferenca_valor
                                           ||' Tolerância:'                  ||vr_vltolemp                                           
                                           ||' Valor original da parcela:'   ||c1.vlpreori
                                           ||' Valor atual:'                 ||c1.vlpreemp
                                           ||' % da Diferença:'              ||vr_diferenca_parcela
                                           ||' % de Tolerância:'             ||vr_pcaltpar                                           
                                           ||' Rating original:'             ||c1.dsratori
                                           ||' Rating atual:'                ||vr_rating
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => (CASE WHEN vr_dscritic IS NULL THEN 1
                                               ELSE 0 
                                               END )
                              ,pr_hrtransa => gene0002.fn_busca_time
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);          
        END IF;
      END LOOP;
      -- Se chegou até o final sem erro retorna OK
      pr_dserro := 'OK';
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_dserro:= 'NOK';
        IF NVL(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        pr_cdcritic := NVL(vr_cdcritic, 0);
        pr_dscritic := vr_dscritic;
              
      WHEN OTHERS THEN
        pr_dserro:= 'NOK';
        pr_cdcritic := 0;
        pr_dscritic := 'Erro na procedure EMPR0012.pc_processa_perda_aprovacao: ' || SQLERRM;
    END;

  END pc_processa_perda_aprov;
---------------------------------------
  -- Chamar a pc_processa_perda_aprovacao por mensageria
  PROCEDURE pc_processa_perda_aprov_web(pr_cdcooper        IN crapdat.cdcooper%TYPE  --> Codigo da Cooperativa
                                       ,pr_nrdconta        IN crapass.nrdconta%TYPE  --> Numero da conta
                                       ,pr_nrctremp        IN crawepr.nrctremp%TYPE  --> Numero do contrato de emprestimo
                                       ,pr_tipoacao        IN VARCHAR2               --> C - Consulta ou P - Processo de perda
                                       -- Parâmteros necessários para chamada da rotina de cálculo do rating
                                       ,pr_cdagenci        IN crapass.cdagenci%TYPE  --> Codigo Agencia
                                       ,pr_nrdcaixa        IN craperr.nrdcaixa%TYPE  --> Numero Caixa
                                       ,pr_cdoperad        IN crapnrc.cdoperad%TYPE  --> Codigo Operador
                                       ,pr_tpctrato        IN crapnrc.tpctrrat%TYPE  --> Tipo Contrato Rating
                                       ,pr_flgcriar        IN OUT INTEGER            --> Indicado se deve criar o rating
                                       ,pr_flgcalcu        IN INTEGER                --> Indicador de calculo
                                       ,pr_idseqttl        IN crapttl.idseqttl%TYPE  --> Sequencial do Titular
                                       ,pr_idorigem        IN INTEGER                --> Identificador Origem
                                       ,pr_nmdatela        IN craptel.nmdatela%TYPE  --> Nome da tela
                                       ,pr_flgerlog        IN VARCHAR2               --> Identificador de geração de log
                                       ,pr_flghisto        IN INTEGER                --> Indicador se deve gerar historico
                                       ,pr_dsorigem        IN craplgm.dsorigem%TYPE  --> Descrição da origem
                                       ,pr_xmllog          IN VARCHAR2               --> XML com informações de LOG
                                       ,pr_cdcritic        OUT PLS_INTEGER           --> Código da crítica
                                       ,pr_dscritic        OUT VARCHAR2              --> Descrição da crítica
                                       ,pr_retxml          IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                       ,pr_nmdcampo        OUT VARCHAR2              --> Nome do campo com erro
                                       ,pr_des_erro        OUT VARCHAR2
                                       ) IS          --> Erros do processo 
                                   
    -- VARIÁVEIS
    vr_idpeapro      INTEGER;
    vr_cdcritic      crapcri.cdcritic%TYPE;
    vr_dscritic      VARCHAR2(4000);
    vr_dserro        crapcri.dscritic%TYPE;
    
    -- Variáveis para armazenar as informações em XML
    vr_des_xml         CLOB;
    
    -- Variável para armazenar os dados do XML antes de incluir no CLOB
    vr_texto_completo  VARCHAR2(32600);
    
    -- EXCEPTIONS
    vr_exc_saida     EXCEPTION;
    
    -- Escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
    END;    
    
  BEGIN 
    
    pr_des_erro := 'OK';

    gene0001.pc_informa_acesso(pr_module => 'EMPR0002');
    
    EMPR0012.pc_processa_perda_aprov(pr_cdcooper => pr_cdcooper
                                    ,pr_nrdconta => pr_nrdconta
                                    ,pr_nrctremp => pr_nrctremp
                                    ,pr_tipoacao => pr_tipoacao
                                     -- Parâmteros necessários para chamada da rotina de cálculo do rating
                                    ,pr_cdagenci => pr_cdagenci
                                    ,pr_nrdcaixa => pr_nrdcaixa
                                    ,pr_cdoperad => pr_cdoperad
                                    ,pr_tpctrato => pr_tpctrato
                                    ,pr_flgcriar => pr_flgcriar
                                    ,pr_flgcalcu => pr_flgcalcu
                                    ,pr_idseqttl => pr_idseqttl
                                    ,pr_idorigem => pr_idorigem
                                    ,pr_nmdatela => pr_nmdatela 
                                    ,pr_flgerlog => pr_flgerlog
                                    ,pr_flghisto => pr_flghisto
                                    ,pr_dsorigem => pr_dsorigem
                                     --
                                    ,pr_idpeapro => vr_idpeapro
                                    ,pr_dserro   => vr_dserro
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic);
   
    -- Se houve o retorno de erro
    IF vr_dserro <> 'OK' THEN
      RAISE vr_exc_saida;
    END IF;
    
    -- Inicializar o CLOB
    vr_des_xml := NULL;
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
    vr_texto_completo := NULL;
      
    pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><root><dados idpeapro="'||vr_idpeapro||'">');
   
    -- Finaliza o XML     
    pc_escreve_xml('</dados></root>',TRUE);        
    pr_retxml := XMLType.createXML(vr_des_xml);
  EXCEPTION
    WHEN vr_exc_saida THEN
      
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
      
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral PC_INCLUI_BLOQUEIO_JUD_WEB: ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_processa_perda_aprov_web;

----------------------------------------  

  PROCEDURE pc_processa_prop_empr_expirada(pr_cdcooper  IN crapdat.cdcooper%TYPE     --> Codigo da Cooperativa
                                          ,pr_nrdconta  IN crapass.nrdconta%TYPE     --> Numero da conta
                                          ,pr_nrctremp  IN crawepr.nrctremp%TYPE     --> Numero do contrato de emprestimo
                                          ,pr_dserro    OUT crapcri.dscritic%TYPE     --> OK - se processar e NOK - se erro
                                          ,pr_cdcritic  OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                          ,pr_dscritic  OUT crapcri.dscritic%TYPE) IS          --> Erros do processo
  BEGIN
    /* .............................................................................

       Programa: pc_processa_prop_emp_expirada
       Sistema : Crédito - Cooperativa de Credito
       Sigla   : CRED
       Autor   : 
       Data    : 07/2018                         Ultima atualizacao: 

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para procesar as regras de expiração da proposta de crédito

       Alteracoes: 
    ............................................................................. */

    DECLARE
      CURSOR cr_crapcop IS   
        SELECT 
              cop.cdcooper
          FROM 
              crapcop cop
         WHERE
              cop.cdcooper = NVL(pr_cdcooper, cop.cdcooper)
          AND cop.cdcooper <> 3 -- Diferente de Ailos
          AND cop.flgativo = 1
      ORDER BY
              cop.cdcooper;  

      CURSOR cr_crawepr(p_cdcooper IN crapcop.cdcooper%type) IS             
        SELECT 
              w.cdcooper,
              w.nrdconta,
              w.nrctremp,
              w.dtaprova
          FROM
              crawepr w
         WHERE 
              w.cdcooper = p_cdcooper
          AND w.nrdconta = NVL(pr_nrdconta,w.nrdconta)
          AND w.nrctremp = NVL(pr_nrctremp,w.nrctremp)
          AND w.insitapr = 1 -- Aprovado 
      ORDER BY          
              w.cdcooper,
              w.nrdconta,
              w.nrctremp;          

      CURSOR cr_crapbpr_imovel(p_cdcooper IN crapcop.cdcooper%type,
                               p_nrdconta IN crapass.nrdconta%type,
                               p_nrctrpro IN crapbpr.nrctrpro%type) IS             

        SELECT  
              1 -- Existe Garantia de Imóvel
          FROM
              crapbpr bpr
         WHERE 
              bpr.cdcooper = p_cdcooper
          AND bpr.nrdconta = p_nrdconta
          AND bpr.nrctrpro = p_nrctrpro -- Numero proposta contrato
          AND bpr.flgalien = 1          -- garantia alienada a proposta
          AND bpr.tpctrpro IN (90,99)    -- Garantia
          AND dscatbem IN ('TERRENO','APARTAMENTO','CASA')
          AND ROWNUM = 1;

      CURSOR cr_crapbpr_automovel(p_cdcooper IN crapcop.cdcooper%type,
                                  p_nrdconta IN crapass.nrdconta%type,
                                  p_nrctrpro IN crapbpr.nrctrpro%type) IS             
        SELECT  
              1 -- Existe Garantia de Automovel
          FROM
              crapbpr bpr
         WHERE 
              bpr.cdcooper = p_cdcooper
          AND bpr.nrdconta = p_nrdconta
          AND bpr.nrctrpro = p_nrctrpro -- Numero proposta contrato
          AND bpr.flgalien = 1  -- garantia alienada a proposta
          AND bpr.tpctrpro IN (90,99) -- Garantia
          AND dscatbem IN ('AUTOMOVEL','CAMINHAO','MOTO')
          AND ROWNUM = 1;          

      -- Variaveis Excecao
      vr_exc_erro           EXCEPTION;

      -- Variaveis Erro
      vr_cdcritic              INTEGER;
      vr_dscritic              VARCHAR2(4000);
      
      --Variáveis locais
      vr_dstextab    craptab.dstextab%TYPE;      
      vr_qtddiexp    NUMBER(5):= 0;
      vr_qtdpaimo    NUMBER(5):= 0;
      vr_qtdpaaut    NUMBER(5):= 0;
      vr_qtdpaava    NUMBER(5):= 0;
      vr_qtdpaapl    NUMBER(5):= 0;
      vr_qtdpasem    NUMBER(5):= 0;
      vr_qtdpameq    NUMBER(5):= 0;

    BEGIN
      FOR rw_crapcop IN cr_crapcop LOOP -- Cursor de Cooperativas
        -- Inicia a variável com zero pois está dentro do loop
        vr_qtddiexp := 0;
        -- Ler a TAB089 para identificar os dias de expiração para cada garantia.
        vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => rw_crapcop.cdcooper
                                                 ,pr_nmsistem => 'CRED'
                                                 ,pr_tptabela => 'USUARI'
                                                 ,pr_cdempres => 11
                                                 ,pr_cdacesso => 'PAREMPREST'
                                                 ,pr_tpregist => 01);
          vr_qtdpaimo := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,73,3)),0);
          vr_qtdpaaut := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,77,3)),0);
          vr_qtdpaava := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,81,3)),0);
          vr_qtdpaapl := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,85,3)),0);
          vr_qtdpasem := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,89,3)),0);
          vr_qtdpameq := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,105,3)),0);        
          
          FOR rw_crawepr IN cr_crawepr(rw_crapcop.cdcooper) LOOP -- Cursor de Empréstimos
            -- Com base no retorno das propostas lidas deverá ser verificado se existem garantias, conforme abaixo:
            
            -- Garantia de Imóvel
            FOR rw_crapbpr_imovel IN cr_crapbpr_imovel(rw_crapcop.cdcooper,
                                                       rw_crawepr.nrdconta,
                                                       rw_crawepr.nrctremp) LOOP -- Cursor de Garantia de Imóvel
              -- Existe Garantia de Imóvel              
              vr_qtddiexp := vr_qtdpaimo;
            END LOOP;-- Cursor de Garantia de Imóvel
            
            -- Garantia  de automóvel
            FOR rw_crapbpr_automovel IN cr_crapbpr_automovel(rw_crapcop.cdcooper,
                                                             rw_crawepr.nrdconta,
                                                             rw_crawepr.nrctremp) LOOP -- Cursor de Garantia de Imóvel
              -- Existe Garantia  de automóvel  
              
              -- Verifica se a quantidade de dias para garantia é maior que a quantidade de dias da variável
              -- de dias de expiração, se for, atribuiu a quantidade de dias da garantia na variável
              IF vr_qtdpaaut > vr_qtddiexp THEN
                vr_qtddiexp := vr_qtdpaaut;
              END IF;
            END LOOP;-- Cursor de Garantia  de automóvel
            
          END LOOP;-- Cursor de Empréstimos
      END LOOP;  -- Cursosr de Cooperativas

/*
Para empréstimo:

Criar uma nova procedure Oracle (EMPR0012) para desenvolver as seguintes especificações.
A regra deverá seguir os seguintes passos:

3. 
 3.1 - Para ler garantias de imóvel devera ser feito a consulta com a seguinte query:

3.2 - Para ler garantias devera ser feito a consulta com a seguinte query:


3.3 - Para ler garantias de Avalista devera ser feito a consulta com as seguintes querys:
-- avalista terceiro
SELECT 1
  FROM crapavt avt
 WHERE TPCTRATO = 1 -- Emprestimo
   AND avt.cdcooper = ?
   AND avt.nrdconta = ?
   AND avt.nrctremp = ?
 
-- Avalista não terceiro (que tem conta na coop) 
SELECT 1
  FROM crapavl avl
 WHERE avl.cdcooper = ?
   AND avl.nrdconta = ?
   AND avl.NRCTRAVD = ? -- Numero do contrato avalisado.
   AND avl.tpctrato = 1; -- emprestimo

3.4 - Para ler garantias de Aplicação devera ser feito a consulta com a seguinte query:
-- Aplicação e poupança
SELECT 1 -- Existe Aplicação Poupança
  FROM tbgar_cobertura_operacao t
 WHERE t.cdcooper  = ?
  AND t.nrdconta   = ?
  AND t.nrcontrato = ?
  AND t.tpcontrato = 90;

3.5 - Para ler garantias de Máquinas / Equipamentos devera ser feito a consulta com a seguinte query:
SELECT 1 -- Existe equipamento
  FROM crapbpr bpr
 WHERE bpr.cdcooper = ?
   AND bpr.nrdconta = ?
   AND bpr.nrctrpro = ? -- Numero proposta contrato
   AND bpr.flgalien = 1  -- garantia alienada a proposta
   AND bpr.tpctrpro IN (90,99) -- Garantia
   AND dscatbem IN ('EQUIPAMENTO','MAQUINA DE COSTURA')
  ;
3.6 - Caso não encontre garantias, o sistema deverá considerar uma proposta sem garantia.

4. Com base nas garantias vinculadas a propostas, deverá ser feito uma busca no cadastro da tab089 para encontrar os dias cadastrados no frame "PA - Prazo de validade da análise para efetivação"
 - No caso de um contrato ter mais de uma garantia, considerar do cadastro tab089 o que tem a maior quantidade de dias;
 - No caso a proposta não tiver garantias, o sistema deverá considerar somente o parâmetro da tela tab089 "Operação sem garantia"




5. Com os dias corretamente selecionados, o sistema deverá soma-los com a data de aprovação da proposta (Somar somente dias úteis).
6. Se a data for maior que hoje, o sistema deverá realizar a alteração da situação da proposta para 5 - " expirada por decurso de prazo ".
7. Abaixo os campos que deverão ser atualizado quando a proposta entrar nos critérios de expiração:
crawepr.insitapr := 0 -- Decisao da proposta
crawepr.cdopeapr := null
crawepr.dtaprova := null
crawepr.hraprova := 0
crawepr.insitest := 5 -- Situação da proposta - Nova situação "5 - expirada por decurso de prazo"

8. Por se tratar de uma nova situação de proposta, deverá ser visto as seguintes rotinas e verificar se necessário com Rafael / Oscar a necessidade da alteração.
b1wgen0002.p
ESTE0001.pck
ESTE0003.pck
ESTE0004.pck
ESTE0005.pck
WEBS0001.pck
TELA_CONPRO.pck

*/   

------------------------------
/* 
      -- Extrai os dados vindos do XML
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Seleciona o calendario
      OPEN  BTCH0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      vr_blnachou := BTCH0001.cr_crapdat%FOUND;
      CLOSE BTCH0001.cr_crapdat;
      -- Se NAO achou
      IF NOT vr_blnachou THEN
        vr_cdcritic := 1;
        RAISE vr_exc_erro;
      END IF;
      
      -- Buscar os dados da proposta de emprestimo
      OPEN cr_crawepr(pr_cdcooper => vr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrctremp => pr_nrctremp);
      FETCH cr_crawepr INTO rw_crawepr;
      vr_blnachou := cr_crawepr%FOUND;
      CLOSE cr_crawepr;
      -- Se NAO achou
      IF NOT vr_blnachou THEN
        vr_cdcritic := 535;
        RAISE vr_exc_erro;
      END IF;

      -- Selecionar Associado
      OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      CLOSE cr_crapass;

      -- Selecionar Operadores
      OPEN cr_crapope(pr_cdcooper => vr_cdcooper
                     ,pr_cdoperad => vr_cdoperad);
      FETCH cr_crapope INTO rw_crapope;
      vr_crapope := cr_crapope%FOUND;
      CLOSE cr_crapope;
      -- Se NAO achou
      IF NOT vr_crapope THEN
        vr_cdcritic := 67;
        RAISE vr_exc_erro;
      END IF;
      */
      -- Se chegou até o final sem erro retorna OK
      pr_dserro := 'OK';
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_dserro:= 'NOK';
        IF NVL(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        pr_cdcritic := NVL(vr_cdcritic, 0);
        pr_dscritic := vr_dscritic;
              
      WHEN OTHERS THEN
        pr_dserro:= 'NOK';
        pr_cdcritic := 0;
        pr_dscritic := 'Erro na procedure EMPR0012.pc_processa_perda_aprovacao: ' || SQLERRM;
    END;

  END pc_processa_prop_empr_expirada;

END EMPR0012;
/
