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
                                       
  PROCEDURE pc_executa_expiracao(pr_cdcooper  IN crapdat.cdcooper%TYPE     --> Codigo da Cooperativa
                                ,pr_nrdconta  IN crapass.nrdconta%TYPE     --> Numero da conta
                                ,pr_nrctremp  IN crawepr.nrctremp%TYPE     --> Numero do contrato de emprestimo
                                ,pr_dserro    OUT crapcri.dscritic%TYPE     --> OK - se processar e NOK - se erro
                                ,pr_cdcritic  OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                ,pr_dscritic  OUT crapcri.dscritic%TYPE); 
                                   
  PROCEDURE pc_gerar_evento_email (pr_cdcooper  IN crapdat.cdcooper%TYPE     --> Codigo da Cooperativa
                                  ,pr_nrdconta  IN crapass.nrdconta%TYPE     --> Numero da conta
                                  ,pr_nrctremp  IN crawepr.nrctremp%TYPE     --> Numero do contrato de emprestimo
                                  ,pr_dserro    OUT crapcri.dscritic%TYPE     --> OK - se processar e NOK - se erro
                                  ,pr_cdcritic  OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                  ,pr_dscritic  OUT crapcri.dscritic%TYPE);

  PROCEDURE pc_valida_email_proposta (pr_cdcooper  IN crapdat.cdcooper%TYPE      --> Codigo da Cooperativa
                                     ,pr_nrdconta  IN crapass.nrdconta%TYPE      --> Numero da conta
                                     ,pr_nrctremp  IN crawepr.nrctremp%TYPE      --> Numero do contrato de emprestimo
                                     ,pr_flgenvia  OUT NUMBER                   --> false não envia email / true envia email                                     
                                     ,pr_retxml    OUT NOCOPY xmltype            --> Arquivo de retorno do XML
                                     ,pr_cdcritic  OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                     ,pr_dscritic  OUT crapcri.dscritic%TYPE);                                  

  PROCEDURE pc_aval_perde_aprov (pr_cdcooper  IN crapdat.cdcooper%TYPE      --> Codigo da Cooperativa
                                ,pr_avtperda  OUT NUMBER  
                                ,pr_vlperavt  OUT NUMBER  
                                ,pr_cdcritic  OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                ,pr_dscritic  OUT crapcri.dscritic%TYPE);  

  PROCEDURE pc_valida_perda_aprov_proposta(pr_cdcooper        IN crapdat.cdcooper%TYPE     --> Codigo da Cooperativa
                                          ,pr_cdoperad        IN crapnrc.cdoperad%TYPE      --> Codigo Operador                                                                          
                                          ,pr_nmdatela        IN craptel.nmdatela%TYPE      --> Nome da tela
                                          ,pr_nrdconta        IN crapass.nrdconta%TYPE      --> Numero da conta
                                          ,pr_idseqttl        IN crapttl.idseqttl%TYPE      --> Sequencial do Titular
                                          ,pr_nrctremp        IN crawepr.nrctremp%TYPE      --> Numero do contrato de emprestimo
                                          ,pr_dsorigem        IN craplgm.dsorigem%TYPE      --> Descrição da origem
                                           /** ---------------------- Dados para a crawepr -------------------- */
                                          ,pr_qtpreemp        IN crawepr.qtpreemp%TYPE      --> quantidade de prestacoes do emprestimo. 
                                          ,pr_dsnivris        IN crawepr.dsnivris%TYPE      -- risco melhora  
                                          ,pr_cdlcremp        IN crawepr.cdlcremp%TYPE      -- codigo da linha de credito do emprestimo. 
                                          ,pr_cdfinemp        IN crawepr.cdfinemp%TYPE      -- codigo da finalidade do emprestimo. 
                                          ,pr_qtdialib        IN crawepr.qtdialib%TYPE      -- numero de dias para liberacao do emprestimo. 
                                          ,pr_flgimpnp        IN crawepr.flgimpnp%TYPE      -- emissao de nota promissoria. 
                                          ,pr_percetop        IN crawepr.percetop%TYPE      -- percentual do cet nas operacoes. 
                                          ,pr_idquapro        IN crawepr.idquapro%TYPE      -- identificacao da qualificacao da operacao (proposta). 
                                          ,pr_dtdpagto        IN crawepr.dtdpagto%TYPE      -- data do pagamento da primeira prestacao. 
                                          ,pr_qtpromis        IN crawepr.qtpromis%TYPE      -- quantidade promissorias a serem emitidas. 
                                          ,pr_flgpagto        IN crawepr.flgpagto%TYPE      -- Data do pagamento
                                          ,pr_dsctrliq        IN varchar2                   -- Contratos sendo liquidados
                                          ,pr_idcarenc        IN crawepr.idcarenc%TYPE      -- identificador da carencia para posfixado 
                                          ,pr_dtcarenc        IN crawepr.dtcarenc%TYPE      -- data da carencia para posfixado  
                                           /** ------- Dados para dados do Rating e do Banco central ---------- */                      
                                          ,pr_nrgarope        IN crapprp.nrgarope%TYPE       --numero da garantia da operacao 
                                          ,pr_nrperger        IN crapprp.nrperger%TYPE       --percepcao geral com relacao a empresa (rating) 
                                          ,pr_dtcnsspc        IN crapprp.dtcnsspc%TYPE       --data da consulta ao spc. 
                                          ,pr_dtdrisco        IN crapprp.dtdrisco%TYPE       --data de entrada na central de risco. 
                                          ,pr_vltotsfn        IN crapprp.vltotsfn%TYPE       --valor total sfn exceto na cooperativa 
                                          ,pr_qtopescr        IN crapprp.qtopescr%TYPE       --quantidade de operacoes na central de risco scr. 
                                          ,pr_qtifoper        IN crapprp.qtifoper%TYPE       --quantidade de instituicoes financeiras que o cooperado ja possui operacao. 
                                          ,pr_nrliquid        IN crapprp.nrliquid%TYPE       --numero do contrato do limite credito ou adp que esta sendo liquidado 
                                          ,pr_vlopescr        IN crapprp.vlopescr%TYPE       --valor das operacoes vencidas na central de risco scr. 
                                          ,pr_vlrpreju        IN crapprp.vlrpreju%TYPE       --valor do prejuizo fora da cooperativa. 
                                          ,pr_nrpatlvr        IN crapprp.nrpatlvr%TYPE       --sequencia do item relativo ao patrimonio pessoal livre do endividamento (rating) 
                                          ,pr_dtoutspc        IN crapprp.dtoutspc%TYPE       --contem a data da consulta do conjuge / seg. titular ao spc. 
                                          ,pr_dtoutris        IN crapprp.dtoutris%TYPE       --contem a data da consulta na central de risco para o conjuge / seg. titular. 
                                          ,pr_vlsfnout        IN crapprp.vlsfnout%TYPE       --contem o endividamento do conjuge ou do 2. titular. 
                                          /** ---------------- Dados Salario/Faturamento -------------------- **/
                                          ,pr_vlsalari        IN crapprp.vlsalari%TYPE       --valor do salario do associado. 
                                          ,pr_vloutras        IN crapprp.vloutras%TYPE       --valor das outras rendas. 
                                          ,pr_vlalugue        IN crapprp.vlalugue%TYPE       --valor do aluguel. 
                                          ,pr_vlsalcon        IN crapprp.vlsalcon%TYPE       --valor do salario do conjuge. 
                                          ,pr_nmempcje        IN crapprp.nmempcje%TYPE       --nome da empresa onde o conjuge trabalha. 
                                          ,pr_flgdocje        IN crapprp.flgdocje%TYPE       --conjuge co-responsavel. 
                                          ,pr_nrctacje        IN crapprp.nrctacje%TYPE       --numero da conta do conjuge. 
                                          ,pr_nrcpfcje        IN crapprp.nrcpfcje%TYPE       --numero do cpf do conjuge do associado. 
                                          ,pr_vlmedfat        IN crapprp.vlmedfat%TYPE       --valor medio do faturamento bruto mensal. 
                                          ,pr_dsdfinan        IN varchar2                    --Faturamento em casp de pessoa física
                                          ,pr_dsdrendi        IN varchar2                    --Rendimentos
                                          ,pr_dsjusren        IN varchar2                    --Justificativa rendimento
                                          ,pr_idfiniof        IN crawepr.idfiniof%TYPE       --Indicador finaciamento de IOF
                                          --
                                          ,pr_idpeapro        OUT INTEGER                   --> 0 - Não perdeu aprovação e 1 - Perdeu aprovação
                                          ,pr_dserro          OUT crapcri.dscritic%TYPE     --> OK - se processar e NOK - se erro
                                          ,pr_cdcritic        OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                          ,pr_dscritic        OUT crapcri.dscritic%TYPE); --> Descricao da critica                                                                                      
  function zeroToNull(p_valor in number) return varchar2;
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
  -- Alteracoes: Incluido mascara para formatar valores para VERLOG com duas casas decimais - Rubens Lima - Mouts - 30/01/2019
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
           AND c.insitest > 0
           AND c.insitapr = 1;
        
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
                                    pr_dsdadatu => to_char(nvl(c1.vlempori,0),'FM999G999G990D00'));
                                            
          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                    pr_nmdcampo => 'Valor Atual do empréstimo',
                                    pr_dsdadant => 'ND',
                                    pr_dsdadatu => to_char(nvl(pr_vlemprst,0),'FM999G999G990D00'));
                                         
          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                    pr_nmdcampo => 'Diferença',
                                    pr_dsdadant => 'ND',
                                    pr_dsdadatu => to_char(nvl(vr_diferenca_valor,0),'FM999G999G990D00'));
                                            
          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                    pr_nmdcampo => 'Tolerância',
                                    pr_dsdadant => 'ND',
                                    pr_dsdadatu => to_char(nvl(vr_vltolemp,0),'FM999G999G990D00'));
                                            
          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                    pr_nmdcampo => 'Valor original da parcela',
                                    pr_dsdadant => 'ND',
                                    pr_dsdadatu => to_char(nvl(c1.vlpreori,0),'FM999G999G990D00'));

          GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                    pr_nmdcampo => 'Valor atual da parcela',
                                    pr_dsdadant => 'ND',
                                    pr_dsdadatu => to_char(nvl(pr_vlpreemp,0),'FM999G999G990D00'));

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
       Data    : 07/2018                         Ultima atualizacao: 19/10/2018

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para procesar as regras de expiração da proposta de crédito

       Alteracoes: 19/10/2018 - P442 - Troca de checagem fixa por funcão para garantir se bem é alienável (Marcos-Envolti)
				   
                   Inclusão de GALPAO para garantia de imovel
                   05/12/2018 - Sprint 7 - Paulo Martins (Mouts)
                   
                   06/09/2019 - P438 Inclusão da origem 10 para considerar Canal Digital (Douglas Pagel / AMcom)
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
          AND w.insitapr = 1 -- Decisao Aprovado 
          AND w.dtaprova > to_date('14/08/2018','dd/mm/yyyy') -- Data de inicio
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
          AND upper(dscatbem) IN ('TERRENO','APARTAMENTO','CASA','GALPAO')
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
          AND grvm0001.fn_valida_categoria_alienavel(bpr.dscatbem) = 'S'
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
          AND upper(dscatbem) IN ('EQUIPAMENTO','MAQUINA DE COSTURA', 'MAQUINA E EQUIPAMENTO')
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
      vr_qtdiacor    NUMBER(5):= 0; -- Guarda a quantidade de dias CORRIDOS entre a data de aprovação e a data atual
      
      vr_qtdibaut    INTEGER :=0;
      vr_qtdibapl    INTEGER :=0;
      vr_qtdibsem    INTEGER :=0;
      vr_cdorigem    crawepr.cdorigem%TYPE;
      vr_setibaut    BOOLEAN := FALSE;  -- indica se achou qtd de dias em que expira proposta para garantia automovel do conta online
      vr_setibapl    BOOLEAN := FALSE;  -- indica se achou qtd de dias em que expira proposta para garantia apliação do conta online
      vr_setibsem    BOOLEAN := FALSE;  -- indica se achou qtd de dias em que expira proposta para sem garantia do conta online

      rw_crapdat btch0001.cr_crapdat%ROWTYPE;      

      FUNCTION get_cdorigem(pr_cdcooper crawepr.cdcooper%TYPE
                           ,pr_nrdconta crawepr.nrdconta%TYPE
                           ,pr_nrctremp crawepr.nrctremp%TYPE) RETURN crawepr.cdorigem%TYPE IS
       CURSOR c_origem IS
         SELECT cwep.cdorigem
           FROM crawepr cwep      
          WHERE cwep.cdcooper = pr_cdcooper
            AND cwep.nrdconta = pr_nrdconta
            AND cwep.nrctremp = pr_nrctremp;
         vcd_origem crawepr.cdorigem%TYPE;
         
       BEGIN
          OPEN c_origem;
          FETCH c_origem INTO vcd_origem;
          CLOSE c_origem;      
          RETURN nvl(vcd_origem,-99);
       EXCEPTION WHEN OTHERS
         THEN RETURN -99;   
      END get_cdorigem;
      

    BEGIN
      FOR rw_crapcop IN cr_crapcop LOOP -- Cursor de Cooperativas
        -- Busca a data do sistema
        OPEN btch0001.cr_crapdat(rw_crapcop.cdcooper);
        FETCH btch0001.cr_crapdat INTO rw_crapdat;
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
            vr_qtdiacor := 0;
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
              --
              vr_cdorigem := get_cdorigem(rw_crapcop.cdcooper,rw_crawepr.nrdconta,rw_crawepr.nrctremp); -- P438              
              vr_qtdibaut := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,93,3)),0);  -- automóvel -- P438
              vr_setibaut := FALSE; -- P438
              IF vr_cdorigem in (3,10) AND vr_qtdibaut > 0 -- P438
               THEN                
                 IF vr_qtdibaut > vr_qtddiexp THEN   -- P438                  
                    vr_qtddiexp := vr_qtdibaut; -- P438
                    vr_setibaut := TRUE; -- P438
                 END IF;
              END IF; -- P438
              --
              -- Verifica se a quantidade de dias para garantia é maior que a quantidade de dias da variável
              -- de dias de expiração, se for, atribuiu a quantidade de dias da garantia na variável
              IF vr_qtdpaaut > vr_qtddiexp AND NOT(vr_setibaut) THEN -- P438 THEN
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
              --
              vr_cdorigem := get_cdorigem(rw_crapcop.cdcooper,rw_crawepr.nrdconta,rw_crawepr.nrctremp); -- P438
              vr_qtdibapl := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,97,3)),0);  -- aplicação oriunda conta online -- P438
              vr_setibapl := FALSE; -- P438
              IF vr_cdorigem in (3,10) AND vr_qtdibaut > 0 -- P438
               THEN                
                 IF vr_qtdibapl > vr_qtddiexp THEN -- P438
                    vr_qtddiexp := vr_qtdibapl; -- P438
                    vr_setibapl := TRUE; -- P438
                 END IF;              
              END IF; 
              --
              -- Verifica se a quantidade de dias para garantia é maior que a quantidade de dias da variável
              -- de dias de expiração, se for, atribuiu a quantidade de dias da garantia na variável
              IF vr_qtdpaapl > vr_qtddiexp AND NOT(vr_setibapl) THEN
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
                        
            vr_cdorigem := get_cdorigem(rw_crapcop.cdcooper,rw_crawepr.nrdconta,rw_crawepr.nrctremp); -- P438
            vr_qtdibsem := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,101,3)),0); -- sem garantia oriunda conta online  -- P438
             
            vr_setibsem := FALSE; -- P438
            IF vr_cdorigem in (3,10) AND vr_idencgar = 0 THEN -- P438
              vr_qtddiexp := vr_qtdibsem; -- P438
              vr_setibsem := TRUE; -- P438
            END IF;  
                        
            -- No caso em que a proposta não tem garantias, o sistema deverá considerar somente o parâmetro da 
            -- tela tab089 "Operação sem garantia"
            IF vr_idencgar = 0 AND NOT(vr_setibsem) THEN
              vr_qtddiexp:= vr_qtdpasem;
            END IF;
            -- Verificar a quantidade de dias CORRIDOS entre a data de aprovação da proposta e a data atual
            vr_qtdiacor:= rw_crapdat.dtmvtolt - rw_crawepr.dtaprova;
            
            -- Se a quantidade de dias úteis entre a data de aprovação e a data atual
            -- for maior que a quantidade de dias de expiração, o sistema deverá realizar
            -- a alteração da situação da proposta para 5 - " expirada por decurso de prazo ".            
            IF vr_qtdiacor >= vr_qtddiexp THEN
              BEGIN
                UPDATE
                     crawepr c
                   SET
                      c.insitapr = 0,   -- Decisao da proposta
                      c.cdopeapr = null,
                      c.dtaprova = null,
                      c.hraprova = 0,
                      c.insitest = 5    -- Situação da proposta - Nova situação "5 - expirada por decurso de prazo"       
                     ,c.dtexpira = rw_crapdat.dtmvtolt
                 WHERE
                      c.rowid = rw_crawepr.rowid;
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
         AND lim.dtaprova > to_date('14/08/2018','dd/mm/yyyy') -- Data de inicio
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
    vr_qtdiacor    NUMBER(5):= 0; -- Guarda a quantidade de CORRIDOS úteis entre a data de aprovação e a data atual
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
    IF nvl(pr_nrdconta,0) > 0 AND 
       nvl(pr_cdcooper,0) > 0 THEN
      vr_nrdconta := pr_nrdconta;
    END IF;
    IF nvl(pr_nrctremp,0) > 0 AND 
       nvl(pr_nrdconta,0) > 0 AND 
       nvl(pr_cdcooper,0) > 0 THEN
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
        vr_qtdiacor:= rw_crapdat.dtmvtolt - rw_crawlim.dtaprova;
        --
        -- Data calculada conforme regras de garantia e tab089 maior que data atual sistema, recebe expiração
        IF vr_qtdiacor >= vr_qtdiatab THEN
          BEGIN
            -- Realizar a expiração do contrato   
            UPDATE crawlim lim
               SET lim.insitlim = 8 --> 8 --> Expirada por decurso de prazo
                  ,lim.insitest = 0 --> 0 --> NAO ENVIADO
                  ,lim.insitapr = 0 --> 0 --> NAO ANALISADO
                  ,lim.cdopeapr = null
                  ,lim.dtaprova = null
                  ,lim.hraprova = 0 
                  ,lim.dtexpira = rw_crapdat.dtmvtolt
             WHERE lim.rowid = rw_crawlim.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar tabela crawlim - Expiração. ' || SQLERRM;
              --Sair do programa
              RAISE vr_exc_erro;           
          END;
          
          COMMIT;
          
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
      pr_dscritic := 'Erro na procedure EMPR0012.pc_processa_titulo_expirada: ' || SQLERRM;
    
  END pc_processa_titulo_expirada;

  PROCEDURE pc_executa_expiracao(pr_cdcooper  IN crapdat.cdcooper%TYPE     --> Codigo da Cooperativa
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
       Data    : Agosto/2018                         Ultima atualizacao: 
     
       Dados referentes ao programa:
      
       Frequencia: Sempre que for chamado.
     
       Objetivo  : Procedure para chamar as expirações da proposta de empréstimo e limite 
                   desconto título

       Alteracoes: 
    ............................................................................. */         
    vr_cdcooper  crapdat.cdcooper%TYPE;
    vr_nrdconta  crapass.nrdconta%TYPE;
    vr_nrctremp  crawepr.nrctremp%TYPE;
    vr_dserro    crapcri.dscritic%TYPE;     --> OK - se processar e NOK - se erro
    vr_cdcritic  crapcri.cdcritic%TYPE;     --> Codigo da critica
    vr_dscritic  crapcri.dscritic%TYPE;    

    -- Variaveis Excecao
    vr_exc_erro    EXCEPTION;    
                           
  BEGIN
    -- Inicializar variaveis 
    vr_cdcooper := NULL; 
    vr_nrdconta := NULL;
    vr_nrctremp := NULL;
    vr_dserro   := 'OK';
    vr_cdcritic := NULL;
    vr_dscritic := NULL;
    
    -- tratar parametros
    IF nvl(pr_cdcooper,0) > 0 THEN
      vr_cdcooper := pr_cdcooper;
    END IF;
    
    IF nvl(pr_nrdconta,0) > 0 AND 
       nvl(pr_cdcooper,0) > 0 THEN
      vr_nrdconta := pr_nrdconta;
    END IF;
    
    IF nvl(pr_nrctremp,0) > 0 AND 
       nvl(pr_nrdconta,0) > 0 AND 
       nvl(pr_cdcooper,0) > 0 THEN
      vr_nrctremp := pr_nrctremp;    
    END IF;
    --
    -- Processar a expiração de proposta de emprestimo
    EMPR0015.pc_processa_prop_empr_expirada(pr_cdcooper => vr_cdcooper,
                                            pr_nrdconta => vr_nrdconta,
                                            pr_nrctremp => vr_nrctremp,
                                            pr_dserro   => vr_dserro,
                                            pr_cdcritic => vr_cdcritic,
                                            pr_dscritic => vr_dscritic);
    IF nvl(vr_dserro,'OK') <> 'OK' THEN
      RAISE vr_exc_erro;
    END IF;
    --
    -- Processar a expiração Limite Desconto Título
    EMPR0015.pc_processa_titulo_expirada(pr_cdcooper => vr_cdcooper,
                                         pr_nrdconta => vr_nrdconta,
                                         pr_nrctremp => vr_nrctremp,
                                         pr_dserro   => vr_dserro,
                                         pr_cdcritic => vr_cdcritic,
                                         pr_dscritic => vr_dscritic);
    IF nvl(vr_dserro,'OK') <> 'OK' THEN
      RAISE vr_exc_erro;
    END IF;                                            
    
  
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
      pr_dscritic := 'Erro na procedure EMPR0012.pc_executa_expiracao: ' || SQLERRM;  
  END pc_executa_expiracao; 

  PROCEDURE pc_gerar_evento_email (pr_cdcooper  IN crapdat.cdcooper%TYPE     --> Codigo da Cooperativa
                                  ,pr_nrdconta  IN crapass.nrdconta%TYPE     --> Numero da conta
                                  ,pr_nrctremp  IN crawepr.nrctremp%TYPE     --> Numero do contrato de emprestimo
                                  ,pr_dserro    OUT crapcri.dscritic%TYPE     --> OK - se processar e NOK - se erro
                                  ,pr_cdcritic  OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                  ,pr_dscritic  OUT crapcri.dscritic%TYPE) IS
  /* .............................................................................

       Programa: pc_gerar_evento_email
       Sistema : Crédito - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Márcio(Mouts)
       Data    : 08/2018                         Ultima atualizacao: 

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para procesar as regras de geração de e-mail

       Alteracoes: 
    ............................................................................. */                                  
  
    CURSOR cr_crapcop IS
      SELECT *
        FROM crapcop cop
       WHERE cop.cdcooper = nvl(pr_cdcooper, cop.cdcooper)
         AND cop.cdcooper <> 3
         AND cop.flgativo = 1
      ORDER BY
              cop.cdcooper; 
              
    CURSOR cr_crawepr (prc_cdcooper crawepr.cdcooper%TYPE,
                       prc_nrdconta crawepr.nrdconta%TYPE,
                       prc_nrctremp crawepr.nrctremp%TYPE) IS
      SELECT epr.cdcooper,
             epr.nrdconta,
             epr.nrctremp,
             epr.dtaprova,
             epr.rowid
        FROM crawepr epr,
             crapope c,
             tbcadast_email_proposta t
       WHERE epr.cdcooper = prc_cdcooper
         AND epr.nrdconta = nvl(prc_nrdconta, epr.nrdconta)
         AND epr.nrctremp = nvl(prc_nrctremp,epr.nrctremp)       
         AND epr.insitest = 3 -- Situacao Analise Finalizada
         AND epr.insitapr = 1 -- Decisao aprovada
         AND epr.dtaprova IS NOT NULL  -- Ter data de 
         AND epr.cdcooper = c.cdcooper
         AND epr.cdopeste = c.cdoperad
         AND TRIM(c.dsdemail) is not null
         AND NOT EXISTS (SELECT 1 
                           FROM crapepr epr2
                          WHERE epr2.cdcooper = epr.cdcooper
                            AND epr2.nrdconta = epr.nrdconta
                            AND epr2.nrctremp = epr.nrctremp)
         AND t.cdcooper  = epr.cdcooper
         AND t.tpproduto = 1 -- Emprestimo/financiamento
         AND t.idativo   = 1 -- ativo                            
         AND(
             (epr.dtulteml is null     AND trunc(sysdate) - trunc(epr.dtaprova) >= t.qt_periodicidade) 
           OR(epr.dtulteml is not null AND trunc(sysdate) - trunc(epr.dtulteml) >= t.qt_periodicidade)
             )         ;
                            
    CURSOR cr_email_proposta(pr_cdcooper  IN tbcadast_email_proposta.cdcooper%TYPE) IS
      SELECT t.qt_envio
        FROM tbcadast_email_proposta t
       WHERE t.cdcooper  = pr_cdcooper
         AND t.tpproduto = 1
         AND t.idativo   = 1;                            

    rw_email_proposta cr_email_proposta%ROWTYPE;
                                
    -- Variaveis Excecao
    vr_exc_erro           EXCEPTION;

    -- Variaveis Erro
    vr_cdcritic              INTEGER;
    vr_dscritic              VARCHAR2(4000);
      
    --Variáveis locais
    vr_cdcooper        crapcop.cdcooper%TYPE;
    vr_nrdconta        crapass.nrdconta%TYPE;
    vr_nrctremp        crawepr.nrctremp%TYPE;    
    vr_seg_envio       INTEGER     :=28800; -- O Cálculo será feito em segundos - 28800 é 08:00:00 h
    vr_tempo_intervalo INTEGER     :=0;
    vr_qt_envio       tbcadast_email_proposta.qt_envio%type;
    vr_hora_envio      VARCHAR2(9);
    rw_crapdat         btch0001.cr_crapdat%ROWTYPE;                             
    vr_idevento        tbgen_evento_soa.idevento%type;
    
    -- Variáveis para armazenar as informações em XML
    vr_des_xml         CLOB;
    vr_texto_completo  VARCHAR2(32600);      
  BEGIN
    pr_dserro := 'OK';
    vr_cdcooper := NULL;
    vr_nrdconta := NULL;
    vr_nrctremp := NULL;
    
    IF nvl(pr_cdcooper,0) > 0 THEN
      vr_cdcooper := pr_cdcooper;
    END IF;
    IF nvl(pr_nrdconta,0) > 0 AND 
       nvl(pr_cdcooper,0) > 0 THEN
      vr_nrdconta := pr_nrdconta;
    END IF;
    IF nvl(pr_nrctremp,0) > 0 AND 
       nvl(pr_nrdconta,0) > 0 AND 
       nvl(pr_cdcooper,0) > 0 THEN
      vr_nrctremp := pr_nrctremp;
    END IF;    

    FOR rw_crapcop IN cr_crapcop LOOP -- Cursor de Cooperativas
       
      -- Buscar Parâmetros de envio do e-mail
      OPEN cr_email_proposta(rw_crapcop.cdcooper);
      FETCH cr_email_proposta INTO rw_email_proposta;
		
      -- Se não existe
      IF cr_email_proposta%NOTFOUND THEN
        CLOSE cr_email_proposta;         
      ELSE
        CLOSE cr_email_proposta;         
        -- Calcular a cada quantos segundos deve enviar um e-mail
        -- O horário pré-definido para envio do e-mail é das 08:00 as 18:00, ou seja, 10 horas (36000 segundos) para envio
        vr_tempo_intervalo:= 36000/rw_email_proposta.qt_envio;
        
        FOR rw_crawepr IN cr_crawepr(rw_crapcop.cdcooper,
                                     vr_nrdconta,
                                     vr_nrctremp) LOOP -- Cursor de Empréstimos
          vr_qt_envio :=0;          
          vr_seg_envio:=28800;
          -- Incluir os eventos de acordo com a quantidade de envios cadastrada
          WHILE vr_qt_envio < rw_email_proposta.qt_envio LOOP
            vr_hora_envio := cecred.gene0002.fn_calc_hora(pr_segundos => vr_seg_envio);
            -- inserir os eventos
            soap0003.pc_gerar_evento_soa(pr_cdcooper               => rw_crawepr.cdcooper
                                        ,pr_nrdconta               => rw_crawepr.nrdconta
                                        ,pr_nrctrprp               => rw_crawepr.nrctremp
                                        ,pr_tpevento               => 'LEMBRETE_EFETIVACAO'
                                        ,pr_tproduto_evento        => 'CREDITO'
                                        ,pr_tpoperacao             => 'EMAIL'
                                        ,pr_dhoperacao             => to_date(to_char(sysdate,'DD/MM/RRRR') ||' '||vr_hora_envio,'DD/MM/RRRR HH24:MI:SS')
                                        ,pr_dsconteudo_requisicao  => vr_des_xml
                                        ,pr_idevento               => vr_idevento
                                        ,pr_dscritic               => vr_dscritic);
            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;
            vr_qt_envio := vr_qt_envio + 1;
          vr_seg_envio:= vr_seg_envio + vr_tempo_intervalo;
        END LOOP;
        IF vr_qt_envio > 0 THEN
          BEGIN
            UPDATE 
                  crawepr c
            SET  
                  c.dtulteml = sysdate
            WHERE
                  c.rowid = rw_crawepr.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar tabela crawepr - Data de envio do último E-mail. ' || SQLERRM;
              --Sair do programa
              RAISE vr_exc_erro;           
          END;                
        END IF;            
      END LOOP;-- Cursor de Empréstimos
      END IF; -- Tem parâmetro de e-mail
    END LOOP;  -- Cursor de Cooperativas
    
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
      rollback;
              
    WHEN OTHERS THEN
      pr_dserro:= 'NOK';
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na procedure EMPR0015.pc_gerar_evento_email: ' || SQLERRM;
      rollback;  
  END pc_gerar_evento_email; 

  PROCEDURE pc_valida_email_proposta (pr_cdcooper  IN crapdat.cdcooper%TYPE      --> Codigo da Cooperativa
                                     ,pr_nrdconta  IN crapass.nrdconta%TYPE      --> Numero da conta
                                     ,pr_nrctremp  IN crawepr.nrctremp%TYPE      --> Numero do contrato de emprestimo
                                     ,pr_flgenvia  OUT NUMBER                    --> 0 não envia email / 1 envia email
                                     ,pr_retxml    OUT NOCOPY xmltype            --> Arquivo de retorno do XML
                                     ,pr_cdcritic  OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                     ,pr_dscritic  OUT crapcri.dscritic%TYPE) IS
   /* .............................................................................

       Programa: pc_valida_push_proposta
       Sistema : Crédito - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Rafael(Mouts)
       Data    : 08/2018                         Ultima atualizacao: 

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para procesar as regras de geração de e-mail

       Alteracoes: 
    ............................................................................. */   
    CURSOR cr_proposta_efetivada IS    
      SELECT epr2.rowid 
        FROM crapepr epr2
       WHERE epr2.cdcooper = pr_cdcooper
         AND epr2.nrdconta = pr_nrdconta
         AND epr2.nrctremp = pr_nrctremp;

    rw_proposta_efetivada cr_proposta_efetivada%ROWTYPE;
    
    CURSOR cr_crawepr IS
      SELECT epr.insitest, -- 3 -- Situacao Analise Finalizada
             epr.insitapr, -- 1 -- Decisao aprovada
             epr.dtaprova, -- IS NOT NULL
             epr.rowid,
             c.dsdemail,
             a.nmprimtl,
             to_char(epr.vlemprst,'999,999,999,990.00') vlemprst,
             to_char(epr.dtaprova, 'DD/MM/YYYY') dtaprovaimp,
            trunc(sysdate)-trunc(epr.dtaprova) qt_dias
        FROM crawepr epr,
             crapope c,
             crapass a
       WHERE epr.cdcooper = pr_cdcooper
         AND epr.nrdconta = pr_nrdconta
         AND epr.nrctremp = pr_nrctremp
         AND epr.cdcooper = c.cdcooper
         AND epr.cdopeste = c.cdoperad
         AND TRIM(c.dsdemail) is not null
         AND a.cdcooper = epr.cdcooper
         AND a.nrdconta = epr.nrdconta
         AND NOT EXISTS (SELECT 1 
                           FROM crapepr epr2
                          WHERE epr2.cdcooper = epr.cdcooper
                            AND epr2.nrdconta = epr.nrdconta
                            AND epr2.nrctremp = epr.nrctremp);

    rw_crawepr cr_crawepr%ROWTYPE;
             
    CURSOR cr_email_proposta IS
      SELECT t.ds_assunto
            ,t.ds_corpo
        FROM tbcadast_email_proposta t
       WHERE t.cdcooper  = pr_cdcooper
         AND t.tpproduto = 1 -- Emprestimo/financiamento
         AND t.idativo   = 1; 

    rw_email_proposta cr_email_proposta%ROWTYPE;
    
    CURSOR  CR_EMAIL_REMETENTE IS         
      SELECT
             cp.dsvlrprm
         FROM
             crapprm cp
        WHERE
             cp.nmsistem = 'CRED'
         AND cp.cdacesso = 'EMPR_REMETENTE_PROP_OPE'             
         AND cp.cdcooper = 0;
    RW_EMAIL_REMETENTE CR_EMAIL_REMETENTE%ROWTYPE;
        
    CURSOR cr_nls IS
      SELECT v.parameter
            ,v.value
        FROM V$NLS_PARAMETERS v
       WHERE v.parameter IN ('NLS_TIME_FORMAT',
                             'NLS_DATE_LANGUAGE',
                             'NLS_TIMESTAMP_FORMAT');    
    
    -- Variaveis Excecao
    vr_exc_erro           EXCEPTION;

    -- Variaveis Erro
    vr_cdcritic              INTEGER;
    vr_dscritic              VARCHAR2(4000);
      
    --Variáveis locais
    vr_ds_corpo       VARCHAR2(4000);     
    -- Variáveis para armazenar as informações em XML
    vr_xml            CLOB;             --> XML do retorno
    vr_texto_completo  VARCHAR2(32600);    
                                                                     
    vr_nls_time_format VARCHAR2(400);
    vr_nls_date_language VARCHAR2(400);
    vr_nls_timestamp_format VARCHAR2(400);
      
                                                                     
  BEGIN
    -- Carregar os parametros atuais 
    FOR rw_nls IN cr_nls LOOP
      IF rw_nls.parameter = 'NLS_TIME_FORMAT' THEN
        vr_nls_time_format := rw_nls.value;
      ELSIF rw_nls.parameter = 'NLS_DATE_LANGUAGE' THEN
        vr_nls_date_language    := rw_nls.value;  
      ELSIF rw_nls.parameter = 'NLS_TIMESTAMP_FORMAT' THEN
        vr_nls_timestamp_format := rw_nls.value;
      END IF;
    END LOOP;
    --
    -- Atualizar os parametros para brasil.
    BEGIN
      EXECUTE IMMEDIATE 'ALTER SESSION SET nls_date_language = ''BRAZILIAN PORTUGUESE''';
      EXECUTE IMMEDIATE 'ALTER SESSION SET nls_time_format = ''HH24:MI:SSXFF''';      
      EXECUTE IMMEDIATE 'ALTER SESSION SET nls_timestamp_format = ''DD/MM/RR HH24:MI:SSXFF''';      
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar SESSION '||SQLERRM;
        RAISE vr_exc_erro;
    END;
   

    -- Busca os endereços de e-mail do remetente
    OPEN cr_email_remetente;
    FETCH cr_email_remetente INTO rw_email_remetente;
    IF cr_email_remetente%NOTFOUND THEN
      CLOSE cr_email_remetente;
      vr_dscritic := 'E-mail do remetente não cadastrado!';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_email_remetente;      
    END IF;
    
    --> Verifica se a proposta foi efetivada, se foi, atualiza a data de ultimo envio do email para nulo
    OPEN cr_proposta_efetivada;
    FETCH cr_proposta_efetivada INTO rw_proposta_efetivada;                  
    IF cr_proposta_efetivada%FOUND THEN
      CLOSE cr_proposta_efetivada;
      -- Como a proposta perdeu foi efetivada, limpar a data de ultimo envio do email
      BEGIN
        UPDATE 
              crawepr c
        SET  
              c.dtulteml = null
        WHERE
              c.rowid = rw_proposta_efetivada.rowid;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar tabela crawepr - Data de envio do último E-mail. ' || SQLERRM;
          --Sair do programa
          RAISE vr_exc_erro;           
      END; 
                
      pr_flgenvia:= 0;        
    ELSE
      CLOSE cr_proposta_efetivada;

      --> Buscar dados do email
      OPEN cr_email_proposta;
      FETCH cr_email_proposta INTO rw_email_proposta;                  
      IF cr_email_proposta%NOTFOUND THEN
        -- Como não tem mais o parâmetro ou está inativo, não envia o e-mail
        BEGIN
          UPDATE 
                crawepr c
          SET  
                c.dtulteml = null
          WHERE
                c.cdcooper = pr_cdcooper
            AND c.nrdconta = pr_nrdconta
            AND c.nrctremp = pr_nrctremp;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar tabela crawepr - Data de envio do último E-mail. ' || SQLERRM;
            --Sair do programa
            RAISE vr_exc_erro;           
        END; 
                
        pr_flgenvia:= 0;        

      ELSE
        CLOSE cr_email_proposta;
        
        --> Buscar dados do emprestimo
        OPEN cr_crawepr;
        FETCH cr_crawepr INTO rw_crawepr;                  
        IF cr_crawepr%NOTFOUND THEN
          vr_cdcritic := 535; --> 535 - Proposta nao encontrada.
          CLOSE cr_crawepr;
          RAISE vr_exc_erro;
        ELSE
          CLOSE cr_crawepr;
        END IF;
    
        -- Se a proposta ainda estiver analisada, aprovada e existir o e-mail do operador, envio o e-mail
        IF    rw_crawepr.insitest = 3 -- Situacao Analise Finalizada
          AND rw_crawepr.insitapr = 1 -- Decisao aprovada
          AND rw_crawepr.dtaprova IS NOT NULL 
          AND rw_crawepr.dsdemail IS NOT NULL THEN
          pr_flgenvia:= 1;

          -- Inicializar as informações do XML de dados para o relatório
          dbms_lob.createtemporary(vr_xml, TRUE, dbms_lob.CALL);
          dbms_lob.open(vr_xml, dbms_lob.lob_readwrite);

          -- Inicializa o XML
          gene0002.pc_escreve_xml(vr_xml, vr_texto_completo,'<?xml version="1.0" encoding="utf-8"?><notificacao>'||chr(13));

          -- Cria o no de retorno do remetente
          gene0002.pc_escreve_xml(vr_xml, vr_texto_completo, 
                   '<remetente>'||rw_email_remetente.dsvlrprm||'</remetente>'||chr(13));    
               
          -- Cria o no de retorno do assunto
          gene0002.pc_escreve_xml(vr_xml, vr_texto_completo, 
                   '<assunto>'||rw_email_proposta.ds_assunto||'</assunto>'||chr(13));    
 
          vr_ds_corpo:= rw_email_proposta.ds_corpo||chr(13)||chr(13)
                      ||' N° da conta:'        ||pr_nrdconta||chr(13)
                      ||' Titular da conta:'   ||rw_crawepr.nmprimtl||chr(13)
                      ||' N° da proposta:'     ||pr_nrctremp||chr(13)
                      ||' Valor da proposta:'  ||rw_crawepr.vlemprst||chr(13)
                      ||' Data de Aprovação:'  ||rw_crawepr.dtaprovaimp||chr(13)
                      ||' Proposta aprovada à:'||rw_crawepr.qt_dias||' Dias.'||chr(13);
                  
          -- Cria o no de retorno do conteudo
          gene0002.pc_escreve_xml(vr_xml, vr_texto_completo, 
                   '<conteudo>'||vr_ds_corpo||'</conteudo>'||chr(13));    

          -- Cria o no de retorno do Formato
          gene0002.pc_escreve_xml(vr_xml, vr_texto_completo, 
                   '<formatoMensagem>text/plain</formatoMensagem>'||chr(13));    

          -- Popula a linha de detalhes
          gene0002.pc_escreve_xml(vr_xml, vr_texto_completo, 
               '<destinatarios>'||chr(13)||
                 '<destinatario>'||chr(13)||           
                   '<enderecoEletronico>'||rw_crawepr.dsdemail||'</enderecoEletronico>'||chr(13)||
                   --tipoDestinatario :1=(TO) Principal  / 2 = (CC) Em Cópia / 3= (CCO) Em cópia Oculta
                   '<tipoDestinatario>1</tipoDestinatario>'||chr(13)
                 );
          -- Finaliza o nó destinatario
          gene0002.pc_escreve_xml(vr_xml, vr_texto_completo, 
             '</destinatario>'||chr(13));
             
          -- Finaliza o nó destinatarios
          gene0002.pc_escreve_xml(vr_xml, vr_texto_completo, 
             '</destinatarios>'||chr(13));
             
          -- Cria o no de retorno 
          gene0002.pc_escreve_xml(vr_xml, vr_texto_completo, 
                     '</notificacao>',TRUE);
          -- Converte o CLOB para o XML de retorno
          pr_retxml := XMLType.createxml(vr_xml);                 
        ELSE -- Como a proposta perdeu a aprovação, limpar a data de ultimo envio do email
          BEGIN
            UPDATE 
                  crawepr c
            SET  
                  c.dtulteml = null
            WHERE
                  c.rowid = rw_crawepr.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar tabela crawepr - Data de envio do último E-mail. ' || SQLERRM;
              --Sair do programa
              RAISE vr_exc_erro;           
          END; 
                
          pr_flgenvia:= 0;        
        END IF;
      END IF;        
    END IF;
    
    -- Atualizar os parametros para o que estava antes
    BEGIN
      EXECUTE IMMEDIATE 'ALTER SESSION SET nls_time_format = '''||vr_nls_time_format||'''';
      EXECUTE IMMEDIATE 'ALTER SESSION SET nls_date_language = '''||vr_nls_date_language||'''';
      EXECUTE IMMEDIATE 'ALTER SESSION SET nls_timestamp_format = '''||vr_nls_timestamp_format||'''';
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar SESSION '||SQLERRM;
        RAISE vr_exc_erro;
    END;    
    --gene0002.pc_XML_para_arquivo(pr_retxml
    --                           ,'/usr/coop/cecred/'
    --                           ,'TESTE.txt'
    --                           ,pr_dscritic );
    COMMIT;
  EXCEPTION
    WHEN vr_exc_erro THEN
      IF NVL(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;
      pr_cdcritic := NVL(vr_cdcritic, 0);
      pr_dscritic := vr_dscritic;
              
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na procedure EMPR0015.pc_valida_email_proposta: ' || SQLERRM;
        
  END pc_valida_email_proposta;   
  
  PROCEDURE pc_aval_perde_aprov (pr_cdcooper  IN crapdat.cdcooper%TYPE      --> Codigo da Cooperativa
                                ,pr_avtperda  OUT NUMBER  -- 0 Não perde | 1 perde aprovação
                                ,pr_vlperavt  OUT NUMBER  -- Valor
                                ,pr_cdcritic  OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                ,pr_dscritic  OUT crapcri.dscritic%TYPE) IS
   /* .............................................................................

       Programa: pc_aval_perde_aprov
       Sistema : Crédito - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Paulo Martins (Mouts)
       Data    : 30/10/2018          Ultima atualizacao: 

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para retornar informação referente a perda de aprovação em troca de avalista 
       onde :
             pr_avtperda se 0 perde aprovação e 1 não perde.
             pr_vlperavt valor utilizado como vamor base para perda de aprovação.

       Alteracoes: 
    ............................................................................. */   

    vr_dstextab craptab.dstextab%TYPE;
    vr_avtperda NUMBER  :=1; --Não perder | 0 Perde
    vr_vlperavt NUMBER  :=0; 
        
    -- Variaveis Excecao
    vr_exc_erro           EXCEPTION;

    vr_dscritic              VARCHAR2(4000);
                                                                     
  BEGIN
      if pr_cdcooper is not null then

      vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'PAREMPREST'
                                               ,pr_tpregist => 01);

      pr_avtperda := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,132,1)),1); 
      pr_vlperavt := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,134,12)),0); 
      
      else
        vr_dscritic := 'Cooperativa nao informada!';
        raise vr_exc_erro;
      end if;

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := 0;
      pr_dscritic := vr_dscritic;
              
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na procedure EMPR0015.pc_aval_perde_aprov: ' || SQLERRM;
        
  END pc_aval_perde_aprov;   
  
  PROCEDURE pc_valida_perda_aprov_proposta(pr_cdcooper        IN crapdat.cdcooper%TYPE     --> Codigo da Cooperativa
                                          ,pr_cdoperad        IN crapnrc.cdoperad%TYPE      --> Codigo Operador                                                                          
                                          ,pr_nmdatela        IN craptel.nmdatela%TYPE      --> Nome da tela
                                          ,pr_nrdconta        IN crapass.nrdconta%TYPE      --> Numero da conta
                                          ,pr_idseqttl        IN crapttl.idseqttl%TYPE      --> Sequencial do Titular
                                          ,pr_nrctremp        IN crawepr.nrctremp%TYPE      --> Numero do contrato de emprestimo
                                          ,pr_dsorigem        IN craplgm.dsorigem%TYPE      --> Descrição da origem
                                           /** ---------------------- Dados para a crawepr -------------------- */
                                          ,pr_qtpreemp        IN crawepr.qtpreemp%TYPE      --> quantidade de prestacoes do emprestimo. 
                                          ,pr_dsnivris        IN crawepr.dsnivris%TYPE      -- risco melhora  
                                          ,pr_cdlcremp        IN crawepr.cdlcremp%TYPE      -- codigo da linha de credito do emprestimo. 
                                          ,pr_cdfinemp        IN crawepr.cdfinemp%TYPE      -- codigo da finalidade do emprestimo. 
                                          ,pr_qtdialib        IN crawepr.qtdialib%TYPE      -- numero de dias para liberacao do emprestimo. 
                                          ,pr_flgimpnp        IN crawepr.flgimpnp%TYPE      -- emissao de nota promissoria. 
                                          ,pr_percetop        IN crawepr.percetop%TYPE      -- percentual do cet nas operacoes. 
                                          ,pr_idquapro        IN crawepr.idquapro%TYPE      -- identificacao da qualificacao da operacao (proposta). 
                                          ,pr_dtdpagto        IN crawepr.dtdpagto%TYPE      -- data do pagamento da primeira prestacao. 
                                          ,pr_qtpromis        IN crawepr.qtpromis%TYPE      -- quantidade promissorias a serem emitidas. 
                                          ,pr_flgpagto        IN crawepr.flgpagto%TYPE      -- Data do pagamento
                                          ,pr_dsctrliq        IN varchar2                   -- Contratos sendo liquidados
                                          ,pr_idcarenc        IN crawepr.idcarenc%TYPE      -- identificador da carencia para posfixado 
                                          ,pr_dtcarenc        IN crawepr.dtcarenc%TYPE      -- data da carencia para posfixado  
                                           /** ------- Dados para dados do Rating e do Banco central ---------- */                      
                                          ,pr_nrgarope        IN crapprp.nrgarope%TYPE       --numero da garantia da operacao 
                                          ,pr_nrperger        IN crapprp.nrperger%TYPE       --percepcao geral com relacao a empresa (rating) 
                                          ,pr_dtcnsspc        IN crapprp.dtcnsspc%TYPE       --data da consulta ao spc. 
                                          ,pr_dtdrisco        IN crapprp.dtdrisco%TYPE       --data de entrada na central de risco. 
                                          ,pr_vltotsfn        IN crapprp.vltotsfn%TYPE       --valor total sfn exceto na cooperativa 
                                          ,pr_qtopescr        IN crapprp.qtopescr%TYPE       --quantidade de operacoes na central de risco scr. 
                                          ,pr_qtifoper        IN crapprp.qtifoper%TYPE       --quantidade de instituicoes financeiras que o cooperado ja possui operacao. 
                                          ,pr_nrliquid        IN crapprp.nrliquid%TYPE       --numero do contrato do limite credito ou adp que esta sendo liquidado 
                                          ,pr_vlopescr        IN crapprp.vlopescr%TYPE       --valor das operacoes vencidas na central de risco scr. 
                                          ,pr_vlrpreju        IN crapprp.vlrpreju%TYPE       --valor do prejuizo fora da cooperativa. 
                                          ,pr_nrpatlvr        IN crapprp.nrpatlvr%TYPE       --sequencia do item relativo ao patrimonio pessoal livre do endividamento (rating) 
                                          ,pr_dtoutspc        IN crapprp.dtoutspc%TYPE       --contem a data da consulta do conjuge / seg. titular ao spc. 
                                          ,pr_dtoutris        IN crapprp.dtoutris%TYPE       --contem a data da consulta na central de risco para o conjuge / seg. titular. 
                                          ,pr_vlsfnout        IN crapprp.vlsfnout%TYPE       --contem o endividamento do conjuge ou do 2. titular. 
                                          /** ---------------- Dados Salario/Faturamento -------------------- **/
                                          ,pr_vlsalari        IN crapprp.vlsalari%TYPE       --valor do salario do associado. 
                                          ,pr_vloutras        IN crapprp.vloutras%TYPE       --valor das outras rendas. 
                                          ,pr_vlalugue        IN crapprp.vlalugue%TYPE       --valor do aluguel. 
                                          ,pr_vlsalcon        IN crapprp.vlsalcon%TYPE       --valor do salario do conjuge. 
                                          ,pr_nmempcje        IN crapprp.nmempcje%TYPE       --nome da empresa onde o conjuge trabalha. 
                                          ,pr_flgdocje        IN crapprp.flgdocje%TYPE       --conjuge co-responsavel. 
                                          ,pr_nrctacje        IN crapprp.nrctacje%TYPE       --numero da conta do conjuge. 
                                          ,pr_nrcpfcje        IN crapprp.nrcpfcje%TYPE       --numero do cpf do conjuge do associado. 
                                          ,pr_vlmedfat        IN crapprp.vlmedfat%TYPE       --valor medio do faturamento bruto mensal. 
                                          ,pr_dsdfinan        IN varchar2                    --Faturamento em casp de pessoa física
                                          ,pr_dsdrendi        IN varchar2                    --Rendimentos
                                          ,pr_dsjusren        IN varchar2                    --Justificativa rendimento
                                          ,pr_idfiniof        IN crawepr.idfiniof%TYPE       --Indicador finaciamento de IOF
                                          --
                                          ,pr_idpeapro        OUT INTEGER                   --> 0 - Não perdeu aprovação e 1 - Perdeu aprovação
                                          ,pr_dserro          OUT crapcri.dscritic%TYPE     --> OK - se processar e NOK - se erro
                                          ,pr_cdcritic        OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                          ,pr_dscritic        OUT crapcri.dscritic%TYPE) IS --> Descricao da critica
  BEGIN
    /* .............................................................................

       Programa: pc_valida_perda_aprov_proposta
       Sistema : Crédito - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Paulo Martins (Mouts)
       Data    : Novembro/2018                         Ultima atualizacao: 

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para processaer as regras para perda da aprovação da proposta de empréstimo.
                   Esta procedure concentra as regras que não estão no Progress (b1wgen0002) referente as 
                   validações da alteração de propostas aprovadas, após as validações das regras já existentes, 
                   será validadas as regras contidas nesta procedure.
                   
                     
       Alterações: 
    ............................................................................. */

    DECLARE
       /** ---------------------- Dados para a crawepr -------------------- */
       CURSOR cr_crawepr is
       SELECT c.qtpreemp, -- quantidade de prestacoes do emprestimo. 
              c.dsnivris, -- risco melhora  
              c.cdlcremp, -- codigo da linha de credito do emprestimo. 
              c.cdfinemp, -- codigo da finalidade do emprestimo. 
              c.qtdialib, -- numero de dias para liberacao do emprestimo. 
              c.flgimppr, -- indica se a proposta do emprestimo devera ser impressa ou nao. 
              c.flgimpnp, -- emissao de nota promissoria. 
              c.percetop, -- percentual do cet nas operacoes. 
              c.idquapro, -- identificacao da qualificacao da operacao (proposta). 
              c.dtdpagto, -- data do pagamento da primeira prestacao. 
              c.qtpromis, -- quantidade promissorias a serem emitidas. 
              c.flgpagto, -- Data do pagamento
              c.idcarenc, -- identificador da carencia para posfixado 
              c.dtcarenc, -- data da carencia para posfixado  
              nvl(c.nrctrliq##1,0)+nvl(c.nrctrliq##2,0)+nvl(c.nrctrliq##3,0)+nvl(c.nrctrliq##4,0)+nvl(c.nrctrliq##5,0)+
              nvl(c.nrctrliq##6,0)+nvl(c.nrctrliq##7,0)+nvl(c.nrctrliq##8,0)+nvl(c.nrctrliq##9,0)+nvl(c.nrctrliq##10,0) smctrliq, --Contratos a serem liquidados
              zeroToNull(c.nrctrliq##1)||' '||
              zeroToNull(c.nrctrliq##2)||' '||
              zeroToNull(c.nrctrliq##3)||' '||
              zeroToNull(c.nrctrliq##4)||' '||
              zeroToNull(c.nrctrliq##5)||' '||
              zeroToNull(c.nrctrliq##6)||' '||
              zeroToNull(c.nrctrliq##7)||' '||
              zeroToNull(c.nrctrliq##8)||' '||
              zeroToNull(c.nrctrliq##9)||' '||
              zeroToNull(c.nrctrliq##10) nrctrliq,    
              tpemprst,       
              decode(c.idfiniof,0,'Não','Sim') idfiniof
         FROM crawepr c
        WHERE c.cdcooper = pr_cdcooper
          AND c.nrdconta = pr_nrdconta
          AND c.nrctremp = pr_nrctremp;
          --
          r_crawepr cr_crawepr%rowtype;

       CURSOR cr_crapprp is
       SELECT p.nrgarope, --numero da garantia da operacao 
              p.nrperger, --percepcao geral com relacao a empresa (rating) 
              p.dtcnsspc, --data da consulta ao spc. 
              p.nrinfcad, --sequencia do item relacionado a informacoes cadastrais 
              p.dtdrisco, --data de entrada na central de risco. 
              p.vltotsfn, --valor total sfn exceto na cooperativa 
              p.qtopescr, --quantidade de operacoes na central de risco scr. 
              p.qtifoper, --quantidade de instituicoes financeiras que o cooperado ja possui operacao. 
              p.nrliquid, --numero do contrato do limite credito ou adp que esta sendo liquidado 
              p.vlopescr, -- valor das operacoes vencidas na central de risco scr. 
              p.vlrpreju, --valor do prejuizo fora da cooperativa. 
              p.nrpatlvr, --sequencia do item relativo ao patrimonio pessoal livre do endividamento (rating) 
              p.dtoutspc, --contem a data da consulta do conjuge / seg. titular ao spc. 
              p.dtoutris, --contem a data da consulta na central de risco para o conjuge / seg. titular. 
              p.vlsfnout, --contem o endividamento do conjuge ou do 2. titular. 
              /** ---------------- Dados Salario/Faturamento -------------------- **/
              p.vlsalari, --valor do salario do associado. 
              p.vloutras, --valor das outras rendas. 
              p.vlalugue, --valor do aluguel. 
              p.vlsalcon, --valor do salario do conjuge. 
              p.nmempcje, --nome da empresa onde o conjuge trabalha. 
              p.flgdocje, --conjuge co-responsavel. 
              p.nrctacje, --numero da conta do conjuge. 
              p.nrcpfcje, --numero do cpf do conjuge do associado. 
              p.vlmedfat  --valor medio do faturamento bruto mensal. 
         FROM crapprp p 
        WHERE p.cdcooper = pr_cdcooper
          AND p.nrdconta = pr_nrdconta
          AND p.nrctrato = pr_nrctremp;
          --AND p.tpctrato = ;
          --
          r_crapprp cr_crapprp%rowtype;    
      
      /*Quando existe mais de uma renda para o mesmo contrato, a justificativa no banco é a mesma*/
      CURSOR cr_craprpr IS
      SELECT r.dsjusren
            ,sum(r.tpdrendi) Smtpdrendi
            ,sum(r.vldrendi) Smvldrendi
        FROM craprpr r
       WHERE r.cdcooper = pr_cdcooper
         AND r.nrdconta = pr_nrdconta
         AND r.nrctrato = pr_nrctremp
       group by r.dsjusren;

      r_craprpr cr_craprpr%rowtype;        

      CURSOR cr_crapjfn IS       
      SELECT nvl(f.vlrftbru##1,0)+
             nvl(f.vlrftbru##2,0)+
             nvl(f.vlrftbru##3,0)+            
             nvl(f.vlrftbru##4,0)+             
             nvl(f.vlrftbru##5,0)+             
             nvl(f.vlrftbru##6,0)+             
             nvl(f.vlrftbru##7,0)+
             nvl(f.vlrftbru##8,0)+
             nvl(f.vlrftbru##9,0)+
             nvl(f.vlrftbru##10,0)+
             nvl(f.vlrftbru##11,0)+
             nvl(f.vlrftbru##12,0) vlrftbru
        FROM crapjfn f 
       WHERE f.cdcooper = pr_cdcooper
         AND f.nrdconta = pr_nrdconta;       
         
      r_crapjfn cr_crapjfn%rowtype; 
       
      -- Variaveis tratamento de erros
      vr_cdcritic             crapcri.cdcritic%TYPE;
      vr_dscritic             VARCHAR2(4000);
      vr_exc_erro             EXCEPTION;
      
      --Variáveis utilizadas nas validações
      vr_perde char(1) := 'N';
      vr_indx PLS_INTEGER;
      vr_split               gene0002.typ_split := gene0002.typ_split();
      vr_split_rendimentos   gene0002.typ_split := gene0002.typ_split();
      vr_split_faturamentos  gene0002.typ_split := gene0002.typ_split();      
      vr_somaContratos number(10) := 0;
      vr_somaValoresRendimento number(10,2) := 0;
      vr_somaTpContratos       number(10) := 0; 
      vr_somaFaturamentos      number(25,2) := 0;   
      vr_nrdrowid              ROWID;          
      vr_idiof_aux             varchar2(5);     

      
       --Será utilizado para gravar todas as alterações
       TYPE typ_reg_alteracoes IS RECORD(dsmotivo varchar2(100)   --> Motivos da Perda
                                        ,nmcampo  varchar2(200)   --> Nome do campo
                                        ,dsdadant varchar2(4000)   --> Valor Anterior
                                        ,dsdadatu varchar2(4000)); --> Valor Atual
        /* Definição de tabela que compreenderá os registros acima declarados */
        TYPE typ_tab_alteracoes IS TABLE OF typ_reg_alteracoes INDEX BY PLS_INTEGER;
        /* Variável que armazenará uma instancia da tabela */
        vr_tab_alteracoes typ_tab_alteracoes;
        
      PROCEDURE prc_grava_log IS
      /*Gravar log*/
      begin

        GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => ''
                            ,pr_dsorigem => pr_dsorigem
                            ,pr_dstransa => 'A proposta :'||pr_nrctremp
                                          ||' Perdeu a aprovação devido alteracao em Regra Geral.'
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 1
                            ,pr_hrtransa => gene0002.fn_busca_time
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
      exception 
        when others then
          vr_dscritic := 'Erro ao gravar log: '||sqlerrm;
          raise vr_exc_erro;                            
      end;         
      
      PROCEDURE prc_grava_item_log(p_nmcampo in varchar2,
                                   p_nrdrowid in rowid,
                                   p_dsdadant in varchar2,
                                   p_dsdadatu in varchar2) IS
      /*Gravar Item log*/
      begin

        GENE0001.pc_gera_log_item(pr_nrdrowid => p_nrdrowid,
                                  pr_nmdcampo => p_nmcampo,--'Valor Atual do empréstimo',
                                  pr_dsdadant => p_dsdadant,--'ND',
                                  pr_dsdadatu => p_dsdadatu); 
                                  
      exception 
        when others then
          vr_dscritic := 'Erro ao gravar item log: '||sqlerrm;
          raise vr_exc_erro;                                       
      end;          
      
      PROCEDURE prc_valida_alteracao(p_motivo   in varchar2,
                                     p_nmcampo  in varchar2,
                                     p_dsdadant in varchar2,
                                     p_dsdadatu in varchar2,
                                     p_index    in out number,
                                     p_sn_perde in out varchar2) IS
                                     
      /*Validar se ocorreu alteração*/
      
      vr_dsdadant varchar2(4000);
      vr_dsdadatu varchar2(4000);
      
      begin
        
        if p_dsdadant is null then
          vr_dsdadant := 'ND';
        else
          vr_dsdadant := p_dsdadant;
        end if;
        --
        if p_dsdadatu is null then
          vr_dsdadatu := 'ND';
        else
          vr_dsdadatu := p_dsdadatu;
        end if;
        
        --Ocorreu alteração de valores
        if vr_dsdadant != vr_dsdadatu then
          vr_tab_alteracoes(p_index).dsmotivo := p_motivo;    --> Motivos da Perda
          vr_tab_alteracoes(p_index).nmcampo  := p_nmcampo;   --> Nome do campo
          vr_tab_alteracoes(p_index).dsdadant := vr_dsdadant; --> Valor Anterior
          vr_tab_alteracoes(p_index).dsdadatu := vr_dsdadatu; --> Valor Atual   
          p_index := p_index+1;
          p_sn_perde := 'S';
        end if; 
      exception 
       when others then
        vr_dscritic := 'Erro ao validar alterações: '||sqlerrm;
        raise vr_exc_erro;          
      end;         
      
    BEGIN
      
      OPEN cr_crawepr;
       FETCH cr_crawepr INTO r_crawepr;
        if cr_crawepr%notfound then
          close cr_crawepr;
		     vr_dscritic := 'Nao foi possivel incluir proposta. Tente novamente!';
           --vr_dscritic := 'Contrato[ '||pr_nrctremp||' ] nao encontrado para validar Regras gerais.';
           raise vr_exc_erro;    
        end if;
      CLOSE cr_crawepr;
      
      OPEN cr_crapprp;
       FETCH cr_crapprp INTO r_crapprp;
      CLOSE cr_crapprp;

      OPEN cr_craprpr;
       FETCH cr_craprpr INTO r_craprpr;
      CLOSE cr_craprpr;
      
      OPEN cr_crapjfn;
       FETCH cr_crapjfn INTO r_crapjfn;
      CLOSE cr_crapjfn;      
      
      vr_indx  := 1;
      vr_perde := 'N';
      
      /**Informações que chegam como String**/
      
      --dsctrliq
/*      if substr(trim(upper(pr_dsctrliq)),1,3) != 'SEM' then -- Sem liquidações
        vr_split := gene0002.fn_quebra_string(pr_string  => replace(pr_dsctrliq,'.'),
                                              pr_delimit => ',');
    
      IF vr_split.count > 0 THEN
        FOR x IN vr_split.FIRST .. vr_split.LAST LOOP
         vr_somaContratos := vr_somaContratos+to_number(vr_split(x));
        END LOOP;
      END IF;
      end if;
      --
      if nvl(vr_somaContratos,0) != r_crawepr.smctrliq then
        --
        vr_tab_alteracoes(vr_indx).dsmotivo := 'Alterado contratos liquidados.';    --> Motivos da Perda
        vr_tab_alteracoes(vr_indx).nmcampo  := 'Contratos liquidacoes';   --> Nome do campo
        vr_tab_alteracoes(vr_indx).dsdadant := r_crawepr.nrctrliq; --> Valor Anterior
        vr_tab_alteracoes(vr_indx).dsdadatu := pr_dsctrliq; --> Valor Atual
        vr_indx  := vr_indx+1;
        vr_perde := 'S';
        --
      end if;   
      
      --dsdrendi
      vr_split.delete;
      \*Como os códigos são numéricos efetuaremos a soma para poder validar a alteração*\
      vr_split_rendimentos := gene0002.fn_quebra_string(pr_string  => replace(pr_dsdrendi,'.'),
                                                        pr_delimit => '|');
      IF vr_split_rendimentos.count > 0 THEN
        FOR x IN vr_split_rendimentos.FIRST .. vr_split_rendimentos.LAST LOOP
          
          vr_split := gene0002.fn_quebra_string(pr_string  => vr_split_rendimentos(x),
                                                pr_delimit => ';');
      
          IF vr_split.count > 0 THEN
            FOR y IN vr_split.FIRST .. vr_split.LAST LOOP
              CASE y
                WHEN 1 THEN
                  vr_somaTpContratos       := vr_somaTpContratos+vr_split(y);  
                WHEN 2 THEN
                  vr_somaValoresRendimento := vr_somaValoresRendimento+vr_split(y);                
                ELSE
                  NULL;
              END CASE;
            END LOOP;
          END IF;
          --
        END LOOP;
      END IF;
      --
      if vr_somaTpContratos != r_craprpr.Smtpdrendi or vr_somaValoresRendimento != r_craprpr.Smvldrendi  then
        --
        vr_tab_alteracoes(vr_indx).dsmotivo := 'Alterado rendimentos.';    --> Motivos da Perda
        vr_tab_alteracoes(vr_indx).nmcampo  := 'Rendimentos';   --> Nome do campo
        vr_tab_alteracoes(vr_indx).dsdadant := 'Soma rendimentos atu: '||r_craprpr.Smvldrendi; --> Valor Anterior
        vr_tab_alteracoes(vr_indx).dsdadatu := 'Soma rendimentos ant: '||vr_somaValoresRendimento; --> Valor Atual
        vr_indx  := vr_indx+1;
        vr_perde := 'S';
        --
      end if;       
      --dsdrendi--FIM

      --dsdfinan -- Retirado Paulo
      vr_split.delete;
      \*Soma dos faturamentos mensais*\
      vr_split_faturamentos := gene0002.fn_quebra_string(pr_string  => pr_dsdfinan,
                                                         pr_delimit => '|');
      IF vr_split_faturamentos.count > 0 THEN
        FOR x IN vr_split_faturamentos.FIRST .. vr_split_faturamentos.LAST LOOP
          
          vr_split := gene0002.fn_quebra_string(pr_string  => vr_split_faturamentos(x),
                                                pr_delimit => ';');
      
          IF vr_split.count > 0 THEN
            FOR y IN vr_split.FIRST .. vr_split.LAST LOOP
              CASE y
                WHEN 3 THEN -- Somar os valores encontrados
                  vr_somaFaturamentos  := vr_somaFaturamentos+to_number(vr_split(y));  
                ELSE
                  NULL;
              END CASE;
            END LOOP;
          END IF;
          --
        END LOOP;
      END IF;
      --
      if vr_somaFaturamentos != r_crapjfn.vlrftbru  then
        --
        vr_tab_alteracoes(vr_indx).dsmotivo := 'Alterado Faturamentos.';    --> Motivos da Perda
        vr_tab_alteracoes(vr_indx).nmcampo  := 'Faturamentos';   --> Nome do campo
        vr_tab_alteracoes(vr_indx).dsdadant := 'Soma 12 meses atu: '||r_crapjfn.vlrftbru; --> Valor Anterior
        vr_tab_alteracoes(vr_indx).dsdadatu := 'Soma 12 meses ant: '||vr_somaFaturamentos; --> Valor Atual
        vr_indx  := vr_indx+1;
        vr_perde := 'S';
        --
      end if; */    
      --dsdfinan-FIM
      
      /*dsjusren* Não sera validado/
/*      prc_valida_alteracao(p_motivo   => 'Alterada Justificativa Rendimento.'
                          ,p_nmcampo  => 'Justificativa Rendimento'
                          ,p_dsdadant => r_craprpr.dsjusren
                          ,p_dsdadatu => pr_dsjusren
                          ,p_index    => vr_indx
                          ,p_sn_perde => vr_perde);  */  
    
      /** ---------------------- Dados para a Proposta -------------------- */
/*      if pr_idfiniof = 0 then
       vr_idiof_aux := 'Não';
      else
       vr_idiof_aux := 'Sim';
      end if;
      prc_valida_alteracao(p_motivo   => 'Alterada opcao financiar iof junto ao emprestimo.'
                          ,p_nmcampo  => 'Finaciar IOF'
                          ,p_dsdadant => r_crawepr.idfiniof
                          ,p_dsdadatu => vr_idiof_aux
                          ,p_index    => vr_indx
                          ,p_sn_perde => vr_perde);*/
                          
/*      prc_valida_alteracao(p_motivo   => 'Alterada quantidade de prestacoes do emprestimo.'
                          ,p_nmcampo  => 'Quantidade prestacoes'
                          ,p_dsdadant => r_crawepr.qtpreemp
                          ,p_dsdadatu => pr_qtpreemp
                          ,p_index    => vr_indx
                          ,p_sn_perde => vr_perde);*/
      --Bug 14170
/*      prc_valida_alteracao(p_motivo   => 'Alterado risco da operacao.'
                          ,p_nmcampo  => 'Risco da Operacao'
                          ,p_dsdadant => r_crawepr.dsnivris
                          ,p_dsdadatu => pr_dsnivris
                          ,p_index    => vr_indx
                          ,p_sn_perde => vr_perde);      */

      prc_valida_alteracao(p_motivo   => 'Alterada codigo da linha de credito do emprestimo.'
                          ,p_nmcampo  => 'Linha de credito'
                          ,p_dsdadant => r_crawepr.cdlcremp
                          ,p_dsdadatu => pr_cdlcremp
                          ,p_index    => vr_indx
                          ,p_sn_perde => vr_perde); 

      if r_crapprp.flgdocje = 1 and pr_flgdocje = 0 then
      prc_valida_alteracao(p_motivo   => 'Alterada conjuge co-responsavel.'
                          ,p_nmcampo  => 'Conjuge co-responsavel'
                          ,p_dsdadant => r_crapprp.flgdocje
                          ,p_dsdadatu => pr_flgdocje
                          ,p_index    => vr_indx
                          ,p_sn_perde => vr_perde);                           
      end if;

/*      prc_valida_alteracao(p_motivo   => 'Alterado codigo da finalidade do emprestimo. '
                          ,p_nmcampo  => 'Finalidade'
                          ,p_dsdadant => r_crawepr.cdfinemp
                          ,p_dsdadatu => pr_cdfinemp
                          ,p_index    => vr_indx
                          ,p_sn_perde => vr_perde); */
                          
/*      prc_valida_alteracao(p_motivo   => 'Alterado numero de dias para liberacao do emprestimo.'
                          ,p_nmcampo  => 'Dias para liberacao'
                          ,p_dsdadant => r_crawepr.qtdialib
                          ,p_dsdadatu => pr_qtdialib
                          ,p_index    => vr_indx
                          ,p_sn_perde => vr_perde);*/ 

/*      prc_valida_alteracao(p_motivo   => 'Alterada emissao nota promissoria.'
                          ,p_nmcampo  => 'Emite Promissoria'
                          ,p_dsdadant => r_crawepr.flgimpnp
                          ,p_dsdadatu => pr_flgimpnp
                          ,p_index    => vr_indx
                          ,p_sn_perde => vr_perde); */

/*      prc_valida_alteracao(p_motivo   => 'Alterado percentual do cet nas operacoes'
                          ,p_nmcampo  => 'Percentual cet'
                          ,p_dsdadant => r_crawepr.percetop
                          ,p_dsdadatu => pr_percetop
                          ,p_index    => vr_indx
                          ,p_sn_perde => vr_perde);   */ 

/*      prc_valida_alteracao(p_motivo   => 'Alterada identificacao da qualificacao da operacao'
                          ,p_nmcampo  => 'Qualificacao'
                          ,p_dsdadant => r_crawepr.idquapro
                          ,p_dsdadatu => pr_idquapro
                          ,p_index    => vr_indx
                          ,p_sn_perde => vr_perde); */

/*      prc_valida_alteracao(p_motivo   => 'Alterada data do pagamento da primeira prestacao.'
                          ,p_nmcampo  => 'Data primeira prestacao'
                          ,p_dsdadant => r_crawepr.dtdpagto
                          ,p_dsdadatu => pr_dtdpagto
                          ,p_index    => vr_indx
                          ,p_sn_perde => vr_perde); */

/*      prc_valida_alteracao(p_motivo   => 'Alteracao quantidade promissorias a serem emitidas'
                          ,p_nmcampo  => 'Numero de promissorias'
                          ,p_dsdadant => r_crawepr.qtpromis
                          ,p_dsdadatu => pr_qtpromis
                          ,p_index    => vr_indx
                          ,p_sn_perde => vr_perde);*/ 
                          
/*      prc_valida_alteracao(p_motivo   => 'Alterado pagamento'
                          ,p_nmcampo  => 'Flag Pagamento'
                          ,p_dsdadant => r_crawepr.flgpagto
                          ,p_dsdadatu => pr_flgpagto
                          ,p_index    => vr_indx
                          ,p_sn_perde => vr_perde); 
                          
      --Valida somente para tpempret = 2
      if r_crawepr.tpemprst = 2 then                    
      prc_valida_alteracao(p_motivo   => 'Alterado identificador da carencia para posfixado'
                          ,p_nmcampo  => 'Indica carencia'
                          ,p_dsdadant => r_crawepr.idcarenc
                          ,p_dsdadatu => pr_idcarenc
                          ,p_index    => vr_indx
                          ,p_sn_perde => vr_perde);                           
      end if;                    

      prc_valida_alteracao(p_motivo   => 'Alterada data da carencia'
                          ,p_nmcampo  => 'Data carencia'
                          ,p_dsdadant => r_crawepr.dtcarenc
                          ,p_dsdadatu => pr_dtcarenc
                          ,p_index    => vr_indx
                          ,p_sn_perde => vr_perde);  
            
      \** ------- Dados para dados do Rating e do Banco central ---------- *\    
      -- Informação não é mais utilizada
      \*prc_valida_alteracao(p_motivo   => 'Alterada Valor Total SFN exceto na cooperativa.'
                          ,p_nmcampo  => 'Valor Total SFN'
                          ,p_dsdadant => r_crapprp.vltotsfn
                          ,p_dsdadatu => pr_vltotsfn
                          ,p_index    => vr_indx
                          ,p_sn_perde => vr_perde);       
                          *\      
      
      prc_valida_alteracao(p_motivo   => 'Alterada numero da garantia da operacao.'
                          ,p_nmcampo  => 'Numero Garantia Operacao'
                          ,p_dsdadant => r_crapprp.nrgarope
                          ,p_dsdadatu => pr_nrgarope
                          ,p_index    => vr_indx
                          ,p_sn_perde => vr_perde); 

      prc_valida_alteracao(p_motivo   => 'Alterada a percepcao geral com relacao a empresa (rating).'
                          ,p_nmcampo  => 'Rating'
                          ,p_dsdadant => r_crapprp.nrperger
                          ,p_dsdadatu => pr_nrperger
                          ,p_index    => vr_indx
                          ,p_sn_perde => vr_perde); 

\*      prc_valida_alteracao(p_motivo   => 'Alterada data da consulta ao spc'
                          ,p_nmcampo  => 'Consulta ao spc'
                          ,p_dsdadant => r_crapprp.dtcnsspc
                          ,p_dsdadatu => pr_dtcnsspc
                          ,p_index    => vr_indx
                          ,p_sn_perde => vr_perde); *\

      prc_valida_alteracao(p_motivo   => 'Alterada data de entrada na central de risco'
                          ,p_nmcampo  => 'Data central risco'
                          ,p_dsdadant => r_crapprp.dtdrisco
                          ,p_dsdadatu => pr_dtdrisco
                          ,p_index    => vr_indx
                          ,p_sn_perde => vr_perde);  

      prc_valida_alteracao(p_motivo   => 'Alterada quantidade de operacoes na central de risco scr.'
                          ,p_nmcampo  => 'Quantidade operacao scr'
                          ,p_dsdadant => r_crapprp.qtopescr
                          ,p_dsdadatu => pr_qtopescr
                          ,p_index    => vr_indx
                          ,p_sn_perde => vr_perde); 

      prc_valida_alteracao(p_motivo   => 'Quantidade de instituicoes financeiras que o cooperado ja possui operacao'
                          ,p_nmcampo  => 'Qtd operacoes financeiras'
                          ,p_dsdadant => r_crapprp.qtifoper
                          ,p_dsdadatu => pr_qtifoper
                          ,p_index    => vr_indx
                          ,p_sn_perde => vr_perde); 

      prc_valida_alteracao(p_motivo   => 'Numero do contrato do limite credito ou adp que esta sendo liquidado'
                          ,p_nmcampo  => 'Contratos Liquidados'
                          ,p_dsdadant => r_crapprp.nrliquid
                          ,p_dsdadatu => pr_nrliquid
                          ,p_index    => vr_indx
                          ,p_sn_perde => vr_perde); 
                          
      prc_valida_alteracao(p_motivo   => 'Alterada valor das operacoes vencidas na central de risco scr.'
                          ,p_nmcampo  => 'Valor vencido central de risco'
                          ,p_dsdadant => r_crapprp.vlopescr
                          ,p_dsdadatu => pr_vlopescr
                          ,p_index    => vr_indx
                          ,p_sn_perde => vr_perde); 
                          
      prc_valida_alteracao(p_motivo   => 'Alterado valor do prejuizo fora da cooperativa'
                          ,p_nmcampo  => 'Valor prejuizo'
                          ,p_dsdadant => r_crapprp.vlrpreju
                          ,p_dsdadatu => pr_vlrpreju
                          ,p_index    => vr_indx
                          ,p_sn_perde => vr_perde); 

      prc_valida_alteracao(p_motivo   => 'Alterada sequencia do item relativo ao patrimonio pessoal livre do endividamento (rating).'
                          ,p_nmcampo  => 'Patrimonio pessoal livre'
                          ,p_dsdadant => r_crapprp.nrpatlvr
                          ,p_dsdadatu => pr_nrpatlvr
                          ,p_index    => vr_indx
                          ,p_sn_perde => vr_perde);   

      prc_valida_alteracao(p_motivo   => 'Alterada contem a data da consulta do conjuge / seg. titular ao spc.'
                          ,p_nmcampo  => 'Data consulta conjuge'
                          ,p_dsdadant => r_crapprp.dtoutspc
                          ,p_dsdadatu => pr_dtoutspc
                          ,p_index    => vr_indx
                          ,p_sn_perde => vr_perde); 
    
      prc_valida_alteracao(p_motivo   => 'Alterada data da consulta na central de risco para o conjuge / seg. titular.'
                          ,p_nmcampo  => 'Consulta central risco ara o conjuge / seg. titular.'
                          ,p_dsdadant => r_crapprp.dtoutris
                          ,p_dsdadatu => pr_dtoutris
                          ,p_index    => vr_indx
                          ,p_sn_perde => vr_perde); 
                          
      prc_valida_alteracao(p_motivo   => 'Alterado endividamento do conjuge ou do 2. titular.'
                          ,p_nmcampo  => 'Endivdamento Conjuge/2. titular'
                          ,p_dsdadant => r_crapprp.vlsfnout
                          ,p_dsdadatu => pr_vlsfnout
                          ,p_index    => vr_indx
                          ,p_sn_perde => vr_perde); 

      \** ---------------- Dados Salario/Faturamento -------------------- **\
      prc_valida_alteracao(p_motivo   => 'Alterado valor do salario do associado.'
                          ,p_nmcampo  => 'Salario associado'
                          ,p_dsdadant => r_crapprp.vlsalari
                          ,p_dsdadatu => pr_vlsalari
                          ,p_index    => vr_indx
                          ,p_sn_perde => vr_perde); 
      
      prc_valida_alteracao(p_motivo   => 'Alterado valor das outras rendas.'
                          ,p_nmcampo  => 'Outras rendas'
                          ,p_dsdadant => r_crapprp.vloutras
                          ,p_dsdadatu => pr_vloutras
                          ,p_index    => vr_indx
                          ,p_sn_perde => vr_perde); 

      prc_valida_alteracao(p_motivo   => 'Alterado valor do aluguel.'
                          ,p_nmcampo  => 'Valor do Aluguel'
                          ,p_dsdadant => r_crapprp.vlalugue
                          ,p_dsdadatu => pr_vlalugue
                          ,p_index    => vr_indx
                          ,p_sn_perde => vr_perde); 

      prc_valida_alteracao(p_motivo   => 'Valor do salario do conjuge.'
                          ,p_nmcampo  => 'Salario conjuge'
                          ,p_dsdadant => r_crapprp.vlsalcon
                          ,p_dsdadatu => pr_vlsalcon
                          ,p_index    => vr_indx
                          ,p_sn_perde => vr_perde);     

      prc_valida_alteracao(p_motivo   => 'Alterado nome da empresa onde o conjuge trabalha.'
                          ,p_nmcampo  => 'Empresa conjuge'
                          ,p_dsdadant => r_crapprp.nmempcje
                          ,p_dsdadatu => pr_nmempcje
                          ,p_index    => vr_indx
                          ,p_sn_perde => vr_perde);  

    

      prc_valida_alteracao(p_motivo   => 'Alterado o numero da conta do conjuge.'
                          ,p_nmcampo  => 'Conta conjuge'
                          ,p_dsdadant => r_crapprp.nrctacje
                          ,p_dsdadatu => pr_nrctacje
                          ,p_index    => vr_indx
                          ,p_sn_perde => vr_perde); 

      prc_valida_alteracao(p_motivo   => 'Alterado numero do cpf do conjuge do associado.'
                          ,p_nmcampo  => 'Cpf conjuge'
                          ,p_dsdadant => r_crapprp.nrcpfcje
                          ,p_dsdadatu => pr_nrcpfcje
                          ,p_index    => vr_indx
                          ,p_sn_perde => vr_perde); 

      prc_valida_alteracao(p_motivo   => 'Alterado valor medio do faturamento bruto mensal.'
                          ,p_nmcampo  => 'Faturamento mensal'
                          ,p_dsdadant => r_crapprp.vlmedfat
                          ,p_dsdadatu => pr_vlmedfat
                          ,p_index    => vr_indx
                          ,p_sn_perde => vr_perde); */       

      /** -----------------FIM- Dados para a Proposta -FIM---------------- */
      -- 0 - Não perdeu aprovação e 1 - Perdeu aprovação
      pr_idpeapro := 0;
      if vr_perde = 'S' then
        pr_idpeapro := 1;
        --Grava Log
        prc_grava_log; 
        --Gravar os itens do Log
        FOR x IN 1..vr_tab_alteracoes.count() LOOP
          
         prc_grava_item_log(p_nmcampo  => vr_tab_alteracoes(x).nmcampo,
                            p_nrdrowid => vr_nrdrowid,
                            p_dsdadant => vr_tab_alteracoes(x).dsdadant,
                            p_dsdadatu => vr_tab_alteracoes(x).dsdadatu);
        END LOOP;     
      end if;         
      
      -- Se chegou até o final sem erro retorna OK
      pr_dserro := 'OK';
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_dserro:= 'NOK';
        IF NVL(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        pr_cdcritic := NVL(vr_cdcritic, 0);
        pr_dscritic := substr(vr_dscritic,1,250);
              
      WHEN OTHERS THEN
        pr_dserro:= 'NOK';
        pr_cdcritic := 0;
        pr_dscritic := substr('Erro na procedure EMPR0015.pc_valida_perda_aprov_proposta: ' || SQLERRM,1,250);
    END;

  END pc_valida_perda_aprov_proposta;  

  function zeroToNull(p_valor in number) return varchar2 is
       
  begin
    if to_number(p_valor) = 0 then
      return '';
    else
      return p_valor;
    end if;  
  end;    
  
END EMPR0015;
/
