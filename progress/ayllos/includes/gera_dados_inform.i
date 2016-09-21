/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | includes/gera_dados_inform.i    | FORM0004.pc_gera_dados_inform     |
  +---------------------------------+-----------------------------------+
  
  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.
  
  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/




/* ............................................................................

   Programa: includes/gera_dados_inform.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Gabriel
   Data    : Maio/2010                     Ultima atualizacao: 12/12/2013

   Dados referentes ao programa:

   Frequencia: Sempre que chamada por outros programas.
   Objetivo  : Gerar os dados para a frente e verso dos informativos.
               Um formulario por pagina (frente e verso).
               Unificacao das includes/gera_dados_inform_1_postmix.i e
                              includes/gera_dados_inform_2_postmix.i .  

   Alteracoes: 06/05/2011 - Incluido os campos cratext.nrcepcdd e 
                            cratext.dscentra na descricao do CDD (Elton).
                            
               12/07/2011 - Inclusa gravacao na tabela de informativos do 
                            associado - crapinf (GATI - Eder).
                            
               25/03/2013 - Quando dividir arquivo, incluir carta separadora
                            no início do novo arquivo (Diego).
                            
               03/07/2013 - Ajuste ordenação PLSQL (Guilherme).
               
               12/12/2013 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( André Euzébio / SUPERO) 
                                         
.............................................................................*/


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

IF   aux_qtmaxarq = 0   THEN
     OUTPUT STREAM str_1 TO VALUE(aux_nmarqdat) PAGED PAGE-SIZE 84.
ELSE
     /* Para informativos que geram arquivos muito grande, divir em *01.dat, 
        *02.dat ... */ 
     OUTPUT STREAM str_1 TO VALUE(aux_nmarqdat + "01.dat") PAGED PAGE-SIZE 84.


ASSIGN aux_nrpagina = 0.


/* Ordenar a criaçao por faixa de CEP, CORREIO  */
FOR EACH cratext WHERE cratext.indespac = 1 EXCLUSIVE-LOCK  
                       BREAK BY cratext.nomedcdd
                                BY cratext.nrcepend 
                                   BY cratext.dsender1
                                     BY cratext.nrdconta: 

    ASSIGN aux_nrpagina     = aux_nrpagina + 1
        
           cratext.nrseqint = aux_nrpagina.

    /* Para informativos que geram arquivos muito grande, divir em *01.dat, 
        *02.dat ... */ 
    IF   (aux_qtmaxarq > 0) AND (aux_nrpagina MODULO aux_qtmaxarq = 0) THEN
          DO:
              OUTPUT STREAM str_1 CLOSE.
              
              ASSIGN aux_nrarquiv = aux_nrarquiv + 1.
              
              OUTPUT STREAM str_1 TO VALUE(aux_nmarqdat +  
                                           STRING(aux_nrarquiv, "99") + ".dat").

              DO TRANSACTION:

                 aux_nomedarq = SUBSTR(aux_nmarqdat,R-INDEX(aux_nmarqdat,"/") +
                                1,14) + "_" + STRING(aux_nrarquiv - 1,"99")   +
                                ".dat".

                 FIND LAST gndcimp WHERE 
                           gndcimp.cdcooper = glb_cdcooper   AND
                           gndcimp.dtmvtolt = glb_dtmvtolt   AND
                           gndcimp.nmarquiv = aux_nomedarq
                           EXCLUSIVE-LOCK NO-ERROR.

                 IF   AVAILABLE gndcimp   THEN
                      DO:
                          IF   gndcimp.flgenvio   THEN
                               DO:
                                   /* proximo sequencial */
                                   ASSIGN aux_numerseq = gndcimp.nrsequen + 1.
                               
                                   CREATE gndcimp.
                                   ASSIGN gndcimp.cdcooper = glb_cdcooper
                                          gndcimp.dtmvtolt = glb_dtmvtolt
                                          gndcimp.nmarquiv = aux_nomedarq
                                          gndcimp.qtdoctos = aux_numberdc
                                          gndcimp.nrsequen = aux_numerseq
                                          aux_numberdc     = 0.
                                   VALIDATE gndcimp.
                               END.
                          ELSE
                               ASSIGN gndcimp.qtdoctos = aux_numberdc
                                      aux_numberdc     = 0.
                      END.     
                 ELSE            
                      DO:
                          CREATE gndcimp.          
                          ASSIGN gndcimp.cdcooper = glb_cdcooper
                                 gndcimp.dtmvtolt = glb_dtmvtolt
                                 gndcimp.qtdoctos = aux_numberdc
                                 gndcimp.nmarquiv = aux_nomedarq
                                 gndcimp.nrsequen = 1
                                 aux_numberdc     = 0.
                          VALIDATE gndcimp.
                      END. 

              END. /* Fim Transaction */


              /* 9999999999 - utilizado na PostMix/Engecopy para separar as
                cartas */   
              IF   cratext.nomedcdd = " " THEN
                   PUT STREAM str_1 "9999999999 CDD NAO CADASTRADO" SKIP.
              ELSE
                   PUT STREAM str_1 "9999999999 " cratext.nomedcdd " " 
                                    cratext.nrcepcdd " " cratext.dscentra
                       FORMAT "x(60)" SKIP.
           
              aux_numberdc = aux_numberdc + 1.
           
              { includes/gera_dados_crapinf.i &NRDCONTA=0}.

          END.

    /*  Imprimir Folha com a nova faixa de CEP */
    IF   FIRST-OF (cratext.nomedcdd)  THEN
         DO:
             /* 9999999999 - utilizado na PostMix/Engecopy para separar as
                cartas */   
             IF   cratext.nomedcdd = " " THEN
                  PUT STREAM str_1 "9999999999 CDD NAO CADASTRADO" SKIP.
             ELSE
                  PUT STREAM str_1 "9999999999 " cratext.nomedcdd " " 
                                   cratext.nrcepcdd " " cratext.dscentra
                      FORMAT "x(60)" SKIP.

              aux_numberdc = aux_numberdc + 1.

              { includes/gera_dados_crapinf.i &NRDCONTA=0}.
         END.
         
    IF   cratext.tpdocmto = 5  THEN   /* Cartas CONVITE (Progrid) */  
         ASSIGN aux_dsultlin = "ORDEM:" + STRING(cratext.nrdordem, "999") +
                               "   TIPO:" + STRING(cratext.tpdocmto, "999") + 
                               " - " + STRING(cratext.nrdconta, "99999999") +
                               "  SEQUENCIA:" + 
                               STRING(cratext.nrseqint,"999,999").
    ELSE 
         ASSIGN aux_dsultlin = "ORDEM:" + STRING(cratext.nrdordem, "999") +
                               "        TIPO:" + 
                               STRING(cratext.tpdocmto, "999") + 
                               "        SEQUENCIA:" + 
                               STRING(cratext.nrseqint,"999,999").
  
    PUT STREAM str_1 cratext.nmprimtl                FORMAT "x(51)" SKIP
                     cratext.dsender1                FORMAT "x(50)" SKIP
                     "COMPLEMENTO:" cratext.complend FORMAT "x(50)" SKIP
                     "BAIRRO:" cratext.dsender2      FORMAT "x(50)" SKIP.
                       
         /* Emprestimo em atraso */
    IF   cratext.tpdocmto = 10  AND  cratext.numeroar <> 0  THEN   
         PUT STREAM str_1 
                     "CEP:" cratext.nrcepend FORMAT "99,999,999"
                     "   "      
                     "AR:" cratext.numeroar  FORMAT "999999"
                     "       "
                     "EMISSAO:" STRING(cratext.dtemissa,"99/99/9999")
                     FORMAT "x(10)"                             SKIP.
    ELSE
         PUT STREAM str_1
                     "CEP:" cratext.nrcepend FORMAT "99,999,999"   
                     FILL(" ", 11)
                     "EMISSAO:" STRING(cratext.dtemissa,"99/99/9999")   
                     FORMAT "x(10)"                             SKIP.
                                             
    PUT STREAM str_1 aux_dsultlin            FORMAT "x(50)"     SKIP
                     aux_dsmsgext[1]         FORMAT "x(50)"     SKIP
                     aux_dsmsgext[2]         FORMAT "x(50)"     SKIP
                     aux_dsmsgext[3]         FORMAT "x(50)"     SKIP
                     aux_dsmsgext[4]         FORMAT "x(50)"     SKIP
                     aux_dsmsgext[5]         FORMAT "x(50)"     SKIP
                     aux_dsmsgext[6]         FORMAT "x(50)"     SKIP
                     aux_dsmsgext[7]         FORMAT "x(50)"     SKIP
                     TRIM(aux_imlogoex)      FORMAT "x(80)"     SKIP
                     TRIM(aux_impostal)      FORMAT "x(80)"     SKIP.
                     
    IF   cratext.tpdocmto = 5   THEN  /* Cartas CONVITE (Progrid) */  
         PUT STREAM str_1 TRIM(aux_imcorre1) FORMAT "x(80)"     SKIP
         SKIP.
    ELSE 
         PUT STREAM str_1 TRIM(aux_imcorre2) FORMAT "x(80)"     SKIP
         SKIP.
                                                                
    ASSIGN aux_qtintern = 1.
    
    /* INTERNO  */
    PUT STREAM str_1 TRIM(aux_imlogoin)              FORMAT "x(60)"  SKIP.

    DO WHILE cratext.dsintern[aux_qtintern] <> "#" AND aux_qtintern < 100:
      
       PUT STREAM str_1 cratext.dsintern[aux_qtintern]  FORMAT "x(80)"  SKIP. 
                         
       ASSIGN aux_qtintern = aux_qtintern + 1.
    END.

    aux_numberdc = aux_numberdc + 1.

    { includes/gera_dados_crapinf.i &NRDCONTA=cratext.nrdconta}.

END. /* Fim cratext ... Correio */


/* Ordenar a criacao pelo PAC , SECAO */
FOR EACH cratext WHERE cratext.indespac <> 1 EXCLUSIVE-LOCK  
                       BREAK BY cratext.cdagenci:

    ASSIGN aux_nrpagina     = aux_nrpagina + 1
        
           cratext.nrseqint = aux_nrpagina.

    /* Para informativos que geram arquivos muito grande, divir em *01.dat, 
        *02.dat ... */ 
    IF   (aux_qtmaxarq > 0) AND (aux_nrpagina MODULO aux_qtmaxarq = 0) THEN
          DO:
              OUTPUT STREAM str_1 CLOSE.
              
              ASSIGN aux_nrarquiv = aux_nrarquiv + 1.
              
              OUTPUT STREAM str_1 TO VALUE(aux_nmarqdat +  
                                           STRING(aux_nrarquiv, "99") + ".dat").

              DO TRANSACTION:

                 aux_nomedarq = SUBSTR(aux_nmarqdat,R-INDEX(aux_nmarqdat,"/") +
                                1,14) + "_" + STRING(aux_nrarquiv - 1,"99")   +
                                ".dat".

                 FIND LAST gndcimp WHERE 
                           gndcimp.cdcooper = glb_cdcooper   AND
                           gndcimp.dtmvtolt = glb_dtmvtolt   AND
                           gndcimp.nmarquiv = aux_nomedarq
                           EXCLUSIVE-LOCK NO-ERROR.

                 IF   AVAILABLE gndcimp   THEN
                      DO:
                          IF   gndcimp.flgenvio   THEN
                               DO:
                                   /* proximo sequencial */
                                   ASSIGN aux_numerseq = gndcimp.nrsequen + 1.
                               
                                   CREATE gndcimp.
                                   ASSIGN gndcimp.cdcooper = glb_cdcooper
                                          gndcimp.dtmvtolt = glb_dtmvtolt
                                          gndcimp.nmarquiv = aux_nomedarq
                                          gndcimp.qtdoctos = aux_numberdc
                                          gndcimp.nrsequen = aux_numerseq
                                          aux_numberdc     = 0.
                                   VALIDATE gndcimp.
                               END.
                          ELSE
                               ASSIGN gndcimp.qtdoctos = aux_numberdc
                                      aux_numberdc     = 0.
                      END.     
                 ELSE            
                      DO:
                          CREATE gndcimp.          
                          ASSIGN gndcimp.cdcooper = glb_cdcooper
                                 gndcimp.dtmvtolt = glb_dtmvtolt
                                 gndcimp.qtdoctos = aux_numberdc
                                 gndcimp.nmarquiv = aux_nomedarq
                                 gndcimp.nrsequen = 1
                                 aux_numberdc     = 0.
                          VALIDATE gndcimp.
                      END. 
                      
              END. /* Fim Transaction */


              FIND crapage WHERE crapage.cdcooper = glb_cdcooper  AND
                                 crapage.cdagenci = cratext.cdagenci
                                 NO-LOCK NO-ERROR.

              /* 9999999999 - utilizado na PostMix/Engecopy para gerar quebra 
                              de  pagina */ 
              PUT STREAM str_1 "9999999999 " crapage.nmresage FORMAT "x(60)" 
                                SKIP.

              aux_numberdc = aux_numberdc + 1.

              { includes/gera_dados_crapinf.i &NRDCONTA=0}.                            

          END.

    IF   FIRST-OF (cratext.cdagenci)   THEN
         DO:
             FIND crapage WHERE crapage.cdcooper = glb_cdcooper  AND
                                crapage.cdagenci = cratext.cdagenci
                                NO-LOCK NO-ERROR.

             /* 9999999999 - utilizado na PostMix/Engecopy para gerar quebra de
                             pagina */ 
             PUT STREAM str_1 "9999999999 " crapage.nmresage FORMAT "x(60)" SKIP.

             aux_numberdc = aux_numberdc + 1.

             { includes/gera_dados_crapinf.i &NRDCONTA=0}.
         END.

    ASSIGN aux_dsultlin = "ORDEM:" + STRING(cratext.nrdordem, "999") +
                          "        TIPO:" + 
                          STRING(cratext.tpdocmto, "999") + 
                          "        SEQUENCIA:" + 
                          STRING(cratext.nrseqint,"999,999").

    PUT STREAM str_1 cratext.nmempres      FORMAT "x(20)"
                     cratext.nmsecext      FORMAT "x(25)"  SKIP
                     cratext.nmagenci      FORMAT "x(24)"  
                     "CONTA/DV: " 
                     STRING(cratext.nrdconta,"zzzz,zz9,9")
                     FORMAT "x(10)"                        SKIP
                     FILL(" ", 50)                         SKIP
                     STRING(cratext.nmprimtl,"x(47)")       
                     FORMAT "x(47)"                        SKIP
                     "EMISSAO:" STRING(cratext.dtemissa,"99/99/9999")   
                     FORMAT "x(10)"                        SKIP
                     aux_dsultlin          FORMAT "x(50)"  SKIP
                     aux_dsmsgext[1]       FORMAT "x(50)"  SKIP
                     aux_dsmsgext[2]       FORMAT "x(50)"  SKIP
                     aux_dsmsgext[3]       FORMAT "x(50)"  SKIP
                     aux_dsmsgext[4]       FORMAT "x(50)"  SKIP
                     aux_dsmsgext[5]       FORMAT "x(50)"  SKIP
                     aux_dsmsgext[6]       FORMAT "x(50)"  SKIP
                     aux_dsmsgext[7]       FORMAT "x(50)"  SKIP
                     TRIM(aux_imlogoex)    FORMAT "x(80)"  SKIP
                     TRIM(aux_imgvazio)    FORMAT "x(80)"  SKIP(1).

    ASSIGN aux_qtintern = 1.
    
    /* INTERNO */
    PUT STREAM str_1 TRIM(aux_imlogoin)    FORMAT "x(60)"  SKIP.

    DO WHILE cratext.dsintern[aux_qtintern] <> "#" AND aux_qtintern < 100:
      
       PUT STREAM str_1 cratext.dsintern[aux_qtintern]  FORMAT "x(80)"  SKIP. 
                         
       ASSIGN aux_qtintern = aux_qtintern + 1.
    END.

    aux_numberdc = aux_numberdc + 1.

    { includes/gera_dados_crapinf.i &NRDCONTA=cratext.nrdconta}.

END. /* Fim cratext ... Secao */

OUTPUT STREAM str_1 CLOSE.

DO TRANSACTION:

   IF   aux_numberdc > 0   THEN
        DO:               
            aux_nomedarq = IF   aux_qtmaxarq <> 0   THEN
                                SUBSTR(aux_nmarqdat,R-INDEX(aux_nmarqdat,"/") +
                                1,14) + "_" + STRING(aux_nrarquiv,"99") + ".dat"
                           ELSE 
                                SUBSTR(aux_nmarqdat,R-INDEX(
                                                    aux_nmarqdat,"/") + 1).
            
            FIND LAST gndcimp WHERE
                      gndcimp.cdcooper = glb_cdcooper   AND
                      gndcimp.dtmvtolt = glb_dtmvtolt   AND
                      gndcimp.nmarquiv = aux_nomedarq               
                      EXCLUSIVE-LOCK NO-ERROR.
   
            IF   AVAILABLE gndcimp   THEN
                 DO:
                     IF   gndcimp.flgenvio   THEN
                          DO:                
                              /* proximo sequencial */
                              ASSIGN aux_numerseq = gndcimp.nrsequen + 1.
                     
                              CREATE gndcimp.
                              ASSIGN gndcimp.cdcooper = glb_cdcooper
                                     gndcimp.dtmvtolt = glb_dtmvtolt
                                     gndcimp.qtdoctos = aux_numberdc
                                     gndcimp.nmarquiv = aux_nomedarq
                                     gndcimp.nrsequen = aux_numerseq
                                     aux_numberdc     = 0.
                              VALIDATE gndcimp.
                          END.  
                     ELSE
                          ASSIGN gndcimp.qtdoctos = aux_numberdc
                                 aux_numberdc     = 0.
                 END.
    
            ELSE   
                 DO:
                     CREATE gndcimp.
                     ASSIGN gndcimp.cdcooper = glb_cdcooper  
                            gndcimp.dtmvtolt = glb_dtmvtolt
                            gndcimp.qtdoctos = aux_numberdc
                            gndcimp.nmarquiv = aux_nomedarq
                            gndcimp.nrsequen = 1
                            aux_numberdc     = 0.
                     VALIDATE gndcimp.
                 END.
        END.
END.

/* .......................................................................... */
