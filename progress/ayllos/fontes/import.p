/* --------------------------------------------------------------------------

    ################################################################
    
   !!!!! ATENCAO !!!! O campo crapcop.nmrescop deve estar atualizado.
    
    ################################################################
    
    AUTOR: Diego
   
 Objetivo:  1 - IMPORTAR CRAPTAB'S  NA NOVA COOPERATIVA.
                GERA RELATORIO rl/craptab_importados.txt
   
   Alteracoes: 16/03/2012 - Tratamento "VALORBAIXA" (Diego).
   
               05/04/2012 - Deixar criar registros "HRTR" e "HRGUIAS" (Diego).
               
               09/04/2012 - Tratar "TELESALDOS" (Diego).
               
               03/06/2012 - Nao criar "PROPOSTEPR"  (Diego).
               
               12/07/2012 - Nao criar "CONTACONVE" (Diego).
               
               21/11/2012 - Retirado restrição de numeracao de contratos de
                            emprestimos (David Kruger).	
                            
               11/12/2013 - Inclusao de VALIDATE craptab (Carlos)

               02/01/2014 - removido "IF" que tratava craptab "FILAIMPRES" 
                            (Tiago).
                            
               02/04/2015 - Projeto de separação contábeis de PF e PJ.
                            Ajustando atualizacao do dstextab de "VALORBAIXA"
                            para que sejam inseridos as informacoes separadas
                            por PF e PJ. (Andre Santos - SUPERO).
                            
               25/05/2015 - Adicionado tratamento para "NUMCTREMPR". (Reinert)

---------------------------------------------------------------------------- */


DEF        VAR tel_nmarquiv AS CHAR                                  NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR aux_confirma AS CHAR FORMAT "!(1)"                    NO-UNDO.
DEF        VAR aux_nmarqimp AS CHAR                                  NO-UNDO.
DEF        VAR aux_contador AS INT                                   NO-UNDO.
DEF        VAR aux_cdcooper AS INT                                   NO-UNDO.

DEF STREAM str_1.

DEF TEMP-TABLE w-craptab  NO-UNDO LIKE craptab.     

     
FORM SKIP(1)
     aux_cdcooper FORMAT "zz9"  AT 3 LABEL "Nova Coop."
     HELP "Informe o codigo da nova cooperativa"
     SKIP(1)
     "Diretorio do arquivo a ser importado"  AT  3 SKIP
     tel_nmarquiv  FORMAT "x(70)" NO-LABEL   AT  3 
     HELP "Informe o diretorio do arquivo a ser importado" 
     WITH ROW 10 OVERLAY SIDE-LABELS CENTERED TITLE "IMPORTAR TAB'S"
     FRAME f_diretorio.
     
FORM "RELACAO DE REGISTROS(craptab) IMPORTADOS"  SKIP(1)
     WITH NO-BOX NO-LABEL CENTERED FRAME f_titulo.
     

ASSIGN aux_nmarqimp = "rl/" + "craptab_importados.txt".
            
UPDATE aux_cdcooper tel_nmarquiv WITH FRAME f_diretorio.

FIND crapcop WHERE crapcop.cdcooper = aux_cdcooper NO-LOCK NO-ERROR.

RUN Confirma.
IF   aux_confirma = "S"  THEN
     DO:
         IF   SEARCH(tel_nmarquiv) = ?   THEN
              DO:
                  MESSAGE "Arquivo nao existe.".
                  NEXT.
              END.
              
         MESSAGE "IMPORTANDO ARQUIVO . . .".
                                       
         INPUT FROM VALUE(tel_nmarquiv).

         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                             
            CREATE w-craptab.
            IMPORT w-craptab.

            IF  (w-craptab.cdacesso BEGINS "VLTARIF" AND 
                 w-craptab.cdacesso <> "VLTARIF040"  AND
                 w-craptab.cdacesso <> "VLTARIF351"  AND
                 w-craptab.cdacesso <> "VLTARIFDIV"  AND
                 w-craptab.cdacesso <> "VLTARIFADT")  OR
                 w-craptab.tptabela = "BLQRGT"       OR
                 /**
                 w-craptab.cdacesso = "CONVTALOES"   OR /* MENU */ 
                 **/
                 w-craptab.cdacesso = ""             OR /* BRANCO */
                 w-craptab.cdacesso = "COMPBB"       OR
                 w-craptab.cdacesso = "0000085448"   OR
                 w-craptab.cdacesso = "99999999"     OR
                 w-craptab.cdacesso = "CONVEMBRAT"   OR
                 w-craptab.cdacesso = "CONVFOLHAS"   OR
                 w-craptab.cdacesso = "CONVERREAL"   OR
                 w-craptab.cdacesso = "crdevdivrs"   OR
                 w-craptab.cdacesso = "DESPRDCAII"   OR
                 w-craptab.cdacesso = "DEPJUDCPMF"   OR
                 w-craptab.cdacesso = "EMPRESINOP"   OR
                 w-craptab.cdacesso = "EXESOLMOED"   OR
                 w-craptab.cdacesso = "EXTRDIARIO"   OR
                 w-craptab.cdacesso = "CHEQSALARI"   OR
                 w-craptab.cdacesso = "bloqcbrbcb"   OR
                 /* Desenvolvimento */
                 w-craptab.cdacesso = "LOCALIDADE"    OR
                 w-craptab.cdacesso BEGINS "ANUIDCAR" OR 
                 w-craptab.cdacesso BEGINS "EA2"      OR
                 w-craptab.cdacesso = "DC20031125"   OR
                 w-craptab.cdacesso = "EMAILDOTED"   OR
                 w-craptab.cdacesso = "EXERESFAIX"   OR
                 w-craptab.cdacesso = "LOTEINTO31"   OR
                 w-craptab.cdacesso = "NUMULTCHTR"   OR
                 w-craptab.cdacesso = "SAQMAXCASH"   OR
                 w-craptab.cdacesso = "TESTECONVE"   OR
                 w-craptab.cdacesso = "TH30092002"   OR
                 w-craptab.cdacesso = "USUARIOMIC"   OR
                 w-craptab.cdacesso = "LIMCNVEMPR"   OR
                 w-craptab.cdacesso = "PROCESSARQ"   OR
                 w-craptab.cdacesso = "DESPESAMES"   OR
                 w-craptab.cdacesso BEGINS "ENTRGCAR" OR
        /***     w-craptab.cdacesso BEGINS "HRTR"    OR ***/
        /***     w-craptab.cdacesso BEGINS "HRGUIAS" OR ***/
                 w-craptab.cdacesso BEGINS "CREDFORNEC" OR
                 w-craptab.cdacesso = "EMAILDOTED"   OR
                 w-craptab.cdacesso BEGINS "CM"      OR
                 w-craptab.cdacesso BEGINS "CB"      OR
                 w-craptab.cdacesso BEGINS "DC"      OR
                 w-craptab.cdacesso BEGINS "EA"      OR
                 w-craptab.cdacesso BEGINS "EC"      OR
                 w-craptab.cdacesso BEGINS "EP"      OR
                 w-craptab.cdacesso BEGINS "IS"      OR
                 w-craptab.cdacesso BEGINS "SD"      OR  
                 w-craptab.cdacesso BEGINS "CH"      OR
                 w-craptab.cdacesso = "COMPEL"       OR
                 w-craptab.cdacesso = "DOCTOS"       OR
                 w-craptab.cdacesso = "MOVGPS"       OR
                 w-craptab.cdacesso = "PROCES"       OR
                 w-craptab.cdacesso = "TITULO"       OR
                 w-craptab.cdacesso = "CTASHERING"   OR
                 w-craptab.cdacesso = "CONVEMBRAT"   OR
                 (w-craptab.cdacesso = "DIADOPAGTO"   AND
                  NOT(CAN-DO("11,81,88",STRING(w-craptab.tpregist))))  OR
                 w-craptab.cdacesso = "CONVBANCOS"   OR
                 w-craptab.cdacesso = "LOCALIDADE"   OR
                 w-craptab.cdacesso = "CORRESPOND"   OR   
                (w-craptab.cdacesso = "NUMLOTEFOL"  AND
                 NOT(CAN-DO("11,81,88",STRING(w-craptab.tpregist))))  OR  
                ( w-craptab.cdacesso = "NUMLOTECOT"   AND
                 NOT(CAN-DO("11,81,88",STRING(w-craptab.tpregist))))  OR
                (w-craptab.cdacesso = "NUMLOTEEMP"   AND
                 NOT(CAN-DO("11,81,88",STRING(w-craptab.tpregist))))  OR
                 w-craptab.cdacesso = "VLOPCREDAS"                    OR
                 w-craptab.cdacesso = "PROPOSTEPR"                    OR
                 w-craptab.cdacesso = "CONTACONVE" THEN
                 DO:
                     DELETE w-craptab.
                     NEXT.
                 END.
            ELSE
                 DO: 
                     /* verifica se o registro ja existe */ 
                     FIND craptab WHERE 
                          craptab.cdcooper = crapcop.cdcooper       AND
                          craptab.cdacesso = w-craptab.cdacesso AND
                          craptab.cdempres = w-craptab.cdempres AND
                          craptab.nmsistem = w-craptab.nmsistem AND
                          craptab.tpregist = w-craptab.tpregist AND
                          craptab.tptabela = w-craptab.tptabela
                          NO-LOCK NO-ERROR.
                                      
                     IF   AVAIL craptab  THEN
                          DO:
                              DELETE w-craptab.
                              NEXT.
                          END.
                          
                     CREATE craptab.
                     ASSIGN craptab.cdacesso = w-craptab.cdacesso  
                            craptab.cdempres = w-craptab.cdempres
                            craptab.dstextab = w-craptab.dstextab
                            craptab.nmsistem = w-craptab.nmsistem
                            craptab.tpregist = w-craptab.tpregist
                            craptab.tptabela = w-craptab.tptabela.

                     IF   w-craptab.cdcooper <> 0  THEN
                          ASSIGN craptab.cdcooper = crapcop.cdcooper.
                                                              
                     IF   w-craptab.cdacesso = "CONVTALOES"  OR
                          w-craptab.cdacesso = "NUMCTREMPR"  OR
                          w-craptab.cdacesso = "CNVBANCOOB"  OR
                          w-craptab.cdacesso = "MICROFILMA"  OR
                          w-craptab.cdacesso = "TELESALDOS"  THEN
                          ASSIGN craptab.cdempres = crapcop.cdcooper.

                     IF   w-craptab.cdacesso = "MENSAGEM" OR
                          w-craptab.cdacesso = "MENAVS"   OR
                          w-craptab.cdacesso = "MSGCON"   OR
                          w-craptab.cdacesso = "MENAPL"   OR
                          w-craptab.cdacesso = "MENEXT"   OR
                          w-craptab.cdacesso = "MSGSOB"   THEN
                          ASSIGN craptab.dstextab = " ".
                                 
                     IF   w-craptab.cdacesso = "MICROFILMA"  AND
                          w-craptab.tpregist = 0  THEN
                          ASSIGN craptab.dstextab = crapcop.dssigaut.
                                 
                     IF   w-craptab.cdacesso = "DIADOPAGTO"  THEN
                          ASSIGN craptab.cdempres = 0.
                          
                     IF   w-craptab.cdacesso = "VALORBAIXA"  THEN     
                          ASSIGN craptab.dstextab = "000000000000,00  " +
                                                    "000000000000,00  " +
                                                    "000000000000,00  " +
                                                    "000000000000,00  " +
                                                    "000000000000,00  " +
                                                    "000000000000,00".
                     VALIDATE craptab.
                 END.
         END.

         INPUT CLOSE.
                     
         HIDE MESSAGE NO-PAUSE.
                     
         /* LISTA TAB'S IMPORTADAS */
         OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp). 
                     
         VIEW STREAM str_1 FRAME f_titulo.
                     
         ASSIGN aux_contador = 0.
                     
         FOR EACH w-craptab BREAK BY w-craptab.cdacesso:
                     
             IF   FIRST-OF(w-craptab.cdacesso)  THEN           
                  DO:
                      DISPLAY STREAM str_1 w-craptab.cdacesso " "
                                           w-craptab.tptabela.
                                           
                      ASSIGN aux_contador = aux_contador + 1.
                  END.
                                 
             DOWN STREAM str_1.

         END.

         DISPLAY STREAM str_1 SKIP(2) aux_contador  LABEL "Qtd."
                              WITH SIDE-LABELS.
                                      
         OUTPUT STREAM str_1 CLOSE.
                     
         MESSAGE "ARQUIVO IMPORTADO COM SUCESSO !!!".             
                                                 
         PAUSE 3 NO-MESSAGE.   
                         
         LEAVE.
                        
     END.

PROCEDURE confirma.

   /* Confirma */
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      ASSIGN aux_confirma = "N".
             MESSAGE COLOR NORMAL "078 - Confirma a operacao? (S/N):" 
             UPDATE aux_confirma. 
             LEAVE.
   END.  /*  Fim do DO WHILE TRUE  */
           
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR   aux_confirma <> "S" THEN
        DO:
            MESSAGE "079 - Operacao nao efetuada.".
            PAUSE 2 NO-MESSAGE.
        END. /* Mensagem de confirmacao */

END PROCEDURE.
/* .......................................................................... */
