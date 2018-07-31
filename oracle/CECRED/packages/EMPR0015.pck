CREATE OR REPLACE PACKAGE CECRED.EMPR0015 IS
  PROCEDURE pc_processa_perda_aprov(pr_cdcooper        IN crapdat.cdcooper%TYPE     --> Codigo da Cooperativa
                                   ,pr_nrdconta        IN crapass.nrdconta%TYPE     --> Numero da conta
                                   ,pr_nrctremp        IN crawepr.nrctremp%TYPE     --> Numero do contrato de emprestimo
                                   ,pr_tipoacao        IN VARCHAR2                  --> C - Consulta ou P - Processo de perda                                       
                                   ,pr_vlemprst        IN crawepr.vlemprst%TYPE     --> Novo valor da proposta
                                   ,pr_vlpreemp        IN crawepr.vlpreemp%TYPE     --> Novo valor da prestação
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
                                      
  PROCEDURE pc_processa_perda_aprov_web(pr_nrdconta        IN crapass.nrdconta%TYPE  --> Numero da conta
                                       ,pr_nrctremp        IN crawepr.nrctremp%TYPE  --> Numero do contrato de emprestimo
                                       ,pr_tipoacao        IN VARCHAR2               --> C - Consulta ou P - Processo de perda
                                       ,pr_vlemprst        IN crawepr.vlemprst%TYPE     --> Novo valor da proposta
                                       ,pr_vlpreemp        IN crawepr.vlpreemp%TYPE     --> Novo valor da prestação
                                       -- Parâmteros necessários para chamada da rotina de cálculo do rating
                                       ,pr_tpctrato        IN crapnrc.tpctrrat%TYPE  --> Tipo Contrato Rating
                                       ,pr_flgcalcu        IN INTEGER                --> Indicador de calculo
                                       ,pr_idseqttl        IN crapttl.idseqttl%TYPE  --> Sequencial do Titular
                                       ,pr_flgerlog        IN VARCHAR2               --> Identificador de geração de log
                                       ,pr_flghisto        IN INTEGER                --> Indicador se deve gerar historico
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

  PROCEDURE pc_processa_titulo_expirada(pr_cdcooper  IN crapdat.cdcooper%TYPE     --> Codigo da Cooperativa
                                       ,pr_nrdconta  IN crapass.nrdconta%TYPE     --> Numero da conta
                                       ,pr_nrctremp  IN crawepr.nrctremp%TYPE     --> Numero do contrato de emprestimo
                                       ,pr_dserro    OUT crapcri.dscritic%TYPE     --> OK - se processar e NOK - se erro
                                       ,pr_cdcritic  OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                       ,pr_dscritic  OUT crapcri.dscritic%TYPE);
END EMPR0015;
/
CREATE OR REPLACE PACKAGE BODY CECRED.EMPR0015 IS
  ---------------------------------------------------------------------------
  --
  --  Programa : EMPR0015
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
                                   ,pr_vlemprst        IN crawepr.vlemprst%TYPE     --> Novo valor da proposta
                                   ,pr_vlpreemp        IN crawepr.vlpreemp%TYPE     --> Novo valor da prestação
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
               c.vlempori,
               c.vlpreori,
               c.dsratori,
               c.rowid
          FROM
               crawepr c
         WHERE
               c.cdcooper = pr_cdcooper
           AND c.nrdconta = pr_nrdconta
           AND c.nrctremp = pr_nrctremp
           AND c.insitest > 0;
        
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
      pr_idpeapro := 0;

      --1ª Regra: Valor Emprestado
      --O Ayllos deverá pegar o valor da proposta alterada e subtrair do valor da proposta original aprovada,
      --essa subtração irá gerar uma diferença, o valor dessa diferença deverá ser verificado com o valor 
      --cadastrado no parâmetro “tolerância por valor de empréstimo”. Se a diferença entre as propostas
      --for menor ou igual ao parâmetro denominado “tolerância por valor de empréstimo” o Ayllos deverá
      --seguir com as demais verificações. Caso contrário a proposta irá perder a aprovação e não será 
      --necessário verificar a próxima regra.      
      FOR C1 in cr_crawepr LOOP
        vr_diferenca_valor:= pr_vlemprst - c1.vlempori;
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
        /*Regra para realizar a perda de aprovação por valor de emprestimo*/
        IF vr_diferenca_valor >  vr_vltolemp AND -- A diferenca é maior que o parametro tab089
           c1.vlempori > 0 AND -- O valor do emprestimo devera ser maior que zero
           c1.vlempori <> pr_vlemprst THEN -- devera ter alteracao do que esta na base com o que foi alterado
          pr_idpeapro := 1;
          -- Gerar log VERLOG
          IF pr_tipoacao = 'S' THEN
              GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                                  ,pr_cdoperad => pr_cdoperad
                                  ,pr_dscritic => ''
                                  ,pr_dsorigem => pr_dsorigem
                                  ,pr_dstransa => 'A proposta :'||pr_nrctremp
                                                ||' Perdeu a aprovação por Tolerância por valor de empréstimo'
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
          vr_diferenca_parcela:= 0;
          IF c1.vlpreori > 0 THEN
             vr_diferenca_parcela:= ((nvl(pr_vlpreemp,0)/nvl(c1.vlpreori,0))-1)*100;
          END IF;
          
          IF vr_diferenca_parcela > vr_pcaltpar AND -- A diferenca deve ser maior que esta na TAB089
             c1.vlpreori > 0 AND -- Valor prestação na base deve ser maior que zero
             c1.vlpreori <> pr_vlpreemp THEN -- Devera ter diferenca entre a base com o que foi alterado
            pr_idpeapro := 1;            
            -- Gerar Log VERLOG
            IF pr_tipoacao = 'S' THEN
              GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                                  ,pr_cdoperad => pr_cdoperad
                                  ,pr_dscritic => ''
                                  ,pr_dsorigem => pr_dsorigem
                                  ,pr_dstransa => 'A proposta :'||pr_nrctremp
                                                ||' Perdeu a aprovação por Alteração de parcela.'
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
                vr_dscritic:= 'Falha ao calcular rating sem tabela de erros EMPR0015.';
              ELSE
                vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
                vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
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
            -- Se não existir o rating original, não deverá validar a regra
            -- Porém, deverá validar se agora encontrou se sim, o sistema
            -- irá gravar no original este.   
            IF TRIM(c1.dsratori) IS NOT NULL OR 
               c1.dsratori <> ' ' THEN
              IF vr_rating > c1.dsratori THEN
                pr_idpeapro := 1;
                -- gerar Log 
                IF pr_tipoacao = 'S' THEN
                  GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                                      ,pr_cdoperad => pr_cdoperad
                                      ,pr_dscritic => ''
                                      ,pr_dsorigem => pr_dsorigem
                                      ,pr_dstransa => 'A proposta :'||pr_nrctremp
                                                    ||' Perdeu a aprovação por Alteração do Rating para pior.'
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
            ELSE 
              -- Se no momento da inclusão não havia rating e agora 
              IF vr_rating IS NOT NULL OR
                 vr_rating <> ' ' THEN
                BEGIN
                  UPDATE crawepr c
                     SET c.dsratori = vr_rating
                   WHERE c.cdcooper = pr_cdcooper
                     AND c.nrdconta = pr_nrdconta
                     AND c.nrctremp = pr_nrctremp;
                     /*c.rowid = c1.rowid;*/
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'Erro ao atualizar tabela crawepr rating. ' || SQLERRM;
                    --Sair do programa
                    RAISE vr_exc_erro;
                END;
              END IF; 
            END IF;
          END IF; 
        END IF;  
        -- Se não é consulta e chegou ao final do processo sem perder a aprovação, grava um log
        IF pr_idpeapro = 0 AND pr_tipoacao = 'S' THEN
          GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => ''
                              ,pr_dsorigem => pr_dsorigem
                              ,pr_dstransa => 'A proposta :'||pr_nrctremp
                                            ||' teve a sua aprovação mantida.'
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
         --
         IF pr_tipoacao = 'S' THEN
          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                    pr_nmdcampo => 'Valor original do empréstimo',
                                    pr_dsdadant => 'ND',
                                    pr_dsdadatu => c1.vlempori);
                                            
          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                    pr_nmdcampo => 'Valor Atual do empréstimo',
                                    pr_dsdadant => 'ND',
                                    pr_dsdadatu => pr_vlemprst);  
                                         
          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                    pr_nmdcampo => 'Diferença',
                                    pr_dsdadant => 'ND',
                                    pr_dsdadatu => to_char(nvl(vr_diferenca_valor,0),'FM999G999G990D00'));
                                            
          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                    pr_nmdcampo => 'Tolerância',
                                    pr_dsdadant => 'ND',
                                    pr_dsdadatu => nvl(vr_vltolemp,0));
                                            
          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                    pr_nmdcampo => 'Valor original da parcela',
                                    pr_dsdadant => 'ND',
                                    pr_dsdadatu => c1.vlpreori);

          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                    pr_nmdcampo => 'Valor atual da parcela',
                                    pr_dsdadant => 'ND',
                                    pr_dsdadatu => pr_vlpreemp);

          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                    pr_nmdcampo => '% da Diferença',
                                    pr_dsdadant => 'ND',
                                    pr_dsdadatu => to_char(nvl(vr_diferenca_parcela,0),'FM999G999G990D00'));

          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                    pr_nmdcampo => '% de Tolerância',
                                    pr_dsdadant => 'ND',
                                    pr_dsdadatu => to_char(nvl(vr_pcaltpar,0),'FM999G999G990D00'));

          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                    pr_nmdcampo => 'Rating original',
                                    pr_dsdadant => 'ND',
                                    pr_dsdadatu => c1.dsratori);

          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                    pr_nmdcampo => 'Rating atual',
                                    pr_dsdadant => 'ND',
                                    pr_dsdadatu => nvl(vr_rating,'ND'));

        END IF;
      END LOOP;
      IF pr_tipoacao = 'S' THEN
        COMMIT;
      END IF;
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
        pr_dscritic := 'Erro na procedure EMPR0015.pc_processa_perda_aprov: ' || SQLERRM;
    END;

  END pc_processa_perda_aprov;
---------------------------------------
  -- Chamar a pc_processa_perda_aprovacao por mensageria
  PROCEDURE pc_processa_perda_aprov_web(pr_nrdconta        IN crapass.nrdconta%TYPE  --> Numero da conta
                                       ,pr_nrctremp        IN crawepr.nrctremp%TYPE  --> Numero do contrato de emprestimo
                                       ,pr_tipoacao        IN VARCHAR2               --> C - Consulta ou P - Processo de perda
                                       ,pr_vlemprst        IN crawepr.vlemprst%TYPE     --> Novo valor da proposta
                                       ,pr_vlpreemp        IN crawepr.vlpreemp%TYPE     --> Novo valor da prestação
                                       -- Parâmteros necessários para chamada da rotina de cálculo do rating
                                       ,pr_tpctrato        IN crapnrc.tpctrrat%TYPE  --> Tipo Contrato Rating
                                       ,pr_flgcalcu        IN INTEGER                --> Indicador de calculo
                                       ,pr_idseqttl        IN crapttl.idseqttl%TYPE  --> Sequencial do Titular
                                       ,pr_flgerlog        IN VARCHAR2               --> Identificador de geração de log
                                       ,pr_flghisto        IN INTEGER                --> Indicador se deve gerar historico
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
    
    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_dsorigem VARCHAR2(1000);
    vr_flgcriar INTEGER:= 0; 
    
    -- Escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
    END;    
    
  BEGIN 
    
    pr_des_erro := 'OK';

    gene0001.pc_informa_acesso(pr_module => 'EMPR0002');
    
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
                            
    vr_dsorigem := gene0001.vr_vet_des_origens(vr_idorigem);                              
    
    EMPR0015.pc_processa_perda_aprov(pr_cdcooper => vr_cdcooper
                                    ,pr_nrdconta => pr_nrdconta
                                    ,pr_nrctremp => pr_nrctremp
                                    ,pr_tipoacao => pr_tipoacao
                                    ,pr_vlemprst => pr_vlemprst
                                    ,pr_vlpreemp => pr_vlpreemp
                                     -- Parâmteros necessários para chamada da rotina de cálculo do rating
                                    ,pr_cdagenci => vr_cdagenci
                                    ,pr_nrdcaixa => vr_nrdcaixa
                                    ,pr_cdoperad => vr_cdoperad
                                    ,pr_tpctrato => pr_tpctrato
                                    ,pr_flgcriar => vr_flgcriar
                                    ,pr_flgcalcu => pr_flgcalcu
                                    ,pr_idseqttl => pr_idseqttl
                                    ,pr_idorigem => vr_idorigem
                                    ,pr_nmdatela => vr_nmdatela 
                                    ,pr_flgerlog => pr_flgerlog
                                    ,pr_flghisto => pr_flghisto
                                    ,pr_dsorigem => vr_dsorigem
                                     --
                                    ,pr_idpeapro => vr_idpeapro
                                    ,pr_dserro   => vr_dserro
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic);
   
    -- Se houve o retorno de erro
    IF vr_dserro <> 'OK' THEN
      RAISE vr_exc_saida;
    END IF;
    
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root', pr_posicao => 0, pr_tag_nova => 'Dados', pr_tag_cont => null, pr_des_erro => vr_dscritic);
    
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'idpeapro', pr_tag_cont => vr_idpeapro, pr_des_erro => vr_dscritic);

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
      pr_dscritic := 'Erro geral pc_processa_perda_aprov_web: ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_processa_perda_aprov_web;

  PROCEDURE pc_processa_prop_empr_expirada(pr_cdcooper  IN crapdat.cdcooper%TYPE      --> Codigo da Cooperativa
                                          ,pr_nrdconta  IN crapass.nrdconta%TYPE      --> Numero da conta
                                          ,pr_nrctremp  IN crawepr.nrctremp%TYPE      --> Numero do contrato de emprestimo
                                          ,pr_dserro    OUT crapcri.dscritic%TYPE     --> OK - se processar e NOK - se erro
                                          ,pr_cdcritic  OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                          ,pr_dscritic  OUT crapcri.dscritic%TYPE) IS --> Erros do processo
  BEGIN
    /* .............................................................................

       Programa: pc_processa_prop_empr_expirada
       Sistema : Crédito - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Márcio(Mouts)
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
              w.dtaprova,
              w.nrctaav1,
              w.nrctaav2,
              w.rowid
          FROM
              crawepr w
         WHERE 
              w.cdcooper = p_cdcooper
          AND w.nrdconta = NVL(pr_nrdconta,w.nrdconta)
          AND w.nrctremp = NVL(pr_nrctremp,w.nrctremp)
          AND w.insitapr = 1 -- Aprovado 
          AND w.dtaprova > to_date('18/07/2018','dd/mm/yyyy') -- Data de inicio
          AND NOT EXISTS (SELECT 
                                1 
                            FROM 
                                crapepr cc 
                           WHERE
                                cc.cdcooper = w.cdcooper 
                            AND cc.nrdconta = w.nrdconta 
                            AND cc.nrctremp = w.nrctremp)          
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

      CURSOR cr_crapbpr_maq_equ(p_cdcooper IN crapcop.cdcooper%type,
                                p_nrdconta IN crapass.nrdconta%type,
                                p_nrctrpro IN crapbpr.nrctrpro%type) IS             
        SELECT  
              1 -- Existe Garantia de Máquinas e Equipamentos
          FROM
              crapbpr bpr
         WHERE 
              bpr.cdcooper = p_cdcooper
          AND bpr.nrdconta = p_nrdconta
          AND bpr.nrctrpro = p_nrctrpro -- Numero proposta contrato
          AND bpr.flgalien = 1  -- garantia alienada a proposta
          AND bpr.tpctrpro IN (90,99) -- Garantia
          AND dscatbem IN ('EQUIPAMENTO','MAQUINA DE COSTURA')
          AND ROWNUM = 1;           
          
      CURSOR cr_crapavt_terc(p_cdcooper IN crapcop.cdcooper%type,
                             p_nrdconta IN crapass.nrdconta%type,
                             p_nrctrpro IN crapbpr.nrctrpro%type) IS             
        SELECT  
              1 -- Existe Garantia de Avalista Terceiro
          FROM
              crapavt avt
         WHERE
              tpctrato = 1 -- Emprestimo
          AND avt.cdcooper = p_cdcooper
          AND avt.nrdconta = p_nrdconta
          AND avt.nrctremp = p_nrctrpro
          AND ROWNUM = 1;            

      CURSOR cr_crapavt_nao_terc(p_cdcooper IN crapcop.cdcooper%type,
                                 p_nrdconta IN crapass.nrdconta%type,
                                 p_nrctrpro IN crapbpr.nrctrpro%type) IS             
        SELECT  
              1 -- Existe Garantia de Avalista não terceiro (que tem conta na coop) 
          FROM 
              crapavl avl
         WHERE
              avl.cdcooper = p_cdcooper
          AND avl.nrdconta = p_nrdconta
          AND avl.NRCTRAVD = p_nrctrpro -- Numero do contrato avalisado.
          AND avl.tpctrato = 1 -- emprestimo            
          AND ROWNUM = 1;    

      CURSOR cr_aplicacao(p_cdcooper IN crapcop.cdcooper%type,
                          p_nrdconta IN crapass.nrdconta%type,
                          p_nrctrpro IN crapbpr.nrctrpro%type) IS             
        SELECT  
              1 -- Existe Aplicação Poupança
          FROM 
              tbgar_cobertura_operacao t
         WHERE
              t.cdcooper   = p_cdcooper
          AND t.nrdconta   = p_nrdconta
          AND t.nrcontrato = p_nrctrpro -- Numero do contrato
          AND t.tpcontrato = 90 -- emprestimo            
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
      vr_idencgar    NUMBER(1):= 0; -- Variável que define que encontrou garantia
      vr_qtdiaute    NUMBER(5):= 0; -- Guarda a quantidade de dias úteis entre a data de aprovação e a data atual
      
      pr_rw_crapdat btch0001.cr_crapdat%ROWTYPE;      

    BEGIN
      FOR rw_crapcop IN cr_crapcop LOOP -- Cursor de Cooperativas
        -- Busca a data do sistema
        OPEN btch0001.cr_crapdat(rw_crapcop.cdcooper);
        FETCH btch0001.cr_crapdat INTO pr_rw_crapdat;
        CLOSE btch0001.cr_crapdat;        
        
        -- Ler a TAB089 para identificar os dias de expiração para cada garantia.
        -- Com base nas garantias vinculadas a propostas, deverá ser feito uma busca no cadastro da tab089
        -- para encontrar os dias cadastrados no frame "PA - Prazo de validade da análise para efetivação"        
        vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => rw_crapcop.cdcooper
                                                 ,pr_nmsistem => 'CRED'
                                                 ,pr_tptabela => 'USUARI'
                                                 ,pr_cdempres => 11
                                                 ,pr_cdacesso => 'PAREMPREST'
                                                 ,pr_tpregist => 01);
          vr_qtdpaimo := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,73,3)),0); -- imóvel
          vr_qtdpaaut := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,77,3)),0); -- automóvel
          vr_qtdpaava := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,81,3)),0); -- avalista
          vr_qtdpaapl := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,85,3)),0); -- aplicação
          vr_qtdpasem := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,89,3)),0); -- sem garantia
          vr_qtdpameq := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,105,3)),0);-- máquinas e equipamentos
          
          FOR rw_crawepr IN cr_crawepr(rw_crapcop.cdcooper) LOOP -- Cursor de Empréstimos
            -- Inicia a variável com zero pois está dentro do loop
            vr_qtddiexp := 0;
            vr_idencgar := 0;            
            vr_qtdiaute := 0;
            -- Com base no retorno das propostas lidas deverá ser verificado se existem garantias, conforme abaixo:
            
            -- Garantia de Imóvel
            FOR rw_crapbpr_imovel IN cr_crapbpr_imovel(rw_crapcop.cdcooper,
                                                       rw_crawepr.nrdconta,
                                                       rw_crawepr.nrctremp) LOOP 
              vr_qtddiexp := vr_qtdpaimo;
              vr_idencgar := 1;
            END LOOP;-- Cursor de Garantia de Imóvel
            
            -- Garantia  de automóvel
            FOR rw_crapbpr_automovel IN cr_crapbpr_automovel(rw_crapcop.cdcooper,
                                                             rw_crawepr.nrdconta,
                                                             rw_crawepr.nrctremp) LOOP
              -- Verifica se a quantidade de dias para garantia é maior que a quantidade de dias da variável
              -- de dias de expiração, se for, atribuiu a quantidade de dias da garantia na variável
              IF vr_qtdpaaut > vr_qtddiexp THEN
                -- No caso de um contrato ter mais de uma garantia, considerar do cadastro tab089 o que tem a maior quantidade de dias;                
                vr_qtddiexp := vr_qtdpaaut;
              END IF;
              vr_idencgar := 1;              
            END LOOP;-- Cursor de Garantia  de automóvel

            -- Avalista terceiro
            FOR rw_crapavt_terc IN cr_crapavt_terc(rw_crapcop.cdcooper,
                                                   rw_crawepr.nrdconta,
                                                   rw_crawepr.nrctremp) LOOP
              -- Verifica se a quantidade de dias para garantia é maior que a quantidade de dias da variável
              -- de dias de expiração, se for, atribuiu a quantidade de dias da garantia na variável
              IF vr_qtdpaava > vr_qtddiexp THEN
                -- No caso de um contrato ter mais de uma garantia, considerar do cadastro tab089 o que tem a maior quantidade de dias;                
                vr_qtddiexp := vr_qtdpaava;
              END IF;
              vr_idencgar := 1;              
            END LOOP;-- Cursor de Avalista terceiro

            -- Avalista não terceiro
            /*FOR rw_crapavt_nao_terc IN cr_crapavt_nao_terc(rw_crapcop.cdcooper,
                                                           rw_crawepr.nrdconta,
                                                           rw_crawepr.nrctremp) LOOP*/
              -- Verifica se a quantidade de dias para garantia é maior que a quantidade de dias da variável
              -- de dias de expiração, se for, atribuiu a quantidade de dias da garantia na variável
            IF rw_crawepr.nrctaav1 > 0 OR rw_crawepr.nrctaav2 > 0 THEN
              IF vr_qtdpaava > vr_qtddiexp THEN
                -- No caso de um contrato ter mais de uma garantia, considerar do cadastro tab089 o que tem a maior quantidade de dias;                
                vr_qtddiexp := vr_qtdpaava;
              END IF;
              vr_idencgar := 1;              
            END IF;
            --END LOOP;-- Cursor de Avalista não terceiro
            
            -- Aplicação e poupança
            FOR rw_aplicacao IN cr_aplicacao(rw_crapcop.cdcooper,
                                             rw_crawepr.nrdconta,
                                             rw_crawepr.nrctremp) LOOP
              -- Verifica se a quantidade de dias para garantia é maior que a quantidade de dias da variável
              -- de dias de expiração, se for, atribuiu a quantidade de dias da garantia na variável
              IF vr_qtdpaapl > vr_qtddiexp THEN
                -- No caso de um contrato ter mais de uma garantia, considerar do cadastro tab089 o que tem a maior quantidade de dias;                
                vr_qtddiexp := vr_qtdpaapl;
              END IF;
              vr_idencgar := 1;              
            END LOOP;-- Aplicação e poupança
            
            --Máquins e Equipamentos
            FOR rw_crapbpr_maq_equ IN cr_crapbpr_maq_equ(rw_crapcop.cdcooper,
                                                         rw_crawepr.nrdconta,
                                                         rw_crawepr.nrctremp) LOOP
              -- Verifica se a quantidade de dias para garantia é maior que a quantidade de dias da variável
              -- de dias de expiração, se for, atribuiu a quantidade de dias da garantia na variável
              IF vr_qtdpameq > vr_qtddiexp THEN
                -- No caso de um contrato ter mais de uma garantia, considerar do cadastro tab089 o que tem a maior quantidade de dias;                
                vr_qtddiexp := vr_qtdpameq;
              END IF;
              vr_idencgar := 1;              
            END LOOP;-- Máquins e Equipamentos
                        
            -- No caso em que a proposta não tem garantias, o sistema deverá considerar somente o parâmetro da 
            -- tela tab089 "Operação sem garantia"
            IF vr_idencgar = 0 THEN
              vr_qtddiexp:= vr_qtdpasem;
            END IF;
            -- Verificar a quantidade de dias úteis entre a data de aprovação da proposta e a data atual
            vr_qtdiaute:= GENE0005.fn_calc_qtd_dias_uteis(rw_crapcop.cdcooper,
                                                          rw_crawepr.dtaprova,
                                                          pr_rw_crapdat.dtmvtolt);
            -- Se a quantidade de dias úteis entre a data de aprovação e a data atual
            -- for maior que a quantidade de dias de expiração, o sistema deverá realizar
            -- a alteração da situação da proposta para 5 - " expirada por decurso de prazo ".            
            IF vr_qtdiaute > vr_qtddiexp THEN
              BEGIN
                UPDATE
                     crawepr c
                   SET
                      c.insitapr = 0,   -- Decisao da proposta
                      c.cdopeapr = null,
                      c.dtaprova = null,
                      c.hraprova = 0,
                      c.insitest = 5    -- Situação da proposta - Nova situação "5 - expirada por decurso de prazo"       
                 WHERE
                      c.rowid LIKE rw_crawepr.rowid;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao atualizar tabela crawemp. ' || SQLERRM;
                  --Sair do programa
                  RAISE vr_exc_erro;
              END;
            END IF;
          END LOOP;-- Cursor de Empréstimos
      END LOOP;  -- Cursosr de Cooperativas
      -- Se chegou até o final sem erro retorna OK
      pr_dserro := 'OK';
      COMMIT;
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
        pr_dscritic := 'Erro na procedure EMPR0015.pc_processa_prop_empr_expirada: ' || SQLERRM;
    END;

  END pc_processa_prop_empr_expirada;

  PROCEDURE pc_processa_titulo_expirada(pr_cdcooper  IN crapdat.cdcooper%TYPE     --> Codigo da Cooperativa
                                       ,pr_nrdconta  IN crapass.nrdconta%TYPE     --> Numero da conta
                                       ,pr_nrctremp  IN crawepr.nrctremp%TYPE     --> Numero do contrato de emprestimo
                                       ,pr_dserro    OUT crapcri.dscritic%TYPE     --> OK - se processar e NOK - se erro
                                       ,pr_cdcritic  OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                       ,pr_dscritic  OUT crapcri.dscritic%TYPE) IS
     /* .............................................................................

       Programa: pc_processa_titulo_expirada
       Sistema : Crédito - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Rafael Muniz Monteiro
       Data    : julho/2018                         Ultima atualizacao: 

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para procesar as regras de expiração da proposta limite desconto título

       Alteracoes: 
    ............................................................................. */
    --    
    CURSOR cr_crapcop (prc_cdcooper IN crapcop.cdcooper%TYPE) IS 
      SELECT cop.cdcooper
        FROM crapcop cop
       WHERE cop.cdcooper = NVL(prc_cdcooper, cop.cdcooper)
         AND cop.cdcooper <> 3 -- Diferente de Ailos
         AND cop.flgativo = 1;  

    CURSOR cr_crawlim (prc_cdcooper crawlim.cdcooper%TYPE,
                       prc_nrdconta crawlim.nrdconta%TYPE,
                       prc_nrctrlim crawlim.nrctrlim%TYPE) IS 
      SELECT lim.nrdconta,
             lim.nrctrlim,
             lim.dtaprova,
             lim.rowid
        FROM crawlim lim
       WHERE lim.cdcooper = prc_cdcooper
         AND lim.nrdconta = nvl(prc_nrdconta, lim.nrdconta)
         AND lim.nrctrlim = nvl(prc_nrctrlim,lim.nrctrlim)
         AND lim.insitlim = 5 -- when 5 then 'APROVADA'
         AND lim.dtaprova > to_date('18/07/2018','dd/mm/yyyy') -- Data de inicio
         AND lim.insitapr IN (1,2,3) --when 1 then 'APROVADA AUTOMATICAMENTE' when 2 then 'APROVADA MANUAL' when 3 then 'APROVADA'
         AND NOT EXISTS (SELECT 1
                           FROM craplim plim
                          WHERE plim.cdcooper = lim.cdcooper
                            AND plim.nrdconta = lim.nrdconta
                            AND plim.nrctrlim = lim.nrctrlim
                           );  
    --
    CURSOR cr_avalista (prc_cdcooper crawlim.cdcooper%TYPE,
                        prc_nrdconta crawlim.nrdconta%TYPE,
                        prc_nrctrlim crawlim.nrctrlim%TYPE) IS
      -- Buscar os avalistas
      SELECT 1 existe
        FROM crawlim lim
       WHERE lim.cdcooper = prc_cdcooper
         AND lim.nrdconta = prc_nrdconta
         AND lim.nrctrlim = prc_nrctrlim
         AND (nvl(lim.nrctaav1,0) <> 0
           OR nvl(lim.nrctaav2,0) <> 0);  
    --
    CURSOR cr_aplicacao (prc_cdcooper crawlim.cdcooper%TYPE,
                         prc_nrdconta crawlim.nrdconta%TYPE,
                         prc_nrctrlim crawlim.nrctrlim%TYPE) IS
      -- Aplicação
      SELECT *
        FROM tbgar_cobertura_operacao tco
       WHERE tco.cdcooper = prc_cdcooper
         AND tco.nrdconta = prc_nrdconta
         AND tco.nrcontrato = prc_nrctrlim
         AND tco.tpcontrato = 3;  
    --
    -- Variaveis --
    vr_cdcooper    crapcop.cdcooper%TYPE;
    vr_nrdconta    crapass.nrdconta%TYPE;
    vr_nrctremp    crawepr.nrctremp%TYPE;
    vr_qtdpaava    NUMBER := 0;
    vr_qtdpaapl    NUMBER := 0;
    vr_qtdpasem    NUMBER := 0;
    vr_qtdiatab    NUMBER := 0;
    vr_dstextab    craptab.dstextab%TYPE;
    vr_qtdiaute    NUMBER(5):= 0; -- Guarda a quantidade de dias úteis entre a data de aprovação e a data atual
    vr_controle    NUMBER;
    --
    rw_crapdat     btch0001.cr_crapdat%rowtype;  
    --
    -- Variaveis Excecao
    vr_exc_erro    EXCEPTION;
    -- Variaveis Erro
    vr_cdcritic    INTEGER;
    vr_dscritic    VARCHAR2(4000);  

  BEGIN
    pr_dserro:= 'OK'; 
    vr_cdcooper := NULL;
    vr_nrdconta := NULL;
    vr_nrctremp := NULL;
    
    IF nvl(pr_cdcooper,0) > 0 THEN
      vr_cdcooper := pr_cdcooper;
    END IF;
    IF nvl(pr_nrdconta,0) > 0 THEN
      vr_nrdconta := pr_nrdconta;
    END IF;
    IF nvl(pr_nrctremp,0)> 0 THEN
      vr_nrctremp := pr_nrctremp;
    END IF;
    --
    -- Cursor cooperativa
    FOR rw_crapcop IN cr_crapcop(vr_cdcooper) LOOP
      --
      -- Buscar data do sistema
      OPEN btch0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      CLOSE btch0001.cr_crapdat;    
      
      vr_qtdpaava := 0;
      vr_qtdpaapl := 0;
      vr_qtdpasem := 0;
      
      -- Ler a TAB089 para identificar os dias de expiração para cada garantia.
      vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => rw_crapcop.cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'PAREMPREST'
                                               ,pr_tpregist => 01);
      vr_qtdpaava := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,109,3)),0);  
      vr_qtdpaapl := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,113,3)),0);  
      vr_qtdpasem := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,117,3)),0);      
      --
      -- Propostas de Limite Desconto Titulo
      FOR rw_crawlim IN cr_crawlim(rw_crapcop.cdcooper,
                                   vr_nrdconta,
                                   vr_nrctremp) LOOP

        vr_controle := 0;
        vr_qtdiatab := 0;
        -- Buscar se existe avalista      
        FOR rr_avalista IN cr_avalista (rw_crapcop.cdcooper,
                                        rw_crawlim.nrdconta,
                                        rw_crawlim.nrctrlim) LOOP
          vr_qtdiatab := vr_qtdpaava;
          vr_controle := 1;
        END LOOP; 
        -- Buscar aplicação
        FOR rw_aplicacao IN cr_aplicacao(rw_crapcop.cdcooper,
                                         rw_crawlim.nrdconta,
                                         rw_crawlim.nrctrlim) LOOP
          IF vr_qtdpaapl > vr_qtdiatab THEN
            vr_qtdiatab := vr_qtdpaapl;
          END IF;
          vr_controle := 1;
        END LOOP;
        
        IF vr_controle = 0 THEN
          vr_qtdiatab := vr_qtdpasem;
        END IF;
      
        -- Verificar a quantidade de dias úteis entre a data de aprovação da proposta e a data atual
        vr_qtdiaute:= GENE0005.fn_calc_qtd_dias_uteis(rw_crapcop.cdcooper,
                                                      rw_crawlim.dtaprova,
                                                      rw_crapdat.dtmvtolt);      
        --
        -- Data calculada conforme regras de garantia e tab089 maior que data atual sistema, recebe expiração
        IF vr_qtdiaute > vr_qtdiatab THEN
          BEGIN
            -- Realizar a expiração do contrato   
            UPDATE crawlim lim
               SET lim.insitlim = 8 --> 8 --> Expirada por decurso de prazo
                  ,lim.insitest = 0 --> 0 --> NAO ENVIADO
                  ,lim.insitapr = 0 --> 0 --> NAO ANALISADO
                  ,lim.cdopeapr = null
                  ,lim.dtaprova = null
                  ,lim.hraprova = 0 
             WHERE lim.rowid LIKE rw_crawlim.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar tabela crawlim - Expiração. ' || SQLERRM;
              --Sair do programa
              RAISE vr_exc_erro;           
          END;
           
        END IF;
      END LOOP;
    END LOOP;


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
    
  END pc_processa_titulo_expirada;



END EMPR0015;
/
