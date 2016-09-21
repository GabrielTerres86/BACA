/* .............................................................................

   Programa: Fontes/desconto_titulos.p
   Sistema : Conta-Corrente - Cooperativa 
   Sigla   : CRED
   Autor   : Guilherme
   Data    : Agosto/2008                         Ultima atualizacao: 09/07/2012

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para tratar descontos de titulos para a tela ATENDA.

   Alteracoes: 15/05/2009 - Incluir parametros para LOG (Guilherme).
    
               09/07/2012 - Inclusão de campos no form para listagem de 
                            informações de títulos descontados com e sem
                            registro (Lucas).
                            
............................................................................. */

{ includes/var_online.i }
{ includes/var_atenda.i }

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0030tt.i }
DEF VAR h-b1wgen0001 AS HANDLE                                       NO-UNDO.
DEF VAR h-b1wgen0030 AS HANDLE                                       NO-UNDO.
DEF STREAM str_1.

DEF VAR tel_dsborder AS CHAR    FORMAT "x(8)" INIT "Borderos"        NO-UNDO.
DEF VAR tel_dslimite AS CHAR    FORMAT "x(6)" INIT "Limite"          NO-UNDO.

DEF VAR tel_vllimite AS DECI                                         NO-UNDO.
DEF VAR tel_nrctrlim AS INT                                          NO-UNDO.
DEF VAR tel_qtdiavig AS INT                                          NO-UNDO.

DEF VAR tel_vlalugue AS DECI                                         NO-UNDO.
DEF VAR tel_vloutras AS DECI                                         NO-UNDO.
DEF VAR tel_vlsalari AS DECI                                         NO-UNDO.
DEF VAR tel_vlsalcon AS DECI                                         NO-UNDO.
DEF VAR tel_dsobserv AS CHAR                                         NO-UNDO.

DEF VAR tel_qtrenova AS INT                                          NO-UNDO.

DEF VAR tel_nrctrpro AS INT                                          NO-UNDO.
DEF VAR tel_cdmotivo AS INT                                          NO-UNDO.
DEF VAR tel_dtinivig AS DATE                                         NO-UNDO.
DEF VAR tel_dtfimvig AS DATE                                         NO-UNDO.
DEF VAR tel_dsdlinha AS CHAR                                         NO-UNDO.
DEF VAR tel_cdldscto AS INT                                          NO-UNDO.
DEF VAR tel_vlfatura AS DECIMAL                                      NO-UNDO.
DEF VAR tel_txjurmor AS DECIMAL DECIMALS 7                           NO-UNDO.
DEF VAR tel_vldmulta AS DECIMAL                                      NO-UNDO.
DEF VAR tel_vlmedchq AS DECIMAL                                      NO-UNDO.
DEF VAR tel_dsramati AS CHAR                                         NO-UNDO.

DEF VAR opcao        AS INT                                          NO-UNDO.
DEF VAR reg_dsdopcao      AS CHAR    EXTENT 2 INIT ["Borderos","Limite"]  NO-UNDO.

DEF VAR tab_cddopcao AS CHAR    EXTENT 9 INIT ["B","L"]              NO-UNDO.

FORM SKIP(1)
     tel_nrctrlim AT  9 FORMAT " z,zzz,zz9"     LABEL "Contrato"
     tel_dtinivig AT 33 FORMAT "99/99/9999"     LABEL "Inicio"
     tel_qtdiavig AT 56 FORMAT "zz9"            LABEL "Vigencia"
     "dias"      
     SKIP(1)
     tel_vllimite AT 11 FORMAT "zzz,zzz,zz9.99" LABEL "Limite"
     tel_qtrenova AT 52 FORMAT "9" LABEL "Renovado por" "vezes"
     SKIP(1)
     tel_dsdlinha AT 10 FORMAT "x(40)"          LABEL "Linha de Descontos"
     SKIP(1)
     tt-desconto_titulos.vlutilcr AT 6 FORMAT "zzz,zzz,zz9.99" LABEL "Valor utilizado (Registrada)"
     "("                          AT 53
     tt-desconto_titulos.qtutilcr AT 60 FORMAT "zz,zz9" NO-LABEL
     "titulos)"
     tt-desconto_titulos.vlutilsr AT 4 FORMAT "zzz,zzz,zz9.99" LABEL "Valor utilizado (Sem Registro)"
     "("                          AT 53
     tt-desconto_titulos.qtutilsr AT 60 FORMAT "zz,zz9" NO-LABEL
     "titulos)"
     WITH ROW 9 CENTERED SIDE-LABELS NO-LABELS OVERLAY TITLE COLOR NORMAL
          " Desconto de Titulos " WIDTH  78 FRAME f_limite.

FORM SPACE(30)
     reg_dsdopcao[1] FORMAT "x(8)" 
     reg_dsdopcao[2] FORMAT "x(6)"
     SPACE(31)
     WITH ROW 20 CENTERED NO-BOX NO-LABELS OVERLAY FRAME f_opcoes.

HIDE MESSAGE NO-PAUSE.
   
RUN sistema/generico/procedures/b1wgen0030.p PERSISTENT SET h-b1wgen0030.

IF  VALID-HANDLE(h-b1wgen0030)  THEN
    DO:
        RUN busca_dados_dsctit IN h-b1wgen0030 
                                 (INPUT glb_cdcooper,
                                  INPUT 0, /*agenci*/
                                  INPUT 0, /*nrdcaixa*/
                                  INPUT glb_cdoperad,
                                  INPUT glb_dtmvtolt,
                                  INPUT 1, /*origem*/
                                  INPUT tel_nrdconta,
                                  INPUT 1, /*seqttl */
                                  INPUT glb_nmdatela,
                                  INPUT TRUE, /* LOG */
                                 OUTPUT TABLE tt-erro,
                                 OUTPUT TABLE tt-desconto_titulos).

        DELETE PROCEDURE h-b1wgen0030.
        
        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                IF  AVAIL tt-erro THEN
                    DO:
                        MESSAGE tt-erro.dscritic.
                        RETURN.
                    END.
                
            END.
    
    END.                             
ELSE
    DO:
        MESSAGE "Handle invalido para b1wgen0030.".
        RETURN.
    END.

FIND FIRST tt-desconto_titulos NO-LOCK NO-ERROR.

IF  AVAIL tt-desconto_titulos  THEN
    ASSIGN tel_nrctrlim = tt-desconto_titulos.nrctrlim
           tel_dtinivig = tt-desconto_titulos.dtinivig
           tel_qtdiavig = tt-desconto_titulos.qtdiavig
           tel_vllimite = tt-desconto_titulos.vllimite
           tel_qtrenova = tt-desconto_titulos.qtrenova
           tel_dsdlinha = tt-desconto_titulos.dsdlinha.

DISPLAY tel_nrctrlim     tel_dtinivig   tel_qtdiavig 
        tel_vllimite     tel_qtrenova   tel_dsdlinha
        tt-desconto_titulos.vlutilcr	tt-desconto_titulos.qtutilcr
        tt-desconto_titulos.vlutilsr	tt-desconto_titulos.qtutilsr
        WITH FRAME f_limite.

PAUSE 0.

ASSIGN opcao = tt-desconto_titulos.cddopcao.

DISPLAY reg_dsdopcao WITH FRAME f_opcoes.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
    DISPLAY reg_dsdopcao[1] reg_dsdopcao[2] 
            WITH FRAME f_opcoes.
            
    /* Escolhe a opcao desejada */
    IF  opcao = 1  THEN
        CHOOSE FIELD reg_dsdopcao[opcao] reg_dsdopcao[opcao + 1] 
                     WITH FRAME f_opcoes.
    ELSE
        CHOOSE FIELD reg_dsdopcao[opcao] reg_dsdopcao[opcao - 1] 
                     WITH FRAME f_opcoes.
                    
    /* Se escolher titulos */
    IF  FRAME-VALUE = reg_dsdopcao[1]  THEN
        DO:
            ASSIGN glb_nmrotina = "DSC TITS - BORDERO". 

            { includes/acesso.i }
            
            RUN fontes/dsctit_bordero.p.            
            
        END.         
    ELSE
    IF  FRAME-VALUE = reg_dsdopcao[2]  THEN
        DO:
            ASSIGN glb_nmrotina = "DSC TITS - LIMITE". 

            { includes/acesso.i }
            
            RUN fontes/dsctit_limite.p.
            
        END.

END. /* Final do DO WHILE */

HIDE FRAME f_opcoes NO-PAUSE.
HIDE FRAME f_limite NO-PAUSE.

HIDE MESSAGE NO-PAUSE.

/* .......................................................................... */
