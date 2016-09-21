/*............................................................................

    Programa: b1wgen0076.p
    Autor   : Kbase - Alexandre
    Data    : Junho/2010                   Ultima Atualizacao: 07/06/2016
    
    Dados referentes ao programa:

    Objetivo  : Rotinas para integragco de varios cheques custodiados a uma
                conta.
                
    Alteracoes 16/08/2010 - Incluir procedure ver_cheque
                          - Incluir procedure ver_associado
                          - Incluir procedure contra_ordem 
                          - Ajustes para deixar a BO o mais generico possivel
                           (Guilherme).
                           
               17/09/2010 - Incluido caminho completo na leitura e gravacao 
                            dos arquivos no diretorio "salvar" (Elton).
                            
               09/12/2011 - Sustação provisória (André R./Supero).
               
               21/05/2012 - substituição do FIND craptab para os registros 
                            CONTACONVE pela chamada do fontes ver_ctace.p
                            (Lucas R.) 
                            
               13/12/2013 - Adicionado VALIDATE para CREATE. (Jorge)                           

               17/06/2016 - Inclusão de campos de controle de vendas - M181 ( Rafael Maciel - RKAM)                       
...........................................................................*/

/*................................ DEFINICOES ..............................*/

{ sistema/generico/includes/b1wgen0076tt.i } 
{ sistema/ayllos/includes/var_online.i NEW }

{ sistema/generico/includes/var_internet.i } 
{ sistema/generico/includes/gera_erro.i }    

DEF STREAM str-in.

DEFINE VARIABLE aux_cdcritic AS INTEGER     NO-UNDO.
DEFINE VARIABLE aux_dscritic AS CHARACTER   NO-UNDO.

PROCEDURE ler_arquivo:

    DEFINE INPUT        PARAMETER par_cdcooper AS INT        NO-UNDO.
    DEFINE INPUT        PARAMETER par_dtmvtolt AS DATE       NO-UNDO.
    DEFINE INPUT        PARAMETER par_cdoperad AS CHAR       NO-UNDO.
    DEFINE INPUT        PARAMETER par_nmarqint AS CHAR       NO-UNDO.
    DEFINE INPUT        PARAMETER par_cdagenci AS INT        NO-UNDO.
    DEFINE INPUT        PARAMETER par_cdbccxlt AS INT        NO-UNDO.
    DEFINE INPUT        PARAMETER par_nrdolote AS INT        NO-UNDO.
    DEFINE INPUT        PARAMETER par_nrcustod AS INT        NO-UNDO.
    DEFINE OUTPUT       PARAMETER par_dscritic AS CHAR       NO-UNDO.
    DEFINE OUTPUT       PARAMETER TABLE FOR tt-msg-confirma.
    DEFINE OUTPUT       PARAMETER TABLE FOR arq-lote.
    DEFINE OUTPUT       PARAMETER TABLE FOR tt-retorno.
    DEFINE OUTPUT       PARAMETER TABLE FOR tt-erros-arq.   

    DEFINE VARIABLE aux_nrderros AS INTEGER     NO-UNDO.
    DEFINE VARIABLE c-linha      AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE i-cont       AS INT         NO-UNDO INITIAL 0.

    EMPTY TEMP-TABLE tt-msg-confirma.
    EMPTY TEMP-TABLE tt-retorno.
    EMPTY TEMP-TABLE tt-erros-arq.
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    ASSIGN i-cont = 0.
    INPUT STREAM str-in FROM VALUE (par_nmarqint).

    REPEAT:
        IMPORT STREAM str-in UNFORMATTED c-linha.
        
        /*cria temporarias*/
        CASE SUBSTRING(c-linha,8,1):
            WHEN '0' THEN
            DO:
                CREATE arq-header.
                ASSIGN arq-header.con-banco     = INT(SUBSTRING(c-linha,1,3))
                       arq-header.con-lote      = INT(SUBSTRING(c-linha,4,4))
                       arq-header.con-registro  = INT(SUBSTRING(c-linha,8,1))
                       arq-header.insc-tipo     = INT(SUBSTRING(c-linha,18,1))
                       arq-header.insc-numero   = SUBSTRING(c-linha,19,14)       /*verificar*/          
                       arq-header.convenio      = INT(SUBSTRING(c-linha,33,9))
                       arq-header.emp-banco     = SUBSTRING(c-linha,42,11)
                       arq-header.ag-codigo     = INT(SUBSTRING(c-linha,53,5))
                       arq-header.ag-dv         = SUBSTRING(c-linha,58,1)
                       arq-header.cta-numero    = SUBSTRING(c-linha,59,12)       /*verificar*/
                       arq-header.cta-dv        = SUBSTRING(c-linha,71,1)
                       arq-header.ag-ct-dv      = SUBSTRING(c-linha,72,1)
                       arq-header.nome          = SUBSTRING(c-linha,73,30)
                       arq-header.banco         = SUBSTRING(c-linha,103,30)
                       arq-header.identificador = INT(SUBSTRING(c-linha,143,1))
                       arq-header.dat-gera      = SUBSTRING(c-linha,144,8)
                       arq-header.hora-gera     = SUBSTRING(c-linha,152,6)
                       arq-header.seq           = INT(SUBSTRING(c-linha,158,6))
                       arq-header.ver-layout    = INT(SUBSTRING(c-linha,164,3))
                       arq-header.densidade     = INT(SUBSTRING(c-linha,167,5))
                       arq-header.reserv-banco  = SUBSTRING(c-linha,172,20)
                       arq-header.reserv-emp    = SUBSTRING(c-linha,192,20)
                       arq-header.cod-retorno   = SUBSTRING(c-linha,231,2)
                       arq-header.cod-ocor-retorno 
                                                = SUBSTRING(c-linha,233,8).
            END.
            WHEN '1' THEN
            DO:
                CREATE arq-header-lote.
                ASSIGN i-cont = i-cont + 1.
                ASSIGN arq-header-lote.cont     = i-cont
                       arq-header-lote.con-banco 
                                                = INT(SUBSTRING(c-linha,1,3))
                       arq-header-lote.con-lote = INT(SUBSTRING(c-linha,4,4))
                       arq-header-lote.con-registro
                                                = INT(SUBSTRING(c-linha,8,1))
                       arq-header-lote.s-ope    = SUBSTRING(c-linha,9,1)
                       arq-header-lote.s-serv   = INT(SUBSTRING(c-linha,10,2))
                       arq-header-lote.s-flanc  = INT(SUBSTRING(c-linha,12,2))
                       arq-header-lote.ver-layout
                                                = INT(SUBSTRIN(c-linha,14,3))
                       arq-header-lote.ins-tipo = INT(SUBSTRING(c-linha,18,1))
                       arq-header-lote.ins-numero
                                                = SUBSTRING(c-linha,19,14)
                       arq-header-lote.e-convenio
                                                = INT(SUBSTRING(c-linha,33,9))
                       arq-header-lote.e-banco  = SUBSTRING(c-linha,42,11)
                       arq-header-lote.e-agencia
                                                = INT(SUBSTRING(c-linha,53,5))
                       arq-header-lote.e-dv-aencia
                                                = SUBSTRING(c-linha,58,1)
                       arq-header-lote.e-remessa
                                                = INT(SUBSTRING(c-linha,59,6))
                       arq-header-lote.ag-codigo
                                                = INT(SUBSTRING(c-linha,65,5))
                       arq-header-lote.ag-dv    = SUBSTRING(c-linha,70,1)
                       arq-header-lote.con-numero
                                                = INT(SUBSTRING(c-linha,71,12))
                       arq-header-lote.con-dv   = SUBSTRING(c-linha,83,1)
                       arq-header-lote.ag-ct-dv = SUBSTRING(c-linha,84,1)
                       arq-header-lote.e-nome   = SUBSTRING(c-linha,85,30)
                       arq-header-lote.e-dat-remessa
                                                = SUBSTRING(c-linha,115,8)
                       arq-header-lote.num-remessa
                                                = SUBSTRING(c-linha,123,6)
                       arq-header-lote.c-livre1 = SUBSTRING(c-linha,129,10)
                       arq-header-lote.inf1     = SUBSTRING(c-linha,139,4)
                       arq-header-lote.end-logradouro
                                                = SUBSTRING(c-linha,143,30)
                       arq-header-lote.end-numero
                                                = SUBSTRING(c-linha,173,5)
                       arq-header-lote.end-complemento
                                                = SUBSTRING(c-linha,178,15)
                       arq-header-lote.end-cidade
                                                = SUBSTRING(c-linha,193,20)
                       arq-header-lote.end-cep  = SUBSTRING(c-linha,213,5)
                       arq-header-lote.end-comp-cep
                                                = SUBSTRING(c-linha,218,3)
                       arq-header-lote.end-uf   = SUBSTRING(c-linha,221,2)
                       arq-header-lote.cod-retorno
                                                = SUBSTRING(c-linha,231,2)
                       arq-header-lote.cod-ocor-retorno
                                                = SUBSTRING(c-linha,233,8).

            END.
            WHEN '3' THEN
            DO:
                CREATE arq-det-seg.
                ASSIGN arq-det-seg.cont         = i-cont 
                       arq-det-seg.con-banco    = INT(SUBSTRING(c-linha,1,3))
                       arq-det-seg.con-lote     = INT(SUBSTRING(c-linha,4,4))
                       arq-det-seg.con-registro = INT(SUBSTRING(c-linha,8,1))
                       arq-det-seg.s-num-registro
                                                = INT(SUBSTRING(c-linha,9,5))
                       arq-det-seg.s-segmento   = SUBSTRING(c-linha,14,1)
                       arq-det-seg.s-mov-tipo   = INT(SUBSTRING(c-linha,15,1))
                       arq-det-seg.s-mov-cod    = INT(SUBSTRIN(c-linha,16,2))
                       arq-det-seg.c-cmc7       = SUBSTRING(c-linha,18,34)
                       arq-det-seg.c-cmc7-ori   = SUBSTRING(c-linha,18,34)
                       arq-det-seg.c-cgc        = SUBSTRING(c-linha,52,14)
                       arq-det-seg.c-valor      = 
                                          (DEC(SUBSTRING(c-linha,66,15))) / 100
                       arq-det-seg.dat-bom      = DATE(SUBSTRING(c-linha,81,2) 
                                                    +  SUBSTRING(c-linha,83,2) 
                                                    +  SUBSTRING(c-linha,85,4))
                       arq-det-seg.campo-livre  = SUBSTRING(c-linha,89,10)
                       arq-det-seg.banco        = SUBSTRING(c-linha,99,10)
                       arq-det-seg.v-comp-depositan
                                                = INT(SUBSTRING(c-linha,109,3))
                       arq-det-seg.v-banco-rem  = INT(SUBSTRING(c-linha,112,3))
                       arq-det-seg.v-ag-rem     = INT(SUBSTRING(c-linha,115,5))
                       arq-det-seg.v-ag-dep     = INT(SUBSTRING(c-linha,120,5))
                       arq-det-seg.v-num-cta    = SUBSTRING(c-linha,125,12)
                       arq-det-seg.d-juros      = 
                                          (DEC(SUBSTRING(c-linha,137,15))) / 100
                       arq-det-seg.d-iof        =
                                          (DEC(SUBSTRING(c-linha,152,15))) / 100
                       arq-det-seg.d-outros     =
                                          (DEC(SUBSTRING(c-linha,167,15))) / 100
                       arq-det-seg.cod-retorno  = SUBSTRING(c-linha,231,2)
                       arq-det-seg.cod-ocor-retorno
                                                = SUBSTRING(c-linha,233,8).

                ASSIGN arq-det-seg.c-cmc7       = "<" +
                                    SUBSTRING(arq-det-seg.c-cmc7,2,8)   + "<" + 
                                    SUBSTRING(arq-det-seg.c-cmc7,11,10) + ">" +
                                    SUBSTRING(arq-det-seg.c-cmc7,22,12) + ":".
            END.
            WHEN '5' THEN
            DO:
                CREATE arq-lote.
                ASSIGN arq-lote.cont            = i-cont
                       arq-lote.con-banco       = INT(SUBSTRING(c-linha,1,3))
                       arq-lote.con-lote        = INT(SUBSTRING(c-linha,4,4))
                       arq-lote.con-registro    = INT(SUBSTRING(c-linha,8,1))
                       arq-lote.qtd-reg         = INT(SUBSTRING(c-linha,18,6))
                       arq-lote.val-cheques     =
                                          (DEC(SUBSTRING(c-linha,24,18))) / 100
                       arq-lote.qtd-cheques     = INT(SUBSTRING(c-linha,42,6))
                       arq-lote.tot-d-juros     = 
                                          (DEC(SUBSTRING(c-linha,100,18))) / 100
                       arq-lote.tot-d-iof       = 
                                          (DEC(SUBSTRING(c-linha,118,18))) / 100
                       arq-lote.tot-d-outros    =
                                          (DEC(SUBSTRING(c-linha,136,18))) / 100
                       arq-lote.re-qtd-processado
                                                = INT(SUBSTRING(c-linha,154,6))
                       arq-lote.re-val-processado =
                                         (DEC(SUBSTRING(c-linha,160,18))) / 100.
            END.
            WHEN '9' THEN
            DO:
                CREATE arq-trailer.
                ASSIGN arq-trailer.con-banco    = INT(SUBSTRING(c-linha,1,3))
                       arq-trailer.con-lote     = INT(SUBSTRING(c-linha,4,4))
                       arq-trailer.con-registro = INT(SUBSTRING(c-linha,8,1))
                       arq-trailer.qtd-lote     = INT(SUBSTRING(c-linha,18,6))
                       arq-trailer.qtd-registros
                                                = INT(SUBSTRING(c-linha,24,6))
                       arq-trailer.qtd-cta      = INT(SUBSTRING(c-linha,30,6)).
            END.
        END CASE.
    END.
        
    INPUT STREAM str-in CLOSE.
                              
    RUN valida-arquivo(INPUT par_cdcooper,
                       INPUT par_dtmvtolt,
                       INPUT par_cdoperad,
                       INPUT par_cdagenci,
                       INPUT par_cdbccxlt, 
                       INPUT par_nrdolote, 
                       INPUT par_nrcustod,
                      OUTPUT par_dscritic,
                      OUTPUT TABLE arq-lote).
    
    IF  RETURN-VALUE <> "OK" THEN
        DO:
            RETURN "NOK".
        END.                   
    
    FIND FIRST tt-erros-arq WHERE tt-erros-arq.flgderro NO-LOCK NO-ERROR.

    IF  AVAIL tt-erros-arq  THEN
    DO:
        CREATE tt-msg-confirma.
        ASSIGN tt-msg-confirma.inconfir = 99
               tt-msg-confirma.dsmensag = 
               "Arquivo possui restricoes. Deseja importar?".
    END.
    
    RETURN "OK".

END PROCEDURE.


PROCEDURE valida-arquivo:

    DEFINE INPUT        PARAMETER par_cdcooper AS INT        NO-UNDO.
    DEFINE INPUT        PARAMETER par_dtmvtolt AS DATE       NO-UNDO.
    DEFINE INPUT        PARAMETER par_cdoperad AS CHAR       NO-UNDO.
    DEFINE INPUT        PARAMETER par_cdagenci AS INT        NO-UNDO.
    DEFINE INPUT        PARAMETER par_cdbccxlt AS INT        NO-UNDO.
    DEFINE INPUT        PARAMETER par_nrdolote AS INT        NO-UNDO.
    DEFINE INPUT        PARAMETER par_nrcustod AS DEC        NO-UNDO.
    DEFINE OUTPUT       PARAMETER par_dscritic AS CHAR       NO-UNDO.
    DEFINE OUTPUT       PARAMETER TABLE FOR arq-lote.
    
    DEFINE VARIABLE i-cont-header AS INTEGER     NO-UNDO.
    DEFINE VARIABLE i-cont-lote   AS INTEGER     NO-UNDO.
    DEFINE VARIABLE i-qtd-regs    AS INTEGER     NO-UNDO. /*1,3,5*/
    DEFINE VARIABLE d-c-valor     AS DECIMAL     NO-UNDO.
    DEFINE VARIABLE d-d-juros     AS DECIMAL     NO-UNDO.
    DEFINE VARIABLE d-d-iof       AS DECIMAL     NO-UNDO.
    DEFINE VARIABLE d-d-outros    AS DECIMAL     NO-UNDO.
    DEFINE VARIABLE d-val-cheq    AS DECIMAL     NO-UNDO.
    DEFINE VARIABLE i-cont-det    AS INTEGER     NO-UNDO.
    DEFINE VARIABLE aux_dtminimo  AS DATE        NO-UNDO.
    DEFINE VARIABLE aux_qtddmini AS INT          NO-UNDO.
    DEFINE VARIABLE aux_nrcalcul AS DECIMAL FORMAT ">>>>>>>>>>>>>9" NO-UNDO.
    DEFINE VARIABLE aux_flgderro AS LOGICAL      NO-UNDO.
    DEFINE VARIABLE i-nrseqdig   AS INT          NO-UNDO.

    DEFINE VARIABLE aux_dsdctitg AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE aux_nrchqsdv AS INTEGER     NO-UNDO.
    DEFINE VARIABLE aux_nrchqcdv AS INTEGER     NO-UNDO.

    DEFINE VARIABLE tab_intracst AS INT         NO-UNDO.
    DEFINE VARIABLE tab_inchqcop AS INT         NO-UNDO.
    
    /*cmc7*/
    DEFINE VARIABLE aux_cdbanchq AS INTEGER     NO-UNDO.
    DEFINE VARIABLE aux_cdagechq AS INTEGER     NO-UNDO.
    DEFINE VARIABLE aux_cdcmpchq AS INTEGER     NO-UNDO.
    DEFINE VARIABLE aux_nrcheque AS INTEGER     NO-UNDO.
    DEFINE VARIABLE aux_nrctachq AS DECIMAL     NO-UNDO.
    DEFINE VARIABLE aux_nrddigc1 AS INTEGER     NO-UNDO.
    DEFINE VARIABLE aux_nrddigc2 AS INTEGER     NO-UNDO.
    DEFINE VARIABLE aux_nrddigc3 AS INTEGER     NO-UNDO.
    DEFINE VARIABLE aux_nrdconta AS INTEGER     NO-UNDO.
    DEFINE VARIABLE aux_nrdocmto AS INT         NO-UNDO.

    DEFINE VARIABLE h-b1wgen0044 AS HANDLE      NO-UNDO.
    DEFINE VARIABLE h-b1wgen9999 AS HANDLE      NO-UNDO.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           par_dscritic = "".

    EMPTY TEMP-TABLE arq-lote.

    FOR EACH arq-header NO-LOCK:

        IF arq-header.ver-layout <> 30 THEN
           RUN gera_erro_arq (INPUT "Versao de Layout do Header incorreta.", 
                              INPUT TRUE,
                              INPUT arq-header.con-lote,
                              INPUT "").
        
        ASSIGN i-cont-header = i-cont-header + 1.
    END.
    
    FOR EACH arq-header-lote NO-LOCK
        BREAK BY arq-header-lote.cont :

        IF arq-header-lote.ver-layout <> 20 THEN
           RUN gera_erro_arq (INPUT "Versao de Layout do Header do Lote incorreta.",
                              INPUT TRUE,
                              INPUT arq-header-lote.con-lote,
                              INPUT "").
        
        ASSIGN i-cont-lote = i-cont-lote + 1.
    
        IF FIRST-OF(arq-header-lote.cont) THEN
            ASSIGN d-c-valor   = 0
                   d-d-juros   = 0
                   d-d-iof     = 0
                   d-d-outros  = 0
                   i-cont-det  = 0
                   d-val-cheq  = 0.

        ASSIGN i-qtd-regs = i-qtd-regs + i-cont-lote.

        FOR EACH arq-det-seg WHERE
                 arq-det-seg.cont = arq-header-lote.cont 
                 NO-LOCK :
    
            ASSIGN d-c-valor   = d-c-valor  + arq-det-seg.c-valor
                   d-d-juros   = d-d-juros  + arq-det-seg.d-juros
                   d-d-iof     = d-d-iof    + arq-det-seg.d-iof
                   d-d-outros  = d-d-outros + arq-det-seg.d-outros
                   i-cont-det  = i-cont-det + 1
                   d-val-cheq  = d-val-cheq + arq-det-seg.c-valor.
        
            IF  arq-det-seg.dat-bom = ? THEN
                RUN gera_erro_arq (INPUT "(" + STRING(arq-det-seg.s-num-registro,"99999")
                                         + ") Data (Bom Para) do cheque invalida.",
                                   INPUT TRUE,
                                   INPUT arq-det-seg.con-lote,
                                   INPUT arq-det-seg.c-cmc7-ori).
            ELSE
                DO:
                     ASSIGN aux_dtminimo = par_dtmvtolt
                            aux_qtddmini = 0.

                     IF  par_cdcooper = 1 THEN
                         DO WHILE TRUE:

                            aux_dtminimo = aux_dtminimo + 1.

                            IF  CAN-DO("1,7",STRING(WEEKDAY(aux_dtminimo))) OR
                                CAN-FIND(crapfer WHERE crapfer.cdcooper =
                                                       par_cdcooper         AND
                                crapfer.dtferiad = aux_dtminimo) THEN
                                NEXT.
                            ELSE 
                                aux_qtddmini = aux_qtddmini + 1.

                            IF   aux_qtddmini = 2 THEN
                                 LEAVE.

                         END.  /*  Fim do DO WHILE TRUE  */
                     
                     IF  arq-det-seg.dat-bom < aux_dtminimo         OR
                         arq-det-seg.dat-bom > (par_dtmvtolt + 360) OR
                         /*  Nao permite data de liberacao para 31/12  */
                        (MONTH(arq-det-seg.dat-bom) = 12   AND
                         DAY(arq-det-seg.dat-bom)  >= 29)   /* 31 */ THEN
                         RUN gera_erro_arq (
                             INPUT "(" + STRING(arq-det-seg.s-num-registro,"99999")
                                   + ") Data (Bom Para) do cheque invalida.",
                             INPUT TRUE,
                             INPUT arq-det-seg.con-lote,
                             INPUT arq-det-seg.c-cmc7-ori). 
           
                END.
                
            IF arq-det-seg.c-valor <= 0 THEN
                RUN gera_erro_arq (INPUT "(" + STRING(arq-det-seg.s-num-registro,"99999")
                                         + ") Valor do cheque invalido.",
                                   INPUT TRUE,
                                   INPUT arq-det-seg.con-lote,
                                   INPUT arq-det-seg.c-cmc7-ori).
        END.
    
        ASSIGN i-qtd-regs = i-qtd-regs + i-cont-det.
        
        FOR EACH arq-lote WHERE
                 arq-lote.cont = arq-header-lote.cont 
                 NO-LOCK :
                
            IF arq-lote.tot-d-juros <> d-d-juros THEN
                RUN gera_erro_arq (INPUT "Valor Total do JURUS nao confere.", 
                                   INPUT TRUE, 
                                   INPUT arq-lote.con-lote,
                                   INPUT "").
                            
            IF arq-lote.tot-d-iof <> d-d-iof THEN
                RUN gera_erro_arq (INPUT "Valor Total do IOF nao confere.", 
                                   INPUT TRUE,
                                   INPUT arq-lote.con-lote,
                                   INPUT "").
    
            IF arq-lote.tot-d-outros <> d-d-outros THEN
                RUN gera_erro_arq (INPUT "Valor Total de OUTROS nao confere.", 
                                   INPUT TRUE,
                                   INPUT arq-lote.con-lote,
                                   INPUT "").
                                                
            ASSIGN i-qtd-regs = i-qtd-regs + 1.
    
            IF i-qtd-regs <> arq-lote.qtd-reg  THEN
                RUN gera_erro_arq (INPUT "Quantidade de registros do LOTE " +
                                         "nao confere.", 
                                   INPUT TRUE,
                                   INPUT arq-lote.con-lote,
                                   INPUT "").
  
            IF i-cont-det <> arq-lote.qtd-cheques THEN
                RUN gera_erro_arq (INPUT "Quantidade de cheques nao confere.", 
                                   INPUT TRUE,
                                   INPUT arq-lote.con-lote,
                                   INPUT "").
    
            IF d-val-cheq <> arq-lote.val-cheques  THEN
                RUN gera_erro_arq (INPUT "Valor Total dos cheques nao confere.", 
                                   INPUT TRUE,
                                   INPUT arq-lote.con-lote,
                                   INPUT "").
        END.
    END.

    FIND FIRST arq-trailer NO-LOCK NO-ERROR.
    
    IF  arq-trailer.qtd-lote <> i-cont-lote  THEN
        RUN gera_erro_arq (INPUT "Quantidade de Lotes do arquivo nao confere.", 
                           INPUT TRUE, 
                           INPUT arq-trailer.con-lote,
                           INPUT "").
   
    ASSIGN i-nrseqdig = 0.

    EMPTY TEMP-TABLE tt-erro.

    RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.

    IF   NOT VALID-HANDLE(h-b1wgen9999)  THEN
         DO:
             ASSIGN par_dscritic = "Handle invalido para h-b1wgen9999.".
             RETURN "NOK".
         END.
    
    FOR EACH arq-det-seg NO-LOCK :
           
        ASSIGN aux_flgderro = FALSE.
        
        /*CMC7*/
        ASSIGN aux_cdbanchq = INT(SUBSTRING(arq-det-seg.c-cmc7,02,03)) NO-ERROR.
               aux_cdagechq = INT(SUBSTRING(arq-det-seg.c-cmc7,05,04)) NO-ERROR.
               aux_cdcmpchq = INT(SUBSTRING(arq-det-seg.c-cmc7,11,03)) NO-ERROR.
               aux_nrcheque = INT(SUBSTRING(arq-det-seg.c-cmc7,14,06)) NO-ERROR.
               aux_nrctachq = IF aux_cdbanchq = 1
                              THEN DECIMAL(SUBSTRING(arq-det-seg.c-cmc7,25,08))
                              ELSE DECIMAL(SUBSTRING(arq-det-seg.c-cmc7,23,10)) 
                                   NO-ERROR.
        
               aux_nrcalcul = DECIMAL(STRING(aux_cdcmpchq,"999") +
                                      STRING(aux_cdbanchq,"999") +
                                      STRING(aux_cdagechq,"9999") + "0") 
                                      NO-ERROR.

        IF  ERROR-STATUS:ERROR  THEN
            DO:
                RUN gera_erro_arq (INPUT "Erro no CMC7 " + ERROR-STATUS:GET-MESSAGE(1),
                                   INPUT TRUE,
                                   INPUT arq-det-seg.con-lote,
                                   INPUT arq-det-seg.c-cmc7).
                ASSIGN aux_flgderro = TRUE.
            END.

        RUN dig_fun IN h-b1wgen9999 (INPUT par_cdcooper,
                                     INPUT par_cdagenci,
                                     INPUT 0,
                                     INPUT-OUTPUT aux_nrcalcul,
                                     OUTPUT TABLE tt-erro).

        aux_nrddigc1 = INT(SUBSTRING(STRING(aux_nrcalcul),
                       LENGTH(STRING(aux_nrcalcul)))) NO-ERROR.

        IF  ERROR-STATUS:ERROR  THEN
            DO:
                RUN gera_erro_arq (INPUT "Erro no C1 " + ERROR-STATUS:GET-MESSAGE(1), 
                                   INPUT TRUE,
                                   INPUT arq-det-seg.con-lote,
                                   INPUT arq-det-seg.c-cmc7).
                ASSIGN aux_flgderro = TRUE.
            END.
                
        aux_nrcalcul = aux_nrctachq * 10.
        
        RUN dig_fun IN h-b1wgen9999 (INPUT par_cdcooper,
                                     INPUT par_cdagenci,
                                     INPUT 0,
                                     INPUT-OUTPUT aux_nrcalcul,
                                     OUTPUT TABLE tt-erro).
        
        aux_nrddigc2 = INT(SUBSTRING(STRING(aux_nrcalcul),
                       LENGTH(STRING(aux_nrcalcul)))) NO-ERROR.

        IF  ERROR-STATUS:ERROR  THEN
            DO:
                RUN gera_erro_arq (INPUT "Erro no C2 " + ERROR-STATUS:GET-MESSAGE(1), 
                                   INPUT TRUE,
                                   INPUT arq-det-seg.con-lote,
                                   INPUT arq-det-seg.c-cmc7).
                ASSIGN aux_flgderro = TRUE.
            END.
                                      
        aux_nrcalcul = aux_nrcheque * 10.
        
        RUN dig_fun IN h-b1wgen9999 (INPUT par_cdcooper,
                                     INPUT par_cdagenci,
                                     INPUT 0,
                                     INPUT-OUTPUT aux_nrcalcul,
                                     OUTPUT TABLE tt-erro).
        
        aux_nrddigc3 = INT(SUBSTRING(STRING(aux_nrcalcul),
                       LENGTH(STRING(aux_nrcalcul)))) NO-ERROR.

        IF  ERROR-STATUS:ERROR  THEN
            DO:
                RUN gera_erro_arq (INPUT "Erro no C3 " + 
                                         ERROR-STATUS:GET-MESSAGE(1), 
                                   INPUT TRUE,
                                   INPUT arq-det-seg.con-lote,
                                   INPUT arq-det-seg.c-cmc7).
                ASSIGN aux_flgderro = TRUE.
            END.
        
        RUN ver_cheque(INPUT par_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT par_nrcustod,
                       INPUT aux_nrctachq,
                       INPUT aux_nrcheque,
                       INPUT aux_nrddigc3,
                       INPUT aux_cdbanchq,
                       INPUT aux_cdagechq,
                       INPUT arq-det-seg.c-valor,
                       OUTPUT aux_nrdconta,
                       OUTPUT aux_dsdctitg,
                       OUTPUT aux_nrchqsdv,
                       OUTPUT aux_nrchqcdv,
                       OUTPUT TABLE tt-erro).

        IF  RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            IF  AVAIL tt-erro  THEN
            DO:
                RUN gera_erro_arq (INPUT tt-erro.dscritic,
                                   INPUT TRUE,
                                   INPUT arq-det-seg.con-lote,
                                   INPUT arq-det-seg.c-cmc7).
                ASSIGN aux_flgderro = TRUE.
            END.
            ELSE
            DO:
                RUN gera_erro_arq (INPUT "Problema na leitura do cheque",
                                   INPUT TRUE,
                                   INPUT arq-det-seg.con-lote,
                                   INPUT arq-det-seg.c-cmc7).
                ASSIGN aux_flgderro = TRUE.
            END.
        END.
            
        /*  Verifica parametros de custodia para a conta favorecida  */
        FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                           craptab.nmsistem = "CRED"       AND
                           craptab.tptabela = "CUSTOD"     AND
                           craptab.cdempres = 00           AND
                           craptab.cdacesso = STRING(par_nrcustod,
                                           "9999999999")   AND
                           craptab.tpregist = 0 NO-LOCK NO-ERROR.
        IF   NOT AVAILABLE craptab   THEN
             ASSIGN tab_intracst = 1 /*  Tratamento comp. CREDIHERING  */
                    tab_inchqcop = 1.
        ELSE
             ASSIGN tab_intracst = INT(SUBSTR(craptab.dstextab,01,01))
                    tab_inchqcop = INT(SUBSTR(craptab.dstextab,03,01)).

        /*CMC-7:*/
        IF   LENGTH(arq-det-seg.c-cmc7-ori) <> 34           OR
             SUBSTRING(arq-det-seg.c-cmc7-ori,01,1) <> "<"  OR
             SUBSTRING(arq-det-seg.c-cmc7-ori,10,1) <> "<"  OR
             SUBSTRING(arq-det-seg.c-cmc7-ori,21,1) <> ">"  OR
             SUBSTRING(arq-det-seg.c-cmc7-ori,34,1) <> ":"  THEN
        DO:  
            RUN gera_erro_arq (INPUT "(" + 
                                      STRING(arq-det-seg.s-num-registro,"99999") 
                                      + ") Formato do CMC7 invalido ",
                               INPUT TRUE,
                               INPUT arq-det-seg.con-lote,
                               INPUT arq-det-seg.c-cmc7-ori).
            ASSIGN aux_flgderro = TRUE.
        END.
        
        /* Instanciar a BO que fara validacao do Banco e Agencia */
        RUN sistema/generico/procedures/b1wgen0044.p 
            PERSISTENT SET h-b1wgen0044.

        IF   VALID-HANDLE(h-b1wgen0044)  THEN
             DO:
                 RUN valida_banco_agencia IN h-b1wgen0044                 
                    (INPUT  INT(SUBSTRING(arq-det-seg.c-cmc7,02,3)), 
                     INPUT  INT(SUBSTRING(arq-det-seg.c-cmc7,05,4)), 
                     OUTPUT TABLE tt-erro).

                 /* Verifica se houve erro */
                 FIND FIRST tt-erro NO-LOCK NO-ERROR.

                 IF   AVAILABLE tt-erro   THEN
                      DO:
                          RUN gera_erro_arq 
                              (INPUT "(" + STRING(arq-det-seg.s-num-registro,"99999") 
                                     + ") " + tt-erro.dscritic,
                               INPUT TRUE,
                               INPUT arq-det-seg.con-lote,
                               INPUT arq-det-seg.c-cmc7-ori).
                          ASSIGN aux_flgderro = TRUE.
                      END.

                 /* Remover a instancia da b1wgen0044 da memoria */
                 DELETE PROCEDURE h-b1wgen0044.  
             END.
        ELSE
             DO:
                 ASSIGN par_dscritic =  "Handle invalido para h-b1wgen0044.".
                 RETURN "NOK".
             END.

        FIND crapcst WHERE crapcst.cdcooper = par_cdcooper AND 
                           crapcst.dtmvtolt = par_dtmvtolt AND
                           crapcst.cdagenci = par_cdagenci AND
                           crapcst.cdbccxlt = par_cdbccxlt AND
                           crapcst.nrdolote = par_nrdolote AND
                           crapcst.cdcmpchq = aux_cdcmpchq AND
                           crapcst.cdbanchq = aux_cdbanchq AND
                           crapcst.cdagechq = aux_cdagechq AND
                           crapcst.nrctachq = aux_nrctachq AND
                           crapcst.nrcheque = aux_nrcheque
                           NO-LOCK NO-ERROR.
        
        IF  AVAIL crapcst THEN
            DO:
                RUN gera_erro_arq 
                    (INPUT "(" + STRING(arq-det-seg.s-num-registro,"99999") 
                           + ") Cheque ja esta em custodia. " ,
                     INPUT TRUE,
                     INPUT arq-det-seg.con-lote,
                     INPUT arq-det-seg.c-cmc7-ori).
                ASSIGN aux_flgderro = TRUE.
            END.
        
        CREATE tt-retorno.
        ASSIGN tt-retorno.nrdconta   = par_nrcustod
               tt-retorno.nrdolote   = par_nrdolote
               tt-retorno.dtmvtolt   = par_dtmvtolt
               tt-retorno.dtlibera   = arq-det-seg.dat-bom
               tt-retorno.cdcmpchq   = aux_cdcmpchq
               tt-retorno.cdbanchq   = aux_cdbanchq
               tt-retorno.cdagechq   = aux_cdagechq
               tt-retorno.nrctachq   = aux_nrctachq
               tt-retorno.nrcheque   = aux_nrcheque
               tt-retorno.vlcheque   = arq-det-seg.c-valor
               tt-retorno.cdopedev   = ""
               tt-retorno.insitchq   = 0
               tt-retorno.dtdevolu   = ?
               tt-retorno.dsdocmc7   = arq-det-seg.c-cmc7
               tt-retorno.c-cmc7-ori = arq-det-seg.c-cmc7-ori
               tt-retorno.nrseqdig   = i-nrseqdig + 1
               tt-retorno.nrddigc1   = aux_nrddigc1
               tt-retorno.nrddigc2   = aux_nrddigc2
               tt-retorno.nrddigc3   = aux_nrddigc2
               tt-retorno.cdagenci   = par_cdagenci
               tt-retorno.cdbccxlt   = par_cdbccxlt
               tt-retorno.cdoperad   = par_cdoperad
               tt-retorno.cdcooper   = par_cdcooper
               tt-retorno.flgderro   = aux_flgderro
               tt-retorno.inchqcop   = tab_inchqcop
               tt-retorno.corrente   = aux_nrdconta
               tt-retorno.s-num-registro 
                                     = arq-det-seg.s-num-registro
               tt-retorno.lote-cont  = arq-det-seg.cont
               i-nrseqdig            = i-nrseqdig + 1.

    END.
    
    DELETE PROCEDURE h-b1wgen9999.

    RETURN "OK".

END PROCEDURE.


PROCEDURE integra-arquivo:

    DEFINE INPUT        PARAMETER par_cdcooper AS INT        NO-UNDO.
    DEFINE INPUT        PARAMETER par_dtmvtolt AS DATE       NO-UNDO.
    DEFINE INPUT        PARAMETER par_cdoperad AS CHAR       NO-UNDO.
    DEFINE INPUT        PARAMETER par_nmarqint AS CHAR       NO-UNDO.
    DEFINE INPUT        PARAMETER par_cdagenci AS INT        NO-UNDO.
    DEFINE INPUT        PARAMETER par_cdbccxlt AS INT        NO-UNDO.
    DEFINE INPUT        PARAMETER par_nrdolote AS INT        NO-UNDO.
    DEFINE INPUT        PARAMETER par_qttotreg AS INT        NO-UNDO.
    DEFINE INPUT        PARAMETER par_vltotreg AS DEC        NO-UNDO.
    /* dados do cheque arquivo */
    DEFINE INPUT        PARAMETER par_cdagechq AS INTEGER    NO-UNDO.
    DEFINE INPUT        PARAMETER par_cdbanchq AS INTEGER    NO-UNDO.
    DEFINE INPUT        PARAMETER par_cdcmpchq AS INTEGER    NO-UNDO.
    DEFINE INPUT        PARAMETER par_dsdocmc7 AS CHARACTER  NO-UNDO.
    DEFINE INPUT        PARAMETER par_dtlibera AS DATE       NO-UNDO.
    DEFINE INPUT        PARAMETER par_nrctachq AS INTEGER    NO-UNDO.
    DEFINE INPUT        PARAMETER par_nrdconta AS INTEGER    NO-UNDO.
    DEFINE INPUT        PARAMETER par_nrddigc1 AS INTEGER    NO-UNDO.
    DEFINE INPUT        PARAMETER par_nrddigc2 AS INTEGER    NO-UNDO.
    DEFINE INPUT        PARAMETER par_nrddigc3 AS INTEGER    NO-UNDO.
    DEFINE INPUT        PARAMETER par_nrcheque AS INTEGER    NO-UNDO.
    DEFINE INPUT        PARAMETER par_nrseqdig AS INTEGER    NO-UNDO.
    DEFINE INPUT        PARAMETER par_vlcheque AS DECIMAL    NO-UNDO.
    DEFINE INPUT        PARAMETER par_corrente AS INTEGER    NO-UNDO.
    DEFINE INPUT        PARAMETER par_inchqcop AS INTEGER    NO-UNDO.

    DEFINE OUTPUT       PARAMETER par_dscritic AS CHAR       NO-UNDO.
    
    DEFINE VARIABLE i-tot-lanc   AS INTEGER                  NO-UNDO.
    DEFINE VARIABLE d-val-lanc   AS DECIMAL                  NO-UNDO.
    DEFINE VARIABLE aux_dscalcul AS CHAR                     NO-UNDO.
    DEFINE VARIABLE h-b1wgen9998 AS HANDLE                   NO-UNDO.
    DEFINE VARIABLE aux_nrdocmto AS INTEGER                  NO-UNDO.
    DEFINE VARIABLE tab_vlchqmai AS DECIMAL                  NO-UNDO. 
    DEFINE VARIABLE aux_dsdestin AS CHAR                     NO-UNDO. 

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".
    
    EMPTY TEMP-TABLE tt-erro.

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR. 

    ASSIGN aux_dsdestin = "/usr/coop/" + crapcop.dsdircop + "/salvar/".

    RUN sistema/generico/procedures/b1wgen9998.p PERSISTENT SET h-b1wgen9998.

    IF   NOT VALID-HANDLE(h-b1wgen9998)  THEN
         DO:
             ASSIGN par_dscritic = "Handle invalido para h-b1wgen9998.".
             RETURN "NOK".
         END.

    DO TRANSACTION ON ERROR UNDO, RETURN "NOK":
         
        /* Verifica se o lote ja foi criado, pois a criacao eh feita
           registro por registro */
        FIND craplot WHERE craplot.cdcooper = par_cdcooper  AND
                           craplot.dtmvtolt = par_dtmvtolt  AND
                           craplot.cdagenci = par_cdagenci  AND
                           craplot.cdbccxlt = par_cdbccxlt  AND
                           craplot.nrdolote = par_nrdolote
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF  NOT AVAILABLE craplot   THEN
            DO:
                CREATE craplot.
                ASSIGN craplot.cdcooper = par_cdcooper
                       craplot.dtmvtolt = par_dtmvtolt 
                       craplot.cdagenci = par_cdagenci   
                       craplot.cdbccxlt = par_cdbccxlt 
                       craplot.nrdolote = par_nrdolote 
                       craplot.tplotmov = 19            
                       craplot.qtinfoln = par_qttotreg
                       craplot.vlinfodb = par_vltotreg
                       craplot.vlinfocr = par_vltotreg
                       craplot.cdoperad = par_cdoperad   
                       craplot.dtmvtopg = par_dtmvtolt.
                VALIDATE craplot.
            END.
        
        CREATE crapcst.
        ASSIGN crapcst.cdagechq = par_cdagechq  
               crapcst.cdagenci = par_cdagenci   
               crapcst.cdbanchq = par_cdbanchq  
               crapcst.cdbccxlt = par_cdbccxlt  
               crapcst.cdcmpchq = par_cdcmpchq   
               crapcst.cdopedev = ""                    
               crapcst.cdoperad = par_cdoperad          
               crapcst.dsdocmc7 = par_dsdocmc7   
               crapcst.dtdevolu = ?                     
               crapcst.dtlibera = par_dtlibera   
               crapcst.dtmvtolt = par_dtmvtolt   
               crapcst.insitchq = 0                     
               crapcst.nrctachq = par_nrctachq   
               crapcst.nrdconta = par_nrdconta   
               crapcst.nrddigc1 = par_nrddigc1   
               crapcst.nrddigc2 = par_nrddigc2   
               crapcst.nrddigc3 = par_nrddigc3   
               crapcst.nrcheque = par_nrcheque  
               crapcst.nrdolote = par_nrdolote   
               crapcst.nrseqdig = par_nrseqdig
               crapcst.vlcheque = par_vlcheque
               crapcst.cdcooper = par_cdcooper
               /* Inicio - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */
               crapcst.cdopeori = par_cdoperad
               crapcst.cdageori = par_cdagenci
               crapcst.dtinsori = TODAY
               /* Fim - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */
               crapcst.inchqcop = IF par_corrente > 0 
                                  THEN 1
                                  ELSE 0
               craplot.qtcompln = craplot.qtcompln + 1
               craplot.vlcompdb = craplot.vlcompdb + par_vlcheque
               craplot.vlcompcr = craplot.vlcompcr + par_vlcheque
               craplot.nrseqdig = crapcst.nrseqdig
               aux_nrdocmto = INT(STRING(crapcst.nrcheque,"999999") +
                                  STRING(crapcst.nrddigc3,"9")).
        VALIDATE crapcst.

        /* Le tabela com o valor dos cheques maiores  */
                    
        FIND craptab WHERE craptab.cdcooper = par_cdcooper   AND 
                           craptab.nmsistem = "CRED"         AND
                           craptab.tptabela = "USUARI"       AND
                           craptab.cdempres = 11             AND
                           craptab.cdacesso = "MAIORESCHQ"   AND
                           craptab.tpregist = 1 NO-LOCK NO-ERROR.
                               
        IF  NOT AVAILABLE craptab   THEN
            tab_vlchqmai = 1.
        ELSE
            tab_vlchqmai = DECIMAL(SUBSTRING(craptab.dstextab,01,15)).
         
        IF  crapcst.inchqcop = 1 THEN
            ASSIGN craplot.qtcompcc = craplot.qtcompcc + 1
                   craplot.vlcompcc = craplot.vlcompcc + 
                                      par_vlcheque.
        ELSE
            IF par_vlcheque < tab_vlchqmai THEN
                ASSIGN craplot.qtcompci = craplot.qtcompci + 1
                       craplot.vlcompci = craplot.vlcompci + 
                                          par_vlcheque.
            ELSE
                ASSIGN craplot.qtcompcs = craplot.qtcompcs + 1
                       craplot.vlcompcs = craplot.vlcompcs + 
                                          par_vlcheque.
        
        IF   par_corrente > 0   AND   
             par_inchqcop = 1   THEN /* Cheque Cooperativa */
             DO:
                 ASSIGN aux_dscalcul = "".
                 
                 RUN dig_bbx IN h-b1wgen9998 (INPUT par_cdcooper,
                                              INPUT par_cdagenci,
                                              INPUT 0,
                                              INPUT crapcst.nrctachq,
                                              OUTPUT aux_dscalcul,
                                              OUTPUT TABLE tt-erro).
                 
                 CREATE craplau.
                 ASSIGN craplau.dtmvtolt = crapcst.dtmvtolt
                        craplau.cdagenci = crapcst.cdagenci
                        craplau.cdbccxlt = crapcst.cdbccxlt
                        craplau.nrdolote = crapcst.nrdolote
                        craplau.nrdconta = par_corrente
                        craplau.nrdocmto = aux_nrdocmto
                        craplau.vllanaut = crapcst.vlcheque
                        craplau.cdhistor = 21
                        craplau.nrseqdig = crapcst.nrseqdig
                        craplau.nrdctabb = crapcst.nrctachq
                        craplau.nrdctitg = aux_dscalcul
                        craplau.cdbccxpg = 011
                        craplau.dtmvtopg = crapcst.dtlibera    
                        craplau.tpdvalor = 1
                        craplau.insitlau = 1
                        craplau.cdcritic = 0
                        craplau.nrcrcard = 0
                        craplau.nrseqlan = 0
                        craplau.dtdebito = ?
                        craplau.cdcooper = par_cdcooper
                        craplau.cdseqtel = STRING(crapcst.dtmvtolt,
                                           "99/99/9999") + " " +
                                           STRING(crapcst.cdagenci,
                                           "999") + " " +
                                           STRING(crapcst.cdbccxlt,
                                           "999") + " " +
                                           STRING(crapcst.nrdolote,
                                           "999999") + " " +
                                           STRING(crapcst.cdcmpchq,
                                           "999") + " " +
                                           STRING(crapcst.cdbanchq,
                                           "999") + " " +
                                           STRING(crapcst.cdagechq,
                                           "9999") + " " +
                                           STRING(crapcst.nrctachq,
                                           "99999999") + " " +
                                           STRING(crapcst.nrcheque,
                                           "999999").
                 VALIDATE craplau.
             
             END.
        
         DELETE PROCEDURE h-b1wgen9998.

    END.
    
    /* Move arquivo para o salvar com nr da conta e o TIME */
    UNIX SILENT VALUE("mv " + par_nmarqint + " " + aux_dsdestin 
                      + SUBSTRING(par_nmarqint,R-INDEX(par_nmarqint,"/") + 1,
                                  LENGTH(par_nmarqint) - 
                                  R-INDEX(par_nmarqint,"/"))
                      + "_" + STRING(par_nrdconta) + "_"
                      + STRING(TIME) + " 2> /dev/null").

    RETURN "OK".
    
END PROCEDURE.


PROCEDURE gera_erro_arq: 
    /*************************************************************************
    Objetivo: Gerar erros na temp-table para cada arquivo validado
    *************************************************************************/
    DEF INPUT PARAM par_dsdoerro   AS CHAR NO-UNDO.
    DEF INPUT PARAM par_flgderro   AS LOG  NO-UNDO.
    DEF INPUT PARAM par_nrdolote   AS INTE NO-UNDO.
    DEF INPUT PARAM par_c_cmc7_ori AS CHAR NO-UNDO.
    
    DEFINE VARIABLE aux_seqarqui AS INTEGER     NO-UNDO.

    ASSIGN aux_seqarqui = 1.               

    FIND LAST tt-erros-arq NO-ERROR.

    IF  AVAIL tt-erros-arq   THEN 
        ASSIGN aux_seqarqui = tt-erros-arq.nrsequen + 1.
                                                   
    CREATE tt-erros-arq.
    ASSIGN tt-erros-arq.nrsequen   = aux_seqarqui
           tt-erros-arq.dsdoerro   = par_dsdoerro
           tt-erros-arq.flgderro   = par_flgderro
           tt-erros-arq.nrdolote   = par_nrdolote
           tt-erros-arq.c-cmc7-ori = par_c_cmc7_ori.

END PROCEDURE. /* gera_erro_arquivo */


/* Validar os dados do cheque - baseado na procedure ver_cheque da 
                                includes/proc_lancst.i */
PROCEDURE ver_cheque:

    DEFINE INPUT        PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT        PARAMETER par_cdagenci AS INTEGER     NO-UNDO.
    DEFINE INPUT        PARAMETER par_nrdcaixa AS INTEGER     NO-UNDO.
    DEFINE INPUT        PARAMETER par_nrcustod AS INTEGER     NO-UNDO.
    DEFINE INPUT        PARAMETER par_nrctachq AS INTEGER     NO-UNDO.
    DEFINE INPUT        PARAMETER par_nrcheque AS INTEGER     NO-UNDO.
    DEFINE INPUT        PARAMETER par_nrddigc3 AS INTEGER     NO-UNDO.
    DEFINE INPUT        PARAMETER par_cdbanchq AS INTEGER     NO-UNDO.
    DEFINE INPUT        PARAMETER par_cdagechq AS INTEGER     NO-UNDO.
    DEFINE INPUT        PARAMETER par_vlcheque AS DECIMAL     NO-UNDO.
    /* conta corrente do cheque */
    DEFINE OUTPUT       PARAMETER opt_corrente AS INTEGER     NO-UNDO.
    DEFINE OUTPUT       PARAMETER opt_dsdctitg AS CHARACTER   NO-UNDO.
    DEFINE OUTPUT       PARAMETER opt_nrchqsdv AS INTEGER     NO-UNDO.
    DEFINE OUTPUT       PARAMETER opt_nrchqcdv AS INTEGER     NO-UNDO.
    DEFINE OUTPUT       PARAMETER TABLE FOR tt-erro.

    /* variaveis internas */
    DEFINE VARIABLE aux_nrdctitg AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE aux_nrctaass AS INTEGER     NO-UNDO.
    DEFINE VARIABLE aux_nrdconta AS INTEGER     NO-UNDO.
    DEFINE VARIABLE aux_nrdctabb AS INTEGER     NO-UNDO.
    DEFINE VARIABLE aux_nrtalchq AS INTEGER     NO-UNDO.
    DEFINE VARIABLE aux_nrdocmto AS INTEGER     NO-UNDO.
    
    DEFINE VARIABLE h-b1wgen9998 AS HANDLE      NO-UNDO.
    
    DEFINE VARIABLE aux_lscontas AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE aux_lsconta1 AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE aux_lsconta2 AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE aux_lsconta3 AS CHARACTER   NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_cdcritic = 0
           aux_nrdconta = 0
           aux_nrdctabb = 0
           aux_nrtalchq = 0
           aux_nrdocmto = INT(STRING(par_nrcheque,"999999") +
                              STRING(par_nrddigc3,"9")).
    
    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
    
    IF   NOT AVAILABLE crapcop   THEN
         DO:
             ASSIGN aux_cdcritic = 651
                    aux_dscritic = "".
            
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).        
                 
             RETURN "NOK".
         END.
    
    /*** Verifica a existencia de conta de integracao ***/
    RUN sistema/generico/procedures/b1wgen9998.p PERSISTENT SET h-b1wgen9998.

    IF   NOT VALID-HANDLE(h-b1wgen9998)  THEN
         DO:
             ASSIGN aux_cdcritic = 0
                    aux_dscritic = "Handle invalido para h-b1wgen9998.".   
            
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).        
                 
             RETURN "NOK".
         END.

    RUN existe_conta_integracao IN h-b1wgen9998 (INPUT  par_cdcooper,
                                                 INPUT  par_nrctachq,
                                                 OUTPUT aux_nrdctitg,
                                                 OUTPUT aux_nrctaass).
    /*** FIM - Verifica a existencia de conta de integracao ***/
    
    IF   (par_cdbanchq = 1   AND
          par_cdagechq = 3420)   OR
         
         /** Conta Integracao **/

         (aux_nrdctitg <> "" AND
         CAN-DO("3420", STRING(par_cdagechq)))  THEN
         DO:

              RUN dig_bbx IN h-b1wgen9998 (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT par_nrctachq,
                                           OUTPUT opt_dsdctitg,
                                           OUTPUT TABLE tt-erro).
              
              DELETE PROCEDURE h-b1wgen9998.

              IF  RETURN-VALUE <> "OK"  THEN
                  RETURN "NOK".

              ASSIGN opt_nrchqsdv = par_nrcheque
                     opt_nrchqcdv = aux_nrdocmto.

              /* BUSCAR CONTAS CONVENIO */
              /*  Le tabela com as contas convenio do Banco do Brasil - Geral  */

              RUN fontes/ver_ctace.p(INPUT par_cdcooper,
                                     INPUT 0,
                                     OUTPUT aux_lscontas).
              
              /*  Le tabela com as contas convenio do Banco do Brasil - talao normal */
              
              RUN fontes/ver_ctace.p(INPUT par_cdcooper,
                                     INPUT 1,
                                     OUTPUT aux_lsconta1).
              
              /*  Le tabela com as contas convenio do Banco do Brasil - talao transf.*/
              
             RUN fontes/ver_ctace.p(INPUT par_cdcooper,
                                    INPUT 2,
                                    OUTPUT aux_lsconta2).
              
              /*  Le tabela com as contas convenio do Banco do Brasil - chq.salario */
              
              RUN fontes/ver_ctace.p(INPUT par_cdcooper,
                                     INPUT 3,
                                     OUTPUT aux_lsconta3).
              
              /* FIM - BUSCAR CONTAS CONVENIO */
              
              IF   CAN-DO(aux_lsconta1,STRING(par_nrctachq))   OR
                  /** Conta Integracao **/
                  (aux_nrdctitg <> "" AND
                  CAN-DO("3420", STRING(par_cdagechq)))  THEN
                  DO:
                      FIND crapfdc WHERE crapfdc.cdcooper = par_cdcooper AND
                                         crapfdc.cdbanchq = par_cdbanchq AND
                                         crapfdc.cdagechq = par_cdagechq AND
                                         crapfdc.nrctachq = par_nrctachq AND
                                         crapfdc.nrcheque = opt_nrchqsdv
                                         USE-INDEX crapfdc1 NO-LOCK NO-ERROR.
                      
                      IF   NOT AVAILABLE crapfdc  THEN
                           DO:
                              ASSIGN aux_cdcritic = 108
                                     aux_dscritic = "".   
                              
                              RUN gera_erro (INPUT par_cdcooper,
                                             INPUT par_cdagenci,
                                             INPUT par_nrdcaixa,
                                             INPUT 1,            /** Sequencia **/
                                             INPUT aux_cdcritic,
                                             INPUT-OUTPUT aux_dscritic).        
                                  
                              RETURN "NOK".
                           END.

                      ASSIGN aux_nrdconta = crapfdc.nrdconta
                             aux_nrdctabb = crapfdc.nrdctabb.
                           
                      IF   crapfdc.dtemschq = ?   THEN
                           DO:
                              ASSIGN aux_cdcritic = 108
                                     aux_dscritic = "".   
    
                              RUN gera_erro (INPUT par_cdcooper,
                                             INPUT par_cdagenci,
                                             INPUT par_nrdcaixa,
                                             INPUT 1,            /** Sequencia **/
                                             INPUT aux_cdcritic,
                                             INPUT-OUTPUT aux_dscritic).        
    
                              RETURN "NOK".
                           END.

                      IF   crapfdc.dtretchq = ?   THEN
                           DO:
                              ASSIGN aux_cdcritic = 109
                                     aux_dscritic = "".   
    
                              RUN gera_erro (INPUT par_cdcooper,
                                             INPUT par_cdagenci,
                                             INPUT par_nrdcaixa,
                                             INPUT 1,            /** Sequencia **/
                                             INPUT aux_cdcritic,
                                             INPUT-OUTPUT aux_dscritic).        
    
                              RETURN "NOK".
                           END.
                      
                      IF   crapfdc.incheque <> 0  THEN
                           DO:
                               IF   crapfdc.incheque = 1   THEN
                                    aux_cdcritic = 96.
                               ELSE
                               IF   crapfdc.incheque = 2   THEN
                               DO:
                                   RUN contra_ordem(INPUT par_cdcooper,
                                                    INPUT par_cdbanchq,
                                                    INPUT par_cdagechq,
                                                    INPUT par_nrctachq,
                                                    INPUT opt_nrchqcdv,
                                                    INPUT crapfdc.incheque,
                                                    OUTPUT TABLE tt-erro).

                                   IF  RETURN-VALUE <> "OK" THEN
                                       RETURN "NOK".
                               END.
                               ELSE
                               IF   crapfdc.incheque = 5   THEN
                                    aux_cdcritic = 97.
                               ELSE
                               IF   crapfdc.incheque = 8   THEN
                                    aux_cdcritic = 320.
                               ELSE
                                    aux_cdcritic = 1000.
                                    
                               ASSIGN aux_dscritic = "".   

                               RUN gera_erro (INPUT par_cdcooper,
                                              INPUT par_cdagenci,
                                              INPUT par_nrdcaixa,
                                              INPUT 1,            /** Sequencia **/
                                              INPUT aux_cdcritic,
                                              INPUT-OUTPUT aux_dscritic).        

                               RETURN "NOK".

                           END.
                  END.
             ELSE
             IF   CAN-DO(aux_lsconta2,STRING(par_nrctachq))   THEN
                  DO:
                      ASSIGN aux_cdcritic = 646.           /*  CHEQUE TB  */
                             aux_dscritic = "".   

                      RUN gera_erro (INPUT par_cdcooper,
                                     INPUT par_cdagenci,
                                     INPUT par_nrdcaixa,
                                     INPUT 1,            /** Sequencia **/
                                     INPUT aux_cdcritic,
                                     INPUT-OUTPUT aux_dscritic).        

                      RETURN "NOK".
                  END.
             ELSE
             IF   CAN-DO(aux_lsconta3,STRING(par_nrctachq))   THEN
                  DO:
                      FIND crapfdc WHERE crapfdc.cdcooper = par_cdcooper AND
                                         crapfdc.cdbanchq = par_cdbanchq AND
                                         crapfdc.cdagechq = par_cdagechq AND
                                         crapfdc.nrctachq = par_nrctachq AND
                                         crapfdc.nrcheque = opt_nrchqsdv
                                         USE-INDEX crapfdc1 NO-LOCK NO-ERROR.

                      IF   NOT AVAILABLE crapfdc   THEN
                           DO:
                               ASSIGN aux_cdcritic = 286.
                                      aux_dscritic = "".   

                               RUN gera_erro (INPUT par_cdcooper,
                                              INPUT par_cdagenci,
                                              INPUT par_nrdcaixa,
                                              INPUT 1,            /** Sequencia **/
                                              INPUT aux_cdcritic,
                                              INPUT-OUTPUT aux_dscritic).        
        
                               RETURN "NOK".
                           END.

                      IF   crapfdc.vlcheque = par_vlcheque   THEN
                           DO:
                               ASSIGN aux_nrdconta = crapfdc.nrdconta
                                      aux_nrdctabb = crapfdc.nrdctabb.
                                    
                               IF   crapfdc.incheque <> 0   THEN
                                    DO:
                                        IF   crapfdc.incheque = 1   THEN
                                             aux_cdcritic = 96.
                                        ELSE
                                        IF   crapfdc.incheque = 2   THEN
                                        DO:
                                            RUN contra_ordem(INPUT par_cdcooper,
                                                             INPUT par_cdbanchq,
                                                             INPUT par_cdagechq,
                                                             INPUT par_nrctachq,
                                                             INPUT opt_nrchqcdv,
                                                             INPUT crapfdc.incheque,
                                                             OUTPUT TABLE tt-erro).

                                            IF  RETURN-VALUE <> "OK" THEN
                                                RETURN "NOK".
                                        END.
                                        ELSE
                                        IF   crapfdc.incheque = 5   THEN
                                             aux_cdcritic = 97.
                                        ELSE
                                        IF   crapfdc.incheque = 8   THEN
                                             aux_cdcritic = 320.
                                        ELSE
                                             aux_cdcritic = 1000.
                                    
                                        ASSIGN aux_dscritic = "".   

                                        RUN gera_erro (INPUT par_cdcooper,
                                                       INPUT par_cdagenci,
                                                       INPUT par_nrdcaixa,
                                                       INPUT 1,            /** Sequencia **/
                                                       INPUT aux_cdcritic,
                                                       INPUT-OUTPUT aux_dscritic).        

                                        RETURN "NOK".

                                    END.
                           END.
                      ELSE
                           DO:
                               ASSIGN aux_cdcritic = 91
                                      aux_dscritic = "".

                               RUN gera_erro (INPUT par_cdcooper,
                                              INPUT par_cdagenci,
                                              INPUT par_nrdcaixa,
                                              INPUT 1,            /** Sequencia **/
                                              INPUT aux_cdcritic,
                                              INPUT-OUTPUT aux_dscritic).        

                               RETURN "NOK".
                           END.
                  END.
             ELSE
                  RETURN "OK".      /*  Qualquer outra conta da agencia 95/3420  */
                  
             RUN ver_associado(INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT aux_nrdconta,
                               OUTPUT TABLE tt-erro).
             
             IF  RETURN-VALUE <> "OK"  THEN
                 RETURN "NOK".

         END.
    ELSE
    IF  (par_cdbanchq = 756           AND  
         par_cdagechq = crapcop.cdagebcb)  
        OR
        (par_cdbanchq = crapcop.cdbcoctl  AND  
         par_cdagechq = crapcop.cdagectl)  THEN
         DO:
             ASSIGN opt_nrchqsdv = par_nrcheque
                    opt_nrchqcdv = aux_nrdocmto
                    aux_nrdconta = INT(par_nrctachq).
                      
             RUN ver_associado(INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT aux_nrdconta,
                               OUTPUT TABLE tt-erro).

             IF  RETURN-VALUE <> "OK"  THEN
                 RETURN "NOK".
                      
             par_nrctachq = aux_nrdconta.
             
             RUN dig_bbx IN h-b1wgen9998 (INPUT par_cdcooper,
                                          INPUT par_cdagenci,
                                          INPUT par_nrdcaixa,
                                          INPUT par_nrctachq,
                                          OUTPUT opt_dsdctitg,
                                          OUTPUT TABLE tt-erro).

             DELETE PROCEDURE h-b1wgen9998.

             IF  RETURN-VALUE <> "OK"  THEN
                 RETURN "NOK".
             
             FIND crapfdc WHERE crapfdc.cdcooper = par_cdcooper AND
                                crapfdc.cdbanchq = par_cdbanchq AND
                                crapfdc.cdagechq = par_cdagechq AND
                                crapfdc.nrctachq = par_nrctachq AND
                                crapfdc.nrcheque = opt_nrchqsdv
                                USE-INDEX crapfdc1 NO-LOCK NO-ERROR.
             
             IF   NOT AVAILABLE crapfdc  THEN
                  DO:
                     ASSIGN aux_cdcritic = 108
                            aux_dscritic = "".   
    
                     RUN gera_erro (INPUT par_cdcooper,
                                    INPUT par_cdagenci,
                                    INPUT par_nrdcaixa,
                                    INPUT 1,            /** Sequencia **/
                                    INPUT aux_cdcritic,
                                    INPUT-OUTPUT aux_dscritic).        
    
                     RETURN "NOK".
                  END.
              
             ASSIGN aux_nrdctabb = crapfdc.nrdctabb.
             
             IF   crapfdc.dtemschq = ?   THEN
                  DO:
                     ASSIGN aux_cdcritic = 108
                            aux_dscritic = "".   
        
                     RUN gera_erro (INPUT par_cdcooper,
                                    INPUT par_cdagenci,
                                    INPUT par_nrdcaixa,
                                    INPUT 1,            /** Sequencia **/
                                    INPUT aux_cdcritic,
                                    INPUT-OUTPUT aux_dscritic).        
        
                     RETURN "NOK".
                  END.

             IF   crapfdc.dtretchq = ?   THEN
                  DO:
                     ASSIGN aux_cdcritic = 109
                            aux_dscritic = "".   
    
                     RUN gera_erro (INPUT par_cdcooper,
                                    INPUT par_cdagenci,
                                    INPUT par_nrdcaixa,
                                    INPUT 1,            /** Sequencia **/
                                    INPUT aux_cdcritic,
                                    INPUT-OUTPUT aux_dscritic).        
    
                     RETURN "NOK".
                  END.
                   
             IF   crapfdc.incheque <> 0   THEN
                  DO:
                      IF   crapfdc.incheque = 1   THEN
                           aux_cdcritic = 96.
                      ELSE
                      IF   crapfdc.incheque = 2   THEN
                      DO:
                          RUN contra_ordem(INPUT par_cdcooper,
                                           INPUT par_cdbanchq,
                                           INPUT par_cdagechq,
                                           INPUT par_nrctachq,
                                           INPUT opt_nrchqcdv,
                                           INPUT crapfdc.incheque,
                                           OUTPUT TABLE tt-erro).

                          IF  RETURN-VALUE <> "OK" THEN
                              RETURN "NOK".

                      END.
                      ELSE
                      IF   crapfdc.incheque = 5   THEN
                           aux_cdcritic = 97.
                      ELSE
                      IF   crapfdc.incheque = 8   THEN
                           aux_cdcritic = 320.
                      ELSE
                           aux_cdcritic = 1000.
                                    
                       ASSIGN aux_dscritic = "".   

                       RUN gera_erro (INPUT par_cdcooper,
                                      INPUT par_cdagenci,
                                      INPUT par_nrdcaixa,
                                      INPUT 1,            /** Sequencia **/
                                      INPUT aux_cdcritic,
                                      INPUT-OUTPUT aux_dscritic).        

                       RETURN "NOK".

                  END.
         END.
    
    /* nao permitir cheque do cooperado */     
    IF  par_nrcustod = aux_nrdconta  THEN
        DO:
            ASSIGN aux_cdcritic = 121
                   aux_dscritic = "".   

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).        

             RETURN "NOK".

        END.

    ASSIGN opt_corrente = aux_nrdconta.

    RETURN "OK".

END PROCEDURE.

/*
Procedure para verificar se o cheque tem contra-ordem
baseado na procedure contra_ordem da includes/proc_lancst.i
*/
PROCEDURE contra_ordem PRIVATE:

    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdbanchq AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagechq AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrctachq AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrchqcdv AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_incheque AS INTEGER     NO-UNDO.  
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    IF  par_incheque = 1   OR
        par_incheque = 2   THEN
        DO:
            FIND crapcor WHERE crapcor.cdcooper = par_cdcooper   AND
                               crapcor.cdbanchq = par_cdbanchq   AND
                               crapcor.cdagechq = par_cdagechq   AND
                               crapcor.nrctachq = par_nrctachq   AND
                               crapcor.nrcheque = par_nrchqcdv   AND
                               crapcor.flgativo = TRUE
                               NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE crapcor   THEN
                DO:
                    ASSIGN aux_cdcritic = 101
                           aux_dscritic = "".   
     
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).        
     
                    RETURN "NOK".
                END.

            FIND craphis WHERE craphis.cdcooper = par_cdcooper AND
                               craphis.cdhistor = crapcor.cdhistor
                               NO-LOCK NO-ERROR.

            IF   NOT AVAILABLE craphis   THEN
                 aux_dscritic = FILL("*",50).
            ELSE
                 aux_dscritic = craphis.dshistor.
            
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Aviso de " + STRING(crapcor.dtemscor,"99/99/9999") 
                                  + " ->" + aux_dscritic.
        
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).        
    
            RETURN "NOK".
                
        END.
    
     RETURN "OK".

END PROCEDURE.


/* Validar os dados do cheque - baseado na procedure ver_associado da 
                                includes/proc_lancst.i */
PROCEDURE ver_associado PRIVATE:

    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdconta AS INTEGER     NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    IF   par_nrdconta > 0   THEN
         DO WHILE TRUE:
    
            FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                               crapass.nrdconta = par_nrdconta  
                               NO-LOCK NO-ERROR NO-WAIT.

            IF   NOT AVAILABLE crapass   THEN
                 DO:
                     ASSIGN aux_cdcritic = 9
                            aux_dscritic = "".

                     RUN gera_erro (INPUT par_cdcooper,
                                    INPUT par_cdagenci,
                                    INPUT par_nrdcaixa,
                                    INPUT 1,            /** Sequencia **/
                                    INPUT aux_cdcritic,
                                    INPUT-OUTPUT aux_dscritic).        
        
                     RETURN "NOK".
                 END.
 
            IF   CAN-DO("5,6,7,8",STRING(crapass.cdsitdtl))   THEN
                 DO:
                    ASSIGN aux_cdcritic = 695
                           aux_dscritic = "".
    
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).        
    
                    RETURN "NOK".
                 END.

            IF   CAN-DO("2,4,6,8",STRING(crapass.cdsitdtl))   THEN
                 DO:
                     FIND FIRST craptrf WHERE
                                craptrf.cdcooper = par_cdcooper     AND 
                                craptrf.nrdconta = crapass.nrdconta AND
                                craptrf.tptransa = 1 
                                USE-INDEX craptrf1 NO-LOCK NO-ERROR.

                     IF   NOT AVAILABLE craptrf THEN
                          DO:
                             ASSIGN aux_cdcritic = 95
                                    aux_dscritic = "".
    
                             RUN gera_erro (INPUT par_cdcooper,
                                            INPUT par_cdagenci,
                                            INPUT par_nrdcaixa,
                                            INPUT 1,            /** Sequencia **/
                                            INPUT aux_cdcritic,
                                            INPUT-OUTPUT aux_dscritic).        
    
                             RETURN "NOK".
                          END.
                          
                     RUN gera_erro_arq (INPUT "Conta transferida de " +
                                              STRING(craptrf.nrdconta,"zzzz,zzz,9") +
                                              " para " +
                                              STRING(craptrf.nrsconta,"zzzz,zzz,9"),
                                        INPUT FALSE,
                                        INPUT 0,
                                        INPUT "").
                     
                     ASSIGN par_nrdconta = craptrf.nrsconta.
                     
                     NEXT. 
                 END.

            IF   crapass.dtelimin <> ? THEN
                 DO:
                    ASSIGN aux_cdcritic = 410
                           aux_dscritic = "".
    
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).        
    
                    RETURN "NOK".
                 END.
          
            LEAVE.

         END.  /*  Fim do DO WHILE TRUE  */

END PROCEDURE.
