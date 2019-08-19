/* .............................................................................

   Programa: bacalhau/crpb101.p
   Autor   : Edson
   Data    :                                     Ultima alteracao: 23/05/2017 

   Dados referentes ao programa:

   Frequencia: Diario (Assim que solicitado)
   Objetivo  : Validar layout de arquivo de convenios 
   
   Alteracao : 10/01/2008 - Validar formato de datas e historicos (Guilherme).
    
               25/02/2010 - Acerto na validacao do codigo da empresa (Diego).

               25/04/2017 - Ajuste para apresentar critica e abortar processo
                            de validacao do arquivo quando encontrado um
                            valor negativo
                            (Adriano - 653213).

			   23/05/2017 - Ajuste para apresentar criticas no form de erros
				           (Adriano - 653213).

............................................................................. */

DEF STREAM s1.

DEF VAR empresa       AS INT FORMAT "999" .
DEF VAR refere        AS DATE FORMAT "99999999". 

DEF VAR tipo          AS INT FORMAT "9".
DEF VAR seq           AS INT FORMAT "999999".
DEF VAR conta         AS INT FORMAT "999999999".
DEF VAR valor         AS DECIMAL FORMAT "9999999999.99".
DEF VAR aux_vllanmto  AS CHAR FORMAT "x(15)".
DEF VAR hst           AS INT FORMAT "9999".
DEF VAR arquivo       AS CHAR FORMAT "x(35)" NO-UNDO.
DEF VAR qtreg         AS INT FORMAT "zz,zz9" NO-UNDO.
DEF VAR c2            AS DECIMAL FORMAT "9999999.99".
DEF VAR c1            AS INT FORMAT "999".
DEF VAR aux_dscritic  AS CHAR NO-UNDO.

DEF VAR data          AS CHAR FORMAT "x(10)".
DEF VAR cdata         AS DATE FORMAT "99/99/9999".

DEF VAR aux_contador  AS INT NO-UNDO.
DEF VAR aux_flgrodape AS LOGICAL NO-UNDO.
DEF VAR arq_vlsomado  AS DECIMAL FORMAT "zzz,zzz,zz9.99" NO-UNDO.
DEF VAR aux_cdempres  AS INT                             NO-UNDO.
DEF VAR aux_data      AS CHAR                            NO-UNDO.

DEF VAR tot_vllanmto  AS DECIMAL FORMAT "zzz,zzz,zz9.99" EXTENT 9999 NO-UNDO.
DEF VAR tot_vlsomado  AS DECIMAL FORMAT "zzz,zzz,zz9.99" NO-UNDO.
DEF VAR aux_dtultdia  AS DATE    FORMAT "99999999"       NO-UNDO.

DEF VAR hoje          AS DATE    NO-UNDO.
DEF VAR resposta      AS LOGICAL FORMAT "S/N" INIT TRUE NO-UNDO.
DEF VAR erro          AS LOGICAL NO-UNDO.
DEF VAR mes_ref       AS INT     FORMAT "zz"             NO-UNDO.
DEF VAR ano_ref       AS INT     FORMAT "zzzz"           NO-UNDO.
DEF VAR glb_cdcooper  AS INT                             NO-UNDO.

FORM "T o t a l" tot_vlsomado NO-LABEL WITH FRAME cc OVERLAY.

FORM arq_vlsomado LABEL "Total no arquivo" WITH ROW 4 COLUMN 30 OVERLAY FRAME t.

FORM "Qtd. Reg" qtreg NO-LABEL WITH FRAME qt OVERLAY.

FORM SKIP(1) " VALORES  DIFERENTES " SKIP(1)
     WITH FRAME DIF OVERLAY ROW 4 COLUMN 51.

FORM SKIP(1) " TOTAL DO ARQUIVO OK " SKIP(1)
     WITH FRAME ok OVERLAY ROW 4 COLUMN 51.
     
FORM SKIP(1) "ERRO!!! FALTA REG. 9 " at 25
     SKIP(1)
     "Critica:" aux_dscritic no-label format "x(60)"
     WITH FRAME err OVERLAY ROW 10 COLUMN 2 WIDTH 78.

FORM conta FORMAT "zzzz,zzz,9" "--> NAO CADASTRADA."
     WITH FRAME conta 8 DOWN COLUMN 30 ROW 10.

FORM conta FORMAT "zzzz,zzz,9" "--> Demitido."
     WITH FRAME demi 8 DOWN COLUMN 30 ROW 10.

ASSIGN glb_cdcooper = INT(OS-GETENV('CDCOOPER')).

REPEAT:
   
   INICIO:

   REPEAT:
    
      UPDATE arquivo LABEL "Nome do arquivo a somar" 
             mes_ref LABEL "Ref."
             "/"
             ano_ref WITH SIDE-LABELS NO-LABELS FRAME bb OVERLAY.
      
      ASSIGN hoje = DATE(mes_ref,01,ano_ref)
                    aux_dtultdia = ((DATE(MONTH(hoje),28,YEAR(hoje)) + 4) -
                                     DAY(DATE(MONTH(hoje),28,
                                            YEAR(hoje)) + 4)).
      
      MESSAGE "Arquivo a testar e' folha ou convenio? (S/N) " UPDATE resposta.
   
      IF    search(arquivo) = ?   THEN
            DO:
                BELL.
                MESSAGE "Arquivo nao existe" arquivo.
                NEXT.
            END.

      ASSIGN tot_vllanmto = 0
             tot_vlsomado = 0
             qtreg        = 0
             aux_flgrodape = FALSE
             erro = TRUE.
       
      HIDE FRAME ab NO-PAUSE.
      HIDE FRAME cc NO-PAUSE.
      HIDE FRAME DIF NO-PAUSE.
      HIDE FRAME t NO-PAUSE.
      HIDE FRAME ok NO-PAUSE.
      HIDE FRAME demi NO-PAUSE.
      HIDE FRAME conta NO-PAUSE.

      CLEAR FRAME conta ALL NO-PAUSE.

      INPUT STREAM s1 FROM VALUE(arquivo) NO-ECHO.
     
      SET STREAM s1 tipo refere empresa c1 c2 NO-ERROR.
      
      IF   tipo <> 1 THEN
           DO:
               BELL.
               MESSAGE "Registro de controle faltando ou invalido!".
               LEAVE. 
           END.
    
      IF   LENGTH(arquivo) > 14  THEN /* cdempres 99999 */
           ASSIGN aux_cdempres = INT(SUBSTR(arquivo,02,5))
                  aux_data     = SUBSTRING(arquivo,7,8).
      ELSE
           ASSIGN aux_cdempres = INT(SUBSTR(arquivo,02,2))
                  aux_data     = SUBSTRING(arquivo,4,8).
      
      IF   resposta THEN
           DO:
               IF   arquivo BEGINS "f"   OR
                    arquivo BEGINS "p"   THEN     /****  FOLHA  ****/
                    DO:
                     /*   IF   STRING(aux_dtultdia,"99999999") <> aux_data THEN
                             DO:
                                 BELL.
                                 MESSAGE "Data no nome do arquivo errada!".
                                 LEAVE.
                             END. 
                       */
                        IF   aux_dtultdia <> refere THEN
                             DO:
                                 BELL.
                                 MESSAGE "Data no arquivo errada!".
                                 LEAVE.
                             END.
                        
                        FIND crapemp WHERE crapemp.cdcooper = glb_cdcooper AND
                                           crapemp.cdempres = aux_cdempres
                                           NO-LOCK NO-ERROR.
            
                             IF   NOT AVAILABLE crapemp THEN
                                  DO:
                                      BELL.
                                      MESSAGE "Empresa inexistente. " + 
                                              "Verifique nome arquivo " arquivo.
                                      LEAVE.
                                  END.
        
                             IF   crapemp.cdempfol <> empresa THEN
                                  DO:
                                      BELL.
                                      MESSAGE "Empresa invalida no arquivo "
                                              crapemp.cdcooper
                                              crapemp.cdempfol empresa
                                              arquivo.
                                      LEAVE.
                                  END.
                    END.
               
               ELSE                   /****  CONVENIO  ****/
                    
                  /*  IF   STRING(aux_dtultdia,"99999999") <>  
                         SUBSTRING(arquivo,1,8) THEN
                         DO:
                             BELL.
                             MESSAGE "Data no nome do arquivo errada!".
                             LEAVE.
                         END.
                    
                    IF   aux_dtultdia <> refere THEN
                         DO:
                             BELL.
                             MESSAGE "Data no arquivo errada!".
                             LEAVE.
                         END.
                    */
           END.
      
      ELSE
           IF   arquivo BEGINS "f"   OR
                arquivo BEGINS "p"   THEN     /****  FOLHA  ****/
                DO:
                    IF   STRING(aux_dtultdia,"99999999") = aux_data  THEN
                         DO:
                             BELL.
                             MESSAGE "Data no nome do arquivo nao pode ser " +
                                     "ultimo dia do mes!".
                             LEAVE.
                         END.
        
                    IF   aux_dtultdia = refere THEN
                         DO:
                             BELL.
                             MESSAGE "Data no arquivo nao pode ser ultimo " +
                                     "dia do mes!".
                             LEAVE.
                         END.
                       
                    IF   aux_data <> STRING(refere,"99999999") THEN
                         DO:
                             BELL.
                             MESSAGE "Datas diferentes. Verifique arquivo.".
                             LEAVE.
                         END.
                     
                    FIND crapemp WHERE crapemp.cdcooper = glb_cdcooper AND
                                       crapemp.cdempres = aux_cdempres
                                       NO-LOCK NO-ERROR.
            
                         IF   NOT AVAILABLE crapemp THEN
                              DO:
                                  BELL.
                                  MESSAGE "Empresa inexistente. " + 
                                          "Verifique nome arquivo " arquivo.
                                  LEAVE.
                              END.
        
                         IF   crapemp.cdempfol <> empresa THEN
                              DO:
                                  BELL.
                                  MESSAGE "Empresa invalida no arquivo "
                                           arquivo.
                                  LEAVE.
                              END.
                END.
           
           ELSE             /****  CONVENIO  ****/
                
                DO:
                    IF   STRING(aux_dtultdia,"99999999") =  
                         SUBSTRING(arquivo,1,8) THEN
                         DO:
                             BELL.
                             MESSAGE "Data no nome do arquivo nao " +
                                     "pode ser ultimo dia do mes!".
                             LEAVE.
                         END.
 
                    IF   aux_dtultdia = refere THEN
                         DO:
                             BELL.
                             MESSAGE "Data no arquivo nao pode " +
                                     "ser ultimo dia do mes!".
                             LEAVE.
                         END.
            
                    IF   SUBSTRING(arquivo,1,8) <> 
                         STRING(refere,"99999999") THEN
                         DO:
                             BELL.
                             MESSAGE "Datas diferentes. Verifique arquivo.".
                             LEAVE.
                         END.
                END.             
   
   
      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
     
         SET STREAM s1 tipo seq conta aux_vllanmto hst data.
                 
                 IF   LENGTH(STRING(hst)) > 3   THEN
              DO:
                 ASSIGN aux_dscritic =  "HISTORICO INCORRETO. VERIFIQUE ARQUIVO.".
                 LEAVE.
              END.
         IF   tipo = 0 THEN
              DO:          
                  IF NOT CAN-DO("1,2,3,4,5,6,7,8,9,0",SUBSTRING(data,1,1)) AND
                      data <> "" THEN
                     DO:
                        ASSIGN aux_dscritic = "ATENCAO!! COLUNA DE DATA POSSUI CARACTERES." 
                                            +  "Conta:" + string(conta,"99999999999"). 
                        LEAVE.        
                     END.
 
                  cdata = DATE(data) NO-ERROR.
                  
                  IF   ERROR-STATUS:ERROR THEN
                       DO:
                          MESSAGE "ATENCAO!! DATA COM FORMATO INCORRETO." 
                                                "Conta:" conta. 
                                                  PAUSE.
                       END.

                  IF INDEX(aux_vllanmto,"-") <> 0 THEN
                     DO:
                        ASSIGN aux_dscritic = "ATENCAO!! ARQUIVO COM VALOR NEGATIVO." +
                                              "Conta:" + string(conta,"99999999999"). 
                        
                        LEAVE.
                     END.
                  ELSE IF SUBSTR(aux_vllanmto,10,1) = "." THEN
                       MESSAGE "ATENCAO!! VALORES COM PONTOS".
                  ELSE
                       valor = DECIMAL(aux_vllanmto).
                  
                  tot_vllanmto[hst] = tot_vllanmto[hst] + valor.
                  qtreg = qtreg + 1.

                  FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                                     crapass.nrdconta = conta 
                                     NO-LOCK NO-ERROR.

                  IF   NOT AVAILABLE crapass   THEN
                       DO:
                           DISPLAY conta WITH FRAME conta.
               
                           down with frame conta.
                       END.
                  ELSE
                  IF   crapass.dtdemiss <> ? THEN
                       DO:
                           DISPLAY conta  WITH FRAME demi.
                    
                           DOWN WITH FRAME demi.
                       END.
                       
                 /*message crapass.nrdconta crapass.nmprimtl. pause.*/
              END.
         ELSE
         IF   tipo = 9 THEN
              DO:
                  ASSIGN arq_vlsomado = DECIMAL(aux_vllanmto)
                         aux_flgrodape = TRUE
                         erro = FALSE.
                  
                  cdata = DATE(data) NO-ERROR.

                  IF   ERROR-STATUS:ERROR THEN
                       DO:
                          MESSAGE "ATENCAO!! DATA DE REGISTRO DE CONTROLE NO"
                                  "RODAPE C/ PROBLEMA.". PAUSE.
                       END.

                  LEAVE.
              END.

      END.  /* Fim do DO WHILE */
    
      CLEAR FRAME ab ALL NO-PAUSE.
    
      DO aux_contador = 1 TO 9999:
         
         IF  NOT aux_flgrodape   THEN
             LEAVE.

         IF tot_vllanmto[aux_contador] > 0  THEN
            DO:
                DISPLAY aux_contador LABEL "Historico" FORMAT "z,zz9"
                        tot_vllanmto[aux_contador] LABEL "Total"
                        WITH 10 DOWN FRAME ab OVERLAY.

                DOWN WITH FRAME ab.
     
                tot_vlsomado      = tot_vlsomado + tot_vllanmto[aux_contador].
            END.

      END.   /* Fim do DO... */

      IF   NOT aux_flgrodape THEN
           DO:
               HIDE FRAME cc NO-PAUSE.
               HIDE FRAME conta NO-PAUSE.    
               HIDE FRAME demi NO-PAUSE.
               HIDE FRAME ab NO-PAUSE.
               DISP aux_dscritic WITH FRAME err.
           END.
      ELSE
           DO:
               DISPLAY tot_vlsomado WITH FRAME cc.
               /*  DISPLAY qtreg WITH FRAME qt.   */

               IF   tot_vlsomado <> arq_vlsomado  THEN
                    DO:
                        DISPLAY arq_vlsomado WITH FRAME t.
                        VIEW FRAME DIF.
                    END.
               ELSE
                    VIEW FRAME ok.
           END.
           
      PAUSE 0.

   END.  /* Fim do REPEAT */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            LEAVE.
        END.

   IF  erro  THEN
       DO:
           INPUT STREAM s1 CLOSE.
           NEXT.
       END.

   LEAVE.

END.  /*  Fim do REPEAT */
