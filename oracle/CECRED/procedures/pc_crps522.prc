CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS522 ( pr_cdcooper  IN crapcop.cdcooper%TYPE  --> Cooperativa solicitada
                                        ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                        ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                        ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                        ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                        ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada AS
  BEGIN
    /* ............................................................................

    Programa: pc_crps522 (Antigo fontes/crps522.p)
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Guilherme
    Data    : Novembro/2008                   Ultima atualizacao: 05/01/2015

    Dados referentes ao programa:

    Frequencia: Semestral.
    Objetivo  : Atende a solicitacao 105.
                Geracao da DIMOF para a Receita Federal.

    Alteracoes: 19/10/2009 - Alteracao Codigo Historico (Kbase).

               03/03/2010 - Alteracao Historico (Gati)

               09/08/2010 - Alterada ordem da solicitacao dentro do crapord de
                            261 para 71. Programa paralelo chamado no meio
                            da cadeia exclusiva. (Magui).

               13/08/2010 - Ajustado problema com leitura da TEMP-TABLE tt-hist
                            (Fernando).

               09/06/2011 - Alteracao para atender aos padroes do novo layout
                            (Adriano).

               22/08/2011 - Desprezar lancto da conta 2652404 indevido (Magui).

               10/06/2013 - Alteração função enviar_email_completo para
                            nova versão (Jean Michel).

               26/08/2013 - Conversão Progress >> Oracle PLSQL (Edison-AMcom)

               05/01/2015 -  Ajustado a formatacao de data para RRRR para gravar
                             corretamente na variavel vr_dtiniper.
                             (Andre Santos - SUPERO)

               07/01/2015 - Implementada regra para contas incorporadas não
                            considerarem lcm geradas antes da incorporação
                            (Dionathan)

    ............................................................................. */
    DECLARE
      -- Definindo o tipo de registro ref. aos logradouros
      TYPE typ_des_logradouro IS VARRAY(44) OF VARCHAR2(40);
      vr_vet_logradouro typ_des_logradouro := typ_des_logradouro('AEROPORTO'  --01
                                                                 ,'ALAMEDA'   --02
                                                                 ,'AREA'      --03
                                                                 ,'AVENIDA'   --04
                                                                 ,'CAMPO'     --05
                                                                 ,'CHACARA'   --06
                                                                 ,'COLONIA'   --07
                                                                 ,'CONDOMINIO'--08
                                                                 ,'CONJUNTO'  --09
                                                                 ,'DISTRITO'  --10
                                                                 ,'ESPLANADA' --11
                                                                 ,'ESTACAO'   --12
                                                                 ,'ESTRADA'   --13
                                                                 ,'FAVELA'    --14
                                                                 ,'FAZENDA'   --15
                                                                 ,'FEIRA'     --16
                                                                 ,'JARDIM'    --17
                                                                 ,'LADEIRA'   --18
                                                                 ,'LAGO'      --19
                                                                 ,'LAGOA'     --20
                                                                 ,'LARGO'     --21
                                                                 ,'LOTEAMENTO'--22
                                                                 ,'MORRO'     --23
                                                                 ,'NUCLEO'    --24
                                                                 ,'PARQUE'    --25
                                                                 ,'PASSARELA' --26
                                                                 ,'PATIO'     --27
                                                                 ,'PRACA'     --28
                                                                 ,'QUADRA'    --29
                                                                 ,'RECANTO'   --30
                                                                 ,'RESIDENCIAL'--31
                                                                 ,'RODOVIA'    --32
                                                                 ,'RUA'        --33
                                                                 ,'SETOR'      --34
                                                                 ,'SITIO'      --35
                                                                 ,'TRAVESSA'   --36
                                                                 ,'TRECHO'     --37
                                                                 ,'TREVO'      --38
                                                                 ,'VALE'       --39
                                                                 ,'VEREDA'     --40
                                                                 ,'VIA'        --41
                                                                 ,'VIADUTO'    --42
                                                                 ,'VIELA'      --43
                                                                 ,'VILA'       --44
                                                                 );
      ------------------------------------------------------
      -- Definicao do vetor para armazenar os saldos mensais
      ------------------------------------------------------
      TYPE typ_tab_vlcremes IS VARRAY(12) OF NUMBER(15,2);
      -- Vetor para armazenar os valores de créditos
      vr_tab_vlcremes typ_tab_vlcremes := typ_tab_vlcremes(0,0,0,0,0,0,0,0,0,0,0,0);
      -- Vetor para armazenar os valores de débitos
      vr_tab_vldebmes typ_tab_vlcremes := typ_tab_vlcremes(0,0,0,0,0,0,0,0,0,0,0,0);
      ----------------------------------------------
      -- Definicao do tipo de registro de históricos
      ----------------------------------------------
      TYPE typ_reg_craphis IS
      RECORD ( cdhistor craphis.cdhistor%TYPE
              ,indebcre craphis.indebcre%TYPE);
      -- Definicao do tipo de tabela de históricos
      TYPE typ_tab_craphis IS
        TABLE OF typ_reg_craphis
        INDEX BY PLS_INTEGER;
      -- Definicao do vetor de memoria
      vr_tab_craphis  typ_tab_craphis;
      -----------------------------------------------
      -- Definicao do tipo de registro de lançamentos
      -----------------------------------------------
      TYPE typ_reg_craplcm IS
      RECORD ( nrchave VARCHAR2(20) -- LPAD(craplcm.nrdconta,10,'0')||TO_CHAR(craplcm.dtmvtolt,'MM')
              ,nrdconta craplcm.nrdconta%TYPE
              ,nrmes NUMBER(2)
              ,valor_debito craplcm.vllanmto%TYPE
              ,valor_credito craplcm.vllanmto%TYPE);
      -- Definicao do tipo de tabela de lançamentos
      TYPE typ_tab_craplcm IS
        TABLE OF typ_reg_craplcm
        INDEX BY VARCHAR2(20);
      -- Definicao do vetor de memoria de lançamentos
      vr_tab_craplcm  typ_tab_craplcm;

      --Selecionar informacoes dos associados
      CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE) IS
        SELECT crapass.nrdconta
              ,crapass.vllimcre
              ,crapass.tpextcta
              ,crapass.inpessoa
              ,crapass.nrcpfcgc
              ,ROWID
              ,COUNT(1) OVER (PARTITION BY crapass.inpessoa, crapass.nrcpfcgc) qtdreg
              ,ROW_NUMBER() OVER (PARTITION BY crapass.inpessoa, crapass.nrcpfcgc
                                  ORDER BY crapass.inpessoa, crapass.nrcpfcgc) nrseqreg
          FROM crapass
         WHERE crapass.cdcooper = pr_cdcooper
           AND crapass.inpessoa < 3
        ORDER BY crapass.cdcooper
                ,crapass.inpessoa
                ,crapass.nrcpfcgc;

      -- Selecionar os dados da Cooperativa
      CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT cop.cdcooper
              ,cop.nmrescop
              ,cop.nrtelura
              ,cop.cdbcoctl
              ,cop.cdagectl
              ,cop.dsdircop
              ,cop.nrdocnpj
              ,cop.cdufdcop
              ,cop.nmextcop
              ,cop.nrcpftit
              ,cop.nrtelvoz
              ,cop.nrcpfctr
              ,cop.nmctrcop
              ,cop.dsendcop
              ,cop.nrendcop
              ,cop.dscomple
              ,cop.nmbairro
              ,cop.nrcepend
              ,cop.nmcidade
        FROM crapcop cop
        WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- CRAPMOF : Contém as datas de controle para geração da DIMOF(Declaração
      --           de Informações sobre Movimentação Financeira) exigidas pelo Banco Central
      CURSOR cr_crapmof(pr_cdcooper IN crapmof.cdcooper%TYPE
                       ,pr_dtiniper IN crapmof.dtiniper%TYPE) IS
        SELECT crapmof.dtiniper -- Data de Inicio do Período de Apuração
              ,crapmof.flgenvio -- Indica se as informações já foram enviadas para o BC
              ,crapmof.dtenvarq -- Dia em que a cooperativa enviou as informações
              ,crapmof.dtfimper -- Data do fim do período de apuração
              ,DECODE(TO_CHAR(crapmof.dtfimper,'MM'),'06', 1, 2) nrsemestre -- Indicação do semestre
              ,crapmof.ROWID
        FROM   crapmof
        WHERE  crapmof.cdcooper = pr_cdcooper
        AND    crapmof.dtiniper = pr_dtiniper;
      rw_crapmof cr_crapmof%ROWTYPE;

      -- CRAPSOL : solicitações de processos - D22
      -- CRAPPRG : Cadastro de Programas
      CURSOR cr_crapsol(pr_cdcooper IN crapprg.cdcooper%TYPE
                       ,pr_cdprogra IN crapprg.cdprogra%TYPE) IS
      SELECT crapsol.cdempres -- Código da empresa a ser processada pela solicitação
            ,crapsol.nrdevias -- Número de vias da solicitação
            ,crapsol.dsparame -- Parâmetros necessários para processar a solicitação
            ,crapsol.nrseqsol -- Sequencia de implantação da solicitação
        FROM crapprg
            ,crapsol
       WHERE crapprg.cdcooper = pr_cdcooper
         AND crapprg.cdprogra = pr_cdprogra
         AND crapsol.cdcooper = crapprg.cdcooper
         AND crapsol.nrsolici = crapprg.nrsolici;
      rw_crapsol cr_crapsol%ROWTYPE;

      -- Seleciona os lançamentos em depósitos a vista
      CURSOR cr_craplcm ( pr_cdcooper IN craplcm.cdcooper%TYPE
                         ,pr_dtiniper IN crapmof.dtiniper%TYPE
                         ,pr_dtfimper IN crapmof.dtfimper%TYPE) IS
      SELECT nrdconta
            ,nrmes
            ,nrchave
            ,SUM(valor_debito) valor_debito
            ,SUM(valor_credito) valor_credito
        FROM (SELECT craplcm.nrdconta
                    ,to_char(craplcm.dtmvtolt, 'MM') nrmes
                    ,lpad(craplcm.nrdconta, 10, '0') ||
                     to_char(craplcm.dtmvtolt, 'MM') nrchave
                    ,DECODE(craphis.indebcre, 'D', craplcm.vllanmto, 0) valor_debito
                    ,DECODE(craphis.indebcre, 'C', craplcm.vllanmto, 0) valor_credito
                FROM craplcm
                    ,craphis
                    ,craptco
               WHERE craplcm.cdcooper = pr_cdcooper
                 AND craplcm.cdhistor NOT IN (103, 104, 432, 503)
                 AND craplcm.dtmvtolt BETWEEN pr_dtiniper AND pr_dtfimper
                 AND craphis.cdcooper = craplcm.cdcooper
                 AND craphis.cdhistor = craplcm.cdhistor
                 AND craplcm.cdcooper = craptco.cdcooper(+)
                 AND craplcm.nrdconta = craptco.nrdconta(+)
                 AND craptco.cdcopant(+) IN (4, 15) -- Em novas incorporações, incluir os códigos das cooperativas incorporadas aqui e mais um par de OR dentro do NOT
                 AND NOT ((craplcm.cdcooper IN (4, 15) AND craplcm.dtmvtolt > to_date('28/11/2014','dd/mm/yyyy')) -- Para contas da incorporada ignorar dados após a migração
                       OR (NVL(craptco.cdcopant,99999) IN (4, 15) AND craplcm.dtmvtolt <= to_date('28/11/2014','dd/mm/yyyy'))) --Para contas da incorporadora ignorar dados anteriores à migração
                 )
       GROUP BY nrdconta
               ,nrmes
               ,nrchave;

      -- Seleciona informações dos históricos
      CURSOR cr_craphis ( pr_cdcooper IN craphis.cdcooper%TYPE) IS
        SELECT craphis.cdhistor
              ,craphis.indebcre
        FROM   craphis
        WHERE  craphis.cdcooper = pr_cdcooper
        ORDER BY craphis.cdhistor;

      -- Código do programa
      vr_cdprogra     CONSTANT crapprg.cdprogra%TYPE := 'CRPS522';
      -- Tratamento de erros
      vr_exc_erro     exception;
      vr_exc_fimprg   exception;
      vr_cdcritic     crapcri.cdcritic%TYPE;
      vr_dscritic     VARCHAR2(4000);
      vr_dscomando    VARCHAR2(4000);
      vr_typ_saida    VARCHAR2(100);
      -- Variáveis de controle de arquivos
      vr_linha        VARCHAR2(4000);
      -- Variáveis de trabalho
      rw_crapdat      BTCH0001.cr_crapdat%ROWTYPE;
      vr_vlcredit     NUMBER(15,2);
      vr_vldebito     NUMBER(15,2);
      vr_reproces     NUMBER;
      vr_cpf          crapass.nrcpfcgc%TYPE;
      vr_cdlograd     NUMBER;
      vr_dslograd     VARCHAR2(100);
      vr_dtiniper     DATE;
      vr_chavelcm     VARCHAR2(20);
      -- Variável de controle de envio de e-mail
      vr_conteudo     VARCHAR2(4000);
      vr_dsemlctr     craptab.dstextab%TYPE;
      -- Variável para armazenar as informações em XML
      vr_des_xml      CLOB;
      vr_nom_direto   VARCHAR2(100);
      vr_nom_dirmic   VARCHAR2(100);
      vr_nom_arquivo  VARCHAR2(100);

      --Escrever no arquivo CLOB
      PROCEDURE pc_escreve_clob(pr_des_dados IN VARCHAR2) IS
      BEGIN
        --Escrever no arquivo CLOB
        dbms_lob.writeappend(vr_des_xml,length(pr_des_dados||chr(13)),pr_des_dados||chr(13));
      END;

      --Procedure para limpar os dados das tabelas de memoria
      PROCEDURE pc_limpa_tabela IS
      BEGIN
        -- Limpando a tabela de memória dos históricos
        vr_tab_craphis.DELETE;
        -- Limpando a tabela de memória dos históricos
        vr_tab_craplcm.DELETE;
      EXCEPTION
        WHEN OTHERS THEN
          --Variavel de erro recebe erro ocorrido
          vr_dscritic := 'Erro ao limpar tabelas de memória. Rotina pc_crps153.pc_limpa_tabela. '||sqlerrm;
          --Sair do programa
          RAISE vr_exc_erro;
      END;
    BEGIN
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => null);

      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic:= 651;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;
      -- Verificação do calendário
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      -- Se nao encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois havera raise
        CLOSE BTCH0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic:= 1;
        vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;

      -- Validações iniciais do programa
      BTCH0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper
                                ,pr_flgbatch => 1
                                ,pr_cdprogra => vr_cdprogra
                                ,pr_infimsol => pr_infimsol
                                ,pr_cdcritic => vr_cdcritic);

      --Se retornou critica aborta programa
      IF vr_cdcritic <> 0 THEN
        --Descricao do erro recebe mensagam da critica
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        --Envio do log de erro
        RAISE vr_exc_erro;
      END IF;

      -- Buscando a data de Inicio do Período de Apuração
      OPEN cr_crapsol(pr_cdcooper => pr_cdcooper
                     ,pr_cdprogra => vr_cdprogra);
      FETCH cr_crapsol INTO rw_crapsol;
      --Fecha o cursor cr_crapsol
      CLOSE cr_crapsol;

      -- Convertendo o parâmetro de string para data
      BEGIN
        vr_dtiniper := to_date(rw_crapsol.dsparame,'DD/MM/RRRR');
      EXCEPTION
        WHEN OTHERS THEN
          vr_dtiniper := NULL;
          --Descricao do erro recebe mensagam da critica
          vr_dscritic := 'O parâmetro "Data de inicio da apuração" necessário para '
                         ||' processar a solicitação está incorreto.';
          --Envio do log de erro
          RAISE vr_exc_erro;
      END;

      -- Verifica as datas de controle para geração da DIMOF
      OPEN cr_crapmof( pr_cdcooper => pr_cdcooper
                      ,pr_dtiniper => vr_dtiniper);
      FETCH cr_crapmof INTO rw_crapmof;

      -- Verificando se existe registro da DIMOF gerado
      IF cr_crapmof%NOTFOUND THEN
        -- Fecha o cursor cr_crapmof
        CLOSE cr_crapmof;
        -- Descricao do erro recebe mensagam da critica
        vr_dscritic := 'Registro de DIMOF nao encontrado para o período inicial informado: '||to_char(vr_dtiniper,'DD/MM/YYYY');
        -- Envio do log de erro
        RAISE vr_exc_erro;
      ELSE
        -- Fecha o cursor cr_crapmof
        CLOSE cr_crapmof;
      END IF;

      -- Se o arquivo já foi gerado e enviado, informa que é reprocesso
      IF rw_crapmof.flgenvio = 0 AND rw_crapmof.dtenvarq IS NOT NULL THEN
        -- Indica que o arquivo está sendo reprocessado
        vr_reproces := 1;
      ELSE
        -- Indica que o arquivo ainda não foi processadoM
        vr_reproces := 0;
      END IF;

      -- Inicializar o CLOB
      dbms_lob.createtemporary(vr_des_xml, TRUE);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

      -------------------------------------------------------------------------
      -- INICIANDO A GERAÇÃO DO ARFQUIVO
      -------------------------------------------------------------------------
      -- Gerando registro 01
      vr_linha := '01'
                  || GENE0002.fn_mask(rw_crapcop.nrdocnpj,'99999999999999')
                  || rw_crapmof.nrsemestre
                  || TO_CHAR(rw_crapmof.dtiniper,'YYYY')
                  || TO_CHAR(rw_crapmof.dtiniper,'YYYY')
                  || TO_CHAR(rw_crapmof.dtiniper,'MM')
                  || TO_CHAR(rw_crapmof.dtiniper,'DD')
                  || TO_CHAR(rw_crapmof.dtfimper,'YYYY')
                  || TO_CHAR(rw_crapmof.dtfimper,'MM')
                  || TO_CHAR(rw_crapmof.dtfimper,'DD')
                  || vr_reproces
                  || '00'
                  || '00000000'
                  || rpad(rw_crapcop.cdufdcop,2,' ')
                  || rpad(rw_crapcop.nmextcop,60,' ')
                  || 'DIMOF'
                  || rpad(' ',237);
      -- Escrevendo no CLOB
      pc_escreve_clob(vr_linha);

      -- Gerando registro 02
      vr_linha := '02'
                  || GENE0002.fn_mask(rw_crapcop.nrcpftit,'99999999999')
                  || GENE0002.fn_mask(SUBSTR(rw_crapcop.nrtelvoz,2,2),'99')
                  || GENE0002.fn_mask(REPLACE(SUBSTR(rw_crapcop.nrtelvoz,5,9),'-',''),'99999999')
                  || '00000'
                  || rpad(' ',234,' ');
      -- Escrevendo no CLOB
      pc_escreve_clob(vr_linha);

      -- Gerando registro 03
      vr_linha := '03'
                  || GENE0002.fn_mask(rw_crapcop.nrcpfctr,'99999999999')
                  || GENE0002.fn_mask(SUBSTR(rw_crapcop.nrtelvoz,2,2),'99')
                  || GENE0002.fn_mask(REPLACE(SUBSTR(rw_crapcop.nrtelvoz,5,9),'-',''),'99999999')
                  || '00000'
                  || rpad(' ',324,' ');
      -- Escrevendo no CLOB
      pc_escreve_clob(vr_linha);

      -- Gerando registro 04
      vr_linha := '04'
                  || GENE0002.fn_mask(rw_crapcop.nrcpfctr,'99999999999')
                  || RPAD(rw_crapcop.nmctrcop,80,' ')
                  || GENE0002.fn_mask(SUBSTR(rw_crapcop.nrtelvoz,2,2),'9999')
                  || GENE0002.fn_mask(REPLACE(SUBSTR(rw_crapcop.nrtelvoz,5,9),'-',''),'999999999')
                  || '00000'
                  || RPAD('Contabilidade',100,' ')
                  || RPAD(' ',141,' ');
      -- Escrevendo no CLOB
      pc_escreve_clob(vr_linha);

      -- Seleciona o código do logradouro
      vr_cdlograd := 99; -- Outro logradouro
      -- Busca a primeira informação do endereço. Ex. Rua, Avenida, etc..
      vr_dslograd := GENE0002.fn_busca_entrada(pr_postext => 1
                                                  ,pr_dstext => rw_crapcop.dsendcop
                                                  ,pr_delimitador => ' ');
      -- Verifica o código do logradouro conforme descrição
      FOR vr_ind IN 1 .. 44 LOOP
        IF vr_vet_logradouro(vr_ind) = TRIM(UPPER(vr_dslograd)) THEN
          vr_cdlograd := vr_ind;
          EXIT;
        END IF;
      END LOOP;

      -- Gerando registro 05 do arquivo
      vr_linha := '05'
                  || lpad(vr_cdlograd,2,'0')
                  || rpad(rw_crapcop.dsendcop,80,' ')
                  || rpad(rw_crapcop.nrendcop,6,' ')
                  || rpad(rw_crapcop.dscomple,50,' ')
                  || rpad(rw_crapcop.nmbairro,50,' ')
                  || GENE0002.fn_mask(GENE0002.fn_char_para_number(rw_crapcop.nrcepend), '99999999')
                  || rpad(rw_crapcop.nmcidade,30,' ')
                  || rpad(rw_crapcop.cdufdcop,2,' ')
                  || rpad(' ',122,' ');
      -- Escrevendo no CLOB
      pc_escreve_clob(vr_linha);

      -- Limpando as tabelas de memória
      pc_limpa_tabela;

      -- Carregando a tabela de históricos
      FOR rw_craphis  IN cr_craphis (pr_cdcooper => pr_cdcooper)  LOOP
        vr_tab_craphis(rw_craphis.cdhistor).cdhistor := rw_craphis.cdhistor;
        vr_tab_craphis(rw_craphis.cdhistor).indebcre := rw_craphis.indebcre;
      END LOOP;

      -- Carregando a tabela de lançamentos
      FOR rw_craplcm  IN cr_craplcm (pr_cdcooper => pr_cdcooper
                                    ,pr_dtiniper => rw_crapmof.dtiniper
                                    ,pr_dtfimper => rw_crapmof.dtfimper)
      LOOP
        vr_tab_craplcm(rw_craplcm.nrchave).nrchave := rw_craplcm.nrchave;
        vr_tab_craplcm(rw_craplcm.nrchave).nrdconta := rw_craplcm.nrdconta;
        vr_tab_craplcm(rw_craplcm.nrchave).nrmes := rw_craplcm.nrmes;
        vr_tab_craplcm(rw_craplcm.nrchave).valor_debito := rw_craplcm.valor_debito;
        vr_tab_craplcm(rw_craplcm.nrchave).valor_credito := rw_craplcm.valor_credito;
      END LOOP;

      -- Selecionando todos os associados que são 1-Pessoa Física e 2-Pessoa jurídica
      FOR rw_crapass IN cr_crapass (pr_cdcooper => pr_cdcooper)
      LOOP
        -- Se é o primeiro registro da quebra (FIRST-OF), inicializa as variáveis de totais
        IF rw_crapass.nrseqreg = 1 THEN
          vr_vlcredit := 0;
          vr_vldebito := 0;
          -- Inicializando o vetor do saldos mensais de crédito e débito
          FOR vr_ind IN TO_NUMBER(TO_CHAR(rw_crapmof.dtiniper,'MM')) .. TO_NUMBER(TO_CHAR(rw_crapmof.dtfimper,'MM'))
          LOOP
            vr_tab_vlcremes(vr_ind) := 0;
            vr_tab_vldebmes(vr_ind) := 0;
          END LOOP;
        END IF;
        -- Gerando as informações
        FOR vr_ind IN TO_NUMBER(TO_CHAR(rw_crapmof.dtiniper,'MM')) .. TO_NUMBER(TO_CHAR(rw_crapmof.dtfimper,'MM'))
        LOOP
          -- Gerando a chave de acesso da pltable
          vr_chavelcm := LPAD(rw_crapass.nrdconta,10,'0')||LPAD(vr_ind,2,'0');
          -- Verifica se o registro existe para a conta e mês informados
          IF vr_tab_craplcm.EXISTS(vr_chavelcm) THEN
            -- Acumulando o valor total de créditos
            vr_vlcredit := NVL(vr_vlcredit,0) + NVL(vr_tab_craplcm(vr_chavelcm).valor_credito,0);

            -- Acumulando o valor total de créditos do mês
            vr_tab_vlcremes(vr_ind) := NVL(vr_tab_vlcremes(vr_ind),0) +
                                       NVL(vr_tab_craplcm(vr_chavelcm).valor_credito,0);
            -- Acumulando o valor total de débitos
            vr_vldebito := NVL(vr_vldebito,0) + NVL(vr_tab_craplcm(vr_chavelcm).valor_debito,0);

            -- Acumulando o valor total de débitos do mês
            vr_tab_vldebmes(vr_ind) := NVL(vr_tab_vldebmes(vr_ind),0) +
                                       NVL(vr_tab_craplcm(vr_chavelcm).valor_debito,0);
          END IF;
        END LOOP;

        -- Se é o último registro da quebra (LAST-OF), escreve os totais no arquivo
        IF rw_crapass.qtdreg = rw_crapass.nrseqreg  THEN
          -- Se o associado é do tipo pessoa física
          IF rw_crapass.inpessoa = 1 THEN
            -- se a movimentação a crédito ou a débito for superior a 5.000,00
            -- Gera registro 06 no arquivo
            IF vr_vlcredit >= 5000  OR vr_vldebito >= 5000  THEN
              -- Alimentando a variável de controle
              vr_cpf := rw_crapass.nrcpfcgc;
              -- Inicializando a variável vr_linha pois abaixo ela é concatenada
              vr_linha := '';
              -- Percorre o vetor dos saldos mensais para concatenar mês a mês na linha do arquivo
              FOR vr_ind IN TO_CHAR(rw_crapmof.dtiniper,'MM') .. TO_CHAR(rw_crapmof.dtfimper,'MM')
              LOOP
                -- Concatenando os saldos mensais na linha do arquivo
                vr_linha := vr_linha
                            || GENE0002.fn_mask(NVL(vr_tab_vlcremes(vr_ind),0)*100,'99999999999999999')
                            || GENE0002.fn_mask(NVL(vr_tab_vldebmes(vr_ind),0)*100,'99999999999999999');
              END LOOP;
              -- Gerando a linha que será gravada no arquivo
              vr_linha := '06'
                          || GENE0002.fn_mask(vr_cpf,'99999999999')
                          || vr_linha
                          || RPAD(' ',135,' ');
              -- Escrevendo no CLOB
              pc_escreve_clob(vr_linha);
            END IF;
          ELSE
            -- se a movimentação a crédito ou a débito for superior a 5.000,00
            -- Gera registro 06 no arquivo
            IF vr_vlcredit >= 10000  OR vr_vldebito >= 10000  THEN
              -- Alimentando a variável de controle
              vr_cpf := rw_crapass.nrcpfcgc;
              -- Inicializando a variável vr_linha pois abaixo ela é concatenada
              vr_linha := '';
              -- Percorre o vetor dos saldos mensais para concatenar mês a mês na linha do arquivo
              FOR vr_ind IN TO_CHAR(rw_crapmof.dtiniper,'MM') .. TO_CHAR(rw_crapmof.dtfimper,'MM')
              LOOP
                -- Concatenando os saldos mensais na linha do arquivo
                vr_linha := vr_linha
                            || GENE0002.fn_mask(NVL(vr_tab_vlcremes(vr_ind),0)*100,'99999999999999999')
                            || GENE0002.fn_mask(NVL(vr_tab_vldebmes(vr_ind),0)*100,'99999999999999999');
              END LOOP;
              -- Gerando a linha que será gravada no arquivo
              vr_linha := '07'
                          || GENE0002.fn_mask(vr_cpf,'99999999999999')
                          || vr_linha
                          || RPAD(' ',132,' ');
              -- Escrevendo no CLOB
              pc_escreve_clob(vr_linha);
            END IF;
          END IF;
        END IF;
      END LOOP;

      -- Gerando a linha final do arquivo
      vr_linha := 'T9'
                  || RPAD('9',350,'9');

      -- Escrevendo no CLOB diretamente para não passar o chr(13) na última linha do arquivo
      dbms_lob.writeappend(vr_des_xml,length(vr_linha),vr_linha);

      -- Busca do diretório arq da cooperativa
      vr_nom_direto := gene0001.fn_diretorio( pr_tpdireto => 'C' -- /usr/coop
                                             ,pr_cdcooper => pr_cdcooper
                                             ,pr_nmsubdir => '/arq'); --> Gerado no diretorio /arq/
      -- Busca do diretório micros contab
      vr_nom_dirmic := gene0001.fn_diretorio( pr_tpdireto => 'M' -- /micros
                                             ,pr_cdcooper => pr_cdcooper
                                             ,pr_nmsubdir => '/contab'); --> Gerado no diretorio /contab/

      --Determinar o nome do arquivo que será gerado
      vr_nom_arquivo := 'dimof'||TO_CHAR(rw_crapmof.dtiniper,'YYYY')||GENE0002.fn_mask(rw_crapmof.nrsemestre,'99')||'.txt';

      -- Escreve o clob no arquivo físico
      gene0002.pc_clob_para_arquivo(pr_clob     => vr_des_xml
                                   ,pr_caminho  => vr_nom_direto
                                   ,pr_arquivo  => vr_nom_arquivo
                                   ,pr_des_erro => vr_dscritic);
      -- Teste de erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Atualizando o status da DIMOF para 1-Enviado
      BEGIN
        UPDATE crapmof SET crapmof.flgenvio = 1
                          ,crapmof.dtenvarq = rw_crapdat.dtmvtopr
        WHERE  crapmof.ROWID = rw_crapmof.ROWID;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar o flag de envio da DIMOF ref. ao período '
                         || to_char(rw_crapmof.dtiniper,'DD/MM/YYYY')||' na tabela crapmof. '||SQLERRM;
          --Sair do programa
          RAISE vr_exc_erro;
      END;

      -- Converter o arquivo gerado para DOS
      -- Ao final, converter o arquivo para DOS e enviá-lo a pasta micros/<dsdircop>/contab
      vr_dscomando := 'ux2dos < '||vr_nom_direto||'/'||vr_nom_arquivo||' | tr -d "\032" > '
                                 ||vr_nom_dirmic||'/'||vr_nom_arquivo||' 2>/dev/null';
      --Executar o comando no unix
      GENE0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => vr_dscomando
                           ,pr_typ_saida   => vr_typ_saida
                           ,pr_des_saida   => vr_dscritic);
      --Se ocorreu erro dar RAISE
      IF vr_typ_saida = 'ERR' THEN
        vr_dscritic:= 'Nao foi possivel executar comando unix de conversão: '||vr_dscomando||'. Erro: '||vr_dscritic;
        RAISE vr_exc_erro;
      END IF;

      -- Remover o arquivo original
      vr_dscomando := 'rm '||vr_nom_direto||'/'||vr_nom_arquivo||' 2>/dev/null';
      --Executar o comando no unix
      GENE0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => vr_dscomando
                           ,pr_typ_saida   => vr_typ_saida
                           ,pr_des_saida   => vr_dscritic);
      --Se ocorreu erro dar RAISE
      IF vr_typ_saida = 'ERR' THEN
        vr_dscritic:= 'Nao foi possivel executar comando unix de remoção: '||vr_dscomando||'. Erro: '||vr_dscritic;
        RAISE vr_exc_erro;
      END IF;

      -- Gerando o conteúdo do e-mail
      vr_conteudo := 'Informamos que o arquivo de Declaracao de Informacoes Sobre a'
                    || ' Movimentacao Financeira - DIMOF ( ' || vr_nom_arquivo
                    || ' ) esta localizado no diretorio ' || vr_nom_direto
                    || ' para ser enviado ao BACEN.<br><br>'
                    || 'Cooperativa Central de Credito Urbano<br>'
                    || 'CECRED';

      -- Busca o e-mail do departamento de contabilidade da cooperativa
      vr_dsemlctr := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                    ,pr_nmsistem => 'CRED'
                                                    ,pr_tptabela => 'USUARI'
                                                    ,pr_cdempres => 0
                                                    ,pr_cdacesso => 'EMLCTBCOOP'
                                                    ,pr_tpregist => 0);

      --Enviar Email de para o departamento de contabilidade comunicando sobre a geração do arquivo
      gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                ,pr_cdprogra        => vr_cdprogra
                                ,pr_des_destino     => vr_dsemlctr
                                ,pr_des_assunto     => 'Enviar arquivo DIMOF ao BACEN'
                                ,pr_des_corpo       => vr_conteudo
                                ,pr_des_anexo       => null--> não envia anexo, anexo esta disponivel no dir conf. geração do arq.
                                ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                ,pr_flg_remete_coop => 'N' --> Se o envio será do e-mail da Cooperativa
                                ,pr_flg_enviar      => 'S' --> Enviar o e-mail na hora
                                ,pr_des_erro        => vr_dscritic);

      --Se ocorreu algum erro no envio do e-mail
      IF vr_dscritic IS NOT NULL  THEN
        -- Descrição do erro
        vr_dscritic := 'Problemas no envio do e-mail: '||vr_dscritic;

        --Sair do programa
        RAISE vr_exc_erro;
      END IF;

      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);

      -- Limpando as tabelas de memória
      pc_limpa_tabela;

      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);
      -- Commitando a transação
      COMMIT;

    EXCEPTION
      WHEN vr_exc_fimprg THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Se foi gerada critica para envio ao log
        IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '
                                                     || vr_dscritic );
        END IF;
        -- Limpando as tabelas de memória
        pc_limpa_tabela;

        -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
        btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_stprogra => pr_stprogra);
        -- Efetuar commit pois gravaremos o que foi processo até então
        COMMIT;
      WHEN vr_exc_erro THEN
        -- Efetuar rollback
        ROLLBACK;
        -- Se não foi passado o código da critica
        pr_cdcritic := nvl(vr_cdcritic, 0);
        pr_dscritic := vr_dscritic;
        -- Limpando as tabelas de memória
        pc_limpa_tabela;
      WHEN OTHERS THEN
        -- Efetuar rollback
        ROLLBACK;
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
       -- Limpando as tabelas de memória
       pc_limpa_tabela;
    END;
  END PC_CRPS522;
/

