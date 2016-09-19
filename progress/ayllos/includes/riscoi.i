/* .............................................................................

   Programa: Includes/riscoi.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete
   Data    : Junho/2001                      Ultima Alteracao: 11/12/2013

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de inclusao da tela RISCO.


   Alteracoes: 13/11/2001 - Gerar uma unica transacao (Margarete)
   
               09/04/2003 - Permitir incluir pessoas fisicas para a Concredi
                            (Deborah).
                            Incluir novos campos na tela (Margarete).
                            
               17/11/2003 - Alt. p/para gravar conforme layout Docto 3020, 
                            gravando tambem inddocto 0(Docto 3010) (Mirtes).
                            
               01/12/2004 - Somente Viacredi/Creditextil poderao incluir(qdo
                            pessoa juridica.(Mirtes)

               06/07/2005 - Alimentado campo cdcooper da tabela crapris (Diego).

               01/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

               22/10/2008 - Incluir prejuizo a +48 ate 60M (Magui).
               
               11/12/2013 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( André Euzébio / SUPERO) 
............................................................................. */

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   /*----------
   ASSIGN tel_vlvec30   = 0   tel_vlvec60   = 0
          tel_vlvec90   = 0   tel_vlvec180  = 0
          tel_vlvec360  = 0   tel_vlvec720  = 0
          tel_vlvec1080 = 0   tel_vlvec1440 = 0
          tel_vlvec1800 = 0   tel_vlvec5400 = 0
          tel_vlvec9999 = 0
          tel_vldiv14   = 0   tel_vldiv30   = 0
          tel_vldiv60   = 0   tel_vldiv90   = 0
          tel_vldiv120  = 0   tel_vldiv150  = 0
          tel_vldiv180  = 0   tel_vldiv240  = 0
          tel_vldiv300  = 0   tel_vldiv360  = 0
          tel_vldiv540  = 0   tel_vldiv999  = 0          
          tel_vlprjano  = 0   tel_vlprjaan  = 0
          tel_vlprjant  = 0.
 
   DISPLAY "" @ tel_vlvec30 
           "" @ tel_vlvec60
           "" @ tel_vlvec90
           "" @ tel_vlvec180
           "" @ tel_vlvec360
           "" @ tel_vlvec720
           "" @ tel_vlvec1080
           "" @ tel_vlvec1440
           "" @ tel_vlvec1800
           "" @ tel_vlvec5400
           "" @ tel_vlvec9999
           "" @ tel_vldiv14
           "" @ tel_vldiv30
           "" @ tel_vldiv60
           "" @ tel_vldiv90
           "" @ tel_vldiv120
           "" @ tel_vldiv150 
           "" @ tel_vldiv180 
           "" @ tel_vldiv240 
           "" @ tel_vldiv300 
           "" @ tel_vldiv360 
           "" @ tel_vldiv540
           "" @ tel_vldiv999
           "" @ tel_vlprjano
           "" @ tel_vlprjaan
           "" @ tel_vlprjant
           WITH FRAME f_risco.
   ------------------*/        
   UPDATE tel_nrdconta WITH FRAME f_risco.
   
   FIND crapass WHERE crapass.cdcooper = glb_cdcooper   AND
                      crapass.nrdconta = tel_nrdconta   NO-LOCK NO-ERROR.
 
   IF  glb_cdcooper <> 1 AND
       glb_cdcooper <> 2 THEN
       DO:
          ASSIGN glb_cdcritic = 36.
          RUN fontes/critic.p.
          BELL.
          MESSAGE glb_dscritic.
          CLEAR FRAME f_risco.
          DISPLAY glb_cddopcao tel_dtrefere WITH FRAME f_risco.
          NEXT.
       END. 
   ELSE
       IF  crapass.inpessoa <> 2   THEN
           DO:
               ASSIGN glb_cdcritic = 331.
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               CLEAR FRAME f_risco.
               DISPLAY glb_cddopcao tel_dtrefere WITH FRAME f_risco.
               NEXT.
           END.
        
   ASSIGN tel_nmprimtl = crapass.nmprimt.
   DISPLAY tel_nmprimtl WITH FRAME f_risco.
   
   UPDATE tel_innivris WITH FRAME f_risco.
   
   /*--   Nao deve existir mais de um registro  (Emprestimos) --*/
   FIND FIRST crapris WHERE crapris.cdcooper = glb_cdcooper  AND
                            crapris.nrdconta = tel_nrdconta  AND
                            crapris.dtrefere = tel_dtrefere  AND
                            crapris.innivris = tel_innivris  AND
                            crapris.cdorigem = 3             NO-LOCK NO-ERROR.
                            
   IF   AVAILABLE crapris   THEN                     
        DO:
            ASSIGN glb_cdcritic = 591.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            CLEAR FRAME f_risco.
            DISPLAY glb_cddopcao tel_dtrefere WITH FRAME f_risco.
            NEXT.
        END.
   
   ASSIGN tel_cdmodali = 0299.

   UPDATE tel_cdmodali
          tel_nrctremp
          tel_nrseqctr
          tel_dtinictr
          WITH FRAME f_risco.

   UPDATE tel_vlvec30   tel_vlvec60 
          tel_vlvec90   tel_vlvec180
          tel_vlvec360  tel_vlvec720
          tel_vlvec1080 tel_vlvec1440
          tel_vlvec1800 tel_vlvec5400
          tel_vlvec9999
          tel_vldiv14   tel_vldiv30
          tel_vldiv60   tel_vldiv90
          tel_vldiv120  tel_vldiv150
          tel_vldiv180  tel_vldiv240
          tel_vldiv300  tel_vldiv360
          tel_vldiv540  tel_vldiv999

          tel_vlprjano  tel_vlprjaan  tel_vlprjant
       
          WITH FRAME f_risco
  
   EDITING:
            DO:
                READKEY.
                IF   FRAME-FIELD = "tel_vlvec30"   THEN
                     DO:
                         IF   LASTKEY =  KEYCODE(".")   THEN
                              APPLY 44.
                         ELSE
                              APPLY LASTKEY.
                     END.
                ELSE
                IF   FRAME-FIELD = "tel_vlvec60"   THEN
                     DO:
                         IF   LASTKEY =  KEYCODE(".")   THEN
                              APPLY 44.
                         ELSE
                              APPLY LASTKEY.
                     END.
                ELSE
                IF   FRAME-FIELD = "tel_vlvec90"   THEN
                     DO:
                         IF   LASTKEY =  KEYCODE(".")   THEN
                              APPLY 44.
                         ELSE
                              APPLY LASTKEY.
                     END.
                ELSE
                IF   FRAME-FIELD = "tel_vlvec180"   THEN
                     DO:
                         IF   LASTKEY =  KEYCODE(".")   THEN
                              APPLY 44.
                         ELSE
                              APPLY LASTKEY.
                     END.
                ELSE
                IF   FRAME-FIELD = "tel_vlvec360"   THEN
                     DO:
                         IF   LASTKEY =  KEYCODE(".")   THEN
                              APPLY 44.
                         ELSE
                              APPLY LASTKEY.
                     END.
                ELSE
                IF   FRAME-FIELD = "tel_vlvec720"   THEN
                     DO:
                         IF   LASTKEY =  KEYCODE(".")   THEN
                              APPLY 44.
                         ELSE
                              APPLY LASTKEY.
                     END.
                ELSE
                IF   FRAME-FIELD = "tel_vlvec1080"   THEN
                     DO:
                         IF   LASTKEY =  KEYCODE(".")   THEN
                              APPLY 44.
                         ELSE
                              APPLY LASTKEY.
                     END.
                ELSE
                IF   FRAME-FIELD = "tel_vlvec1440"   THEN
                     DO:
                         IF   LASTKEY =  KEYCODE(".")   THEN
                              APPLY 44.
                         ELSE
                              APPLY LASTKEY.
                     END.
                ELSE
                IF   FRAME-FIELD = "tel_vlvec1800"   THEN
                     DO:
                         IF   LASTKEY =  KEYCODE(".")   THEN
                              APPLY 44.
                         ELSE
                              APPLY LASTKEY.
                     END.
                ELSE
                IF   FRAME-FIELD = "tel_vlvec5400"   THEN
                     DO:
                         IF   LASTKEY =  KEYCODE(".")   THEN
                              APPLY 44.
                         ELSE
                              APPLY LASTKEY.
                     END.
                ELSE
                IF   FRAME-FIELD = "tel_vlvec9999"   THEN
                     DO:
                         IF   LASTKEY =  KEYCODE(".")   THEN
                              APPLY 44.
                         ELSE
                              APPLY LASTKEY.
                     END.
                ELSE
                IF   FRAME-FIELD = "tel_vldiv14"   THEN
                     DO:
                         IF   LASTKEY =  KEYCODE(".")   THEN
                              APPLY 44.
                         ELSE
                              APPLY LASTKEY.
                     END.
                ELSE
                IF   FRAME-FIELD = "tel_vldiv30"   THEN
                     DO:
                         IF   LASTKEY =  KEYCODE(".")   THEN
                              APPLY 44.
                         ELSE
                              APPLY LASTKEY.
                     END.
                ELSE
                IF   FRAME-FIELD = "tel_vldiv60"   THEN
                     DO:
                         IF   LASTKEY =  KEYCODE(".")   THEN
                              APPLY 44.
                         ELSE
                              APPLY LASTKEY.
                     END.
                ELSE
                IF   FRAME-FIELD = "tel_vldiv90"   THEN
                     DO:
                         IF   LASTKEY =  KEYCODE(".")   THEN
                              APPLY 44.
                         ELSE
                              APPLY LASTKEY.
                     END.
                ELSE
                IF   FRAME-FIELD = "tel_vldiv120"   THEN
                     DO:
                         IF   LASTKEY =  KEYCODE(".")   THEN
                              APPLY 44.
                         ELSE
                              APPLY LASTKEY.
                     END.
                ELSE
                IF   FRAME-FIELD = "tel_vldiv150"   THEN
                     DO:
                         IF   LASTKEY =  KEYCODE(".")   THEN
                              APPLY 44.
                         ELSE
                              APPLY LASTKEY.
                     END.
 
                ELSE
                IF   FRAME-FIELD = "tel_vldiv180"   THEN
                     DO:
                         IF   LASTKEY =  KEYCODE(".")   THEN
                              APPLY 44.
                         ELSE
                              APPLY LASTKEY.
                     END.
                ELSE
                IF   FRAME-FIELD = "tel_vldiv240"   THEN
                     DO:
                         IF   LASTKEY =  KEYCODE(".")   THEN
                              APPLY 44.
                         ELSE
                              APPLY LASTKEY.
                     END.
                ELSE
                IF   FRAME-FIELD = "tel_vldiv300"   THEN
                     DO:
                         IF   LASTKEY =  KEYCODE(".")   THEN
                              APPLY 44.
                         ELSE
                              APPLY LASTKEY.
                     END.
                ELSE
                IF   FRAME-FIELD = "tel_vldiv360"   THEN
                     DO:
                         IF   LASTKEY =  KEYCODE(".")   THEN
                              APPLY 44.
                         ELSE
                              APPLY LASTKEY.
                     END.
                ELSE
                IF   FRAME-FIELD = "tel_vldiv540"   THEN
                     DO:
                         IF   LASTKEY =  KEYCODE(".")   THEN
                              APPLY 44.
                         ELSE
                              APPLY LASTKEY.
                     END.
                ELSE
                IF   FRAME-FIELD = "tel_vldiv999"   THEN
                     DO:
                         IF   LASTKEY =  KEYCODE(".")   THEN
                              APPLY 44.
                         ELSE
                              APPLY LASTKEY.
                     END.
                ELSE
                IF   FRAME-FIELD = "tel_vlprjano"   THEN
                     DO:
                         IF   LASTKEY =  KEYCODE(".")   THEN
                              APPLY 44.
                         ELSE
                              APPLY LASTKEY.
                     END.
                ELSE
                IF   FRAME-FIELD = "tel_vlprjaan"   THEN
                     DO:
                         IF   LASTKEY =  KEYCODE(".")   THEN
                              APPLY 44.
                         ELSE
                              APPLY LASTKEY.
                     END.
                ELSE
                IF   FRAME-FIELD = "tel_vlprjant"   THEN
                     DO:
                         IF   LASTKEY =  KEYCODE(".")   THEN
                              APPLY 44.
                         ELSE
                              APPLY LASTKEY.
                     END.
                 ELSE
                     APPLY LASTKEY.

            END.
   END. /* end do editing */
   /*
   IF  tel_cdmodali <> 0101 AND   /* Adiantamento Depositante */
       tel_cdmodali <> 0299 AND   /* Emprestimos - Outros     */
       tel_cdmodali <> 0302 AND   /* Desconto de Cheques      */
       tel_cdmodali <> 0201 THEN  /* Cheque Especial          */
   */     
   IF  tel_cdmodali <> 0299 THEN  /* Emprestimos - Outros */
       DO:
          ASSIGN glb_cdcritic = 468. /*- Tipo de Registro(Modalidade) Inv. -*/
          RUN fontes/critic.p.
          BELL.
          MESSAGE glb_dscritic.
          NEXT.
       END.
       
   IF  tel_nrctremp = 0 THEN
       DO:
          ASSIGN glb_cdcritic = 361. /*- Contrato deve ser Informado -*/
          RUN fontes/critic.p.
          BELL.
          MESSAGE glb_dscritic.
          NEXT.
       END.
       
   IF  tel_nrseqctr = 0 THEN
       ASSIGN tel_nrseqctr = 1.
              
   IF  tel_dtinictr = ? THEN
       DO:
          ASSIGN glb_cdcritic = 13. /*- Data Errada -*/
          RUN fontes/critic.p.
          BELL.
          MESSAGE glb_dscritic.
          NEXT.
       END.
 
   ASSIGN aux_vldivida = tel_vlvec30   + tel_vlvec60   + teL_vlvec90   + 
                         tel_vlvec180  + tel_vlvec360  + tel_vlvec720  +
                         tel_vlvec1080 + tel_vlvec1440 + tel_vlvec1800 +
                         tel_vlvec5400 + tel_vlvec9999 + 
                         tel_vldiv14   + tel_vldiv30   + tel_vldiv60   +
                         tel_vldiv90   + tel_vldiv120  + tel_vldiv150  +
                         tel_vldiv180  + tel_vldiv240  + tel_vldiv300  +
                         tel_vldiv360  + tel_vldiv540  + tel_vldiv999  +
                         tel_vlprjano  + tel_vlprjaan  + tel_vlprjant.
   IF  aux_vldivida = 0 THEN
       DO:
          ASSIGN glb_cdcritic = 269. /*- Valor errado(Deve ser Informado) -*/
          RUN fontes/critic.p.
          BELL.
          MESSAGE glb_dscritic.
          NEXT.
       END.
   
   DO TRANSACTION:
      CREATE crapris.
      ASSIGN crapris.nrdconta = tel_nrdconta
             crapris.dtrefere = tel_dtrefere
             crapris.innivris = tel_innivris
             crapris.inpessoa = crapass.inpessoa
             crapris.nrcpfcgc = crapass.nrcpfcgc
             crapris.inddocto = 1
             crapris.cdmodali = tel_cdmodali
             crapris.nrctremp = tel_nrctremp
             crapris.nrseqctr = tel_nrseqctr
             crapris.dtinictr = tel_dtinictr
             crapris.vldivida = aux_vldivida
             crapris.cdorigem = 3
             crapris.cdagenci = crapass.cdagenci
             crapris.cdcooper = glb_cdcooper.

      IF  tel_cdmodali = 0302 THEN
          ASSIGN crapris.cdorigem = 2.
          
      IF  tel_cdmodali = 0201 OR
          tel_cdmodali = 0101 THEN
          ASSIGN crapris.cdorigem  = 1.
      VALIDATE crapris.
      RUN gera_crapris_crapvri.   /* crapris - Docto 3010 */
 
   END.

   ASSIGN tel_vlvec30   = 0   tel_vlvec60   = 0
          tel_vlvec90   = 0   tel_vlvec180  = 0
          tel_vlvec360  = 0   tel_vlvec720  = 0
          tel_vlvec1080 = 0   tel_vlvec1440 = 0
          tel_vlvec1800 = 0   tel_vlvec5400 = 0
          tel_vlvec9999 = 0
          tel_vldiv14   = 0   tel_vldiv30   = 0
          tel_vldiv60   = 0   tel_vldiv90   = 0
          tel_vldiv120  = 0   tel_vldiv150  = 0
          tel_vldiv180  = 0   tel_vldiv240  = 0
          tel_vldiv300  = 0   tel_vldiv360  = 0
          tel_vldiv540  = 0   tel_vldiv999  = 0          
          tel_vlprjano  = 0   tel_vlprjaan  = 0
          tel_vlprjant  = 0.
 
   DISPLAY "" @ tel_vlvec30 
           "" @ tel_vlvec60
           "" @ tel_vlvec90
           "" @ tel_vlvec180
           "" @ tel_vlvec360
           "" @ tel_vlvec720
           "" @ tel_vlvec1080
           "" @ tel_vlvec1440
           "" @ tel_vlvec1800
           "" @ tel_vlvec5400
           "" @ tel_vlvec9999
           "" @ tel_vldiv14
           "" @ tel_vldiv30
           "" @ tel_vldiv60
           "" @ tel_vldiv90
           "" @ tel_vldiv120
           "" @ tel_vldiv150 
           "" @ tel_vldiv180 
           "" @ tel_vldiv240 
           "" @ tel_vldiv300 
           "" @ tel_vldiv360 
           "" @ tel_vldiv540
           "" @ tel_vldiv999
           "" @ tel_vlprjano
           "" @ tel_vlprjaan
           "" @ tel_vlprjant
           WITH FRAME f_risco.
 
  
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
        LEAVE.
END.

CLEAR FRAME f_risco NO-PAUSE.
/* .......................................................................... */


