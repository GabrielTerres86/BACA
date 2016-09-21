/* .............................................................................

   Programa: Fontes/deschq_x.p
   Sistema : Conta-Corrente - Cooperativa 
   Sigla   : CRED
   Autor   : Edson
   Data    : Marco/2003                          Ultima atualizacao: 05/12/2012

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para cancelar o limite de descontos de cheques.

   Alteracoes: 22/06/2004 - Alterar tabela avalistas Terceiros(Mirtes).
   
               17/08/2004 - Incluido campos cidade/uf/cep(Evandro).
               
               26/01/2006 - Unificacao dos Bancos - SQLWorks - Andre

               05/07/2007 - HIDE no campo lim_dtcancel na hora de cancelar.
                            (Guilherme).

               17/09/2008 - Alterada chave de acesso a tabela crapldc 
                            (Gabriel). 
                            
               13/10/2009 - Alterado para um browse dinamico (Gabriel).
                            Desativar Rating do limite quando cancelado.
                            
               227/04/2011 - Alteração para CEP integrado. Campos nrendere,
                             complend e nrcxapst. (André - DB1)   
                             
               05/12/2012 - Ajuste para utilizar a BO9 (Adriano).              
                                      
............................................................................. */

{ includes/var_online.i }
{ includes/var_atenda.i }
{ includes/var_deschq.i }
{ sistema/generico/includes/var_internet.i }

DEF INPUT PARAM par_nrctrlim AS INT                                  NO-UNDO.

DEF VAR  h-b1wgen0043 AS HANDLE                                      NO-UNDO. 
DEF VAR  h-b1wgen0009 AS HANDLE                                      NO-UNDO.


        
CANCELA:
DO WHILE TRUE ON ERROR UNDO, LEAVE:


   ASSIGN lim_nmdaval1     = " "
          lim_cpfcgc1      = 0
          lim_tpdocav1     = " " 
          lim_dscpfav1     = " "
          lim_nmdcjav1     = " "
          lim_cpfccg1      = 0
          lim_tpdoccj1     = " " 
          lim_dscfcav1     = " "
          lim_dsendav1[1]  = " "
          lim_dsendav1[2]  = " "
          lim_nrfonres1    = " "
          lim_dsdemail1    = " "
          lim_nmcidade1    = " "
          lim_cdufresd1    = " "
          lim_nrcepend1    = 0
          lim_nrendere1    = 0
          lim_complend1    = " "
          lim_nrcxapst1    = 0
          
          lim_nmdaval2     = " " 
          lim_cpfcgc2      = 0
          lim_tpdocav2     = " "
          lim_dscpfav2     = " "
          lim_nmdcjav2     = " "
          lim_cpfccg2      = 0
          lim_tpdoccj2     = " " 
          lim_dscfcav2     = " "
          lim_dsendav2[1]  = " "
          lim_dsendav2[2]  = " "
          lim_nrfonres2    = " "
          lim_dsdemail2    = " "
          lim_nmcidade2    = " "
          lim_cdufresd2    = " "
          lim_nrcepend2    = 0
          lim_nrendere2    = 0
          lim_complend2    = " "
          lim_nrcxapst2    = 0.


    /*  Confirmacao do cancelamento  */

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
      ASSIGN aux_confirma = "N"
             glb_cdcritic = 78.

      RUN fontes/critic.p.
      BELL.
      ASSIGN glb_cdcritic = 0.
      MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF KEYFUNCTION(LASTKEY) = "END-ERROR" OR aux_confirma <> "S" THEN
      DO:
          ASSIGN glb_cdcritic = 79.
          RUN fontes/critic.p.
          BELL.
          ASSIGN glb_cdcritic = 0.
          MESSAGE glb_dscritic.
          LEAVE.

      END.


   IF NOT VALID-HANDLE(h-b1wgen0009) THEN
      RUN sistema/generico/procedures/b1wgen0009.p 
          PERSISTENT SET h-b1wgen0009.

   RUN efetua_cancelamento_limite IN h-b1wgen0009(INPUT glb_cdcooper,
                                                  INPUT glb_cdagenci,
                                                  INPUT 0, /*nrdcaixa*/
                                                  INPUT glb_cdoperad,
                                                  INPUT glb_nmdatela,
                                                  INPUT 1, /*idorigem*/
                                                  INPUT tel_nrdconta,
                                                  INPUT 1, /*idseqttl*/
                                                  INPUT glb_dtmvtolt,
                                                  INPUT glb_dtmvtopr,
                                                  INPUT glb_inproces,
                                                  INPUT par_nrctrlim,
                                                  INPUT TRUE, /*log*/
                                                  OUTPUT TABLE tt-erro).

   IF VALID-HANDLE(h-b1wgen0009) THEN
      DELETE OBJECT h-b1wgen0009.              
    
   IF RETURN-VALUE <> "OK" THEN
      DO:
         FIND FIRST tt-erro NO-LOCK NO-ERROR.
          
         IF AVAIL tt-erro THEN
            DO:
               BELL.
               MESSAGE tt-erro.dscritic.
               PAUSE 3 NO-MESSAGE.
               HIDE MESSAGE.

            END.
         ELSE
            DO:
               BELL.
               MESSAGE "Nao foi possivel cancelar o limite.".
               PAUSE 3 NO-MESSAGE.
               HIDE MESSAGE.

            END.

         RETURN.

      END.

   LEAVE.

END.  /*  Fim do DO TRANSACTION  */



/* .......................................................................... */
