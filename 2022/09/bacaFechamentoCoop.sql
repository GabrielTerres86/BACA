declare

  vr_cdcritic_geral     NUMBER;
  vr_dscritic_geral     VARCHAR2(4000);

  -- Registro dos riscos 
  TYPE typ_risco IS
    RECORD(cdcooper       tbcrd_risco.cdcooper%TYPE
          ,nrdconta       tbcrd_risco.nrdconta%TYPE
          ,nrcontrato     tbcrd_risco.nrcontrato%TYPE
          ,nrseqctr       crapris.nrseqctr%TYPE
          ,cdagencia      crapris.cdagenci%TYPE
          ,nrmodalidade   tbcrd_risco.nrmodalidade%TYPE
          ,dtcadastro     tbcrd_risco.dtcadastro%TYPE
          ,dtvencimento   tbcrd_risco.dtvencimento%TYPE
          ,innivris       crapris.innivris%TYPE
          ,vldivida       crapris.vldivida%TYPE
          ,inpessoa       crapris.inpessoa%TYPE
          ,dtvencop       crapris.dtvencop%TYPE
          ,qtdiaatr       crapris.qtdiaatr%TYPE
          ,nrcpfcgc       crapris.nrcpfcgc%TYPE
          ,dtprxpar       crapris.dtprxpar%TYPE
          ,vlprxpar       crapris.vlprxpar%TYPE
          ,qtparcel       crapris.qtparcel%TYPE
          ,vlvec180       crapris.vlvec180%TYPE
          ,vlvec360       crapris.vlvec360%TYPE
          ,vlvec999       crapris.vlvec999%TYPE
          ,vldiv060       crapris.vldiv060%TYPE
          ,vldiv180       crapris.vldiv180%TYPE
          ,vldiv360       crapris.vldiv360%TYPE
          ,vldiv999       crapris.vldiv999%TYPE
          ,vlprjano       crapris.vlprjano%TYPE
          ,vlprjaan       crapris.vlprjaan%TYPE
          ,vlprjant       crapris.vlprjant%TYPE
          ,cdinfadi       crapris.cdinfadi%TYPE
          ,dsinfaux       crapris.dsinfaux%TYPE
          ,flgindiv       crapris.flgindiv%TYPE
          ,flarrasto      crapris.flarrasto%TYPE);
                
  -- Definição de um tipo de tabela com o registro acima
  TYPE typ_tab_risco IS
    TABLE OF typ_risco
      INDEX BY VARCHAR2(60);

  -- Registro dos riscos 
  TYPE typ_risco_venc IS
    RECORD(cdcooper       tbcrd_risco.cdcooper%TYPE
          ,nrdconta       tbcrd_risco.nrdconta%TYPE
          ,nrcontrato     tbcrd_risco.nrcontrato%TYPE
          ,nrseqctr       crapris.nrseqctr%TYPE
          ,nrmodalidade   tbcrd_risco.nrmodalidade%TYPE
          ,cdvencto       crapvri.cdvencto%TYPE
          ,innivris       crapvri.innivris%TYPE
          ,vldivida       crapvri.vldivida%TYPE);
                
  -- Definição de um tipo de tabela com o registro acima
  TYPE typ_tab_risco_venc IS
    TABLE OF typ_risco_venc
      INDEX BY VARCHAR2(70);

    TYPE typ_tab_risco_temp IS
      TABLE OF typ_risco
        INDEX BY PLS_INTEGER;

    TYPE typ_tab_risco_venc_temp IS
      TABLE OF typ_risco_venc
        INDEX BY PLS_INTEGER;

  PROCEDURE pc_grava_crapris_temporaria_temp(pr_cdcooper     IN tbcrd_risco.cdcooper%TYPE         -- Codigo da cooperativa
                                       ,pr_nrdconta          IN tbcrd_risco.nrdconta%TYPE         -- Numero da conta
                                       ,pr_inpessoa          IN crapris.inpessoa%TYPE             -- Tipo de pessoa
                                       ,pr_nrcontrato        IN tbcrd_risco.nrcontrato%TYPE       -- Numero do contrato
                                       ,pr_nrseqctr          IN crapris.nrseqctr%TYPE             -- Sequencia contrato
                                       ,pr_cdagencia         IN crapris.cdagenci%TYPE             -- Numero da agencia
                                       ,pr_nrcpfcnpj         IN tbcrd_risco.nrcpfcnpj%TYPE        -- CPF/CNPJ
                                       ,pr_nrmodalidade      IN tbcrd_risco.nrmodalidade%TYPE     -- Codigo da modalidade
                                       ,pr_dtultdma_util     IN DATE                              -- Ultima dia util do mes anterior
                                       ,pr_dsnivel_risco     IN VARCHAR2                          -- Nivel do Risco
                                       ,pr_dtcadastro        IN tbcrd_risco.dtcadastro%TYPE       -- Data de abertura da conta cartao
                                       ,pr_dtvencimento      IN tbcrd_risco.dtvencimento%TYPE     -- Data de vencimento
                                       ,pr_vlsaldo_devedor   IN tbcrd_risco.vlsaldo_devedor%TYPE  -- Saldo Devedor
                                       ,pr_dtprxpar          IN crapris.dtprxpar%TYPE             -- Data proxima parcela
                                       ,pr_vlprxpar          IN crapris.vlprxpar%TYPE             -- Valor proxima parcela
                                       ,pr_qtparcel          IN crapris.qtparcel%TYPE             -- Quantidade de parcelas
                                       ,pr_cdinfadi          IN crapris.cdinfadi%TYPE             -- Saida de operação
                                       ,pr_dsinfaux          IN crapris.dsinfaux%TYPE             -- Informação auxiliar
                                       ,pr_calcparc          IN BOOLEAN                           -- Inidica se calcularemos as parcelas ou não
                                       ,pr_tab_risco      IN OUT NOCOPY typ_tab_risco       --> Temp-Table dos Riscos
                                       ,pr_tab_risco_venc IN OUT NOCOPY typ_tab_risco_venc  --> Risco de vencimentos
                                       ,pr_idproduto         IN tbrisco_provisgarant_movto.idproduto%TYPE --> ID do Produto do Movimento Risco de Provisao e Garantia
                                       ,pr_vlarrasto         IN NUMBER                           --> Valor parametrizado para arrasto
                                       ,pr_cdcritic          OUT PLS_INTEGER                     --> Código da critica
                                       ,pr_dscritic          OUT VARCHAR2) IS                    --> Descricao da critica IS
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --  Programa : pc_grava_crapris_temporaria_temp
    --  Sistema  : Ayllos
    --  Sigla    : CRED
    --  Autor    : James Prust Junior
    --  Data     : Fevereiro/2016.                   Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedure para gravar os dados na crapris temporaria
    --
    -- Alterações
    ---------------------------------------------------------------------------------------------------------------
    DECLARE
      vr_ind_risco          VARCHAR2(60);
      vr_indice             VARCHAR2(70);
      vr_cdvencto           NUMBER;
      vr_vlparcel           NUMBER := 0;
      vr_vlsdeved           NUMBER := 0;
      vr_diasvenc           NUMBER := 0;
      vr_dtparcel           date;
      
      -- Variaveis tratamento de erro
      vr_exc_erro           EXCEPTION;
      vr_cdcritic           crapcri.cdcritic%TYPE;
      vr_dscritic           VARCHAR2(4000);
      
      
      vr_vldiv060     crapris.vldiv060%TYPE := 0; --> Valor do atraso quando prazo inferior a 60
      vr_vldiv180     crapris.vldiv180%TYPE := 0; --> Valor do atraso quando prazo inferior a 180
      vr_vldiv360     crapris.vldiv360%TYPE := 0; --> Valor do atraso quando prazo inferior a 360
      vr_vldiv999     crapris.vldiv999%TYPE := 0; --> Valor do atraso para outros casos
      vr_vlvec180     crapris.vlvec180%TYPE := 0; --> Valor a vencer nos próximos 180 dias
      vr_vlvec360     crapris.vlvec360%TYPE := 0; --> Valor a vencer nos próximos 360 dias
      vr_vlvec999     crapris.vlvec999%TYPE := 0; --> Valor a vencer para outros casos
      vr_vlprjano     crapris.vlprjano%TYPE := 0; --> Valor prejuizo no ano corrente
      vr_vlprjaan     crapris.vlprjaan%TYPE := 0; --> Valor prejuizo no ano anterior
      vr_vlprjant     crapris.vlprjant%TYPE := 0; --> Valor prejuizo anterior
      
      -- Vetor para armazenar parcelas
      TYPE typ_reg_parcel IS
        RECORD(dtvencto DATE
              ,cdvencto NUMBER
              ,vlvencto NUMBER);
      TYPE typ_tab_parcel IS
        TABLE OF typ_reg_parcel
          INDEX BY BINARY_INTEGER; --> Id
      vr_tab_parcel typ_tab_parcel;
      
      -- Calcula os dias de atraso do cartao de credito
      FUNCTION fn_calcula_dias_atraso(pr_dtvencimento  IN DATE
                                     ,pr_dtultdma_util IN DATE) RETURN NUMBER IS
      BEGIN
        IF (pr_dtvencimento - pr_dtultdma_util) <= 0 THEN
          RETURN ABS(pr_dtvencimento - pr_dtultdma_util);
        END IF;
        
        RETURN 0;        
      END;     
      
      -- Subrotina para calculo do código de vencimento
      FUNCTION fn_calc_codigo_vcto(pr_diasvenc IN OUT NUMBER
                                  ,pr_qtdiapre IN NUMBER DEFAULT 0
                                  ,pr_flgempre IN BOOLEAN DEFAULT FALSE) RETURN NUMBER IS
      BEGIN
        -- Se for crédito a vencer
        IF pr_diasvenc >= 0  THEN
          IF  pr_diasvenc <= 30 THEN
            RETURN 110;
          ELSIF pr_diasvenc <= 60 THEN
            IF pr_qtdiapre <= 30 AND pr_flgempre THEN
              RETURN 110;
            ELSE
             RETURN 120;
            END IF;
          ELSIF pr_diasvenc <= 90 THEN
            IF pr_qtdiapre <= 60 AND pr_flgempre THEN
              RETURN 120;
            ELSE
              RETURN 130;
            END IF;
          ELSIF pr_diasvenc <= 180 THEN
            IF pr_qtdiapre <= 90 AND pr_flgempre THEN
              RETURN 130;
            ELSE
              RETURN 140;
            END IF;
          ELSIF pr_diasvenc <= 360 THEN
            IF pr_qtdiapre <= 180 AND pr_flgempre THEN
              RETURN 140;
            ELSE
              RETURN 150;
            END IF;
          ELSIF pr_diasvenc <= 720 THEN
            IF pr_qtdiapre <= 360 AND pr_flgempre THEN
              RETURN 150;
            ELSE
              RETURN 160;
            END IF;
          ELSIF pr_diasvenc <= 1080 THEN
            IF pr_qtdiapre <= 720 AND pr_flgempre THEN
              RETURN 160;
            ELSE
              RETURN 165;
            END IF;
          ELSIF  pr_diasvenc <= 1440 THEN
            IF pr_qtdiapre <= 1080 AND pr_flgempre THEN
              RETURN 165;
            ELSE
              RETURN 170;
            END IF;
          ELSIF pr_diasvenc <= 1800 THEN
            IF pr_qtdiapre <= 1440 AND pr_flgempre THEN
              RETURN 170;
            ELSE
              RETURN 175;
            END IF;
          ELSIF pr_diasvenc <= 5400 THEN
            IF pr_qtdiapre <= 1800 AND pr_flgempre THEN
              RETURN 175;
            ELSE
              RETURN 180;
            END IF;
          ELSIF pr_qtdiapre <= 5400 AND pr_flgempre THEN
            RETURN 180;
          ELSE
            RETURN 190;
          END IF;
        ELSE -- Creditos Vencidos
          -- Multiplicar por -1 para que os dias fiquem no passado
          pr_diasvenc := pr_diasvenc * -1;
          IF pr_diasvenc <= 14 THEN
            RETURN 205;
          ELSIF pr_diasvenc <= 30 THEN
            RETURN 210;
          ELSIF pr_diasvenc <= 60 THEN
            RETURN 220;
          ELSIF pr_diasvenc <= 90 THEN
            RETURN 230;
          ELSIF pr_diasvenc <= 120 THEN
            RETURN 240;
          ELSIF pr_diasvenc <= 150 THEN
            RETURN 245;
          ELSIF pr_diasvenc <= 180 THEN
            RETURN 250;
          ELSIF pr_diasvenc <= 240 THEN
            RETURN 255;
          ELSIF pr_diasvenc <= 300 THEN
            RETURN 260;
          ELSIF pr_diasvenc <= 360 THEN
            RETURN 270;
          ELSIF pr_diasvenc <= 540 THEN
            RETURN 280;
          ELSE
            RETURN 290;
          END IF;
        END IF;
      END;
      
      
    BEGIN
      vr_ind_risco := LPAD(pr_nrdconta,20,'0') || LPAD(pr_nrcontrato,20,'0') || LPAD(pr_nrmodalidade,10,'0') ||lpad(pr_nrseqctr,10,'0');
      IF NOT pr_tab_risco.EXISTS(vr_ind_risco) THEN
        pr_tab_risco(vr_ind_risco).cdcooper     := pr_cdcooper;
        pr_tab_risco(vr_ind_risco).nrdconta     := pr_nrdconta;
        pr_tab_risco(vr_ind_risco).nrcontrato   := pr_nrcontrato;
        pr_tab_risco(vr_ind_risco).nrseqctr     := pr_nrseqctr;
        pr_tab_risco(vr_ind_risco).nrmodalidade := pr_nrmodalidade;
        pr_tab_risco(vr_ind_risco).dtcadastro   := pr_dtcadastro;
        pr_tab_risco(vr_ind_risco).inpessoa     := pr_inpessoa;
        pr_tab_risco(vr_ind_risco).dtvencimento := pr_dtvencimento;
        pr_tab_risco(vr_ind_risco).dtvencop     := pr_dtvencimento;
        pr_tab_risco(vr_ind_risco).cdagencia    := pr_cdagencia;
        pr_tab_risco(vr_ind_risco).qtdiaatr     := 0;
        pr_tab_risco(vr_ind_risco).nrcpfcgc     := pr_nrcpfcnpj;
        pr_tab_risco(vr_ind_risco).vldivida     := 0;
        pr_tab_risco(vr_ind_risco).dtprxpar     := pr_dtprxpar;
        pr_tab_risco(vr_ind_risco).vlprxpar     := pr_vlprxpar;
        pr_tab_risco(vr_ind_risco).qtparcel     := pr_qtparcel;
        pr_tab_risco(vr_ind_risco).flgindiv     := 0;
        pr_tab_risco(vr_ind_risco).cdinfadi     := pr_cdinfadi;
        pr_tab_risco(vr_ind_risco).dsinfaux     := pr_dsinfaux;
      ELSE       
        -- Data de vencimento da operacao
        IF (pr_dtvencimento > pr_tab_risco(vr_ind_risco).dtvencop) THEN
          pr_tab_risco(vr_ind_risco).dtvencop := pr_dtvencimento;
        END IF;
              
        -- Menor data de vencimento
        IF (pr_dtvencimento < pr_tab_risco(vr_ind_risco).dtvencimento) THEN
          pr_tab_risco(vr_ind_risco).dtvencimento := pr_dtvencimento;
        END IF;
        
      END IF;
      
      pr_tab_risco(vr_ind_risco).vldivida := pr_tab_risco(vr_ind_risco).vldivida + NVL(pr_vlsaldo_devedor,0);
        
      -- Calculo da quantidade de dias em atraso somente quando há saldo
      IF pr_tab_risco(vr_ind_risco).vldivida > 0 THEN 
        pr_tab_risco(vr_ind_risco).qtdiaatr := fn_calcula_dias_atraso(pr_dtvencimento  => pr_tab_risco(vr_ind_risco).dtvencimento
                                                                     ,pr_dtultdma_util => pr_dtultdma_util);
      END IF;
          
      -- Calculo do nivel de risco
      pr_tab_risco(vr_ind_risco).innivris := risc0003.fn_calcula_nivel_risco(pr_dsnivel_risco); 
      
      -- Saída ou Operação sem Saldo não necessita VRI
      IF pr_cdinfadi != '0301' AND pr_tab_risco(vr_ind_risco).vldivida > 0 THEN 
      
        -- Se operação vencida ou Para cartões ou Remessas sem Fluxo Financeiro
        IF pr_tab_risco(vr_ind_risco).qtdiaatr > 0 OR NOT pr_calcparc THEN 
          -- Sem atraso
          IF pr_tab_risco(vr_ind_risco).qtdiaatr > 0 THEN
            -- Multiplicar por -1 para significar atraso
            pr_tab_risco(vr_ind_risco).qtdiaatr := pr_tab_risco(vr_ind_risco).qtdiaatr *-1;
          ELSE
            -- Para cartões ou sem Fluxo Financeiro, não há atraso
            pr_tab_risco(vr_ind_risco).qtdiaatr := 0;
          END IF;
          
          -- Calcular o código do vencimento conforme dias de atraso 
          vr_cdvencto := fn_calc_codigo_vcto(pr_diasvenc => pr_tab_risco(vr_ind_risco).qtdiaatr); 
          
          -- Posicionar 
          IF pr_tab_risco(vr_ind_risco).qtdiaatr = 0 THEN
            vr_vlvec180 := vr_vlvec180 + pr_tab_risco(vr_ind_risco).vldivida;
          ELSIF pr_tab_risco(vr_ind_risco).qtdiaatr <= 60 THEN
            vr_vldiv060 := vr_vldiv060 + pr_tab_risco(vr_ind_risco).vldivida;
          ELSIF pr_tab_risco(vr_ind_risco).qtdiaatr <= 180 THEN
            vr_vldiv180 := vr_vldiv180 + pr_tab_risco(vr_ind_risco).vldivida;
          ELSIF pr_tab_risco(vr_ind_risco).qtdiaatr <= 360 THEN
            vr_vldiv360 := vr_vldiv360 + pr_tab_risco(vr_ind_risco).vldivida;
          ELSE
            vr_vldiv999 := vr_vldiv999 + pr_tab_risco(vr_ind_risco).vldivida;
          END IF;
          
          -- Criar o único registro na VRI lançando todo o saldo vencido
          vr_indice    := LPAD(pr_nrdconta,20,'0') || LPAD(pr_nrcontrato,20,'0') || lpad(pr_nrmodalidade,10,'0') ||lpad(pr_nrseqctr,10,'0') || LPAD(vr_cdvencto,10,'0');
          IF NOT pr_tab_risco_venc.EXISTS(vr_indice) THEN
            pr_tab_risco_venc(vr_indice).cdcooper     := pr_cdcooper;
            pr_tab_risco_venc(vr_indice).nrdconta     := pr_nrdconta;
            pr_tab_risco_venc(vr_indice).nrcontrato   := pr_nrcontrato;        
            pr_tab_risco_venc(vr_indice).nrseqctr     := pr_nrseqctr;        
            pr_tab_risco_venc(vr_indice).innivris     := pr_tab_risco(vr_ind_risco).innivris;
            pr_tab_risco_venc(vr_indice).nrmodalidade := pr_nrmodalidade;
            pr_tab_risco_venc(vr_indice).cdvencto     := vr_cdvencto;
            pr_tab_risco_venc(vr_indice).vldivida     := 0;
          END IF;
          pr_tab_risco_venc(vr_indice).vldivida := pr_tab_risco_venc(vr_indice).vldivida + NVL(pr_vlsaldo_devedor,0);
          
        ELSE
          -- Calcular quantas parcelas serão necessárias para a quitação
          vr_vlsdeved := pr_tab_risco(vr_ind_risco).vldivida;
          vr_tab_parcel.delete();
          vr_dtparcel := nvl(pr_tab_risco(vr_ind_risco).dtprxpar,pr_dtultdma_util+1);
          -- Adicionar primeira parcela
          vr_tab_parcel(0).dtvencto := vr_dtparcel;        
          LOOP
            -- Próxima data
            vr_dtparcel := add_months(vr_dtparcel,1);  
            -- Sair quando próxima ultrapassar o vencimento
            EXIT WHEN vr_dtparcel > pr_tab_risco(vr_ind_risco).dtvencimento;
            -- Adicionar ao vetor 
            vr_tab_parcel(vr_tab_parcel.count()).dtvencto := vr_dtparcel;   
          END LOOP;
          -- Calcular o valor da parcela
          IF vr_tab_parcel.count() = 1 THEN
            -- Valor da parcela é o saldo devedor
            vr_vlparcel := pr_tab_risco(vr_ind_risco).vldivida;
          ELSE
            -- Dividir valor da divida pela quantidade parcelas
            vr_vlparcel := round(pr_tab_risco(vr_ind_risco).vldivida / vr_tab_parcel.count(),2);
          END IF;
          -- Para cada parcela
          FOR vr_idx IN 0..vr_tab_parcel.count()-1 LOOP
            -- Calcular o código do vencimento conforme dias até próxima parcela
            vr_diasvenc := vr_tab_parcel(vr_idx).dtvencto-(pr_dtultdma_util+1);
            IF (pr_idproduto is not null and pr_idproduto = 8 /*08-FINAME BRDE*/) THEN
              IF (pr_dtvencimento >= (pr_dtultdma_util+1)) THEN
                vr_diasvenc := pr_dtvencimento-(pr_dtultdma_util+1);
              ELSE
                vr_diasvenc := (pr_dtultdma_util+1)-(pr_dtultdma_util+1);
              END IF;
            end if;
            vr_tab_parcel(vr_idx).cdvencto := fn_calc_codigo_vcto(pr_diasvenc => vr_diasvenc); 
            
            -- Na ultima parcela 
            IF vr_idx = vr_tab_parcel.count()-1 THEN 
              -- Utilizar o resto 
              vr_tab_parcel(vr_idx).vlvencto := vr_vlsdeved;
            ELSE
              -- Utilizar valor da parcela
              vr_tab_parcel(vr_idx).vlvencto := vr_vlparcel;
              -- Decrementar
              vr_vlsdeved := vr_vlsdeved - vr_vlparcel;
            END IF;
            -- Acumular na variavel correspondente de acordo com a quantidade de dias
            IF vr_diasvenc <= 180 THEN
              vr_vlvec180 := vr_vlvec180 + vr_tab_parcel(vr_idx).vlvencto;
            ELSIF vr_diasvenc <= 360 THEN
              vr_vlvec360 := vr_vlvec360 + vr_tab_parcel(vr_idx).vlvencto;
            ELSE
              vr_vlvec999 := vr_vlvec999 + vr_tab_parcel(vr_idx).vlvencto;
            END IF;
          END LOOP;
          
          -- Iterar novamente para criação da VRI
          FOR vr_idx IN 0..vr_tab_parcel.count()-1 LOOP
            vr_indice    := LPAD(pr_nrdconta,20,'0') || LPAD(pr_nrcontrato,20,'0') || lpad(pr_nrmodalidade,10,'0') ||lpad(pr_nrseqctr,10,'0') || LPAD(vr_tab_parcel(vr_idx).cdvencto,10,'0');
            IF NOT pr_tab_risco_venc.EXISTS(vr_indice) THEN
              pr_tab_risco_venc(vr_indice).cdcooper     := pr_cdcooper;
              pr_tab_risco_venc(vr_indice).nrdconta     := pr_nrdconta;
              pr_tab_risco_venc(vr_indice).nrcontrato   := pr_nrcontrato;        
              pr_tab_risco_venc(vr_indice).nrseqctr     := pr_nrseqctr;        
              pr_tab_risco_venc(vr_indice).innivris     := pr_tab_risco(vr_ind_risco).innivris;
              pr_tab_risco_venc(vr_indice).nrmodalidade := pr_nrmodalidade;
              pr_tab_risco_venc(vr_indice).cdvencto     := vr_tab_parcel(vr_idx).cdvencto;
              pr_tab_risco_venc(vr_indice).vldivida     := 0;
            END IF;
            pr_tab_risco_venc(vr_indice).vldivida := pr_tab_risco_venc(vr_indice).vldivida + NVL(vr_tab_parcel(vr_idx).vlvencto,0);
          END LOOP;
        END IF;
      END IF;  
      
      -- Gravar nos campos de vencimentos, a vencer, e projeções
      pr_tab_risco(vr_ind_risco).vlvec180 := nvl(vr_vlvec180,0);
      pr_tab_risco(vr_ind_risco).vlvec360 := nvl(vr_vlvec360,0);
      pr_tab_risco(vr_ind_risco).vlvec999 := nvl(vr_vlvec999,0);
      pr_tab_risco(vr_ind_risco).vldiv060 := nvl(vr_vldiv060,0);
      pr_tab_risco(vr_ind_risco).vldiv180 := nvl(vr_vldiv180,0);
      pr_tab_risco(vr_ind_risco).vldiv360 := nvl(vr_vldiv360,0);
      pr_tab_risco(vr_ind_risco).vldiv999 := nvl(vr_vldiv999,0);
      pr_tab_risco(vr_ind_risco).vlprjano := nvl(vr_vlprjano,0);
      pr_tab_risco(vr_ind_risco).vlprjaan := nvl(vr_vlprjaan,0);
      pr_tab_risco(vr_ind_risco).vlprjant := nvl(vr_vlprjant,0);
      
      pr_tab_risco(vr_ind_risco).flarrasto := 1;
      -- Se for AA marca a flag como nao arrastar
      IF risc0003.fn_calcula_nivel_risco(pr_dsnivel_risco) = 1 THEN
        pr_tab_risco(vr_ind_risco).flarrasto := 0;
      END IF;
      -- Divida menor que o valor do parametro do arrasto (Materialidade)
      IF pr_vlarrasto > pr_tab_risco(vr_ind_risco).vldivida THEN
        pr_tab_risco(vr_ind_risco).flarrasto := 0;
      END IF;
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        --Variavel de erro recebe erro ocorrido
        IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        -- Descricao do erro
        pr_dscritic := 'Erro nao tratado na risc0003.pc_grava_crapris_temporaria_temp ' || SQLERRM;
    END;
    
  END pc_grava_crapris_temporaria_temp;


  PROCEDURE pc_fecham_risco_garantia_prest(pr_cdcooper  IN crapcop.cdcooper%TYPE    --> codigo da cooperativa
                                          ,pr_dtrefere  IN DATE                     --> Data de Referencia
                                          ,pr_cdcritic OUT PLS_INTEGER              --> Código da critica
                                          ,pr_dscritic OUT VARCHAR2) IS             --> Descricao da critica
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --  Programa : pc_fecham_risco_garantia_prest
    --  Sistema  : Ayllos
    --  Sigla    : CRED
    --  Autor    : Andrei Vieira
    --  Data     : Maio/2017.                   Ultima atualizacao: 25/01/2021
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Converter os movimentos criados na tabela tbrisco_provisgarant_movto para crapris
    --
    -- Alterações : 25/01/2021 - Squad Risco - Implementação de tratamento na atualização da crapvri para quando
    --                           não encontrar o vencimento inserir (Luiz Otávio Olinger Momm/AMCOM)
    ---------------------------------------------------------------------------------------------------------------
    DECLARE

    ----------------------------- CURSORES -------------------------------

      -- Busca as cooperativas
      CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT crapcop.cdagebcb
              ,crapcop.nmrescop
              ,crapcop.dsdircop
          FROM crapcop
         WHERE cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- Busca dos associados unindo com seu saldo na conta
      CURSOR cr_crapass IS
        SELECT crapass.nrdconta,
               crapass.cdagenci,
               crapass.inpessoa,
               crapass.nrcpfcgc
          FROM crapass
         WHERE crapass.cdcooper = pr_cdcooper
           AND EXISTS(SELECT 1 
                        FROM tbrisco_provisgarant_movto 
                       WHERE tbrisco_provisgarant_movto.cdcooper = crapass.cdcooper
                         AND tbrisco_provisgarant_movto.nrdconta = crapass.nrdconta
                         AND tbrisco_provisgarant_movto.dtbase   = pr_dtrefere);

      TYPE typ_crapass_bulk IS TABLE OF cr_crapass%ROWTYPE INDEX BY PLS_INTEGER;
      vr_crapass_bulk typ_crapass_bulk;

      -- Verificar se existe lançamento sem conta
      CURSOR cr_movto_sem_conta IS
        SELECT 1
          FROM tbrisco_provisgarant_movto mvto 
         WHERE mvto.cdcooper  = pr_cdcooper
           AND mvto.dtbase    = pr_dtrefere
           AND mvto.nrdconta  = 0;
      vr_exis_cta_zero NUMBER;

      -- Busca os movimentos lançados para a data de referência
      CURSOR cr_movto IS
        SELECT mvto.idmovto_risco
              ,mvto.idproduto 
              ,mvto.cdcooper
              ,mvto.nrdconta
              ,mvto.nrctremp
              ,mvto.nrcpfcgc
              ,mvto.cdclassifica_operacao
              ,mvto.dtvenc_operacao
              ,mvto.vlsaldo_pendente
              ,risc0003.fn_valor_opcao_dominio(prod.idmodalidade) nrmodalidade
              ,mvto.dtproxima_parcela
              ,mvto.vlparcela
              ,mvto.qtdparcelas
              ,mvto.dtlib_operacao
              ,upper(prod.tparquivo) tparquivo
              ,prod.flpermite_fluxo_financeiro
              ,decode(mvto.flsaida_operacao,1,'0301',' ') cdinfadi
              ,ROW_NUMBER ()
                 OVER (PARTITION BY mvto.nrdconta
                           ORDER BY mvto.nrdconta) nrseqctr
          FROM tbrisco_provisgarant_prodt prod
              ,tbrisco_provisgarant_movto mvto
         WHERE mvto.idproduto = prod.idproduto
           AND mvto.cdcooper  = pr_cdcooper
           AND mvto.dtbase    = pr_dtrefere
         ORDER BY mvto.nrdconta;

      ----------------- TIPOS E REGISTROS -------------------
      -- Definicao dos registros da tabela crapass

      TYPE typ_reg_crapass IS
        RECORD(inpessoa crapass.inpessoa%TYPE
              ,cdagenci crapass.cdagenci%TYPE
              ,nrcpfcgc crapass.nrcpfcgc%TYPE);
      
      TYPE typ_tab_crapass IS
        TABLE OF typ_reg_crapass
          INDEX BY VARCHAR2(50);

      -- Tabela para armazenar os registros do arquivo
      vr_tab_risco           typ_tab_risco;
      vr_tab_risco_temp      typ_tab_risco_temp;
      vr_tab_risco_venc      typ_tab_risco_venc;
      vr_tab_risco_venc_temp typ_tab_risco_venc_temp;
      vr_tab_crapass         typ_tab_crapass;

      -------------------------- Variaveis ----------------------------------------
      vr_indice               VARCHAR2(70);
      vr_ind_crapvri          VARCHAR2(70);
      vr_dtultdma_util        DATE;                             -- Data do ultimo dia util do mes anterior
      vr_calcparc             BOOLEAN;
      vr_dstextab             craptab.dstextab%TYPE;
      vr_vlarrasto            NUMBER;
      
      -- Variaveis de Erro
      vr_cdcritic             crapcri.cdcritic%TYPE;
      vr_dscritic             VARCHAR2(4000);

      -- Variaveis Excecao
      vr_exc_erro             EXCEPTION;
    BEGIN
      vr_tab_crapass.DELETE;

      -- Ignorar o parâmetro financeiro, para checarmos se a central de risco está liberada 
/*
      IF risc0003.fn_periodo_habilitado(pr_cdcooper => pr_cdcooper
                              ,pr_dtbase   => pr_dtrefere
                              ,pr_prmfinan => FALSE) = 0 THEN
        -- Gerar critica 411
        vr_cdcritic := 411;
        RAISE vr_exc_erro;
      END IF;

      -- Se a digitação já estiver fechada
      IF risc0003.fn_periodo_habilitado(pr_cdcooper => pr_cdcooper
                              ,pr_dtbase => pr_dtrefere) = 0 THEN 
        -- Nao conseguiremos reabrir a digitação pois a TAB principal já não está liberada
        vr_dscritic := 'Periodo de digitacao nao liberado - Nao eh necessario fecha-lo!';
        RAISE vr_exc_erro;
      END IF;
*/
      -- Ultima data util do mes anterior
      vr_dtultdma_util := gene0005.fn_valida_dia_util(pr_cdcooper  => pr_cdcooper, -- Cooperativa
                                                      pr_dtmvtolt  => pr_dtrefere, -- Data de referencia
                                                      pr_tipo      => 'A');
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      -- Se nao encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois havera raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;

      -- Verificar se existe lançamentos sem conta 
      OPEN cr_movto_sem_conta;
      FETCH cr_movto_sem_conta
       INTO vr_exis_cta_zero;
      -- Se encontrar
      IF cr_movto_sem_conta%FOUND THEN
        -- Gerar critica
        CLOSE cr_movto_sem_conta;
        vr_dscritic := 'Existe movimentos sem Conta - Favor ajustar o cadastro dos mesmos!';
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_movto_sem_conta;
      END IF;

      -- Buscar todas os tipos de pessoa
      OPEN cr_crapass;
      LOOP
        FETCH cr_crapass BULK COLLECT INTO vr_crapass_bulk LIMIT 50000; -- carrega de 50 em 50 mil registros
        EXIT WHEN vr_crapass_bulk.COUNT = 0;              
        IF vr_crapass_bulk.COUNT > 0 THEN
          -- percorre a PLTABLE refazendo o indice com a composicao dos campos
          FOR idx IN vr_crapass_bulk.FIRST..vr_crapass_bulk.LAST LOOP
            -- Armazenar na tabela de memória
            vr_tab_crapass(vr_crapass_bulk(idx).nrdconta).inpessoa := vr_crapass_bulk(idx).inpessoa;
            vr_tab_crapass(vr_crapass_bulk(idx).nrdconta).cdagenci := vr_crapass_bulk(idx).cdagenci;
            vr_tab_crapass(vr_crapass_bulk(idx).nrdconta).nrcpfcgc := vr_crapass_bulk(idx).nrcpfcgc;
          END LOOP;
        END IF;        
        vr_crapass_bulk.DELETE;
      END LOOP;
      CLOSE cr_crapass;

      vr_cdcritic  := 0;
      vr_dscritic  := '';
      
      -- Chamar função que busca o dstextab para retornar o valor de arrasto
      -- no parâmetro de sistema RISCOBACEN
      vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'RISCOBACEN'
                                               ,pr_tpregist => 000);
      -- Se a variavel voltou vazia
      IF vr_dstextab IS NULL THEN
        vr_cdcritic := 55;
        -- Envio centralizado de log de erro
        RAISE vr_exc_erro;
      END IF;
      -- Por fim, tenta converter o valor de arrasto presente na posição 3 até 12
      vr_vlarrasto := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,3,9));

      -- Busca os registros da tabela de Movimento
      FOR rw_movto IN cr_movto LOOP

        -- Se cartão ou remessa sem fluxo financeiro
        IF rw_movto.tparquivo LIKE '%CARTAO%' OR rw_movto.flpermite_fluxo_financeiro = 0 OR rw_movto.dtproxima_parcela IS NULL THEN 
          vr_calcparc := FALSE;
        ELSE
          vr_calcparc := TRUE;
        END IF;

        -----------------------------------------------------------------------------------------------------------
        --  INICIO PARA MONTAR OS REGISTROS PARA A CENTRAL DE RISCO
        -----------------------------------------------------------------------------------------------------------              
        pc_grava_crapris_temporaria_temp(pr_cdcooper          => rw_movto.cdcooper
                                   ,pr_nrdconta          => rw_movto.nrdconta
                                   ,pr_inpessoa          => vr_tab_crapass(rw_movto.nrdconta).inpessoa
                                   ,pr_nrcontrato        => rw_movto.nrctremp
                                   ,pr_nrseqctr          => rw_movto.nrseqctr
                                   ,pr_cdagencia         => vr_tab_crapass(rw_movto.nrdconta).cdagenci
                                   ,pr_nrcpfcnpj         => rw_movto.nrcpfcgc
                                   ,pr_nrmodalidade      => rw_movto.nrmodalidade
                                   ,pr_dsnivel_risco     => rw_movto.cdclassifica_operacao
                                   ,pr_dtultdma_util     => vr_dtultdma_util
                                   ,pr_dtcadastro        => rw_movto.dtlib_operacao
                                   ,pr_dtvencimento      => rw_movto.dtvenc_operacao
                                   ,pr_vlsaldo_devedor   => rw_movto.vlsaldo_pendente
                                   ,pr_dtprxpar          => rw_movto.dtproxima_parcela
                                   ,pr_vlprxpar          => rw_movto.vlparcela
                                   ,pr_qtparcel          => rw_movto.qtdparcelas
                                   ,pr_cdinfadi          => rw_movto.cdinfadi
                                   ,pr_dsinfaux          => rw_movto.idmovto_risco
                                   ,pr_calcparc          => vr_calcparc
                                   ,pr_tab_risco         => vr_tab_risco
                                   ,pr_tab_risco_venc    => vr_tab_risco_venc
                                   ,pr_idproduto         => rw_movto.idproduto
                                   ,pr_vlarrasto         => vr_vlarrasto
                                   ,pr_cdcritic          => vr_cdcritic
                                   ,pr_dscritic          => vr_dscritic);

        IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      END LOOP;

      -----------------------------------------------------------------------------------------------------------
      --  INICIO PARA GRAVAR OS REGISTROS CRAPRIS
      -----------------------------------------------------------------------------------------------------------
      vr_indice := vr_tab_risco.first;
      WHILE vr_indice IS NOT NULL LOOP
        -- Reposicionar na tabela
        vr_tab_risco_temp(vr_tab_risco_temp.count + 1) := vr_tab_risco(vr_indice); 
        -- Proximo idx
        vr_indice := vr_tab_risco.next(vr_indice);
      END LOOP;

      BEGIN
        FORALL idx IN INDICES OF vr_tab_risco_temp SAVE EXCEPTIONS
          INSERT INTO crapris
                   (  nrdconta,
                      dtrefere,
                      innivris,
                      qtdiaatr,
                      vldivida,
                      inpessoa,
                      nrcpfcgc,
                      inddocto,
                      cdmodali,
                      nrctremp,
                      nrseqctr,
                      dtinictr,
                      cdorigem,
                      cdagenci,
                      innivori,
                      cdcooper,
                      inindris,
                      cdinfadi,
                      dtvencop,
                      vlvec180,
                      vlvec360,
                      vlvec999,
                      vldiv060,
                      vldiv180,
                      vldiv360,
                      vldiv999,
                      vlprjano,
                      vlprjaan,
                      vlprjant,
                      vlprxpar,
                      dtprxpar,
                      qtparcel,
                      dsinfaux,
                      flgindiv,
                      flarrasto)  
              VALUES (vr_tab_risco_temp(idx).nrdconta,
                      pr_dtrefere,
                      vr_tab_risco_temp(idx).innivris,
                      ABS(vr_tab_risco_temp(idx).qtdiaatr),
                      vr_tab_risco_temp(idx).vldivida,
                      vr_tab_risco_temp(idx).inpessoa,
                      vr_tab_risco_temp(idx).nrcpfcgc,
                      5, --inddocto
                      vr_tab_risco_temp(idx).nrmodalidade,
                      vr_tab_risco_temp(idx).nrcontrato,
                      vr_tab_risco_temp(idx).nrseqctr,
                      vr_tab_risco_temp(idx).dtcadastro,
                      7, --cdorigem
                      vr_tab_risco_temp(idx).cdagencia,
                      vr_tab_risco_temp(idx).innivris, --innivori
                      vr_tab_risco_temp(idx).cdcooper,
                      vr_tab_risco_temp(idx).innivris, --inindris
                      vr_tab_risco_temp(idx).cdinfadi, --cdinfadi
                      vr_tab_risco_temp(idx).dtvencop,
                      vr_tab_risco_temp(idx).vlvec180,
                      vr_tab_risco_temp(idx).vlvec360,
                      vr_tab_risco_temp(idx).vlvec999,
                      vr_tab_risco_temp(idx).vldiv060,
                      vr_tab_risco_temp(idx).vldiv180,
                      vr_tab_risco_temp(idx).vldiv360,
                      vr_tab_risco_temp(idx).vldiv999,
                      vr_tab_risco_temp(idx).vlprjano,
                      vr_tab_risco_temp(idx).vlprjaan,
                      vr_tab_risco_temp(idx).vlprjant,
                      vr_tab_risco_temp(idx).vlprxpar,
                      vr_tab_risco_temp(idx).dtprxpar,
                      vr_tab_risco_temp(idx).qtparcel,
                      vr_tab_risco_temp(idx).dsinfaux,
                      vr_tab_risco_temp(idx).flgindiv,
                      vr_tab_risco_temp(idx).flarrasto);
      EXCEPTION
        WHEN others THEN
          -- Gerar erro
          vr_dscritic := 'Erro ao inserir na tabela crapris. '|| SQLERRM(-(SQL%BULK_EXCEPTIONS(1).ERROR_CODE));
          RAISE vr_exc_erro;
      END;

      -----------------------------------------------------------------------------------------------------------
      --  INICIO PARA GRAVAR OS REGISTROS CRAPVRI
      -----------------------------------------------------------------------------------------------------------
      vr_indice := vr_tab_risco_venc.first;
      WHILE vr_indice IS NOT NULL LOOP
        -- Indice da tabela de memoria crapvri
        vr_ind_crapvri := vr_tab_risco_venc_temp.count + 1;
        -- Reposicionar a tabela
        vr_tab_risco_venc_temp(vr_ind_crapvri)          := vr_tab_risco_venc(vr_indice);
        -- Proximo indice
        vr_indice := vr_tab_risco_venc.next(vr_indice);
      END LOOP;

      BEGIN
        FOR idx IN 1..vr_tab_risco_venc_temp.count LOOP
          UPDATE crapvri
             SET vldivida = nvl(vr_tab_risco_venc_temp(idx).vldivida,0)
           WHERE cdcooper = vr_tab_risco_venc_temp(idx).cdcooper
             AND dtrefere = pr_dtrefere
             AND nrdconta = vr_tab_risco_venc_temp(idx).nrdconta
             AND innivris = vr_tab_risco_venc_temp(idx).innivris
             AND cdmodali = vr_tab_risco_venc_temp(idx).nrmodalidade
             AND nrctremp = vr_tab_risco_venc_temp(idx).nrcontrato
             AND nrseqctr = vr_tab_risco_venc_temp(idx).nrseqctr
             AND cdvencto = vr_tab_risco_venc_temp(idx).cdvencto;

          IF SQL%ROWCOUNT = 0 THEN
            INSERT INTO crapvri(cdcooper
                               ,nrdconta
                               ,dtrefere
                               ,innivris
                               ,cdmodali
                               ,cdvencto
                               ,nrctremp
                               ,nrseqctr
                               ,vldivida)
                        VALUES (vr_tab_risco_venc_temp(idx).cdcooper
                               ,vr_tab_risco_venc_temp(idx).nrdconta
                               ,pr_dtrefere
                               ,vr_tab_risco_venc_temp(idx).innivris
                               ,vr_tab_risco_venc_temp(idx).nrmodalidade
                               ,vr_tab_risco_venc_temp(idx).cdvencto
                               ,vr_tab_risco_venc_temp(idx).nrcontrato
                               ,vr_tab_risco_venc_temp(idx).nrseqctr
                               ,nvl(vr_tab_risco_venc_temp(idx).vldivida,0));
          END IF;
        END LOOP;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar CRAPVRI. ' || SQLERRM;
          RAISE vr_exc_erro;
      END;

      -- Efetuar o arrasto das operações
      risc0003.pc_efetua_arrasto_docto5(pr_cdcooper => pr_cdcooper --> codigo da cooperativa
                              ,pr_dtrefere => pr_dtrefere --> Data de Referencia
                              ,pr_cdcritic => vr_cdcritic 
                              ,pr_dscritic => vr_dscritic);
      -- Em caso de erro
      IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Executar limpeza para sempre a executar o pc_crps660
      -- devido aos lançamentos manuais da tela MOVRGP
      BEGIN
        UPDATE crapris ris
           SET ris.flgindiv = 0
         WHERE ris.cdcooper = pr_cdcooper
           AND ris.dtrefere = pr_dtrefere;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao limpar individualizado de '|| to_char(pr_dtrefere, 'dd/mm/yyyy') || ' da central de risco  > ' || SQLERRM;
          RAISE vr_exc_erro;
      END;

      BEGIN
        DELETE crapris ris
         WHERE ris.cdcooper = pr_cdcooper
           AND ris.inddocto = 2 -- saida
           AND ris.dtrefere = pr_dtrefere;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao remover saídas de '|| to_char(pr_dtrefere, 'dd/mm/yyyy') || ' da central de risco  > ' || SQLERRM;
          RAISE vr_exc_erro;
      END;
      -- Executar limpeza para sempre a executar o pc_crps660
      -- devido aos lançamentos manuais da tela MOVRGP

      -- Vamos efetuar o fechamento da digitação
      BEGIN 
        UPDATE CRAPPRM
           SET dsvlrprm = 0
         WHERE nmsistem = 'CRED'
           AND cdcooper = pr_cdcooper
           AND cdacesso = 'DIGIT_RISCO_FINAN_LIBERA';
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro no Fechamento da Digitacao de Riscos > ' || SQLERRM;
          RAISE vr_exc_erro;
      END;

      COMMIT;

    EXCEPTION
      WHEN vr_exc_erro THEN
        ROLLBACK;
        -- Variavel de erro recebe erro ocorrido
        IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

        ROLLBACK;
        -- Descricao do erro
        pr_dscritic := 'Erro nao tratado na risc0003.pc_fecham_risco_garantia_prest --> ' || SQLERRM;
    END;

  END pc_fecham_risco_garantia_prest;

begin

  UPDATE CRAPPRM
     SET dsvlrprm = 1
   WHERE nmsistem = 'CRED'
     AND cdcooper = 3
     AND cdacesso = 'DIGIT_RISCO_FINAN_LIBERA';
  COMMIT;

  pc_fecham_risco_garantia_prest(pr_cdcooper => 3,
                                                 pr_dtrefere => to_date('31/08/2022', 'dd/mm/yyyy'),
                                                 pr_cdcritic => vr_cdcritic_geral,
                                                 pr_dscritic => vr_dscritic_geral);

  UPDATE CRAPPRM
     SET dsvlrprm = 1
   WHERE nmsistem = 'CRED'
     AND cdcooper = 1
     AND cdacesso = 'DIGIT_RISCO_FINAN_LIBERA';
  COMMIT;

  pc_fecham_risco_garantia_prest(pr_cdcooper => 1,
                                                 pr_dtrefere => to_date('31/08/2022', 'dd/mm/yyyy'),
                                                 pr_cdcritic => vr_cdcritic_geral,
                                                 pr_dscritic => vr_dscritic_geral);

end;
