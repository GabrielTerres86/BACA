CREATE OR REPLACE PACKAGE CECRED.EMPR0020 IS
 /* -----------------------------------------------------------------------------------

    Programa: EMPR0020
    Autor   : Fernanda Kelli de Oliveira / AMcom
    Data    : 02/05/2019    ultima Atualizacao: --

    Dados referentes ao programa:

    Objetivo  : Concentrar rotinas referente ao processo do Crédito Consignado

    Alteracoes:

    ..............................................................................*/

  PROCEDURE pc_validar_dtpgto_antecipada(pr_xmllog      IN VARCHAR2              --> XML com informacoes de LOG
                                        ,pr_cdcritic   OUT PLS_INTEGER           --> Codigo da critica
                                        ,pr_dscritic   OUT VARCHAR2              --> Descricao da critica
                                        ,pr_retxml      IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                        ,pr_nmdcampo   OUT VARCHAR2              --> Nome do campo com erro
                                        ,pr_des_erro   OUT VARCHAR2);            --> Erros do processo
                                                                     
  PROCEDURE pc_efetua_debito_conveniada(pr_cdcooper     IN crapcop.cdcooper%TYPE --> Código da cooperativa
                                       ,pr_cdempres     IN crapemp.cdempres%TYPE --> Código da Empresa que receberá o débito
                                       ,pr_cdoperad     IN VARCHAR2              --> Operador da Consulta – Valor 'xxxxx' para Internet
                                       ,pr_aplOrigem    IN VARCHAR2              --> Aplicação de Origem da chamada do Serviço
                                       ,pr_nrdcaixa      IN INTEGER               --> Código de caixa do canal de atendimento – Valor 'XXXX' para Internet
                                       ,pr_dtmvtolt     IN crapdat.dtmvtolt%TYPE --> Data do movimento atual.
                                       ,pr_vrdebito     IN NUMBER                --> Valor a ser debitado   
                                       ,pr_idpagto      IN NUMBER                --> Identificador de pagamento enviado pelo consumidor
                                       ,pr_dscritic    OUT VARCHAR2              --> Descrição da crítica          
                                       ,pr_retorno      OUT xmltype);   
                                       
  PROCEDURE pc_efetiva_pagto_parc_consig(pr_cdcooper    IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                        ,pr_cdagenci    IN crapass.cdagenci%TYPE --> Código da agência
                                        ,pr_nrdcaixa    IN craperr.nrdcaixa%TYPE --> Número do caixa
                                        ,pr_cdoperad    IN crapdev.cdoperad%TYPE --> Código do Operador
                                        ,pr_nmdatela    IN VARCHAR2              --> Nome da tela
                                        ,pr_idorigem    IN INTEGER               --> Id do módulo de sistema
                                        ,pr_cdpactra    IN INTEGER               --> P.A. da transação
                                        ,pr_nrdconta    IN crapepr.nrdconta%TYPE --> Número da conta
                                        ,pr_idseqttl    IN crapttl.idseqttl%TYPE --> Seq titula
                                        ,pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                        ,pr_flgerlog    IN VARCHAR2              --> Indicador S/N para geração de log
                                        ,pr_nrctremp    IN crapepr.nrctremp%TYPE --> Número do contrato de empréstimo
                                        ,pr_nrparepr    IN INTEGER               --> Número parcelas empréstimo
                                        ,pr_vlparepr    IN NUMBER                --> Valor da parcela emprestimo
                                        ,pr_vlparcel    IN NUMBER                --> valor da parcela
                                        ,pr_dtvencto    IN crappep.dtvencto%TYPE --> Vencimento da parcela
                                        ,pr_cdlcremp    IN crapepr.cdlcremp%TYPE --> Linha de crédito
                                        ,pr_tppagmto    IN VARCHAR2              --> Tipo Pagamento - "D" -Em Dia, "A"- Em Atraso                                        
                                        ,pr_vlrmulta    IN crappep.vlpagmta%TYPE --> Valor da multa
                                        ,pr_vlatraso    IN crappep.vlpagmra %TYPE--> Valor Juros de mora
                                        ,pr_vliofcpl    IN crappep.vliofcpl%TYPE --> Valor do IOF complementar de atraso
                                        ,pr_nrseqava    IN NUMBER DEFAULT 0      --> Pagamento: Sequencia do avalista
                                        ,pr_des_reto    OUT VARCHAR              --> Retorno OK / NOK
                                        ,pr_tab_erro    OUT gene0001.typ_tab_erro);

  PROCEDURE pc_inc_alt_tbepr_consig_pagto (pr_idsequencia IN number, --tbepr_consignado_pagamento.idsequencia%TYPE,
                                           pr_cdcooper    IN number, --tbepr_consignado_pagamento.cdcooper%TYPE,
                                           pr_nrdconta    IN number, --tbepr_consignado_pagamento.nrdconta%TYPE,
                                           pr_nrctremp    IN number, --tbepr_consignado_pagamento.nrctremp%TYPE,
                                           pr_nrparepr    IN number, --tbepr_consignado_pagamento.nrparepr%TYPE,
                                           pr_vlparepr    IN number, --tbepr_consignado_pagamento.vlparepr%TYPE,
                                           pr_vlpagpar    IN number, --tbepr_consignado_pagamento.vlpagpar%TYPE,
                                           pr_dtvencto    IN date, --tbepr_consignado_pagamento.dtvencto%TYPE,
                                           pr_instatus    IN number, --tbepr_consignado_pagamento.instatus%TYPE,
                                           pr_dscritic    OUT VARCHAR2 );

   FUNCTION fn_ret_status_pagto_consignado (pr_cdcooper    IN number, --tbepr_consignado_pagamento.cdcooper%TYPE,
                                            pr_nrdconta    IN number, --tbepr_consignado_pagamento.nrdconta%TYPE,
                                            pr_nrctremp    IN number, --tbepr_consignado_pagamento.nrctremp%TYPE,
                                            pr_nrparepr    IN number) return number; --tbepr_consignado_pagamento.nrparepr%TYPE) RETURN NUMBER;                                                                                                                    

   PROCEDURE pc_gera_xml_pagamento_consig(pr_cdcooper    IN crapepr.cdcooper%TYPE, -- código da cooperativa
                                          pr_nrdconta    IN crapepr.nrdconta%TYPE, -- Número da conta
                                          pr_nrctremp    IN crapepr.nrctremp%TYPE, -- Número do contrato de emprestimo
                                          pr_nrparepr    IN crappep.nrparepr%TYPE, -- Numero da parcela
                                          pr_dsxmlali   OUT XmlType,               -- XML de saida do pagamento
                                          pr_dscritic   OUT VARCHAR2); --> Descricao Erro
                                          
   PROCEDURE  pc_envia_email_erro_int_consig(pr_cdcooper    IN crapepr.cdcooper%TYPE, --Cooperativa
                                              pr_nrdconta    IN crapepr.nrdconta%TYPE, --Conta
                                              pr_nrctremp    IN crapepr.nrctremp%TYPE, --Contrato
                                              pr_nrparepr    IN crappep.nrparepr%TYPE default null, --Parcela (Opcional)
                                              pr_idoperacao  IN NUMBER default null, --ID Operacao (Opcional)
                                              pr_tipoemail   IN VARCHAR2, --Tipo de Email 
                                              pr_msg         IN VARCHAR2, --Mensagem_erro_origem
                                              pr_dscritic    OUT VARCHAR2,
                                              pr_retxml      OUT xmltype
                                               );
  
   PROCEDURE pc_alt_emp_cooperado_desligado(pr_cdcooper      IN crapepr.cdcooper%TYPE  --> Cooperativa
                                           ,pr_nrdconta      IN crapepr.nrdconta%TYPE  --> Conta
                                           ,pr_flgdesligado  IN VARCHAR2               --> Indica se o cliente foi desligado (1 = Sim / 2 = Nao)
                                           -- campos padrões
                                           ,pr_cdcritic      OUT PLS_INTEGER           --> Codigo da critica
                                           ,pr_dscritic      OUT VARCHAR2              --> Descricao da critica
                                           ,pr_des_erro      OUT VARCHAR2              --> Erros do processo
                                           );                                               

END EMPR0020;
/
CREATE OR REPLACE PACKAGE BODY CECRED.EMPR0020 IS
  /* -----------------------------------------------------------------------------------

    Programa: EMPR0020
    Autor   : Fernanda Kelli de Oliveira / AMcom
    Data    : 02/05/2019    ultima Atualizacao: 06/05/2019

    Dados referentes ao programa:

    Objetivo  : Concentrar rotinas referente ao processo do Crédito Consignado

    Alteracoes: 06/05/2019 - P437 Consignado - Inclusão da rotina pc_efetiva_pagto_parc_consig 
                Josiane Stiehler AMcom
        14/05/2019 - P437 Consignado - Inclusão da rotina pc_envia_email_erro_int_consig 
                Jackson Barcellos AMcom

    ..............................................................................*/

  PROCEDURE pc_validar_dtpgto_antecipada (-- campos padrões
                                          pr_xmllog             IN VARCHAR2              --> XML com informacoes de LOG
                                         ,pr_cdcritic          OUT PLS_INTEGER           --> Codigo da critica
                                         ,pr_dscritic          OUT VARCHAR2              --> Descricao da critica
                                         ,pr_retxml             IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                         ,pr_nmdcampo          OUT VARCHAR2              --> Nome do campo com erro
                                         ,pr_des_erro          OUT VARCHAR2              --> Erros do processo
                                         )IS
  /*---------------------------------------------------------------------------------------------------------
      Programa : pc_validar_dtpgto_antecipada
      Sistema  : AIMARO
      Sigla    : ATENDA->PRESTAÇÕES->COOPERATIVA
      Autor    : Fernanda Kelli de Oliveira - AMcom Sistemas de Informação
      Data     : 02/05/2019

      Objetivo : Na antecipação de parcelas para empréstimos de Consignado que tenham vínculo com conveniada 
                 cadastrada na tela Consig, o sistema Aimaro deverá validar a data atual de movimento 
                 (a data do dia) para permitir ou não a antecipação de uma parcela.

      Alteração :

  ----------------------------------------------------------------------------------------------------------*/
  BEGIN
    DECLARE
       /* Tratamento de erro */
      vr_exc_erro EXCEPTION;

      /* Descrição e código da critica */
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      vr_des_erro VARCHAR2(10);

      -- variaveis de entrada vindas no xml
      vr_cdcooper integer;      
      vr_nmdatela varchar2(100);
      vr_nmeacao  varchar2(100);
      vr_cdagenci varchar2(100);
      vr_nrdcaixa varchar2(100);
      vr_idorigem varchar2(100);
      vr_cdoperad varchar2(100);
      vr_cdempres crapepr.cdempres%TYPE; 
      
      --Variaveis para leitura do XML
      vr_nrdconta         crapepr.nrdconta%type;
      vr_nrctremp         crapepr.nrctremp%type;
      vr_total_parcelas   number;
      vr_nrparc           number;
      vr_count            number;
      vr_dtvencto         VARCHAR(10);
      vr_dtmvtolt         VARCHAR(10); 
      
      vr_dsmensag         VARCHAR2(10) := NULL;      
                  
    BEGIN
      
      pr_nmdcampo := NULL;
      pr_des_erro := 'OK';

      -- Extrai os dados vindos do XML pr_retxml
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);
      IF  TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
      END IF;
      
      --Ler o valor das tag's enviadas no XML
      --Nr. Conta
      BEGIN
        vr_nrdconta    := TRIM(pr_retxml.extract('/Root/dto/nrdconta/text()').getstringval());  
      EXCEPTION
        WHEN OTHERS THEN
          IF SQLCODE = '-30625' THEN
            vr_dscritic := 'Numero da conta deve ser preenchida.';
            RAISE vr_exc_erro;
          END IF;  
      END;
       
      --Numero do Contrato
      BEGIN
        vr_nrctremp    := TRIM(pr_retxml.extract('/Root/dto/nrctremp/text()').getstringval());  
      EXCEPTION
        WHEN OTHERS THEN
          IF SQLCODE = '-30625' THEN
            vr_dscritic := 'Numero do contrato deve ser preenchido.';
            RAISE vr_exc_erro;
          END IF;  
      END;      
      
      --Validar se a empresa possui o Convênio do Consignado
      BEGIN
        select epr.cdempres
          into vr_cdempres
          from crapepr epr 
         where epr.cdcooper = vr_cdcooper
           and epr.nrctremp = vr_nrctremp
           and epr.tpdescto = 2  --Tipo de desconto do emprestimo (2 = Desconto em Folha de Pagamento)
           and epr.tpemprst = 1; --Contem o tipo do emprestimo (1 = Pré-Fixado).
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          vr_cdempres := NULL;
        WHEN OTHERS THEN
          vr_dscritic := 'Numero do contrato deve ser preenchido.';
          RAISE vr_exc_erro;
      END;
      
      IF vr_cdempres IS NULL THEN
        vr_dsmensag := 'N';  -- Não preciva pedir a Senha do Operador
      ELSE
        
        --Total de parcelas
        BEGIN
          vr_total_parcelas    := TRIM(pr_retxml.extract('/Root/dto/total/text()').getstringval());  
        EXCEPTION
          WHEN OTHERS THEN
            IF SQLCODE = '-30625' THEN
              vr_dscritic := 'Total de parcelas deve ser preenchido.';
              RAISE vr_exc_erro;
            END IF;  
        END;
        
        FOR x in 1 .. vr_total_parcelas LOOP
          --Numero da parcela
          BEGIN
            vr_nrparc  := TRIM(pr_retxml.extract('/Root/dto/parcelas/parc_'||x||'/text()').getstringval());
          EXCEPTION
            WHEN OTHERS THEN
              IF SQLCODE = '-30625' THEN
                vr_dscritic := 'Numero da parcela deve ser preenchida.';
                RAISE vr_exc_erro;
              END IF;  
          END;
          
          --Buscar a Data de Vencimento da Parcela
          BEGIN
            SELECT to_char(dtvencto,'DD/MM')||'/1900' dtvencto
              INTO vr_dtvencto
              FROM crappep 
             WHERE crappep.cdcooper = vr_cdcooper
               AND crappep.Nrdconta = vr_nrdconta
               AND crappep.nrctremp = vr_nrctremp
               AND crappep.nrparepr = vr_nrparc;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Problemas no select de busca da data de vencimento. ' || SQLERRM;
              RAISE vr_exc_erro; 
          END;
          
          --Buscar a Data de movimento da Cooperativa
          BEGIN
            SELECT to_char(dtmvtolt,'DD/MM')||'/1900' dtmvtolt           
              INTO vr_dtmvtolt
              FROM crapdat 
             WHERE crapdat.cdcooper = vr_cdcooper;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Problemas no select de busca da data de vencimento. ' || SQLERRM;
              RAISE vr_exc_erro; 
          END;
          
          --Validar a data de pagamento da parcela
          BEGIN
            SELECT COUNT(1)
              INTO vr_count 
              FROM tbcadast_emp_consig_param dts,
                   tbcadast_empresa_consig   emp
             WHERE emp.idemprconsig = dts.idemprconsig
               AND emp.cdempres = vr_cdempres
               AND emp.cdcooper = vr_cdcooper
               AND to_date(vr_dtvencto,'DD/MM/RRRR') BETWEEN dts.dtenvioarquivo AND dts.dtvencimento
               AND to_date(vr_dtmvtolt,'DD/MM/RRRR') BETWEEN dts.dtenvioarquivo AND dts.dtvencimento;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Problemas no select de validacao da data de pagamento. ' || SQLERRM;
              RAISE vr_exc_erro;  
          END;  
          
          IF vr_count > 0 THEN
            vr_dsmensag := 'S';  --Deve pedir a Senha do Operador
            EXIT WHEN vr_count > 0;
          ELSE
            vr_dsmensag := 'N';  -- Não preciva pedir a Senha do Operador
          END IF;          
        END LOOP;        
      END IF;  
       
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><dsmensag>'||vr_dsmensag||'</dsmensag></Root>');
    
    EXCEPTION
      WHEN vr_exc_erro THEN
         /*  se foi retornado apenas código */
         IF  nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
             /* buscar a descriçao */
             vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
         END IF;
         /* variavel de erro recebe erro ocorrido */
         pr_des_erro := 'NOK';
         pr_cdcritic := nvl(vr_cdcritic,0);
         pr_dscritic := vr_dscritic;
           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
           pr_des_erro := 'NOK';
         /* montar descriçao de erro nao tratado */
           pr_dscritic := 'erro não tratado na EMPR0020.PC_VALIDAR_DTPGTO_ANTECIPADA ' ||SQLERRM;
           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;    
  END pc_validar_dtpgto_antecipada;
  
  PROCEDURE pc_efetua_debito_conveniada(pr_cdcooper     IN crapcop.cdcooper%TYPE --> Código da cooperativa
                                       ,pr_cdempres     IN crapemp.cdempres%TYPE --> Código da Empresa que receberá o débito
                                       ,pr_cdoperad     IN VARCHAR2              --> Operador da Consulta – Valor 'xxxxx' para Internet
                                       ,pr_aplOrigem    IN VARCHAR2              --> Aplicação de Origem da chamada do Serviço
                                       ,pr_nrdcaixa      IN INTEGER               --> Código de caixa do canal de atendimento – Valor 'XXXX' para Internet
                                       ,pr_dtmvtolt     IN crapdat.dtmvtolt%TYPE --> Data do movimento atual.
                                       ,pr_vrdebito     IN NUMBER                --> Valor a ser debitado   
                                       ,pr_idpagto      IN NUMBER                --> Identificador de pagamento enviado pelo consumidor
                                       ,pr_dscritic    OUT VARCHAR2              --> Descrição da crítica          
                                       ,pr_retorno      OUT xmltype) IS
  /*---------------------------------------------------------------------------------------------------------
      Programa : pc_efetua_debito_conveniada
      Sistema  : AIMARO
      Sigla    : 
      Autor    : Fernanda Kelli de Oliveira - AMcom Sistemas de Informação
      Data     : 03/05/2019
  
      Objetivo : Efetuar débito de consignado em conta da conveniada. 
                 Procedure será chamada pelo barramento SOA.

      Alteração:

  ----------------------------------------------------------------------------------------------------------*/
    /* Tratamento de erro */
    vr_exc_erro   EXCEPTION;
    vr_dscritic   VARCHAR2(4000);      
    vr_des_erro   VARCHAR2(10);
    vr_tab_erro   GENE0001.typ_tab_erro;
   
    vr_idsequencia tbepr_consignado_debconveniada.idsequencia%type;  
    vr_instatus    tbepr_consignado_debconveniada.instatus%type;  
    vr_dtmvtolt    crapdat.dtmvtolt%type;
    vr_cdagenci    crapass.cdagenci%type;
    vr_nrdconta    crapass.nrdconta%type;
  
  BEGIN
          
    BEGIN      
      pr_dscritic    := null;
      --Verificar se o registro já existe
      vr_idsequencia := null;
      vr_instatus    := null;
      BEGIN
        SELECT debconv.idsequencia,
               debconv.instatus
          INTO vr_idsequencia,
               vr_instatus
          FROM cecred.tbepr_consignado_debconveniada debconv
         WHERE debconv.cdcooper = pr_cdcooper
           AND debconv.cdempres = pr_cdempres
           AND debconv.idpagto  = pr_idpagto;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          vr_idsequencia := NULL;
        WHEN OTHERS THEN  
          vr_dscritic := 'Problemas ao consultar se o registro ja foi cadastrado - tabela tbepr_consignado_debconveniada. ' || SQLERRM; 
          RAISE vr_exc_erro;
      END;
        
      --Inserir os parâmetros de entrada na tabela de controle de pagamento
      IF vr_idsequencia IS NULL THEN
        BEGIN
          vr_instatus := 1; 
          INSERT INTO cecred.tbepr_consignado_debconveniada
            (idsequencia,
             cdcooper,
             cdempres,
             idpagto,
             vrdebito,
             instatus,
             cdoperad,
             dtincreg,
             dtupdreg)
          VALUES
            (cecred.tbepr_consig_debconv_seq.nextval,
             pr_cdcooper,
             pr_cdempres,
             pr_idpagto,
             pr_vrdebito,
             vr_instatus,  --pr_instatus (1-Pendente, 2-Processado, 3-Erro)
             pr_cdoperad,
             sysdate,      --pr_dtincreg - Data de inclusao do registro
             null)        --pr_dtupdreg - Data de alteração do registro
        
          RETURNING tbepr_consignado_debconveniada.idsequencia INTO vr_idsequencia;
          
        EXCEPTION
          WHEN OTHERS THEN
            RAISE vr_exc_erro;    
        END;
      ELSE
        BEGIN
          UPDATE cecred.tbepr_consignado_debconveniada
             SET cdoperad = pr_cdoperad,
                 dtupdreg = sysdate
           WHERE idsequencia = vr_idsequencia;
        EXCEPTION
          WHEN OTHERS THEN
            RAISE vr_exc_erro;    
        END;       
      END IF;
      
      --Buscar a Data de movimento da Cooperativa
      BEGIN
        SELECT dtmvtolt          
          INTO vr_dtmvtolt
          FROM crapdat 
         WHERE crapdat.cdcooper = pr_cdcooper;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Problemas no select de busca da data de vencimento. ' || SQLERRM;
          RAISE vr_exc_erro; 
      END;
      
      --Buscar o Número da Conta da Empresa
      BEGIN 
        vr_nrdconta := NULL;       
        SELECT crapemp.nrdconta               
          INTO vr_nrdconta                    
          FROM crapemp,
               tbcadast_empresa_consig consig
         WHERE crapemp.cdempres = consig.cdempres
           AND crapemp.cdcooper = consig.cdcooper
           AND consig.indautrepassecc = 1 --Autorizar Debito Repasse em C/C. (0 - NÃ£o Autorizado / 1 - Autorizado)
           AND crapemp.cdempres = pr_cdempres
           AND crapemp.cdcooper = pr_cdcooper;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          vr_nrdconta := NULL;
        WHEN OTHERS THEN
          vr_dscritic := 'Problemas no select de busca da data de conta/agencia. ' || SQLERRM;
          RAISE vr_exc_erro; 
      END;
      
      --Caso não tenha conta corrente cadastrada na Cademp, então o sistema Aimaro não fará o débito do repasse.
      IF nvl(vr_nrdconta,0) = 0 THEN
        vr_dscritic := 'Empresa '||pr_cdempres||' nao possui conta-corrente cadastrada. ';
        RAISE vr_exc_erro; 
      ELSE
        --Buscar o codigo da agencia
        BEGIN 
          vr_cdagenci := NULL;       
          SELECT crapass.cdagenci
            INTO vr_cdagenci  
            FROM crapass   
           WHERE crapass.cdcooper = pr_cdcooper
             AND crapass.nrdconta = vr_nrdconta;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            vr_cdagenci := NULL;
          WHEN OTHERS THEN
            vr_dscritic := 'Problemas no select de busca do numero do PA. ' || SQLERRM;
            RAISE vr_exc_erro; 
        END;
        
        IF nvl(vr_cdagenci,0) = 0 THEN
          vr_dscritic := 'Empresa '||pr_cdempres||' conta-corrente '||vr_nrdconta||' nao possui agencia cadastrada. ';
          RAISE vr_exc_erro; 
        END IF; 
      END IF;
      
      --Se estiver Pendente/Erro de processamento 
      IF vr_instatus in(1,3) THEN  --
        
        /* Lanca em C/C e atualiza o lote */
        empr0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper      --> Cooperativa conectada
                                      ,pr_dtmvtolt => vr_dtmvtolt      --> Movimento atual
                                      ,pr_cdagenci => vr_cdagenci      --> Código da agência
                                      ,pr_cdbccxlt => 1                --> Número do caixa
                                      ,pr_cdoperad => pr_cdoperad      --> Código do Operador
                                      ,pr_cdpactra => vr_cdagenci      --> P.A. da transação
                                      ,pr_nrdolote => 600014           --> Numero do Lote
                                      ,pr_nrdconta => vr_nrdconta      --> Número da conta
                                      ,pr_cdhistor => 2972             --> Codigo historico
                                      ,pr_vllanmto => pr_vrdebito      --> Valor da parcela emprestimo
                                      ,pr_nrparepr => 0                --> Número parcelas empréstimo
                                      ,pr_nrctremp => 0                --> Número do contrato de empréstimo
                                      ,pr_des_reto => vr_des_erro      --> Retorno OK / NOK
                                      ,pr_tab_erro => vr_tab_erro);    --> Tabela com possíves erros
        --Se Retornou erro
        IF vr_des_erro <> 'OK' THEN
          --Sair
          vr_dscritic := 'Problema na rotina empr0001.pc_cria_lancamento_cc, empresa '|| pr_cdempres || '. Erro: '|| sqlerrm ;
          RAISE vr_exc_erro;
        ELSE
          BEGIN
            UPDATE cecred.tbepr_consignado_debconveniada T
               SET t.instatus = 2  --Processado
             WHERE idsequencia = vr_idsequencia;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Problema na atualizacao do processamento da empresa '|| pr_cdempres || '. Erro: '|| sqlerrm ;
              RAISE vr_exc_erro;    
          END;  
        END IF;
      END IF;
      
      --Retorno (SUCESSO)
      pr_dscritic:= null;
      vr_dscritic := 'Débito realizado com sucesso!';      
      pr_retorno := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><retorno>'||vr_dscritic||'</retorno></Root>');
      
      COMMIT;
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        BEGIN
          UPDATE cecred.tbepr_consignado_debconveniada T
             SET t.instatus = 3  --Erro
           WHERE idsequencia = vr_idsequencia;
           
           COMMIT;
           
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Problema na atualizacao do processamento da empresa '|| pr_cdempres || '. Erro: '|| sqlerrm ;
            RAISE vr_exc_erro;    
        END;
        --Retorno (NÃO SUCESSO)
        pr_retorno := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><retorno>' || pr_dscritic || '</retorno></Root>');
        pr_dscritic:= 'Erro ao debitar valor solicitado. ' || vr_dscritic;                                         
      WHEN OTHERS THEN
         --Retorno (NÃO SUCESSO)        
        pr_retorno := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><retorno>' || pr_dscritic || '</retorno></Root>');
        pr_dscritic:= 'Erro ao debitar valor solicitado. Erro: ' || sqlerrm;                                         
    END;    
  END pc_efetua_debito_conveniada;                                        
                                   
  PROCEDURE pc_efetiva_pagto_parc_consig(pr_cdcooper    IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                        ,pr_cdagenci    IN crapass.cdagenci%TYPE --> Código da agência
                                        ,pr_nrdcaixa    IN craperr.nrdcaixa%TYPE --> Número do caixa
                                        ,pr_cdoperad    IN crapdev.cdoperad%TYPE --> Código do Operador
                                        ,pr_nmdatela    IN VARCHAR2              --> Nome da tela
                                        ,pr_idorigem    IN INTEGER               --> Id do módulo de sistema
                                        ,pr_cdpactra    IN INTEGER               --> P.A. da transação
                                        ,pr_nrdconta    IN crapepr.nrdconta%TYPE --> Número da conta
                                        ,pr_idseqttl    IN crapttl.idseqttl%TYPE --> Seq titula
                                        ,pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                        ,pr_flgerlog    IN VARCHAR2              --> Indicador S/N para geração de log
                                        ,pr_nrctremp    IN crapepr.nrctremp%TYPE --> Número do contrato de empréstimo
                                        ,pr_nrparepr    IN INTEGER               --> Número parcelas empréstimo
                                        ,pr_vlparepr    IN NUMBER                --> Valor da parcela emprestimo à pagar
                                        ,pr_vlparcel    IN NUMBER                --> valor da parcela
                                        ,pr_dtvencto    IN crappep.dtvencto%TYPE --> Vencimento da parcela
                                        ,pr_cdlcremp    IN crapepr.cdlcremp%TYPE --> Linha de crédito
                                        ,pr_tppagmto    IN VARCHAR2              --> Tipo Pagamento - "D" -Em Dia, "A"- Em Atraso
                                        ,pr_vlrmulta    IN crappep.vlpagmta%TYPE --> Valor da multa
                                        ,pr_vlatraso    IN crappep.vlpagmra %TYPE--> Valor Juros de mora
                                        ,pr_vliofcpl    IN crappep.vliofcpl%TYPE --> Valor do IOF complementar de atraso
                                        ,pr_nrseqava    IN NUMBER DEFAULT 0      --> Pagamento: Sequencia do avalista
                                        ,pr_des_reto    OUT VARCHAR              --> Retorno OK / NOK
                                        ,pr_tab_erro    OUT gene0001.typ_tab_erro) IS --> Tabela com possíves erros
  
  /*---------------------------------------------------------------------------------------------------------
      Programa : pc_efetiva_pagto_parc_consig
      Sistema  : AIMARO
      Sigla    : 
      Autor    : Josiane Stiehler - AMcom
      Data     : 06/05/2019
  
      Objetivo : Efetiva pagamento da parcela, ou seja grava evento SOA referente ao pagamento
                 para ser enviado a FIS Brasil. 
      Alteração:

  ----------------------------------------------------------------------------------------------------------*/
  BEGIN
    DECLARE
      -- Cursor de Linha de Credito 
      CURSOR cr_craplcr(pr_cdcooper IN craplcr.cdcooper%TYPE
                       ,pr_cdlcremp IN craplcr.cdlcremp%TYPE) IS
        SELECT craplcr.cdlcremp
              ,craplcr.dsoperac
          FROM craplcr
         WHERE craplcr.cdcooper = pr_cdcooper
               AND craplcr.cdlcremp = pr_cdlcremp;
               
      rw_craplcr cr_craplcr%ROWTYPE;
  
      --Variaveis Locais
      vr_dstransa VARCHAR2(100);
      vr_dsorigem VARCHAR2(100);
      vr_nrdrowid ROWID;
      vr_flgtrans BOOLEAN;
      vr_floperac BOOLEAN;
      vr_cdhismul craphis.cdhistor%TYPE;
      vr_cdhisatr craphis.cdhistor%TYPE;
      vr_cdhisiof craphis.cdhistor%TYPE;
      vr_cdhistor craphis.cdhistor%TYPE;
      vr_lotemult craplot.nrdolote%TYPE;
      vr_loteatra craplot.nrdolote%TYPE;
      vr_loteiof  craplot.nrdolote%TYPE;
      vr_nrdolote craplot.nrdolote%TYPE; 
      vr_nrseqdig tbgen_iof_lancamento.nrseqdig_lcm%TYPE;
      
      vr_dsxmlali XMLType;
      -- ID Evento SOA
      vr_idevento   tbgen_evento_soa.idevento%type;    

      --Variaveis Erro
      vr_cdcritic INTEGER;
      vr_des_erro VARCHAR2(3);
      vr_dscritic VARCHAR2(4000);

      --Variaveis Excecao
      vr_exc_erro  EXCEPTION;
      vr_exc_saida EXCEPTION;

    BEGIN
      --Inicializar variavel erro
      pr_des_reto := 'OK';
      --Marcar que nao ocorreu transacao
      vr_flgtrans := FALSE;

      --Limpar tabela erro
      pr_tab_erro.DELETE;

      --Se escreve erro log
      IF pr_flgerlog = 'S' THEN
        --Buscar Descricao origem
        vr_dsorigem := GENE0001.vr_vet_des_origens(pr_idorigem);
        --Descricao Transacao
        vr_dstransa := 'Efetiva pagamento de parcela consignado';
      END IF;

      BEGIN
        --Criar savepoint para desfazer transacao
        SAVEPOINT savtrans_efetiva_pagto_parcela;
        
        -- Gera evento SOA de pagamento e insere lancamento na C/C somente
        -- o pagamento que não foi enviado ou que retornou erro da FIS Brasil
        IF fn_ret_status_pagto_consignado (pr_cdcooper => pr_cdcooper,
                                           pr_nrdconta => pr_nrdconta,
                                           pr_nrctremp => pr_nrctremp, 
                                           pr_nrparepr => pr_nrparepr) IN (0,2,3) THEN -- 0- não enviado, 2, Pagamento Efetuado na FIS, 3- Erro

           --Selecionar Linha Credito
           OPEN cr_craplcr(pr_cdcooper => pr_cdcooper
                          ,pr_cdlcremp => pr_cdlcremp);
           FETCH cr_craplcr
            INTO rw_craplcr;
           --Se nao Encontrou
           IF cr_craplcr%NOTFOUND THEN
              --Fechar Cursor
              CLOSE cr_craplcr;
              vr_cdcritic := 363;
              --Sair
              RAISE vr_exc_saida;
           ELSE
             --Determinar se a Operacao é financiamento
             vr_floperac := rw_craplcr.dsoperac = 'FINANCIAMENTO';
           END IF;
           
           -- verifica se o pagamento é em dia
           IF pr_tppagmto = 'D' THEN 
              IF vr_floperac THEN
                 vr_nrdolote := 600015;
              ELSE
                 vr_nrdolote := 600014;
              END IF;
              vr_cdhistor := 108;
           ELSE -- pagamento em atraso
               IF vr_floperac THEN -- Financiamento
                  -- multa
                  vr_lotemult := 600021; 
                  vr_cdhismul := 1070;
                  -- atraso
                  vr_cdhisatr := 1072;
                  vr_loteatra := 600025;
                  -- IOF
                  vr_cdhisiof:= 2314;
                  vr_loteiof:=  600023;
                  -- pago da parcela
                  vr_cdhistor := 108;
                  vr_nrdolote:=  600015;
               ELSE -- Emprestimo 
                  -- multa
                  vr_lotemult := 600020; 
                  vr_cdhismul := 1060;
                  -- atraso
                  vr_cdhisatr := 1071;
                  vr_loteatra := 600024;
                  -- IOF
                  vr_cdhisiof:= 2313;
                  vr_loteiof:= 600022;
                  -- pago da parcela
                  vr_cdhistor := 108;
                  vr_nrdolote:= 600014;
               END IF;
           END IF;
           
           -- Gera o XML do pagamento a ser gravado no evento SOA
           pc_gera_xml_pagamento_consig(pr_cdcooper  => pr_cdcooper, -- código da cooperativa
                                        pr_nrdconta  => pr_nrdconta, -- Número da conta
                                        pr_nrctremp  => pr_nrctremp, -- Número do contrato de emprestimo
                                        pr_nrparepr  => pr_nrparepr, -- Numero da parcela
                                        pr_dsxmlali  => vr_dsxmlali, -- XML de saida do pagamento
                                        pr_dscritic  => vr_dscritic); 

           -- Tratar saida com erro                          
           IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
           END IF;                                  
           
           -- gera evento soa para o pagamento de consignado
           soap0003.pc_gerar_evento_soa(pr_cdcooper               => pr_cdcooper
                                       ,pr_nrdconta               => pr_nrdconta
                                       ,pr_nrctrprp               => pr_nrctremp
                                       ,pr_tpevento               => 'PAGAMENTO_PARCELA'
                                       ,pr_tproduto_evento        => 'CDC'
                                       ,pr_tpoperacao             => 'INSERT'
                                       ,pr_dsconteudo_requisicao  => vr_dsxmlali.getClobVal()
                                       ,pr_idevento               => vr_idevento
                                       ,pr_dscritic               => vr_dscritic);
           -- Tratar saida com erro                          
           IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
           END IF;

           -- Lanca em C/C e atualiza o lote 
           empr0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper --> Cooperativa conectada
                                          ,pr_dtmvtolt => pr_dtmvtolt --> Movimento atual
                                          ,pr_cdagenci => pr_cdagenci --> Código da agência
                                          ,pr_cdbccxlt => 100         --> Número do caixa
                                          ,pr_cdoperad => pr_cdoperad --> Código do Operador
                                          ,pr_cdpactra => pr_cdpactra --> P.A. da transação
                                          ,pr_nrdolote => vr_nrdolote --> Numero do Lote
                                          ,pr_nrdconta => pr_nrdconta --> Número da conta
                                          ,pr_cdhistor => vr_cdhistor --> Codigo historico
                                          ,pr_vllanmto => pr_vlparepr --> Valor da parcela emprestimo
                                          ,pr_nrparepr => pr_nrparepr --> Número parcelas empréstimo
                                          ,pr_nrctremp => pr_nrctremp --> Número do contrato de empréstimo
                                          ,pr_nrseqava => pr_nrseqava --> Pagamento: Sequencia do avalista
                                          ,pr_des_reto => vr_des_erro --> Retorno OK / NOK
                                          ,pr_tab_erro => pr_tab_erro); --> Tabela com possíves erros
           --Se Retornou erro
           IF vr_des_erro <> 'OK' THEN
              --Sair
              RAISE vr_exc_saida;
           END IF;

           pc_inc_alt_tbepr_consig_pagto (pr_idsequencia => null,        -- Numero sequencial da tabela
                                          pr_cdcooper    => pr_cdcooper, -- codigo da cooperativa
                                          pr_nrdconta    => pr_nrdconta, -- numero da conta
                                          pr_nrctremp    => pr_nrctremp, -- Numero do contrato
                                          pr_nrparepr    => pr_nrparepr, -- Numero da parcela
                                          pr_vlparepr    => pr_vlparcel, -- valor da parcela do emprestimo
                                          pr_vlpagpar    => pr_vlparepr, -- Valor pago da parcela
                                          pr_dtvencto    => pr_dtvencto, -- Vencimento da parcela
                                          pr_instatus    => 1,           -- Status do processamento
                                          pr_dscritic     => vr_dscritic); -- critica de erro
           -- Tratar saida com erro                          
           IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
           END IF;                                                   
        
           -- Para os pagamentos em atraso
           -- lançar em c/c  Multa, juros e IOF
           IF pr_tppagmto = 'A' THEN
              ------------------------------
              -- Lançamento de Multa
              ------------------------------
              IF nvl(pr_vlrmulta,0) > 0 then
                 --Lanca em C/C e atualiza o lote 
                 empr0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper --> Cooperativa conectada
                                               ,pr_dtmvtolt => pr_dtmvtolt --> Movimento atual
                                               ,pr_cdagenci => pr_cdagenci --> Código da agência
                                               ,pr_cdbccxlt => 100 --> Número do caixa
                                               ,pr_cdoperad => pr_cdoperad --> Código do Operador
                                               ,pr_cdpactra => pr_cdpactra --> P.A. da transação
                                               ,pr_nrdolote => vr_lotemult --> Numero do Lote
                                               ,pr_nrdconta => pr_nrdconta --> Número da conta
                                               ,pr_cdhistor => vr_cdhismul --> Codigo historico
                                               ,pr_vllanmto => pr_vlrmulta --> Valor da parcela emprestimo
                                               ,pr_nrparepr => pr_nrparepr --> Número parcelas empréstimo
                                               ,pr_nrctremp => pr_nrctremp --> Número do contrato de empréstimo
                                               ,pr_nrseqava => pr_nrseqava -- Pagamento: Sequencia do avalista
                                               ,pr_des_reto => vr_des_erro --> Retorno OK / NOK
                                               ,pr_tab_erro => pr_tab_erro); --> Tabela com possíves erros
                 --Se Retornou erro
                 IF vr_des_erro <> 'OK' THEN
                    --Sair
                    RAISE vr_exc_saida;
                 END IF;
              END IF;
              
              ---------------------------------
              -- Lançamento de juros de mora 
              ---------------------------------
              IF nvl(pr_vlatraso, 0) > 0  THEN
                 -- AND nvl(vr_vlpagsld, 0) >= 0 THEN
                 -- Debita o pagamento da parcela da C/C 
                 empr0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper --> Cooperativa conectada
                                                ,pr_dtmvtolt => pr_dtmvtolt --> Movimento atual
                                                ,pr_cdagenci => pr_cdagenci --> Código da agência
                                                ,pr_cdbccxlt => 100 --> Número do caixa
                                                ,pr_cdoperad => pr_cdoperad --> Código do Operador
                                                ,pr_cdpactra => pr_cdpactra --> P.A. da transação
                                                ,pr_nrdolote => vr_loteatra --> Numero do Lote
                                                ,pr_nrdconta => pr_nrdconta --> Número da conta
                                                ,pr_cdhistor => vr_cdhisatr --> Codigo historico
                                                ,pr_vllanmto => pr_vlatraso --> Valor da parcela emprestimo
                                                ,pr_nrparepr => pr_nrparepr --> Número parcelas empréstimo
                                                ,pr_nrctremp => pr_nrctremp --> Número do contrato de empréstimo
                                                ,pr_nrseqava => pr_nrseqava --> Pagamento: Sequencia do avalista
                                                ,pr_des_reto => vr_des_erro --> Retorno OK / NOK
                                                ,pr_tab_erro => pr_tab_erro); --> Tabela com possíves erros
                 --Se Retornou erro
                 IF vr_des_erro <> 'OK' THEN
                    --Sair
                    RAISE vr_exc_saida;
                 END IF;
              END IF;
                
              ----------------------------------------
              -- Lançamento do IOF complementar
              ----------------------------------------
              IF nvl(pr_vliofcpl, 0) > 0 THEN
                 -- AND nvl(vr_vlpagsld, 0) >= 0 THEN
                 -- Debita o valor do IOF complementar atraso da C/C 
                 empr0001.pc_cria_lancamento_cc_chave(pr_cdcooper => pr_cdcooper --> Cooperativa conectada
                                                      ,pr_dtmvtolt => pr_dtmvtolt --> Movimento atual
                                                      ,pr_cdagenci => pr_cdagenci --> Código da agência
                                                      ,pr_cdbccxlt => 100 --> Número do caixa
                                                      ,pr_cdoperad => pr_cdoperad --> Código do Operador
                                                      ,pr_cdpactra => pr_cdpactra --> P.A. da transação
                                                      ,pr_nrdolote => vr_loteiof  --> Numero do Lote
                                                      ,pr_nrdconta => pr_nrdconta --> Número da conta
                                                      ,pr_cdhistor => vr_cdhisiof --> Codigo historico
                                                      ,pr_vllanmto => pr_vliofcpl --> Valor da parcela emprestimo
                                                      ,pr_nrparepr => pr_nrparepr --> Número parcelas empréstimo
                                                      ,pr_nrctremp => pr_nrctremp --> Número do contrato de empréstimo
                                                      ,pr_nrseqava => pr_nrseqava --> Pagamento: Sequencia do avalista
                                                      ,pr_nrseqdig => vr_nrseqdig
                                                      ,pr_des_reto => vr_des_erro --> Retorno OK / NOK
                                                      ,pr_tab_erro => pr_tab_erro); --> Tabela com possíves erros
                 --Se Retornou erro
                 IF vr_des_erro <> 'OK' THEN
                    --Sair
                    RAISE vr_exc_saida;
                 END IF;  
                
                 -- Insere o IOF 
                 tiof0001.pc_insere_iof(pr_cdcooper     => pr_cdcooper
                                       ,pr_nrdconta     => pr_nrdconta
                                       ,pr_dtmvtolt     => pr_dtmvtolt
                                       ,pr_tpproduto    => 1 -- Emprestimo
                                       ,pr_nrcontrato   => pr_nrctremp
                                       ,pr_idlautom     => null
                                       ,pr_dtmvtolt_lcm => pr_dtmvtolt
                                       ,pr_cdagenci_lcm => pr_cdpactra
                                       ,pr_cdbccxlt_lcm => 100
                                       ,pr_nrdolote_lcm => vr_loteiof
                                       ,pr_nrseqdig_lcm => vr_nrseqdig
                                       ,pr_vliofpri     => 0
                                       ,pr_vliofadi     => 0
                                       ,pr_vliofcpl     => pr_vliofcpl
                                       ,pr_flgimune     => 0
                                       ,pr_cdcritic     => vr_cdcritic
                                       ,pr_dscritic     => vr_dscritic);

                 IF vr_dscritic is not null THEN
                    RAISE vr_exc_saida;
                 end if;
              END IF;
           END IF;
        END IF;
        
        --Marcar que ocorreu transacao
        vr_flgtrans := TRUE;

      EXCEPTION
        WHEN vr_exc_saida THEN
          --Desfaz transacoes
          ROLLBACK TO SAVEPOINT savtrans_efetiva_pagto_parcela;
      END;

      --Se nao ocorreu a transacao
      IF NOT vr_flgtrans THEN
        -- Retorno não OK
        pr_des_reto := 'NOK';
        --Se nao tem erro na tabela
        IF pr_tab_erro.COUNT = 0 THEN
          -- Gerar rotina de gravação de erro
          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => 1 --> Fixo
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);
        END IF;
      ELSIF pr_flgerlog = 'S' THEN
        -- Se foi solicitado o envio de LOG
        -- Gerar LOG
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => ''
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => pr_dtmvtolt
                            ,pr_flgtrans => 1 --> TRUE
                            ,pr_hrtransa => GENE0002.fn_busca_time
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
        -- Retorno OK
        pr_des_reto := 'OK';
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Montar descrição de erro não tratado
        vr_dscritic := 'Erro não tratado na empr0020.pc_efetiva_pagto_parc_consig ' ||
                       sqlerrm;
        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
    END;
    END pc_efetiva_pagto_parc_consig;     
    
    PROCEDURE pc_inc_alt_tbepr_consig_pagto (pr_idsequencia IN number, --tbepr_consignado_pagamento.idsequencia%TYPE,
                                             pr_cdcooper    IN number, --tbepr_consignado_pagamento.cdcooper%TYPE,
                                             pr_nrdconta    IN number, --tbepr_consignado_pagamento.nrdconta%TYPE,
                                             pr_nrctremp    IN number, --tbepr_consignado_pagamento.nrctremp%TYPE,
                                             pr_nrparepr    IN number, --tbepr_consignado_pagamento.nrparepr%TYPE,
                                             pr_vlparepr    IN number, --tbepr_consignado_pagamento.vlparepr%TYPE,
                                             pr_vlpagpar    IN number, --tbepr_consignado_pagamento.vlpagpar%TYPE,
                                             pr_dtvencto    IN date,   --tbepr_consignado_pagamento.dtvencto%TYPE,
                                             pr_instatus    IN number, --tbepr_consignado_pagamento.instatus%TYPE,
                                             pr_dscritic    OUT VARCHAR2 ) IS 
     /*---------------------------------------------------------------------------------------------------------
      Programa : pc_inc_alt_tbepr_consignado_pagamento
      Sistema  : AIMARO
      Sigla    : 
      Autor    : Josiane Stiehler - AMcom
      Data     : 06/05/2019
  
      Objetivo : Inclui ou altera a tabela bepr_consignado_pagamento, 
                 para o controle de pagamento enviados a FIS Brasil

      Alteração:

     ----------------------------------------------------------------------------------------------------------*/
  BEGIN
    DECLARE
     vr_dscritic  varchar2(2000);
     vr_exc_saida exception;
  BEGIN 
 /*       IF pr_idsequencia IS NULL THEN
          BEGIN   
            INSERT INTO tbepr_consignado_pagamento
                 (idsequencia,
                  cdcooper,
                  nrdconta,
                  nrctremp,
                  nrparepr,
                  vlparepr,
                  vlpagpar,
                  dtvencto,
                  instatus,
                  dtincreg,
                  dtupdreg)
              VALUES
                 (null,
                  pr_cdcooper,
                  pr_nrdconta,
                  pr_nrctremp,
                  pr_nrparepr,
                  pr_vlparepr,
                  pr_vlpagpar,
                  pr_dtvencto,
                  pr_instatus,
                  sysdate,
                  null);
           EXCEPTION
             WHEN OTHERS THEN
               vr_dscritic:= 'Erro no insert da tabela tbepr_consignado_pagamento - ' ||sqlerrm;
               RAISE vr_exc_saida;
           END;      
         ELSE
           BEGIN
             UPDATE tbepr_consignado_pagamento
                SET instatus = pr_instatus,
                    dtupdreg = dtupdreg
              WHERE idsequencia = pr_idsequencia;
           EXCEPTION
             WHEN OTHERS THEN
               vr_dscritic:= 'Erro no updateda tabela tbepr_consignado_pagamento - '||sqlerrm;
               RAISE vr_exc_saida;               
           END;      
         END IF;*/
         null;
     EXCEPTION
        WHEN vr_exc_saida THEN
           pr_dscritic:= vr_dscritic; 
      END;
    END pc_inc_alt_tbepr_consig_pagto;
    
    FUNCTION fn_ret_status_pagto_consignado (pr_cdcooper    IN number,--tbepr_consignado_pagamento.cdcooper%TYPE, -- código da cooperativa
                                             pr_nrdconta    IN number,--tbepr_consignado_pagamento.nrdconta%TYPE, -- Número da conta
                                             pr_nrctremp    IN number,--tbepr_consignado_pagamento.nrctremp%TYPE, -- Número do contrato de emprestimo
                                             pr_nrparepr    IN number)--tbepr_consignado_pagamento.nrparepr%TYPE) -- Número da parcela de emprestimo
                          RETURN NUMBER IS
     /*---------------------------------------------------------------------------------------------------------
      Programa : fn_ret_status_pagto_consignado
      Sistema  : AIMARO
      Sigla    : 
      Autor    : Josiane Stiehler - AMcom
      Data     : 06/05/2019
  
      Objetivo : Retorna o status do processamento do pagamento criado no Evento SOA.
                 Pagamento que irá ocorrer na FIS Brasil

      Alteração:

     ----------------------------------------------------------------------------------------------------------*/
    BEGIN
      DECLARE
       vr_instatus number;--tbepr_consignado_pagamento.instatus%TYPE;

       CURSOR cr_consig_pagto IS      
          SELECT 0 instatus  -- 1- Enviado, 2 - Pagamento efetuado FIS, 3- Erro
            FROM dual; --tbepr_consignado_pagamento
         /*  WHERE cdcooper = pr_cdcooper
             AND nrdconta = pr_nrdconta
             AND nrctremp = pr_nrctremp
             AND nrparepr = pr_nrparepr;*/
       BEGIN
         vr_instatus:= 0;
         FOR rw_consig_pagto IN cr_consig_pagto
         LOOP
           vr_instatus:= rw_consig_pagto.instatus;
         END LOOP;
        RETURN (vr_instatus);
      END;
    END fn_ret_status_pagto_consignado;
    
    -- Montar o XML para registro do Gravames somente CDC 
    PROCEDURE pc_gera_xml_pagamento_consig(pr_cdcooper    IN crapepr.cdcooper%TYPE, -- código da cooperativa
                                           pr_nrdconta    IN crapepr.nrdconta%TYPE, -- Número da conta
                                           pr_nrctremp    IN crapepr.nrctremp%TYPE, -- Número do contrato de emprestimo
                                           pr_nrparepr    IN crappep.nrparepr%TYPE, -- Numero da parcela
                                           pr_dsxmlali   OUT XmlType,               -- XML de saida do pagamento
                                           pr_dscritic   OUT VARCHAR2) IS --> Descricao Erro

    BEGIN
    /* .............................................................................
       Programa : pc_gera_xml_pagamento
       Sistema  : AIMARO
       Sigla    : 
       Autor    : Josiane Stiehler - AMcom
       Data     : 09/05/2019                      Última Alteração:
                        
      Alterações :
                              
    ............................................................................... */
                          
    DECLARE
      -- Código do programa
      vr_cdprogra crapprg.cdprogra%TYPE;
      -- Erro para parar a cadeia
      vr_exc_saida exception;

      -------------- Cursores específicos ----------------

         
                      
      -------------- Variáveis e Tipos -------------------
                        
      vr_cdcritic crapcri.cdcritic%TYPE; --> Código da crítica
      vr_dscritic     VARCHAR2(2000);    --> Descrição da crítica
                              
      -- Variaveis locais para retorno de erro
      vr_des_reto varchar2(4000);
                            
      -- Varchar2 temporário
      vr_dsxmltemp VARCHAR2(32767);

      -- Temporárias para o CLOB
      vr_clobxml CLOB;                   -- CLOB para armazenamento das informações do arquivo
      vr_clobaux VARCHAR2(32767);        -- Var auxiliar para montagem do arquivo

                          
    BEGIN
      --Inicializar variavel erro
      pr_dscritic := NULL;
      
      -- Inicializar as informações do XML de dados
      dbms_lob.createtemporary(vr_clobxml, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_clobxml,dbms_lob.lob_readwrite);
                        
      -- Escrever no arquivo XML
      gene0002.pc_escreve_xml(vr_clobxml
                             ,vr_clobaux
                             ,'<?xml version="1.0" encoding="UTF-8"?><Root>');
                        
      -- Monta XML do pagamento do consignado   
      vr_dsxmltemp:= '<TESTE> TESTE CONSIGNADO </TESTE>';    
      -- Enviar o mesmo ao CLOB
      gene0002.pc_escreve_xml(vr_clobxml
                             ,vr_clobaux
                             ,vr_dsxmltemp); 
                  
                      
      -- Finalizar o XML
      gene0002.pc_escreve_xml(vr_clobxml
                             ,vr_clobaux
                             ,'</Root>'
                             ,TRUE);      
      -- E converter o CLOB para o XMLType de retorno
      pr_dsxmlali := XmlType.createXML(vr_clobxml);
                      
      --Fechar Clob e Liberar Memoria  
      dbms_lob.close(vr_clobxml);
      dbms_lob.freetemporary(vr_clobxml); 
          
      EXCEPTION
        WHEN OTHERS THEN
          -- Montar descrição de erro não tratado
          pr_dscritic := 'Erro não tratado na empr0020.pc_gera_xml_pagamento_consig ' ||
                         sqlerrm;
      END;
      END pc_gera_xml_pagamento_consig;
      
      PROCEDURE  pc_envia_email_erro_int_consig(pr_cdcooper  IN crapepr.cdcooper%TYPE, --Cooperativa
                                              pr_nrdconta    IN crapepr.nrdconta%TYPE, --Conta
                                              pr_nrctremp    IN crapepr.nrctremp%TYPE, --Contrato
                                              pr_nrparepr    IN crappep.nrparepr%TYPE default null, --Parcela (Opcional)
                                              pr_idoperacao  IN NUMBER default null, --ID Operacao (Opcional)
                                              pr_tipoemail   IN VARCHAR2, --Tipo de Email 
                                              pr_msg         IN VARCHAR2, --Mensagem_erro_origem
                                              pr_dscritic    OUT VARCHAR2,
                                              pr_retxml      OUT xmltype
                                              )IS  
                                                                                                         

      BEGIN
        DECLARE       
          vr_email      VARCHAR2(4000) := null ;
          vr_desemail   VARCHAR(4000) := '';
          
          -- Variaveis de Erro
          vr_cdcritic   crapcri.cdcritic%TYPE;
          vr_dscritic   VARCHAR2(4000);
          vr_des_erro   VARCHAR2(10);
          
          -- Variaveis Excecao
          vr_exc_erro   EXCEPTION;  
          

        BEGIN
          SELECT dsvlrprm INTO vr_email FROM crapprm WHERE nmsistem = 'CRED' AND cdcooper = 0 AND cdacesso = 'EMAIL_ERR_INT_CONSIG';
          vr_desemail := 'Consignado<br>
                          Ocorreu um erro no procedimento <b><i>'||pr_tipoemail||'</i></b>, verifique com urgência.<br><br> 
                          
                          Segue abaixo dados do processo executado:<br>
                          <b>Cooperativa:</b> '||pr_cdcooper||' <br>
                          <b>Conta:</b> '||pr_nrdconta||' <br>
                          <b>Contrato:</b> '||pr_nrctremp||' <br>';
          if pr_nrparepr is not null then
              vr_desemail :=  vr_desemail || '<b>Parcela:</b> '||pr_nrparepr||' <br>';
          end if;
          vr_desemail :=  vr_desemail || '<b>Descrição do erro ocorrido:</b> '||pr_msg||' <br>';
          
          if pr_idoperacao is not null then
              vr_desemail :=  vr_desemail || '<b>Id Operação:</b> '||pr_idoperacao||' <br>';
          end if;
          vr_desemail :=  vr_desemail || '<b>Descrição do erro ocorrido:</b> '||pr_msg||' <br>';
          
          IF ((vr_email is not null ) and (pr_msg is not null)) THEN
            -- Envia email 
             gene0003.pc_solicita_email(pr_cdcooper         => 3
                                        ,pr_cdprogra        => 'EMPR0020'
                                        ,pr_des_destino     => vr_email
                                        ,pr_des_assunto     => 'Consignado - Ocorreu um erro no procedimento '|| pr_tipoemail ||', verifique com urgência. '
                                        ,pr_des_corpo       => vr_desemail
                                        ,pr_des_anexo       => NULL --> nao envia anexo, anexo esta disponivel no dir conf. geracao do arq.
                                        ,pr_flg_remove_anex => 'N'  --> Remover os anexos passados
                                        ,pr_flg_remete_coop => 'N'  --> Se o envio sera do e-mail da Cooperativa
                                        ,pr_flg_enviar      => 'S'  --> Enviar o e-mail na hora
                                        ,pr_des_erro        => vr_dscritic);

             -- Se houver erros
             IF vr_dscritic IS NOT NULL THEN
                RAISE vr_exc_erro;
             END IF;  
          END IF;
          
          pr_dscritic := 'OK'; 
          -- Existe para satisfazer exigência da interface. 
          pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><dsmensag>OK</dsmensag></Root>');
          commit; 
        
        
         EXCEPTION
      WHEN vr_exc_erro THEN
         /*  se foi retornado apenas código */
         IF  nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
             /* buscar a descriçao */
             vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
         END IF;
         /* variavel de erro recebe erro ocorrido */
         pr_dscritic := 'NOK';
         -- Carregar XML padrao para variavel de retorno
          pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || vr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
          /* montar descriçao de erro nao tratado */
           vr_dscritic := 'erro não tratado na empr0020.pc_envia_email_erro_pagam_fis ' ||SQLERRM;
           pr_dscritic := 'NOK';
           -- Carregar XML padrao para variavel de retorno
           pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || vr_dscritic || '</Erro></Root>');
      END;
                                               
     END  pc_envia_email_erro_int_consig;
    
   PROCEDURE pc_alt_emp_cooperado_desligado(pr_cdcooper      IN crapepr.cdcooper%TYPE  --> Cooperativa
                                           ,pr_nrdconta      IN crapepr.nrdconta%TYPE  --> Conta
                                           ,pr_flgdesligado  IN VARCHAR2               --> Indica se o cliente foi desligado (1 = Sim / 2 = Nao)
                                           -- campos padrões
                                           ,pr_cdcritic      OUT PLS_INTEGER           --> Codigo da critica
                                           ,pr_dscritic      OUT VARCHAR2              --> Descricao da critica
                                           ,pr_des_erro      OUT VARCHAR2              --> Erros do processo
                                           )IS
   /*---------------------------------------------------------------------------------------------------------
      Programa  : pc_alt_emp_cooperado_desligado
      Sistema   : AIMARO
      Sigla     : 
      Autor     : Fernanda Kelli de Oliveira - AMcom Sistemas de Informação
      Data      : 14/05/2019

      Objetivo  : O sistema Aimaro receberá, via serviço da FIS Brasil, a informação quando cooperado 
                  for desligado da Conveniada e esta rotina irá fazer a alteração da empresa para 
                  9999 (Desligado Consignado) na conta e nos contratos do cooperado.
                  
                  Controle de COMMIT/ROLLBACK será feito pela rotina principal (JOB)

      Alteração :

  ----------------------------------------------------------------------------------------------------------*/
 
  BEGIN
    DECLARE
      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;
      
      -- Variáveis auxiliares
      v_cdempres  crapttl.cdempres%type;
        
    BEGIN
      
      IF pr_flgdesligado IS NULL THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Parâmetro pr_flgdesligado deve ser preenchido. Conta: '||pr_nrdconta|| ' da cooperativa: '||pr_cdcooper;
        RAISE vr_exc_erro;          
      ELSIF pr_flgdesligado = 1 THEN
        --Buscar o Codigo da empresa onde o titular trabalha.       
        BEGIN
          SELECT t.cdempres
            INTO v_cdempres
            FROM crapttl t
           WHERE t.cdcooper = pr_cdcooper
             AND t.nrdconta = pr_nrdconta
             AND t.idseqttl = 1;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            v_cdempres := null; 
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao buscar a empresa da conta: '||pr_nrdconta|| ' da cooperativa: '||pr_cdcooper;
            RAISE vr_exc_erro;
        END;
       
        IF v_cdempres IS NOT NULL AND v_cdempres <> 9999 THEN
          --Atualizar a empresa no Cadastro de titulares da conta para 9999 - Desligado Consignado
          --Contas > Comercial > Empresa 
          BEGIN
            UPDATE crapttl t
               SET t.cdempres = 9999 -- Desligado Consignado
             WHERE t.cdcooper = pr_cdcooper
               AND t.nrdconta = pr_nrdconta
               AND t.idseqttl = 1; 
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao atualizar a empresa da conta: '||pr_nrdconta|| ' da cooperativa: '||pr_cdcooper|| ' para 9999-Desligado Consignado.';
              RAISE vr_exc_erro;  
          END;
          
          --Atualizar a empresa nos Contratos de Consignado do cooperado e desvincular da empresa.
          BEGIN
           UPDATE crapepr c
              SET c.cdempres = 9999
            WHERE c.cdcooper = pr_cdcooper
              AND c.nrdconta = pr_nrdconta              
              AND c.inliquid = 0           --Contrato não liquidado
              AND c.tpdescto = 2           --Desconto em Folha de Pgto
              AND c.tpemprst = 1           --Empréstimo Pré-Fixado  
              AND c.cdempres is not null 
              AND c.cdempres <> 9999;       --ainda esta vinculada a uma empresa
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao atualizar a empresa nos Contratos da conta: '||pr_nrdconta|| ' da cooperativa: '||pr_cdcooper|| ' para 9999-Desligado Consignado.';
              RAISE vr_exc_erro;  
          END;                    
        END IF;  
      END IF;
      
      pr_des_erro := 'OK';
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        IF  vr_cdcritic <> 0 THEN
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        pr_des_erro := 'NOK';
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        --ROLLBACK;
      WHEN OTHERS THEN
        pr_des_erro := 'NOK';
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina tela_consig.pc_excluir_param_consig_web: '||SQLERRM;        
        --ROLLBACK;     
    END;
    
  END pc_alt_emp_cooperado_desligado;                                           
                                             
END EMPR0020;
/
