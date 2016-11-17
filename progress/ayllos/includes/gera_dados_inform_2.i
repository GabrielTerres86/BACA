/* ...........................................................................

   Programa: includes/gera_dados_inform_2.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio
   Data    : Setembro/2006                     Ultima atualizacao: 22/08/2007

   Dados referentes ao programa:

   Frequencia:
   Objetivo  : Gerar os dados para a frente dos informativos gerados atraves
               do FORMPRINT. Dois formularios por pagina (frente e verso)

   Alteracoes: 03/01/2007 - Quebrar arquivo em varios quando for muito grande,
                            respeitando o parametro "qtmaxarq" (Julio).
                            
               09/07/2007 - Aumentado format das variaveis que recebem caminhos
                            de imagens (Diego).
                            
               22/08/2007 - Incluido tratamento referente AR-Correio (Diego).
   
............................................................................ */ 

FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                   craptab.nmsistem = "CRED"        AND
                   craptab.tptabela = "USUARI"      AND
                   craptab.cdempres = 11            AND
                   craptab.cdacesso = aux_cdacesso  AND
                   craptab.tpregist = 1             NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craptab   THEN      
     ASSIGN aux_dsmsgext = "".
ELSE
     ASSIGN aux_dsmsgext[1] = SUBSTRING(craptab.dstextab,001,50)
            aux_dsmsgext[2] = SUBSTRING(craptab.dstextab,051,50)
            aux_dsmsgext[3] = SUBSTRING(craptab.dstextab,101,50)
            aux_dsmsgext[4] = SUBSTRING(craptab.dstextab,151,50)
            aux_dsmsgext[5] = SUBSTRING(craptab.dstextab,201,50)
            aux_dsmsgext[6] = SUBSTRING(craptab.dstextab,251,50)
            aux_dsmsgext[7] = SUBSTRING(craptab.dstextab,301,50).

FIND LAST cratext NO-LOCK USE-INDEX cratext1 NO-ERROR.

IF   AVAILABLE cratext   THEN
     ASSIGN aux_nrseqdir = IF cratext.nrseqint MODULO 2 = 1 THEN
                              (TRUNCATE(cratext.nrseqint / 2, 0) + 2)
                           ELSE
                              (cratext.nrseqint / 2) + 1
            aux_nrpagina = 0.

FOR EACH cratext BY cratext.nrseqint:
  
    IF   cratext.nrseqint < aux_nrseqdir   THEN
         ASSIGN cratext.nrpagina = cratext.nrseqint
                cratext.dsladopg = "E"
                cratext.nrsequen = cratext.nrseqint.
    ELSE
         ASSIGN aux_nrpagina = aux_nrpagina + 1
                cratext.nrpagina = aux_nrpagina
                cratext.dsladopg = "D"
                cratext.nrsequen = cratext.nrseqint.              
END.

FIND cratext WHERE cratext.nrpagina = (aux_nrpagina + 1) AND
                   cratext.dsladopg = "E"   NO-LOCK NO-ERROR.

IF   AVAILABLE cratext   THEN
     DO:
         CREATE cratext.
         ASSIGN cratext.nrpagina    = aux_nrpagina + 1
                cratext.dsladopg    = "D"
                cratext.dsintern[1] = "#".
     END.

IF   aux_qtmaxarq = 0   THEN
     OUTPUT STREAM str_1 TO VALUE(aux_nmarqdat).
ELSE
     OUTPUT STREAM str_1 TO VALUE(aux_nmarqdat + "01.dat").
                       
FOR EACH cratext WHERE cratext.dsladopg = "E" NO-LOCK BY cratext.nrpagina:

    IF   (aux_qtmaxarq > 0) AND (cratext.nrpagina MODULO aux_qtmaxarq = 0) THEN
         DO:
             OUTPUT STREAM str_1 CLOSE.
             ASSIGN aux_nrarquiv = aux_nrarquiv + 1.
             OUTPUT STREAM str_1 TO VALUE(aux_nmarqdat +  
                                          STRING(aux_nrarquiv, "99") + 
                                          ".dat").
         END.

    ASSIGN aux_dsultlin = "ORDEM:" + STRING(cratext.nrdordem, "999") +
                       "        TIPO:" + STRING(cratext.tpdocmto, "999") + 
                       "        SEQUENCIA:" + 
                       STRING(cratext.nrsequen,"999,999").
    
    FIND cratext_dir WHERE cratext_dir.nrpagina = cratext.nrpagina AND
                           cratext_dir.dsladopg = "D" NO-LOCK NO-ERROR.

    /***** EXTERNO LADO ESQUERDO **********/
    IF   cratext.indespac = 1   THEN /***** CORREIO *******/
         DO:
            PUT STREAM str_1 cratext.nmprimtl     FORMAT "x(51)"       SKIP
                             cratext.dsender1     FORMAT "x(50)"       SKIP
                             "BAIRRO:" cratext.dsender2 FORMAT "x(50)" SKIP.
                             
            /* Emprestimos em atraso  */
            IF   cratext.tpdocmto = 10  AND  cratext.numeroar <> 0  THEN   
                 PUT STREAM str_1 
                             "CEP:" cratext.nrcepend FORMAT "99,999,999"
                             "   "      
                             "AR:" cratext.numeroar   FORMAT "999999"
                             "       "
                             "EMISSAO:" STRING(cratext.dtemissa,"99/99/9999")
                             FORMAT "x(10)"                            SKIP.
            ELSE
                 PUT STREAM str_1
                             "CEP:" cratext.nrcepend FORMAT "99,999,999"   
                             FILL(" ", 11)
                             "EMISSAO:" STRING(cratext.dtemissa,"99/99/9999")   
                             FORMAT "x(10)"                            SKIP.
                             
            PUT STREAM str_1 aux_dsultlin          FORMAT "x(50)"      SKIP
                             aux_dsmsgext[1]       FORMAT "x(50)"      SKIP
                             aux_dsmsgext[2]       FORMAT "x(50)"      SKIP
                             aux_dsmsgext[3]       FORMAT "x(50)"      SKIP
                             aux_dsmsgext[4]       FORMAT "x(50)"      SKIP
                             aux_dsmsgext[5]       FORMAT "x(50)"      SKIP
                             aux_dsmsgext[6]       FORMAT "x(50)"      SKIP
                             aux_dsmsgext[7]       FORMAT "x(50)"      SKIP
                             TRIM(aux_imlogoex)    FORMAT "x(80)"      SKIP
                             TRIM(aux_impostal)    FORMAT "x(80)"      SKIP
                             TRIM(aux_imcorre2)    FORMAT "x(80)"      SKIP
                             SKIP.
         END.
    ELSE     
         DO:  /****** SECAO *******/
            PUT STREAM str_1 cratext.nmempres         FORMAT "x(20)"
                             cratext.nmsecext         FORMAT "x(25)"  SKIP
                             cratext.nmagenci         FORMAT "x(24)"  
                             "CONTA/DV: " 
                             STRING(cratext.nrdconta,"zzzz,zz9,9")
                             FORMAT "x(10)"                               SKIP
                             STRING(cratext.nmprimtl,"x(40)") 
                             FORMAT "x(40)"                               SKIP
                             "EMISSAO:" STRING(cratext.dtemissa,"99/99/9999")   
                             FORMAT "x(10)"                               SKIP
                             aux_dsultlin          FORMAT "x(50)"      SKIP
                             aux_dsmsgext[1]       FORMAT "x(50)"      SKIP
                             aux_dsmsgext[2]       FORMAT "x(50)"      SKIP
                             aux_dsmsgext[3]       FORMAT "x(50)"      SKIP
                             aux_dsmsgext[4]       FORMAT "x(50)"      SKIP
                             aux_dsmsgext[5]       FORMAT "x(50)"      SKIP
                             aux_dsmsgext[6]       FORMAT "x(50)"      SKIP
                             aux_dsmsgext[7]       FORMAT "x(50)"      SKIP
                             TRIM(aux_imlogoex)    FORMAT "x(80)"      SKIP
                             TRIM(aux_imgvazio)    FORMAT "x(80)"      SKIP(1).
         END.

    ASSIGN aux_dsultlin = "ORDEM:" + STRING(cratext_dir.nrdordem, "999") +
                       "        TIPO:" + STRING(cratext_dir.tpdocmto, "999") + 
                       "        SEQUENCIA:" + 
                       STRING(cratext_dir.nrsequen,"999,999").

    /******* EXTERNO LADO DIREITO ************/
    IF   cratext_dir.indespac = 1   THEN /* CORREIO */
         DO:
            PUT STREAM str_1 cratext_dir.nmprimtl     FORMAT "x(51)"       SKIP
                             cratext_dir.dsender1     FORMAT "x(50)"       SKIP
                             "BAIRRO:" cratext_dir.dsender2 FORMAT "x(50)" SKIP.
                             
            /* Emprestimos em atraso  */
            IF   cratext_dir.tpdocmto = 10  AND  cratext_dir.numeroar <> 0 THEN
                 PUT STREAM str_1 
                             "CEP:" cratext_dir.nrcepend FORMAT "99,999,999"
                             "   "      
                             "AR:" cratext_dir.numeroar   FORMAT "999999"
                             "       "
                             "EMISSAO:"
                             STRING(cratext_dir.dtemissa,"99/99/9999")
                             FORMAT "x(10)"                            SKIP.
            ELSE
                 PUT STREAM str_1
                             "CEP:" cratext_dir.nrcepend FORMAT "99,999,999"   
                             FILL(" ", 11)
                             "EMISSAO:"
                             STRING(cratext_dir.dtemissa,"99/99/9999")   
                             FORMAT "x(10)"                            SKIP.
                             
            PUT STREAM str_1 aux_dsultlin          FORMAT "x(50)"      SKIP
                             aux_dsmsgext[1]       FORMAT "x(50)"      SKIP
                             aux_dsmsgext[2]       FORMAT "x(50)"      SKIP
                             aux_dsmsgext[3]       FORMAT "x(50)"      SKIP
                             aux_dsmsgext[4]       FORMAT "x(50)"      SKIP
                             aux_dsmsgext[5]       FORMAT "x(50)"      SKIP
                             aux_dsmsgext[6]       FORMAT "x(50)"      SKIP
                             aux_dsmsgext[7]       FORMAT "x(50)"      SKIP
                             TRIM(aux_imlogoex) FORMAT "x(80)"         SKIP
                             TRIM(aux_impostal) FORMAT "x(80)"         SKIP
                             TRIM(aux_imcorre2) FORMAT "x(80)"         SKIP
                             SKIP.
         END.
    ELSE     
         DO: /******** SECAO ***********/
            PUT STREAM str_1 cratext_dir.nmempres         FORMAT "x(20)"
                             cratext_dir.nmsecext         FORMAT "x(25)"  SKIP
                             cratext_dir.nmagenci         FORMAT "x(24)"  
                             "CONTA/DV: " 
                             STRING(cratext_dir.nrdconta,"zzzz,zz9,9")
                             FORMAT "x(10)"                               SKIP
                             STRING(cratext_dir.nmprimtl,"x(40)") 
                             FORMAT "x(40)"                               SKIP
                             "EMISSAO:" 
                             STRING(cratext_dir.dtemissa, "99/99/9999")   
                             FORMAT "x(10)"                               SKIP
                             aux_dsultlin          FORMAT "x(50)"         SKIP
                             aux_dsmsgext[1]       FORMAT "x(50)"         SKIP
                             aux_dsmsgext[2]       FORMAT "x(50)"         SKIP
                             aux_dsmsgext[3]       FORMAT "x(50)"         SKIP
                             aux_dsmsgext[4]       FORMAT "x(50)"         SKIP
                             aux_dsmsgext[5]       FORMAT "x(50)"         SKIP
                             aux_dsmsgext[6]       FORMAT "x(50)"         SKIP
                             aux_dsmsgext[7]       FORMAT "x(50)"         SKIP
                             TRIM(aux_imlogoex)    FORMAT "x(80)"         SKIP
                             TRIM(aux_imgvazio)    FORMAT "x(80)"      SKIP(1).
         END.        

    ASSIGN aux_qtintern = 1.
    
    /* INTERNO LADO ESQUERDO */
    PUT STREAM str_1 TRIM(aux_imlogoin)              FORMAT "x(60)"  SKIP.
    DO WHILE cratext.dsintern[aux_qtintern] <> "#" AND aux_qtintern < 100:
      
       PUT STREAM str_1 cratext.dsintern[aux_qtintern]  FORMAT "x(80)"  SKIP. 
                         
       ASSIGN aux_qtintern = aux_qtintern + 1.
    END.
    
    ASSIGN aux_qtintern = 1.

    PUT STREAM str_1 TRIM(aux_imlogoin)       FORMAT "x(60)"      SKIP.    
    /* INTERNO LADO ESQUERDO */
    DO WHILE cratext_dir.dsintern[aux_qtintern] <> "#" AND aux_qtintern < 100:
        PUT STREAM str_1 cratext_dir.dsintern[aux_qtintern] FORMAT "x(80)" 
                         SKIP.

       ASSIGN aux_qtintern = aux_qtintern + 1.
    END.

END. /* FOR EACH cratext.... */

OUTPUT STREAM str_1 CLOSE.

/* ......................................................................... */
