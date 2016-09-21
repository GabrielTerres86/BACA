/* ............................................................................
                                                  
   Programa: Includes/crps428.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro   
   Data    : Julho/2005.                     Ultima atualizacao: 05/07/2016

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Gerar relatorios de erros(396) referentes a CONTA DE INTEGRACAO.

               Rel. crrl396_99 - 500,505,509,510,552(Tela PRCITG e Intranet)
                    crrl39699  - 500 e 509(Resumo no Final) - Intranet
 
   Alteracoes: 16/08/2005 - Incluido o arquivo COO552 (Evandro).

               23/09/2005 - Incluidas STREAM str_2 e str_3 (Diego).

               28/09/2005 - Alterado para imprimir relatorio resumido dos 
                            PAC'S(crrl39699.lst) (Diego).
                            
               29/09/2005 - Alterada leitura da situacao do associado para
                            crapass.cdsitdct = 1 (Diego).

               04/10/2005 - Alterado e_mail(Mirtes)
               
               02/05/2006 - Incluida critica para contas nao encontradas
                            crrl396_00 (Diego).

               17/08/2006 - Adicionado o campo dtretarq no relatorio (David).
   
               22/10/2007 - Alteracao no FOR EACH crapeca para melhoria de
                            performance (Julio)
                                                                   
               14/03/2008 - Incluido arquivo COO509 (Diego).
               
               08/04/2008 - Alterado envio de email para BO b1wgen0011
                            (Sidnei - Precise)

               08/01/2009 - Alterado e_mail adminstrativo para ezequiel (Magui).

               19/02/2009 - Tratamento para reativacao da C.I (Gabriel). 

               07/05/2009 - Retiradas criticas do arquivo COO506, mostrar 
                            somente a ultima critica da conta do arquivo
                            COO510 em crrl396_99 e ajustar formato do relatorio
                            crrl396_99 (Gabriel).

               15/06/2009 - Retirar arquivos nao utilizados e incluir no 
                            crrl396_99 os arquivos 500, 552 e 505 (Gabriel).

               09/09/2009 - Restaurar arquivos retirados na ultima alteracao
                            (Gabriel).
                            
               06/10/2011 - Incluido relatorio  crrl613  (Henrique).
               
               08/11/2011 - crrl613 somente para as cooperativas singulares
                            (Gabriel)

               11/11/2011 - Considerar so cartoes BB e enviar email  
                            so quando for online no 613 (Gabriel). 
                            
               16/11/2011 - Nao enviar o email do 613 quando opcao R da
                            PRCITG (Gabriel).             

               23/11/2011 - Enviar 613 somente na opcao 'P' (Gabriel).         
               
               27/06/2012 - Enviar relatório 613 apenas quando processar o
                            arquivo COO510 (Tiago).   
                            
               28/06/2012 - Enviar email do relatorio 613 apenas se o arq
                            COO510 foi processado "aux_flrel510" (Tiago). 
                            
               02/10/2013 - Ajustes para o banco ORACLE. Alterado campo 
                            crapass.dtdemis para crapass.dtdemiss 
                            (Douglas Pagel).                                        
                            
               01/11/2013 - Alterado totalizador de PAs de 99 para 999.
                          - Alterado de PAC para PA. (Reinert)
                          
               13/02/2015 - Ajustado format PA de z9 para zz9 (Daniel) 
               
			   05/07/2016 - Incluir verificacao da crapass antes da leitura dos
							registros (Lucas Ranghetti #480462)
............................................................................. */

DEF   VAR b1wgen0011   AS HANDLE                                     NO-UNDO.

/* apaga os relatorios */
UNIX SILENT VALUE("rm rl/crrl396* 2>/dev/null").

{ includes/cabrel132_1.i }
{ includes/cabrel132_2.i }
{ includes/cabrel132_4.i }

IF  glb_cdcooper <> 3 THEN
DO:
    ASSIGN aux_nmarqimp_2 = "rl/crrl396999.lst".
                
    OUTPUT STREAM str_2 TO VALUE(aux_nmarqimp_2) PAGE-SIZE 84.
                
    VIEW STREAM str_2 FRAME f_cabrel132_2.
    
    FOR EACH crapeca WHERE (crapeca.cdcooper = glb_cdcooper AND
                            crapeca.tparquiv = 500)   OR
                           (crapeca.cdcooper = glb_cdcooper AND
                            crapeca.tparquiv = 505)   OR
                           (crapeca.cdcooper = glb_cdcooper AND
                            crapeca.tparquiv = 509)   OR
                           (crapeca.cdcooper = glb_cdcooper AND
                            crapeca.tparquiv = 552)         NO-LOCK:
                           
        FIND crapass NO-LOCK WHERE crapass.cdcooper = glb_cdcooper     AND
                                   crapass.nrdconta = crapeca.nrdconta NO-ERROR.
       
        CREATE w-erros.
        ASSIGN w-erros.cdagenci = IF AVAIL crapass  THEN
                                     crapass.cdagenci  
                                  ELSE 0
               w-erros.tparquiv = crapeca.tparquiv
               w-erros.nrdconta = IF AVAIL crapass  THEN
                                     crapass.nrdconta
                                  ELSE 0
               w-erros.nmprimtl = IF AVAIL crapass  THEN
                                     crapass.nmprimtl
                                  ELSE 
                                     "****************************************"
               w-erros.dscritic = crapeca.dscritic
               w-erros.cdsitdct = IF AVAIL crapass  THEN
                                     crapass.cdsitdct
                                  ELSE 0
               w-erros.cdtipcta = IF AVAIL crapass  THEN
                                     crapass.cdtipcta
                                  ELSE 0
               w-erros.dtretarq = crapeca.dtretarq.
    
    END.
        
    /* gera o relatorio separado por PAC para COO500, COO505, COO509 e COO552 */
    FOR EACH w-erros USE-INDEX w_erros1 NO-LOCK  BREAK BY w-erros.cdagenci
                                                          BY w-erros.tparquiv
                                                             BY w-erros.nrdconta:
        /* abre um arquivo para cada PAC */
        IF   FIRST-OF(w-erros.cdagenci)   THEN
             DO:
                aux_nmarqimp = "rl/crrl396_" + STRING(w-erros.cdagenci,"999") + 
                               ".lst".
                
                OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGE-SIZE 84.
                
                VIEW STREAM str_1 FRAME f_cabrel132_1.
                
                FIND crapage WHERE crapage.cdcooper = glb_cdcooper  AND
                                   crapage.cdagenci = w-erros.cdagenci
                                   NO-LOCK NO-ERROR.
    
                IF   AVAIL crapage  THEN
                     ASSIGN aux_nmresage = crapage.nmresage.
                ELSE
                     ASSIGN aux_nmresage = "CONTAS NAO ENCONTRADAS".
                
                DISPLAY STREAM str_1 w-erros.cdagenci  aux_nmresage
                                     WITH FRAME f_pac.
             END.
    
        IF   FIRST-OF(w-erros.tparquiv)   THEN
             DO:
                 CASE w-erros.tparquiv:
                 
                    WHEN 500   THEN
                      rel_dsrelato = "COO500 - ERROS NO PROCESSAMENTO DO"
                                     + " CADASTRAMENTO DA CONTA DE INTEGRACAO".
                    WHEN 505   THEN
                      rel_dsrelato = "COO505 - ERROS NO PROCESSAMENTO DAS"
                                     + " ALTERACOES CADASTRAIS".
                    WHEN 509   THEN
                      rel_dsrelato = "COO509 - ERROS NO PROCESSAMENTO DO "
                                     + "ENCERR./REATIVACAO DA CONTA INTEGRACAO".
                    WHEN 552   THEN
                      rel_dsrelato = "COO552 - DIVERGENCIAS ENTRE OS TITULARES" 
                                     + " CADASTRADOS NA COOPERATIVA E NO BB".
                       
                    OTHERWISE  rel_dsrelato = "".
                 
                 END CASE.
                 
                 DISPLAY STREAM str_1 rel_dsrelato WITH FRAME f_cab.
             END.    
                 
        DISPLAY STREAM str_1 w-erros.nrdconta   w-erros.nmprimtl
                             w-erros.dscritic   w-erros.dtretarq 
                             WITH FRAME f_dados.
                      
        DOWN STREAM str_1 WITH FRAME f_dados.
    
        IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
             DO:
                 PAGE STREAM str_1.
                 VIEW STREAM str_1 FRAME f_cab.
             END.
    
        /* fecha o arquivo de cada PAC */
        IF   LAST-OF(w-erros.cdagenci)   THEN
             OUTPUT STREAM str_1 CLOSE.
    
    END.
    
     /* Para relatorio resumido ( crrl39699 )*/
    DISPLAY STREAM str_2 "CRITICAS REFERENTES A ARQUIVOS 500 E 509"
                          WITH CENTERED FRAME f_subtitulo.
    
     /* Para relatorio resumido */
    FOR EACH w-erros WHERE CAN-DO("500,509",STRING(w-erros.tparquiv))
                           USE-INDEX w_erros1 NO-LOCK BREAK BY w-erros.cdagenci
                                                            BY w-erros.tparquiv
                                                            BY w-erros.nrdconta:
        IF   FIRST-OF (w-erros.cdagenci)   THEN
             DO:
            
                 FIND crapage WHERE crapage.cdcooper = glb_cdcooper  AND
                                    crapage.cdagenci = w-erros.cdagenci
                                    NO-LOCK NO-ERROR.
                                                    
                 IF   AVAIL crapage  THEN
                      ASSIGN aux_nmresage = crapage.nmresage.
                 ELSE
                      ASSIGN aux_nmresage = "CONTAS NAO ENCONTRADAS".
    
                 DISPLAY STREAM str_2 SKIP(1) WITH FRAME f_pula.
                 
                 DISPLAY STREAM str_2 w-erros.cdagenci  
                                      aux_nmresage WITH FRAME f_pac.
             
             END.
      
        IF   FIRST-OF(w-erros.tparquiv)   THEN
             DO:
                 rel_dsrelato = IF   w-erros.tparquiv = 500   THEN
                                     "COO500 - ERROS NO PROCESSAMENTO DO "  +
                                     "CADASTRAMENTO DA CONTA DE INTEGRACAO"
    
                                ELSE "COO509 - ERROS NO PROCESSAMENTO DO "  +
                                     "ENCERR./REATIVACAO DA CONTA INTEGRACAO".
    
                 DISPLAY STREAM str_2 rel_dsrelato WITH FRAME f_cab_resum.
             
             END.
       
        FIND w_resumo WHERE w_resumo.cdagenci = w-erros.cdagenci 
                      NO-LOCK NO-ERROR.
                                                
        IF   NOT AVAILABLE w_resumo  THEN
             DO:
                 CREATE w_resumo.
                 ASSIGN w_resumo.cdagenci = w-erros.cdagenci.
    
             END.
             
        ASSIGN w_resumo.toterros = w_resumo.toterros + 1.
        
        DISPLAY STREAM str_2  w-erros.nrdconta  w-erros.nmprimtl
                              w-erros.cdtipcta  w-erros.cdsitdct
                              w-erros.dscritic  w-erros.dtretarq
                              WITH FRAME f_dados_resum.
    
        DOWN STREAM str_2 WITH FRAME f_dados_resum.
        
        IF   LINE-COUNTER(str_2) > PAGE-SIZE(str_2)   THEN
             DO:
                 PAGE STREAM str_2.
    
                 VIEW STREAM str_2 FRAME f_cab_resum.
    
             END.
             
    END.
    
    /* Relatorio cooperados sem conta integracao */
    ASSIGN aux_nmarqimp_3  = "crrl396999.txt".
    
    OUTPUT STREAM str_3 TO VALUE("arq/" + aux_nmarqimp_3).
                
    PUT STREAM str_3 
               "PA"              AT  1 ";"
               "CONTA/DV"        AT  7 ";"
               "NOME"            AT 16 ";"
               "TIPO CONTA"      AT 57 ";"
               "SITUACAO CONTA"  AT 79
               SKIP.
    
    FOR EACH crapass WHERE crapass.cdcooper = glb_cdcooper AND
                           crapass.cdsitdct = 1            AND
                          (crapass.cdtipcta = 1 OR
                           crapass.cdtipcta = 2 OR
                           crapass.cdtipcta = 3 OR
                           crapass.cdtipcta = 4)           AND
                           crapass.dtdemiss = ? NO-LOCK
                           BREAK BY crapass.cdagenci:
    
        FIND w_resumo WHERE w_resumo.cdagenci = crapass.cdagenci 
                      NO-LOCK NO-ERROR.
        
        IF   NOT AVAILABLE w_resumo  THEN
             DO:
                 CREATE w_resumo.
                 ASSIGN w_resumo.cdagenci = crapass.cdagenci.
             END.
                 
        ASSIGN w_resumo.totaisok = w_resumo.totaisok + 1.  
        
        FIND craptip WHERE craptip.cdcooper = glb_cdcooper       
                       AND craptip.cdtipcta = crapass.cdtipcta   
                       NO-LOCK NO-ERROR.
    
        ASSIGN tel_dstipcta = STRING(crapass.cdtipcta,"99") + " - " +              
                                    craptip.dstipcta.
        
        tel_dssitdct = STRING(crapass.cdsitdct,"9") + " - " +
                       IF crapass.cdsitdct = 1
                          THEN "NORMAL"
                       ELSE IF crapass.cdsitdct = 2
                          THEN "ENCERRADA P/ASSOCIADO"
                       ELSE IF crapass.cdsitdct = 3
                          THEN "ENCERRADA P/COOP"
                       ELSE IF crapass.cdsitdct = 4
                          THEN "ENCERRADA P/DEMISSAO"
                       ELSE IF crapass.cdsitdct = 5
                          THEN "NAO APROVADA"
                       ELSE IF crapass.cdsitdct = 9
                          THEN "ENCERRADA P/OUTRO MOTIVO"
                       ELSE "".
        
        PUT  STREAM str_3
                    crapass.cdagenci   FORMAT "zz9"         ";"
                    crapass.nrdconta   FORMAT "zzzz,zzz,9"  ";"
                    crapass.nmprimtl   FORMAT "x(40)"       ";"
                    tel_dstipcta       FORMAT "x(21)"       ";"
                    tel_dssitdct       FORMAT "x(26)"
                    SKIP.
    END.
    
    OUTPUT STREAM str_3 CLOSE.
    
    UNIX SILENT VALUE("cp arq/" + aux_nmarqimp_3 + " salvar"). 
    
    ASSIGN aux_arq_excell     = "salvar/" + aux_nmarqimp_3.
    
    IF   glb_cdcooper = 1  AND glb_inproces <> 1  THEN
         DO:
             FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.
    
             /* Move para diretorio converte para utilizar na BO */
             UNIX SILENT VALUE
                        ("cp " + aux_arq_excell + " /usr/coop/" +
                        crapcop.dsdircop + "/converte" +
                         " 2> /dev/null").
                        
             /* envio de email */ 
             RUN sistema/generico/procedures/b1wgen0011.p
                 PERSISTENT SET b1wgen0011.
             
             RUN enviar_email IN b1wgen0011
                                (INPUT glb_cdcooper,
                                 INPUT glb_cdprogra,
                                 INPUT "ezequiel@viacredi.coop.br",
                                 INPUT '"Relacao Cooperados sem Conta Integracao"',
                                 INPUT SUBSTRING(aux_arq_excell, 8),
                                 INPUT TRUE).
               
             DELETE PROCEDURE b1wgen0011.                           
         END.
    
    UNIX SILENT VALUE("rm " + "arq/" + aux_nmarqimp_3 +       
                      "> /dev/null").
                           
    PAGE STREAM str_2.
    
    VIEW STREAM str_2 FRAME f_cab_total.
    
    FOR EACH w_resumo NO-LOCK BREAK BY w_resumo.cdagenci:
       
        FIND crapage WHERE crapage.cdcooper = glb_cdcooper        
                       AND crapage.cdagenci = w_resumo.cdagenci   
                       NO-LOCK NO-ERROR.
        
        IF   AVAIL crapage  THEN
             ASSIGN aux_dsagenci = STRING(w_resumo.cdagenci, "zz9") + " - " +       
                                   crapage.nmresage.
        ELSE
             ASSIGN aux_dsagenci = STRING(w_resumo.cdagenci, "zz9")  + " - " +
                                   "NAO ENCONTRADAS".
     
        IF   LAST-OF(w_resumo.cdagenci)  THEN
             
             DISPLAY STREAM str_2 aux_dsagenci       w_resumo.toterros
                                  w_resumo.totaisok  WITH FRAME f_resumo_total.
             
        DOWN STREAM str_2 WITH FRAME f_resumo_total.
             
        ASSIGN aux_totgeral = aux_totgeral + w_resumo.toterros.
        
        ASSIGN aux_geraltot = aux_geraltot + w_resumo.totaisok.
        
        IF   LINE-COUNTER(str_2) > PAGE-SIZE(str_2)   THEN
             DO:
                 PAGE STREAM str_2.                          
                 VIEW STREAM str_2 FRAME f_cab_total.
             END.               
    END.
    
    DISPLAY STREAM str_2 aux_totgeral   aux_geraltot WITH FRAME f_totgeral.
    
    OUTPUT STREAM str_2 CLOSE.
            
    IF   glb_inproces <> 1  THEN
         DO:
             /* Referente relatorio crrl39699.lst */     
             ASSIGN glb_nmformul = "132col"
                    glb_nmarqimp = aux_nmarqimp_2
                    glb_nrcopias = 1.
                    
             RUN fontes/imprim.p.
         END.
                    
    /* cria um arquivo para os PAC'S que nao tiveram erros 
       (COO500/COO505/COO509/COO552) */
     
    FOR EACH crapage WHERE crapage.cdcooper = glb_cdcooper NO-LOCK: 
    
        /* se nao achar arquivo */
        IF  SEARCH("rl/crrl396_" + STRING(crapage.cdagenci,"999") + ".lst") = ? THEN
            DO:
                aux_nmarqimp = "rl/crrl396_" + STRING(crapage.cdagenci,"999") + 
                               ".lst".
                
                OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp).
                
                DISPLAY STREAM str_1
                               SKIP(1)
                               "!!! NAO HA CRITICAS DE CADASTRAMENTO/ALTERACAO"
                               "CADASTRAL PARA ESTE PA !!!"
                               SKIP(1).
                               
                OUTPUT STREAM str_1 CLOSE.
    
            END.
    END.
    
    /* gera o relatorio para controle centralizado (nao para cada pac) */
    ASSIGN aux_nmarqimp = "rl/crrl396_999.lst"
           aux_flgexist = FALSE.
                
    OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGE-SIZE 84.
                
    VIEW STREAM str_1 FRAME f_cabrel132_1.
    
    EMPTY TEMP-TABLE w-erros.
    
    
    /* Para relatorio - crrl396_99 */
    
    DISPLAY STREAM str_1 "CRITICAS REFERENTES A ARQUIVOS 500,505,509,510 E 552"
                         WITH CENTERED FRAME f_subtitulo_2.
    
    FOR EACH crapeca WHERE (crapeca.cdcooper = glb_cdcooper   AND
                            crapeca.tparquiv = 500)           OR
                           (crapeca.cdcooper = glb_cdcooper   AND
                            crapeca.tparquiv = 505)           OR
                           (crapeca.cdcooper = glb_cdcooper   AND
                            crapeca.tparquiv = 509)           OR
                           (crapeca.cdcooper = glb_cdcooper   AND
                            crapeca.tparquiv = 510)           OR
                           (crapeca.cdcooper = glb_cdcooper   AND
                            crapeca.tparquiv = 552)           NO-LOCK:
    
        FIND crapass WHERE crapass.cdcooper = glb_cdcooper      AND
                           crapass.nrdconta = crapeca.nrdconta  NO-LOCK NO-ERROR.
                           
        CREATE w-erros.
        ASSIGN w-erros.cdagenci = IF AVAIL crapass  THEN
                                     crapass.cdagenci  
                                  ELSE 0
               w-erros.tparquiv = crapeca.tparquiv
               w-erros.nrdconta = IF AVAIL crapass  THEN
                                     crapass.nrdconta
                                  ELSE 0
               w-erros.nmprimtl = IF AVAIL crapass  THEN
                                     crapass.nmprimtl
                                  ELSE "****************************************"
               w-erros.dscritic = crapeca.dscritic
               w-erros.dtretarq = crapeca.dtretarq.
    END.           
    
    FOR EACH w-erros NO-LOCK BREAK BY w-erros.cdagenci
                                      BY w-erros.tparquiv
                                         BY w-erros.nrdconta
                                            BY w-erros.dtretarq:    
    
        IF   FIRST-OF(w-erros.tparquiv) THEN
             DO:
                 ASSIGN  rel_dsrelato =  "PA" + STRING(w-erros.cdagenci, "zz9") +
                                         " - "
     
                         aux_flgexist = TRUE.
                 
                 CASE w-erros.tparquiv:
                 
                    WHEN   500   THEN
                      rel_dsrelato = rel_dsrelato                            +
                                     "COO500 - ERROS NO PROCESSAMENTO DO "   +
                                     "CADASTRAMENTO DA CONTA DE INTEGRACAO".
    
                    WHEN   505   THEN
                      rel_dsrelato = rel_dsrelato                            +
                                     "COO505 - ATUALIZACAO CADASTRAL".
     
                    WHEN   509   THEN
                      rel_dsrelato = rel_dsrelato                            +
                                     "COO509 - ERROS NO PROCESSAMENTO DO"    +
                                     " ENCERR./REATIVACAO DA CONTA INTEGRACAO".
     
                    WHEN   510   THEN
                      rel_dsrelato = rel_dsrelato                            +
                                     "COO510 - ERROS NO PROCESSAMENTO DOS"   +
                                     " CARTOES DE CREDITO".
                    
                    WHEN   552   THEN
                      rel_dsrelato = rel_dsrelato +
                                     "COO552 - DIFERENCAS ENTRE COOPERATIVA E BB".
    
                    OTHERWISE  rel_dsrelato = "".
                 
                 END CASE.
                 
                 DISPLAY STREAM str_1 rel_dsrelato WITH FRAME f_cab.
             
             END.    
    
        /* Se for o arquivo  510 lista somente o ultimo da conta ... */            
                 
        IF   (w-erros.tparquiv = 510   AND   LAST-OF(w-erros.nrdconta))  OR
        
             (w-erros.tparquiv <> 510)                                   THEN
    
             DO:
                 DISPLAY STREAM str_1 w-erros.nrdconta   w-erros.nmprimtl
                                      w-erros.dscritic   w-erros.dtretarq 
                                      WITH FRAME f_dados.
             
                 DOWN STREAM str_1 WITH FRAME f_dados.
             
             END.
             
        IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
             DO:
                PAGE STREAM str_1.
                VIEW STREAM str_1 FRAME f_cab.
             END.
    
    END.
    
    OUTPUT STREAM str_1 CLOSE.
    
    IF   glb_inproces <> 1  THEN
         DO:
             /* Referente relatorio crrl396_99.lst */
             ASSIGN glb_nmformul = "132col"
                    glb_nmarqimp = aux_nmarqimp
                    glb_nrcopias = 1.
         
             RUN fontes/imprim.p.
         END.
END. /* Fim IF glb_cdcooper = 3 */

ASSIGN aux_nmarqimp_4 = "rl/crrl613.lst".

OUTPUT STREAM str_4 TO VALUE (aux_nmarqimp_4) PAGED PAGE-SIZE 80.

VIEW STREAM str_4 FRAME f_cabrel132_4.

FOR EACH crapcop WHERE crapcop.cdcooper = glb_cdcooper   AND 
                       glb_cdcooper <> 3                 NO-LOCK:

    FOR EACH crapeca WHERE crapeca.cdcooper = crapcop.cdcooper  AND
                           crapeca.tparquiv = 510               AND
                           crapeca.dtretarq = glb_dtmvtolt      NO-LOCK:
    
        /* Busca o titular do cartao */
        FIND crapass WHERE crapass.cdcooper = crapeca.cdcooper
                       AND crapass.nrdconta = crapeca.nrdconta
                       NO-LOCK NO-ERROR.
        
        /* Busca o cartao */
        FIND FIRST crawcrd WHERE crawcrd.cdcooper = crapeca.cdcooper
                             AND crawcrd.nrdconta = crapeca.nrdconta
                             AND crawcrd.flgctitg = 1 
                             AND crawcrd.nrcrcard = 0 
                             AND crawcrd.nrcctitg = 0
                             NO-LOCK NO-ERROR.
    
        IF NOT AVAIL crawcrd THEN
            DO:
                CREATE tt-crapeca.
                ASSIGN tt-crapeca.cdcooper = crapeca.cdcooper
                       tt-crapeca.cdagenci = IF AVAIL crapass THEN 
                                                crapass.cdagenci ELSE 0
                       tt-crapeca.nrdconta = crapeca.nrdconta 
                       tt-crapeca.nrdctitg = IF AVAIL crapass THEN 
                                                crapass.nrdctitg ELSE "0"
                       tt-crapeca.nmprimtl = IF AVAIL crapass THEN 
                                                crapass.nmprimtl  
                                             ELSE "****************************************"
                       tt-crapeca.flginteg = FALSE
                       tt-crapeca.dscritic = "CARTAO NAO ENCONTRADO".
                NEXT.
            END.
    
        /* Cartao BB */
        IF   NOT (crawcrd.cdadmcrd >= 83  AND crawcrd.cdadmcrd <= 88)   THEN
             NEXT.

        /* Busca a modalidade do cartao */
        FIND crapadc WHERE crapadc.cdcooper = crawcrd.cdcooper
                       AND crapadc.cdadmcrd = crawcrd.cdadmcrd
                       NO-LOCK NO-ERROR.
    
        IF  AVAIL crapadc THEN
            ASSIGN aux_nmresadm = crapadc.nmresadm.
    
        
        CREATE tt-crapeca.
        ASSIGN tt-crapeca.cdcooper = crapeca.cdcooper
               tt-crapeca.cdagenci = IF AVAIL crapass THEN 
                                        crapass.cdagenci ELSE 0
               tt-crapeca.nrdconta = crapeca.nrdconta 
               tt-crapeca.nrdctitg = IF AVAIL crapass THEN 
                                        crapass.nrdctitg ELSE "0"
               tt-crapeca.nmprimtl = IF AVAIL crapass THEN 
                                        crapass.nmprimtl 
                                     ELSE "****************************************"
               tt-crapeca.nmresadm = aux_nmresadm
               tt-crapeca.flginteg = FALSE
               tt-crapeca.dscritic = crapeca.dscritic.

        ASSIGN aux_nmresadm = "".
    
    END.

    FOR EACH crawcrd WHERE crawcrd.cdcooper  = crapcop.cdcooper
                       AND crawcrd.dtentreg  = glb_dtmvtolt
                       AND crawcrd.insitcrd  = 4                       
                       AND crawcrd.cdadmcrd >= 83 
                       AND crawcrd.cdadmcrd <= 88
                       NO-LOCK:

        /* Busca o titular do cartao */
        FIND crapass WHERE crapass.cdcooper = crawcrd.cdcooper
                       AND crapass.nrdconta = crawcrd.nrdconta
                       NO-LOCK NO-ERROR.
        
        /* Busca a modalidade do cartao */
        FIND crapadc WHERE crapadc.cdcooper = crawcrd.cdcooper
                       AND crapadc.cdadmcrd = crawcrd.cdadmcrd
                       NO-LOCK NO-ERROR.
    
        IF  AVAIL crapadc THEN
            ASSIGN aux_nmresadm = crapadc.nmresadm.
    
        
        CREATE tt-crapeca.
        ASSIGN tt-crapeca.cdcooper = crawcrd.cdcooper
               tt-crapeca.cdagenci = IF AVAIL crapass THEN 
                                       crapass.cdagenci ELSE 0
               tt-crapeca.nrdconta = crawcrd.nrdconta 
               tt-crapeca.nrdctitg = IF AVAIL crapass THEN 
                                       crapass.nrdctitg ELSE "0"
               tt-crapeca.nmprimtl = IF AVAIL crapass THEN 
                                        crapass.nmprimtl 
                                     ELSE "****************************************"
               tt-crapeca.nmresadm = aux_nmresadm
               tt-crapeca.flginteg = TRUE
               tt-crapeca.dscritic = "CARTAO INTEGRADO " + 
                                     STRING(crawcrd.nrcrcard,
                                            "9999,9999,9999,9999").

        ASSIGN aux_nmresadm = "".
    
    END.

END. /* FIM FOR EACH crapcop */


FOR EACH tt-crapeca NO-LOCK BREAK BY tt-crapeca.cdcooper
                                  BY tt-crapeca.flginteg
                                  BY tt-crapeca.cdagenci
                                  BY tt-crapeca.nrdconta:

    IF  FIRST-OF(tt-crapeca.cdcooper) THEN
        DO:
            PAGE STREAM str_4.
            FIND crapcop WHERE crapcop.cdcooper = tt-crapeca.cdcooper 
                         NO-LOCK NO-ERROR.

            DISP STREAM str_4 crapcop.nmrescop WITH FRAME f_nmrescop.
        END.

    DISP STREAM str_4 tt-crapeca.cdagenci 
                      tt-crapeca.nrdconta
                      tt-crapeca.nrdctitg
                      tt-crapeca.nmprimtl
                      tt-crapeca.nmresadm
                      tt-crapeca.dscritic
                      WITH FRAME f_crapeca.

    DOWN STREAM str_4 WITH FRAME f_crapeca.

    IF LAST-OF(tt-crapeca.flginteg) THEN
        DOWN 2 STREAM str_4 WITH FRAME f_crapeca.

END. /* FIM FOR EACH tt-crapeca */

OUTPUT STREAM str_4 CLOSE.

IF   glb_inproces <> 1  THEN
     DO:
         /* Referente relatorio crrl613.lst */
         ASSIGN glb_nmformul = "132col"
                glb_nmarqimp = aux_nmarqimp_4
                glb_nrcopias = 1.
     
         RUN fontes/imprim.p.
     END.

IF  aux_flrel510 THEN
    DO:
    
        /* Enviar por e-mail so se for on-line e o relatorio nao tiver zerado */
        IF  glb_cdcooper <> 3   AND 
            glb_inproces  = 1   AND 
            glb_cddopcao  = "P" AND
            TEMP-TABLE tt-crapeca:HAS-RECORDS   THEN
            DO: 
                ASSIGN aux_nmarqenv = "crrl613.txt".
                       
                RUN sistema/generico/procedures/b1wgen0011.p PERSISTENT SET b1wgen0011.
                
                RUN converte_arquivo IN b1wgen0011 (INPUT glb_cdcooper,
                                                    INPUT aux_nmarqimp_4,
                                                    INPUT aux_nmarqenv).
                
                RUN enviar_email IN b1wgen0011
                                   (INPUT glb_cdcooper,
                                    INPUT glb_cdprogra,
                                    INPUT "cartoes@cecred.coop.br",
                                    INPUT "CRITICAS ARQUIVO COO510 ",
                                    INPUT aux_nmarqenv,
                                    INPUT TRUE).
                
                DELETE PROCEDURE b1wgen0011.
            END.

    END.
/* .......................................................................... */

