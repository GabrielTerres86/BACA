/* ............................................................................
                    
   Programa: Fontes/limcrd.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio
   Data    : Marco/2004                         Ultima atualizacao: 05/12/2016

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela LIMCRD - Cadastro de Limites de Cartoes de 
                                       Credito.   
   
   Alteracoes: 22/06/2004 - Alterar apenas os campos que nao fazem parte do 
                            indice (Julio).

               04/07/2005 - Alimentado campo cdcooper da tabela craptlc (Diego).

               22/11/2005 - Correcao no p_gravadados, para permitir salvar
                            tpcartao = 0 (Julio)               
               
               27/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
               
               03/10/2006 - Alterado para cooperativas singulares somente
                            consultar (Elton).

               10/02/2009 - Permissao ao operador 979 (Gabriel). 
               
               20/05/2009 - Alteracao CDOPERAD (Kbase).
               
               
               27/05/2011 - Alterado validacao da entrada de dados do campo 
                            TIPO DE CARTAO. Somente será permitido digitar 
                            "NACIONAL", "INTERNACIONAL", "GOLD" ou vazio.
                            
               13/12/2013 - Inclusao de VALIDATE craptlc (Carlos)
               
               09/10/2015 - Desenvolvimento do projeto 126. (James)
               
               05/12/2016 - Alterado campo dsdepart para cddepart.
                            PRJ341 - BANCENJUD (Odirlei-AMcom)

               06/09/2017 - Removida validacao por departamento.
                            Heitor (Mouts) - Chamado 746901
                            
............................................................................ */

{ includes/var_online.i }

DEF   VAR   aux_cddopcao AS CHAR                                      NO-UNDO.
DEF   VAR   aux_confirma AS CHAR  FORMAT "!(1)"                       NO-UNDO.
DEF   VAR   aux_contador AS INT                                       NO-UNDO.
DEF   VAR   aux_tpcartao AS CHAR INIT " ,NACIONAL,INTERNACIONAL,GOLD" NO-UNDO.
DEF   VAR   aux_insittab AS INT                                       NO-UNDO.
DEF   VAR   aux_indposic AS INT                                       NO-UNDO.

DEF   VAR   tel_cdadmcrd AS INT     FORMAT "zz9"                      NO-UNDO.
DEF   VAR   tel_insittab AS LOGICAL FORMAT "HABILITADO/DESABILITADO" 
                                    INITIAL TRUE                      NO-UNDO.
DEF   VAR   tel_nrctamae AS DECIMAL FORMAT "9999,9999,9999,9999"      NO-UNDO.
DEF   VAR   tel_dddebito AS INT     FORMAT "99"                       NO-UNDO.
DEF   VAR   tel_vllimcrd AS DECIMAL FORMAT "zzz,zzz,zz9.99"           NO-UNDO.
DEF   VAR   tel_cdlimcrd AS INT     FORMAT "zzzz9"                    NO-UNDO. 
DEF   VAR   tel_tpcartao AS CHAR    FORMAT "x(13)"                    NO-UNDO.
    
DEFINE TEMP-TABLE crawtlc                                             NO-UNDO
       FIELD  cdadmcrd  AS  INTEGER   FORMAT "zz9"
       FIELD  dsadmcrd  AS  CHARACTER FORMAT "x(25)"
       FIELD  cdlimcrd  AS  INTEGER   FORMAT "zzz99"
       FIELD  vllimcrd  AS  DECIMAL   FORMAT "zzz,zzz,zz9.99"
       FIELD  tpcartao  AS  INTEGER   FORMAT "z9"
       FIELD  dddebito  AS  INTEGER   FORMAT "zz"
       FIELD  insittab  AS  LOGICAL   FORMAT "H/D".           
       
DEF QUERY q_limite FOR crawtlc. 
                                     
DEF BROWSE b_limite QUERY q_limite 
                    DISP crawtlc.cdadmcrd COLUMN-LABEL "Adm"
                         crawtlc.dsadmcrd COLUMN-LABEL "Administradora" 
                         crawtlc.cdlimcrd COLUMN-LABEL "Lim"     
                         crawtlc.vllimcrd COLUMN-LABEL "Valor Limite"   
                         crawtlc.dddebito COLUMN-LABEL "Dia Deb"     
                         crawtlc.tpcartao COLUMN-LABEL "Tipo"
                         crawtlc.insittab COLUMN-LABEL "*"
                         WITH 5 DOWN CENTERED NO-BOX.
       
FORM SKIP(1)
     "Opcao:" AT 5
     glb_cddopcao HELP "Informe a opcao desejada: (C, A, I, E)"
     SKIP(1)
     b_limite AT 5 HELP "* -> Indicador de Situacao HABILITADO/DESABILITADO!" 
     WITH NO-LABEL ROW 5 COLUMN 2 SIZE 77 BY 10 OVERLAY NO-BOX FRAME f_limcrd.

FORM "ADMINISTRADORA:"  AT 5  tel_cdadmcrd 
     HELP "Informe o codigo da administradora de cartao de credito."   
     "TIPO DE CARTAO :" AT 45 tel_tpcartao 
     HELP "Utilize as setas para escolher o tipo de cartao." 
     VALIDATE(CAN-DO(",NACIONAL,INTERNACIONAL,GOLD", tel_tpcartao),
                     "513 - Tipo errado.")
     SKIP
     "NR. CONTA MAE :"  AT 5  tel_nrctamae    
     HELP "Informe o numero da Conta Mae"
     "COD.LIMITE CRED:" AT 45 tel_cdlimcrd   
     HELP "Informe o codigo do limite de cartao de credito" SKIP
     "VALOR LIMITE  :"  AT 5  tel_vllimcrd    
     HELP "Informe o valor do limite do cartao"
     "DIA DO DEBITO  :" AT 45 tel_dddebito 
     HELP "Informe o dia para debito da fatura" SKIP
     "SITUACAO      :"  AT 5  tel_insittab 
     HELP "Tecle 'H' para Habilitado ou 'D' para Desabilitado" SKIP(1)
     WITH NO-LABEL ROW 16 NO-BOX COLUMN 2 OVERLAY WIDTH 77 FRAME f_editlim.

FORM WITH NO-LABEL TITLE COLOR MESSAGE 
          "Cadastramento de Limites de Cartao de Credito"
          ROW 4 COLUMN 1 SIZE 80 BY 18 OVERLAY WITH FRAME f_moldura.

/********* IMPLEMENTACAO DE PROCEDURES INTERNAS ***********/

PROCEDURE p_editacampos:

   IF   glb_cddopcao = "A"   THEN
        SET tel_nrctamae    tel_vllimcrd   tel_insittab    
            WITH FRAME f_editlim.
   ELSE
        SET tel_cdadmcrd    tel_tpcartao      tel_nrctamae    
            tel_cdlimcrd    tel_vllimcrd      tel_dddebito
            tel_insittab    WITH FRAME f_editlim
                
   
   EDITING:

      READKEY.

      IF   FRAME-FIELD = "tel_tpcartao"            AND
           (KEYFUNCTION(LASTKEY) = "CURSOR-DOWN"   OR
            KEYFUNCTION(LASTKEY) = "CURSOR-LEFT")  THEN
           DO: 
               aux_indposic = aux_indposic + 1.

               IF   aux_indposic > NUM-ENTRIES(aux_tpcartao)   THEN                                 aux_indposic = 1.

               tel_tpcartao = TRIM(ENTRY(aux_indposic,aux_tpcartao)).
               DISPLAY tel_tpcartao WITH FRAME f_editlim.

           END.
      ELSE
          APPLY LASTKEY.
      
   END.
END.

PROCEDURE p_carregabrowser:

    /*FOR EACH crawtlc:
        DELETE crawtlc.
    END.*/
   
   EMPTY TEMP-TABLE crawtlc.

    FOR EACH craptlc WHERE craptlc.cdcooper = glb_cdcooper, 
       /*EACH crapadc OF craptlc NO-LOCK:*/
        EACH crapadc WHERE crapadc.cdcooper = glb_cdcooper      AND
                           crapadc.cdadmcrd = craptlc.cdadmcrd  NO-LOCK:
        
        CREATE crawtlc.        
        ASSIGN crawtlc.cdadmcrd = craptlc.cdadmcrd
               crawtlc.dsadmcrd = crapadc.nmresadm
               crawtlc.vllimcrd = craptlc.vllimcrd
               crawtlc.dddebito = craptlc.dddebito
               crawtlc.cdlimcrd = craptlc.cdlimcrd
               crawtlc.tpcartao = craptlc.tpcartao
               crawtlc.insittab = (craptlc.insittab = 0).
    END.

    OPEN QUERY q_limite FOR EACH crawtlc BY crawtlc.cdadmcrd 
                                            BY crawtlc.dddebito
                                               BY crawtlc.vllimcrd.
    
    ENABLE b_limite WITH FRAME f_limcrd.                              
END.

PROCEDURE p_carregalimite:

  DEF INPUT PARAMETER  par_cdadmcrd AS INTEGER                     NO-UNDO.
  DEF INPUT PARAMETER  par_dddebito AS INTEGER                     NO-UNDO.
  DEF INPUT PARAMETER  par_tpcartao AS INTEGER                     NO-UNDO.
  DEF INPUT PARAMETER  par_cdlimcrd AS INTEGER                     NO-UNDO. 
                                      
  FIND craptlc WHERE craptlc.cdcooper = glb_cdcooper  AND
                     craptlc.cdadmcrd = par_cdadmcrd  AND
                     craptlc.dddebito = par_dddebito  AND
                     craptlc.cdlimcrd = par_cdlimcrd  AND
                     craptlc.tpcartao = par_tpcartao  NO-LOCK NO-ERROR.
                     
  IF   AVAILABLE craptlc  THEN
       DO:
           ASSIGN tel_cdadmcrd = craptlc.cdadmcrd
                  tel_dddebito = craptlc.dddebito
                  tel_tpcartao = ENTRY(par_tpcartao + 1, aux_tpcartao)
                  tel_cdlimcrd = craptlc.cdlimcrd
                  tel_vllimcrd = craptlc.vllimcrd
                  tel_nrctamae = craptlc.nrctamae
                  tel_insittab = (craptlc.insittab = 0).               
       END.
END.

PROCEDURE p_gravadados:

  FIND craptlc WHERE craptlc.cdcooper = glb_cdcooper  AND
                     craptlc.cdadmcrd = tel_cdadmcrd  AND
                     craptlc.dddebito = tel_dddebito  AND
                     craptlc.cdlimcrd = tel_cdlimcrd  AND
                     craptlc.tpcartao = LOOKUP(tel_tpcartao, aux_tpcartao) - 1
                     EXCLUSIVE-LOCK NO-ERROR.

  IF   AVAILABLE craptlc   THEN
       ASSIGN craptlc.vllimcrd = tel_vllimcrd
              craptlc.nrctamae = tel_nrctamae
              craptlc.insittab = IF   tel_insittab   THEN 
                                      0
                                 ELSE
                                      1.
  ELSE
      DO:
          IF   CAN-FIND(crapadc WHERE crapadc.cdcooper = glb_cdcooper    AND
                                      crapadc.cdadmcrd = tel_cdadmcrd)   THEN
               DO:
                   CREATE craptlc.      
                   ASSIGN craptlc.cdadmcrd = tel_cdadmcrd
                          craptlc.dddebito = tel_dddebito
                          craptlc.cdlimcrd = tel_cdlimcrd
                          craptlc.tpcartao = 
                                     IF TRIM(tel_tpcartao) = "" THEN
                                        0
                                     ELSE   
                                        LOOKUP(tel_tpcartao, aux_tpcartao) - 1
                          craptlc.vllimcrd = tel_vllimcrd
                          craptlc.nrctamae = tel_nrctamae
                          craptlc.insittab = IF   tel_insittab THEN 
                                                  0
                                             ELSE
                                                  1
                          craptlc.cdcooper = glb_cdcooper.
                   VALIDATE craptlc.
               END.
          ELSE
               DO:
                   glb_cdcritic = 605.
                   RUN fontes/critic.p.
                   MESSAGE glb_dscritic.
                   BELL.
                   PAUSE.
                   HIDE MESSAGE.
               END.
      END.
END.

/************** IMPLEMENTACAO DE TRIGER'S  ********************/

ON VALUE-CHANGED, ENTRY OF b_limite
   DO:
       RUN p_carregalimite(INPUT crawtlc.cdadmcrd, INPUT crawtlc.dddebito,
                           INPUT crawtlc.tpcartao, INPUT crawtlc.cdlimcrd).
                           
       DISPLAY tel_cdadmcrd    tel_tpcartao
               tel_cdlimcrd    tel_vllimcrd   tel_dddebito
               tel_nrctamae    tel_insittab   WITH FRAME f_editlim.         

       IF   glb_cddopcao = "E"   THEN
            MESSAGE "Pressione <ENTER> para Excluir !".
   END.

ON RETURN OF b_limite
   DO:
       IF   INPUT glb_cddopcao = "A"   THEN
            DO:
                RUN p_editacampos.
                RUN p_gravadados.
                RUN p_carregabrowser.
            END.
       ELSE
       IF   INPUT glb_cddopcao = "E"   THEN
            DO:           
                aux_confirma = "N".

                MESSAGE COLOR NORMAL "Deseja realmente excluir este registro ?"
                        UPDATE aux_confirma.
                        
                IF   CAPS(aux_confirma) = "S"  THEN
                     DO:
                         glb_cdcritic = 236.
                         RUN fontes/critic.p.
               
                         DO aux_contador = 1 TO 10:     

                            FIND craptlc WHERE
                                      craptlc.cdcooper = glb_cdcooper      AND
                                      craptlc.cdadmcrd = crawtlc.cdadmcrd  AND
                                      craptlc.dddebito = crawtlc.dddebito  AND
                                      craptlc.cdlimcrd = crawtlc.cdlimcrd  AND
                                      craptlc.tpcartao = crawtlc.tpcartao
                                      EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                        
                            IF   NOT AVAILABLE craptlc   THEN
                                 DO:
                                     IF   LOCKED craptlc   THEN
                                          DO:
                                              MESSAGE glb_dscritic.
                                              BELL.
                                              PAUSE 1 NO-MESSAGE.
                                              NEXT.  
                                          END.
                                     LEAVE.
                                 END.
                            ELSE    
                                 DELETE craptlc.
                         END.

                     END.

                glb_cdcritic = 0.
                     
                RUN p_carregabrowser.
                
                DISPLAY b_limite WITH FRAME f_limcrd.
            END.      
   END.

/************** IMPLEMENTACAO DO PROGRAMA PRINCIPAL ***********/

VIEW FRAME f_moldura.

PAUSE(0).

glb_cddopcao = "C".  

DISPLAY glb_cddopcao WITH FRAME f_limcrd.

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      UPDATE glb_cddopcao WITH FRAME f_limcrd.
      LEAVE.

   END.

   HIDE MESSAGE.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   glb_nmdatela <> "LIMCRD"   THEN
                 DO:
                     HIDE FRAME f_limcrd.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   IF   aux_cddopcao <> glb_cddopcao   THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
        END.

   /*
   IF   glb_cddopcao <> "C"  THEN
        IF   glb_cddepart <>  8  AND /* COORD.ADM/FINANCEIRO */
             glb_cddepart <> 20  AND /* TI                   */
             glb_cddepart <>  9 THEN /* COORD.PRODUTOS       */
             DO:
                 BELL.
                 MESSAGE "Sistema liberado somente para Consulta !!!".
                 NEXT.
             END.*/
   
   IF   glb_cddopcao = "C"   THEN
        DO:
            RUN p_carregabrowser.

            DISPLAY tel_cdadmcrd    tel_tpcartao
                    tel_cdlimcrd    tel_vllimcrd      tel_dddebito
                    tel_nrctamae    tel_insittab      WITH FRAME f_editlim.

            DISPLAY b_limite WITH FRAME f_limcrd.
                      
            SET b_limite WITH FRAME f_limcrd.
        END.    
   ELSE
   IF   glb_cddopcao = "A"   THEN  
        DO:
            RUN p_carregabrowser.

            DISPLAY tel_cdadmcrd    tel_tpcartao
                    tel_cdlimcrd    tel_vllimcrd      tel_dddebito
                    tel_nrctamae    tel_insittab      WITH FRAME f_editlim.

            DISPLAY b_limite WITH FRAME f_limcrd.                            

            SET b_limite WITH FRAME f_limcrd.
        END.
   ELSE
   IF   glb_cddopcao = "E"   THEN  
        DO:
            RUN p_carregabrowser.

            DISPLAY tel_cdadmcrd    tel_tpcartao
                    tel_cdlimcrd    tel_vllimcrd      tel_dddebito
                    tel_nrctamae    tel_insittab      WITH FRAME f_editlim.

            DISPLAY b_limite WITH FRAME f_limcrd.

            SET b_limite WITH FRAME f_limcrd.
        END.              
   ELSE
   IF   glb_cddopcao = "I"   THEN
        DO:
            HIDE FRAME f_limcrd.
          
            ASSIGN tel_cdadmcrd = 0   
                   tel_tpcartao = ""
                   tel_cdlimcrd = 0  
                   tel_vllimcrd = 0.0    
                   tel_dddebito = 0
                   tel_nrctamae = 0.0  
                   tel_insittab = TRUE.
                   
            DISPLAY tel_cdadmcrd    tel_tpcartao
                    tel_cdlimcrd    tel_vllimcrd      tel_dddebito
                    tel_nrctamae    tel_insittab      WITH FRAME f_editlim.

            RUN p_editacampos.
            RUN p_gravadados.
            
            DISPLAY b_limite WITH FRAME f_limcrd.
        END.
END.

RELEASE craptlc.    

WAIT-FOR ENDKEY OF b_limite.

/* ......................................................................... */

