/* ..........................................................................

   Programa: Fontes/crps600.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Fabricio
   Data    : Junho/2011                        Ultima atualizacao:   /  /
                                                                          
   Dados referentes ao programa:

   Frequencia: Tela.
   Objetivo  : Atende a solicitacao 107.
               Importacao Folha(Holerite de pagamento)
               
   Alteracoes:


............................................................................. */
DEF INPUT PARAM par_diretori AS CHAR                                 NO-UNDO.

DEF STREAM str_1. /* Para importacao, retorno e relatorio */
DEF STREAM str_2. /* Para ler o arquivo */

{ includes/var_batch.i "NEW" }

DEF NEW SHARED VAR shr_inpessoa AS INT                               NO-UNDO.

DEFINE VARIABLE aux_dsdlinha AS CHARACTER                            NO-UNDO.
DEFINE VARIABLE aux_dtrefere AS DATE                                 NO-UNDO.
DEFINE VARIABLE aux_nrseqddp AS INTEGER                              NO-UNDO.
DEFINE VARIABLE aux_nrseqmdp AS INTEGER                              NO-UNDO.
DEFINE VARIABLE aux_nrcgcemp AS DECIMAL                              NO-UNDO.
DEFINE VARIABLE aux_flgrgatv AS LOGICAL                              NO-UNDO.
DEFINE VARIABLE aux_cddpagto AS INTEGER                              NO-UNDO.
DEFINE VARIABLE aux_nrdconta AS INTEGER                              NO-UNDO.
DEFINE VARIABLE aux_idseqttl AS INTEGER                              NO-UNDO.
DEFINE VARIABLE aux_cdempres AS INTEGER                              NO-UNDO.
DEFINE VARIABLE aux_flgrecus AS LOGICAL                              NO-UNDO.
DEFINE VARIABLE aux_nmarquiv AS CHAR                                 NO-UNDO.
DEFINE VARIABLE aux_lsretarq AS CHAR                                 NO-UNDO.
DEFINE VARIABLE aux_lsarqint AS CHAR                                 NO-UNDO.

DEFINE VARIABLE aux_qtreghol AS INTEGER                              NO-UNDO.
DEFINE VARIABLE aux_qtregarq AS INTEGER                              NO-UNDO.
DEFINE VARIABLE aux_qtheader AS INTEGER                              NO-UNDO.
DEFINE VARIABLE aux_contador AS INTEGER                              NO-UNDO.

DEFINE VARIABLE rel_qtderros AS INTEGER                              NO-UNDO.
DEFINE VARIABLE rel_qtdgeral AS INTEGER                              NO-UNDO.
DEFINE VARIABLE rel_qtdcerto AS INTEGER                              NO-UNDO.

DEFINE VARIABLE h-b1wgen0011 AS HANDLE                               NO-UNDO.

/* Para auxiliar na geracao do arquivo de retorno */
DEFINE TEMP-TABLE w_retorno  NO-UNDO
       FIELD nmarquiv AS CHARACTER
       FIELD dslinarq AS CHARACTER
       FIELD cddmsgm1 AS INTEGER
       FIELD cddmsgm2 AS INTEGER
       FIELD cddmsgm3 AS INTEGER
       FIELD nrsequen AS INTEGER
       FIELD tpregist AS INTEGER
       FIELD qtheader AS INTEGER.
       
/* Variaveis para o relatorio */
DEFINE VARIABLE rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5      NO-UNDO.
DEFINE VARIABLE rel_nmresemp AS CHAR                                 NO-UNDO.
DEFINE VARIABLE rel_nrmodulo AS INT     FORMAT "9"                   NO-UNDO.
       
FORM w_retorno.nmarquiv         FORMAT "x(60)"    LABEL "ARQUIVO"
     SKIP(2)
     "RECEBIDOS"         AT 19
     "INTEGRADOS"        AT 38
     "REJEITADOS"        AT 58
     SKIP(1)
     "REGISTROS:"
     rel_qtdgeral        AT 22  FORMAT "zz,zz9" 
     rel_qtdcerto        AT 42  FORMAT "zz,zz9"
     rel_qtderros        AT 62  FORMAT "zz,zz9"
     SKIP(5)
     WITH DOWN NO-BOX SIDE-LABELS NO-LABELS FRAME f_relatorio.

ASSIGN glb_cdprogra = "crps600"
       glb_flgbatch = FALSE.

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     QUIT.

{ includes/crps479.i }

RUN fontes/fimprg.p.

/* ......................................................................... */
