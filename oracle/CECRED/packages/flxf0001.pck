CREATE OR REPLACE PACKAGE CECRED.flxf0001 AS

  /*-------------------------------------------------------------------------------------------------------------

    Programa: FLXF0001                        Antiga: sistema/generico/procedures/b1wgen0131.p
    Autor   : Gabriel Capoia (DB1)
    Data    : Dezembro/2011                     Ultima Atualizacao: 06/10/2016

    Dados referentes ao programa:

    Objetivo  : Tranformacao BO tela PREVIS

    Alteracoes: 13/08/2012 - Ajustes referente ao projeto Fluxo Financeiro
                             (Adriano).

                21/11/2012 - Ajustes comentar a critica na opção "L" referente
                             a datas futuras não existia antes está critica e
                             o financeiro usa data futuras (Oscar).

                12/12/2012 - Tornar o campo do Mvto.Cta.ITG habilitado para
                             edição (Lucas).

                14/03/2013 - O campo Mvto.Cta.ITG passa a ser calculado
                             atraves de projecao (Adriano).

                28/03/2013 - Adicionado parametro para a procedure
                             'consulta_faturas' (Lucas).

                28/03/2013 - Ajuste na leitura da craplcm na procedure
                             pi rec transf dep intercoop_f (Gabriel).

                08/11/2013 - Conversao Progress para oracle (Odirlei-AMcom )

                22/10/2013 - Ajuste calculo movitação da conta itg (Oscar).

                14/11/2013 - Ajuste na procedure "pi_sr_cheques_f" para enviar
                             a cooperativa que veio como parametro na chamada
                             da funcao "fnRetornaProximaDataUtil". (James)

                30/12/2013 - Correcao da procedure pi_rec_mov_conta_itg_f a qual
                             nao estava zerando a variavel aux_maiorvlr (Daniel).

                24/01/2014 - Alteracao no FIND LAST tt-per-datas (Oscar).

                20/02/2014 - Conversão para PLSQL das alterações de 12/2013 e 01/2014 (Daniel - Supero)

                24/01/2014 - Alteracao no FIND LASTtt-per-datas (Oscar)

                06/10/2016 - SD 489677 - Inclusao do flgativo na CRAPLGP (Guilherme/SUPERO)

  -------------------------------------------------------------------------------------------------------------*/

  --criação TempTable
  /* Type de registros para armazenar os valores dos periodos*/
  TYPE typ_reg_per_datas IS
      RECORD (cdagrupa NUMBER
             ,nrsequen NUMBER
             ,dtmvtolt DATE
             ,vlrtotal NUMBER);

  /* Definicao de tabela que compreende os registros acima declarados */
  TYPE typ_tab_per_datas IS
    TABLE OF typ_reg_per_datas
    INDEX BY varchar2(12);-- cdagrup (3) + dt(8) formato DDMMRRRR

  TYPE typ_tab_datas  is
    table of INTEGER  INDEX BY varchar2(8);-- dt(8) formato DDMMRRRR

  TYPE typ_tab_ValDia is
    varray(31) of PLS_INTEGER;

  /* Type de registros para armazenar as informações de fluxo financeiro*/
  TYPE typ_reg_ffin_mvto_sing IS
      RECORD (cdbcoval INTEGER,
              tpdmovto INTEGER,
              vlcheque NUMBER,
              vltotdoc NUMBER,
              vltotted NUMBER,
              vltottit NUMBER,
              vldevolu NUMBER,
              vlmvtitg NUMBER,
              vlttinss NUMBER,
              vltrdeit NUMBER,
              vlsatait NUMBER,
              vlfatbra NUMBER,
              vlconven NUMBER,
              vlrepass NUMBER,
              vlnumera NUMBER,
              vlrfolha NUMBER,
              vldivers NUMBER,
              vlttcrdb NUMBER,
              vloutros NUMBER);

  TYPE typ_tab_ffin_mvto_sing  IS
    TABLE OF typ_reg_ffin_mvto_sing  INDEX BY varchar2(3);-- CdBanco(3)

  -- Procedure para gravar movimentação de fluxo financeiro
  PROCEDURE pc_grava_movimentacao   (pr_cdcooper IN INTEGER      -- Codigo da Cooperativa
                                    ,pr_cdoperad IN crapope.cdoperad%type      -- Codigo do operador
                                    ,pr_dtmvtolt IN DATE         -- Data de movimento
                                    ,pr_tpdmovto IN INTEGER      -- Tipo de movimento
                                    ,pr_cdbccxlt IN NUMBER       -- Codigo do banco/caixa.
                                    ,pr_tpdcampo IN NUMBER       -- Tipo de campo
                                    ,pr_vldcampo IN NUMBER       -- Valor do campo
                                    ,pr_dscritic OUT VARCHAR2);  -- Descrição da critica

  -- Procedure para Verificar se o dia é feriado
  FUNCTION fn_verifica_feriado( pr_cdcooper in number   -- codigo da cooperativa
                               ,pr_dtrefmes in date     -- Data referencia
                                ) return boolean;

  -- Procedure para Buscar proximo sequecia para a tabela de periodo de datas
  FUNCTION fn_ret_prox_sequencia ( pr_tab_per_datas IN typ_tab_per_datas) -- Tabela de datas
                                           return number;

  -- Procedure para Validar a regra de media de dia util
  FUNCTION fn_valid_Media_Dia_Util_Semana ( pr_nrdiasme in varchar2 -- numero que representa o dia do mes
                                           ,pr_nrdiasse in varchar2 -- numero que representa o dia da semana
                                           ,pr_dtperiod in date     -- Data referencia
                                           ,pr_cdcooper in number   -- codigo da cooperativa
                                           ,pr_tipodoct in varchar2 -- Tipo de documento (C-Cheque,T-Titulo-I-Conta Integração )
                                            )
                                          return boolean;

  -- Procedure para gravar movimento do fluxo financeiro
  PROCEDURE pc_grava_fluxo_financeiro ( pr_cdcooper  IN INTEGER      -- Codigo da Cooperativa
                                       ,pr_cdagenci  IN INTEGER      -- Codigo da agencia
                                       ,pr_nrdcaixa  IN INTEGER      -- Numero da caixa
                                       ,pr_cdoperad  IN crapope.cdoperad%type     -- Codigo do operador
                                       ,pr_dtmvtolt  IN DATE         -- Data de movimento
                                       ,pr_nmdatela  IN VARCHAR2     -- Nome da tela
                                       ,pr_cdcoopex  IN INTEGER      -- Codigo da Cooperativa
                                       ,pr_dtmvtoan  IN DATE         -- Data de movimento anterior
                                       ,pr_cdagefim  IN INTEGER      -- Codigo da agencia
                                       ,pr_tab_erro OUT GENE0001.typ_tab_erro -- Tabela contendo os erros
                                       ,pr_dscritic OUT VARCHAR2);   -- Descrição da critica

  -- Procedure para gravar movimento financeiro dos titulos
  PROCEDURE pc_grava_mvt_titulos  ( pr_cdcooper IN INTEGER      -- Codigo da Cooperativa
                                   ,pr_cdagenci IN INTEGER      -- Codigo da agencia
                                   ,pr_nrdcaixa IN INTEGER      -- Numero da caixa
                                   ,pr_cdoperad IN crapope.cdoperad%type     -- Codigo do operador
                                   ,pr_dtmvtolt IN DATE         -- Data de movimento
                                   ,pr_nmdatela IN VARCHAR2     -- Nome da tela
                                   ,pr_dtmvtoan IN DATE         -- Data de movimento anterior
                                   ,pr_cdcoopex IN VARCHAR2     -- Codigo da Cooperativa
                                   ,pr_calcproj IN BOOLEAN      -- Identificador se calcula projeção
                                   ,pr_tab_erro OUT GENE0001.typ_tab_erro -- Tabela contendo os erros
                                   ,pr_dscritic OUT VARCHAR2);  -- Descrição da critica

  -- Procedure para gravar movimento financeiro dos docs
  PROCEDURE pc_grava_mvt_doc  ( pr_cdcooper IN INTEGER      -- Codigo da Cooperativa
                               ,pr_cdagenci IN INTEGER      -- Codigo da agencia
                               ,pr_nrdcaixa IN INTEGER      -- Numero da caixa
                               ,pr_cdoperad IN crapope.cdoperad%type     -- Codigo do operador
                               ,pr_dtmvtolt IN DATE         -- Data de movimento
                               ,pr_nmdatela IN VARCHAR2     -- Nome da tela
                               ,pr_tab_erro OUT GENE0001.typ_tab_erro -- Tabela contendo os erros
                               ,pr_dscritic OUT VARCHAR2);  -- Descrição da critica

  -- Procedure para gravar movimento financeiro de cheques saida
  PROCEDURE pc_grava_mvt_cheques  ( pr_cdcooper IN INTEGER      -- Codigo da Cooperativa
                                   ,pr_cdagenci IN INTEGER      -- Codigo da agencia
                                   ,pr_nrdcaixa IN INTEGER      -- Numero da caixa
                                   ,pr_cdoperad IN crapope.cdoperad%type     -- Codigo do operador
                                   ,pr_dtmvtolt IN DATE         -- Data de movimento
                                   ,pr_nmdatela IN VARCHAR2     -- Nome da tela
                                   ,pr_tab_erro OUT GENE0001.typ_tab_erro -- Tabela contendo os erros
                                   ,pr_dscritic OUT VARCHAR2);

  -- Procedure para gravar movimento financeiro das contas Itg
  PROCEDURE pc_grava_mvt_conta_itg  ( pr_cdcooper IN INTEGER      -- Codigo da Cooperativa
                                     ,pr_cdagenci IN INTEGER      -- Codigo da agencia
                                     ,pr_nrdcaixa IN INTEGER      -- Numero da caixa
                                     ,pr_cdoperad IN crapope.cdoperad%type     -- Codigo do operador
                                     ,pr_dtmvtolt IN DATE         -- Data de movimento
                                     ,pr_nmdatela IN VARCHAR2     -- Nome da tela
                                     ,pr_tpdmovto IN NUMBER       -- tipo de movimento(1-entrada 2-saida)
                                     ,pr_cdcoopex IN VARCHAR2     -- Codigo da Cooperativa
                                     ,pr_dscritic OUT VARCHAR2);  -- Descrição da critica

  -- Procedure para Verificar se o dia til anterior é feriado
  FUNCTION fn_feriado_dia_anterior ( pr_cdcooper in number -- codigo da cooperativa
                                    ,pr_dtrefmes in date ) -- Data atual
                                          return boolean;

  -- Função para validar a quantidade de dias uteis do mes
  FUNCTION fn_Valida_Dias_Uteis_Mes( pr_cdcooper in number,  -- codigo da cooperativa
                                     pr_dtdatmes IN DATE)   -- Data do periodo
           RETURN BOOLEAN;
END FLXF0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.flxf0001 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa: FLXF0001                        Antiga: sistema/generico/procedures/b1wgen0131.p
  --  Autor   : Odirlei-AMcom Capoia (DB1)
  --  Data    : Dezembro/2011                     Ultima Atualizacao: 14/12/2016
  --
  --  Dados referentes ao programa:
  --
  --  Objetivo  : Tranformacao BO tela PREVIS
  --
  --  Alteracoes: 30/09/2013 - Conversao Progress para oracle (Odirlei-AMcom).
  --
  --			  07/11/2016 - Ajuste para contabilizar as TED - SICREDI (Adriano - M211)
  --
  --              14/12/2016 - Ajuste para gravar movimentação de TED - SICREDI corretamente (Adriano - SD 577067)
  ---------------------------------------------------------------------------------------------------------------

  -- Procedure para gravar movimentação de fluxo financeiro
  PROCEDURE pc_grava_movimentacao
                                    (pr_cdcooper IN INTEGER      -- Codigo da Cooperativa
                                    ,pr_cdoperad IN crapope.cdoperad%type    -- Codigo do operador
                                    ,pr_dtmvtolt IN DATE         -- Data de movimento
                                    ,pr_tpdmovto IN INTEGER      -- Tipo de movimento
                                    ,pr_cdbccxlt IN NUMBER       -- Codigo do banco/caixa.
                                    ,pr_tpdcampo IN NUMBER       -- Tipo de campo
                                    ,pr_vldcampo IN NUMBER       -- Valor do campo
                                    ,pr_dscritic OUT VARCHAR2) AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_movimentacao          Antigo: b1wgen0131.p/grava-movimentacao
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 08/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Grava movimentação de fluxo financeiro
    --
    --   Atualizacao: 08/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --..........................................................................

    -- Buscar Informacoes da movimentacao do fluxo financeiro.
    CURSOR cr_crapffm is
      SELECT vlrepass,
             vlnumera,
             vlrfolha,
             vloutros,
             cdbccxlt
        FROM crapffm
       WHERE crapffm.cdcooper = pr_cdcooper AND
             crapffm.dtmvtolt = pr_dtmvtolt AND
             crapffm.tpdmovto = pr_tpdmovto AND
             crapffm.cdbccxlt = pr_cdbccxlt;

    rw_crapffm cr_crapffm%rowtype;

  BEGIN

    -- Buscar Informacoes da movimentacao do fluxo financeiro.
    OPEN cr_crapffm;
    FETCH cr_crapffm
      INTO rw_crapffm;

    IF cr_crapffm%NOTFOUND THEN
      -- Se não existe o registro insere
      BEGIN
        INSERT INTO crapffm
                      ( CDCOOPER,
                        DTMVTOLT,
                        TPDMOVTO,
                        CDBCCXLT,
                        VLCHEQUE,
                        VLTOTDOC,
                        VLTOTTED,
                        VLTOTTIT,
                        VLDEVOLU,
                        VLMVTITG,
                        VLTTINSS,
                        VLTRDEIT,
                        VLSATAIT,
                        VLFATBRA,
                        VLCONVEN,
                        VLREPASS,
                        VLNUMERA,
                        VLRFOLHA,
                        VLOUTROS)
               VALUES ( pr_cdcooper, --CDCOOPER
                        pr_dtmvtolt, --DTMVTOLT,
                        pr_tpdmovto, --TPDMOVTO,
                        pr_cdbccxlt, --CDBCCXLT,
                        DECODE(pr_tpdcampo,1,pr_vldcampo,0), --vlcheque
                        DECODE(pr_tpdcampo,2,pr_vldcampo,0), -- vltotdoc
                        DECODE(pr_tpdcampo,3,pr_vldcampo,0), --vltotted
                        DECODE(pr_tpdcampo,4,pr_vldcampo,0), --vltottit
                        DECODE(pr_tpdcampo,5,pr_vldcampo,0), --vldevolu
                        DECODE(pr_tpdcampo,6,pr_vldcampo,0), --vlmvtitg
                        DECODE(pr_tpdcampo,7,pr_vldcampo,0), --vlttinss
                        DECODE(pr_tpdcampo,8,pr_vldcampo,0), --vltrdeit
                        DECODE(pr_tpdcampo,9,pr_vldcampo,0), --vlsatait
                        DECODE(pr_tpdcampo,10,pr_vldcampo,0),--vlfatbra
                        DECODE(pr_tpdcampo,11,pr_vldcampo,0),--vlconven
                        DECODE(pr_tpdcampo,12,pr_vldcampo,0),--vlrepass
                        DECODE(pr_tpdcampo,13,pr_vldcampo,0),--vlnumera
                        DECODE(pr_tpdcampo,14,pr_vldcampo,0),--vlrfolha
                        DECODE(pr_tpdcampo,15,pr_vldcampo,0) --vloutros
                       );
      EXCEPTION
        WHEN OTHERS THEN
          close cr_crapffm;
          pr_dscritic := 'Erro ao inserir crapffm: '|| SQLerrm;
          return;
      END;
    ELSE
      -- Se ja existe o registro apenas atualizar
      BEGIN
        UPDATE crapffm
           SET vlcheque = DECODE(pr_tpdcampo,1,pr_vldcampo,vlcheque),
               vltotdoc = DECODE(pr_tpdcampo,2,pr_vldcampo,vltotdoc),
               vltotted = DECODE(pr_tpdcampo,3,pr_vldcampo,vltotted),
               vltottit = DECODE(pr_tpdcampo,4,pr_vldcampo,vltottit),
               vldevolu = DECODE(pr_tpdcampo,5,pr_vldcampo,vldevolu),
               vlmvtitg = DECODE(pr_tpdcampo,6,pr_vldcampo,vlmvtitg),
               vlttinss = DECODE(pr_tpdcampo,7,pr_vldcampo,vlttinss),
               vltrdeit = DECODE(pr_tpdcampo,8,pr_vldcampo,vltrdeit),
               vlsatait = DECODE(pr_tpdcampo,9,pr_vldcampo,vlsatait),
               vlfatbra = DECODE(pr_tpdcampo,10,pr_vldcampo,vlfatbra),
               vlconven = DECODE(pr_tpdcampo,11,pr_vldcampo,vlconven),
               vlrepass = DECODE(pr_tpdcampo,12,pr_vldcampo,vlrepass),
               vlnumera = DECODE(pr_tpdcampo,13,pr_vldcampo,vlnumera),
               vlrfolha = DECODE(pr_tpdcampo,14,pr_vldcampo,vlrfolha),
               vloutros = DECODE(pr_tpdcampo,15,pr_vldcampo,vloutros)
         WHERE crapffm.cdcooper = pr_cdcooper AND
               crapffm.dtmvtolt = pr_dtmvtolt AND
               crapffm.tpdmovto = pr_tpdmovto AND
               crapffm.cdbccxlt = pr_cdbccxlt;
      EXCEPTION
        WHEN OTHERS THEN
          close cr_crapffm;
          pr_dscritic := 'Erro ao atualizar crapffm: '|| SQLerrm;
          return;
      END;
    END IF;
    close cr_crapffm;

    -- Gerar Log previs.log
    IF pr_tpdcampo = 12 THEN
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 1 -- apenas log
                                ,pr_nmarqlog     => 'previs.log'
                                ,pr_des_log      => to_char(pr_dtmvtolt,'DD/MM/RRRR') ||' '||to_char(sysdate,'hh24:mi:ss')||
                                                    ' --> Operador '|| pr_cdoperad ||
                                                    ' - alterou o valor do repasse de '|| gene0002.fn_mask(rw_crapffm.vlrepass,'zzzz.zzz.zz9,99')||
                                                    ' para '||gene0002.fn_mask(pr_vldcampo,'zzzz.zzz.zz9,99') ||
                                                    ', banco '|| rw_crapffm.cdbccxlt||
                                                    (case pr_tpdmovto
                                                     when 1 then ', Entrada'
                                                     else ', Saida'
                                                     end)
                                                    );
    ELSIF pr_tpdcampo = 13 THEN
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 1 -- apenas log
                                ,pr_nmarqlog     => 'previs.log'
                                ,pr_des_log      => to_char(pr_dtmvtolt,'DD/MM/RRRR') ||' '||to_char(sysdate,'hh24:mi:ss')||
                                                    ' --> Operador '|| pr_cdoperad ||
                                                    (case pr_tpdmovto
                                                     when 1 then ' - alterou o valor do deposito de numerario de '
                                                     else ' - alterou o valor do alivio de numerario '
                                                     end) ||
                                                    gene0002.fn_mask(rw_crapffm.vlnumera,'z.zzz.zzz.zz9,99')||
                                                    ' para '||gene0002.fn_mask(pr_vldcampo,'z.zzz.zzz.zz9,99') ||
                                                    ', banco '|| rw_crapffm.cdbccxlt||
                                                    (case pr_tpdmovto
                                                     when 1 then ', Entrada'
                                                     else ', Saida'
                                                     end)
                                                    );

    ELSIF pr_tpdcampo = 14 THEN
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 1 -- apenas log
                                ,pr_nmarqlog     => 'previs.log'
                                ,pr_des_log      => to_char(pr_dtmvtolt,'DD/MM/RRRR') ||' '||to_char(sysdate,'hh24:mi:ss')||
                                                    ' --> Operador '|| pr_cdoperad ||
                                                    (case pr_tpdmovto
                                                     when 1 then ' - alterou o valor da folha de pagamento de '
                                                     else ' - alterou o valor do saque numerario '
                                                     end) ||
                                                    gene0002.fn_mask(rw_crapffm.vlrfolha,'z.zzz.zzz.zz9,99')||
                                                    ' para '||gene0002.fn_mask(pr_vldcampo,'z.zzz.zzz.zz9,99') ||
                                                    ', banco '|| rw_crapffm.cdbccxlt||
                                                    (case pr_tpdmovto
                                                     when 1 then ', Entrada'
                                                     else ', Saida'
                                                     end)
                                                    );
    ELSIF pr_tpdcampo = 15 THEN
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 1 -- apenas log
                                ,pr_nmarqlog     => 'previs.log'
                                ,pr_des_log      => to_char(pr_dtmvtolt,'DD/MM/RRRR') ||' '||to_char(sysdate,'hh24:mi:ss')||
                                                    ' --> Operador '|| pr_cdoperad ||
                                                    ' - Alterou o valor outros de '||
                                                    gene0002.fn_mask(rw_crapffm.vlrfolha,'z.zzz.zzz.zz9,99')||
                                                    ' para '||gene0002.fn_mask(pr_vldcampo,'z.zzz.zzz.zz9,99') ||
                                                    ', banco '|| rw_crapffm.cdbccxlt||
                                                    (case pr_tpdmovto
                                                     when 1 then ', Entrada'
                                                     else ', Saida'
                                                     end)
                                                    );
    END if;

    pr_dscritic := 'OK';

  END pc_grava_movimentacao;

  -- Procedure para gravar Informacoes do fluxo financeiro consolidado.
  PROCEDURE pc_grava_consolidado_singular
                                    (pr_cdcooper IN INTEGER       -- Codigo da Cooperativa
                                    ,pr_dtmvtolt IN DATE          -- Data de movimento
                                    ,pr_tpdcampo IN NUMBER        -- Tipo de campo
                                    ,pr_vldcampo IN NUMBER        -- Valor do campo
                                    ,pr_dscritic OUT VARCHAR2) AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_consolidado_singular          Antigo: b1wgen0131.p/grava_consolidado_singular
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 20/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Grava Informacoes do fluxo financeiro consolidado.
    --
    --   Atualizacao: 20/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --..........................................................................

    -- Buscar Informacoes do fluxo financeiro consolidado.
    CURSOR cr_crapffc is
      SELECT rowid
        FROM crapffc
       WHERE crapffc.cdcooper = pr_cdcooper AND
             crapffc.dtmvtolt = pr_dtmvtolt;

    rw_crapffc cr_crapffc%rowtype;

  BEGIN

    -- Buscar Informacoes do fluxo financeiro consolidado.
    OPEN cr_crapffc;
    FETCH cr_crapffc
      INTO rw_crapffc;

    IF cr_crapffc%NOTFOUND THEN
      -- Se não existe o registro, deve inserir
      BEGIN
        INSERT INTO crapffc
                 ( cdcooper
                  ,dtmvtolt
                  ,vlentrad
                  ,vlsaidas
                  ,vlsldcta
                  ,vlresgat
                  ,vlaplica)
               VALUES
                 ( pr_cdcooper -- cdcooper
                  ,pr_dtmvtolt -- dtmvtolt
                  ,DECODE(pr_tpdcampo,1,pr_vldcampo,0)-- vlentrad
                  ,DECODE(pr_tpdcampo,2,pr_vldcampo,0)-- vlsaidas
                  ,DECODE(pr_tpdcampo,3,pr_vldcampo,0)-- vlsldcta
                  ,DECODE(pr_tpdcampo,4,pr_vldcampo,0)-- vlresgat
                  ,DECODE(pr_tpdcampo,5,pr_vldcampo,0)-- vlaplica
                  );
      EXCEPTION
        WHEN OTHERS THEN
          close cr_crapffc;
          pr_dscritic := 'Erro ao inserir crapffc: '|| SQLerrm;
          return;
      END;
    ELSE
    -- Se ja existe o registro, apenas altera
      BEGIN
        UPDATE crapffc
           SET vlentrad = DECODE(pr_tpdcampo,1,pr_vldcampo,vlentrad),
               vlsaidas = DECODE(pr_tpdcampo,2,pr_vldcampo,vlsaidas),
               vlsldcta = DECODE(pr_tpdcampo,3,pr_vldcampo,vlsldcta),
               vlresgat = DECODE(pr_tpdcampo,4,pr_vldcampo,DECODE(pr_tpdcampo,5,0,vlresgat)),
               vlaplica = DECODE(pr_tpdcampo,5,pr_vldcampo,DECODE(pr_tpdcampo,4,0,vlaplica))
         WHERE rowid = rw_crapffc.rowid;
      EXCEPTION
        WHEN OTHERS THEN
          close cr_crapffc;
          pr_dscritic := 'Erro ao atualizar crapffc: '|| SQLerrm;
          return;
      END;
    END IF;

    pr_dscritic := 'OK';

  END pc_grava_consolidado_singular;

  -- Função para retornar a lista de dias conforme o dia passado como parametro
  FUNCTION fn_Busca_Lista_Dias(pr_dtdiames IN varchar2)
           RETURN VARCHAR2 IS
  -- .........................................................................
  --
  --  Programa : fn_Busca_Lista_Dias          Antigo: b1wgen0131.p/fnBuscaListaDias
  --
  --  Sistema  : Cred
  --  Sigla    : FLXF0001
  --  Autor    : Odirlei Busana
  --  Data     : novembro/2013.                   Ultima atualizacao: 13/11/2013
  --
  --  Dados referentes ao programa:
  --
  --   Objetivo  : Retorna a lista de dias conforme o dia passado como parametro
  --
  --   Atualizacao: 13/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
  --..........................................................................
  BEGIN

    IF pr_dtdiames IN (1,2,3) THEN
      RETURN '01,02,03';
    ELSIF pr_dtdiames IN (4) THEN
      RETURN '01,02,03,04';
    ELSIF pr_dtdiames IN (5,6,7,8,9) THEN
      RETURN '06,07,08,09';
    ELSIF pr_dtdiames IN (10,11,12) THEN
      RETURN '10,11,12,13,14';
    ELSIF pr_dtdiames IN (13,14) THEN
      RETURN '11,12,13,14';
    ELSIF pr_dtdiames IN (15) THEN
      RETURN '15,16,17,18';
    ELSIF pr_dtdiames IN (16) THEN
      RETURN '15,16,17,18,19';
    ELSIF pr_dtdiames IN (17,18,19) THEN
      RETURN '16,17,18,19';
    ELSIF pr_dtdiames IN (20,21) THEN
      RETURN '20,21,22,23,24';
    ELSIF pr_dtdiames IN (22,23,24) THEN
      RETURN '21,22,23,24';
    ELSIF pr_dtdiames IN (25,26,27,28) THEN
      RETURN '26,27,28,29';
    ELSIF pr_dtdiames IN (29,30) THEN
      RETURN '26,27,28,29,30';
    ELSIF pr_dtdiames IN (31) THEN
      RETURN '26,27,28,29,30,31';
    ELSE
      RETURN pr_dtdiames;
    END IF;

  END fn_Busca_Lista_Dias;

  -- Função retornar a quantidade de dias uteis
  FUNCTION fn_Calcula_Dia_Util(pr_dtdiames IN Integer)
           RETURN VARCHAR2 IS
  -- .........................................................................
  --
  --  Programa : fn_Calcula_Dia_Util          Antigo: b1wgen0131.p/fnCalculaDiaUtil
  --
  --  Sistema  : Cred
  --  Sigla    : FLXF0001
  --  Autor    : Odirlei Busana
  --  Data     : novembro/2013.                   Ultima atualizacao: 13/11/2013
  --
  --  Dados referentes ao programa:
  --
  --   Objetivo  : Retorna a quantidade de dias uteis
  --
  --   Atualizacao: 13/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
  --..........................................................................

  vr_tab_CalcDiaUtil flxf0001.typ_tab_ValDia;

  BEGIN
    --Monta temptable com os valores, o indice é o dia.

                                       -- dia :=  1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31
    vr_tab_CalcDiaUtil := flxf0001.typ_tab_ValDia(0,0,0,2,3,4,5,6,6, 7, 7, 8, 9,10, 0,11,12,12,13,14, 0, 0,16,16,17,18,19,20,21, 0, 0);

    return vr_tab_CalcDiaUtil(pr_dtdiames);

  END fn_Calcula_Dia_Util;

  -- Função retornar a quantidade de dias limite
  FUNCTION fn_busca_limite_Dia(pr_dtdiames IN Integer,
                               pr_tplimite IN NUMBER) -- Tipo de Limite (1 - Minimo 2 Maximo)
           RETURN VARCHAR2 IS
  -- .........................................................................
  --
  --  Programa : fn_busca_limite_Dia          Antigo: b1wgen0131.p/fnBuscaLimiteMinimo
  --                                                               fnBuscaLimiteMaximo
  --
  --  Sistema  : Cred
  --  Sigla    : FLXF0001
  --  Autor    : Odirlei Busana
  --  Data     : novembro/2013.                   Ultima atualizacao: 14/11/2013
  --
  --  Dados referentes ao programa:
  --
  --   Objetivo  : Retorna a quantidade de dias limite
  --
  --   Atualizacao: 14/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
  --..........................................................................

  vr_tab_LimDia flxf0001.typ_tab_ValDia;

  BEGIN
    --Monta temptable com os valores, o indice é o dia.

    IF pr_tplimite = 1 THEN -- LIMITE MINIMO
                                    -- dia :=  1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31
      vr_tab_LimDia := flxf0001.typ_tab_ValDia(0,0,0,0,5,5,5,5,5, 9, 9, 9,10,10,14,14,15,15,15,19,19,20,20,20,25,25,25,25,25,25,25);

      return NVL(vr_tab_LimDia(pr_dtdiames),0);

    ELSIF pr_tplimite = 2 THEN -- LIMITE MAXIMO
                                    -- dia :=  1,2,3,4, 5, 6, 7, 8, 9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31
      vr_tab_LimDia := flxf0001.typ_tab_ValDia(3,3,3,5,10,10,10,10,10,15,15,15,15,15,19,20,20,20,20,25,25,25,25,25,30,20,30,30,31,31,99);

      return NVL(vr_tab_LimDia(pr_dtdiames),99);
    END IF;

  END fn_busca_limite_Dia;

  -- Função buscar os dados do fluxo financeiro
  FUNCTION fn_busca_dados_flx_singular(pr_cdcooper IN Integer, -- codigo da cooperativa
                                       pr_dtmvtolx IN DATE,    -- Data de movimento
                                       pr_tpdmovto IN NUMBER)   -- Tipo de movimento

           RETURN typ_tab_ffin_mvto_sing IS
  -- .........................................................................
  --
  --  Programa : pc_busca_dados_flx_singular          Antigo: b1wgen0131.p/busca_dados_fluxo_singular
  --
  --
  --  Sistema  : Cred
  --  Sigla    : FLXF0001
  --  Autor    : Odirlei Busana
  --  Data     : novembro/2013.                   Ultima atualizacao: 19/11/2013
  --
  --  Dados referentes ao programa:
  --
  --   Objetivo  : Buscar os dados do fluxo financeiro
  --
  --   Atualizacao: 19/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
  --..........................................................................

  vr_tab_ffin_mvto_sing FLXF0001.typ_tab_ffin_mvto_sing;
  vr_idx                VARCHAR2(3);

    -- Buscar Informacoes da movimentacao do fluxo financeiro.
    CURSOR cr_crapffm IS
      SELECT cdbccxlt,
             vlcheque,
             vltotdoc,
             vltotted,
             vltottit,
             vldevolu,
             vlmvtitg,
             vlttinss,
             vltrdeit,
             vlsatait,
             vlrepass,
             vlnumera,
             vlrfolha,
             vloutros,
             vlfatbra,
             vlconven
        FROM crapffm
       WHERE crapffm.cdcooper = pr_cdcooper
         AND crapffm.dtmvtolt = pr_dtmvtolx
         AND crapffm.tpdmovto = pr_tpdmovto
         AND crapffm.cdbccxlt IN (85,1,756,100); --Carregar apenas estes bancos

  BEGIN
    --Inicializar valores
    vr_tab_ffin_mvto_sing('085').cdbcoval := 85;
    vr_tab_ffin_mvto_sing('085').tpdmovto := pr_tpdmovto;

    vr_tab_ffin_mvto_sing('001').cdbcoval := 1;
    vr_tab_ffin_mvto_sing('001').tpdmovto := pr_tpdmovto;

    vr_tab_ffin_mvto_sing('756').cdbcoval := 756;
    vr_tab_ffin_mvto_sing('756').tpdmovto := pr_tpdmovto;

    vr_tab_ffin_mvto_sing('100').cdbcoval := 100;
    vr_tab_ffin_mvto_sing('100').tpdmovto := pr_tpdmovto;

    -- Ler Informacoes da movimentacao do fluxo financeiro.
    FOR rw_crapffm IN cr_crapffm LOOP

      vr_idx := LPAD(rw_crapffm.cdbccxlt,3,'0') ;


      IF pr_tpdmovto = 1 THEN --Entrada
        vr_tab_ffin_mvto_sing(vr_idx).vlcheque := rw_crapffm.vlcheque;
        vr_tab_ffin_mvto_sing(vr_idx).vltotdoc := rw_crapffm.vltotdoc;
        vr_tab_ffin_mvto_sing(vr_idx).vltotted := rw_crapffm.vltotted;
        vr_tab_ffin_mvto_sing(vr_idx).vltottit := rw_crapffm.vltottit;
        vr_tab_ffin_mvto_sing(vr_idx).vldevolu := rw_crapffm.vldevolu;
        vr_tab_ffin_mvto_sing(vr_idx).vlmvtitg := rw_crapffm.vlmvtitg;
        vr_tab_ffin_mvto_sing(vr_idx).vlttinss := rw_crapffm.vlttinss;
        vr_tab_ffin_mvto_sing(vr_idx).vltrdeit := rw_crapffm.vltrdeit;
        vr_tab_ffin_mvto_sing(vr_idx).vlsatait := rw_crapffm.vlsatait;
        vr_tab_ffin_mvto_sing(vr_idx).vlrepass := rw_crapffm.vlrepass;
        vr_tab_ffin_mvto_sing(vr_idx).vlnumera := rw_crapffm.vlnumera;
        vr_tab_ffin_mvto_sing(vr_idx).vlrfolha := rw_crapffm.vlrfolha;
        vr_tab_ffin_mvto_sing(vr_idx).vloutros := rw_crapffm.vloutros;
        vr_tab_ffin_mvto_sing(vr_idx).vldivers := rw_crapffm.vlrepass +
                                                  rw_crapffm.vlnumera +
                                                  rw_crapffm.vlrfolha +
                                                  rw_crapffm.vloutros;
        vr_tab_ffin_mvto_sing(vr_idx).vlttcrdb := rw_crapffm.vlcheque +
                                                  rw_crapffm.vltotdoc +
                                                  rw_crapffm.vltotted +
                                                  rw_crapffm.vltottit +
                                                  rw_crapffm.vlmvtitg +
                                                  rw_crapffm.vlttinss +
                                                  rw_crapffm.vltrdeit +
                                                  rw_crapffm.vlsatait +
                                                  rw_crapffm.vlrepass +
                                                  rw_crapffm.vlnumera +
                                                  rw_crapffm.vlrfolha +
                                                  rw_crapffm.vloutros +
                                                  rw_crapffm.vldevolu;
      ELSE
        vr_tab_ffin_mvto_sing(vr_idx).vlcheque := rw_crapffm.vlcheque;
        vr_tab_ffin_mvto_sing(vr_idx).vltotdoc := rw_crapffm.vltotdoc;
        vr_tab_ffin_mvto_sing(vr_idx).vltotted := rw_crapffm.vltotted;
        vr_tab_ffin_mvto_sing(vr_idx).vltottit := rw_crapffm.vltottit;
        vr_tab_ffin_mvto_sing(vr_idx).vldevolu := rw_crapffm.vldevolu;
        vr_tab_ffin_mvto_sing(vr_idx).vlmvtitg := rw_crapffm.vlmvtitg;
        vr_tab_ffin_mvto_sing(vr_idx).vlttinss := rw_crapffm.vlttinss;
        vr_tab_ffin_mvto_sing(vr_idx).vltrdeit := rw_crapffm.vltrdeit;
        vr_tab_ffin_mvto_sing(vr_idx).vlsatait := rw_crapffm.vlsatait;
        vr_tab_ffin_mvto_sing(vr_idx).vlfatbra := rw_crapffm.vlfatbra;
        vr_tab_ffin_mvto_sing(vr_idx).vlconven := rw_crapffm.vlconven;
        vr_tab_ffin_mvto_sing(vr_idx).vlrepass := rw_crapffm.vlrepass;
        vr_tab_ffin_mvto_sing(vr_idx).vlnumera := rw_crapffm.vlnumera;
        vr_tab_ffin_mvto_sing(vr_idx).vlrfolha := rw_crapffm.vlrfolha;
        vr_tab_ffin_mvto_sing(vr_idx).vloutros := rw_crapffm.vloutros;
        vr_tab_ffin_mvto_sing(vr_idx).vldivers := rw_crapffm.vlrepass +
                                                  rw_crapffm.vlnumera +
                                                  rw_crapffm.vlrfolha +
                                                  rw_crapffm.vloutros;
        vr_tab_ffin_mvto_sing(vr_idx).vlttcrdb := rw_crapffm.vlcheque +
                                                  rw_crapffm.vltotdoc +
                                                  rw_crapffm.vltotted +
                                                  rw_crapffm.vltottit +
                                                  rw_crapffm.vlmvtitg +
                                                  rw_crapffm.vlttinss +
                                                  rw_crapffm.vltrdeit +
                                                  rw_crapffm.vlsatait +
                                                  rw_crapffm.vlfatbra +
                                                  rw_crapffm.vlconven +
                                                  rw_crapffm.vlrepass +
                                                  rw_crapffm.vlnumera +
                                                  rw_crapffm.vlrfolha +
                                                  rw_crapffm.vloutros +
                                                  rw_crapffm.vldevolu;
      END IF;

    END LOOP;

    RETURN vr_tab_ffin_mvto_sing;

  EXCEPTION
    WHEN OTHERS THEN
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                  || 'FLXF0001 --> '
                                                  || 'Erro na fn_busca_dados_flx_singular: '||SQLErrm );
  END fn_busca_dados_flx_singular;

  -- Função para identificar o banco da agencia
  FUNCTION fn_identifica_bcoctl(pr_cdcooper IN Integer, -- codigo da cooperativa
                                pr_cdagenci IN Integer, -- Codigo da agencia
                                pr_idtpdoct IN VARCHAR2)-- Tipo de documento (T-titulo,D-doc,C-cheque)

           RETURN NUMBER IS
  -- .........................................................................
  --
  --  Programa : pc_busca_dados_flx_singular          Antigo: b1wgen0131.p/pi_identifica_bcoctl
  --
  --
  --  Sistema  : Cred
  --  Sigla    : FLXF0001
  --  Autor    : Odirlei Busana
  --  Data     : novembro/2013.                   Ultima atualizacao: 20/11/2013
  --
  --  Dados referentes ao programa:
  --
  --   Objetivo  : Identificar o banco da agencia
  --
  --   Atualizacao: 20/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
  --..........................................................................

    -- buscar codigo do banco no cadastro da agencia
    CURSOR cr_crapage IS
      SELECT (CASE pr_idtpdoct
               WHEN 'T' THEN cdbantit
               WHEN 'D' THEN cdbandoc
               WHEN 'C' THEN cdbanchq
              END) cdbanco
        FROM crapage
       WHERE crapage.cdcooper = pr_cdcooper
         AND crapage.cdagenci = nvl(pr_cdagenci,0);
    rw_crapage cr_crapage%rowtype;

  BEGIN

    -- buscar agencia
    OPEN cr_crapage;
    FETCH cr_crapage
      INTO rw_crapage;

    IF cr_crapage%NOTFOUND THEN
      CLOSE cr_crapage;
      RETURN NULL;
    ELSE
      CLOSE cr_crapage;

      -- Gerar identificador conforme o codigo do banco
      CASE rw_crapage.cdbanco
        WHEN 85   THEN RETURN 1;
        WHEN 1    THEN RETURN 2;
        WHEN 756  THEN RETURN 3;
      END CASE;
    END IF;

  END fn_identifica_bcoctl;

  -- Função retornar o numero de dia util
  FUNCTION Fn_retorna_numero_dia_util( pr_cdcooper in number,  -- codigo da cooperativa
                                       pr_numdiaut IN Integer, -- Numero de dia calculado
                                       pr_dtdatmes IN DATE)    -- Data do periodo
           RETURN INTEGER IS
  -- .........................................................................
  --
  --  Programa : Fn_retorna_numero_dia_util          Antigo: b1wgen0131.p/fnRetornaNumeroDiaUtilChqDoc
  --                                                                      fnRetornaNumeroDiaUtilTitulo
  --                                                                      fnRetornaNumeroDiaUtilItg
  --
  --
  --
  --  Sistema  : Cred
  --  Sigla    : FLXF0001
  --  Autor    : Odirlei Busana
  --  Data     : novembro/2013.                   Ultima atualizacao: 14/11/2013
  --
  --  Dados referentes ao programa:
  --
  --   Objetivo  : Retorna o numero de dia util para o chqdoc
  --
  --   Atualizacao: 14/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
  --..........................................................................

    vr_dtverdat date;
    vr_contador number := 0;

  BEGIN
    -- selecionar primeiro dia do mês
    vr_dtverdat := to_date(to_char(pr_dtdatmes,'MMRRRR'),'MMRRRR');

    -- Varrer dias do mês
    WHILE TO_CHAR(vr_dtverdat,'MM') = TO_CHAR(pr_dtdatmes,'MM')  LOOP
      -- Se não for domingo ou sabado e não for feriado
      IF TO_CHAR(vr_dtverdat,'D') NOT IN (1,7) AND
         NOT FLXF0001.fn_verifica_feriado(pr_cdcooper,vr_dtverdat) THEN

        vr_contador := vr_contador + 1;
        -- se o contador de dias uteis for igual a qtd de dias uteis calculado
        IF vr_contador = pr_numdiaut THEN
          -- sair do loop
          exit;
        END IF;
      END IF;

      vr_dtverdat := vr_dtverdat + 1;

    END LOOP;

    -- se o contador de dias uteis for igual a qtd de dias uteis calculado
    IF vr_contador = pr_numdiaut THEN
       RETURN to_char(vr_dtverdat,'DD');
    ELSE
       RETURN 0;
    END IF;

  END Fn_retorna_numero_dia_util;

  -- Função para validar a quantidade de dias uteis do mes
  FUNCTION fn_Valida_Dias_Uteis_Mes( pr_cdcooper in number,  -- codigo da cooperativa
                                     pr_dtdatmes IN DATE)   -- Data do periodo
           RETURN BOOLEAN IS
  -- .........................................................................
  --
  --  Programa : fn_Valida_Dias_Uteis_Mes          Antigo: b1wgen0131.p/fnValidaDiasUteisMes
  --
  --
  --  Sistema  : Cred
  --  Sigla    : FLXF0001
  --  Autor    : Odirlei Busana
  --  Data     : novembro/2013.                   Ultima atualizacao: 14/11/2013
  --
  --  Dados referentes ao programa:
  --
  --   Objetivo  : Valida a quantidade de dias uteis do mes
  --
  --   Atualizacao: 14/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
  --..........................................................................

    vr_dtverdat date;
    vr_contador number := 0;

  BEGIN
    -- selecionar primeiro dia do mês
    vr_dtverdat := to_date(to_char(pr_dtdatmes,'MMRRRR'),'MMRRRR');

    -- Varrer dias do mês
    WHILE TO_CHAR(vr_dtverdat,'MM') = TO_CHAR(pr_dtdatmes,'MM')  LOOP
      -- Se não for domingo ou sabado e não for feriado
      IF TO_CHAR(vr_dtverdat,'D') NOT IN (1,7) AND
         NOT FLXF0001.fn_verifica_feriado(pr_cdcooper,vr_dtverdat) THEN
        -- incrementar contador
        vr_contador := vr_contador + 1;

      END IF;
      --Incrementar data
      vr_dtverdat := vr_dtverdat + 1;

    END LOOP;

    -- se a quantidade de dias uteis for maior ou igual a 20 dias
    RETURN (vr_contador >= 20);

  END fn_Valida_Dias_Uteis_Mes;

  -- Procedure para Buscar proximo sequecia para a tabela de periodo de datas
  FUNCTION fn_ret_prox_sequencia ( pr_tab_per_datas IN typ_tab_per_datas) -- Tabela de datas
                            return number is
    -- .........................................................................
    --
    --  Programa : fn_ret_prox_sequencia          Antigo: b1wgen0131.p/fnRetornaProximaSequencia
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 08/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Busca proximo sequecia para a tabela de periodo de datas
    --
    --   Atualizacao: 08/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --..........................................................................

    vridx varchar2(20);

  BEGIN

    -- localizar ultimo
    vridx := pr_tab_per_datas.LAST;
    --se não existe registro, retorna 1
    IF vridx is null THEN
      RETURN 1;
    ELSE
     --se localizou, retornar o nrsequen do ultimo + 1
     RETURN NVL(pr_tab_per_datas(vridx).nrsequen,0) + 1;
    END IF;

  END fn_ret_prox_sequencia;

  -- Procedure para Verificar se o dia til anterior é feriado
  FUNCTION fn_feriado_dia_anterior ( pr_cdcooper in number -- codigo da cooperativa
                                    ,pr_dtrefmes in date ) -- Data atual
                                          return boolean AS
    -- .........................................................................
    --
    --  Programa : fn_feriado_dia_anterior          Antigo: b1wgen0131.p/fnDiaAnteriorEhFeriado
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 08/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Verifica se o dia til anterior é feriado
    --
    --   Atualizacao: 08/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --..........................................................................

    vr_datautil date;

  BEGIN

    vr_datautil := pr_dtrefmes - 1;

    -- Se for domingo diminui dois dias
    IF TO_CHAR(vr_datautil,'D') = 1 THEN
      vr_datautil := vr_datautil - 2;
    -- se for sabado diminui um dia
    ELSIF TO_CHAR(vr_datautil,'D') = 7 THEN
      vr_datautil := vr_datautil - 1;
    END IF;

    -- Retorna true se for feriado
    RETURN FLXF0001.fn_verifica_feriado( pr_cdcooper => pr_cdcooper   -- codigo da cooperativa
                                        ,pr_dtrefmes => vr_datautil); -- Data referencia

  END fn_feriado_dia_anterior;

  -- Procedure para buscar a data anterior ao feriado
  FUNCTION fn_Busca_Data_anterior_feriado ( pr_cdcooper in number -- codigo da cooperativa
                                          ,pr_dtrefmes in date ) -- Data atual
                                          return DATE AS
    -- .........................................................................
    --
    --  Programa : fn_Busca_Data_anterior_feriado          Antigo: b1wgen0131.p/fnBuscaDataAnteriorFeriado
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 08/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Buscar a data anterior ao feriado
    --
    --   Atualizacao: 08/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --..........................................................................

    vr_datautil date;

  BEGIN

    vr_datautil := pr_dtrefmes - 1;

    -- Se for domingo diminui dois dias
    IF TO_CHAR(vr_datautil,'D') = 1 THEN
      vr_datautil := vr_datautil - 2;
    -- Se for sabado diminui um dia
    ELSIF TO_CHAR(vr_datautil,'D') = 7 THEN
      vr_datautil := vr_datautil - 1;
    END IF;

    -- se for feriado retorna a data
    IF FLXF0001.fn_verifica_feriado( pr_cdcooper => pr_cdcooper   -- codigo da cooperativa
                                    ,pr_dtrefmes => vr_datautil) then -- Data referencia
      RETURN vr_datautil;
    ELSE
      -- senão retorna nulo
      RETURN NULL;
    END IF;

  END fn_Busca_Data_anterior_feriado;

  -- Procedure para Verificar se o dia é feriado
  FUNCTION fn_verifica_feriado( pr_cdcooper in number   -- codigo da cooperativa
                               ,pr_dtrefmes in date     -- Data referencia
                                )
                                          return boolean AS
    -- .........................................................................
    --
    --  Programa : fn_verifica_feriado          Antigo: b1wgen0131.p/fnEhFeriado
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 11/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Verifica se o dia é feriado
    --
    --   Atualizacao: 08/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --..........................................................................

    -- Ler tabela de feriado
    CURSOR cr_crapfer IS
      SELECT 1
        FROM crapfer
       WHERE crapfer.cdcooper = pr_cdcooper
         AND crapfer.dtferiad = pr_dtrefmes;

    rw_crapfer cr_crapfer%rowtype;

  BEGIN

    -- Ler tabela de feriado
    OPEN cr_crapfer;
    FETCH cr_crapfer
      INTO rw_crapfer;
    -- Se existir na tabela de feriado retorna true, senão retorna false;
    IF cr_crapfer%NOTFOUND THEN
      CLOSE cr_crapfer;
      RETURN FALSE;
    ELSE
      CLOSE cr_crapfer;
      RETURN TRUE;
    END IF;

  END fn_verifica_feriado;

  -- Procedure para Validar a regra de media de dia util
  FUNCTION fn_valid_Media_Dia_Util_Semana ( pr_nrdiasme in varchar2 -- numero que representa o dia do mes
                                           ,pr_nrdiasse in varchar2 -- numero que representa o dia da semana
                                           ,pr_dtperiod in date     -- Data referencia
                                           ,pr_cdcooper in number   -- codigo da cooperativa
                                           ,pr_tipodoct in varchar2 -- Tipo de documento (C-Cheque,T-Titulo-I-Conta Integração )
                                            )
                                          return boolean AS
    -- .........................................................................
    --
    --  Programa : fn_valid_Media_Dia_Util_Semana          Antigo: b1wgen0131.p/fnValidaRegraMediaDiasUteisDaSemanaItg
    --                                                                          fnValidaRegraMediaDiasUteisDaSemanaTitulo
    --                                                                          fnValidaRegraMediaDiasUteisDaSemanaChqDoc
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 08/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Valida a regra de media de dia util
    --
    --   Atualizacao: 08/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --..........................................................................


  BEGIN
       -- Verifica se existe o dia do mes na string
    IF GENE0002.fn_existe_valor(pr_base      => pr_nrdiasme              --> String que irá sofrer a busca
                               ,pr_busca     => TO_CHAR(pr_dtperiod,'DD')--> String objeto de busca
                               ,pr_delimite  => ',') = 'S'               --> String que será o delimitador)
       AND -- verifica se existe o dia da semana dentro da string
       GENE0002.fn_existe_valor(pr_base      => pr_nrdiasse               --> String que irá sofrer a busca
                               ,pr_busca     => TO_CHAR(pr_dtperiod,'D')  --> String objeto de busca
                               ,pr_delimite  => ',') = 'S'                --> String que será o delimitador)
       AND
       --Verifica se o dia é dia util, comparando o retorno da função com a data passada.
       (GENE0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper, --> Cooperativa conectada
                                    pr_dtmvtolt => pr_dtperiod, --> Data do movimento
                                    pr_tipo     => 'P',       --> Tipo de busca (P = proximo, A = anterior)
                                    pr_feriado  => TRUE)
           ) = pr_dtperiod AND
       -- verifica se o dia anterior nao é um feriado
       fn_feriado_dia_anterior ( pr_cdcooper => pr_cdcooper -- codigo da cooperativa
                                ,pr_dtrefmes => pr_dtperiod ) = FALSE then

      -- Se for validação de cheque
      IF pr_tipodoct = 'C' THEN
        -- Se for os primeiros 3 dias do mês, o mês precisa ter no minimo 20 dias uteis
       IF ( pr_nrdiasme in (1,2,3) AND
           fn_Valida_Dias_Uteis_Mes(pr_cdcooper,pr_dtperiod)) or
           pr_nrdiasme not in (1,2,3)THEN
          RETURN TRUE;
        ELSE
          RETURN FALSE;
        END IF;
      ELSE --senao retornar true
        RETURN TRUE;
      END IF;

    ELSE
      RETURN FALSE;
    END IF;

  END fn_valid_Media_Dia_Util_Semana;

  -- Procedure para Gerar temptable da media de datas de segunda feira
  PROCEDURE pc_regra_media_segfeira
                                    (pr_cdcooper  IN INTEGER     -- Codigo da Cooperativa
                                    ,pr_dtmvtolt  IN DATE        -- Data de movimento
                                    ,pr_listdias  IN VARCHAR2    -- Lista de dias do mes
                                    ,pr_cdagrupa  IN INTEGER DEFAULT NULL    -- Código de agrupamento
                                    ,pr_tab_per_datas IN OUT typ_tab_per_datas -- Tabela de datas
                                    ,pr_tab_datas     IN OUT typ_tab_datas -- tabela com as datas para controle
                                    ,pr_dscritic OUT VARCHAR2) AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_regra_media_segfeira          Antigo: b1wgen0131.p/RegraMediaSegundaFeiraChqDoc
    --                                                                   RegraMediaSegundaFeiraitg
    --                                                                   RegraMediaSegundaFeiratitulo
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 11/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gera temptable da media de datas de segunda feira
    --
    --   Atualizacao: 08/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --..........................................................................

    vr_dtperiod   DATE;
    vr_nrsequen   number;
    vr_idx        VARCHAR2(12);

  BEGIN
    vr_dtperiod := pr_dtmvtolt - 360;
     -- Varrer os ultmos 360 dias
    WHILE vr_dtperiod < pr_dtmvtolt LOOP
      -- Verifica se existe o dia do mes na string
      IF GENE0002.fn_existe_valor(pr_base      => pr_listdias              --> String que irá sofrer a busca
                                 ,pr_busca     => TO_CHAR(vr_dtperiod,'DD')--> String objeto de busca
                                 ,pr_delimite  => ',') = 'S'               --> String que será o delimitador)
           -- Verifica se é segunda feira
           AND TO_CHAR(vr_dtperiod,'D') = 2
           AND
           --Verifica se o dia é dia util, comparando o retorno da função com a data passada.
           (GENE0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper, --> Cooperativa conectada
                                        pr_dtmvtolt => vr_dtperiod, --> Data do movimento
                                        pr_tipo     => 'P',       --> Tipo de busca (P = proximo, A = anterior)
                                        pr_feriado  => TRUE)
               ) = vr_dtperiod AND
           -- verifica se o dia anterior nao é um feriado
           fn_feriado_dia_anterior ( pr_cdcooper => pr_cdcooper -- codigo da cooperativa
                                    ,pr_dtrefmes => vr_dtperiod ) = FALSE then

        --se ainda não existe a data, então inserir
        IF pr_tab_datas.EXISTS(TO_CHAR(vr_dtperiod,'DDMMRRRR')) = FALSE THEN
          --Buscar sequencial
          vr_nrsequen := FLXF0001.fn_ret_prox_sequencia(pr_tab_per_datas);
          vr_idx := lpad(pr_cdagrupa,3,'0')||TO_CHAR(vr_dtperiod,'RRRRMMDD');

          pr_tab_per_datas(vr_idx).nrsequen := vr_nrsequen;
          pr_tab_per_datas(vr_idx).dtmvtolt := vr_dtperiod;
          pr_tab_per_datas(vr_idx).cdagrupa := pr_cdagrupa;

          --controle que ja gravou a data
          pr_tab_datas(TO_CHAR(vr_dtperiod,'DDMMRRRR')) := 1;
        END IF;
      END IF;
      -- incrementar data
      vr_dtperiod := vr_dtperiod + 1;
    END LOOP;

    pr_dscritic := 'OK';

  END pc_regra_media_segfeira;

  -- Procedure para Gerar temptable da media de datas util de segunda feira
  PROCEDURE pc_media_dia_util_segfeira
                                    (pr_cdcooper  IN INTEGER    -- Codigo da Cooperativa
                                    ,pr_dtmvtolt  IN DATE       -- Data de movimento
                                    ,pr_numdiaut  IN INTEGER    -- Numero de dia calculado
                                    ,pr_diaminim  IN INTEGER    -- Qtd de dias limite minimo
                                    ,pr_diamaxim  IN INTEGER    -- Qtd de dias limite maximo
                                    ,pr_tab_per_datas IN OUT typ_tab_per_datas -- Tabela de datas
                                    ,pr_tab_datas     IN OUT typ_tab_datas     -- tabela com as datas para controle
                                    ,pr_dscritic OUT VARCHAR2) AS              -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_media_dia_util_segfeira          Antigo: b1wgen0131.p/RegraMediaDiaUtilSegundaFeira
    --
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 14/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gera temptable da media de datas util de segunda feira
    --
    --   Atualizacao: 14/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --..........................................................................

    vr_dtperiod   DATE;
    vr_nrsequen   number;
    vr_idx        VARCHAR2(12);
    vr_numdiaut   INTEGER;

  BEGIN
    vr_dtperiod := pr_dtmvtolt - 360;
     -- Varrer os ultmos 360 dias
    WHILE vr_dtperiod < pr_dtmvtolt LOOP

      vr_numdiaut := FLXF0001.Fn_retorna_numero_dia_util( pr_cdcooper => pr_cdcooper,  -- codigo da cooperativa
                                                          pr_numdiaut => pr_numdiaut,  -- Numero de dia calculado
                                                          pr_dtdatmes => vr_dtperiod); -- Data do periodo


      IF (TO_CHAR(VR_dtperiod,'D') = 2)   AND
         (TO_CHAR(VR_dtperiod,'DD') = vr_numdiaut) AND
         (vr_numdiaut < pr_diamaxim)      AND
         (vr_numdiaut > pr_diaminim)      THEN

        --se ainda não existe a data, então inserir
        IF pr_tab_datas.EXISTS(TO_CHAR(vr_dtperiod,'DDMMRRRR')) = FALSE THEN
          --Buscar sequencial
          vr_nrsequen := FLXF0001.fn_ret_prox_sequencia(pr_tab_per_datas);
          vr_idx := '000'||TO_CHAR(vr_dtperiod,'RRRRMMDD');

          pr_tab_per_datas(vr_idx).nrsequen := vr_nrsequen;
          pr_tab_per_datas(vr_idx).dtmvtolt := vr_dtperiod;

          --controle que ja gravou a data
          pr_tab_datas(TO_CHAR(vr_dtperiod,'DDMMRRRR')) := 1;
        END IF;
      END IF;

      -- incrementar data
      vr_dtperiod := vr_dtperiod + 1;
    END LOOP;

    pr_dscritic := 'OK';

  END pc_media_dia_util_segfeira;

  -- Procedure para Gerar temptable da media de datas com as primeiras segundas feiras uteis
  PROCEDURE pc_media_pri_dutil_segfeira
                                    (pr_cdcooper  IN INTEGER    -- Codigo da Cooperativa
                                    ,pr_dtmvtolt  IN DATE       -- Data de movimento
                                    ,pr_cdagrupa  IN INTEGER   -- Codigo do agrupamento
                                    ,pr_tab_per_datas IN OUT typ_tab_per_datas -- Tabela de datas
                                    ,pr_tab_datas     IN OUT typ_tab_datas     -- tabela com as datas para controle
                                    ,pr_dscritic OUT VARCHAR2) AS              -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_media_pri_dutil_segfeira          Antigo: b1wgen0131.p/RegraMediaPrimeiroDiaUtilSegundaFeiraTit
    --                                                                       RegraMediaPrimeiroDiaUtilSegundaFeiraItg
    --
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 14/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gera temptable da media de datas com as primeiras segundas feiras uteis
    --
    --   Atualizacao: 14/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --..........................................................................

    vr_dtperiod   DATE;
    vr_nrsequen   number;
    vr_idx        VARCHAR2(12);
    vr_numdiaut   INTEGER;

  BEGIN
    vr_dtperiod := pr_dtmvtolt - 360;

    -- Varrer os ultmos 360 dias
    WHILE vr_dtperiod < pr_dtmvtolt LOOP

      -- Buscar primeiro dia util do mês
      vr_numdiaut := FLXF0001.Fn_retorna_numero_dia_util( pr_cdcooper => pr_cdcooper,  -- codigo da cooperativa
                                                          pr_numdiaut => 1,            -- Numero de dia calculado
                                                          pr_dtdatmes => vr_dtperiod); -- Data do periodo


      IF (TO_CHAR(VR_dtperiod,'D') = 2)   AND
         (TO_CHAR(VR_dtperiod,'DD') = vr_numdiaut) AND
         (NOT FLXF0001.fn_feriado_dia_anterior(pr_cdcooper,vr_dtperiod) ) THEN

        --se ainda não existe a data, então inserir
        IF pr_tab_datas.EXISTS(TO_CHAR(vr_dtperiod,'DDMMRRRR')) = FALSE THEN
          --Buscar sequencial
          vr_nrsequen := FLXF0001.fn_ret_prox_sequencia(pr_tab_per_datas);
          vr_idx := '000'||TO_CHAR(vr_dtperiod,'RRRRMMDD');

          pr_tab_per_datas(vr_idx).nrsequen := vr_nrsequen;
          pr_tab_per_datas(vr_idx).dtmvtolt := vr_dtperiod;
          pr_tab_per_datas(vr_idx).cdagrupa := pr_cdagrupa;

          --controle que ja gravou a data
          pr_tab_datas(TO_CHAR(vr_dtperiod,'DDMMRRRR')) := 1;
        END IF;
      END IF;

      -- incrementar data
      vr_dtperiod := vr_dtperiod + 1;
    END LOOP;

    pr_dscritic := 'OK';

  END pc_media_pri_dutil_segfeira;

  -- Procedure para Gerar temptable da media de datas
  PROCEDURE pc_med_dia_util_semana  (pr_cdcooper IN INTEGER      -- Codigo da Cooperativa
                                    ,pr_dtmvtolt IN DATE         -- Data de movimento
                                    ,pr_nrdiasse IN VARCHAR2     -- Numero que representa o dia da semana
                                    ,pr_nrdiasme IN VARCHAR2     -- Numero que representa o dia do mes
                                    ,pr_cdagrupa IN INTEGER DEFAULT NULL       -- Código de agrupamento
                                    ,pr_tipodoct in varchar2     -- Tipo de documento (C-Cheque,T-Titulo-I-Conta Integração )
                                    ,pr_tab_per_datas IN OUT typ_tab_per_datas -- Tabela de datas
                                    ,pr_tab_datas     IN OUT typ_tab_datas     -- tabela com as datas para controle
                                    ,pr_dscritic OUT VARCHAR2) AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_med_dia_util_semana          Antigo: b1wgen0131.p/RegraMediaDiasUteisDaSemanaItg
    --                                                                  RegraMediaDiasUteisDaSemanaChqDoc
    --                                                                  RegraMediaDiasUteisDaSemanaTitulo
    --
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 11/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gera temptable da media de datas
    --
    --   Atualizacao: 08/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --..........................................................................

    vr_dtperiod   DATE;
    vr_tab_diasme GENE0002.typ_split;
    vr_nrsequen   number;
    vr_idx        varchar2(15);

  BEGIN
    vr_dtperiod := pr_dtmvtolt - 360;

    vr_tab_diasme := GENE0002.fn_quebra_string(pr_string => pr_nrdiasme);

    -- Varrer os ultmos 360 dias
    WHILE vr_dtperiod < pr_dtmvtolt LOOP
      -- se for diferente da validação de chequeDoc
      -- e conter dois dias mês informado
      IF pr_tipodoct <> 'C' AND --RegraMediaDiasUteisDaSemanaChqDoc
         vr_tab_diasme.COUNT = 2 THEN
        IF FLXF0001.fn_valid_Media_Dia_Util_Semana ( pr_nrdiasme => pr_nrdiasme -- numero que representa o dia do mes
                                                    ,pr_nrdiasse => pr_nrdiasse -- numero que representa o dia da semana
                                                    ,pr_dtperiod => vr_dtperiod -- Data referencia
                                                    ,pr_cdcooper => pr_cdcooper -- codigo da cooperativa
                                                    ,pr_tipodoct => pr_tipodoct)-- Tipo de documento (C-Cheque,T-Titulo-I-Conta Integração )
          AND
           FLXF0001.fn_valid_Media_Dia_Util_Semana ( pr_nrdiasme => pr_nrdiasme -- numero que representa o dia do mes
                                                    ,pr_nrdiasse => pr_nrdiasse -- numero que representa o dia da semana
                                                    ,pr_dtperiod => vr_dtperiod + 1   -- Data referencia
                                                    ,pr_cdcooper => pr_cdcooper -- codigo da cooperativa
                                                    ,pr_tipodoct => pr_tipodoct)THEN-- Tipo de documento (C-Cheque,T-Titulo-I-Conta Integração )

          --se ainda não existe a data, então inserir
          IF pr_tab_datas.EXISTS(TO_CHAR(vr_dtperiod,'DDMMRRRR')) = FALSE THEN
            --Buscar sequencial
            vr_nrsequen := FLXF0001.fn_ret_prox_sequencia(pr_tab_per_datas);
            vr_idx := lpad(pr_cdagrupa,3,'0')||TO_CHAR(vr_dtperiod,'RRRRMMDD');

            pr_tab_per_datas(vr_idx).nrsequen := vr_nrsequen;
            pr_tab_per_datas(vr_idx).dtmvtolt := vr_dtperiod;
            pr_tab_per_datas(vr_idx).cdagrupa := pr_cdagrupa;

            --controle que ja gravou a data
            pr_tab_datas(TO_CHAR(vr_dtperiod,'DDMMRRRR')) := 1;
          END IF;

          --se ainda não existe a data + 1, então inserir
          IF pr_tab_datas.EXISTS(TO_CHAR(vr_dtperiod + 1,'DDMMRRRR')) = FALSE THEN
            --Buscar sequencial
            vr_nrsequen := FLXF0001.fn_ret_prox_sequencia(pr_tab_per_datas);

            vr_idx := lpad(pr_cdagrupa,3,'0')||TO_CHAR(vr_dtperiod,'RRRRMMDD');
            pr_tab_per_datas(vr_idx).nrsequen := vr_nrsequen;
            pr_tab_per_datas(vr_idx).dtmvtolt := vr_dtperiod + 1;
            pr_tab_per_datas(vr_idx).cdagrupa := pr_cdagrupa;

            --controle que ja gravou a data
            pr_tab_datas(TO_CHAR(vr_dtperiod,'DDMMRRRR')) := 1;
          END IF;

        END IF; -- Fim fn_valid_Media_Dia_Util_Semana
      ELSE
        IF FLXF0001.fn_valid_Media_Dia_Util_Semana ( pr_nrdiasme => pr_nrdiasme -- numero que representa o dia do mes
                                                    ,pr_nrdiasse => pr_nrdiasse -- numero que representa o dia da semana
                                                    ,pr_dtperiod => vr_dtperiod -- Data referencia
                                                    ,pr_cdcooper => pr_cdcooper -- codigo da cooperativa
                                                    ,pr_tipodoct => pr_tipodoct) THEN -- Tipo de documento (C-Cheque,T-Titulo-I-Conta Integração )



          --se ainda não existe a data, então inserir
          IF pr_tab_datas.EXISTS(TO_CHAR(vr_dtperiod,'DDMMRRRR')) = FALSE THEN
            --Buscar sequencial
            vr_nrsequen := FLXF0001.fn_ret_prox_sequencia(pr_tab_per_datas);
            vr_idx := lpad(pr_cdagrupa,3,'0')||TO_CHAR(vr_dtperiod,'RRRRMMDD');

            pr_tab_per_datas(vr_idx).nrsequen := vr_nrsequen;
            pr_tab_per_datas(vr_idx).dtmvtolt := vr_dtperiod;
            pr_tab_per_datas(vr_idx).cdagrupa := pr_cdagrupa;

            --controle que ja gravou a data
            pr_tab_datas(TO_CHAR(vr_dtperiod,'DDMMRRRR')) := 1;
          END IF;

        END IF; -- Fim fn_valid_Media_Dia_Util_Semana


      END IF; -- Fim vr_tab_diasme.COUNT = 2

      -- incrementar data
      vr_dtperiod := vr_dtperiod + 1;

    END LOOP;

    pr_dscritic := 'OK';

  END pc_med_dia_util_semana;

  -- Procedure para gerar os periodo de projeção Itg
  PROCEDURE pc_gera_periodo_projecao_itg
                                    (pr_cdcooper IN INTEGER      -- Codigo da Cooperativa
                                    ,pr_dtmvtolt IN DATE         -- Data de movimento
                                    ,pr_cdagrupa IN INTEGER      -- Código de agrupamento
                                    ,pr_tab_per_datas OUT typ_tab_per_datas -- Tabela de datas
                                    ,pr_dscritic      OUT VARCHAR2) AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_periodo_projecao_itg          Antigo: b1wgen0131.p/gera-periodos-projecao-itg
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 08/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gera os periodo de projeção Itg
    --
    --   Atualizacao: 08/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --..........................................................................

  -- variavel para armazenar ultimo dia do ano
  vr_ultdiaan DATE;
  -- variavel para armazenar primeiro dia do ano
  vr_pridiaan DATE;
  vr_dtperiod DATE;
  vr_nrsequen NUMBER;

  vr_dtnumdia Varchar2(5);
  vr_dtsemdia Varchar2(5);
  vr_listadia Varchar2(10);
  vr_idx      Varchar2(15);

  vr_tab_datas FLXF0001.typ_tab_datas;

  BEGIN

    -- Passar para a função o ultimo dia do ano (ex.31122013), e a funçao retorna o dia util anterior a essa data ou ela mesma.
    vr_ultdiaan := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper, --> Cooperativa conectada
                                               pr_dtmvtolt => to_date('3112'||to_char(pr_dtmvtolt,'RRRR'),'DDMMRRRR'), --> Data do movimento
                                               pr_tipo     => 'A',       --> Tipo de busca (P = proximo, A = anterior)
                                               pr_feriado  => TRUE);

    -- Passar para a função o primeiro dia do ano (ex.01012013), e a funçao retorna o proximo dia util a essa data ou ela mesma.
    vr_pridiaan := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper, --> Cooperativa conectada
                                               pr_dtmvtolt => to_date('0101'||to_char(pr_dtmvtolt,'RRRR'),'DDMMRRRR'), --> Data do movimento
                                               pr_tipo     => 'P',       --> Tipo de busca (P = proximo, A = anterior)
                                               pr_feriado  => TRUE);

    -- Verificar se é o ultimo dia do ano
    IF pr_dtmvtolt = vr_ultdiaan THEN
      -- Passar para a função o ultimo dia do ano anterior (ex.31122013), e a funçao retorna o dia util anterior a essa data ou ela mesma.
      vr_dtperiod := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper, --> Cooperativa conectada
                                                 pr_dtmvtolt => to_date('3112'||(to_char(pr_dtmvtolt,'RRRR')-1), 'DDMMRRRR'), --> Data do movimento
                                                 pr_tipo     => 'A',       --> Tipo de busca (P = proximo, A = anterior)
                                                 pr_feriado  => TRUE);

      --se ainda não existe a data, então inserir
      IF vr_tab_datas.EXISTS(TO_CHAR(vr_dtperiod,'DDMMRRRR')) = FALSE THEN
        --Buscar sequencial
        vr_nrsequen := FLXF0001.fn_ret_prox_sequencia(pr_tab_per_datas);

        vr_idx := lpad(pr_cdagrupa,3,'0')||TO_CHAR(vr_dtperiod,'RRRRMMDD');
        pr_tab_per_datas(vr_idx).nrsequen := vr_nrsequen;
        pr_tab_per_datas(vr_idx).dtmvtolt := vr_dtperiod;

        --controle que ja gravou a data
        Vr_tab_datas(TO_CHAR(vr_dtperiod,'DDMMRRRR')) := 1;

      END IF;

      pr_dscritic := 'OK';
      RETURN;

      -- Verificar se é o primeiro dia do ano
    ELSIF pr_dtmvtolt = vr_pridiaan THEN
      -- Passar para a função o primeiro dia do ano anterior (ex.31122013), e a funçao retorna o proximo dia util a essa data ou ela mesma.
      vr_dtperiod := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper, --> Cooperativa conectada
                                                 pr_dtmvtolt => to_date('0101'||(to_char(pr_dtmvtolt,'RRRR')-1), 'DDMMRRRR'), --> Data do movimento
                                                 pr_tipo     => 'P',       --> Tipo de busca (P = proximo, A = anterior)
                                                 pr_feriado  => TRUE);

      --se ainda não existe a data, então inserir
      IF vr_tab_datas.EXISTS(TO_CHAR(vr_dtperiod,'DDMMRRRR')) = FALSE THEN
        --Buscar sequencial
        vr_nrsequen := FLXF0001.fn_ret_prox_sequencia(pr_tab_per_datas);

        vr_idx := lpad(pr_cdagrupa,3,'0')||TO_CHAR(vr_dtperiod,'RRRRMMDD');

        pr_tab_per_datas(vr_idx).nrsequen := vr_nrsequen;
        pr_tab_per_datas(vr_idx).dtmvtolt := vr_dtperiod;

        --controle que ja gravou a data
        vr_tab_datas(TO_CHAR(vr_dtperiod,'DDMMRRRR')) := 1;
      END IF;

      pr_dscritic := 'OK';
      RETURN;

    -- verifica se o dia anterior é feriado
    ELSIF FLXF0001.fn_feriado_dia_anterior(pr_cdcooper, pr_dtmvtolt) THEN
      -- chamar a propria rotina passando o dia anterior ao feriado
      FLXF0001.pc_gera_periodo_projecao_itg (pr_cdcooper => pr_cdcooper      -- Codigo da Cooperativa
                                            ,pr_dtmvtolt => fn_Busca_Data_anterior_feriado(pr_cdcooper,pr_dtmvtolt)  -- Data de movimento
                                            ,pr_cdagrupa => pr_cdagrupa + 1  -- Código de agrupamento
                                            -- OUT
                                            ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                            ,pr_dscritic      => pr_dscritic);

    END IF; -- fim pr_dtmvtolt = vr_ultdiaan

    vr_dtnumdia := to_char(pr_dtmvtolt,'DD');
    vr_dtsemdia := to_char(pr_dtmvtolt,'D');

    -- Se for diferente de segunda-feira
    IF vr_dtsemdia <> 2 THEN
      vr_listadia := to_char(pr_dtmvtolt,'DD');
      --se for o ultimo dia do mes de fevereiro
      IF ((vr_dtnumdia = 28) OR (vr_dtnumdia = 29)) AND
          (last_day(pr_dtmvtolt) = pr_dtmvtolt) THEN

        FLXF0001.pc_med_dia_util_semana (pr_cdcooper => pr_cdcooper      -- Codigo da Cooperativa
                                        ,pr_dtmvtolt => pr_dtmvtolt      -- Data de movimento
                                        ,pr_nrdiasse => '3,4,5,6'        -- Numero que representa o dia da semana
                                        ,pr_nrdiasme => 30               -- Numero que representa o dia do mes
                                        ,pr_cdagrupa => pr_cdagrupa      -- Código de agrupamento
                                        ,pr_tipodoct => 'I'              -- Tipo de documento (C-Cheque,T-Titulo-I-Conta Integração )
                                        --OUT
                                        ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                        ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                        ,pr_dscritic      => pr_dscritic);

      ELSE
        FLXF0001.pc_med_dia_util_semana (pr_cdcooper => pr_cdcooper      -- Codigo da Cooperativa
                                        ,pr_dtmvtolt => pr_dtmvtolt      -- Data de movimento
                                        ,pr_nrdiasse => '3,4,5,6'        -- Numero que representa o dia da semana
                                        ,pr_nrdiasme => vr_listadia      -- Numero que representa o dia do mes
                                        ,pr_cdagrupa => pr_cdagrupa      -- Código de agrupamento
                                        ,pr_tipodoct => 'I'              -- Tipo de documento (C-Cheque,T-Titulo-I-Conta Integração )
                                        --OUT
                                        ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                        ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                        ,pr_dscritic      => pr_dscritic);
      END IF; -- Fim fevereiro
    ELSE
      IF vr_dtnumdia in (1,2,3) THEN
        FLXF0001.pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                          ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                          ,pr_listdias => '01,02,03'     -- Lista de dias do mes
                                          ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                          --OUT
                                          ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                          ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                          ,pr_dscritic      => pr_dscritic );
      ELSIF vr_dtnumdia = 4 THEN
        FLXF0001.pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                          ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                          ,pr_listdias => '01,02,03,04'   -- Lista de dias do mes
                                          ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                          --OUT
                                          ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                          ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                          ,pr_dscritic      => pr_dscritic );
      ELSIF vr_dtnumdia in (5,6,7) THEN
        FLXF0001.pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                          ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                          ,pr_listdias => '05,06,07'     -- Lista de dias do mes
                                          ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                          --OUT
                                          ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                          ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                          ,pr_dscritic      => pr_dscritic );
      ELSIF vr_dtnumdia in (8,9) THEN
        FLXF0001.pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                          ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                          ,pr_listdias => '08,09'       -- Lista de dias do mes
                                          ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                          --OUT
                                          ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                          ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                          ,pr_dscritic => pr_dscritic );

      ELSIF vr_dtnumdia in (10,11,12) THEN
        FLXF0001.pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                          ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                          ,pr_listdias => '10,11,12'  -- Lista de dias do mes
                                          ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                          --OUT
                                          ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                          ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                          ,pr_dscritic => pr_dscritic );

      ELSIF vr_dtnumdia in (13,14) THEN
        FLXF0001.pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                          ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                          ,pr_listdias => '13,14'     -- Lista de dias do mes
                                          ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                          --OUT
                                          ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                          ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                          ,pr_dscritic      => pr_dscritic );

      ELSIF vr_dtnumdia in (15,16,17) THEN
        FLXF0001.pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                          ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                          ,pr_listdias => '15,16,17'  -- Lista de dias do mes
                                          ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                          --OUT
                                          ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                          ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                          ,pr_dscritic      => pr_dscritic );
      ELSIF vr_dtnumdia in (18,19) THEN
        FLXF0001.pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                          ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                          ,pr_listdias => '18,19'     -- Lista de dias do mes
                                          ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                          --OUT
                                          ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                          ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                          ,pr_dscritic => pr_dscritic );
      ELSIF vr_dtnumdia in (20,21,22) THEN
        FLXF0001.pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                          ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                          ,pr_listdias => '20,21,22'  -- Lista de dias do mes
                                          ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                          --OUT
                                          ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                          ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                          ,pr_dscritic => pr_dscritic );
      ELSIF vr_dtnumdia in (23,24) THEN
        FLXF0001.pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                          ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                          ,pr_listdias => '23,24'     -- Lista de dias do mes
                                          ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                          --OUT
                                          ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                          ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                          ,pr_dscritic      => pr_dscritic );

      ELSIF vr_dtnumdia in (25,26,27) THEN
        FLXF0001.pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                          ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                          ,pr_listdias => '25,26,27'  -- Lista de dias do mes
                                          ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                          --OUT
                                          ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                          ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                          ,pr_dscritic      => pr_dscritic );

      ELSIF vr_dtnumdia in (28,29) THEN
        IF LAST_DAY(pr_dtmvtolt) = pr_dtmvtolt THEN
          FLXF0001.pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                            ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                            ,pr_listdias => '30,31'     -- Lista de dias do mes
                                            ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                            --OUT
                                            ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                            ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                            ,pr_dscritic      => pr_dscritic );
        ELSE
          FLXF0001.pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                            ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                            ,pr_listdias => '28,29'     -- Lista de dias do mes
                                            ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                            --OUT
                                            ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                            ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                            ,pr_dscritic      => pr_dscritic );
        END IF;
      ELSIF vr_dtnumdia in (30,31) THEN
        FLXF0001.pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                          ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                          ,pr_listdias => '30,31'     -- Lista de dias do mes
                                          ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                          --OUT
                                          ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                          ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                          ,pr_dscritic      => pr_dscritic );
      ELSE
        FLXF0001.pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                          ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                          ,pr_listdias => vr_dtnumdia -- Lista de dias do mes
                                          ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                          --OUT
                                          ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                          ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                          ,pr_dscritic      => pr_dscritic );
      END IF;
    END IF; --Fim vr_dtsemdia <> 2

  END pc_gera_periodo_projecao_itg;

  -- Procedure para gravar movimento financeiro das contas Itg
  PROCEDURE pc_grava_mvt_conta_itg  ( pr_cdcooper IN INTEGER      -- Codigo da Cooperativa
                                     ,pr_cdagenci IN INTEGER      -- Codigo da agencia
                                     ,pr_nrdcaixa IN INTEGER      -- Numero da caixa
                                     ,pr_cdoperad IN crapope.cdoperad%type     -- Codigo do operador
                                     ,pr_dtmvtolt IN DATE         -- Data de movimento
                                     ,pr_nmdatela IN VARCHAR2     -- Nome da tela
                                     ,pr_tpdmovto IN NUMBER       -- tipo de movimento(1-entrada 2-saida)
                                     ,pr_cdcoopex IN VARCHAR2     -- Codigo da Cooperativa
                                     ,pr_dscritic OUT VARCHAR2)AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_mvt_conta_itg_ent          Antigo: b1wgen0131.p/1-pi_rec_mov_conta_itg_f
    --                                                                      2-pi_rem_mov_conta_itg_f
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 11/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar movimento financeiro das contas Itg
    --
    --   Atualizacao: 08/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --..........................................................................

    vr_exc_erro      EXCEPTION;
    vr_tab_cdbccxlt  gene0002.typ_split;
    vr_tab_per_datas FLXF0001.typ_tab_per_datas;
    vr_maiorvlr      NUMBER;
    vr_contador      NUMBER;
    vr_vlrttdev      NUMBER;
    vr_vlrmedia      NUMBER;
    vr_idx           VARCHAR2(15);
    vr_dstextab      craptab.dstextab%type;

    -- Busca lancamentos
    CURSOR cr_craplcm (pr_dtmvtolt DATE,
                       pr_cdcoopex NUMBER,
                       pr_tpdmovto NUMBER) IS
      SELECT nvl(sum(vllanmto),0) vllanmto
        FROM craplcm
       WHERE craplcm.cdcooper = pr_cdcoopex
         AND (  --Entrada
               (pr_tpdmovto = 1 and craplcm.cdhistor IN (170,646,314,584,651,169,444,662,191,694))
              or --Saida
               (pr_tpdmovto = 2 and craplcm.cdhistor IN (297,290,614,658,613,668,471,661,50,59))
              )
         AND craplcm.dtmvtolt = pr_dtmvtolt;

  BEGIN

    vr_contador := 0;
    vr_vlrttdev := 0;
    vr_vlrmedia := 0;
    vr_maiorvlr := 0;

    -- gerar os periodo de projeção Itg
    FLXF0001.pc_gera_periodo_projecao_itg (pr_cdcooper => pr_cdcooper  -- Codigo da Cooperativa
                                          ,pr_dtmvtolt => pr_dtmvtolt  -- Data de movimento
                                          ,pr_cdagrupa => 1            -- Código de agrupamento
                                          --out
                                          ,pr_tab_per_datas => vr_tab_per_datas -- Tabela de datas
                                          ,pr_dscritic      => pr_dscritic);

    IF pr_dscritic <> 'OK' THEN
      RAISE vr_exc_erro;
    ELSE
      pr_dscritic := NULL;
    END IF;

    vr_idx := vr_tab_per_datas.first;
    LOOP
      EXIT WHEN vr_idx IS NULL;

      -- buscar lançamentos
      FOR rw_craplcm IN cr_craplcm(pr_dtmvtolt => vr_tab_per_datas(vr_idx).dtmvtolt,
                                   pr_cdcoopex => pr_cdcoopex,
                                   pr_tpdmovto => pr_tpdmovto ) LOOP
        -- Somar valores
        vr_tab_per_datas(vr_idx).vlrtotal := NVL(vr_tab_per_datas(vr_idx).vlrtotal,0) + NVL(rw_craplcm.vllanmto,0);
      END LOOP;

      -- identificar maior valor se for entrada
      IF NVL(vr_tab_per_datas(vr_idx).vlrtotal,0) > NVL(vr_maiorvlr,0) AND
         pr_tpdmovto = 1 THEN
        vr_maiorvlr := vr_tab_per_datas(vr_idx).vlrtotal;
      END IF;

      vr_vlrttdev := NVL(vr_vlrttdev,0) + NVL(vr_tab_per_datas(vr_idx).vlrtotal,0);
      vr_contador := vr_contador + 1;

      IF vr_idx = vr_tab_per_datas.LAST OR
         vr_tab_per_datas(vr_idx).cdagrupa <> vr_tab_per_datas(nvl(vr_tab_per_datas.NEXT(vr_idx),vr_idx)).cdagrupa then

        -- SE FOR ENTRADA
        IF pr_tpdmovto = 1 THEN
          IF (vr_contador > 1) THEN
            vr_vlrttdev := vr_vlrttdev - vr_maiorvlr;
            vr_vlrmedia := vr_vlrmedia + (vr_vlrttdev  / (vr_contador - 1));
          ELSE
            vr_vlrttdev := vr_maiorvlr;
            vr_vlrmedia := vr_vlrmedia + (vr_vlrttdev  / (vr_contador));
          END IF;
        -- SE FOR SAIDA
        ELSIF pr_tpdmovto = 2 THEN
          vr_vlrmedia := vr_vlrmedia + (vr_vlrttdev  / (vr_contador));
        END IF;

        vr_vlrttdev := 0;
        vr_contador := 0;
        vr_maiorvlr := 0;
      END IF;

      vr_idx := vr_tab_per_datas.NEXT(vr_idx);
    END LOOP;

    -- Buscar informacoes para calculo de poupanca
    vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                             ,pr_nmsistem => 'CRED'
                                             ,pr_tptabela => 'GENERI'
                                             ,pr_cdempres => 00
                                             ,pr_cdacesso => 'PARFLUXOFINAN'
                                             ,pr_tpregist => 0);

    -- SE FOR ENTRADA, BUSCAR POSIÇÃO 6
    IF pr_tpdmovto = 1 THEN
      vr_vlrmedia := vr_vlrmedia +  ((vr_vlrmedia *
                                  to_number(gene0002.fn_busca_entrada(6,vr_dstextab,';'))) / 100);
    -- SE FOR SAIDA, BUSCAR POSIÇÃO 7
    ELSIF pr_tpdmovto = 2 THEN
      vr_vlrmedia := vr_vlrmedia +  ((vr_vlrmedia *
                                  to_number(gene0002.fn_busca_entrada(7,vr_dstextab,';'))) / 100);
    END IF;

    vr_tab_cdbccxlt := gene0002.fn_quebra_string('01,85,756,100',',');

    FOR idx IN vr_tab_cdbccxlt.first..vr_tab_cdbccxlt.last LOOP
      FLXF0001.pc_grava_movimentacao(pr_cdcooper => pr_cdcooper      -- Codigo da Cooperativa
                                    ,pr_cdoperad => pr_cdoperad      -- Codigo do operador
                                    ,pr_dtmvtolt => pr_dtmvtolt      -- Data de movimento
                                    ,pr_tpdmovto => pr_tpdmovto         -- Tipo de movimento
                                    ,pr_cdbccxlt => vr_tab_cdbccxlt(idx)-- Codigo do banco/caixa.
                                    ,pr_tpdcampo => 6  /*VLMVTITG*/     -- Tipo de campo
                                    ,pr_vldcampo => (case vr_tab_cdbccxlt(idx)
                                                     when '01' then vr_vlrmedia
                                                     else 0
                                                     end)               -- Valor do campo
                                    ,pr_dscritic => pr_dscritic);

      IF pr_dscritic <> 'OK' THEN
        RAISE vr_exc_erro;
      END IF;

    END LOOP;

    pr_dscritic := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
        NULL;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na FLXF0001.pc_grava_mvt_conta_itg: '||SQLerrm;
  END pc_grava_mvt_conta_itg;

  -- Procedure para gerar os periodo de projeção cheque doc
  PROCEDURE pc_gr_periodo_projecao_chqdoc
                                    (pr_cdcooper IN INTEGER      -- Codigo da Cooperativa
                                    ,pr_dtmvtolt IN DATE         -- Data de movimento
                                    ,pr_tab_per_datas OUT typ_tab_per_datas -- Tabela de datas
                                    ,pr_dscritic      OUT VARCHAR2) AS      -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_gera_periodo_projecao_chqdoc          Antigo: b1wgen0131.p/gera-periodos-projecao-chqdoc
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 12/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gera os periodo de projeção do chqdoc
    --
    --   Atualizacao: 08/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --..........................................................................

  -- variavel para armazenar ultimo dia do ano
  vr_ultdiaan DATE;
  -- variavel para armazenar primeiro dia do ano
  vr_pridiaan DATE;
  vr_dtperiod DATE;
  vr_nrsequen NUMBER;
  -- Variavel para controlar dias(dia mes e dia semana)
  vr_dtnumdia Varchar2(5);
  vr_dtsemdia Varchar2(5);

  vr_tab_datas FLXF0001.typ_tab_datas;
  vr_idx       varchar2(15);

  BEGIN

    -- Passar para a função o ultimo dia do ano (ex.31122013), e a funçao retorna o dia util anterior a essa data ou ela mesma.
    vr_ultdiaan := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper, --> Cooperativa conectada
                                               pr_dtmvtolt => to_date('3112'||to_char(pr_dtmvtolt,'RRRR'),'DDMMRRRR'), --> Data do movimento
                                               pr_tipo     => 'A',       --> Tipo de busca (P = proximo, A = anterior)
                                               pr_feriado  => TRUE);

    -- Passar para a função o primeiro dia do ano (ex.01012013), e a funçao retorna o proximo dia util a essa data ou ela mesma.
    vr_pridiaan := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper, --> Cooperativa conectada
                                               pr_dtmvtolt => to_date('0101'||to_char(pr_dtmvtolt,'RRRR'),'DDMMRRRR'), --> Data do movimento
                                               pr_tipo     => 'P',       --> Tipo de busca (P = proximo, A = anterior)
                                               pr_feriado  => TRUE);

    -- Verificar se é o ultimo dia do ano
    IF pr_dtmvtolt = vr_ultdiaan THEN
      -- Passar para a função o ultimo dia do ano anterior (ex.31122013), e a funçao retorna o dia util anterior a essa data ou ela mesma.
      vr_dtperiod := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper, --> Cooperativa conectada
                                                 pr_dtmvtolt => to_date('3112'||(to_char(pr_dtmvtolt,'RRRR')-1), 'DDMMRRRR'), --> Data do movimento
                                                 pr_tipo     => 'A',       --> Tipo de busca (P = proximo, A = anterior)
                                                 pr_feriado  => TRUE);

      --se ainda não existe a data, então inserir
      IF vr_tab_datas.EXISTS(TO_CHAR(vr_dtperiod,'DDMMRRRR')) = FALSE THEN
        --Buscar sequencial
        vr_nrsequen := FLXF0001.fn_ret_prox_sequencia(pr_tab_per_datas);

        vr_idx := '000'||TO_CHAR(vr_dtperiod,'RRRRMMDD');

        pr_tab_per_datas(vr_idx).nrsequen := vr_nrsequen;
        pr_tab_per_datas(vr_idx).dtmvtolt := vr_dtperiod;

        --controle que ja gravou a data
        vr_tab_datas(TO_CHAR(vr_dtperiod,'DDMMRRRR')) := 1;
      END IF;

      pr_dscritic := 'OK';
      RETURN;

      -- Verificar se é o primeiro dia do ano
    ELSIF pr_dtmvtolt = vr_pridiaan THEN
      -- Passar para a função o primeiro dia do ano anterior (ex.31122013), e a funçao retorna o proximo dia util a essa data ou ela mesma.
      vr_dtperiod := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper, --> Cooperativa conectada
                                                 pr_dtmvtolt => to_date('0101'||(to_char(pr_dtmvtolt,'RRRR')-1), 'DDMMRRRR'), --> Data do movimento
                                                 pr_tipo     => 'P',       --> Tipo de busca (P = proximo, A = anterior)
                                                 pr_feriado  => TRUE);

      --se ainda não existe a data, então inserir
      IF vr_tab_datas.EXISTS(TO_CHAR(vr_dtperiod,'DDMMRRRR')) = FALSE THEN
        --Buscar sequencial
        vr_nrsequen := FLXF0001.fn_ret_prox_sequencia(pr_tab_per_datas);

        vr_idx := '000'||TO_CHAR(vr_dtperiod,'RRRRMMDD');

        pr_tab_per_datas(vr_idx).nrsequen := vr_nrsequen;
        pr_tab_per_datas(vr_idx).dtmvtolt := vr_dtperiod;

        --controle que ja gravou a data
        vr_tab_datas(TO_CHAR(vr_dtperiod,'DDMMRRRR')) := 1;
      END IF;

      pr_dscritic := 'OK';
      RETURN;

    END IF; -- fim pr_dtmvtolt = vr_ultdiaan

    vr_dtnumdia := to_char(pr_dtmvtolt,'DD');
    vr_dtsemdia := to_char(pr_dtmvtolt,'D');

    --Se o dia anterior é feriado, atribuir variavel como segunda feira
    IF FLXF0001.fn_verifica_feriado(pr_cdcooper, pr_dtmvtolt - 1) THEN
      vr_dtsemdia := 2;
    END IF;

    -- Se for diferente de segunda-feira
    IF vr_dtsemdia <> 2 THEN
      IF vr_dtnumdia IN ('07','08',12,13,17,18) THEN
        IF vr_dtsemdia = 3 THEN
          FLXF0001.pc_med_dia_util_semana (pr_cdcooper => pr_cdcooper  -- Codigo da Cooperativa
                                          ,pr_dtmvtolt => pr_dtmvtolt  -- Data de movimento
                                          ,pr_nrdiasse => '3'          -- Numero que representa o dia da semana
                                          ,pr_nrdiasme => TO_CHAR(pr_dtmvtolt,'DD')               -- Numero que representa o dia do mes
                                          ,pr_cdagrupa => NULL         -- Código de agrupamento
                                          ,pr_tipodoct => 'C'          -- Tipo de documento (C-Cheque,T-Titulo-I-Conta Integração )
                                          --OUT
                                          ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                          ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                          ,pr_dscritic      => pr_dscritic);

          IF NVL(pr_tab_per_datas.COUNT,0) = 0 THEN
            IF vr_dtnumdia IN ('07','12',17) THEN
              FLXF0001.pc_med_dia_util_semana (pr_cdcooper => pr_cdcooper  -- Codigo da Cooperativa
                                              ,pr_dtmvtolt => pr_dtmvtolt  -- Data de movimento
                                              ,pr_nrdiasse => '3'          -- Numero que representa o dia da semana
                                              ,pr_nrdiasme => TO_CHAR(pr_dtmvtolt-1,'DD')               -- Numero que representa o dia do mes
                                              ,pr_cdagrupa => NULL         -- Código de agrupamento
                                              ,pr_tipodoct => 'C'          -- Tipo de documento (C-Cheque,T-Titulo-I-Conta Integração )
                                              --OUT
                                              ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                              ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                              ,pr_dscritic      => pr_dscritic);
            ELSE
              FLXF0001.pc_med_dia_util_semana (pr_cdcooper => pr_cdcooper  -- Codigo da Cooperativa
                                              ,pr_dtmvtolt => pr_dtmvtolt  -- Data de movimento
                                              ,pr_nrdiasse => '3'          -- Numero que representa o dia da semana
                                              ,pr_nrdiasme => TO_CHAR(pr_dtmvtolt-1,'DD')||','||TO_CHAR(pr_dtmvtolt-2,'DD') -- Numero que representa o dia do mes
                                              ,pr_cdagrupa => NULL         -- Código de agrupamento
                                              ,pr_tipodoct => 'C'          -- Tipo de documento (C-Cheque,T-Titulo-I-Conta Integração )
                                              --OUT
                                              ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                              ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                              ,pr_dscritic      => pr_dscritic);
            END IF;-- Fim vr_dtnumdia IN ('07','12',17)

          END IF;

        ELSE
          IF vr_dtnumdia IN ('07','08',13,18) THEN
            FLXF0001.pc_med_dia_util_semana (pr_cdcooper => pr_cdcooper  -- Codigo da Cooperativa
                                            ,pr_dtmvtolt => pr_dtmvtolt  -- Data de movimento
                                            ,pr_nrdiasse => '3,4,5,6'    -- Numero que representa o dia da semana
                                            ,pr_nrdiasme => TO_CHAR(pr_dtmvtolt,'DD')               -- Numero que representa o dia do mes
                                            ,pr_cdagrupa => NULL         -- Código de agrupamento
                                            ,pr_tipodoct => 'C'          -- Tipo de documento (C-Cheque,T-Titulo-I-Conta Integração )
                                            --OUT
                                            ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                            ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                            ,pr_dscritic      => pr_dscritic);
          ELSE
            FLXF0001.pc_med_dia_util_semana (pr_cdcooper => pr_cdcooper  -- Codigo da Cooperativa
                                            ,pr_dtmvtolt => pr_dtmvtolt  -- Data de movimento
                                            ,pr_nrdiasse => '4,5,6'      -- Numero que representa o dia da semana
                                            ,pr_nrdiasme => TO_CHAR(pr_dtmvtolt,'DD')               -- Numero que representa o dia do mes
                                            ,pr_cdagrupa => NULL         -- Código de agrupamento
                                            ,pr_tipodoct => 'C'          -- Tipo de documento (C-Cheque,T-Titulo-I-Conta Integração )
                                            --OUT
                                            ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                            ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                            ,pr_dscritic      => pr_dscritic);
          END IF; -- Fim vr_dtnumdia IN ('07','08',13,18)
        END IF; -- Fim vr_dtsemdia = 3
      ELSE
        --se for o ultimo dia do mes de fevereiro
        IF ((vr_dtnumdia = 28) OR (vr_dtnumdia = 29)) AND
            (last_day(pr_dtmvtolt) = pr_dtmvtolt) THEN

          FLXF0001.pc_med_dia_util_semana (pr_cdcooper => pr_cdcooper      -- Codigo da Cooperativa
                                          ,pr_dtmvtolt => pr_dtmvtolt      -- Data de movimento
                                          ,pr_nrdiasse => '3,4,5,6'        -- Numero que representa o dia da semana
                                          ,pr_nrdiasme => '30'             -- Numero que representa o dia do mes
                                          ,pr_cdagrupa => null             -- Código de agrupamento
                                          ,pr_tipodoct => 'C'              -- Tipo de documento (C-Cheque,T-Titulo-I-Conta Integração )
                                          --OUT
                                          ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                          ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                          ,pr_dscritic      => pr_dscritic);

        ELSE
          FLXF0001.pc_med_dia_util_semana (pr_cdcooper => pr_cdcooper      -- Codigo da Cooperativa
                                          ,pr_dtmvtolt => pr_dtmvtolt      -- Data de movimento
                                          ,pr_nrdiasse => '3,4,5,6'        -- Numero que representa o dia da semana
                                          ,pr_nrdiasme => to_char(pr_dtmvtolt,'DD')      -- Numero que representa o dia do mes
                                          ,pr_cdagrupa => NULL             -- Código de agrupamento
                                          ,pr_tipodoct => 'C'              -- Tipo de documento (C-Cheque,T-Titulo-I-Conta Integração )
                                          --OUT
                                          ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                          ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                          ,pr_dscritic      => pr_dscritic);
        END IF; -- Fim fevereiro
      END IF; -- Fim vr_dtnumdia IN ('07','08',12,13,17,18)

    ELSE
      IF vr_dtnumdia in ('01','02','03') THEN
        FLXF0001.pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                          ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                          ,pr_listdias => '01,02,03'     -- Lista de dias do mes
                                          ,pr_cdagrupa => NULL        -- Código de agrupamento
                                          --OUT
                                          ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                          ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                          ,pr_dscritic => pr_dscritic );
      ELSIF vr_dtnumdia = 15 THEN
        FLXF0001.pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                          ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                          ,pr_listdias => vr_dtnumdia -- Lista de dias do mes
                                          ,pr_cdagrupa => NULL        -- Código de agrupamento
                                          --OUT
                                          ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                          ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                          ,pr_dscritic => pr_dscritic );

        IF NVL(pr_tab_per_datas.COUNT,0) = 0 THEN
          FLXF0001.pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                          ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                                          ,pr_listdias => fn_Busca_Lista_Dias(vr_dtnumdia)     -- Lista de dias do mes
                                          ,pr_cdagrupa => NULL          -- Código de agrupamento
                                          --OUT
                                          ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                          ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                          ,pr_dscritic => pr_dscritic );
        END IF;

      ELSIF vr_dtnumdia = 21 THEN
        FLXF0001.pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                          ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                          ,pr_listdias => '20,21'     -- Lista de dias do mes
                                          ,pr_cdagrupa => NULL        -- Código de agrupamento
                                          --OUT
                                          ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                          ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                          ,pr_dscritic => pr_dscritic );

        IF NVL(pr_tab_per_datas.COUNT,0) = 0 THEN
          FLXF0001.pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                          ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                                          ,pr_listdias => fn_Busca_Lista_Dias(vr_dtnumdia)     -- Lista de dias do mes
                                          ,pr_cdagrupa => NULL          -- Código de agrupamento
                                          --OUT
                                          ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                          ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                          ,pr_dscritic => pr_dscritic );
        END IF;

      ELSIF vr_dtnumdia = 22 THEN
        FLXF0001.pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                          ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                          ,pr_listdias => '20,22'     -- Lista de dias do mes
                                          ,pr_cdagrupa => NULL        -- Código de agrupamento
                                          --OUT
                                          ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                          ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                          ,pr_dscritic => pr_dscritic );

        IF NVL(pr_tab_per_datas.COUNT,0) = 0 THEN
          FLXF0001.pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                          ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                                          ,pr_listdias => fn_Busca_Lista_Dias(vr_dtnumdia)     -- Lista de dias do mes
                                          ,pr_cdagrupa => NULL          -- Código de agrupamento
                                          --OUT
                                          ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                          ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                          ,pr_dscritic => pr_dscritic );
        END IF;

      ELSIF vr_dtnumdia in (28,29) THEN
        IF LAST_DAY(pr_dtmvtolt) = pr_dtmvtolt THEN
          FLXF0001.pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                            ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                            ,pr_listdias => '30'        -- Lista de dias do mes
                                            ,pr_cdagrupa => NULL        -- Código de agrupamento
                                            --OUT
                                            ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                            ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                            ,pr_dscritic      => pr_dscritic );

          IF NVL(pr_tab_per_datas.COUNT,0) = 0 THEN
            FLXF0001.pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                            ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                                            ,pr_listdias => fn_Busca_Lista_Dias(vr_dtnumdia)     -- Lista de dias do mes
                                            ,pr_cdagrupa => NULL          -- Código de agrupamento
                                            --OUT
                                            ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                            ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                            ,pr_dscritic => pr_dscritic );
          END IF;
        ELSE
          FLXF0001.pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                            ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                            ,pr_listdias => vr_dtnumdia -- Lista de dias do mes
                                            ,pr_cdagrupa => NULL        -- Código de agrupamento
                                            --OUT
                                            ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                            ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                            ,pr_dscritic      => pr_dscritic );

          IF NVL(pr_tab_per_datas.COUNT,0) = 0 THEN
            FLXF0001.pc_media_dia_util_segfeira
                                    (pr_cdcooper  => pr_cdcooper    -- Codigo da Cooperativa
                                    ,pr_dtmvtolt  => pr_dtmvtolt    -- Data de movimento
                                    ,pr_numdiaut  => FLXF0001.fn_calcula_dia_util(vr_dtnumdia)   -- Numero de dia calculado
                                    ,pr_diaminim  => FLXF0001.fn_busca_limite_dia(vr_dtnumdia,1) -- Qtd de dias limite minimo
                                    ,pr_diamaxim  => FLXF0001.fn_busca_limite_dia(vr_dtnumdia,2) -- Qtd de dias limite maximo
                                    ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                    ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                    ,pr_dscritic      => pr_dscritic);

            IF NVL(pr_tab_per_datas.COUNT,0) = 0 THEN
              FLXF0001.pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                              ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                                              ,pr_listdias => FLXF0001.fn_Busca_Lista_Dias(vr_dtnumdia) -- Lista de dias do mes
                                              ,pr_cdagrupa => NULL          -- Código de agrupamento
                                              --OUT
                                              ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                              ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                              ,pr_dscritic => pr_dscritic );
            END IF;
          END IF;
        END IF;
      ELSIF vr_dtnumdia = 30 THEN
        FLXF0001.pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                          ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                          ,pr_listdias => vr_dtnumdia -- Lista de dias do mes
                                          ,pr_cdagrupa => NULL        -- Código de agrupamento
                                          --OUT
                                          ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                          ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                          ,pr_dscritic => pr_dscritic );

        IF NVL(pr_tab_per_datas.COUNT,0) = 0 THEN
          FLXF0001.pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                          ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                                          ,pr_listdias => fn_Busca_Lista_Dias(vr_dtnumdia)     -- Lista de dias do mes
                                          ,pr_cdagrupa => NULL          -- Código de agrupamento
                                          --OUT
                                          ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                          ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                          ,pr_dscritic => pr_dscritic );
        END IF;

      ELSIF vr_dtnumdia = 31 THEN
        FLXF0001.pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                          ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                          ,pr_listdias => '30,31'     -- Lista de dias do mes
                                          ,pr_cdagrupa => NULL        -- Código de agrupamento
                                          --OUT
                                          ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                          ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                          ,pr_dscritic => pr_dscritic );

        IF NVL(pr_tab_per_datas.COUNT,0) = 0 THEN
          FLXF0001.pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                          ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                                          ,pr_listdias => fn_Busca_Lista_Dias(vr_dtnumdia)     -- Lista de dias do mes
                                          ,pr_cdagrupa => NULL          -- Código de agrupamento
                                          --OUT
                                          ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                          ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                          ,pr_dscritic => pr_dscritic );
        END IF;

      ELSE
        FLXF0001.pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                          ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                          ,pr_listdias => vr_dtnumdia -- Lista de dias do mes
                                          ,pr_cdagrupa => NULL        -- Código de agrupamento
                                          --OUT
                                          ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                          ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                          ,pr_dscritic      => pr_dscritic );

        IF NVL(pr_tab_per_datas.COUNT,0) = 0 THEN
          FLXF0001.pc_media_dia_util_segfeira
                                    (pr_cdcooper  => pr_cdcooper    -- Codigo da Cooperativa
                                    ,pr_dtmvtolt  => pr_dtmvtolt    -- Data de movimento
                                    ,pr_numdiaut  => FLXF0001.fn_calcula_dia_util(vr_dtnumdia)   -- Numero de dia calculado
                                    ,pr_diaminim  => FLXF0001.fn_busca_limite_dia(vr_dtnumdia,1) -- Qtd de dias limite minimo
                                    ,pr_diamaxim  => FLXF0001.fn_busca_limite_dia(vr_dtnumdia,2) -- Qtd de dias limite maximo
                                    ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                    ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                    ,pr_dscritic      => pr_dscritic);

          IF NVL(pr_tab_per_datas.COUNT,0) = 0 THEN
            FLXF0001.pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                              ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                              ,pr_listdias => fn_Busca_Lista_Dias(vr_dtnumdia)     -- Lista de dias do mes
                                              ,pr_cdagrupa => NULL        -- Código de agrupamento
                                              --OUT
                                              ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                              ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                              ,pr_dscritic      => pr_dscritic );
          END IF;
        END IF;
      END IF; --Fim vr_dtnumdia = N
    END IF; --Fim vr_dtsemdia <> 2

    pr_dscritic := 'OK';

  END pc_gr_periodo_projecao_chqdoc;

  -- Procedure para gravar movimento financeiro de cheques saida
  PROCEDURE pc_grava_mvt_cheques  ( pr_cdcooper IN INTEGER      -- Codigo da Cooperativa
                                   ,pr_cdagenci IN INTEGER      -- Codigo da agencia
                                   ,pr_nrdcaixa IN INTEGER      -- Numero da caixa
                                   ,pr_cdoperad IN crapope.cdoperad%type  -- Codigo do operador
                                   ,pr_dtmvtolt IN DATE         -- Data de movimento
                                   ,pr_nmdatela IN VARCHAR2     -- Nome da tela
                                   ,pr_tab_erro OUT GENE0001.typ_tab_erro -- Tabela contendo os erros
                                   ,pr_dscritic OUT VARCHAR2) AS          -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_mvt_cheques          Antigo: b1wgen0131.p/pi_sr_cheques_f
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 11/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar movimento financeiro de cheques saida
    --
    --   Atualizacao: 08/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --..........................................................................

    vr_exc_erro      EXCEPTION;
    vr_tab_per_datas FLXF0001.typ_tab_per_datas;
    vr_idx           VARCHAR2(15);
    vr_dtproxim      DATE;
    vr_mesanter      NUMBER := 0;
    vr_contador      NUMBER;
    vr_vltotger      NUMBER(20,2);
    vr_vlrmedia      NUMBER(20,2);
    vr_dstextab      CRAPTAB.dstextab%type;
    -- Variavel para armazenar os cdbancos para fazer o loop
    vr_tab_cdbccxlt  gene0002.typ_split;
    vr_nrsequen      number;

    -- Ler lancamentos de deposito a vista, do proxima data a ser simulada
    CURSOR cr_craplcm_p (pr_dtproxim DATE,
                         pr_cdcooper NUMBER,
                         pr_dtmvtolt DATE) IS
      SELECT nvl(sum(vllanmto),0) vllanmto
        FROM craplcm
       WHERE craplcm.cdcooper = pr_cdcooper
         AND craplcm.cdhistor IN (524) /* CHEQUE COMP. */
         AND ( craplcm.dtmvtolt = pr_dtproxim AND
               craplcm.dtrefere is not null   AND
               craplcm.dtrefere = pr_dtmvtolt
               );

    -- Ler lancamentos de deposito a vista da data atual
    CURSOR cr_craplcm  (pr_cdcooper NUMBER,
                        pr_dtmvtolt DATE) IS
      SELECT nvl(sum(vllanmto),0) vllanmto
        FROM craplcm
       WHERE craplcm.cdcooper = pr_cdcooper
         AND craplcm.cdhistor IN (524) /* CHEQUE COMP. */
         AND ( craplcm.dtmvtolt = pr_dtmvtolt AND
               craplcm.dtrefere is null
               );
  BEGIN
    FLXF0001.pc_gr_periodo_projecao_chqdoc
                                    (pr_cdcooper => pr_cdcooper          -- Codigo da Cooperativa
                                    ,pr_dtmvtolt => pr_dtmvtolt          -- Data de movimento
                                    ,pr_tab_per_datas => vr_tab_per_datas-- Tabela de datas
                                    ,pr_dscritic      => pr_dscritic);   -- Descrição da critica

    IF pr_dscritic <> 'OK' THEN
      return;
    END IF;

    vr_idx := vr_tab_per_datas.first;
    LOOP
      EXIT WHEN vr_idx is null;
      --busca proxima data util
      vr_dtproxim := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper,
                                                 pr_dtmvtolt => vr_tab_per_datas(vr_idx).dtmvtolt + 1,
                                                 pr_tipo     => 'P' ,
                                                 pr_feriado  => TRUE );

      -- Buscar lancamentos do proximo dia util
      FOR rw_craplcm IN cr_craplcm_p (pr_dtproxim => vr_dtproxim,
                                      pr_cdcooper => pr_cdcooper,
                                      pr_dtmvtolt => vr_tab_per_datas(vr_idx).dtmvtolt) LOOP

        vr_tab_per_datas(vr_idx).vlrtotal := nvl(vr_tab_per_datas(vr_idx).vlrtotal,0) + nvl(rw_craplcm.vllanmto,0);
      END LOOP;

      -- Buscar lancamentos do dia e data de referencia nula
      FOR rw_craplcm IN cr_craplcm (pr_cdcooper => pr_cdcooper,
                                    pr_dtmvtolt => vr_tab_per_datas(vr_idx).dtmvtolt) LOOP

        vr_tab_per_datas(vr_idx).vlrtotal := nvl(vr_tab_per_datas(vr_idx).vlrtotal,0) + nvl(rw_craplcm.vllanmto,0);
      END LOOP;

      -- Buscar lancamentos do dia e data de referencia igual a data do dia
      FOR rw_craplcm IN cr_craplcm_p (pr_dtproxim => vr_tab_per_datas(vr_idx).dtmvtolt,
                                      pr_cdcooper => pr_cdcooper,
                                      pr_dtmvtolt => vr_tab_per_datas(vr_idx).dtmvtolt) LOOP

        vr_tab_per_datas(vr_idx).vlrtotal := nvl(vr_tab_per_datas(vr_idx).vlrtotal,0) + nvl(rw_craplcm.vllanmto,0);
      END LOOP;
      -- contar os meses
      IF vr_mesanter <> to_char(vr_tab_per_datas(vr_idx).dtmvtolt,'MM') THEN
        vr_contador := nvl(vr_contador,0) + 1;
      END IF;

      vr_mesanter := to_char(vr_tab_per_datas(vr_idx).dtmvtolt,'MM');
      vr_vltotger := nvl(vr_vltotger,0) + nvl(vr_tab_per_datas(vr_idx).vlrtotal,0);

      -- busca o proximo
      vr_idx := vr_tab_per_datas.next(vr_idx);
    END LOOP; -- Fim loop per_datas

    -- calcular media mês
    IF vr_contador > 0 THEN
      vr_vlrmedia := (vr_vltotger / vr_contador);
    ELSE
      vr_vlrmedia := 0;
    END IF;

    -- Buscar informacoes para calculo de poupanca
    vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                             ,pr_nmsistem => 'CRED'
                                             ,pr_tptabela => 'GENERI'
                                             ,pr_cdempres => 00
                                             ,pr_cdacesso => 'PARFLUXOFINAN'
                                             ,pr_tpregist => 0);

    --acrescentar percentual
    IF vr_dstextab IS NOT NULL THEN
      vr_vlrmedia := vr_vlrmedia + ((vr_vlrmedia *
                                     to_number(gene0002.fn_busca_entrada(2,vr_dstextab,';'))) / 100);
    END IF;

    vr_tab_cdbccxlt := gene0002.fn_quebra_string('01,85,756,100',',');
    -- Inserir os movimentos para cada banco
    FOR idx IN vr_tab_cdbccxlt.first..vr_tab_cdbccxlt.last LOOP
      FLXF0001.pc_grava_movimentacao(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                                    ,pr_cdoperad => pr_cdoperad   -- Codigo do operador
                                    ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                                    ,pr_tpdmovto => 2             -- Tipo de movimento
                                    ,pr_cdbccxlt => vr_tab_cdbccxlt(idx)     -- Codigo do banco/caixa.
                                    ,pr_tpdcampo => 1/*VLCHEQUE*/ -- Tipo de campo
                                    ,pr_vldcampo => (case vr_tab_cdbccxlt(idx)
                                                     when '85' then vr_vlrmedia
                                                     else 0
                                                     end)         -- Valor do campo
                                    ,pr_dscritic => pr_dscritic);

      IF pr_dscritic <> 'OK' THEN
        RAISE vr_exc_erro;
      END IF;

    END LOOP;

    pr_dscritic := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- gerar log de erro
      vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
      GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                            pr_cdagenci => pr_cdagenci,
                            pr_nrdcaixa => pr_nrdcaixa,
                            pr_nrsequen => vr_nrsequen,
                            pr_cdcritic => 0,
                            pr_dscritic => pr_dscritic,
                            pr_tab_erro => pr_tab_erro);

    WHEN OTHERS THEN
      -- gerar log de erro
      pr_dscritic := 'Erro na FLXF0001.pc_grava_mvt_cheques: '||SQLerrm;
      vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
      GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                            pr_cdagenci => pr_cdagenci,
                            pr_nrdcaixa => pr_nrdcaixa,
                            pr_nrsequen => vr_nrsequen,
                            pr_cdcritic => 0,
                            pr_dscritic => pr_dscritic,
                            pr_tab_erro => pr_tab_erro);
  END pc_grava_mvt_cheques;

  -- Procedimento para gerar o periodo de projeção dos titulos
  PROCEDURE pc_gera_periodo_projecao_tit
                                    (pr_cdcooper IN INTEGER      -- Codigo da Cooperativa
                                    ,pr_cdagenci IN INTEGER      -- Codigo da agencia
                                    ,pr_nrdcaixa IN INTEGER      -- Numero do caixa
                                    ,pr_cdoperad IN crapope.cdoperad%type     -- Codigo do operador
                                    ,pr_dtmvtolt IN DATE         -- Data de movimento
                                    ,pr_nmdatela IN VARCHAR2     -- Nome da tela chamadora
                                    ,pr_cdagrupa IN INTEGER      -- Código de agrupamento
                                    ,pr_tab_per_datas OUT typ_tab_per_datas -- Tabela de datas
                                    ,pr_dscritic      OUT VARCHAR2) AS      -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_gera_periodo_projecao_tit          Antigo: b1wgen0131.p/gera-periodos-projecao-titulo
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 08/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gera os periodo de projeção titulo
    --
    --   Atualizacao: 19/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --..........................................................................

  vr_dtnumdia Varchar2(5);
  vr_dtsemdia Varchar2(5);
  vr_listadia Varchar2(10);

  vr_tab_datas FLXF0001.typ_tab_datas;

  BEGIN

    -- verifica se o dia anterior é feriado
    IF FLXF0001.fn_feriado_dia_anterior(pr_cdcooper, pr_dtmvtolt) THEN
      -- chamar a propria rotina passando o dia anterior ao feriado
      FLXF0001.pc_gera_periodo_projecao_tit (pr_cdcooper => pr_cdcooper      -- Codigo da Cooperativa
                                            ,pr_cdagenci => pr_cdagenci       -- Codigo da agencia
                                            ,pr_nrdcaixa => pr_nrdcaixa       -- Numero do caixa
                                            ,pr_cdoperad => pr_cdoperad     -- Codigo do operador
                                            ,pr_dtmvtolt => fn_Busca_Data_anterior_feriado(pr_cdcooper,pr_dtmvtolt)  -- Data de movimento
                                            ,pr_nmdatela => pr_nmdatela
                                            ,pr_cdagrupa => pr_cdagrupa + 1  -- Código de agrupamento
                                            -- OUT
                                            ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                            ,pr_dscritic      => pr_dscritic);
    END IF;

    vr_dtnumdia := to_char(pr_dtmvtolt,'DD');
    vr_dtsemdia := to_char(pr_dtmvtolt,'D');

    -- Se for diferente de segunda-feira
    IF vr_dtsemdia <> 2 THEN

      vr_listadia := to_char(pr_dtmvtolt,'DD');
      FLXF0001.pc_med_dia_util_semana (pr_cdcooper => pr_cdcooper      -- Codigo da Cooperativa
                                      ,pr_dtmvtolt => pr_dtmvtolt      -- Data de movimento
                                      ,pr_nrdiasse => '3,4,5,6'        -- Numero que representa o dia da semana
                                      ,pr_nrdiasme => vr_listadia      -- Numero que representa o dia do mes
                                      ,pr_cdagrupa => pr_cdagrupa      -- Código de agrupamento
                                      ,pr_tipodoct => 'T'              -- Tipo de documento (C-Cheque,T-Titulo-I-Conta Integração )
                                      --OUT
                                      ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                      ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                      ,pr_dscritic      => pr_dscritic);
    ELSE
      IF vr_dtnumdia in (1,2,3) THEN
        FLXF0001.pc_media_pri_dutil_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                              ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                              ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                              --OUT
                                              ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                              ,pr_tab_datas     => vr_tab_datas -- tabela com as datas para controle
                                              ,pr_dscritic      => pr_dscritic );
      ELSIF vr_dtnumdia = 4 THEN
        FLXF0001.pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                          ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                          ,pr_listdias => vr_dtnumdia -- Lista de dias do mes
                                          ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                          --OUT
                                          ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                          ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                          ,pr_dscritic      => pr_dscritic );

        IF NVL(pr_tab_per_datas.COUNT,0) = 0 THEN
          FLXF0001.pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                            ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                            ,pr_listdias => '02,03,04,05'   -- Lista de dias do mes
                                            ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                            --OUT
                                            ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                            ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                            ,pr_dscritic => pr_dscritic );
        END IF;

      ELSIF vr_dtnumdia in (5,6,7) THEN
        FLXF0001.pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                          ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                          ,pr_listdias => '05,06,07'     -- Lista de dias do mes
                                          ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                          --OUT
                                          ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                          ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                          ,pr_dscritic      => pr_dscritic );
      ELSIF vr_dtnumdia in (8,9) THEN
        FLXF0001.pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                          ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                          ,pr_listdias => vr_dtnumdia -- Lista de dias do mes
                                          ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                          --OUT
                                          ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                          ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                          ,pr_dscritic => pr_dscritic );

        IF NVL(pr_tab_per_datas.COUNT,0) = 0 THEN
          FLXF0001.pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                            ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                            ,pr_listdias => '08,09'   -- Lista de dias do mes
                                            ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                            --OUT
                                            ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                            ,pr_tab_datas     => vr_tab_datas -- tabela com as datas para controle
                                            ,pr_dscritic => pr_dscritic );
        END IF;

      ELSIF vr_dtnumdia in (10,11,12) THEN
        FLXF0001.pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                          ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                          ,pr_listdias => '10,11,12'     -- Lista de dias do mes
                                          ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                          --OUT
                                          ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                          ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                          ,pr_dscritic => pr_dscritic );

      ELSIF vr_dtnumdia in (13,14) THEN
        FLXF0001.pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                          ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                          ,pr_listdias => vr_dtnumdia -- Lista de dias do mes
                                          ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                          --OUT
                                          ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                          ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                          ,pr_dscritic      => pr_dscritic );

        IF NVL(pr_tab_per_datas.COUNT,0) = 0 THEN
          FLXF0001.pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                            ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                            ,pr_listdias => '13,14'     -- Lista de dias do mes
                                            ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                            --OUT
                                            ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                            ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                            ,pr_dscritic => pr_dscritic );
        END IF;

      ELSIF vr_dtnumdia in (15,16,17) THEN
        FLXF0001.pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                          ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                          ,pr_listdias => '15,16,17'  -- Lista de dias do mes
                                          ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                          --OUT
                                          ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                          ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                          ,pr_dscritic      => pr_dscritic );
      ELSIF vr_dtnumdia in (18,19) THEN
        FLXF0001.pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                          ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                          ,pr_listdias => vr_dtnumdia -- Lista de dias do mes
                                          ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                          --OUT
                                          ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                          ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                          ,pr_dscritic => pr_dscritic );

        IF NVL(pr_tab_per_datas.COUNT,0) = 0 THEN
          FLXF0001.pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                            ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                            ,pr_listdias => '18,19'     -- Lista de dias do mes
                                            ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                            --OUT
                                            ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                            ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                            ,pr_dscritic => pr_dscritic );
        END IF;

      ELSIF vr_dtnumdia in (20,21,22) THEN
        FLXF0001.pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                          ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                          ,pr_listdias => '20,21,22'  -- Lista de dias do mes
                                          ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                          --OUT
                                          ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                          ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                          ,pr_dscritic => pr_dscritic );
      ELSIF vr_dtnumdia in (23,24) THEN
        FLXF0001.pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                          ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                          ,pr_listdias => vr_dtnumdia -- Lista de dias do mes
                                          ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                          --OUT
                                          ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                          ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                          ,pr_dscritic      => pr_dscritic );

        IF NVL(pr_tab_per_datas.COUNT,0) = 0 THEN
          FLXF0001.pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                            ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                            ,pr_listdias => '23,24'     -- Lista de dias do mes
                                            ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                            --OUT
                                            ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                            ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                            ,pr_dscritic => pr_dscritic );
        END IF;

      ELSIF vr_dtnumdia in (25,26,27) THEN
        FLXF0001.pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                          ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                          ,pr_listdias => '25,26,27'  -- Lista de dias do mes
                                          ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                          --OUT
                                          ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                          ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                          ,pr_dscritic      => pr_dscritic );

      ELSIF vr_dtnumdia in (28,29) THEN
        FLXF0001.pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                          ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                          ,pr_listdias => vr_dtnumdia -- Lista de dias do mes
                                          ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                          --OUT
                                          ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                          ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                          ,pr_dscritic      => pr_dscritic );

        IF NVL(pr_tab_per_datas.COUNT,0) = 0 THEN
          FLXF0001.pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                            ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                            ,pr_listdias => '28,29'     -- Lista de dias do mes
                                            ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                            --OUT
                                            ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                            ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                            ,pr_dscritic => pr_dscritic );
        END IF;

      ELSIF vr_dtnumdia in (30) THEN
        FLXF0001.pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                          ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                          ,pr_listdias => vr_dtnumdia -- Lista de dias do mes
                                          ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                          --OUT
                                          ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                          ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                          ,pr_dscritic      => pr_dscritic );

        IF NVL(pr_tab_per_datas.COUNT,0) = 0 THEN
          FLXF0001.pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                            ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                            ,pr_listdias => '30,31'     -- Lista de dias do mes
                                            ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                            --OUT
                                            ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                            ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                            ,pr_dscritic => pr_dscritic );
        END IF;
      ELSIF vr_dtnumdia in (31) THEN
        FLXF0001.pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                          ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                          ,pr_listdias => '30,31'     -- Lista de dias do mes
                                          ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                          --OUT
                                          ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                          ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                          ,pr_dscritic      => pr_dscritic );

      ELSE
        FLXF0001.pc_regra_media_segfeira ( pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                          ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                          ,pr_listdias => vr_dtnumdia -- Lista de dias do mes
                                          ,pr_cdagrupa => pr_cdagrupa -- Código de agrupamento
                                          --OUT
                                          ,pr_tab_per_datas => pr_tab_per_datas -- Tabela de datas
                                          ,pr_tab_datas     => vr_tab_datas     -- tabela com as datas para controle
                                          ,pr_dscritic      => pr_dscritic );
      END IF;
    END IF; --Fim vr_dtsemdia <> 2

  END pc_gera_periodo_projecao_tit;

  -- Procedure para gravar movimento financeiro dos titulos
  PROCEDURE pc_grava_mvt_titulos  ( pr_cdcooper IN INTEGER      -- Codigo da Cooperativa
                                   ,pr_cdagenci IN INTEGER      -- Codigo da agencia
                                   ,pr_nrdcaixa IN INTEGER      -- Numero da caixa
                                   ,pr_cdoperad IN crapope.cdoperad%type     -- Codigo do operador
                                   ,pr_dtmvtolt IN DATE         -- Data de movimento
                                   ,pr_nmdatela IN VARCHAR2     -- Nome da tela
                                   ,pr_dtmvtoan IN DATE         -- Data de movimento anterior
                                   ,pr_cdcoopex IN VARCHAR2     -- Codigo da Cooperativa
                                   ,pr_calcproj IN BOOLEAN      -- Identificador se calcula projeção
                                   ,pr_tab_erro OUT GENE0001.typ_tab_erro -- Tabela contendo os erros
                                   ,pr_dscritic OUT VARCHAR2) AS          -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_mvt_titulos          Antigo: b1wgen0131.p/pi_sr_titulos_f
    --
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 11/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar movimento financeiro dos titulos
    --
    --   Atualizacao: 08/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --..........................................................................

    vr_exc_erro      EXCEPTION;
    vr_tab_cdbccxlt  gene0002.typ_split;
    vr_tab_per_datas FLXF0001.typ_tab_per_datas;
    -- Variaveis para calculo do movimento
    vr_contador      NUMBER;
    vr_vlrdotit      NUMBER;
    vr_vlrmedia      NUMBER;
    vr_vltotger      NUMBER;
    vr_idx           VARCHAR2(15);
    vr_dstextab      craptab.dstextab%type;
    vr_nrsequen      number;

    --Buscar lancamentos em depositos a vista
    CURSOR cr_craplcm (pr_dtmvtolt DATE,
                       pr_cdcooper NUMBER) IS
      SELECT nvl(sum(vllanmto),0) vllanmto
        FROM craplcm
       WHERE craplcm.cdcooper = pr_cdcooper
         AND craplcm.cdhistor IN (977)
         AND craplcm.dtmvtolt = pr_dtmvtolt;

    --Buscar de bloquetos de cobranca
    CURSOR cr_crapcob is
      SELECT nvl(sum(vldpagto),0) vldpagto
        FROM crapcob
       WHERE crapcob.cdcooper = pr_cdcoopex
         AND crapcob.dtdpagto = pr_dtmvtoan
         AND crapcob.cdbandoc = 1 /*Banco do Brasil*/
         AND crapcob.incobran = 5 /*Compensacao*/
         AND crapcob.indpagto = 0
         AND crapcob.vldpagto > 0;

  BEGIN

    -- Inicializar valores
    vr_contador := 0;
    vr_vlrdotit := 0;
    vr_vlrmedia := 0;
    vr_vltotger := 0;

    -- Verificar e deve calcular
    IF pr_calcproj THEN
      -- gerar os periodo de projeção titulo
      FLXF0001.pc_gera_periodo_projecao_tit (pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                                            ,pr_cdagenci => pr_cdagenci   -- Codigo da agencia
                                            ,pr_nrdcaixa => pr_nrdcaixa   -- Numero do caixa
                                            ,pr_cdoperad => pr_cdoperad   -- Codigo do operador
                                            ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                                            ,pr_cdagrupa => 1             -- Código de agrupamento
                                            ,pr_nmdatela => pr_nmdatela   -- Nome da tela
                                            --out
                                            ,pr_tab_per_datas => vr_tab_per_datas -- Tabela de datas
                                            ,pr_dscritic      => pr_dscritic);

      IF pr_dscritic <> 'OK' THEN
        RAISE vr_exc_erro;
      ELSE
        pr_dscritic := NULL;
      END IF;

      vr_idx := vr_tab_per_datas.first;
      LOOP
        EXIT WHEN vr_idx IS NULL;

        -- buscar lançamentos
        FOR rw_craplcm IN cr_craplcm(pr_dtmvtolt => vr_tab_per_datas(vr_idx).dtmvtolt,
                                     pr_cdcooper => pr_cdcooper) LOOP
          -- Somar valores
          vr_tab_per_datas(vr_idx).vlrtotal := NVL(vr_tab_per_datas(vr_idx).vlrtotal,0) + NVL(rw_craplcm.vllanmto,0);
        END LOOP;

        vr_vltotger := vr_vltotger + nvl(vr_tab_per_datas(vr_idx).vlrtotal,0);
        vr_contador := vr_contador + 1;

        -- Se for o ultimo registro deve calcular a media
        IF vr_idx = vr_tab_per_datas.LAST OR
           vr_tab_per_datas(vr_idx).cdagrupa <> vr_tab_per_datas(nvl(vr_tab_per_datas.NEXT(vr_idx),vr_idx)).cdagrupa then

          vr_vlrmedia := vr_vlrmedia + (vr_vltotger  / vr_contador);
          vr_vltotger := 0;
          vr_contador := 0;

        END IF;

        vr_idx := vr_tab_per_datas.NEXT(vr_idx);
      END LOOP;

      -- Buscar informacoes para calculo de poupanca
      vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'GENERI'
                                               ,pr_cdempres => 00
                                               ,pr_cdacesso => 'PARFLUXOFINAN'
                                               ,pr_tpregist => 0);


      -- Buscar valor na posição 4
      vr_vlrmedia := vr_vlrmedia +  ((vr_vlrmedia *
                                    to_number(gene0002.fn_busca_entrada(4,vr_dstextab,';'))) / 100);

      vr_tab_cdbccxlt := gene0002.fn_quebra_string('01,85,756,100',',');

      FOR idx IN vr_tab_cdbccxlt.first..vr_tab_cdbccxlt.last LOOP
        FLXF0001.pc_grava_movimentacao(pr_cdcooper => pr_cdcooper     -- Codigo da Cooperativa
                                      ,pr_cdoperad => pr_cdoperad     -- Codigo do operador
                                      ,pr_dtmvtolt => pr_dtmvtolt     -- Data de movimento
                                      ,pr_tpdmovto => 1               -- Tipo de movimento
                                      ,pr_cdbccxlt => vr_tab_cdbccxlt(idx)     -- Codigo do banco/caixa.
                                      ,pr_tpdcampo => 4 /*VLTOTTIT*/  -- Tipo de campo
                                      ,pr_vldcampo => (case vr_tab_cdbccxlt(idx)
                                                       when '85' then vr_vlrmedia
                                                       else 0
                                                       end)      -- Valor do campo
                                      ,pr_dscritic => pr_dscritic);

        IF pr_dscritic <> 'OK' THEN
          RAISE vr_exc_erro;
        END IF;

      END LOOP;

    ELSE --se não buscar valores direto dos bloquetos de cobranca
      FOR rw_crapcob IN cr_crapcob LOOP
        vr_vlrdotit := nvl(vr_vlrdotit,0) + nvl(rw_crapcob.vldpagto,0);
      END LOOP;

      FLXF0001.pc_grava_movimentacao(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                                    ,pr_cdoperad => pr_cdoperad   -- Codigo do operador
                                    ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                                    ,pr_tpdmovto => 1             -- Tipo de movimento
                                    ,pr_cdbccxlt => 01            -- Codigo do banco/caixa.
                                    ,pr_tpdcampo => 4 /*VLTOTTIT*/-- Tipo de campo
                                    ,pr_vldcampo => vr_vlrdotit   -- Valor do campo
                                    ,pr_dscritic => pr_dscritic);

      IF pr_dscritic <> 'OK' THEN
        RAISE vr_exc_erro;
      END IF;

    END IF; -- FIM pr_calcproj
    pr_dscritic := 'OK';

  EXCEPTION
    -- Gerar logs de erro
    WHEN vr_exc_erro THEN

      vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
      GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                            pr_cdagenci => pr_cdagenci,
                            pr_nrdcaixa => pr_nrdcaixa,
                            pr_nrsequen => vr_nrsequen,
                            pr_cdcritic => 0,
                            pr_dscritic => pr_dscritic,
                            pr_tab_erro => pr_tab_erro);

    WHEN OTHERS THEN
      pr_dscritic := 'Erro na FLXF0001.pc_grava_mvt_titulos: '||SQLerrm;
      vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
      GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                            pr_cdagenci => pr_cdagenci,
                            pr_nrdcaixa => pr_nrdcaixa,
                            pr_nrsequen => vr_nrsequen,
                            pr_cdcritic => 0,
                            pr_dscritic => pr_dscritic,
                            pr_tab_erro => pr_tab_erro);

  END pc_grava_mvt_titulos;

  -- Procedure para gravar movimento financeiro dos titulos *****
  PROCEDURE pc_grava_mvt_titulos_nr ( pr_cdcooper  IN INTEGER      -- Codigo da Cooperativa
                                     ,pr_cdagenci  IN INTEGER      -- Codigo da agencia
                                     ,pr_nrdcaixa  IN INTEGER      -- Numero da caixa
                                     ,pr_cdoperad  IN crapope.cdoperad%type     -- Codigo do operador
                                     ,pr_dtmvtolt  IN DATE         -- Data de movimento
                                     ,pr_nmdatela  IN VARCHAR2     -- Nome da tela
                                     ,pr_cdagefim  IN INTEGER      -- Codigo da agencia final
                                     ,pr_cdcoopex  IN INTEGER      -- Codigo da Cooperativa
                                     ,pr_dtmvtoan  IN DATE         -- Data de movimento anterior
                                     ,pr_dscritic OUT VARCHAR2) AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_mvt_titulos_nr          Antigo: b1wgen0131.p/pi_titulos_f_nr
    --
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 21/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar movimento financeiro dos titulos *****
    --
    --   Atualizacao: 21/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --..........................................................................

    vr_exc_erro      EXCEPTION;
    vr_tab_cdbccxlt  gene0002.typ_split;
    vr_vlrtitnr      NUMBER;
    vr_vltitliq      NUMBER := 0;
    vr_vlfatliq      NUMBER := 0;
    vr_vlinss        NUMBER := 0;
    vr_dstextab      craptab.dstextab%type;
    vr_idbcoctl      INTEGER;

    --Buscar titulos
    CURSOR cr_craptit (pr_dtmvtolt DATE,
                       pr_cdcooper NUMBER,
                       pr_cdagenci NUMBER,
                       pr_cdagefim NUMBER) IS
      SELECT cdbcoenv,
             vldpagto,
             cdcooper,
             cdagenci
        FROM craptit
       WHERE cdcooper  = pr_cdcooper
         AND dtdpagto  = pr_dtmvtolt
         AND cdagenci >= nvl(pr_cdagenci,0)
         AND cdagenci <= pr_cdagefim
         AND tpdocmto  = 20
         AND intitcop  = 0
         AND insittit in (2,4);

    --Buscar Retorno do COBAN (CBF800)
    CURSOR cr_craprcb (pr_dtmvtolt DATE,
                       pr_cdcooper NUMBER) IS
      SELECT valorpag,
             cdtransa,
             flgrgatv
        FROM craprcb
       WHERE craprcb.cdcooper = pr_cdcooper
         AND craprcb.dtmvtolt = pr_dtmvtolt
         AND (craprcb.cdtransa = '268' OR /* Titulos */
              craprcb.cdtransa = '358' OR /* Faturas */
              craprcb.cdtransa = '284') /* Recebto INSS */
         AND
             craprcb.cdagenci <> 9999 /* Totais dias anteriores */
      ;

  BEGIN

    vr_vlrtitnr := 0;

    --Buscar titulos
    FOR rw_craptit IN cr_craptit(pr_dtmvtolt => pr_dtmvtolt,
                                 pr_cdcooper => pr_cdcoopeX,
                                 pr_cdagenci => pr_cdagenci,
                                 pr_cdagefim => pr_cdagefim) LOOP

      CASE rw_craptit.cdbcoenv
        -- Somar se o banco enviado pelo banco 85
        WHEN 85 THEN
          vr_vlrtitnr := vr_vlrtitnr + nvl(rw_craptit.vldpagto,0);
        WHEN 0 THEN
          vr_idbcoctl := FLXF0001.fn_identifica_bcoctl
                                     (pr_cdcooper => rw_craptit.cdcooper, -- codigo da cooperativa
                                      pr_cdagenci => rw_craptit.cdagenci, -- Codigo da agencia
                                      pr_idtpdoct => 'T');                -- Tipo de documento (T-titulo,D-doc,C-cheque)
          -- Somar se o banco de cheques da agencia for 85
          IF vr_idbcoctl = 1 THEN
            vr_vlrtitnr := vr_vlrtitnr + nvl(rw_craptit.vldpagto,0);
          END IF;

      END CASE;
    END LOOP;

    -- Buscar informacoes para calculo de poupanca
    vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                             ,pr_nmsistem => 'CRED'
                                             ,pr_tptabela => 'GENERI'
                                             ,pr_cdempres => 00
                                             ,pr_cdacesso => 'PARFLUXOFINAN'
                                             ,pr_tpregist => 0);

    -- Acrescentar percentual
    IF vr_dstextab IS NOT NULL THEN
        vr_vlrtitnr := vr_vlrtitnr +
                      ((vr_vlrtitnr * to_number(gene0002.fn_busca_entrada(3,vr_dstextab,';')))/ 100);

    END IF;

    vr_tab_cdbccxlt := gene0002.fn_quebra_string('01,85,756,100',',');

    FOR idx IN vr_tab_cdbccxlt.first..vr_tab_cdbccxlt.last LOOP
      FLXF0001.pc_grava_movimentacao(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                                    ,pr_cdoperad => pr_cdoperad   -- Codigo do operador
                                    ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                                    ,pr_tpdmovto => 2             -- Tipo de movimento
                                    ,pr_cdbccxlt => vr_tab_cdbccxlt(idx)     -- Codigo do banco/caixa.
                                    ,pr_tpdcampo => 4 /*VLTOTTIT*/           -- Tipo de campo
                                    ,pr_vldcampo => (case vr_tab_cdbccxlt(idx)
                                                     when '85' then vr_vlrtitnr
                                                     else 0
                                                     end)         -- Valor do campo
                                    ,pr_dscritic => pr_dscritic);

      IF pr_dscritic <> 'OK' THEN
        RAISE vr_exc_erro;
      END IF;

    END LOOP;--Fim loop bancos

    vr_vlrtitnr := 0;
    vr_vltitliq := 0;
    vr_vlfatliq := 0;
    vr_vlinss   := 0;

    --Buscar Retorno do COBAN
    FOR rw_craprcb IN cr_craprcb(pr_dtmvtolt => pr_dtmvtoan,
                                 pr_cdcooper => pr_cdcoopeX) LOOP

      /* para resumo do banco do brasil */
      IF rw_craprcb.cdtransa = '268'  THEN   /* Titulos */
        IF rw_craprcb.flgrgatv = 1 THEN
          vr_vltitliq := vr_vltitliq + nvl(rw_craprcb.valorpag,0);
        END IF;
      ELSE
        IF rw_craprcb.cdtransa = '358' THEN    /* Faturas */
          IF rw_craprcb.flgrgatv = 1 THEN
            vr_vlfatliq := vr_vlfatliq + nvl(rw_craprcb.valorpag,0);
          END IF;
        ELSE
          IF rw_craprcb.flgrgatv = 1 THEN
            vr_vlinss := vr_vlinss + nvl(rw_craprcb.valorpag,0);
          END IF;
        END IF;
      END IF;
    END LOOP;--Fim Loop cr_craprcb

    vr_vlrtitnr := (vr_vltitliq + vr_vlfatliq) - (vr_vlinss);

    FLXF0001.pc_grava_movimentacao(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                                  ,pr_cdoperad => pr_cdoperad   -- Codigo do operador
                                  ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                                  ,pr_tpdmovto => 2             -- Tipo de movimento
                                  ,pr_cdbccxlt => 01            -- Codigo do banco/caixa.
                                  ,pr_tpdcampo => 4 /*VLTOTTIT*/-- Tipo de campo
                                  ,pr_vldcampo => vr_vlrtitnr   -- Valor do campo
                                  ,pr_dscritic => pr_dscritic);

    IF pr_dscritic <> 'OK' THEN
      RAISE vr_exc_erro;
    END IF;

    pr_dscritic := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
        NULL;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na FLXF0001.pc_grava_mvt_titulos_nr: '||SQLerrm;
  END pc_grava_mvt_titulos_nr;

  -- Procedure para gravar movimento financeiro dos docs
  PROCEDURE pc_grava_mvt_doc  ( pr_cdcooper IN INTEGER      -- Codigo da Cooperativa
                               ,pr_cdagenci IN INTEGER      -- Codigo da agencia
                               ,pr_nrdcaixa IN INTEGER      -- Numero da caixa
                               ,pr_cdoperad IN crapope.cdoperad%type     -- Codigo do operador
                               ,pr_dtmvtolt IN DATE         -- Data de movimento
                               ,pr_nmdatela IN VARCHAR2     -- Nome da tela
                               ,pr_tab_erro OUT GENE0001.typ_tab_erro -- Tabela contendo os erros
                               ,pr_dscritic OUT VARCHAR2) AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_mvt_doc          Antigo: b1wgen0131.p/pi_sr_doc_f
    --
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 11/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar movimento financeiro dos docs
    --
    --   Atualizacao: 08/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --..........................................................................

    vr_exc_erro      EXCEPTION;
    vr_tab_cdbccxlt  gene0002.typ_split;
    vr_tab_per_datas FLXF0001.typ_tab_per_datas;
    -- variavel para calcular o movimento
    vr_contador      NUMBER;
    vr_vlrmedia      NUMBER;
    vr_vltotger      NUMBER;
    vr_idx           VARCHAR2(15);
    vr_dstextab      craptab.dstextab%type;
    -- Variavel para controlar o mes
    vr_mesanter      NUMBER := 0;
    vr_nrsequen      number;

    vr_val number;
    vr_dt date;

    --Buscar lancamentos em depositos a vista
    CURSOR cr_craplcm (pr_dtmvtolt DATE,
                       pr_cdcooper NUMBER) IS
      SELECT nvl(sum(vllanmto),0) vllanmto
        FROM craplcm
       WHERE craplcm.cdcooper = pr_cdcooper
         AND craplcm.cdhistor IN (575)
         AND craplcm.dtmvtolt = pr_dtmvtolt;

  BEGIN

    vr_contador := 0;
    vr_vlrmedia := 0;
    vr_vltotger := 0;

    -- gerar os periodo de projeção chqdoc
    FLXF0001.pc_gr_periodo_projecao_chqdoc (pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                                           ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                                              --out
                                           ,pr_tab_per_datas => vr_tab_per_datas -- Tabela de datas
                                           ,pr_dscritic      => pr_dscritic);

    IF pr_dscritic <> 'OK' THEN
      RAISE vr_exc_erro;
    ELSE
      pr_dscritic := NULL;
    END IF;

    -- Ler todas as datas
    vr_idx := vr_tab_per_datas.first;
    LOOP
      EXIT WHEN vr_idx IS NULL;

      -- buscar lançamentos
      FOR rw_craplcm IN cr_craplcm(pr_dtmvtolt => vr_tab_per_datas(vr_idx).dtmvtolt,
                                   pr_cdcooper => pr_cdcooper) LOOP
        -- Somar valores
        vr_tab_per_datas(vr_idx).vlrtotal := NVL(vr_tab_per_datas(vr_idx).vlrtotal,0) + NVL(rw_craplcm.vllanmto,0);
      END LOOP;

      -- incrementar contador de mes
      IF vr_mesanter <> to_char(vr_tab_per_datas(vr_idx).dtmvtolt,'MM') THEN
        vr_contador := nvl(vr_contador,0) + 1;
      END IF;

      vr_val := vr_tab_per_datas(vr_idx).vlrtotal;
      vr_dt  := vr_tab_per_datas(vr_idx).dtmvtolt;

      vr_mesanter := to_char(vr_tab_per_datas(vr_idx).dtmvtolt,'MM');
      vr_vltotger := nvl(vr_vltotger,0) + nvl(vr_tab_per_datas(vr_idx).vlrtotal,0);

      vr_idx := vr_tab_per_datas.NEXT(vr_idx);
    END LOOP; --Fim loop periodo

    -- calcular media mês
    IF vr_contador > 0 THEN
      vr_vlrmedia := (vr_vltotger / vr_contador);
    ELSE
      vr_vlrmedia := 0;
    END IF;

    -- Buscar informacoes para calculo de poupanca
    vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                             ,pr_nmsistem => 'CRED'
                                             ,pr_tptabela => 'GENERI'
                                             ,pr_cdempres => 00
                                             ,pr_cdacesso => 'PARFLUXOFINAN'
                                             ,pr_tpregist => 0);


    -- Buscar valor na posição 1, e acrescentar percentual
    vr_vlrmedia := vr_vlrmedia +  ((vr_vlrmedia *
                                  to_number(gene0002.fn_busca_entrada(1,vr_dstextab,';'))) / 100);

    vr_tab_cdbccxlt := gene0002.fn_quebra_string('01,85,756,100',',');

    FOR idx IN vr_tab_cdbccxlt.first..vr_tab_cdbccxlt.last LOOP
      FLXF0001.pc_grava_movimentacao(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                                    ,pr_cdoperad => pr_cdoperad   -- Codigo do operador
                                    ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                                    ,pr_tpdmovto => 1             -- Tipo de movimento
                                    ,pr_cdbccxlt => vr_tab_cdbccxlt(idx)     -- Codigo do banco/caixa.
                                    ,pr_tpdcampo => 2 /*VLTOTDOC*/-- Tipo de campo
                                    ,pr_vldcampo => (case vr_tab_cdbccxlt(idx)
                                                     when '85' then vr_vlrmedia
                                                     else 0
                                                     end)         -- Valor do campo
                                    ,pr_dscritic => pr_dscritic);

      IF pr_dscritic <> 'OK' THEN
        RAISE vr_exc_erro;
      END IF;

    END LOOP;--Fim loop bancos


    pr_dscritic := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Gerar log de erro
      vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
      GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                            pr_cdagenci => pr_cdagenci,
                            pr_nrdcaixa => pr_nrdcaixa,
                            pr_nrsequen => vr_nrsequen,
                            pr_cdcritic => 0,
                            pr_dscritic => pr_dscritic,
                            pr_tab_erro => pr_tab_erro);

    WHEN OTHERS THEN
      pr_dscritic := 'Erro na FLXF0001.pc_grava_mvt_doc: '||SQLerrm;
      vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
      GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                            pr_cdagenci => pr_cdagenci,
                            pr_nrdcaixa => pr_nrdcaixa,
                            pr_nrsequen => vr_nrsequen,
                            pr_cdcritic => 0,
                            pr_dscritic => pr_dscritic,
                            pr_tab_erro => pr_tab_erro);

  END pc_grava_mvt_doc;

  -- Procedure para gravar movimento financeiro das transferencias DOCs
  PROCEDURE pc_grava_mvt_doc_nr ( pr_cdcooper  IN INTEGER      -- Codigo da Cooperativa
                                 ,pr_cdagenci  IN INTEGER      -- Codigo da agencia
                                 ,pr_nrdcaixa  IN INTEGER      -- Numero da caixa
                                 ,pr_cdoperad  IN crapope.cdoperad%type     -- Codigo do operador
                                 ,pr_dtmvtolt  IN DATE         -- Data de movimento
                                 ,pr_nmdatela  IN VARCHAR2     -- Nome da tela
                                 ,pr_cdagefim  IN INTEGER      -- Codigo da agencia final
                                 ,pr_cdcoopex  IN INTEGER      -- Codigo da Cooperativa
                                 ,pr_dscritic OUT VARCHAR2) AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_mvt_doc_nr          Antigo: b1wgen0131.p/pi_doc_f_nr
    --
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 21/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar movimento financeiro das transferencias DOCs
    --
    --   Atualizacao: 21/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --..........................................................................

    vr_exc_erro      EXCEPTION;
    vr_tab_cdbccxlt  gene0002.typ_split;
    vr_vlrdocnr      NUMBER;
    vr_idbcoctl      INTEGER;

    -- Buscar tranferencia de valores (DOC C, DOC D E TEDS)
    CURSOR cr_craptvl (pr_dtmvtolt DATE,
                       pr_cdcooper NUMBER,
                       pr_cdagenci NUMBER,
                       pr_cdagefim NUMBER) IS
      SELECT vldocrcb,
             cdbcoenv,
             cdcooper,
             cdagenci
        FROM craptvl
       WHERE cdcooper  = pr_cdcooper
         AND dtmvtolt  = pr_dtmvtolt
         AND cdagenci >= nvl(pr_cdagenci,0)
         AND cdagenci <= pr_cdagefim
         AND cdbcoenv  = 85
         AND tpdoctrf  <> 3;/* DOC */

  BEGIN

    vr_vlrdocnr := 0;

    /* Transferencias - DOC*/
    FOR rw_craptvl IN cr_craptvl(pr_dtmvtolt => pr_dtmvtolt,
                                 pr_cdcooper => pr_cdcoopeX,
                                 pr_cdagenci => pr_cdagenci,
                                 pr_cdagefim => pr_cdagefim) LOOP

      CASE rw_craptvl.cdbcoenv
        -- Somar se o banco enviado pelo banco 85
        WHEN 85 THEN
          vr_vlrdocnr := vr_vlrdocnr + nvl(rw_craptvl.vldocrcb,0);
        WHEN 0 THEN
          vr_idbcoctl := FLXF0001.fn_identifica_bcoctl
                                     (pr_cdcooper => rw_craptvl.cdcooper, -- codigo da cooperativa
                                      pr_cdagenci => rw_craptvl.cdagenci, -- Codigo da agencia
                                      pr_idtpdoct => 'D');                -- Tipo de documento (T-titulo,D-doc,C-cheque)
          -- Somar se o banco de cheques da agencia for 85
          IF vr_idbcoctl = 1 THEN
            vr_vlrdocnr := vr_vlrdocnr + nvl(rw_craptvl.vldocrcb,0);
          END IF;

      END CASE;
    END LOOP;

    -- Ler os bancos e gravar os movimentos
    vr_tab_cdbccxlt := gene0002.fn_quebra_string('01,85,756,100',',');
    FOR idx IN vr_tab_cdbccxlt.first..vr_tab_cdbccxlt.last LOOP
      FLXF0001.pc_grava_movimentacao(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                                    ,pr_cdoperad => pr_cdoperad   -- Codigo do operador
                                    ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                                    ,pr_tpdmovto => 2             -- Tipo de movimento
                                    ,pr_cdbccxlt => vr_tab_cdbccxlt(idx)     -- Codigo do banco/caixa.
                                    ,pr_tpdcampo => 2 /*VLTOTDOC*/-- Tipo de campo
                                    ,pr_vldcampo => (case vr_tab_cdbccxlt(idx)
                                                     when '85' then vr_vlrdocnr
                                                     else 0
                                                     end)         -- Valor do campo
                                    ,pr_dscritic => pr_dscritic);

      IF pr_dscritic <> 'OK' THEN
        RAISE vr_exc_erro;
      END IF;

    END LOOP;--Fim loop bancos

    pr_dscritic := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
        NULL;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na FLXF0001.pc_grava_mvt_doc_nr: '||SQLerrm;
  END pc_grava_mvt_doc_nr;

  -- Procedure para gravar movimento financeiro das faturas do bradesco
  PROCEDURE pc_gera_mvt_fatura_bradesco ( pr_cdcooper  IN INTEGER      -- Codigo da Cooperativa
                                         ,pr_cdagenci  IN INTEGER      -- Codigo da agencia
                                         ,pr_nrdcaixa  IN INTEGER      -- Numero da caixa
                                         ,pr_cdoperad  IN crapope.cdoperad%type     -- Codigo do operador
                                         ,pr_dtmvtolt  IN DATE         -- Data de movimento
                                         ,pr_nmdatela  IN VARCHAR2     -- Nome da tela
                                         ,pr_cdcoopex  IN INTEGER      -- Codigo da Cooperativa
                                         ,pr_dscritic OUT VARCHAR2) AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_mvt_fatura_bradesco          Antigo: b1wgen0131.p/pi_rem_fatura_bradesco_f
    --
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 20/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar movimento financeiro das faturas do bradesco
    --
    --   Atualizacao: 20/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --..........................................................................

    vr_exc_erro      EXCEPTION;
    vr_tab_cdbccxlt  gene0002.typ_split;
    vr_vlremfat      NUMBER := 0;

    --Buscar Lancamentos Automaticos
    CURSOR cr_craplau (pr_dtmvtolt DATE,
                       pr_cdcooper NUMBER) IS
      SELECT nvl(sum(vllanaut),0) vllanaut
        FROM craplau
       WHERE cdcooper = pr_cdcooper
         AND cdhistor IN (293)
         AND dtmvtopg = pr_dtmvtolt;

  BEGIN

    vr_vlremfat := 0;

    --Buscar Lancamentos Automaticos
    FOR rw_craplau IN cr_craplau(pr_dtmvtolt => pr_dtmvtolt,
                                 pr_cdcooper => pr_cdcoopeX) LOOP
      vr_vlremfat := vr_vlremfat + rw_craplau.vllanaut;

    END LOOP;

    vr_tab_cdbccxlt := gene0002.fn_quebra_string('01,85,756,100',',');
    -- Varrer os bancos e inserir movimento
    FOR idx IN vr_tab_cdbccxlt.first..vr_tab_cdbccxlt.last LOOP
      FLXF0001.pc_grava_movimentacao(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                                    ,pr_cdoperad => pr_cdoperad   -- Codigo do operador
                                    ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                                    ,pr_tpdmovto => 2             -- Tipo de movimento
                                    ,pr_cdbccxlt => vr_tab_cdbccxlt(idx)     -- Codigo do banco/caixa.
                                    ,pr_tpdcampo => 10            -- Tipo de campo
                                    ,pr_vldcampo => (case vr_tab_cdbccxlt(idx)
                                                     when '100' then vr_vlremfat
                                                     else 0
                                                     end)         -- Valor do campo
                                    ,pr_dscritic => pr_dscritic);

      IF pr_dscritic <> 'OK' THEN
        RAISE vr_exc_erro;
      END IF;

    END LOOP;--Fim loop bancos


    pr_dscritic := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
        NULL;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na FLXF0001.pc_gera_mvt_fatura_bradesco: '||SQLerrm;
  END pc_gera_mvt_fatura_bradesco;

  -- Procedure para gravar movimento financeiro das Guias de recolhimento da Previdencia Social
  PROCEDURE pc_grava_mvt_grps ( pr_cdcooper  IN INTEGER      -- Codigo da Cooperativa
                               ,pr_cdagenci  IN INTEGER      -- Codigo da agencia
                               ,pr_nrdcaixa  IN INTEGER      -- Numero da caixa
                               ,pr_cdoperad  IN crapope.cdoperad%type     -- Codigo do operador
                               ,pr_dtmvtolt  IN DATE         -- Data de movimento
                               ,pr_nmdatela  IN VARCHAR2     -- Nome da tela
                               ,pr_cdcoopex  IN INTEGER      -- Codigo da Cooperativa
                               ,pr_dscritic OUT VARCHAR2) AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_mvt_grps          Antigo: b1wgen0131.p/pi_gps_f
    --
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 06/10/2016
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar movimento financeiro das Guias de recolhimento da Previdencia Social
    --
    --   Atualizacao: 20/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --
	--                06/10/2016 - SD 489677 - Inclusao do flgativo na CRAPLGP (Guilherme/SUPERO)
    --..........................................................................

    vr_exc_erro      EXCEPTION;
    vr_tab_cdbccxlt  gene0002.typ_split;
    vr_vltitrec      NUMBER := 0;

    --Buscar Lancamentos das Guias de recolhimento da Previdencia Social
    CURSOR cr_craplgp (pr_dtmvtolt DATE,
                       pr_cdcooper NUMBER) IS
      SELECT nvl(sum(vlrtotal),0) vlrtotal
        FROM craplgp
       WHERE cdcooper = pr_cdcooper
         AND dtmvtolt = pr_dtmvtolt
         AND cdagenci >= 1
         AND cdagenci <= 9999
         AND nrdcaixa >= 1
         AND nrdcaixa <= 9999
         AND flgativo = 1;

  BEGIN

    vr_vltitrec := 0;

    --Buscar Lancamentos das Guias de recolhimento da Previdencia Social
    FOR rw_craplgp IN cr_craplgp(pr_dtmvtolt => pr_dtmvtolt,
                                 pr_cdcooper => pr_cdcoopeX) LOOP
      vr_vltitrec := vr_vltitrec + rw_craplgp.vlrtotal;

    END LOOP;

    -- Varrer os bancos e inserir movimentos
    vr_tab_cdbccxlt := gene0002.fn_quebra_string('01,85,756,100',',');
    FOR idx IN vr_tab_cdbccxlt.first..vr_tab_cdbccxlt.last LOOP
      FLXF0001.pc_grava_movimentacao(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                                    ,pr_cdoperad => pr_cdoperad   -- Codigo do operador
                                    ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                                    ,pr_tpdmovto => 2             -- Tipo de movimento
                                    ,pr_cdbccxlt => vr_tab_cdbccxlt(idx)     -- Codigo do banco/caixa.
                                    ,pr_tpdcampo => 7             -- Tipo de campo
                                    ,pr_vldcampo => (case vr_tab_cdbccxlt(idx)
                                                     when '756' then vr_vltitrec
                                                     else 0
                                                     end)         -- Valor do campo
                                    ,pr_dscritic => pr_dscritic);

      IF pr_dscritic <> 'OK' THEN
        RAISE vr_exc_erro;
      END IF;

    END LOOP;--Fim loop bancos


    pr_dscritic := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
        NULL;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na FLXF0001.pc_grava_mvt_grps: '||SQLerrm;
  END pc_grava_mvt_grps;

  -- Procedure para gravar movimento financeiro das movimentções de INSS
  PROCEDURE pc_grava_mvt_inss ( pr_cdcooper  IN INTEGER      -- Codigo da Cooperativa
                               ,pr_cdagenci  IN INTEGER      -- Codigo da agencia
                               ,pr_nrdcaixa  IN INTEGER      -- Numero da caixa
                               ,pr_cdoperad  IN crapope.cdoperad%type     -- Codigo do operador
                               ,pr_dtmvtolt  IN DATE         -- Data de movimento
                               ,pr_nmdatela  IN VARCHAR2     -- Nome da tela
                               ,pr_cdcoopex  IN INTEGER      -- Codigo da Cooperativa
                               ,pr_dscritic OUT VARCHAR2) AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_mvt_inss          Antigo: b1wgen0131.p/pi_inss_f
    --
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 20/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar movimento financeiro das movimentções de INSS
    --
    --   Atualizacao: 20/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --..........................................................................

    vr_exc_erro      EXCEPTION;
    vr_tab_cdbccxlt  gene0002.typ_split;
    vr_vltitrec      NUMBER := 0;

    --Buscar Lancamentos de creditos de beneficios do INSS
    CURSOR cr_craplbi (pr_dtmvtolt DATE,
                       pr_cdcooper NUMBER) IS
      SELECT vlliqcre
        FROM craplbi
       WHERE cdcooper = pr_cdcooper
         AND dtdpagto = pr_dtmvtolt
         AND cdagenci >= 1
         AND cdagenci <= 99999;

  BEGIN

    vr_vltitrec := 0;

    --Buscar Lancamentos de creditos de beneficios do INSS
    FOR rw_craplbi IN cr_craplbi(pr_dtmvtolt => pr_dtmvtolt,
                                 pr_cdcooper => pr_cdcoopeX) LOOP
      vr_vltitrec := vr_vltitrec + nvl(rw_craplbi.vlliqcre,0);

    END LOOP;

    vr_tab_cdbccxlt := gene0002.fn_quebra_string('01,85,756,100',',');

    FOR idx IN vr_tab_cdbccxlt.first..vr_tab_cdbccxlt.last LOOP
      FLXF0001.pc_grava_movimentacao(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                                    ,pr_cdoperad => pr_cdoperad   -- Codigo do operador
                                    ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                                    ,pr_tpdmovto => 1             -- Tipo de movimento
                                    ,pr_cdbccxlt => vr_tab_cdbccxlt(idx)     -- Codigo do banco/caixa.
                                    ,pr_tpdcampo => 7             -- Tipo de campo
                                    ,pr_vldcampo => (case vr_tab_cdbccxlt(idx)
                                                     when '756' then vr_vltitrec
                                                     else 0
                                                     end)         -- Valor do campo
                                    ,pr_dscritic => pr_dscritic);

      IF pr_dscritic <> 'OK' THEN
        RAISE vr_exc_erro;
      END IF;

    END LOOP;--Fim loop bancos


    pr_dscritic := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
        NULL;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na FLXF0001.pc_grava_mvt_inss: '||SQLerrm;
  END pc_grava_mvt_inss;

  -- Procedure para gravar movimento financeiro das movimentções de Cheques acolhidos para depositos nas contas dos associados.
  PROCEDURE pc_grava_mvt_cheque_nr ( pr_cdcooper  IN INTEGER      -- Codigo da Cooperativa
                                    ,pr_cdagenci  IN INTEGER      -- Codigo da agencia
                                    ,pr_nrdcaixa  IN INTEGER      -- Numero da caixa
                                    ,pr_cdoperad  IN crapope.cdoperad%type     -- Codigo do operador
                                    ,pr_dtmvtolt  IN DATE         -- Data de movimento
                                    ,pr_nmdatela  IN VARCHAR2     -- Nome da tela
                                    ,pr_cdagefim  IN INTEGER      -- Codigo da agencia fim
                                    ,pr_cdcoopex  IN INTEGER      -- Codigo da Cooperativa
                                    ,pr_dscritic OUT VARCHAR2) AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_mvt_cheque_nr          Antigo: b1wgen0131.p/pi_cheques_f_nr
    --
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 20/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar movimento financeiro das movimentções de Cheques acolhidos para depositos nas contas dos associados.
    --
    --   Atualizacao: 20/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --..........................................................................

    vr_exc_erro      EXCEPTION;
    vr_tab_cdbccxlt  gene0002.typ_split;
    vr_vlrchenr      NUMBER := 0;
    vr_idbcoctl      INTEGER;

    --Buscar Cheques acolhidos para depositos nas contas dos associados.
    CURSOR cr_crapchd (pr_dtmvtolt DATE,
                       pr_cdcooper NUMBER,
                       pr_cdagenci NUMBER,
                       pr_cdagefim NUMBER) IS
      SELECT cdbcoenv,
             vlcheque,
             cdcooper,
             cdagenci
        FROM crapchd
       WHERE cdcooper  = pr_cdcooper
         AND dtmvtolt  = pr_dtmvtolt
         AND cdagenci >= nvl(pr_cdagenci,0)
         AND cdagenci <= pr_cdagefim
         AND insitchq in (0,2)
         AND inchqcop  = 0;

  BEGIN

    vr_vlrchenr := 0;

    --Buscar Lancamentos de Cheques acolhidos para depositos nas contas dos associados.
    FOR rw_crapchd IN cr_crapchd(pr_dtmvtolt => pr_dtmvtolt,
                                 pr_cdcooper => pr_cdcoopeX,
                                 pr_cdagenci => pr_cdagenci,
                                 pr_cdagefim => pr_cdagefim) LOOP

      CASE rw_crapchd.cdbcoenv
        -- Somar se o banco enviado pelo banco 85
        WHEN 85 THEN
          vr_vlrchenr := vr_vlrchenr + nvl(rw_crapchd.vlcheque,0);
        WHEN 0 THEN
          vr_idbcoctl := FLXF0001.fn_identifica_bcoctl
                                     (pr_cdcooper => rw_crapchd.cdcooper, -- codigo da cooperativa
                                      pr_cdagenci => rw_crapchd.cdagenci, -- Codigo da agencia
                                      pr_idtpdoct => 'C');                -- Tipo de documento (T-titulo,D-doc,C-cheque)
          -- Somar se o banco de cheques da agencia for 85
          IF vr_idbcoctl = 1 THEN
            vr_vlrchenr := vr_vlrchenr + nvl(rw_crapchd.vlcheque,0);
          END IF;

      END CASE;
    END LOOP;

    vr_tab_cdbccxlt := gene0002.fn_quebra_string('01,85,756,100',',');

    FOR idx IN vr_tab_cdbccxlt.first..vr_tab_cdbccxlt.last LOOP
      FLXF0001.pc_grava_movimentacao(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                                    ,pr_cdoperad => pr_cdoperad   -- Codigo do operador
                                    ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                                    ,pr_tpdmovto => 1             -- Tipo de movimento
                                    ,pr_cdbccxlt => vr_tab_cdbccxlt(idx)     -- Codigo do banco/caixa.
                                    ,pr_tpdcampo => 1/*VLCHEQUE*/ -- Tipo de campo
                                    ,pr_vldcampo => (case vr_tab_cdbccxlt(idx)
                                                     when '85' then vr_vlrchenr
                                                     else 0
                                                     end)         -- Valor do campo
                                    ,pr_dscritic => pr_dscritic);

      IF pr_dscritic <> 'OK' THEN
        RAISE vr_exc_erro;
      END IF;

    END LOOP;--Fim loop bancos


    pr_dscritic := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
        NULL;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na FLXF0001.pc_grava_mvt_cheque_nr: '||SQLerrm;
  END pc_grava_mvt_cheque_nr;

  -- Procedure para gravar movimento financeiro da devolucao de cheques ou taxa de devolucao.
  PROCEDURE pc_grava_mvt_dev_cheque_rem (  pr_cdcooper  IN INTEGER      -- Codigo da Cooperativa
                                          ,pr_cdagenci  IN INTEGER      -- Codigo da agencia
                                          ,pr_nrdcaixa  IN INTEGER      -- Numero da caixa
                                          ,pr_cdoperad  IN crapope.cdoperad%type     -- Codigo do operador
                                          ,pr_dtmvtolt  IN DATE         -- Data de movimento
                                          ,pr_nmdatela  IN VARCHAR2     -- Nome da tela
                                          ,pr_dtmvtoan  IN DATE         -- Data movimento anterior
                                          ,pr_cdcoopex  IN INTEGER      -- Codigo da Cooperativa
                                          ,pr_dscritic OUT VARCHAR2) AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_mvt_dev_cheque_rem          Antigo: b1wgen0131.p/pi_dev_cheques_rem_f
    --
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 20/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar movimento financeiro da devolucao de cheques ou taxa de devolucao.
    --
    --   Atualizacao: 20/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --..........................................................................

    vr_exc_erro      EXCEPTION;
    vr_tab_cdbccxlt  gene0002.typ_split;
    vr_dstextab      CRAPTAB.Dstextab%type;
    vr_vldevolu      NUMBER := 0;
    vr_valorvlb      NUMBER := 0;
    vr_vlrttdev      NUMBER := 0;

    --Buscar Compensacao de Cheques Devolvidos da Central
    CURSOR cr_gncpdev (pr_dtmvtolt DATE,
                       pr_cdcooper NUMBER) IS
      SELECT vlcheque
        FROM gncpdev
       WHERE cdcooper  = pr_cdcooper
         AND dtmvtolt  = pr_dtmvtolt
         AND cdbanchq  = 85
         AND cdtipreg in (1,2);

    --Buscar Arquivo intermediario para a devolucao de cheques ou taxa de devolucao.
    CURSOR cr_crapdev (pr_cdbcoctl NUMBER,
                       pr_cdcooper NUMBER) IS
      SELECT vllanmto,
             indevarq,
             nrdconta,
             TRIM(cdpesqui) cdpesqui,
             nrcheque,
             cdcooper
        FROM crapdev
       WHERE crapdev.cdcooper = pr_cdcooper
         AND crapdev.cdbanchq = pr_cdbcoctl
         AND crapdev.insitdev = 1
         AND crapdev.cdhistor <> 46 /* TX.DEV.CHQ. */
         AND nvl(crapdev.cdalinea,0) > 0
       ORDER BY crapdev.nrctachq,
                crapdev.nrcheque;

    --Buscar contas transferidas entre cooperativas
    CURSOR cr_craptco (pr_cdcooper NUMBER,
                       pr_nrdconta NUMBER) IS
      SELECT cdcopant,
             nrctaant
        FROM craptco
       WHERE craptco.cdcopant = pr_cdcooper
         AND craptco.nrctaant = pr_nrdconta
         AND craptco.tpctatrf = 1 /* 1 = C/C */
         AND craptco.flgativo = 1; --TRUE
    rw_craptco cr_craptco%ROWTYPE;

    --Buscar ultimo registro na Compensacao de Cheques da Central
    CURSOR cr_gncpchq (pr_cdcoopex NUMBER,
                       pr_dtmvtoan DATE,
                       pr_vllanmto NUMBER,
                       pr_cdbcoctl crapcop.cdbcoctl%type,
                       pr_cdagectl crapcop.cdagectl%type,
                       pr_nrdconta crapdev.nrdconta%type,
                       pr_nrcheque crapdev.nrcheque%type) IS
      SELECT 1
        FROM gncpchq g
       WHERE g.progress_recid =
             (SELECT max(g1.progress_recid)
                FROM gncpchq g1
               WHERE g1.cdcooper = pr_cdcoopex
                 AND g1.dtmvtolt = pr_dtmvtoan
                 AND g1.cdbanchq = pr_cdbcoctl
                 AND g1.cdagechq = pr_cdagectl
                 AND g1.nrctachq = pr_nrdconta
                 AND g1.nrcheque = pr_nrcheque
                 AND g1.cdtipreg in ( 3, 4)
                 AND g1.vlcheque = pr_vllanmto);
    rw_gncpchq cr_gncpchq%ROWTYPE;

    /* Busca dos dados da cooperativa */
    CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
      SELECT cdbcoctl,
             cdagectl
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

  BEGIN

    vr_vlrttdev := 0;

    /* No crps624 executa após limpeza da crapdev usar este para o mesmo */
    IF nvl(pr_nmdatela,' ') <> 'PREVIS' THEN
      --Buscar Compensacao de Cheques Devolvidos da Central
      FOR rw_gncpdev IN cr_gncpdev(pr_dtmvtolt => pr_dtmvtoan,
                                   pr_cdcooper => pr_cdcoopeX) LOOP

        vr_vlrttdev := vr_vlrttdev + nvl(rw_gncpdev.vlcheque,0);

      END LOOP;
    ELSE
      /* Cooperativa precisa saber o valor antes da criação do gncpdev
         Feito como no relatório 219 crps264 */

      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop(pr_cdcooper => pr_cdcoopeX);
      FETCH cr_crapcop
       INTO rw_crapcop;
      -- Se nao encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois havera raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        pr_dscritic := 'Cooperativa '||pr_cdcoopeX||' não localizada.';
        Return;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;

      -- Buscar informacoes CRAPTAB
      vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcoopeX
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'GENERI'
                                               ,pr_cdempres => 0
                                               ,pr_cdacesso => 'VALORESVLB'
                                               ,pr_tpregist => 0);
      IF vr_dstextab IS NOT NULL THEN
        vr_vldevolu := to_number(gene0002.fn_busca_entrada(3,vr_dstextab,';'));
        vr_valorvlb := to_number(gene0002.fn_busca_entrada(2,vr_dstextab,';'));
      ELSE
        pr_dscritic := 'NOK';
        Return;
      END IF;

      --Ler Arquivo intermediario para a devolucao de cheques ou taxa de devolucao.
      FOR rw_crapdev IN cr_crapdev(pr_cdbcoctl => rw_crapcop.cdbcoctl,
                                   pr_cdcooper => pr_cdcoopeX) LOOP

        -- Se não foi informada a conta
        IF rw_crapdev.nrdconta = 0 THEN
          -- calcular valor de devolução
          CASE rw_crapdev.indevarq
            WHEN 1 THEN  -- devolução enviada pelo arquivo
              vr_vlrttdev := vr_vlrttdev + nvl(rw_crapdev.vllanmto,0);
            WHEN 2 THEN
              IF nvl(rw_crapdev.vllanmto,0) < vr_valorvlb THEN
                vr_vlrttdev := vr_vlrttdev + nvl(rw_crapdev.vllanmto,0);
              END IF;
          END CASE;
        ELSE
          IF rw_crapdev.cdpesqui is null THEN
            --Buscar ultimo registro na Compensacao de Cheques da Central
            OPEN cr_gncpchq (pr_cdcoopex => pr_cdcoopex,
                             pr_dtmvtoan => pr_dtmvtoan,
                             pr_vllanmto => rw_crapdev.vllanmto,
                             pr_cdbcoctl => rw_crapcop.cdbcoctl,
                             pr_cdagectl => rw_crapcop.cdagectl,
                             pr_nrdconta => rw_crapdev.nrdconta,
                             pr_nrcheque => rw_crapdev.nrcheque );
            FETCH cr_gncpchq
              INTO rw_gncpchq;
            IF cr_gncpchq%NOTFOUND THEN
              close cr_gncpchq;
              CONTINUE;
            END IF;
            close cr_gncpchq;
          ELSE
            IF rw_crapdev.cdpesqui = 'TCO' THEN /* Contas transferidas */
              /* Tabela de contas transferidas entre cooperativas */
              OPEN cr_craptco (pr_cdcooper => rw_crapdev.cdcooper,
                               pr_nrdconta => rw_crapdev.nrdconta);
              FETCH cr_craptco
                INTO rw_craptco;
              IF cr_craptco%NOTFOUND THEN
                close cr_craptco;
                continue;
              ELSE
                close cr_craptco;
                --Buscar ultimo registro na Compensacao de Cheques da Central
                OPEN cr_gncpchq (pr_cdcoopex => rw_craptco.cdcopant,
                                 pr_dtmvtoan => pr_dtmvtoan,
                                 pr_vllanmto => rw_crapdev.vllanmto,
                                 pr_cdbcoctl => rw_crapcop.cdbcoctl,
                                 pr_cdagectl => rw_crapcop.cdagectl,
                                 pr_nrdconta => rw_craptco.nrctaant,
                                 pr_nrcheque => rw_crapdev.nrcheque);
                FETCH cr_gncpchq
                  INTO rw_gncpchq;
                IF cr_gncpchq%NOTFOUND THEN
                  close cr_gncpchq;
                  CONTINUE;
                END IF;
                close cr_gncpchq;
              END IF;

            END IF; -- Fim rw_crapdev.cdpesqui = 'TCO'
          END IF; -- Fim  rw_crapdev.cdpesqui is null
        END IF; -- Fim rw_crapdev.nrdconta = 0

        IF rw_crapdev.cdpesqui is not null AND
           rw_crapdev.cdpesqui <> 'TCO'    THEN
          continue;
        ELSE
          -- calcular valor de devolução
          CASE rw_crapdev.indevarq
            WHEN 1 THEN
              vr_vlrttdev := vr_vlrttdev + nvl(rw_crapdev.vllanmto,0);
            WHEN 2 THEN
              IF rw_crapdev.vllanmto < vr_valorvlb THEN
                vr_vlrttdev := vr_vlrttdev + nvl(rw_crapdev.vllanmto,0);
              END IF;
          END CASE;
        END IF;
      END LOOP; -- Fim loop cr_gncpdev

    END IF; -- Fim pr_nmdatela <> 'PREVIS'

    vr_tab_cdbccxlt := gene0002.fn_quebra_string('01,85,756,100',',');

    -- Varrer o array com os bancos e gerar a movimentação
    FOR idx IN vr_tab_cdbccxlt.first..vr_tab_cdbccxlt.last LOOP
      FLXF0001.pc_grava_movimentacao(pr_cdcooper => pr_cdcoopex   -- Codigo da Cooperativa
                                    ,pr_cdoperad => pr_cdoperad   -- Codigo do operador
                                    ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                                    ,pr_tpdmovto => 1             -- Tipo de movimento
                                    ,pr_cdbccxlt => vr_tab_cdbccxlt(idx)     -- Codigo do banco/caixa.
                                    ,pr_tpdcampo => 5   /**VLDEVOLU*/          -- Tipo de campo
                                    ,pr_vldcampo => (case vr_tab_cdbccxlt(idx)
                                                     when '85' then vr_vlrttdev
                                                     else 0
                                                     end)         -- Valor do campo
                                    ,pr_dscritic => pr_dscritic);

      IF pr_dscritic <> 'OK' THEN
        RAISE vr_exc_erro;
      END IF;

    END LOOP;--Fim loop bancos

    pr_dscritic := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
        NULL;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na FLXF0001.pc_grava_mvt_dev_cheque_rem: '||SQLerrm;
  END pc_grava_mvt_dev_cheque_rem;

  -- Procedure para gravar movimento financeiro dos Credito deposito/transferencia/tec salario intercooperativo
  PROCEDURE pc_mvt_transf_dep_intercoop ( pr_cdcooper  IN INTEGER      -- Codigo da Cooperativa
                                         ,pr_cdagenci  IN INTEGER      -- Codigo da agencia
                                         ,pr_nrdcaixa  IN INTEGER      -- Numero da caixa
                                         ,pr_cdoperad  IN crapope.cdoperad%type     -- Codigo do operador
                                         ,pr_dtmvtolt  IN DATE         -- Data de movimento
                                         ,pr_nmdatela  IN VARCHAR2     -- Nome da tela
                                         ,pr_cdcoopex  IN INTEGER      -- Codigo da Cooperativa
                                         ,pr_tpdmovto  IN INTEGER      -- Tipo de movimento (1-Entrada 2-saida)
                                         ,pr_dscritic OUT VARCHAR2) AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_mvt_transf_dep_intercoop          Antigo: b1wgen0131.p/1 - pi_rec_transf_dep_intercoop_f
    --                                                                       2 - pi_rem_transf_dep_intercoop_f
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 11/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar movimento financeiro dos Credito deposito/transferencia/tec salario intercooperativo
    --
    --   Atualizacao: 08/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --..........................................................................

    vr_exc_erro      EXCEPTION;
    vr_tab_cdbccxlt  gene0002.typ_split;
    vr_vlrtsfns      NUMBER;

    --Buscar lancamentos em depositos a vista
    CURSOR cr_craplcm (pr_dtmvtolt DATE,
                       pr_cdcooper NUMBER,
                       pr_tpdmovto INTEGER) IS
      SELECT sum(vllanmto) vllanmto, 1 id
        FROM craplcm
       WHERE craplcm.cdcooper = pr_cdcooper
         AND craplcm.dtmvtolt = pr_dtmvtolt
         AND ( (pr_tpdmovto = 1 and craplcm.cdhistor IN (1004,1011,1022)) OR
               (pr_tpdmovto = 2 and craplcm.cdhistor IN (1009,1008))
              )
      UNION
      -- se for 2-saida deve buscar os lanc. do hist. 1004  do cooperativa do cash
      SELECT Sum(vllanmto) vllanmto, 2 id
        FROM craplcm
       WHERE pr_tpdmovto = 2
         AND craplcm.cdcooper <> pr_cdcooper
         AND craplcm.dtmvtolt = pr_dtmvtolt
         AND craplcm.cdcoptfn = pr_cdcooper
         and craplcm.cdhistor = 1004; --CR.DEP.INTERC

  BEGIN

    vr_vlrtsfns := 0;

    -- buscar lançamentos
    FOR rw_craplcm IN cr_craplcm(pr_dtmvtolt => pr_dtmvtolt,
                                 pr_cdcooper => pr_cdcoopex,
                                 pr_tpdmovto => pr_tpdmovto) LOOP
      -- Somar valores
      vr_vlrtsfns := NVL(vr_vlrtsfns,0) + NVL(rw_craplcm.vllanmto,0);
    END LOOP;

    vr_tab_cdbccxlt := gene0002.fn_quebra_string('01,85,756,100',',');

    FOR idx IN vr_tab_cdbccxlt.first..vr_tab_cdbccxlt.last LOOP
      FLXF0001.pc_grava_movimentacao(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                                    ,pr_cdoperad => pr_cdoperad   -- Codigo do operador
                                    ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                                    ,pr_tpdmovto => pr_tpdmovto   -- Tipo de movimento
                                    ,pr_cdbccxlt => vr_tab_cdbccxlt(idx)     -- Codigo do banco/caixa.
                                    ,pr_tpdcampo => 8 /*VLTRDEIT*/-- Tipo de campo
                                    ,pr_vldcampo => (case vr_tab_cdbccxlt(idx)
                                                     when '100' then vr_vlrtsfns
                                                     else 0
                                                     end)         -- Valor do campo
                                    ,pr_dscritic => pr_dscritic);

      IF pr_dscritic <> 'OK' THEN
        RAISE vr_exc_erro;
      END IF;

    END LOOP;--Fim loop bancos


    pr_dscritic := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
        NULL;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na FLXF0001.pc_mvt_transf_dep_intercoop: '||SQLerrm;
  END pc_mvt_transf_dep_intercoop;

  -- Procedure para gravar movimento financeiro das devoluções de cheques de outros bancos
  PROCEDURE pc_grava_mvt_dev_cheque_rec ( pr_cdcooper  IN INTEGER      -- Codigo da Cooperativa
                                         ,pr_cdagenci  IN INTEGER      -- Codigo da agencia
                                         ,pr_nrdcaixa  IN INTEGER      -- Numero da caixa
                                         ,pr_cdoperad  IN crapope.cdoperad%type     -- Codigo do operador
                                         ,pr_dtmvtolt  IN DATE         -- Data de movimento
                                         ,pr_nmdatela  IN VARCHAR2     -- Nome da tela
                                         ,pr_dtmvtoan  IN DATE         -- Data de movimento anterior
                                         ,pr_cdcoopex  IN INTEGER      -- Codigo da Cooperativa
                                         ,pr_cdagefim  IN INTEGER      -- Codigo da agencia final
                                         ,pr_tab_erro OUT GENE0001.typ_tab_erro -- Tabela contendo os erros
                                         ,pr_dscritic OUT VARCHAR2) AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_mvt_dev_cheque_rec          Antigo: b1wgen0131.p/pi_dev_cheques_rec_f
    --
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 20/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar movimento financeiro das devoluções de cheques de outros bancos
    --
    --   Atualizacao: 20/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --..........................................................................

    vr_exc_erro      EXCEPTION;
    vr_tab_cdbccxlt  gene0002.typ_split;
    vr_vldevchq      NUMBER;
    vr_dstextab      craptab.dstextab%type;
    vr_idbcoctl      INTEGER;
    vr_nrsequen      NUMBER;
    vr_dscritic      varchar2(500);

    --Buscar Cheques acolhidos para depositos nas contas dos associados.
    CURSOR cr_crapchd (pr_dtmvtolt DATE,
                       pr_cdcooper NUMBER,
                       pr_cdagenci NUMBER,
                       pr_cdagefim NUMBER) IS
      SELECT cdbcoenv,
             vlcheque,
             cdcooper,
             cdagenci
        FROM crapchd
       WHERE cdcooper  = pr_cdcooper
         AND dtmvtolt  = pr_dtmvtolt
         AND cdagenci >= nvl(pr_cdagenci,0)
         AND cdagenci <= pr_cdagefim
         AND insitchq in (0,2)
         AND inchqcop  = 0;

  BEGIN

    vr_vldevchq := 0;

    -- Buscar informacoes para calculo de poupanca
    vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                             ,pr_nmsistem => 'CRED'
                                             ,pr_tptabela => 'GENERI'
                                             ,pr_cdempres => 00
                                             ,pr_cdacesso => 'PARFLUXOFINAN'
                                             ,pr_tpregist => 0);

    IF vr_dstextab IS NOT NULL THEN
      IF to_number(gene0002.fn_busca_entrada(5,vr_dstextab,';')) > 0 THEN
        --Buscar Lancamentos de Cheques acolhidos para depositos nas contas dos associados.
        FOR rw_crapchd IN cr_crapchd(pr_dtmvtolt => pr_dtmvtoan,
                                     pr_cdcooper => pr_cdcoopeX,
                                     pr_cdagenci => pr_cdagenci,
                                     pr_cdagefim => pr_cdagefim) LOOP

          CASE rw_crapchd.cdbcoenv
            -- Somar se o banco enviado pelo banco 85
            WHEN 85 THEN
              vr_vldevchq := vr_vldevchq + nvl(rw_crapchd.vlcheque,0);
            WHEN 0 THEN
              vr_idbcoctl := FLXF0001.fn_identifica_bcoctl
                                         (pr_cdcooper => rw_crapchd.cdcooper, -- codigo da cooperativa
                                          pr_cdagenci => rw_crapchd.cdagenci, -- Codigo da agencia
                                          pr_idtpdoct => 'C');                -- Tipo de documento (T-titulo,D-doc,C-cheque)
              -- Somar se o banco de cheques da agencia for 85
              IF vr_idbcoctl = 1 THEN
                vr_vldevchq := vr_vldevchq + nvl(rw_crapchd.vlcheque,0);
              END IF;

          END CASE;
        END LOOP;

        -- acrescentar percentual
        vr_vldevchq := ((vr_vldevchq * to_number(gene0002.fn_busca_entrada(5,vr_dstextab,';')))/ 100);

      ELSE
        -- Gerar log de erro
        IF pr_tab_erro.count > 0 then
          vr_nrsequen := pr_tab_erro(pr_tab_erro.last).nrsequen + 1;
        else
          vr_nrsequen := nvl(vr_nrsequen,0) + 1;
        end if;

        vr_dscritic := 'Base de calculo devolucao de cheques nao informada.';

        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                              pr_cdagenci => pr_cdagenci,
                              pr_nrdcaixa => pr_nrdcaixa,
                              pr_nrsequen => vr_nrsequen,
                              pr_cdcritic => 0,
                              pr_dscritic => vr_dscritic,
                              pr_tab_erro => pr_tab_erro);
      END IF;
    END IF;

    vr_tab_cdbccxlt := gene0002.fn_quebra_string('01,85,756,100',',');

    FOR idx IN vr_tab_cdbccxlt.first..vr_tab_cdbccxlt.last LOOP
      FLXF0001.pc_grava_movimentacao(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                                    ,pr_cdoperad => pr_cdoperad   -- Codigo do operador
                                    ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                                    ,pr_tpdmovto => 2             -- Tipo de movimento
                                    ,pr_cdbccxlt => vr_tab_cdbccxlt(idx)     -- Codigo do banco/caixa.
                                    ,pr_tpdcampo => 5 /**VLDEVOLU*/          -- Tipo de campo
                                    ,pr_vldcampo => (case vr_tab_cdbccxlt(idx)
                                                     when '85' then vr_vldevchq
                                                     else 0
                                                     end)         -- Valor do campo
                                    ,pr_dscritic => pr_dscritic);

      IF pr_dscritic <> 'OK' THEN
        RAISE vr_exc_erro;
      END IF;

    END LOOP;--Fim loop bancos


    pr_dscritic := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
        NULL;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na FLXF0001.pc_grava_mvt_dev_cheque_rec: '||SQLerrm;
  END pc_grava_mvt_dev_cheque_rec;

  -- Procedure para gravar movimento financeiro referente aos TEDs recebidos
  PROCEDURE pc_grava_mvt_ted (pr_cdcooper  IN INTEGER      -- Codigo da Cooperativa
                             ,pr_cdagenci  IN INTEGER      -- Codigo da agencia
                             ,pr_nrdcaixa  IN INTEGER      -- Numero da caixa
                             ,pr_cdoperad  IN crapope.cdoperad%type     -- Codigo do operador
                             ,pr_dtmvtolt  IN DATE         -- Data de movimento
                             ,pr_nmdatela  IN VARCHAR2     -- Nome da tela
                             ,pr_cdcoopex  IN INTEGER      -- Codigo da Cooperativa
                             ,pr_tab_erro IN OUT NOCOPY GENE0001.typ_tab_erro -- Tabela com os erros
                             ,pr_dscritic OUT VARCHAR2) AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_mvt_ted         Antigo: b1wgen0131.p/pi_sr_ted_f
    --
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 14/12/2016
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar movimento financeiro referente aos TEDs recebidos
    --
    --   Atualizacao: 25/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --
    --                28/09/2016 - Passar novos parämetros na chamada a sspb0001 (Jonata-RKAM)
	--
  	--				        07/11/2016 - Ajuste para contabilizar as TED - SICREDI (Adriano - M211)
    --
    --                14/12/2016 - Ajuste para gravar movimentação de TED - SICREDI corretamente (Adriano - SD 577067)
    --..........................................................................

    vr_exc_erro      EXCEPTION;
    vr_tab_cdbccxlt  gene0002.typ_split;
    vr_vlrtedsr      NUMBER;

    vr_tab_logspb          SSPB0001.typ_tab_logspb;
    vr_tab_logspb_detalhe  SSPB0001.typ_tab_logspb_detalhe;
    vr_tab_logspb_totais   SSPB0001.typ_tab_logspb_totais;
    vr_tab_erro            GENE0001.typ_tab_erro;


  BEGIN

    vr_vlrtedsr := 0;

    /** Procedimento para obter log do SPB da Cecred*/
    SSPB0001.pc_obtem_log_cecred( pr_cdcooper  => pr_cdcooper   -- Codigo Cooperativa
                                 ,pr_cdagenci  => pr_cdagenci   -- Cod. Agencia
                                 ,pr_nrdcaixa  => 0             -- Numero Caixa
                                 ,pr_cdoperad  => pr_cdoperad   -- Operador
                                 ,pr_nmdatela  => pr_nmdatela   -- Nome da tela
                                 ,pr_cdorigem  => 0 /* TODOS */ -- Identificador Origem
                                 ,pr_dtmvtini  => pr_dtmvtolt   -- Data de movimento de log
                                 ,pr_dtmvtfim  => pr_dtmvtolt   -- Data de movimento de log
                                 ,pr_numedlog  =>  2  /* RECEBIDAS */   -- Indicador de log a carregar
                                 ,pr_cdsitlog  => 'P' /* Processadas */ -- Codigo de situação de log
                                 ,pr_nrdconta  => 0             -- Numero da Conta
                                 ,pr_nrsequen  => 0             -- Sequencia
                                 ,pr_nriniseq  => 1             -- numero inicial da sequencia
                                 ,pr_nrregist  => 99999         -- numero de registros
                                 ,pr_cdifconv  => 0             -- IF Da TED - Somente CECRED
                                 ,pr_vlrdated  => 0             -- Valor da ted
                                 ,pr_dscritic  => pr_dscritic
                                 ,pr_tab_logspb         => vr_tab_logspb         --> TempTable para armazenar o valor
                                 ,pr_tab_logspb_detalhe => vr_tab_logspb_detalhe --> TempTable para armazenar o valor
                                 ,pr_tab_logspb_totais  => vr_tab_logspb_totais  --> Variavel para armazenar os totais por situação de log
                                 ,pr_tab_erro           => vr_tab_erro           --> Tabela contendo os erros
                                );

    -- Convertido conforme o progress ignorando o retorno da package SSPB0001,
    -- conforme passado por Diego Vincentini, será revisado todo a BO, caso necessario retornar o erro o codigo ja esta pronto
    /*IF pr_dscritic <> 'OK' THEN
      pr_dscritic := pr_tab_erro(1).dscritic;
    END IF; */
    vr_tab_erro.DELETE;

    --Verificar se existe valores totais de recebido
    IF vr_tab_logspb_totais.EXISTS('3') THEN /* RECEBIDAS-OK */
      vr_vlrtedsr := vr_tab_logspb_totais('3').vlsitlog ;
    ELSE
      vr_vlrtedsr := 0;
    END IF;

    vr_tab_cdbccxlt := gene0002.fn_quebra_string('01,85,756,100',',');

    FOR idx IN vr_tab_cdbccxlt.first..vr_tab_cdbccxlt.last LOOP
      FLXF0001.pc_grava_movimentacao(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                                    ,pr_cdoperad => pr_cdoperad   -- Codigo do operador
                                    ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                                    ,pr_tpdmovto => 1             -- Tipo de movimento
                                    ,pr_cdbccxlt => vr_tab_cdbccxlt(idx) -- Codigo do banco/caixa.
                                    ,pr_tpdcampo => 3 /*VLTOTTED*/       -- Tipo de campo
                                    ,pr_vldcampo => (case vr_tab_cdbccxlt(idx)
                                                     when '85' then vr_vlrtedsr
                                                     else 0
                                                     end)         -- Valor do campo
                                    ,pr_dscritic => pr_dscritic);

      IF pr_dscritic <> 'OK' THEN
        RAISE vr_exc_erro;
      END IF;

    END LOOP;--Fim loop bancos

    vr_vlrtedsr := 0;

    /** Procedimento para obter log do SPB da Cecred - SICREDI*/
    SSPB0001.pc_obtem_log_cecred( pr_cdcooper  => pr_cdcooper   -- Codigo Cooperativa
                                 ,pr_cdagenci  => pr_cdagenci   -- Cod. Agencia
                                 ,pr_nrdcaixa  => 0             -- Numero Caixa
                                 ,pr_cdoperad  => pr_cdoperad   -- Operador
                                 ,pr_nmdatela  => pr_nmdatela   -- Nome da tela
                                 ,pr_cdorigem  => 0 /* TODOS */ -- Identificador Origem
                                 ,pr_dtmvtini  => pr_dtmvtolt   -- Data de movimento de log
                                 ,pr_dtmvtfim  => pr_dtmvtolt   -- Data de movimento de log
                                 ,pr_numedlog  =>  2  /* RECEBIDAS */   -- Indicador de log a carregar
                                 ,pr_cdsitlog  => 'P' /* Processadas */ -- Codigo de situação de log
                                 ,pr_nrdconta  => 0             -- Numero da Conta
                                 ,pr_nrsequen  => 0             -- Sequencia
                                 ,pr_nriniseq  => 1             -- numero inicial da sequencia
                                 ,pr_nrregist  => 99999         -- numero de registros
                                 ,pr_cdifconv  => 1             -- IF Da TED - Somente SICREDI
                                 ,pr_vlrdated  => 0             -- Valor da ted
                                 ,pr_dscritic  => pr_dscritic
                                 ,pr_tab_logspb         => vr_tab_logspb         --> TempTable para armazenar o valor
                                 ,pr_tab_logspb_detalhe => vr_tab_logspb_detalhe --> TempTable para armazenar o valor
                                 ,pr_tab_logspb_totais  => vr_tab_logspb_totais  --> Variavel para armazenar os totais por situação de log
                                 ,pr_tab_erro           => vr_tab_erro           --> Tabela contendo os erros
                                );

    -- Convertido conforme o progress ignorando o retorno da package SSPB0001,
    -- conforme passado por Diego Vincentini, será revisado todo a BO, caso necessario retornar o erro o codigo ja esta pronto
    /*IF pr_dscritic <> 'OK' THEN
      pr_dscritic := pr_tab_erro(1).dscritic;
    END IF; */
    vr_tab_erro.DELETE;

    --Verificar se existe valores totais de recebido
    IF vr_tab_logspb_totais.EXISTS('3') THEN /* RECEBIDAS-OK */
      vr_vlrtedsr := vr_tab_logspb_totais('3').vlsitlog ;
    ELSE
      vr_vlrtedsr := 0;
    END IF;

      FLXF0001.pc_grava_movimentacao(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                                    ,pr_cdoperad => pr_cdoperad   -- Codigo do operador
                                    ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                                    ,pr_tpdmovto => 1             -- Tipo de movimento
                                  ,pr_cdbccxlt => 100           -- Codigo do banco/caixa.
                                  ,pr_tpdcampo => 3 /*VLTOTTED*/-- Tipo de campo
                                  ,pr_vldcampo => vr_vlrtedsr   -- Valor do campo
                                    ,pr_dscritic => pr_dscritic);

      IF pr_dscritic <> 'OK' THEN
        RAISE vr_exc_erro;
      END IF;

    pr_dscritic := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
        NULL;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na FLXF0001.pc_grava_mvt_ted: '||SQLerrm;
  END pc_grava_mvt_ted;

  -- Procedure para gravar movimento financeiro dos TEDs e TECs
  PROCEDURE pc_grava_mvt_tedtec_nr ( pr_cdcooper  IN INTEGER      -- Codigo da Cooperativa
                                    ,pr_cdagenci  IN INTEGER      -- Codigo da agencia
                                    ,pr_nrdcaixa  IN INTEGER      -- Numero da caixa
                                    ,pr_cdoperad  IN crapope.cdoperad%type     -- Codigo do operador
                                    ,pr_dtmvtolt  IN DATE         -- Data de movimento
                                    ,pr_nmdatela  IN VARCHAR2     -- Nome da tela
                                    ,pr_cdagefim  IN INTEGER      -- Codigo da agencia final
                                    ,pr_cdcoopex  IN INTEGER      -- Codigo da Cooperativa
                                    ,pr_dscritic OUT VARCHAR2) AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_mvt_tedtec_nr          Antigo: b1wgen0131.p/pi_tedtec_nr_f
    --
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 14/12/2016
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar movimento financeiro dos TEDs e TECs
    --
    --   Atualizacao: 21/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
	--
	  --				        07/11/2016 - Ajuste para contabilizar as TED - SICREDI (Adriano - M211)
    --
    --				        14/12/2016 - Ajuste para gravar movimentação de TED - SICREDI corretamente (Adriano - SD 577067)
    --..........................................................................

    vr_exc_erro      EXCEPTION;
    vr_tab_cdbccxlt  gene0002.typ_split;
    vr_vlrtednr      NUMBER;

    --Buscar lancamentos dos funcionarios das empresas que optaram por transferir o salario para outra instituicao financeira.
    CURSOR cr_craplcs (pr_dtmvtolt DATE,
                       pr_cdcooper NUMBER,
                       pr_cdagenci NUMBER,
                       pr_cdagefim NUMBER) IS
      SELECT nvl(sum(vllanmto),0) vllanmto
        FROM craplcs
       WHERE cdcooper  = pr_cdcooper
         AND dtmvtolt  = pr_dtmvtolt
         AND cdagenci >= nvl(pr_cdagenci,0)
         AND cdagenci <= pr_cdagefim
         AND cdhistor  = 827; /* TEC ENVIADA PELA NOSSA IF */

    -- Buscar tranferencia de valores (DOC C, DOC D E TEDS)
    CURSOR cr_craptvl (pr_dtmvtolt DATE,
                       pr_cdcooper NUMBER,
                       pr_cdagenci NUMBER,
                       pr_cdagefim NUMBER) IS
      SELECT nvl(sum(vldocrcb),0) vldocrcb
        FROM craptvl
       WHERE cdcooper  = pr_cdcooper
         AND dtmvtolt  = pr_dtmvtolt
         AND cdagenci >= nvl(pr_cdagenci,0)
         AND cdagenci <= pr_cdagefim
         AND cdbcoenv  = 85
         AND tpdoctrf  = 3;/* TED */

    --Buscar Lancamentos em depositos a vista
    CURSOR cr_craplcm (pr_dtmvtolt DATE,
                       pr_cdcooper NUMBER) IS
      SELECT nvl(sum(vllanmto),0) vllanmto
        FROM craplcm
       WHERE cdcooper  = pr_cdcooper
         AND dtmvtolt  = pr_dtmvtolt
         AND cdhistor  = 887; /*** Desprezar TEC'S  e TED'S rejeitadas pela cabine da JD ***/

    --Buscar Lancamentos em depositos a vista
    CURSOR cr_craplcm_sicredi (pr_dtmvtolt DATE) IS
      SELECT nvl(sum(vllanmto),0) vllanmto
        FROM craplcm
       WHERE cdcooper  <> 16
         AND dtmvtolt  = pr_dtmvtolt
         AND cdhistor  = 1787; /*** TED - SICREDI ***/

  BEGIN

    vr_vlrtednr := 0;

    /* Verificar TED p/ estornos */
    FOR rw_craplcs IN cr_craplcs(pr_dtmvtolt => pr_dtmvtolt,
                                 pr_cdcooper => pr_cdcoopeX,
                                 pr_cdagenci => pr_cdagenci,
                                 pr_cdagefim => pr_cdagefim) LOOP

      vr_vlrtednr := vr_vlrtednr + rw_craplcs.vllanmto;
    END LOOP;

    /* TED - Transferencias*/
    FOR rw_craptvl IN cr_craptvl(pr_dtmvtolt => pr_dtmvtolt,
                                 pr_cdcooper => pr_cdcoopeX,
                                 pr_cdagenci => pr_cdagenci,
                                 pr_cdagefim => pr_cdagefim) LOOP

      vr_vlrtednr := vr_vlrtednr + rw_craptvl.vldocrcb;

    END LOOP;

    /*** Desprezar TEC'S  e TED'S rejeitadas pela cabine da JD ***/
    FOR rw_craplcm IN cr_craplcm(pr_dtmvtolt => pr_dtmvtolt,
                                 pr_cdcooper => pr_cdcoopeX) LOOP

      vr_vlrtednr := vr_vlrtednr - rw_craplcm.vllanmto;

    END LOOP;

    vr_tab_cdbccxlt := gene0002.fn_quebra_string('01,85,756,100',',');

    FOR idx IN vr_tab_cdbccxlt.first..vr_tab_cdbccxlt.last LOOP
      FLXF0001.pc_grava_movimentacao(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                                    ,pr_cdoperad => pr_cdoperad   -- Codigo do operador
                                    ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                                    ,pr_tpdmovto => 2             -- Tipo de movimento
                                    ,pr_cdbccxlt => vr_tab_cdbccxlt(idx)     -- Codigo do banco/caixa.
                                    ,pr_tpdcampo => 3/*VLTOTTED*/ -- Tipo de campo
                                    ,pr_vldcampo => (case vr_tab_cdbccxlt(idx)
                                                     when '85' then vr_vlrtednr
                                                     else 0
                                                     end)         -- Valor do campo
                                    ,pr_dscritic => pr_dscritic);

      IF pr_dscritic <> 'OK' THEN
        RAISE vr_exc_erro;
      END IF;

    END LOOP;--Fim loop bancos

    /*Para teds SICREDI somente a cooperativa Alto Vale tera
   	  movimentacao de saida.*/
    IF pr_cdcooper = 16 THEN
      
      vr_vlrtednr := 0;
      
      /*** Busca TEDs SICREDI ***/
      FOR rw_craplcm_sicredi IN cr_craplcm_sicredi(pr_dtmvtolt => pr_dtmvtolt) LOOP

        vr_vlrtednr := vr_vlrtednr + rw_craplcm_sicredi.vllanmto;

      END LOOP;
      
        FLXF0001.pc_grava_movimentacao(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                                      ,pr_cdoperad => pr_cdoperad   -- Codigo do operador
                                      ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                                      ,pr_tpdmovto => 2             -- Tipo de movimento
                                    ,pr_cdbccxlt => 100           -- Codigo do banco/caixa.
                                      ,pr_tpdcampo => 3/*VLTOTTED*/ -- Tipo de campo
                                    ,pr_vldcampo => vr_vlrtednr   -- Valor do campo
                                      ,pr_dscritic => pr_dscritic);

        IF pr_dscritic <> 'OK' THEN
          RAISE vr_exc_erro;
        END IF;

    END IF;

    pr_dscritic := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
        NULL;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na FLXF0001.pc_grava_mvt_tedtec_nr: '||SQLerrm;
	END pc_grava_mvt_tedtec_nr;

  -- Procedure para gravar movimento financeiro dos conveniados
  PROCEDURE pc_grava_mvt_convenios( pr_cdcooper  IN INTEGER      -- Codigo da Cooperativa
                                   ,pr_cdagenci  IN INTEGER      -- Codigo da agencia
                                   ,pr_nrdcaixa  IN INTEGER      -- Numero da caixa
                                   ,pr_cdoperad  IN crapope.cdoperad%type     -- Codigo do operador
                                   ,pr_dtmvtolt  IN DATE         -- Data de movimento
                                   ,pr_nmdatela  IN VARCHAR2     -- Nome da tela
                                   ,pr_cdcoopex  IN INTEGER      -- Codigo da Cooperativa
                                   ,pr_dscritic OUT VARCHAR2) AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_mvt_convenios          Antigo: b1wgen0131.p/pi_convenios_f
    --
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 22/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar movimento financeiro dos conveniados
    --
    --   Atualizacao: 22/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --..........................................................................

    vr_exc_erro      EXCEPTION;
    vr_tab_cdbccxlt  gene0002.typ_split;
    vr_vlrconve      NUMBER;
    vr_qtregist      INTEGER;
    vr_tab_erro      GENE0001.typ_tab_erro;
    vr_tab_dados_pesqti CONV0001.typ_tab_dados_pesqti;


    -- Buscar Convenios por cooperativa
    CURSOR cr_gncvcop (pr_cdcooper NUMBER) IS
      SELECT cdconven
        FROM gncvcop
       WHERE gncvcop.cdcooper = pr_cdcooper;

    -- Buscar convenios
    CURSOR cr_gnconve (pr_cdconven gncvcop.cdconven%type) IS
      SELECT cdhisdeb
        FROM gnconve
       WHERE gnconve.cdconven = pr_cdconven
         AND gnconve.flgativo = 1 --true
         AND gnconve.cdconven <> 39
         AND gnconve.cdhisdeb > 0;

    --Buscar Lancamentos em depositos a vista
    CURSOR cr_craplcm (pr_dtmvtolt DATE,
                       pr_cdcooper NUMBER,
                       pr_cdhisdeb gnconve.cdhisdeb%type) IS
      SELECT sum(nvl(vllanmto,0)) vllanmto
        FROM craplcm
       WHERE cdcooper  = pr_cdcooper
         AND dtmvtolt  = pr_dtmvtolt
         AND cdhistor  = pr_cdhisdeb;


  BEGIN

    vr_vlrconve := 0;

    /* Gerar tempTable dos Lancamentos de faturas.(craplft)  dos convenios*/
    CONV0001.pc_consulta_faturas (pr_cdcooper  => pr_cdcoopex    -- Codigo da cooperativa
                                 ,pr_dtmvtolt  => pr_dtmvtolt    -- Data de movimento
                                 ,pr_nrdcaixa  => 0              -- Numero da caixa
                                 ,pr_dtdpagto  => pr_dtmvtolt    -- Data de pagamento
                                 ,pr_vldpagto  => 0              -- Valor do pagamento
                                 ,pr_cdagenci  => 0              -- Codigo da agencia
                                 ,pr_cdhistor  => 0              -- Codigo do historico
                                 ,pr_flgpagin  => FALSE          -- Indicativo  de paginação
                                 ,pr_nrregist  => 0              -- Número de controle de registros
                                 ,pr_nriniseq  => 0              -- Número de controle de inicio de registro
                                 ,pr_cdempcon  => 0              -- Codigo da empresa a ser conveniada.
                                 ,pr_cdsegmto  => 0              -- Identificacao do segmento da empresa/orgao
                                 ,pr_flgcnvsi  => FALSE          -- Indicador SICREDI associa ao historico específico
                                 ,pr_qtregist => vr_qtregist     -- Retorna a quantidade de registro
                                 ,pr_vlrtotal => vr_vlrconve     -- Valor total
                                 ,pr_dscritic => pr_dscritic     -- Descricao da critica
                                 ,pr_tab_erro => vr_tab_erro     -- Tabela contendo os erros
                                 ,pr_tab_dados_pesqti => vr_tab_dados_pesqti); -- tabela de historicos

    IF pr_dscritic <> 'OK' THEN
      RETURN;
    END IF;

    /* Débito automatico */
    FOR rw_gncvcop IN cr_gncvcop(pr_cdcooper => pr_cdcoopex) LOOP
      -- Ler convenios
      FOR rw_gnconve IN cr_gnconve(pr_cdconven => rw_gncvcop.cdconven) LOOP
        --ler lancamentos
        FOR rw_craplcm IN cr_craplcm(pr_dtmvtolt => pr_dtmvtolt,
                                     pr_cdcooper => pr_cdcoopeX,
                                     pr_cdhisdeb => rw_gnconve.cdhisdeb) LOOP

          vr_vlrconve := nvl(vr_vlrconve,0) + nvl(rw_craplcm.vllanmto,0);

        END LOOP; -- Fim loop craplcm
      END LOOP; -- Fim loop gnconve
    END LOOP; -- Fim loop gncvcop

    vr_tab_cdbccxlt := gene0002.fn_quebra_string('01,85,756,100',',');

    -- ler os bancos
    FOR idx IN vr_tab_cdbccxlt.first..vr_tab_cdbccxlt.last LOOP
      FLXF0001.pc_grava_movimentacao(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                                    ,pr_cdoperad => pr_cdoperad   -- Codigo do operador
                                    ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                                    ,pr_tpdmovto => 2             -- Tipo de movimento
                                    ,pr_cdbccxlt => vr_tab_cdbccxlt(idx) -- Codigo do banco/caixa.
                                    ,pr_tpdcampo => 11/*VLCONVEN*/       -- Tipo de campo
                                    ,pr_vldcampo => (case vr_tab_cdbccxlt(idx)
                                                     when '100' then vr_vlrconve
                                                     else 0
                                                     end)         -- Valor do campo
                                    ,pr_dscritic => pr_dscritic);

      IF pr_dscritic <> 'OK' THEN
        RAISE vr_exc_erro;
      END IF;

    END LOOP;--Fim loop bancos

    pr_dscritic := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
        NULL;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na FLXF0001.pc_grava_mvt_convenios: '||SQLerrm;
  END pc_grava_mvt_convenios;

  -- Procedure para gravar movimento financeiro referente aos saques no TAA das intercoop
  PROCEDURE pc_grava_mvt_saq_taa_intercoop (pr_cdcooper  IN INTEGER      -- Codigo da Cooperativa
                                           ,pr_cdagenci  IN INTEGER      -- Codigo da agencia
                                           ,pr_nrdcaixa  IN INTEGER      -- Numero da caixa
                                           ,pr_cdoperad  IN crapope.cdoperad%type     -- Codigo do operador
                                           ,pr_dtmvtolt  IN DATE         -- Data de movimento
                                           ,pr_nmdatela  IN VARCHAR2     -- Nome da tela
                                           ,pr_cdcoopex  IN INTEGER      -- Codigo da Cooperativa
                                           ,pr_tpdmovto  IN INTEGER      -- Tipo de movimento (1-Entrada 2-saida)
                                           ,pr_dscritic OUT VARCHAR2) AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_mvt_saq_taa_intercoop   Antigo: b1wgen0131.p/pi_rem_saq_taa_intercoop_f
    --                                                                   pi_rec_saq_taa_intercoop_f
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 22/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar movimento financeiro referente aos saques no TAA das intercoop
    --
    --   Atualizacao: 22/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --..........................................................................

    vr_exc_erro      EXCEPTION;
    vr_tab_cdbccxlt  gene0002.typ_split;
    vr_vlsaqtaa      NUMBER;
    vr_idx           varchar2(38);
    vr_tab_lancamentos  CADA0001.typ_tab_lancamentos;


  BEGIN

    vr_vlsaqtaa := 0;

    /* Rotina gera temptable com os movimentos de saques da cooperativa */
    CADA0001.pc_busca_movto_saque_cooper (pr_cdcooper  => (CASE pr_tpdmovto
                                                            WHEN 1 then 0
                                                            WHEN 2 THEN pr_cdcoopex
                                                           END)--> Código da cooperativo
                                         ,pr_cdcoptfn  => (CASE pr_tpdmovto
                                                            WHEN 1 then pr_cdcoopex
                                                            WHEN 2 THEN 0
                                                           END)  --> Codigo que identifica a Cooperativa do Cash.
                                         ,pr_dtmvtoin  => pr_dtmvtolt    --> Data de movimento inicial
                                         ,pr_dtmvtofi  => pr_dtmvtolt    --> Data de movimento final
                                         ,pr_cdtplanc  => 1              --> Codigo do tipo de lançamento
                                         ,pr_dscritic  => pr_dscritic    --> retorno da descrição de critica
                                         ,pr_tab_lancamentos => vr_tab_lancamentos);  --> Retorno da temptable com os lançamentos

    IF pr_dscritic is not null THEN
      RETURN;
    END IF;

    --Varrer temptable
    vr_idx := vr_tab_lancamentos.first;
    LOOP
      EXIT WHEN vr_idx is null;

      vr_vlsaqtaa := vr_vlsaqtaa + nvl(vr_tab_lancamentos(vr_idx).vlrtotal,0);

      --buscar proximo
      vr_idx := vr_tab_lancamentos.next(vr_idx);
    END LOOP;

    -- Ler os bancos e gravar os movimentos
    vr_tab_cdbccxlt := gene0002.fn_quebra_string('01,85,756,100',',');
    FOR idx IN vr_tab_cdbccxlt.first..vr_tab_cdbccxlt.last LOOP
      FLXF0001.pc_grava_movimentacao(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                                    ,pr_cdoperad => pr_cdoperad   -- Codigo do operador
                                    ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                                    ,pr_tpdmovto => pr_tpdmovto   -- Tipo de movimento
                                    ,pr_cdbccxlt => vr_tab_cdbccxlt(idx)     -- Codigo do banco/caixa.
                                    ,pr_tpdcampo => 9 /*VLSATAIT*/-- Tipo de campo
                                    ,pr_vldcampo => (case vr_tab_cdbccxlt(idx)
                                                     when '100' then vr_vlsaqtaa
                                                     else 0
                                                     end)         -- Valor do campo
                                    ,pr_dscritic => pr_dscritic);

      IF pr_dscritic <> 'OK' THEN
        RAISE vr_exc_erro;
      END IF;

    END LOOP;--Fim loop bancos

    pr_dscritic := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
        NULL;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na FLXF0001.pc_grava_mvt_saq_taa_intercoop: '||SQLerrm;
  END pc_grava_mvt_saq_taa_intercoop;

  -- Procedure para gravar movimento financeiro consolidado do saldo do dia anterior
  PROCEDURE pc_grav_consolida_sld_dia_ant ( pr_cdcooper  IN INTEGER      -- Codigo da Cooperativa
                                           ,pr_cdagenci  IN INTEGER      -- Codigo da agencia
                                           ,pr_nrdcaixa  IN INTEGER      -- Numero da caixa
                                           ,pr_cdoperad  IN crapope.cdoperad%type     -- Codigo do operador
                                           ,pr_dtmvtolt  IN DATE         -- Data de movimento
                                           ,pr_nmdatela  IN VARCHAR2     -- Nome da tela
                                           ,pr_dtmvtoan  IN DATE         -- Data de movimento anterior
                                           ,pr_cdcoopex  IN INTEGER      -- Codigo da Cooperativa
                                           ,pr_tab_erro IN OUT NOCOPY GENE0001.typ_tab_erro -- Tabela com os erros
                                           ,pr_dscritic OUT VARCHAR2) AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grav_consolida_sld_dia_ant     Antigo: b1wgen0131.p/pi_grava_consolidado_sld_dia_ant_f
    --
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 26/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar movimento financeiro consolidado do saldo do dia anterior
    --
    --   Atualizacao: 26/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --..........................................................................

    vr_exc_erro      EXCEPTION;
    vr_vlressal      NUMBER;

    vr_tab_saldos    EXTR0001.typ_tab_saldos;
    vr_tab_erro      GENE0001.typ_tab_erro;

    /* Busca dos dados da cooperativa */
    CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
      SELECT nrctactl
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

  BEGIN

    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop(pr_cdcooper => pr_cdcoopeX);
    FETCH cr_crapcop
     INTO rw_crapcop;
    -- Apenas fechar o cursor
    CLOSE cr_crapcop;

    vr_vlressal := 0;

    /* Procedure para obter saldos anteriores da conta-corrente */
    EXTR0001.pc_obtem_saldos_anteriores  (pr_cdcooper   => 3            -- Codigo da Cooperativa
                                         ,pr_cdagenci   => 0            -- Codigo da agencia
                                         ,pr_nrdcaixa   => 0            -- Numero da caixa
                                         ,pr_cdopecxa   => pr_cdoperad  -- Codigo do operador do caixa
                                         ,pr_nmdatela   => pr_nmdatela  -- Nome da tela
                                         ,pr_idorigem   => 1            -- Indicador de origem
                                         ,pr_nrdconta   => rw_crapcop.nrctactl -- Numero da conta do cooperado
                                         ,pr_idseqttl   => 1            -- Indicador de sequencial
                                         ,pr_dtmvtolt   => pr_dtmvtolt  -- Data de movimento
                                         ,pr_dtmvtoan   => pr_dtmvtoan  -- Data de movimento anterior
                                         ,pr_dtrefere   => pr_dtmvtoan  -- Data de referencia
                                         ,pr_flgerlog   => TRUE         -- Flag se deve gerar log
                                         ,pr_dscritic   => pr_dscritic  -- Retorno de critica
                                         ,pr_tab_saldos => vr_tab_saldos-- Retorna os saldos
                                         ,pr_tab_erro   => vr_tab_erro);

    -- Convertido conforme o progress ignorando o retorno da package SSPB0001,
    -- conforme passado por Diego Vincentini, será revisado todo a BO, caso necessario retornar o erro o codigo ja esta pronto
    /*IF pr_dscritic <> 'OK' THEN
      pr_dscritic := pr_tab_erro(1).dscritic;
    END IF; */
    vr_tab_erro.DELETE;
    pr_dscritic := null;

    --Buscar valores do saldo anterior
    IF vr_tab_saldos.count > 0 THEN
      vr_vlressal := nvl(vr_tab_saldos(vr_tab_saldos.first).vlstotal,0);
    ELSE
      vr_vlressal := 0;
    END IF;

    -- Gravar Informacoes do fluxo financeiro consolidado.
    FLXF0001.pc_grava_consolidado_singular
                                    (pr_cdcooper => pr_cdcoopex   -- Codigo da Cooperativa
                                    ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                                    ,pr_tpdcampo => 3             -- Tipo de campo
                                    ,pr_vldcampo => vr_vlressal   -- Valor do campo
                                    ,pr_dscritic => pr_dscritic); -- Descrição da critica

    IF pr_dscritic <> 'OK' THEN
      RETURN;
    END IF;

    pr_dscritic := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
        NULL;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na FLXF0001.pc_grav_consolida_sld_dia_ant: '||SQLerrm;
  END pc_grav_consolida_sld_dia_ant;

  -- Procedure para gravar movimento financeiro do fluxo de entrada
  PROCEDURE pc_grava_fluxo_entrada (pr_cdcooper  IN INTEGER      -- Codigo da Cooperativa
                                   ,pr_cdagenci  IN INTEGER      -- Codigo da agencia
                                   ,pr_nrdcaixa  IN INTEGER      -- Numero da caixa
                                   ,pr_cdoperad  IN crapope.cdoperad%type     -- Codigo do operador
                                   ,pr_dtmvtolt  IN DATE         -- Data de movimento
                                   ,pr_nmdatela  IN VARCHAR2     -- Nome da tela
                                   ,pr_dtmvtoan  IN DATE         -- Data de movimento anterior
                                   ,pr_cdcoopex  IN INTEGER      -- Codigo da Cooperativa
                                   ,pr_cdagefim  IN INTEGER      -- Codigo da agencia
                                   ,pr_nmrescop  IN VARCHAR2     -- Nome do responsavel
                                   ,pr_tab_erro OUT GENE0001.typ_tab_erro -- Tabela contendo os erros
                                   ,pr_dscritic OUT VARCHAR2) AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_fluxo_entrada   Antigo: b1wgen0131.p/grava-fluxo-entrada
    --
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 25/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar movimento financeiro do fluxo de entrada
    --
    --   Atualizacao: 25/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --..........................................................................

    vr_exc_erro      EXCEPTION;
    vr_dscritic      VARCHAR2(4000) ;
    vr_nrsequen      NUMBER;

  BEGIN
    vr_dscritic := null;

    -- Gravar movimento financeiro referente aos TEDs recebidos
    FLXF0001.pc_grava_mvt_ted(pr_cdcooper  => pr_cdcooper   -- Codigo da Cooperativa
                             ,pr_cdagenci  => pr_cdagenci   -- Codigo da agencia
                             ,pr_nrdcaixa  => pr_nrdcaixa   -- Numero da caixa
                             ,pr_cdoperad  => pr_cdoperad   -- Codigo do operador
                             ,pr_dtmvtolt  => pr_dtmvtolt   -- Data de movimento
                             ,pr_nmdatela  => pr_nmdatela   -- Nome da tela
                             ,pr_cdcoopex  => pr_cdcoopex   -- Codigo da Cooperativa
                             ,pr_tab_erro  => pr_tab_erro   -- Tabela com os erros
                             ,pr_dscritic  => vr_dscritic);

    IF vr_dscritic <> 'OK' THEN
      vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
      vr_dscritic := 'Calculo do SR TED nao foi efetuado - '||pr_nmrescop||'.';

      GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                            pr_cdagenci => pr_cdagenci,
                            pr_nrdcaixa => pr_nrdcaixa,
                            pr_nrsequen => vr_nrsequen,
                            pr_cdcritic => 0,
                            pr_dscritic => vr_dscritic,
                            pr_tab_erro => pr_tab_erro);
    END IF;

    -- Gravar movimento financeiro das movimentções de Cheques acolhidos para depositos nas contas dos associados.
    FLXF0001.pc_grava_mvt_cheque_nr( pr_cdcooper  => pr_cdcooper     -- Codigo da Cooperativa
                                    ,pr_cdagenci  => pr_cdagenci    -- Codigo da agencia
                                    ,pr_nrdcaixa  => pr_nrdcaixa    -- Numero da caixa
                                    ,pr_cdoperad  => pr_cdoperad    -- Codigo do operador
                                    ,pr_dtmvtolt  => pr_dtmvtolt     -- Data de movimento
                                    ,pr_nmdatela  => pr_nmdatela    -- Nome da tela
                                    ,pr_cdagefim  => pr_cdagefim   -- Codigo da agencia fim
                                    ,pr_cdcoopex  => pr_cdcoopex    -- Codigo da Cooperativa
                                    ,pr_dscritic  => vr_dscritic);

    IF vr_dscritic <> 'OK' THEN
      vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
      vr_dscritic := 'Calculo do NR CHEQUES nao foi efetuado - '||pr_nmrescop||'.';

      GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                            pr_cdagenci => pr_cdagenci,
                            pr_nrdcaixa => pr_nrdcaixa,
                            pr_nrsequen => vr_nrsequen,
                            pr_cdcritic => 0,
                            pr_dscritic => vr_dscritic,
                            pr_tab_erro => pr_tab_erro);
    END IF;

    -- Gravar movimento financeiro da devolucao de cheques ou taxa de devolucao.
    FLXF0001.pc_grava_mvt_dev_cheque_rem ( pr_cdcooper => pr_cdcooper     -- Codigo da Cooperativa
                                          ,pr_cdagenci => pr_cdagenci    -- Codigo da agencia
                                          ,pr_nrdcaixa => pr_nrdcaixa   -- Numero da caixa
                                          ,pr_cdoperad => pr_cdoperad   -- Codigo do operador
                                          ,pr_dtmvtolt => pr_dtmvtolt    -- Data de movimento
                                          ,pr_nmdatela => pr_nmdatela    -- Nome da tela
                                          ,pr_dtmvtoan => pr_dtmvtoan    -- Data movimento anterior
                                          ,pr_cdcoopex => pr_cdcoopex    -- Codigo da Cooperativa
                                          ,pr_dscritic => vr_dscritic);

    IF vr_dscritic <> 'OK' THEN
      vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
      vr_dscritic := 'Calculo da Devolucao Cheques Remet. nao foi efetuado - '||pr_nmrescop||'.';

      GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                            pr_cdagenci => pr_cdagenci,
                            pr_nrdcaixa => pr_nrdcaixa,
                            pr_nrsequen => vr_nrsequen,
                            pr_cdcritic => 0,
                            pr_dscritic => vr_dscritic,
                            pr_tab_erro => pr_tab_erro);
    END IF;

    -- gravar movimento financeiro das movimentções de INSS
    FLXF0001.pc_grava_mvt_inss (  pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                 ,pr_cdagenci => pr_cdagenci -- Codigo da agencia
                                 ,pr_nrdcaixa => pr_nrdcaixa -- Numero da caixa
                                 ,pr_cdoperad => pr_cdoperad -- Codigo do operador
                                 ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                                 ,pr_nmdatela => pr_nmdatela -- Nome da tela
                                 ,pr_cdcoopex => pr_cdcoopex -- Codigo da Cooperativa
                                 ,pr_dscritic => vr_dscritic);

    IF vr_dscritic <> 'OK' THEN
      vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
      vr_dscritic := 'Calculo do INSS nao foi efetuado - '||pr_nmrescop||'.';

      GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                            pr_cdagenci => pr_cdagenci,
                            pr_nrdcaixa => pr_nrdcaixa,
                            pr_nrsequen => vr_nrsequen,
                            pr_cdcritic => 0,
                            pr_dscritic => vr_dscritic,
                            pr_tab_erro => pr_tab_erro);
    END IF;

    -- gravar movimento financeiro dos Credito deposito/transferencia/tec salario intercooperativo
    FLXF0001.pc_mvt_transf_dep_intercoop (  pr_cdcooper  => pr_cdcooper    -- Codigo da Cooperativa
                                           ,pr_cdagenci  => pr_cdagenci     -- Codigo da agencia
                                           ,pr_nrdcaixa  => pr_nrdcaixa     -- Numero da caixa
                                           ,pr_cdoperad  => pr_cdoperad     -- Codigo do operador
                                           ,pr_dtmvtolt  => pr_dtmvtolt     -- Data de movimento
                                           ,pr_nmdatela  => pr_nmdatela     -- Nome da tela
                                           ,pr_cdcoopex  => pr_cdcoopex     -- Codigo da Cooperativa
                                           ,pr_tpdmovto  => 1     -- Tipo de movimento (1-Entrada 2-saida)
                                           ,pr_dscritic  => vr_dscritic);

    IF vr_dscritic <> 'OK' THEN
      vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
      vr_dscritic := 'Calculo da Transf/Depos Interc. nao foi efetuado - '||pr_nmrescop||'.';

      GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                            pr_cdagenci => pr_cdagenci,
                            pr_nrdcaixa => pr_nrdcaixa,
                            pr_nrsequen => vr_nrsequen,
                            pr_cdcritic => 0,
                            pr_dscritic => vr_dscritic,
                            pr_tab_erro => pr_tab_erro);
    END IF;

    -- gravar movimento financeiro dos titulos
    FLXF0001.pc_grava_mvt_titulos ( pr_cdcooper  => pr_cdcooper    -- Codigo da Cooperativa
                                   ,pr_cdagenci  => pr_cdagenci    -- Codigo da agencia
                                   ,pr_nrdcaixa  => pr_nrdcaixa    -- Numero da caixa
                                   ,pr_cdoperad  => pr_cdoperad    -- Codigo do operador
                                   ,pr_dtmvtolt  => pr_dtmvtolt    -- Data de movimento
                                   ,pr_nmdatela  => pr_nmdatela    -- Nome da tela
                                   ,pr_dtmvtoan  => pr_dtmvtoan    -- Data de movimento anterior
                                   ,pr_cdcoopex  => pr_cdcoopex    -- Codigo da Cooperativa
                                   ,pr_calcproj  => FALSE    -- Identificador se calcula projeção
                                   ,pr_tab_erro  => pr_tab_erro
                                   ,pr_dscritic  => vr_dscritic);

    IF vr_dscritic <> 'OK' THEN
      vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
      vr_dscritic := 'Nao foi possivel realizar o calculo do SR Titulos - '||pr_nmrescop||'.';

      GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                            pr_cdagenci => pr_cdagenci,
                            pr_nrdcaixa => pr_nrdcaixa,
                            pr_nrsequen => vr_nrsequen,
                            pr_cdcritic => 0,
                            pr_dscritic => vr_dscritic,
                            pr_tab_erro => pr_tab_erro);
    END IF;

    -- gravar movimento financeiro referente aos saques no TAA das intercoop
    FLXF0001.pc_grava_mvt_saq_taa_intercoop (pr_cdcooper  => pr_cdcooper     -- Codigo da Cooperativa
                                            ,pr_cdagenci  => pr_cdagenci     -- Codigo da agencia
                                            ,pr_nrdcaixa  => pr_nrdcaixa     -- Numero da caixa
                                            ,pr_cdoperad  => pr_cdoperad     -- Codigo do operador
                                            ,pr_dtmvtolt  => pr_dtmvtolt     -- Data de movimento
                                            ,pr_nmdatela  => pr_nmdatela     -- Nome da tela
                                            ,pr_cdcoopex  => pr_cdcoopex     -- Codigo da Cooperativa
                                            ,pr_tpdmovto  => 1               -- Tipo de movimento (1-Entrada 2-saida)
                                            ,pr_dscritic  => vr_dscritic);

    IF vr_dscritic <> 'OK' THEN
      vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
      vr_dscritic := 'Calculo do Saque TAA Interc. nao foi efetuado - '||pr_nmrescop||'.';

      GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                            pr_cdagenci => pr_cdagenci,
                            pr_nrdcaixa => pr_nrdcaixa,
                            pr_nrsequen => vr_nrsequen,
                            pr_cdcritic => 0,
                            pr_dscritic => vr_dscritic,
                            pr_tab_erro => pr_tab_erro);
    END IF;

    pr_dscritic := 'OK';

  END pc_grava_fluxo_entrada;

  -- Procedure para gravar movimento financeiro do fluxo de saida
  PROCEDURE pc_grava_fluxo_saida (pr_cdcooper  IN INTEGER      -- Codigo da Cooperativa
                                   ,pr_cdagenci  IN INTEGER      -- Codigo da agencia
                                   ,pr_nrdcaixa  IN INTEGER      -- Numero da caixa
                                   ,pr_cdoperad  IN crapope.cdoperad%type     -- Codigo do operador
                                   ,pr_dtmvtolt  IN DATE         -- Data de movimento
                                   ,pr_nmdatela  IN VARCHAR2     -- Nome da tela
                                   ,pr_dtmvtoan  IN DATE         -- Data de movimento anterior
                                   ,pr_cdcoopex  IN INTEGER      -- Codigo da Cooperativa
                                   ,pr_cdagefim  IN INTEGER      -- Codigo da agencia
                                   ,pr_nmrescop  IN VARCHAR2     -- Nome do responsavel
                                   ,pr_tab_erro OUT GENE0001.typ_tab_erro -- Tabela contendo os erros
                                   ,pr_dscritic OUT VARCHAR2) AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_fluxo_saida   Antigo: b1wgen0131.p/grava-fluxo-saida
    --
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 26/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar movimento financeiro do fluxo de saida
    --
    --   Atualizacao: 26/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --..........................................................................

    vr_exc_erro      EXCEPTION;
    vr_dscritic      VARCHAR2(4000) ;
    vr_nrsequen      NUMBER;

  BEGIN

    vr_dscritic := null;

    -- Procedure para gravar movimento financeiro dos conveniados
    FLXF0001.pc_grava_mvt_convenios(  pr_cdcooper  => pr_cdcooper      -- Codigo da Cooperativa
                                     ,pr_cdagenci  => pr_cdagenci    -- Codigo da agencia
                                     ,pr_nrdcaixa  => pr_nrdcaixa    -- Numero da caixa
                                     ,pr_cdoperad  => pr_cdoperad    -- Codigo do operador
                                     ,pr_dtmvtolt  => pr_dtmvtolt    -- Data de movimento
                                     ,pr_nmdatela  => pr_nmdatela    -- Nome da tela
                                     ,pr_cdcoopex  => pr_cdcoopex    -- Codigo da Cooperativa
                                     ,pr_dscritic  => vr_dscritic);

    IF vr_dscritic <> 'OK' THEN
      vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
      vr_dscritic := 'Calculo do convenio nao foi efetuado - '||pr_nmrescop||'.';

      GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                            pr_cdagenci => pr_cdagenci,
                            pr_nrdcaixa => pr_nrdcaixa,
                            pr_nrsequen => vr_nrsequen,
                            pr_cdcritic => 0,
                            pr_dscritic => vr_dscritic,
                            pr_tab_erro => pr_tab_erro);
    END IF;

    -- Procedure para gravar movimento financeiro das transferencias DOCs
    FLXF0001.pc_grava_mvt_doc_nr( pr_cdcooper => pr_cdcooper     -- Codigo da Cooperativa
                                 ,pr_cdagenci => pr_cdagenci     -- Codigo da agencia
                                 ,pr_nrdcaixa => pr_nrdcaixa     -- Numero da caixa
                                 ,pr_cdoperad => pr_cdoperad     -- Codigo do operador
                                 ,pr_dtmvtolt => pr_dtmvtolt     -- Data de movimento
                                 ,pr_nmdatela => pr_nmdatela     -- Nome da tela
                                 ,pr_cdagefim => pr_cdagefim     -- Codigo da agencia final
                                 ,pr_cdcoopex => pr_cdcoopex     -- Codigo da Cooperativa
                                 ,pr_dscritic => vr_dscritic);

    IF vr_dscritic <> 'OK' THEN
      vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
      vr_dscritic := 'Calculo do NR DOC nao foi efetuado - '||pr_nmrescop||'.';

      GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                            pr_cdagenci => pr_cdagenci,
                            pr_nrdcaixa => pr_nrdcaixa,
                            pr_nrsequen => vr_nrsequen,
                            pr_cdcritic => 0,
                            pr_dscritic => vr_dscritic,
                            pr_tab_erro => pr_tab_erro);
    END IF;

    -- Gravar movimento financeiro dos TEDs e TECs
    FLXF0001.pc_grava_mvt_tedtec_nr( pr_cdcooper => pr_cdcooper      -- Codigo da Cooperativa
                                    ,pr_cdagenci => pr_cdagenci     -- Codigo da agencia
                                    ,pr_nrdcaixa => pr_nrdcaixa     -- Numero da caixa
                                    ,pr_cdoperad => pr_cdoperad     -- Codigo do operador
                                    ,pr_dtmvtolt => pr_dtmvtolt     -- Data de movimento
                                    ,pr_nmdatela => pr_nmdatela     -- Nome da tela
                                    ,pr_cdagefim => pr_cdagefim     -- Codigo da agencia final
                                    ,pr_cdcoopex => pr_cdcoopex     -- Codigo da Cooperativa
                                    ,pr_dscritic => vr_dscritic);

    IF vr_dscritic <> 'OK' THEN
      vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
      vr_dscritic := 'Calculo do NR TED nao foi efetuado - '||pr_nmrescop||'.';

      GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                            pr_cdagenci => pr_cdagenci,
                            pr_nrdcaixa => pr_nrdcaixa,
                            pr_nrsequen => vr_nrsequen,
                            pr_cdcritic => 0,
                            pr_dscritic => vr_dscritic,
                            pr_tab_erro => pr_tab_erro);
    END IF;

    -- Gravar movimento financeiro dos NR titulos
    FLXF0001.pc_grava_mvt_titulos_nr( pr_cdcooper => pr_cdcooper     -- Codigo da Cooperativa
                                     ,pr_cdagenci => pr_cdagenci     -- Codigo da agencia
                                     ,pr_nrdcaixa => pr_nrdcaixa     -- Numero da caixa
                                     ,pr_cdoperad => pr_cdoperad     -- Codigo do operador
                                     ,pr_dtmvtolt => pr_dtmvtolt     -- Data de movimento
                                     ,pr_nmdatela => pr_nmdatela     -- Nome da tela
                                     ,pr_cdagefim => pr_cdagefim     -- Codigo da agencia final
                                     ,pr_cdcoopex => pr_cdcoopex     -- Codigo da Cooperativa
                                     ,pr_dtmvtoan => pr_dtmvtoan     -- Data de movimento anterior
                                     ,pr_dscritic => vr_dscritic);

    IF vr_dscritic <> 'OK' THEN
      vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
      vr_dscritic := 'Calculo do NR Titulos nao foi efetuado - '||pr_nmrescop||'.';

      GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                            pr_cdagenci => pr_cdagenci,
                            pr_nrdcaixa => pr_nrdcaixa,
                            pr_nrsequen => vr_nrsequen,
                            pr_cdcritic => 0,
                            pr_dscritic => vr_dscritic,
                            pr_tab_erro => pr_tab_erro);
    END IF;

    -- Gravar movimento financeiro das devoluções de cheques de outros bancos
    FLXF0001.pc_grava_mvt_dev_cheque_rec( pr_cdcooper => pr_cdcooper      -- Codigo da Cooperativa
                                         ,pr_cdagenci => pr_cdagenci     -- Codigo da agencia
                                         ,pr_nrdcaixa => pr_nrdcaixa     -- Numero da caixa
                                         ,pr_cdoperad => pr_cdoperad     -- Codigo do operador
                                         ,pr_dtmvtolt => pr_dtmvtolt     -- Data de movimento
                                         ,pr_nmdatela => pr_nmdatela     -- Nome da tela
                                         ,pr_dtmvtoan => pr_dtmvtoan     -- Data de movimento anterior
                                         ,pr_cdcoopex => pr_cdcoopex     -- Codigo da Cooperativa
                                         ,pr_cdagefim => pr_cdagefim     -- Codigo da agencia final
                                         ,pr_tab_erro => pr_tab_erro -- Tabela contendo os erros
                                         ,pr_dscritic => vr_dscritic);

    IF vr_dscritic <> 'OK' THEN
      vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
      vr_dscritic := 'Calculo de devolucao de cheques recebidos nao foi efetuado - '||pr_nmrescop||'.';

      GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                            pr_cdagenci => pr_cdagenci,
                            pr_nrdcaixa => pr_nrdcaixa,
                            pr_nrsequen => vr_nrsequen,
                            pr_cdcritic => 0,
                            pr_dscritic => vr_dscritic,
                            pr_tab_erro => pr_tab_erro);
    END IF;

    -- Procedure para gravar movimento financeiro das Guias de recolhimento da Previdencia Social
    FLXF0001.pc_grava_mvt_grps( pr_cdcooper => pr_cdcooper      -- Codigo da Cooperativa
                               ,pr_cdagenci => pr_cdagenci      -- Codigo da agencia
                               ,pr_nrdcaixa => pr_nrdcaixa     -- Numero da caixa
                               ,pr_cdoperad => pr_cdoperad     -- Codigo do operador
                               ,pr_dtmvtolt => pr_dtmvtolt     -- Data de movimento
                               ,pr_nmdatela => pr_nmdatela     -- Nome da tela
                               ,pr_cdcoopex => pr_cdcoopex      -- Codigo da Cooperativa
                               ,pr_dscritic => vr_dscritic);

    IF vr_dscritic <> 'OK' THEN
      vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
      vr_dscritic := 'Calculo do GPS nao foi efetuado - '||pr_nmrescop||'.';

      GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                            pr_cdagenci => pr_cdagenci,
                            pr_nrdcaixa => pr_nrdcaixa,
                            pr_nrsequen => vr_nrsequen,
                            pr_cdcritic => 0,
                            pr_dscritic => vr_dscritic,
                            pr_tab_erro => pr_tab_erro);
    END IF;

    -- Gravar movimento financeiro dos Credito deposito/transferencia/tec salario intercooperativo
    FLXF0001.pc_mvt_transf_dep_intercoop( pr_cdcooper => pr_cdcooper     -- Codigo da Cooperativa
                                         ,pr_cdagenci => pr_cdagenci     -- Codigo da agencia
                                         ,pr_nrdcaixa => pr_nrdcaixa     -- Numero da caixa
                                         ,pr_cdoperad => pr_cdoperad     -- Codigo do operador
                                         ,pr_dtmvtolt => pr_dtmvtolt     -- Data de movimento
                                         ,pr_nmdatela => pr_nmdatela     -- Nome da tela
                                         ,pr_cdcoopex => pr_cdcoopex     -- Codigo da Cooperativa
                                         ,pr_tpdmovto => 2               -- Tipo de movimento (1-Entrada 2-saida)
                                         ,pr_dscritic => vr_dscritic);

    IF vr_dscritic <> 'OK' THEN
      vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
      vr_dscritic := 'Calculo das Transf/Depos Interc. nao foi efetuado - '||pr_nmrescop||'.';

      GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                            pr_cdagenci => pr_cdagenci,
                            pr_nrdcaixa => pr_nrdcaixa,
                            pr_nrsequen => vr_nrsequen,
                            pr_cdcritic => 0,
                            pr_dscritic => vr_dscritic,
                            pr_tab_erro => pr_tab_erro);
    END IF;

    -- Gravar movimento financeiro referente aos saques no TAA das intercoop
    FLXF0001.pc_grava_mvt_saq_taa_intercoop(pr_cdcooper => pr_cdcooper     -- Codigo da Cooperativa
                                           ,pr_cdagenci => pr_cdagenci     -- Codigo da agencia
                                           ,pr_nrdcaixa => pr_nrdcaixa     -- Numero da caixa
                                           ,pr_cdoperad => pr_cdoperad     -- Codigo do operador
                                           ,pr_dtmvtolt => pr_dtmvtolt     -- Data de movimento
                                           ,pr_nmdatela => pr_nmdatela     -- Nome da tela
                                           ,pr_cdcoopex => pr_cdcoopex     -- Codigo da Cooperativa
                                           ,pr_tpdmovto => 2               -- Tipo de movimento (1-Entrada 2-saida)
                                           ,pr_dscritic => vr_dscritic);


    IF vr_dscritic <> 'OK' THEN
      vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
      vr_dscritic := 'Calculo do Saque TAA Interc. nao foi efetuado - '||pr_nmrescop||'.';

      GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                            pr_cdagenci => pr_cdagenci,
                            pr_nrdcaixa => pr_nrdcaixa,
                            pr_nrsequen => vr_nrsequen,
                            pr_cdcritic => 0,
                            pr_dscritic => vr_dscritic,
                            pr_tab_erro => pr_tab_erro);
    END IF;

    -- Gravar movimento financeiro das faturas do bradesco
    FLXF0001.pc_gera_mvt_fatura_bradesco( pr_cdcooper => pr_cdcooper     -- Codigo da Cooperativa
                                         ,pr_cdagenci => pr_cdagenci     -- Codigo da agencia
                                         ,pr_nrdcaixa => pr_nrdcaixa     -- Numero da caixa
                                         ,pr_cdoperad => pr_cdoperad     -- Codigo do operador
                                         ,pr_dtmvtolt => pr_dtmvtolt     -- Data de movimento
                                         ,pr_nmdatela => pr_nmdatela     -- Nome da tela
                                         ,pr_cdcoopex => pr_cdcoopex     -- Codigo da Cooperativa
                                         ,pr_dscritic => vr_dscritic);

    IF vr_dscritic <> 'OK' THEN
      vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
      vr_dscritic := 'Calculo das faturas do cartão Bradesco nao foi efetuado - '||pr_nmrescop||'.';

      GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                            pr_cdagenci => pr_cdagenci,
                            pr_nrdcaixa => pr_nrdcaixa,
                            pr_nrsequen => vr_nrsequen,
                            pr_cdcritic => 0,
                            pr_dscritic => vr_dscritic,
                            pr_tab_erro => pr_tab_erro);
    END IF;

    pr_dscritic := 'OK';

  END pc_grava_fluxo_saida;

  -- Procedure para gravar Informacoes do fluxo financeiro consolidado de entrada ou saida
  PROCEDURE pc_gera_consolidado_singular ( pr_cdcooper IN INTEGER      -- Codigo da Cooperativa
                                           ,pr_cdagenci IN INTEGER      -- Codigo da agencia
                                           ,pr_nrdcaixa IN INTEGER      -- Numero da caixa
                                           ,pr_cdoperad IN crapope.cdoperad%type     -- Codigo do operador
                                           ,pr_dtmvtolt IN DATE         -- Data de movimento
                                           ,pr_nmdatela IN VARCHAR2     -- Nome da tela
                                           ,pr_cdcoopex IN INTEGER      -- Codigo da Cooperativa
                                           ,pr_tpdmovto IN INTEGER      -- Tipo de movimento (1-Entrada 2-saida)
                                           ,pr_dscritic      OUT VARCHAR2) AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_gera_consolidado_singular          Antigo: b1wgen0131.p/pi_grava_consolidado_singular_saida_f
    --                                                                         pi_grava_consolidado_singular_entrada_f
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 20/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar Informacoes do fluxo financeiro consolidado de entrada ou saida
    --
    --   Atualizacao: 20/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --..........................................................................

    vr_vlresult      NUMBER := 0;
    vr_tab_ffin_mvto_sing FLXF0001.typ_tab_ffin_mvto_sing;


  BEGIN
    -- Buscar informações do fluxo financeiro
    vr_tab_ffin_mvto_sing := FLXF0001.fn_busca_dados_flx_singular(pr_cdcooper => pr_cdcooper, -- codigo da cooperativa
                                                                  pr_dtmvtolx => pr_dtmvtolt, -- Data de movimento
                                                                  pr_tpdmovto => pr_tpdmovto);-- Tipo de movimento

    -- Somar valores
    IF vr_tab_ffin_mvto_sing.COUNT > 0 THEN
      vr_vlresult := NVL(vr_tab_ffin_mvto_sing('085').vlttcrdb,0) +
                     NVL(vr_tab_ffin_mvto_sing('001').vlttcrdb,0) +
                     NVL(vr_tab_ffin_mvto_sing('756').vlttcrdb,0) +
                     NVL(vr_tab_ffin_mvto_sing('100').vlttcrdb,0);

    END IF;

    --Gravar valores agrupados
    FLXF0001.pc_grava_consolidado_singular
                                    (pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                                    ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                                    ,pr_tpdcampo => pr_tpdmovto   -- Tipo de campo
                                    ,pr_vldcampo => vr_vlresult   -- Valor do campo
                                    ,pr_dscritic => pr_dscritic); -- Descrição da critica

    IF pr_dscritic <> 'OK' THEN
      RETURN;
    END IF;

    pr_dscritic := 'OK';

  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na FLXF0001.pc_gera_consolidado_singular: '||SQLerrm;
  END pc_gera_consolidado_singular;

  -- Procedure para gravar movimento do fluxo financeiro
  PROCEDURE pc_grava_fluxo_financeiro ( pr_cdcooper  IN INTEGER      -- Codigo da Cooperativa
                                       ,pr_cdagenci  IN INTEGER      -- Codigo da agencia
                                       ,pr_nrdcaixa  IN INTEGER      -- Numero da caixa
                                       ,pr_cdoperad  IN crapope.cdoperad%type     -- Codigo do operador
                                       ,pr_dtmvtolt  IN DATE         -- Data de movimento
                                       ,pr_nmdatela  IN VARCHAR2     -- Nome da tela
                                       ,pr_cdcoopex  IN INTEGER      -- Codigo da Cooperativa
                                       ,pr_dtmvtoan  IN DATE         -- Data de movimento anterior
                                       ,pr_cdagefim  IN INTEGER      -- Codigo da agencia
                                       ,pr_tab_erro OUT GENE0001.typ_tab_erro -- Tabela contendo os erros
                                       ,pr_dscritic OUT VARCHAR2) AS -- Descrição da critica

    -- .........................................................................
    --
    --  Programa : pc_grava_fluxo_financeiro   Antigo: b1wgen0131.p/grava-fluxo-financeiro
    --
    --
    --  Sistema  : Cred
    --  Sigla    : FLXF0001
    --  Autor    : Odirlei Busana
    --  Data     : novembro/2013.                   Ultima atualizacao: 26/11/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Gravar movimento do fluxo financeiro
    --
    --   Atualizacao: 26/11/2013 - Conversao Progress => Oracle (Odirlei-AMcom)
    --..........................................................................

    vr_exc_erro      EXCEPTION;
    vr_dscritic      VARCHAR2(4000) ;
    vr_nrsequen      NUMBER;
    vr_cdcooper      crapcop.cdcooper%type;


    /* Busca dos dados da cooperativa */
    CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE,
                      pr_cdcoopex IN craptab.cdcooper%TYPE ) IS
      SELECT cdcooper,
             nmrescop
        FROM crapcop cop
              -- Se for diferente de 3, deve buscar apenas a cdcooper informada no pr_cdcooper
       WHERE (pr_cdcooper <> 3 AND cop.cdcooper = pr_cdcooper)
             --Ou se for a cooperativa 3 e cooperx for zero, trazer todos diferente do 3
             --senão trazer somente a informada na cooperx
          OR (pr_cdcooper = 3 AND
              ((pr_cdcoopex = 0 AND cop.cdcooper <> 3) OR
              (pr_cdcoopex <> 0 AND cop.cdcooper = pr_cdcoopex))
              )
              ;

  BEGIN

    -- Buscar cooperativas, se for cooperativa 3-cecred, deve buscar totas as cooperativas,
    -- exeto a cooperativa 3 ou somente a cooperativa informada no cdcooperx
    --  Ou se for diferente trazer apenas a informada
    FOR rw_crapcop IN cr_crapcop(pr_cdcooper => pr_cdcooper,
                                 pr_cdcoopex => pr_cdcoopex) LOOP

      vr_cdcooper := 0;
      IF pr_cdcooper = 3 THEN
        IF pr_cdcoopex = 0 THEN
          vr_cdcooper := rw_crapcop.cdcooper;
        ELSE
          vr_cdcooper := pr_cdcoopex;
        END IF;
      ELSE
        vr_cdcooper := pr_cdcooper;
      END IF;

      -- Gravar movimento financeiro do fluxo de entrada
      FLXF0001.pc_grava_fluxo_entrada ( pr_cdcooper => pr_cdcooper     -- Codigo da Cooperativa
                                       ,pr_cdagenci => pr_cdagenci     -- Codigo da agencia
                                       ,pr_nrdcaixa => pr_nrdcaixa     -- Numero da caixa
                                       ,pr_cdoperad => pr_cdoperad     -- Codigo do operador
                                       ,pr_dtmvtolt => pr_dtmvtolt     -- Data de movimento
                                       ,pr_nmdatela => pr_nmdatela     -- Nome da tela
                                       ,pr_dtmvtoan => pr_dtmvtoan     -- Data de movimento anterior
                                       ,pr_cdcoopex => vr_cdcooper      -- Codigo da Cooperativa
                                       ,pr_cdagefim => pr_cdagefim     -- Codigo da agencia
                                       ,pr_nmrescop => rw_crapcop.nmrescop     -- Nome do responsavel
                                       ,pr_tab_erro => pr_tab_erro -- Tabela contendo os erros
                                       ,pr_dscritic => vr_dscritic);

      IF vr_dscritic <> 'OK' THEN
        vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
        vr_dscritic := 'Calculo do fluxo de entrada nao foi efetuado - '||rw_crapcop.nmrescop||'.';

        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                              pr_cdagenci => pr_cdagenci,
                              pr_nrdcaixa => pr_nrdcaixa,
                              pr_nrsequen => vr_nrsequen,
                              pr_cdcritic => 0,
                              pr_dscritic => vr_dscritic,
                              pr_tab_erro => pr_tab_erro);
      END IF;

      -- Gravar movimento financeiro do fluxo de saida
      FLXF0001.pc_grava_fluxo_saida ( pr_cdcooper => pr_cdcooper     -- Codigo da Cooperativa
                                     ,pr_cdagenci => pr_cdagenci     -- Codigo da agencia
                                     ,pr_nrdcaixa => pr_nrdcaixa     -- Numero da caixa
                                     ,pr_cdoperad => pr_cdoperad     -- Codigo do operador
                                     ,pr_dtmvtolt => pr_dtmvtolt     -- Data de movimento
                                     ,pr_nmdatela => pr_nmdatela     -- Nome da tela
                                     ,pr_dtmvtoan => pr_dtmvtoan     -- Data de movimento anterior
                                     ,pr_cdcoopex => vr_cdcooper      -- Codigo da Cooperativa
                                     ,pr_cdagefim => pr_cdagefim     -- Codigo da agencia
                                     ,pr_nmrescop => rw_crapcop.nmrescop     -- Nome do responsavel
                                     ,pr_tab_erro => pr_tab_erro -- Tabela contendo os erros
                                     ,pr_dscritic => vr_dscritic);

      IF vr_dscritic <> 'OK' THEN
        vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
        vr_dscritic := 'Calculo do fluxo de saida nao foi efetuado - '||rw_crapcop.nmrescop||'.';

        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                              pr_cdagenci => pr_cdagenci,
                              pr_nrdcaixa => pr_nrdcaixa,
                              pr_nrsequen => vr_nrsequen,
                              pr_cdcritic => 0,
                              pr_dscritic => vr_dscritic,
                              pr_tab_erro => pr_tab_erro);
      END IF;

      -- Gravar Informacoes do fluxo financeiro consolidado de entrada
      FLXF0001.pc_gera_consolidado_singular( pr_cdcooper => pr_cdcooper     -- Codigo da Cooperativa

                                             ,pr_cdagenci => pr_cdagenci     -- Codigo da agencia
                                             ,pr_nrdcaixa => pr_nrdcaixa     -- Numero da caixa
                                             ,pr_cdoperad => pr_cdoperad     -- Codigo do operador
                                             ,pr_dtmvtolt => pr_dtmvtolt     -- Data de movimento
                                             ,pr_nmdatela => pr_nmdatela     -- Nome da tela
                                             ,pr_cdcoopex => vr_cdcooper     -- Codigo da Cooperativa
                                             ,pr_tpdmovto => 1               -- Tipo de movimento (1-Entrada 2-saida)
                                             ,pr_dscritic => vr_dscritic);

      IF vr_dscritic <> 'OK' THEN
        vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
        vr_dscritic := 'Calculo das entradas nao foi efetuado - '||rw_crapcop.nmrescop||'.';

        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                              pr_cdagenci => pr_cdagenci,
                              pr_nrdcaixa => pr_nrdcaixa,
                              pr_nrsequen => vr_nrsequen,
                              pr_cdcritic => 0,
                              pr_dscritic => vr_dscritic,
                              pr_tab_erro => pr_tab_erro);
      END IF;

      -- Gravar Informacoes do fluxo financeiro consolidado de saida
      FLXF0001.pc_gera_consolidado_singular( pr_cdcooper => pr_cdcooper     -- Codigo da Cooperativa
                                             ,pr_cdagenci => pr_cdagenci     -- Codigo da agencia
                                             ,pr_nrdcaixa => pr_nrdcaixa     -- Numero da caixa
                                             ,pr_cdoperad => pr_cdoperad     -- Codigo do operador
                                             ,pr_dtmvtolt => pr_dtmvtolt     -- Data de movimento
                                             ,pr_nmdatela => pr_nmdatela     -- Nome da tela
                                             ,pr_cdcoopex => vr_cdcooper     -- Codigo da Cooperativa
                                             ,pr_tpdmovto => 2               -- Tipo de movimento (1-Entrada 2-saida)
                                             ,pr_dscritic => vr_dscritic);

      IF vr_dscritic <> 'OK' THEN
        vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
        vr_dscritic := 'Calculo das saidas nao foi efetuado - '||rw_crapcop.nmrescop||'.';

        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                              pr_cdagenci => pr_cdagenci,
                              pr_nrdcaixa => pr_nrdcaixa,
                              pr_nrsequen => vr_nrsequen,
                              pr_cdcritic => 0,
                              pr_dscritic => vr_dscritic,
                              pr_tab_erro => pr_tab_erro);
      END IF;

      -- Gravar movimento financeiro consolidado do saldo do dia anterior
      FLXF0001.pc_grav_consolida_sld_dia_ant( pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                                             ,pr_cdagenci => pr_cdagenci   -- Codigo da agencia
                                             ,pr_nrdcaixa => pr_nrdcaixa   -- Numero da caixa
                                             ,pr_cdoperad => pr_cdoperad   -- Codigo do operador
                                             ,pr_dtmvtolt => pr_dtmvtolt   -- Data de movimento
                                             ,pr_nmdatela => pr_nmdatela   -- Nome da tela
                                             ,pr_dtmvtoan => pr_dtmvtoan   -- Data de movimento anterior
                                             ,pr_cdcoopex => vr_cdcooper   -- Codigo da Cooperativa
                                             ,pr_tab_erro => pr_tab_erro   -- Tabela com os erros
                                             ,pr_dscritic => pr_dscritic);

      IF vr_dscritic <> 'OK' THEN
        vr_nrsequen := NVL(pr_tab_erro.COUNT,0)+ 1;
        vr_dscritic := 'Calculo do saldo do dia anterior nao foi efetuado - '||rw_crapcop.nmrescop||'.';

        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                              pr_cdagenci => pr_cdagenci,
                              pr_nrdcaixa => pr_nrdcaixa,
                              pr_nrsequen => vr_nrsequen,
                              pr_cdcritic => 0,
                              pr_dscritic => vr_dscritic,
                              pr_tab_erro => pr_tab_erro);
      END IF;
    END LOOP;

    pr_dscritic := 'OK';

  END pc_grava_fluxo_financeiro;

END FLXF0001;
/
