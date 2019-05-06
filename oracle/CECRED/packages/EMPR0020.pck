CREATE OR REPLACE PACKAGE CECRED.EMPR0020 IS
 /* -----------------------------------------------------------------------------------

    Programa: EMPR0020
    Autor   : Fernanda Kelli de Oliveira / AMcom
    Data    : 02/05/2019    ultima Atualizacao: --

    Dados referentes ao programa:

    Objetivo  : Concentrar rotinas referente ao processo do Cr�dito Consignado

    Alteracoes:

    ..............................................................................*/

  PROCEDURE pc_validar_dtpgto_antecipada(pr_xmllog      IN VARCHAR2              --> XML com informacoes de LOG
                                        ,pr_cdcritic   OUT PLS_INTEGER           --> Codigo da critica
                                        ,pr_dscritic   OUT VARCHAR2              --> Descricao da critica
                                        ,pr_retxml      IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                        ,pr_nmdcampo   OUT VARCHAR2              --> Nome do campo com erro
                                        ,pr_des_erro   OUT VARCHAR2);            --> Erros do processo
                                                                     
  PROCEDURE pc_efetua_debito_conveniada(pr_cdcooper 		IN crapcop.cdcooper%TYPE --> C�digo da cooperativa
                                       ,pr_cdempres 		IN crapemp.cdempres%TYPE --> C�digo da Empresa que receber� o d�bito
                                       ,pr_cdoperad 		IN VARCHAR2              --> Operador da Consulta � Valor 'xxxxx' para Internet
                                       ,pr_aplOrigem		IN VARCHAR2              --> Aplica��o de Origem da chamada do Servi�o
                                       ,pr_nrdcaixa		  IN INTEGER               --> C�digo de caixa do canal de atendimento � Valor 'XXXX' para Internet
                                       ,pr_dtmvtolt 		IN crapdat.dtmvtolt%TYPE --> Data do movimento atual.
                                       ,pr_vrdebito 		IN NUMBER                --> Valor a ser debitado   
                                       ,pr_idpagto		  IN NUMBER                --> Identificador de pagamento enviado pelo consumidor
                                       ,pr_dscritic 	 OUT VARCHAR2              --> Descri��o da cr�tica          
                                       ,pr_retorno 	   OUT xmltype);                                         

END EMPR0020;
/
CREATE OR REPLACE PACKAGE BODY CECRED.EMPR0020 IS
  /* -----------------------------------------------------------------------------------

    Programa: EMPR0020
    Autor   : Fernanda Kelli de Oliveira / AMcom
    Data    : 02/05/2019    ultima Atualizacao: --

    Dados referentes ao programa:

    Objetivo  : Concentrar rotinas referente ao processo do Cr�dito Consignado

    Alteracoes:

    ..............................................................................*/

  PROCEDURE pc_validar_dtpgto_antecipada (-- campos padr�es
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
      Sigla    : ATENDA->PRESTA��ES->COOPERATIVA
      Autor    : Fernanda Kelli de Oliveira - AMcom Sistemas de Informa��o
      Data     : 02/05/2019

      Objetivo : Na antecipa��o de parcelas para empr�stimos de Consignado que tenham v�nculo com conveniada 
                 cadastrada na tela Consig, o sistema Aimaro dever� validar a data atual de movimento 
                 (a data do dia) para permitir ou n�o a antecipa��o de uma parcela.

      Altera��o :

  ----------------------------------------------------------------------------------------------------------*/
  BEGIN
    DECLARE
       /* Tratamento de erro */
      vr_exc_erro EXCEPTION;

      /* Descri��o e c�digo da critica */
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
      
      --Validar se a empresa possui o Conv�nio do Consignado
      BEGIN
        select epr.cdempres
          into vr_cdempres
          from crapepr epr 
         where epr.cdcooper = vr_cdcooper
           and epr.nrctremp = vr_nrctremp
           and epr.tpdescto = 2  --Tipo de desconto do emprestimo (2 = Desconto em Folha de Pagamento)
           and epr.tpemprst = 1; --Contem o tipo do emprestimo (1 = Pr�-Fixado).
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          vr_cdempres := NULL;
        WHEN OTHERS THEN
          vr_dscritic := 'Numero do contrato deve ser preenchido.';
          RAISE vr_exc_erro;
      END;
      
      IF vr_cdempres IS NULL THEN
        vr_dsmensag := 'N';  -- N�o preciva pedir a Senha do Operador
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
            vr_dsmensag := 'N';  -- N�o preciva pedir a Senha do Operador
          END IF;          
        END LOOP;        
      END IF;  
       
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><dsmensag>'||vr_dsmensag||'</dsmensag></Root>');
    
    EXCEPTION
      WHEN vr_exc_erro THEN
         /*  se foi retornado apenas c�digo */
         IF  nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
             /* buscar a descri�ao */
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
         /* montar descri�ao de erro nao tratado */
           pr_dscritic := 'erro n�o tratado na EMPR0020.PC_VALIDAR_DTPGTO_ANTECIPADA ' ||SQLERRM;
           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;    
  END pc_validar_dtpgto_antecipada;
  
  PROCEDURE pc_efetua_debito_conveniada(pr_cdcooper 		IN crapcop.cdcooper%TYPE --> C�digo da cooperativa
                                       ,pr_cdempres 		IN crapemp.cdempres%TYPE --> C�digo da Empresa que receber� o d�bito
                                       ,pr_cdoperad 		IN VARCHAR2              --> Operador da Consulta � Valor 'xxxxx' para Internet
                                       ,pr_aplOrigem		IN VARCHAR2              --> Aplica��o de Origem da chamada do Servi�o
                                       ,pr_nrdcaixa		  IN INTEGER               --> C�digo de caixa do canal de atendimento � Valor 'XXXX' para Internet
                                       ,pr_dtmvtolt 		IN crapdat.dtmvtolt%TYPE --> Data do movimento atual.
                                       ,pr_vrdebito 		IN NUMBER                --> Valor a ser debitado   
                                       ,pr_idpagto		  IN NUMBER                --> Identificador de pagamento enviado pelo consumidor
                                       ,pr_dscritic 	 OUT VARCHAR2              --> Descri��o da cr�tica          
                                       ,pr_retorno 		 OUT xmltype) IS
  /*---------------------------------------------------------------------------------------------------------
      Programa : pc_efetua_debito_conveniada
      Sistema  : AIMARO
      Sigla    : 
      Autor    : Fernanda Kelli de Oliveira - AMcom Sistemas de Informa��o
      Data     : 03/05/2019
  
      Objetivo : Efetuar d�bito de consignado em conta da conveniada. 
                 Procedure ser� chamada pelo barramento SOA.

      Altera��o:

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
      --Verificar se o registro j� existe
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
        
      --Inserir os par�metros de entrada na tabela de controle de pagamento
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
             null)        --pr_dtupdreg - Data de altera��o do registro
        
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
      
      --Buscar o N�mero da Conta da Empresa
      BEGIN 
        vr_nrdconta := NULL;       
        SELECT crapemp.nrdconta               
          INTO vr_nrdconta                    
          FROM crapemp,
               tbcadast_empresa_consig consig
         WHERE crapemp.cdempres = consig.cdempres
           AND crapemp.cdcooper = consig.cdcooper
           AND consig.indautrepassecc = 1 --Autorizar Debito Repasse em C/C. (0 - Não Autorizado / 1 - Autorizado)
           AND crapemp.cdempres = pr_cdempres
           AND crapemp.cdcooper = pr_cdcooper;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          vr_nrdconta := NULL;
        WHEN OTHERS THEN
          vr_dscritic := 'Problemas no select de busca da data de conta/agencia. ' || SQLERRM;
          RAISE vr_exc_erro; 
      END;
      
      --Caso n�o tenha conta corrente cadastrada na Cademp, ent�o o sistema Aimaro n�o far� o d�bito do repasse.
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
                                      ,pr_cdagenci => vr_cdagenci      --> C�digo da ag�ncia
                                      ,pr_cdbccxlt => 1                --> N�mero do caixa
                                      ,pr_cdoperad => pr_cdoperad      --> C�digo do Operador
                                      ,pr_cdpactra => vr_cdagenci      --> P.A. da transa��o
                                      ,pr_nrdolote => 600014           --> Numero do Lote
                                      ,pr_nrdconta => vr_nrdconta      --> N�mero da conta
                                      ,pr_cdhistor => 2972             --> Codigo historico
                                      ,pr_vllanmto => pr_vrdebito      --> Valor da parcela emprestimo
                                      ,pr_nrparepr => 0                --> N�mero parcelas empr�stimo
                                      ,pr_nrctremp => 0                --> N�mero do contrato de empr�stimo
                                      ,pr_des_reto => vr_des_erro      --> Retorno OK / NOK
                                      ,pr_tab_erro => vr_tab_erro);    --> Tabela com poss�ves erros
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
      vr_dscritic := 'D�bito realizado com sucesso!';      
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
        --Retorno (N�O SUCESSO)
        pr_retorno := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><retorno>' || pr_dscritic || '</retorno></Root>');
        pr_dscritic:= 'Erro ao debitar valor solicitado. ' || vr_dscritic;                                         
      WHEN OTHERS THEN
         --Retorno (N�O SUCESSO)        
        pr_retorno := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><retorno>' || pr_dscritic || '</retorno></Root>');
        pr_dscritic:= 'Erro ao debitar valor solicitado. Erro: ' || sqlerrm;                                         
    END;    
  END pc_efetua_debito_conveniada;                                        
                                   
  
END EMPR0020;
/
