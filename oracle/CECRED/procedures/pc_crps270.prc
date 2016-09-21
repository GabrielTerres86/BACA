CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS270 (pr_cdcooper IN crapcop.cdcooper%type   --> Codigo da cooperativa
                      ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                      ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                      ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                      ,pr_cdcritic OUT crapcri.cdcritic%type  --> Codigo de critica
                      ,pr_dscritic OUT VARCHAR2)              --> Descricao de critica
AS
BEGIN
  /* ........................................................................

  Programa: PC_CRPS270 (Antigo Fontes/crps270.p)
  Sistema : Conta-Corrente - Cooperativa de Credito
  Sigla   : CRED
  Autor   : Deborah
  Data    : Agosto/99                       Ultima atualizacao: 15/01/2016

  Dados referentes ao programa:

  Frequencia: Mensal (Batch).
  Objetivo  : Atende a solicitacao 83.
             Mensal do seguro de vida.
             Emite relatorio 220.

  Alteracoes: 30/12/1999 - Dar a mensagem de gravacao do arquivo somente
                          se houve registros (Deborah).

             10/03/2000 - Padronizar mensagem (Deborah).

             19/09/2002 - Alterado para enviar arquivo de seguro de vida
                          automaticamente (Junior).

             22/11/2002 - Colocar "&" no final do comando "MT SEND" (Junior).

             06/02/2003 - Alterar endereco de email para envio de arquivo
                          (Junior).

             06/07/2004 - Alterado para enviar o arquivos crrl220 por
                          email para a Janeide da ADDMakler (Edson).

             09/12/2004 - Gerar arquvios geral de seguros e envia-lo por
                          email para a Janeide da ADDMakler (Edson).


             16/02/2005 - Desmembrar o relatorio geral de seguros para
                          antes de 01/12/2004 e outro para depois de
                          30/11/2004 (Edson).

             23/03/2005 - Incluir o campos craptsg.cdsegura na leitura da
                          tabela craptsg (Edson).

             30/06/2005 - Alimentado campo cdcooper da tabela crapres (Diego).

             01/09/2005 - Alterado para enviar os arquivos crrl220 e crrl399
                          por email para a Elisangela da ADDMakler (Edson).

             21/09/2005 - Modificado FIND FIRST para FIND na tabela
                          crapcop.cdcooper = glb_cdcooper (Diego).

             16/02/2006 - Unificacao dos Campos - SQLWorks - Fernando.

             05/07/2006 - Incluida execucao do procedimento imprim.p na
                          procedure proc_seguro_geral (David).

             30/08/2006 - Alterado envio de email pela BO b1wgen0011 (David).

             05/01/2007 - Incluido envio do relatorio 220 para o email
                          pedro.bnu@addmakler.com.br (David).

             22/05/2007 - Incluido envio do relatorio 220 para o email:
                          rene.bnu@addmakler.com.br (Guilherme).

             06/08/2007 - Incluido envio do relatorio 220 para os emails:
                          susan.bnu@addmakle.com.br
                          fernandabrizola.bnu@addmakler.com.br (Guilherme).

             03/10/2007 - Enviar email com o crrl399 para os mesmos
                          destinatarios do crrl220(Guilherme).

             18/03/2008 - Retirado comentario da rotina de envio de email
                          (Sidnei - Precise)

             29/11/2008 - glb_nmformul com 234dh para crrl399 (Magui).

             28/01/2009 - Enviar e-mail somente para aylloscecred@addmakler
                          .com.br em ambos relatorios (Gabriel).

             14/01/2011 - Alterado campo CAPITAL no relatorio 399 para exibir
                          o valor do campo craptsg.vlmorada. (Jorge)

             01/02/2011 - Alterado format do campo nrdconta e nrctrseg da
                          str_4 (Henrique).

             05/07/2011 - Enviar e-mail para jeicy@cecred.coop.br (Henrique)

             04/03/2013 - Substituido e-mail jeicy@cecred.coop.br por
                          cecredseguros@cecred.coop.br (Daniele).

             09/09/2013 - Conversao Progress -> PL/SQL (Douglas Pagel).

             11/10/2013 - Ajustes na rotina para prever a nova forma de retorno
                          das criticas e chamadas a fimprg.p (Douglas Pagel)

             18/10/2013 - Ajuste para não gerar relatorio quando não houverem
                          registros no crrl220 (Douglas Pagel).

             18/11/2013 - Ajustar o programa para repassar também o texto no
                          dos totais no relatório 220 (Marcos-Supero)

             25/11/2013 - Ajustes na passagem dos parâmetros para restart (Marcos-Supero)

             08/01/2014 - Remoção de chamada duplicada a geração de relatorio
                          ja que agora é possivel passar qual a extensão da
                          copia ou e-mail, e ainda não, o que gerava a necessidade
                          de duas chamadas (Marcos-Supero)

             09/03/2015 - Ajuste para buscar o valor do premio da tabela crawseg.(James)

             23/09/2015 - #318395 Correção do totalizador dos seguros, que estavam pegando o valor do seguro
                          já renovado, o que levava a uma diferença a maior. Resolvido pegando o valor do lançamento
                          na conta do cooperado (Carlos)

             27/10/2015 - Adicionado novo campo de apólice, asterisco na coluna premio para contas que estejam
                          canceladas no mês, porém há lancamentos e também totalizadores por apólice no final
                          dos relatórios 220 e 399, conforme solicitado no chamado 343435 (Kelvin)
             
             15/01/2015 - Ajustado indice(vr_chave_399) da temptable do relatorio crrl399 incluindo nrdconta
                          para não sobrepor contas quando possuem mesmo numero de contrato SD381774 (Odirlei-AMcom)
                          
                          
  ......................................................................... */
  DECLARE
    -- Identificacao do programa
    vr_cdprogra crapprg.cdprogra%type := 'CRPS270';

    -- Cursor para validação da cooperativa
    cursor cr_crapcop is
      SELECT nmrescop
        FROM crapcop
       WHERE cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%rowtype;

    -- Buscar as informações para restart e Rowid para atualização posterior
    cursor cr_crapres is
      SELECT res.rowid
        FROM crapres res
       WHERE res.cdcooper = pr_cdcooper
         AND res.cdprogra = vr_cdprogra;
    rw_crapres cr_crapres%ROWTYPE;

    -- Cursor para leitura dos planos de seguro
    cursor cr_crapseg is
      SELECT crapseg.nrdconta, -- Numero da conta do cooperado segurado
             crapseg.dtinivig, -- Data de inicio de vigencia do seguro
             crapseg.nrctrseg, -- Numero da proposta/contrato do seguro
             crapseg.tpplaseg, -- Tipo de plano de seguro
             crapseg.dtdebito, -- Data do proximo debito
             crapseg.vlpreseg, -- Valor do premio mensal a ser debitado
             crapseg.dtultalt, -- Data da ultima alteração
             crapseg.dtcancel, -- Data de cancelamento
             crapseg.cdsitseg, -- Situacao do seguro: 1 - Ativo 2 - Cancelado
             crapseg.indebito, -- Indicador de débito: 0 - Nao debitado 1 - Debitado
             crapseg.dtmvtolt, -- Data do movimento
             crapseg.dtfimvig, -- Data de fim de vigencia do seguro
             crapseg.cdsegura, -- Codigo da seguradora
             crapseg.tpseguro -- Tipo de Seguro
        FROM crapseg
       WHERE crapseg.cdcooper = pr_cdcooper AND
             crapseg.tpseguro = 3 -- Seguro de vida
        order by cdcooper, tpseguro, cdsegura, nrctrseg, nrdconta;
       rw_crapseg cr_crapseg%rowtype;

    -- Cursor para leitura da tabela auxiliar de contratacao de seguro
    cursor cr_crawseg (pr_nrdconta crawseg.nrdconta%type
                      ,pr_tpseguro crawseg.tpseguro%type
                      ,pr_nrctrseg crawseg.nrctrseg%type) is
      SELECT substr(crawseg.nmdsegur, 0, 40) nmdsegur, -- Nome do segurado
             crawseg.dtnascsg,                         -- Data de nascimento do segurado
             substr(crawseg.nrcpfcgc, 0, 14) nrcpfcgc, -- CPF/CNPJ do segurado
             crawseg.vlseguro
        FROM crawseg
       WHERE crawseg.cdcooper = pr_cdcooper AND
             crawseg.nrdconta = pr_nrdconta AND
             crawseg.tpseguro = pr_tpseguro AND
             crawseg.nrctrseg = pr_nrctrseg;
    rw_crawseg cr_crawseg%rowtype;

    -- Cursor para listagem dos planos de seguro
    cursor cr_craptsg is
      SELECT craptsg.tpseguro,
             craptsg.tpplaseg,
             craptsg.cdsegura,
             craptsg.dsmorada
        FROM craptsg
       WHERE craptsg.cdcooper = pr_cdcooper;

    -- Tipo de registro para PlTable de Planos de Seguro vr_tab_tsg
    type typ_reg_tsg is
      record(dsmorada craptsg.dsmorada%type);
    type typ_tab_tsg is
      table of typ_reg_tsg
        index by varchar(30); -- (10)tpseguro || (10)tpplaseg || (10)cdsegura

    -- Variavel para PlTable de Planos de Seguro
    vr_tab_tsg typ_tab_tsg;

    -- Variavel de auxilio para chave da PlTable vr_tab_tsg
    vr_chave_tsg varchar(30);

    -- Cursor para identificar os seguros renovados no final do mes
    cursor cr_seguros_renovados (pr_dtmvtolt crapdat.dtmvtolt%type
                                ,pr_dtmvtopr crapdat.dtmvtopr%type) is
      SELECT  s.nrdconta --,s.dtrenova,s.dtinivig,s.dtultalt,s.vlpreseg,s.indebito,s.dtcancel,s.cdsitseg
        FROM crapseg s
       WHERE s.cdcooper = pr_cdcooper
         AND s.tpseguro = 3
         AND s.cdsitseg = 1
         AND s.dtrenova >  pr_dtmvtolt -- '31/08/2016' -- mvtolt
         AND s.dtrenova <= pr_dtmvtopr; -- '01/09/2016' -- mvtopr
    rw_seguro_renovado cr_seguros_renovados%rowtype;

    -- Tipo de registro para PlTable de Associados
    type typ_reg_seguro_renovado is
      record(nrdconta crapass.nrdconta%type);

    -- Tipo de tabela para PlTable de contas com seguros renovados
    type typ_tab_seguro_renovado is
      table of typ_reg_seguro_renovado
        index by pls_integer; -- rw_crapass.nrdconta

    -- PlTable de seguros renovados
    vr_tab_seguro_renovado typ_tab_seguro_renovado;

    -- Lançamento do seguro no mes atual
    CURSOR cr_craplcm (pr_nrdconta crapass.nrdconta%type
                      ,pr_nrctrseq craplcm.nrdocmto%type
                      ,pr_dtmvtolt crapdat.dtmvtolt%type) IS
       SELECT craplcm.vllanmto
         FROM craplcm
        WHERE cdcooper = pr_cdcooper
          AND craplcm.nrdconta = pr_nrdconta
          AND craplcm.cdhistor = 341
          AND craplcm.nrdocmto = pr_nrctrseq
          AND to_char(craplcm.dtmvtolt,'mm/RRRR') = to_char(pr_dtmvtolt,'mm/RRRR')
          AND ROWNUM = 1
        ORDER BY craplcm.dtmvtolt DESC;
    rw_craplcm cr_craplcm%rowtype;

    -- Cursor para busca dos associados
    cursor cr_crapass is
      SELECT crapass.nrdconta,
             crapass.cdagenci,
             substr(crapass.nmprimtl, 0, 40) nmprimtl
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper;

    --Tipo de registro para PlTable da Herco
    type typ_reg_herco is
      record(cdagenci crapass.cdagenci%type
            ,nrdconta crapseg.nrdconta%type
            ,nrctrseg crapseg.nrctrseg%type
            ,tpplaseg crapseg.tpplaseg%type
            ,dtdebito crapseg.dtdebito%type
            ,vlpreseg crapseg.vlpreseg%type);

    CURSOR cr_seg_lcm(pr_cdcooper crapseg.cdcooper%TYPE
                     ,pr_nrdconta crapseg.nrdconta%TYPE
                     ,pr_nrctrseg crapseg.nrctrseg%TYPE
                     ,pr_dtmvtolt crapseg.dtmvtolt%TYPE) IS
      SELECT 1
        FROM craplcm lcm
       WHERE lcm.cdcooper = pr_cdcooper
         AND lcm.nrdconta = pr_nrdconta
         AND lcm.nrdocmto = pr_nrctrseg
         AND lcm.cdhistor = 341
         AND lcm.dtmvtolt >= pr_dtmvtolt;

   rw_seg_lcm cr_seg_lcm%ROWTYPE;

    -- Tipo de tabela para PlTable da Herco
    type typ_tab_herco is
      table of typ_reg_herco
        index by pls_integer;

    -- Variavel para auxilio da chave da PlTable da Herco
    vr_chave_herco integer := 1;

    -- Variável auxiliar para o valor do premio mensal, que poderá vir da seg ou da lcm
    vr_vlpreseg crapseg.vlpreseg%type;

    -- Variavel para PlTable da Herco
    vr_tab_herco typ_tab_herco;

    -- Tipo de registro para PlTable de Associados
    type typ_reg_ass is
      record(nrdconta crapass.nrdconta%type
            ,cdagenci crapass.cdagenci%type
            ,nmprimtl crapass.nmprimtl%type);

    -- Tipo de tabela para PlTable de cadastro de associado
    type typ_tab_ass is
      table of typ_reg_ass
        index by pls_integer; -- rw_crapass.nrdconta

    -- PlTable de associados
    vr_tab_ass typ_tab_ass;

    -- Tipo de registro para PlTable do relatorio 220
    type typ_reg_220 is
      record(tpregist integer -- 1 - Novos 2 - Alterados 3 - Cancelados
            ,cdagenci crapass.cdagenci%type
            ,nrdconta crapseg.nrdconta%type
            ,nrctrseg crapseg.nrctrseg%type
            ,tpplaseg crapseg.tpplaseg%type
            ,dtdebito crapseg.dtdebito%type
            ,vlpreseg crapseg.vlpreseg%type
            ,dtinivig crapseg.dtinivig%type
            ,nmprimtl crapass.nmprimtl%TYPE
            ,dtcancel crapseg.dtcancel%TYPE
            ,nrdapoli VARCHAR(7)
            ,idseglcm NUMBER(1));

    -- Tipo de tabela para PlTable do relatorio 220
    type typ_tab_220 is
      table of typ_reg_220
        index by varchar2(100); -- ((1)tpregist || (12)vlpreseg || (10)dtinivig (30)nmprimtll (3)cdagenci (10)nrdconta (10)nrctrseg)

    -- Variavel para PlTable do relatorio 220
    vr_tab_220 typ_tab_220;

    -- Variavel para auxilio da chave da PlTable vr_tab_220
    vr_chave_220 varchar2(100);

    -- Tipo de registro para PlTable vr_tab_399
    type typ_reg_399 is
      record(cdativo integer -- 1 - Ativo | 2 - Cancelado
            ,periodo integer -- 1 - Antes de 30/11/2004 | 2 - Depois de 01/12/2004
            ,tpplaseg crapseg.tpplaseg%type
            ,nrdconta crapseg.nrdconta%type
            ,nmdsegur crawseg.nmdsegur%type
            ,vlseguro crawseg.vlseguro%type
            ,vlpreseg crapseg.vlpreseg%type
            ,dtnascsg crawseg.dtnascsg%type
            ,nrcpfcgc crawseg.nrcpfcgc%type
            ,cdagenci crapass.cdagenci%type
            ,nrctrseg crapseg.nrctrseg%type
            ,dtinivig crapseg.dtinivig%type
            ,dtfimvig crapseg.dtfimvig%type
            ,dtcancel crapseg.dtcancel%type
            ,dscobert varchar(50)
            ,nrdapoli VARCHAR2(7)
            ,idseglcm NUMBER(1));

    -- Tipo de tabela para PlTable vr_tab_399
    type typ_tab_399 is
      table of typ_reg_399
        index by varchar(35); -- (1)periodo || (1) cdativo (5)tpplaseg || (15)nrctrseg || (10) nrdconta

    -- Variavel para PlTable do crrl399
    -- Feito desta maneira para garantir que mesmo que nao haja seguros para o filtro do relatorio,
    -- aparecam nos relatorio os totais zerados.
    vr_tab_399_1_1 typ_tab_399;
    vr_tab_399_1_2 typ_tab_399;
    vr_tab_399_2_1 typ_tab_399;
    vr_tab_399_2_2 typ_tab_399;

    -- Variavel para auxilio da chave da PlTable vr_tab_399
    vr_chave_399 varchar(35);

    -- Variavel temporaria de Tipo de Registro para o crrl220
    vr_tmp_tpregis integer;

    -- Variaveis para referencia de data
    vr_dtinicio date; -- Data de inicio do relatorio crrl220
    vr_dsrefere varchar2(20); -- Descricao do MES/ANO de referencia
    vr_dtinicio_399 date; -- Data de inicio crrl399
    vr_dtliminf date := To_Date('01/01/1901','DD/MM/YYYY'); -- Data de limite inferior para crrl399
    vr_dtlimmed date := To_Date('01/12/2004','DD/MM/YYYY'); -- Data de limite superior para periodo antes de 2004 do crrl399
    vr_dtlimsup date := To_Date('01/12/2999','DD/MM/YYYY'); -- Data de limite superior para periodo depois de 2004 do crrl399
    vr_nrdapoli VARCHAR2(7);
    vr_idseglcm NUMBER(1) := 0;
    vr_vltoap01 NUMBER := 0;
    vr_vltoap02 NUMBER := 0;
    vr_vltoap03 NUMBER := 0;
    vr_vltoap04 NUMBER := 0;

    -- Variaveis para totalizacao
    vr_vltotdeb crapseg.vlpreseg%type := 0;
    vr_qttotdeb integer := 0;

    -- Variaveis para auxilio no crr399
    vr_cdativo integer; -- vr_tab_399.cdativo
    vr_periodo integer; -- vr_tab_399.periodo

    -- Rowtype para validacao da data
    rw_crapdat btch0001.cr_crapdat%rowtype;

    -- Variavel de excecao para saida padrao
    -- Tratamento de erros
    vr_exc_saida  EXCEPTION;
    vr_exc_fimprg EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);

    -- Variavel de dados do XML em memória (CLOB)
    vr_dsxmldad  CLOB;

    -- Diretorio da cooperativa
    vr_dircoop varchar2(300);

    -- Variaveis para envio de email dos relatorios
    vr_emails crapprm.dsvlrprm%TYPE;

    -- Variaveis para controle de restart
    vr_nrctares crapass.nrdconta%TYPE;--> Número da conta de restart
    vr_dsrestar VARCHAR2(4000);       --> String genérica com informações para restart
    vr_inrestar INTEGER;              --> Indicador de Restart

    -- Procedimento auxiliar para escrita no CLOB vr_dsxmldad
    PROCEDURE pc_escreve_clob(pr_des_dados IN VARCHAR2) IS
    BEGIN
      dbms_lob.writeappend(vr_dsxmldad,length(pr_des_dados),pr_des_dados);
    END;

  BEGIN
    -- Informa acesso
    GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                              ,pr_action => null);

    -- Valida a cooperativa
    open cr_crapcop;
    fetch cr_crapcop
      into rw_crapcop;
    if cr_crapcop%notfound then
      vr_cdcritic := 651;
      close cr_crapcop;
      raise vr_exc_saida;
    end if;
    close cr_crapcop;

    -- Valida a data do programa
    open btch0001.cr_crapdat(pr_cdcooper);
    fetch btch0001.cr_crapdat
      into rw_crapdat;
    if btch0001.cr_crapdat%notfound then
      vr_cdcritic := 1;
      close btch0001.cr_crapdat;
      raise vr_exc_saida;
    end if;
    close btch0001.cr_crapdat;

    -- Validações iniciais do programa
    BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                             ,pr_flgbatch => 1
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_cdcritic => vr_cdcritic);
    -- Se a variavel de erro é <> 0
    IF vr_cdcritic <> 0 THEN
      -- Envio centralizado de log de erro
      RAISE vr_exc_saida;
    END IF;

    -- Tratamento e retorno de valores de restart
    btch0001.pc_valida_restart(pr_cdcooper  => pr_cdcooper   --> Cooperativa conectada
                              ,pr_cdprogra  => vr_cdprogra   --> Código do programa
                              ,pr_flgresta  => pr_flgresta   --> Indicador de restart
                              ,pr_nrctares  => vr_nrctares   --> Número da conta de restart
                              ,pr_dsrestar  => vr_dsrestar   --> String genérica com informações para restart
                              ,pr_inrestar  => vr_inrestar   --> Indicador de Restart
                              ,pr_cdcritic  => vr_cdcritic   --> Código de erro
                              ,pr_des_erro  => vr_dscritic); --> Saída de erro
    -- Se encontrou erro, gerar exceção
    IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
    -- Se houver indicador de restart, mas não veio conta
    IF vr_inrestar > 0 AND vr_nrctares = 0  THEN
      -- Remover o indicador
      vr_inrestar := 0;
    END IF;

    -- Inicio da regra de negocio

    -- So gera os relatorios quando nao estiver em restart
    if vr_inrestar = 0 then

      -- Alimenta PlTable vr_tab_ass com dados de Associados
      FOR rw_crapass IN cr_crapass LOOP
        vr_tab_ass(rw_crapass.nrdconta).nrdconta := rw_crapass.nrdconta;
        vr_tab_ass(rw_crapass.nrdconta).cdagenci := rw_crapass.cdagenci;
        vr_tab_ass(rw_crapass.nrdconta).nmprimtl := rw_crapass.nmprimtl;
      END LOOP;

      -- Alimenta PlTable de Planos de Seguro
      FOR rw_craptsg IN cr_craptsg LOOP
        -- Formacao da chave (10)tpseguro || (10)tpplaseg || (10)cdsegura
        vr_chave_tsg := LPAD(rw_craptsg.tpseguro, 10, '0') || LPAD(rw_craptsg.tpplaseg, 10, '0') || LPAD(rw_craptsg.cdsegura, 10, '0');
        vr_tab_tsg(vr_chave_tsg).dsmorada := rw_craptsg.dsmorada;
      END LOOP;

      -- Formacao da data de incio
      vr_dtinicio := rw_crapdat.dtmvtolt - to_char(rw_crapdat.dtmvtolt, 'dd');
      vr_dtinicio_399 := rw_crapdat.dtmvtolt - to_char(rw_crapdat.dtmvtolt, 'dd') + 1;
      vr_dsrefere := gene0001.vr_vet_nmmesano(to_char(rw_crapdat.dtmvtolt, 'mm')) || '/' || to_char(rw_crapdat.dtmvtolt, 'yyyy');

      -- Armazena as contas com seguros renovados para o inicio do mês
      FOR rw_seguro_renovado IN cr_seguros_renovados(add_months(rw_crapdat.dtmvtolt,12)  -- seguros aqui já estarão renovados para
                                                    ,add_months(rw_crapdat.dtmvtopr,12)) -- mais um ano
                                                    LOOP
        vr_tab_seguro_renovado(rw_seguro_renovado.nrdconta).nrdconta := rw_seguro_renovado.nrdconta;
      END LOOP;

      -- Listagem dos seguros
      open cr_crapseg;
      loop
        fetch cr_crapseg
          into rw_crapseg;

        -- Sai quando nao houver mais seguros
        exit when cr_crapseg%notfound;

        IF rw_crapseg.tpplaseg IN (11, 15, 21, 31, 41, 51 , 61) THEN
          vr_nrdapoli := '6142149';
        ELSIF rw_crapseg.tpplaseg IN (12, 16, 22, 32, 42, 52, 62) THEN
          vr_nrdapoli := '6077071';
        ELSIF rw_crapseg.tpplaseg IN (13, 17, 23, 33, 43, 53, 63) THEN
          vr_nrdapoli := '6077070';
        ELSIF rw_crapseg.tpplaseg IN (14, 18, 24, 34, 44, 54, 64) THEN
          vr_nrdapoli := '6077069';
        END IF;

        -- Valida associado do seguro
        if not vr_tab_ass.exists(rw_crapseg.nrdconta) then
          vr_cdcritic := 251;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic)
                       || ' CONTA = ' || rw_crapseg.nrdconta;
          raise vr_exc_saida;
        end if;

        -- Inicio da insercao na Pltable do crrl220
        vr_tmp_tpregis := null;
        -- O mesmo seguro pode aparecer nos 3 totalizadores (Novos, Alterados e Cancelados).
        --Verificacao do tipo de registro

        if vr_tab_seguro_renovado.exists(rw_crapseg.nrdconta) then
          -- para seguro renovado, pegar valor do ultimo lançamento do mês pelo historico 341 #318395
          open cr_craplcm(rw_crapseg.nrdconta
                         ,rw_crapseg.nrctrseg
                         ,rw_crapdat.dtmvtolt);
          fetch cr_craplcm
            into rw_craplcm;
          if cr_craplcm%notfound then
            vr_vlpreseg := 0;
          else
            vr_vlpreseg := rw_craplcm.vllanmto;
          end if;
          close cr_craplcm;
        else
          vr_vlpreseg := rw_crapseg.vlpreseg;
        end IF;
        IF to_char(rw_crapseg.dtcancel,'MM/YYYY') = TO_CHAR(rw_crapdat.dtmvtolt,'MM/YYYY') THEN
          OPEN cr_seg_lcm(pr_cdcooper
                         ,rw_crapseg.nrdconta
                         ,rw_crapseg.nrctrseg
                         ,trunc(rw_crapdat.dtmvtolt,'MM'));
          FETCH cr_seg_lcm
          INTO rw_seg_lcm;

          IF cr_seg_lcm%FOUND THEN
            vr_idseglcm := 1;
          ELSE
            vr_idseglcm := 0;
          END IF;

          CLOSE cr_seg_lcm;
        ELSE
          vr_idseglcm := 0;
        END IF;

        if rw_crapseg.dtinivig > vr_dtinicio then
          vr_tmp_tpregis := 1; -- Novo

          -- Monta chave para PlTable vr_tab_220 ( (1)tpregist || (12)vlpreseg || (10)dtinivig (30)nmprimtll (3)cdagenci (10)nrdconta (10)nrctrseg)
          vr_chave_220 := vr_tmp_tpregis ||
                          LPad(to_char(vr_vlpreseg, '999G999D99'),12,'0') ||
                          LPAD(to_char(rw_crapseg.dtinivig, 'ddmmyyyy'), 10, '0') ||
                          RPad(substr(vr_tab_ass(rw_crapseg.nrdconta).nmprimtl, 0, INSTR(vr_tab_ass(rw_crapseg.nrdconta).nmprimtl,' ', 3, 1)-1),30,'0') ||
                          LPAD(vr_tab_ass(rw_crapseg.nrdconta).cdagenci, 3, '0') ||
                          LPAD(rw_crapseg.nrdconta, 10, '0') ||
                          LPAD(rw_crapseg.nrctrseg, 10, '0');
          -- Insere registro
          vr_tab_220(vr_chave_220).tpregist := vr_tmp_tpregis;
          vr_tab_220(vr_chave_220).cdagenci := vr_tab_ass(rw_crapseg.nrdconta).cdagenci;
          vr_tab_220(vr_chave_220).nrdconta := rw_crapseg.nrdconta;
          vr_tab_220(vr_chave_220).nrctrseg := rw_crapseg.nrctrseg;
          vr_tab_220(vr_chave_220).tpplaseg := rw_crapseg.tpplaseg;
          vr_tab_220(vr_chave_220).dtdebito := rw_crapseg.dtdebito;
          vr_tab_220(vr_chave_220).vlpreseg := vr_vlpreseg;
          vr_tab_220(vr_chave_220).dtinivig := rw_crapseg.dtinivig;
          vr_tab_220(vr_chave_220).nmprimtl := vr_tab_ass(rw_crapseg.nrdconta).nmprimtl;
          vr_tab_220(vr_chave_220).dtcancel := rw_crapseg.dtcancel;
          vr_tab_220(vr_chave_220).nrdapoli := vr_nrdapoli;
          vr_tab_220(vr_chave_220).idseglcm := vr_idseglcm;

        end if;
        if rw_crapseg.dtultalt > vr_dtinicio then
          vr_tmp_tpregis := 2; -- Alterado
          -- Monta chave para PlTable vr_tab_220 ( (1)tpregist || (12)vlpreseg || (10)dtinivig (30)nmprimtll (3)cdagenci (10)nrdconta (10)nrctrseg)
          vr_chave_220 := vr_tmp_tpregis ||
                          LPad(to_char(vr_vlpreseg, '999G999D99'),12,'0') ||
                          LPAD(to_char(rw_crapseg.dtultalt, 'ddmmyyyy'), 10, '0') ||
                          RPad(substr(vr_tab_ass(rw_crapseg.nrdconta).nmprimtl, 0, INSTR(vr_tab_ass(rw_crapseg.nrdconta).nmprimtl,' ', 3, 1)-1),30,'0') ||
                          LPAD(vr_tab_ass(rw_crapseg.nrdconta).cdagenci, 3, '0') ||
                          LPAD(rw_crapseg.nrdconta, 10, '0') ||
                          LPAD(rw_crapseg.nrctrseg, 10, '0');
          -- Insere registro
          vr_tab_220(vr_chave_220).tpregist := vr_tmp_tpregis;
          vr_tab_220(vr_chave_220).cdagenci := vr_tab_ass(rw_crapseg.nrdconta).cdagenci;
          vr_tab_220(vr_chave_220).nrdconta := rw_crapseg.nrdconta;
          vr_tab_220(vr_chave_220).nrctrseg := rw_crapseg.nrctrseg;
          vr_tab_220(vr_chave_220).tpplaseg := rw_crapseg.tpplaseg;
          vr_tab_220(vr_chave_220).dtdebito := rw_crapseg.dtdebito;
          vr_tab_220(vr_chave_220).vlpreseg := vr_vlpreseg;
          vr_tab_220(vr_chave_220).dtinivig := rw_crapseg.dtultalt;
          vr_tab_220(vr_chave_220).nmprimtl := vr_tab_ass(rw_crapseg.nrdconta).nmprimtl;
          vr_tab_220(vr_chave_220).dtcancel := rw_crapseg.dtcancel;
          vr_tab_220(vr_chave_220).nrdapoli := vr_nrdapoli;
          vr_tab_220(vr_chave_220).idseglcm := vr_idseglcm;
        end if;
        if rw_crapseg.dtcancel > vr_dtinicio then
          vr_tmp_tpregis := 3; -- Cancelado
          -- Monta chave para PlTable vr_tab_220 ( (1)tpregist || (12)vlpreseg || (10)dtinivig (30)nmprimtll (3)cdagenci (10)nrdconta (10)nrctrseg)
          vr_chave_220 := vr_tmp_tpregis ||
                          LPad(to_char(vr_vlpreseg, '999G999D99'),12,'0') ||
                          LPAD(to_char(rw_crapseg.dtcancel, 'ddmmyyyy'), 10, '0') ||
                          RPad(substr(vr_tab_ass(rw_crapseg.nrdconta).nmprimtl, 0, INSTR(vr_tab_ass(rw_crapseg.nrdconta).nmprimtl,' ', 3, 1)-1),30,'0') ||
                          LPAD(vr_tab_ass(rw_crapseg.nrdconta).cdagenci, 3, '0') ||
                          LPAD(rw_crapseg.nrdconta, 10, '0') ||
                          LPAD(rw_crapseg.nrctrseg, 10, '0');
          -- Insere registro
          vr_tab_220(vr_chave_220).tpregist := vr_tmp_tpregis;
          vr_tab_220(vr_chave_220).cdagenci := vr_tab_ass(rw_crapseg.nrdconta).cdagenci;
          vr_tab_220(vr_chave_220).nrdconta := rw_crapseg.nrdconta;
          vr_tab_220(vr_chave_220).nrctrseg := rw_crapseg.nrctrseg;
          vr_tab_220(vr_chave_220).tpplaseg := rw_crapseg.tpplaseg;
          vr_tab_220(vr_chave_220).dtdebito := rw_crapseg.dtdebito;
          vr_tab_220(vr_chave_220).vlpreseg := vr_vlpreseg;
          vr_tab_220(vr_chave_220).dtinivig := rw_crapseg.dtcancel;
          vr_tab_220(vr_chave_220).nmprimtl := vr_tab_ass(rw_crapseg.nrdconta).nmprimtl;
          vr_tab_220(vr_chave_220).dtcancel := rw_crapseg.dtcancel;
          vr_tab_220(vr_chave_220).nrdapoli := vr_nrdapoli;
          vr_tab_220(vr_chave_220).idseglcm := vr_idseglcm;
        end if;

        -- Fim crrl220

        -- Verificacoes para inserir no arquivo da Herco e totalizadores para crrl220
        if rw_crapseg.cdsitseg = 1 or
           (rw_crapseg.dtcancel > vr_dtinicio AND
            rw_crapseg.indebito = 1) then
          -- Monta chave
          vr_chave_herco := vr_chave_herco + 1;

          -- Totalizadores que aparecem no crrl220, mas que são contados dentro do filtro do arquivo para herco
          vr_vltotdeb := vr_vltotdeb + vr_vlpreseg;
          vr_qttotdeb := vr_qttotdeb + 1;

          --Insere na PlTable do arquivo da herco
          vr_tab_herco(vr_chave_herco).nrdconta := rw_crapseg.nrdconta;
          vr_tab_herco(vr_chave_herco).cdagenci := vr_tab_ass(rw_crapseg.nrdconta).cdagenci;
          vr_tab_herco(vr_chave_herco).nrctrseg := rw_crapseg.nrctrseg;
          vr_tab_herco(vr_chave_herco).tpplaseg := rw_crapseg.tpplaseg;
          vr_tab_herco(vr_chave_herco).dtdebito := rw_crapseg.dtdebito;
          vr_tab_herco(vr_chave_herco).vlpreseg := vr_vlpreseg;

        -- Fim arquivo herco
        end if;

        -- Inicio crrl399

        -- Zerando variaveis de auxilio
        vr_cdativo := null;
        vr_periodo := null;

        -- Verificacao do periodo
        if rw_crapseg.dtmvtolt > vr_dtliminf and
           rw_crapseg.dtmvtolt < vr_dtlimmed then
          -- E ate 01/12/2004
          vr_periodo := 1;
        else
          if rw_crapseg.dtmvtolt < vr_dtlimsup then
            -- E depois de 01/12/2004
            vr_periodo := 2;
          end if;
        end if;

        -- Verificacao do status
        if rw_crapseg.cdsitseg = 1 then
          vr_cdativo := 1; -- ativo
        end if;
        -- Seguros com data de cancelamento,
        -- com data de movimento maior que a data limite inferior
        -- e data de cancelamento maior que a data do inicio do periodo
        if rw_crapseg.dtcancel is not null and
            rw_crapseg.dtmvtolt >= vr_dtliminf and
            rw_crapseg.dtcancel >= vr_dtinicio_399 then
          vr_cdativo := 2; -- cancelado
        end if;

        -- Validacao para entrada no relatorio crrl399
        if vr_periodo is null or
           vr_cdativo is null then
          -- Passa para o proximo seguro.
          continue;
        end if;

        -- Valida registro da tabela auxiliar de contratacao de seguro
        open cr_crawseg(rw_crapseg.nrdconta
                       ,rw_crapseg.tpseguro
                       ,rw_crapseg.nrctrseg);
        fetch cr_crawseg
          into rw_crawseg;
        if cr_crawseg%notfound then
          continue;
          close cr_crawseg;
        end if;
        close cr_crawseg;

        -- Monta chave para insercao na PlTable do crrl399
        --(1)periodo || (1) cdativo (5)tpplaseg || (15)nrctrseg || (10)nrdconta
        vr_chave_399 := vr_periodo || vr_cdativo || LPAD(rw_crapseg.tpplaseg, 5, '0') || LPAD(rw_crapseg.nrctrseg, 15, '0')|| LPAD(rw_crapseg.nrdconta, 10, '0');
        -- Antes de 2004
        if vr_periodo = 1 then
          -- ativos
          if vr_cdativo = 1 then
            vr_tab_399_1_1(vr_chave_399).cdativo := vr_cdativo;
            vr_tab_399_1_1(vr_chave_399).periodo := vr_periodo;
            vr_tab_399_1_1(vr_chave_399).tpplaseg := rw_crapseg.tpplaseg;
            vr_tab_399_1_1(vr_chave_399).nrdconta := rw_crapseg.nrdconta;
            vr_tab_399_1_1(vr_chave_399).nmdsegur := rw_crawseg.nmdsegur;
            vr_tab_399_1_1(vr_chave_399).vlpreseg := vr_vlpreseg;
            vr_tab_399_1_1(vr_chave_399).dtnascsg := rw_crawseg.dtnascsg;
            vr_tab_399_1_1(vr_chave_399).nrcpfcgc := rw_crawseg.nrcpfcgc;
            vr_tab_399_1_1(vr_chave_399).cdagenci := vr_tab_ass(rw_crapseg.nrdconta).cdagenci;
            vr_tab_399_1_1(vr_chave_399).nrctrseg := rw_crapseg.nrctrseg;
            vr_tab_399_1_1(vr_chave_399).dtinivig := rw_crapseg.dtinivig;
            vr_tab_399_1_1(vr_chave_399).dtfimvig := rw_crapseg.dtfimvig;
            vr_tab_399_1_1(vr_chave_399).dtcancel := rw_crapseg.dtcancel;
            vr_tab_399_1_1(vr_chave_399).vlseguro := rw_crawseg.vlseguro;
            vr_tab_399_1_1(vr_chave_399).nrdapoli := vr_nrdapoli;
            vr_tab_399_1_1(vr_chave_399).idseglcm := vr_idseglcm;
            -- Monta chave para pesquisa da cobertura do plano
            vr_chave_tsg := LPAD(rw_crapseg.tpseguro, 10, '0') || LPAD(rw_crapseg.tpplaseg, 10, '0') || LPAD(rw_crapseg.cdsegura, 10, '0');
            -- Busca descricao da cobertura do plano
            if vr_tab_tsg.exists(vr_chave_tsg) then
              vr_tab_399_1_1(vr_chave_399).dscobert := vr_tab_tsg(vr_chave_tsg).dsmorada;
            end if;
          end if;
          -- Cancelados antes de 2004
          if vr_cdativo = 2 then
            vr_tab_399_1_2(vr_chave_399).cdativo := vr_cdativo;
            vr_tab_399_1_2(vr_chave_399).periodo := vr_periodo;
            vr_tab_399_1_2(vr_chave_399).tpplaseg := rw_crapseg.tpplaseg;
            vr_tab_399_1_2(vr_chave_399).nrdconta := rw_crapseg.nrdconta;
            vr_tab_399_1_2(vr_chave_399).nmdsegur := rw_crawseg.nmdsegur;
            vr_tab_399_1_2(vr_chave_399).vlpreseg := vr_vlpreseg;
            vr_tab_399_1_2(vr_chave_399).dtnascsg := rw_crawseg.dtnascsg;
            vr_tab_399_1_2(vr_chave_399).nrcpfcgc := rw_crawseg.nrcpfcgc;
            vr_tab_399_1_2(vr_chave_399).cdagenci := vr_tab_ass(rw_crapseg.nrdconta).cdagenci;
            vr_tab_399_1_2(vr_chave_399).nrctrseg := rw_crapseg.nrctrseg;
            vr_tab_399_1_2(vr_chave_399).dtinivig := rw_crapseg.dtinivig;
            vr_tab_399_1_2(vr_chave_399).dtfimvig := rw_crapseg.dtfimvig;
            vr_tab_399_1_2(vr_chave_399).dtcancel := rw_crapseg.dtcancel;
            vr_tab_399_1_2(vr_chave_399).vlseguro := rw_crawseg.vlseguro;
            vr_tab_399_1_2(vr_chave_399).nrdapoli := vr_nrdapoli;
            vr_tab_399_1_2(vr_chave_399).idseglcm := vr_idseglcm;
            -- Monta chave para pesquisa da cobertura do plano
            vr_chave_tsg := LPAD(rw_crapseg.tpseguro, 10, '0') || LPAD(rw_crapseg.tpplaseg, 10, '0') || LPAD(rw_crapseg.cdsegura, 10, '0');
            -- Busca descricao da cobertura do plano
            if vr_tab_tsg.exists(vr_chave_tsg) then
              vr_tab_399_1_2(vr_chave_399).dscobert := vr_tab_tsg(vr_chave_tsg).dsmorada;
            end if;
          end if;
        end if;
        -- Depois de 2004
        if vr_periodo = 2 then
          -- Ativos
          if vr_cdativo = 1 then
            vr_tab_399_2_1(vr_chave_399).cdativo := vr_cdativo;
            vr_tab_399_2_1(vr_chave_399).periodo := vr_periodo;
            vr_tab_399_2_1(vr_chave_399).tpplaseg := rw_crapseg.tpplaseg;
            vr_tab_399_2_1(vr_chave_399).nrdconta := rw_crapseg.nrdconta;
            vr_tab_399_2_1(vr_chave_399).nmdsegur := rw_crawseg.nmdsegur;
            vr_tab_399_2_1(vr_chave_399).vlpreseg := vr_vlpreseg;
            vr_tab_399_2_1(vr_chave_399).dtnascsg := rw_crawseg.dtnascsg;
            vr_tab_399_2_1(vr_chave_399).nrcpfcgc := rw_crawseg.nrcpfcgc;
            vr_tab_399_2_1(vr_chave_399).cdagenci := vr_tab_ass(rw_crapseg.nrdconta).cdagenci;
            vr_tab_399_2_1(vr_chave_399).nrctrseg := rw_crapseg.nrctrseg;
            vr_tab_399_2_1(vr_chave_399).dtinivig := rw_crapseg.dtinivig;
            vr_tab_399_2_1(vr_chave_399).dtfimvig := rw_crapseg.dtfimvig;
            vr_tab_399_2_1(vr_chave_399).dtcancel := rw_crapseg.dtcancel;
            vr_tab_399_2_1(vr_chave_399).vlseguro := rw_crawseg.vlseguro;
            vr_tab_399_2_1(vr_chave_399).nrdapoli := vr_nrdapoli;
            vr_tab_399_2_1(vr_chave_399).idseglcm := vr_idseglcm;
            -- Monta chave para pesquisa da cobertura do plano
            vr_chave_tsg := LPAD(rw_crapseg.tpseguro, 10, '0') || LPAD(rw_crapseg.tpplaseg, 10, '0') || LPAD(rw_crapseg.cdsegura, 10, '0');
            -- Busca descricao da cobertura do plano
            if vr_tab_tsg.exists(vr_chave_tsg) then
              vr_tab_399_2_1(vr_chave_399).dscobert := vr_tab_tsg(vr_chave_tsg).dsmorada;
            end if;
          end if;
          -- Cancelados depois de 2004
          if vr_cdativo = 2 then
            vr_tab_399_2_2(vr_chave_399).cdativo := vr_cdativo;
            vr_tab_399_2_2(vr_chave_399).periodo := vr_periodo;
            vr_tab_399_2_2(vr_chave_399).tpplaseg := rw_crapseg.tpplaseg;
            vr_tab_399_2_2(vr_chave_399).nrdconta := rw_crapseg.nrdconta;
            vr_tab_399_2_2(vr_chave_399).nmdsegur := rw_crawseg.nmdsegur;
            vr_tab_399_2_2(vr_chave_399).vlpreseg := vr_vlpreseg;
            vr_tab_399_2_2(vr_chave_399).dtnascsg := rw_crawseg.dtnascsg;
            vr_tab_399_2_2(vr_chave_399).nrcpfcgc := rw_crawseg.nrcpfcgc;
            vr_tab_399_2_2(vr_chave_399).cdagenci := vr_tab_ass(rw_crapseg.nrdconta).cdagenci;
            vr_tab_399_2_2(vr_chave_399).nrctrseg := rw_crapseg.nrctrseg;
            vr_tab_399_2_2(vr_chave_399).dtinivig := rw_crapseg.dtinivig;
            vr_tab_399_2_2(vr_chave_399).dtfimvig := rw_crapseg.dtfimvig;
            vr_tab_399_2_2(vr_chave_399).dtcancel := rw_crapseg.dtcancel;
            vr_tab_399_2_2(vr_chave_399).vlseguro := rw_crawseg.vlseguro;
            vr_tab_399_2_2(vr_chave_399).nrdapoli := vr_nrdapoli;
            vr_tab_399_2_2(vr_chave_399).idseglcm := vr_idseglcm;
            -- Monta chave para pesquisa da cobertura do plano
            vr_chave_tsg := LPAD(rw_crapseg.tpseguro, 10, '0') || LPAD(rw_crapseg.tpplaseg, 10, '0') || LPAD(rw_crapseg.cdsegura, 10, '0');
            -- Busca descricao da cobertura do plano
            if vr_tab_tsg.exists(vr_chave_tsg) then
              vr_tab_399_2_2(vr_chave_399).dscobert := vr_tab_tsg(vr_chave_tsg).dsmorada;
            end if;
          end if;
        end if;
        -- Fim crrl399

      -- Fim da listagem dos seguros
      end loop;

      -- Fecha cursor da listagem de seguros
      close cr_crapseg;

      -- Aqui as PlTables dos relatorios já estão com dados.

      -- Busca diretorio rl da cooperativa
      vr_dircoop := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                       ,pr_cdcooper => pr_cdcooper);

      -- Inicio da montagem do CLOB do crrl220
      declare
        -- Variaveis para auxilio na mudança de tipo de seguro no loop
        vr_novo_tpregist boolean;
        vr_dstpregist varchar2(20);
        vr_dstotpremi varchar2(40);
        vr_tem220 boolean := false;
      begin
        -- Limpa variavel temporaria
        vr_tmp_tpregis := 0;
        -- Inicializar o CLOB (XML)
        dbms_lob.createtemporary(vr_dsxmldad, TRUE);
        dbms_lob.open(vr_dsxmldad, dbms_lob.lob_readwrite);

        -- Escreve cabecalho padrao
        pc_escreve_clob('<?xml version="1.0" encoding="utf-8"?><raiz>');
        pc_escreve_clob(' <seguros>');
        pc_escreve_clob(' <mesrefe>' || vr_dsrefere || '</mesrefe>');

        -- Leitura da PlTable do crrl220
        vr_chave_220 := vr_tab_220.FIRST;
        loop
          -- Sai do loop quando nao encontrar proximo registro
          exit when vr_chave_220 is null;

          -- Verifica se mudou o tipo de registro
          vr_novo_tpregist := vr_tmp_tpregis <> vr_tab_220(vr_chave_220).tpregist;

          -- Alimenta indicador de que há registros
          vr_tem220 := true;

          -- Se mudou o tipo de registro, abre tag com novo tipo
          if vr_novo_tpregist then
            -- Carrega descricao do tipo
            CASE vr_tab_220(vr_chave_220).tpregist
              WHEN 1 THEN
                vr_dstpregist := 'PROPOSTAS NOVAS:';
                vr_dstotpremi := 'TOTAL DOS NOVOS PREMIOS';
              WHEN 2 THEN
                vr_dstpregist := 'ALTERACOES:';
                vr_dstotpremi := 'TOTAL DOS PREMIOS ALTERADOS';
              WHEN 3 THEN
                vr_dstpregist := 'CANCELAMENTOS:';
                vr_dstotpremi := 'TOTAL DOS PREMIOS CANCELADOS';
            END CASE;
            -- Fecha tag para abrir proxima
            if vr_tmp_tpregis <> 0 then
              pc_escreve_clob('</tpregist>');
            end if;
            pc_escreve_clob('<tpregist id = "' || vr_dstpregist || '" dstt = "'||vr_dstotpremi||'" >');
          end if;

          --Apenas cancelados que tenham debitos no mês
          IF (vr_tab_220(vr_chave_220).idseglcm = 1) OR
             (trim(to_char(vr_tab_220(vr_chave_220).dtcancel,'MM/YYYY')) IS NULL AND
              vr_tab_220(vr_chave_220).idseglcm = 0) THEN
            IF  vr_tab_220(vr_chave_220).nrdapoli = '6142149' THEN
              vr_vltoap01 := vr_vltoap01 + vr_tab_220(vr_chave_220).vlpreseg;
            ELSIF vr_tab_220(vr_chave_220).nrdapoli = '6077071' THEN
              vr_vltoap02 := vr_vltoap02 + vr_tab_220(vr_chave_220).vlpreseg;
            ELSIF vr_tab_220(vr_chave_220).nrdapoli = '6077070' THEN
              vr_vltoap03 := vr_vltoap03 + vr_tab_220(vr_chave_220).vlpreseg;
            ELSIF vr_tab_220(vr_chave_220).nrdapoli = '6077069' THEN
              vr_vltoap04 := vr_vltoap04 + vr_tab_220(vr_chave_220).vlpreseg;
            END IF;
          END IF;

          --Tags com dados dos seguros
          pc_escreve_clob(' <seguro>');

          pc_escreve_clob('<cdagenci>' || vr_tab_220(vr_chave_220).cdagenci || '</cdagenci>');
          pc_escreve_clob('<nrdconta>' || gene0002.fn_mask_conta(vr_tab_220(vr_chave_220).nrdconta) || '</nrdconta>');
          pc_escreve_clob('<nrctrseg>' || gene0002.fn_mask_contrato(vr_tab_220(vr_chave_220).nrctrseg) || '</nrctrseg>');
          pc_escreve_clob('<tpplaseg>' || vr_tab_220(vr_chave_220).tpplaseg || '</tpplaseg>');
          pc_escreve_clob('<dtdebito>' || to_char(vr_tab_220(vr_chave_220).dtdebito, 'dd') || '</dtdebito>');
          pc_escreve_clob('<vlpreseg>' || vr_tab_220(vr_chave_220).vlpreseg || '</vlpreseg>');
          pc_escreve_clob('<dtinivig>' || to_char(vr_tab_220(vr_chave_220).dtinivig,'DD/MM/RRRR') || '</dtinivig>');
          pc_escreve_clob('<nmprimtl>' || vr_tab_220(vr_chave_220).nmprimtl || '</nmprimtl>');
          pc_escreve_clob('<nrdapoli>' || vr_tab_220(vr_chave_220).nrdapoli || '</nrdapoli>');
          pc_escreve_clob('<idseglcm>' || vr_tab_220(vr_chave_220).idseglcm || '</idseglcm>');

          pc_escreve_clob(' </seguro>');

          -- Passa tpregist atual para ser comparado com o proximo
          vr_tmp_tpregis := vr_tab_220(vr_chave_220).tpregist;
          -- Pega chave do proximo registro
          vr_chave_220 := vr_tab_220.NEXT(vr_chave_220);
        end loop;

        -- Fecha tags do xml crrl220
        pc_escreve_clob('</tpregist>');
        -- Escreve totalizadores gerais de debitos
        pc_escreve_clob('<qttotdeb>' || vr_qttotdeb || '</qttotdeb>');
        pc_escreve_clob('<vltotdeb>' || vr_vltotdeb || '</vltotdeb>');
        pc_escreve_clob('<vltoap01>' || vr_vltoap01 || '</vltoap01>');
        pc_escreve_clob('<vltoap02>' || vr_vltoap02 || '</vltoap02>');
        pc_escreve_clob('<vltoap03>' || vr_vltoap03 || '</vltoap03>');
        pc_escreve_clob('<vltoap04>' || vr_vltoap04 || '</vltoap04>');
        pc_escreve_clob(' </seguros>');
        pc_escreve_clob('</raiz>');
        -- Fim do Clob do crrl220

        vr_vltoap01 := 0;
        vr_vltoap02 := 0;
        vr_vltoap03 := 0;
        vr_vltoap04 := 0;

        --Somente gera relatorio se houverem registros
        if vr_tem220 then
          --Busca destinatario do relatorio
          vr_emails := GENE0001.fn_param_sistema('CRED',pr_cdcooper,'CRRL220_EMAIL');

          -- Solicitando a geracao do crrl220
          GENE0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                      --> Cooperativa conectada
                                     ,pr_cdprogra  => vr_cdprogra                      --> Programa chamador
                                     ,pr_dtmvtolt  => rw_crapdat.dtmvtolt              --> Data do movimento atual
                                     ,pr_dsxml     => vr_dsxmldad                      --> Arquivo XML de dados
                                     ,pr_dsxmlnode => '/raiz/seguros/tpregist/seguro'  --> Nó do XML para iteração
                                     ,pr_dsjasper  => 'crrl220.jasper'                 --> Arquivo de layout do iReport
                                     ,pr_dsparams  => NULL                             --> Array de parametros diversos
                                     ,pr_dsarqsaid => vr_dircoop || '/rl/crrl220.lst'  --> Path/Nome do arquivo PDF gerado
                                     ,pr_flg_gerar => 'N'                              --> Gerar o arquivo na hora
                                     ,pr_qtcoluna  => 132                              --> Qtd colunas do relatório (80,132,234)
                                     ,pr_flg_impri=> 'S'                               --> Chamar a impressão (Imprim.p)
                                     ,pr_nrcopias  => 2                                --> Número de cópias para impressão
                                     ,pr_dsmailcop => vr_emails                        --> Lista sep. por ';' de emails para envio do relatório
                                     ,pr_dsassmail => 'ENVIO DE ARQUIVO MENSAL ' || rw_crapcop.nmrescop    --> Assunto do e-mail que enviará o relatório
                                     ,pr_dscormail => 'ARQUIVO EM ANEXO.'              --> HTML corpo do email que enviará o relatório
                                     ,pr_fldosmail => 'S'                               --> Conversar anexo para DOS antes de enviar
                                     ,pr_dscmaxmail => ' | tr -d "\032"'                --> Complemento do comando converte-arquivo
                                     ,pr_dsextmail => 'txt'                            --> Enviar o anexo como TXT
                                     ,pr_flgremarq => 'N'                              --> Flag para remover o arquivo após cópia/email
                                     ,pr_des_erro  => vr_dscritic);                    --> Saída com erro

          -- Liberando a memória alocada pro CLOB
          dbms_lob.close(vr_dsxmldad);
          dbms_lob.freetemporary(vr_dsxmldad);

          -- Verifica retorno de criticas na solicitacao
          if vr_dscritic is not null then
            raise vr_exc_saida;
          end if;
        else
          -- Liberando a memória alocada pro CLOB
          dbms_lob.close(vr_dsxmldad);
          dbms_lob.freetemporary(vr_dsxmldad);
        end if;
      -- Bloco de exception para montagem do crrl220
      exception
        when vr_exc_saida then
          raise vr_exc_saida;

        when others then
          vr_dscritic := 'Erro ao gerar relatorio crrl220: ' || sqlerrm;
          raise vr_exc_saida;
      -- Fim da geracao no crrl220
      end;

      -- Inicio da montagem do xml do crrl399
      begin
        -- Inicializar o CLOB (XML)
        dbms_lob.createtemporary(vr_dsxmldad, TRUE);
        dbms_lob.open(vr_dsxmldad, dbms_lob.lob_readwrite);

        -- Escreve cabecalho padrao
        pc_escreve_clob('<?xml version="1.0" encoding="utf-8"?><raiz>');
        -- Abertura das tags
        pc_escreve_clob(' <seguros>');
        pc_escreve_clob(' <mesrefe>' || vr_dsrefere || '</mesrefe>');

        -- Loop da PlTable do crrl399 periodo 1 cdativo 1
        pc_escreve_clob('<cdativo id_ativo = "'||'SEGUROS ATIVOS (CONTRATADOS ATE 30/11/2004)'||'">');

        -- Se houver registros na PlTable do filtro
        if vr_tab_399_1_1.count > 0 then
          -- Pega chave e inicia montagem do XML
          vr_chave_399 := vr_tab_399_1_1.FIRST;
          loop
            -- Sai do loop quando nao encontrar proximo registro
            exit when vr_chave_399 is null;

            --Apenas cancelados que tenham debitos no mês
            IF (vr_tab_399_1_1(vr_chave_399).idseglcm = 1) OR
               (trim(to_char(vr_tab_399_1_1(vr_chave_399).dtcancel,'MM/YYYY')) IS NULL  AND
                vr_tab_399_1_1(vr_chave_399).idseglcm = 0) THEN
              IF vr_tab_399_1_1(vr_chave_399).nrdapoli = '6142149' THEN
                vr_vltoap01 := vr_vltoap01 + vr_tab_399_1_1(vr_chave_399).vlpreseg;
              ELSIF vr_tab_399_1_1(vr_chave_399).nrdapoli = '6077071' THEN
                vr_vltoap02 := vr_vltoap02 + vr_tab_399_1_1(vr_chave_399).vlpreseg;
              ELSIF vr_tab_399_1_1(vr_chave_399).nrdapoli = '6077070' THEN
                vr_vltoap03 := vr_vltoap03 + vr_tab_399_1_1(vr_chave_399).vlpreseg;
              ELSIF vr_tab_399_1_1(vr_chave_399).nrdapoli = '6077069' THEN
                vr_vltoap04 := vr_vltoap04 + vr_tab_399_1_1(vr_chave_399).vlpreseg;
              END IF;
            END IF;

            pc_escreve_clob(' <seguro>');

            pc_escreve_clob(' <tpplaseg>' || vr_tab_399_1_1(vr_chave_399).tpplaseg || '</tpplaseg>');
            pc_escreve_clob(' <nrdconta>' || gene0002.fn_mask_conta(vr_tab_399_1_1(vr_chave_399).nrdconta) || '</nrdconta>');
            pc_escreve_clob(' <nmdsegur>' || vr_tab_399_1_1(vr_chave_399).nmdsegur || '</nmdsegur>');
            pc_escreve_clob(' <vlmorada>' || vr_tab_399_1_1(vr_chave_399).vlseguro || '</vlmorada>');
            pc_escreve_clob(' <vlpreseg>' || vr_tab_399_1_1(vr_chave_399).vlpreseg || '</vlpreseg>');
            pc_escreve_clob(' <dtnascsg>' || to_char(vr_tab_399_1_1(vr_chave_399).dtnascsg,'DD/MM/RRRR') || '</dtnascsg>');
            pc_escreve_clob(' <nrcpfcgc>' || vr_tab_399_1_1(vr_chave_399).nrcpfcgc || '</nrcpfcgc>');
            pc_escreve_clob(' <cdagenci>' || vr_tab_399_1_1(vr_chave_399).cdagenci || '</cdagenci>');
            pc_escreve_clob(' <nrctrseg>' || gene0002.fn_mask_contrato(vr_tab_399_1_1(vr_chave_399).nrctrseg) || '</nrctrseg>');
            pc_escreve_clob(' <dtinivig>' || to_char(vr_tab_399_1_1(vr_chave_399).dtinivig,'DD/MM/RRRR') || '</dtinivig>');
            pc_escreve_clob(' <dtfimvig>' || to_char(vr_tab_399_1_1(vr_chave_399).dtfimvig,'DD/MM/RRRR') || '</dtfimvig>');
            pc_escreve_clob(' <dtcancel>' || to_char(vr_tab_399_1_1(vr_chave_399).dtcancel,'DD/MM/RRRR') || '</dtcancel>');
            pc_escreve_clob(' <dscobert>' || substr(vr_tab_399_1_1(vr_chave_399).dscobert, 0, 30) || '</dscobert>');
            pc_escreve_clob(' <nrdapoli>' || vr_tab_399_1_1(vr_chave_399).nrdapoli || '</nrdapoli>');
            pc_escreve_clob(' <idseglcm>' || vr_tab_399_1_1(vr_chave_399).idseglcm || '</idseglcm>');

            pc_escreve_clob(' </seguro>');

            -- Pega chave do proximo registro
            vr_chave_399 := vr_tab_399_1_1.NEXT(vr_chave_399);
          end loop;
        else
          -- Se não encontrar registros na PlTable do filtro, insere tag vazia para constar no relatorio
          pc_escreve_clob('<seguro/>');
        end if;
        -- Fechamento da tag
        pc_escreve_clob('</cdativo>');

        -- Loop da PlTable do crrl399 periodo 1 cdativo 2
        pc_escreve_clob('<cdativo id_ativo = "' || 'SEGUROS CANCELADOS (CONTRATADOS ATE 30/11/2004)' || '">');

        if vr_tab_399_1_2.count > 0 then
          vr_chave_399 := vr_tab_399_1_2.FIRST;
          loop
            -- Sai do loop quando nao encontrar proximo registro
            exit when vr_chave_399 is null;

            --Apenas cancelados que tenham debitos no mês
            IF (vr_tab_399_1_2(vr_chave_399).idseglcm = 1) OR
               (trim(to_char(vr_tab_399_1_2(vr_chave_399).dtcancel,'MM/YYYY')) IS NULL AND
                vr_tab_399_1_2(vr_chave_399).idseglcm = 0) THEN
              IF vr_tab_399_1_2(vr_chave_399).nrdapoli = '6142149' THEN
                vr_vltoap01 := vr_vltoap01 + vr_tab_399_1_2(vr_chave_399).vlpreseg;
              ELSIF vr_tab_399_1_2(vr_chave_399).nrdapoli = '6077071' THEN
                vr_vltoap02 := vr_vltoap02 + vr_tab_399_1_2(vr_chave_399).vlpreseg;
              ELSIF vr_tab_399_1_2(vr_chave_399).nrdapoli = '6077070' THEN
                vr_vltoap03 := vr_vltoap03 + vr_tab_399_1_2(vr_chave_399).vlpreseg;
              ELSIF vr_tab_399_1_2(vr_chave_399).nrdapoli = '6077069' THEN
                vr_vltoap04 := vr_vltoap04 + vr_tab_399_1_2(vr_chave_399).vlpreseg;
              END IF;
            END IF;

            pc_escreve_clob(' <seguro>');

            pc_escreve_clob(' <tpplaseg>' || vr_tab_399_1_2(vr_chave_399).tpplaseg || '</tpplaseg>');
            pc_escreve_clob(' <nrdconta>' || gene0002.fn_mask_conta(vr_tab_399_1_2(vr_chave_399).nrdconta) || '</nrdconta>');
            pc_escreve_clob(' <nmdsegur>' || vr_tab_399_1_2(vr_chave_399).nmdsegur || '</nmdsegur>');
            pc_escreve_clob(' <vlmorada>' || vr_tab_399_1_2(vr_chave_399).vlseguro || '</vlmorada>');
            pc_escreve_clob(' <vlpreseg>' || vr_tab_399_1_2(vr_chave_399).vlpreseg || '</vlpreseg>');
            pc_escreve_clob(' <dtnascsg>' || to_char(vr_tab_399_1_2(vr_chave_399).dtnascsg,'DD/MM/RRRR') || '</dtnascsg>');
            pc_escreve_clob(' <nrcpfcgc>' || vr_tab_399_1_2(vr_chave_399).nrcpfcgc || '</nrcpfcgc>');
            pc_escreve_clob(' <cdagenci>' || vr_tab_399_1_2(vr_chave_399).cdagenci || '</cdagenci>');
            pc_escreve_clob(' <nrctrseg>' || gene0002.fn_mask_contrato(vr_tab_399_1_2(vr_chave_399).nrctrseg) || '</nrctrseg>');
            pc_escreve_clob(' <dtinivig>' || to_char(vr_tab_399_1_2(vr_chave_399).dtinivig,'DD/MM/RRRR') || '</dtinivig>');
            pc_escreve_clob(' <dtfimvig>' || to_char(vr_tab_399_1_2(vr_chave_399).dtfimvig,'DD/MM/RRRR') || '</dtfimvig>');
            pc_escreve_clob(' <dtcancel>' || to_char(vr_tab_399_1_2(vr_chave_399).dtcancel,'DD/MM/RRRR') || '</dtcancel>');
            pc_escreve_clob(' <dscobert>' || substr(vr_tab_399_1_2(vr_chave_399).dscobert, 0, 30) || '</dscobert>');
            pc_escreve_clob(' <nrdapoli>' || vr_tab_399_1_2(vr_chave_399).nrdapoli || '</nrdapoli>');
            pc_escreve_clob(' <idseglcm>' || vr_tab_399_1_2(vr_chave_399).idseglcm || '</idseglcm>');

            pc_escreve_clob(' </seguro>');

            -- Pega chave do proximo registro
            vr_chave_399 := vr_tab_399_1_2.NEXT(vr_chave_399);
          end loop;
        else
          pc_escreve_clob(' <seguro/>');
        end if;
        -- Fechamento da tag
        pc_escreve_clob('</cdativo>');

        -- Loop da PlTable do crrl399 periodo 2 cdativo 1
        pc_escreve_clob('<cdativo id_ativo = "' || 'SEGUROS ATIVOS (CONTRATADOS A PARTIR DE 01/12/2004)' || '">');

        if vr_tab_399_2_1.count > 0 then
          vr_chave_399 := vr_tab_399_2_1.FIRST;
          loop
            -- Sai do loop quando nao encontrar proximo registro
            exit when vr_chave_399 is null;

            --Apenas cancelados que tenham debitos no mês
            IF (vr_tab_399_2_1(vr_chave_399).idseglcm = 1) OR
               (trim(to_char(vr_tab_399_2_1(vr_chave_399).dtcancel,'MM/YYYY')) IS NULL AND
                vr_tab_399_2_1(vr_chave_399).idseglcm = 0) THEN
              IF vr_tab_399_2_1(vr_chave_399).nrdapoli = '6142149' THEN
                vr_vltoap01 := vr_vltoap01 + vr_tab_399_2_1(vr_chave_399).vlpreseg;
              ELSIF vr_tab_399_2_1(vr_chave_399).nrdapoli = '6077071' THEN
                vr_vltoap02 := vr_vltoap02 + vr_tab_399_2_1(vr_chave_399).vlpreseg;
              ELSIF vr_tab_399_2_1(vr_chave_399).nrdapoli = '6077070' THEN
                vr_vltoap03 := vr_vltoap03 + vr_tab_399_2_1(vr_chave_399).vlpreseg;
              ELSIF vr_tab_399_2_1(vr_chave_399).nrdapoli = '6077069' THEN
                vr_vltoap04 := vr_vltoap04 + vr_tab_399_2_1(vr_chave_399).vlpreseg;
              END IF;
            END IF;

            pc_escreve_clob(' <seguro>');

            pc_escreve_clob(' <tpplaseg>' || vr_tab_399_2_1(vr_chave_399).tpplaseg || '</tpplaseg>');
            pc_escreve_clob(' <nrdconta>' || gene0002.fn_mask_conta(vr_tab_399_2_1(vr_chave_399).nrdconta) || '</nrdconta>');
            pc_escreve_clob(' <nmdsegur>' || vr_tab_399_2_1(vr_chave_399).nmdsegur || '</nmdsegur>');
            pc_escreve_clob(' <vlmorada>' || vr_tab_399_2_1(vr_chave_399).vlseguro || '</vlmorada>');
            pc_escreve_clob(' <vlpreseg>' || vr_tab_399_2_1(vr_chave_399).vlpreseg || '</vlpreseg>');
            pc_escreve_clob(' <dtnascsg>' || to_char(vr_tab_399_2_1(vr_chave_399).dtnascsg,'DD/MM/RRRR') || '</dtnascsg>');
            pc_escreve_clob(' <nrcpfcgc>' || vr_tab_399_2_1(vr_chave_399).nrcpfcgc || '</nrcpfcgc>');
            pc_escreve_clob(' <cdagenci>' || vr_tab_399_2_1(vr_chave_399).cdagenci || '</cdagenci>');
            pc_escreve_clob(' <nrctrseg>' || gene0002.fn_mask_contrato(vr_tab_399_2_1(vr_chave_399).nrctrseg) || '</nrctrseg>');
            pc_escreve_clob(' <dtinivig>' || to_char(vr_tab_399_2_1(vr_chave_399).dtinivig,'DD/MM/RRRR') || '</dtinivig>');
            pc_escreve_clob(' <dtfimvig>' || to_char(vr_tab_399_2_1(vr_chave_399).dtfimvig,'DD/MM/RRRR') || '</dtfimvig>');
            pc_escreve_clob(' <dtcancel>' || to_char(vr_tab_399_2_1(vr_chave_399).dtcancel,'DD/MM/RRRR') || '</dtcancel>');
            pc_escreve_clob(' <dscobert>' || substr(vr_tab_399_2_1(vr_chave_399).dscobert, 0, 30) || '</dscobert>');
            pc_escreve_clob(' <nrdapoli>' || vr_tab_399_2_1(vr_chave_399).nrdapoli || '</nrdapoli>');
            pc_escreve_clob(' <idseglcm>' || vr_tab_399_2_1(vr_chave_399).idseglcm || '</idseglcm>');


            pc_escreve_clob(' </seguro>');

            -- Pega chave do proximo registro
            vr_chave_399 := vr_tab_399_2_1.NEXT(vr_chave_399);
          end loop;
        else
          pc_escreve_clob(' <seguro/>');
        end if;
        -- Fechamento da tag
        pc_escreve_clob('</cdativo>');

        -- Loop da PlTable do crrl399 periodo 2 cdativo 2
        pc_escreve_clob('<cdativo id_ativo = "' || 'SEGUROS CANCELADOS (CONTRATADOS A PARTIR DE 01/12/2004)' || '">');

        if vr_tab_399_2_2.count > 0 then
          vr_chave_399 := vr_tab_399_2_2.FIRST;
          loop
            -- Sai do loop quando nao encontrar proximo registro
            exit when vr_chave_399 is null;

            --Apenas cancelados que tenham debitos no mês
            IF (vr_tab_399_2_2(vr_chave_399).idseglcm = 1) OR
               (trim(to_char(vr_tab_399_2_2(vr_chave_399).dtcancel,'MM/YYYY')) IS NULL AND
                vr_tab_399_2_2(vr_chave_399).idseglcm = 0) THEN
              IF vr_tab_399_2_2(vr_chave_399).nrdapoli = '6142149' THEN
                vr_vltoap01 := vr_vltoap01 + vr_tab_399_2_2(vr_chave_399).vlpreseg;
              ELSIF vr_tab_399_2_2(vr_chave_399).nrdapoli = '6077071' THEN
                vr_vltoap02 := vr_vltoap02 + vr_tab_399_2_2(vr_chave_399).vlpreseg;
              ELSIF vr_tab_399_2_2(vr_chave_399).nrdapoli = '6077070' THEN
                vr_vltoap03 := vr_vltoap03 + vr_tab_399_2_2(vr_chave_399).vlpreseg;
              ELSIF vr_tab_399_2_2(vr_chave_399).nrdapoli = '6077069' THEN
                vr_vltoap04 := vr_vltoap04 + vr_tab_399_2_2(vr_chave_399).vlpreseg;
              END IF;
            END IF;

            pc_escreve_clob(' <seguro>');

            pc_escreve_clob(' <tpplaseg>' || vr_tab_399_2_2(vr_chave_399).tpplaseg || '</tpplaseg>');
            pc_escreve_clob(' <nrdconta>' || gene0002.fn_mask_conta(vr_tab_399_2_2(vr_chave_399).nrdconta) || '</nrdconta>');
            pc_escreve_clob(' <nmdsegur>' || vr_tab_399_2_2(vr_chave_399).nmdsegur || '</nmdsegur>');
            pc_escreve_clob(' <vlmorada>' || vr_tab_399_2_2(vr_chave_399).vlseguro || '</vlmorada>');
            pc_escreve_clob(' <vlpreseg>' || vr_tab_399_2_2(vr_chave_399).vlpreseg || '</vlpreseg>');
            pc_escreve_clob(' <dtnascsg>' || to_char(vr_tab_399_2_2(vr_chave_399).dtnascsg,'DD/MM/RRRR') || '</dtnascsg>');
            pc_escreve_clob(' <nrcpfcgc>' || vr_tab_399_2_2(vr_chave_399).nrcpfcgc || '</nrcpfcgc>');
            pc_escreve_clob(' <cdagenci>' || vr_tab_399_2_2(vr_chave_399).cdagenci || '</cdagenci>');
            pc_escreve_clob(' <nrctrseg>' || gene0002.fn_mask_contrato(vr_tab_399_2_2(vr_chave_399).nrctrseg) || '</nrctrseg>');
            pc_escreve_clob(' <dtinivig>' || to_char(vr_tab_399_2_2(vr_chave_399).dtinivig,'DD/MM/RRRR') || '</dtinivig>');
            pc_escreve_clob(' <dtfimvig>' || to_char(vr_tab_399_2_2(vr_chave_399).dtfimvig,'DD/MM/RRRR') || '</dtfimvig>');
            pc_escreve_clob(' <dtcancel>' || to_char(vr_tab_399_2_2(vr_chave_399).dtcancel,'DD/MM/RRRR') || '</dtcancel>');
            pc_escreve_clob(' <dscobert>' || substr(vr_tab_399_2_2(vr_chave_399).dscobert, 0, 30) || '</dscobert>');
            pc_escreve_clob(' <nrdapoli>' || vr_tab_399_2_2(vr_chave_399).nrdapoli || '</nrdapoli>');
            pc_escreve_clob(' <idseglcm>' || vr_tab_399_2_2(vr_chave_399).idseglcm || '</idseglcm>');

            pc_escreve_clob(' </seguro>');

            -- Pega chave do proximo registro
            vr_chave_399 := vr_tab_399_2_2.NEXT(vr_chave_399);
          end loop;
        else
          pc_escreve_clob(' <seguro/>');
        end if;

        -- Fechamento de tags
        pc_escreve_clob('</cdativo>');
        pc_escreve_clob('<vltoap01>' || vr_vltoap01 || '</vltoap01>');
        pc_escreve_clob('<vltoap02>' || vr_vltoap02 || '</vltoap02>');
        pc_escreve_clob('<vltoap03>' || vr_vltoap03 || '</vltoap03>');
        pc_escreve_clob('<vltoap04>' || vr_vltoap04 || '</vltoap04>');
        pc_escreve_clob(' </seguros>');
        pc_escreve_clob('</raiz>');

        -- Buscando destinatarios
        vr_emails := GENE0001.fn_param_sistema('CRED',pr_cdcooper,'CRRL399_EMAIL');

        -- Solicitando email do crrl399
         GENE0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                       --> Cooperativa conectada
                                    ,pr_cdprogra  => vr_cdprogra                      --> Programa chamador
                                    ,pr_dtmvtolt  => rw_crapdat.dtmvtolt              --> Data do movimento atual
                                    ,pr_dsxml     => vr_dsxmldad                      --> Arquivo XML de dados
                                    ,pr_dsxmlnode => '/raiz/seguros/cdativo/seguro'   --> Nó do XML para iteração
                                    ,pr_dsjasper  => 'crrl399.jasper'                 --> Arquivo de layout do iReport
                                    ,pr_dsparams  => NULL                             --> Array de parametros diversos
                                    ,pr_dsarqsaid => vr_dircoop || '/rl/crrl399.lst'  --> Path/Nome do arquivo PDF gerado
                                    ,pr_flg_gerar => 'N'                              --> Gerar o arquivo na hora
                                    ,pr_qtcoluna  => 234                              --> Qtd colunas do relatório (80,132,234)
                                    ,pr_sqcabrel  => 2                                --> Sequencia do relatorio (cabrel 1..5)
                                    ,pr_flg_impri=> 'S'                               --> Chamar a impressão (Imprim.p)
                                    ,pr_nrcopias  => 1                                --> Número de cópias para impressão
                                    ,pr_nmformul  => '234dh'                          --> Nome do formulário para impressão
                                    ,pr_dsmailcop => vr_emails                        --> Lista sep. por ';' de emails para envio do relatório
                                    ,pr_fldosmail => 'S'                               --> Conversar anexo para DOS antes de enviar
                                    ,pr_dscmaxmail => ' | tr -d "\032"'                --> Complemento do comando converte-arquivo
                                    ,pr_dsextmail => 'txt'                            --> Anexar como txt
                                    ,pr_dsassmail => 'ENVIO DE ARQUIVO MENSAL GERAL ' || rw_crapcop.nmrescop    --> Assunto do e-mail que enviará o relatório
                                    ,pr_dscormail => 'ARQUIVO EM ANEXO.'              --> HTML corpo do email que enviará o relatório
                                    ,pr_flgremarq => 'N'                             --> Flag para remover o arquivo após cópia/email
                                    ,pr_des_erro  => vr_dscritic);                    --> Saída com erro

        -- Liberando a memória alocada pro CLOB
        dbms_lob.close(vr_dsxmldad);
        dbms_lob.freetemporary(vr_dsxmldad);

        -- Verifica retorno de erro da solicitacao de relatorio
        if vr_dscritic is not null then
          raise vr_exc_saida;
        end if;
      -- Bloco de exception para geracao do crrl399
      exception
       when vr_exc_saida then
         raise vr_exc_saida;

       when others then
          vr_dscritic := 'Erro ao gerar relatorio crrl399: ' || sqlerrm;
          raise vr_exc_saida;
      -- Fim do xml crrl399
      end;

      -- Inicio da geracao do arquivo da herco
      declare
        -- declarando handle do arquivo
        vr_arq_herco utl_file.file_type;
      begin
        -- Abrindo o arquivo em modo W (Limpa o arquivo antes de usar)
        gene0001.pc_abre_arquivo(pr_nmdireto => vr_dircoop || '/arq' --> Diretório do arquivo
                                ,pr_nmarquiv => 'ccohvida.txt'       --> Nome do arquivo
                                ,pr_tipabert => 'W'                  --> Modo de abertura (R,W,A)
                                ,pr_utlfileh => vr_arq_herco         --> Handle do arquivo aberto
                                ,pr_des_erro => vr_dscritic);        --> Erro

        -- Pega primeira chave da PlTable
        vr_chave_herco := vr_tab_herco.FIRST;

        -- Leitura da PlTable do aruqivo para herco
        loop
          -- sai do loop quando a chave vier nula
          exit when vr_chave_herco is null;

          -- Insere linha no arquivo
          gene0001.pc_escr_linha_arquivo(vr_arq_herco,GENE0002.fn_mask(vr_tab_herco(vr_chave_herco).cdagenci, '999')||
                                                      to_char(vr_tab_herco(vr_chave_herco).nrdconta, '00000000')||
                                                      to_char(vr_tab_herco(vr_chave_herco).nrctrseg, '00000000')||
                                                      to_char(vr_tab_herco(vr_chave_herco).tpplaseg, '000')|| ' ' ||
                                                      to_char(vr_tab_herco(vr_chave_herco).dtdebito, 'dd')||
                                                      to_char(vr_tab_herco(vr_chave_herco).vlpreseg, '0000000000D00'));


          -- Pega proxima chave
          vr_chave_herco := vr_tab_herco.next(vr_chave_herco);
        end loop;
        -- Fecha o arquivo
        gene0001.pc_fecha_arquivo(pr_utlfileh => vr_arq_herco); --> Handle do arquivo aberto;

        --Copiar arquivo para a pasta salvar
        gene0001.pc_oscommand_shell('cp '|| vr_dircoop||'/arq/ccohvida.txt '||vr_dircoop||'/salvar/');

      -- Bloco de exception da geracao do arquivo para herco
      exception
        when others then
          vr_dscritic := 'Erro ao gerar relatorio para herco: ' || sqlerrm;
          raise vr_exc_saida;
      -- Fim do arquivo da herco
      end;

    -- Fim controle restart
    end if;

    -- Atualização do controle de restart
    open cr_crapres;
      fetch cr_crapres
       into rw_crapres;
    -- Se não encontrar
    if cr_crapres%NOTFOUND then
      -- Fechar o cursor e gerar erro
      close cr_crapres;
      -- Montar mensagem de erro
      vr_cdcritic := 151;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 151);
      raise vr_exc_saida;
    else
      -- Atualiza o registro
      begin
        UPDATE crapres
           SET nrdconta = 1
         WHERE rowid = rw_crapres.rowid;
        -- Comita o update
        -- commit; -- NÃO DEVE-SE COMITAR A CADA UPDATE.
        -- Fecha o cursor
        close cr_crapres;
      exception
        when others then
          close cr_crapres;
          vr_dscritic :=  'Erro ao atualizar controle de restart: ' || sqlerrm;
          raise vr_exc_saida;
      end;
    end if;

    -- Atualiza os registro de seguro
    begin
      UPDATE crapseg
         SET indebito = 0
       WHERE cdcooper = pr_cdcooper AND
             cdsitseg = 1 AND -- Situacao do seguro: 1 - Ativo 2 - Cancelado
             tpseguro = 3; -- Seguro de vida
    exception
      when others then
        vr_dscritic := 'Erro ao atualizar registros de Seguro: ' || sqlerrm;
        raise vr_exc_saida;
    end;

    -- Rotina para remover o restart
    btch0001.pc_elimina_restart(pr_cdcooper => pr_cdcooper   --> Cooperativa conectada
                               ,pr_cdprogra => vr_cdprogra   --> Código do programa
                               ,pr_flgresta => pr_flgresta   --> Indicador de restart
                               ,pr_des_erro => vr_dscritic); --> Saída de erro
    -- Testar saída de erro
    IF vr_dscritic IS NOT NULL THEN
      -- Sair do processo
      RAISE vr_exc_saida;
    END IF;

    -- Comita as alteracoes no banco
    COMMIT;

    -- Fim da regra de negocio
  -- Bloco de exception do programa
  EXCEPTION
    WHEN vr_exc_fimprg THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
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
      -- Efetuar commit
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
END PC_CRPS270;
/
