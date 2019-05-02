CREATE OR REPLACE PACKAGE CECRED.EMPR0020 IS
 /* -----------------------------------------------------------------------------------

    Programa: EMPR0020
    Autor   : Fernanda Kelli de Oliveira / AMcom
    Data    : 02/05/2019    ultima Atualizacao: --

    Dados referentes ao programa:

    Objetivo  : Concentrar rotinas referente ao processo do Crédito Consignado

    Alteracoes:

    ..............................................................................*/

 PROCEDURE pc_validar_dtpgto_antecipada (-- campos padrões
                                          pr_xmllog             IN VARCHAR2              --> XML com informacoes de LOG
                                         ,pr_cdcritic          OUT PLS_INTEGER           --> Codigo da critica
                                         ,pr_dscritic          OUT VARCHAR2              --> Descricao da critica
                                         ,pr_retxml             IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                         ,pr_nmdcampo          OUT VARCHAR2              --> Nome do campo com erro
                                         ,pr_des_erro          OUT VARCHAR2              --> Erros do processo
                                         );

end EMPR0020;
/
CREATE OR REPLACE PACKAGE BODY CECRED.EMPR0020 IS
  /* -----------------------------------------------------------------------------------

    Programa: EMPR0020
    Autor   : Fernanda Kelli de Oliveira / AMcom
    Data    : 02/05/2019    ultima Atualizacao: --

    Dados referentes ao programa:

    Objetivo  : Concentrar rotinas referente ao processo do Crédito Consignado

    Alteracoes:

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
  
END EMPR0020;
/
