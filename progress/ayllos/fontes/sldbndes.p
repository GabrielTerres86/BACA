/* ............................................................................
   Programa: Fontes/sldbndes.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Lucas R.
   Data    : Maio/2013.                          Ultima atualizacao: 21/01/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar opcao de BNDES para tela ATENDA.

   Alteracoes: 21/01/2015 - Alterado o formato do campo nrctremp para 8 
                            caracters (Kelvin - 233714)
   
............................................................................*/

{ sistema/generico/includes/b1wgen0147tt.i }
{ sistema/generico/includes/var_internet.i }
 
{ includes/var_online.i }
{ includes/var_atenda.i }

DEF VAR h-b1wgen0147 AS HANDLE                                      NO-UNDO.
                   
DEF VAR aux_query    AS CHAR                                        NO-UNDO.
DEF VAR aux_vlparepr AS DEC                                         NO-UNDO.
DEF VAR aux_vlsaldod AS DEC                                         NO-UNDO.

DEFINE QUERY q_workbnd FOR tt-saldo-devedor-bndes.

DEF BROWSE b_workbnd QUERY q_workbnd 
    DISP tt-saldo-devedor-bndes.dsdprodu COLUMN-LABEL "Produto"  FORMAT "x(10)"
         SPACE(8)
         tt-saldo-devedor-bndes.nrctremp COLUMN-LABEL "Contrato" 
                                         FORMAT "zz,zzz,zz9"
          SPACE(8)
         tt-saldo-devedor-bndes.vlropepr COLUMN-LABEL "Emprestado"  
                                         FORMAT "zzz,zzz,zzz,zz9.99"
         WITH 9 DOWN WIDTH 60 SCROLLBAR-VERTICAL.

DEF FRAME f_workbnd
          b_workbnd  
    HELP "Pressione <ENTER> p/ detalhes ou <SETAS> p/ outras informacoes "
    WITH NO-BOX CENTERED OVERLAY ROW 9 .

DEF FRAME f_bnd_det.

FORM SKIP(1)
     tt-saldo-devedor-bndes.dsdprodu AT 3  LABEL "Produto "
     tt-saldo-devedor-bndes.vlropepr AT 39 LABEL "Emprestado" 
     SKIP
     tt-saldo-devedor-bndes.nrctremp AT 3  LABEL "Contrato" FORMAT "zz,zzz,zz9"
     tt-saldo-devedor-bndes.vlparepr AT 39 LABEL "Prestacao "
     SKIP
     tt-saldo-devedor-bndes.vlsdeved AT 39 LABEL "Saldo     "
     SKIP
     tt-saldo-devedor-bndes.qtdmesca AT 3  LABEL "Carencia"
     SKIP                                  
     tt-saldo-devedor-bndes.percaren AT 3  LABEL "Periodicidade" 
     tt-saldo-devedor-bndes.dtinictr AT 39 LABEL "Dt. Contrato   "
     SKIP
     tt-saldo-devedor-bndes.dtlibera AT 39 LABEL "Dt. Liberacao  "
     SKIP
     tt-saldo-devedor-bndes.qtparctr AT 3  LABEL "Parcelas"
     tt-saldo-devedor-bndes.dtpricar AT 39 LABEL "Dt. 1ª Carencia"
     SKIP
     tt-saldo-devedor-bndes.perparce AT 3  LABEL "Periodicidade"
     tt-saldo-devedor-bndes.dtpripar AT 39 LABEL "Dt. 1ª Parcela "
     SKIP(2)
     WITH ROW 9 CENTERED NO-LABELS SIDE-LABELS OVERLAY FRAME f_bnd_det.

IF  NOT VALID-HANDLE(h-b1wgen0147) THEN
    RUN sistema/generico/procedures/b1wgen0147.p
        PERSISTEN SET h-b1wgen0147.

RUN dados_bndes IN h-b1wgen0147
               (INPUT glb_cdcooper,
                INPUT tel_nrdconta,
                OUTPUT aux_vlparepr,
                OUTPUT aux_vlsaldod,
                OUTPUT TABLE tt-saldo-devedor-bndes).

IF  RETURN-VALUE <> "OK" THEN
    RETURN.

DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:

    ON  ENTER OF b_workbnd IN FRAME f_workbnd DO:

        IF  NOT AVAILABLE tt-saldo-devedor-bndes THEN
            LEAVE.
       
        HIDE FRAME f_workbnd.
        HIDE MESSAGE NO-PAUSE.

        DISP tt-saldo-devedor-bndes.dsdprodu FORMAT "x(15)"
             tt-saldo-devedor-bndes.vlropepr
             tt-saldo-devedor-bndes.nrctremp
             tt-saldo-devedor-bndes.vlparepr
             tt-saldo-devedor-bndes.vlsdeved
             tt-saldo-devedor-bndes.qtdmesca
             tt-saldo-devedor-bndes.percaren FORMAT "x(15)"
             tt-saldo-devedor-bndes.dtinictr
             tt-saldo-devedor-bndes.dtpricar
             tt-saldo-devedor-bndes.qtparctr
             tt-saldo-devedor-bndes.dtlibera
             tt-saldo-devedor-bndes.perparce FORMAT "x(15)"
             tt-saldo-devedor-bndes.dtpripar
             WITH FRAME f_bnd_det. 
                                  
        ENABLE b_workbnd WITH FRAME f_workbnd.
        HIDE FRAME f_bnd_det.

    END.
    
    aux_query = "FOR EACH tt-saldo-devedor-bndes".
    QUERY q_workbnd:QUERY-CLOSE().
    QUERY q_workbnd:QUERY-PREPARE(aux_query).
    MESSAGE "Aguarde...".

    QUERY q_workbnd:QUERY-OPEN().

    HIDE MESSAGE NO-PAUSE.
    
    ENABLE b_workbnd WITH FRAME f_workbnd.

    WAIT-FOR END-ERROR OF DEFAULT-WINDOW.
    
    HIDE FRAME f_workbnd.
    HIDE FRAME f_bnd_det.

    HIDE MESSAGE NO-PAUSE.
    
    LEAVE.

END.    /*fim do DO WHILE TRUE*/
     
IF  VALID-HANDLE(h-b1wgen0147) THEN
    DELETE PROCEDURE h-b1wgen0147.
