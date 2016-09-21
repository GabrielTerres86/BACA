/* ............................................................................

   Programa: Fontes/protecao_credito.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Jonata (Rkam)
   Data    : Julho/2014                         Ultima Atualizacao: 12/01/2016

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado (on-line)
   Objetivo  : Orgaos de protecao ao credito.
               Projeto Automatização de Consultas em Propostas
               de Crédito/Limites (Jonata-RKAM).
                                                 
   Alteracoes:  06/05/2015 - Ajuste para o limite de credito (Gabriel-RKAM)
   
                11/08/2015 - Gravacao do novo campo indserma na tabela crapass
                             correspondente a tela CONTAS, OPCAO Conta Corrente                             
                             (Projeto 218 - Melhorias Tarifas (Carlos Rafael Tanholi)   
                             
                12/01/2016 - Incluida leitura do campo de assinatura conjunta. (Jean Michel)
                                          
                12/01/2016 - Removida flag flgcrdpa da chamada da BO74. (Anderson).

.............................................................................*/

DEF INPUT PARAM par_inpessoa AS INTE                                    NO-UNDO.

{ sistema/generico/includes/var_oracle.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/b1wgen0074tt.i }
{ sistema/generico/includes/b1wgen0191tt.i }

{ includes/var_online.i }
{ includes/var_contas.i } 
{ includes/var_protecao_credito.i }

DEF VAR aux_indserma    AS LOGICAL                                  NO-UNDO.
aux_indserma = FALSE.

VIEW FRAME f_moldura.
PAUSE 0.

RUN sistema/generico/procedures/b1wgen0191.p PERSISTENT SET h-b1wgen0191.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   RUN Busca_Dados.

   IF  RETURN-VALUE <> "OK" THEN
       NEXT.

   FIND FIRST tt-conta-corr NO-LOCK NO-ERROR.

   IF  AVAIL tt-conta-corr   THEN
       ASSIGN tel_dtcnsspc = tt-conta-corr.dtcnsspc
              tel_dtdsdspc = tt-conta-corr.dtdsdspc
              tel_dtdscore = tt-conta-corr.dtdscore
              tel_dsdscore = tt-conta-corr.dsdscore              
              tel_dsinacop = IF   tt-conta-corr.inadimpl = 0   THEN 
                                  "N" 
                             ELSE 
                                  "S".

   RUN Busca_Biro IN h-b1wgen0191
                  (INPUT glb_cdcooper,
                   INPUT tel_nrdconta,
                  OUTPUT aux_nrconbir,
                  OUTPUT aux_nrseqdet).

   IF  RETURN-VALUE <> "OK"   THEN
       LEAVE.

   RUN Busca_Situacao IN h-b1wgen0191 (INPUT aux_nrconbir,
                                       INPUT aux_nrseqdet,
                                      OUTPUT aux_cdbircon,
                                      OUTPUT aux_dsbircon,
                                      OUTPUT aux_cdmodbir,
                                      OUTPUT aux_dssituac,
                                      OUTPUT aux_dsmodbir).

   IF   RETURN-VALUE <> "OK"   THEN
        LEAVE.

   IF   aux_dssituac = ""   THEN
        aux_dssituac = "Sem consulta".

   ASSIGN tel_dsinaout = aux_dssituac.

   IF   aux_dsbircon = "Serasa" THEN      
        DISPLAY tel_dtcnsspc
                tel_dtdsdspc
                tel_dsinacop 
                tel_dsinaout  
                tel_dtdscore
                tel_dsdscore
                WITH FRAME f_protecao_serasa.
   ELSE 
        DISPLAY tel_dtcnsspc
                tel_dtdsdspc
                tel_dsinacop 
                tel_dsinaout  
                tel_dtdscore
                tel_dsdscore  
                WITH FRAME f_protecao_spc.

   DISPLAY tel_btnalter
           tel_btndetal 
           WITH FRAME f_botoes.

   IF  aux_nrconbir = 0   AND 
       aux_nrseqdet = 0   THEN
       DO:
           CHOOSE FIELD tel_btnalter WITH FRAME f_botoes.
       END.
   ELSE 
       DO:       
           CHOOSE FIELD tel_btnalter
                        tel_btndetal WITH FRAME f_botoes.
       END.

   IF   FRAME-VALUE = tel_btnalter   THEN
        DO:
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                IF   aux_dsbircon = "Serasa" THEN 
                     UPDATE tel_dtcnsspc
                            tel_dtdsdspc
                            tel_dsinacop WITH FRAME f_protecao_serasa.
                ELSE
                     UPDATE tel_dtcnsspc
                            tel_dtdsdspc
                            tel_dsinacop WITH FRAME f_protecao_spc.
                LEAVE.
            END.

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                 NEXT.

            RUN Valida_Dados.

            IF   RETURN-VALUE <> "OK"   THEN
                 NEXT.

            RUN fontes/confirma.p (INPUT "",
                                  OUTPUT aux_confirma).

            IF   aux_confirma <> "S"   THEN
                 NEXT.

            RUN Grava_Dados.

            IF   RETURN-VALUE <> "OK"   THEN
                 NEXT.

        END.
   ELSE
   IF   FRAME-VALUE = tel_btndetal   THEN
        DO:            
            ASSIGN aux_confirma = "T".
            
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
               MESSAGE "Deseja (I)mprimir ou visualizar em (T)ela ?" 
                       UPDATE aux_confirma.
               LEAVE.
            END.

            HIDE MESSAGE NO-PAUSE.

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                 NEXT.
            
            RUN Imprime_Consulta IN h-b1wgen0191
                                 (INPUT glb_cdcooper,
                                  INPUT tel_nrdconta,
                                  INPUT 0, /* inprodut */
                                  INPUT 0, /* nrctremp */
                                  INPUT 1,
                                  INPUT aux_confirma,
                                 OUTPUT aux_nmarqimp,
                                 OUTPUT aux_nmarqpdf,
                                 OUTPUT TABLE tt-erro).

            IF   aux_confirma = "T"   THEN
                 DO:
                     HIDE FRAME f_moldura.
                
                     RUN fontes/visrel.p (INPUT aux_nmarqimp).
                 
                     VIEW FRAME f_moldura.
                 
                     PAUSE 0.
                 END.
            ELSE
            IF   aux_confirma = "I"   THEN
                 DO:
                      ASSIGN par_flgrodar = TRUE
                             glb_nmformul = "132col"
                             glb_nrdevias = 1.

                      FIND FIRST crapass WHERE 
                                 crapass.cdcooper = glb_cdcooper
                                  NO-LOCK NO-ERROR.
            
                      { includes/impressao.i }

                 END.
          
            NEXT.

        END.
    
   LEAVE.

END.

HIDE FRAME f_protecao_credito.

DELETE PROCEDURE h-b1wgen0191.

PROCEDURE Busca_Dados:

    RUN sistema/generico/procedures/b1wgen0074.p PERSISTENT SET h-b1wgen0074.

    RUN Busca_Dados IN h-b1wgen0074
        ( INPUT glb_cdcooper, 
          INPUT 0,            
          INPUT 0,            
          INPUT glb_cdoperad, 
          INPUT glb_nmdatela, 
          INPUT 1,            
          INPUT tel_nrdconta, 
          INPUT glb_dtmvtolt,
          INPUT tel_idseqttl, 
          INPUT YES,
          INPUT glb_cddopcao,
         OUTPUT TABLE tt-conta-corr,
         OUTPUT TABLE tt-erro ) NO-ERROR.

    DELETE PROCEDURE h-b1wgen0074.

    IF  ERROR-STATUS:ERROR THEN
        DO:
           MESSAGE ERROR-STATUS:GET-MESSAGE(1).
           RETURN "NOK".
        END.

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
           FIND FIRST tt-erro NO-ERROR.

           IF  AVAILABLE tt-erro THEN
               MESSAGE tt-erro.dscritic.
                  
           RETURN "NOK".
        END.

    RETURN "OK".

END.

PROCEDURE Valida_Dados:

    DEF VAR aux_nmdcampo AS CHAR                                        NO-UNDO.
    DEF VAR aux_tipconfi AS INTE                                        NO-UNDO.
    DEF VAR aux_msgconfi AS CHAR                                        NO-UNDO.
    
    ASSIGN aux_inadimpl = IF   tel_dsinacop = "N"   THEN 
                               0
                          ELSE 
                               1.

    RUN sistema/generico/procedures/b1wgen0074.p PERSISTENT SET h-b1wgen0074.

    RUN Valida_Dados IN h-b1wgen0074
        ( INPUT glb_cdcooper, 
          INPUT 0,            
          INPUT 0,            
          INPUT glb_cdoperad, 
          INPUT glb_nmdatela, 
          INPUT 1,            
          INPUT tel_nrdconta, 
          INPUT tel_idseqttl, 
          INPUT TRUE,
          INPUT glb_dtmvtolt,
          INPUT 'A',
          INPUT tt-conta-corr.cdtipcta,
          INPUT tt-conta-corr.cdbcochq,
          INPUT tt-conta-corr.tpextcta,
          INPUT tt-conta-corr.cdagepac,
          INPUT tt-conta-corr.cdsitdct,
          INPUT tt-conta-corr.cdsecext, 
          INPUT tt-conta-corr.tpavsdeb,
          INPUT aux_inadimpl,
          INPUT tt-conta-corr.inlbacen,
          INPUT tel_dtdsdspc,
          INPUT FALSE,
         OUTPUT aux_flgcreca,
         OUTPUT aux_tipconfi,
         OUTPUT aux_msgconfi,
         OUTPUT aux_nmdcampo,
         OUTPUT TABLE tt-erro ) NO-ERROR.

    DELETE PROCEDURE h-b1wgen0074.

    IF  ERROR-STATUS:ERROR THEN
        DO:
           MESSAGE ERROR-STATUS:GET-MESSAGE(1).
           RETURN "NOK".
        END.

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
           FIND FIRST tt-erro NO-ERROR.

           IF  AVAILABLE tt-erro THEN
               MESSAGE tt-erro.dscritic.
                  
           RETURN "NOK".
        END.

    RETURN "OK".
END.

PROCEDURE Grava_Dados:

    DEF VAR aux_tpatlcad AS INTE                                       NO-UNDO.
    DEF VAR aux_msgatcad AS CHAR                                       NO-UNDO.
    DEF VAR aux_chavealt AS CHAR                                       NO-UNDO.

    RUN sistema/generico/procedures/b1wgen0074.p PERSISTENT SET h-b1wgen0074.

    FOR FIRST crapass FIELDS(idastcjt) WHERE crapass.cdcooper = glb_cdcooper
                                         AND crapass.nrdconta = tel_nrdconta NO-LOCK. END.
    RUN Grava_Dados IN h-b1wgen0074
       ( INPUT glb_cdcooper, 
         INPUT 0,            
         INPUT 0,            
         INPUT glb_cdoperad, 
         INPUT glb_nmdatela, 
         INPUT 1,            
         INPUT tel_nrdconta, 
         INPUT tel_idseqttl, 
         INPUT YES,
         INPUT ?,
         INPUT glb_dtmvtolt,
         INPUT 'A',
         INPUT 'A',
         INPUT aux_flgcreca,
         INPUT tt-conta-corr.cdtipcta,
         INPUT tt-conta-corr.cdsitdct,
         INPUT tt-conta-corr.cdsecext,
         INPUT tt-conta-corr.tpextcta,
         INPUT tt-conta-corr.cdagepac,
         INPUT tt-conta-corr.cdbcochq,
         INPUT tt-conta-corr.flgiddep,
         INPUT tt-conta-corr.tpavsdeb,
         INPUT tt-conta-corr.dtcnsscr,
         INPUT tel_dtcnsspc,
         INPUT tel_dtdsdspc,
         INPUT aux_inadimpl,
         INPUT tt-conta-corr.inlbacen,
         INPUT FALSE,
         INPUT tt-conta-corr.flgrestr,
         INPUT aux_indserma,
         INPUT crapass.idastcjt,
        OUTPUT aux_tpatlcad,
        OUTPUT aux_msgatcad,
        OUTPUT aux_chavealt,
        OUTPUT TABLE tt-erro ) NO-ERROR.

    DELETE PROCEDURE h-b1wgen0074.

    IF  ERROR-STATUS:ERROR THEN
        DO:
           MESSAGE ERROR-STATUS:GET-MESSAGE(1).
           RETURN "NOK".
        END.

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
           FIND FIRST tt-erro NO-ERROR.
   
           IF  AVAILABLE tt-erro THEN
               MESSAGE tt-erro.dscritic.
   
           RETURN "NOK".
        END.
    
    RETURN "OK".

END PROCEDURE.

                               
/* ......................................................................... */
