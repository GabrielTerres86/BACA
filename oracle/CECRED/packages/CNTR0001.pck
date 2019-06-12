CREATE OR REPLACE PACKAGE CECRED.CNTR0001 AS

procedure pc_cria_trans_pend_ctd(pr_nrdconta         IN crapass.nrdconta%TYPE   --> Numero da conta
                                ,pr_tpcontrato       IN tbgar_cobertura_operacao.tpcontrato%TYPE --> Tipo do contrato
                                ,pr_nrcontrato       IN NUMBER --> Numero do contrato 
                                ,pr_vlcontrato       IN NUMBER --> Valor do contrato
                                ,pr_cdrecid_crapcdc  IN NUMBER --> Progress_Recid da tabela CRAPCDC
                                ,pr_contas_digitadas IN VARCHAR2 --> Lista separada por ; com as contas digitadas e válidas
                                ,pr_xmllog           IN VARCHAR2 --> XML com informações de LOG
                                ,pr_cdcritic        OUT PLS_INTEGER --> Código da crítica
                                ,pr_dscritic        OUT VARCHAR2 --> Descrição da crítica
                                ,pr_retxml       IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                ,pr_nmdcampo        OUT VARCHAR2 --> Nome do campo com erro
                                ,pr_des_erro        OUT VARCHAR2);
                                                                
PROCEDURE pc_gera_protocolo_ctd(pr_cdcooper IN NUMBER
                               ,pr_nrdconta IN NUMBER
                               ,pr_cdtippro IN NUMBER
                               ,pr_dhcontrato IN DATE
                               ,pr_nrcontrato IN NUMBER
                               ,pr_vlcontrato IN NUMBER
                               ,pr_dsaprovador IN VARCHAR2
                               ,pr_nrdcaixa IN VARCHAR2
                               ,pr_cdoperad IN VARCHAR2
                               ,pr_idorigem IN VARCHAR2
                               ,pr_dscomplemento IN VARCHAR2 DEFAULT NULL
                               ,pr_cdcritic OUT VARCHAR2 -- Codigo da critica
                               ,pr_dscritic OUT VARCHAR2
                               ,pr_des_erro OUT VARCHAR2
                               ,pr_retxml   IN OUT NOCOPY XMLType);                               

PROCEDURE pc_gera_protocolo_ctd_pj(pr_nrdconta in number
                                  ,pr_cdtippro in number
                                  ,pr_dhcontrato in date
                                  ,pr_nrcontrato in number
                                  ,pr_vlcontrato in number
                                  ,pr_cdtransacao_pendente in number
                                  ,pr_contas_digitadas IN VARCHAR2 DEFAULT NULL --> Lista separada por ; com as contas digitadas e válidas
                                  ,pr_cdcooper_tel in number DEFAULT NULL
                                  ,pr_dscomplemento IN VARCHAR2 DEFAULT NULL
                                  ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2); 

PROCEDURE pc_gera_prot_ctd_pj_prgs(pr_cdcooper in number
                                  ,pr_nrdconta in number
                                  ,pr_cdtippro in number
                                  ,pr_dhcontrato in date
                                  ,pr_nrcontrato in number
                                  ,pr_vlcontrato in number
                                  ,pr_cdtransacao_pendente in number
                                  ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                  ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2); 

procedure pc_gera_protocolo_ctd_pf(pr_nrdconta in number
                                  ,pr_cdtippro in number
                                  ,pr_nrcontrato in number
                                  ,pr_vlcontrato in number
                                  ,pr_dscomplemento IN VARCHAR2 DEFAULT NULL
                                  ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2);
                                  
PROCEDURE pc_ver_protocolo_ctd(pr_cdcooper IN NUMBER
                                ,pr_nrdconta IN NUMBER
                                ,pr_tpcontrato IN NUMBER
                                ,pr_dtmvtolt IN DATE
                                ,pr_cdrecid_crapcdc IN NUMBER
                              ,pr_nrdocmto IN NUMBER
                                ,pr_idexiste OUT NUMBER
                                ,pr_dscritic OUT VARCHAR2);

PROCEDURE pc_ver_protocolo (pr_cdcooper   IN NUMBER
                           ,pr_nrdconta   IN NUMBER
                           ,pr_nrcontrato IN NUMBER
                           ,pr_tpcontrato IN NUMBER
                           ,pr_dsfrase_cooperado   OUT VARCHAR2 --> Código da crítica
                           ,pr_dsfrase_cooperativa OUT VARCHAR2 --> Descrição da crítica
                           );

PROCEDURE pc_novo_num_cnt_limite (pr_nrdconta  IN NUMBER
                                 ,pr_xmllog    IN VARCHAR2
                                 ,pr_cdcritic OUT PLS_INTEGER
                                 ,pr_dscritic OUT VARCHAR2
                                 ,pr_retxml    IN OUT NOCOPY XMLType
                                 ,pr_nmdcampo OUT VARCHAR2
                                 ,pr_des_erro OUT VARCHAR2);

PROCEDURE pc_inativa_protocolo(pr_cdcooper  IN crapcop.cdcooper%TYPE
                              ,pr_nrdconta  IN crapass.nrdconta%TYPE
                              ,pr_cdtippro  IN crappro.cdtippro%TYPE
                              ,pr_nrdocmto  IN crappro.nrdocmto%TYPE
                              ,pr_dscritic OUT VARCHAR2);
END CNTR0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.CNTR0001 AS

--pj
procedure pc_cria_trans_pend_ctd(pr_nrdconta         IN crapass.nrdconta%TYPE   --> Numero da conta
                                ,pr_tpcontrato       IN tbgar_cobertura_operacao.tpcontrato%TYPE --> Tipo do contrato
                                ,pr_nrcontrato       IN NUMBER --> Numero do contrato 
                                ,pr_vlcontrato       IN NUMBER --> Valor do contrato
                                ,pr_cdrecid_crapcdc  IN NUMBER --> Progress_Recid da tabela CRAPCDC
                                ,pr_contas_digitadas IN VARCHAR2 --> Lista separada por ; com as contas digitadas e válidas
                                ,pr_xmllog           IN VARCHAR2 --> XML com informações de LOG
                                ,pr_cdcritic        OUT PLS_INTEGER --> Código da crítica
                                ,pr_dscritic        OUT VARCHAR2 --> Descrição da crítica
                                ,pr_retxml       IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                ,pr_nmdcampo        OUT VARCHAR2 --> Nome do campo com erro
                                ,pr_des_erro        OUT VARCHAR2) is
/*
    Programa : PC_CRIA_TRANS_PEND_CTD
    Sistema  : CECRED
    Autor    : Rubens Lima - Mouts
    Data     : Dezembro/2018.                   Ultima atualizacao: 
  
   Dados referentes ao programa:
  
   Frequencia: Sempre que for chamado
   Objetivo  : Gerar pendência para as operações de contrato
  
   Alteracoes:
   
*/

   --Variaveis
   vr_dscontrato       VARCHAR2(200);
   vr_tab_crapavt      CADA0001.typ_tab_crapavt_58; --Tabela Avalistas 
   vr_tab_crapavt_atu  CADA0001.typ_tab_crapavt_58; --Tabela Avalistas 
   vr_cdtranpe         tbgen_trans_pend.cdtransacao_pendente%TYPE;
   vr_dstransa         VARCHAR2(100);
   vr_nrctapro         crappod.nrctapro%TYPE; --Conta do associado
   vr_nrdconta         crapass.nrdconta%TYPE;
   vr_nrcpfrep         crapass.nrcpfcgc%TYPE;
   vr_lixo             VARCHAR2(100);
   vr_dsaprovador      VARCHAR2(200); -- Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts
   
   -- Rowid tabela de log
   vr_nrdrowid ROWID;

   --Exceção
   vr_exec_erro EXCEPTION;
   vr_exec_saida EXCEPTION;
  
   --Variáveis de crítica
   vr_cdcritic   crapcri.cdcritic%TYPE;
   vr_dscritic   crapcri.dscritic%TYPE;
   vr_dsprotoc   crappro.dsprotoc%TYPE;
   vr_des_erro   VARCHAR2(200);
   
   -- Variaveis de log
   vr_cdcooper crapcop.cdcooper%TYPE;
   vr_cdoperad VARCHAR2(100);
   vr_nmdatela VARCHAR2(100);
   vr_nmeacao  VARCHAR2(100);
   vr_cdagenci VARCHAR2(100);
   vr_nrdcaixa VARCHAR2(100);
   vr_idorigem VARCHAR2(100);
   vr_dsorigem VARCHAR2(1000);
   
   --Variáveis para criar transação operador
   vr_idseqttl  crapttl.idseqttl%TYPE;
   vr_idastcjt  crapass.idastcjt%TYPE;
   vr_nrcpfcgc  crapass.nrcpfcgc%TYPE;
   
   --Cursores--
   --Busca indicador de assinatura conjunta
   CURSOR cr_idastcjt (pr_cdcooper in crapcop.cdcooper%TYPE,
                       pr_nrdconta in crapass.nrdconta%TYPE) IS
   SELECT idastcjt
         ,nrcpfcgc
     FROM crapass
    WHERE cdcooper = pr_cdcooper
      AND nrdconta = pr_nrdconta;
   
BEGIN

   gene0001.pc_informa_acesso(pr_module => 'CNTR0001');

   -- Extrai os dados vindos do XML
   gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                            pr_cdcooper => vr_cdcooper,
                            pr_nmdatela => vr_nmdatela,
                            pr_nmeacao  => vr_nmeacao,
                            pr_cdagenci => vr_cdagenci,
                            pr_nrdcaixa => vr_nrdcaixa,
                            pr_idorigem => vr_idorigem,
                            pr_cdoperad => vr_cdoperad,
                            pr_dscritic => vr_dscritic);

   IF vr_dscritic IS NOT NULL THEN
     vr_dscritic := null;
     vr_cdcooper := 1;
     vr_idorigem := 1;
   END IF;
   
   vr_dsorigem := gene0001.vr_vet_des_origens(vr_idorigem);
   
   --Monta a descrição do contrato
   IF pr_tpcontrato = 25 THEN
      vr_dscontrato := 'Rescisão de Lim. Créd. (Termo)';
   ELSIF pr_tpcontrato = 26 THEN
         vr_dscontrato := 'Solicitação de Portab. Créd. (Termo)';
   ELSIF pr_tpcontrato = 27 THEN
         vr_dscontrato := 'Limite de Desc. Chq. (Contrato)';
   ELSIF pr_tpcontrato = 28 THEN
         vr_dscontrato := 'Limite de Desc. Tit. (Contrato)';
   ELSIF pr_tpcontrato = 29 THEN
         vr_dscontrato := 'Limite de Crédito (Contrato)';
   ELSIF pr_tpcontrato = 30 THEN
         vr_dscontrato := 'Solicitação de Sustação de Chq.';
   ELSIF pr_tpcontrato = 31 THEN
         vr_dscontrato := 'Sol.Canc.de Folha/Tal.de Chq. (Termo)';
   ELSE
         vr_dscritic := 'Tipo de contrato não conhecido - '||'pr_cdtippro'||'.';
         RAISE vr_exec_erro;
   END IF;
   
   --Busca indicador de assinatura conjunta
   OPEN cr_idastcjt (pr_cdcooper => vr_cdcooper,
                     pr_nrdconta => pr_nrdconta);
   FETCH cr_idastcjt
   INTO vr_idastcjt
       ,vr_nrcpfcgc;

   IF cr_idastcjt%NOTFOUND THEN
      vr_dscritic:= 'Não localizou indicador de assinatura conjunta.';
      
      CLOSE cr_idastcjt;
      RAISE vr_exec_erro;
   --
   END IF;
   CLOSE cr_idastcjt;

   BEGIN
     SELECT regexp_substr(pr_contas_digitadas,'[^;]+', 1, LEVEL) AS conta 
       INTO vr_nrdconta
       FROM dual
      WHERE ROWNUM = 1
    CONNECT BY regexp_substr(pr_contas_digitadas, '[^;]+', 1, LEVEL) IS NOT NULL;

     --Busca indicador de assinatura conjunta
     OPEN cr_idastcjt (pr_cdcooper => vr_cdcooper,
                       pr_nrdconta => vr_nrdconta);
     FETCH cr_idastcjt
     INTO vr_lixo
         ,vr_nrcpfrep;

     IF cr_idastcjt%NOTFOUND THEN
        vr_dscritic:= 'Não localizou CPF/CNPJ responsavel.'
                   ||' - Coop: '||vr_cdcooper
                   ||' - Ctas: '||pr_contas_digitadas;
        CLOSE cr_idastcjt;
        RAISE vr_exec_erro;
     END IF;
     CLOSE cr_idastcjt;
   END;

   --INET0002.PC_CRIA_TRANSACAO_OPERADOR
   INET0002.pc_cria_transacao_operador(pr_cdagenci => vr_cdagenci
                                      ,pr_nrdcaixa => vr_nrdcaixa
                                      ,pr_cdoperad => vr_cdoperad
                                      ,pr_nmdatela => vr_nmdatela
                                      ,pr_idorigem => vr_idorigem
                                      ,pr_idseqttl => 1
                                      ,pr_cdcooper => vr_cdcooper
                                      ,pr_nrdconta => pr_nrdconta
                                      ,pr_nrcpfope => 0
                                      ,pr_nrcpfrep => vr_nrcpfrep
                                      ,pr_cdcoptfn => 0
                                      ,pr_cdagetfn => 0
                                      ,pr_nrterfin => 0
                                      ,pr_dtmvtolt => trunc(sysdate)
                                      ,pr_cdtiptra => 20 -- Contratos
                                      ,pr_idastcjt => vr_idastcjt
                                      ,pr_tab_crapavt => vr_tab_crapavt
                                      ,pr_cdtranpe => vr_cdtranpe
                                      ,pr_dscritic => vr_dscritic);

   IF TRIM(vr_dscritic) IS NOT NULL THEN
     RAISE vr_exec_saida;
   END IF;

   --Grava dados da transação de contrato pendente de efetivação
   BEGIN
      INSERT INTO
        TBCTD_TRANS_PEND (
   	       cdtransacao_pendente
          ,cdcooper
          ,nrdconta
          ,tpcontrato
          ,dscontrato
          ,nrcontrato
          ,vlcontrato
          ,dhcontrato
          ,cdoperad
          ,cdrecid_crapcdc)         
      VALUES (
          vr_cdtranpe --retorno da pc_cria_transacao_operador
         ,vr_cdcooper
         ,pr_nrdconta
         ,pr_tpcontrato
         ,vr_dscontrato
         ,pr_nrcontrato
         ,pr_vlcontrato
         ,sysdate
         ,vr_cdoperad
         ,pr_cdrecid_crapcdc);
      EXCEPTION
         WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao incluir registro na tbctd_trans_pend: ' || SQLERRM;
            RAISE vr_exec_saida;
   END;

   --Faz uma copia da crapavt salvando apenas os registros necessarios para a pc_cria_aprova_transpend
   for i in 1..vr_tab_crapavt.count loop
       vr_tab_crapavt_atu(i).idrspleg := vr_tab_crapavt(i).idrspleg;
       vr_tab_crapavt_atu(i).nrcpfcgc := vr_tab_crapavt(i).nrcpfcgc;
       vr_tab_crapavt_atu(i).nmdavali := vr_tab_crapavt(i).nmdavali;
   end loop;
   
   INET0002.pc_cria_aprova_transpend(pr_cdagenci => vr_cdagenci
                                    ,pr_nrdcaixa => vr_nrdcaixa
                                    ,pr_cdoperad => vr_cdoperad
                                    ,pr_nmdatela => vr_nmdatela
                                    ,pr_idorigem => vr_idorigem
                                    ,pr_idseqttl => vr_idseqttl
                                    ,pr_cdcooper => vr_cdcooper
                                    ,pr_nrdconta => pr_nrdconta
                                    ,pr_nrcpfrep => 0
                                    ,pr_dtmvtolt => trunc(sysdate)
                                    ,pr_cdtiptra => 20 -- Contratos 
                                    ,pr_tab_crapavt => vr_tab_crapavt_atu
                                    ,pr_cdtranpe => vr_cdtranpe
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic);
                            
    --Para cada conta recebida via parametro com separador ;
    BEGIN
    FOR r1 IN (SELECT regexp_substr(pr_contas_digitadas,'[^;]+', 1, LEVEL) AS conta FROM dual
               CONNECT BY regexp_substr(pr_contas_digitadas, '[^;]+', 1, LEVEL) IS NOT NULL) LOOP
               vr_nrctapro := r1.conta;
               --
               FOR r1 IN cr_idastcjt (pr_cdcooper => vr_cdcooper
                                     ,pr_nrdconta => vr_nrctapro)
               LOOP
                 --Aprova transação pendente
                 UPDATE tbgen_aprova_trans_pend
                    SET idsituacao_aprov        = 2 --Aprovado
                  WHERE cdtransacao_pendente    = vr_cdtranpe
                    AND cdcooper                = vr_cdcooper
                    AND nrcpf_responsavel_aprov = r1.nrcpfcgc;
/*                 
                 --Se não conseguiu localizar a conta para aprovar, aborta com mensagem de erro
                 IF sql%rowcount=0 THEN
                    vr_cdcritic:='0';
                    vr_dscritic:='Erro ao aprovar a transacao pendente '||vr_cdtranpe||' nrdconta: '||vr_nrctapro||' cdcooper: '||vr_cdcooper ;
                    raise vr_exec_erro;
                 END IF;
*/
               END LOOP;
    END LOOP;
    EXCEPTION
      WHEN OTHERS THEN
      vr_cdcritic:='0';
      vr_dscritic:='Erro ao tratar os registros das contas recebidas --> '||pr_contas_digitadas;
      raise vr_exec_erro;
    END;
     
    vr_dstransa := 'Aprovação de transação de propostos pendentes';
    GENE0001.pc_gera_log( pr_cdcooper => vr_cdcooper
                         ,pr_cdoperad => vr_cdoperad 
                         ,pr_dscritic => ''         
                         ,pr_dsorigem => vr_dsorigem
                         ,pr_dstransa => vr_dstransa
                         ,pr_dttransa => trunc(sysdate)
                         ,pr_flgtrans => 1
                         ,pr_hrtransa => gene0002.fn_busca_time
                         ,pr_idseqttl => 1
                         ,pr_nmdatela => vr_nmdatela
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_nrdrowid => vr_nrdrowid);

    --Gera log da transação que foi aprovada                           
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                              pr_nmdcampo => 'Codigo da Transacao Pendente Aprovada', 
                              pr_dsdadant => '',
                              pr_dsdadatu => vr_cdtranpe);
                              
   EXCEPTION
     WHEN vr_exec_erro THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>'); 
     WHEN OTHERS THEN
        cecred.pc_internal_exception(3);
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em CNTR0001.PC_CRIA_TRANS_PEND - '||sqlerrm;
        pr_des_erro := 'NOK';
          
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');                              

END pc_cria_trans_pend_ctd;

PROCEDURE pc_gera_protocolo_ctd(pr_cdcooper IN NUMBER
                               ,pr_nrdconta IN NUMBER
                               ,pr_cdtippro IN NUMBER
                               ,pr_dhcontrato IN DATE
                               ,pr_nrcontrato IN NUMBER
                               ,pr_vlcontrato IN NUMBER
                               ,pr_dsaprovador IN VARCHAR2
                               ,pr_nrdcaixa IN VARCHAR2
                               ,pr_cdoperad IN VARCHAR2
                               ,pr_idorigem IN VARCHAR2
                               ,pr_dscomplemento IN VARCHAR2 DEFAULT NULL
                               ,pr_cdcritic OUT VARCHAR2 -- Codigo da critica
                               ,pr_dscritic OUT VARCHAR2 -- Descrição da critica
                               ,pr_des_erro OUT VARCHAR2 -- Descrião do erro
                               ,pr_retxml   IN OUT NOCOPY XMLType) is --Descricao da critica
/*
    Programa : PC_GERA_PROTOCOLO_CTD
    Sistema  : CECRED
    Autor    : Rubens Lima - Mouts
    Data     : Dezembro/2018.                   Ultima atualizacao: 
  
   Dados referentes ao programa:
  
   Frequencia: 
   Objetivo  : Gerar protocolo de Solicitação de Contrato
  
   Alteracoes:
*/
 --Variáveis
   vr_nmprintl crapass.nmprimtl%TYPE;  
   vr_nrdrowid ROWID;

 --Variáveis para descrição do protocolo
   vr_dsinfor1   varchar2(100);
   vr_dsinfor2   varchar2(100);
   vr_dsinfor3   varchar2(1000);

   --Exceção
   vr_exc_erro exception;
   vr_exc_sair exception;
   
   --Variáveis de crítica
   vr_cdcritic   crapcri.cdcritic%TYPE;
   vr_dscritic   crapcri.dscritic%TYPE;
   vr_dsprotoc  crappro.dsprotoc%TYPE;
   vr_des_erro  varchar2(200);
                                      
BEGIN

   --Monta a descrição de acordo com o tipo
   IF pr_cdtippro = 25 THEN
      vr_dsinfor1 := 'Rescisão de Lim. Créd. (Termo)';
   ELSIF pr_cdtippro = 26 THEN
      vr_dsinfor1 := 'Solicitação de Portab. Créd. (Termo)';
   ELSIF pr_cdtippro = 27 THEN
      vr_dsinfor1 := 'Limite de Desc. Chq. (Contrato)';
   ELSIF pr_cdtippro = 28 THEN
      vr_dsinfor1 := 'Limite de Desc. Tit. (Contrato)';
   ELSIF pr_cdtippro = 29 THEN
      vr_dsinfor1 := 'Limite de Crédito (Contrato)';
   ELSIF pr_cdtippro = 30 THEN
      vr_dsinfor1 := 'Solicitação de Sustação de Chq.';
   ELSIF pr_cdtippro = 31 THEN
      vr_dsinfor1 := 'Sol.Canc.de Folha/Tal.de Chq. (Termo)';
   ELSE
      vr_dscritic := 'Tipo de contrato não conhecido - '||pr_cdtippro||'.';
      RAISE vr_exc_erro;
   END IF;
 
  --Seleciona nome do associado
  BEGIN
    
    SELECT nmprimtl
    INTO vr_nmprintl
    FROM crapass
    WHERE cdcooper = pr_cdcooper
    AND nrdconta = pr_nrdconta;
  EXCEPTION
    WHEN OTHERS THEN
      vr_nmprintl := '-';
  END;
  
               --vr_nmextttl  
  vr_dsinfor2 := SUBSTR(vr_nmprintl,40)||'#' || TO_CHAR(pr_dhcontrato,'DD/MM/YYYY') ||'#'|| TO_CHAR(pr_dhcontrato,'HH24:MI:SS');
  
  IF pr_cdtippro IN (30,31) THEN
    vr_dsinfor2 := vr_dsinfor2 ||'#'||pr_dscomplemento;
  END IF;

  vr_dsinfor3 := 'Documento autorizado mediante digitação de senha por:' || pr_dsaprovador;
    --
  -- Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts
  pc_inativa_protocolo(pr_cdcooper  => pr_cdcooper
                      ,pr_nrdconta  => pr_nrdconta
                      ,pr_cdtippro  => pr_cdtippro
                      ,pr_nrdocmto  => pr_nrcontrato
                      ,pr_dscritic  => vr_dscritic);
  -- Fim Pj470 - SM2
   --Gerar protocolo
   GENE0006.pc_gera_protocolo(pr_cdcooper => pr_cdcooper --> Código da cooperativa
                             ,pr_dtmvtolt => trunc(SYSDATE) --> Data Aprovação
                             ,pr_hrtransa => TO_CHAR(sysdate,'SSSSS') --> Hora Aprovação
                             ,pr_nrdconta => pr_nrdconta --> Número da conta
                             ,pr_nrdocmto => pr_nrcontrato --> Número do documento 
                             ,pr_nrseqaut => 1             --> Número da sequencia
                             ,pr_vllanmto => pr_vlcontrato --> Valor lançamento
                             ,pr_nrdcaixa => pr_nrdcaixa --> Número do caixa NOK
                             ,pr_gravapro => TRUE --> Controle de gravação
                             ,pr_cdtippro => pr_cdtippro --> Código de operação
                             ,pr_dsinfor1 => vr_dsinfor1 --> Descrição 1
                             ,pr_dsinfor2 => vr_dsinfor2 --> Descrição 2
                             ,pr_dsinfor3 => vr_dsinfor3 --> Descrição 3
                             ,pr_dscedent => NULL --> Descritivo
                             ,pr_flgagend => FALSE --> Controle de agenda
                             ,pr_nrcpfope => 0 --> Número de operação
                             ,pr_nrcpfpre => 0 --> Número pré operação
                             ,pr_nmprepos => NULL --> Nome
                             ,pr_dsprotoc => vr_dsprotoc --> Descrição do protocolo
                             ,pr_dscritic => vr_dscritic --> Descrição crítica
                             ,pr_des_erro => vr_des_erro); --> Descrição dos erros de processo
  
   --Se ocorreu erro
   IF vr_des_erro = 'NOK' THEN
      RAISE vr_exc_erro;
   END IF;
   -- Gerar log ao cooperado - VERLOG
   GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                       ,pr_cdoperad => NVL(pr_cdoperad,1)
                       ,pr_dscritic => NULL
                       ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem)
                       ,pr_dstransa => 'Documento autorizado mediante digitação de senha!'
                       ,pr_dttransa => TRUNC(SYSDATE)
                       ,pr_flgtrans => 1 -- Transação OK
                       ,pr_hrtransa => gene0002.fn_busca_time
                       ,pr_idseqttl => 1
                       ,pr_nmdatela => 'AUTCTD'
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_nrdrowid => vr_nrdrowid);
   GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                            ,pr_nmdcampo => 'Aprovador'
                            ,pr_dsdadant => NULL
                            ,pr_dsdadatu => SUBSTR(pr_dsaprovador,2,LENGTH(pr_dsaprovador)));
   GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                            ,pr_nmdcampo => 'Tipo de Documento'
                            ,pr_dsdadant => NULL
                            ,pr_dsdadatu => vr_dsinfor1);
   GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                            ,pr_nmdcampo => 'Nr.Documento'
                            ,pr_dsdadant => NULL
                            ,pr_dsdadatu => pr_nrcontrato);
                            
   EXCEPTION
     WHEN vr_exc_sair THEN
       NULL;
     WHEN vr_exc_erro THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        pr_des_erro := 'NOK';

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>'); 
     WHEN OTHERS THEN
        cecred.pc_internal_exception(3);
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em CNTR0001.PC_GERA_PROTOCOLO_CTD - '||SQLERRM;
        pr_des_erro := 'NOK';
          
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');

END pc_gera_protocolo_ctd;  

PROCEDURE pc_gera_protocolo_ctd_pj(pr_nrdconta in number
                                  ,pr_cdtippro in number
                                  ,pr_dhcontrato in date
                                  ,pr_nrcontrato in number
                                  ,pr_vlcontrato in number
                                  ,pr_cdtransacao_pendente in number
                                  ,pr_contas_digitadas IN VARCHAR2 DEFAULT NULL --> Lista separada por ; com as contas digitadas e válidas
                                  ,pr_cdcooper_tel in number DEFAULT NULL
                                  ,pr_dscomplemento IN VARCHAR2 DEFAULT NULL
                                  ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2) is

/*
    Programa : PC_GERA_PROTOCOLO_CTD_PJ
    Sistema  : AYLLOS
    Sigla    : 
    Autor    : Rubens Lima - Mouts
    Data     : Dezembro/2018.                   Ultima atualizacao: 
  
   Dados referentes ao programa:
  
   Frequencia: Sempre que for chamado
   Objetivo  : Gerar protocolo Pessoa Juritica
  
   Alteracoes:
*/

   --Variáveis
   vr_dsaprovador VARCHAR2(200);
   
   -- Variável de críticas
   vr_cdcritic crapcri.cdcritic%TYPE := 0;
   vr_dscritic VARCHAR2(4000);

   --Exceção
   vr_exc_erro exception;
   
   -- Variaveis de log
   vr_cdcooper crapcop.cdcooper%type;
   vr_cdoperad VARCHAR2(100);
   vr_nmdatela VARCHAR2(100);
   vr_nmeacao  VARCHAR2(100);
   vr_cdagenci VARCHAR2(100);
   vr_nrdcaixa VARCHAR2(100);
   vr_idorigem VARCHAR2(100);
   vr_dsorigem VARCHAR2(1000);
                                 
BEGIN
    gene0001.pc_informa_acesso(pr_module => 'CNTR0001');

    IF pr_cdcooper_tel IS NOT NULL THEN
      vr_cdcooper := pr_cdcooper_tel;
      vr_idorigem := 1;
    ELSE
      -- Extrai os dados vindos do XML
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcooper,
                               pr_nmdatela => vr_nmdatela,
                               pr_nmeacao  => vr_nmeacao,
                               pr_cdagenci => vr_cdagenci,
                               pr_nrdcaixa => vr_nrdcaixa,
                               pr_idorigem => vr_idorigem,
                               pr_cdoperad => vr_cdoperad,
                               pr_dscritic => vr_dscritic);

      IF vr_dscritic IS NOT NULL THEN
        vr_dscritic := null;
        vr_cdcooper := 1;
        vr_idorigem := 1;
        vr_cdoperad := 1;
      END IF;
   END IF;
   
   vr_dsorigem := gene0001.vr_vet_des_origens(vr_idorigem);    

   vr_dsaprovador := CHR(10);
   --
   IF pr_cdtransacao_pendente IS NOT NULL THEN
     FOR r1 IN (SELECT gene0002.fn_mask_cpf_cnpj(nrcpf_responsavel_aprov
                      ,(CASE 
                        WHEN LENGTH(nrcpf_responsavel_aprov)<=11 THEN 
                          1 
                        ELSE 
                          2 
                        END))
                        ||' - '|| o.nmprimtl as nmpessoa
                       ,p.cdoperad
                  FROM tbgen_trans_pend l
                      ,tbgen_aprova_trans_pend m
                      ,crapavt n
                      ,crapass o
                      ,tbctd_trans_pend p
                 WHERE l.cdtransacao_pendente = pr_cdtransacao_pendente
                   AND m.cdtransacao_pendente = l.cdtransacao_pendente
                   AND m.nrdconta = l.nrdconta
                   AND n.cdcooper (+) = m.cdcooper
                   AND n.nrdconta (+) = m.nrdconta
                   AND n.nrcpfcgc (+) = m.nrcpf_responsavel_aprov
                   AND o.cdcooper = n.cdcooper
                   AND o.nrdconta = n.nrdctato
                   AND p.cdtransacao_pendente = l.cdtransacao_pendente
                )
     LOOP
       vr_dsaprovador := vr_dsaprovador || r1.nmpessoa || CHR(10);
       vr_cdoperad    := r1.cdoperad;
     END LOOP;
   ELSE
     FOR r2 IN (SELECT regexp_substr(pr_contas_digitadas,'[^;]+', 1, LEVEL) AS nrdconta
                  FROM dual CONNECT BY regexp_substr(pr_contas_digitadas, '[^;]+', 1, LEVEL) IS NOT NULL)
     LOOP
       FOR r3 IN (SELECT gene0002.fn_mask_cpf_cnpj(a.nrcpfcgc,a.inpessoa)||' - '|| a.nmprimtl nmpessoa
                    FROM crapass a
                   WHERE a.cdcooper = vr_cdcooper
                     AND a.nrdconta = r2.nrdconta)
       LOOP
         vr_dsaprovador := vr_dsaprovador || r3.nmpessoa || CHR(10);
       END LOOP;
     END LOOP;
   END IF;
   --Gerar protocolo
   CNTR0001.pc_gera_protocolo_ctd (pr_cdcooper => vr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_cdtippro => pr_cdtippro
                                  ,pr_dhcontrato => NVL(pr_dhcontrato,sysdate)
                                  ,pr_nrcontrato => pr_nrcontrato
                                  ,pr_vlcontrato => pr_vlcontrato
                                  ,pr_dsaprovador => vr_dsaprovador
                                  ,pr_nrdcaixa => vr_nrdcaixa
                                  ,pr_cdoperad => vr_cdoperad
                                  ,pr_idorigem => vr_idorigem
                                  ,pr_dscomplemento => pr_dscomplemento
                                  ,pr_cdcritic => vr_cdcritic --OUT código da crítica
                                  ,pr_dscritic => vr_dscritic
                                  ,pr_des_erro => pr_des_erro
                                  ,pr_retxml => pr_retxml); -- descrição da crítica

   --Se ocorreu erro
   IF pr_des_erro = 'NOK' THEN
      RAISE vr_exc_erro;
   END IF; 

   EXCEPTION
     WHEN vr_exc_erro THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>'); 
     WHEN OTHERS THEN
      cecred.pc_internal_exception(3);
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral em CNTR0001.PC_GERA_PROTOCOLO_CTD_PJ '||sqlerrm;
      pr_des_erro := 'NOK';
          
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic ||
                                     '</Erro></Root>');
  
END pc_gera_protocolo_ctd_pj;   

-- Procedure para ser chamada pelo PROGRESS
PROCEDURE pc_gera_prot_ctd_pj_prgs(pr_cdcooper in number
                                  ,pr_nrdconta in number
                                  ,pr_cdtippro in number
                                  ,pr_dhcontrato in date
                                  ,pr_nrcontrato in number
                                  ,pr_vlcontrato in number
                                  ,pr_cdtransacao_pendente in number
                                  ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                  ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2) IS
  vr_retxml XMLType;
BEGIN
  pc_gera_protocolo_ctd_pj(pr_nrdconta             => pr_nrdconta
                          ,pr_cdtippro             => pr_cdtippro
                          ,pr_dhcontrato           => pr_dhcontrato
                          ,pr_nrcontrato           => pr_nrcontrato
                          ,pr_vlcontrato           => pr_vlcontrato
                          ,pr_cdtransacao_pendente => pr_cdtransacao_pendente
                          ,pr_contas_digitadas     => NULL
                          ,pr_cdcooper_tel         => pr_cdcooper
                          ,pr_xmllog               => pr_xmllog
                          ,pr_cdcritic             => pr_cdcritic
                          ,pr_dscritic             => pr_dscritic
                          ,pr_retxml               => vr_retxml
                          ,pr_nmdcampo             => pr_nmdcampo
                          ,pr_des_erro             => pr_des_erro);
END pc_gera_prot_ctd_pj_prgs;

PROCEDURE pc_gera_protocolo_ctd_pf(pr_nrdconta in number
                                  ,pr_cdtippro in number
                                  ,pr_nrcontrato in number
                                  ,pr_vlcontrato in number
                                  ,pr_dscomplemento IN VARCHAR2 DEFAULT NULL
                                  ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2) IS
/*
    Programa : PC_GERA_PROTOCOLO_CTD_PF
    Sistema  : AYLLOS
    Sigla    : 
    Autor    : Rubens Lima - Mouts
    Data     : Dezembro/2018.                   Ultima atualizacao: 
  
   Dados referentes ao programa:
  
   Frequencia: Sempre que for chamado
   Objetivo  : Gerar protocolo Pessoa Fisica
  
   Alteracoes:
   
*/                                   

  /* Aprovador do associado da conta */
  CURSOR cr_aprovador (pr_cdcooper IN crapass.cdcooper%TYPE
                      ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT CHR(10) || gene0002.fn_mask_cpf_cnpj(a.nrcpfcgc,1)||' - '|| a.nmextttl nmpessoa
    FROM crapttl a
    WHERE a.cdcooper = pr_cdcooper
    AND a.nrdconta = pr_nrdconta
    AND a.idseqttl = 1;

   --Variáveis
   vr_dsaprovador VARCHAR2(200);
   vr_dhcontrato  DATE;
   
   -- Variável de críticas
   vr_cdcritic crapcri.cdcritic%TYPE := 0;
   vr_dscritic VARCHAR2(4000);

   --Exceção
   vr_exc_erro EXCEPTION;
   
   -- Variaveis de log
   vr_cdcooper crapcop.cdcooper%TYPE;
   vr_cdoperad VARCHAR2(100);
   vr_nmdatela VARCHAR2(100);
   vr_nmeacao  VARCHAR2(100);
   vr_cdagenci VARCHAR2(100);
   vr_nrdcaixa VARCHAR2(100);
   vr_idorigem NUMBER;
   vr_dsorigem VARCHAR2(1000);

BEGIN
    
    vr_dhcontrato := SYSDATE;
 
    gene0001.pc_informa_acesso(pr_module => 'CNTR0001');

    -- Extrai os dados vindos do XML
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);

   IF vr_dscritic IS NOT NULL THEN
     vr_dscritic := null;
     vr_cdcooper := 1;
     vr_idorigem := 1;
   END IF;
   
   vr_dsorigem := gene0001.vr_vet_des_origens(vr_idorigem);
   
   --Consultar aprovador
   OPEN cr_aprovador(pr_cdcooper => vr_cdcooper,
                     pr_nrdconta => pr_nrdconta);
   FETCH cr_aprovador INTO vr_dsaprovador;

   --Se nao encontrou 
   IF cr_aprovador%NOTFOUND THEN 
      --Fechar Cursor
      CLOSE cr_aprovador;   
           
      --Registro não encontrado na CRAPTTL
      vr_cdcritic:= 564;
      vr_dscritic:= GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || ' na tabela CRAPTTL';
      --Levantar Excecao
      RAISE vr_exc_erro;
   END IF;
   --Fechar Cursor
   CLOSE cr_aprovador;
   
   --Gerar protocolo
   CNTR0001.pc_gera_protocolo_ctd (pr_cdcooper => vr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_cdtippro => pr_cdtippro
                                  ,pr_dhcontrato => vr_dhcontrato
                                  ,pr_nrcontrato => pr_nrcontrato
                                  ,pr_vlcontrato => pr_vlcontrato
                                  ,pr_dsaprovador => vr_dsaprovador
                                  ,pr_nrdcaixa => vr_nrdcaixa
                                  ,pr_cdoperad => vr_cdoperad
                                  ,pr_idorigem => vr_idorigem
                                  ,pr_dscomplemento => pr_dscomplemento
                                  ,pr_cdcritic => vr_cdcritic --OUT código da crítica
                                  ,pr_dscritic => vr_dscritic
                                  ,pr_des_erro => pr_des_erro
                                  ,pr_retxml => pr_retxml); -- descrição da crítica
   --Se ocorreu erro
   IF pr_des_erro = 'NOK' THEN
      RAISE vr_exc_erro;
   END IF; 

   EXCEPTION
     WHEN vr_exc_erro THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>'); 
     WHEN OTHERS THEN
        cecred.pc_internal_exception(3);
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em CNTR0001.PC_GERA_PROTOCOLO_CTD_PF - '||sqlerrm;
        pr_des_erro := 'NOK';
          
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');


END pc_gera_protocolo_ctd_pf;

PROCEDURE pc_ver_protocolo_ctd(pr_cdcooper IN NUMBER
                                ,pr_nrdconta IN NUMBER
                                ,pr_tpcontrato IN NUMBER
                                ,pr_dtmvtolt IN DATE
                                ,pr_cdrecid_crapcdc IN NUMBER
                              ,pr_nrdocmto IN NUMBER
                                ,pr_idexiste OUT NUMBER
                                ,pr_dscritic OUT VARCHAR2) IS
   vr_exc_saida EXCEPTION;
BEGIN
   pr_idexiste := 0;
   
   -- verificar se já foi gerado o protocolo
   BEGIN
     SELECT 1
       INTO pr_idexiste
       FROM crappro a
      WHERE a.cdcooper = pr_cdcooper
        AND a.nrdconta = pr_nrdconta
        AND a.cdtippro = pr_tpcontrato
        AND a.dtmvtolt = pr_dtmvtolt
        AND a.nrdocmto = pr_nrdocmto
        AND ((pr_cdrecid_crapcdc IS NULL)
          OR (pr_cdrecid_crapcdc IS NOT NULL AND a.dsinform##3 LIKE '%'||pr_cdrecid_crapcdc||'%'))
        AND a.flgativo = 1;
   EXCEPTION
   WHEN OTHERS THEN
     NULL;
   END;
   --
   IF pr_idexiste = 1 THEN
     RAISE vr_exc_saida;
   END IF;
   -- verificar se existe pendência para IB/Mobile
   BEGIN
     SELECT 1
       INTO pr_idexiste
       FROM tbctd_trans_pend a
      WHERE a.cdcooper               = pr_cdcooper
        AND a.nrdconta               = pr_nrdconta
        AND a.tpcontrato             = pr_tpcontrato
        AND TRUNC(a.dhcontrato)      = pr_dtmvtolt
        AND a.nrcontrato             = pr_nrdocmto
        AND NVL(a.cdrecid_crapcdc,0) = NVL(pr_cdrecid_crapcdc,nvl(a.cdrecid_crapcdc,0));
   EXCEPTION
   WHEN OTHERS THEN
     NULL;
   END;
 EXCEPTION
    WHEN vr_exc_saida THEN
  NULL;

END pc_ver_protocolo_ctd;

PROCEDURE pc_ver_protocolo (pr_cdcooper   IN NUMBER
                           ,pr_nrdconta   IN NUMBER
                           ,pr_nrcontrato IN NUMBER
                           ,pr_tpcontrato IN NUMBER
                           ,pr_dsfrase_cooperado   OUT VARCHAR2 --> Código da crítica
                           ,pr_dsfrase_cooperativa OUT VARCHAR2 --> Descrição da crítica
                           ) IS
   --Cursor para buscar o protocolo do contrato 
   CURSOR cr_protocolo (pr_cdcooper   IN NUMBER
                       ,pr_nrdconta   IN NUMBER
                       ,pr_nrcontrato IN NUMBER
                       ,pr_tpcontrato IN NUMBER) IS
     SELECT TRIM(gene0002.fn_busca_entrada(2,dsinform##2, '#')) dtprotocolo
           ,TRIM(gene0002.fn_busca_entrada(3,dsinform##2, '#')) hrprotocolo
           ,REPLACE(
            SUBSTR(dsinform##3,LENGTH('Documento autorizado mediante digitação de senha por:')+2,length(dsinform##3)-2
                             - LENGTH('Documento autorizado mediante digitação de senha por:')),CHR(10),', ') dscontratante
       FROM crappro
      WHERE cdcooper = pr_cdcooper
        AND nrdconta = pr_nrdconta
        AND cdtippro = pr_tpcontrato
        AND nrdocmto = pr_nrcontrato
        AND flgativo = 1;

   -- Cursor para buscar o nome da cooperativa
   CURSOR cr_crapcop (pr_cdcooper IN NUMBER) IS
   SELECT nmextcop
     FROM crapcop
    WHERE cdcooper = pr_cdcooper;

   -- Cursor para buscar o protocolo do contrato 
   CURSOR cr_efetivacao (pr_cdcooper   IN NUMBER
                        ,pr_nrdconta   IN NUMBER
                        ,pr_nrcontrato IN NUMBER
                        ,pr_tpcontrato IN NUMBER) IS
     SELECT TO_CHAR(dtinivig,'dd/mm/yyyy') dtvigencia
           ,null hrvigencia
       FROM craplim
      WHERE cdcooper = pr_cdcooper
        AND nrdconta = pr_nrdconta
        AND nrctrlim = pr_nrcontrato
        AND pr_tpcontrato IN (25 -- Rescisão de Lim. Créd. (Termo)
                             ,27 -- Limite de Desc. Chq. (Contrato)
                             ,28 -- Limite de Desc. Tit. (Contrato)
                             ,29)-- Limite de Crédito (Contrato)
     UNION
     SELECT TO_CHAR(dtaprova,'dd/mm/yyyy') dtvigencia
           ,TO_CHAR(TO_DATE(hraprova,'sssss'),'hh24:mi:ss') hrvigencia
       FROM crawepr a
      WHERE cdcooper = pr_cdcooper
        AND nrdconta = pr_nrdconta
        AND nrctremp = pr_nrcontrato
        AND insitapr = 2
        AND pr_tpcontrato = 26; -- Solicitação de Portab. Créd. (Termo)
  -- Variaveis de trabalho
  vr_dtprotocolo   VARCHAR2(100);
  vr_hrprotocolo   VARCHAR2(100);
  vr_dscontratante VARCHAR2(4000);
  vr_dtvigencia    VARCHAR2(100);
  vr_hrvigencia    VARCHAR2(100);
  vr_nmextcop      VARCHAR2(100);
BEGIN
  -- Buscar o protocolo do contrato
  vr_dtprotocolo   := NULL;
  vr_hrprotocolo   := NULL;
  vr_dscontratante := NULL;
  vr_dtvigencia    := NULL;
  vr_hrvigencia    := NULL;
  OPEN cr_protocolo (pr_cdcooper   => pr_cdcooper
                    ,pr_nrdconta   => pr_nrdconta
                    ,pr_nrcontrato => pr_nrcontrato
                    ,pr_tpcontrato => pr_tpcontrato);
  FETCH cr_protocolo
   INTO vr_dtprotocolo
       ,vr_hrprotocolo
       ,vr_dscontratante;
  CLOSE cr_protocolo;
  --
  IF vr_dtprotocolo IS NOT NULL THEN
    pr_dsfrase_cooperado := 'Assinado eletronicamente pelo CONTRATANTE '
                         || vr_dscontratante
                         || ', no dia '
                         || vr_dtprotocolo
                         || CASE WHEN pr_tpcontrato = 25 THEN ', as ' ELSE ', às ' END -- Relatório em progress não pode ter acentuação
                         || vr_hrprotocolo
                         || CASE WHEN pr_tpcontrato = 25 THEN ', mediante aposicao de senha numerica.' ELSE ', mediante aposição de senha numérica.' END; -- Relatório em progress não pode ter acentuação
    OPEN cr_crapcop (pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop
     INTO vr_nmextcop;
    CLOSE cr_crapcop;
    --
    OPEN cr_efetivacao (pr_cdcooper   => pr_cdcooper
                       ,pr_nrdconta   => pr_nrdconta
                       ,pr_nrcontrato => pr_nrcontrato
                       ,pr_tpcontrato => pr_tpcontrato);
    FETCH cr_efetivacao
     INTO vr_dtvigencia
         ,vr_hrvigencia;
    CLOSE cr_efetivacao;
    --
    IF vr_dtvigencia IS NOT NULL THEN
      pr_dsfrase_cooperativa := 'Assinado eletronicamente pela COOPERATIVA '
                             || vr_nmextcop
                             || ', no dia '
                             || vr_dtvigencia
                             || CASE WHEN vr_hrvigencia IS NOT NULL THEN CASE WHEN pr_tpcontrato = 25 THEN ', as ' ELSE ', às ' END || vr_hrvigencia END
                             || '.';
    ELSE
      pr_dsfrase_cooperativa := 'Contrato ainda não efetivado pela COOPERATIVA '||vr_nmextcop||'.';
    END IF;
  ELSE
    pr_dsfrase_cooperado := '*'; --> Enviar 1 Asterisco para que o JASPER/Progress possa identificar que não tem protocolo gerado
  END IF;
  
END pc_ver_protocolo;

PROCEDURE pc_novo_num_cnt_limite (pr_nrdconta  IN NUMBER
                                 ,pr_xmllog    IN VARCHAR2
                                 ,pr_cdcritic OUT PLS_INTEGER
                                 ,pr_dscritic OUT VARCHAR2
                                 ,pr_retxml    IN OUT NOCOPY XMLType
                                 ,pr_nmdcampo OUT VARCHAR2
                                 ,pr_des_erro OUT VARCHAR2) IS
  -- Projeto 470 - SM 2
  -- MArcelo Telles Coelho
  -- Buscar um número do contrato de limite de crédito livre para a Cooperativa/Conta
  --
  -- Cursor para verificar se contrato já existe para a CDCOOPER/NRDCONTA
  CURSOR cr_craplim (pr_cdcooper   IN NUMBER
                    ,pr_nrdconta   IN NUMBER
                    ,pr_nrctrlim   IN NUMBER) IS
    SELECT 1 idexiste
      FROM craplim a
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta
       AND nrctrlim = pr_nrctrlim;
  --
  vr_idexiste NUMBER;
  vr_nrctrlim NUMBER;
   -- Variaveis de log
  vr_cdcooper crapcop.cdcooper%TYPE;
  vr_cdoperad VARCHAR2(100);
  vr_nmdatela VARCHAR2(100);
  vr_nmeacao  VARCHAR2(100);
  vr_cdagenci VARCHAR2(100);
  vr_nrdcaixa VARCHAR2(100);
  vr_idorigem NUMBER;
  vr_dsorigem VARCHAR2(1000);
BEGIN
  gene0001.pc_informa_acesso(pr_module => 'CNTR0001');
  -- Extrai os dados vindos do XML
  gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                          ,pr_cdcooper => vr_cdcooper
                          ,pr_nmdatela => vr_nmdatela
                          ,pr_nmeacao  => vr_nmeacao
                          ,pr_cdagenci => vr_cdagenci
                          ,pr_nrdcaixa => vr_nrdcaixa
                          ,pr_idorigem => vr_idorigem
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => pr_dscritic);

  IF pr_dscritic IS NOT NULL THEN
    pr_dscritic := null;
    vr_cdcooper := 1;
    vr_idorigem := 1;
  END IF;
  --
  LOOP
    vr_nrctrlim := fn_sequence('CRAPLIM'
                              ,'NRCTRLIM'
                              ,TO_CHAR(vr_cdcooper));
    OPEN cr_craplim(pr_cdcooper => vr_cdcooper
                   ,pr_nrdconta => pr_nrdconta
                   ,pr_nrctrlim => vr_nrctrlim);
    FETCH cr_craplim INTO vr_idexiste;
    --Se nao encontrou 
    IF cr_craplim%NOTFOUND THEN
      CLOSE cr_craplim;
      EXIT;
    END IF;
    CLOSE cr_craplim;
  END LOOP;
  --
  pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
  --
  gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => pr_dscritic);
  gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'nrctrlim', pr_tag_cont => to_char(vr_nrctrlim), pr_des_erro => pr_dscritic);
  --
END pc_novo_num_cnt_limite;

PROCEDURE pc_inativa_protocolo(pr_cdcooper  IN crapcop.cdcooper%TYPE
                              ,pr_nrdconta  IN crapass.nrdconta%TYPE
                              ,pr_cdtippro  IN crappro.cdtippro%TYPE
                              ,pr_nrdocmto  IN crappro.nrdocmto%TYPE
                              ,pr_dscritic OUT VARCHAR2) IS
 -- Cursor
 -- Buscar protocolos ativos
 -- Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts
  CURSOR cr_crappro (pr_cdcooper in crapcop.cdcooper%TYPE,
                     pr_nrdconta in crapass.nrdconta%TYPE,
                     pr_nrdocmto in crappro.nrdocmto%TYPE,
                     pr_cdtippro IN NUMBER) IS
  SELECT rowid dsrosid_crappro
    FROM crappro
   WHERE cdcooper = pr_cdcooper
     AND nrdconta = pr_nrdconta
     AND cdtippro = pr_cdtippro
     AND nrdocmto = pr_nrdocmto
     AND flgativo = 1;
BEGIN
  pr_dscritic := null;
  --
  -- Verificar se existe protocolo ativo para a Cooperativa/Conta/Tipo, se existir inativa o mesmo.
  FOR rv_crappro in cr_crappro (pr_cdcooper => pr_cdcooper
                               ,pr_nrdconta => pr_nrdconta
                               ,pr_cdtippro => pr_cdtippro
                               ,pr_nrdocmto => pr_nrdocmto)
  LOOP
    UPDATE crappro a
       SET a.flgativo = 0
     WHERE ROWID = rv_crappro.dsrosid_crappro;
  END LOOP;
  --
EXCEPTION
WHEN OTHERS THEN
  pr_dscritic := 'Erro alteração CRAPPRO - '||sqlerrm;
END pc_inativa_protocolo;

END CNTR0001;
/
