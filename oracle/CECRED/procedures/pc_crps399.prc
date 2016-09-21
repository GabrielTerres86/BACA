CREATE OR REPLACE PROCEDURE CECRED."PC_CRPS399" ( pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                          ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                          ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                          ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                          ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                          ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* ............................................................................

       Programa: pc_crps399 (Fontes/crps399.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autora  : Mirtes
       Data    : Julho/2004                        Ultima atualizacao: 22/11/2013

       Dados referentes ao programa:

       Frequencia: Diario (Batch - Background).
       Objetivo  : Listar as cartas de aviso Emprestimo/Cl em Atraso.
                   Solicitacao : 82
                   Exclusividade 1 - Cadeia 3
                   Relatorio 359  - Formulario LASER.

       Alteracoes: 23/09/2004 - Utilizar numero de conta dos avalistas do
                                crapepr(Contratos Antigos crawepr<>crapepr)(Mirtes).

                   24/09/2004 - Nao efetuar impressao de 2 vias para a primeira
                                carta do devedor e primeira carta do aval.

                   27/09/2004 - Alterada data de emissao(glb_dtmvtopr)(Mirtes)

                   28/09/2004 - Relacionar sequencia das cartas/relatorio(Mirtes)

                   23/09/2005 - Modificado FIND FIRST para FIND na tabela
                                crapcop.cdcooper = glb_cdcooper (Diego).

                   20/01/2006 - Tratamento de erro no campo nrctaav1/2 (Ze).

                   06/02/2006 - Alterado layout relatorio 359(str_1) (Diego).

                   13/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre

                   19/06/2006 - Modificados campos referente endereco da estrutura
                                crapass para crapenc (Diego).

                   21/03/2007 - Alterado formato dos campos de endereco baseados na
                                estrutura crapass para crapenc (Elton).

                   28/08/2007 - Alterado de FormXpress para FormPrint (Diego).

                   10/09/2007 - Gerar arquivo de script(FormPrint) para cada tipo
                                de carta (Diego).

                   31/10/2007 - Efetuado acerto 2 carta avalista (Diego).

                   07/02/2008 - Chamar nova include "gera_dados_inform_2_postmix.i"
                                e incluido campo cratext.complend (Diego).

                   05/05/2008 - Chamar nova includes "envia_dados_postmix.i",
                                criada variavel para usar na includes e outra
                                para contablizar os documentos (Gabriel).

                   03/06/2008 - Incluidos 2 campos novos no arquivo de dados AR
                                (Diego).

                   05/08/2008 - Alterado para mostrar tambem o "numero" do endereco
                                de devolucao do AR (Diego).

                   14/08/2008 - Alterado para evitar erro de upload (Gabriel).

                   15/08/2008 - Incluido argumento AGUARDA na includes de envio
                                (Evandro/Gabriel).

                   04/02/2009 - Acerto no tamanho do endereco => aux_dsendres
                                (Diego).

                   06/02/2009 - Movida definicao da variavel aux_nmdatspt para
                                includes/var_informativos.i (Diego).

                   08/07/2009 - Enviar e-mail para Engecopy com arquivos para
                                impressao nas cooperativas 1,2 e 4 (Diego).

                   28/08/2009 - Utilizar glb_dtmvtopr na carta AR (Diego).

                   27/05/2010 - Gravar o nome da faixa do CEP (nomedcdd) na cratext.
                                Unificacao da includes de geracao dos dados
                               (Gabriel).

                   01/06/2010 - Alteração do campo "pkzip25" para "zipcecred.pl"
                                (Vitor).

                   23/08/2010 - Alteracao para nao gerar AR quando a cooperativa
                                estiver com parametro "NAO" na tab032 (Irlan).

                   11/08/2011 - Inclusao da faixa de CEP e da Centralizadora dos
                                correios no separador dos informativos (Elton).

                   23/09/2011 - Criacao de regitros de crapinf por meio da include
                                gera_dados_crapinf.i para cartas AR. (GATI - Eder)

                   23/09/2011 - Alimentar campo cratext.cdagenci (Diego).

                   28/09/2011 - Contabilizar cartas separadoras do arquivo AR para
                                tabela gndcimp (Diego).

                   26/12/2011 - Alterado para gerar somente 1 via dos informativos
                                para as cooperativas que nao geram AR e 2 vias
                                para 2o. devedor e 2o.avalista das cooperativas
                                que geram AR (Elton).

                   20/03/2013 - Incluido numero de endereço do aval para enviar
                                cartas ao avalista (Kruger).

                   10/06/2013 - Alteração função enviar_email_completo para
                                nova versão (Jean Michel).

                   21/06/2013 - Conversão Progress >> PLSQL (Marcos-Supero)

                   22/11/2013 - Correção na chamada a vr_exc_fimprg, a mesma só deve
                                ser acionada em caso de saída para continuação da cadeia,
                                e não em caso de problemas na execução (Marcos-Supero)

    ............................................................................ */

    DECLARE

      ------------------------------- CURSORES ---------------------------------

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.dsendcop
              ,cop.nmbairro
              ,cop.nrendcop
              ,cop.nmcidade
              ,cop.cdufdcop
              ,cop.nmextcop
              ,cop.nrcepend
              ,cop.nmrescop
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- Buscar o cadastro dos associados da Cooperativa
      CURSOR cr_crapass IS
        SELECT nrdconta
              ,cdagenci
              ,nmprimtl
              ,inpessoa
          FROM crapass
         WHERE cdcooper = pr_cdcooper;

      -- Busca dos endereços dos cooperados
      CURSOR cr_crapenc IS
        SELECT nrdconta
              ,nrcepend
              ,nrendere
              ,dsendere
              ,nmbairro
              ,nmcidade
              ,cdufende
              ,complend
          FROM crapenc
         WHERE cdcooper = pr_cdcooper
           AND idseqttl = 1  --> Somente do titular
           AND cdseqinc = 1;

      -- Listagem das cartas de empréstimo com atraso
      CURSOR cr_crapcdv IS
        SELECT nrdconta
              ,cdorigem
              ,nrctremp
              ,dtslavl2
              ,dtemavl2
              ,dtsldev2
              ,dtemdev2
              ,dtsldev1
              ,dtemdev1
              ,qtdiatra
              ,vlsdeved
              ,rowid
          FROM crapcdv
         WHERE cdcooper = pr_cdcooper
           AND dtliquid IS NULL -- Ainda não liquidado
           AND flgenvio <> 0    -- 0 - False ou seja, não enviar
         ORDER BY dtmvtolt
                 ,nrdconta
                 ,cdorigem
                 ,nrctremp;

      -- Buscar do cadastro e complemento dos emprétimos
      CURSOR cr_crapepr(pr_nrdconta IN crapepr.nrdconta%TYPE
                       ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
        SELECT epr.nrctaav1
              ,epr.nrctaav2
              ,wpr.nrctaav1 nrctaav1_compl
              ,wpr.nmdaval1 nmdaval1_compl
              ,wpr.nrctaav2 nrctaav2_compl
              ,wpr.nmdaval2 nmdaval2_compl
          FROM crawepr wpr
              ,crapepr epr
         WHERE epr.cdcooper = wpr.cdcooper
           AND epr.nrdconta = wpr.nrdconta
           AND epr.nrctremp = wpr.nrctremp
           AND epr.cdcooper = pr_cdcooper
           AND epr.nrdconta = pr_nrdconta
           AND epr.nrctremp = pr_nrctremp;
      rw_crapepr cr_crapepr%ROWTYPE;

      -- Busca do cadastro de centros de distribuição por CEP
      CURSOR cr_crapcdd(pr_nrcepend IN crapcdd.nrcepini%TYPE) IS
        SELECT nrcepini
              ,nrcepfim
              ,nomedcdd
              ,dscentra
              ,'S' flgachou
          FROM crapcdd
         WHERE nrcepini <= pr_nrcepend
           AND nrcepfim >= pr_nrcepend;
      rw_crapcdd cr_crapcdd%ROWTYPE;

      -- Busca dos avalistas terceiros
      CURSOR cr_crapavt(pr_nrdconta IN crapavt.nrdconta%TYPE
                       ,pr_nrctremp IN crapavt.nrctremp%TYPE) IS
        SELECT nrendere
              ,dsendres##1
              ,dsendres##2
              ,nrcepend
              ,complend
              ,nmcidade
              ,cdufresd
              ,nmdavali
          FROM crapavt
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctremp = pr_nrctremp
           AND tpctrato = 1; --> Empréstimo

      ------------------------ ESTRUTURAS E TIPOS --------------------------

      /* Tipo que compreende o registro para gerar o relatório rl/crrl359.lst */
      TYPE typ_reg_rel359 IS
          RECORD (tpdcarta PLS_INTEGER
                 ,nrdconta crapass.nrdconta%TYPE
                 ,nrctremp crapepr.nrctremp%TYPE
                 ,qtdiatra crapcdv.qtdiatra%TYPE
                 ,vlsdeved crapcdv.vlsdeved%TYPE
                 ,nomedes1 VARCHAR2(60)
                 ,tpctrato crapcdv.cdorigem%TYPE
                 ,cdagenci crapage.cdagenci%TYPE
                 ,nrsequen PLS_INTEGER);
      /* Definição de tabela que compreende os registros acima declarados */
      TYPE typ_tab_rel359 IS
        TABLE OF typ_reg_rel359
        INDEX BY VARCHAR2(20); -- Ordenação Tipo de Carta (1) + Agencia (3) + Conta (10) + Sequencia (6)
      vr_tab_rel359 typ_tab_rel359; --> Vetor para armazenar registros
      vr_chv_rel359 VARCHAR2(20);   --> Var para montagem da chave

      -- Instancias para cada tipo de carga
      vr_tab_cratext_1 form0001.typ_tab_cratext; --> 1ª carta aos devedores
      vr_tab_cratext_2 form0001.typ_tab_cratext; --> 2ª carta aos devedores
      vr_tab_cratext_3 form0001.typ_tab_cratext; --> 1ª carta aos avalistas
      vr_tab_cratext_4 form0001.typ_tab_cratext; --> 2ª carta aos avalistas
      --> Var para montagem da chave para as vr_tab_cratext_<tipo_de_carta>
      --    Nome Cidade(35) + FaixaCep(23) + Cep(8) + Endereco(60) + Conta(8) + Sequencia (6)
      vr_chv_cratext VARCHAR2(140);

      /* Tipo que compreende o registro genérico de A.Rs */
      TYPE typ_reg_cartaAR IS
          RECORD (nrcepend PLS_INTEGER
                 ,nomedcdd VARCHAR2(35)
                 ,nrcepcdd VARCHAR2(23)
                 ,dscentra VARCHAR2(35)
                 ,dsdlinha form0001.tab_dsintern --> Linhas internas do formulário
                 ,nrdconta crapass.nrdconta%TYPE
                 ,indespac PLS_INTEGER     /* 1-Correio / 2-Secao */
                 ,cdagenci crapage.cdagenci%TYPE);
      /* Definição de tabela que compreende os registros acima declarados */
      TYPE typ_tab_cartaAR IS
        TABLE OF typ_reg_cartaAR
        INDEX BY VARCHAR2(140);
      vr_tab_cartaAR typ_tab_cartaAR; --> Vetor para armazenar registros
      -- Chave composta por:
      --   Nome Cidade(35) + FaixaCep(23) + Cep(8) + Endereco(60) + Conta(8) + Sequencia (6)
      vr_chv_cartaAR VARCHAR2(140);   --> Var para montagem da chave

      -- Definição de tipo para armazenar informações dos associados (crapass)
      -- e também adicionamos as informações do endereço dos cooperados (crapenc)
      TYPE typ_reg_crapass IS
        RECORD(cdagenci crapass.cdagenci%TYPE
              ,nmprimtl crapass.nmprimtl%TYPE
              ,inpessoa crapass.inpessoa%TYPE
              ,nrcepend crapenc.nrcepend%TYPE
              ,nrendere crapenc.nrendere%TYPE
              ,dsendere crapenc.dsendere%TYPE
              ,nmbairro crapenc.nmbairro%TYPE
              ,nmcidade crapenc.nmcidade%TYPE
              ,cdufende crapenc.cdufende%TYPE
              ,complend crapenc.complend%TYPE);
      TYPE typ_tab_crapass IS
        TABLE OF typ_reg_crapass
          INDEX BY PLS_INTEGER; --> Número da conta
      vr_tab_crapass typ_tab_crapass;

      ----------------------------- VARIAVEIS ------------------------------

      -- Código do programa
      vr_cdprogra constant crapprg.cdprogra%TYPE := 'CRPS399';

      -- Tratamento de erros e desvios de fluxo
      vr_exc_erro exception;
      vr_exc_fimprg exception;
      vr_cdcritic   crapcri.cdcritic%TYPE;
      vr_dscritic   VARCHAR2(4000);

      -- Tipo de saída do comando Host
      vr_typ_said VARCHAR2(100);

      -- Variaveis auxiliares ao procsso geral
      vr_dstextab  craptab.dstextab%TYPE;  --> Busca na craptab
      vr_diaregepr PLS_INTEGER;            --> Número de dias de atraso para Emprestimos
      vr_diaregcli PLS_INTEGER;            --> Número de dias de atraso para Desc. Cheques e Conta
      vr_nrdedias  PLS_INTEGER;            --> Var generica para assimilar a qtde de dias de atraso cfme tipo de carta
      vr_flgenvar  BOOLEAN := FALSE;       --> Envio ou não de AR
      vr_dtininar  DATE;                   --> Data de início da parametrização de AR (antes dela era sempre enviado)

      -- Contadores de arquivos gerados cfme cada tipo
      vr_nrseq1dv PLS_INTEGER; -- 1º aviso aos devedores
      vr_nrseq2dv PLS_INTEGER; -- 2º aviso aos devedores
      vr_nrseq1av PLS_INTEGER; -- 1º aviso aos avalistas
      vr_nrseq2av PLS_INTEGER; -- 2º aviso aos avalistas
      vr_nrseq0ar PLS_INTEGER; -- Avisos de recebimento (AR)
      vr_nrseqger PLS_INTEGER; -- Número geral de sequenciamento
      vr_qtdoctos PLS_INTEGER; -- Número de documentos gerados

      -- Variaveis para os XMLs e relatórios
      vr_clobarq    CLOB;           --> Clob para conter o dados dos ARs
      vr_clobrel    CLOB;           --> Clob para os dados do relatório 359
      vr_dsdireto   VARCHAR2(200);  --> Diretório padrão cfme a cooperativa
      vr_nmarqdat   VARCHAR2(200);  --> Nome base do relatório (01crrl359_ddmm_)
      vr_numerseq   PLS_INTEGER;    --> Sequencial de documentos impressos

      -- Variaveis para envio a Blucopy
      vr_dscoreml VARCHAR2(300);
      vr_dslstarq VARCHAR2(400);

      -- Variavel informando se existira copia
      vr_flenvcop VARCHAR2(01);

      -- Subrotina para montagem da chave de gravação na tabela vr_tab_cratext
      FUNCTION fn_chv_cratext (pr_rw_crapcdd IN cr_crapcdd%ROWTYPE
                              ,pr_nrcepend   IN crapenc.nrcepend%TYPE
                              ,pr_dsendres   IN crapenc.dsendere%TYPE
                              ,pr_nrendere   IN crapenc.nrendere%TYPE
                              ,pr_nrdconta   IN crapass.nrdconta%TYPE
                              ,pr_sqarqatu   IN NUMBER) RETURN VARCHAR2 IS
        -- Chave auxiliar
        --    Nome Cidade(35) + FaixaCep(23) + Cep(8) + Endereco(60) + Conta(8) + Sequencia (6)
        vr_chv_cratext VARCHAR2(140);
        -- Descrição do endereço com o número da casa
        vr_dsendere VARCHAR2(60);
      BEGIN
        -- Montar a descrição do endereço incluindo o número da casa se passado
        vr_dsendere := pr_dsendres;
        --
        IF pr_nrendere > 0 THEN
          vr_dsendere := vr_dsendere || ', ' || gene0002.fn_mask(pr_nrendere,'zzz.zz9');
        END IF;
        -- Ajustar a variavel para garantir 60 posições
        vr_dsendere := RPAD(vr_dsendere,60,' ');
        -- Montar a chave para gravação do formulário composta por:
        -- Se foi encontrado crapcdd
        IF pr_rw_crapcdd.flgachou = 'S' THEN
          --    Nome Cidade(35) + FaixaCep(23) + ...
          vr_chv_cratext := RPAD(SUBSTR(pr_rw_crapcdd.nomedcdd,1,35),35,' ')
                         || gene0002.fn_mask(pr_rw_crapcdd.nrcepini,'99.999.999') || ' - ' || gene0002.fn_mask(pr_rw_crapcdd.nrcepfim,'99.999.999');
        ELSE
          -- Montar a chave sem cidade e faixa de cep ...
          vr_chv_cratext := RPAD(' ',58,' ');
        END IF;
        -- Incluir o restante da informação da chave:
        --   Cep(8) + Endereço(60) + Conta(8) + Sequencia(6)
        vr_chv_cratext := vr_chv_cratext ||to_char(pr_nrcepend,'fm00000000')
                       || vr_dsendere
                       || LPAD(pr_nrdconta,8,'0')
                       || LPAD(pr_sqarqatu,6,'0');
        -- Retornar a chave montada
        RETURN vr_chv_cratext;
      END;

      -- Subrotina para geração do A.R. (Aviso Recebimento)
      PROCEDURE pc_gera_AR(pr_nrdconta_cdv  IN crapass.nrdconta%TYPE
                          ,pr_nrdconta  IN crapass.nrdconta%TYPE
                          ,pr_cdagenci  IN crapass.cdagenci%TYPE
                          ,pr_nmprimtl  IN crapass.nmprimtl%TYPE
                          ,pr_nrcepend  IN crapenc.nrcepend%TYPE
                          ,pr_dsendres  IN crapenc.dsendere%TYPE
                          ,pr_nrendere  IN crapenc.nrendere%TYPE
                          ,pr_complend  IN crapenc.complend%TYPE
                          ,pr_nmbairro  IN crapenc.nmbairro%TYPE
                          ,pr_nmcidade  IN crapenc.nmcidade%TYPE
                          ,pr_cdufresd  IN crapenc.cdufende%TYPE
                          ,pr_indespac  IN PLS_INTEGER
                          ,pr_dscritic OUT VARCHAR2) IS
      BEGIN
        -- Incrementar contador de AR
        vr_nrseq0ar := vr_nrseq0ar + 1;
        -- Incrementar contador de documentos
        vr_qtdoctos := vr_qtdoctos + 1;
        -- Limpar flag de encontro dos centros de distribuição
        rw_crapcdd.flgachou := 'N';
        -- Se foi passado CEP
        IF pr_nrcepend <> 0 THEN
          -- Busca do cadastro de centros de distribuição por CEP
          OPEN cr_crapcdd(pr_nrcepend => pr_nrcepend);
          FETCH cr_crapcdd
           INTO rw_crapcdd;
          CLOSE cr_crapcdd;
        END IF;
        -- Montar a chave através de funçao
        vr_chv_cartaAR := fn_chv_cratext(pr_rw_crapcdd => rw_crapcdd
                                        ,pr_nrcepend   => pr_nrcepend
                                        ,pr_dsendres   => pr_dsendres
                                        ,pr_nrendere   => pr_nrendere
                                        ,pr_nrdconta   => pr_nrdconta
                                        ,pr_sqarqatu   => vr_nrseq0ar);
        -- Se foi encontrado crapcdd
        IF rw_crapcdd.flgachou = 'S' THEN
          -- Copiar as informações provenientes desta tabela
          vr_tab_cartaAR(vr_chv_cartaAR).nomedcdd := RPAD(rw_crapcdd.nomedcdd,35,' ');
          vr_tab_cartaAR(vr_chv_cartaAR).nrcepcdd := gene0002.fn_mask(rw_crapcdd.nrcepini,'99.999.999') || ' - ' || gene0002.fn_mask(rw_crapcdd.nrcepfim,'99.999.999');
          vr_tab_cartaAR(vr_chv_cartaAR).dscentra := rw_crapcdd.dscentra;
        END IF;
        -- Enviar os outros campos que são independentes da crapcdd
        vr_tab_cartaAR(vr_chv_cartaAR).nrcepend := pr_nrcepend;
        vr_tab_cartaAR(vr_chv_cartaAR).nrdconta := pr_nrdconta;
        vr_tab_cartaAR(vr_chv_cartaAR).cdagenci := pr_cdagenci;
        vr_tab_cartaAR(vr_chv_cartaAR).indespac := pr_indespac;
        -- Enviar linhas internas da carta
        vr_tab_cartaAR(vr_chv_cartaAR).dsdlinha(1) := to_char(vr_nrseqger,'fm000000');
        vr_tab_cartaAR(vr_chv_cartaAR).dsdlinha(2) := RPAD(substr(pr_nmprimtl,1,40),40,' ');
        vr_tab_cartaAR(vr_chv_cartaAR).dsdlinha(3) := pr_dsendres;
        -- Se existe o número da casa
        IF pr_nrendere > 0 THEN
          -- Concatenamos o mesmo no endereço 1
          vr_tab_cartaAR(vr_chv_cartaAR).dsdlinha(3) := vr_tab_cartaAR(vr_chv_cartaAR).dsdlinha(3) || ', ' || gene0002.fn_mask(pr_nrendere,'zzz.zz9');
        END IF;
        vr_tab_cartaAR(vr_chv_cartaAR).dsdlinha(4) := RPAD(SUBSTR(pr_complend,1,40),40,' ');
        vr_tab_cartaAR(vr_chv_cartaAR).dsdlinha(5) := RPAD(SUBSTR(pr_nmbairro,1,24),24,' ')||RPAD(SUBSTR(pr_nmcidade,1,15),15,' ')||' - '||pr_cdufresd;
        vr_tab_cartaAR(vr_chv_cartaAR).dsdlinha(6) := gene0002.fn_mask(pr_nrcepend,'zzzzz.zz9');
        vr_tab_cartaAR(vr_chv_cartaAR).dsdlinha(7) := RPAD(SUBSTR(rw_crapcop.nmextcop,1,40),40,' ');
        vr_tab_cartaAR(vr_chv_cartaAR).dsdlinha(8) := TRIM(SUBSTR(rw_crapcop.dsendcop,1,40) || ' ' || TRIM(gene0002.fn_mask(SUBSTR(rw_crapcop.nrendcop,1,5),'zz.zzz')));
        vr_tab_cartaAR(vr_chv_cartaAR).dsdlinha(9) := RPAD(SUBSTR(rw_crapcop.nmbairro,1,29),29,' ')||RPAD(SUBSTR(rw_crapcop.nmcidade,1,15),15,' ')||' - '||rw_crapcop.cdufdcop;
        vr_tab_cartaAR(vr_chv_cartaAR).dsdlinha(10) := gene0002.fn_mask(rw_crapcop.nrcepend,'zzzzz.zz9');
        vr_tab_cartaAR(vr_chv_cartaAR).dsdlinha(11) := to_char(rw_crapdat.dtmvtopr,'dd/mm/yyyy');
        vr_tab_cartaAR(vr_chv_cartaAR).dsdlinha(12) := 'PSC';
        vr_tab_cartaAR(vr_chv_cartaAR).dsdlinha(13) := to_char(pr_cdcooper,'fm00') || to_char(pr_nrdconta_cdv,'fm00000000');
      EXCEPTION
        WHEN OTHERS THEN
          -- Gerar critica
          pr_dscritic := 'Erro na subrotina pc_gera_AR. Detalhes: '||sqlerrm;
      END;

      -- Subrotina para geração do 1º aviso para o devedor
      PROCEDURE pc_emite_1_carta_dev(pr_nrdconta     IN crapass.nrdconta%TYPE
                                    ,pr_nmprimtl     IN crapass.nmprimtl%TYPE
                                    ,pr_nrctremp     IN crapcdv.nrctremp%TYPE
                                    ,pr_cdagenci     IN crapass.cdagenci%TYPE
                                    ,pr_tpctrato     IN crapcdv.cdorigem%TYPE
                                    ,pr_vlsdeved     IN crapcdv.vlsdeved%TYPE
                                    ,pr_qtdiatra     IN crapcdv.qtdiatra%TYPE
                                    ,pr_nrcepend     IN crapenc.nrcepend%TYPE
                                    ,pr_dsendres     IN crapenc.dsendere%TYPE
                                    ,pr_nrendere     IN crapenc.nrendere%TYPE
                                    ,pr_complend     IN crapenc.complend%TYPE
                                    ,pr_nmbairro     IN crapenc.nmbairro%TYPE
                                    ,pr_nmcidade     IN crapenc.nmcidade%TYPE
                                    ,pr_cdufresd     IN crapenc.cdufende%TYPE
                                    ,pr_dscritic    OUT VARCHAR2) IS
      BEGIN
        -- Incrementar contador de 1º aviso para devedores
        vr_nrseq1dv := vr_nrseq1dv + 1;
        -- Montar a chave para gravação dos registros w-relat (Tipo de Carta (1) + Agencia (3) + Conta (10) + Sequencia (6))
        vr_chv_rel359 := 1||LPAD(pr_cdagenci,3,'0')||LPAD(pr_nrdconta,10,'0')||LPAD(vr_nrseq1dv,6,'0');
        -- Finalmente insere na tabela
        vr_tab_rel359(vr_chv_rel359).tpdcarta := 1;
        vr_tab_rel359(vr_chv_rel359).nrdconta := pr_nrdconta;
        vr_tab_rel359(vr_chv_rel359).nrctremp := pr_nrctremp;
        vr_tab_rel359(vr_chv_rel359).qtdiatra := pr_qtdiatra;
        vr_tab_rel359(vr_chv_rel359).vlsdeved := pr_vlsdeved;
        vr_tab_rel359(vr_chv_rel359).nomedes1 := pr_nmprimtl;
        vr_tab_rel359(vr_chv_rel359).tpctrato := pr_tpctrato;
        vr_tab_rel359(vr_chv_rel359).cdagenci := pr_cdagenci;
        vr_tab_rel359(vr_chv_rel359).nrsequen := vr_nrseq1dv;
        -- Limpar flag de encontro dos centros de distribuição
        rw_crapcdd.flgachou := 'N';
        -- Se foi passado CEP
        IF pr_nrcepend <> 0 THEN
          -- Busca do cadastro de centros de distribuição por CEP
          OPEN cr_crapcdd(pr_nrcepend => pr_nrcepend);
          FETCH cr_crapcdd
           INTO rw_crapcdd;
          CLOSE cr_crapcdd;
        END IF;
        -- Montar a chave através de funçao
        vr_chv_cratext := fn_chv_cratext (pr_rw_crapcdd => rw_crapcdd
                                         ,pr_nrcepend   => pr_nrcepend
                                         ,pr_dsendres   => pr_dsendres
                                         ,pr_nrendere   => pr_nrendere
                                         ,pr_nrdconta   => pr_nrdconta
                                         ,pr_sqarqatu   => vr_nrseq1dv);
        -- Se foi encontrado crapcdd
        IF rw_crapcdd.flgachou = 'S' THEN
          -- Copiar as informações provenientes desta tabela
          vr_tab_cratext_1(vr_chv_cratext).nomedcdd := rw_crapcdd.nomedcdd;
          vr_tab_cratext_1(vr_chv_cratext).nrcepcdd := gene0002.fn_mask(rw_crapcdd.nrcepini,'99.999.999') || ' - ' || gene0002.fn_mask(rw_crapcdd.nrcepfim,'99.999.999');
          vr_tab_cratext_1(vr_chv_cratext).dscentra := rw_crapcdd.dscentra;
        END IF;
        -- Criar o registro da carta
        vr_tab_cratext_1(vr_chv_cratext).cdagenci := pr_cdagenci;
        vr_tab_cratext_1(vr_chv_cratext).nrdconta := pr_nrdconta;
        vr_tab_cratext_1(vr_chv_cratext).nmprimtl := RPAD(SUBSTR(pr_nmprimtl,1,40),47,' ')||LPAD(pr_cdagenci,3,'0');
        vr_tab_cratext_1(vr_chv_cratext).dsender1 := pr_dsendres;
        vr_tab_cratext_1(vr_chv_cratext).dsender2 := RPAD(SUBSTR(pr_nmbairro,1,15),18,' ')||RPAD(SUBSTR(pr_nmcidade,1,15),15,' ')||' - '||pr_cdufresd;
        vr_tab_cratext_1(vr_chv_cratext).nrcepend := pr_nrcepend;
        vr_tab_cratext_1(vr_chv_cratext).complend := RPAD(SUBSTR(pr_complend,1,35),35,' ');
        vr_tab_cratext_1(vr_chv_cratext).dtemissa := rw_crapdat.dtmvtopr;
        vr_tab_cratext_1(vr_chv_cratext).nrdordem := 1;              -- ORDEM
        vr_tab_cratext_1(vr_chv_cratext).tpdocmto := 10;             -- TIPO
        vr_tab_cratext_1(vr_chv_cratext).nrseqint := vr_nrseq1dv;    -- SEQUENCIA
        vr_tab_cratext_1(vr_chv_cratext).indespac := 1;              -- CORREIO
        -- Se existe o número da casa
        IF pr_nrendere > 0 THEN
          -- Concatenamos o mesmo no endereço 1
          vr_tab_cratext_1(vr_chv_cratext).dsender1 := vr_tab_cratext_1(vr_chv_cratext).dsender1 || ', ' || gene0002.fn_mask(pr_nrendere,'zzz.zz9');
        END IF;
        -- Envio dos dados internos
        vr_tab_cratext_1(vr_chv_cratext).dsintern(1) := RPAD(SUBSTR(pr_nmprimtl,1,40),43,' ')||gene0002.fn_mask_conta(pr_nrdconta);
        vr_tab_cratext_1(vr_chv_cratext).dsintern(2) := rw_crapcop.nmextcop;
        vr_tab_cratext_1(vr_chv_cratext).dsintern(3) := '#';
      EXCEPTION
        WHEN OTHERS THEN
          -- Gerar critica
          pr_dscritic := 'Erro na subrotina pc_emite_1_carta_dev. Detalhes: '||sqlerrm;
      END;

      -- Subrotina para geração do 2º aviso para o devedor
      PROCEDURE pc_emite_2_carta_dev(pr_nrdconta     IN crapass.nrdconta%TYPE
                                    ,pr_nmprimtl     IN crapass.nmprimtl%TYPE
                                    ,pr_nrctremp     IN crapcdv.nrctremp%TYPE
                                    ,pr_cdagenci     IN crapass.cdagenci%TYPE
                                    ,pr_tpctrato     IN crapcdv.cdorigem%TYPE
                                    ,pr_vlsdeved     IN crapcdv.vlsdeved%TYPE
                                    ,pr_qtdiatra     IN crapcdv.qtdiatra%TYPE
                                    ,pr_nrcepend     IN crapenc.nrcepend%TYPE
                                    ,pr_dsendres     IN crapenc.dsendere%TYPE
                                    ,pr_nrendere     IN crapenc.nrendere%TYPE
                                    ,pr_complend     IN crapenc.complend%TYPE
                                    ,pr_nmbairro     IN crapenc.nmbairro%TYPE
                                    ,pr_nmcidade     IN crapenc.nmcidade%TYPE
                                    ,pr_cdufresd     IN crapenc.cdufende%TYPE
                                    ,pr_nrdedias     IN PLS_INTEGER
                                    ,pr_dscritic    OUT VARCHAR2) IS
      BEGIN
        -- Incrementar contador de 2º aviso para devedores
        vr_nrseq2dv := vr_nrseq2dv + 1;
        -- Incrementar contador geral
        vr_nrseqger := vr_nrseqger + 1;
        -- Montar a chave para gravação dos registros w-relat (Tipo de Carta (1) + Agencia (3) + Conta (10) + Sequencia (6))
        vr_chv_rel359 := 2||LPAD(pr_cdagenci,3,'0')||LPAD(pr_nrdconta,10,'0')||LPAD(vr_nrseq2dv,6,'0');
        -- Finalmente insere na tabela
        vr_tab_rel359(vr_chv_rel359).tpdcarta := 2;
        vr_tab_rel359(vr_chv_rel359).nrdconta := pr_nrdconta;
        vr_tab_rel359(vr_chv_rel359).nrctremp := pr_nrctremp;
        vr_tab_rel359(vr_chv_rel359).qtdiatra := pr_qtdiatra;
        vr_tab_rel359(vr_chv_rel359).vlsdeved := pr_vlsdeved;
        vr_tab_rel359(vr_chv_rel359).nomedes1 := pr_nmprimtl;
        vr_tab_rel359(vr_chv_rel359).tpctrato := pr_tpctrato;
        vr_tab_rel359(vr_chv_rel359).cdagenci := pr_cdagenci;
        vr_tab_rel359(vr_chv_rel359).nrsequen := vr_nrseq2dv;
        -- Limpar flag de encontro dos centros de distribuição
        rw_crapcdd.flgachou := 'N';
        -- Se foi passado CEP
        IF pr_nrcepend <> 0 THEN
          -- Busca do cadastro de centros de distribuição por CEP
          OPEN cr_crapcdd(pr_nrcepend => pr_nrcepend);
          FETCH cr_crapcdd
           INTO rw_crapcdd;
          CLOSE cr_crapcdd;
        END IF;
        -- Montar a chave através de funçao
        vr_chv_cratext := fn_chv_cratext (pr_rw_crapcdd => rw_crapcdd
                                         ,pr_nrcepend   => pr_nrcepend
                                         ,pr_dsendres   => pr_dsendres
                                         ,pr_nrendere   => pr_nrendere
                                         ,pr_nrdconta   => pr_nrdconta
                                         ,pr_sqarqatu   => vr_nrseq2dv);
        -- Se foi encontrado crapcdd
        IF rw_crapcdd.flgachou = 'S' THEN
          -- Copiar as informações provenientes desta tabela
          vr_tab_cratext_2(vr_chv_cratext).nomedcdd := rw_crapcdd.nomedcdd;
          vr_tab_cratext_2(vr_chv_cratext).nrcepcdd := gene0002.fn_mask(rw_crapcdd.nrcepini,'99.999.999') || ' - ' || gene0002.fn_mask(rw_crapcdd.nrcepfim,'99.999.999');
          vr_tab_cratext_2(vr_chv_cratext).dscentra := rw_crapcdd.dscentra;
        END IF;
        -- Criar o registro da carta
        vr_tab_cratext_2(vr_chv_cratext).cdagenci := pr_cdagenci;
        vr_tab_cratext_2(vr_chv_cratext).nrdconta := pr_nrdconta;
        vr_tab_cratext_2(vr_chv_cratext).nmprimtl := RPAD(SUBSTR(pr_nmprimtl,1,40),47,' ')||LPAD(pr_cdagenci,3,'0');
        vr_tab_cratext_2(vr_chv_cratext).dsender1 := pr_dsendres;
        vr_tab_cratext_2(vr_chv_cratext).dsender2 := RPAD(SUBSTR(pr_nmbairro,1,15),18,' ')||RPAD(SUBSTR(pr_nmcidade,1,15),15,' ')||' - '||pr_cdufresd;
        vr_tab_cratext_2(vr_chv_cratext).nrcepend := pr_nrcepend;
        vr_tab_cratext_2(vr_chv_cratext).complend := RPAD(SUBSTR(pr_complend,1,35),35,' ');
        vr_tab_cratext_2(vr_chv_cratext).dtemissa := rw_crapdat.dtmvtopr;
        vr_tab_cratext_2(vr_chv_cratext).nrdordem := 1;              -- ORDEM
        vr_tab_cratext_2(vr_chv_cratext).tpdocmto := 10;             -- TIPO
        vr_tab_cratext_2(vr_chv_cratext).nrseqint := vr_nrseq2dv;    -- SEQUENCIA
        vr_tab_cratext_2(vr_chv_cratext).indespac := 1;              -- CORREIO
        vr_tab_cratext_2(vr_chv_cratext).numeroar := vr_nrseqger;    -- Contador geral
        -- Se existe o número da casa
        IF pr_nrendere > 0 THEN
          -- Concatenamos o mesmo no endereço 1
          vr_tab_cratext_2(vr_chv_cratext).dsender1 := vr_tab_cratext_2(vr_chv_cratext).dsender1 || ', ' || gene0002.fn_mask(pr_nrendere,'zzz.zz9');
        END IF;
        -- Envio dos dados internos
        vr_tab_cratext_2(vr_chv_cratext).dsintern(1) := RPAD(SUBSTR(pr_nmprimtl,1,40),43,' ')||gene0002.fn_mask_conta(pr_nrdconta);
        vr_tab_cratext_2(vr_chv_cratext).dsintern(2) := to_char(pr_nrdedias,'fm00');
        vr_tab_cratext_2(vr_chv_cratext).dsintern(3) := rw_crapcop.nmextcop;
        vr_tab_cratext_2(vr_chv_cratext).dsintern(4) := '#';
        -- Se está parametrizado para enviarmos o AR
        IF vr_flgenvar THEN
          -- Gerar A.R. (Aviso Recebimento)
          pc_gera_AR(pr_nrdconta_cdv => pr_nrdconta
                    ,pr_nrdconta => pr_nrdconta
                    ,pr_cdagenci => pr_cdagenci
                    ,pr_indespac => 1 -- Correio
                    ,pr_nmprimtl => pr_nmprimtl
                    ,pr_nrcepend => pr_nrcepend
                    ,pr_dsendres => pr_dsendres
                    ,pr_nrendere => pr_nrendere
                    ,pr_complend => pr_complend
                    ,pr_nmbairro => pr_nmbairro
                    ,pr_nmcidade => pr_nmcidade
                    ,pr_cdufresd => pr_cdufresd
                    ,pr_dscritic => pr_dscritic);
          -- Se retornou erro
          IF pr_dscritic IS NOT NULL THEN
            -- Efetuar raise do erro
            RAISE vr_exc_erro;
          END IF;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          -- Gerar critica
          pr_dscritic := 'Erro na subrotina pc_emite_2_carta_dev. Detalhes: '||sqlerrm;
      END;

      -- Subrotina para geração do 1º avisto para a avalista
      PROCEDURE pc_emite_1_carta_avalista(pr_nrdconta     IN crapass.nrdconta%TYPE
                                         ,pr_nmprimtl     IN crapass.nmprimtl%TYPE
                                         ,pr_nrctremp     IN crapcdv.nrctremp%TYPE
                                         ,pr_cdagenci     IN crapass.cdagenci%TYPE
                                         ,pr_tpctrato     IN crapcdv.cdorigem%TYPE
                                         ,pr_nrdconta_avl IN crapass.nrdconta%TYPE
                                         ,pr_nmdavali     IN crapass.nmprimtl%TYPE
                                         ,pr_vlsdeved     IN crapcdv.vlsdeved%TYPE
                                         ,pr_qtdiatra     IN crapcdv.qtdiatra%TYPE
                                         ,pr_nrcepend     IN crapenc.nrcepend%TYPE
                                         ,pr_dsendres     IN crapenc.dsendere%TYPE
                                         ,pr_nrendere     IN crapenc.nrendere%TYPE
                                         ,pr_complend     IN crapenc.complend%TYPE
                                         ,pr_nmbairro     IN crapenc.nmbairro%TYPE
                                         ,pr_nmcidade     IN crapenc.nmcidade%TYPE
                                         ,pr_cdufresd     IN crapenc.cdufende%TYPE
                                         ,pr_dscritic    OUT VARCHAR2) IS
      BEGIN
        -- Incrementar contador de 1º aviso para avalistas
        vr_nrseq1av := vr_nrseq1av + 1;
        -- Incrementar contador geral
        vr_nrseqger := vr_nrseqger + 1;
        -- Montar a chave para gravação dos registros w-relat (Tipo de Carta (1) + Agencia (3) + Conta (10) + Sequencia(6))
        vr_chv_rel359 := 3||LPAD(pr_cdagenci,3,'0')||LPAD(pr_nrdconta,10,'0')||LPAD(vr_nrseq1av,6,'0');
        -- Finalmente insere na tabela
        vr_tab_rel359(vr_chv_rel359).tpdcarta := 3;
        vr_tab_rel359(vr_chv_rel359).nrdconta := pr_nrdconta;
        vr_tab_rel359(vr_chv_rel359).nrctremp := pr_nrctremp;
        vr_tab_rel359(vr_chv_rel359).qtdiatra := pr_qtdiatra;
        vr_tab_rel359(vr_chv_rel359).vlsdeved := pr_vlsdeved;
        vr_tab_rel359(vr_chv_rel359).nomedes1 := pr_nmdavali;
        vr_tab_rel359(vr_chv_rel359).tpctrato := pr_tpctrato;
        vr_tab_rel359(vr_chv_rel359).cdagenci := pr_cdagenci;
        vr_tab_rel359(vr_chv_rel359).nrsequen := vr_nrseq1av;
        -- Limpar flag de encontro dos centros de distribuição
        rw_crapcdd.flgachou := 'N';
        -- Se foi passado CEP
        IF pr_nrcepend <> 0 THEN
          -- Busca do cadastro de centros de distribuição por CEP
          OPEN cr_crapcdd(pr_nrcepend => pr_nrcepend);
          FETCH cr_crapcdd
           INTO rw_crapcdd;
          CLOSE cr_crapcdd;
        END IF;
        -- Montar a chave através de funçao
        vr_chv_cratext := fn_chv_cratext (pr_rw_crapcdd => rw_crapcdd
                                         ,pr_nrcepend   => pr_nrcepend
                                         ,pr_dsendres   => pr_dsendres
                                         ,pr_nrendere   => pr_nrendere
                                         ,pr_nrdconta   => pr_nrdconta
                                         ,pr_sqarqatu   => vr_nrseq1av);
        -- Se foi encontrado crapcdd
        IF rw_crapcdd.flgachou = 'S' THEN
          -- Copiar as informações provenientes desta tabela
          vr_tab_cratext_3(vr_chv_cratext).nomedcdd := rw_crapcdd.nomedcdd;
          vr_tab_cratext_3(vr_chv_cratext).nrcepcdd := gene0002.fn_mask(rw_crapcdd.nrcepini,'99.999.999') || ' - ' || gene0002.fn_mask(rw_crapcdd.nrcepfim,'99.999.999');
          vr_tab_cratext_3(vr_chv_cratext).dscentra := rw_crapcdd.dscentra;
        END IF;
        -- Criar o registro da carta
        vr_tab_cratext_3(vr_chv_cratext).cdagenci := pr_cdagenci;
        vr_tab_cratext_3(vr_chv_cratext).nrdconta := pr_nrdconta;
        vr_tab_cratext_3(vr_chv_cratext).nmprimtl := RPAD(SUBSTR(pr_nmdavali,1,40),47,' ')||LPAD(pr_cdagenci,3,'0');
        vr_tab_cratext_3(vr_chv_cratext).dsender1 := pr_dsendres;
        vr_tab_cratext_3(vr_chv_cratext).dsender2 := RPAD(SUBSTR(pr_nmbairro,1,15),18,' ')||RPAD(SUBSTR(pr_nmcidade,1,15),15,' ')||' - '||pr_cdufresd;
        vr_tab_cratext_3(vr_chv_cratext).nrcepend := pr_nrcepend;
        vr_tab_cratext_3(vr_chv_cratext).complend := RPAD(SUBSTR(pr_complend,1,35),35,' ');
        vr_tab_cratext_3(vr_chv_cratext).dtemissa := rw_crapdat.dtmvtopr;
        vr_tab_cratext_3(vr_chv_cratext).nrdordem := 1;              -- ORDEM
        vr_tab_cratext_3(vr_chv_cratext).tpdocmto := 10;             -- TIPO
        vr_tab_cratext_3(vr_chv_cratext).nrseqint := vr_nrseq1av;    -- SEQUENCIA
        vr_tab_cratext_3(vr_chv_cratext).indespac := 1;              -- CORREIO
        -- Se existe o número da casa
        IF pr_nrendere > 0 THEN
          -- Concatenamos o mesmo no endereço 1
          vr_tab_cratext_3(vr_chv_cratext).dsender1 := vr_tab_cratext_3(vr_chv_cratext).dsender1 || ', ' || gene0002.fn_mask(pr_nrendere,'zzz.zz9');
        END IF;
        -- Envio dos dados internos de 1 a 4 de acordo com o envio ou não da conta
        IF pr_nrdconta_avl <> 0 THEN
          -- Enviamos além do nome a conta
          vr_tab_cratext_3(vr_chv_cratext).dsintern(1) := RPAD(SUBSTR(pr_nmdavali,1,40),43,' ')||gene0002.fn_mask_conta(pr_nrdconta_avl);
          vr_tab_cratext_3(vr_chv_cratext).dsintern(2) := pr_nmdavali;
          vr_tab_cratext_3(vr_chv_cratext).dsintern(3) := 'C/C   ';
          vr_tab_cratext_3(vr_chv_cratext).dsintern(4) := gene0002.fn_mask_conta(pr_nrdconta_avl);
        ELSE
          -- Enviamos somente o nome
          vr_tab_cratext_3(vr_chv_cratext).dsintern(1) := pr_nmdavali;
          vr_tab_cratext_3(vr_chv_cratext).dsintern(2) := pr_nmdavali;
          vr_tab_cratext_3(vr_chv_cratext).dsintern(3) := ' ';
          vr_tab_cratext_3(vr_chv_cratext).dsintern(4) := ' ';
        END IF;
        -- Envio do restante das informações internas
        vr_tab_cratext_3(vr_chv_cratext).dsintern(5) := SUBSTR(pr_nmprimtl,1,40);
        vr_tab_cratext_3(vr_chv_cratext).dsintern(6) := gene0002.fn_mask_conta(pr_nrdconta);
        vr_tab_cratext_3(vr_chv_cratext).dsintern(7) := rw_crapcop.nmextcop;
        vr_tab_cratext_3(vr_chv_cratext).dsintern(8) := '#';
      EXCEPTION
        WHEN OTHERS THEN
          -- Gerar critica
          pr_dscritic := 'Erro na subrotina pc_emite_1_carta_avalista. Detalhes: '||sqlerrm;
      END;

      -- Subrotina para geração do 2º aviso para a avalista
      PROCEDURE pc_emite_2_carta_avalista(pr_nrdconta     IN crapass.nrdconta%TYPE
                                         ,pr_nmprimtl     IN crapass.nmprimtl%TYPE
                                         ,pr_nrctremp     IN crapcdv.nrctremp%TYPE
                                         ,pr_cdagenci     IN crapass.cdagenci%TYPE
                                         ,pr_tpctrato     IN crapcdv.cdorigem%TYPE
                                         ,pr_nrdconta_avl IN crapass.nrdconta%TYPE
                                         ,pr_nmdavali     IN crapass.nmprimtl%TYPE
                                         ,pr_vlsdeved     IN crapcdv.vlsdeved%TYPE
                                         ,pr_qtdiatra     IN crapcdv.qtdiatra%TYPE
                                         ,pr_nrcepend     IN crapenc.nrcepend%TYPE
                                         ,pr_dsendres     IN crapenc.dsendere%TYPE
                                         ,pr_nrendere     IN crapenc.nrendere%TYPE
                                         ,pr_complend     IN crapenc.complend%TYPE
                                         ,pr_nmbairro     IN crapenc.nmbairro%TYPE
                                         ,pr_nmcidade     IN crapenc.nmcidade%TYPE
                                         ,pr_cdufresd     IN crapenc.cdufende%TYPE
                                         ,pr_nrdedias     IN PLS_INTEGER
                                         ,pr_dscritic    OUT VARCHAR2) IS
      BEGIN
        -- Incrementar contador de 1º aviso para avalistas
        vr_nrseq2av := vr_nrseq2av + 1;
        -- Incrementar contador geral
        vr_nrseqger := vr_nrseqger + 1;
        -- Montar a chave para gravação dos registros w-relat (Tipo de Carta (1) + Agencia (3) + Conta (10) + Sequencia (6))
        vr_chv_rel359 := 4||LPAD(pr_cdagenci,3,'0')||LPAD(pr_nrdconta,10,'0')||LPAD(vr_nrseq2av,6,'0');
        -- Finalmente insere na tabela
        vr_tab_rel359(vr_chv_rel359).tpdcarta := 4;
        vr_tab_rel359(vr_chv_rel359).nrdconta := pr_nrdconta;
        vr_tab_rel359(vr_chv_rel359).nrctremp := pr_nrctremp;
        vr_tab_rel359(vr_chv_rel359).qtdiatra := pr_qtdiatra;
        vr_tab_rel359(vr_chv_rel359).vlsdeved := pr_vlsdeved;
        vr_tab_rel359(vr_chv_rel359).nomedes1 := pr_nmdavali;
        vr_tab_rel359(vr_chv_rel359).tpctrato := pr_tpctrato;
        vr_tab_rel359(vr_chv_rel359).cdagenci := pr_cdagenci;
        vr_tab_rel359(vr_chv_rel359).nrsequen := vr_nrseq2av;
        -- Limpar flag de encontro dos centros de distribuição
        rw_crapcdd.flgachou := 'N';
        -- Se foi passado CEP
        IF pr_nrcepend <> 0 THEN
          -- Busca do cadastro de centros de distribuição por CEP
          OPEN cr_crapcdd(pr_nrcepend => pr_nrcepend);
          FETCH cr_crapcdd
           INTO rw_crapcdd;
          CLOSE cr_crapcdd;
        END IF;
        -- Montar a chave através de funçao
        vr_chv_cratext := fn_chv_cratext (pr_rw_crapcdd => rw_crapcdd
                                         ,pr_nrcepend   => pr_nrcepend
                                         ,pr_dsendres   => pr_dsendres
                                         ,pr_nrendere   => pr_nrendere
                                         ,pr_nrdconta   => pr_nrdconta
                                         ,pr_sqarqatu   => vr_nrseq2av);
        -- Se foi encontrado crapcdd
        IF rw_crapcdd.flgachou = 'S' THEN
          -- Copiar as informações provenientes desta tabela
          vr_tab_cratext_4(vr_chv_cratext).nomedcdd := rw_crapcdd.nomedcdd;
          vr_tab_cratext_4(vr_chv_cratext).nrcepcdd := gene0002.fn_mask(rw_crapcdd.nrcepini,'99.999.999') || ' - ' || gene0002.fn_mask(rw_crapcdd.nrcepfim,'99.999.999');
          vr_tab_cratext_4(vr_chv_cratext).dscentra := rw_crapcdd.dscentra;
        END IF;
        -- Criar o registro da carta
        vr_tab_cratext_4(vr_chv_cratext).cdagenci := pr_cdagenci;
        vr_tab_cratext_4(vr_chv_cratext).nrdconta := pr_nrdconta;
        vr_tab_cratext_4(vr_chv_cratext).nmprimtl := RPAD(SUBSTR(pr_nmdavali,1,40),47,' ')||LPAD(pr_cdagenci,3,'0');
        vr_tab_cratext_4(vr_chv_cratext).dsender1 := pr_dsendres;
        vr_tab_cratext_4(vr_chv_cratext).dsender2 := RPAD(SUBSTR(pr_nmbairro,1,15),18,' ')||RPAD(SUBSTR(pr_nmcidade,1,15),15,' ')||' - '||pr_cdufresd;
        vr_tab_cratext_4(vr_chv_cratext).nrcepend := pr_nrcepend;
        vr_tab_cratext_4(vr_chv_cratext).complend := RPAD(SUBSTR(pr_complend,1,35),35,' ');
        vr_tab_cratext_4(vr_chv_cratext).dtemissa := rw_crapdat.dtmvtopr;
        vr_tab_cratext_4(vr_chv_cratext).nrdordem := 1;              -- ORDEM
        vr_tab_cratext_4(vr_chv_cratext).tpdocmto := 10;             -- TIPO
        vr_tab_cratext_4(vr_chv_cratext).nrseqint := vr_nrseq2av;    -- SEQUENCIA
        vr_tab_cratext_4(vr_chv_cratext).indespac := 1;              -- CORREIO
        vr_tab_cratext_4(vr_chv_cratext).numeroar := vr_nrseqger;    -- Contador geral
        -- Se existe o número da casa
        IF pr_nrendere > 0 THEN
          -- Concatenamos o mesmo no endereço 1
          vr_tab_cratext_4(vr_chv_cratext).dsender1 := vr_tab_cratext_4(vr_chv_cratext).dsender1 || ', ' || gene0002.fn_mask(pr_nrendere,'zzz.zz9');
        END IF;
        -- Envio dos dados internos 1 de acordo com o envio ou não da conta
        IF pr_nrdconta_avl <> 0 THEN
          -- Enviamos além do nome a conta
          vr_tab_cratext_4(vr_chv_cratext).dsintern(1) := RPAD(SUBSTR(pr_nmdavali,1,40),43,' ')||gene0002.fn_mask_conta(pr_nrdconta_avl);
        ELSE
          -- Enviamos somente o nome
          vr_tab_cratext_4(vr_chv_cratext).dsintern(1) := pr_nmdavali;
        END IF;
        -- Envio do restante das informações internas
        vr_tab_cratext_4(vr_chv_cratext).dsintern(2) := pr_nmdavali;
        vr_tab_cratext_4(vr_chv_cratext).dsintern(3) := SUBSTR(pr_nmprimtl,1,40);
        vr_tab_cratext_4(vr_chv_cratext).dsintern(4) := gene0002.fn_mask_conta(pr_nrdconta);
        vr_tab_cratext_4(vr_chv_cratext).dsintern(5) := to_char(pr_nrdedias,'fm00');
        vr_tab_cratext_4(vr_chv_cratext).dsintern(6) := rw_crapcop.nmextcop;
        vr_tab_cratext_4(vr_chv_cratext).dsintern(7) := '#';
        -- Se está parametrizado para enviarmos o AR
        IF vr_flgenvar THEN
          -- Gerar A.R. (Aviso Recebimento)
          pc_gera_AR(pr_nrdconta_cdv => pr_nrdconta
                    ,pr_nrdconta => pr_nrdconta_avl
                    ,pr_cdagenci => pr_cdagenci
                    ,pr_indespac => 1 -- Correio
                    ,pr_nmprimtl => pr_nmdavali
                    ,pr_nrcepend => pr_nrcepend
                    ,pr_dsendres => pr_dsendres
                    ,pr_nrendere => pr_nrendere
                    ,pr_complend => pr_complend
                    ,pr_nmbairro => pr_nmbairro
                    ,pr_nmcidade => pr_nmcidade
                    ,pr_cdufresd => pr_cdufresd
                    ,pr_dscritic => pr_dscritic);
          -- Se retornou erro
          IF pr_dscritic IS NOT NULL THEN
            -- Efetuar raise do erro
            RAISE vr_exc_erro;
          END IF;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          -- Gerar critica
          pr_dscritic := 'Erro na subrotina pc_emite_2_carta_avalista. Detalhes: '||sqlerrm;
      END;

      -- Subrotina para geração da carta ao avalista
      PROCEDURE pc_prepara_emissao_avalistas(pr_seq_envio  IN PLS_INTEGER         --> 1º ou 2º envio
                                            ,pr_rw_crapcdv IN cr_crapcdv%ROWTYPE  --> Dados da carta
                                            ,pr_rw_crapepr IN cr_crapepr%ROWTYPE  --> Dados de empréstimo
                                            ,pr_nrdedias   IN PLS_INTEGER           --> Número de dias em atraso
                                            ,pr_dscritic  OUT VARCHAR2) IS
      BEGIN
        -- Se existir avalista 1
        IF (pr_rw_crapepr.nrctaav1 IS NOT NULL)
        AND (  (pr_rw_crapepr.nrctaav1 <> 0 AND pr_rw_crapepr.nmdaval1_compl = ' ')
             OR
               (pr_rw_crapepr.nrctaav1 <> 0 AND pr_rw_crapepr.nrctaav1 = pr_rw_crapepr.nrctaav1_compl)) THEN
          -- Somente continuar se o avalista 1 existir na tabela e for de um tipo de pessoa <> 3
          IF vr_tab_crapass.EXISTS(pr_rw_crapepr.nrctaav1) AND vr_tab_crapass(pr_rw_crapepr.nrctaav1).inpessoa <> 3 THEN
            -- Gerar arquivo para o avalista cfme sequencia de envio
            IF pr_seq_envio = 1 THEN
              -- Enviar arquivo 1 (1ª carta) ao avalista
              pc_emite_1_carta_avalista(pr_nrdconta     => pr_rw_crapcdv.nrdconta
                                       ,pr_nmprimtl     => vr_tab_crapass(pr_rw_crapcdv.nrdconta).nmprimtl
                                       ,pr_nrctremp     => pr_rw_crapcdv.nrctremp
                                       ,pr_cdagenci     => vr_tab_crapass(pr_rw_crapcdv.nrdconta).cdagenci
                                       ,pr_tpctrato     => pr_rw_crapcdv.cdorigem
                                       ,pr_nrdconta_avl => rw_crapepr.nrctaav1
                                       ,pr_nmdavali     => vr_tab_crapass(rw_crapepr.nrctaav1).nmprimtl
                                       ,pr_vlsdeved     => pr_rw_crapcdv.vlsdeved
                                       ,pr_qtdiatra     => pr_rw_crapcdv.qtdiatra
                                       ,pr_nrcepend     => vr_tab_crapass(rw_crapepr.nrctaav1).nrcepend
                                       ,pr_dsendres     => vr_tab_crapass(rw_crapepr.nrctaav1).dsendere
                                       ,pr_nrendere     => vr_tab_crapass(rw_crapepr.nrctaav1).nrendere
                                       ,pr_complend     => vr_tab_crapass(rw_crapepr.nrctaav1).complend
                                       ,pr_nmbairro     => vr_tab_crapass(rw_crapepr.nrctaav1).nmbairro
                                       ,pr_nmcidade     => vr_tab_crapass(rw_crapepr.nrctaav1).nmcidade
                                       ,pr_cdufresd     => vr_tab_crapass(rw_crapepr.nrctaav1).cdufende
                                       ,pr_dscritic     => pr_dscritic);
            ELSE
              -- Enviar arquivo 2 (2ª carta) ao avalista
              pc_emite_2_carta_avalista(pr_nrdconta     => pr_rw_crapcdv.nrdconta
                                       ,pr_nmprimtl     => vr_tab_crapass(pr_rw_crapcdv.nrdconta).nmprimtl
                                       ,pr_nrctremp     => pr_rw_crapcdv.nrctremp
                                       ,pr_cdagenci     => vr_tab_crapass(pr_rw_crapcdv.nrdconta).cdagenci
                                       ,pr_tpctrato     => pr_rw_crapcdv.cdorigem
                                       ,pr_nrdconta_avl => rw_crapepr.nrctaav1
                                       ,pr_nmdavali     => vr_tab_crapass(rw_crapepr.nrctaav1).nmprimtl
                                       ,pr_vlsdeved     => pr_rw_crapcdv.vlsdeved
                                       ,pr_qtdiatra     => pr_rw_crapcdv.qtdiatra
                                       ,pr_nrcepend     => vr_tab_crapass(rw_crapepr.nrctaav1).nrcepend
                                       ,pr_dsendres     => vr_tab_crapass(rw_crapepr.nrctaav1).dsendere
                                       ,pr_nrendere     => vr_tab_crapass(rw_crapepr.nrctaav1).nrendere
                                       ,pr_complend     => vr_tab_crapass(rw_crapepr.nrctaav1).complend
                                       ,pr_nmbairro     => vr_tab_crapass(rw_crapepr.nrctaav1).nmbairro
                                       ,pr_nmcidade     => vr_tab_crapass(rw_crapepr.nrctaav1).nmcidade
                                       ,pr_cdufresd     => vr_tab_crapass(rw_crapepr.nrctaav1).cdufende
                                       ,pr_nrdedias     => pr_nrdedias
                                       ,pr_dscritic     => pr_dscritic);
            END IF;
            -- Se retornou erro
            IF pr_dscritic IS NOT NULL THEN
              -- Efetuar raise do erro
              RAISE vr_exc_erro;
            END IF;
          END IF;
        END IF;

        -- Se existir avalista 2
        IF (pr_rw_crapepr.nrctaav2 IS NOT NULL)
        AND (  (pr_rw_crapepr.nrctaav2 <> 0 AND pr_rw_crapepr.nmdaval2_compl = ' ')
             OR
               (pr_rw_crapepr.nrctaav2 <> 0 AND pr_rw_crapepr.nrctaav2 = pr_rw_crapepr.nrctaav2_compl)) THEN
          -- Somente continuar se o avalista 2 existir na tabela e for de um tipo de pessoa <> 3
          IF vr_tab_crapass.EXISTS(pr_rw_crapepr.nrctaav2) AND vr_tab_crapass(pr_rw_crapepr.nrctaav2).inpessoa <> 3 THEN
            -- Gerar arquivo para o avalista cfme sequencia de envio
            IF pr_seq_envio = 1 THEN
              -- Enviar arquivo 1 (1ª carta) ao avalista 2
              pc_emite_1_carta_avalista(pr_nrdconta     => pr_rw_crapcdv.nrdconta
                                       ,pr_nmprimtl     => vr_tab_crapass(pr_rw_crapcdv.nrdconta).nmprimtl
                                       ,pr_nrctremp     => pr_rw_crapcdv.nrctremp
                                       ,pr_cdagenci     => vr_tab_crapass(pr_rw_crapcdv.nrdconta).cdagenci
                                       ,pr_tpctrato     => pr_rw_crapcdv.cdorigem
                                       ,pr_nrdconta_avl => rw_crapepr.nrctaav2
                                       ,pr_nmdavali     => vr_tab_crapass(rw_crapepr.nrctaav2).nmprimtl
                                       ,pr_vlsdeved     => pr_rw_crapcdv.vlsdeved
                                       ,pr_qtdiatra     => pr_rw_crapcdv.qtdiatra
                                       ,pr_nrcepend     => vr_tab_crapass(rw_crapepr.nrctaav2).nrcepend
                                       ,pr_dsendres     => vr_tab_crapass(rw_crapepr.nrctaav2).dsendere
                                       ,pr_nrendere     => vr_tab_crapass(rw_crapepr.nrctaav2).nrendere
                                       ,pr_complend     => vr_tab_crapass(rw_crapepr.nrctaav2).complend
                                       ,pr_nmbairro     => vr_tab_crapass(rw_crapepr.nrctaav2).nmbairro
                                       ,pr_nmcidade     => vr_tab_crapass(rw_crapepr.nrctaav2).nmcidade
                                       ,pr_cdufresd     => vr_tab_crapass(rw_crapepr.nrctaav2).cdufende
                                       ,pr_dscritic     => pr_dscritic);
            ELSE
              -- Enviar arquivo 2 (2ª carta) ao avalista
              pc_emite_2_carta_avalista(pr_nrdconta     => pr_rw_crapcdv.nrdconta
                                       ,pr_nmprimtl     => vr_tab_crapass(pr_rw_crapcdv.nrdconta).nmprimtl
                                       ,pr_nrctremp     => pr_rw_crapcdv.nrctremp
                                       ,pr_cdagenci     => vr_tab_crapass(pr_rw_crapcdv.nrdconta).cdagenci
                                       ,pr_tpctrato     => pr_rw_crapcdv.cdorigem
                                       ,pr_nrdconta_avl => rw_crapepr.nrctaav2
                                       ,pr_nmdavali     => vr_tab_crapass(rw_crapepr.nrctaav2).nmprimtl
                                       ,pr_vlsdeved     => pr_rw_crapcdv.vlsdeved
                                       ,pr_qtdiatra     => pr_rw_crapcdv.qtdiatra
                                       ,pr_nrcepend     => vr_tab_crapass(rw_crapepr.nrctaav2).nrcepend
                                       ,pr_dsendres     => vr_tab_crapass(rw_crapepr.nrctaav2).dsendere
                                       ,pr_nrendere     => vr_tab_crapass(rw_crapepr.nrctaav2).nrendere
                                       ,pr_complend     => vr_tab_crapass(rw_crapepr.nrctaav2).complend
                                       ,pr_nmbairro     => vr_tab_crapass(rw_crapepr.nrctaav2).nmbairro
                                       ,pr_nmcidade     => vr_tab_crapass(rw_crapepr.nrctaav2).nmcidade
                                       ,pr_cdufresd     => vr_tab_crapass(rw_crapepr.nrctaav2).cdufende
                                       ,pr_nrdedias     => pr_nrdedias
                                       ,pr_dscritic     => pr_dscritic);
            END IF;
            -- Se retornou erro
            IF pr_dscritic IS NOT NULL THEN
              -- Efetuar raise do erro
              RAISE vr_exc_erro;
            END IF;
          END IF;
        END IF;

        -- Se existirem avalistas terceiros
        IF (pr_rw_crapepr.nmdaval1_compl <> ' '  AND pr_rw_crapepr.nrctaav1_compl = 0)
        OR (pr_rw_crapepr.nmdaval2_compl <> ' '  AND pr_rw_crapepr.nrctaav2_compl = 0) THEN
          -- Buscá-los na tabela crapavt
          FOR rw_crapavt IN cr_crapavt(pr_nrdconta => pr_rw_crapcdv.nrdconta
                                      ,pr_nrctremp => pr_rw_crapcdv.nrctremp) LOOP
            -- Gerar arquivo para o avalista terceiro cfme sequencia de envio
            IF pr_seq_envio = 1 THEN
              -- Enviar arquivo 1 (1ª carta) ao avalista terceiro encontrado
              pc_emite_1_carta_avalista(pr_nrdconta     => pr_rw_crapcdv.nrdconta
                                       ,pr_nmprimtl     => vr_tab_crapass(pr_rw_crapcdv.nrdconta).nmprimtl
                                       ,pr_nrctremp     => pr_rw_crapcdv.nrctremp
                                       ,pr_cdagenci     => vr_tab_crapass(pr_rw_crapcdv.nrdconta).cdagenci
                                       ,pr_tpctrato     => pr_rw_crapcdv.cdorigem
                                       ,pr_nrdconta_avl => 0 --> Não existe conta na cooperativa
                                       ,pr_nmdavali     => rw_crapavt.nmdavali
                                       ,pr_vlsdeved     => pr_rw_crapcdv.vlsdeved
                                       ,pr_qtdiatra     => pr_rw_crapcdv.qtdiatra
                                       ,pr_nrcepend     => rw_crapavt.nrcepend
                                       ,pr_dsendres     => rw_crapavt.dsendres##1
                                       ,pr_nrendere     => rw_crapavt.nrendere
                                       ,pr_complend     => rw_crapavt.complend
                                       ,pr_nmbairro     => rw_crapavt.dsendres##2
                                       ,pr_nmcidade     => rw_crapavt.nmcidade
                                       ,pr_cdufresd     => rw_crapavt.cdufresd
                                       ,pr_dscritic     => pr_dscritic);
            ELSE
              -- Enviar arquivo 2 (2ª carta) ao avalista terceiro
              pc_emite_2_carta_avalista(pr_nrdconta     => pr_rw_crapcdv.nrdconta
                                       ,pr_nmprimtl     => vr_tab_crapass(pr_rw_crapcdv.nrdconta).nmprimtl
                                       ,pr_nrctremp     => pr_rw_crapcdv.nrctremp
                                       ,pr_cdagenci     => vr_tab_crapass(pr_rw_crapcdv.nrdconta).cdagenci
                                       ,pr_tpctrato     => pr_rw_crapcdv.cdorigem
                                       ,pr_nrdconta_avl => 0 --> Não existe conta na cooperativa
                                       ,pr_nmdavali     => rw_crapavt.nmdavali
                                       ,pr_vlsdeved     => pr_rw_crapcdv.vlsdeved
                                       ,pr_qtdiatra     => pr_rw_crapcdv.qtdiatra
                                       ,pr_nrcepend     => rw_crapavt.nrcepend
                                       ,pr_dsendres     => rw_crapavt.dsendres##1
                                       ,pr_nrendere     => rw_crapavt.nrendere
                                       ,pr_complend     => rw_crapavt.complend
                                       ,pr_nmbairro     => rw_crapavt.dsendres##2
                                       ,pr_nmcidade     => rw_crapavt.nmcidade
                                       ,pr_cdufresd     => rw_crapavt.cdufresd
                                       ,pr_nrdedias     => pr_nrdedias
                                       ,pr_dscritic     => pr_dscritic);
            END IF;
            -- Se retornou erro
            IF pr_dscritic IS NOT NULL THEN
              -- Efetuar raise do erro
              RAISE vr_exc_erro;
            END IF;
          END LOOP;
        END IF;

      EXCEPTION
        WHEN vr_exc_erro THEN
          -- Concatenamos a descrição padrão
          pr_dscritic := 'Erro na subrotina pc_prepara_emissao_avalistas. Detalhes: '||pr_dscritic;
        WHEN OTHERS THEN
          -- Erro não tratado
          pr_dscritic := 'Erro não tratado na subrotina pc_prepara_emissao_avalistas. Detalhes: '||sqlerrm;
      END;

      -- Rotina pra reaproveitamento de código na chamada da form0001.pc_gera_dados_inform
      PROCEDURE pc_envia_dados_inform(pr_nmarqdat    IN VARCHAR2
                                     ,pr_nrarquiv    IN PLS_INTEGER
                                     ,pr_flenvcop    IN CHAR
                                     ,pr_dscritic    OUT VARCHAR2) IS
      BEGIN
        -- Mover o arquivo para o diretório salvar
        gene0001.pc_OScommand_Shell(pr_des_comando => 'mv '||vr_dsdireto||'/arq/'||pr_nmarqdat|| ' '||vr_dsdireto||'/salvar/'||pr_nmarqdat
                                   ,pr_typ_saida   => vr_typ_said
                                   ,pr_des_saida   => pr_dscritic);
        -- Testar erro
        IF vr_typ_said = 'ERR' THEN
          -- O comando shell executou com erro, gerar log e sair do processo
          pr_cdcritic := 0;
          pr_dscritic := 'Erro ao mover o arquivo '||vr_dsdireto||'/arq/'||pr_nmarqdat||' para o diretório salvar: ' || pr_dscritic;
          RAISE vr_exc_erro;
        END IF;
        -- Cooperativas que trabalham com a Engecopy / Blucopy
        IF pr_cdcooper IN(1,2,4) THEN
          -- Se foi solicitado para enviar uma 2ª copia
          IF pr_flenvcop = 'S' THEN
            -- Efetuamos uma cópia do mesmo arquivo com sufixo "a" e "b" no final do nome
            gene0001.pc_OScommand_Shell(pr_des_comando => 'cp '||vr_dsdireto||'/salvar/'||pr_nmarqdat|| ' '||vr_dsdireto||'/salvar/'||SUBSTR(pr_nmarqdat,1,LENGTH(pr_nmarqdat)-4)||'a.dat'
                                       ,pr_typ_saida   => vr_typ_said
                                       ,pr_des_saida   => pr_dscritic);
            -- Testar erro
            IF vr_typ_said = 'ERR' THEN
              -- O comando shell executou com erro, gerar log e sair do processo
              pr_cdcritic := 0;
              pr_dscritic := 'Erro ao copiar o arquivo '||vr_dsdireto||'/salvar/'||pr_nmarqdat||' para envio da 1a cópia a blucopy: ' || pr_dscritic;
              RAISE vr_exc_erro;
            END IF;
            -- Efetuamos uma cópia do mesmo arquivo com sufixo "a" e "b" no final do nome
            gene0001.pc_OScommand_Shell(pr_des_comando => 'cp '||vr_dsdireto||'/salvar/'||pr_nmarqdat|| ' '||vr_dsdireto||'/salvar/'||SUBSTR(pr_nmarqdat,1,LENGTH(pr_nmarqdat)-4)||'b.dat'
                                       ,pr_typ_saida   => vr_typ_said
                                       ,pr_des_saida   => pr_dscritic);
            -- Testar erro
            IF vr_typ_said = 'ERR' THEN
              -- O comando shell executou com erro, gerar log e sair do processo
              pr_cdcritic := 0;
              pr_dscritic := 'Erro ao copiar o arquivo '||vr_dsdireto||'/salvar/'||pr_nmarqdat||' para envio da 1a cópia a blucopy: ' || pr_dscritic;
              RAISE vr_exc_erro;
            END IF;
            -- Montamos a lista de anexos com os dois arquivos com sufixo a e b criados
            vr_dslstarq := vr_dsdireto||'/salvar/'||SUBSTR(pr_nmarqdat,1,LENGTH(pr_nmarqdat)-4)||'a.dat;'
                        || vr_dsdireto||'/salvar/'||SUBSTR(pr_nmarqdat,1,LENGTH(pr_nmarqdat)-4)||'b.dat';
            -- Montamos o corpo do e-mail
            vr_dscoreml := 'Em anexo os arquivos(' || SUBSTR(pr_nmarqdat,1,LENGTH(pr_nmarqdat)-4)||'a.zip e '
                        || SUBSTR(pr_nmarqdat,1,LENGTH(pr_nmarqdat)-4)||'b.zip) contendo as cartas da '
                        || rw_crapcop.nmrescop || '.';
          ELSE
            -- Enviaremos apenas o arquivo original
            vr_dslstarq := vr_dsdireto||'/salvar/'||pr_nmarqdat;
            -- Montamos o corpo do e-mail
            vr_dscoreml := 'Em anexo o arquivo(' || SUBSTR(pr_nmarqdat,1,LENGTH(pr_nmarqdat)-4)||'.zip) '
                        || 'contendo as cartas da '|| rw_crapcop.nmrescop || '.';
          END IF;
          -- Finalmente solicita o envio a Blucopy
          form0001.pc_envia_dados_blucopy(pr_cdcooper => pr_cdcooper   --> Coop conectada
                                         ,pr_cdprogra => vr_cdprogra   --> Programa que solicitou o envio
                                         ,pr_dslstarq => vr_dslstarq   --> Lista de arquivos a enviar
                                         ,pr_dsasseml => 'Cartas ' || rw_crapcop.nmrescop || ' - Arquivo ['||pr_nrarquiv||']' --> Assunto do e-mail de envio
                                         ,pr_dscoreml => vr_dscoreml   --> Corpo com as informações do e-mail
                                         ,pr_des_erro => pr_dscritic); --> Erro no processo
          -- Testar saída com erro
          IF pr_dscritic IS NOT NULL THEN
            -- Levanta exceção
            pr_cdcritic := 0;
            RAISE vr_exc_erro;
          END IF;

          -- Remover arquivos duplicados para enviar por email
          IF pr_flenvcop = 'S' THEN
            -- Remover cópia do mesmo arquivo com sufixo "a" no final do nome
            gene0001.pc_OScommand_Shell(pr_des_comando => 'rm '||vr_dsdireto||'/salvar/'||SUBSTR(pr_nmarqdat,1,LENGTH(pr_nmarqdat)-4)||'a.dat'
                                       ,pr_typ_saida   => vr_typ_said
                                       ,pr_des_saida   => pr_dscritic);

            -- Remover cópia do mesmo arquivo com sufixo "b" no final do nome
            gene0001.pc_OScommand_Shell(pr_des_comando => 'rm '||vr_dsdireto||'/salvar/'||SUBSTR(pr_nmarqdat,1,LENGTH(pr_nmarqdat)-4)||'b.dat'
                                       ,pr_typ_saida   => vr_typ_said
                                       ,pr_des_saida   => pr_dscritic);
          END IF;
        ELSE
          -- Enviar 1ª copia (trocando o nome do arquivo)
          gene0001.pc_OScommand_Shell(pr_des_comando => 'cp '||vr_dsdireto||'/salvar/'||pr_nmarqdat|| ' '||vr_dsdireto||'/salvar/'||SUBSTR(pr_nmarqdat,1,LENGTH(pr_nmarqdat)-4)||'a.dat'
                                     ,pr_typ_saida   => vr_typ_said
                                     ,pr_des_saida   => pr_dscritic);
          -- Testar erro
          IF vr_typ_said = 'ERR' THEN
            -- O comando shell executou com erro, gerar log e sair do processo
            pr_cdcritic := 0;
            pr_dscritic := 'Erro ao copiar o arquivo '||vr_dsdireto||'/salvar/'||pr_nmarqdat||' para envio da 1a cópia a postmix: ' || pr_dscritic;
            RAISE vr_exc_erro;
          END IF;
          -- Chamar o envio dos dados a Postmix
          form0001.pc_envia_dados_postmix(pr_cdcooper => pr_cdcooper
                                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                         ,pr_nmarqdat => pr_nmarqdat
                                         ,pr_nmarqenv => 'salvar/'||SUBSTR(pr_nmarqdat,1,LENGTH(pr_nmarqdat)-4)||'a.dat'
                                         ,pr_inaguard => 'S'
                                         ,pr_des_erro => pr_dscritic);
          -- Testar saída com erro
          IF pr_dscritic IS NOT NULL THEN
            -- Levanta exceção
            pr_cdcritic := 0;
            RAISE vr_exc_erro;
          END IF;
          -- Efetuar remoção do arquivo copiado
          gene0001.pc_oscommand_shell('rm '||vr_dsdireto||'/salvar/'||SUBSTR(pr_nmarqdat,1,LENGTH(pr_nmarqdat)-4)||'a.dat');
          -- Se foi solicitado para enviar uma 2ª copia
          IF pr_flenvcop = 'S' THEN
            -- Efetuar nova copia e trocar o nome desta vez com B antes da extensão
            gene0001.pc_OScommand_Shell(pr_des_comando => 'cp '||vr_dsdireto||'/salvar/'||pr_nmarqdat|| ' '||vr_dsdireto||'/salvar/'||SUBSTR(pr_nmarqdat,1,LENGTH(pr_nmarqdat)-4)||'b.dat'
                                       ,pr_typ_saida   => vr_typ_said
                                       ,pr_des_saida   => pr_dscritic);
            -- Testar erro
            IF vr_typ_said = 'ERR' THEN
              -- O comando shell executou com erro, gerar log e sair do processo
              pr_cdcritic := 0;
              pr_dscritic := 'Erro ao copiar o arquivo '||vr_dsdireto||'/salvar/'||pr_nmarqdat||' para envio da 2a cópia a postmix: ' || pr_dscritic;
              RAISE vr_exc_erro;
            END IF;
            -- Chamar o envio dos dados a Postmix
            form0001.pc_envia_dados_postmix(pr_cdcooper => pr_cdcooper
                                           ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                           ,pr_nmarqdat => pr_nmarqdat
                                           ,pr_nmarqenv => 'salvar/'||SUBSTR(pr_nmarqdat,1,LENGTH(pr_nmarqdat)-4)||'b.dat'
                                           ,pr_inaguard => 'S'
                                           ,pr_des_erro => pr_dscritic);
            -- Testar saída com erro
            IF pr_dscritic IS NOT NULL THEN
              -- Levanta exceção
              pr_cdcritic := 0;
              RAISE vr_exc_erro;
            END IF;
            -- Efetuar remoção do arquivo copiado
            gene0001.pc_oscommand_shell('rm '||vr_dsdireto||'/salvar/'||SUBSTR(pr_nmarqdat,1,LENGTH(pr_nmarqdat)-4)||'b.dat');
          END IF;
        END IF;
      EXCEPTION
        WHEN vr_exc_fimprg THEN
          -- Guardar a critica na variavel global que será retornada ao final do programa
          vr_dscritic := pr_dscritic;
          RAISE vr_exc_fimprg;
        WHEN vr_exc_erro THEN
          -- Concatenamos a descrição padrão
          pr_dscritic := 'Erro na subrotina pc_envia_dados_inform. Detalhes: '||pr_dscritic;
        WHEN OTHERS THEN
          -- Erro não tratado
          pr_dscritic := 'Erro não tratado na subrotina pc_envia_dados_inform. Detalhes: '||sqlerrm;
      END;

      -- Rotina para geração de dados a partir de tabelas do tipo form0001.typ_tab_cratext
      -- e envio dos mesmos para as empresas conveniadas (postmix ou blucopy)
      PROCEDURE pc_gera_dados_inform(pr_nmarqdat    IN VARCHAR2
                                    ,pr_tab_cratext IN OUT form0001.typ_tab_cratext
                                    ,pr_nrarquiv    IN PLS_INTEGER
                                    ,pr_flenvcop    IN CHAR
                                    ,pr_dscritic    OUT VARCHAR2) IS
        -- Variaveis auxiliares
        vr_nrarquiv PLS_INTEGER;   --> Sequencial do arquivo
      BEGIN
        -- Copiar a informação do sequencial e nome do arquivo para variaveis
        -- locais já que o procedimento na package tem retorno, e os parametros
        -- são somente de entrada
        vr_nrarquiv := pr_nrarquiv;
        -- Chamar rotina para geração dos arquivos da 1ª carta aos devedores
        form0001.pc_gera_dados_inform(pr_cdcooper    => pr_cdcooper
                                     ,pr_dtmvtolt    => rw_crapdat.dtmvtolt
                                     ,pr_cdacesso    => NULL --> Sem mensagem
                                     ,pr_qtmaxarq    => 0    --> Sem qtdade máxima
                                     ,pr_nrarquiv    => vr_nrarquiv
                                     ,pr_dsdireto    => vr_dsdireto||'/arq'
                                     ,pr_nmarqdat    => pr_nmarqdat
                                     ,pr_tab_cratext => pr_tab_cratext
                                     ,pr_imlogoex    => 'laser/imagens/logo_'||trim(lower(rw_crapcop.nmrescop))||'_externo.pcx'
                                     ,pr_imlogoin    => 'laser/imagens/logo_'||trim(lower(rw_crapcop.nmrescop))||'_interno.pcx'
                                     ,pr_des_erro    => pr_dscritic);
        -- Testar saida com erro
        IF pr_dscritic IS NOT NULL THEN
          -- Gerar exceção
          pr_cdcritic := 0;
          RAISE vr_exc_erro;
        END IF;
        -- Prosseguimos com o processo de envio dos arquivos já gerados
        pc_envia_dados_inform(pr_nmarqdat => pr_nmarqdat
                             ,pr_nrarquiv => vr_nrarquiv
                             ,pr_flenvcop => pr_flenvcop
                             ,pr_dscritic => pr_dscritic);
        -- Limpamos o vetor que não sera mais utilizado
        pr_tab_cratext.DELETE;
      EXCEPTION
        WHEN vr_exc_fimprg THEN
          RAISE vr_exc_fimprg;
        WHEN vr_exc_erro THEN
          -- Concatenamos a descrição padrão
          pr_dscritic := 'Erro na subrotina pc_gera_dados_inform. Detalhes: '||pr_dscritic;
        WHEN OTHERS THEN
          -- Erro não tratado
          pr_dscritic := 'Erro não tratado na subrotina pc_gera_dados_inform. Detalhes: '||sqlerrm;
      END;

      -- Subrotina para escrever texto na variável CLOB do XML
      PROCEDURE pc_escreve_clob(pr_clobdado IN OUT NOCOPY CLOB
                               ,pr_desdados IN VARCHAR2) IS
      BEGIN
        dbms_lob.writeappend(pr_clobdado, length(pr_desdados),pr_desdados);
      END;

      -- Subrotina simples para retornar a descrição do tipo da carta
      FUNCTION fn_dstpcart(pr_tpdcarta IN NUMBER) RETURN VARCHAR2 IS
      BEGIN
        IF pr_tpdcarta = 1 THEN
          RETURN '1a. CARTA DEVEDOR';
        ELSIF pr_tpdcarta = 2 THEN
          RETURN '2a. CARTA DEVEDOR';
        ELSIF pr_tpdcarta = 3 THEN
          RETURN '1a. CARTA AVALISTA';
        ELSE
          RETURN '2a. CARTA AVALISTA';
        END IF;
      END;

      -- Subrotina simples para retorno da origem cfme tipo de contrato
      FUNCTION fn_dsorigem(pr_tpctrato IN NUMBER) RETURN VARCHAR2 IS
      BEGIN
        IF pr_tpctrato = 1 THEN
          RETURN 'CL';
        ELSIF pr_tpctrato = 3 THEN
          RETURN 'EP';
        ELSE
          RETURN '  ';
        END IF;
      END;

    BEGIN

      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra);

      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop;
      FETCH cr_crapcop
       INTO rw_crapcop;
      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 651);
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;

      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat
       INTO rw_crapdat;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      -- Validações iniciais do programa
      BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                               ,pr_flgbatch => 1 --true
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_cdcritic => vr_cdcritic);
      -- Se a variavel de erro é <> 0
      IF vr_cdcritic <> 0 THEN
        -- Buscar descrição da crítica
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        -- Envio centralizado de log de erro
        RAISE vr_exc_erro;
      END IF;

      -- Buscar configuração de dias para cartas em atraso
      vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'DIASCARTAS'
                                               ,pr_tpregist => 001);
      -- Se encontrar
      IF vr_dstextab IS NOT NULL THEN
        -- Separar informações contidas no txt genérico
        -- Número de dias para Emprestimos (posição 29 até 31)
        vr_diaregepr := gene0002.fn_char_para_number(substr(vr_dstextab,29,3));
        -- Número de dias para Desc. Cheques e Conta (posição 33 até 35)
        vr_diaregcli := gene0002.fn_char_para_number(substr(vr_dstextab,33,3));
        -- Verificar configuração de AR (posição 37,38 e 39 [SIM ou NAO]]
        IF UPPER(substr(vr_dstextab,37,3)) = 'NAO' THEN
          -- Desativar envio e iniciar contador com 1
          vr_flgenvar := FALSE;
          -- Armazenar a data de início do envio de AR somente com parametrização
          -- Obs: Anteriormente a esta data era sempre enviado
          vr_dtininar := to_date(substr(vr_dstextab,45,10),'dd/mm/yyyy');
          -- Se a data atual for inferior a esta data
          IF rw_crapdat.dtmvtolt < vr_dtininar THEN
            -- Subscrever a flag pois deverá haver o envio
            vr_flgenvar := TRUE;
          END IF;
        ELSE
          -- Ativar o envio e inicar o contador com 2, pois o
          -- 1º será o arquivo dos envios de AR
          vr_flgenvar := TRUE;
        END IF;
      END IF;

      -- Busca do parâmetro de número de cópias
      IF upper(substr(tabe0001.fn_busca_dstextab(pr_cdcooper => 1,
                                                 pr_nmsistem => 'CRED',
                                                 pr_tptabela => 'USUARI',
                                                 pr_cdempres => 11,
                                                 pr_cdacesso => 'DIASCARTAS',
                                                 pr_tpregist => 001),37,3)) = 'NAO' THEN
        vr_flenvcop := 'N';
      ELSE
        vr_flenvcop := 'S';
      END IF;

      -- Busca dos associados da cooperativa
      FOR rw_crapass IN cr_crapass LOOP
        -- Adicionar ao vetor as informações chaveando pela conta
        vr_tab_crapass(rw_crapass.nrdconta).cdagenci := rw_crapass.cdagenci;
        vr_tab_crapass(rw_crapass.nrdconta).nmprimtl := rw_crapass.nmprimtl;
        vr_tab_crapass(rw_crapass.nrdconta).inpessoa := rw_crapass.inpessoa;
      END LOOP;

      -- Varrer também o cadastro de endereços dos cooperados e atualizar
      -- a mesma pltable utilizada acima na crapass
      FOR rw_crapenc IN cr_crapenc LOOP
        -- Adicionar a tabela somente se já existe informação
        -- ou seja, existia crapass que a gerou
        IF vr_tab_crapass.EXISTS(rw_crapenc.nrdconta) THEN
          vr_tab_crapass(rw_crapenc.nrdconta).nrcepend := rw_crapenc.nrcepend;
          vr_tab_crapass(rw_crapenc.nrdconta).nrendere := rw_crapenc.nrendere;
          vr_tab_crapass(rw_crapenc.nrdconta).dsendere := rw_crapenc.dsendere;
          vr_tab_crapass(rw_crapenc.nrdconta).nmbairro := rw_crapenc.nmbairro;
          vr_tab_crapass(rw_crapenc.nrdconta).nmcidade := rw_crapenc.nmcidade;
          vr_tab_crapass(rw_crapenc.nrdconta).cdufende := rw_crapenc.cdufende;
          vr_tab_crapass(rw_crapenc.nrdconta).complend := rw_crapenc.complend;
        END IF;
      END LOOP;

      -- Montar nome base dos arquivos
      vr_nmarqdat := to_char(pr_cdcooper,'fm00')||'crrl359_'
                  || to_char(rw_crapdat.dtmvtolt,'dd')||to_char(rw_crapdat.dtmvtolt,'mm')||'_';
      -- Inicializar contadores por tipo de arquivo
      vr_nrseq0ar := 0; -- Avisos de recebimento (AR)
      vr_nrseq1dv := 0; -- 1º aviso aos devedores
      vr_nrseq2dv := 0; -- 2º aviso aos devedores
      vr_nrseq1av := 0; -- 1º aviso aos avalistas
      vr_nrseq2av := 0; -- 2º aviso aos avalistas
      vr_nrseqger := 0; -- Sequenciador geral
      vr_qtdoctos := 0; -- Sequenciador de documentos

      -- Listagem das cartas de empréstimo com atraso
      FOR rw_crapcdv IN cr_crapcdv LOOP
        -- Somente continuar se a carta for de um associado cadastro
        IF NOT vr_tab_crapass.EXISTS(rw_crapcdv.nrdconta) THEN
          -- Ignorar o registro
          CONTINUE;
        END IF;
        -- Para cartas de empréstimo
        IF rw_crapcdv.cdorigem = 3 THEN
          -- Usar dias de atraso de empréstimo
          vr_nrdedias := vr_diaregepr;
          -- Tambem verificamos se existe o cadastro de
          -- emprestimo (crapepr) e e seu complemento (crawper)
          OPEN cr_crapepr(pr_nrdconta => rw_crapcdv.nrdconta
                         ,pr_nrctremp => rw_crapcdv.nrctremp);
          FETCH cr_crapepr
           INTO rw_crapepr;
          -- Ignorar o registro se não tiver encontrado
          IF cr_crapepr%NOTFOUND THEN
            -- Fecha o cursor e sai do registro
            CLOSE cr_crapepr;
            CONTINUE;
          ELSE
            -- Apenas fechar o cursor
            CLOSE cr_crapepr;
          END IF;
        ELSE
          -- Usar dias de atraso para conta e desc cheques
          vr_nrdedias := vr_diaregcli;
        END IF;
        -- Para emprestimos onde já foi solicitado a 2ª carta ao avalista e ainda não foi emitida
        -- e exista pelo menos 1 avalista em qualquer um dos campos de avalista
        IF rw_crapcdv.dtslavl2 <= rw_crapdat.dtmvtolt AND rw_crapcdv.dtemavl2 IS NULL AND rw_crapcdv.cdorigem = 3
        AND (rw_crapepr.nrctaav1 > 0 OR rw_crapepr.nmdaval1_compl <> ' ' OR rw_crapepr.nrctaav2 > 0 OR rw_crapepr.nmdaval2_compl <> ' ') THEN
          -- Emitir a 2ª carta do avalista
          pc_prepara_emissao_avalistas(pr_seq_envio  => 2  --> 2º envio
                                      ,pr_rw_crapcdv => rw_crapcdv  --> Dados da carta
                                      ,pr_rw_crapepr => rw_crapepr  --> Dados de empréstimo
                                      ,pr_nrdedias   => vr_nrdedias --> Número de dias em atraso
                                      ,pr_dscritic   => vr_dscritic);
          -- Testar se houve algum erro
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
          -- Atualizar a data de emissão da 2ª carta ao avalista
          BEGIN
            UPDATE crapcdv
               SET dtemavl2 = rw_crapdat.dtmvtopr
             WHERE rowid = rw_crapcdv.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              -- Gerar exceção e sair
              vr_dscritic := 'Erro ao atualizar data de emissão da 2a carta ao avalista na CRAPCDV. Detalhes: '||sqlerrm;
          END;
        -- Se já foi solicitada 2º envio ao devedor e ainda não foi enviada
        ELSIF rw_crapcdv.dtsldev2 <= rw_crapdat.dtmvtolt AND rw_crapcdv.dtemdev2 IS NULL THEN
          -- Emitir a 2ª carta ao devedor
          pc_emite_2_carta_dev(pr_nrdconta => rw_crapcdv.nrdconta
                              ,pr_nmprimtl => vr_tab_crapass(rw_crapcdv.nrdconta).nmprimtl
                              ,pr_nrctremp => rw_crapcdv.nrctremp
                              ,pr_cdagenci => vr_tab_crapass(rw_crapcdv.nrdconta).cdagenci
                              ,pr_tpctrato => rw_crapcdv.cdorigem
                              ,pr_vlsdeved => rw_crapcdv.vlsdeved
                              ,pr_qtdiatra => rw_crapcdv.qtdiatra
                              ,pr_nrcepend => vr_tab_crapass(rw_crapcdv.nrdconta).nrcepend
                              ,pr_dsendres => vr_tab_crapass(rw_crapcdv.nrdconta).dsendere
                              ,pr_nrendere => vr_tab_crapass(rw_crapcdv.nrdconta).nrendere
                              ,pr_complend => vr_tab_crapass(rw_crapcdv.nrdconta).complend
                              ,pr_nmbairro => vr_tab_crapass(rw_crapcdv.nrdconta).nmbairro
                              ,pr_nmcidade => vr_tab_crapass(rw_crapcdv.nrdconta).nmcidade
                              ,pr_cdufresd => vr_tab_crapass(rw_crapcdv.nrdconta).cdufende
                              ,pr_nrdedias => vr_nrdedias --> Número de dias em atraso
                              ,pr_dscritic => vr_dscritic);
          -- Testar se houve algum erro
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
          -- Se for um empréstimo
          IF rw_crapcdv.cdorigem = 3 THEN
            -- Somente continuar caso exista avalista
            IF rw_crapepr.nrctaav1 > 0 OR rw_crapepr.nmdaval1_compl <> ' ' OR rw_crapepr.nrctaav2 > 0 OR rw_crapepr.nmdaval2_compl <> ' ' THEN
              -- Emitir a 1ª carta ao avalista
              pc_prepara_emissao_avalistas(pr_seq_envio  => 1           --> 1º envio
                                          ,pr_rw_crapcdv => rw_crapcdv  --> Dados da carta
                                          ,pr_rw_crapepr => rw_crapepr  --> Dados de empréstimo
                                          ,pr_nrdedias   => vr_nrdedias --> Número de dias em atraso
                                          ,pr_dscritic   => vr_dscritic);
              -- Testar se houve algum erro
              IF vr_dscritic IS NOT NULL THEN
                RAISE vr_exc_erro;
              END IF;
            END IF;
          END IF;
          -- Atualizar a data de emissão da 2ª carta ao devedor
          BEGIN
            UPDATE crapcdv
               SET dtemdev2 = rw_crapdat.dtmvtopr
                  ,dtemavl1 = rw_crapdat.dtmvtopr
             WHERE rowid = rw_crapcdv.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              -- Gerar exceção e sair
              vr_dscritic := 'Erro ao atualizar data de emissão da 2a carta ao devedor na CRAPCDV. Detalhes: '||sqlerrm;
          END;
        -- Se já foi solicitada 1º envio ao devedor e ainda não foi enviado
        ELSIF rw_crapcdv.dtsldev1 <= rw_crapdat.dtmvtolt AND rw_crapcdv.dtemdev1 IS NULL THEN
          -- Emitir a 1ª carta ao devedor
          pc_emite_1_carta_dev(pr_nrdconta => rw_crapcdv.nrdconta
                              ,pr_nmprimtl => vr_tab_crapass(rw_crapcdv.nrdconta).nmprimtl
                              ,pr_nrctremp => rw_crapcdv.nrctremp
                              ,pr_cdagenci => vr_tab_crapass(rw_crapcdv.nrdconta).cdagenci
                              ,pr_tpctrato => rw_crapcdv.cdorigem
                              ,pr_vlsdeved => rw_crapcdv.vlsdeved
                              ,pr_qtdiatra => rw_crapcdv.qtdiatra
                              ,pr_nrcepend => vr_tab_crapass(rw_crapcdv.nrdconta).nrcepend
                              ,pr_dsendres => vr_tab_crapass(rw_crapcdv.nrdconta).dsendere
                              ,pr_nrendere => vr_tab_crapass(rw_crapcdv.nrdconta).nrendere
                              ,pr_complend => vr_tab_crapass(rw_crapcdv.nrdconta).complend
                              ,pr_nmbairro => vr_tab_crapass(rw_crapcdv.nrdconta).nmbairro
                              ,pr_nmcidade => vr_tab_crapass(rw_crapcdv.nrdconta).nmcidade
                              ,pr_cdufresd => vr_tab_crapass(rw_crapcdv.nrdconta).cdufende
                              ,pr_dscritic => vr_dscritic);
          -- Testar se houve algum erro
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
          -- Atualizar a data de emissão da 1ª carta ao devedor
          BEGIN
            UPDATE crapcdv
               SET dtemdev1 = rw_crapdat.dtmvtopr
             WHERE rowid = rw_crapcdv.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              -- Gerar exceção e sair
              vr_dscritic := 'Erro ao atualizar data de emissão da 1a carta ao devedor na CRAPCDV. Detalhes: '||sqlerrm;
          END;
        END IF;
      END LOOP;

      -- Buscar diretório base da cooperativa
      vr_dsdireto := gene0001.fn_diretorio(pr_tpdireto => 'C' --> Coop
                                          ,pr_cdcooper => pr_cdcooper);

      -- Se existe 1ª carta aos devedores
      IF vr_nrseq1dv > 0 THEN
        -- Chamar o envio das 1ªs cartas aos devedores através da rotina form0001.pc_gera_dados_inform
        BEGIN
          pc_gera_dados_inform(pr_nmarqdat    => vr_nmarqdat||'01.dat'
                              ,pr_tab_cratext => vr_tab_cratext_1
                              ,pr_nrarquiv    => 1   --> Arquivo nro 1
                              ,pr_flenvcop    => 'N' --> Apenas 1 via
                              ,pr_dscritic    => vr_dscritic);
        EXCEPTION
          WHEN vr_exc_fimprg THEN
            RAISE vr_exc_fimprg;
        END;
        -- Testar saída de erro
        IF vr_dscritic IS NOT NULL THEN
          -- Levantar exceção
          RAISE vr_exc_erro;
        END IF;
      END IF;

      -- Se existe 2ª carta aos devedores
      IF vr_nrseq2dv > 0 THEN
        -- Chamar o envio das 2ªs cartas aos devedores e enviar em duas cópias
        pc_gera_dados_inform(pr_nmarqdat    => vr_nmarqdat||'02.dat'
                            ,pr_tab_cratext => vr_tab_cratext_2
                            ,pr_nrarquiv    => 2   --> Arquivo nro 2
                            ,pr_flenvcop    => vr_flenvcop --> Flag de Envio de cópia
                            ,pr_dscritic    => vr_dscritic);
        -- Testar saída de erro
        IF vr_dscritic IS NOT NULL THEN
          -- Levantar exceção
          RAISE vr_exc_erro;
        END IF;
      END IF;

      -- Se existe 1º aviso aos avalistas
      IF vr_nrseq1av > 0 THEN
        -- Chamar o envio das 1ªs cartas aos avalistas através da rotina form0001.pc_gera_dados_inform
        pc_gera_dados_inform(pr_nmarqdat    => vr_nmarqdat||'03.dat'
                            ,pr_tab_cratext => vr_tab_cratext_3
                            ,pr_nrarquiv    => 3   --> Arquivo nro 3
                            ,pr_flenvcop    => 'N' --> Apenas 1 via
                            ,pr_dscritic    => vr_dscritic);
        -- Testar saída de erro
        IF vr_dscritic IS NOT NULL THEN
          -- Levantar exceção
          RAISE vr_exc_erro;
        END IF;
      END IF;

      -- Se existe 2º aviso aos avalistas
      IF vr_nrseq2av > 0 THEN
        -- Chamar o envio das 2ªs cartas aos avalistas e enviar em duas cópias
        pc_gera_dados_inform(pr_nmarqdat    => vr_nmarqdat||'04.dat'
                            ,pr_tab_cratext => vr_tab_cratext_4
                            ,pr_nrarquiv    => 4   --> Arquivo nro 4
                            ,pr_flenvcop    => vr_flenvcop --> Flag de Envio de cópia
                            ,pr_dscritic    => vr_dscritic);
        -- Testar saída de erro
        IF vr_dscritic IS NOT NULL THEN
          -- Levantar exceção
          RAISE vr_exc_erro;
        END IF;
      END IF;

      -- Se foram criados Avisos de Recebimento (AR)
      IF vr_nrseq0ar > 0 THEN
        -- Instanciar o CLOB com dados para a carta de AR
        dbms_lob.createtemporary(vr_clobarq, TRUE, dbms_lob.CALL);
        dbms_lob.open(vr_clobarq,dbms_lob.lob_readwrite);
        -- Buscar o primeiro registro da temp-table de ARs
        vr_chv_cartaAR := vr_tab_cartaAR.FIRST;
        -- Para cada registro da temp-table de AR
        LOOP
          -- Sair quando não encontrar mais indices
          EXIT WHEN vr_chv_cartaAR IS NULL;
          -- Se for o primeiro registro da cidade ou do vetor
          IF vr_chv_cartaAR = vr_tab_cartaAR.FIRST OR vr_tab_cartaAR(vr_chv_cartaAR).nomedcdd <> vr_tab_cartaAR(vr_tab_cartaAR.PRIOR(vr_chv_cartaAR)).nomedcdd THEN
            -- 9999999999 - utilizado na PostMix/Engecopy para separar as cartas
            IF vr_tab_cartaAR(vr_chv_cartaAR).nomedcdd = ' ' THEN
              -- Enviar quebra sem cidade
              pc_escreve_clob(vr_clobarq,'9999999999 CDD NAO CADASTRADO'||chr(13));
            ELSE
              -- Enviar quebra com o nome, cep e central
              pc_escreve_clob(vr_clobarq,'9999999999 '
                                       ||vr_tab_cartaAR(vr_chv_cartaAR).nomedcdd||' '
                                       ||vr_tab_cartaAR(vr_chv_cartaAR).nrcepcdd||' '
                                       ||vr_tab_cartaAR(vr_chv_cartaAR).dscentra||chr(13));
              -- Incrementar quantidade de documentos
              vr_qtdoctos := vr_qtdoctos + 1;
              -- Chamar rotina de criação da crapinf de cabeçalho
              form0001.pc_atualiza_crapinf(pr_cdcooper => pr_cdcooper
                                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                          ,pr_cdagenci => vr_tab_cartaAR(vr_chv_cartaAR).cdagenci
                                          ,pr_indespac => vr_tab_cartaAR(vr_chv_cartaAR).indespac
                                          ,pr_tpdocmto => 10 -- Emprestimos em Atraso
                                          ,pr_nrdconta => 0
                                          ,pr_des_erro => vr_dscritic);
              -- Testar saída de erro
              IF vr_dscritic IS NOT NULL THEN
                -- Gerar exceção
                RAISE vr_exc_erro;
              END IF;
            END IF;
          END IF;
          -- Envia o restante das informações ao arquivo
          pc_escreve_clob(vr_clobarq,vr_tab_cartaAR(vr_chv_cartaAR).dsdlinha(1)||chr(13)
                                   ||form0001.vr_imagemar||chr(13)
                                   ||vr_tab_cartaAR(vr_chv_cartaAR).dsdlinha(2)||chr(13)
                                   ||vr_tab_cartaAR(vr_chv_cartaAR).dsdlinha(3)||chr(13)
                                   ||vr_tab_cartaAR(vr_chv_cartaAR).dsdlinha(4)||chr(13)
                                   ||vr_tab_cartaAR(vr_chv_cartaAR).dsdlinha(5)||chr(13)
                                   ||vr_tab_cartaAR(vr_chv_cartaAR).dsdlinha(6)||chr(13)
                                   ||vr_tab_cartaAR(vr_chv_cartaAR).dsdlinha(7)||chr(13)
                                   ||vr_tab_cartaAR(vr_chv_cartaAR).dsdlinha(8)||chr(13)
                                   ||vr_tab_cartaAR(vr_chv_cartaAR).dsdlinha(9)||chr(13)
                                   ||vr_tab_cartaAR(vr_chv_cartaAR).dsdlinha(10)||chr(13)
                                   ||vr_tab_cartaAR(vr_chv_cartaAR).dsdlinha(11)||chr(13)
                                   ||vr_tab_cartaAR(vr_chv_cartaAR).dsdlinha(12)||chr(13)
                                   ||vr_tab_cartaAR(vr_chv_cartaAR).dsdlinha(13)||chr(13));
          -- Por fim, chamar rotina de criação da crapinf para cada documento
          form0001.pc_atualiza_crapinf(pr_cdcooper => pr_cdcooper
                                      ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                      ,pr_cdagenci => vr_tab_cartaAR(vr_chv_cartaAR).cdagenci
                                      ,pr_indespac => vr_tab_cartaAR(vr_chv_cartaAR).indespac
                                      ,pr_tpdocmto => 10 -- Emprestimos em Atraso
                                      ,pr_nrdconta => vr_tab_cartaAR(vr_chv_cartaAR).nrdconta
                                      ,pr_des_erro => vr_dscritic);
          -- Testar saída de erro
          IF vr_dscritic IS NOT NULL THEN
            -- Gerar exceção
            RAISE vr_exc_erro;
          END IF;
          -- Buscar o próximo registro
          vr_chv_cartaAR := vr_tab_cartaAR.NEXT(vr_chv_cartaAR);
        END LOOP;
        -- Enviar uma quebra de página no final do arquivo
        pc_escreve_clob(vr_clobarq,chr(12));
        -- Submeter a geração do arquivo txt puro
        gene0002.pc_solicita_relato_arquivo(pr_cdcooper  => pr_cdcooper                                  --> Cooperativa conectada
                                           ,pr_cdprogra  => vr_cdprogra                                  --> Programa chamador
                                           ,pr_dtmvtolt  => rw_crapdat.dtmvtolt                          --> Data do movimento atual
                                           ,pr_dsxml     => vr_clobarq                                   --> Arquivo XML de dados
                                           ,pr_cdrelato  => '359'                                        --> Código do relatório
                                           ,pr_dsarqsaid => vr_dsdireto||'/arq/'||vr_nmarqdat||'00.dat' --> Arquivo final com o path
                                           ,pr_flg_gerar => 'S'                                          --> Geraçao na hora
                                           ,pr_des_erro  => pr_dscritic);                                --> Saída com erro
        -- Liberando a memória alocada pro CLOB
        dbms_lob.close(vr_clobarq);
        dbms_lob.freetemporary(vr_clobarq);
        -- Testar se houve erro
        IF pr_dscritic IS NOT NULL THEN
          -- Gerar exceção
          RAISE vr_exc_erro;
        END IF;
      END IF;
      -- Testar se algum dos arquivos foi gerado
      IF vr_nrseq1dv + vr_nrseq2dv + vr_nrseq1av + vr_nrseq2av + vr_nrseq0ar > 0 THEN
        -- Efetuaremos a geração do relatório, portanto preparar o CLOB para o relatório 359
        dbms_lob.createtemporary(vr_clobrel, TRUE, dbms_lob.CALL);
        dbms_lob.open(vr_clobrel, dbms_lob.lob_readwrite);
        pc_escreve_clob(vr_clobrel,'<?xml version="1.0" encoding="utf-8"?><raiz>');
        -- Buscar o primeiro registro da pltable de relatórios
        vr_chv_rel359 := vr_tab_rel359.FIRST;
        LOOP
          -- Sair quando não encontrar mais indices
          EXIT WHEN vr_chv_rel359 IS NULL;
          -- Se for o primeiro registro ou mudou o tipo de carta
          IF vr_chv_rel359 = vr_tab_rel359.FIRST OR vr_tab_rel359(vr_chv_rel359).tpdcarta <> vr_tab_rel359(vr_tab_rel359.PRIOR(vr_chv_rel359)).tpdcarta THEN
            -- Inicializar a tag do tipo de carta
            pc_escreve_clob(vr_clobrel,'<tpdcarta id="'||vr_tab_rel359(vr_chv_rel359).tpdcarta||'" dstpcart="'||fn_dstpcart(vr_tab_rel359(vr_chv_rel359).tpdcarta)||'">');
          END IF;
          -- Enviar as cartas
          pc_escreve_clob(vr_clobrel,'<carta>'
                                   ||'  <pac>'||vr_tab_rel359(vr_chv_rel359).cdagenci||'</pac>'
                                   ||'  <nrdconta>'||gene0002.fn_mask_conta(vr_tab_rel359(vr_chv_rel359).nrdconta)||'</nrdconta>'
                                   ||'  <nrctremp>'||vr_tab_rel359(vr_chv_rel359).nrctremp||'</nrctremp>'
                                   ||'  <dsorigem>'||fn_dsorigem(vr_tab_rel359(vr_chv_rel359).tpctrato)||'</dsorigem>'
                                   ||'  <qtdiatra>'||gene0002.fn_mask(vr_tab_rel359(vr_chv_rel359).qtdiatra,'zzz9')||'</qtdiatra>'
                                   ||'  <vlsdeved>'||to_char(vr_tab_rel359(vr_chv_rel359).vlsdeved,'fm999g999g990d00')||'</vlsdeved>'
                                   ||'  <nomedes1>'||SUBSTR(vr_tab_rel359(vr_chv_rel359).nomedes1,1,40)||'</nomedes1>'
                                   ||'  <nrsequen>'||vr_tab_rel359(vr_chv_rel359).nrsequen||'</nrsequen>'
                                   ||'</carta>');
          -- Se for o ultimo registrou ou mudou o tipo de carta
          IF vr_chv_rel359 = vr_tab_rel359.LAST OR vr_tab_rel359(vr_chv_rel359).tpdcarta <> vr_tab_rel359(vr_tab_rel359.NEXT(vr_chv_rel359)).tpdcarta THEN
            -- Fechar a tag do tipo de carta
            pc_escreve_clob(vr_clobrel,'</tpdcarta>');
          END IF;
          -- Buscar o proximo registro
          vr_chv_rel359 := vr_tab_rel359.NEXT(vr_chv_rel359);
        END LOOP;
        -- Fechar a tag raiz
        pc_escreve_clob(vr_clobrel,'</raiz>');
        -- Chamar a geração do relatório
        gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                          --> Cooperativa conectada
                                   ,pr_cdprogra  => vr_cdprogra                          --> Programa chamador
                                   ,pr_dtmvtolt  => rw_crapdat.dtmvtolt                  --> Data do movimento atual
                                   ,pr_dsxml     => vr_clobrel                           --> Arquivo XML de dados
                                   ,pr_dsxmlnode => '/raiz/tpdcarta/carta'               --> Nó base do XML para leitura dos dados
                                   ,pr_dsjasper  => 'crrl359.jasper'                     --> Arquivo de layout do iReport
                                   ,pr_dsparams  => 'PR_DTENVIO##'||to_char(rw_crapdat.dtmvtopr,'dd/mm/yyyy') --> Sem parâmetros
                                   ,pr_dsarqsaid => vr_dsdireto||'/rl/crrl359.lst'     --> Arquivo final com o path
                                   ,pr_qtcoluna  => 132                                  --> 132 colunas
                                   ,pr_flg_gerar => 'N'                                  --> Geraçao na hora
                                   ,pr_flg_impri => 'S'                                  --> Chamar a impressão (Imprim.p)
                                   ,pr_nmformul  => ''                                   --> Nome do formulário para impressão
                                   ,pr_nrcopias  => 1                                    --> Número de cópias
                                   ,pr_sqcabrel  => 1                                    --> Qual a seq do cabrel
                                   ,pr_des_erro  => vr_dscritic);                        --> Saída com erro
        -- Liberando a memória alocada pro CLOB
        dbms_lob.close(vr_clobrel);
        dbms_lob.freetemporary(vr_clobrel);
        -- Testar se houve erro
        IF vr_dscritic IS NOT NULL THEN
          -- Gerar exceção
          RAISE vr_exc_erro;
        END IF;
      END IF;
      -- Se existe quantidade de documentos gerados com AR
      IF vr_qtdoctos > 0 THEN
        -- Atualizar tabela gncdimp pois o documento com ARs será enviado para Engecopy/Postmix
        form0001.pc_atualiza_gndcimp(pr_cdcooper => pr_cdcooper
                                    ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                    ,pr_nmarquiv => vr_nmarqdat||'00.dat'
                                    ,pr_numberdc => vr_qtdoctos
                                    ,pr_numerseq => vr_numerseq
                                    ,pr_dscritic => vr_dscritic);
        -- Se houve erro
        IF vr_dscritic IS NOT NULL THEN
          -- Gerar exceção
          RAISE vr_exc_erro;
        END IF;
        -- Prosseguimos com o processo de envio dos arquivos já gerados
        pc_envia_dados_inform(pr_nmarqdat => vr_nmarqdat||'00.dat'
                             ,pr_nrarquiv => 0   --> AR
                             ,pr_flenvcop => 'N' --> Apenas 1 cópia
                             ,pr_dscritic => vr_dscritic);
        -- Se houve erro
        IF vr_dscritic IS NOT NULL THEN
          -- Gerar exceção
          RAISE vr_exc_erro;
        END IF;
      END IF;

      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);
      -- Salvar informações atualizada
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
        -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
        btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_stprogra => pr_stprogra);
        -- Efetuar commit pois gravaremos o que foi processo até então
        COMMIT;

      WHEN vr_exc_erro THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Devolvemos código e critica encontradas
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
        -- Efetuar rollback
        ROLLBACK;

      WHEN OTHERS THEN
        -- Efetuar retorno do erro nao tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;

        -- Efetuar rollback
        ROLLBACK;
    END;
  END pc_crps399;
/

