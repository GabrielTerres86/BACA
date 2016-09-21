CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS441(pr_cdcooper  IN craptab.cdcooper%TYPE
                                      ,pr_flgresta  IN PLS_INTEGER            --> Indicador para utilização de restart
                                      ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                      ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                      ,pr_dscritic OUT VARCHAR2)  IS
/* ............................................................................

   Programa: PC_CRPS441         Antigo  : Fontes/crps441.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Maio/2005                        Ultima atualizacao: 09/01/2014

   Dados referentes ao programa:

   Frequencia: Diario (Batch). "Paralelo"
   Objetivo  : Fechamento dos seguros, tipo = 11.
               Atende a solicitacao 02, ordem 9, emite relatorio 418.

   Observacao: Embora paralelo este programa faz atualizacao do campo
               crapseg.indebito. Portanto existe uma transacao.

   Alteracoes: 18/08/2005 - Implementado o total geral para o relatorio (Julio)

               31/08/2005 - Alterar destinatario do e-mail do Jean para a
                            Janeide (Julio)

               13/12/2005 - Alterado o programa para rodar diariamente, antes
                            era quinzenal (Julio)

               10/01/2006 - Correcao da atualizacao do indicador de pagamento
                            e melhorias gerais no programa (Julio)

               17/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre

               03/04/2006 - Acerto na atualizacao do indicador de debito
                            (Julio).

               16/06/2006 - Alteracao no calculo da data inicial para
                            relacionar os seguros. Alterar situacao dos
                            seguros que estiverem em fim de vigencia (Julio)

               12/07/2006 - Alteracoes na totalizacao das prestacoes pagas
                            e atualizacao do indicador de pagamento (Julio)

               06/08/2007 - Incluido envio de email para:
                            rene.bnu@addmakler.com.br (Guilherme).

               04/09/2007 - Verificar atraves do craplcm se a prestacao do
                            seguro foi paga no periodo em questao (Julio)

               25/03/2008 - Alterado envio de email para BO b1wgen0011
                            (Sidnei - Precise)

               09/04/2008 - Alteragco do campo "crapseg.qtprepag", de "99" para
                            "zz9" - Kbase it Solutions - Eduardo.

               28/01/2009 - Enviar email somente p/ aylloscecred@addmakler.com
                            .br (Gabriel).

               25/02/2010 - Incluido coluna "PAC ASS" no relatorio (Elton).

               05/07/2011 - Enviar e-mail para jeicy@cecred.coop.br (Henrique)

               20/09/2011 - Retirado seguros endossado inclusao dos seguros
                            renovados. (Lauro)

               02/02/2012 - Modificada extensao do arquivo crrl418 somente
                            para envio de e-mail (Diego).

               22/05/2012 - Alterado busca na crapseg para nao trazer seguros
                            com a data de contratraçao igual a data de
                            cancelamento (Guilherme Maba).

              04/03/2013 - Substituido e-mail jeicy@cecred.coop.br por
                           cecredseguros@cecred.coop.br (Daniele).

              05/09/2013 - Conversão Progress >> Oracle PL/SQL (Renato - Supero).

              08/01/2014 - Remoção de chamada duplicada a geração de relatorio
                          ja que agora é possivel passar qual a extensão da
                          copia ou e-mail, e ainda não, o que gerava a necessidade
                          de duas chamadas (Marcos-Supero)
                          
              23/05/2014 - Ajustado para converter o relatorio(ux2dos) antes de 
                           envia-lo por e-mail(Odirlei-AMcom)             

............................................................................. */

  -- CURSORES
  -- Buscar informações da cooperativa
  CURSOR cr_crapcop IS
    SELECT crapcop.dsdircop
         , LPAD(crapcop.cdbcoctl,3,0) cdbcoctl
         , crapcop.cdagectl
         , crapcop.nmrescop
      FROM crapcop
     WHERE crapcop.cdcooper = pr_cdcooper;

  -- Buscar os dados dos planos de seguros
  CURSOR cr_craptsg(pr_ddmvtolt   NUMBER
                   ,pr_ddmvtoan   NUMBER
                   ,pr_ddmvtopr   NUMBER) IS
    SELECT DISTINCT
           craptsg.cdsegura
         , craptsg.dddcorte  -- Contem o dia do corte da seguradora
      FROM craptsg
     WHERE craptsg.cdcooper  = pr_cdcooper
       AND craptsg.tpseguro  = 11 -- fixo
       AND craptsg.cdsitpsg  = 1  -- Codigo da situacao do plano (1-ativo, 2-inativo).
       AND ((pr_ddmvtoan      <  pr_ddmvtolt
         AND craptsg.dddcorte >  pr_ddmvtoan
         AND craptsg.dddcorte <= pr_ddmvtolt)                  
        OR (pr_ddmvtolt       >  pr_ddmvtopr
         AND craptsg.dddcorte >= pr_ddmvtolt));

  -- Buscar a corretora
  CURSOR cr_crapcsg(pr_cdsegura  crapcsg.cdsegura%TYPE) IS
    SELECT crapcsg.cdhstcas##2  cdhstcas2
         , crapcsg.cdhstcas##3  cdhstcas3
         , crapcsg.nmsegura
      FROM crapcsg
     WHERE crapcsg.cdcooper = pr_cdcooper
       AND crapcsg.cdsegura = pr_cdsegura;

  -- Buscar os seguros da operadora
  CURSOR cr_crapseg(pr_cdsegura  IN NUMBER) IS
    SELECT crapseg.rowid    crapseg_rowid
         , crapseg.tpseguro
         , crapseg.cdsegura
         , CRAPSEG.cdsitseg
         , crapseg.cdagenci
         , crapseg.nrdconta
         , crapseg.nrctrseg
         , crapseg.dtinivig
         , crapseg.dtfimvig
         , crapseg.dtcancel
         , crapseg.vlpreseg
         , crapseg.dtmvtolt
         , crapseg.qtprepag
         , crapseg.dtprideb
         , crapseg.qtparcel
         , crapseg.tpplaseg
         , crapseg.progress_recid
      FROM crapseg
     WHERE crapseg.cdcooper  = pr_cdcooper
       AND crapseg.cdsegura  = pr_cdsegura
       AND NVL(crapseg.dtcancel,TO_DATE('01/01/1900','DD/MM/YYYY')) <> crapseg.dtmvtolt
       AND crapseg.tpseguro  = 11
       AND crapseg.cdsitseg  < 4
     ORDER BY crapseg.progress_recid;

  -- Somar os lançamentos
  CURSOR cr_sum_craplcm(pr_nrdconta    craplcm.nrdconta%TYPE
                       ,pr_nrctrseg    craplcm.nrdocmto%TYPE
                       ,pr_cdhstcas2   craplcm.cdhistor%TYPE
                       ,pr_cdhstcas3   craplcm.cdhistor%TYPE
                       ,pr_dtiniaux    craplcm.dtmvtolt%TYPE
                       ,pr_dtmvtolt    craplcm.dtmvtolt%TYPE ) IS
    SELECT SUM( DECODE(craplcm.cdhistor, pr_cdhstcas2, craplcm.vllanmto
                                       , pr_cdhstcas3, (craplcm.vllanmto * -1) ))
      FROM craplcm
     WHERE craplcm.cdcooper  = pr_cdcooper
       AND craplcm.nrdconta  = pr_nrdconta
       AND craplcm.nrdocmto  = pr_nrctrseg
       AND craplcm.cdhistor IN (pr_cdhstcas2,pr_cdhstcas3)
       AND craplcm.dtmvtolt  > pr_dtiniaux
       AND craplcm.dtmvtolt <= pr_dtmvtolt;

  -- REGISTROS
  rw_crapcop      cr_crapcop%ROWTYPE;
  rw_crapcsg      cr_crapcsg%ROWTYPE;

  -- TIPOS
  TYPE rec_seguro  IS RECORD(tpseguro     crapseg.tpseguro%TYPE
                            ,cdsegura     crapseg.cdsegura%TYPE
                            ,nmsegura     crapcsg.nmsegura%TYPE
                            ,cdagenci     crapseg.cdagenci%TYPE
                            ,nrdconta     crapseg.nrdconta%TYPE
                            ,nrctrseg     crapseg.nrctrseg%TYPE
                            ,cdhistor     craphis.cdhistor%TYPE
                            ,cdhisest     craphis.cdhistor%TYPE
                            ,cdsitseg     crapseg.cdsitseg%TYPE
                            ,qtparcel     crapseg.qtparcel%TYPE
                            ,qtprepag     crapseg.qtprepag%TYPE
                            ,tpplaseg     crapseg.tpplaseg%TYPE
                            ,vlpreseg     crapseg.vlpreseg%TYPE
                            ,dtinivig     crapseg.dtinivig%TYPE
                            ,dtfimvig     crapseg.dtfimvig%TYPE
                            ,dtcancel     crapseg.dtcancel%TYPE
                            ,flgpagto     BOOLEAN
                            ,flgtotal     BOOLEAN);

  TYPE typ_seguro  IS TABLE OF rec_seguro INDEX BY VARCHAR2(100);

  -- VARIÁVEIS
  -- Código do programa
  vr_cdprogra      CONSTANT VARCHAR2(10) := 'CRPS441';
  -- Data do movimento
  vr_dtmvtolt      crapdat.dtmvtolt%TYPE;
  vr_dtmvtoan      crapdat.dtmvtoan%TYPE;
  vr_dtmvtopr      crapdat.dtmvtopr%TYPE;
  -- Guardar o dia do movimento
  vr_ddmvtolt      NUMBER;
  vr_ddmvtoan      NUMBER;
  vr_ddmvtopr      NUMBER;
  -- Data de início da verificação
  vr_dtiniaux      DATE;
  -- Dados dos seguros
  vr_tbseguro      typ_seguro;
  vr_inseguro      VARCHAR2(100);
  vr_insegord      VARCHAR2(100);
  -- Valor pago no mês
  vr_vlpagmes      NUMBER;
  -- Variáveis para geração do relatório
  vr_cdageass      crapass.cdagenci%TYPE;
  vr_nmprimtl      crapass.nmprimtl%TYPE;

  vr_nom_direto    VARCHAR2(200);

  -- Descrição da data de referencia
  vr_dsrefere      VARCHAR2(20);

  -- Variável de erros

  -- Tratamento de erros
  vr_exc_erro      EXCEPTION;

BEGIN

  -- Validações iniciais do programa
  btch0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                           ,pr_flgbatch => 1
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_cdcritic => pr_cdcritic);

  -- Se retornou algum erro
  IF pr_cdcritic <> 0 THEN
    -- Buscar descricão do erro
    pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
    -- Envio centralizado de log de erro
    RAISE vr_exc_erro;
  END IF;

  -- Incluir nome do modulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_CRPS441',
                             pr_action => vr_cdprogra);

  -- Buscar os dados da cooperativa
  OPEN  cr_crapcop;
  FETCH cr_crapcop INTO rw_crapcop;

  -- Se não encontrar registros
  IF cr_crapcop%NOTFOUND THEN
    pr_cdcritic := 651;
    pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
    CLOSE cr_crapcop;
    RAISE vr_exc_erro;
  END IF;

  CLOSE cr_crapcop;

  -- Buscar as datas do movimento
  OPEN  btch0001.cr_crapdat(pr_cdcooper);
  FETCH btch0001.cr_crapdat INTO btch0001.rw_crapdat;

  -- Se não encontrar o registro de movimento
  IF btch0001.cr_crapdat%NOTFOUND THEN
    -- 001 - Sistema sem data de movimento.
    pr_cdcritic := 1;
    -- Buscar descricão do erro
    pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);

    CLOSE btch0001.cr_crapdat;

    -- Envio centralizado de log de erro
    RAISE vr_exc_erro;
  ELSE
    -- Atualizar as variáveis
    vr_dtmvtolt := btch0001.rw_crapdat.dtmvtolt;
    vr_dtmvtoan := btch0001.rw_crapdat.dtmvtoan;
    vr_dtmvtopr := btch0001.rw_crapdat.dtmvtopr;
  END IF;

  CLOSE btch0001.cr_crapdat;

  -- Extrai os dias das datas de movimento
  vr_ddmvtolt := TO_NUMBER(TO_CHAR(vr_dtmvtolt,'DD'));
  vr_ddmvtoan := TO_NUMBER(TO_CHAR(vr_dtmvtoan,'DD'));
  vr_ddmvtopr := TO_NUMBER(TO_CHAR(vr_dtmvtopr,'DD'));

  -- Percorrer os registros das seguradoras
  FOR rw_craptsg IN cr_craptsg(vr_ddmvtolt,vr_ddmvtoan,vr_ddmvtopr) LOOP

    -- Buscar o registro da seguradora
    OPEN  cr_crapcsg(rw_craptsg.cdsegura);
    FETCH cr_crapcsg INTO rw_crapcsg;

    -- Verifica se encontroup registros
    IF cr_crapcsg%NOTFOUND THEN
      pr_cdcritic := 556; -- 556 - Seguradora nao cadastrada.
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||  ' - SEGURADORA = ' ||
                                       gene0002.fn_mask(rw_craptsg.cdsegura,'zzz,zzz,zz9');
      -- Gerar o Log
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                               pr_ind_tipo_log => 2, -- Erro tratado
                               pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                  || vr_cdprogra || ' --> '
                                                  || pr_dscritic);

      -- Fecha o cursor e vai para o próximo registro
      CLOSE  cr_crapcsg;
      CONTINUE;
    END IF;

    -- Se o cursor estiver aberto
    IF cr_crapcsg%ISOPEN THEN
      CLOSE cr_crapcsg;
    END IF;

    -- Busca do diretório base da cooperativa para a geração de relatórios
    vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                          ,pr_cdcooper => pr_cdcooper);

    -- Utilizar a data de corte com base no dia e na data anterior
    BEGIN
      vr_dtiniaux := TO_DATE(TO_CHAR(rw_craptsg.dddcorte,'FM00')||TO_CHAR(vr_dtmvtoan,'MMYYYY'),'DDMMYYYY');
    EXCEPTION
      WHEN OTHERS THEN
        vr_dtiniaux := LAST_DAY(vr_dtmvtoan);
    END;

    -- Retorna a data de corte em um mês a partir
    vr_dtiniaux := LAST_DAY( ADD_MONTHS(vr_dtiniaux, -1));

    -- Ler os seguros da corretora
    FOR rw_crapseg IN cr_crapseg(rw_craptsg.cdsegura) LOOP

      -- define o índice padrão para formar o registro
      vr_inseguro := 'X';

      -- Guardar os dados no registro para o relatório
      vr_tbseguro(vr_inseguro).tpseguro := rw_crapseg.tpseguro;
      vr_tbseguro(vr_inseguro).cdsegura := rw_crapseg.cdsegura;
      vr_tbseguro(vr_inseguro).nmsegura := rw_crapcsg.nmsegura;
      vr_tbseguro(vr_inseguro).cdagenci := rw_crapseg.cdagenci;
      vr_tbseguro(vr_inseguro).nrdconta := rw_crapseg.nrdconta;
      vr_tbseguro(vr_inseguro).nrctrseg := rw_crapseg.nrctrseg;
      vr_tbseguro(vr_inseguro).cdhistor := rw_crapcsg.cdhstcas2;
      vr_tbseguro(vr_inseguro).cdhisest := rw_crapcsg.cdhstcas3;
      vr_tbseguro(vr_inseguro).cdsitseg := rw_crapseg.cdsitseg;
      vr_tbseguro(vr_inseguro).qtparcel := rw_crapseg.qtparcel;
      vr_tbseguro(vr_inseguro).qtprepag := rw_crapseg.qtprepag;
      vr_tbseguro(vr_inseguro).tpplaseg := rw_crapseg.tpplaseg;
      vr_tbseguro(vr_inseguro).vlpreseg := rw_crapseg.vlpreseg;
      vr_tbseguro(vr_inseguro).dtinivig := rw_crapseg.dtinivig;
      vr_tbseguro(vr_inseguro).dtfimvig := rw_crapseg.dtfimvig;
      vr_tbseguro(vr_inseguro).dtcancel := rw_crapseg.dtcancel;
      vr_tbseguro(vr_inseguro).flgpagto := NULL;
      vr_tbseguro(vr_inseguro).flgtotal := NULL;

      -- Inicializa a variáveL de calculo
      vr_vlpagmes := 0;

      -- Soma os valores pagos
      OPEN  cr_sum_craplcm(rw_crapseg.nrdconta
                          ,rw_crapseg.nrctrseg
                          ,rw_crapcsg.cdhstcas2
                          ,rw_crapcsg.cdhstcas3
                          ,vr_dtiniaux
                          ,vr_dtmvtolt);
      FETCH cr_sum_craplcm INTO vr_vlpagmes;
      CLOSE cr_sum_craplcm;


      -- Verifica se o valor pago é maior ou igual ao valor do seguro
      vr_tbseguro(vr_inseguro).flgpagto := (NVL(vr_vlpagmes,0) >= rw_crapseg.vlpreseg);
      vr_tbseguro(vr_inseguro).flgtotal := vr_tbseguro(vr_inseguro).flgpagto;

      -- Avalia a situação dos seguros
      -- Se situação é igual a 3 e data de movimento está no periodo indicado
      IF rw_crapseg.cdsitseg = 3             AND
         rw_crapseg.dtmvtolt >  vr_dtiniaux  AND
         rw_crapseg.dtmvtolt <= vr_dtmvtolt  THEN

        -- Seguro RENOVADO
        vr_tbseguro(vr_inseguro).cdsitseg := 3;

      -- Se a data de cancelamento é nula e data de movimento está no periodo indicado
      ELSIF rw_crapseg.dtmvtolt >  vr_dtiniaux  AND
            rw_crapseg.dtmvtolt <= vr_dtmvtolt  AND
            rw_crapseg.dtcancel IS NULL        THEN

        -- Se nenhuma prestação foi paga no período
        IF rw_crapseg.qtprepag   = 0  OR
            (rw_crapseg.qtprepag = 1             AND
             rw_crapseg.dtprideb > vr_dtiniaux   AND
             rw_crapseg.dtprideb <= vr_dtmvtolt) THEN

          -- Seguro NOVO
          vr_tbseguro(vr_inseguro).cdsitseg := 1;

        END IF;

      -- Se a data de cancelamento está no período
      ELSIF rw_crapseg.dtcancel >  vr_dtiniaux  AND
            rw_crapseg.dtcancel <= vr_dtmvtolt  THEN

        -- Seguro CANCELADO
        vr_tbseguro(vr_inseguro).cdsitseg := 2;

      -- Verifica o flag de pagamento
      ELSIF vr_tbseguro(vr_inseguro).flgpagto THEN

        -- Seguro EFETIVO
        vr_tbseguro(vr_inseguro).cdsitseg := 4;

      ELSE

        -- Retira o registro da memória
        vr_tbseguro.DELETE(vr_inseguro);

      END IF;

      -- Se a não excluiu o registro
      IF vr_tbseguro.EXISTS(vr_inseguro) THEN
        -- define o índice de forma ordenada para o relatório
        vr_insegord := LPAD(rw_crapseg.tpseguro              , 5,'0')||
                       LPAD(rw_crapseg.cdsegura              ,10,'0')||
                       LPAD(vr_tbseguro(vr_inseguro).cdsitseg, 5,'0')||
                       LPAD(rw_crapseg.cdagenci              , 5,'0')||
                       LPAD(rw_crapseg.nrdconta              ,10,'0')||
                       LPAD(vr_tbseguro(vr_inseguro).nrctrseg,10,'0');

        -- Copia o registro para a posição correta
        vr_tbseguro(vr_insegord) := vr_tbseguro(vr_inseguro);

        -- Exclui o registro auxiliar de indice X
        vr_tbseguro.DELETE(vr_inseguro);

        -- Atualiza o indice
        vr_inseguro := vr_insegord;

        -- Se a situação for igual a 2 e estiver flegado para true
        IF vr_tbseguro(vr_insegord).cdsitseg = 2 AND vr_tbseguro(vr_insegord).flgpagto THEN
          vr_tbseguro(vr_insegord).flgpagto := TRUE;
        ELSE
          vr_tbseguro(vr_insegord).flgpagto := FALSE;
        END IF;
      END IF;

      -- Atualiza o indicador de debito se nao tiver pago todas as prestações
      IF rw_crapseg.qtprepag < rw_crapseg.qtparcel   AND
         rw_crapseg.cdsitseg <> 2                    THEN
        -- ASSIGN crapseg.indebito = 0
        BEGIN
          -- atualizar o indicador de débito do seguro
          UPDATE crapseg
             SET crapseg.indebito = 0
           WHERE crapseg.rowid    = rw_crapseg.crapseg_rowid;
        EXCEPTION
          WHEN OTHERS THEN
            -- Buscar descricão do erro
            pr_dscritic := 'Erro ao atualizar CRAPSEG.INDEBITO: '||SQLERRM;
            -- Envio centralizado de log de erro
            RAISE vr_exc_erro;
        END;
      END IF;

      -- Atualiza situacao do seguro se for fim de vigencia
      IF rw_crapseg.cdsitseg <> 2      AND
         TRUNC(rw_crapseg.dtfimvig,'MM') = TRUNC(vr_dtmvtolt,'MM') THEN
        -- Seguro VENCIDO
        -- ASSIGN crapseg.cdsitseg = 4;
        BEGIN
          -- atualizar a situação para afetivo
          UPDATE crapseg
             SET crapseg.cdsitseg = 4
           WHERE crapseg.rowid    = rw_crapseg.crapseg_rowid;
          --
          -- Se o registro ainda está na memória atualiza
          IF vr_tbseguro.EXISTS(vr_inseguro) THEN
            vr_tbseguro(vr_inseguro).cdsitseg := 4;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            -- Buscar descricão do erro
            pr_dscritic := 'Erro ao atualizar CRAPSEG.CDSITSEG: '||SQLERRM;
            -- Envio centralizado de log de erro
            RAISE vr_exc_erro;
        END;
      END IF;

    END LOOP;

  END LOOP;

  /*** RELATÓRIO ***/
  -- Se tem dados para o relatório
  IF vr_tbseguro.count() > 0 THEN

    vr_inseguro := vr_tbseguro.FIRST();

    -- Montar o XML para o relatório e solicitar o mesmo
    DECLARE

      -- Cursores
      -- Buscar o associado
      CURSOR cr_crapass(pr_nrdconta  crapass.nrdconta%TYPE) IS
        SELECT crapass.cdagenci
             , crapass.nmprimtl
          FROM crapass
         WHERE crapass.cdcooper = pr_cdcooper
           AND crapass.nrdconta = pr_nrdconta;

      -- Variáveis locais do bloco
      -- Nome do arquivo
      vr_xml_nmarqlst      CONSTANT VARCHAR2(20) := 'crrl418.lst';
      vr_xml_emails        crapprm.dsvlrprm%TYPE;
      vr_xml_clobxml       CLOB;
      vr_xml_des_erro      VARCHAR2(4000);
      vr_xml_dsseguro      VARCHAR2(50);
      vr_xml_dspropos      VARCHAR2(50);
      vr_xml_dsqtprop      VARCHAR2(50);
      vr_xml_dstotpre      VARCHAR2(50);
      vr_xml_flgpagto      VARCHAR2(1);
      vr_xml_dsprepag      VARCHAR2(10);
      vr_xml_vlqtdreg      NUMBER := 0;
      vr_xml_vltotreg      NUMBER := 0;

      -- Subrotina para escrever texto na variável CLOB do XML
      PROCEDURE pc_escreve_clob(pr_clobdado IN OUT NOCOPY CLOB
                               ,pr_desdados IN VARCHAR2) IS
      BEGIN
        dbms_lob.writeappend(pr_clobdado, length(pr_desdados),pr_desdados);
      END;

    BEGIN

      -- Preparar o CLOB para armazenar as infos do arquivo
      dbms_lob.createtemporary(vr_xml_clobxml, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_xml_clobxml, dbms_lob.lob_readwrite);
      pc_escreve_clob(vr_xml_clobxml,'<?xml version="1.0" encoding="utf-8"?>'||chr(13)||
                                     '<crps418 >'||chr(13));

      -- Percorer todos os registros em memória
      LOOP

        -- Inicializa
        vr_cdageass := NULL;
        vr_nmprimtl := NULL;

        -- Buscar o associado
        OPEN  cr_crapass(vr_tbseguro(vr_inseguro).nrdconta);
        FETCH cr_crapass INTO vr_cdageass
                            , vr_nmprimtl;
        -- Se não encontrar
        IF cr_crapass%NOTFOUND THEN
          pr_cdcritic := 9; -- 009 - Associado nao cadastrado.
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) || ' - CONTA = ' ||
                         gene0002.fn_mask(vr_tbseguro(vr_inseguro).nrdconta,'zzzz,zzz,9');
          -- Gerar o Log
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                     pr_ind_tipo_log => 2, -- Erro tratado
                                     pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                        || vr_cdprogra || ' --> '
                                                        || pr_dscritic);
          -- Fecha o cursor
          CLOSE cr_crapass;
          -- Próximo registro
          CONTINUE;
        END IF;

        -- Se o cursor estiver aberto, fecha o mesmo
        IF cr_crapass%ISOPEN THEN
          CLOSE cr_crapass;
        END IF;

        -- Se mudar o CDSEGURA ou o TPSEGURO   (Substitui o FIRST-OF do PROGRESS)
        IF substr(vr_inseguro,1,15) <> NVL(substr(vr_tbseguro.PRIOR(vr_inseguro),1,15),' ') THEN

          -- Verifica o tipo do seguro
          IF vr_tbseguro(vr_inseguro).tpseguro = 11 THEN
            vr_xml_dsseguro := '** SEGURO RESIDENCIAL **';
          ELSE
            vr_xml_dsseguro := NULL;
          END IF;

          -- Monta data de referencia
          vr_dsrefere := GENE0001.vr_vet_nmmesano(TO_NUMBER(TO_CHAR(vr_dtmvtolt, 'MM')))||'/'||TO_CHAR(vr_dtmvtolt, 'YYYY');


          -- Quebra por Tipo de seguro
          pc_escreve_clob(vr_xml_clobxml,'<tiposeg nmresseg="'||vr_tbseguro(vr_inseguro).nmsegura||'" '
                                               ||' dsrefere="'||vr_dsrefere||'" '
                                               ||' dsseguro="'||vr_xml_dsseguro||'" > '||chr(13));

        END IF;

        -- Se mudar a situação do seguro
        IF substr(vr_inseguro,1,20) <> NVL(substr(vr_tbseguro.PRIOR(vr_inseguro),1,20),' ') THEN

          vr_xml_dspropos := NULL;
          vr_xml_dsqtprop := NULL;
          vr_xml_dstotpre := NULL;

          -- Verifica a descrição da situação
          IF vr_tbseguro(vr_inseguro).cdsitseg = 1 THEN
             vr_xml_dspropos := 'SEGUROS NOVOS';
             vr_xml_dsqtprop := 'QUANTIDADE DE PROPOSTAS NOVAS:';
             vr_xml_dstotpre := 'TOTAL DOS NOVOS PREMIOS:';
          ELSIF vr_tbseguro(vr_inseguro).cdsitseg = 2 THEN
             vr_xml_dspropos := 'SEGUROS CANCELADOS';
             vr_xml_dsqtprop := 'QUANTIDADE DE CANCELAMENTOS:';
             vr_xml_dstotpre := 'TOTAL DOS PREMIOS CANCELADOS:';
          ELSIF vr_tbseguro(vr_inseguro).cdsitseg = 3 THEN
             vr_xml_dspropos := 'SEGUROS RENOVADOS';
             vr_xml_dsqtprop := 'QUANTIDADE DE PROPOSTA:';
             vr_xml_dstotpre := 'TOTAL DOS NOVOS PREMIOS:';
          ELSIF vr_tbseguro(vr_inseguro).cdsitseg = 4 THEN
             vr_xml_dspropos := 'SEGUROS EFETIVOS';
             vr_xml_dsqtprop := 'QUANTIDADE DE EFETIVOS:';
             vr_xml_dstotpre := 'TOTAL DOS PREMIOS:';
          END IF;

          -- Quebra por Situação
          pc_escreve_clob(vr_xml_clobxml,'<situacao dspropos="'||vr_xml_dspropos||'" '
                                                ||' dsqtprop="'||vr_xml_dsqtprop||'" '
                                                ||' dstotpre="'||vr_xml_dstotpre||'" > '||chr(13));

        END IF;

        -- verifica o flag de pagamento
        IF vr_tbseguro(vr_inseguro).flgpagto THEN
          vr_xml_flgpagto := '*';
        ELSE
          vr_xml_flgpagto := NULL;
        END IF;

        -- Verifica a quantidade de parcelas
        IF vr_tbseguro(vr_inseguro).qtparcel > 0 THEN
          vr_xml_dsprepag := vr_tbseguro(vr_inseguro).qtprepag||'/'||vr_tbseguro(vr_inseguro).qtparcel;
        ELSE
          vr_xml_dsprepag := vr_tbseguro(vr_inseguro).qtprepag;
        END IF;

        -- Registros do relatório
        pc_escreve_clob(vr_xml_clobxml,'<seguro > '||chr(13)||
                                       '  <nrdconta>'||TRIM(gene0002.fn_mask(vr_tbseguro(vr_inseguro).nrdconta,'zzzz.zzz.9'))||'</nrdconta> '||chr(13)||
                                       '  <nrctrseg>'||TRIM(gene0002.fn_mask(vr_tbseguro(vr_inseguro).nrctrseg,'zz.zzz.zz9'))||'</nrctrseg> '||chr(13)||
                                       '  <tpplaseg>'||TRIM(gene0002.fn_mask(vr_tbseguro(vr_inseguro).tpplaseg,'zz9'))||'</tpplaseg> '||chr(13)||
                                       '  <cdageass>'||TRIM(gene0002.fn_mask(vr_cdageass,'zz9'))||'</cdageass> '||chr(13)||
                                       '  <cdageseg>'||TRIM(gene0002.fn_mask(vr_tbseguro(vr_inseguro).cdagenci,'zz9'))||'</cdageseg> '||chr(13)||
                                       '  <nmprimtl>'||SUBSTR(vr_nmprimtl,1,22)||'</nmprimtl> '||chr(13)||
                                       '  <vlpreseg>'||TO_CHAR(vr_tbseguro(vr_inseguro).vlpreseg,'FM9G999G999G990D00')||'</vlpreseg> '||chr(13)||
                                       '  <flgpagto>'||vr_xml_flgpagto||'</flgpagto> '||chr(13)||
                                       '  <dsprepag>'||vr_xml_dsprepag||'</dsprepag> '||chr(13)||
                                       '  <dtinivig>'||TO_CHAR(vr_tbseguro(vr_inseguro).dtinivig,'DD/MM/YYYY')||'</dtinivig> '||chr(13)||
                                       '  <dtfimvig>'||TO_CHAR(vr_tbseguro(vr_inseguro).dtfimvig,'DD/MM/YYYY')||'</dtfimvig> '||chr(13)||
                                       '  <dtcancel>'||TO_CHAR(vr_tbseguro(vr_inseguro).dtcancel,'DD/MM/YYYY')||'</dtcancel> '||chr(13)||
                                       '</seguro >'||chr(13));

        -- Se a situação muda na próxima iteração
        IF substr(vr_inseguro,1,20) <> NVL(substr(vr_tbseguro.NEXT(vr_inseguro),1,20),' ') THEN
          -- Fecha a quebra por Situação
          pc_escreve_clob(vr_xml_clobxml,'</situacao>'||chr(13) );
        END IF;

        -- Se o CDSEGURA ou o TPSEGURO muda na proximo iteração
        IF substr(vr_inseguro,1,15) <> NVL(substr(vr_tbseguro.NEXT(vr_inseguro),1,15),' ') THEN
          -- Fecha a quebra por TPSEGURO
          pc_escreve_clob(vr_xml_clobxml,'</tiposeg>'||chr(13));
        END IF;

        -- Se a situação for de novo, renovado ou efetivo
        IF vr_tbseguro(vr_inseguro).flgtotal THEN
          -- Sumarizar os totalizadores
           vr_xml_vlqtdreg := vr_xml_vlqtdreg + 1;
           vr_xml_vltotreg := vr_xml_vltotreg + vr_tbseguro(vr_inseguro).vlpreseg;
        END IF;

        EXIT WHEN vr_inseguro = vr_tbseguro.LAST();
        vr_inseguro := vr_tbseguro.NEXT(vr_inseguro);
      END LOOP;

      -- Imprime o total geral
      pc_escreve_clob(vr_xml_clobxml,'<total > '||chr(13)||
                                     '  <vlqtdreg>'||to_char(vr_xml_vlqtdreg,'FM9G999G999G990')||'</vlqtdreg> '||chr(13)||
                                     '  <vltotreg>'||to_char(vr_xml_vltotreg,'FM9G999G999G990D00')||'</vltotreg> '||chr(13)||
                                     '</total > '||chr(13));

      -- Finaliza o XML
      pc_escreve_clob(vr_xml_clobxml,'</crps418 >'||chr(10));

      -- Se há quantidade, deve solicitar o envio do e-mail
      IF NVL(vr_xml_vlqtdreg,0) > 0 THEN
        -- Busca destinatario do relatorio
        vr_xml_emails := GENE0001.fn_param_sistema('CRED',pr_cdcooper,'CRRL418_EMAIL');
      ELSE
        -- Não passar destinatários, o que acaba não gerando o e-mail
        vr_xml_emails := null;
      END IF;

      -- Submeter o relatório gerando o arquivo de extensão txt, para enviar por e-mail
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                          --> Cooperativa conectada
                                 ,pr_cdprogra  => vr_cdprogra                          --> Programa chamador
                                 ,pr_dtmvtolt  => vr_dtmvtolt                          --> Data do movimento atual
                                 ,pr_dsxml     => vr_xml_clobxml                       --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/crps418/tiposeg/situacao/seguro'   --> Nó base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl418.jasper'                     --> Arquivo de layout do iReport
                                 ,pr_dsparams  => null                                 --> Sem parâmetros
                                 ,pr_dsarqsaid => vr_nom_direto||'/rl/'||vr_xml_nmarqlst --> Arquivo final com o path
                                 ,pr_qtcoluna  => 132                                  --> 132 colunas
                                 ,pr_flg_gerar => 'N'                                  --> Geraçao na hora
                                 ,pr_flg_impri => 'S'                                  --> Chamar a impressão (Imprim.p)
                                 ,pr_nmformul  => '132col'                             --> Nome do formulário para impressão
                                 ,pr_nrcopias  => 1                                    --> Número de cópias
                                 ,pr_sqcabrel  => 1                                    --> Qual a seq do cabrel
                                 ,pr_dsmailcop => vr_xml_emails                        --> Lista sep. por ';' de emails para envio do relatório
                                 ,pr_fldosmail => 'S'                                  --> Flag para converter o arquivo gerado em DOS antes do e-mail
                                 ,pr_dsassmail => 'RESUMO DOS SEGUROS - '||rw_crapcop.nmrescop --> Assunto do e-mail que enviará o relatório
                                 ,pr_dscormail => 'ARQUIVO EM ANEXO.'                  --> HTML corpo do email que enviará o relatório
                                 ,pr_dsextmail => 'txt'                                --> Enviar o anexo como txt
                                 ,pr_flgremarq => 'N'                                  --> Flag para remover o arquivo após cópia/email
                                 ,pr_des_erro  => vr_xml_des_erro);                    --> Saída com erro

      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_xml_clobxml);
      dbms_lob.freetemporary(vr_xml_clobxml);

      -- Verifica se ocorreram erros na geração do XML
      IF vr_xml_des_erro IS NOT NULL THEN

        pr_dscritic := vr_xml_des_erro;

        -- Gerar exceção
        RAISE vr_exc_erro;
      END IF;

    END;

  END IF; -- vr_tbseguro.count() > 0

  -- Processo OK, devemos chamar a fimprg
  btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_stprogra => pr_stprogra);
  -- Grava os dados processados
  COMMIT;

EXCEPTION
  WHEN vr_exc_erro THEN
    -- Se foi retornado apenas código
    IF pr_cdcritic > 0 AND pr_dscritic IS NULL THEN
      -- Buscar a descrição
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
    END IF;
    -- Efetuar rollback
    ROLLBACK;
  WHEN OTHERS THEN
    -- Efetuar retorno do erro não tratado
    pr_cdcritic := 0;
    pr_dscritic := sqlerrm;
    -- Efetuar rollback
    ROLLBACK;
END PC_CRPS441;
/

