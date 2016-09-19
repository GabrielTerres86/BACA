CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS037(pr_cdcooper  IN crapcop.cdcooper%TYPE  --> Cooperativa solicitada
                    ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                    ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                    ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                    ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada AS
BEGIN
  /* ..........................................................................

   Programa: PC_CRPS037    (Fontes/crps037.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Setembro/92.                        Ultima atualizacao: 22/11/2013

   Dados referentes ao programa:

   Frequencia: Mensal (Batch - Background).
   Objetivo  : Atende a solicitacao 004.
               Lista resumo das entradas e saidas no capital (36).

   Alteracoes: 05/07/94 - Retirado o literal "CR$".

               09/09/94 - Alterado valor da moeda para 8 casas decimais
                          (Deborah).

               17/03/95 - Alterado para verificar se for final de trimestre
                          imprimir as entradas e saidas em moedas.

               22/04/98 - Tratamento para milenio e troca para V8 (Margarete).

             05/10/2005 - Alterado para mostrar ao final do relatorio um Total
                          Geral por Pac's de Entradas e Saidas (Diego/Mirtes).

             14/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

             21/07/2008 - Inclusao do cdcooper no FIND craphis (Mirtes).

             19/10/2009 - Alteracao Codigo Historico (Kbase).

             08/03/2010 - Alteracao Historico (Gati)

             11/09/2013 - Conversao Progress >> Oracle PLSQL (Odirlei-AMcom)

             10/10/2013 - Ajuste para correto funcionamento da cadeia (Gabriel)

             22/11/2013 - Correção na chamada a vr_exc_fimprg, a mesma só deve
                          ser acionada em caso de saída para continuação da cadeia,
                          e não em caso de problemas na execução (Marcos-Supero)

............................................................................. */
  DECLARE
    -- Codigo do programa
    vr_cdprogra crapprg.cdprogra%TYPE;
    -- Tratamento de erros
   vr_exc_fimprg EXCEPTION;
   vr_exc_saida  EXCEPTION;

    /* Busca dos dados da cooperativa */
    CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
      SELECT cop.nmrescop
            ,cop.nrtelura
            ,cop.dsdircop
            ,cop.cdbcoctl
            ,cop.cdagectl
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    /* Cursor generico de calendario */
    RW_CRAPDAT BTCH0001.CR_CRAPDAT%ROWTYPE;

    --Leitura dos historicos de capital
    CURSOR cr_craphis(pr_cdcooper IN craptab.cdcooper%TYPE) IS
      SELECT cdhistor,
             inhistor
        FROM craphis h
       WHERE h.cdcooper = pr_cdcooper
         AND h.tplotmov IN (0,2,3);

    --Leitura Valor de cada moeda fixa usada pelo sistema.
    CURSOR cr_crapmfx (pr_cdcooper IN craptab.cdcooper%TYPE,
                       pr_dttrimes IN DATE) is
      SELECT vlmoefix,
             to_char(dtmvtolt,'DD') dia
        FROM crapmfx
       WHERE crapmfx.cdcooper = pr_cdcooper
         AND crapmfx.tpmoefix = 12
         AND TO_CHAR(crapmfx.dtmvtolt,'MM/RRRR') = TO_CHAR(pr_dttrimes,'MM/RRRR');


    -- Busca lotes do periodo
    CURSOR cr_craplot (pr_cdcooper IN craptab.cdcooper%TYPE,
                       pr_dttrimes IN DATE,
                       pr_dtmvtolt IN DATE )IS
      SELECT dtmvtolt,
             cdagenci,
             cdbccxlt,
             nrdolote
        FROM craplot
       WHERE craplot.cdcooper = pr_cdcooper
         AND craplot.dtmvtolt >= pr_dttrimes
         AND craplot.dtmvtolt <= pr_dtmvtolt
         AND craplot.tplotmov IN (2,3);

    --Busca lancamentos dos lotes
    CURSOR cr_craplct (pr_cdcooper IN craptab.cdcooper%TYPE,
                       pr_dtmvtolt IN craplot.dtmvtolt%TYPE,
                       pr_cdagenci IN craplot.cdagenci%TYPE,
                       pr_cdbccxlt IN craplot.cdbccxlt%TYPE,
                       pr_nrdolote IN craplot.nrdolote%TYPE)IS
      SELECT cdhistor,
             nrdconta,
             vllanmto,
             qtlanmfx
        FROM craplct
       WHERE craplct.cdcooper = pr_cdcooper
         AND craplct.dtmvtolt = pr_dtmvtolt
         AND craplct.cdagenci = pr_cdagenci
         AND craplct.cdbccxlt = pr_cdbccxlt
         AND craplct.nrdolote = pr_nrdolote;


    --Type para armazenar a tabela de cadastro de historicos de capital
    type typ_reg_his is record (cdhistor       craphis.cdhistor%type,
                                inhistor       craphis.inhistor%type
                                 );

    type typ_tab_reg_his is table of typ_reg_his
                           index by varchar2(5); --his(5)
    vr_tab_his typ_tab_reg_his;

    --Type para armazenar a valor moeda
    type typ_reg_mfx is record (vlmoefix       crapmfx.vlmoefix%type);

    type typ_tab_reg_mfx is table of typ_reg_mfx
                           index by BINARY_INTEGER; --dia(2)
    vr_tab_mfx typ_tab_reg_mfx;

    --Type para armazenar os dados por agencia para o relatorio
    type typ_reg_age is record (vlentrad number,
                                vlsaidas number,
                                cdagenci crapass.cdagenci%type
                                 );

    type typ_tab_reg_age is table of typ_reg_age
                           index by varchar2(3); --ag(3)
    vr_tab_age typ_tab_reg_age;

    --Type para armazenar a valores de entrada/saida por dia
    type typ_reg_val is record (vlentcrz number,
                                vlentmfx number,
                                vlsaicrz number,
                                vlsaimfx number);

    type typ_tab_reg_val is table of typ_reg_val
                           index by varchar2(2); --dia(2)
    vr_tab_val typ_tab_reg_val;

    --Variaveis de controle
    vr_dttrimes date;
    vr_exbmes   varchar2(1) := 'T';
    vr_cdagenci crapass.cdagenci%type;

    -- Variaveis de totalizador acumulado
    vr_totcrz   number := 0;
    vr_totmfx   number := 0;

    -- Variavel para armazenar as informacos em XML
    vr_des_xml       clob;
    vr_nom_direto    varchar2(100);
    vr_nom_arquivo   varchar2(100);

    -- Variavel para chaveamento (hash) da tabela de aplicac?es
    vr_des_chave    varchar2(3);
    vr_des_chmfx    number;

    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic varchar2(2000);

    FUNCTION pc_busca_agen_conta(pr_nrdconta IN crapass.nrdconta%type) return number is

      CURSOR cr_crapass IS
        SELECT ass.cdagenci
         FROM crapass ass
         where ass.progress_recid =
                           (SELECT MAX(ass1.progress_recid)
                            FROM crapass ass1
                            WHERE ass1.cdcooper = pr_cdcooper  AND
                                  ass1.nrdconta = pr_nrdconta);
      rw_crapass cr_crapass%rowtype;

    BEGIN
      -- buscar dados do associado
      OPEN cr_crapass;
      FETCH cr_crapass
       INTO rw_crapass;
      -- Se nao encontrar
      IF cr_crapass%NOTFOUND THEN
        CLOSE cr_crapass;
        return 0;
      ELSE
        CLOSE cr_crapass;
        return rw_crapass.cdagenci;
      END IF;

    END pc_busca_agen_conta;

    PROCEDURE pc_carrega_lancamento(pr_dtinici   IN date,
                                    pr_dtfinal   IN date
                                    ) IS
    BEGIN
      --Ler lotes do periodo
      FOR rw_craplot IN cr_craplot(pr_cdcooper => pr_cdcooper,
                                   pr_dttrimes => pr_dtinici,
                                   pr_dtmvtolt => pr_dtfinal) LOOP

        -- Ler lancamentos dos lotes
        FOR rw_craplct IN cr_craplct (pr_cdcooper => pr_cdcooper,
                                      pr_dtmvtolt => rw_craplot.dtmvtolt,
                                      pr_cdagenci => rw_craplot.cdagenci,
                                      pr_cdbccxlt => rw_craplot.cdbccxlt,
                                      pr_nrdolote => rw_craplot.nrdolote) LOOP

          vr_cdagenci := pc_busca_agen_conta(rw_craplct.nrdconta);
          vr_des_chave := lpad(vr_cdagenci,3,0);
          vr_tab_age(vr_des_chave).cdagenci := vr_cdagenci;

          -- Verificar se existe historico
          IF vr_tab_his.exists(rw_craplct.cdhistor) THEN
            --Verificar se deve armazenar valores de entrada
            IF vr_tab_his(rw_craplct.cdhistor).inhistor IN (6,7,8) THEN

              vr_tab_age(vr_des_chave).vlentrad := NVL(vr_tab_age(vr_des_chave).vlentrad,0) +
                                                  rw_craplct.vllanmto;

              --Armazenar valores no array
              IF  vr_tab_val.EXISTS(to_char(rw_craplot.dtmvtolt,'DD')) THEN
                vr_tab_val(to_char(rw_craplot.dtmvtolt,'DD')).vlentcrz := nvl(vr_tab_val(to_char(rw_craplot.dtmvtolt,'DD')).vlentcrz,0) +
                                                                     rw_craplct.vllanmto;
                vr_tab_val(to_char(rw_craplot.dtmvtolt,'DD')).vlentmfx := nvl(vr_tab_val(to_char(rw_craplot.dtmvtolt,'DD')).vlentmfx,0) +
                                                                    rw_craplct.qtlanmfx;
              ELSE
                -- caso id ainda nao existe, inicializa-lo com o valor
                vr_tab_val(to_char(rw_craplot.dtmvtolt,'DD')).vlentcrz := rw_craplct.vllanmto;
                vr_tab_val(to_char(rw_craplot.dtmvtolt,'DD')).vlentmfx := rw_craplct.qtlanmfx;

              END IF;
            --Verificar se deve armazenar valores de saida
            ELSIF vr_tab_his(rw_craplct.cdhistor).inhistor IN (16,17,18) THEN
              vr_tab_age(vr_des_chave).vlsaidas := NVL(vr_tab_age(vr_des_chave).vlsaidas,0) +
                                                  rw_craplct.vllanmto;

              --Armazenar valores no array
              IF  vr_tab_val.EXISTS(to_char(rw_craplot.dtmvtolt,'DD')) THEN
                vr_tab_val(to_char(rw_craplot.dtmvtolt,'DD')).vlsaicrz := nvl(vr_tab_val(to_char(rw_craplot.dtmvtolt,'DD')).vlsaicrz,0) +
                                                                     rw_craplct.vllanmto;
                vr_tab_val(to_char(rw_craplot.dtmvtolt,'DD')).vlsaimfx := nvl(vr_tab_val(to_char(rw_craplot.dtmvtolt,'DD')).vlsaimfx,0) +
                                                                    rw_craplct.qtlanmfx;
              ELSE
                -- caso id ainda nao existe, inicializa-lo com o valor
                vr_tab_val(to_char(rw_craplot.dtmvtolt,'DD')).vlsaicrz := rw_craplct.vllanmto;
                vr_tab_val(to_char(rw_craplot.dtmvtolt,'DD')).vlsaimfx := rw_craplct.qtlanmfx;
              END IF;

            END IF;

          END IF;--vr_tab_his.exists
        END LOOP;/* Fim do FOR - Leitura lancamentos de capital */

      END LOOP; /* Fim do FOR - Leitura dos lotes de capital */

    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao carregar lancamentos: '||SQLerrm;
        raise vr_exc_saida;
    END pc_carrega_lancamento;

    --Escrever no arquivo CLOB
    PROCEDURE pc_escreve_xml(pr_des_dados IN CLOB) IS
    BEGIN
      --Escrever no arquivo XML
      vr_des_xml := vr_des_xml||pr_des_dados;
    END;

    PROCEDURE pc_monta_xml (pr_tipo IN varchar2)is
    BEGIN
      --Gerar apenas o grupo de tag dos totalizadores por agencia
      IF pr_tipo = 'T' THEN
        -- Gerar xml para o total
        IF vr_tab_age.COUNT > 0 THEN

          vr_des_chave := vr_tab_age.FIRST;
          pc_escreve_xml('<totger>');

          vr_totcrz := 0;
          LOOP
            -- Sair quando a chave atual for null (chegou no final)
            exit when vr_des_chave is null;

            vr_totcrz := vr_totcrz + nvl(vr_tab_age(vr_des_chave).vlentrad,0) - nvl(vr_tab_age(vr_des_chave).vlsaidas,0);

            pc_escreve_xml('<totdet>
                               <cdagenci>'||vr_tab_age(vr_des_chave).cdagenci||'</cdagenci>
                               <vlentrad>'||nvl(vr_tab_age(vr_des_chave).vlentrad,0)||'</vlentrad>
                               <vlsaidas>'||nvl(vr_tab_age(vr_des_chave).vlsaidas,0)||'</vlsaidas>
                               <vltotage>'||vr_totcrz||'</vltotage>
                             </totdet>');

            vr_des_chave := vr_tab_age.NEXT(vr_des_chave);
          END LOOP;

          pc_escreve_xml('</totger>');

        END IF;
      ELSE

        IF vr_tab_val.COUNT > 0 THEN

          vr_des_chave := vr_tab_val.FIRST;
          pc_escreve_xml('<mesref mes="'||gene0001.vr_vet_nmmesano(to_char(vr_dttrimes,'MM'))||'/'||to_char(vr_dttrimes,'RRRR')||'">');

          --Gerar xml para o mfx
          IF vr_tab_mfx.COUNT > 0 THEN

            vr_des_chmfx := vr_tab_mfx.FIRST;
            pc_escreve_xml('<tabmfx>');

            LOOP
              -- Sair quando a chave atual for null (chegou no final)
              exit when vr_des_chmfx is null;

              --Montar xml com 5 em 5 registros para exibir relatorio com orientacao horizontal
              pc_escreve_xml('<mfxdet>
                                 <desdia1>'||vr_des_chmfx||'</desdia1>
                                 <vlmoefix1>'||vr_tab_mfx(vr_des_chmfx).vlmoefix||'</vlmoefix1>');

              IF vr_tab_mfx.EXISTS(vr_des_chmfx+1) THEN
                pc_escreve_xml('<desdia2>'||(vr_des_chmfx+1)||'</desdia2>');
                pc_escreve_xml('<vlmoefix2>'||vr_tab_mfx(vr_des_chmfx+1).vlmoefix||'</vlmoefix2>');
              ELSE
                pc_escreve_xml('<desdia2></desdia2>
                                <vlmoefix2></vlmoefix2>');
              END IF;

              IF vr_tab_mfx.EXISTS(vr_des_chmfx+2) THEN
                pc_escreve_xml('<desdia3>'||(vr_des_chmfx+2)||'</desdia3>
                                <vlmoefix3>'||vr_tab_mfx(vr_des_chmfx+2).vlmoefix||'</vlmoefix3>');
              ELSE
                pc_escreve_xml('<desdia3></desdia3>
                                <vlmoefix3></vlmoefix3>');
              END IF;

              IF vr_tab_mfx.EXISTS(vr_des_chmfx+3) THEN
                pc_escreve_xml('<desdia4>'||(vr_des_chmfx+3)||'</desdia4>
                                <vlmoefix4>'||vr_tab_mfx(vr_des_chmfx+3).vlmoefix||'</vlmoefix4>');
              ELSE
                pc_escreve_xml('<desdia4></desdia4>
                                <vlmoefix4></vlmoefix4>');
              END IF;

              IF vr_tab_mfx.EXISTS(vr_des_chmfx+4) THEN
                pc_escreve_xml('<desdia5>'||(vr_des_chmfx+4)||'</desdia5>
                                <vlmoefix5>'||vr_tab_mfx(vr_des_chmfx+4).vlmoefix||'</vlmoefix5>');
              ELSE
                pc_escreve_xml('<desdia5></desdia5>
                                <vlmoefix5></vlmoefix5>');
              END IF;

              pc_escreve_xml('</mfxdet>');

              vr_des_chmfx := vr_tab_mfx.NEXT(vr_des_chmfx+4);
            END LOOP;

            pc_escreve_xml('</tabmfx>');

          END IF;

          pc_escreve_xml('<resumo>');
          vr_totcrz := 0;
          vr_totmfx  := 0;

          -- Gerar grupo de tags do resumo por dia
          LOOP
            -- Sair quando a chave atual for null (chegou no final)
            exit when vr_des_chave is null;

            vr_totcrz := vr_totcrz + vr_tab_val(vr_des_chave).vlentcrz - vr_tab_val(vr_des_chave).vlsaicrz;
            vr_totmfx := vr_totmfx + vr_tab_val(vr_des_chave).vlentmfx - vr_tab_val(vr_des_chave).vlsaimfx;

            pc_escreve_xml('<resdia>
                               <desdia>'||vr_des_chave||'</desdia>
                               <vlentcrz>'||vr_tab_val(vr_des_chave).vlentcrz||'</vlentcrz>
                               <vlsaicrz>'||vr_tab_val(vr_des_chave).vlsaicrz||'</vlsaicrz>
                               <vrtotcrz>'||vr_totcrz||'</vrtotcrz>
                               <vlentmfx>'||vr_tab_val(vr_des_chave).vlentmfx||'</vlentmfx>
                               <vlsaimfx>'||vr_tab_val(vr_des_chave).vlsaimfx||'</vlsaimfx>
                               <vrtotmfx>'||vr_totmfx||'</vrtotmfx>
                             </resdia>');

            vr_des_chave := vr_tab_val.NEXT(vr_des_chave);
          END LOOP;
          pc_escreve_xml('</resumo>');

          pc_escreve_xml('</mesref>');

        END IF;
      END IF;

    END;

  BEGIN
    -- Codigo do programa
    vr_cdprogra := 'CRPS037';
    -- Incluir nome do modulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS037'
                              ,pr_action => null);
    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop
     INTO rw_crapcop;
    -- Se nao encontrar
    IF cr_crapcop%NOTFOUND THEN
      -- Fechar o cursor pois havera raise
      CLOSE cr_crapcop;
      -- Montar mensagem de critica
      vr_cdcritic := 651;
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crapcop;
    END IF;
    -- Leitura do calendario da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat
     INTO rw_crapdat;
    -- Se nao encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois efetuaremos raise
      CLOSE btch0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic := 1;
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;
    -- Validacoes iniciais do programa
    BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                             ,pr_flgbatch => 1
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_cdcritic => vr_cdcritic);
    -- Se a variavel de erro e <> 0
    IF vr_cdcritic <> 0 THEN
      -- Envio centralizado de log de erro
      RAISE vr_exc_saida;
    END IF;

    -- Carregar cadastro de historicos de capital
    FOR rw_craphis IN cr_craphis(pr_cdcooper => pr_cdcooper)LOOP
      vr_tab_his(rw_craphis.cdhistor).cdhistor := rw_craphis.cdhistor;
      vr_tab_his(rw_craphis.cdhistor).inhistor := rw_craphis.inhistor;
    END LOOP;

    -- Inicializar o CLOB
    dbms_lob.createtemporary(vr_des_xml, true);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

    IF to_char(rw_crapdat.dtmvtolt,'MM') in ('03','06','09','12') THEN

      vr_dttrimes := ADD_MONTHS( TO_DATE(TO_CHAR(rw_crapdat.dtmvtolt,'MM/RRRR'),'MM/RRRR'), -2);

      LOOP
        EXIT WHEN vr_dttrimes > rw_crapdat.dtmvtolt;

        -- carregar valor da moeda do periodo
        FOR rw_crapmfx IN cr_crapmfx(pr_cdcooper => pr_cdcooper,
                                     pr_dttrimes => vr_dttrimes) LOOP
          IF NVL(rw_crapmfx.vlmoefix,0) = 0 THEN
            continue;
          END IF;
          vr_tab_mfx(rw_crapmfx.dia).vlmoefix := rw_crapmfx.vlmoefix;
        END LOOP;

        pc_carrega_lancamento(pr_dtinici => vr_dttrimes,
                              pr_dtfinal => LAST_DAY(vr_dttrimes));

        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;

        -- Montar xml com os registros
        pc_monta_xml (pr_tipo => 'R');

        --limpar array que ja foi gerado no xml
        vr_tab_mfx.delete;
        vr_tab_val.delete;

        vr_dttrimes := ADD_MONTHS(vr_dttrimes,1);

      END LOOP;  /*  FIM DO DO LOOP vr_dttrimes < dtmvtolt */

      -- Montar xml com os totais
      pc_monta_xml (pr_tipo => 'T');
      vr_exbmes := 'T';-- Exibir formato trimestral

    ELSE --Se nao forem os meses 03,06,09,12

      vr_dttrimes := TO_DATE(TO_CHAR(rw_crapdat.dtmvtolt,'MM/RRRR'),'MM/RRRR');
      pc_carrega_lancamento(pr_dtinici  => vr_dttrimes,
                            pr_dtfinal  => rw_crapdat.dtmvtolt);

      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Montar xml com os registros
      pc_monta_xml (pr_tipo => 'R');
      -- Montar xml com os totais
      pc_monta_xml (pr_tipo => 'T');
      vr_exbmes := 'M';--Exibir formato Mes

    END IF;

    IF vr_des_xml IS NOT NULL THEN
      -- Busca do diretorio base da cooperativa
      vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl

      vr_nom_arquivo:= 'crrl036';
      vr_des_xml    := '<?xml version="1.0" encoding="utf-8"?><crrl036 exbmes="'||vr_exbmes||'">'||vr_des_xml||'</crrl036>';

      -- Solicitar impressao de todas as agencias
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                 ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                 ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/crrl036'          --> No base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl036.jasper'    --> Arquivo de layout do iReport
                                 ,pr_dsparams  => null                --> Enviar como parametro apenas a agencia
                                 ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nom_arquivo||'.lst' --> Arquivo final com codigo da agencia
                                 ,pr_qtcoluna  => 132                 --> 132 colunas
                                 ,pr_flg_impri => 'S'                 --> Chamar a impress?o (Imprim.p)
                                 ,pr_nmformul  => '132dh'             --> Nome do formulario para impress?o
                                 ,pr_nrcopias  => 1                   --> Numero de copias
                                 ,pr_des_erro  => vr_dscritic);       --> Saida com erro

      IF vr_dscritic IS NOT NULL THEN
        -- Gerar excecao
        raise vr_exc_saida;
      END IF;
    END IF;

    -- Processo OK, devemos chamar a fimprg
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);
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
    WHEN vr_exc_saida THEN
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
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
      -- Efetuar rollback
      ROLLBACK;
    END;
END;
/

