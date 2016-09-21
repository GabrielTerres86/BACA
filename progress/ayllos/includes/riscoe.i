/* .............................................................................

   Programa: Includes/riscoe.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete
   Data    : Junho/2001                      Ultima Alteracao: 22/10/2008

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de exclusao da tela RISCO.


   Alteracoes: 13/11/2001 - Gerar uma unica transacao (Margarete).
               09/04/2003 - Permitir alterar pessoa fisica para a Concredi
                            (Deborah).
                            Incluir novos campos na tela (Margarete).
               12/11/2003 - Ler apenas crapris.indocto = 0(Mirtes).
               17/11/2003 - Alt. p/para gravar conforme layout Docto 3020,     
                            gravando tambem inddocto 0(Docto 3010) (Mirtes).
               01/12/2004 - Somente Viacredi/Creditextil poderao eliminar(qdo
                            pessoa juridica.(Mirtes)
               12/07/2005- Permitir exclusao da base de dados a informacao da
                           conta 1457 do mes de 06/2005 - CREDCREA(Mirtes)
               01/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
               22/10/2008 - Incluir prejuizo a +48M ate 60M(Magui).
............................................................................. */

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

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
           
   UPDATE tel_nrdconta WITH FRAME f_risco.
   
   FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                      crapass.nrdconta = tel_nrdconta NO-LOCK NO-ERROR.

   IF   glb_cdcooper <> 1 AND
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
        IF   crapass.inpessoa <> 2   THEN
             DO:
                 ASSIGN glb_cdcritic = 331.
                 RUN fontes/critic.p.
                 BELL.
                 MESSAGE glb_dscritic.
                 CLEAR FRAME f_risco.
                 DISPLAY glb_cddopcao tel_dtrefere WITH FRAME f_risco.
                 NEXT.
             END.
   
   ASSIGN tel_nmprimtl = crapass.nmprimtl.
   DISPLAY tel_nmprimtl WITH FRAME f_risco.
   
   UPDATE tel_innivris
          tel_cdmodali
          tel_nrctremp
          tel_nrseqctr
          WITH FRAME f_risco.
   
   FIND FIRST crapris WHERE crapris.cdcooper = glb_cdcooper 
                        AND crapris.nrdconta = tel_nrdconta
                        AND crapris.dtrefere = tel_dtrefere
                        AND crapris.innivris = tel_innivris 
                        AND crapris.inddocto = 1
                        AND crapris.cdmod    >= tel_cdmodali
                        AND crapris.nrctremp >= tel_nrctremp
                        AND crapris.nrseqctr >= tel_nrseqctr    
                        AND 
                        ((crapris.cdorigem = 3 AND
                            glb_cdcooper <> 7) OR
                            (crapris.cdorigem = 1 AND
                            glb_cdcooper = 7 AND
                            tel_nrdconta = 1457)) 
                            NO-LOCK NO-ERROR.
   IF   NOT AVAILABLE crapris   THEN                     
        DO:
            ASSIGN glb_cdcritic = 564.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            CLEAR FRAME f_risco.
            DISPLAY glb_cddopcao tel_dtrefere WITH FRAME f_risco.
            NEXT.
        END.
 
    
   ASSIGN tel_cdmodali  = crapris.cdmodali
          tel_nrctremp  = crapris.nrctremp 
          tel_nrseqctr  = crapris.nrseqctr
          tel_dtinictr  = crapris.dtinictr.

   DISPLAY tel_cdmodali tel_nrctremp
           tel_nrseqctr tel_dtinictr WITH FRAME f_risco.
 

   ASSIGN aux_vlprjano = 0
          aux_vlprjaan = 0
          aux_vlprjant = 0.
    
   ASSIGN aux_contador = 1.
   DO  WHILE aux_contador LE 11:
       ASSIGN aux_vlvencto[aux_contador]  = 0
              aux_contador = aux_contador + 1.
   END.
    
   ASSIGN aux_contador = 1.
   DO  WHILE aux_contador LE 12:
       ASSIGN aux_vlvencid[aux_contador] = 0
              aux_contador = aux_contador + 1.
   END.
   
   FOR EACH crapvri NO-LOCK WHERE
            crapvri.cdcooper  = glb_cdcooper     AND
            crapvri.nrdconta  = crapris.nrdconta AND
            crapvri.dtrefere  = crapris.dtrefere AND
            crapvri.innivris  = crapris.innivris AND
            crapvri.cdmodali  = crapris.cdmodali AND
            crapvri.nrctremp  = crapris.nrctremp AND 
            crapvri.nrseqctr  = crapris.nrseqctr :
   
       IF  crapvri.cdvencto = 310  THEN
           ASSIGN aux_vlprjano = crapvri.vldivida.

       IF  crapvri.cdvencto = 320 THEN
           ASSIGN aux_vlprjaan = crapvri.vldivida.
      
       IF  crapvri.cdvencto = 330 THEN
           ASSIGN aux_vlprjant = crapvri.vldivida.
           
       IF  crapvri.cdvencto >= 110 AND
           crapvri.cdvencto <= 190 THEN
           DO:
               ASSIGN aux_contador = 1.
               DO  WHILE aux_contador LE 11:
                   IF  aux_cdvencto[aux_contador] = crapvri.cdvencto THEN
                       ASSIGN aux_vlvencto[aux_contador] = crapvri.vldivida.
                   ASSIGN aux_contador = aux_contador + 1.
               END.
           END.
       
       IF  crapvri.cdvencto >= 205 AND 
           crapvri.cdvencto <= 290 THEN
           DO:
               ASSIGN aux_contador = 1.
               DO  WHILE aux_contador LE 12:
                   IF  aux_cdvencid[aux_contador] = crapvri.cdvencto THEN
                       ASSIGN aux_vlvencid[aux_contador] = crapvri.vldivida.
                   ASSIGN aux_contador = aux_contador + 1.
               END.
           END.     
              
   END.   /* for each crpavri */         
   
 
   ASSIGN tel_vlvec30   = aux_vlvencto[1]
          tel_vlvec60   = aux_vlvencto[2]
          tel_vlvec90   = aux_vlvencto[3]
          tel_vlvec180  = aux_vlvencto[4]
          tel_vlvec360  = aux_vlvencto[5]
          tel_vlvec720  = aux_vlvencto[6]
          tel_vlvec1080 = aux_vlvencto[7]
          tel_vlvec1440 = aux_vlvencto[8]
          tel_vlvec1800 = aux_vlvencto[9]
          tel_vlvec5400 = aux_vlvencto[10]
          tel_vlvec9999 = aux_vlvencto[11]
          tel_vldiv14   = aux_vlvencid[1] 
          tel_vldiv30   = aux_vlvencid[2] 
          tel_vldiv60   = aux_vlvencid[3] 
          tel_vldiv90   = aux_vlvencid[4] 
          tel_vldiv120  = aux_vlvencid[5] 
          tel_vldiv150  = aux_vlvencid[6] 
          tel_vldiv180  = aux_vlvencid[7] 
          tel_vldiv240  = aux_vlvencid[8] 
          tel_vldiv300  = aux_vlvencid[9] 
          tel_vldiv360  = aux_vlvencid[10] 
          tel_vldiv540  = aux_vlvencid[11] 
          tel_vldiv999  = aux_vlvencid[12] 
          tel_vlprjano  = aux_vlprjano
          tel_vlprjaan  = aux_vlprjaan
          tel_vlprjant  = aux_vlprjant.
          

   DISP tel_vlvec30   tel_vlvec60   tel_vlvec90
        tel_vlvec180  tel_vlvec360  tel_vlvec720
        tel_vlvec1080 tel_vlvec1440 tel_vlvec1800
        tel_vlvec5400 tel_vlvec9999
        tel_vldiv14   tel_vldiv30   tel_vldiv60
        tel_vldiv90   tel_vldiv120  tel_vldiv150
        tel_vldiv180  tel_vldiv240  tel_vldiv300
        tel_vldiv360  tel_vldiv540  tel_vldiv999
        tel_vlprjano  tel_vlprjaan  tel_vlprjant
        WITH FRAME f_risco.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      ASSIGN aux_confirma = "N"
             glb_cdcritic = 78.

      RUN fontes/critic.p.
      BELL.
      MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
      LEAVE.

   END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR" OR
        aux_confirma <> "S" THEN
        DO:
            glb_cdcritic = 79.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            NEXT.
        END.
   
   DO TRANSACTION:

        FIND FIRST crapris WHERE crapris.cdcooper = glb_cdcooper
                             AND crapris.nrdconta = tel_nrdconta
                             AND crapris.dtrefere = tel_dtrefere
                             AND crapris.innivris = tel_innivris 
                             AND crapris.inddocto = 1
                             AND crapris.cdmod    = tel_cdmodali
                             AND crapris.nrctremp = tel_nrctremp
                             AND crapris.nrseqctr = tel_nrseqctr    
                             AND ((crapris.cdorigem = 3 AND
                                   glb_cdcooper <> 7) OR
                                 (crapris.cdorigem = 1 AND
                                   glb_cdcooper = 7 AND
                                   tel_nrdconta = 1457))
                                   EXCLUSIVE-LOCK NO-ERROR. 
        IF   NOT AVAILABLE crapris   THEN                     
             DO:
                 ASSIGN glb_cdcritic = 564.
                 RUN fontes/critic.p.
                 BELL.
                 MESSAGE glb_dscritic.
                 CLEAR FRAME f_risco.
                 DISPLAY glb_cddopcao tel_dtrefere WITH FRAME f_risco.
                 NEXT.
            END.
           
       FOR EACH crapvri  WHERE
                crapvri.cdcooper  = glb_cdcooper     AND
                crapvri.nrdconta  = crapris.nrdconta AND
                crapvri.dtrefere  = crapris.dtrefere AND
                crapvri.innivris  = crapris.innivris AND
                crapvri.cdmodali  = crapris.cdmodali AND
                crapvri.nrctremp  = crapris.nrctremp AND 
                crapvri.nrseqctr  = crapris.nrseqctr EXCLUSIVE-LOCK :
           DELETE crapvri.
       END.

       DELETE crapris.

 
       RUN regera_crapris.   /* Docto 3010 */
       
   END.
   
   CLEAR FRAME f_risco NO-PAUSE.
 
   LEAVE.
END.

CLEAR FRAME f_risco NO-PAUSE.

/* .......................................................................... */
