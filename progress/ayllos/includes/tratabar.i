/* .............................................................................

   Programa: includes/tratabar.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Ze Eduardo.
   Data    : Marco/2001                      Ultima atualizacao: 11/02/2008

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Tratar o codigo de barras tipo 3 para todas as faturas  

   Alteracoes:
              18/04/2001 - Incluir a Opcao de Lancamentos de 2a. via.
                           (Ze Eduardo).

              10/05/2001 - Verificar se a Fatura corresponde ao
                           Lote ou Historico correto. (Ze Eduardo).
                            
              14/08/2003 - Inclusao do tratamento para historico 396 
                           SAMAE JARAGUA (Julio). 

              09/01/2004 - Nao aceitar mais Embratel histor 374 (Margarete).

              23/04/2004 - Aceitar Convenio Samae Gaspar(Historico 748)(Mirtes)
              
              09/06/2004 - Retirar acessos tabelas Convenios(Mirtes).
              
              29/09/2004 - Tratamento para o Historico 625 - CELESC CECRED
                           (Julio)
                           
              20/10/2004 - Inclusao fatura VIVO Historico 452 (Julio)
              
              23/11/2004 - Inclusao convenio SAMAE TIMBO e otimizacao da rotina
                           que le o numero do convenio (Julio).

              16/12/2004 - Inclusao IPTU IBIRAMA -> 633 (Julio)  
              
              19/01/2005 - Inclusao IPTU Indaial -> 639 (Julio)

              28/01/2005 - Inclusao SAMAE GASPAR / CECRED -> 634 (Julio)  
              
              02/02/2005 - Tratamento SAME BLUMENAU / CECRED -> 644 (Julio)
              
              31/03/2005 - Tratamento para CASA FELIZ -> 321 (Julio)
              
              30/01/2006 - Unificacao dos Bancos - SQLWorks - Andre
              
              11/02/2008 - Incluido virgulas (,) e aspas ("") no CAN-DO 
                           para selecionar todos os parametros (Elton).
............................................................................. */

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   IF   glb_cdcritic > 0 THEN 
        DO:
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            PAUSE 5 NO-MESSAGE.
            ASSIGN glb_cdcritic = 0
            tel_cdbarras = "".
        END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  
        LEAVE.

   RUN fontes/cdbarra.p (OUTPUT tel_cdbarras).

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  
        LEAVE.

   FIND crapcon WHERE crapcon.cdcooper = glb_cdcooper                   AND
                      crapcon.cdempcon = INT(SUBSTR(tel_cdbarras,16,4)) 
                      NO-LOCK NO-ERROR.
                      
   IF  NOT AVAIL crapcon then  DO:
       ASSIGN glb_cdcritic = 558.
       NEXT.
   END.

   DO:
       IF  TRIM(tel_cdbarras) = "" THEN     
           DO: 
              RUN fontes/verbar3.p (OUTPUT tel_cdbarras).

              IF   TRIM(tel_cdbarras) = "0"  AND
                   (glb_cddopcao <> "C" AND glb_cddopcao <> "K") THEN
                   NEXT.
                        
           END.     /*   Fim do IF   */
        
       IF  tel_cdhistor = 308 THEN        /*  Telesc Brasil Telecom  */
           tel_cdseqfat = DEC(SUBSTR(tel_cdbarras,20,20)).
       ELSE
       IF  tel_cdhistor = 639   OR   /* Prefeitura Indaial */
           tel_cdhistor = 398   THEN /* Prefeitura Gaspar */
           tel_cdseqfat = DEC(SUBSTR(tel_cdbarras,20,25)). 
       ELSE  
       IF  tel_cdhistor = 396   THEN /* SAMAE JARAGUA */
           tel_cdseqfat = DEC(SUBSTR(tel_cdbarras,28,10)).
       ELSE
       IF  tel_cdhistor = 452   THEN /* VIVO */
           tel_cdseqfat = DEC(SUBSTR(tel_cdbarras,24,10)).
       ELSE
       IF  tel_cdhistor = 627   THEN /* SAMAE TIMBO */
           tel_cdseqfat = DEC(SUBSTR(tel_cdbarras,30,15)).
       ELSE
       IF  tel_cdhistor = 633   THEN /* IPTU IBIRAMA */
           tel_cdseqfat = DEC(SUBSTR(tel_cdbarras,28,17)).
       ELSE
       /*  Celesc e Casan  */
           tel_cdseqfat = DEC(SUBSTR(tel_cdbarras,31,12)).

       IF   glb_cddopcao = "I"  THEN
            DO:
               tel_vlfatura = DEC(SUBSTR(tel_cdbarras,5,11)) / 100.
                                       
               IF   CAN-DO("306,307,348,625,644",
                                       STRING(tel_cdhistor,"999"))  THEN
                   tel_nrdigfat = INT(SUBSTR(tel_cdbarras,43,02)).
               ELSE
               IF   CAN-DO("396,627,452,633,639,321",
                           STRING(tel_cdhistor,"999"))   THEN
                  tel_nrdigfat = INTEGER(SUBSTR(tel_cdbarras,4,1)).
               ELSE
                  tel_nrdigfat = 0.               

            END.                                       
        
       /*  Verifica se as Faturas correspondem a esse Lote ou Historico */ 
       IF   TRIM(tel_cdbarras) <> "0" THEN           
            DO:
                IF   CAN-DO("306,307,308,348,396,398,627,644,321," +
                     "452,625,633,634,748,639", STRING(tel_cdhistor,"999")) THEN
                     DO:
                         IF   crapcon.cdempcon <>
                                          INT(SUBSTR(tel_cdbarras,16,04)) THEN 
                              DO:
                                  glb_cdcritic = 714.
                                  NEXT.                         
                              END.
                     END.
            END.  /*  Fim  do IF  */
       
   END.  
   
   DISPLAY tel_vlfatura tel_cdseqfat tel_nrdigfat WITH FRAME f_lanfat. 
   LEAVE.

END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */
