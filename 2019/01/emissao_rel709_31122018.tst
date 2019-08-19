PL/SQL Developer Test script 3.0
577
 /* .............................................................................
 INC0030086 - REPASSES CONVENIO DPVAT SICREDI
 
 Geração relatório 709
 ..............................................................................*/
 
declare 

  vr_cdcritic  crapcri.cdcritic%TYPE;
  vr_dscritic  crapcri.dscritic%TYPE;
  
   /* Procedure para gerar relatorio dos repasses DPVAT */
  PROCEDURE pc_relat_repasse_dpvat (pr_cdcooper  IN crapcop.cdcooper%TYPE     --> Codigo da cooperativa
                                   ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE     --> Data atual
                                   ,pr_cdprogra  IN crapprg.cdprogra%TYPE     --> Programa chamador
                                   ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo do erro
                                   ,pr_dscritic OUT crapcri.dscritic%TYPE) IS --> Descricao do erro
  BEGIN
    /* .............................................................................

       Programa: pc_relat_repasse_dpvat
       Sistema : Conciliacoes diarias e mensais
       Sigla   : CRED
       Autor   : Jaison
       Data    : Setembro/2015.                    Ultima atualizacao: 

       Dados referentes ao programa:

       Frequencia: 
       Objetivo  : Gerar o relatorio para conciliacao dos repasses DPVAT Sicredi

       Alteracoes: 

    ..............................................................................*/

    DECLARE

      -- Busca as arrecadacoes da cooperativa
      CURSOR cr_arrecad(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_dtiniven IN DATE
                       ,pr_dtfimven IN DATE) IS
        SELECT lft.cdagenci
              ,lft.cdbarras
              ,lft.vllanmto
              ,lft.dtvencto
              ,SUBSTR(TO_CHAR(SYSDATE,'rrrr'),1,2) || SUBSTR(lft.cdbarras,41,2) nranoexe
              ,DECODE(SUBSTR(lft.cdbarras,40,1),1,'I','P') idintegr
          FROM craplft lft
              ,crapscn psc
         WHERE psc.dsoparre <> 'E'
           AND lft.cdcooper  = pr_cdcooper
           AND lft.cdempcon IN(psc.cdempcon,psc.cdempco2)
           AND TO_CHAR(lft.cdsegmto) = psc.cdsegmto   
           AND lft.dtvencto BETWEEN pr_dtiniven AND pr_dtfimven
           AND lft.insitfat  = 2     -- Arrecadada
           AND lft.tpfatura <> 2     -- Todas dif de 2-DARF ARF
           AND lft.cdhistor  = 1154  -- SICREDI
           AND psc.cdempres  = '85'  -- DPVAT
      ORDER BY lft.dtvencto;

      --Tabela de feriados para calcula da data de recolhimento
      CURSOR cr_crapfer(pr_cdcooper IN crapfer.cdcooper%TYPE      --> Código da cooperativa
                       ,pr_dtrecolh IN crapfer.dtferiad%TYPE) IS  --> Data de recolhimento
        SELECT cf.dsferiad
          FROM crapfer cf
         WHERE cf.cdcooper = pr_cdcooper
           AND cf.dtferiad = pr_dtrecolh;

      rw_crapfer cr_crapfer%ROWTYPE;

      -- Tipo de Registro para resumo
      TYPE typ_reg_resumo IS
        RECORD (dt_total DATE
               ,vl_total NUMBER(25,2));

      -- Tipo de tabela de memoria para resumo
      TYPE typ_tab_resumo IS TABLE OF typ_reg_resumo INDEX BY PLS_INTEGER;

      -- Variavel para armazenar a tabela de memoria do resumo
      vr_tab_resumo typ_tab_resumo;

      -- Variaveis Locais
      vr_dtiniiof DATE;
      vr_dtfimiof DATE;
      vr_dtresumo DATE;
      vr_dt_inici DATE;
      vr_dt_final DATE;
      vr_dt_2_dia DATE;
      vr_dt_4_dia DATE;
      vr_txccdiof NUMBER;
      vr_vltarifa NUMBER;
      vr_vltari90 NUMBER;
      vr_vltari91 NUMBER;
      vr_vltaricx NUMBER;
      vr_vltariof NUMBER;
      vr_vlcusbil NUMBER;
      vr_vl_2_dia NUMBER;
      vr_vl_4_dia NUMBER;
      vr_dscusbil VARCHAR2(25);
      vr_nmdireto VARCHAR2(400);
      vr_index    INTEGER;
      vr_contador INTEGER := 0;

      /* Variaveis Prj421 */
      vr_vltotiof NUMBER  := 0;
      vr_dtini    DATE;
      vr_dtfim    DATE;
      vr_dtrecolh DATE;
      vr_contreco NUMBER;
      vr_nrdecend NUMBER;
      
      -- Data do movimento no formato yymmdd
      vr_dtmvtolt_yymmdd     varchar2(6);
      
      -- Nome do diretório
      vr_nom_diretorio       varchar2(200);
      vr_dsdircop            varchar2(200);

      -- Nome do arquivo que será gerado
      vr_nmarqnov            VARCHAR2(50); -- nome do arquivo por cooperativa
      vr_nmarqdat            varchar2(50);

      -- Arquivo texto
      vr_arquivo_txt         utl_file.file_type;
      vr_linhadet            varchar2(200);

      -- Tratamento de erros
      vr_typ_said            VARCHAR2(4);

      -- Variaveis de Erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);

      -- Variaveis de Excecao
      vr_exc_erro EXCEPTION;

      -- Variaveis do Clob
      vr_clobxml CLOB;
      vr_dstexto VARCHAR2(32767);

      -- Calcula os valores da arrecadacao
      PROCEDURE pc_calcula_valores(pr_cdcooper  IN crapcop.cdcooper%TYPE
                                  ,pr_txccdiof  IN NUMBER
                                  ,pr_nranoexe  IN VARCHAR2
                                  ,pr_idintegr  IN VARCHAR2
                                  ,pr_vllanmto  IN craplft.vllanmto%TYPE
                                  ,pr_vltarifa  IN NUMBER
                                  ,pr_vlcusbil OUT NUMBER
                                  ,pr_vltariof OUT NUMBER
                                  ,pr_vl_2_dia OUT NUMBER
                                  ,pr_vl_4_dia OUT NUMBER) IS
      BEGIN

        DECLARE
          vr_dscusbil VARCHAR2(25);

        BEGIN
          -- Parametro de custo de bilhete
          vr_dscusbil := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                  ,pr_cdcooper => pr_cdcooper
                                                  ,pr_cdacesso => 'DPVAT_SICREDI_CSTBIL' || pr_nranoexe);
          -- Custo de bilhete
          IF pr_idintegr = 'I' THEN
            pr_vlcusbil := NVL(TO_NUMBER(SUBSTR(vr_dscusbil,1,6),'FM000D00'),0);
          ELSE
            pr_vlcusbil := NVL(TO_NUMBER(SUBSTR(vr_dscusbil,7,6),'FM000D00'),0);
          END IF;
          
          -- Valor de IOF
          pr_vltariof := ROUND(pr_vllanmto * pr_txccdiof,2);

          -- Repasse 2o dia util
          pr_vl_2_dia := (pr_vllanmto - pr_vlcusbil - pr_vltariof) * 0.5;

          -- Repasse 4o dia util
          pr_vl_4_dia := pr_vllanmto - pr_vltarifa - pr_vltariof - ROUND(pr_vl_2_dia,2);
        END;

      END pc_calcula_valores;

    BEGIN
      
      -- Inicializar variaveis
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;
      
      -- Limpa a PLTABLE
      vr_tab_resumo.DELETE;

      -- Busca informacoes de IOF
      GENE0005.pc_busca_iof (pr_cdcooper  => pr_cdcooper
                            ,pr_dtmvtolt  => pr_dtmvtolt
                            ,pr_dtiniiof  => vr_dtiniiof
                            ,pr_dtfimiof  => vr_dtfimiof
                            ,pr_txccdiof  => vr_txccdiof
                            ,pr_cdcritic  => vr_cdcritic
                            ,pr_dscritic  => vr_dscritic);

      -- Testar se houve erro
      IF vr_dscritic IS NOT NULL THEN
         RAISE vr_exc_erro;
      END IF;

      -- Tarifa Internet
      vr_vltari90 := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => pr_cdcooper
                                              ,pr_cdacesso => 'DPVAT_SICREDI_TRF_INET');
      -- Tarifa TAA
      vr_vltari91 := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => pr_cdcooper
                                              ,pr_cdacesso => 'DPVAT_SICREDI_TRF_TAA');
      -- Tarifa Caixa
      vr_vltaricx := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => pr_cdcooper
                                              ,pr_cdacesso => 'DPVAT_SICREDI_TRF_CAIXA');

      -- Inicializar as informações do XML de dados para o relatório
      dbms_lob.createtemporary(vr_clobxml, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);

      -- Escrever no arquivo XML
      GENE0002.pc_escreve_xml(vr_clobxml,vr_dstexto,
        '<?xml version="1.0" encoding="UTF-8"?><raiz>');

      -- Listagem de arrecadacoes
      FOR rw_arrecad IN cr_arrecad(pr_cdcooper => pr_cdcooper
                                  ,pr_dtiniven => pr_dtmvtolt
                                  ,pr_dtfimven => pr_dtmvtolt) LOOP

        IF rw_arrecad.cdagenci = 90 THEN -- Tarifa Internet
          vr_vltarifa := vr_vltari90;
        ELSIF rw_arrecad.cdagenci = 91 THEN -- Tarifa TAA
          vr_vltarifa := vr_vltari91;
        ELSE -- Tarifa Caixa
          vr_vltarifa := vr_vltaricx;
        END IF;

        -- Processa os calculos
        pc_calcula_valores(pr_cdcooper => pr_cdcooper
                          ,pr_txccdiof => vr_txccdiof
                          ,pr_nranoexe => rw_arrecad.nranoexe
                          ,pr_idintegr => rw_arrecad.idintegr
                          ,pr_vllanmto => rw_arrecad.vllanmto
                          ,pr_vltarifa => vr_vltarifa
                          ,pr_vlcusbil => vr_vlcusbil
                          ,pr_vltariof => vr_vltariof
                          ,pr_vl_2_dia => vr_vl_2_dia
                          ,pr_vl_4_dia => vr_vl_4_dia);

        -- Dados do Repasse
        GENE0002.pc_escreve_xml(vr_clobxml,vr_dstexto,
          '<dados>'||
          '  <cdagenci>'|| LPAD(rw_arrecad.cdagenci,3,0) ||'</cdagenci>'||
          '  <cdbarras>'|| rw_arrecad.cdbarras ||'</cdbarras>'||
          '  <vllanmto>'|| TO_CHAR(rw_arrecad.vllanmto,'FM999999999990D00MI') ||'</vllanmto>'||
          '  <vltarifa>'|| TO_CHAR(vr_vltarifa,'FM9999999990D00') ||'</vltarifa>'||
          '  <vlcusbil>'|| TO_CHAR(vr_vlcusbil,'FM9999999990D00') ||'</vlcusbil>'||
          '  <vltariof>'|| TO_CHAR(vr_vltariof,'FM9999999990D00') ||'</vltariof>'||
          '  <vl_2_dia>'|| TO_CHAR(vr_vl_2_dia,'FM9999999990D00') ||'</vl_2_dia>'||
          '  <vl_4_dia>'|| TO_CHAR(vr_vl_4_dia,'FM9999999990D00') ||'</vl_4_dia>'||
          '</dados>');

        /* Prj421 - Acumular valores de IOF para lancamento contabil */
        vr_vltotiof := vr_vltotiof + vr_vltariof;

      END LOOP; -- cr_arrecad

      -- Monta datas do resumo
      vr_dtresumo := pr_dtmvtolt - 1;
      FOR vr_ind in 1..5 LOOP
        vr_dtresumo := vr_dtresumo + 1;
        vr_dtresumo := GENE0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                  ,pr_dtmvtolt => vr_dtresumo
                                                  ,pr_tipo => 'P'       --> Tipo de busca (P = proximo, A = anterior)
                                                  ,pr_feriado => TRUE     --> Considerar feriados
                                                  ,pr_excultdia => TRUE);
        -- Inicializa a PLTABLE
        vr_tab_resumo(TO_CHAR(vr_dtresumo,'YYYYMMDD')).dt_total := vr_dtresumo;
        vr_tab_resumo(TO_CHAR(vr_dtresumo,'YYYYMMDD')).vl_total := 0;

        -- Se nao foram carregadas datas da pesquisa
        IF vr_dt_inici IS NULL THEN
          vr_dt_inici := vr_dtresumo;
          vr_dt_final := vr_dtresumo;
          FOR vr_ind2 in 1..4 LOOP
            vr_dt_inici := GENE0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                      ,pr_dtmvtolt => vr_dt_inici - 1
                                                      ,pr_tipo     => 'A'
                                                      ,pr_feriado => TRUE     --> Considerar feriados
                                                      ,pr_excultdia => TRUE);
          END LOOP;
        END IF;
      END LOOP;
      
      -- Listagem de arrecadacoes do resumo
      FOR rw_arrecad IN cr_arrecad(pr_cdcooper => pr_cdcooper
                                  ,pr_dtiniven => vr_dt_inici
                                  ,pr_dtfimven => vr_dt_final) LOOP

        IF rw_arrecad.cdagenci = 90 THEN -- Tarifa Internet
          vr_vltarifa := vr_vltari90;
        ELSIF rw_arrecad.cdagenci = 91 THEN -- Tarifa TAA
          vr_vltarifa := vr_vltari91;
        ELSE -- Tarifa Caixa
          vr_vltarifa := vr_vltaricx;
        END IF;

        -- Processa os calculos
        pc_calcula_valores(pr_cdcooper => pr_cdcooper
                          ,pr_txccdiof => vr_txccdiof
                          ,pr_nranoexe => rw_arrecad.nranoexe
                          ,pr_idintegr => rw_arrecad.idintegr
                          ,pr_vllanmto => rw_arrecad.vllanmto
                          ,pr_vltarifa => vr_vltarifa
                          ,pr_vlcusbil => vr_vlcusbil
                          ,pr_vltariof => vr_vltariof
                          ,pr_vl_2_dia => vr_vl_2_dia
                          ,pr_vl_4_dia => vr_vl_4_dia);

        -- Calcula 2o dia util referente a data vencimento
        vr_dt_2_dia := rw_arrecad.dtvencto;
        FOR vr_ind2 in 1..2 LOOP
          vr_dt_2_dia := GENE0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                    ,pr_dtmvtolt => vr_dt_2_dia + 1
                                                    ,pr_tipo => 'P'       --> Tipo de busca (P = proximo, A = anterior)
                                                    ,pr_feriado => TRUE     --> Considerar feriados
                                                    ,pr_excultdia => TRUE);
        END LOOP;  

        -- Calcula 4o dia util referente a data vencimento
        vr_dt_4_dia := vr_dt_2_dia;
        FOR vr_ind2 in 1..2 LOOP
          vr_dt_4_dia := GENE0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                    ,pr_dtmvtolt => vr_dt_4_dia + 1
                                                    ,pr_tipo => 'P'       --> Tipo de busca (P = proximo, A = anterior)
                                                    ,pr_feriado => TRUE     --> Considerar feriados
                                                    ,pr_excultdia => TRUE);
        END LOOP;  

        -- Se existir na PLTABLE soma
        vr_index:= TO_CHAR(vr_dt_2_dia,'YYYYMMDD');
        IF vr_tab_resumo.EXISTS(vr_index) THEN
          -- Somar o valor do vetor com o valor do 2o dia util
          vr_tab_resumo(vr_index).vl_total := vr_tab_resumo(vr_index).vl_total + NVL(vr_vl_2_dia,0);
        END IF;

        -- Se existir na PLTABLE soma
        vr_index:= TO_CHAR(vr_dt_4_dia,'YYYYMMDD');
        IF vr_tab_resumo.EXISTS(vr_index) THEN
          -- Somar o valor do vetor com o valor do 4o dia util
          vr_tab_resumo(vr_index).vl_total := vr_tab_resumo(vr_index).vl_total + NVL(vr_vl_4_dia,0);
        END IF;

      END LOOP; -- cr_arrecad
      
      -- Abre TAG de resumo
      GENE0002.pc_escreve_xml(vr_clobxml,vr_dstexto,'<resumo>');

      vr_index := vr_tab_resumo.FIRST(); -- Posiciona no primeiro registro
      WHILE vr_index IS NOT NULL LOOP
        -- Dados do resumo
        GENE0002.pc_escreve_xml(vr_clobxml,vr_dstexto,
        '  <dt_tot_'|| vr_contador ||'>'|| TO_CHAR(vr_tab_resumo(vr_index).dt_total,'DD/MM/YYYY') ||'</dt_tot_'|| vr_contador ||'>'||
        '  <vl_tot_'|| vr_contador ||'>'|| TO_CHAR(NVL(vr_tab_resumo(vr_index).vl_total,0),'FM999999999990D00') ||'</vl_tot_'|| vr_contador ||'>');
         vr_contador := vr_contador + 1; -- Contador
         vr_index := vr_tab_resumo.NEXT(vr_index); -- Proximo registro
      END LOOP;

      -- Fecha TAG resumo
      GENE0002.pc_escreve_xml(vr_clobxml,vr_dstexto,'</resumo>');

      -- Finaliza TAG Raiz
      GENE0002.pc_escreve_xml(vr_clobxml,vr_dstexto,'</raiz>',TRUE);

      -- Busca o diretorio padrao do sistema
      vr_nmdireto := GENE0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                          ,pr_cdcooper => pr_cdcooper
                                          ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl

      -- Efetuar solicitacao de geracao de relatorio
      GENE0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,
                                  pr_cdprogra  => pr_cdprogra,
                                  pr_dtmvtolt  => pr_dtmvtolt,
                                  pr_dsxml     => vr_clobxml,
                                  pr_dsxmlnode => '/raiz',
                                  pr_dsjasper  => 'crrl709.jasper',
                                  pr_dsparams  => NULL,
                                  pr_dsarqsaid => vr_nmdireto || '/crrl709.lst',
                                  pr_flg_gerar => 'S',
                                  pr_qtcoluna  => 132,
                                  pr_flg_impri => 'S',
                                  pr_nmformul  => '132col',
                                  pr_nrcopias  => 1,
                                  pr_des_erro  => vr_dscritic);

      -- Fechar Clob e Liberar Memoria
      dbms_lob.close(vr_clobxml);
      dbms_lob.freetemporary(vr_clobxml);

      -- Testar se houve erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      CASE WHEN to_number(to_char(pr_dtmvtolt,'DD')) BETWEEN 1 AND 10 THEN
        vr_dtini    := TO_DATE('21' || TO_CHAR(add_months(pr_dtmvtolt,-1), '/MM/RRRR'), 'DD/MM/RRRR');
        vr_dtfim    := LAST_DAY(add_months(pr_dtmvtolt,-1));
        vr_nrdecend := 3;
      WHEN to_number(to_char(pr_dtmvtolt,'DD')) BETWEEN 11 AND 20 THEN
        vr_dtini    := TO_DATE('01' || TO_CHAR(pr_dtmvtolt, '/MM/RRRR'), 'DD/MM/RRRR');
        vr_dtfim    := TO_DATE('10' || TO_CHAR(pr_dtmvtolt, '/MM/RRRR'), 'DD/MM/RRRR');
        vr_nrdecend := 1;
      ELSE
        vr_dtini    := TO_DATE('11' || TO_CHAR(pr_dtmvtolt, '/MM/RRRR'), 'DD/MM/RRRR');
        vr_dtfim    := TO_DATE('20' || TO_CHAR(pr_dtmvtolt, '/MM/RRRR'), 'DD/MM/RRRR');
        vr_nrdecend := 2;
      END CASE;

      vr_dtrecolh := vr_dtfim + 1;
      vr_contreco := 0;

      -- Fazer varredura até encontrar data util
      LOOP
        -- Busca se a data é feriado
        -- Buscar data de processamento
        OPEN cr_crapfer(pr_cdcooper, vr_dtrecolh);
        FETCH cr_crapfer INTO rw_crapfer;
        -- Se a data não for sabado ou domingo ou feriado
        IF NOT(TO_CHAR(vr_dtrecolh, 'd') IN (1,7) OR cr_crapfer%FOUND) THEN
          vr_contreco := vr_contreco + 1;
        END IF;
        --
        close cr_crapfer;
        -- Sair quando encontrar o 3º dia apos
        exit when vr_contreco >= 3;
        -- Incrementar data
        vr_dtrecolh := vr_dtrecolh + 1;
      END LOOP;

      -- Busca próximo dia útil considerando feriados e finais de semana
      vr_dtrecolh := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                ,pr_dtmvtolt => vr_dtrecolh
                                                ,pr_tipo => 'P'       --> Tipo de busca (P = proximo, A = anterior)
                                                ,pr_feriado => TRUE     --> Considerar feriados
                                                ,pr_excultdia => TRUE);
      
      IF nvl(vr_vltotiof,0) > 0 
      OR vr_dtrecolh = pr_dtmvtolt THEN
      
        /* Prj421 - Geracao de arquivo contabil */
        -- Busca do diretório onde ficará o arquivo
        vr_nom_diretorio := gene0001.fn_diretorio(pr_tpdireto => 'C', -- /usr/coop
                                                  pr_cdcooper => pr_cdcooper,
                                                  pr_nmsubdir => 'contab');
                                                  
        -- Busca o diretório final para copiar arquivos
        vr_dsdircop := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                ,pr_cdcooper => 0
                                                ,pr_cdacesso => 'DIR_ARQ_CONTAB_X');                                              
        -- Nome do arquivo a ser gerado
        vr_dtmvtolt_yymmdd := to_char(pr_dtmvtolt, 'yymmdd');
        vr_nmarqdat        := vr_dtmvtolt_yymmdd||'_IOF_DPVAT.txt';

        -- Abre o arquivo para escrita
        gene0001.pc_abre_arquivo(pr_nmdireto => vr_nom_diretorio,    --> Diretório do arquivo
                                 pr_nmarquiv => vr_nmarqdat,         --> Nome do arquivo
                                 pr_tipabert => 'W',                 --> Modo de abertura (R,W,A)
                                 pr_utlfileh => vr_arquivo_txt,      --> Handle do arquivo aberto
                                 pr_des_erro => vr_dscritic);

        if vr_dscritic is not null then
          vr_cdcritic := 0;
          RAISE vr_exc_erro;
        end if;
        
        IF nvl(vr_vltotiof,0) > 0 THEN
          /* Escrita arquivo */
          vr_linhadet := trim(vr_dtmvtolt_yymmdd)||','||
                         trim(to_char(pr_dtmvtolt,'ddmmyy'))||','||
                         '4336,'||
                         '4118,'||
                         trim(to_char(vr_vltotiof, '99999999999990.00'))||','||
                         '5210,'||
                         '"VALOR REF. IOF SOBRE ARRECADACOES DO SEGURO DPVAT"';

          gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
          /* Fim escrita arquivo */
        END IF;
        
      --Se o dia atual é o dia do recolhimento decendial, deve-se realizar lancamento de baixa dos valores
      IF vr_dtrecolh = pr_dtmvtolt THEN
        vr_vltotiof := 0;

        -- Listagem de arrecadacoes do periodo
        FOR rw_arrecad IN cr_arrecad(pr_cdcooper => pr_cdcooper
                                    ,pr_dtiniven => vr_dtini
                                    ,pr_dtfimven => vr_dtfim) LOOP

          IF rw_arrecad.cdagenci = 90 THEN -- Tarifa Internet
            vr_vltarifa := vr_vltari90;
          ELSIF rw_arrecad.cdagenci = 91 THEN -- Tarifa TAA
            vr_vltarifa := vr_vltari91;
          ELSE -- Tarifa Caixa
            vr_vltarifa := vr_vltaricx;
          END IF;

          -- Processa os calculos
          pc_calcula_valores(pr_cdcooper => pr_cdcooper
                            ,pr_txccdiof => vr_txccdiof
                            ,pr_nranoexe => rw_arrecad.nranoexe
                            ,pr_idintegr => rw_arrecad.idintegr
                            ,pr_vllanmto => rw_arrecad.vllanmto
                            ,pr_vltarifa => vr_vltarifa
                            ,pr_vlcusbil => vr_vlcusbil
                            ,pr_vltariof => vr_vltariof
                            ,pr_vl_2_dia => vr_vl_2_dia
                            ,pr_vl_4_dia => vr_vl_4_dia);

          /* Prj421 - Acumular valores de IOF para lancamento contabil */
          vr_vltotiof := vr_vltotiof + vr_vltariof;
        END LOOP; -- cr_arrecad
        
        IF vr_vltotiof > 0 THEN
          vr_linhadet := trim(vr_dtmvtolt_yymmdd)||','||
                         trim(to_char(pr_dtmvtolt,'ddmmyy'))||','||
                         '4118,'||
                         '4336,'||
                         trim(to_char(vr_vltotiof, '99999999999990.00'))||','||
                         '5210,'||
                         '"VALOR REF. IOF S/ARRECADACAO SEGURO DPVAT '||vr_nrdecend||chr(186)||' DECENDIO DE '||trim(to_char(vr_dtini,'MONTH'))||'/'||to_char(vr_dtini,'RRRR')||'"';

          gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        END IF;
      END IF;
      
      gene0001.pc_fecha_arquivo(vr_arquivo_txt);

      vr_nmarqnov := vr_dtmvtolt_yymmdd||'_'||LPAD(TO_CHAR(pr_cdcooper),2,0)||'_IOF_DPVAT.txt';                        

      -- Copia o arquivo gerado para o diretório final convertendo para DOS
      gene0001.pc_oscommand_shell(pr_des_comando => 'ux2dos '||vr_nom_diretorio||'/'||vr_nmarqdat||' > '||vr_dsdircop||'/'||vr_nmarqnov||' 2>/dev/null',
                                  pr_typ_saida   => vr_typ_said,
                                  pr_des_saida   => vr_dscritic);
      -- Testar erro
      if vr_typ_said = 'ERR' then
         vr_cdcritic := 1040;
         gene0001.pc_print(gene0001.fn_busca_critica(vr_cdcritic)||' '||vr_nmarqdat||': '||vr_dscritic);
      end if;
      END IF;

      COMMIT;

    EXCEPTION
       WHEN vr_exc_erro THEN
         pr_cdcritic:= vr_cdcritic;
         pr_dscritic:= vr_dscritic;
       WHEN OTHERS THEN
         pr_cdcritic:= 0;
         pr_dscritic:= 'Erro na rotina CONV0001.pc_relat_repasse_dpvat. ' || SQLERRM;
    END;

  END pc_relat_repasse_dpvat;
  

  
begin
  -- Test statements here
  FOR rec IN (SELECT * FROM crapcop ORDER BY cdcooper ) LOOP
    pc_relat_repasse_dpvat(rec.cdcooper,
                           to_date('31/12/2018','DD/MM/YYYY'),
                           'crps636',
                           vr_cdcritic,
                           vr_dscritic);
                           
  END LOOP;
  
end;
0
0
