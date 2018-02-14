CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS531_1 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                                ,pr_idparale IN crappar.idparale%TYPE   --> ID do paralelo em execução
                                                ,pr_idprogra IN crappar.idprogra%TYPE   --> ID sequencia em execução
                                                ,pr_nmarquiv IN VARCHAR2                --> Nome do arquivo em leitura
                                                ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                                ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
BEGIN
/* ............................................................................

   Programa: PC_CRPS531_1                       Antigo: Fontes/crps531_1.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Diego
   Data    : Setembro/2009.                     Ultima atualizacao: 31/01/2018

   Dados referentes ao programa: Fonte extraido e adaptado para execucao em
                                 paralelo. Fonte original crps531.p.

   Frequencia : Sempre que for chamado.
   Objetivo   : Integrar mensagens(TED/TEC) recebidas via SPB.

   Observacao : Quando o processo diario ainda estiver executando na cooperativa
                de destino, a mensagem nao sera processada e permanecera no
                diretorio /integra ate que finalize o processo.

   Alteracoes: 14/02/2012 - Tratar PAG0143R2 que ira substituir a PAG0106R2
                            (Diego).

               27/02/2012 - Tratamento novo catalogo de mensagens V. 3.05,
                            eliminadas mensagens STR0009R2, PAG0109R2,
                            STR0009R1, PAG0109R1, PAG0106R2 (Gabriel).

               10/04/2012 - Chamada da procedure grava-log-ted para os tipos de
                            mensagens: ENVIADO OK, ENVIADO NOK, REJEITADA OK,
                                       RECEBIDA OK, RECEBIDA NOK. (Fabricio)

               08/05/2012 - Incluida procedure processa_conta_transferida
                            para processamento doc/ted de conta transferida
                            entre cooperativas (Tiago).

               08/06/2012 - Gravar devolucao com numero de documento da mensagem
                            original enviada pelo Legado. Na Rejeicao ja estava
                            fazendo isto (Diego).

               29/06/2012 - Ajuste Log TED (David).

               30/07/2012 - Inclusão de novos parametros na procedure grava-log-ted
                            campos: cdagenci = 0, nrdcaixa = 0,
                            cdoperad = "1" (Lucas R.).

               04/12/2012 - Incluir origem da mensagem no numero de controle
                            (Diego).

               28/01/2013 - Corrigido aux_nrdocmto para pegar ultimos 8
                            caracteres do Numero de Controle das mensagens
                            recebidas de outros bancos (Diego).

               18/03/2013 - Tratamento para recebimento da STR0026R2 - VR Boleto.
                            (Fabricio)

               04/07/2013 - Ajustes na rotina de recebimento STR0026R2 referente
                            ao VR Boleto. (Rafael)

               01/11/2013 - Aumento FORMAT campo aux_idprogra "zzzz9" (Diego).

               12/12/2013 - Tratamento na procedure processa_conta_transferida
                            para contas migradas Acredi >> Viacredi; geracao
                            de arquivo. (Fabricio)

               07/01/2014 - Ajustado find da crapcob para utilizar indice (Daniel).

               13/01/2014 - Alteracao referente a integracao Progress X
                            Dataserver Oracle
                            Inclusao do VALIDATE ( Andre Euzebio / SUPERO)

               28/01/2014 - Alterado para utilizar b-crapdat.dtmvtolt
                            na geracao do arquivo de teds migradas. (Fabricio)

               18/02/2014 - Alterado na procedure gera_logspb_transferida para
                            passar como conta do credito na chamada da
                            procedure grava-log-ted, o numero da conta na
                            cooperativa destino. (Fabricio)

               21/03/2014 - Alterado o Format das contas migradas na procedure
                            gera_logspb_transferida. (Reinert)

               20/05/2014 - Retirado criacao do registro de lote (fara apenas
                            leitura e atualizacao do registro criado
                            anteriormente; pelo crps531).
                            (Chamado 158826) - (Fabricio)

               26/06/2014 - Desprezar estorno de TED de repasse de convenios.
                            (Fabricio - PRJ 019).

               23/10/2014 - Incluir a hora no lancamento da craplcm
                            (Jonata-RKAM).

               05/11/2014 - Mover mensagem para o /salvar e deletar objetos xml
                            criados, quando estorno de TED de repasse de
                            convenios (STR0007/STR0020). (Fabricio)

               14/11/2014 - Alteração na procedure processa_conta_transferida
                            para tratar a incormporação da CREDIMILSUL e
                            ACREDI (Vanessa) SD SD223543

               17/11/2014 - Alteração do E-mail destino dos alertas de
                            pagamentos de VR Boleto  (Kelvin)

               03/12/2014 - Nao verificar data do sistema na cooperativa antiga
                            que foi incorporada (Diego).

               08/01/2015 - Tratado para devolver mensagens que apresentem
                            alguma inconsistencia, destinadas a coop. antiga
                            incorporada. Estavam sendo geradas mensagens de
                            devolucao ainda pela coop. antiga, porem as mesmas
                            nao eram integradas na Cabine, pois eram geradas
                            com a data da coop. antiga. A Cabine integra somente
                            mensagens do dia atual. Este tratamento eh valido
                            enquanto a coop. antiga permanecer ativa no nosso
                            sistema(crapcop.flgativo = TRUE) (Diego).

               19/01/2015 - Adição dos parâmetros "arq" e "coop" na chamada do
                            fonte mqcecred_envia.pl. (Dionathan)
               13/04/2015 - Inclusão parametro na  procedure proc_opera_st para
                            tratar as alterações solicitadas no SD271603 FDR041
                            (Vanessa)

               26/05/2015 - Alterado para tratar mensagens de portabilidade de
                            credito. (Reinert).

               10/07/2015 - Validar se a cooperativa esta ativa no sistema,
                            crapcop.flgativo (Diego).

               21/07/2015 - Alterações relacionadas ao Projeto Nova FOLHAIB (Vanessa).

               11/08/2015 - Ajustado proc. verifica_conta, adicionado verificacao
                            caso conta seja migrada, fazer validacao da conta
                            nova. (Jorge/Rodrigo) - SD 308188

               18/09/2015 - Tratamento na procedure processa_conta_transferida
                            para contas migradas Viacredi >> Alto Vale
                            (Douglas - Chamado 288683)

               22/10/2015 - Adicionado verificacao do cpf do TED com o cpf da
                            conta em proc. verifica_conta.
                            (Jorge/Elton) - SD 338096

               29/10/2015 - Inclusao de verificacao estado de crise.
                            (Jaison/Andrino)

               10/12/2015 - Ajustado a rotina importa_xml para substituir
                            o caracter especial chr(216) e chr(248) por "O"
                            pois caracter invalida o xml, fazendo que as informacoes
                            depois dessa tag sejam ignoradas.
                            SD347591 (Odirlei-AMcom)

               08/01/2015 - Alterado procedimento pc_solicita_email para chamar
                            a rotina convertida na b1wgen0011.p
                            SD356863 (Odirlei-AMcom)

               02/02/2016 - Adicionar tratamento para nao permitir realizar
                            TED/TEC das contas migradas ACREDI >> VIACREDI
                            (Douglas - Chamado 366322)

               11/05/2016 - Adicionar tratamento para nao permitir realizar
                            TED/TEC das contas migradas VIACREDI >> ALTO VALE
                            (Douglas - Chamado 406267)

               30/05/2016 - Adicionar tipo de pessoa juridica na pesquisa de contas
                            da verifica_conta (Douglas - Chamado 406267)

               05/07/2016 - Ajuste para considerar inpessoa > 1 ao validar contas
                            juridicas (Adriano - SD 480514).

               14/09/2016 - Ajuste para utilizar uma sequence na geracao do numero
                            de controle, garantindo sua unicidade
                            (Adriano - SD 518645).

               01/12/2016 - Tratamento credito TED/TEC Transposul (Diego).

               06/12/2016 - Incluido mensagens STR0025 E PAG0121 referente ao
                            Bacenjud (Prj 341 - Andrino - Mouts)

               05/01/2017 - Ajuste para retirada de caracterer especiais
                            (Adriano - SD 556053)

               17/01/2017 - Ajuste para retirada de caracterer especiais
                            (Adriano - SD 594482)

               15/02/2017 - Ajuste para devolver mensagem STR00010 para mensagens
                            STR0006R2, PAG0142R2 (Adriano - SD 553778).

               11/05/2017 - Ajuste para que as mensagens de TED que recebemos sejam
                            gravadas na nova estrutura, e gravar as mensagens de
                            devoluçao (Douglas - Chamado 524133)

               23/05/2017 - Ajuste para devolver as mensagens PAG0142R2 como
                            PAG0111 (Douglas - Chamado 524133)

               02/06/2017 - Ajustes referentes ao Novo Catalogo do SPB (Lucas Ranghetti #668207)
                            - Enviar e-mail interbancario para a mensagem STR0003R2 (Lucas Ranghetti #654769)

               30/06/2017 - Ajustado os parametros passados na chamada da
                            pc_gera_log_batch (Douglas - Chamado 524133)

               04/07/2017 - Ajustar as procedures grava_mensagem_ted e grava_ted_rejeitada
                            para gerar as mensagens de erro no arquivo de log
                            crps531_DDMMYYYY.log (Douglas - Chamado 524133)

               07/07/2017 - Ajustar a gravacao do XML da mensagem de TED, para ser feito apenas
                            quando o retorno da verifica_processo for OK (Douglas - Chamado 524133)

               14/07/2017 - Ajustar a procedure deleta_objetos para validar se o handle do objeto eh
                            valido para que seja excluido (Douglas - Chamado 524133)

               01/08/2017 - Conversão Progress >> Oracle PLSQL (Andrei-Mouts)

               09/08/2017 - Inclusao da verificacao do produto TR. (Jaison/James - PRJ298)

               18/08/2017 - Ajuste para efetuar o controle de lock ao realizar a atualizacao
                            da tabela craplfp (Adriano - SD 733103).

               10/10/2017 - Alteracoes melhoria 407 (Mauricio - Mouts)

               06/11/2017 - Alteração no tratamento da mensagem LTR0005R2 (Mauricio - Mouts)

               24/11/2017 - Alteração no tratamento da mensagem LTR0005R2 e tratamento da mensagem SLC0001 (Mauricio - Mouts)

               11/12/2017 - Inclusão do parametro par_cdmensagem - Codigo da mensagem ou critica
                            (Belli - Envolti - Chamado 786752)

               14/12/2017 - Implementação procedure trata_arquivo_ldl	(Alexandre Borgmann - Mouts) 

               19/12/2017 - Efetuado alteracao para validar corretamente o tipo de pessoa e conta (Jonata - MOUTS).

               29/12/2017 - Tratamento mensagem LDL0020R2,LDL0022,LTR0004	(Alexandre Borgmann - Mouts) 
			   
			         18/01/2018 - Tratar mensagem STR0006R2 para Cielo (Alexandre Borgmann - Mouts) 

               31/01/2018 - Inclusão das ultimas alterações pós-conversão (Andrei-Mouts)

             #######################################################
             ATENCAO!!! Ao incluir novas mensagens para recebimento,
             lembrar de tratar a procedure gera_erro_xml.
             #######################################################

   ............................................................................ */
  DECLARE

    -- Constantes do programa
    vr_glb_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'crps531';
    vr_glb_cdagenci CONSTANT PLS_INTEGER := 1;
    vr_glb_cdbccxlt CONSTANT PLS_INTEGER := 100;
    vr_glb_nrdolote CONSTANT PLS_INTEGER := 10115;
    vr_glb_tplotmov CONSTANT PLS_INTEGER := 1;

    -- Tratamento de erros
    vr_exc_next   EXCEPTION;
    vr_exc_saida  EXCEPTION;
    vr_exc_lock   EXCEPTION;

    -- Erro em chamadas da pc_gera_erro
    vr_des_reto     VARCHAR2(3);
    vr_tab_erro     GENE0001.typ_tab_erro;
    vr_cdcritic     NUMBER;
    vr_dscritic     VARCHAR2(4000);
    vr_typ_saida    VARCHAR2(3000);
    vr_des_saida    VARCHAR2(4000);
    vr_logprogr     VARCHAR2(1000);
    vr_nmarqlog     VARCHAR2(1000);

    /* Busca dos dados da cooperativa */
    /* Busca dados da Coope por outros filtros */
    CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE DEFAULT NULL
                     ,pr_cdagectl IN crapcop.cdagectl%TYPE DEFAULT NULL
                     ,pr_nrctactl IN crapcop.nrctactl%TYPE DEFAULT NULL
                     ,pr_flgativo IN crapcop.flgativo%TYPE DEFAULT NULL) IS
      SELECT cop.cdcooper
            ,cop.nmrescop
            ,cop.nrtelura
            ,GENE0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                  ,pr_cdcooper => cop.cdcooper) dsdircop
            ,cop.cdbcoctl
            ,cop.cdagectl
        FROM crapcop cop
       WHERE cop.cdagectl = NVL(pr_cdagectl,cop.cdagectl)
         AND cop.nrctactl = NVL(pr_nrctactl,cop.nrctactl)
         AND cop.flgativo = nvl(pr_flgativo,cop.flgativo);
    rw_crapcop_central cr_crapcop%ROWTYPE;
    rw_crapcop_mensag cr_crapcop%ROWTYPE;
    rw_crapcop_portab cr_crapcop%ROWTYPE;

    /* Cursor genérico de calendário */
    rw_crapdat_central btch0001.cr_crapdat%ROWTYPE;
    rw_crapdat_mensag btch0001.cr_crapdat%ROWTYPE;
    rw_crapdat_portab btch0001.cr_crapdat%ROWTYPE;

    /* Variaveis genéricos */
    vr_aux_dtintegr DATE;
    vr_aux_flestcri PLS_INTEGER;
    vr_aux_inestcri PLS_INTEGER;

    /* Variavel para manter arquivo fisico */
    vr_aux_manter_fisico BOOLEAN;
    /* Variavel para armazenar/remover as mensagens de TED processadas */
    vr_msgspb_mover  PLS_INTEGER;
    /* Variavel para armazenar as mensagens de TED que nao serao copiadas */
    vr_msgspb_nao_copiar VARCHAR2(100);

    /* Estrutura para Estado de Crise */
    vr_tab_estad_crise sspb0001.typ_tab_estado_crise;

    /* Variaveis para o processamento do XML */
    vr_aux_CodMsg               VARCHAR2(20);
    vr_aux_NrOperacao           VARCHAR2(100);
    vr_aux_NumCtrlRem           VARCHAR2(100);
    vr_aux_NumCtrlIF            VARCHAR2(100);
    vr_aux_ISPBIFDebtd          VARCHAR2(100);
    vr_aux_BancoDeb             PLS_INTEGER := 0;
    vr_aux_AgDebtd              VARCHAR2(100);
    vr_aux_CtDebtd              VARCHAR2(100);
    vr_aux_CNPJ_CPFDeb          VARCHAR2(100);
    vr_aux_NomCliDebtd          VARCHAR2(100);
    vr_aux_ISPBIFCredtd         VARCHAR2(100);
    vr_aux_BancoCre             PLS_INTEGER := 0;
    vr_aux_AgCredtd             VARCHAR2(100);
    vr_aux_CtCredtd             VARCHAR2(100);
    vr_aux_CNPJ_CPFCred         VARCHAR2(100);
    vr_aux_NomCliCredtd         VARCHAR2(100);
    vr_aux_TpPessoaCred         VARCHAR2(100);
    vr_aux_CodDevTransf         VARCHAR2(100);
    vr_aux_TpCtCredtd           VARCHAR2(100);
    vr_aux_CtPgtoCredtd         VARCHAR2(100);
    vr_aux_DtHRBC               VARCHAR2(100);
    vr_aux_CtPgtoDebtd          VARCHAR2(100);
    vr_aux_TpCtDebtd            VARCHAR2(100);
    vr_aux_CodMunicOrigem       VARCHAR2(100);
    vr_aux_CodMunicDest         VARCHAR2(100);
    vr_aux_DsVlrLanc            VARCHAR2(100);
    vr_aux_VlrLanc              NUMBER;
    vr_aux_CdLegado             VARCHAR2(100);
    vr_aux_IdentcDep            VARCHAR2(100);
    vr_aux_NumCodBarras         VARCHAR2(100);
    vr_aux_DtMovto              VARCHAR2(100);
    vr_aux_SitLanc              VARCHAR2(100);
    vr_aux_dadosdeb             VARCHAR2(100);
    vr_aux_codierro             PLS_INTEGER := 0;
    vr_aux_dsdehist             VARCHAR2(1000);
    vr_aux_tagCABInf            BOOLEAN := FALSE;
    vr_aux_nrctacre             PLS_INTEGER := 0;
    vr_aux_nrconven             PLS_INTEGER := 0;
    vr_aux_nrdconta             PLS_INTEGER := 0;
    vr_aux_nrdocmto             NUMBER := 0;
    vr_aux_msgrejei             VARCHAR2(300);
    vr_aux_nmdirxml             VARCHAR2(300);
    vr_aux_nmarqxml             VARCHAR2(300);
    vr_aux_flgderro             BOOLEAN := FALSE;
    vr_aux_nrctrole             VARCHAR2(100);
    vr_aux_cdageinc             PLS_INTEGER := 0;
    vr_aux_nrctremp             PLS_INTEGER := 0;
    vr_aux_tpemprst             PLS_INTEGER := 2;
    vr_aux_qtregist             PLS_INTEGER := 0;
    vr_aux_vlsldliq             PLS_INTEGER := 0;
    vr_aux_Hist                 VARCHAR2(100);
    vr_aux_FinlddCli            VARCHAR2(100);
    vr_aux_NumCtrlLTR           VARCHAR2(100);
    vr_aux_ISPBLTR              VARCHAR2(100);
    vr_aux_IdentdPartCamr       VARCHAR2(100);
    vr_aux_NumCtrlSTR	          VARCHAR2(100);
    vr_aux_NumCtrlSLC           VARCHAR2(100);
    vr_aux_ISPBIF               VARCHAR2(100);
    vr_aux_TpInf                VARCHAR2(100);
    vr_aux_DtHrSLC              VARCHAR2(100);
    vr_aux_NumSeqCicloLiquid    VARCHAR2(100);
    vr_aux_DtLiquid             VARCHAR2(100);
    vr_aux_IdentdLinhaBilat     VARCHAR2(100);
    vr_aux_TpDeb_Cred           VARCHAR2(100);
    vr_aux_CNPJNLiqdantDebtd    VARCHAR2(100);
    vr_aux_CNPJNLiqdantCredtd   VARCHAR2(100);
    vr_aux_IdentLinhaBilat      VARCHAR2(100);
    vr_aux_TpDebCred            VARCHAR2(100);
    vr_aux_CNPJNLiqdant         VARCHAR2(100);
    vr_aux_FinlddIF             VARCHAR2(100);
    vr_aux_TpPessoaDebtd_Remet  VARCHAR2(100);
    

    vr_aux_msgderro       VARCHAR(1000);
    vr_tab_situacao_if    SSPB0001.typ_tab_situacao_if;
    vr_aux_nrispbif       pls_integer;
    vr_aux_cddbanco       pls_integer;
    vr_aux_nmdbanco       VARCHAR2(300);
    vr_aux_CodProdt       VARCHAR2(300);
    vr_aux_dtinispb       VARCHAR2(300);
    vr_aux_flgrespo       pls_integer;
    vr_aux_NUPortdd       VARCHAR2(300);
    vr_aux_cdtiptrf       pls_integer;
    vr_aux_dsarqenv       VARCHAR2(1000);

    /* Variáveis da LDL */

    vr_aux_CodGrdLDL      VARCHAR2(30);
    vr_aux_DtHrAbert      VARCHAR2(30);
    vr_aux_DtHrFcht       VARCHAR2(30);
    vr_aux_TpHrio         VARCHAR2(30);
    vr_aux_DtRef          VARCHAR2(30);

    -- Variaveis auxiliares
    vr_aux_dstextab       craptab.dstextab%TYPE;
    vr_log_msgderro       VARCHAR2(1000);
    vr_aux_vlrjuros       NUMBER;
    vr_aux_vlrmulta       NUMBER;
    vr_aux_vldescto       NUMBER;
    vr_aux_vlabatim       NUMBER;
    vr_aux_vlfatura       NUMBER;
    vr_aux_flgvenci       BOOLEAN;
    vr_aux_liqaposb       BOOLEAN;
    vr_aux_cdbanpag       PLS_INTEGER;
    vr_aux_dsmotivo       VARCHAR2(100);
    vr_ret_nrremret       PLS_INTEGER;
    vr_aux_nrridflp       PLS_INTEGER;

    -- Pagamentos de titulos
    vr_tab_lcm_consolidada paga0001.typ_tab_lcm_consolidada;
    vr_tab_descontar       paga0001.typ_tab_titulos;
    vr_tab_titulosdt       paga0001.typ_tab_titulos;
    vr_idx_descontar       VARCHAR2(20);

    /* Temp-table para Numerarios */
    TYPE typ_reg_numerario IS RECORD(cdcatego PLS_INTEGER
                                    ,vlrdenom NUMBER
                                    ,qtddenom PLS_INTEGER);
    TYPE typ_tab_numerario IS TABLE OF typ_reg_numerario
                              INDEX BY PLS_INTEGER;
    vr_tab_numerario typ_tab_numerario;

    /* Registro de TED */
    CURSOR cr_craptvl(pr_cdcooper crapcop.cdcooper%TYPE
                     ,pr_idopetrf VARCHAR2) IS
      SELECT nmpesrcb
            ,vldocrcb
            ,nrdconta
            ,nmpesemi
            ,cpfcgemi
            ,cdbccrcb
            ,cdagercb
            ,nrcctrcb
            ,cpfcgrcb
            ,tpdctacr
            ,ROWID
        FROM craptvl
       WHERE craptvl.cdcooper = pr_cdcooper
         AND craptvl.tpdoctrf = 3
         AND craptvl.idopetrf = pr_idopetrf;
    rw_craptvl cr_craptvl%ROWTYPE;

    /* Buscar dados do banco */
    CURSOR cr_crapban(pr_cdbccxlt craptvl.cdbccrcb%TYPE DEFAULT NULL
                     ,pr_nrispbif crapban.nrispbif%TYPE DEFAULT NULL) IS
      SELECT nrispbif
            ,cdbccxlt
        FROM crapban
       WHERE cdbccxlt = NVL(pr_cdbccxlt,cdbccxlt)
         AND nrispbif = NVL(pr_nrispbif,nrispbif);
    rw_crapban cr_crapban%ROWTYPE;

    /* Registro de TEC Salário */
    CURSOR cr_craplcs(pr_cdcooper crapcop.cdcooper%type
                     ,pr_idopetrf VARCHAR2) IS
      SELECT lcs.vllanmto
            ,lcs.nrdconta
            ,ccs.nmfuncio
            ,ccs.nrcpfcgc
            ,ccs.cdbantrf
            ,ccs.cdagetrf
            ,ccs.nrctatrf
            ,ccs.nrdigtrf
            ,lcs.rowid
        FROM craplcs lcs
            ,crapccs ccs
       WHERE lcs.cdcooper = pr_cdcooper
         AND lcs.idopetrf = pr_idopetrf
         AND lcs.cdcooper = ccs.cdcooper
         AND lcs.nrdconta = ccs.nrdconta;
    rw_craplcs cr_craplcs%ROWTYPE;

    -- Buscar convênio Boleto
    CURSOR cr_crapcco(pr_nrconven PLS_INTEGER) IS
      SELECT cdcooper
            ,cddbanco
            ,nrdctabb
            ,nrconven
            ,cdagenci
            ,cdbccxlt
            ,nrdolote
        FROM crapcco
       WHERE nrconven = pr_nrconven
         AND dsorgarq <> 'MIGRACAO'
       ORDER BY cdcooper;
    rw_crapcco cr_crapcco%ROWTYPE;

    -- Buscar Boleto
    CURSOR cr_crapcob(pr_cdcooper crapcob.cdcooper%TYPE
                     ,pr_cdbandoc crapcob.cdbandoc%TYPE
                     ,pr_nrdctabb crapcob.nrdctabb%TYPE
                     ,pr_nrcnvcob crapcob.nrcnvcob%TYPE
                     ,pr_nrdconta crapcob.nrdconta%TYPE
                     ,pr_nrdocmto crapcob.nrdocmto%TYPE) IS
      SELECT crapcob.cdcooper
            ,crapcob.incobran
            ,crapcob.vlabatim
            ,crapcob.vltitulo
            ,crapcob.dtvencto
            ,crapcob.vldescto
            ,crapcob.vlrmulta
            ,crapcob.vljurdia
            ,crapcob.cdmensag
            ,crapcob.insitcrt
            ,crapcob.tpdmulta
            ,crapcob.tpjurmor
            ,crapcob.rowid
        FROM crapcob
       WHERE crapcob.cdcooper = pr_cdcooper
         AND crapcob.cdbandoc = pr_cdbandoc
         AND crapcob.nrdctabb = pr_nrdctabb
         AND crapcob.nrcnvcob = pr_nrcnvcob
         AND crapcob.nrdconta = pr_nrdconta
         AND crapcob.nrdocmto = pr_nrdocmto;
    rw_crapcob cr_crapcob%ROWTYPE;

    -- Buscar conta transferida
    CURSOR cr_craptco(pr_cdcooper NUMBER DEFAULT NULL
                     ,pr_cdcopant NUMBER DEFAULT NULL
                     ,pr_ntctaant NUMBER
                     ,pr_flgativo NUMBER DEFAULT NULL
                     ,pr_tpctatrf NUMBER DEFAULT NULL) IS
      SELECT cdcooper
            ,nrdconta
            ,cdcopant
            ,nrctaant
        FROM craptco
       WHERE cdcooper = NVL(pr_cdcooper,cdcooper)
         AND cdcopant = NVL(pr_cdcopant,cdcopant)
         AND nrctaant = pr_ntctaant
         AND flgativo = NVL(pr_flgativo,flgativo)
         AND tpctatrf = NVL(pr_tpctatrf,tpctatrf);
    rw_craptco cr_craptco%ROWTYPE;

    -- Buscar associado
    CURSOR cr_crapass(pr_cdcooper NUMBER
                     ,pr_nrdconta NUMBER
                     ,pr_nrcpfcgc NUMBER default NULL
                     ,pr_flgjurid NUMBER default 0) IS
      SELECT inpessoa
            ,nrcpfcgc
            ,dtelimin
        FROM crapass
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrcpfcgc = NVL(pr_nrcpfcgc,nrcpfcgc)
         -- Se foi solicitado PJ, então pesquisa inpesssoa > 1
         AND (pr_flgjurid = 0 OR inpessoa > 1);
    rw_crapass cr_crapass%ROWTYPE;

    -- Buscar titular
    CURSOR cr_crapttl(pr_cdcooper NUMBER
                     ,pr_nrdconta NUMBER
                     ,pr_nrcpfcgc NUMBER DEFAULT NULL) IS
      SELECT nrcpfcgc
        FROM crapttl
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrcpfcgc = NVL(pr_nrcpfcgc,nrcpfcgc);
    rw_crapttl cr_crapttl%ROWTYPE;

    -- Cursor Capa do Lote
    CURSOR cr_craplot(pr_cdcooper IN craplot.cdcooper%TYPE
                     ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                     ,pr_cdagenci IN craplot.cdagenci%TYPE
                     ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                     ,pr_nrdolote IN craplot.nrdolote%TYPE)  IS
    SELECT lot.dtmvtolt
          ,lot.cdagenci
          ,lot.cdbccxlt
          ,lot.nrdolote
          ,NVL(lot.nrseqdig,0) nrseqdig
          ,lot.cdcooper
          ,lot.tplotmov
          ,lot.vlinfodb
          ,lot.vlcompdb
          ,lot.qtinfoln
          ,lot.qtcompln
          ,lot.cdoperad
          ,lot.tpdmoeda
          ,lot.rowid
      FROM craplot lot
     WHERE lot.cdcooper = pr_cdcooper
       AND lot.dtmvtolt = pr_dtmvtolt
       AND lot.cdagenci = pr_cdagenci
       AND lot.cdbccxlt = pr_cdbccxlt
       AND lot.nrdolote = pr_nrdolote
       FOR UPDATE;
    rw_craplot cr_craplot%ROWTYPE;

    /* Registro de Lancamento no Dia */
    CURSOR cr_craplcm_exis(pr_cdcooper craplcm.cdcooper%type
                          ,pr_dtmvtolt craplcm.dtmvtolt%type
                          ,pr_cdagenci craplcm.cdagenci%type
                          ,pr_cdbccxlt craplcm.cdbccxlt%type
                          ,pr_nrdolote craplcm.nrdolote%type
                          ,pr_nrdctabb craplcm.nrdctabb%type
                          ,pr_nrdocmto craplcm.nrdocmto%type) IS
      SELECT 1
            ,lcm.vllanmto
        FROM craplcm lcm
       WHERE lcm.cdcooper = pr_cdcooper
         AND lcm.dtmvtolt = pr_dtmvtolt
         AND lcm.cdagenci = pr_cdagenci
         AND lcm.cdbccxlt = pr_cdbccxlt
         AND lcm.nrdolote = pr_nrdolote
         AND lcm.nrdctabb = pr_nrdctabb
         AND lcm.nrdocmto = pr_nrdocmto;
    vr_aux_existlcm NUMBER;
    vr_aux_vllanmto NUMBER;


    -- Procedimento para mover o XML processado
    PROCEDURE pc_mover_arquivo_xml(pr_nmarq_mover IN VARCHAR2
                                  ,pr_nmdir_mover IN VARCHAR2) is
    BEGIN
      -- Verificar as mensagens que serao desprezadas na gravacao da nova estrutura
      IF vr_msgspb_nao_copiar IS NOT NULL AND ','||vr_aux_CodMsg||',' LIKE ('%,'||vr_msgspb_nao_copiar||',%') THEN
        -- Se a mensagem nao eh gravada na nova estrutura, vamos continuar movendo ela
        gene0001.pc_OScommand_Shell(pr_des_comando => 'mv '||vr_aux_nmdirxml||'/'||vr_aux_nmarqxml||' '||pr_nmdir_mover||'/salvar/'||pr_nmarq_mover
                                   ,pr_typ_saida   => vr_typ_saida
                                   ,pr_des_saida   => vr_des_saida);
      ELSE
        -- Verificar se o parametro está para MOVER o arquivo
        IF vr_msgspb_mover = 1 OR vr_aux_manter_fisico THEN
          -- Movemos para a salvar
          gene0001.pc_OScommand_Shell(pr_des_comando => 'mv '||vr_aux_nmdirxml||'/'||vr_aux_nmarqxml||' '||pr_nmdir_mover||'/salvar/'||pr_nmarq_mover
                                     ,pr_typ_saida   => vr_typ_saida
                                     ,pr_des_saida   => vr_des_saida);
        ELSE
          -- Se nao esta movendo, remove o arquivo
          gene0001.pc_OScommand_Shell(pr_des_comando => 'rm '||vr_aux_nmdirxml||'/'||vr_aux_nmarqxml
                                     ,pr_typ_saida   => vr_typ_saida
                                     ,pr_des_saida   => vr_des_saida);
        END IF;
      END IF;
      -- Verificar retorno da interface com o SO
      IF vr_typ_saida = 'ERR' OR vr_des_saida IS NOT NULL THEN
        -- Escrever no arquivo de LOG apenas
        BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 1 -- Processo normal
                                  ,pr_des_log      => to_char(sysdate,'dd/mm/rrrr') || ' - '
                                                   || to_char(sysdate,'hh24:mi:ss')||' - '|| vr_glb_cdprogra || ' --> '
                                                   || ' Erro ao mover arquivo da execução paralela - PID: '
                                                   || ' - ' || pr_idparale|| ' Seq.: ' || to_char(pr_idprogra,'fm99990')
                                                   || ' Mensagem: ' || vr_aux_nmdirxml||'/'||vr_aux_nmarqxml
                                                   || ' Erro --> '||vr_des_saida
                                  ,pr_nmarqlog     => vr_logprogr); --> Log específico deste programa
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        -- Escrever no arquivo de LOG apenas
        BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 1 -- Processo normal
                                  ,pr_des_log      => to_char(sysdate,'dd/mm/rrrr') || ' - '
                                                   || to_char(sysdate,'hh24:mi:ss')||' - '|| vr_glb_cdprogra || ' --> '
                                                   || ' Erro ao mover arquivo da execução paralela - PID: '
                                                   || ' - ' || pr_idparale|| ' Seq.: ' || to_char(pr_idprogra,'fm99990')
                                                   || ' Mensagem: ' || vr_aux_nmdirxml||'/'||vr_aux_nmarqxml
                                                   || ' Erro --> '||sqlerrm
                                  ,pr_nmarqlog     => vr_logprogr); --> Log específico deste programa
    END;


    -- Procedimento para salvar o arquivo
    PROCEDURE pc_salva_arquivo IS
    BEGIN
      -- Chamar rotina para mover o XML conforme o dsdircop carregado
      IF rw_crapcop_mensag.cdcooper IS NOT NULL THEN
        -- Mover para a coop carregada
        pc_mover_arquivo_xml(pr_nmarq_mover => vr_aux_nmarqxml
                            ,pr_nmdir_mover => rw_crapcop_mensag.dsdircop);
      ELSE
        -- Mover para a Central
        pc_mover_arquivo_xml(pr_nmarq_mover => vr_aux_nmarqxml
                            ,pr_nmdir_mover => rw_crapcop_central.dsdircop);
      END IF;
    END;

    /* SubRotina para concentrar o encerramento de rotina paralela */
    PROCEDURE pc_finaliza_paralelo IS
    BEGIN
      -- Iniciar LOG de execução
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 1 -- Processo normal
                                ,pr_des_log      => to_char(sysdate,'dd/mm/rrrr') || ' - '
                                                 || to_char(sysdate,'hh24:mi:ss')||' - '|| vr_glb_cdprogra || ' --> '
                                                 || ' Fim da execução paralela - PID: '
                                                 || ' - ' || pr_idparale|| ' Seq.: ' || to_char(pr_idprogra,'fm99990')
                                                 || ' Mensagem: ' || vr_aux_nmdirxml||'/'||vr_aux_nmarqxml
                                ,pr_nmarqlog     => vr_logprogr); --> Log específico deste programa

      -- Encerrar o job do processamento paralelo dessa agência
      gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                  ,pr_idprogra => pr_idprogra
                                  ,pr_des_erro => pr_dscritic);
      -- Testar saida com erro
      IF pr_dscritic IS NOT NULL THEN
        -- Levantar exceçao
        RAISE vr_exc_saida;
      END IF;
    END;

    -- Rotina para validar a conta
    PROCEDURE pc_verifica_conta(pr_cdcritic OUT NUMBER
                               ,pr_dscritic OUT VARCHAR) IS
      -- Variaveis locais
      vr_val_cdcooper PLS_INTEGER;
      vr_val_nrdconta NUMBER;
      vr_val_tppessoa VARCHAR2(10);
      vr_val_nrcpfcgc NUMBER;
      vr_val_tpdconta VARCHAR2(10);
      vr_val_nrdctapg VARCHAR2(100);
      -- Buffers locais
      rw_b_crapcop cr_crapcop%rowtype;
      rw_b_crapdat btch0001.cr_crapdat%rowtype;

    BEGIN

      -- Incializar as variaveis
      vr_val_cdcooper := rw_crapcop_mensag.cdcooper;
      vr_val_nrdconta := to_number(vr_aux_CtCredtd);
      IF vr_aux_CodMsg = 'STR0047R2' THEN
        vr_val_tppessoa := 'J'; -- Conta das filiadas na CECRED
      ELSE
        vr_val_tppessoa := vr_aux_TpPessoaCred;
      END IF;
      vr_val_nrcpfcgc := to_number(vr_aux_CNPJ_CPFCred);
      vr_val_tpdconta := vr_aux_TpCtCredtd;
      vr_val_nrdctapg := vr_aux_CtPgtoCredtd;
      -- Nao recebemos conta e nem cpf para esta mensagem
      IF vr_aux_CodMsg = 'STR0003R2' THEN
        RETURN;
      END IF;

      -- Tratar tamanho da conta
      IF LENGTH(vr_val_nrdconta) > 9 THEN
        -- Conta invalida
        pr_cdcritic := 2;
        pr_dscritic := 'Conta informada invalida.';
      ELSE
        IF vr_val_tpdconta = 'PG' OR vr_val_nrdctapg IS NOT NULL THEN
          -- Conta invalida
          pr_cdcritic := 2;
          pr_dscritic := 'Tipo de Conta Incorreto.';
          vr_aux_CtCredtd := vr_val_nrdctapg;
          RETURN;
        END IF;

        -- Para Incorporação Transulcred
        IF vr_aux_cdageinc > 0 THEN
          -- Identifica cooperativa antiga
          OPEN cr_crapcop(pr_cdagectl => vr_aux_cdageinc);
          FETCH cr_crapcop
           INTO rw_b_crapcop;
          CLOSE cr_crapcop;
          -- Buscar nova conta
          OPEN cr_craptco(pr_cdcooper => vr_val_cdcooper
                         ,pr_cdcopant => rw_b_crapcop.cdcooper
                         ,pr_ntctaant => vr_val_nrdconta);
          FETCH cr_craptco
           INTO rw_craptco;
          -- Se encontrou
          IF cr_craptco%FOUND THEN
            CLOSE cr_craptco;
            -- Usar Nova conta
            vr_val_nrdconta := rw_craptco.nrdconta;
          ELSE
            CLOSE cr_craptco;
            -- Conta invalida
            pr_cdcritic := 2;
            pr_dscritic := 'Conta informada invalida.';
            RETURN;
          END IF;
        ELSE
          -- Buscar nova conta
          OPEN cr_craptco(pr_cdcopant => vr_val_cdcooper
                         ,pr_ntctaant => vr_val_nrdconta
                         ,pr_flgativo => 1
                         ,pr_tpctatrf => 1);
          FETCH cr_craptco
           INTO rw_craptco;
          -- Se encontrou
          IF cr_craptco%FOUND THEN
            CLOSE cr_craptco;
            -- Verificar se conta foi migrada ACREDI >> VIACREDI
            -- Verificar se conta foi migrada VIACREDI >> ALTO VALE
            IF (rw_craptco.cdcooper = 1 AND rw_craptco.cdcopant = 2)
            OR (rw_craptco.cdcooper = 16 AND rw_craptco.cdcopant = 1) THEN
              -- Conta encerrada
              pr_cdcritic := 1;
              RETURN;
            END IF;

            -- Validacao da conta migrada
            vr_val_cdcooper := rw_craptco.cdcooper;
            vr_val_nrdconta := rw_craptco.nrdconta;

            -- Busca cooperativa onde a conta foi transferida
            OPEN cr_crapcop(pr_cdcooper => vr_val_cdcooper);
            FETCH cr_crapcop
             INTO rw_b_crapcop;
            -- Se não encontrar
            IF cr_crapcop%NOTFOUND THEN
              CLOSE cr_crapcop;
              -- Coop nao encontrar
              pr_cdcritic := 99;
              pr_dscritic := 'Cooperativa migrada nao encontrada.';
              RETURN;
            ELSE
              CLOSE cr_crapcop;
            END IF;
            -- Busca data na cooperativa onde a conta foi transferida
            OPEN btch0001.cr_crapdat(pr_cdcooper => vr_val_cdcooper);
            FETCH btch0001.cr_crapdat
             INTO rw_b_crapdat;
            -- Se não encontrar
            IF btch0001.cr_crapdat%NOTFOUND THEN
              CLOSE btch0001.cr_crapdat;
              -- Coop nao encontrar
              pr_cdcritic := 99;
              pr_dscritic := 'Data da cooperativa migrada nao encontrada.';
              RETURN;
            ELSE
              CLOSE btch0001.cr_crapdat;
            END IF;
            -- Verifica se conta transferida existe na Coop destino
            OPEN cr_crapass(pr_cdcooper => vr_val_cdcooper
                           ,pr_nrdconta => vr_val_nrdconta);
            FETCH cr_crapass
             INTO rw_crapass;
            -- Se não encontrar
            IF cr_crapass%NOTFOUND THEN
              CLOSE cr_crapass;
              -- Cconta não encontrada
              pr_cdcritic := 99;
              pr_dscritic := 'Conta migrada nao encontrada.';
              RETURN;
            ELSE
              CLOSE cr_crapass;
            END IF;
          ELSE
            CLOSE cr_craptco;
          END IF;
        END IF;

        -- Verifica se o problema esta na conta
        OPEN cr_crapass(pr_cdcooper => vr_val_cdcooper
                       ,pr_nrdconta => vr_val_nrdconta);
        FETCH cr_crapass
         INTO rw_crapass;
        -- Se não encontrar
        IF cr_crapass%NOTFOUND THEN
          CLOSE cr_crapass;
          -- Cconta não encontrada
          pr_cdcritic := 2;
          pr_dscritic := 'Conta informada invalida.';
          RETURN;
        ELSIF rw_crapass.dtelimin IS NOT NULL THEN
          pr_cdcritic := 1;  /* Conta encerrada */
          RETURN;
        ELSE
          CLOSE cr_crapass;
          -- Para PF
          IF rw_crapass.inpessoa = 1 THEN
            -- Verifica cpf da TED com o cpf da conta
            OPEN cr_crapttl(pr_cdcooper => vr_val_cdcooper
                           ,pr_nrdconta => vr_val_nrdconta
                           ,pr_nrcpfcgc => vr_val_nrcpfcgc);
            FETCH cr_crapttl
             INTO rw_crapttl;
            -- Se não encontrar
            IF cr_crapttl%NOTFOUND OR NOT (vr_val_tppessoa = 'F' OR vr_aux_CodMsg IN('STR0037R2','PAG0137R2')) THEN
              CLOSE cr_crapttl;
              --CPF divergente
              pr_cdcritic := 3;
              RETURN;
            ELSE
              CLOSE cr_crapttl;
            END IF;
          ELSE -- PJ
            -- Verifica se o problema esta no CPF
            rw_crapass := NULL;
            OPEN cr_crapass(pr_cdcooper => vr_val_cdcooper
                           ,pr_nrdconta => vr_val_nrdconta
                           ,pr_nrcpfcgc => vr_val_nrcpfcgc
                           ,pr_flgjurid => 1);
            FETCH cr_crapass
             INTO rw_crapass;
            -- Se não tiver encontrado
            IF vr_val_tppessoa <> 'J' OR cr_crapass%NOTFOUND  THEN
              CLOSE cr_crapass;
              /*CNPJ divergente*/
              pr_cdcritic := 3;
              -- Sair
              RETURN;
            ELSE
              CLOSE cr_crapass;
            END IF;
          END IF;
        END IF;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 2; -- Conta invalida
        pr_dscritic := 'Erro nao tratado com a conta --> '||sqlerrm;
    END;

    -- Rotina para verificar se o processo ainda está rodando
    FUNCTION fn_verifica_processo RETURN BOOLEAN IS
      -- Variavies auxiliares
      vr_cdcooper crapcop.cdcooper%TYPE;
    BEGIN
      -- Se já foi lida a Cooperativa da mensagem
      IF rw_crapcop_mensag.cdcooper IS NOT NULL THEN
        -- Usaremos ela
        vr_cdcooper := rw_crapcop_mensag.cdcooper;
      ELSE
        -- Usaremos a global
        vr_cdcooper := rw_crapcop_central.cdcooper;
      END IF;

      -- Buscar o calendário
      OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      FETCH btch0001.cr_crapdat
       INTO rw_crapdat_mensag;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
        RETURN FALSE;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      -- Se a data do calendário for diferente de sysdate
      IF TRUNC(SYSDATE) > rw_crapdat_mensag.dtmvtolt THEN
        -- Não poderá executar
        RETURN false;
      ELSE
        RETURN true;
      END IF;
    END;

    -- Verificar se o processo esta ainda executando em estado de crise
    FUNCTION fn_verifica_processo_crise RETURN BOOLEAN IS
    BEGIN
      -- Se nao estiver em estado de crise
      IF vr_aux_flestcri = 0 THEN
        -- Acionar verificação do processo
        IF NOT fn_verifica_processo THEN
          RETURN FALSE;
        END IF;
      ELSE
        -- Verifica as Mensagens de Recebimento
        IF vr_aux_CodMsg IN('STR0005R2','STR0007R2','STR0008R2','PAG0107R2','STR0025R2','PAG0121R2'-- ]a Judicial - Andrino
                           ,'PAG0108R2','PAG0143R2'-- TED
                           ,'STR0037R2','PAG0137R2'-- TEC
                           ,'STR0026R2' --VR Boleto
                           ,'STR0005','PAG0107','STR0008','PAG0108','PAG0137','STR0037','STR0026') THEN -- Rejeitadas
          RETURN FALSE;
        END IF;
      END IF;
      -- Se chegar neste ponto sem restrição, retornar positivo
      RETURN TRUE;
    END;

    -- Trazer arquivo de log do mqcecred_processa
    FUNCTION fn_log_mqcecred RETURN VARCHAR2 IS
      -- Variavies auxiliares
      vr_cdcooper crapcop.cdcooper%TYPE;
    BEGIN
      -- Se já foi lida a Cooperativa da mensagem
      IF rw_crapcop_mensag.cdcooper IS NOT NULL THEN
        -- Usaremos ela
        vr_cdcooper := rw_crapcop_mensag.cdcooper;
      ELSE
        -- Usaremos a global
        vr_cdcooper := rw_crapcop_central.cdcooper;
      END IF;

      -- Buscar o calendário
      OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      FETCH btch0001.cr_crapdat
       INTO rw_crapdat_mensag;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        RETURN ' ';
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      -- Para estas mensagens nao e necessario aguardar processo
      IF vr_aux_CodMsg IN ('PAG0101','STR0018','STR0019') THEN
        RETURN 'mqcecred_processa_' || to_char(sysdate,'DDMMRR') || '.log';
      ELSE
        RETURN 'mqcecred_processa_' || to_char(rw_crapdat_mensag.dtmvtolt,'DDMMRR') || '.log';
      END IF;
    END;

    /* Geracao de LOG no SPB */
    -- Cuidar ao mecher no log, pois os espacamentos e formats estao --
    -- ajustados para que a tela LOGSPB pegue os dados com SUBSTRING --
    PROCEDURE pc_gera_log_SPB(pr_tipodlog  IN VARCHAR2
                             ,pr_msgderro  IN VARCHAR2) IS
      -- Variavies auxiliares
      vr_cdcooper      crapcop.cdcooper%TYPE;
      vr_cdbcoctl      crapcop.cdbcoctl%TYPE;
      vr_cdagectl      crapcop.cdagectl%TYPE;
      vr_nmpesrcb      craptvl.nmpesrcb%TYPE;
      vr_tipodlog      VARCHAR2(1000);
    BEGIN
      -- Se já foi lida a Cooperativa da mensagem
      IF rw_crapcop_mensag.cdcooper IS NOT NULL THEN
        -- Usaremos ela
        vr_cdcooper := rw_crapcop_mensag.cdcooper;
        vr_cdbcoctl := rw_crapcop_mensag.cdbcoctl;
        vr_cdagectl := rw_crapcop_mensag.cdagectl;
      ELSE
        -- Usaremos a global
        vr_cdcooper := rw_crapcop_central.cdcooper;
        vr_cdbcoctl := rw_crapcop_central.cdbcoctl;
        vr_cdagectl := rw_crapcop_central.cdagectl;
      END IF;

      -- Trazer arquivo de log do mqcecred_processa
      vr_nmarqlog := fn_log_mqcecred;

      -- Geração de LOG conforme o tipo da mensagem
      IF pr_tipodlog = 'RETORNO JD OK' THEN
        -- Acionar rotina de LOG
        BTCH0001.pc_gera_log_batch(pr_cdcooper      => vr_cdcooper
                                  ,pr_ind_tipo_log  => 2 -- Erro não tratado
                                  ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - '
                                                    || to_char(sysdate,'hh24:mi:ss')||' - '
                                                    || vr_glb_cdprogra ||' - RETORNO JD OK      --> '
                                                    || 'Arquivo ' || RPAD(SUBSTR(vr_aux_nmarqxml,1,40),40,' ') || '. '
                                                    || 'Numero Controle: ' || RPAD(SUBSTR(vr_aux_NumCtrlIF,1,20),20,' ')
                                  ,pr_nmarqlog      => vr_nmarqlog);
      ELSIF pr_tipodlog IN('RETORNO SPB','REJEITADA NAO OK') THEN
        -- Se há erro
        IF TRIM(pr_msgderro) IS NOT NULL THEN
          IF pr_tipodlog = 'RETORNO SPB' THEN
            vr_tipodlog := 'RETORNO SPB NAO OK';
          ELSE
            vr_tipodlog := pr_tipodlog;
          END IF;
          -- Gerar log
          BTCH0001.pc_gera_log_batch(pr_cdcooper      => vr_cdcooper
                                    ,pr_ind_tipo_log  => 2 -- Erro não tratado
                                    ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - '
                                                      || to_char(sysdate,'hh24:mi:ss')||' - '
                                                      || vr_glb_cdprogra ||' - ' || RPAD(substr(vr_tipodlog,1,18),18,' ') || ' --> '
                                                      || 'Arquivo ' || RPAD(SUBSTR(vr_aux_nmarqxml,1,40),40,' ') || '. '
                                                      || 'Evento: ' || RPAD(SUBSTR(VR_aux_CodMsg,1,9),9,' ')
                                                      || ', Motivo Erro: '|| RPAD(SUBSTR(pr_msgderro,1,90),90,' ')
                                                      || ', Numero Controle: '|| RPAD(SUBSTR(vr_aux_NumCtrlIF,1,20),20,' ')
                                    ,pr_nmarqlog      => vr_nmarqlog);
        ELSE
          -- Gerar log
          BTCH0001.pc_gera_log_batch(pr_cdcooper      => vr_cdcooper
                                    ,pr_ind_tipo_log  => 2 -- Erro não tratado
                                    ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - '
                                                      || to_char(sysdate,'hh24:mi:ss')||' - '
                                                      || vr_glb_cdprogra ||' - RETORNO SPB OK     --> '
                                                      || 'Arquivo ' || RPAD(SUBSTR(vr_aux_nmarqxml,1,40),40,' ') || '. '
                                                      || 'Evento: ' || RPAD(SUBSTR(VR_aux_CodMsg,1,9),9,' ')
                                                      || ', Numero Controle: '|| RPAD(SUBSTR(vr_aux_NumCtrlIF,1,20),20,' ')
                                    ,pr_nmarqlog      => vr_nmarqlog);
        END IF;
      ELSIF pr_tipodlog IN('ENVIADA NAO OK','REJEITADA OK') THEN
        -- Se for TED
        IF SUBSTR(vr_aux_NumCtrlIF,1,1) = 1 THEN
          -- Buscar registro transferência
          OPEN cr_craptvl(pr_cdcooper => vr_cdcooper
                         ,pr_idopetrf => vr_aux_NumCtrlIF);
          FETCH cr_craptvl
           INTO rw_craptvl;
          -- Se encontrar
          IF cr_craptvl%FOUND THEN
            CLOSE cr_craptvl;
            -- Substituir caracteres
            vr_nmpesrcb := gene0007.fn_caract_acento(rw_craptvl.nmpesrcb);
            -- Gerar log
            BTCH0001.pc_gera_log_batch(pr_cdcooper      => vr_cdcooper
                                      ,pr_ind_tipo_log  => 2 -- Erro não tratado
                                      ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - '
                                                        || to_char(sysdate,'hh24:mi:ss')||' - '
                                                        || vr_glb_cdprogra ||' - '||RPAD(SUBSTR(pr_tipodlog,1,18),18,' ')||' --> '
                                                        || 'Arquivo ' || RPAD(SUBSTR(vr_aux_nmarqxml,1,40),40,' ') || '. '
                                                        || 'Evento: ' || RPAD(SUBSTR(vr_aux_CodMsg,1,9),9,' ')
                                                        || ', Motivo Erro: ' || RPAD(SUBSTR(pr_msgderro,1,90),90,' ')
                                                        || ', Numero Controle: '|| RPAD(SUBSTR(vr_aux_NumCtrlIF,1,20),20,' ')
                                                        || ', Hora: ' || to_char(sysdate,'HH24:MI:SS')
                                                        || ', Valor: ' || gene0002.fn_mask(rw_craptvl.vldocrcb,'zzz,zzz,zz9.99')
                                                        || ', Banco Remet.: ' || gene0002.fn_mask(VR_cdbcoctl,'zz9')
                                                        || ', Agencia Remet.: ' || gene0002.fn_mask(vr_cdagectl,'zzz9')
                                                        || ', Conta Remet.: ' || gene0002.fn_mask(rw_craptvl.nrdconta,'zzzzzzzz9')
                                                        || ', Nome Remet.: ' || rpad(substr(rw_craptvl.nmpesemi,1,40),40,' ')
                                                        || ', CPF/CNPJ Remet.: ' || gene0002.fn_mask(rw_craptvl.cpfcgemi,'zzzzzzzzzzzzz9')
                                                        || ', Banco Dest.: ' || gene0002.fn_mask(rw_craptvl.cdbccrcb,'zz9')
                                                        || ', Agencia Dest.: ' || gene0002.fn_mask(rw_craptvl.cdagercb,'zzz9')
                                                        || ', Conta Dest.: ' || RPAD(rw_craptvl.nrcctrcb,14,' ')
                                                        || ', Nome Dest.: ' || rpad(substr(vr_nmpesrcb,1,40),40,' ')
                                                        || ', CPF/CNPJ Dest.: ' || gene0002.fn_mask(rw_craptvl.cpfcgrcb,'zzzzzzzzzzzzz9')
                                      ,pr_nmarqlog      => vr_nmarqlog);
            -- Para enviada nao ok
            IF pr_tipodlog = 'ENVIADA NAO OK' THEN
              -- Gravar log TED
              sspb0001.pc_grava_log_ted(pr_cdcooper => vr_cdcooper
                                       ,pr_dttransa => TRUNC(SYSDATE)
                                       ,pr_hrtransa => TO_CHAR(SYSDATE,'SSSSS')
                                       ,pr_idorigem => 1
                                       ,pr_cdprogra => vr_glb_cdprogra
                                       ,pr_idsitmsg => 2 /* Enviada Nao Ok */
                                       ,pr_nmarqmsg => vr_aux_nmarqxml
                                       ,pr_nmevento => vr_aux_CodMsg
                                       ,pr_nrctrlif => vr_aux_NumCtrlIF
                                       ,pr_vldocmto => rw_craptvl.vldocrcb
                                       ,pr_cdbanctl => vr_cdbcoctl
                                       ,pr_cdagectl => vr_cdagectl
                                       ,pr_nrdconta => rw_craptvl.nrdconta
                                       ,pr_nmcopcta => rw_craptvl.nmpesemi
                                       ,pr_nrcpfcop => rw_craptvl.cpfcgemi
                                       ,pr_cdbandif => rw_craptvl.cdbccrcb
                                       ,pr_cdagedif => rw_craptvl.cdagercb
                                       ,pr_nrctadif => rw_craptvl.nrcctrcb
                                       ,pr_nmtitdif => vr_nmpesrcb
                                       ,pr_nrcpfdif => rw_craptvl.cpfcgrcb
                                       ,pr_cdidenti => ''
                                       ,pr_dsmotivo => pr_msgderro
                                       ,pr_cdagenci => 0
                                       ,pr_nrdcaixa => 0
                                       ,pr_cdoperad => '1'
                                       ,pr_nrispbif => vr_aux_ISPBIFCredtd
                                       ,pr_inestcri => vr_aux_inestcri
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic);
               IF vr_dscritic IS NOT NULL THEN
                 vr_dscritic := 'Erro na gravacao de LOG TED: '||vr_dscritic;
                 RAISE vr_exc_saida;
               END IF;
            ELSE
              /* No XML da mensagem REJEITADA nao contem dados
                 da operação, apenas o numero de controle, que
                 utilizamos para buscar os dados na craptvl.
                 Como nao gravamos o ISPB nesta tabela, vamos
                 conseguir obter/logar somente o ISPB das IFs
                 com código de banco */
              /* Buscar dados do banco */
              OPEN cr_crapban(pr_cdbccxlt => rw_craptvl.cdbccrcb);
              FETCH cr_crapban
               INTO rw_crapban;
              -- Se encontrou
              IF cr_crapban%FOUND THEN
                vr_aux_ISPBIFCredtd := rw_crapban.nrispbif;
              END IF;
              CLOSE cr_crapban;
              -- Gerar log da TED
              sspb0001.pc_grava_log_ted(pr_cdcooper => vr_cdcooper
                                       ,pr_dttransa => TRUNC(SYSDATE)
                                       ,pr_hrtransa => TO_CHAR(SYSDATE,'SSSSS')
                                       ,pr_idorigem => 1
                                       ,pr_cdprogra => vr_glb_cdprogra
                                       ,pr_idsitmsg => 5 /* Rejeitada Ok */
                                       ,pr_nmarqmsg => vr_aux_nmarqxml
                                       ,pr_nmevento => vr_aux_CodMsg
                                       ,pr_nrctrlif => vr_aux_NumCtrlIF
                                       ,pr_vldocmto => rw_craptvl.vldocrcb
                                       ,pr_cdbanctl => vr_cdbcoctl
                                       ,pr_cdagectl => vr_cdagectl
                                       ,pr_nrdconta => rw_craptvl.nrdconta
                                       ,pr_nmcopcta => rw_craptvl.nmpesemi
                                       ,pr_nrcpfcop => rw_craptvl.cpfcgemi
                                       ,pr_cdbandif => rw_craptvl.cdbccrcb
                                       ,pr_cdagedif => rw_craptvl.cdagercb
                                       ,pr_nrctadif => rw_craptvl.nrcctrcb
                                       ,pr_nmtitdif => vr_nmpesrcb
                                       ,pr_nrcpfdif => rw_craptvl.cpfcgrcb
                                       ,pr_cdidenti => ''
                                       ,pr_dsmotivo => pr_msgderro
                                       ,pr_cdagenci => 0
                                       ,pr_nrdcaixa => 0
                                       ,pr_cdoperad => '1'
                                       ,pr_nrispbif => vr_aux_ISPBIFCredtd
                                       ,pr_inestcri => vr_aux_inestcri
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic);
               IF vr_dscritic IS NOT NULL THEN
                 vr_dscritic := 'Erro na gravacao de LOG TED: '||vr_dscritic;
                 RAISE vr_exc_saida;
               END IF;
            END IF;
          ELSE
            CLOSE cr_craptvl;
          END IF;
        ELSE -- TEC
          -- Buscar registro transferência
          OPEN cr_craplcs(pr_cdcooper => vr_cdcooper
                         ,pr_idopetrf => vr_aux_NumCtrlIF);
          FETCH cr_craplcs
           INTO rw_craplcs;
          -- Se encontrar
          IF cr_craplcs%FOUND THEN
            CLOSE cr_craplcs;
            -- Gerar log
            BTCH0001.pc_gera_log_batch(pr_cdcooper      => vr_cdcooper
                                      ,pr_ind_tipo_log  => 2 -- Erro não tratado
                                      ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - '
                                                        || to_char(sysdate,'hh24:mi:ss')||' - '
                                                        || vr_glb_cdprogra ||' - '||RPAD(SUBSTR(pr_tipodlog,1,18),18,' ')||' --> '
                                                        || 'Arquivo ' || RPAD(SUBSTR(vr_aux_nmarqxml,1,40),40,' ') || '. '
                                                        || 'Evento: ' || RPAD(SUBSTR(vr_aux_CodMsg,1,9),9,' ')
                                                        || ', Motivo Erro: ' || RPAD(SUBSTR(pr_msgderro,1,90),90,' ')
                                                        || ', Numero Controle: '|| RPAD(SUBSTR(vr_aux_NumCtrlIF,1,20),20,' ')
                                                        || ', Hora: ' || to_char(sysdate,'HH24:MI:SS')
                                                        || ', Valor: ' || gene0002.fn_mask(rw_craplcs.vllanmto,'zzz,zzz,zz9.99')
                                                        || ', Banco Remet.: ' || gene0002.fn_mask(vr_cdbcoctl,'zz9')
                                                        || ', Agencia Remet.: ' || gene0002.fn_mask(vr_cdagectl,'zzz9')
                                                        || ', Conta Remet.: ' || gene0002.fn_mask(rw_craplcs.nrdconta,'zzzzzzzz9')
                                                        || ', Nome Remet.: ' || rpad(substr(rw_craplcs.nmfuncio,1,40),40,' ')
                                                        || ', CPF/CNPJ Remet.: ' || gene0002.fn_mask(rw_craplcs.nrcpfcgc,'zzzzzzzzzzzzz9')
                                                        || ', Banco Dest.: ' || gene0002.fn_mask(rw_craplcs.cdbantrf,'zz9')
                                                        || ', Agencia Dest.: ' || gene0002.fn_mask(rw_craplcs.cdagetrf,'zzz9')
                                                        || ', Conta Dest.: ' || RPAD(rw_craplcs.nrctatrf||rw_craplcs.nrdigtrf,14,' ')
                                                        || ', Nome Dest.: ' || rpad(substr(rw_craplcs.nmfuncio,1,40),40,' ')
                                                        || ', CPF/CNPJ Dest.: ' || gene0002.fn_mask(rw_craplcs.nrcpfcgc,'zzzzzzzzzzzzz9')
                                      ,pr_nmarqlog      => vr_nmarqlog);
            -- Para enviada nao ok
            IF pr_tipodlog = 'ENVIADA NAO OK' THEN
              -- Gravar log TED
              sspb0001.pc_grava_log_ted(pr_cdcooper => vr_cdcooper
                                       ,pr_dttransa => TRUNC(SYSDATE)
                                       ,pr_hrtransa => TO_CHAR(SYSDATE,'SSSSS')
                                       ,pr_idorigem => 1
                                       ,pr_cdprogra => vr_glb_cdprogra
                                       ,pr_idsitmsg => 2 /* Enviada Nao Ok */
                                       ,pr_nmarqmsg => vr_aux_nmarqxml
                                       ,pr_nmevento => vr_aux_CodMsg
                                       ,pr_nrctrlif => vr_aux_NumCtrlIF
                                       ,pr_vldocmto => rw_craplcs.vllanmto
                                       ,pr_cdbanctl => vr_cdbcoctl
                                       ,pr_cdagectl => vr_cdagectl
                                       ,pr_nrdconta => rw_craplcs.nrdconta
                                       ,pr_nmcopcta => rw_craplcs.nmfuncio
                                       ,pr_nrcpfcop => rw_craplcs.nrcpfcgc
                                       ,pr_cdbandif => rw_craplcs.cdbantrf
                                       ,pr_cdagedif => rw_craplcs.cdagetrf
                                       ,pr_nrctadif => rw_craplcs.nrctatrf||rw_craplcs.nrdigtrf
                                       ,pr_nmtitdif => rw_craplcs.nmfuncio
                                       ,pr_nrcpfdif => rw_craplcs.nrcpfcgc
                                       ,pr_cdidenti => ''
                                       ,pr_dsmotivo => pr_msgderro
                                       ,pr_cdagenci => 0
                                       ,pr_nrdcaixa => 0
                                       ,pr_cdoperad => '1'
                                       ,pr_nrispbif => vr_aux_ISPBIFCredtd
                                       ,pr_inestcri => vr_aux_inestcri
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic);
               IF vr_dscritic IS NOT NULL THEN
                 vr_dscritic := 'Erro na gravacao de LOG TED: '||vr_dscritic;
                 RAISE vr_exc_saida;
               END IF;
            ELSE
              -- Gerar log da TED
              sspb0001.pc_grava_log_ted(pr_cdcooper => vr_cdcooper
                                       ,pr_dttransa => TRUNC(SYSDATE)
                                       ,pr_hrtransa => TO_CHAR(SYSDATE,'SSSSS')
                                       ,pr_idorigem => 1
                                       ,pr_cdprogra => vr_glb_cdprogra
                                       ,pr_idsitmsg => 5 /* Rejeitada Ok */
                                       ,pr_nmarqmsg => vr_aux_nmarqxml
                                       ,pr_nmevento => vr_aux_CodMsg
                                       ,pr_nrctrlif => vr_aux_NumCtrlIF
                                       ,pr_vldocmto => rw_craplcs.vllanmto
                                       ,pr_cdbanctl => vr_cdbcoctl
                                       ,pr_cdagectl => vr_cdagectl
                                       ,pr_nrdconta => rw_craplcs.nrdconta
                                       ,pr_nmcopcta => rw_craplcs.nmfuncio
                                       ,pr_nrcpfcop => rw_craplcs.nrcpfcgc
                                       ,pr_cdbandif => rw_craplcs.cdbantrf
                                       ,pr_cdagedif => rw_craplcs.cdagetrf
                                       ,pr_nrctadif => rw_craplcs.nrctatrf||rw_craplcs.nrdigtrf
                                       ,pr_nmtitdif => rw_craplcs.nmfuncio
                                       ,pr_nrcpfdif => rw_craplcs.nrcpfcgc
                                       ,pr_cdidenti => ''
                                       ,pr_dsmotivo => pr_msgderro
                                       ,pr_cdagenci => 0
                                       ,pr_nrdcaixa => 0
                                       ,pr_cdoperad => '1'
                                       ,pr_nrispbif => vr_aux_ISPBIFCredtd
                                       ,pr_inestcri => vr_aux_inestcri
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic);
               IF vr_dscritic IS NOT NULL THEN
                 vr_dscritic := 'Erro na gravacao de LOG TED: '||vr_dscritic;
                 RAISE vr_exc_saida;
               END IF;
            END IF;
          ELSE
            CLOSE cr_craplcs;
          END IF;
        END IF;
      ELSIF pr_tipodlog = 'RECEBIDA' THEN
        /* Buscar dados do banco */
        OPEN cr_crapban(pr_nrispbif => vr_aux_ISPBIFDebtd);
        FETCH cr_crapban
         INTO rw_crapban;
        -- Se encontrou
        IF cr_crapban%FOUND THEN
          vr_aux_BancoDeb := rw_crapban.cdbccxlt;
        END IF;
        CLOSE cr_crapban;
        /* Banco CECRED */
        vr_aux_BancoCre := vr_cdbcoctl;
        IF trim(vr_aux_NumCtrlRem) IS NOT NULL THEN
          vr_aux_nrctrole := vr_aux_NumCtrlRem;
        ELSE
          vr_aux_nrctrole := vr_aux_NumCtrlIF;
        END IF;
        -- Se houve erro
        IF pr_msgderro IS NOT NULL THEN
          -- Gerar log
          BTCH0001.pc_gera_log_batch(pr_cdcooper      => vr_cdcooper
                                    ,pr_ind_tipo_log  => 2 -- Erro não tratado
                                    ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - '
                                                      || to_char(sysdate,'hh24:mi:ss')||' - '
                                                      || vr_glb_cdprogra ||' - RECEBIDA NAO OK    --> '
                                                      || 'Arquivo ' || RPAD(SUBSTR(vr_aux_nmarqxml,1,40),40,' ') || '. '
                                                      || 'Evento: ' || RPAD(SUBSTR(vr_aux_CodMsg,1,9),9,' ')
                                                      || ', Motivo Erro: ' || RPAD(SUBSTR(pr_msgderro,1,90),90,' ')
                                                      || ', Numero Controle: '|| RPAD(SUBSTR(vr_aux_nrctrole,1,20),20,' ')
                                                      || ', Hora: ' || to_char(sysdate,'HH24:MI:SS')
                                                      || ', Valor: ' || to_char(vr_aux_VlrLanc,'99g999g990d00')
                                                      || ', Banco Remet.: ' || gene0002.fn_mask(vr_aux_BancoDeb,'zz9')
                                                      || ', Agencia Remet.: ' || gene0002.fn_mask(vr_aux_AgDebtd,'zzz9')
                                                      || ', Conta Remet.: ' || RPAD(vr_aux_CtDebtd,20,' ')
                                                      || ', Nome Remet.: ' || rpad(substr(vr_aux_NomCliDebtd,1,40),40,' ')
                                                      || ', CPF/CNPJ Remet.: ' || gene0002.fn_mask(vr_aux_CNPJ_CPFDeb,'zzzzzzzzzzzzz9')
                                                      || ', Banco Dest.: ' || gene0002.fn_mask(vr_aux_BancoCre,'zz9')
                                                      || ', Agencia Dest.: ' || gene0002.fn_mask(vr_aux_AgCredtd,'zzz9')
                                                      || ', Conta Dest.: ' || gene0002.fn_mask(vr_aux_CtCredtd,'zzzzzzzzzzzzz9')
                                                      || ', Nome Dest.: ' || rpad(substr(vr_aux_NomCliCredtd,1,40),40,' ')
                                                      || ', CPF/CNPJ Dest.: ' || gene0002.fn_mask(vr_aux_CNPJ_CPFCred,'zzzzzzzzzzzzz9')
                                    ,pr_nmarqlog      => vr_nmarqlog);
          -- Gerar log da TED
          sspb0001.pc_grava_log_ted(pr_cdcooper => vr_cdcooper
                                   ,pr_dttransa => TRUNC(SYSDATE)
                                   ,pr_hrtransa => TO_CHAR(SYSDATE,'SSSSS')
                                   ,pr_idorigem => 1
                                   ,pr_cdprogra => vr_glb_cdprogra
                                   ,pr_idsitmsg => 4 /* Enviada Não Ok */
                                   ,pr_nmarqmsg => vr_aux_nmarqxml
                                   ,pr_nmevento => vr_aux_CodMsg
                                   ,pr_nrctrlif => vr_aux_nrctrole
                                   ,pr_vldocmto => vr_aux_VlrLanc
                                   ,pr_cdbanctl => vr_aux_BancoCre
                                   ,pr_cdagectl => vr_aux_AgCredtd
                                   ,pr_nrdconta => vr_aux_CtCredtd
                                   ,pr_nmcopcta => vr_aux_NomCliCredtd
                                   ,pr_nrcpfcop => vr_aux_CNPJ_CPFCred
                                   ,pr_cdbandif => vr_aux_BancoDeb
                                   ,pr_cdagedif => vr_aux_AgDebtd
                                   ,pr_nrctadif => vr_aux_CtDebtd
                                   ,pr_nmtitdif => vr_aux_NomCliDebtd
                                   ,pr_nrcpfdif => vr_aux_CNPJ_CPFDeb
                                   ,pr_cdidenti => ''
                                   ,pr_dsmotivo => pr_msgderro
                                   ,pr_cdagenci => 0
                                   ,pr_nrdcaixa => 0
                                   ,pr_cdoperad => '1'
                                   ,pr_nrispbif => vr_aux_ISPBIFCredtd
                                   ,pr_inestcri => vr_aux_inestcri
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
           IF vr_dscritic IS NOT NULL THEN
             vr_dscritic := 'Erro na gravacao de LOG TED: '||vr_dscritic;
             RAISE vr_exc_saida;
           END IF;
        ELSE
         -- Gerar log
          BTCH0001.pc_gera_log_batch(pr_cdcooper      => vr_cdcooper
                                    ,pr_ind_tipo_log  => 2 -- Erro não tratado
                                    ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - '
                                                      || to_char(sysdate,'hh24:mi:ss')||' - '
                                                      || vr_glb_cdprogra ||' - RECEBIDA OK        --> '
                                                      || 'Arquivo ' || RPAD(SUBSTR(vr_aux_nmarqxml,1,40),40,' ') || '. '
                                                      || 'Evento: ' || RPAD(SUBSTR(vr_aux_CodMsg,1,9),9,' ')
                                                      || ', Numero Controle: '|| RPAD(SUBSTR(vr_aux_nrctrole,1,20),20,' ')
                                                      || ', Hora: ' || to_char(sysdate,'HH24:MI:SS')
                                                      || ', Valor: ' || to_char(vr_aux_VlrLanc,'99g999g990d00')
                                                      || ', Banco Remet.: ' || gene0002.fn_mask(vr_aux_BancoDeb,'zz9')
                                                      || ', Agencia Remet.: ' || gene0002.fn_mask(vr_aux_AgDebtd,'zzz9')
                                                      || ', Conta Remet.: ' || RPAD(vr_aux_CtDebtd,20,' ')
                                                      || ', Nome Remet.: ' || rpad(substr(vr_aux_NomCliDebtd,1,40),40,' ')
                                                      || ', CPF/CNPJ Remet.: ' || gene0002.fn_mask(vr_aux_CNPJ_CPFDeb,'zzzzzzzzzzzzz9')
                                                      || ', Banco Dest.: ' || gene0002.fn_mask(vr_aux_BancoCre,'zz9')
                                                      || ', Agencia Dest.: ' || gene0002.fn_mask(vr_aux_AgCredtd,'zzz9')
                                                      || ', Conta Dest.: ' || gene0002.fn_mask(vr_aux_CtCredtd,'zzzzzzzzzzzzz9')
                                                      || ', Nome Dest.: ' || rpad(substr(vr_aux_NomCliCredtd,1,40),40,' ')
                                                      || ', CPF/CNPJ Dest.: ' || gene0002.fn_mask(vr_aux_CNPJ_CPFCred,'zzzzzzzzzzzzz9')
                                    ,pr_nmarqlog      => vr_nmarqlog);
          -- Gerar log da TED
          sspb0001.pc_grava_log_ted(pr_cdcooper => vr_cdcooper
                                   ,pr_dttransa => TRUNC(SYSDATE)
                                   ,pr_hrtransa => TO_CHAR(SYSDATE,'SSSSS')
                                   ,pr_idorigem => 1
                                   ,pr_cdprogra => vr_glb_cdprogra
                                   ,pr_idsitmsg => 3 /* Enviada Ok */
                                   ,pr_nmarqmsg => vr_aux_nmarqxml
                                   ,pr_nmevento => vr_aux_CodMsg
                                   ,pr_nrctrlif => vr_aux_nrctrole
                                   ,pr_vldocmto => vr_aux_VlrLanc
                                   ,pr_cdbanctl => vr_aux_BancoCre
                                   ,pr_cdagectl => vr_aux_AgCredtd
                                   ,pr_nrdconta => vr_aux_CtCredtd
                                   ,pr_nmcopcta => vr_aux_NomCliCredtd
                                   ,pr_nrcpfcop => vr_aux_CNPJ_CPFCred
                                   ,pr_cdbandif => vr_aux_BancoDeb
                                   ,pr_cdagedif => vr_aux_AgDebtd
                                   ,pr_nrctadif => vr_aux_CtDebtd
                                   ,pr_nmtitdif => vr_aux_NomCliDebtd
                                   ,pr_nrcpfdif => vr_aux_CNPJ_CPFDeb
                                   ,pr_cdidenti => ''
                                   ,pr_dsmotivo => pr_msgderro
                                   ,pr_cdagenci => 0
                                   ,pr_nrdcaixa => 0
                                   ,pr_cdoperad => '1'
                                   ,pr_nrispbif => vr_aux_ISPBIFCredtd
                                   ,pr_inestcri => vr_aux_inestcri
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
           IF vr_dscritic IS NOT NULL THEN
             vr_dscritic := 'Erro na gravacao de LOG TED: '||vr_dscritic;
             RAISE vr_exc_saida;
           END IF;
        END IF;
      ELSIF pr_tipodlog = 'SPB-STR-IF' THEN
        -- Acionar rotina de LOG
        BTCH0001.pc_gera_log_batch(pr_cdcooper      => vr_cdcooper
                                  ,pr_ind_tipo_log  => 2 -- Erro não tratado
                                  ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - '
                                                    || to_char(sysdate,'hh24:mi:ss')||' - '
                                                    || vr_glb_cdprogra ||' - '
                                                    || SUBSTR(vr_aux_CodMsg,1,18)||' --> '
                                                    || 'Arquivo ' || SUBSTR(vr_aux_nmarqxml,1,40) || '. '
                                                    || pr_msgderro || ' => ISPB ' || vr_aux_nrispbif
                                  ,pr_nmarqlog      => vr_nmarqlog);
      ELSIF pr_tipodlog = 'PAG0101' THEN
        -- Acionar rotina de LOG
        BTCH0001.pc_gera_log_batch(pr_cdcooper      => vr_cdcooper
                                  ,pr_ind_tipo_log  => 2 -- Erro não tratado
                                  ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - '
                                                    || to_char(sysdate,'hh24:mi:ss')||' - '
                                                    || vr_glb_cdprogra ||' - '
                                                    || SUBSTR(vr_aux_CodMsg,1,18)||' --> '
                                                    || 'Arquivo ' || SUBSTR(vr_aux_nmarqxml,1,40) || ' '
                                  ,pr_nmarqlog      => vr_nmarqlog);
      END IF;
    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Erro tratado, gerar em LOG
        BTCH0001.pc_gera_log_batch(pr_cdcooper      => vr_cdcooper
                                  ,pr_ind_tipo_log  => 2 -- Erro não tratado
                                  ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - '
                                                    || to_char(sysdate,'hh24:mi:ss')||' - '
                                                    || vr_glb_cdprogra ||' - ERRO GERACAO LOG   --> '
                                                    || 'Arquivo ' || RPAD(SUBSTR(vr_aux_nmarqxml,1,40),40,' ') || '. '
                                                    || 'Numero Controle: ' || RPAD(SUBSTR(vr_aux_NumCtrlIF,1,20),20,' ')
                                                    || ', Erro --> '||vr_dscritic
                                  ,pr_nmarqlog      => vr_nmarqlog);
      WHEN others THEN
        -- Erro nao tratado
        BTCH0001.pc_gera_log_batch(pr_cdcooper      => vr_cdcooper
                                  ,pr_ind_tipo_log  => 2 -- Erro não tratado
                                  ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - '
                                                    || to_char(sysdate,'hh24:mi:ss')||' - '
                                                    || vr_glb_cdprogra ||' - ERRO GERACAO LOG   --> '
                                                    || 'Arquivo ' || RPAD(SUBSTR(vr_aux_nmarqxml,1,40),40,' ') || '. '
                                                    || 'Numero Controle: ' || RPAD(SUBSTR(vr_aux_NumCtrlIF,1,20),20,' ')
                                                    || ', Erro Nao Tratado --> '||SQLERRM
                                  ,pr_nmarqlog      => vr_nmarqlog);
    END;

    /* Geracao de LOG no SPB para Transferencias */
    -- Cuidar ao mecher no log, pois os espacamentos e formats estao --
    -- ajustados para que a tela LOGSPB pegue os dados com SUBSTRING --
    PROCEDURE pc_gera_log_SPB_transferida(pr_cdcooper  IN crapcop.cdcooper%TYPE
                                         ,pr_cdbcoctl  IN crapcop.cdbcoctl%TYPE
                                         ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE
                                         ,pr_tipodlog  IN VARCHAR2
                                         ,pr_msgderro  IN VARCHAR2) IS
    BEGIN

      -- Trazer arquivo de log do mqcecred_processa
      vr_nmarqlog := 'mqcecred_processa_'||to_char(pr_dtmvtolt,'DDMMRR')||'.log';

      -- Geração de LOG conforme o tipo da mensagem
      IF pr_tipodlog = 'RECEBIDA' THEN
        /* Buscar dados do banco */
        OPEN cr_crapban(pr_nrispbif => vr_aux_ISPBIFDebtd);
        FETCH cr_crapban
         INTO rw_crapban;
        -- Se encontrou
        IF cr_crapban%FOUND THEN
          vr_aux_BancoDeb := rw_crapban.cdbccxlt;
        END IF;
        CLOSE cr_crapban;
        /* Banco CECRED */
        vr_aux_BancoCre := pr_cdbcoctl;
        IF trim(vr_aux_NumCtrlRem) IS NOT NULL THEN
          vr_aux_nrctrole := vr_aux_NumCtrlRem;
        ELSE
          vr_aux_nrctrole := vr_aux_NumCtrlIF;
        END IF;
        -- Se houve erro
        IF pr_msgderro IS NOT NULL THEN
          -- Gerar log
          BTCH0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                    ,pr_ind_tipo_log  => 2 -- Erro não tratado
                                    ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - '
                                                      || to_char(sysdate,'hh24:mi:ss')||' - '
                                                      || vr_glb_cdprogra ||' - RECEBIDA NAO OK    --> '
                                                      || 'Arquivo ' || RPAD(SUBSTR(vr_aux_nmarqxml,1,40),40,' ') || '. '
                                                      || 'Evento: ' || RPAD(SUBSTR(vr_aux_CodMsg,1,9),9,' ')
                                                      || ', Motivo Erro: ' || RPAD(SUBSTR(pr_msgderro,1,90),90,' ')
                                                      || ', Numero Controle: '|| RPAD(SUBSTR(vr_aux_nrctrole,1,20),20,' ')
                                                      || ', Hora: ' || to_char(sysdate,'HH24:MI:SS')
                                                      || ', Valor: ' || to_char(vr_aux_VlrLanc,'99g999g990d00')
                                                      || ', Banco Remet.: ' || gene0002.fn_mask(vr_aux_BancoDeb,'zz9')
                                                      || ', Agencia Remet.: ' || gene0002.fn_mask(vr_aux_AgDebtd,'zzz9')
                                                      || ', Conta Remet.: ' || RPAD(vr_aux_CtDebtd,20,' ')
                                                      || ', Nome Remet.: ' || rpad(substr(vr_aux_NomCliDebtd,1,40),40,' ')
                                                      || ', CPF/CNPJ Remet.: ' || gene0002.fn_mask(vr_aux_CNPJ_CPFDeb,'zzzzzzzzzzzzz9')
                                                      || ', Banco Dest.: ' || gene0002.fn_mask(vr_aux_BancoCre,'zz9')
                                                      || ', Agencia Dest.: ' || gene0002.fn_mask(vr_aux_AgCredtd,'zzz9')
                                                      || ', Conta Dest.: ' || gene0002.fn_mask(rw_craptco.nrdconta,'zzzzzzzzzzzzz9')
                                                      || ', Nome Dest.: ' || rpad(substr(vr_aux_NomCliCredtd,1,40),40,' ')
                                                      || ', CPF/CNPJ Dest.: ' || gene0002.fn_mask(vr_aux_CNPJ_CPFCred,'zzzzzzzzzzzzz9')
                                    ,pr_nmarqlog      => vr_nmarqlog);
          -- Gerar log da TED
          sspb0001.pc_grava_log_ted(pr_cdcooper => pr_cdcooper
                                   ,pr_dttransa => TRUNC(SYSDATE)
                                   ,pr_hrtransa => TO_CHAR(SYSDATE,'SSSSS')
                                   ,pr_idorigem => 1
                                   ,pr_cdprogra => vr_glb_cdprogra
                                   ,pr_idsitmsg => 4 /* Enviada Não Ok */
                                   ,pr_nmarqmsg => vr_aux_nmarqxml
                                   ,pr_nmevento => vr_aux_CodMsg
                                   ,pr_nrctrlif => vr_aux_nrctrole
                                   ,pr_vldocmto => vr_aux_VlrLanc
                                   ,pr_cdbanctl => vr_aux_BancoCre
                                   ,pr_cdagectl => vr_aux_AgCredtd
                                   ,pr_nrdconta => rw_craptco.nrdconta
                                   ,pr_nmcopcta => vr_aux_NomCliCredtd
                                   ,pr_nrcpfcop => vr_aux_CNPJ_CPFCred
                                   ,pr_cdbandif => vr_aux_BancoDeb
                                   ,pr_cdagedif => vr_aux_AgDebtd
                                   ,pr_nrctadif => vr_aux_CtDebtd
                                   ,pr_nmtitdif => vr_aux_NomCliDebtd
                                   ,pr_nrcpfdif => vr_aux_CNPJ_CPFDeb
                                   ,pr_cdidenti => ''
                                   ,pr_dsmotivo => pr_msgderro
                                   ,pr_cdagenci => 0
                                   ,pr_nrdcaixa => 0
                                   ,pr_cdoperad => '1'
                                   ,pr_nrispbif => vr_aux_ISPBIFCredtd
                                   ,pr_inestcri => vr_aux_inestcri
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
           IF vr_dscritic IS NOT NULL THEN
             vr_dscritic := 'Erro na gravacao de LOG TED: '||vr_dscritic;
             RAISE vr_exc_saida;
           END IF;
        ELSE
         -- Gerar log
          BTCH0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                    ,pr_ind_tipo_log  => 2 -- Erro não tratado
                                    ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - '
                                                      || to_char(sysdate,'hh24:mi:ss')||' - '
                                                      || vr_glb_cdprogra ||' - RECEBIDA OK        --> '
                                                      || 'Arquivo ' || RPAD(SUBSTR(vr_aux_nmarqxml,1,40),40,' ') || '. '
                                                      || 'Evento: ' || RPAD(SUBSTR(vr_aux_CodMsg,1,9),9,' ')
                                                      || ', Numero Controle: '|| RPAD(SUBSTR(vr_aux_nrctrole,1,20),20,' ')
                                                      || ', Hora: ' || to_char(sysdate,'HH24:MI:SS')
                                                      || ', Valor: ' || to_char(vr_aux_VlrLanc,'99g999g990d00')
                                                      || ', Banco Remet.: ' || gene0002.fn_mask(vr_aux_BancoDeb,'zz9')
                                                      || ', Agencia Remet.: ' || gene0002.fn_mask(vr_aux_AgDebtd,'zzz9')
                                                      || ', Conta Remet.: ' || RPAD(vr_aux_CtDebtd,20,' ')
                                                      || ', Nome Remet.: ' || rpad(substr(vr_aux_NomCliDebtd,1,40),40,' ')
                                                      || ', CPF/CNPJ Remet.: ' || gene0002.fn_mask(vr_aux_CNPJ_CPFDeb,'zzzzzzzzzzzzz9')
                                                      || ', Banco Dest.: ' || gene0002.fn_mask(vr_aux_BancoCre,'zz9')
                                                      || ', Agencia Dest.: ' || gene0002.fn_mask(vr_aux_AgCredtd,'zzz9')
                                                      || ', Conta Dest.: ' || gene0002.fn_mask(rw_craptco.nrdconta,'zzzzzzzzzzzzz9')
                                                      || ', Nome Dest.: ' || rpad(substr(vr_aux_NomCliCredtd,1,40),40,' ')
                                                      || ', CPF/CNPJ Dest.: ' || gene0002.fn_mask(vr_aux_CNPJ_CPFCred,'zzzzzzzzzzzzz9')
                                    ,pr_nmarqlog      => vr_nmarqlog);
          -- Gerar log da TED
          sspb0001.pc_grava_log_ted(pr_cdcooper => pr_cdcooper
                                   ,pr_dttransa => TRUNC(SYSDATE)
                                   ,pr_hrtransa => TO_CHAR(SYSDATE,'SSSSS')
                                   ,pr_idorigem => 1
                                   ,pr_cdprogra => vr_glb_cdprogra
                                   ,pr_idsitmsg => 3 /* Enviada Ok */
                                   ,pr_nmarqmsg => vr_aux_nmarqxml
                                   ,pr_nmevento => vr_aux_CodMsg
                                   ,pr_nrctrlif => vr_aux_nrctrole
                                   ,pr_vldocmto => vr_aux_VlrLanc
                                   ,pr_cdbanctl => vr_aux_BancoCre
                                   ,pr_cdagectl => vr_aux_AgCredtd
                                   ,pr_nrdconta => rw_craptco.nrdconta
                                   ,pr_nmcopcta => vr_aux_NomCliCredtd
                                   ,pr_nrcpfcop => vr_aux_CNPJ_CPFCred
                                   ,pr_cdbandif => vr_aux_BancoDeb
                                   ,pr_cdagedif => vr_aux_AgDebtd
                                   ,pr_nrctadif => vr_aux_CtDebtd
                                   ,pr_nmtitdif => vr_aux_NomCliDebtd
                                   ,pr_nrcpfdif => vr_aux_CNPJ_CPFDeb
                                   ,pr_cdidenti => ''
                                   ,pr_dsmotivo => pr_msgderro
                                   ,pr_cdagenci => 0
                                   ,pr_nrdcaixa => 0
                                   ,pr_cdoperad => '1'
                                   ,pr_nrispbif => vr_aux_ISPBIFCredtd
                                   ,pr_inestcri => vr_aux_inestcri
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
           IF vr_dscritic IS NOT NULL THEN
             vr_dscritic := 'Erro na gravacao de LOG TED: '||vr_dscritic;
             RAISE vr_exc_saida;
           END IF;
        END IF;
      END IF;
    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Erro tratado, gerar em LOG
        BTCH0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                  ,pr_ind_tipo_log  => 2 -- Erro não tratado
                                  ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - '
                                                    || to_char(sysdate,'hh24:mi:ss')||' - '
                                                    || vr_glb_cdprogra ||' - ERRO GERACAO LOG   --> '
                                                    || 'Arquivo ' || RPAD(SUBSTR(vr_aux_nmarqxml,1,40),40,' ') || '. '
                                                    || 'Numero Controle: ' || RPAD(SUBSTR(vr_aux_NumCtrlIF,1,20),20,' ')
                                                    || ', Erro --> '||vr_dscritic
                                  ,pr_nmarqlog      => vr_nmarqlog);
      WHEN others THEN
        -- Erro nao tratado
        BTCH0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                  ,pr_ind_tipo_log  => 2 -- Erro não tratado
                                  ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - '
                                                    || to_char(sysdate,'hh24:mi:ss')||' - '
                                                    || vr_glb_cdprogra ||' - ERRO GERACAO LOG   --> '
                                                    || 'Arquivo ' || RPAD(SUBSTR(vr_aux_nmarqxml,1,40),40,' ') || '. '
                                                    || 'Numero Controle: ' || RPAD(SUBSTR(vr_aux_NumCtrlIF,1,20),20,' ')
                                                    || ', Erro Nao Tratado --> '||SQLERRM
                                  ,pr_nmarqlog      => vr_nmarqlog);
    END;

    -- Cria registro da mensagem Devolvida
    PROCEDURE pc_cria_gnmvcen(pr_cdagenci IN PLS_INTEGER
                             ,pr_dtmvtolt IN DATE
                             ,pr_dsmensag IN VARCHAR2
                             ,pr_dsdebcre IN VARCHAR2
                             ,pr_vllanmto IN NUMBER
                             ,pr_dscritic OUT VARCHAR2) IS
    BEGIN
      INSERT INTO gnmvcen(cdagectl
                         ,dtmvtolt
                         ,dsmensag
                         ,dsdebcre
                         ,vllanmto)
                   VALUES(pr_cdagenci
                         ,pr_dtmvtolt
                         ,pr_dsmensag
                         ,pr_dsdebcre
                         ,pr_vllanmto);
    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Erro tratado
        pr_dscritic := 'Erro na rotina pc_cria_gnmvcen --> '||vr_dscritic;
      WHEN others THEN
        -- Erro nao tratado
        pr_dscritic := 'Erro nao tratado na rotina pc_cria_gnmvcen --> '||sqlerrm;
    END;

    /* SubRotina para geração de mensagem de erro em XML e envio a fila para devolução ao SPB */
    PROCEDURE pc_gera_erro_xml(pr_dsdehist  IN VARCHAR2
                              ,pr_codierro  IN NUMBER
                              ,pr_dscritic OUT VARCHAR2) IS
      -- Variavies auxiliares
      vr_cdagectl      crapcop.cdagectl%TYPE;
      vr_cdcooper      crapcop.cdcooper%TYPE;
      vr_dsdircop      VARCHAR2(4000);
      vr_aux_cdMsg_dev VARCHAR2(100);
      vr_ioarquiv      utl_file.file_type;
      vr_nmarquiv      VARCHAR2(1000);
      vr_aux_dsarqenv  VARCHAR2(32767);
      -- Comando SO
      vr_dsparam VARCHAR2(4000);
      vr_comando VARCHAR2(4000);
    BEGIN

      -- Se já foi lida a Cooperativa da mensagem
      IF rw_crapcop_mensag.cdcooper IS NOT NULL THEN
        -- Usaremos ela
        vr_cdcooper := rw_crapcop_mensag.cdcooper;
        vr_cdagectl := rw_crapcop_mensag.cdagectl;
        vr_dsdircop := rw_crapcop_mensag.dsdircop;
      ELSE
        -- Usaremos a global
        vr_cdcooper := rw_crapcop_central.cdcooper;
        vr_cdagectl := rw_crapcop_central.cdagectl;
        vr_dsdircop := rw_crapcop_central.dsdircop;
      END IF;

      -- Buscar o calendário
      OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      FETCH btch0001.cr_crapdat
       INTO rw_crapdat_mensag;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
        RETURN;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      -- Montar nome do arquivo
      vr_nmarquiv := 'msge_cecred_'
                  /* para evitar duplicidade devido paralelismo */
                  || to_char(SYSTIMESTAMP,'rrrrmmddsssssff3')
                  || to_char(SEQ_TEDENVIO.nextval,'fm000') || '.xml';
      vr_aux_CdLegado := to_char(vr_cdagectl);
      IF vr_aux_CodMsg IN ('STR0037R2','PAG0137R2') THEN
        vr_aux_cdtiptrf := 2; /* TEC */
      ELSE
        vr_aux_cdtiptrf := 1; /* TED */
      END IF;

      vr_aux_NumCtrlIF := vr_aux_cdtiptrf
                       || to_char(SYSDATE,'rrmmdd')
                       || to_char(vr_cdagectl,'fm0000')
                       || to_char(SYSDATE,'sssss')
                         /* para evitar duplicidade devido paralelismo */
                       || to_char(SEQ_TEDENVIO.nextval,'fm000')
                       || 'A'; /* origem AYLLOS */

      -- Montar o XML
      vr_aux_dsarqenv := '<SISMSG>'
                      ||   '<SEGCAB>'
                      ||     '<CD_LEGADO>' || vr_aux_CdLegado || '</CD_LEGADO>'
                      ||     '<TP_MANUT>I</TP_MANUT>'
                      ||     '<CD_STATUS>D</CD_STATUS>'
                      ||     '<NR_OPERACAO>'|| vr_aux_NumCtrlIF || '</NR_OPERACAO>'
                      ||     '<FL_DEB_CRED>D</FL_DEB_CRED>'
                      ||   '</SEGCAB>';
      -- Montagem do XML conforme tipo da mensagem
      IF vr_aux_CodMsg IN('STR0005R2','STR0007R2','STR0008R2','STR0026R2','STR0037R2','STR0006R2','STR0025R2','STR0034R2') THEN
        vr_aux_cdMsg_dev := 'STR0010';
        -- Continuar XML
        vr_aux_dsarqenv := vr_aux_dsarqenv
                        || '<STR0010>'
                        ||   '<CodMsg>STR0010</CodMsg>'
                        ||   '<NumCtrlIF>' || vr_aux_NumCtrlIF || '</NumCtrlIF>'
                        ||   '<ISPBIFDebtd>' || vr_aux_ISPBIFCredtd || '</ISPBIFDebtd>'
                        ||   '<ISPBIFCredtd>' || vr_aux_ISPBIFDebtd || '</ISPBIFCredtd>'
                        ||   '<VlrLanc>' || vr_aux_DsVlrLanc || '</VlrLanc>'
                        ||   '<CodDevTransf>' || to_char(pr_codierro) ||'</CodDevTransf>'
                        ||   '<NumCtrlSTROr>' || vr_aux_NumCtrlRem || '</NumCtrlSTROr>'
                        /* Descricao Critica */
                        ||   '<Hist>' || pr_dsdehist || '</Hist>'
                        ||   '<DtMovto>'  || vr_aux_DtMovto || '</DtMovto>'
                        || '</STR0010>';
      ELSIF vr_aux_CodMsg IN('PAG0107R2','PAG0108R2','PAG0137R2','PAG0143R2','PAG0121R2','PAG0142R2','PAG0134R2') THEN
        vr_aux_cdMsg_dev := 'PAG0111';
        -- Continuar XML
        vr_aux_dsarqenv := vr_aux_dsarqenv
                        || '<PAG0111>'
                        ||   '<CodMsg>PAG0111</CodMsg>'
                        ||   '<NumCtrlIF>' || vr_aux_NumCtrlIF || '</NumCtrlIF>'
                        ||   '<ISPBIFDebtd>' || vr_aux_ISPBIFCredtd || '</ISPBIFDebtd>'
                        ||   '<ISPBIFCredtd>' || vr_aux_ISPBIFDebtd || '</ISPBIFCredtd>'
                        ||   '<VlrLanc>' || vr_aux_DsVlrLanc || '</VlrLanc>'
                        ||   '<CodDevTransf>' || to_char(pr_codierro) ||'</CodDevTransf>'
                        ||   '<NumCtrlPAGOr>' || vr_aux_NumCtrlRem || '</NumCtrlPAGOr>'
                        /* Descricao Critica */
                        ||   '<Hist>' || pr_dsdehist || '</Hist>'
                        ||   '<DtMovto>' || vr_aux_DtMovto || '</DtMovto>'
                        || '</PAG0111>';
      ELSE
        vr_aux_cdMsg_dev := 'STR0048';
        -- Continuar XML
        vr_aux_dsarqenv := vr_aux_dsarqenv
                        || '<STR0048>'
                        ||   '<CodMsg>STR0048</CodMsg>'
                        ||   '<NumCtrlIF>' || vr_aux_NumCtrlIF || '</NumCtrlIF>'
                        ||   '<ISPBIFDebtd>' || vr_aux_ISPBIFCredtd ||'</ISPBIFDebtd>'
                        ||   '<ISPBIFCredtd>' || vr_aux_ISPBIFDebtd ||'</ISPBIFCredtd>'
                        ||   '<VlrLanc>' || vr_aux_DsVlrLanc || '</VlrLanc>'
                        ||   '<CodDevPortdd>' || TO_CHAR(pr_codierro) || '</CodDevPortdd>'
                        ||   '<NumCtrlSTROr>' || vr_aux_NumCtrlRem || '</NumCtrlSTROr>'
                        ||   '<ISPBPrestd>29011780</ISPBPrestd>'
                        /* Descricao Critica */
                        ||   '<Hist>' || pr_dsdehist || '</Hist>'
                        ||   '<DtMovto>' || vr_aux_DtMovto || '</DtMovto>'
                        || '</STR0048>';
      END IF;
      -- Encerar o XML
      vr_aux_dsarqenv := vr_aux_dsarqenv || '</SISMSG>';

      -- Gerar o XML em arquivo
      gene0001.pc_abre_arquivo(pr_nmdireto => vr_dsdircop || '/salvar' --> Diretorio do arquivo
                              ,pr_nmarquiv => vr_nmarquiv          --> Nome do arquivo
                              ,pr_tipabert => 'W'                  --> Modo de abertura (R,W,A)
                              ,pr_utlfileh => vr_ioarquiv        --> Handle do arquivo aberto
                              ,pr_des_erro => vr_dscritic);        --> Erro
      IF vr_dscritic IS NOT NULL OR NOT utl_file.IS_OPEN(vr_ioarquiv) THEN
        -- Levantar Excecao
        vr_dscritic := 'Erro na abertura do arquivo ['||vr_nmarquiv||'] para escrita --> '||vr_dscritic;
        RAISE vr_exc_saida;
      END IF;

      -- Escrever no arquivo o XML montado
      gene0001.pc_escr_texto_arquivo(pr_utlfileh => vr_ioarquiv
                                    ,pr_des_text => vr_aux_dsarqenv);
      -- Fechar arquivos pois terminamos a escrita
      gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ioarquiv);

      -- Ajustar a variavel para compreender na mesma o caminho completo
      vr_nmarquiv := vr_dsdircop || '/salvar/' || vr_nmarquiv;

      -- Buscar comando MQ
      vr_dsparam := gene0001.fn_param_sistema('CRED',pr_cdcooper,'MQ_SUDO_ENVIA');
      -- Se nao encontrou sai com erro
      IF vr_dsparam IS NULL THEN
        -- Montar mensagem de erro
        vr_dscritic := 'Não foi encontrado diretório para execução MQ.';
        -- Levantar Exceção
        RAISE vr_exc_saida;
      END IF;

      -- Montar comando
      -- /usr/local/bin/exec_comando_oracle.sh mqcecred_envia (conforme solicitacao Tiago Wagner)
      vr_comando := '/usr/local/bin/exec_comando_oracle.sh mqcecred_envia ' || Chr(39) || vr_aux_dsarqenv || Chr(39) || ' '
                                                                            || Chr(39) || to_char(pr_cdcooper) || Chr(39) || ' '
                                                                            || Chr(39) || vr_nmarquiv || Chr(39);

      -- Enviar o XML para a fila do MQ
      GENE0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => vr_comando
                           ,pr_typ_saida   => vr_typ_saida
                           ,pr_des_saida   => vr_dscritic);
      --Se ocorreu erro dar RAISE
      IF vr_typ_saida = 'ERR' THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Nao foi possivel executar comando unix. Erro '|| vr_dscritic||': '||vr_comando;
        RAISE vr_exc_saida;
      END IF;

      -- Tratamento incorporação Transposul
      -- Necessario retornar os valores originais para apresentar no LOG
      IF vr_aux_cdageinc > 0 THEN /* Agencia incorporada */
        vr_aux_AgCredtd := to_char(vr_aux_cdageinc,'fm0000');
      END IF;
      -- Gera LOG SPB
      pc_gera_log_SPB(pr_tipodlog  => 'RECEBIDA'
                     ,pr_msgderro  => vr_log_msgderro);

      -- Cria registro da mensagem Devolvida
      pc_cria_gnmvcen(pr_cdagenci => vr_cdagectl
                     ,pr_dtmvtolt => rw_crapdat_mensag.dtmvtolt
                     ,pr_dsmensag => vr_aux_cdMsg_dev
                     ,pr_dsdebcre => 'C'
                     ,pr_vllanmto => vr_aux_VlrLanc
                     ,pr_dscritic => vr_dscritic);
      -- Se retornou erro
      IF vr_dscritic IS NOT NULL THEN
        -- Acionar rotina de LOG
        BTCH0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                  ,pr_ind_tipo_log  => 2 -- Erro não tratado
                                  ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - ' || to_char(sysdate,'hh24:mi:ss')
                                                    ||' - '|| vr_glb_cdprogra ||' --> '
                                                    || 'Erro na Execucao Paralela - '
                                                    || 'PID: ' || pr_idparale || ' '
                                                    || 'Seq.: ' || to_char(pr_idprogra,'fm99990') ||' '
                                                    || 'Mensagem: ' || vr_aux_nmarqxml || ' '
                                                    || 'Na Rotina pc_cria_gnmvcen --> '||vr_dscritic
                                  ,pr_nmarqlog      => vr_logprogr
                                  ,pr_cdprograma    => vr_glb_cdprogra
                                  ,pr_dstiplog      => 'E'
                                  ,pr_tpexecucao    => 3
                                  ,pr_cdcriticidade => 0
                                  ,pr_flgsucesso    => 1);
      END IF;

      -- Gravar a mensagem de TED devolvida
      SSPB0003.pc_grava_mensagem_ted(pr_cdcooper    => vr_cdcooper
                                    ,pr_nrctrlif    => vr_aux_NumCtrlIF
                                    ,pr_dtmensagem  => to_date(vr_aux_DtMovto,'RRRR-MM-DD')
                                    ,pr_nmevento    => vr_aux_cdMsg_dev
                                    ,pr_dsxml       => vr_aux_dsarqenv
                                    ,pr_cdprograma  => vr_glb_cdprogra
                                    ,pr_cdcritic    => vr_cdcritic
                                    ,pr_dscritic    => vr_dscritic);
      -- Se retornou erro
      IF vr_dscritic IS NOT NULL THEN
        -- Acionar rotina de LOG
        BTCH0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                  ,pr_ind_tipo_log  => 2 -- Erro não tratado
                                  ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - ' || to_char(sysdate,'hh24:mi:ss')
                                                    ||' - '|| vr_glb_cdprogra ||' --> '
                                                    || 'Erro na Execucao Paralela - '
                                                    || 'PID: ' || pr_idparale || ' '
                                                    || 'Seq.: ' || to_char(pr_idprogra,'fm99990') ||' '
                                                    || 'Mensagem: ' || vr_aux_nmarqxml|| ' '
                                                    || 'Na Rotina pc_grava_mensagem_ted --> '||vr_dscritic
                                  ,pr_nmarqlog      => vr_logprogr
                                  ,pr_cdprograma    => vr_glb_cdprogra
                                  ,pr_dstiplog      => 'E'
                                  ,pr_tpexecucao    => 3
                                  ,pr_cdcriticidade => 0
                                  ,pr_flgsucesso    => 1
                                  ,pr_cdmensagem    => vr_cdcritic);
      END IF;

      -- Gravar a mensagem de TED devolvida como rejeitada
      SSPB0003.pc_grava_msg_ted_rejeita(pr_cdcooper => vr_cdcooper                                  --> Cooperativa
                                       ,pr_nrdconta => vr_aux_CtCredtd                              --> Conta
                                       ,pr_cdagenci => vr_glb_cdagenci                              --> Agencia
                                       ,pr_nrdcaixa => 0                                            --> Numero do Caixa
                                       ,pr_cdoperad => '1'                                          --> Operador
                                       ,pr_cdprogra => vr_glb_cdprogra                              --> Programa que chamou
                                       ,pr_nmevento => vr_aux_cdMsg_dev                             --> Evento
                                       ,pr_nrctrlif => vr_aux_NumCtrlIF                             --> Numero de controle
                                       ,pr_vldocmto => vr_aux_VlrLanc --> Valor
                                       -- Dados de Origem da TED (Informações da Conta na CENTRAL)
                                       ,pr_cdbanco_origem   => vr_aux_BancoCre       --> Banco
                                       ,pr_cdagencia_origem => vr_aux_AgCredtd       --> Agencia
                                       ,pr_nmtitular_origem => vr_aux_NomCliCredtd   --> Nome do Titular
                                       ,pr_nrcpf_origem     => vr_aux_CNPJ_CPFCred   --> CPF do Titular
                                       -- Dados de Destino da TED (Informações da Conta em outra IF)
                                       ,pr_cdbanco_destino   => vr_aux_BancoDeb     --> Banco
                                       ,pr_cdagencia_destino => vr_aux_AgDebtd      --> Agencia
                                       ,pr_nrconta_destino   => vr_aux_CtDebtd      --> Conta
                                       ,pr_nmtitular_destino => vr_aux_NomCliDebtd  --> Nome do Titular
                                       ,pr_nrcpf_destino     => vr_aux_CNPJ_CPFDeb  --> CPF do Titular
                                       -- Rejeição
                                       ,pr_dsmotivo_rejeicao => pr_dsdehist        --> Motivo da Rejeição
                                       ,pr_nrispbif          => vr_aux_ISPBIFDebtd --> ISPB
                                       ,pr_cdcritic    => vr_cdcritic
                                       ,pr_dscritic    => vr_dscritic);
      -- Se retornou erro
      IF vr_dscritic IS NOT NULL THEN
        -- Acionar rotina de LOG
        BTCH0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                  ,pr_ind_tipo_log  => 2 -- Erro não tratado
                                  ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - ' || to_char(sysdate,'hh24:mi:ss')
                                                    ||' - '|| vr_glb_cdprogra ||' --> '
                                                    || 'Erro na Execucao Paralela - '
                                                    || 'PID: ' || pr_idparale || ' '
                                                    || 'Seq.: ' || to_char(pr_idprogra,'fm99990') ||' '
                                                    || 'Mensagem: ' || ' '
                                                    || 'Na Rotina pc_grava_mensagem_ted --> '||vr_dscritic
                                  ,pr_nmarqlog      => vr_logprogr
                                  ,pr_cdprograma    => vr_glb_cdprogra
                                  ,pr_dstiplog      => 'E'
                                  ,pr_tpexecucao    => 3
                                  ,pr_cdcriticidade => 0
                                  ,pr_flgsucesso    => 1
                                  ,pr_cdmensagem    => vr_cdcritic);
      END IF;

    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Fechar arquivos caso abertos
        IF utl_file.IS_OPEN(vr_ioarquiv) THEN
          gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ioarquiv);
        END IF;
        -- Erro tratado
        pr_dscritic := 'Erro na rotina pc_gera_erro_xml --> '||vr_dscritic;
      WHEN others THEN
        -- Fechar arquivos caso abertos
        IF utl_file.IS_OPEN(vr_ioarquiv) THEN
          gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ioarquiv);
        END IF;
        -- Erro nao tratado
        pr_dscritic := 'Erro nao tratado na rotina pc_gera_erro_xml --> '||sqlerrm;
    END;

    -- Subrotina para efetuar leitura das informações do XML para dentro das variaveis
    PROCEDURE pc_importa_xml(pr_dscritic OUT VARCHAR2) IS

      -- Variaveis específicas deste
      vr_dscomora          VARCHAR2(4000);
      vr_dsdirbin          VARCHAR2(4000);
      vr_comando           VARCHAR2(4000);
      vr_aux_cdagectl_pesq PLS_INTEGER;
      vr_aux_nro_controle  VARCHAR2(100);
      vr_nmdirarq          VARCHAR2(1000);
      vr_nmarquiv          VARCHAR2(1000);
      vr_nmarqutp          VARCHAR2(1000);
      vr_input_file        UTL_FILE.file_type;
      vr_output_file       UTL_FILE.file_type;
      vr_getlinha          varchar2(32767);
      vr_setlinha          varchar2(32767);
      vr_txtmensg          varchar2(32767);
      vr_aux_msgspb_xml    varchar2(32767);

      -- Documento
      vr_xmltype         xmlType;
      vr_parser          xmlparser.Parser;
      vr_doc             xmldom.DOMDocument;

      -- Root
      vr_node_root       xmldom.DOMNodeList;
      vr_item_root       xmldom.DOMNode;
      vr_elem_root       xmldom.DOMElement;

      -- SubItens
      vr_node_list       xmldom.DOMNodeList;
      vr_node_name       VARCHAR2(100);
      vr_item_node       xmldom.DOMNode;
      vr_elem_node       xmldom.DOMElement;

      -- SubItens da SEGCAB
      vr_node_list_segcab xmldom.DOMNodeList;
      vr_node_name_segcab VARCHAR2(100);
      vr_item_node_segcab xmldom.DOMNode;
      vr_valu_node_segcab xmldom.DOMNode;

      -- SubRotina para tratar a cabINF
      PROCEDURE pc_trata_CABinf(pr_node_cabinf IN xmldom.DOMNode
                               ,pr_dscritic   OUT VARCHAR2) IS
        -- SubItens da CABINF
        vr_elem_node_cabinf xmldom.DOMElement;
        vr_node_list_cabinf xmldom.DOMNodeList;
        vr_node_name_cabinf VARCHAR2(100);
        vr_item_node_cabinf xmldom.DOMNode;
        vr_valu_node_cabinf xmldom.DOMNode;

        -- SubItens da GrupoErro
        vr_elem_node_grperr xmldom.DOMElement;
        vr_node_list_grperr xmldom.DOMNodeList;
        vr_node_name_grperr VARCHAR2(100);
        vr_item_node_grperr xmldom.DOMNode;
        vr_valu_node_grperr xmldom.DOMNode;
      BEGIN
        -- Ativar flag
        vr_aux_tagCABInf := TRUE;
        -- Buscar todos os filhos deste nó
        vr_elem_node_cabinf := xmldom.makeElement(pr_node_cabinf);
        -- Faz o get de toda a lista de filhos da CABINF
        vr_node_list_cabinf := xmldom.getChildrenByTagName(vr_elem_node_cabinf,'*');
        -- Percorrer os elementos
        FOR i IN 0..xmldom.getLength(vr_node_list_cabinf)-1 LOOP
          -- Buscar o item atual
          vr_item_node_cabinf := xmldom.item(vr_node_list_cabinf, i);
          -- Captura o nome e tipo do nodo
          vr_node_name_cabinf := xmldom.getNodeName(vr_item_node_cabinf);
          -- Sair se o nodo não for elemento
          IF xmldom.getNodeType(vr_item_node_cabinf) <> xmldom.ELEMENT_NODE THEN
            CONTINUE;
          END IF;
          -- Para a tag CodMsg
          IF vr_node_name_cabinf = 'CodMsg' THEN
            -- Buscar valor da TAG
            vr_valu_node_cabinf := xmldom.getFirstChild(vr_item_node_cabinf);
            vr_aux_CodMsg       := xmldom.getNodeValue(vr_valu_node_cabinf);
          -- Para a tag NumCtrlIF
          ELSIF vr_node_name_cabinf = 'NumCtrlIF' THEN
            -- Buscar valor da TAG
            vr_valu_node_cabinf := xmldom.getFirstChild(vr_item_node_cabinf);
            vr_aux_NumCtrlIF    := xmldom.getNodeValue(vr_valu_node_cabinf);
          -- Erro de Inconsistencia
          ELSIF vr_node_name_cabinf = 'GrupoTagErro' THEN
            -- Buscar Nodos Filhos
            vr_elem_node_grperr := xmldom.makeElement(vr_item_node_cabinf);
            -- Faz o get de toda a lista de filhos da GrupoTabErro
            vr_node_list_grperr := xmldom.getChildrenByTagName(vr_elem_node_grperr,'*');
            -- Percorrer os elementos
            FOR i IN 0..xmldom.getLength(vr_node_list_grperr)-1 LOOP
              -- Buscar o item atual
              vr_item_node_grperr := xmldom.item(vr_node_list_grperr, i);
              -- Captura o nome e tipo do nodo
              vr_node_name_grperr := xmldom.getNodeName(vr_item_node_grperr);
              -- Sair se o nodo não for elemento
              IF xmldom.getNodeType(vr_item_node_grperr) <> xmldom.ELEMENT_NODE THEN
                CONTINUE;
              END IF;
              -- Para o node CodErro
              IF vr_node_name_grperr = 'CodErro' THEN
                -- Buscar valor da TAG
                vr_valu_node_grperr := xmldom.getFirstChild(vr_item_node_grperr);
                vr_aux_msgderro     := vr_aux_msgderro||', '||xmldom.getNodeValue(vr_valu_node_grperr);
                -- Remover virgula a esquerda que fica quando é a primeira atribuição
                vr_aux_msgderro := LTRIM(vr_aux_msgderro,', ');
              -- Para o node TagErro
              ELSIF vr_node_name_grperr = 'TagErro' THEN
                -- Buscar valor da TAG
                vr_valu_node_grperr := xmldom.getFirstChild(vr_item_node_grperr);
                vr_aux_msgderro     := vr_aux_msgderro||', '||xmldom.getNodeValue(vr_valu_node_grperr);
                -- Remover virgula a esquerda que fica quando é a primeira atribuição
                vr_aux_msgderro := LTRIM(vr_aux_msgderro,', ');
              END IF;
            END LOOP;
          END IF;
        END LOOP;
      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := 'Erro no tratamento do Node pc_trata_CABinf -->'||sqlerrm;
      END;

      -- SubRotina para tratar a IFs
      PROCEDURE pc_trata_IFs(pr_node      IN xmldom.DOMNode
                            ,pr_dscritic OUT VARCHAR2) IS

        -- SubItens da PAG0101/STR0018/STR0019
        vr_elem_node xmldom.DOMElement;
        vr_node_list xmldom.DOMNodeList;
        vr_node_name VARCHAR2(100);
        vr_item_node xmldom.DOMNode;
        vr_valu_node xmldom.DOMNode;

        -- SubItens da GrupoSit
        vr_elem_node_grpsit xmldom.DOMElement;
        vr_node_list_grpsit xmldom.DOMNodeList;
        vr_node_name_grpsit VARCHAR2(100);
        vr_item_node_grpsit xmldom.DOMNode;
        vr_valu_node_grpsit xmldom.DOMNode;

        -- Genéricas
        vr_idx_grpsit       NUMBER := 0;
        vr_aux_descrica     VARCHAR2(1000);
      BEGIN
        -- Reiniciar globais
        vr_aux_nrispbif := 0;
        vr_aux_cddbanco := 0;
        vr_aux_nmdbanco := null;

        -- Buscar todos os filhos deste nó
        vr_elem_node := xmldom.makeElement(pr_node);
        -- Faz o get de toda a lista de filhos do nó passado
        vr_node_list := xmldom.getChildrenByTagName(vr_elem_node,'*');
        -- Percorrer os elementos
        FOR i IN 0..xmldom.getLength(vr_node_list)-1 LOOP
          -- Buscar o item atual
          vr_item_node := xmldom.item(vr_node_list, i);
          -- Captura o nome e tipo do nodo
          vr_node_name := xmldom.getNodeName(vr_item_node);
          -- Sair se o nodo não for elemento
          IF xmldom.getNodeType(vr_item_node) <> xmldom.ELEMENT_NODE THEN
            CONTINUE;
          END IF;
          -- Para Pag0101
          IF vr_node_name = 'Grupo_PAG0101_SitIF' THEN
            -- Mensagem
            vr_aux_CodMsg := 'PAG0101';
            -- Busca os dados da IF Ativa
            vr_elem_node_grpsit := xmldom.makeElement(vr_item_node);
            -- Faz o get de toda a lista de filhos da GrupoTabErro
            vr_node_list_grpsit := xmldom.getChildrenByTagName(vr_elem_node_grpsit,'*');
            -- Percorrer os elementos
            FOR i IN 0..xmldom.getLength(vr_node_list_grpsit)-1 LOOP
              -- Buscar o item atual
              vr_item_node_grpsit := xmldom.item(vr_node_list_grpsit, i);
              -- Captura o nome e tipo do nodo
              vr_node_name_grpsit := xmldom.getNodeName(vr_item_node_grpsit);
              -- Sair se o nodo não for elemento
              IF xmldom.getNodeType(vr_item_node_grpsit) <> xmldom.ELEMENT_NODE THEN
                CONTINUE;
              END IF;
              -- Criar registro na PLTABLE
              vr_idx_grpsit := vr_tab_situacao_if.COUNT()+1;
              -- Para o node ISPBIF
              IF vr_node_name_grpsit = 'ISPBIF' THEN
                -- Buscar valor da TAG
                vr_valu_node_grpsit := xmldom.getFirstChild(vr_item_node_grpsit);
                vr_tab_situacao_if(vr_idx_grpsit).nrispbif := GENE0002.fn_char_para_number(xmldom.getNodeValue(vr_valu_node_grpsit));
              -- Outros
              ELSE
                -- Buscar valor da TAG
                vr_valu_node_grpsit := xmldom.getFirstChild(vr_item_node_grpsit);
                vr_tab_situacao_if(vr_idx_grpsit).cdsitope := GENE0002.fn_char_para_number(xmldom.getNodeValue(vr_valu_node_grpsit));
              END IF;
            END LOOP;
          ELSE
            -- Buscar primeiro filho do nó para buscar seu valor em lógica única
            vr_valu_node := xmldom.getFirstChild(vr_item_node);
            vr_aux_descrica := xmldom.getNodeValue(vr_valu_node);
            -- Copiar para a respectiva variavel conforme nome da tag
            IF vr_node_name = 'CodMsg' THEN
              vr_aux_CodMsg := vr_aux_descrica;
            ELSIF vr_node_name = 'CodProdt' THEN
              vr_aux_CodProdt := vr_aux_descrica;
            ELSIF vr_node_name IN('ISPBPartIncld_Altd','ISPBPartExcl') THEN
              vr_aux_nrispbif := GENE0002.fn_char_para_number(vr_aux_descrica);
            ELSIF vr_node_name = 'NumCodIF' THEN
              vr_aux_cddbanco := GENE0002.fn_char_para_number(vr_aux_descrica);
            ELSIF vr_node_name = 'NomPart'  THEN
              vr_aux_nmdbanco := vr_aux_descrica;
            ELSIF vr_node_name = 'DtIniOp' THEN
              vr_aux_dtinispb := vr_aux_descrica;
            END IF;
          END IF;
        END LOOP;
      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := 'Erro no tratamento do Node pc_trata_IFs -->'||sqlerrm;
      END;

      -- SubRotina para tratar Portabilidade de Crédito
      PROCEDURE pc_trata_portabilidade(pr_node      IN xmldom.DOMNode
                                      ,pr_dscritic OUT VARCHAR2) IS

        -- SubItens da STR0047R2
        vr_elem_node xmldom.DOMElement;
        vr_node_list xmldom.DOMNodeList;
        vr_node_name VARCHAR2(100);
        vr_item_node xmldom.DOMNode;
        vr_valu_node xmldom.DOMNode;

        -- SubItens de Grupo
        vr_elem_node_grpsit xmldom.DOMElement;
        vr_node_list_grpsit xmldom.DOMNodeList;
        vr_node_name_grpsit VARCHAR2(100);
        vr_item_node_grpsit xmldom.DOMNode;
        vr_valu_node_grpsit xmldom.DOMNode;

        -- Genéricas
        vr_aux_descrica     VARCHAR2(1000);

      BEGIN
        -- Reiniciar globais
        vr_aux_CodMsg := 'STR0047R2';

        -- Buscar todos os filhos deste nó
        vr_elem_node := xmldom.makeElement(pr_node);
        -- Faz o get de toda a lista de filhos
        vr_node_list := xmldom.getChildrenByTagName(vr_elem_node,'*');
        -- Percorrer os elementos
        FOR i IN 0..xmldom.getLength(vr_node_list)-1 LOOP
          -- Buscar o item atual
          vr_item_node := xmldom.item(vr_node_list, i);
          -- Captura o nome e tipo do nodo
          vr_node_name := xmldom.getNodeName(vr_item_node);
          -- Sair se o nodo não for elemento
          IF xmldom.getNodeType(vr_item_node) <> xmldom.ELEMENT_NODE THEN
            CONTINUE;
          END IF;

          -- Para AgeFinDed
          IF vr_node_name = 'Grupo_STR0047R2_AgtFinancDebtd' THEN
            -- Busca filhos
            vr_elem_node_grpsit := xmldom.makeElement(vr_item_node);
            -- Faz o get de toda a lista de filhos
            vr_node_list_grpsit := xmldom.getChildrenByTagName(vr_elem_node_grpsit,'*');
            -- Percorrer os elementos
            FOR i IN 0..xmldom.getLength(vr_node_list_grpsit)-1 LOOP
              -- Buscar o item atual
              vr_item_node_grpsit := xmldom.item(vr_node_list_grpsit, i);
              -- Captura o nome e tipo do nodo
              vr_node_name_grpsit := xmldom.getNodeName(vr_item_node_grpsit);
              -- Sair se o nodo não for elemento
              IF xmldom.getNodeType(vr_item_node_grpsit) <> xmldom.ELEMENT_NODE THEN
                CONTINUE;
              END IF;
              -- Para o node CtDebtd
              IF vr_node_name_grpsit = 'CtDebtd' THEN
                -- Buscar valor da TAG
                vr_valu_node_grpsit := xmldom.getFirstChild(vr_item_node_grpsit);
                vr_aux_CtDebtd := xmldom.getNodeValue(vr_valu_node_grpsit);
              END IF;
            END LOOP;
          -- Para AgeFinCre
          ELSIF vr_node_name = 'Grupo_STR0047R2_AgtFinancCredtd' THEN
            -- Busca filhos
            vr_elem_node_grpsit := xmldom.makeElement(vr_item_node);
            -- Faz o get de toda a lista de filhos
            vr_node_list_grpsit := xmldom.getChildrenByTagName(vr_elem_node_grpsit,'*');
            -- Percorrer os elementos
            FOR i IN 0..xmldom.getLength(vr_node_list_grpsit)-1 LOOP
              -- Buscar o item atual
              vr_item_node_grpsit := xmldom.item(vr_node_list_grpsit, i);
              -- Captura o nome e tipo do nodo
              vr_node_name_grpsit := xmldom.getNodeName(vr_item_node_grpsit);
              -- Sair se o nodo não for elemento
              IF xmldom.getNodeType(vr_item_node_grpsit) <> xmldom.ELEMENT_NODE THEN
                CONTINUE;
              END IF;
              -- Para o node CtCredtd
              IF vr_node_name_grpsit = 'CtCredtd' THEN
                -- Buscar valor da TAG
                vr_valu_node_grpsit := xmldom.getFirstChild(vr_item_node_grpsit);
                vr_aux_CtCredtd     := xmldom.getNodeValue(vr_valu_node_grpsit);
              -- CNPJ
              ELSIF vr_node_name_grpsit = 'CNPJCliCredtd' THEN
                -- Buscar valor da TAG
                vr_valu_node_grpsit := xmldom.getFirstChild(vr_item_node_grpsit);
                vr_aux_CNPJ_CPFCred := xmldom.getNodeValue(vr_valu_node_grpsit);
              -- Nome
              ELSIF vr_node_name_grpsit = 'NomCliCredtd' THEN
                -- Buscar valor da TAG
                vr_valu_node_grpsit := xmldom.getFirstChild(vr_item_node_grpsit);
                vr_aux_NomCliCredtd := xmldom.getNodeValue(vr_valu_node_grpsit);
              END IF;
            END LOOP;
          ELSE
            -- Buscar primeiro filho do nó para buscar seu valor em lógica única
            vr_valu_node := xmldom.getFirstChild(vr_item_node);
            vr_aux_descrica := xmldom.getNodeValue(vr_valu_node);
            -- Copiar para a respectiva variavel conforme nome da tag
            IF vr_node_name = 'NumCtrlSTR' THEN
              vr_aux_NumCtrlRem := vr_aux_descrica;
            ELSIF vr_node_name = 'ISPBIFDebtd' THEN
              vr_aux_ISPBIFDebtd := vr_aux_descrica;
            ELSIF vr_node_name = 'ISPBIFCredtd' THEN
              vr_aux_ISPBIFCredtd := vr_aux_descrica;
            ELSIF vr_node_name = 'AgCredtd' THEN
              vr_aux_AgCredtd := vr_aux_descrica;
            ELSIF vr_node_name = 'NUPortdd'  THEN
              vr_aux_NUPortdd := vr_aux_descrica;
            ELSIF vr_node_name = 'DtMovto' THEN
              vr_aux_DtMovto := vr_aux_descrica;
            ELSIF vr_node_name = 'VlrLanc' THEN
              vr_aux_DsVlrLanc := gene0002.fn_char_para_number(vr_aux_descrica);
            ELSIF vr_node_name = 'IdentcDep' THEN
              vr_aux_IdentcDep := vr_aux_descrica;
            END IF;
          END IF;
        END LOOP;
        -- Se houve retorno de valor
        IF trim(vr_aux_DsVlrLanc) IS NOT NULL THEN
          vr_aux_VlrLanc := gene0002.fn_char_para_number(vr_aux_DsVlrLanc);
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := 'Erro no tratamento do Node pc_trata_portabilidade -->'||sqlerrm;
      END;

      -- SubRotina para tratar Recolhimento Numerario
      PROCEDURE pc_trata_numerario(pr_node      IN xmldom.DOMNode
                                  ,pr_dscritic OUT VARCHAR2) IS

        -- SubItens da STR0047R2
        vr_elem_node xmldom.DOMElement;
        vr_node_list xmldom.DOMNodeList;
        vr_node_name VARCHAR2(100);
        vr_item_node xmldom.DOMNode;
        vr_valu_node xmldom.DOMNode;

        -- SubItens de Grupo
        vr_elem_node_grpsit xmldom.DOMElement;
        vr_node_list_grpsit xmldom.DOMNodeList;
        vr_node_name_grpsit VARCHAR2(100);
        vr_item_node_grpsit xmldom.DOMNode;
        vr_valu_node_grpsit xmldom.DOMNode;

        -- VAriaveis genéricas
        vr_idx_numerario PLS_INTEGER;
        vr_aux_descrica  VARCHAR2(1000);

      BEGIN

        -- Buscar todos os filhos deste nó
        vr_elem_node := xmldom.makeElement(pr_node);
        -- Faz o get de toda a lista de filhos
        vr_node_list := xmldom.getChildrenByTagName(vr_elem_node,'*');
        -- Percorrer os elementos
        FOR i IN 0..xmldom.getLength(vr_node_list)-1 LOOP
          -- Buscar o item atual
          vr_item_node := xmldom.item(vr_node_list, i);
          -- Captura o nome e tipo do nodo
          vr_node_name := xmldom.getNodeName(vr_item_node);
          -- Sair se o nodo não for elemento
          IF xmldom.getNodeType(vr_item_node) <> xmldom.ELEMENT_NODE THEN
            CONTINUE;
          END IF;

          -- Para AgeFinDed
          IF vr_node_name = 'Grupo_STR0003R2_Den' THEN
            -- Setar mensagem e indice pltable
            vr_aux_CodMsg := 'STR0003R2';
            vr_idx_numerario := vr_tab_numerario.count()+1;

            -- Busca filhos
            vr_elem_node_grpsit := xmldom.makeElement(vr_item_node);
            -- Faz o get de toda a lista de filhos
            vr_node_list_grpsit := xmldom.getChildrenByTagName(vr_elem_node_grpsit,'*');
            -- Percorrer os elementos
            FOR i IN 0..xmldom.getLength(vr_node_list_grpsit)-1 LOOP
              -- Buscar o item atual
              vr_item_node_grpsit := xmldom.item(vr_node_list_grpsit, i);
              -- Captura o nome e tipo do nodo
              vr_node_name_grpsit := xmldom.getNodeName(vr_item_node_grpsit);
              -- Sair se o nodo não for elemento
              IF xmldom.getNodeType(vr_item_node_grpsit) <> xmldom.ELEMENT_NODE THEN
                CONTINUE;
              END IF;
              -- Para o node Catg
              IF vr_node_name_grpsit = 'Catg' THEN
                -- Buscar valor da TAG
                vr_valu_node_grpsit := xmldom.getFirstChild(vr_item_node_grpsit);
                vr_tab_numerario(vr_idx_numerario).cdcatego := gene0002.fn_char_para_number(xmldom.getNodeValue(vr_valu_node_grpsit));
              -- Para o node VlrDen
              ELSIF vr_node_name_grpsit = 'VlrDen' THEN
                -- Buscar valor da TAG
                vr_valu_node_grpsit := xmldom.getFirstChild(vr_item_node_grpsit);
                vr_tab_numerario(vr_idx_numerario).vlrdenom := gene0002.fn_char_para_number(xmldom.getNodeValue(vr_valu_node_grpsit));
              -- Outros
              ELSE
                -- Buscar valor da TAG
                vr_valu_node_grpsit := xmldom.getFirstChild(vr_item_node_grpsit);
                vr_tab_numerario(vr_idx_numerario).qtddenom := gene0002.fn_char_para_number(xmldom.getNodeValue(vr_valu_node_grpsit));
              END IF;
            END LOOP;
          ELSE
            -- Buscar primeiro filho do nó para buscar seu valor em lógica única
            vr_valu_node := xmldom.getFirstChild(vr_item_node);
            vr_aux_descrica := xmldom.getNodeValue(vr_valu_node);
            -- Copiar para a respectiva variavel conforme nome da tag
            IF vr_node_name = 'CodMsg' THEN
              vr_aux_CodMsg := vr_aux_descrica;
            ELSIF vr_node_name = 'NumCtrlSTR' THEN
              vr_aux_NumCtrlRem := vr_aux_descrica;
            ELSIF vr_node_name = 'DtHrBC' THEN
              vr_aux_DtHRBC := vr_aux_descrica;
            ELSIF vr_node_name = 'ISPBIFDebtd' THEN
              vr_aux_ISPBIFDebtd := vr_aux_descrica;
            ELSIF vr_node_name = 'AgDebtd'  THEN
              vr_aux_AgDebtd := vr_aux_descrica;
            ELSIF vr_node_name = 'ISPBIFCredtd' THEN
              vr_aux_ISPBIFCredtd := vr_aux_descrica;
            ELSIF vr_node_name = 'AgCredtd' THEN
              vr_aux_AgCredtd := gene0002.fn_char_para_number(vr_aux_descrica);
            ELSIF vr_node_name = 'VlrLanc' THEN
              vr_aux_DsVlrLanc := vr_aux_descrica;
            ELSIF vr_node_name = 'CodMunicOrigem' THEN
              vr_aux_CodMunicOrigem := vr_aux_descrica;
            ELSIF vr_node_name = 'CodMunicDest' THEN
              vr_aux_CodMunicDest := vr_aux_descrica;
            ELSIF vr_node_name = 'DtMovto' THEN
              vr_aux_DtMovto := vr_aux_descrica;
            END IF;
          END IF;
        END LOOP;
        -- Se houve retorno de valor
        IF trim(vr_aux_DsVlrLanc) IS NOT NULL THEN
          vr_aux_VlrLanc := gene0002.fn_char_para_number(vr_aux_DsVlrLanc);
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := 'Erro no tratamento do Node pc_trata_numerario -->'||sqlerrm;
      END;

      -- SubRotina para tratar a Transferencia de Valores
      PROCEDURE pc_trata_transfere(pr_node      IN xmldom.DOMNode
                                  ,pr_dscritic OUT VARCHAR2) IS
        -- SubItens
        vr_elem_node xmldom.DOMElement;
        vr_node_list xmldom.DOMNodeList;
        vr_node_name VARCHAR2(100);
        vr_item_node xmldom.DOMNode;
        vr_valu_node xmldom.DOMNode;

        -- Genéricas
        vr_aux_descrica     VARCHAR2(1000);

      BEGIN
        -- Buscar todos os filhos deste nó
        vr_elem_node := xmldom.makeElement(pr_node);
        -- Faz o get de toda a lista de filhos da CABINF
        vr_node_list := xmldom.getChildrenByTagName(vr_elem_node,'*');
        -- Percorrer os elementos
        FOR i IN 0..xmldom.getLength(vr_node_list)-1 LOOP
          -- Buscar o item atual
          vr_item_node := xmldom.item(vr_node_list, i);
          -- Captura o nome e tipo do nodo
          vr_node_name := xmldom.getNodeName(vr_item_node);
          -- Sair se o nodo não for elemento
          IF xmldom.getNodeType(vr_item_node) <> xmldom.ELEMENT_NODE THEN
            CONTINUE;
          END IF;
          -- Buscar primeiro filho do nó para buscar seu valor em lógica única
          vr_valu_node := xmldom.getFirstChild(vr_item_node);
          vr_aux_descrica := xmldom.getNodeValue(vr_valu_node);

          -- Gravar variaveis conforme tag em leitura
          IF vr_node_name = 'CodMsg' THEN
            -- Buscar valor da TAG
            vr_aux_CodMsg := vr_aux_descrica;
            -- Nas mensagens de devolucao, o Numero de Controle Original
            -- gerado pela cooperativa eh obtido pela TAG <NR_OPERACAO>
            IF vr_aux_CodMsg in ('STR0010R2','PAG0111R2') THEN
              vr_aux_NumCtrlIF := vr_aux_NrOperacao;
            END IF;
          ELSIF vr_node_name = 'NumCtrlIF' THEN
            -- Numero de Controle da Cooperativa
            vr_aux_NumCtrlIF := vr_aux_descrica;
          ELSIF vr_node_name IN('NumCtrlSTR','NumCtrlPAG') THEN
            -- Numero de Controle do Remetente
            vr_aux_NumCtrlRem := vr_aux_descrica;
          ELSIF vr_node_name = 'ISPBIFDebtd' THEN
            vr_aux_ISPBIFDebtd := vr_aux_descrica;
          ELSIF vr_node_name IN('AgDebtd','CtDebtd','CPFCliDebtd','CNPJ_CPFCliDebtd','CNPJ_CPFCliDebtdTitlar1','CNPJ_CPFCliDebtdTitlar2','CNPJ_CPFRemet') THEN
            IF vr_node_name = 'AgDebtd' THEN
              vr_aux_AgDebtd := vr_aux_descrica;
            ELSIF vr_node_name = 'CtDebtd' THEN
              vr_aux_CtDebtd := vr_aux_descrica;
            ELSIF vr_node_name = 'CPFCliDebtd' THEN
              vr_aux_CNPJ_CPFCred := vr_aux_descrica;
              vr_aux_CNPJ_CPFDeb  := vr_aux_descrica;
            ELSIF vr_node_name IN('CNPJ_CPFCliDebtd','CNPJ_CPFCliDebtdTitlar1','CNPJ_CPFCliDebtdTitlar2','CNPJ_CPFRemet') THEN
              vr_aux_CNPJ_CPFDeb := vr_aux_descrica;
            END IF;
            IF vr_aux_dadosdeb IS NULL THEN
              vr_aux_dadosdeb := vr_node_name || ':' || vr_aux_descrica;
            ELSE
              vr_aux_dadosdeb := vr_aux_dadosdeb || ' / '
                              || vr_node_name || ':' || vr_aux_descrica;
            END IF;
          ELSIF vr_node_name = 'TpCtDebtd' THEN
            vr_aux_TpCtDebtd := vr_aux_descrica;
          ELSIF vr_node_name = 'CtPgtoDebtd' THEN
            vr_aux_CtPgtoDebtd := vr_aux_descrica;
          ELSIF vr_node_name IN('NomCliDebtd','NomCliDebtdTitlar1','NomRemet') THEN
            vr_aux_NomCliDebtd := vr_aux_descrica;
            -- Transferencia entre mesma titularidade
            IF vr_aux_CodMsg IN('STR0037R2','PAG0137R2') THEN
              vr_aux_NomCliCredtd := vr_aux_descrica;
            END IF;
          ELSIF vr_node_name IN('NomCliCredtd','NomDestinatario','NomCliCredtdTitlar1') THEN
            vr_aux_NomCliCredtd := vr_aux_descrica;
          ELSIF vr_node_name = 'ISPBIFCredtd' THEN
            vr_aux_ISPBIFCredtd := vr_aux_descrica;
          ELSIF vr_node_name = 'AgCredtd' THEN
            vr_aux_AgCredtd := vr_aux_descrica;
          ELSIF vr_node_name = 'TpCtCredtd' THEN
            vr_aux_TpCtCredtd := vr_aux_descrica;
          ELSIF vr_node_name = 'CtPgtoCredtd' THEN
            vr_aux_CtPgtoCredtd := vr_aux_descrica;
          ELSIF vr_node_name IN('TpPessoaCredtd','TpPessoaDestinatario') THEN
            vr_aux_TpPessoaCred := vr_aux_descrica;
          ELSIF vr_node_name IN('CNPJ_CPFCliCredtd','CNPJ_CPFDestinatario','CNPJ_CPFCliCredtdTitlar1') THEN
            vr_aux_CNPJ_CPFCred := vr_aux_descrica;
          ELSIF vr_node_name = 'CtCredtd' THEN
            vr_aux_CtCredtd := vr_aux_descrica;
          ELSIF vr_node_name = 'VlrLanc' THEN
            vr_aux_DsVlrLanc := gene0002.fn_char_para_number(vr_aux_descrica);
          ELSIF vr_node_name = 'IdentcDep' THEN
            vr_aux_IdentcDep := vr_aux_descrica;
          ELSIF vr_node_name = 'NumCodBarras' AND vr_aux_CodMsg = 'STR0026R2' THEN
            vr_aux_NumCodBarras := vr_aux_descrica;
          ELSIF vr_node_name IN('SitLancSTR','SitLancPAG') THEN
            vr_aux_SitLanc:= vr_aux_descrica;
          ELSIF vr_node_name = 'CodDevTransf' THEN
            vr_aux_CodDevTransf := vr_aux_descrica;
          ELSIF vr_node_name = 'DtMovto' THEN
            vr_aux_DtMovto := vr_aux_descrica;
          ELSIF vr_node_name = 'CNPJNLiqdant'  THEN
            -- CNPJ Liquidante - antecipaçao de recebíveis - Mauricio
            vr_aux_CNPJNLiqdant := vr_aux_descrica;
          ELSIF vr_node_name = 'FinlddIF'  THEN
		        -- Tratamento mensagem LTR0005R2 - Mauricio - 03/11/2017
            vr_aux_FinlddIF := vr_aux_descrica;
          ELSIF vr_node_name = 'Hist'  THEN
            vr_aux_Hist := vr_aux_descrica;
          ELSIF vr_node_name = 'DtHrBC'  THEN
            vr_aux_DtHrBC := vr_aux_descrica;
	        ElSIF vr_node_name = 'TpPessoaDebtd_Remet'  THEN
            vr_aux_TpPessoaDebtd_Remet := vr_aux_descrica;
	        ElSIF vr_node_name = 'FinlddCli'  THEN
            vr_aux_FinlddCli := vr_aux_descrica;
     	    ElSIF vr_node_name = 'NumCtrlLTR'  THEN
            vr_aux_NumCtrlLTR := vr_aux_descrica;
	        ElSIF vr_node_name = 'ISPBLTR'  THEN
            vr_aux_ISPBLTR := vr_aux_descrica;
      	  ElSIF  vr_node_name = 'IdentdPartCamr'  THEN
            vr_aux_IdentdPartCamr := vr_aux_descrica;
          END IF;
        END LOOP;

        -- Se conta debitada for Conta de Pagamento
        IF vr_aux_TpCtDebtd = 'PG' THEN
          vr_aux_CtDebtd := vr_aux_CtPgtoDebtd;
        END IF;
        -- Se conta creditada for Conta de Pagamento
        IF vr_aux_TpCtCredtd = 'PG' THEN
          vr_aux_CtCredtd := vr_aux_CtPgtoCredtd;
        END IF;

        -- Se houve retorno de valor
        IF trim(vr_aux_DsVlrLanc) IS NOT NULL THEN
          vr_aux_VlrLanc := gene0002.fn_char_para_number(vr_aux_DsVlrLanc);
        END IF;

      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := 'Erro no tratamento do Node pc_trata_transfere -->'||sqlerrm;
      END;

PROCEDURE pc_trata_arquivo_slc(pr_node      IN xmldom.DOMNode
                              ,pr_dscritic OUT VARCHAR2) IS

        -- SubItens da SLC0001
        vr_elem_node xmldom.DOMElement;
        vr_node_list xmldom.DOMNodeList;
        vr_node_name VARCHAR2(100);
        vr_item_node xmldom.DOMNode;
        vr_valu_node xmldom.DOMNode;

        -- SubItens de Grupo
        vr_elem_node_grpsit xmldom.DOMElement;
        vr_node_list_grpsit xmldom.DOMNodeList;
        vr_node_name_grpsit VARCHAR2(100);
        vr_item_node_grpsit xmldom.DOMNode;
        vr_valu_node_grpsit xmldom.DOMNode;

        -- SubItens1 de Grupo
        vr_elem_node_grpsit1 xmldom.DOMElement;
        vr_node_list_grpsit1 xmldom.DOMNodeList;
        vr_node_name_grpsit1 VARCHAR2(100);
        vr_item_node_grpsit1 xmldom.DOMNode;
        vr_valu_node_grpsit1 xmldom.DOMNode;

        -- SubItens2 de Grupo
        vr_elem_node_grpsit2 xmldom.DOMElement;
        vr_node_list_grpsit2 xmldom.DOMNodeList;
        vr_node_name_grpsit2 VARCHAR2(100);
        vr_item_node_grpsit2 xmldom.DOMNode;
        vr_valu_node_grpsit2 xmldom.DOMNode;

        -- Genéricas
        vr_aux_descrica     VARCHAR2(1000);
        
        vr_ind  NUMBER;
        vr_ind1 NUMBER;
        vr_ind2 NUMBER;

BEGIN
    -- Reiniciar globais
    vr_aux_CodMsg := 'SLC0001';

    -- Buscar todos os filhos deste nó
    vr_elem_node := xmldom.makeElement(pr_node);
    -- Faz o get de toda a lista de filhos
    vr_node_list := xmldom.getChildrenByTagName(vr_elem_node,'*');
    -- Percorrer os elementos
    FOR vr_ind IN 0..xmldom.getLength(vr_node_list)-1 LOOP
      -- Buscar o item atual
      vr_item_node := xmldom.item(vr_node_list, vr_ind);
      -- Captura o nome e tipo do nodo
      vr_node_name := xmldom.getNodeName(vr_item_node);
      -- Sair se o nodo não for elemento
      IF xmldom.getNodeType(vr_item_node) <> xmldom.ELEMENT_NODE THEN
         CONTINUE;
      END IF;
      IF vr_node_name = 'Grupo_SLC0001_Liquid' THEN
         -- Busca filhos
         vr_elem_node_grpsit := xmldom.makeElement(vr_item_node);
         -- Faz o get de toda a lista de filhos
         vr_node_list_grpsit := xmldom.getChildrenByTagName(vr_elem_node_grpsit,'*');
         -- Percorrer os elementos
         FOR vr_ind1 IN 0..xmldom.getLength(vr_node_list_grpsit)-1 LOOP
              -- Buscar o item atual
              vr_item_node_grpsit := xmldom.item(vr_node_list_grpsit, vr_ind1);
              -- Captura o nome e tipo do nodo
              vr_node_name_grpsit := xmldom.getNodeName(vr_item_node_grpsit);
              -- Sair se o nodo não for elemento
              IF xmldom.getNodeType(vr_item_node_grpsit) <> xmldom.ELEMENT_NODE THEN
                CONTINUE;
              END IF;
              IF vr_node_name_grpsit = 'DtLiquid' THEN
                -- Buscar valor da TAG
                vr_valu_node_grpsit := xmldom.getFirstChild(vr_item_node_grpsit);
                vr_aux_DtLiquid := xmldom.getNodeValue(vr_valu_node_grpsit);
              ELSIF vr_node_name_grpsit = 'NumSeqCicloLiquid' THEN
                vr_valu_node_grpsit := xmldom.getFirstChild(vr_item_node_grpsit);
                vr_aux_NumSeqCicloLiquid := xmldom.getNodeValue(vr_valu_node_grpsit);
              ELSIF vr_node_name_grpsit = 'Grupo_SLC0001_Prodt' THEN  
                  -- Busca filhos
                  vr_elem_node_grpsit1 := xmldom.makeElement(vr_item_node_grpsit);
                  -- Faz o get de toda a lista de filhos
                  vr_node_list_grpsit1 := xmldom.getChildrenByTagName(vr_elem_node_grpsit1,'*');
                  -- Percorrer os elementos
                  FOR vr_ind2 IN 0..xmldom.getLength(vr_node_list_grpsit1)-1 LOOP
                    -- Buscar o item atual
                    vr_item_node_grpsit1 := xmldom.item(vr_node_list_grpsit1, vr_ind2);
                    -- Captura o nome e tipo do nodo
                    vr_node_name_grpsit1 := xmldom.getNodeName(vr_item_node_grpsit1);
                    -- Sair se o nodo não for elemento
                    IF xmldom.getNodeType(vr_item_node_grpsit1) <> xmldom.ELEMENT_NODE THEN
                       CONTINUE;
                    END IF;
                    IF vr_node_name_grpsit1 = 'CodProdt' THEN
                       vr_valu_node_grpsit1 := xmldom.getFirstChild(vr_item_node_grpsit1);
                       vr_aux_CodProdt := xmldom.getNodeValue(vr_valu_node_grpsit1);
                    ELSIF vr_node_name_grpsit1 = 'Grupo_SLC0001_LiquidProdt' THEN
                       -- Busca filhos
                       vr_elem_node_grpsit2 := xmldom.makeElement(vr_item_node_grpsit1);
                       -- Faz o get de toda a lista de filhos
                       vr_node_list_grpsit2 := xmldom.getChildrenByTagName(vr_elem_node_grpsit2,'*');
                       -- Percorrer os elementos
                       FOR vr_ind3 IN 0..xmldom.getLength(vr_node_list_grpsit2)-1 LOOP
                         -- Buscar o item atual
                         vr_item_node_grpsit2 := xmldom.item(vr_node_list_grpsit2, vr_ind3);
                         -- Captura o nome e tipo do nodo
                         vr_node_name_grpsit2 := xmldom.getNodeName(vr_item_node_grpsit2);
                         -- Sair se o nodo não for elemento
                         IF xmldom.getNodeType(vr_item_node_grpsit2) <> xmldom.ELEMENT_NODE THEN
                            CONTINUE;
                         END IF;
                         IF vr_node_name_grpsit2 = 'IdentdLinhaBilat' THEN
                            vr_valu_node_grpsit2 := xmldom.getFirstChild(vr_item_node_grpsit2);
                            vr_aux_IdentdLinhaBilat := xmldom.getNodeValue(vr_valu_node_grpsit2);
                         ELSIF vr_node_name_grpsit2 = 'TpDeb_Cred' THEN
                            vr_valu_node_grpsit2 := xmldom.getFirstChild(vr_item_node_grpsit2);
                            vr_aux_TpDeb_Cred := xmldom.getNodeValue(vr_valu_node_grpsit2);
                         ELSIF vr_node_name_grpsit2 = 'ISPBIFCredtd' THEN
                            vr_valu_node_grpsit2 := xmldom.getFirstChild(vr_item_node_grpsit2);
                            vr_aux_ISPBIFCredtd := xmldom.getNodeValue(vr_valu_node_grpsit2);
                         ELSIF vr_node_name_grpsit2 = 'ISPBIFDebtd' THEN
                            vr_valu_node_grpsit2 := xmldom.getFirstChild(vr_item_node_grpsit2);
                            vr_aux_ISPBIFDebtd := xmldom.getNodeValue(vr_valu_node_grpsit2);
                         ELSIF vr_node_name_grpsit2 = 'VlrLanc' THEN
                            vr_valu_node_grpsit2 := xmldom.getFirstChild(vr_item_node_grpsit2);
                            vr_aux_DsVlrLanc := xmldom.getNodeValue(vr_valu_node_grpsit2);
                            vr_aux_VlrLanc := gene0002.fn_char_para_number(vr_aux_DsVlrLanc);
                         ELSIF vr_node_name_grpsit2 = 'CNPJNLiqdantDebtd' THEN
                            vr_valu_node_grpsit2 := xmldom.getFirstChild(vr_item_node_grpsit2);
                            vr_aux_CNPJNLiqdantDebtd := xmldom.getNodeValue(vr_valu_node_grpsit2);
                         ELSIF vr_node_name_grpsit2 = 'NomCliDebtd' THEN
                            vr_valu_node_grpsit2 := xmldom.getFirstChild(vr_item_node_grpsit2);
                            vr_aux_NomCliDebtd := xmldom.getNodeValue(vr_valu_node_grpsit2);
                         ELSIF vr_node_name_grpsit2 = 'CNPJNLiqdantCredtd' THEN
                            vr_valu_node_grpsit2 := xmldom.getFirstChild(vr_item_node_grpsit2);
                            vr_aux_CNPJNLiqdantCredtd := xmldom.getNodeValue(vr_valu_node_grpsit2);
                         ELSIF vr_node_name_grpsit2 = 'NomCliCredtd' THEN
                            vr_valu_node_grpsit2 := xmldom.getFirstChild(vr_item_node_grpsit2);
                            vr_aux_NomCliCredtd := xmldom.getNodeValue(vr_valu_node_grpsit2);
	
									          IF 	vr_aux_TpInf = 'D' THEN -- Apenas para mensagens com tipo = D - Definitiva 

                 								cecred.ccrd0006.pc_insere_msg_slc(vr_aux_VlrLanc		
                       																				   ,vr_aux_codmsg	
																				                         ,vr_aux_NumCtrlSLC			
																				                         ,vr_aux_ISPBIF				
																				                         ,vr_aux_DtLiquid			
																				                         ,vr_aux_NumSeqCicloLiquid	
																				                         ,vr_aux_CodProdt			
																				                         ,vr_aux_IdentLinhaBilat	
																				                         ,vr_aux_TpDebCred			
																				                         ,vr_aux_ISPBIFCredtd		
																				                         ,vr_aux_ISPBIFDebtd		
																				                         ,vr_aux_CNPJNLiqdantDebtd	
																				                         ,vr_aux_NomCliDebtd		
																				                         ,vr_aux_CNPJNLiqdantCredtd	
																				                         ,vr_aux_NomCliCredtd		
																				                         ,vr_aux_DtHrSLC			
																				                         ,vr_aux_DtMovto			
																				                         ,vr_dscritic);
                                                                 
                                -- Se retornou erro
                                IF vr_dscritic IS NOT NULL THEN
                                   -- Acionar rotina de LOG
                                   BTCH0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                                             ,pr_ind_tipo_log  => 2 -- Erro não tratado
                                                             ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - ' || to_char(sysdate,'hh24:mi:ss')
                                                                                  ||' - '|| vr_glb_cdprogra ||' --> '
                                                                                  || 'pc_insere_msg_slc --> '||vr_dscritic
                                                             ,pr_nmarqlog      => vr_logprogr
                                                             ,pr_cdprograma    => vr_glb_cdprogra
                                                             ,pr_dstiplog      => 'E'
                                                             ,pr_tpexecucao    => 3
                                                             ,pr_cdcriticidade => 0
                                                             ,pr_flgsucesso    => 1
                                                             ,pr_cdmensagem    => vr_cdcritic);
                                END IF;
                            END IF;            		
                         END IF;
                       END LOOP;
                    END IF;
                  END LOOP;
              END IF;
         END LOOP;
      ELSE
         -- Buscar primeiro filho do nó para buscar seu valor em lógica única
         vr_valu_node := xmldom.getFirstChild(vr_item_node);
         vr_aux_descrica := xmldom.getNodeValue(vr_valu_node);
         -- Copiar para a respectiva variavel conforme nome da tag
         IF vr_node_name = 'NumCtrlSLC' THEN
	          -- Numero de Controle do Remetente 
            vr_aux_NumCtrlSLC := vr_aux_descrica;
         ELSIF vr_node_name = 'ISPBIF' THEN
            vr_aux_ISPBIF := vr_aux_descrica;
         ELSIF vr_node_name = 'TpInf' THEN
            vr_aux_TpInf := vr_aux_descrica;
         ELSIF vr_node_name = 'DtHrSLC' THEN
            vr_aux_DtHrSLC := vr_aux_descrica;
         ELSIF vr_node_name = 'DtMovto' THEN
            vr_aux_DtMovto := vr_aux_descrica;
         END IF;
      END IF;
    END LOOP;
    -- Salvar o arquivo
    pc_salva_arquivo;
    pc_gera_log_SPB('RECEBIDA OK'
                   ,'SLC RECEBIDA');

EXCEPTION
WHEN OTHERS THEN
   pr_dscritic := 'Erro no tratamento do Node pc_trata_arquivo_slc -->'||sqlerrm;
END;

PROCEDURE pc_trata_arquivo_ldl(pr_node      IN xmldom.DOMNode
                              ,pr_dscritic OUT VARCHAR2) IS

        -- SubItens da LDL0024
        vr_elem_node xmldom.DOMElement;
        vr_node_list xmldom.DOMNodeList;
        vr_node_name VARCHAR2(100);
        vr_item_node xmldom.DOMNode;
        vr_valu_node xmldom.DOMNode;

        -- SubItens de Grupo
        vr_elem_node_grpsit xmldom.DOMElement;
        vr_node_list_grpsit xmldom.DOMNodeList;
        vr_node_name_grpsit VARCHAR2(100);
        vr_item_node_grpsit xmldom.DOMNode;
        vr_valu_node_grpsit xmldom.DOMNode;

        -- Genéricas
        vr_aux_descrica     VARCHAR2(1000);
        
        vr_ind  NUMBER;
        vr_ind1 NUMBER;
        vr_ind2 NUMBER;

BEGIN
    -- Reiniciar globais
    vr_aux_CodMsg := 'LDL0024';

    -- Buscar todos os filhos deste nó
    vr_elem_node := xmldom.makeElement(pr_node);
    -- Faz o get de toda a lista de filhos
    vr_node_list := xmldom.getChildrenByTagName(vr_elem_node,'*');
    -- Percorrer os elementos
    FOR vr_ind IN 0..xmldom.getLength(vr_node_list)-1 LOOP
      -- Buscar o item atual
      vr_item_node := xmldom.item(vr_node_list, vr_ind);
      -- Captura o nome e tipo do nodo
      vr_node_name := xmldom.getNodeName(vr_item_node);
      -- Sair se o nodo não for elemento
      IF xmldom.getNodeType(vr_item_node) <> xmldom.ELEMENT_NODE THEN
         CONTINUE;
      END IF;
      IF vr_node_name = 'Grupo_LDL0024_HrioCamr' THEN
         -- Busca filhos
         vr_elem_node_grpsit := xmldom.makeElement(vr_item_node);
         -- Faz o get de toda a lista de filhos
         vr_node_list_grpsit := xmldom.getChildrenByTagName(vr_elem_node_grpsit,'*');
         -- Percorrer os elementos
         FOR vr_ind1 IN 0..xmldom.getLength(vr_node_list_grpsit)-1 LOOP
              -- Buscar o item atual
              vr_item_node_grpsit := xmldom.item(vr_node_list_grpsit, vr_ind1);
              -- Captura o nome e tipo do nodo
              vr_node_name_grpsit := xmldom.getNodeName(vr_item_node_grpsit);
              -- Sair se o nodo não for elemento
              IF xmldom.getNodeType(vr_item_node_grpsit) <> xmldom.ELEMENT_NODE THEN
                CONTINUE;
              END IF;
              IF vr_node_name_grpsit = 'CodGrdLDL' THEN
                -- Buscar valor da TAG
                vr_valu_node_grpsit := xmldom.getFirstChild(vr_item_node_grpsit);
                vr_aux_CodGrdLDL := xmldom.getNodeValue(vr_valu_node_grpsit);
              ELSIF vr_node_name_grpsit = 'DtHrAbert' THEN
                vr_valu_node_grpsit := xmldom.getFirstChild(vr_item_node_grpsit);
                vr_aux_DtHrAbert := xmldom.getNodeValue(vr_valu_node_grpsit);
              ELSIF vr_node_name_grpsit = 'DtHrFcht' THEN
                vr_valu_node_grpsit := xmldom.getFirstChild(vr_item_node_grpsit);
                vr_aux_DtHrFcht := xmldom.getNodeValue(vr_valu_node_grpsit);
              ELSIF vr_node_name_grpsit = 'TpHrio' THEN  
					        IF 	vr_aux_CodProdt='SLC' and vr_aux_CodGrdLDL in ('PAG94','PAGE3','PAGD3')  THEN 
                      cecred.ccrd0006.pc_insere_horario_grade(vr_aux_codmsg
																                             ,vr_aux_CodGrdLDL		
																                             ,vr_aux_DtHrAbert				
																                             ,vr_aux_DtHrFcht			
																                             ,vr_aux_TpHrio
																                             ,vr_aux_DtRef
																                             ,vr_dscritic);
                                                                 
                      -- Se retornou erro
                      IF vr_dscritic IS NOT NULL THEN
                         -- Acionar rotina de LOG
                         BTCH0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                                   ,pr_ind_tipo_log  => 2 -- Erro não tratado
                                                   ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - ' || to_char(sysdate,'hh24:mi:ss')
                                                                       ||' - '|| vr_glb_cdprogra ||' --> '
                                                                       || 'pc_insere_horario_grade --> '||vr_dscritic
                                                   ,pr_nmarqlog      => vr_logprogr
                                                   ,pr_cdprograma    => vr_glb_cdprogra
                                                   ,pr_dstiplog      => 'E'
                                                   ,pr_tpexecucao    => 3
                                                   ,pr_cdcriticidade => 0
                                                   ,pr_flgsucesso    => 1
                                                   ,pr_cdmensagem    => vr_cdcritic);
                      END IF;
                  END IF;
              END IF;
         END LOOP;
      ELSE
         -- Buscar primeiro filho do nó para buscar seu valor em lógica única
         vr_valu_node := xmldom.getFirstChild(vr_item_node);
         vr_aux_descrica := xmldom.getNodeValue(vr_valu_node);
         -- Copiar para a respectiva variavel conforme nome da tag
         IF vr_node_name = 'CodProdt' THEN
	          -- Numero de Controle do Remetente 
            vr_aux_CodProdt := vr_aux_descrica;
         ELSIF vr_node_name = 'DtRef' THEN
            vr_aux_DtRef := vr_aux_descrica;
         END IF;
      END IF;
    END LOOP;
    -- Salvar o arquivo
    pc_salva_arquivo;
    pc_gera_log_SPB('RECEBIDA OK'
                   ,'LDL0024 RECEBIDA');

EXCEPTION
WHEN OTHERS THEN
   pr_dscritic := 'Erro no tratamento do Node pc_trata_arquivo_ldl -->'||sqlerrm;
END;


									
    BEGIN

      -- Buscar parametros
      vr_dscomora := gene0001.fn_param_sistema('CRED',pr_cdcooper,'SCRIPT_EXEC_SHELL');
      vr_dsdirbin := gene0001.fn_param_sistema('CRED',pr_cdcooper,'ROOT_CECRED_BIN');

      -- Se nao encontrou
      IF vr_dscomora IS NULL OR vr_dsdirbin IS NULL THEN
        -- Montar mensagem erro
        vr_dscritic:= 'Nao foi possivel selecionar parametros para busca do XML.';
        -- Gera exceção
        RAISE vr_exc_saida;
      END IF;

      -- Se o arquivo não existir
      IF NOT gene0001.fn_exis_arquivo(vr_aux_nmdirxml||'/'||vr_aux_nmarqxml) THEN
        -- Montar mensagem erro
        vr_dscritic:= 'Arquivo nao existe - '||vr_aux_nmdirxml||'/'||vr_aux_nmarqxml;
        -- Gera exceção
        RAISE vr_exc_saida;
      END IF;

      -- Comando para criptografar o arquivo
      vr_comando := vr_dscomora||' perl_remoto ' ||vr_dsdirbin||'mqcecred_descriptografa.pl --descriptografa='||chr(39)|| vr_aux_nmdirxml||'/'||vr_aux_nmarqxml ||chr(39);

      -- Acionar rotina de descriptografia
      gene0001.pc_OScommand_Shell(pr_des_comando => REPLACE(REPLACE(REPLACE(vr_comando,'/coopd/','/coop/'),'/cooph/','/coop/'),'/coopl/','/coop/')
                                 ,pr_typ_saida   => vr_typ_saida
                                 ,pr_des_saida   => vr_des_saida);
      -- Obtem arquivo temporario descriptografado
      IF vr_typ_saida = 'ERR' OR vr_des_saida IS NULL THEN
        vr_dscritic := 'Descriptografia nao retornou arquivo valido!;';
        RAISE vr_exc_saida;
      END IF;

      -- O nome do arquivo veio na saida do comando (Já remover sujeira proveniente da chamada)
      vr_nmarquiv := replace(replace(vr_des_saida,chr(10),''),chr(13),'');
      -- Montar nome temporario
      vr_nmarqutp := vr_nmarquiv||'.tmp';

      -- Separar nome do arquivo e caminho e guardar na vr_nmarquiv somente o nome dele
      gene0001.pc_separa_arquivo_path(pr_caminho => vr_nmarquiv
                                     ,pr_direto  => vr_nmdirarq
                                     ,pr_arquivo => vr_nmarquiv);

      -- Separar nome do arquivo e caminho e guardar na vr_nmarqutp somente o nome dele
      gene0001.pc_separa_arquivo_path(pr_caminho => vr_nmarqutp
                                     ,pr_direto  => vr_nmdirarq
                                     ,pr_arquivo => vr_nmarqutp);

      -- Criar arquivo tmp do mesmo
      gene0001.pc_OScommand_Shell(pr_des_comando => 'mv '||vr_nmdirarq||'/'||vr_nmarquiv||' '||vr_nmdirarq||'/'||vr_nmarqutp
                                 ,pr_typ_saida   => vr_typ_saida
                                 ,pr_des_saida   => vr_des_saida);
      -- Obtem arquivo temporario descriptografado
      IF vr_typ_saida = 'ERR' OR vr_des_saida IS NOT NULL THEN
        vr_dscritic := 'Copia do arquivo descriptografado com erro!;';
        RAISE vr_exc_saida;
      END IF;

      -- Abre o arquivo para leitura
      gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdirarq||'/' --> Diretorio do arquivo
                              ,pr_nmarquiv => vr_nmarqutp          --> Nome do arquivo
                              ,pr_tipabert => 'R'                  --> Modo de abertura (R,W,A)
                              ,pr_utlfileh => vr_input_file        --> Handle do arquivo aberto
                              ,pr_des_erro => vr_dscritic);        --> Erro
      IF vr_dscritic IS NOT NULL OR NOT utl_file.IS_OPEN(vr_input_file) THEN
        -- Levantar Excecao
        vr_dscritic := 'Erro na abertura do arquivo ['||vr_nmarqutp||'] para leitura --> '||vr_dscritic;
        RAISE vr_exc_saida;
      END IF;

      -- Abre o arquivo para escrita
      gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdirarq||'/' --> Diretorio do arquivo
                              ,pr_nmarquiv => vr_nmarquiv          --> Nome do arquivo
                              ,pr_tipabert => 'W'                  --> Modo de abertura (R,W,A)
                              ,pr_utlfileh => vr_output_file        --> Handle do arquivo aberto
                              ,pr_des_erro => vr_dscritic);        --> Erro
      IF vr_dscritic IS NOT NULL OR NOT utl_file.IS_OPEN(vr_output_file) THEN
        -- Levantar Excecao
        vr_dscritic := 'Erro na abertura do arquivo ['||vr_nmarquiv||'] para escrita --> '||vr_dscritic;
        RAISE vr_exc_saida;
      END IF;

      -- Efetuar leitura do arquivo linha a linha do arquivo descriptografado
      LOOP
        BEGIN
          -- Ler linha a linha
          gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                      ,pr_des_text => vr_getlinha); --> Texto lido
          -- Substituir caracteres especiais e caracter especial 216 e 248 por "O" e caracter especial 230,207 e 168 por "" (Vazio)
          vr_setlinha := gene0007.fn_caract_acento(pr_texto    => vr_getlinha
                                                  ,pr_insubsti => 1
                                                  ,pr_dssubsin => CHR(216)||CHR(248)||CHR(230)||CHR(207)||CHR(168)
                                                  ,pr_dssubout => 'Oo   ');
          -- Escrever no arquivo
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_output_file
                                        ,pr_des_text => vr_setlinha);
          -- Armazenar informações para aproveitamento posterior
          vr_txtmensg := vr_txtmensg || vr_setlinha;
        EXCEPTION
          -- se apresentou erro de no_data_found é pq chegou no final do arquivo, fechar arquivo e sair do loop
          WHEN NO_DATA_FOUND THEN
            -- Fechar arquivos pois terminamos a leitura
            gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);
            gene0001.pc_fecha_arquivo(pr_utlfileh => vr_output_file);
            EXIT;
        END;
      END LOOP;

      -- Inicializar valor
      vr_aux_VlrLanc  := 0;

      -- Efetuar leitura do arquivo limpo em CLOB e já instanciá-lo como XML
      BEGIN
        vr_xmltype := XMLType.createXML(gene0002.fn_arq_para_clob(pr_caminho => vr_nmdirarq||'/'
                                                                 ,pr_arquivo => vr_nmarquiv));
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao converter o arquivo '||vr_nmarquiv||' para xml --> '||sqlerrm;
          RAISE vr_exc_saida;
      END;

      -- Faz o parse do XMLTYPE para o XMLDOM e libera o parser ao fim
      vr_parser := xmlparser.newParser;
      xmlparser.parseClob(vr_parser,vr_xmltype.getClobVal());
      vr_doc := xmlparser.getDocument(vr_parser);
      xmlparser.freeParser(vr_parser);

      -- Buscar nodo SISMSG
      vr_node_root := xmldom.getElementsByTagName(vr_doc,'SISMSG');
      vr_item_root := xmldom.item(vr_node_root, 0);
      vr_elem_root := xmldom.makeElement(vr_item_root);

      -- Faz o get de toda a lista SISMSG
      vr_node_list := xmldom.getChildrenByTagName(vr_elem_root,'*');

      -- Percorrer os elementos
      FOR i IN 0..xmldom.getLength(vr_node_list)-1 LOOP

        -- Buscar o item atual
        vr_item_node := xmldom.item(vr_node_list, i);
        -- Captura o nome e tipo do nodo
        vr_node_name := xmldom.getNodeName(vr_item_node);

        -- Sair se o nodo não for elemento
        IF xmldom.getNodeType(vr_item_node) <> xmldom.ELEMENT_NODE THEN
          CONTINUE;
        END IF;

        -- Tratar leitura dos dados do SEGCAB (Header)
        IF vr_node_name = 'SEGCAB' THEN

          -- Buscar todos os filhos deste nó
          vr_elem_node := xmldom.makeElement(vr_item_node);
          -- Faz o get de toda a lista de folhas da SEGCAB
          vr_node_list_segcab := xmldom.getChildrenByTagName(vr_elem_node,'*');

          -- Percorrer os elementos
          FOR i IN 0..xmldom.getLength(vr_node_list_segcab)-1 LOOP

            -- Buscar o item atual
            vr_item_node_segcab := xmldom.item(vr_node_list_segcab, i);
            -- Captura o nome e tipo do nodo
            vr_node_name_segcab := xmldom.getNodeName(vr_item_node_segcab);

            -- Sair se o nodo não for elemento
            IF xmldom.getNodeType(vr_item_node_segcab) <> xmldom.ELEMENT_NODE THEN
              CONTINUE;
            END IF;

            -- Para a tag NR_OPERACAO
            IF vr_node_name_segcab = 'NR_OPERACAO' THEN
              -- Buscar valor da TAG
              vr_valu_node_segcab := xmldom.getFirstChild(vr_item_node_segcab);
              vr_aux_NrOperacao   := xmldom.getNodeValue(vr_valu_node_segcab);
            END IF;
          END LOOP;
        ELSE
          -- Chamar rotinas específicas por Node
          IF vr_node_name IN('CABInfSituacao','CABInfCancelamento') THEN
            -- Inconsistencia dados, Resposta da JD ou Rejeicao da cabine
            pc_trata_CabInf(pr_node_cabinf => vr_item_node
                           ,pr_dscritic    => vr_dscritic);
          ELSIF vr_node_name IN('PAG0101','STR0018','STR0019')  THEN
            -- Trata IFs
            pc_trata_IFs(pr_node        => vr_item_node
                        ,pr_dscritic    => vr_dscritic);
          ELSIF vr_node_name = 'STR0047R2' THEN
            -- Portabilidade de crédito
            pc_trata_portabilidade(pr_node        => vr_item_node
                                  ,pr_dscritic    => vr_dscritic);
          ELSIF vr_node_name = 'STR0003R2'THEN
            -- Recolhimento de Numerários
            pc_trata_numerario(pr_node        => vr_item_node
                              ,pr_dscritic    => vr_dscritic);
          ELSIF vr_node_name = 'SLC0001' THEN
	          -- Inclusão tratamento mensagem SLC0001 - Mauricio - 03/11/2017 
            pc_trata_arquivo_slc(pr_node        => vr_item_node
                                ,pr_dscritic    => vr_dscritic);
          ELSIF vr_node_name = 'LDL0024' THEN
         	  -- Inclusão tratamento mensagem LDL0024 - Alexandre (Mouts) - 12/12/2017 
            pc_trata_arquivo_ldl(pr_node        => vr_item_node
                                ,pr_dscritic    => vr_dscritic); 
          ELSE
            -- Trasnferencia de valores
            pc_trata_transfere(pr_node        => vr_item_node
                              ,pr_dscritic    => vr_dscritic);
          END IF;
          -- Se encontrou erro nas rotinas chamadas
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;
        END IF;
      END LOOP;

      -- Somente se o processo já foi finalidado
      IF fn_verifica_processo THEN
        -- Verificar as mensagens que serao desprezadas na gravacao da nova estrutura
        IF ( vr_msgspb_nao_copiar IS NULL OR ','||vr_aux_CodMsg||',' LIKE ('%,'||vr_msgspb_nao_copiar||',%') ) THEN
          --
          IF vr_aux_NumCtrlRem IS NOT NULL THEN
            vr_aux_nro_controle := vr_aux_NumCtrlRem;
          ELSE
            vr_aux_nro_controle := vr_aux_NumCtrlIF;
          END IF;
          --
          IF vr_aux_tagCABInf THEN
            vr_aux_cdagectl_pesq := gene0002.fn_char_para_number(SUBSTR(vr_aux_NumCtrlIF,8,4));
          ELSE
            vr_aux_cdagectl_pesq := gene0002.fn_char_para_number(vr_aux_AgCredtd);
          END IF;

          -- Busca dados da Coope por cdagectl
          OPEN cr_crapcop(pr_cdagectl => vr_aux_cdagectl_pesq);
          FETCH cr_crapcop
           INTO rw_crapcop_mensag;
          CLOSE cr_crapcop;

          -- Verificar se recebemos data na mensagem XML
          IF TRIM(vr_aux_DtMovto) IS NOT NULL AND gene0002.fn_data(vr_aux_DtMovto,'RRRR-MM-DD') THEN
            -- Tratar tamanho do arquivo
            IF length(vr_txtmensg) > 4000 THEN
              -- Montar critica
              vr_aux_msgspb_xml     := 'XML muito grande. Verifique arquivo fisico: ' || vr_aux_nmarqxml;
              vr_aux_manter_fisico  := TRUE;
            ELSE
              -- XML sera processado
              vr_aux_msgspb_xml    := vr_txtmensg;
              vr_aux_manter_fisico := FALSE;
            END IF;

            -- Gravar a mensagem descriptografada
            SSPB0003.pc_grava_mensagem_ted(pr_cdcooper    => NVL(rw_crapcop_mensag.cdcooper,rw_crapcop_central.cdcooper)
                                          ,pr_nrctrlif    => vr_aux_nro_controle
                                          ,pr_dtmensagem  => to_date(vr_aux_DtMovto,'RRRR-MM-DD')
                                          ,pr_nmevento    => vr_aux_CodMsg
                                          ,pr_dsxml       => vr_aux_msgspb_xml
                                          ,pr_cdprograma  => vr_glb_cdprogra
                                          ,pr_cdcritic    => vr_cdcritic
                                          ,pr_dscritic    => vr_dscritic);
            -- Se retornou erro
            IF vr_dscritic IS NOT NULL THEN
              -- Acionar rotina de LOG
              BTCH0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                        ,pr_ind_tipo_log  => 2 -- Erro não tratado
                                        ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - ' || to_char(sysdate,'hh24:mi:ss')||' - '|| vr_glb_cdprogra ||' --> '
                                                          || 'Erro na Execucao Paralela - '
                                                          || 'PID: ' || pr_idparale || ' '
                                                          || 'Seq.: ' || to_char(pr_idprogra,'fm99990') ||' '
                                                          || 'Mensagem: ' || vr_aux_nmarqxml
                                                          || ' --> '||vr_dscritic
                                        ,pr_nmarqlog      => vr_logprogr
                                        ,pr_cdprograma    => vr_glb_cdprogra
                                        ,pr_dstiplog      => 'E'
                                        ,pr_tpexecucao    => 3
                                        ,pr_cdcriticidade => 0
                                        ,pr_flgsucesso    => 1
                                        ,pr_cdmensagem    => vr_cdcritic);
            END IF;
          ELSE
            -- Montar mensagem de erro para enviar ao LOG
            vr_aux_manter_fisico := TRUE;
            vr_aux_msgspb_xml    := to_char(sysdate,'dd/mm/yyyy') || ' - ' || to_char(sysdate,'hh24:mi:ss')||' - '|| vr_glb_cdprogra ||' --> '
                                 || 'Alerta da Execucao Paralela - '
                                 || 'PID: ' || pr_idparale || ' '
                                 || 'Seq.: ' || to_char(pr_idprogra,'fm99990') ||' '
                                 || ' - Mensagem de TED nao possui data ou a data eh invalida. Verifique arquivo fisico: ' || vr_aux_nmarqxml;
            -- Acionar rotina de LOG
            BTCH0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                      ,pr_ind_tipo_log  => 2 -- Erro não tratado
                                      ,pr_des_log       => vr_aux_msgspb_xml
                                      ,pr_nmarqlog      => vr_logprogr
                                      ,pr_cdprograma    => vr_glb_cdprogra
                                      ,pr_dstiplog      => 'E'
                                      ,pr_tpexecucao    => 3
                                      ,pr_cdcriticidade => 0
                                      ,pr_flgsucesso    => 1);
          END IF;
        END IF;
      END IF;

      -- Ao final, remover os arquivos temporarios ignorando possiveis erros
      gene0001.pc_OScommand_Shell(pr_des_comando => 'rm '||vr_nmdirarq||'/'||vr_nmarquiv);
      gene0001.pc_OScommand_Shell(pr_des_comando => 'rm '||vr_nmdirarq||'/'||vr_nmarqutp);

    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Remover os arquivos temporarios ignorando possiveis erros
        gene0001.pc_OScommand_Shell(pr_des_comando => 'rm '||vr_nmdirarq||'/'||vr_nmarquiv);
        gene0001.pc_OScommand_Shell(pr_des_comando => 'rm '||vr_nmdirarq||'/'||vr_nmarqutp);
        -- Fechar arquivos caso abertos
        IF utl_file.IS_OPEN(vr_input_file) THEN
          gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);
        END IF;
        IF utl_file.IS_OPEN(vr_output_file) THEN
          gene0001.pc_fecha_arquivo(pr_utlfileh => vr_output_file);
        END IF;
        -- Erro tratado
        pr_dscritic := 'Erro na rotina pc_importa_xml --> '||vr_dscritic;
      WHEN others THEN
        -- Remover os arquivos temporarios ignorando possiveis erros
        gene0001.pc_OScommand_Shell(pr_des_comando => 'rm '||vr_nmdirarq||'/'||vr_nmarquiv);
        gene0001.pc_OScommand_Shell(pr_des_comando => 'rm '||vr_nmdirarq||'/'||vr_nmarqutp);
        -- Fechar arquivos caso abertos
        IF utl_file.IS_OPEN(vr_input_file) THEN
          gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);
        END IF;
        IF utl_file.IS_OPEN(vr_output_file) THEN
          gene0001.pc_fecha_arquivo(pr_utlfileh => vr_output_file);
        END IF;
        -- Erro nao tratado
        pr_dscritic := 'Erro nao tratado na rotina pc_importa_xml --> '||sqlerrm;
    END;


    -- Funcao true or false para tratar conversao para numero sem gerar exceção
    FUNCTION fn_numerico(pr_dsdtext IN VARCHAR2) RETURN BOOLEAN IS
      vr_nrdtext NUMBER;
    BEGIN
      vr_nrdtext := to_number(pr_dsdtext);
      IF vr_nrdtext IS NOT NULL THEN
        RETURN TRUE;
      END IF;
      RETURN TRUE;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN FALSE;
    END;

    -- Procedimento para tratar registro quando Cecred
    PROCEDURE pc_trata_cecred(pr_cdagectl IN VARCHAR2
                             ,pr_dscritic OUT VARCHAR2) IS
      vr_flgnumer BOOLEAN;
    BEGIN
      -- Se recebemos cdagectl
      IF pr_cdagectl IS NOT NULL THEN
        -- Verificar se eh numero
        vr_flgnumer := fn_numerico(pr_cdagectl);
        rw_crapcop_mensag := NULL;
        -- Busca dados da Coope por cdagectl somente se ele for um numero
        IF vr_flgnumer THEN
          OPEN cr_crapcop(pr_cdagectl => pr_cdagectl
                         ,pr_flgativo => 1);
          FETCH cr_crapcop
           INTO rw_crapcop_mensag;
          CLOSE cr_crapcop;
        END IF;
        -- Se mensagem nao pertence a nenhuma Coop.
        IF rw_crapcop_mensag.cdcooper IS NULL THEN
          -- Buscar erro Agencia invalida
          vr_aux_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => 0
                                                       ,pr_nmsistem => 'CRED'
                                                       ,pr_tptabela => 'GENERI'
                                                       ,pr_cdempres => 0
                                                       ,pr_cdacesso => 'CDERROSSPB'
                                                       ,pr_tpregist => 2);
          -- Se encontrou
          IF vr_aux_dstextab IS NOT NULL THEN
            -- Copiar a var padrão de erro
            vr_log_msgderro := vr_aux_dstextab;
          END IF;
          -- Nao criar gnmvcen para CABInf
          IF NOT vr_aux_tagCABInf THEN
            -- Cria registro da mensagem Devolvida
            pc_cria_gnmvcen(pr_cdagenci => rw_crapcop_central.cdagectl
                           ,pr_dtmvtolt => rw_crapdat_central.dtmvtolt
                           ,pr_dsmensag => vr_aux_CodMsg
                           ,pr_dsdebcre => 'C'
                           ,pr_vllanmto => vr_aux_VlrLanc
                           ,pr_dscritic => vr_dscritic);
            IF vr_dscritic IS NOT NULL THEN
              raise vr_exc_saida;
            END IF;
          END IF;
          -- Para R2
          IF vr_aux_CodMsg LIKE '%R2' THEN
            -- Agencia invalida
            pc_gera_erro_xml(pr_dsdehist => 'Agencia de destino invalida.'
                            ,pr_codierro => 2
                            ,pr_dscritic => vr_dscritic);
            -- Se retornou erro
            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;
          ELSE
            -- Chamar rotina de log no SPB
            pc_gera_log_SPB(pr_tipodlog  => 'RECEBIDA'
                           ,pr_msgderro  => vr_log_msgderro);
          END IF;
        END IF;
      ELSE
        -- Para pagamento
        IF vr_aux_TpCtCredtd = 'PG' OR TRIM(vr_aux_CtPgtoCredtd) IS NOT NULL THEN
          -- Buscar erro Agencia invalida
          vr_aux_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => 0
                                                       ,pr_nmsistem => 'CRED'
                                                       ,pr_tptabela => 'GENERI'
                                                       ,pr_cdempres => 0
                                                       ,pr_cdacesso => 'CDERROSSPB'
                                                       ,pr_tpregist => 2);
          -- Se encontrou
          IF vr_aux_dstextab IS NOT NULL THEN
            -- Copiar a var padrão de erro
            vr_log_msgderro := vr_aux_dstextab;
          END IF;
          -- Nao criar gnmvcen para CABInf
          IF NOT vr_aux_tagCABInf THEN
            -- Cria registro da mensagem Devolvida
            pc_cria_gnmvcen(pr_cdagenci => rw_crapcop_central.cdagectl
                           ,pr_dtmvtolt => rw_crapdat_central.dtmvtolt
                           ,pr_dsmensag => vr_aux_CodMsg
                           ,pr_dsdebcre => 'C'
                           ,pr_vllanmto => vr_aux_VlrLanc
                           ,pr_dscritic => vr_dscritic);
            IF vr_dscritic IS NOT NULL THEN
              raise vr_exc_saida;
            END IF;
          END IF;
          -- Para R2
          IF vr_aux_CodMsg LIKE '%R2' THEN
            -- Agencia invalida
            pc_gera_erro_xml(pr_dsdehist => 'Tipo de conta incorreto.'
                            ,pr_codierro => 2
                            ,pr_dscritic => vr_dscritic);
            -- Se retornou erro
            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;
          END IF;
        ELSE
          -- Mensagem imprevista
          vr_log_msgderro := 'Mensagem nao prevista';
          -- Chamar rotina de log no SPB
          pc_gera_log_SPB(pr_tipodlog  => 'RECEBIDA'
                         ,pr_msgderro  => vr_log_msgderro);

        END IF;
      END IF;
    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := 'Erro na rotina pc_trata_cecred -->'||vr_dscritic;
      WHEN OTHERS THEN
        pr_dscritic := 'Erro na rotina pc_trata_cecred -->'||sqlerrm;
    END;

    -- Buscar motivo devolução
    FUNCTION fn_motivo_devolucao RETURN varchar2 IS
    BEGIN
      -- Buscar descrição de erro conforme motivo
      vr_aux_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => 0
                                                   ,pr_nmsistem => 'CRED'
                                                   ,pr_tptabela => 'GENERI'
                                                   ,pr_cdempres => 0
                                                   ,pr_cdacesso => 'CDERROSSPB'
                                                   ,pr_tpregist => to_number(vr_aux_CodDevTransf));
      -- Se encontrou
      IF vr_aux_dstextab IS NOT NULL THEN
        -- Retornar
        RETURN to_number(vr_aux_CodDevTransf) || ' - ' || vr_aux_dstextab;
      ELSE
        RETURN to_number(vr_aux_CodDevTransf) || ' - Outros';
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN vr_aux_CodDevTransf || ' - Outros ';
    END;

    -- Funcão para validar vencimento titulo
    -- Tratamento para permitir pagamento no primeiro dia util do
    -- ano de titulos vencidos no ultimo dia util do ano anterior
    FUNCTION fn_verifica_vencto_titulo (pr_cdcooper   IN NUMBER
                                       ,pr_dtvencto   IN DATE) RETURN BOOLEAN IS
    BEGIN
      DECLARE
        -- Variaveis Locais
        rw_crapdat btch0001.cr_crapdat%ROWTYPE;
        vr_dtdiautil DATE;
        vr_nranoant  VARCHAR2(4);
      BEGIN
        -- Buscar calendario
        OPEN btch0001.cr_crapdat(pr_cdcooper);
        FETCH btch0001.cr_crapdat
         INTO rw_crapdat;
        CLOSE btch0001.cr_crapdat;

        -- Pagamento no dia OU
        -- Se dia anterior for menor que vencimento
        IF pr_dtvencto > rw_crapdat.dtmvtocd OR rw_crapdat.dtmvtoan < pr_dtvencto THEN
          RETURN FALSE;
        END IF;

        -- Tratamento para permitir pagamento no primeiro dia util do
        -- ano de titulos vencidos no ultimo dia util do ano anterior
        vr_nranoant := to_char(rw_crapdat.dtmvtoan,'YYYY');
        -- Ano anterior diferente Ano Pagamento
        IF vr_nranoant != to_char(rw_crapdat.dtmvtocd,'YYYY') THEN
          -- Montar ultimo dia ano anterior
          vr_dtdiautil:= to_date('3112'||vr_nranoant,'DDMMYYYY');
          -- Se dia 31/12 for segunda-feira obtem data do sabado
          -- para aceitar vencidos do ultimo final de semana
          CASE to_number(to_char(vr_dtdiautil,'D'))
            WHEN 1 THEN vr_dtdiautil:= to_date('2912'||vr_nranoant,'DDMMYYYY');
            WHEN 2 THEN vr_dtdiautil:= to_date('2912'||vr_nranoant,'DDMMYYYY');
            WHEN 7 THEN vr_dtdiautil:= to_date('3012'||vr_nranoant,'DDMMYYYY');
            ELSE NULL;
          END CASE;
          -- Verifica se pode aceitar o titulo vencido
          IF pr_dtvencto >= vr_dtdiautil THEN
            -- Retorna FALSE
            RETURN FALSE;
          END IF;
        END IF;

        -- Se chegar neste ponto, validamos com sucesso
        RETURN true;

      EXCEPTION
        WHEN OTHERS THEN
          -- Sair do programa retornando false
          RETURN false;
      END;
    END fn_verifica_vencto_titulo;

    /* Procedimento para liquidacao de emprestimo novo */
    PROCEDURE pc_liq_contrato_emprest_nov(pr_cdcooper IN crapcop.cdcooper%type
                                         ,pr_nrdconta IN crapass.nrdconta%type
                                         ,pr_nrctremp IN crapepr.nrctremp%type
                                         ,pr_dtmvtolt IN crapdat.dtmvtolt%type
                                         ,pr_dtmvtoan IN crapdat.dtmvtoan%type
                                         ,pr_cdagenci IN craplot.cdagenci%type
                                         ,pr_cdagelot IN craplot.cdagenci%type
                                         ,pr_dscritic OUT varchar2) IS
      --Tabelas de Memoria para Pagamentos das Parcelas Emprestimo
      vr_tab_pgto_parcel EMPR0001.typ_tab_pgto_parcel;
      vr_tab_calculado   EMPR0001.typ_tab_calculado;
      -- Tabela memória WPR
      vr_index_crawepr     VARCHAR2(30);
      -- Cursor de Emprestimos
      CURSOR cr_crawepr(pr_cdcooper IN crawepr.cdcooper%TYPE,
                        pr_nrdconta IN crawepr.nrdconta%TYPE,
                        pr_nrctremp IN crawepr.nrctremp%TYPE) IS
        SELECT wepr.tpemprst
              ,wepr.dtlibera
          FROM crawepr wepr
         WHERE wepr.cdcooper = pr_cdcooper
           AND wepr.nrdconta = pr_nrdconta
           AND wepr.nrctremp = pr_nrctremp;
      rw_crawepr  cr_crawepr%ROWTYPE;
      vr_tab_crawepr EMPR0001.typ_tab_crawepr;

    BEGIN
      -- Buscar pagamentos Parcela
      EMPR0001.pc_busca_pgto_parcelas(pr_cdcooper        => pr_cdcooper
                                     ,pr_cdagenci        => pr_cdagelot
                                     ,pr_nrdcaixa        => 0
                                     ,pr_cdoperad        => '1'
                                     ,pr_nmdatela        => vr_glb_cdprogra||'_1'
                                     ,pr_idorigem        => 1 -- Ayllos
                                     ,pr_nrdconta        => pr_nrdconta
                                     ,pr_idseqttl        => 1 -- Seq titula
                                     ,pr_dtmvtolt        => pr_dtmvtolt
                                     ,pr_flgerlog        => 'N'
                                     ,pr_nrctremp        => pr_nrctremp
                                     ,pr_dtmvtoan        => pr_dtmvtoan
                                     ,pr_nrparepr        => 0  /* Todas */
                                     ,pr_des_reto        => vr_des_reto -- Retorno OK / NOK
                                     ,pr_tab_erro        => vr_tab_erro -- Tabela com possíves erros
                                     ,pr_tab_pgto_parcel => vr_tab_pgto_parcel -- Tabela com registros de pagamentos
                                     ,pr_tab_calculado   => vr_tab_calculado); -- Tabela com totais calculados
      -- Se ocorreu erro
      IF vr_des_reto <> 'OK' THEN
        -- Se tem erro
        IF vr_tab_erro.count > 0 THEN
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        END IF;
        -- Sair da rotina
        RAISE vr_exc_saida;
      END IF;

      -- Buscar dados da Proposta
      OPEN cr_crawepr(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrctremp => pr_nrctremp);
      FETCH cr_crawepr
       INTO rw_crawepr;
      CLOSE cr_crawepr;
      -- Montar Indice acesso
      vr_index_crawepr := lpad(pr_cdcooper, 10,'0') ||
                          lpad(pr_nrdconta, 10,'0') ||
                          lpad(pr_nrctremp, 10,'0');
      -- Popular tabela com informacoes encontradas
      vr_tab_crawepr(vr_index_crawepr).dtlibera := rw_crawepr.dtlibera;
      vr_tab_crawepr(vr_index_crawepr).tpemprst := rw_crawepr.tpemprst;

      -- Efetuar a Liquidacao do Emprestimo
      empr0001.pc_efetua_liquidacao_empr(pr_cdcooper => pr_cdcooper         --> Cooperativa conectada
                                        ,pr_cdagenci => pr_cdagelot         --> Código da agência
                                        ,pr_nrdcaixa => 0                   --> Número do caixa
                                        ,pr_cdoperad => '1'                 --> Código do Operador
                                        ,pr_nmdatela => vr_glb_cdprogra||'_1'   --> Nome da tela
                                        ,pr_idorigem => 1                   --> Id do módulo de sistema
                                        ,pr_cdpactra => 1                   --> P.A. da transação
                                        ,pr_nrdconta => pr_nrdconta         --> Número da conta
                                        ,pr_idseqttl => 1                   --> Seq titular
                                        ,pr_dtmvtolt => pr_dtmvtolt         --> Movimento atual
                                        ,pr_flgerlog => 'N'                 --> Indicador S/N para geração de log
                                        ,pr_nrctremp => pr_nrctremp         --> Número do contrato de empréstimo
                                        ,pr_dtmvtoan => pr_dtmvtoan         --> Data Movimento Anterior
                                        ,pr_ehprcbat => 'N'                 --> Indicador Processo Batch (S/N)
                                        ,pr_tab_pgto_parcel => vr_tab_pgto_parcel --Tabela com Pagamentos de Parcelas
                                        ,pr_tab_crawepr => vr_tab_crawepr   --> Tabela com Contas e Contratos
                                        ,pr_nrseqava => 0                   --> Pagamento: Sequencia do avalista
                                        ,pr_des_erro => vr_des_reto         --> Retorno OK / NOK
                                        ,pr_tab_erro => vr_tab_erro);       --> Tabela de Erros

      -- Se ocorreu erro
      IF vr_des_reto = 'NOK' THEN
        --Se possui erro na tabela
        IF vr_tab_erro.COUNT > 0 THEN
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          vr_dscritic := 'Erro na liquidacao';
        END IF;
        -- Sair da rotina
        RAISE vr_exc_saida;
      END IF;

    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Incrementar a critica as mensagens da liquidacao
        pr_dscritic := ' Liquidacao '
                    || '|' || pr_cdagenci
                    || '|' || pr_nrdconta
                    || '|' || pr_nrctremp
                    || '|' || vr_aux_NUPortdd
                    || ' --> ' || vr_dscritic;
      WHEN OTHERS THEN
        pr_dscritic := ' Liquidacao '
                    || '|' || pr_cdagenci
                    || '|' || pr_nrdconta
                    || '|' || pr_nrctremp
                    || '|' || vr_aux_NUPortdd
                    || ' --> ' || sqlerrm;
    END;

    /* Procedimento para liquidacao de emprestimo antigo */
    PROCEDURE pc_liq_contrato_emprest_ant(pr_cdcooper IN crapcop.cdcooper%type
                                         ,pr_nrdconta IN crapass.nrdconta%type
                                         ,pr_nrctremp IN crapepr.nrctremp%type
                                         ,pr_rw_crapdat IN btch0001.cr_crapdat%ROWTYPE
                                         ,pr_dtmvtolt IN crapdat.dtmvtolt%type
                                         ,pr_dscritic OUT varchar2) IS
      -- Cursor de Emprestimos
      CURSOR cr_crapepr(pr_cdcooper crapepr.cdcooper%TYPE
                       ,pr_nrdconta crapepr.nrdconta%TYPE
                       ,pr_nrctremp crapepr.nrctremp%TYPE) IS
        SELECT epr.cdlcremp
              ,epr.cdagenci
              ,epr.txjuremp
              ,epr.vlpreemp
              ,epr.rowid
          FROM crapepr epr
         WHERE epr.cdcooper = pr_cdcooper
           AND epr.nrdconta = pr_nrdconta
           AND epr.nrctremp = pr_nrctremp;
      rw_crapepr  cr_crapepr%ROWTYPE;

      -- Busca da linha de credito
      CURSOR cr_craplcr(pr_cdcooper crapepr.cdcooper%TYPE
                       ,pr_cdlcremp craplcr.cdlcremp%TYPE) IS
        SELECT cdlcremp
              ,txdiaria
              ,cdusolcr
          FROM craplcr
         WHERE cdcooper = pr_cdcooper
           AND cdlcremp = pr_cdlcremp;
      rw_craplcr cr_craplcr%ROWTYPE;

      -- Variaveis auxiliares
      vr_tab_inusatab BOOLEAN;
      vr_aux_txjuremp NUMBER;

    BEGIN
      -- Buscar empréstimo
      OPEN cr_crapepr(pr_cdcooper
                     ,pr_nrdconta
                     ,pr_nrctremp);
      FETCH cr_crapepr
       INTO rw_crapepr;
      IF cr_crapepr%FOUND THEN
        CLOSE cr_crapepr;
        -- Busca as tarifas
        vr_aux_dstextab:= tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                    ,pr_nmsistem => 'CRED'
                                                    ,pr_tptabela => 'USUARI'
                                                    ,pr_cdempres => 11
                                                    ,pr_cdacesso => 'TAXATABELA'
                                                    ,pr_tpregist => 0  );
        -- Se nao encontrar
        IF vr_aux_dstextab IS NULL THEN
          vr_tab_inusatab := FALSE;
        ELSE
          IF SUBSTR(vr_aux_dstextab,1,1) = '0' THEN
            vr_tab_inusatab := FALSE;
          ELSE
            vr_tab_inusatab := TRUE;
          END IF;
        END IF;

        -- Buscar linha de credito
        OPEN cr_craplcr(pr_cdcooper,rw_crapepr.cdlcremp);
        FETCH cr_craplcr
         INTO rw_craplcr;
        CLOSE cr_craplcr;

        -- Nao debitar os emprestimos com emissao de boletos
        IF rw_craplcr.cdusolcr = 2 THEN
          vr_dscritic := '|Emprestimo com emissao de boleto - LCR: '|| rw_crapepr.cdlcremp;
          -- Sair da rotina
          RAISE vr_exc_saida;
        END IF;

        -- Se usa tabela
        IF vr_tab_inusatab THEN
          -- Checar se achou LCR antes pois ela é obrigatória
          IF rw_craplcr.cdlcremp IS NULL THEN
            -- Gerar erro
            vr_dscritic :=  gene0001.fn_busca_critica(363)|| ' - LCR: '|| rw_crapepr.cdlcremp;
            -- Sair da rotina
            RAISE vr_exc_saida;
          ELSE
            -- Usar tabela de juros da LCR
            vr_aux_txjuremp := rw_craplcr.txdiaria;
          END IF;
        ELSE
          -- Usar da epr
          vr_aux_txjuremp := rw_crapepr.txjuremp;
        END IF;

        -- Atualizar capa do emprestimo
        BEGIN
          UPDATE crapepr
             SET crapepr.inliquid = 1
                ,crapepr.dtultpag = pr_dtmvtolt
                ,crapepr.txjuremp = vr_aux_txjuremp
           WHERE rowid = rw_crapepr.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar CRAPEPR --> '||sqlerrm;
            -- Sair da rotina
            RAISE vr_exc_saida;
        END;

        -- Verificar criação do lote
        OPEN cr_craplot(pr_cdcooper => pr_cdcooper
                       ,pr_dtmvtolt => pr_dtmvtolt
                       ,pr_cdagenci => vr_glb_cdagenci
                       ,pr_cdbccxlt => 100
                       ,pr_nrdolote => 8453);
        FETCH cr_craplot INTO rw_craplot;
        -- Se não encontrou capa do lote
        IF cr_craplot%NOTFOUND THEN
          -- Fecha Cursor
          CLOSE cr_craplot;

          BEGIN
            --Inserir a capa do lote retornando informacoes para uso posterior
            INSERT INTO craplot
               (dtmvtolt
               ,cdagenci
               ,cdbccxlt
               ,nrdolote
               ,tplotmov
               ,cdcooper
               ,nrseqdig
               ,cdhistor
               ,cdoperad)
            VALUES
               (pr_dtmvtolt
               ,1
               ,100
               ,8453
               ,vr_glb_tplotmov
               ,pr_cdcooper
               ,0
               ,0
               ,'1')
             RETURNING dtmvtolt
                      ,cdagenci
                      ,cdbccxlt
                      ,nrdolote
                      ,nrseqdig
                      ,cdcooper
                      ,tplotmov
                      ,vlinfodb
                      ,vlcompdb
                      ,qtinfoln
                      ,qtcompln
                      ,cdoperad
                      ,tpdmoeda
                      ,rowid
                  into rw_craplot.dtmvtolt
                      ,rw_craplot.cdagenci
                      ,rw_craplot.cdbccxlt
                      ,rw_craplot.nrdolote
                      ,rw_craplot.nrseqdig
                      ,rw_craplot.cdcooper
                      ,rw_craplot.tplotmov
                      ,rw_craplot.vlinfodb
                      ,rw_craplot.vlcompdb
                      ,rw_craplot.qtinfoln
                      ,rw_craplot.qtcompln
                      ,rw_craplot.cdoperad
                      ,rw_craplot.tpdmoeda
                      ,rw_craplot.rowid;
           EXCEPTION
             WHEN OTHERS THEN
               vr_dscritic := 'Erro ao inserir na tabela craplot (8453). '||SQLERRM;
               -- Sair da rotina
               RAISE vr_exc_saida;
           END;
        ELSE
          -- Apenas Fecha Cursor
          CLOSE cr_craplot;
        END IF;

        -- Insere pagamento parcela
        BEGIN
          INSERT INTO craplem
             (cdcooper
             ,dtmvtolt
             ,cdagenci
             ,cdbccxlt
             ,nrdolote
             ,nrdconta
             ,nrdocmto
             ,cdhistor
             ,nrseqdig
             ,nrctremp
             ,txjurepr
             ,vlpreemp
             ,vllanmto
             ,dtpagemp)
          VALUES
             (pr_cdcooper
             ,rw_craplot.dtmvtolt
             ,rw_craplot.cdagenci
             ,rw_craplot.cdbccxlt
             ,rw_craplot.nrdolote
             ,pr_nrdconta
             ,vr_aux_nrctremp
             ,095
             ,nvl(rw_craplot.nrseqdig,0) + 1
             ,pr_nrctremp
             ,vr_aux_txjuremp
             ,rw_crapepr.vlpreemp
             ,vr_aux_VlrLanc
             ,rw_craplot.dtmvtolt);
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir na tabela craplem (095). '||SQLERRM;
            -- Sair da rotina
            RAISE vr_exc_saida;
        END;

        -- Atualizar capa do Lote
        BEGIN
          UPDATE craplot SET craplot.vlinfocr = nvl(craplot.vlinfocr,0) + vr_aux_VlrLanc
                            ,craplot.vlcompcr = nvl(craplot.vlcompcr,0) + vr_aux_VlrLanc
                            ,craplot.qtinfoln = nvl(craplot.qtinfoln,0) + 1
                            ,craplot.qtcompln = nvl(craplot.qtcompln,0) + 1
                            ,craplot.nrseqdig = nvl(craplot.nrseqdig,0) + 1
          WHERE craplot.ROWID = rw_craplot.ROWID;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar tabela craplot. '||SQLERRM;
            -- Sair da rotina
            RAISE vr_exc_saida;
        END;

        -- Verificar criação do lote
        OPEN cr_craplot(pr_cdcooper => pr_cdcooper
                       ,pr_dtmvtolt => pr_dtmvtolt
                       ,pr_cdagenci => vr_glb_cdagenci
                       ,pr_cdbccxlt => 100
                       ,pr_nrdolote => 8457);
        FETCH cr_craplot INTO rw_craplot;
        -- Se não encontrou capa do lote
        IF cr_craplot%NOTFOUND THEN
          -- Fecha Cursor
          CLOSE cr_craplot;

          BEGIN
            --Inserir a capa do lote retornando informacoes para uso posterior
            INSERT INTO craplot
               (dtmvtolt
               ,cdagenci
               ,cdbccxlt
               ,nrdolote
               ,tplotmov
               ,cdcooper
               ,nrseqdig
               ,cdhistor
               ,cdoperad)
            VALUES
               (pr_dtmvtolt
               ,1
               ,100
               ,8457
               ,vr_glb_tplotmov
               ,pr_cdcooper
               ,0
               ,0
               ,'1')
             RETURNING dtmvtolt
                      ,cdagenci
                      ,cdbccxlt
                      ,nrdolote
                      ,nrseqdig
                      ,cdcooper
                      ,tplotmov
                      ,vlinfodb
                      ,vlcompdb
                      ,qtinfoln
                      ,qtcompln
                      ,cdoperad
                      ,tpdmoeda
                      ,rowid
                  into rw_craplot.dtmvtolt
                      ,rw_craplot.cdagenci
                      ,rw_craplot.cdbccxlt
                      ,rw_craplot.nrdolote
                      ,rw_craplot.nrseqdig
                      ,rw_craplot.cdcooper
                      ,rw_craplot.tplotmov
                      ,rw_craplot.vlinfodb
                      ,rw_craplot.vlcompdb
                      ,rw_craplot.qtinfoln
                      ,rw_craplot.qtcompln
                      ,rw_craplot.cdoperad
                      ,rw_craplot.tpdmoeda
                      ,rw_craplot.rowid;
           EXCEPTION
             WHEN OTHERS THEN
               vr_dscritic := 'Erro ao inserir na tabela craplot (8453). '||SQLERRM;
               -- Sair da rotina
               RAISE vr_exc_saida;
           END;
        ELSE
          -- Apenas Fecha Cursor
          CLOSE cr_craplot;
        END IF;

        -- Inserir Lancamento de debito na conta
        BEGIN
          INSERT INTO craplcm
             (cdcooper
             ,dtmvtolt
             ,cdagenci
             ,cdbccxlt
             ,nrdolote
             ,nrdconta
             ,nrdctabb
             ,nrdctitg
             ,nrdocmto
             ,cdhistor
             ,nrseqdig
             ,cdpesqbb
             ,vllanmto)
          VALUES
             (pr_cdcooper
             ,rw_craplot.dtmvtolt
             ,rw_craplot.cdagenci
             ,rw_craplot.cdbccxlt
             ,rw_craplot.nrdolote
             ,pr_nrdconta
             ,pr_nrdconta
             ,GENE0002.fn_mask(pr_nrdconta,'99999999')
             ,pr_nrctremp
             ,108
             ,nvl(rw_craplot.nrseqdig,0) + 1
             ,null
             ,vr_aux_VlrLanc);
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir na tabela craplcm --> ' || SQLERRM;
           -- Sair da rotina
           RAISE vr_exc_saida;
        END;

        -- Atualizar capa do Lote
        BEGIN
          UPDATE craplot SET craplot.vlinfodb = nvl(craplot.vlinfodb,0) + vr_aux_VlrLanc
                            ,craplot.vlcompdb = nvl(craplot.vlcompdb,0) + vr_aux_VlrLanc
                            ,craplot.qtinfoln = nvl(craplot.qtinfoln,0) + 1
                            ,craplot.qtcompln = nvl(craplot.qtcompln,0) + 1
                            ,craplot.nrseqdig = nvl(craplot.nrseqdig,0) + 1
          WHERE craplot.ROWID = rw_craplot.ROWID;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar tabela craplot. ' || SQLERRM;
            -- Sair da rotina
            RAISE vr_exc_saida;
        END;

        -- Eliminar avisos de débito pendentes
        BEGIN
          DELETE FROM crapavs
                WHERE crapavs.cdcooper = pr_cdcooper
                  AND crapavs.nrdconta = pr_nrdconta
                  AND crapavs.cdhistor = 108
                  AND crapavs.insitavs = 0
                  AND crapavs.dtrefere >= pr_dtmvtolt;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao eliminar avisos de debito pendentes --> '||sqlerrm;
            -- Sair da rotina
             RAISE vr_exc_saida;
        END;

        -- Desativar o Rating associado a esta operaçao
        rati0001.pc_desativa_rating(pr_cdcooper   => pr_cdcooper         --> Código da Cooperativa
                                   ,pr_cdagenci   => 0                   --> Código da agência
                                   ,pr_nrdcaixa   => 0                   --> Número do caixa
                                   ,pr_cdoperad   => '1'                 --> Código do operador
                                   ,pr_rw_crapdat => pr_rw_crapdat       --> Vetor com dados de parâmetro (CRAPDAT)
                                   ,pr_nrdconta   => pr_nrdconta         --> Conta do associado
                                   ,pr_tpctrrat   => 90                  --> Tipo do Rating (90-Empréstimo)
                                   ,pr_nrctrrat   => pr_nrctremp         --> Número do contrato de Rating
                                   ,pr_flgefeti   => 'S'                 --> Flag para efetivação ou não do Rating
                                   ,pr_idseqttl   => 1                   --> Sequencia de titularidade da conta
                                   ,pr_idorigem   => 1                   --> Indicador da origem da chamada
                                   ,pr_inusatab   => vr_tab_inusatab     --> Indicador de utilização da tabela de juros
                                   ,pr_nmdatela   => vr_glb_cdprogra||'_1'   --> Nome datela conectada
                                   ,pr_flgerlog   => 'N'                 --> Gerar log S/N
                                   ,pr_des_reto   => vr_des_reto         --> Retorno OK / NOK
                                   ,pr_tab_erro   => vr_tab_erro);       --> Tabela com possíves erros
        -- Se retornou erro
        IF vr_des_reto = 'NOK' THEN
          --Se tem erro na tabela
          IF vr_tab_erro.COUNT = 0 THEN
            vr_dscritic:= 'Erro na rati0001.pc_desativa_rating.';
          ELSE
            vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          END IF;
          -- Levantar Excecao
          RAISE vr_exc_saida;
        END IF;

        -- Solicitar a Baixa do gravame
        GRVM0001.pc_solicita_baixa_automatica(pr_cdcooper => pr_cdcooper  -- Código da cooperativa
                                             ,pr_nrdconta => pr_nrdconta  -- Numero da conta do contrato
                                             ,pr_nrctrpro => pr_nrctremp  -- Numero do contrato
                                             ,pr_dtmvtolt => pr_dtmvtolt  -- Data de movimento para baixa
                                             ,pr_des_reto => vr_des_reto  -- Retorno OK ou NOK
                                             ,pr_tab_erro => vr_tab_erro  -- Retorno de erros em PlTable
                                             ,pr_cdcritic => vr_cdcritic  -- Retorno de codigo de critica
                                             ,pr_dscritic => vr_dscritic);-- Retorno de descricao de critica
        -- Se retornou erro
        IF vr_des_reto = 'NOK' THEN
          --Se tem erro na tabela
          IF vr_tab_erro.COUNT > 0 THEN
            vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          END IF;
          -- Levantar Excecao
          RAISE vr_exc_saida;
        END IF;

      ELSE
        CLOSE cr_crapepr;
      END IF;
    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Incrementar a critica as mensagens da liquidacao
        pr_dscritic := ' Liquidacao '
                    || '|' || rw_crapepr.cdagenci
                    || '|' || pr_nrdconta
                    || '|' || pr_nrctremp
                    || '|' || vr_aux_NUPortdd
                    || ' --> ' || vr_dscritic;
      WHEN OTHERS THEN
        pr_dscritic := ' Liquidacao '
                    || '|' || rw_crapepr.cdagenci
                    || '|' || pr_nrdconta
                    || '|' || pr_nrctremp
                    || '|' || vr_aux_NUPortdd
                    || ' --> ' || sqlerrm;
    END;

    /* Procedimento para processamento de conta transferida entre cooperativas */
    PROCEDURE pc_processa_conta_transferida(pr_cdcopant IN crapcop.cdcooper%type
                                           ,pr_nrctaant IN crapass.nrdconta%type
                                           ,pr_vlrlanct IN NUMBER
                                           ,pr_dscritic OUT varchar2) IS
      -- Buffers locais
      rw_b_crapcop cr_crapcop%rowtype;
      rw_b_crapdat btch0001.cr_crapdat%rowtype;
      rw_b_craplot cr_craplot%ROWTYPE;
      -- Variaveis
      vr_aux_hrtransa pls_integer := to_char(sysdate,'sssss');
      vr_aux_dtmvtolt DATE;
      vr_aux_strmigra VARCHAR2(400);
      vr_aux_nmarqimp VARCHAR2(400);
    BEGIN
      -- Buscar registro de transferencia
      rw_craptco := NULL;
      OPEN cr_craptco(pr_cdcopant => pr_cdcopant
                     ,pr_ntctaant => pr_nrctaant
                     ,pr_flgativo => 1
                     ,pr_tpctatrf => 1);
      FETCH cr_craptco
       INTO rw_craptco;
      -- Se não encontrou
      IF cr_craptco%NOTFOUND THEN
        CLOSE cr_craptco;
        -- No caso de TED destinada a uma IF incorporada,
        -- o parametro par_cdcopant contera o codigo da nova IF
        OPEN cr_craptco(pr_cdcooper => pr_cdcopant
                       ,pr_ntctaant => pr_nrctaant
                       ,pr_flgativo => 1
                       ,pr_tpctatrf => 1);
        FETCH cr_craptco
         INTO rw_craptco;
        CLOSE cr_craptco;
      ELSE
        CLOSE cr_craptco;
      END IF;

      -- Somente se encontrou registro TCO
      IF rw_craptco.nrdconta IS NOT NULL THEN
        -- Busca cooperativa onde a conta foi transferida
        -- Identifica cooperativa antiga
        OPEN cr_crapcop(pr_cdcooper => rw_craptco.cdcooper);
        FETCH cr_crapcop
         INTO rw_b_crapcop;
        -- Se não encontrar
        IF cr_crapcop%NOTFOUND THEN
          CLOSE cr_crapcop;
          -- Retornar erro
          vr_dscritic := 'Registro COP nao encontrado - '||rw_craptco.cdcooper;
          RAISE vr_exc_saida;
        ELSE
          CLOSE cr_crapcop;
        END IF;

        -- Busca data na cooperativa onde a conta foi transferida
        OPEN btch0001.cr_crapdat(pr_cdcooper => rw_craptco.cdcooper);
        FETCH btch0001.cr_crapdat
         INTO rw_b_crapdat;
        -- Se não encontrar
        IF btch0001.cr_crapdat%NOTFOUND THEN
          CLOSE btch0001.cr_crapdat;
          -- Coop nao encontrar
          vr_dscritic := 'Data da cooperativa migrada nao encontrada - '||rw_craptco.cdcooper;
          RAISE vr_exc_saida;
        ELSE
          CLOSE btch0001.cr_crapdat;
        END IF;

        -- Conforme estado de crise
        IF vr_aux_flestcri = 0 THEN
          vr_aux_dtmvtolt := rw_b_crapdat.dtmvtolt;
        ELSE
          vr_aux_dtmvtolt := vr_aux_dtintegr;
        END IF;

        -- Verifica se processo ja finalizou na coop de destino
        IF trunc(sysdate) > vr_aux_dtmvtolt AND vr_aux_flestcri = 0 THEN
          vr_dscritic := 'Processo nao finalizado na Coop migrada - '||rw_craptco.cdcooper;
          RAISE vr_exc_saida;
        END IF;

        -- Verifica se a conta transferida existe
        OPEN cr_crapass(pr_cdcooper => rw_craptco.cdcooper
                       ,pr_nrdconta => rw_craptco.nrdconta);
        FETCH cr_crapass
         INTO rw_crapass;
        -- Se não encontrar
        IF cr_crapass%NOTFOUND THEN
          CLOSE cr_crapass;
          -- Cria registro das movimentacoes no SPB
          pc_cria_gnmvcen(pr_cdagenci => rw_b_crapcop.cdagectl
                         ,pr_dtmvtolt => vr_aux_dtmvtolt
                         ,pr_dsmensag => vr_aux_codMsg
                         ,pr_dsdebcre => 'C'
                         ,pr_vllanmto => pr_vlrlanct
                         ,pr_dscritic => vr_dscritic);
          IF vr_dscritic IS NOT NULL THEN
            raise vr_exc_saida;
          END IF;
          -- Gerar log
          pc_gera_log_SPB_transferida(pr_cdcooper => rw_b_crapcop.cdcooper
                                     ,pr_cdbcoctl => rw_b_crapcop.cdbcoctl
                                     ,pr_dtmvtolt => vr_aux_dtmvtolt
                                     ,pr_tipodlog => 'RECEBIDA'
                                     ,pr_msgderro => 'Registro(crapass) de conta transferida nao encontrado');

          -- Mover o arquivo de XML
          pc_mover_arquivo_xml(pr_nmarq_mover => vr_aux_nmarqxml
                              ,pr_nmdir_mover => rw_b_crapcop.dsdircop);

          -- Retornar com erro
          vr_dscritic := 'Registro(crapass) de conta transferida nao encontrado';
          raise vr_exc_saida;
        ELSE
          CLOSE cr_crapass;
        END IF;

      ELSE
        -- Retornar erro
        vr_dscritic := 'Registro TCO nao encontrado.';
        RAISE vr_exc_saida;
      END IF;

      -- Buscar / Criar Lote
      OPEN cr_craplot(pr_cdcooper => rw_b_crapcop.cdcooper
                     ,pr_dtmvtolt => vr_aux_dtmvtolt
                     ,pr_cdagenci => vr_glb_cdagenci
                     ,pr_cdbccxlt => rw_b_crapcop.cdbcoctl
                     ,pr_nrdolote => vr_glb_nrdolote);
      FETCH cr_craplot INTO rw_b_craplot;
      -- Se não encontrou capa do lote
      IF cr_craplot%NOTFOUND THEN
        -- Fecha Cursor
        CLOSE cr_craplot;
        -- Gerar erro
        vr_dscritic := 'Lote nao encontrado.';
        RAISE vr_exc_saida;
      ELSE
        -- Apenas Fecha Cursor
        CLOSE cr_craplot;
      END IF;

      -- Verificar se ja existe Lancamento
      vr_aux_existlcm := 0;
      vr_aux_vllanmto := NULL;
      OPEN cr_craplcm_exis(pr_cdcooper => rw_b_crapcop.cdcooper
                          ,pr_dtmvtolt => rw_b_craplot.dtmvtolt
                          ,pr_cdagenci => rw_b_craplot.cdagenci
                          ,pr_cdbccxlt => rw_b_craplot.cdbccxlt
                          ,pr_nrdolote => rw_b_craplot.nrdolote
                          ,pr_nrdctabb => rw_craptco.nrdconta
                          ,pr_nrdocmto => vr_aux_nrdocmto);
      FETCH cr_craplcm_exis
       INTO vr_aux_existlcm,vr_aux_vllanmto;
      CLOSE cr_craplcm_exis;

      -- Se encontrar
      IF vr_aux_existlcm = 1 THEN
        vr_dscritic := 'Lancamento ja existe! Lote: ' ||rw_b_craplot.nrdolote||', Doc.: ' || vr_aux_nrdocmto;
      ELSE
        -- Inserir Lancamento somente se não criticou acima
        BEGIN
          INSERT INTO craplcm
             (cdcooper
             ,dtmvtolt
             ,cdagenci
             ,cdbccxlt
             ,nrdolote
             ,nrdconta
             ,nrdctabb
             ,nrdocmto
             ,cdhistor
             ,nrseqdig
             ,cdpesqbb
             ,vllanmto
             ,cdoperad
             ,hrtransa)
          VALUES
             (rw_b_crapcop.cdcooper
             ,rw_b_craplot.dtmvtolt
             ,rw_b_craplot.cdagenci
             ,rw_b_craplot.cdbccxlt
             ,rw_b_craplot.nrdolote
             ,rw_craptco.nrdconta
             ,rw_craptco.nrdconta
             ,vr_aux_nrdocmto
                                   /* Credito TEC  TED */
             ,DECODE(vr_aux_CodMsg,'STR0037R2',799,'PAG0137R2',799,578)
             ,nvl(rw_b_craplot.nrseqdig,0) + 1
             ,vr_aux_dadosdeb
             ,pr_vlrlanct
             ,'1'
             ,vr_aux_hrtransa);
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir na tabela craplcm --> ' || SQLERRM;
        END;
      END IF;

      -- Se deu erro na gravação
      IF vr_dscritic IS NOT NULL THEN
        -- Cria registro das movimentacoes no SPB
        pc_cria_gnmvcen(pr_cdagenci => rw_b_crapcop.cdagectl
                       ,pr_dtmvtolt => vr_aux_dtmvtolt
                       ,pr_dsmensag => vr_aux_codMsg
                       ,pr_dsdebcre => 'C'
                       ,pr_vllanmto => pr_vlrlanct
                       ,pr_dscritic => vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
          raise vr_exc_saida;
        END IF;
        -- Gerar log
        pc_gera_log_SPB_transferida(pr_cdcooper => rw_b_crapcop.cdcooper
                                   ,pr_cdbcoctl => rw_b_crapcop.cdbcoctl
                                   ,pr_dtmvtolt => vr_aux_dtmvtolt
                                   ,pr_tipodlog => 'RECEBIDA'
                                   ,pr_msgderro => vr_dscritic);

        -- Mover o arquivo de XML
        pc_mover_arquivo_xml(pr_nmarq_mover => vr_aux_nmarqxml
                            ,pr_nmdir_mover => rw_b_crapcop.dsdircop);

        -- Retornar sem erro
        RETURN;
      END IF;

      -- Atualizar capa do Lote
      BEGIN
        UPDATE craplot SET craplot.vlinfocr = nvl(craplot.vlinfocr,0) + pr_vlrlanct
                          ,craplot.vlcompcr = nvl(craplot.vlcompcr,0) + pr_vlrlanct
                          ,craplot.qtinfoln = nvl(craplot.qtinfoln,0) + 1
                          ,craplot.qtcompln = nvl(craplot.qtcompln,0) + 1
                          ,craplot.nrseqdig = nvl(craplot.nrseqdig,0) + 1
        WHERE craplot.ROWID = rw_b_craplot.ROWID;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar tabela craplot. ' || SQLERRM;
          -- Sair da rotina
          RAISE vr_exc_saida;
      END;

      -- Cria registro das movimentacoes no SPB
      pc_cria_gnmvcen(pr_cdagenci => rw_b_crapcop.cdagectl
                     ,pr_dtmvtolt => vr_aux_dtmvtolt
                     ,pr_dsmensag => vr_aux_codMsg
                     ,pr_dsdebcre => 'C'
                     ,pr_vllanmto => pr_vlrlanct
                     ,pr_dscritic => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        raise vr_exc_saida;
      END IF;

      -- Gerar log
      pc_gera_log_SPB_transferida(pr_cdcooper => rw_b_crapcop.cdcooper
                                 ,pr_cdbcoctl => rw_b_crapcop.cdbcoctl
                                 ,pr_dtmvtolt => vr_aux_dtmvtolt
                                 ,pr_tipodlog => 'RECEBIDA'
                                 ,pr_msgderro => NULL);

      IF rw_craptco.cdcopant = 1  OR    /* Migracao VIACREDI >> Alto Vale */
         rw_craptco.cdcopant = 2  OR    /* Migracao ACREDI >> VIACREDI */
         rw_craptco.cdcopant = 4  OR    /* Incorporação CONCREDI >> VIACREDI */
         rw_craptco.cdcopant = 15 OR    /* Incorporação CREDIMILSUL >>  SCRCRED */
         rw_craptco.cdcopant = 17 THEN  /* Incorporação TRANSULCRED >>  TRANSPOCRED */

        -- Montar nome do arquivo de LOG
        vr_aux_nmarqimp := 'teds_migradas'
                        || to_char(rw_craptco.cdcopant,'fm00')
                        || to_char(vr_aux_dtmvtolt,'ddmmrrrr');

        -- Testar se o arquivo ainda não existe
        IF NOT gene0001.fn_exis_arquivo(gene0001.fn_diretorio(pr_tpdireto => 'C'
                                                             ,pr_cdcooper => 3
                                                             ,pr_nmsubdir => 'log')||'/'||vr_aux_nmarqimp||'.log') THEN
          -- Vamos gerar LOG das TEDs Migradas
          IF rw_craptco.cdcopant = 1 THEN
            vr_aux_strmigra := 'TEDs MIGRADAS: VIACREDI --> VIACREDI AV';
          ELSIF rw_craptco.cdcopant = 2 THEN
            vr_aux_strmigra := 'TEDs MIGRADAS: ACREDI --> VIACREDI';
          ELSIF rw_craptco.cdcopant = 4 THEN
            vr_aux_strmigra := 'TEDs MIGRADAS: CONCREDI --> VIACREDI';
          ELSIF rw_craptco.cdcopant = 15 THEN
            vr_aux_strmigra := 'TEDs MIGRADAS: CREDIMILSUL --> SCRCRED';
          ELSIF rw_craptco.cdcopant = 17 THEN
            vr_aux_strmigra := 'TEDs MIGRADAS: TRANSULCRED --> TRANSPOCRED';
          ELSE
            vr_aux_strmigra := 'TEDs MIGRADAS';
          END IF;

          -- Gerar cabeçalho no arquivo de LOG
          btch0001.pc_gera_log_batch(pr_cdcooper     => 3 /*Sempre na Central*/
                                    ,pr_ind_tipo_log => 1
                                    ,pr_des_log      => LPAD(substr(vr_aux_strmigra,1,40),10,' ')
                                    ,pr_nmarqlog     => vr_aux_nmarqimp);
        END IF;

        -- Gerar registro no arquivo de LOG
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3 /*Sempre na Central*/
                                  ,pr_ind_tipo_log => 1
                                  ,pr_des_log      => LPAD(' ',3,' ')||to_char(sysdate,'hh24:mi:ss')
                                                   || to_char(vr_aux_VlrLanc,'9g999g999g999g990d00')
                                                   || to_char(rw_craptco.nrctaant,'99999999999999')
                                                   || to_char(rw_craptco.nrdconta,'99999999999999')
                                  ,pr_nmarqlog     => vr_aux_nmarqimp);
      END IF;

      -- Ao final, mover o XML processado
      pc_mover_arquivo_xml(pr_nmarq_mover => vr_aux_nmarqxml
                          ,pr_nmdir_mover => rw_b_crapcop.dsdircop);

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := 'Erro na rotina pc_processa_conta_transferida --> '||vr_dscritic;
      WHEN OTHERS THEN
        pr_dscritic := 'Erro nao tratado em pc_processa_conta_transferida --> '||sqlerrm;
    END;


    -- Função centralizadora de tabela em usa
    FUNCTION fn_verifica_tab_em_uso(pr_sig_tabela VARCHAR2
                                   ,pr_rowid ROWID DEFAULT NULL
                                   ,pr_progress_recid NUMBER DEFAULT NULL) RETURN NUMBER IS

      -- Verificar tvl
      CURSOR cr_craptvl IS
        SELECT craptvl.rowid
          FROM craptvl
         WHERE craptvl.rowid = pr_rowid
         FOR UPDATE NOWAIT;
      rw_craptvl cr_craptvl%ROWTYPE;

      -- Verificar LCS
      CURSOR cr_craplcs IS
        SELECT craplcs.rowid
          FROM craplcs
         WHERE craplcs.rowid = pr_rowid
         FOR UPDATE NOWAIT;
      rw_craplcs cr_craplcs%ROWTYPE;

      -- Verificar LFP
      CURSOR cr_craplfp IS
        SELECT craplfp.rowid
          FROM craplfp
         WHERE craplfp.progress_recid = pr_progress_recid
         FOR UPDATE NOWAIT;
      rw_craplfp cr_craplfp%ROWTYPE;

    BEGIN
      /* Tratamento para buscar registro se o mesmo estiver em lock, tenta por 10 seg. */
      FOR i IN 1..100 LOOP
        BEGIN
          -- Leitura cfme tabela passada
          IF pr_sig_tabela = 'TVL' THEN
            OPEN cr_craptvl;
            FETCH cr_craptvl INTO rw_craptvl;
            CLOSE cr_craptvl;
          ELSIF pr_sig_tabela = 'LCS' THEN
            OPEN cr_craplcs;
            FETCH cr_craplcs INTO rw_craplcs;
            CLOSE cr_craplcs;
          ELSIF pr_sig_tabela = 'LFP' THEN
            OPEN cr_craplfp;
            FETCH cr_craplfp INTO rw_craplfp;
            CLOSE cr_craplfp;
          END IF;
          EXIT;
        EXCEPTION
          WHEN OTHERS THEN
            IF cr_craptvl%ISOPEN THEN
              CLOSE cr_craptvl;
            END IF;
            IF cr_craplcs%ISOPEN THEN
              CLOSE cr_craplcs;
            END IF;
            IF cr_craplfp%ISOPEN THEN
              CLOSE cr_craplfp;
            END IF;

            -- setar critica caso for o ultimo
            IF i = 100 THEN
              RETURN 1; --> em uso
            END IF;
            -- aguardar 0,5 seg. antes de tentar novamente
            sys.dbms_lock.sleep(0.1);
        END;
      END LOOP;

      RETURN 0; --> liberado
    END fn_verifica_tab_em_uso;

    /* Procedimento geral de tratamento do lançamento */
    PROCEDURE pc_trata_lancamentos(pr_dscritic OUT varchar2) IS

      -- Variaveis auxiliares
      vr_aux_cdhistor  PLS_INTEGER;
      vr_aux_cdpesqbb  VARCHAR2(200);
      vr_aux_dtmvtolt  DATE;
      vr_tab_dados_epr empr0001.typ_tab_dados_epr;
      vr_aux_flgopfin  NUMBER;
      vr_aux_flgenvio  NUMBER;
      vr_aux_dsdemail  VARCHAR2(4000);
      vr_tipolog       VARCHAR2(100);

      /* Registro de TEC Salário */
      CURSOR cr_craplcs_lct(pr_cdcooper crapcop.cdcooper%TYPE
                           ,pr_dtmvtolt crapdat.dtmvtolt%TYPE
                           ,pr_nrdconta crapass.nrdconta%TYPE
                           ,pr_cdhistor craplcs.cdhistor%TYPE
                           ,pr_nrdocmto craplcs.nrdocmto%TYPE ) IS
        SELECT lcs.vllanmto
          FROM craplcs lcs
         WHERE lcs.cdcooper = pr_cdcooper
           AND lcs.dtmvtolt = pr_dtmvtolt
           AND lcs.nrdconta = pr_nrdconta
           AND lcs.cdhistor = pr_cdhistor
           AND lcs.nrdocmto = pr_nrdocmto;
      rw_craplcs_lct cr_craplcs_lct%ROWTYPE;

      -- Buscar dados da conta em transferencia
      CURSOR cr_crapccs(pr_cdcooper crapcop.cdcooper%TYPE
                       ,pr_nrdconta crapass.nrdconta%TYPE) IS
        SELECT cdagetrf
              ,nrctatrf
          FROM crapccs
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta;
      rw_crapccs cr_crapccs%ROWTYPE;

      -- Busca o registro de portabilidade aprovada na coop. filiada
      CURSOR cr_portab(pr_cdcooper crapcop.cdcooper%TYPE
                      ,pr_nrportab tbepr_portabilidade.nrunico_portabilidade%TYPE) IS
        SELECT nrdconta
              ,nrctremp
              ,dtaprov_portabilidade
          FROM tbepr_portabilidade
         WHERE cdcooper              = pr_cdcooper
           AND nrunico_portabilidade = pr_nrportab;
      rw_portab cr_portab%ROWTYPE;

      -- Buscar informações do contrato a liquidar e do associado do contrato
      CURSOR cr_crapepr(pr_cdcooper crapcop.cdcooper%TYPE
                       ,pr_nrdconta crapepr.nrdconta%TYPE
                       ,pr_nrctremp crawepr.nrctremp%TYPE) IS
        SELECT epr.tpemprst
              ,epr.nrdconta
              ,epr.nrctremp
              ,ass.cdagenci
              ,ass.nmprimtl
              ,epr.inliquid
          FROM crapepr epr
              ,crapass ass
         WHERE epr.cdcooper = ass.cdcooper
           AND epr.nrdconta = ass.nrdconta
           AND epr.cdcooper = pr_cdcooper
           AND epr.nrdconta = pr_nrdconta
           AND epr.nrctremp = pr_nrctremp;
      rw_crapepr cr_crapepr%ROWTYPE;

    BEGIN
      -- Verificar se está rodando o processo
      IF NOT fn_verifica_processo THEN
        -- Retornar para que o arquivo não seja processado neste momento
        RETURN;
      END IF;

      -- Para estado de crise
      IF vr_aux_flestcri = 0 THEN
        vr_aux_dtmvtolt := rw_crapdat_mensag.dtmvtolt;
      ELSE
        vr_aux_dtmvtolt := vr_aux_dtintegr;
      END IF;

      -- Buscar / Criar Lote
      OPEN cr_craplot(pr_cdcooper => rw_crapcop_mensag.cdcooper
                     ,pr_dtmvtolt => vr_aux_dtmvtolt
                     ,pr_cdagenci => vr_glb_cdagenci
                     ,pr_cdbccxlt => rw_crapcop_mensag.cdbcoctl
                     ,pr_nrdolote => vr_glb_nrdolote);
      FETCH cr_craplot INTO rw_craplot;
      -- Se não encontrou capa do lote
      IF cr_craplot%NOTFOUND THEN
        -- Fecha Cursor
        CLOSE cr_craplot;
        -- Gerar erro
        vr_dscritic := 'Lote nao encontrado.';
        RAISE vr_exc_saida;
      ELSE
        -- Apenas Fecha Cursor
        CLOSE cr_craplot;
      END IF;

      -- Como no campo CodMsg do XML de rejeicao vem o codigo da
      -- mensagem gerada pela cooperativa, sera gravado
      -- gnmvcen.dsmensag = MSGREJ quando a rejeicao ocorrer com
      -- sucesso, e ERROREJ quando nao ocorrer por alguma critica.
      -- Esta informacao sera utilizada para contabilizacao das
      -- mensagens rejeitadas no relatorio crrl536. No LOG ira constar
      -- o codigo da mensagem original.

      /* Rejeitada pela cabine */
      IF vr_aux_tagCABInf THEN
        -- Gera devolucao com mesmo numero de documento da mensagem gerada pelo Legado
        vr_aux_nrdocmto := TO_NUMBER(SUBSTR(vr_aux_NumCtrlIF,LENGTH(vr_aux_NumCtrlIF) - 8,8));
        vr_aux_msgrejei := vr_aux_CodMsg;
        -- Somente para as mensagems abaixo
        IF vr_aux_CodMsg IN('STR0010','PAG0111','STR0048') THEN
          -- Chamar rotina de log no SPB
          pc_gera_log_SPB(pr_tipodlog  => 'REJEITADA OK'
                         ,pr_msgderro  => 'Rejeitada pela cabine');
          -- Setar mensagem
          vr_aux_CodMsg := 'MSGREJ';
          -- Cria registro das movimentacoes no SPB
          pc_cria_gnmvcen(pr_cdagenci => rw_crapcop_mensag.cdagectl
                         ,pr_dtmvtolt => rw_crapdat_mensag.dtmvtolt
                         ,pr_dsmensag => vr_aux_CodMsg
                         ,pr_dsdebcre => 'C'
                         ,pr_vllanmto => vr_aux_VlrLanc
                         ,pr_dscritic => vr_dscritic);
          IF vr_dscritic IS NOT NULL THEN
            raise vr_exc_saida;
          END IF;
          -- Retornar pois o processo finalizou
          RETURN;
        END IF;
      ELSIF vr_aux_CodMsg IN('STR0010R2','PAG0111R2') THEN
        -- Gera devolucao com mesmo numero de documento da mensagem gerada pelo Legado
        vr_aux_nrdocmto := TO_NUMBER(SUBSTR(vr_aux_NumCtrlIF,LENGTH(vr_aux_NumCtrlIF) - 8,8));
      ELSIF LENGTH(vr_aux_NumCtrlRem) >= 7 THEN
        -- Gera devolucao com mesmo numero de documento da mensagem gerada pelo Legado
        vr_aux_nrdocmto := TO_NUMBER(SUBSTR(vr_aux_NumCtrlIF,LENGTH(vr_aux_NumCtrlIF) - 7,7));
      END IF;

      -- Tratamentos conforme cada tipo de mensagem

      /* Estorno TEC */
      IF (vr_aux_CodMsg in('STR0010R2','PAG0111R2') OR vr_aux_tagCABInf) AND SUBSTR(vr_aux_NumCtrlIF,1,1) = '2' THEN

        -- Definir flopfin conforme tenha chego ou não na IF
        IF vr_aux_tagCABInf THEN
          vr_aux_flgopfin := 1; /* Registro Devolução chegou a IF*/
        ELSE
          vr_aux_flgopfin := 0; /* Registro Devolução que não chegou a IF*/
        END IF;


        -- Buscar registro transferência
        OPEN cr_craplcs(pr_cdcooper => rw_crapcop_mensag.cdcooper
                       ,pr_idopetrf => vr_aux_NumCtrlIF);
        FETCH cr_craplcs
         INTO rw_craplcs;
        -- Se encontrar
        IF cr_craplcs%NOTFOUND THEN
          CLOSE cr_craplcs;
          -- Gerar critica
          vr_dscritic := 'Numero de Controle invalido';
        ELSE
          CLOSE cr_craplcs;

          -- Verificar se tabela esta lockada
          IF fn_verifica_tab_em_uso(pr_sig_tabela => 'LCS'
                                   ,pr_rowid => rw_craplcs.rowid ) = 1 THEN
            vr_dscritic := 'Registro de Transferencia Conta Salario '||vr_aux_NumCtrlIF||' em uso. Tente novamente.';
            -- apensa jogar critica em log
            RAISE vr_exc_lock;
          END IF;

          -- Atualizar flopfin do registro da TEC
          BEGIN
            UPDATE craplcs
               SET flgopfin = vr_aux_flgopfin
             WHERE ROWID = rw_craplcs.rowid
             RETURNING nrridlfp
                      ,vllanmto
                      ,nrdconta
                  INTO vr_aux_nrridflp
                      ,vr_aux_VlrLanc
                      ,vr_aux_nrctacre;
            -- Se nao atualizou nenhum registro
            IF SQL%ROWCOUNT = 0 THEN
              -- Gerar critica
              vr_dscritic := 'Numero de Controle invalido';
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar registro craplcs --> '||sqlerrm;
          END;
        END IF;
        -- Se não deu erro
        IF vr_dscritic IS NULL THEN
          -- Se retornou Recid Folha IB
          IF vr_aux_nrridflp <> 0 THEN
            -- Se ficou na cabine
            IF vr_aux_tagCABInf THEN
              vr_aux_flgopfin := 0;
            ELSE
              vr_aux_flgopfin := 1;
            END IF;
            -- Histórico vem de PRM
            vr_aux_cdhistor := gene0001.fn_param_sistema('CRED',rw_crapcop_mensag.cdcooper,'FOLHAIB_HIST_REC_TECSAL');
            -- Flgenvio é sempre false
            vr_aux_flgenvio := 0;
          ELSE
            -- Folha Antigo, tem histórico fixo conforme  estar no SPB ou não
            IF vr_aux_tagCABInf THEN
              vr_aux_cdhistor := 887;
            ELSE
              vr_aux_cdhistor := 801;
            END IF;
            -- OPFIn e flgenvio é sempre true
            vr_aux_flgopfin := 1;
            vr_aux_flgenvio := 1;
          END IF;
          -- Verificar se ja existe Lancamento
          rw_craplcs := NULL;
          OPEN cr_craplcs_lct(pr_cdcooper => rw_crapcop_mensag.cdcooper
                             ,pr_dtmvtolt => rw_crapdat_mensag.dtmvtolt
                             ,pr_nrdconta => vr_aux_nrctacre
                             ,pr_cdhistor => vr_aux_cdhistor
                             ,pr_nrdocmto => vr_aux_nrdocmto);
          FETCH cr_craplcs_lct
           INTO rw_craplcs_lct;
          CLOSE cr_craplcs_lct;
          -- Se já existia LCS
          IF rw_craplcs_lct.vllanmto IS NOT NULL THEN
            -- Gerar critica
            vr_dscritic := 'Lancamento ja existe! Conta: '
                        || vr_aux_nrctacre || ', Valor: '
                        || to_char(rw_craplcs_lct.vllanmto,'999g999g990d00')
                        || ', Lote: ' || vr_glb_nrdolote
                        || ', Doc.: ' || vr_aux_nrdocmto;
          ELSE
            BEGIN
              -- Criar LCS
              INSERT INTO craplcs
                 (cdcooper
                 ,dtmvtolt
                 ,nrdconta
                 ,cdhistor
                 ,nrdocmto
                 ,vllanmto
                 ,nrdolote
                 ,cdbccxlt
                 ,cdagenci
                 ,flgenvio
                 ,flgopfin
                 ,cdopetrf
                 ,cdopecrd
                 ,cdsitlcs
                 ,dttransf
                 ,hrtransf
                 ,idopetrf
                 ,nmarqenv
                 ,nrautdoc
                 ,nrridlfp)
              VALUES
                 (rw_crapcop_mensag.cdcooper
                 ,rw_crapdat_mensag.dtmvtolt
                 ,vr_aux_nrctacre
                 ,vr_aux_cdhistor
                 ,vr_aux_nrdocmto
                 ,vr_aux_VlrLanc
                 ,rw_craplot.nrdolote
                 ,rw_craplot.cdbccxlt
                 ,rw_craplot.cdagenci
                 ,vr_aux_flgenvio
                 ,vr_aux_flgopfin
                 ,'1'
                 ,'1'
                 ,1
                 ,rw_crapdat_mensag.dtmvtolt
                 ,to_char(sysdate,'sssss')
                 ,vr_aux_NumCtrlIF
                 ,NULL
                 ,0
                 ,vr_aux_nrridflp);
              -- Atualizar capa do Lote
              UPDATE craplot SET craplot.vlinfocr = nvl(craplot.vlinfocr,0) + vr_aux_VlrLanc
                                ,craplot.vlcompcr = nvl(craplot.vlcompcr,0) + vr_aux_VlrLanc
                                ,craplot.qtinfoln = nvl(craplot.qtinfoln,0) + 1
                                ,craplot.qtcompln = nvl(craplot.qtcompln,0) + 1
                                ,craplot.nrseqdig = nvl(craplot.nrseqdig,0) + 1
              WHERE craplot.ROWID = rw_craplot.ROWID;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao criar lancamento de devolucao ou na atualizacao do Lote: '||sqlerrm;
            END;
            -- Se não houve erro na gravação acima e somente para o produto Folha IB
            IF vr_dscritic IS NULL AND vr_aux_nrridflp > 0 THEN
              -- Buscar dados da conta em transferencia
              OPEN cr_crapccs(rw_crapcop_mensag.cdcooper,vr_aux_nrctacre);
              FETCH cr_crapccs
               INTO rw_crapccs;
              CLOSE cr_crapccs;
              -- Montar email
              vr_aux_dsdemail := 'Ola, houve rejeicao na cabine da seguinte operacao TEC Salario: <br><br>'
                              || ' Conta/Dv: ' || vr_aux_nrctacre || ' <br>'
                              || ' PA: ' || rw_craplot.cdagenci || ' <br>'
                              || ' Dt.Credito: ' || rw_crapdat_mensag.dtmvtolt || ' <br>'
                              || ' Dt.Transferencia: ' || rw_crapdat_mensag.dtmvtolt || ' <br>'
                              || ' Valor: ' || to_char(vr_aux_VlrLanc,'fm999g999g999g990d00')  || ' <br>'
                              || ' Age: ' || rw_crapccs.cdagetrf    || ' <br>'
                              || ' Conta TRF: ' || rw_crapccs.nrctatrf || '. <br><br>'
                              || ' Lembramos que voce tera o dia de hoje e o proximo dia util para reprocessa-la na tela TRFSAL opcao X. '
                              || ' Do contrario este lancamento sera devolvido automaticamente para a Empresa. '
                              || ' Voce tambem podera utilizar a opcao E para efetuar o Estorno antecipado, caso nao deseje esperar ate o final do proximo dia util para o devido estorno. <br><br> '
                              || ' Atenciosamente, <br> '
                              || ' Sistemas Cecred.';

              -- Enviar Email para o Financeiro
              gene0003.pc_solicita_email(pr_cdcooper        => rw_crapcop_mensag.cdcooper
                                        ,pr_cdprogra        => vr_glb_cdprogra
                                        ,pr_des_destino     => gene0001.fn_param_sistema('CRED',rw_crapcop_mensag.cdcooper,'FOLHAIB_EMAIL_ALERT_FIN')
                                        ,pr_des_assunto     => 'Folha de Pagamento - Rejeicao TEC na Cabine'
                                        ,pr_des_corpo       => vr_aux_dsdemail
                                        ,pr_des_anexo       => ''
                                        ,pr_flg_enviar      => 'S'
                                        ,pr_flg_log_batch   => 'N' --> Incluir inf. no log
                                        ,pr_des_erro        => vr_dscritic);
              -- Se ocorreu erro
              IF trim(vr_dscritic) IS NOT NULL THEN
                -- Gerar LOG e continuar o processo normal
                btch0001.pc_gera_log_batch(pr_cdcooper     => 3 /*Sempre na Central*/
                                          ,pr_ind_tipo_log => 1
                                          ,pr_des_log      => vr_dscritic);
                -- Limpar critica
                vr_dscritic := null;
              END IF;
            END IF;
          END IF;
        END IF;

        -- Se houve critica
        IF vr_dscritic IS NOT NULL THEN
          -- Se nao veio da Cabine
          IF vr_aux_tagCABInf THEN
            -- Gera LOG SPB
            pc_gera_log_SPB(pr_tipodlog  => 'REJEITADA NAO OK'
                           ,pr_msgderro  => vr_dscritic);
            -- Sobescreve o codMsg
            vr_aux_CodMsg := 'ERROREJ';
          ELSE
            -- Gera LOG SPB
            pc_gera_log_SPB(pr_tipodlog  => 'RETORNO SPB'
                           ,pr_msgderro  => vr_dscritic);
          END IF;

          -- Cria registro das movimentacoes no SPB
          pc_cria_gnmvcen(pr_cdagenci => rw_crapcop_mensag.cdagectl
                         ,pr_dtmvtolt => rw_crapdat_mensag.dtmvtolt
                         ,pr_dsmensag => vr_aux_CodMsg
                         ,pr_dsdebcre => 'C'
                         ,pr_vllanmto => vr_aux_VlrLanc
                         ,pr_dscritic => vr_dscritic);
          IF vr_dscritic IS NOT NULL THEN
            raise vr_exc_saida;
          END IF;
          -- Processo finalizado
          RETURN;
        ELSE
          -- Se estava na SPB
          IF vr_aux_tagCABInf  THEN
            vr_aux_CodMsg := 'MSGREJ';
          END IF;
          -- Cria registro das movimentacoes no SPB
          pc_cria_gnmvcen(pr_cdagenci => rw_crapcop_mensag.cdagectl
                         ,pr_dtmvtolt => rw_crapdat_mensag.dtmvtolt
                         ,pr_dsmensag => vr_aux_CodMsg
                         ,pr_dsdebcre => 'C'
                         ,pr_vllanmto => vr_aux_VlrLanc
                         ,pr_dscritic => vr_dscritic);
          IF vr_dscritic IS NOT NULL THEN
            raise vr_exc_saida;
          END IF;
        END IF;
      ELSE /* Eh ESTORNO de TED ou CREDITO de TED/TEC */
        -- Verifica se dados do pagamento da portabilidade conferem.
        -- Caso contrario gera devolucao(STR0048)
        IF vr_aux_CodMsg = 'STR0047R2' THEN
          -- Identifica a IF Credora Original(Coop. Filiada)
          OPEN cr_crapcop(pr_cdagectl => vr_aux_CtCredtd); -- C/C filiada na Central
          FETCH cr_crapcop
           INTO rw_crapcop_portab;
          -- Se não encontrar
          IF cr_crapcop%NOTFOUND THEN
            CLOSE cr_crapcop;
            -- Coop nao encontrar
            vr_dscritic := 'Erro de sistema: Registro da cooperativa nao encontrado.';
          ELSE
            CLOSE cr_crapcop;
            -- Busca data na cooperativa onde a conta foi transferida
            OPEN btch0001.cr_crapdat(pr_cdcooper => rw_crapcop_portab.cdcooper);
            FETCH btch0001.cr_crapdat
             INTO rw_crapdat_portab;
            -- Se não encontrar
            IF btch0001.cr_crapdat%NOTFOUND THEN
              CLOSE btch0001.cr_crapdat;
              -- Data nao encontrar
              vr_dscritic := 'Erro de sistema: Registro de data nao encontrado.';
            ELSE
              CLOSE btch0001.cr_crapdat;
            END IF;
          END IF;
          -- Se houve erro
          IF vr_dscritic IS NOT NULL THEN
            -- Gerar LOG
            pc_gera_log_SPB(pr_tipodlog  => 'RECEBIDA'
                           ,pr_msgderro  => vr_dscritic);
            -- Retornar a execução
            RETURN;
          END IF;

          -- Busca o registro de portabilidade aprovada na coop. filiada
          OPEN cr_portab(pr_cdcooper => rw_crapcop_portab.cdcooper
                        ,pr_nrportab => vr_aux_NUPortdd);
          FETCH cr_portab
           INTO rw_portab;
          -- Se não encontrar
          IF cr_portab%NOTFOUND THEN
            CLOSE cr_portab;
            -- Gerar devolucao STR0048
            pc_gera_erro_xml(pr_dsdehist => 'Portabilidade não localizada.'
                            ,pr_codierro => 78
                            ,pr_dscritic => vr_dscritic);
            -- Se retornou erro
            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;
            -- Retornar a execução
            RETURN;

          ELSE
            CLOSE cr_portab;
            -- Identifica o contrato a ser liquidado e o associado do contrato
            OPEN cr_crapepr(rw_crapcop_portab.cdcooper
                           ,rw_portab.nrdconta
                           ,rw_portab.nrctremp);
            FETCH cr_crapepr
             INTO rw_craPepr;
            CLOSE cr_crapepr;
            -- Armazenar informações
            vr_aux_nrctremp := rw_crapepr.nrctremp;
            vr_aux_tpemprst := rw_crapepr.tpemprst; /*PP ou TR*/

            -- Buscar informações do contrato
            empr0001.pc_obtem_dados_empresti (pr_cdcooper       => rw_crapcop_portab.cdcooper --> Cooperativa conectada
                                             ,pr_cdagenci       => 0                     --> Código da agência
                                             ,pr_nrdcaixa       => 0                     --> Número do caixa
                                             ,pr_cdoperad       => '1'                   --> Código do operador
                                             ,pr_nmdatela       => vr_glb_cdprogra||'_1'     --> Nome datela conectada
                                             ,pr_idorigem       => 1                     --> Indicador da origem da chamada
                                             ,pr_nrdconta       => rw_crapepr.nrdconta   --> Conta do associado
                                             ,pr_idseqttl       => 1                     --> Sequencia de titularidade da conta
                                             ,pr_rw_crapdat     => rw_crapdat_portab          --> Vetor com dados de parâmetro (CRAPDAT)
                                             ,pr_dtcalcul       => rw_crapdat_portab.dtmvtolt --> Data solicitada do calculo
                                             ,pr_nrctremp       => rw_crapepr.nrctremp   --> Número contrato empréstimo
                                             ,pr_cdprogra       => vr_glb_cdprogra||'_1'     --> Programa conectado
                                             ,pr_inusatab       => TRUE                  --> Indicador de utilização da tabela
                                             ,pr_flgerlog       => 'N'                   --> Gerar log S/N
                                             ,pr_flgcondc       => TRUE                  --> Mostrar emprestimos liquidados sem prejuizo
                                             ,pr_nmprimtl       => rw_crapepr.nmprimtl   --> Nome Primeiro Titular
                                             ,pr_tab_parempctl  => --> Dados tabela parametro
                                                                   tabe0001.fn_busca_dstextab(pr_cdcooper => 3
                                                                                             ,pr_nmsistem => 'CRED'
                                                                                             ,pr_tptabela => 'USUARI'
                                                                                             ,pr_cdempres => 11
                                                                                             ,pr_cdacesso => 'PAREMPCTL'
                                                                                             ,pr_tpregist => 01)
                                             ,pr_tab_digitaliza => --> Dados tabela parametro
                                                                   tabe0001.fn_busca_dstextab(pr_cdcooper => rw_crapcop_portab.cdcooper
                                                                                             ,pr_nmsistem => 'CRED'
                                                                                             ,pr_tptabela => 'GENERI'
                                                                                             ,pr_cdempres => 00
                                                                                             ,pr_cdacesso => 'DIGITALIZA'
                                                                                             ,pr_tpregist => 5)
                                             ,pr_nriniseq       => 0                     --> Numero inicial da paginacao
                                             ,pr_nrregist       => 0                     --> Numero de registros por pagina
                                             ,pr_qtregist       => vr_aux_qtregist       --> Qtde total de registros
                                             ,pr_tab_dados_epr  => vr_tab_dados_epr      --> Saida com os dados do empréstimo
                                             ,pr_des_reto       => vr_des_reto           --> Retorno OK / NOK
                                             ,pr_tab_erro       => vr_tab_erro);         --> Tabela com possíves erros
            -- Testar saida
            IF vr_des_reto = 'NOK' THEN
              IF vr_tab_erro.exists(vr_tab_erro.first) THEN
                vr_dscritic := 'Erro de Sistema - Conta: '||rw_portab.nrdconta||' --> '||
                                -- concatenado a critica na versao oracle para tbm saber a causa de abortar o programa
                                vr_tab_erro(vr_tab_erro.first).dscritic;
              ELSE
                vr_dscritic := 'Erro de Sistema - Conta: '||rw_portab.nrdconta||' nao possui emprestimo.';
              END IF;
              -- Gerar LOG
              pc_gera_log_SPB(pr_tipodlog  => 'RECEBIDA'
                             ,pr_msgderro  => vr_dscritic);
              -- Retornar a execução
              RETURN;

            END IF;

            -- Calcular Saldo Devedor
            vr_aux_vlsldliq := 0;
            IF vr_tab_dados_epr.COUNT > 0 THEN
              vr_aux_vlsldliq := NVL(vr_tab_dados_epr(vr_tab_dados_epr.first).vlsdeved,0)
                               + NVL(vr_tab_dados_epr(vr_tab_dados_epr.first).vlmtapar,0)
                               + NVL(vr_tab_dados_epr(vr_tab_dados_epr.first).vlmrapar,0);
            END IF;
            vr_log_msgderro := NULL;
            -- 1. Verificar se o valor do pagamento confere com o saldo devedor
            IF vr_aux_vlsldliq <> vr_aux_VlrLanc THEN
              -- Gerar devolucao STR0048
              vr_aux_codierro := 79;
              vr_log_msgderro := 'Portabilidade recusada por divergencia de valor.';
            -- 2. Verifica se contrato ja foi liquidado
            ELSIF rw_crapepr.inliquid = 1 THEN
              vr_aux_codierro := 84;
              vr_log_msgderro := 'Operação de portabilidade já liquidada pelo credor original.';
            -- 3. Verifica se pagamento esta sendo efetuado na mesma data que a IF
            --    Credora Original(neste caso a coop. filiada) aprovou a portabilidade
            ELSIF rw_portab.dtaprov_portabilidade <> to_date(vr_aux_DtMovto,'RRRR-MM-DD') THEN
              vr_aux_codierro := 83;
              vr_log_msgderro := 'Pagamento em data inválida.';
            END IF;

            -- Se houve critica
            IF vr_log_msgderro IS NOT NULL THEN
              -- Gerar devolucao STR0048
              pc_gera_erro_xml(pr_dsdehist => vr_dscritic
                              ,pr_codierro => vr_aux_codierro
                              ,pr_dscritic => vr_dscritic);
              -- Se retornou erro
              IF vr_dscritic IS NOT NULL THEN
                RAISE vr_exc_saida;
              END IF;
              -- Gerar LOG
              vr_dscritic := to_char(rw_crapdat_portab.dtmvtolt,'dd/mm/rrrr hh24:mi:ss')
                          || ' => Liquidacao '
                          || '|' || rw_crapepr.cdagenci
                          || '|' || rw_crapepr.nrdconta
                          || '|' || rw_crapepr.nrctremp
                          || '|' || vr_aux_NUPortdd
                          || '|' ||'Cancelar => '||vr_log_msgderro;
              -- Escrever em LOG e finalizar o processo
              btch0001.pc_gera_log_batch(pr_cdcooper     => rw_crapcop_portab.cdcooper
                                        ,pr_ind_tipo_log => 1
                                        ,pr_des_log      => vr_dscritic
                                        ,pr_nmarqlog     => 'logprt');

              -- Retornar a execução
              RETURN;
            END IF;

          END IF;
        END IF;

        -- Caso seja estorno de TED de repasse de convenio entao despreza
        IF vr_aux_CodMsg IN('STR0007','STR0020') THEN
          -- Retornar
          RETURN;
        END IF;

        -- Troca de numerarios - CECRED
        IF vr_aux_CodMsg = 'STR0003R2' THEN
          -- Montar email
          vr_aux_dsdemail := 'Codigo Mensagem: ' || vr_aux_CodMsg || ' <br>'
                          || 'Numero controle STR: ' || vr_aux_NumCtrlRem || ' <br>'
                          || 'Data Hora Bacen: ' || vr_aux_DtHrBC || ' <br>'
                          || 'ISPB IF Debitada: ' || vr_aux_ISPBIFDebtd || ' <br>'
                          || 'Agencia Debitada: ' || vr_aux_AgDebtd || ' <br>'
                          || 'ISPB IF Credidata: ' || vr_aux_ISPBIFCredtd || ' <br>'
                          || 'Agencia Creditada: ' || vr_aux_AgCredtd || ' <br>'
                          || 'Valor Lançamento: ' || vr_aux_VlrLanc || ' <br>'
                          || 'Codigo Municipio Origem: ' || vr_aux_CodMunicOrigem || ' <br>'
                          || 'Codigo Municipio Destino: ' || vr_aux_codMunicDest || ' <br>'
                          || 'Data Movimento: ' || vr_aux_DtMovto || ' <br><br>';
          -- Incluir numerarios
          FOR vr_idx IN vr_tab_numerario.first..vr_tab_numerario.last LOOP
            vr_aux_dsdemail := vr_aux_dsdemail
                            || 'Categoria: ' || vr_tab_numerario(vr_idx).cdcatego || ' <br>'
                            || 'Valor Denominacao: ' || vr_tab_numerario(vr_idx).vlrdenom || ' <br> '
                            || 'Quantidade Denominacao: ' || vr_tab_numerario(vr_idx).qtddenom || ' <br>';
          END LOOP;

          -- Enviar Email para o Financeiro
          gene0003.pc_solicita_email(pr_cdcooper        => rw_crapcop_mensag.cdcooper
                                    ,pr_cdprogra        => vr_glb_cdprogra
                                    ,pr_des_destino     => gene0001.fn_param_sistema('CRED',rw_crapcop_mensag.cdcooper,'EMAIL_CARRO_FORTE')
                                    ,pr_des_assunto     => 'Troca de numerarios - CECRED'
                                    ,pr_des_corpo       => vr_aux_dsdemail
                                    ,pr_des_anexo       => ''
                                    ,pr_flg_enviar      => 'S'
                                    ,pr_flg_log_batch   => 'N' --> Incluir inf. no log
                                    ,pr_des_erro        => vr_dscritic);
          -- Se ocorreu erro
          IF trim(vr_dscritic) IS NOT NULL THEN
            -- Gerar LOG e continuar o processo normal
            btch0001.pc_gera_log_batch(pr_cdcooper     => 3 /*Sempre na Central*/
                                      ,pr_ind_tipo_log => 1
                                      ,pr_des_log      => vr_dscritic);
            -- Limpar critica
            vr_dscritic := null;
          END IF;

          -- Retornar a execução
          RETURN;
        END IF;

        -- Caso seja estorno de TED de BACENJUD entao despreza
        IF vr_aux_CodMsg IN('STR0025','PAG0121') THEN
          -- Buscar TVL
          OPEN cr_craptvl(rw_crapcop_mensag.cdcooper,vr_aux_NumCtrlIF);
          FETCH cr_craptvl
           INTO rw_craptvl;
          -- Se não encontrou
          IF cr_craptvl%NOTFOUND THEN
            CLOSE cr_craptvl;
            -- Gera LOG SPB conforme cabInf
            IF vr_aux_tagCABInf THEN
              pc_gera_log_SPB(pr_tipodlog  => 'REJEITADA NAO OK'
                             ,pr_msgderro  => 'Numero de Controle invalido');
              vr_aux_CodMsg := 'ERROREJ';
            ELSE
              pc_gera_log_SPB(pr_tipodlog  => 'RETORNO SPB'
                             ,pr_msgderro  => 'Numero de Controle invalido');
            END IF;
            -- Cria registro das movimentacoes no SPB
            pc_cria_gnmvcen(pr_cdagenci => rw_crapcop_mensag.cdagectl
                           ,pr_dtmvtolt => rw_crapdat_mensag.dtmvtolt
                           ,pr_dsmensag => vr_aux_codMsg
                           ,pr_dsdebcre => 'C'
                           ,pr_vllanmto => vr_aux_VlrLanc
                           ,pr_dscritic => vr_dscritic);
            IF vr_dscritic IS NOT NULL THEN
              raise vr_exc_saida;
            END IF;

            -- Retornar a execução
            RETURN;
          ELSE
            CLOSE cr_craptvl;
            -- Gera log de estorno na cobine
            gene0005.pc_gera_inconsistencia(pr_cdcooper => rw_crapcop_mensag.cdcooper
                                           ,pr_iddgrupo => 2
                                           ,pr_tpincons => 2 -- Erro
                                           ,pr_dsregist => 'Cooperativa: ' || rw_crapcop_mensag.nmrescop
                                                        || '   Conta Origem: ' || rw_craptvl.nrdconta
                                                        || '   Valor: ' || to_char(rw_craptvl.vldocrcb,'99g999g990d00')
                                                        || '   Identificacao Dep.: ' || rw_craptvl.nrcctrcb
                                           ,pr_dsincons => 'TED BacenJud: Rejeitada pela cabine'
                                           ,pr_des_erro => vr_des_reto
                                           ,pr_dscritic => vr_dscritic);

            -- Retornar a execução
            RETURN;

          END IF;
        END IF;

        -- Para Bloqueio Judicial ou mensagens da Cabine
        rw_craptvl := null;
        IF vr_aux_CodMsg IN('STR0010R2','PAG0111R2') OR vr_aux_tagCABInf THEN
          -- Busca numero da conta a CREDITAR
          OPEN cr_craptvl(rw_crapcop_mensag.cdcooper,vr_aux_NumCtrlIF);
          FETCH cr_craptvl
           INTO rw_craptvl;
          -- Se não encontrou
          IF cr_craptvl%NOTFOUND THEN
            CLOSE cr_craptvl;
            -- Gera LOG SPB conforme cabInf
            IF vr_aux_tagCABInf THEN
              vr_aux_CodMsg := 'ERROREJ';
              pc_gera_log_SPB(pr_tipodlog  => 'REJEITADA NAO OK'
                             ,pr_msgderro  => 'Numero de Controle invalido');
            ELSE
              pc_gera_log_SPB(pr_tipodlog  => 'RETORNO SPB'
                             ,pr_msgderro  => 'Numero de Controle invalido');
            END IF;
            -- Cria registro das movimentacoes no SPB
            pc_cria_gnmvcen(pr_cdagenci => rw_crapcop_mensag.cdagectl
                           ,pr_dtmvtolt => rw_crapdat_mensag.dtmvtolt
                           ,pr_dsmensag => vr_aux_codMsg
                           ,pr_dsdebcre => 'C'
                           ,pr_vllanmto => vr_aux_VlrLanc
                           ,pr_dscritic => vr_dscritic);
            IF vr_dscritic IS NOT NULL THEN
              raise vr_exc_saida;
            END IF;

            -- Retornar a execução
            RETURN;

          ELSE
            CLOSE cr_craptvl;
            -- Se está na cabine
            IF vr_aux_tagCABInf THEN
              vr_aux_VlrLanc := rw_craptvl.vldocrcb;

              -- Verificar se tabela esta lockada
              IF fn_verifica_tab_em_uso(pr_sig_tabela => 'TVL'
                                       ,pr_rowid => rw_craptvl.rowid ) = 1 THEN
                vr_dscritic := 'Registro de Transferencia DOC/TED '||vr_aux_NumCtrlIF||' em uso. Tente novamente.';
                -- apensa jogar critica em log
                RAISE vr_exc_lock;
              END IF;

              -- Atualizar a operação como finalizada
              BEGIN
                UPDATE craptvl
                   SET craptvl.flgopfin = 1 /*Finaliz.*/
                 WHERE ROWID = rw_craptvl.rowid;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao atualizar craptlv --> '||sqlerrm;
                  raise vr_exc_saida;
              END;
            END IF;
            -- Usar a conta da TVL
            vr_aux_nrctacre := rw_craptvl.nrdconta;

            -- Logar Estorno TED de nao cooperado
            IF vr_aux_nrctacre = 0 THEN
              -- Gera LOG SPB conforme cabInf
              IF vr_aux_tagCABInf THEN
                vr_aux_CodMsg := 'ERROREJ';
                pc_gera_log_SPB(pr_tipodlog  => 'REJEITADA NAO OK'
                               ,pr_msgderro  => 'Rejeitada pela cabine');
              ELSE
                pc_gera_log_SPB(pr_tipodlog  => 'ENVIADA NAO OK'
                               ,pr_msgderro  => fn_motivo_devolucao);
              END IF;
              -- Cria registro das movimentacoes no SPB
              pc_cria_gnmvcen(pr_cdagenci => rw_crapcop_mensag.cdagectl
                             ,pr_dtmvtolt => vr_aux_dtmvtolt
                             ,pr_dsmensag => vr_aux_codMsg
                             ,pr_dsdebcre => 'C'
                             ,pr_vllanmto => vr_aux_VlrLanc
                             ,pr_dscritic => vr_dscritic);
              IF vr_dscritic IS NOT NULL THEN
                raise vr_exc_saida;
              END IF;

              -- Retornar a execução
              RETURN;

            END IF;
          END IF;
        ELSE
          -- Conta a creditar
          vr_aux_nrctacre := vr_aux_CtCredtd;
        END IF;

        -- Se for bloqueio Judicial deve-se gerar email e encerrar o processo nao deve creditar a conta
        IF rw_craptvl.nrdconta IS NOT NULL AND rw_craptvl.tpdctacr = 9 THEN
          -- Gera log de estorno na cobine
          gene0005.pc_gera_inconsistencia(pr_cdcooper => rw_crapcop_mensag.cdcooper
                                         ,pr_iddgrupo => 2
                                         ,pr_tpincons => 2 -- Erro
                                         ,pr_dsregist => 'Cooperativa: ' || rw_crapcop_mensag.nmrescop
                                                      || '   Conta Origem: ' || rw_craptvl.nrdconta
                                                      || '   Valor: ' || to_char(vr_aux_VlrLanc,'99g999g990d00')
                                                      || '   Identificacao Dep.: ' || rw_craptvl.nrcctrcb
                                         ,pr_dsincons => 'TED BacenJud: Devolvida'
                                         ,pr_des_erro => vr_des_reto
                                         ,pr_dscritic => vr_dscritic);
          -- Cria registro das movimentacoes no SPB
          pc_cria_gnmvcen(pr_cdagenci => rw_crapcop_mensag.cdagectl
                         ,pr_dtmvtolt => vr_aux_dtmvtolt
                         ,pr_dsmensag => vr_aux_codMsg
                         ,pr_dsdebcre => 'C'
                         ,pr_vllanmto => vr_aux_VlrLanc
                         ,pr_dscritic => vr_dscritic);
          IF vr_dscritic IS NOT NULL THEN
            raise vr_exc_saida;
          END IF;
          pc_gera_log_SPB(pr_tipodlog  => 'ENVIADA NAO OK'
                         ,pr_msgderro  => 'DEVOLUCAO BACENJUD');

          -- Retornar a execução
          RETURN;

        END IF;

        -- Se existir craptco eh uma conta incorporada ou migrada,
        -- conforme validacao efetuada na procedure verifica_conta.
        IF rw_craptco.nrdconta IS NOT NULL THEN
          pc_processa_conta_transferida(pr_cdcopant => rw_crapcop_mensag.cdcooper
                                       ,pr_nrctaant => vr_aux_nrctacre
                                       ,pr_vlrlanct => vr_aux_VlrLanc
                                       ,pr_dscritic => vr_dscritic);
          -- Se retornou erro
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;
        ELSE
          -- Verificar se o LCM já não existe
          vr_aux_existlcm := 0;
          vr_aux_vllanmto := NULL;
          OPEN cr_craplcm_exis(pr_cdcooper => rw_crapcop_mensag.cdcooper
                              ,pr_dtmvtolt => rw_craplot.dtmvtolt
                              ,pr_cdagenci => rw_craplot.cdagenci
                              ,pr_cdbccxlt => rw_craplot.cdbccxlt
                              ,pr_nrdolote => rw_craplot.nrdolote
                              ,pr_nrdctabb => vr_aux_nrctacre
                              ,pr_nrdocmto => vr_aux_nrdocmto);
          FETCH cr_craplcm_exis
           INTO vr_aux_existlcm,vr_aux_vllanmto;
          CLOSE cr_craplcm_exis;
          -- Se encontrou
          IF vr_aux_existlcm = 1 THEN
            -- Para Rejeição
            IF vr_aux_CodMsg in ('STR0010R2','PAG0111R2') OR vr_aux_tagCABInf THEN
              -- Montar textos de logs
              vr_log_msgderro := 'Lancamento ja existe! Conta: ' || vr_aux_nrctacre
                              || ', Lote: ' || rw_craplot.nrdolote
                              || ', Doc.: ' || vr_aux_nrdocmto;
              -- Conforme cabine
              IF vr_aux_tagCABInf THEN
                vr_tipolog := 'REJEITADA NAO OK';
                vr_aux_CodMsg := 'ERROREJ';
              ELSE
                vr_tipolog := 'RETORNO SPB';
              END IF;
            ELSE
              -- Montar textos de logs
              vr_tipolog := 'RECEBIDA';
              vr_log_msgderro := 'Lancamento ja existe! Lote: '|| rw_craplot.nrdolote
                              || ', Doc.: ' || vr_aux_nrdocmto;
            END IF;
            -- Cria registro das movimentacoes no SPB
            pc_cria_gnmvcen(pr_cdagenci => rw_crapcop_mensag.cdagectl
                           ,pr_dtmvtolt => vr_aux_dtmvtolt
                           ,pr_dsmensag => vr_aux_codMsg
                           ,pr_dsdebcre => 'C'
                           ,pr_vllanmto => vr_aux_VlrLanc
                           ,pr_dscritic => vr_dscritic);
            IF vr_dscritic IS NOT NULL THEN
              raise vr_exc_saida;
            END IF;
            -- Gerar LOG SPB
            pc_gera_log_SPB(pr_tipodlog  => vr_tipolog
                           ,pr_msgderro  => vr_log_msgderro);

            -- Retornar a execução
            RETURN;

          ELSE
            -- Gerar histórico
            /* Estorno TED */
            IF vr_aux_CodMsg in('STR0010R2','PAG0111R2') THEN
              vr_aux_cdhistor := 600;
              vr_aux_cdpesqbb := vr_aux_CodDevTransf;
            /* Estorno TED Rejeitada*/
            ELSIF vr_aux_tagCABInf THEN
              vr_aux_cdhistor := 887;
              vr_aux_cdpesqbb := 'TED/TEC rejeitado coop';
            /* Credito TEC */
            ELSIF vr_aux_CodMsg IN('STR0037R2','PAG0137R2') THEN
              vr_aux_cdhistor := 799;
              vr_aux_cdpesqbb := vr_aux_dadosdeb;
            ELSIF vr_aux_CodMsg = 'STR0047R2' THEN
              vr_aux_cdhistor := 1921;
              vr_aux_cdpesqbb := 'CRED TED PORT';
            ELSE
              /* Credito TED */
              vr_aux_cdhistor := 578;
              vr_aux_cdpesqbb := vr_aux_dadosdeb;
            END IF;
            -- Gerar lançamento em conta
            BEGIN
              INSERT INTO craplcm
                 (cdcooper
                 ,dtmvtolt
                 ,cdagenci
                 ,cdbccxlt
                 ,nrdolote
                 ,nrdconta
                 ,nrdctabb
                 ,nrdocmto
                 ,cdhistor
                 ,nrseqdig
                 ,cdpesqbb
                 ,vllanmto
                 ,cdoperad
                 ,hrtransa)
              VALUES
                 (rw_crapcop_mensag.cdcooper
                 ,rw_craplot.dtmvtolt
                 ,rw_craplot.cdagenci
                 ,rw_craplot.cdbccxlt
                 ,rw_craplot.nrdolote
                 ,vr_aux_nrctacre
                 ,vr_aux_nrctacre
                 ,vr_aux_nrdocmto
                 ,vr_aux_cdhistor
                 ,nvl(rw_craplot.nrseqdig,0) + 1
                 ,vr_aux_cdpesqbb
                 ,vr_aux_VlrLanc
                 ,'1'
                 ,to_char(sysdate,'sssss'));
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao inserir na tabela craplcm --> ' || SQLERRM;
               -- Sair da rotina
               RAISE vr_exc_saida;
            END;

            -- Atualizar capa do Lote
            BEGIN
              UPDATE craplot SET craplot.vlinfocr = nvl(craplot.vlinfocr,0) + vr_aux_VlrLanc
                                ,craplot.vlcompcr = nvl(craplot.vlcompcr,0) + vr_aux_VlrLanc
                                ,craplot.qtinfoln = nvl(craplot.qtinfoln,0) + 1
                                ,craplot.qtcompln = nvl(craplot.qtcompln,0) + 1
                                ,craplot.nrseqdig = nvl(craplot.nrseqdig,0) + 1
              WHERE craplot.ROWID = rw_craplot.ROWID;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar tabela craplot. ' || SQLERRM;
                -- Sair da rotina
                RAISE vr_exc_saida;
            END;

            -- Conforme cabine
            IF vr_aux_tagCABInf THEN
              vr_aux_CodMsg := 'ERROREJ';
            END IF;
            -- Cria registro das movimentacoes no SPB
            pc_cria_gnmvcen(pr_cdagenci => rw_crapcop_mensag.cdagectl
                           ,pr_dtmvtolt => vr_aux_dtmvtolt
                           ,pr_dsmensag => vr_aux_codMsg
                           ,pr_dsdebcre => 'C'
                           ,pr_vllanmto => vr_aux_VlrLanc
                           ,pr_dscritic => vr_dscritic);
            IF vr_dscritic IS NOT NULL THEN
              raise vr_exc_saida;
            END IF;
          END IF;
        END IF;
      END IF;

      -- Mensagem de Sucesso
      IF vr_aux_CodMsg IN('STR0010R2','PAG0111R2') THEN
        -- Gerar log conforme situação cabine
        IF vr_aux_tagCABInf THEN
          vr_aux_CodMsg := vr_aux_msgrejei;
          -- Gerar LOG
          pc_gera_log_SPB(pr_tipodlog  => 'REJEITADA OK'
                         ,pr_msgderro  => 'Rejeitada pela cabine');
        ELSE
          -- Gerar LOG
          pc_gera_log_SPB(pr_tipodlog  => 'ENVIADA NAO OK'
                         ,pr_msgderro  => fn_motivo_devolucao);
        END IF;
      -- Liquidar contrato de empréstimo após receber pagamento da portabilidade
      ELSIF vr_aux_CodMsg = 'STR0047R2' THEN
        -- Leitura do Lote na cooperativa do contrato referente ao crédito do saldo devedor
        -- Verificar criação do lote
        OPEN cr_craplot(pr_cdcooper => rw_crapcop_portab.cdcooper
                       ,pr_dtmvtolt => rw_crapdat_portab.dtmvtolt
                       ,pr_cdagenci => vr_glb_cdagenci
                       ,pr_cdbccxlt => vr_glb_cdbccxlt
                       ,pr_nrdolote => 600030);
        FETCH cr_craplot INTO rw_craplot;
        -- Se não encontrou capa do lote
        IF cr_craplot%NOTFOUND THEN
          -- Fecha Cursor
          CLOSE cr_craplot;

          BEGIN
            --Inserir a capa do lote retornando informacoes para uso posterior
            INSERT INTO craplot
               (dtmvtolt
               ,cdagenci
               ,cdbccxlt
               ,nrdolote
               ,tplotmov
               ,cdcooper
               ,nrseqdig
               ,cdhistor
               ,cdoperad)
            VALUES
               (rw_crapdat_portab.dtmvtolt
               ,vr_glb_cdagenci
               ,vr_glb_cdbccxlt
               ,600030
               ,vr_glb_tplotmov
               ,rw_crapcop_portab.cdcooper
               ,0
               ,0
               ,'1')
             RETURNING dtmvtolt
                      ,cdagenci
                      ,cdbccxlt
                      ,nrdolote
                      ,nrseqdig
                      ,cdcooper
                      ,tplotmov
                      ,vlinfodb
                      ,vlcompdb
                      ,qtinfoln
                      ,qtcompln
                      ,cdoperad
                      ,tpdmoeda
                      ,rowid
                  into rw_craplot.dtmvtolt
                      ,rw_craplot.cdagenci
                      ,rw_craplot.cdbccxlt
                      ,rw_craplot.nrdolote
                      ,rw_craplot.nrseqdig
                      ,rw_craplot.cdcooper
                      ,rw_craplot.tplotmov
                      ,rw_craplot.vlinfodb
                      ,rw_craplot.vlcompdb
                      ,rw_craplot.qtinfoln
                      ,rw_craplot.qtcompln
                      ,rw_craplot.cdoperad
                      ,rw_craplot.tpdmoeda
                      ,rw_craplot.rowid;
           EXCEPTION
             WHEN OTHERS THEN
               vr_dscritic := 'Erro ao inserir na tabela craplot (8453). '||SQLERRM;
               -- Sair da rotina
               RAISE vr_exc_saida;
           END;
        ELSE
          -- Apenas Fecha Cursor
          CLOSE cr_craplot;
        END IF;
        -- Verificar se já não existe lançamento na conta do Cooperado
        vr_aux_existlcm := 0;
        vr_aux_vllanmto := NULL;
        OPEN cr_craplcm_exis(pr_cdcooper => rw_crapcop_portab.cdcooper
                            ,pr_dtmvtolt => rw_craplot.dtmvtolt
                            ,pr_cdagenci => rw_craplot.cdagenci
                            ,pr_cdbccxlt => rw_craplot.cdbccxlt
                            ,pr_nrdolote => rw_craplot.nrdolote
                            ,pr_nrdctabb => rw_portab.nrdconta
                            ,pr_nrdocmto => vr_aux_nrctremp);
        FETCH cr_craplcm_exis
         INTO vr_aux_existlcm,vr_aux_vllanmto;
        CLOSE cr_craplcm_exis;

        -- Se já existia LCS
        IF vr_aux_vllanmto IS NOT NULL THEN
          -- Gerar critica
          vr_dscritic := to_char(rw_crapdat_portab.dtmvtolt,'dd/mm/rrrr hh24:mi:ss')
                      || ' => Liquidacao '
                      || '|' || rw_crapepr.cdagenci
                      || '|' || rw_crapepr.nrdconta
                      || '|' || vr_aux_nrctremp
                      || '|' || vr_aux_NUPortdd
                      || '|' ||'Lancamento ja existe!';
          -- Escrever em LOG e finalizar o processo
          btch0001.pc_gera_log_batch(pr_cdcooper     => rw_crapcop_portab.cdcooper
                                    ,pr_ind_tipo_log => 1
                                    ,pr_des_log      => vr_dscritic
                                    ,pr_nmarqlog     => 'logprt');
          RETURN;
        ELSE
          -- Conforme o tipo do Empréstimo
          IF vr_aux_tpemprst = 1 THEN -- PP
            -- Chamar liquidação Empréstimo Novo
            pc_liq_contrato_emprest_nov(pr_cdcooper => rw_crapcop_portab.cdcooper
                                       ,pr_nrdconta => rw_portab.nrdconta
                                       ,pr_nrctremp => vr_aux_nrctremp
                                       ,pr_dtmvtolt => rw_crapdat_portab.dtmvtolt
                                       ,pr_dtmvtoan => rw_crapdat_portab.dtmvtoan
                                       ,pr_cdagenci => rw_crapepr.cdagenci
                                       ,pr_cdagelot => rw_craplot.cdagenci
                                       ,pr_dscritic => vr_dscritic);
          ELSIF vr_aux_tpemprst = 0 THEN -- TR
            -- Chamar Liquidação Empréstimo Antigo
            pc_liq_contrato_emprest_ant(pr_cdcooper   => rw_crapcop_portab.cdcooper
                                       ,pr_nrdconta   => rw_portab.nrdconta
                                       ,pr_nrctremp   => vr_aux_nrctremp
                                       ,pr_rw_crapdat => rw_crapdat_portab
                                       ,pr_dtmvtolt   => rw_crapdat_portab.dtmvtolt
                                       ,pr_dscritic   => vr_dscritic);
          END IF;

          -- Se retornou erro na Liquidação
          IF vr_dscritic IS NOT NULL THEN
            -- Retornar a execução
            RETURN;
          END IF;

          BEGIN
            -- Criar LCM
            INSERT INTO craplcm
               (cdcooper
               ,dtmvtolt
               ,cdagenci
               ,cdbccxlt
               ,nrdolote
               ,nrdconta
               ,nrdctabb
               ,nrdocmto
               ,cdhistor
               ,vllanmto
               ,nrseqdig
               ,cdpesqbb
               ,cdoperad
               ,hrtransa)
            VALUES
               (rw_crapcop_portab.cdcooper
               ,rw_craplot.dtmvtolt
               ,rw_craplot.cdagenci
               ,rw_craplot.cdbccxlt
               ,rw_craplot.nrdolote
               ,rw_portab.nrdconta
               ,rw_portab.nrdconta
               ,vr_aux_nrctremp
               ,1918
               ,vr_aux_VlrLanc
               ,rw_craplot.nrseqdig + 1
               ,'CRED TED PORT'
               ,'1'
               ,to_char(sysdate,'sssss'));
            -- Atualizar capa do Lote
            UPDATE craplot SET craplot.vlinfocr = nvl(craplot.vlinfocr,0) + vr_aux_VlrLanc
                              ,craplot.vlcompcr = nvl(craplot.vlcompcr,0) + vr_aux_VlrLanc
                              ,craplot.qtinfoln = nvl(craplot.qtinfoln,0) + 1
                              ,craplot.qtcompln = nvl(craplot.qtcompln,0) + 1
                              ,craplot.nrseqdig = nvl(craplot.nrseqdig,0) + 1
            WHERE craplot.ROWID = rw_craplot.ROWID;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao criar lancamento de TED ou na atualizacao do Lote: '||sqlerrm;
          END;

          -- Se não houve erro até então
          IF vr_dscritic IS NULL THEN

            -- Atualiza situacao da portabilidade para Concluida no JDCTC
            BEGIN
              UPDATE tbepr_portabilidade
                 SET dtliquidacao = rw_crapdat_portab.dtmvtolt
               WHERE cdcooper = rw_crapcop_portab.cdcooper
                 AND nrunico_portabilidade = vr_aux_NUPortdd;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar Portabilidade --> '||sqlerrm;
                RAISE vr_exc_saida;
            END;

            -- Achar numero Banco Central
            OPEN cr_crapban(pr_cdbccxlt => 85);
            FETCH cr_crapban
             INTO rw_crapban;
            CLOSE cr_crapban;

            -- Atualiza situacao da portabilidade para Concluida no JDCTC
            empr0006.pc_atualizar_situacao(pr_cdcooper => rw_crapcop_mensag.cdcooper           /* Cód. Cooperativa */
                                          ,pr_idservic => 2                             /* Tipo de servico(1-Proponente/2-Credora) */
                                          ,pr_cdlegado => 'LEG'                         /* Codigo Legado */
                                          ,pr_nrispbif => rw_crapban.nrispbif           /* Numero ISPB IF */
                                          ,pr_nrcontrl => '1'                           /* Nr. controle (verificar) */
                                          ,pr_nuportld => vr_aux_NUPortdd               /* Numero Portabilidade CTC */
                                          ,pr_cdsittit => 'PL5'                         /* Codigo Situacao Titulo */
                                          ,pr_flgrespo => vr_aux_flgrespo               /* 1 - Se o registro na JDCTC for atualizado com sucesso */
                                          ,pr_des_erro => vr_des_reto                   /* Indicador erro OK/NOK */
                                          ,pr_dscritic => vr_dscritic);                 /* Descricao do erro */

            -- Se houve erro
            IF vr_des_reto <> 'OK' OR vr_aux_flgrespo <> 1 THEN
              -- Gerar log
              vr_dscritic := to_char(rw_crapdat_portab.dtmvtolt,'dd/mm/rrrr hh24:mi:ss')
                          || ' => Liquidacao '
                          || '|' || rw_crapepr.cdagenci
                          || '|' || rw_crapepr.nrdconta
                          || '|' || vr_aux_nrctremp
                          || '|' || vr_aux_NUPortdd
                          || '|' ||'Erro ao atualizar situacao da portabilidade no JDCTC.!';
              -- Escrever em LOG e continuar
              btch0001.pc_gera_log_batch(pr_cdcooper     => rw_crapcop_portab.cdcooper
                                        ,pr_ind_tipo_log => 1
                                        ,pr_des_log      => vr_dscritic
                                        ,pr_nmarqlog     => 'logprt');
              -- Limpar critica
              vr_dscritic := null;
            END IF;

            -- Chegou ao fim sem erro, gera log
            pc_gera_log_SPB(pr_tipodlog  => 'RECEBIDA'
                           ,pr_msgderro  => NULL);
          ELSE
            RAISE vr_exc_saida;
          END IF;
        END IF;
      ELSE
        -- Apenas gerar LOG
        pc_gera_log_SPB(pr_tipodlog  => 'RECEBIDA'
                       ,pr_msgderro  => NULL);
      END IF;

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := 'Erro tratado em pc_trata_lancamentos --> '||vr_dscritic;
      WHEN OTHERS THEN
        pr_dscritic := 'Erro nao tratado em pc_trata_lancamentos --> '||sqlerrm;
    END;


  BEGIN

    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_glb_cdprogra
                              ,pr_action => 'PC_'||vr_glb_cdprogra||'_1');

    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop
     INTO rw_crapcop_central;
    -- Se não encontrar
    IF cr_crapcop%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE cr_crapcop;
      -- Montar mensagem de critica
      pr_cdcritic := 651;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 651);
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crapcop;
    END IF;

    -- Leitura do calendário da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat
     INTO rw_crapdat_central;
    -- Se não encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois efetuaremos raise
      CLOSE btch0001.cr_crapdat;
      -- Montar mensagem de critica
      pr_cdcritic := 1;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;

    -- Definir nome do arquivo de log
    vr_logprogr :=  vr_glb_cdprogra||'_'||to_char(rw_crapdat_central.dtmvtolt,'DDMMRRRR');

    -- Buscar Estado de Crise
    SSPB0001.pc_estado_crise_tb(pr_flproces => 'S'                  -- Indica para verificar o processo
                               ,pr_inestcri => vr_aux_flestcri          -- 0-Sem crise / 1-Com Crise
                               ,pr_tbestcri => vr_tab_estad_crise); -- Tabela com informações

    -- Resetar variaveis
    vr_aux_dtintegr      := rw_crapdat_central.dtmvtolt;
    vr_aux_manter_fisico := TRUE;

    -- Carregar o parametro que identifica se a mensagem sera movida
    vr_msgspb_mover := gene0001.fn_param_sistema('CRED',0,'MSGSPB_MOVER');

    -- Carregar o parametro que identifica as mensagem que nao serao gravadas na nova estrutura
    vr_msgspb_nao_copiar := gene0001.fn_param_sistema('CRED',0,'MSGSPB_NAO_COPIAR');

    -- Separar Path do nome do arquivo
    gene0001.pc_separa_arquivo_path(pr_caminho => pr_nmarquiv
                                   ,pr_direto  => vr_aux_nmdirxml
                                   ,pr_arquivo => vr_aux_nmarqxml);
    vr_tab_situacao_if.delete();

    -- Chamar rotina para processamento do XML
    pc_importa_xml(vr_dscritic);
    -- Se retornou erro
    IF vr_dscritic IS NOT NULL THEN
      -- Incrementar o LOG
      vr_dscritic := 'Erro ao descriptografar e ler o arquivo : ' || vr_aux_nmdirxml||'/'||vr_aux_nmarqxml;
      RAISE vr_exc_saida;
    ELSE
      -- Criar bloco para facilitar o desvio de fluxo ao final
      BEGIN

        -- Se o xml conter a TAG <CABInfSituacao>, pode ser mensagem com erro de
        -- inconsistencia de dados (STR0005E,STR0008E,STR0037E,PAG0107E,PAG0108E,
        -- PAG0137E) ou mensagen de controle da JD.
        -- No caso da TAG <CABInfCancelamento, a mensagem refere-se a uma rejeicao
        -- gerada pela Cabine. Todas sao mensagens de retorno ref. alguma mensagem
        -- enviada pela cooperativa
        IF vr_aux_tagCABInf THEN
          -- Busca cooperativa da destino
          OPEN cr_crapcop(pr_cdagectl => SUBSTR(vr_aux_NumCtrlIF,8,4));
          FETCH cr_crapcop
           INTO rw_crapcop_mensag;
          -- Se encontrar
          IF cr_crapcop%FOUND THEN
            CLOSE cr_crapcop;
            -- Se estamos em estado de crise
            IF vr_aux_flestcri > 0 THEN
              -- Buscar informações da Coop
              IF vr_tab_estad_crise.exists(rw_crapcop_mensag.cdcooper) THEN
                vr_aux_dtintegr := vr_tab_estad_crise(rw_crapcop_mensag.cdcooper).dtintegr;
                vr_aux_inestcri := vr_tab_estad_crise(rw_crapcop_mensag.cdcooper).inestcri;
              END IF;
            END IF;
            -- Se nao estiver em estado de crise verifica processo
            IF NOT fn_verifica_processo_crise THEN
              -- Arquivo será ignorado
              RAISE vr_exc_next;
            END IF;
            -- Se encontramos mensagem
            IF trim(vr_aux_CodMsg) IS NOT NULL THEN
              -- Tratar inconsistência de Dados
              IF vr_aux_CodMsg LIKE '%E' THEN
                -- Gera LOG SPB
                pc_gera_log_SPB(pr_tipodlog  => 'REJEITADA OK'
                               ,pr_msgderro  => 'Inconsistencia dados: '|| vr_aux_msgderro ||'.');
              ELSE
                -- Rejeitada pela Cabine Vem com mesmo CodMsg da mensagem gerada pela cooperativa
                pc_trata_lancamentos(pr_dscritic  => vr_dscritic);
                -- Tratar erro na chamada da gera log SPB
                IF vr_dscritic IS NOT NULL THEN
                  RAISE vr_exc_saida;
                END IF;
              END IF;
            ELSE
              -- Gera LOG SPB
              pc_gera_log_SPB(pr_tipodlog  => 'RETORNO JD OK'
                             ,pr_msgderro  => NULL);
            END IF;
            -- Tratar erro na chamada da gera log SPB
            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;
          ELSE -- Se não encontrou
            CLOSE cr_crapcop;
            -- Verificar processo
            IF NOT fn_verifica_processo THEN
              -- Arquivo será ignorado
              RAISE vr_exc_next;
            END IF;
            -- CECRED
            pc_trata_cecred (pr_cdagectl => SUBSTR(vr_aux_NumCtrlIF,8,4)
                            ,pr_dscritic => vr_dscritic);
            -- Se retornou erro
            IF vr_dscritic IS NOT NULL THEN
              -- Incrementar o LOG
              vr_dscritic := 'Erro ao processar mensagem --> ' || vr_dscritic;
              RAISE vr_exc_saida;
            END IF;
          END IF;
          -- Salvar o arquivo
          pc_salva_arquivo;
          -- Processo finalizado
          RAISE vr_exc_next;
        END IF;

        -- Verifica as Mensagens de Recebimento
        IF vr_aux_CodMsg NOT IN('PAG0101'                                       -- Situacao IF
                               ,'STR0018','STR0019'                             -- Exclusao/Inclusao IF
                               ,'STR0005R2','STR0007R2','STR0008R2','PAG0107R2'
                               ,'STR0025R2','PAG0121R2'                         -- Transferencia Judicial - Andrino
                               ,'LTR0005R2'                                     -- Antecipaçao de Recebíveis - LTR - Mauricio
		                           ,'LDL0020R2','LDL0022','LTR0004'                 -- Alexandre - Mouts 
                               ,'SLC0001'                                       -- Requisição de Transferência de cliente para IF - Mauricio 
		                           ,'LDL0024'                                       -- Aviso Alteração Horários Câmara LDL - Alexandre Borgmann - Mouts 
		                           ,'STR0006R2'                                     -- Cielo finalidade 15 gravar e não gerar STR0010 - Alexandre Borgmann - Mouts 
                               ,'PAG0108R2','PAG0143R2'                         -- TED
                               ,'STR0037R2','PAG0137R2'                         -- TEC
                               ,'STR0010R2','PAG0111R2'                         -- Devolucao TED/TEC enviado com erro
                               ,'STR0003R2'                                     -- Liquidacao de transferencia de numerarios
                               ,'STR0004R1','STR0005R1','STR0008R1','STR0037R1'
                               ,'PAG0107R1','PAG0108R1','PAG0137R1'             -- Confirma envio
                               ,'STR0010R1','PAG0111R1'                         -- Confirma devolucao enviada
                               ,'STR0026R2'                                     -- Recebimento VR Boleto
                               ,'STR0047R1','STR0048R1','STR0047R2') THEN       -- Portabilidade de Credito
          -- Se o processo estiver rodando
          IF NOT fn_verifica_processo THEN
            -- Arquivo será ignorado
            RAISE vr_exc_next;
          END IF;

          -- Mensagem nao tratada pelo sistema CECRED e devemos enviar uma mensagem STR0010 como resposta. SD 553778
          IF vr_aux_CodMsg IN('STR0006R2','PAG0142R2','STR0034R2','PAG0134R2') THEN
            -- Buscar Coop destino
            rw_crapcop_mensag := NULL;
            OPEN cr_crapcop(pr_cdagectl => vr_aux_AgCredtd);
            FETCH cr_crapcop
             INTO rw_crapcop_mensag;
            CLOSE cr_crapcop;
            -- Mensagem Invalida para o Tipo de Transacao ou Finalidade
            vr_log_msgderro := 'Mensagem Invalida para o Tipo de Transacao ou Finalidade.';
            -- Gerar XML de erro
            pc_gera_erro_xml(pr_dsdehist => 'Mensagem Invalida para o Tipo de Transacao ou Finalidade.'
                            ,pr_codierro => 4
                            ,pr_dscritic => vr_dscritic);
          ELSE
            -- Tratamento Cecred
            pc_trata_cecred (pr_cdagectl => NULL
                            ,pr_dscritic => vr_dscritic);
          END IF;
          -- Se retornou erro
          IF vr_dscritic IS NOT NULL THEN
            -- Incrementar o LOG
            vr_dscritic := 'Erro ao processar mensagem --> ' || vr_dscritic;
            RAISE vr_exc_saida;
          END IF;
          -- Salvar o arquivo
          pc_salva_arquivo;
          -- Processo finalizado
          RAISE vr_exc_next;
        END IF;

        -- Transferencia Judicial - Andrino
        IF vr_aux_CodMsg IN('STR0025R2','PAG0121R2') THEN
          -- Enviar mensagem STR0010 e PAG0111
          pc_gera_erro_xml(pr_dsdehist => 'IF nao autorizada a receber esse tipo de operacao.'
                          ,pr_codierro => 4
                          ,pr_dscritic => vr_dscritic);
          -- Se retornou erro
          IF vr_dscritic IS NOT NULL THEN
            -- Incrementar o LOG
            vr_dscritic := 'Erro ao processar mensagem --> ' || vr_dscritic;
            RAISE vr_exc_saida;
          END IF;
          -- Salvar o arquivo
          pc_salva_arquivo;
          -- Processo finalizado
          RAISE vr_exc_next;
        END IF;
			
    -- Antecipaçao de Recebíveis - LTR - Mauricio
    IF vr_aux_CodMsg in ('LTR0005R2','STR0006R2','LTR0005R2',
                         'LDL0020R2','LDL0022','LTR0004') THEN

          -- Acionar log
          BTCH0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                    ,pr_ind_tipo_log  => 2 -- Erro não tratado
                                    ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - '
                                                      || to_char(sysdate,'hh24:mi:ss')||' - '
                                                      || vr_glb_cdprogra ||' - '
                                                      || vr_dscritic
                                    ,pr_nmarqlog      => vr_nmarqlog);

			  IF vr_aux_CodMsg = 'STR0006R2' and vr_aux_FinlddCli <> '15' and vr_aux_CNPJ_CPFDeb<>'01027058000191' THEN
				
					/* Mensagem Invalida para o Tipo de Transacao ou Finalidade*/  
            vr_aux_codierro := 4;
            vr_aux_dsdehist := 'Mensagem Invalida para o Tipo de Transacao ou Finalidade.';
            vr_log_msgderro := vr_aux_dsdehist;
            
            pc_gera_erro_xml(vr_aux_dsdehist
                            ,vr_aux_codierro
                            ,vr_dscritic);

            pc_salva_arquivo;
            RAISE vr_exc_next;
			  ELSE
					ccrd0006.pc_insere_msg_ltr_str(vr_aux_VlrLanc	       			
															  ,vr_aux_CodMsg					
															  ,vr_aux_NumCtrlLTR				 	
															  ,vr_aux_NumCtrlSTR				
															  ,vr_aux_ISPBLTR				
															  ,vr_aux_ISPBIFDebtd			
															  ,vr_aux_ISPBIFCredtd																		  
															  ,vr_aux_CNPJNLiqdant			
															  ,vr_aux_IdentdPartCamr			
															  ,vr_aux_AgCredtd				
															  ,vr_aux_CtCredtd				
															  ,vr_aux_AgDebtd				 
															  ,vr_aux_Hist					
															  ,vr_aux_FinlddIF				
															  ,vr_aux_TpPessoaDebtd_Remet   	
															  ,vr_aux_CNPJ_CPFDeb			
															  ,vr_aux_NomCliDebtd			 
															  ,vr_aux_FinlddCli				
															  ,vr_aux_DtHrBC					
															  ,vr_aux_DtMovto				
															  ,vr_dscritic);             			
          -- Se retornou erro
          IF vr_dscritic IS NOT NULL THEN
             -- Incrementar o LOG
             vr_dscritic := 'Erro ao processar mensagem --> ' || vr_dscritic;
             RAISE vr_exc_saida;
          END IF;
          -- Salvar o arquivo
          pc_salva_arquivo;
          -- Processo finalizado
          RAISE vr_exc_next;
		   END IF;
   END IF;
        -- VR Boleto
        IF vr_aux_CodMsg = 'STR0026R2' THEN
          -- Trazer arquivo de log do mqcecred_processa
          vr_nmarqlog := fn_log_mqcecred;
          -- Se nao estiver em estado de crise verifica processo
          IF NOT fn_verifica_processo_crise THEN
            -- Arquivo será ignorado
            RAISE vr_exc_next;
          END IF;

          -- Buscar informações do convênio conforme código de barras
          vr_aux_nrconven := SUBSTR(vr_aux_NumCodBarras, 20, 6);
          vr_aux_nrdconta := SUBSTR(vr_aux_NumCodBarras, 26, 8);
          vr_aux_nrdocmto := SUBSTR(vr_aux_NumCodBarras, 34, 9);

          -- Procurar o convênio relacionado
          OPEN cr_crapcco(pr_nrconven => vr_aux_nrconven);
          FETCH cr_crapcco
           INTO rw_crapcco;
          -- Se não encontrar
          IF cr_crapcco%NOTFOUND THEN
            CLOSE cr_crapcco;
            -- Enviar mensagem STR0010
            pc_gera_erro_xml(pr_dsdehist => 'Convenio do VR Boleto nao encontrado.'
                            ,pr_codierro => 2
                            ,pr_dscritic => vr_dscritic);
            -- Se retornou erro
            IF vr_dscritic IS NOT NULL THEN
              -- Incrementar o LOG
              vr_dscritic := 'Erro ao processar mensagem --> ' || vr_dscritic;
              RAISE vr_exc_saida;
            END IF;
            -- Salvar o arquivo
            pc_salva_arquivo;
            -- Processo finalizado
            RAISE vr_exc_next;
          ELSE
            CLOSE cr_crapcco;
            -- Posicionar a cooperativa da mensagem (Buffer) igual a Cooperativa encontrada na CCO
            OPEN cr_crapcop(pr_cdcooper => rw_crapcco.cdcooper);
            FETCH cr_crapcop
             INTO rw_crapcop_mensag;
            CLOSE cr_crapcop;
          END IF;
          -- Procurar Boleto
          OPEN cr_crapcob(pr_cdcooper => rw_crapcco.cdcooper
                         ,pr_cdbandoc => rw_crapcco.cddbanco
                         ,pr_nrdctabb => rw_crapcco.nrdctabb
                         ,pr_nrcnvcob => rw_crapcco.nrconven
                         ,pr_nrdconta => vr_aux_nrdconta
                         ,pr_nrdocmto => vr_aux_nrdocmto);
          FETCH cr_crapcob
           INTO rw_crapcob;
          -- Se não encontrar
          IF cr_crapcob%NOTFOUND THEN
            CLOSE cr_crapcob;
            -- Enviar mensagem STR0010
            pc_gera_erro_xml(pr_dsdehist => 'VR Boleto nao encontrado.'
                            ,pr_codierro => 2
                            ,pr_dscritic => vr_dscritic);
            -- Se retornou erro
            IF vr_dscritic IS NOT NULL THEN
              -- Incrementar o LOG
              vr_dscritic := 'Erro ao processar mensagem --> ' || vr_dscritic;
              RAISE vr_exc_saida;
            END IF;
            -- Salvar o arquivo
            pc_salva_arquivo;
            -- Processo finalizado
            RAISE vr_exc_next;
          ELSE
            CLOSE cr_crapcob;
          END IF;

          -- Em estado de critica
          IF vr_aux_flestcri > 0 THEN
            -- Buscar informações do estado de crise
            IF vr_tab_estad_crise.exists(rw_crapcob.cdcooper) THEN
              vr_aux_dtintegr := vr_tab_estad_crise(rw_crapcob.cdcooper).dtintegr;
              vr_aux_inestcri := vr_tab_estad_crise(rw_crapcob.cdcooper).inestcri;
            END IF;
          END IF;

          -- Se Boleto já foi pago
          IF rw_crapcob.incobran = 5 THEN
            -- Enviar mensagem STR0010
            pc_gera_erro_xml(pr_dsdehist => 'VR Boleto ja foi pago.'
                            ,pr_codierro => 2
                            ,pr_dscritic => vr_dscritic);
            -- Se retornou erro
            IF vr_dscritic IS NOT NULL THEN
              -- Incrementar o LOG
              vr_dscritic := 'Erro ao processar mensagem --> ' || vr_dscritic;
              RAISE vr_exc_saida;
            END IF;
            -- Salvar o arquivo
            pc_salva_arquivo;
            -- Processo finalizado
            RAISE vr_exc_next;
          END IF;

          -- variaveis de calculo para juros/multa
          vr_aux_vlrjuros := 0;
          vr_aux_vlrmulta := 0;
          vr_aux_vldescto := 0;
          vr_aux_vlabatim := rw_crapcob.vlabatim;
          vr_aux_vlfatura := rw_crapcob.vltitulo;

          -- Verifica necessidade de calculo juros caso o titulo esteja vencido
          vr_aux_flgvenci := fn_verifica_vencto_titulo(rw_crapcob.cdcooper,rw_crapcob.dtvencto);

          -- calculo de abatimento deve ser antes da aplicacao de juros e multa
          IF vr_aux_vlabatim > 0 THEN
            vr_aux_vlfatura := vr_aux_vlfatura - vr_aux_vlabatim;
          END IF;

          -- Trata o desconto se concede apos o vencimento
          IF rw_crapcob.cdmensag = 2 THEN
            vr_aux_vldescto := rw_crapcob.vldescto;
            vr_aux_vlfatura := vr_aux_vlfatura - vr_aux_vldescto;
          END IF;

          -- Verifica se o titulo esta vencido
          IF vr_aux_flgvenci  THEN
            -- MULTA PARA ATRASO
            IF rw_crapcob.tpdmulta = 1 THEN /* Valor */
              vr_aux_vlrmulta := rw_crapcob.vlrmulta;
            /* % de multa do valor  do boleto */
            ELSIF rw_crapcob.tpdmulta = 2  THEN
              vr_aux_vlrmulta := (rw_crapcob.vlrmulta * vr_aux_vlfatura) / 100;
            END IF;
            /* MORA PARA ATRASO */
            IF rw_crapcob.tpjurmor = 1  THEN /* dias */
              vr_aux_vlrjuros := rw_crapcob.vljurdia * (vr_aux_dtintegr - rw_crapcob.dtvencto);
            ELSIF rw_crapcob.tpjurmor = 2  THEN /* mes */
              vr_aux_vlrjuros := (rw_crapcob.vltitulo * ((rw_crapcob.vljurdia / 100) / 30) * (vr_aux_dtintegr - rw_crapcob.dtvencto));
            END IF;
          ELSE
            -- se concede apos vencto, ja calculou
            IF rw_crapcob.cdmensag <> 2  THEN
              vr_aux_vldescto := rw_crapcob.vldescto;
            END IF;
          END IF;

          IF (rw_crapcob.incobran = 3 AND (rw_crapcob.insitcrt = 0 OR rw_crapcob.insitcrt = 1)) THEN
            vr_aux_liqaposb := TRUE;
          ELSE
            vr_aux_liqaposb := FALSE;
          END IF;

          /* Buscar dados do banco */
          OPEN cr_crapban(pr_cdbccxlt => null
                         ,pr_nrispbif => vr_aux_ISPBIFDebtd);
          FETCH cr_crapban
           INTO rw_crapban;
          -- Se não encontrou
          IF cr_crapban%NOTFOUND THEN
            CLOSE cr_crapban;
            -- enviar mensagem STR0010
            pc_gera_erro_xml(pr_dsdehist => 'Agencia nao encontrada.'
                            ,pr_codierro => 2
                            ,pr_dscritic => vr_dscritic);
            -- Se retornou erro
            IF vr_dscritic IS NOT NULL THEN
              -- Incrementar o LOG
              vr_dscritic := 'Erro ao processar mensagem --> ' || vr_dscritic;
              RAISE vr_exc_saida;
            END IF;
            -- Salvar o arquivo
            pc_salva_arquivo;
            -- Processo finalizado
            RAISE vr_exc_next;
          ELSE
            CLOSE cr_crapban;
          END IF;

          vr_aux_cdbanpag := rw_crapban.cdbccxlt;
          vr_aux_dsmotivo := '04'; /* compensacao eletronica */

          -- Liquidação tratar em Bloco para pegar erros de CAST
          BEGIN
            -- Se não for liquidacao de titulo já pago, então liq normal
            IF NOT vr_aux_liqaposb THEN
              paga0001.pc_processa_liquidacao(pr_idtabcob => rw_crapcob.rowid
                                             ,pr_nrnosnum => 0
                                             ,pr_cdbanpag => vr_aux_cdbanpag
                                             ,pr_cdagepag => vr_aux_AgDebtd
                                             ,pr_vltitulo => rw_crapcob.vltitulo
                                             ,pr_vlliquid => 0
                                             ,pr_vlrpagto => vr_aux_VlrLanc
                                             ,pr_vlabatim => 0
                                             ,pr_vldescto => vr_aux_vldescto + vr_aux_vlabatim
                                             ,pr_vlrjuros => vr_aux_vlrjuros + vr_aux_vlrmulta
                                             ,pr_vloutdeb => 0
                                             ,pr_vloutcre => 0
                                             ,pr_dtocorre => vr_aux_dtintegr
                                             ,pr_dtcredit => vr_aux_dtintegr
                                             ,pr_cdocorre => 6
                                             ,pr_dsmotivo => vr_aux_dsmotivo
                                             ,pr_dtmvtolt => vr_aux_dtintegr
                                             ,pr_cdoperad => '1'
                                             ,pr_indpagto => 0 -- Compe
                                             ,pr_inestcri => vr_aux_inestcri
                                             ,pr_ret_nrremret => vr_ret_nrremret
                                             ,pr_nmtelant => NULL
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic
                                             ,pr_tab_lcm_consolidada => vr_tab_lcm_consolidada
                                             ,pr_tab_descontar => vr_tab_descontar);
            ELSE
              paga0001.pc_proc_liquid_apos_baixa(pr_idtabcob => rw_crapcob.rowid
                                                ,pr_nrnosnum => 0
                                                ,pr_cdbanpag => vr_aux_cdbanpag
                                                ,pr_cdagepag => vr_aux_AgDebtd
                                                ,pr_vltitulo => rw_crapcob.vltitulo
                                                ,pr_vlliquid => 0
                                                ,pr_vlrpagto => vr_aux_VlrLanc
                                                ,pr_vlabatim => 0
                                                ,pr_vldescto => vr_aux_vldescto + vr_aux_vlabatim
                                                ,pr_vlrjuros => 0
                                                ,pr_vloutdeb => 0
                                                ,pr_vloutcre => 0
                                                ,pr_dtocorre => vr_aux_dtintegr
                                                ,pr_dtcredit => vr_aux_dtintegr
                                                ,pr_cdocorre => 17
                                                ,pr_dsmotivo => vr_aux_dsmotivo
                                                ,pr_dtmvtolt => vr_aux_dtintegr
                                                ,pr_cdoperad => '1'
                                                ,pr_indpagto => 0 -- Compe
                                                ,pr_inestcri => vr_aux_inestcri
                                                ,pr_ret_nrremret => vr_ret_nrremret
                                                ,pr_cdcritic => vr_cdcritic
                                                ,pr_dscritic => vr_dscritic
                                                ,pr_tab_lcm_consolidada => vr_tab_lcm_consolidada);
            END IF;
            -- Se voltou erro nas criticas
            IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
              -- Se ha critica sem descricao
              IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
                vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
              END IF;
              -- Gerar a critica em LOG
              BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                        ,pr_ind_tipo_log => 1 -- Processo normal
                                        ,pr_des_log      => to_char(sysdate,'dd/mm/rrrr') || ' - '
                                                         || to_char(sysdate,'hh24:mi:ss')||' - '|| vr_glb_cdprogra || ' --> '
                                                         || ' Erro ao liquidar fatura '
                                                         || ' , Execução paralela - PID: '
                                                         || ' - ' || pr_idparale|| ' Seq.: ' || to_char(pr_idprogra,'fm99990')
                                                         || ' Mensagem: ' || vr_aux_nmdirxml||'/'||vr_aux_nmarqxml
                                                         || ' , Erro: '||vr_dscritic
                                        ,pr_nmarqlog     => vr_nmarqlog); --> Log específico do SPB
              -- Salvar o arquivo
              pc_salva_arquivo;
              -- Processo finalizado
              RAISE vr_exc_next;
            END IF;
          EXCEPTION
            WHEN vr_exc_next THEN
              -- Apenas propagar
              RAISE vr_exc_next;
            WHEN OTHERS THEN
              -- Gerar a critica em LOG
              BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                        ,pr_ind_tipo_log => 1 -- Processo normal
                                        ,pr_des_log      => to_char(sysdate,'dd/mm/rrrr') || ' - '
                                                         || to_char(sysdate,'hh24:mi:ss')||' - '|| vr_glb_cdprogra || ' --> '
                                                         || ' Erro na execução paralela - PID: '
                                                         || ' - ' || pr_idparale|| ' Seq.: ' || to_char(pr_idprogra,'fm99990')
                                                         || ' Mensagem: ' || vr_aux_nmdirxml||'/'||vr_aux_nmarqxml
                                                         || ' , Erro: '||sqlerrm
                                        ,pr_nmarqlog     => vr_nmarqlog); --> Log específico do SPB
              -- Salvar o arquivo
              pc_salva_arquivo;
              -- Processo finalizado
              RAISE vr_exc_next;
          END;
          -- Controle para lancamento consolidado na conta corrente
          paga0001.pc_realiza_lancto_cooperado(pr_cdcooper => rw_crapcco.cdcooper
                                              ,pr_dtmvtolt => vr_aux_dtintegr
                                              ,pr_cdagenci => rw_crapcco.cdagenci
                                              ,pr_cdbccxlt => rw_crapcco.cdbccxlt
                                              ,pr_nrdolote => rw_crapcco.nrdolote
                                              ,pr_cdpesqbb => rw_crapcco.nrconven
                                              ,pr_tab_lcm_consolidada => vr_tab_lcm_consolidada
                                              ,pr_cdcritic => vr_cdcritic
                                              ,pr_dscritic => vr_dscritic);
          -- Se voltou erro nas criticas
          IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
            -- Se ha critica sem descricao
            IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
              vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
            END IF;
            -- Gerar a critica em LOG
            BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 1 -- Processo normal
                                      ,pr_des_log      => to_char(sysdate,'dd/mm/rrrr') || ' - '
                                                       || to_char(sysdate,'hh24:mi:ss')||' - '|| vr_glb_cdprogra || ' --> '
                                                       || ' Erro ao creditar Cooperado '
                                                       || ' , Execução paralela - PID: '
                                                       || ' - ' || pr_idparale|| ' Seq.: ' || to_char(pr_idprogra,'fm99990')
                                                       || ' Mensagem: ' || vr_aux_nmdirxml||'/'||vr_aux_nmarqxml
                                                       || ' , Erro: '||vr_dscritic
                                      ,pr_nmarqlog     => vr_nmarqlog); --> Log específico do SPB
            -- Salvar o arquivo
            pc_salva_arquivo;
            -- Processo finalizado
            RAISE vr_exc_next;
          END IF;

          -- Realiza liquidacao dos titulos descontados (se houver)
          vr_idx_descontar := vr_tab_descontar.first;
          LOOP
            EXIT WHEN vr_idx_descontar IS NULL;
            -- Devemos criar um novo pltable por conta
            vr_tab_titulosdt(vr_idx_descontar) := vr_tab_descontar(vr_idx_descontar);
            -- Se for o ultimo registro da conta ou da pltable
            IF vr_tab_descontar.next(vr_idx_descontar) IS NULL
            OR vr_tab_descontar(vr_idx_descontar).nrdconta <> vr_tab_descontar(vr_tab_descontar.next(vr_idx_descontar)).nrdconta THEN
              -- Efetuar a baixa do titulo
              DSCT0001 .pc_efetua_baixa_titulo (pr_cdcooper    => pr_cdcooper     -- Codigo Cooperativa
                                              ,pr_cdagenci    => 0               -- Codigo Agencia
                                              ,pr_nrdcaixa    => 0               -- Numero Caixa
                                              ,pr_cdoperad    => 0               -- Codigo operador
                                              ,pr_dtmvtolt    => vr_aux_dtintegr     -- Data Movimento
                                              ,pr_idorigem    => 1               -- Identificador Origem pagamento
                                              ,pr_nrdconta    => vr_tab_descontar(vr_idx_descontar).nrdconta -- Numero da conta
                                              ,pr_indbaixa    => 1                   -- Indicador Baixa /* 1-Pagamento 2- Vencimento */
                                              ,pr_tab_titulos => vr_tab_titulosdt    -- Titulos a serem baixados
                                              ,pr_dtintegr    => vr_aux_dtintegr     -- Data Integração Pagamento
                                              ,pr_cdcritic    => vr_cdcritic         -- Codigo Critica
                                              ,pr_dscritic    => vr_dscritic         -- Descricao Critica
                                              ,pr_tab_erro    => vr_tab_erro);       -- Tabela erros
              -- Se ocorreu erro
              IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL OR vr_tab_erro.COUNT() > 0 THEN
                IF vr_tab_erro.Count > 0 THEN
                  vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
                ELSE
                  -- Se ha critica sem descricao
                  IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
                    vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
                  END IF;
                END IF;
                -- Gerar a critica em LOG
                BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                          ,pr_ind_tipo_log => 1 -- Processo normal
                                          ,pr_des_log      => to_char(sysdate,'dd/mm/rrrr') || ' - '
                                                           || to_char(sysdate,'hh24:mi:ss')||' - '|| vr_glb_cdprogra || ' --> '
                                                           || ' Erro ao baixar titulo Cooperado Conta '||vr_tab_descontar(vr_idx_descontar).nrdconta
                                                           || ' , Execução paralela - PID: '
                                                           || ' - ' || pr_idparale|| ' Seq.: ' || to_char(pr_idprogra,'fm99990')
                                                           || ' Mensagem: ' || vr_aux_nmdirxml||'/'||vr_aux_nmarqxml
                                                           || ' , Erro: '||vr_dscritic
                                          ,pr_nmarqlog     => vr_nmarqlog); --> Log específico do SPB
                -- Salvar o arquivo
                pc_salva_arquivo;
                -- Processo finalizado
                RAISE vr_exc_next;
              END IF;

              -- Limpar tabela temporaria conta
              vr_tab_titulosdt.delete();
            END IF;
            -- Buscar o próximo
            vr_idx_descontar := vr_tab_descontar.next(vr_idx_descontar);
          END LOOP;

          -- Ao final, salvar o arquivo
          pc_salva_arquivo;
          -- Processo finalizado
          RAISE vr_exc_next;
        END IF;

        -- Trata IFs operantes no SPB
        IF vr_aux_CodMsg IN ('PAG0101','STR0018','STR0019') THEN
          -- Trazer arquivo de log do mqcecred_processa
          vr_nmarqlog := fn_log_mqcecred;
          -- Inicializar retorno
          vr_dscritic := 'OK';
          -- Para Pag0101
          IF vr_aux_CodMsg = 'PAG0101' THEN
            -- Somente Para TED
            IF UPPER(vr_aux_CodProdt) = 'TED' THEN
              -- Chamar pc_proc_pag0101
              sspb0001.pc_proc_pag0101_tb(pr_cdprogra => vr_glb_cdprogra
                                         ,pr_nmarqxml => vr_aux_nmarqxml
                                         ,pr_nmarqlog => vr_nmarqlog
                                         ,pr_tab_situa_if => vr_tab_situacao_if
                                         ,pr_des_erro => vr_dscritic);
              -- Caso Sucesso
              IF vr_dscritic = 'OK' THEN
                -- Gera LOG SPB
                pc_gera_log_SPB(pr_tipodlog  => 'PAG0101'
                               ,pr_msgderro  => NULL);
              END IF;
            END IF;
          ELSE
            -- Formatar a data
            vr_aux_dtinispb := SUBSTR(vr_aux_dtinispb, 9, 2) || '/' || SUBSTR(vr_aux_dtinispb, 6, 2) || '/' || SUBSTR(vr_aux_dtinispb, 1, 4);
            -- Chamar rotina de operação do STR
            sspb0001.pc_proc_opera_str(pr_cdprogra => vr_glb_cdprogra
                                      ,pr_nmarqxml => vr_aux_nmarqxml
                                      ,pr_nmarqlog => vr_nmarqlog
                                      ,pr_cdmensag => vr_aux_CodMsg
                                      ,pr_nrispbif => vr_aux_nrispbif
                                      ,pr_cddbanco => vr_aux_cddbanco
                                      ,pr_nmdbanco => vr_aux_nmdbanco
                                      ,pr_dtinispb => vr_aux_dtinispb
                                      ,pr_des_erro => vr_dscritic);
            -- Caso Sucesso
            IF vr_dscritic = 'OK' THEN
              -- Gerar LOG conforme tipo de mensagem
              IF vr_aux_CodMsg = 'STR0018' THEN
                -- Gera LOG SPB
                pc_gera_log_SPB(pr_tipodlog  => 'SPB-STR-IF'
                               ,pr_msgderro  => 'Exclusao IF STR');
              ELSE
                -- Gera LOG SPB
                pc_gera_log_SPB(pr_tipodlog  => 'SPB-STR-IF'
                               ,pr_msgderro  => 'Inclusao IF STR');
              END IF;
            END IF;
          END IF;

          -- Se houve critica
          IF NVL(TRIM(vr_dscritic),'OK') <> 'OK' THEN
            vr_dscritic := 'Erro ao processar mensagem --> ' || vr_dscritic;
            RAISE vr_exc_saida;
          END IF;

          -- Salvar o arquivo
          pc_salva_arquivo;
          -- Processo finalizado
          RAISE vr_exc_next;
        END IF;

        -- Verifica se cooperativa de destino eh valida
        IF vr_aux_CodMsg like '%R1'  OR  vr_aux_CodMsg in('STR0010R2','PAG0111R2') THEN
          -- Tenta converter agencia para numero
          IF NOT fn_numerico(SUBSTR(vr_aux_NumCtrlIF,8,4)) THEN
            vr_aux_flgderro := TRUE;
          END IF;
          -- Se não deu erro
          IF NOT vr_aux_flgderro THEN
            -- Busca dados da Coope por cdagectl
            OPEN cr_crapcop(pr_cdagectl => SUBSTR(vr_aux_NumCtrlIF,8,4));
            FETCH cr_crapcop
             INTO rw_crapcop_mensag;
            -- Se não encontrou
            IF cr_crapcop%NOTFOUND THEN
              vr_aux_flgderro := TRUE;
            END IF;
            CLOSE cr_crapcop;
          END IF;

          -- Se gerou erro
          IF vr_aux_flgderro THEN
            -- Se não validar processo
            IF NOT fn_verifica_processo THEN
              -- Ir ao próximo registro
              RAISE vr_exc_next;
            END IF;
            -- Rodar trata Cecred
            pc_trata_cecred (pr_cdagectl => SUBSTR(vr_aux_NumCtrlIF,8,4)
                            ,pr_dscritic => vr_dscritic);
            -- Se retornou erro
            IF vr_dscritic IS NOT NULL THEN
              -- Incrementar o LOG
              vr_dscritic := 'Erro ao processar mensagem --> ' || vr_dscritic;
              RAISE vr_exc_saida;
            END IF;
            -- Salvar o arquivo
            pc_salva_arquivo;
            -- Processo finalizado
            RAISE vr_exc_next;
          END IF;
        ELSE
          -- Tenta converter agencia para numero
          IF NOT fn_numerico(vr_aux_AgCredtd) THEN
            vr_aux_flgderro := TRUE;
          END IF;
          -- Se não deu erro
          IF NOT vr_aux_flgderro THEN
            -- Busca dados da Coope por cdagectl
            OPEN cr_crapcop(pr_cdagectl => vr_aux_AgCredtd
                           ,pr_flgativo => 1);
            FETCH cr_crapcop
             INTO rw_crapcop_mensag;
            -- Se não encontrou
            IF cr_crapcop%NOTFOUND THEN
              CLOSE cr_crapcop;
              -- Tratamento incorporacao TRANSULCRED
              IF to_number(vr_aux_AgCredtd) = 116 AND trunc(sysdate) < to_date('21/01/2017','dd/mm/rrrr') THEN
                -- Usar agencia Incorporada
                vr_aux_cdageinc := to_number(vr_aux_AgCredtd);
                vr_aux_AgCredtd := '0108';
                -- Busca cooperativa de destino (nova)
                OPEN cr_crapcop(pr_cdagectl => vr_aux_AgCredtd);
                FETCH cr_crapcop
                 INTO rw_crapcop_mensag;
                CLOSE cr_crapcop;
              ELSE
                vr_aux_flgderro := TRUE;
              END IF;
            END IF;
            CLOSE cr_crapcop;
          END IF;

          -- Se estamos em estado de crise
          IF vr_aux_flestcri > 0 THEN
            -- Buscar informações da Coop
            IF vr_tab_estad_crise.exists(rw_crapcop_mensag.cdcooper) THEN
              vr_aux_dtintegr := vr_tab_estad_crise(rw_crapcop_mensag.cdcooper).dtintegr;
              vr_aux_inestcri := vr_tab_estad_crise(rw_crapcop_mensag.cdcooper).inestcri;
            END IF;
          -- IFs incorporadas foram desativadas(crapcop.flgativo = FALSE)
          ELSE
             -- Tratamento incorporacao CONCREDI e CREDIMILSUL */
             IF to_number(vr_aux_AgCredtd) = 103 THEN
               vr_aux_cdageinc := to_number(vr_aux_AgCredtd);
               vr_aux_AgCredtd := '0101';
             ELSIF to_number(vr_aux_AgCredtd) = 114 THEN
               vr_aux_cdageinc := to_number(vr_aux_AgCredtd);
               vr_aux_AgCredtd := '0112';
             END IF;
             -- Busca cooperativa de destino
             OPEN cr_crapcop(pr_cdagectl => vr_aux_AgCredtd);
             FETCH cr_crapcop
              INTO rw_crapcop_mensag;
             CLOSE cr_crapcop;
          END IF;

          -- Se houve erro
          IF vr_aux_flgderro THEN
            -- Se não validar processo
            IF NOT fn_verifica_processo THEN
              -- Ir ao próximo registro
              RAISE vr_exc_next;
            END IF;
            -- Rodar trata Cecred
            pc_trata_cecred (pr_cdagectl => vr_aux_AgCredtd
                            ,pr_dscritic => vr_dscritic);
            -- Se retornou erro
            IF vr_dscritic IS NOT NULL THEN
              -- Incrementar o LOG
              vr_dscritic := 'Erro ao processar mensagem --> ' || vr_dscritic;
              RAISE vr_exc_saida;
            END IF;
            -- Salvar o arquivo
            pc_salva_arquivo;
            -- Processo finalizado
            RAISE vr_exc_next;
          ELSE
            -- Se não validar processo
            IF NOT fn_verifica_processo THEN
              -- Ir ao próximo registro
              RAISE vr_exc_next;
            END IF;

            vr_aux_dsdehist := NULL;

            -- Verifica se a conta eh valida
            pc_verifica_conta(pr_cdcritic => vr_aux_codierro
                             ,pr_dscritic => vr_aux_dsdehist);
            -- Se não voltou erro
            IF vr_aux_codierro <> 0 THEN
              -- Buscar o calendário
              OPEN btch0001.cr_crapdat(pr_cdcooper => rw_crapcop_mensag.cdcooper);
              FETCH btch0001.cr_crapdat
               INTO rw_crapdat_mensag;
              -- Se não encontrar
              IF btch0001.cr_crapdat%NOTFOUND THEN
                -- Fechar o cursor pois efetuaremos raise
                CLOSE btch0001.cr_crapdat;
                -- Montar mensagem de critica
                vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
                -- Gerar em LOG
                BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                          ,pr_ind_tipo_log => 1 -- Processo normal
                                          ,pr_des_log      => to_char(sysdate,'dd/mm/rrrr') || ' - '
                                                           || to_char(sysdate,'hh24:mi:ss')||' - '|| vr_glb_cdprogra || ' --> '
                                                           || ' Erro na execução paralela - PID: '
                                                           || ' - ' || pr_idparale|| ' Seq.: ' || to_char(pr_idprogra,'fm99990')
                                                           || ' Mensagem: ' || vr_aux_nmdirxml||'/'||vr_aux_nmarqxml
                                                           || ', Erro: '||vr_dscritic
                                          ,pr_nmarqlog     => vr_logprogr); --> Log específico deste programa
                -- Ir ao próximo registro
                RAISE vr_exc_next;
              ELSE
                -- Apenas fechar o cursor
                CLOSE btch0001.cr_crapdat;
              END IF;
              -- Cria registro da mensagem recebida com ERRO
              pc_cria_gnmvcen(pr_cdagenci => rw_crapcop_mensag.cdagectl
                             ,pr_dtmvtolt => rw_crapdat_mensag.dtmvtolt
                             ,pr_dsmensag => vr_aux_codMsg
                             ,pr_dsdebcre => 'C'
                             ,pr_vllanmto => vr_aux_VlrLanc
                             ,pr_dscritic => vr_dscritic);
              IF vr_dscritic IS NOT NULL THEN
                raise vr_exc_saida;
              END IF;
              -- Buscar erro Agencia invalida
              vr_aux_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => 0
                                                           ,pr_nmsistem => 'CRED'
                                                           ,pr_tptabela => 'GENERI'
                                                           ,pr_cdempres => 0
                                                           ,pr_cdacesso => 'CDERROSSPB'
                                                           ,pr_tpregist => vr_aux_codierro);
              -- Se encontrou
              IF vr_aux_dstextab IS NOT NULL THEN
                -- Copiar a var padrão de erro
                vr_log_msgderro := vr_aux_dstextab;
              END IF;
              -- Gerar XML de erro
              pc_gera_erro_xml(pr_dsdehist => vr_aux_dsdehist
                              ,pr_codierro => vr_aux_codierro
                              ,pr_dscritic => vr_dscritic);
              -- Se retornou erro
              IF vr_dscritic IS NOT NULL THEN
                -- Incrementar o LOG
                vr_dscritic := 'Erro ao processar mensagem --> ' || vr_dscritic;
                RAISE vr_exc_saida;
              END IF;
              -- Salvar o arquivo
              pc_salva_arquivo;
              -- Processo finalizado
              RAISE vr_exc_next;
            END IF;
          END IF;
        END IF;

        -- Confirmacao
        IF vr_aux_CodMsg like '%R1' THEN
          -- Busca data do sistema
          OPEN btch0001.cr_crapdat(pr_cdcooper => rw_crapcop_mensag.cdcooper);
          FETCH btch0001.cr_crapdat
           INTO rw_crapdat_mensag;
          -- Se não encontrar
          IF btch0001.cr_crapdat%NOTFOUND THEN
            -- Fechar o cursor pois efetuaremos raise
            CLOSE btch0001.cr_crapdat;
            -- Montar mensagem de critica
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
            -- Gerar em LOG
            BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 1 -- Processo normal
                                      ,pr_des_log      => to_char(sysdate,'dd/mm/rrrr') || ' - '
                                                       || to_char(sysdate,'hh24:mi:ss')||' - '|| vr_glb_cdprogra || ' --> '
                                                       || ' Erro na execução paralela - PID: '
                                                       || ' - ' || pr_idparale|| ' Seq.: ' || to_char(pr_idprogra,'fm99990')
                                                       || ' Mensagem: ' || vr_aux_nmdirxml||'/'||vr_aux_nmarqxml
                                                       || ', Erro: '||vr_dscritic
                                      ,pr_nmarqlog     => vr_logprogr); --> Log específico deste programa
            -- Ir ao próximo registro
            RAISE vr_exc_next;
          ELSE
            -- Apenas fechar o cursor
            CLOSE btch0001.cr_crapdat;
          END IF;
          -- Se não validar processo
          IF NOT fn_verifica_processo THEN
            -- Ir ao próximo registro
            RAISE vr_exc_next;
          END IF;
          -- Cria registro da mensagem recebida com ERRO
          pc_cria_gnmvcen(pr_cdagenci => rw_crapcop_mensag.cdagectl
                         ,pr_dtmvtolt => rw_crapdat_mensag.dtmvtolt
                         ,pr_dsmensag => vr_aux_codMsg
                         ,pr_dsdebcre => ' '
                         ,pr_vllanmto => 0
                         ,pr_dscritic => vr_dscritic);
          IF vr_dscritic IS NOT NULL THEN
            raise vr_exc_saida;
          END IF;

          -- Nao gravamos o Numero de Controle das mensagens de
          -- devolucao(STR0010/PAG0111) geradas pelo Legado,
          -- sendo assim, apenas logamos o recebimento da R1
          IF vr_aux_CodMsg NOT IN ('STR0010R1','PAG0111R1') THEN
            -- TED
            IF SUBSTR(vr_aux_NumCtrlIF,1,1) = '1'  THEN
              -- Se veio mensagem de Cancelado ou Rejeitado
              IF vr_aux_SitLanc IN('5','9','14','15') THEN
                -- Gera LOG SPB
                pc_gera_log_SPB(pr_tipodlog  => 'ENVIADA NAO OK'
                               ,pr_msgderro  => 'Situacao Lancamento: '||vr_aux_SitLanc);
                -- Salvar o arquivo
                pc_salva_arquivo;
                -- Processo finalizado
                RAISE vr_exc_next;
              ELSE
                -- Buscar o registro da TVL a ser atualizado
                OPEN cr_craptvl(rw_crapcop_mensag.cdcooper,vr_aux_NumCtrlIF);
                FETCH cr_craptvl
                 INTO rw_craptvl;
                -- Se não encontrou
                IF cr_craptvl%NOTFOUND THEN
                  CLOSE cr_craptvl;
                  vr_dscritic := 'Numero de Controle invalido';
                ELSE
                  CLOSE cr_craptvl;
                  -- Verificar se tabela esta lockada
                  IF fn_verifica_tab_em_uso(pr_sig_tabela => 'TVL'
                                           ,pr_rowid => rw_craptvl.rowid ) = 1 THEN
                    vr_dscritic := 'Registro de Transferencia DOC/TED '||vr_aux_NumCtrlIF||' em uso. Tente novamente.';
                    -- apensa jogar critica em log
                    RAISE vr_exc_lock;
                  END IF;

                  -- Atualizar flopfin do registro da TED
                  BEGIN
                    UPDATE craptvl
                       SET flgopfin = 1 -- True
                     WHERE ROWID = rw_craptvl.rowid;
                    -- Se nao atualizou nenhum registro
                    IF SQL%ROWCOUNT = 0 THEN
                      -- Gerar critica
                      vr_dscritic := 'Numero de Controle invalido';
                    END IF;
                  EXCEPTION
                    WHEN OTHERS THEN
                      vr_dscritic := 'Erro ao atualizar registro craptvl --> '||sqlerrm;
                  END;
                END IF;
              END IF;
            -- TEC
            ELSIF SUBSTR(vr_aux_NumCtrlIF,1,1) = '2'  THEN
              -- Se veio mensagem de Cancelado ou Rejeitado
              IF vr_aux_SitLanc IN('5','9','14','15') THEN
                -- Gera LOG SPB
                pc_gera_log_SPB(pr_tipodlog  => 'ENVIADA NAO OK'
                               ,pr_msgderro  => 'Situacao Lancamento: '||vr_aux_SitLanc);
                -- Salvar o arquivo
                pc_salva_arquivo;
                -- Processo finalizado
                RAISE vr_exc_next;
              ELSE
                -- Buscar registro transferência
                OPEN cr_craplcs(pr_cdcooper => rw_crapcop_mensag.cdcooper
                               ,pr_idopetrf => vr_aux_NumCtrlIF);
                FETCH cr_craplcs
                 INTO rw_craplcs;
                -- Se encontrar
                IF cr_craplcs%NOTFOUND THEN
                  CLOSE cr_craplcs;
                  -- Gerar critica
                  vr_dscritic := 'Numero de Controle invalido';
                ELSE
                  CLOSE cr_craplcs;

                  -- Verificar se tabela esta lockada
                  IF fn_verifica_tab_em_uso(pr_sig_tabela => 'LCS'
                                           ,pr_rowid => rw_craplcs.rowid ) = 1 THEN
                    vr_dscritic := 'Registro de Transferencia Conta Salario '||vr_aux_NumCtrlIF||' em uso. Tente novamente.';
                    -- apensa jogar critica em log
                    RAISE vr_exc_lock;
                  END IF;
                  -- Atualizar flopfin do registro da TEC
                  BEGIN
                    UPDATE craplcs
                       SET flgopfin = 1 -- True
                     WHERE cdcooper = rw_crapcop_mensag.cdcooper
                       AND idopetrf = vr_aux_NumCtrlIF
                     RETURNING nrridlfp INTO vr_aux_nrridflp;
                    -- Se nao atualizou nenhum registro
                    IF SQL%ROWCOUNT = 0 THEN
                      -- Gerar critica
                      vr_dscritic := 'Numero de Controle invalido';
                    END IF;
                  EXCEPTION
                    WHEN OTHERS THEN
                      vr_dscritic := 'Erro ao atualizar registro craplcs --> '||sqlerrm;
                  END;
                END IF;
                -- Se não deu erro e retornou Recid Folha IB
                IF vr_dscritic IS NULL AND vr_aux_nrridflp <> 0 THEN
                  -- checar se a tabela nao esta em lock
                  IF fn_verifica_tab_em_uso(pr_sig_tabela => 'LFP'
                                           ,pr_progress_recid => vr_aux_nrridflp ) = 1 THEN
                    vr_dscritic := 'Registro de Folha Conta Salario '||vr_aux_nrridflp||' em uso. Tente novamente.';
                    -- apensa jogar critica em log
                    RAISE vr_exc_lock;
                  END IF;

                  -- Usaremos este Recid para atualizar o registro no sistema de Folha
                  BEGIN
                    UPDATE craplfp
                       SET idsitlct = 'T'  -- Transmitido
                          ,dsobslct = NULL -- Sem observações por hora
                     WHERE cdcooper = rw_crapcop_mensag.cdcooper
                       AND progress_recid = vr_aux_nrridflp;
                  EXCEPTION
                    WHEN OTHERS THEN
                      vr_dscritic := 'Erro ao atualizar registro craplfp --> '||sqlerrm;
                  END;
                END IF;
              END IF;
            -- STR0004
            ELSIF SUBSTR(vr_aux_NumCtrlIF,1,1) <> '3'  THEN
              -- Gera critica
              vr_dscritic := 'Identificador TED/TEC invalido';
            END IF;
            -- Se houve critica
            IF vr_dscritic IS NOT NULL THEN
              -- Gera LOG SPB
              pc_gera_log_SPB(pr_tipodlog  => 'RETORNO SPB'
                             ,pr_msgderro  => vr_dscritic);
              -- Salvar o arquivo
              pc_salva_arquivo;
              -- Processo finalizado
              RAISE vr_exc_next;
            END IF;
          END IF;

          -- Ao final, gera LOG SPB
          pc_gera_log_SPB(pr_tipodlog  => 'RETORNO SPB'
                         ,pr_msgderro  => NULL);

          -- Salvar o arquivo
          pc_salva_arquivo;
          -- Processo finalizado
          RAISE vr_exc_next;

        ELSE
          -- Acionar rotina de tratamento de lançamentos
          pc_trata_lancamentos(pr_dscritic  => vr_dscritic);
          -- Tratar erro na chamada da gera log SPB
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;

          -- Salvar o arquivo
          pc_salva_arquivo;
          -- Processo finalizado
          RAISE vr_exc_next;

        END IF;

      EXCEPTION
        WHEN vr_exc_next THEN
          NULL; --> Apenas ignorar e continar o processo final
      END;
    END IF;

    -- Acionar rotina de encerramento da execução paralelo
    pc_finaliza_paralelo;
    -- Efetuar commit das alterações
    COMMIT;

  EXCEPTION
    WHEN vr_exc_lock THEN
      -- O arquivo não será movido, portanto não haverá chamada a pc_salva_arquivo ou pc_mover_arquivo_xml
      -- Assim ele será processado posteriormente em momento que a tabela não estiver em lock
      pr_dscritic := vr_dscritic;
      -- Efetuar rollback
      ROLLBACK;
      -- Iniciar LOG de execução
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratado
                                ,pr_des_log      => to_char(sysdate,'dd/mm/yyyy') || ' - ' || to_char(sysdate,'hh24:mi:ss')||' - '|| vr_glb_cdprogra ||' --> '||pr_dscritic);

      -- Novamente tenta encerrar o JOB
      gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                  ,pr_idprogra => pr_idprogra
                                  ,pr_des_erro => pr_dscritic);

      -- Efetuar commit das alterações
      COMMIT;
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
      END IF;
      -- Copiar aos parametros
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      -- Efetuar rollback
      ROLLBACK;
      -- Iniciar LOG de execução
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratado
                                ,pr_des_log      => to_char(sysdate,'dd/mm/yyyy') || ' - ' || to_char(sysdate,'hh24:mi:ss')||' - '|| vr_glb_cdprogra ||' --> '||pr_dscritic);

      -- Novamente tenta encerrar o JOB
      gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                  ,pr_idprogra => pr_idprogra
                                  ,pr_des_erro => pr_dscritic);

      -- Efetuar commit das alterações
      COMMIT;
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
      -- Iniciar LOG de execução
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 3 -- Erro não tratado
                                ,pr_des_log      => to_char(sysdate,'dd/mm/yyyy') || ' - ' || to_char(sysdate,'hh24:mi:ss')||' - '|| vr_glb_cdprogra ||' --> '||pr_dscritic);
      -- Efetuar rollback
      ROLLBACK;
      -- Novament tenta encerrar o JOB
      gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                  ,pr_idprogra => pr_idprogra
                                  ,pr_des_erro => pr_dscritic);
      -- Efetuar commit das alterações
      COMMIT;
  END;
END PC_CRPS531_1;
/
