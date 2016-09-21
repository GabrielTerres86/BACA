/* ..........................................................................

   Programa: includes/gerarazao.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio
   Data    : Setembro/2003                       Ultima atualizacao: 27/04/2009

   Dados referentes ao programa:

   Frequencia: Mensal.
   Objetivo  : Listar os lancamentos conforme parametro.
   
               {1} -> Tabela de lancamentos.
               {2} -> Campo referente ao numero da conta no Banco do Brasil.
               {3} -> Segunda tabela de lancamentos (crps358)
               
   Alteracoes: 14/11/2003 - Alteracao na atualizacao do numero do livro no
                            crapcop, vai atualizar somente apos a impressao
                            dos lancamento. (Julio).

               28/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).
                             
               03/02/2006 - Unificacao dos bancos - SQLWorks - Eder
               
               09/06/2008 - Incluído a chave de acesso (craphis.cdcooper = 
                            glb_cdcooper) no "for each" da tabela CRAPHIS. 
                          - Kbase IT Solutions - Paulo Ricardo Maciel.
                          
               27/04/2009 - Acertar logica de FOR EACH que utiliza OR (David).          
                          
.............................................................................*/

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> log/proc_batch.log").
         QUIT.
     END.

ASSIGN rel_nmcooper = crapcop.nmextcop.

IF   "{1}" = "craplcm"   THEN
     rel_tpdrazao = "DEPOSITOS A VISTA".
ELSE
IF   "{1}" = "craplem"   THEN
     rel_tpdrazao = "EMPRESTIMOS".
ELSE
IF   "{1}" = "craplct"   THEN
     rel_tpdrazao = "CAPITAL".
ELSE
IF   "{1}" = "craplap" AND "{3}" = "craplpp"   THEN
     rel_tpdrazao = "APLICACOES".

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

OUTPUT STREAM str_1 TO VALUE(aux_nmarqlan).

DO aux_contdata = aux_dtperini TO aux_dtperfim:

   FIND FIRST {1} WHERE {1}.cdcooper = glb_cdcooper  AND
                        {1}.dtmvtolt = aux_contdata  NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE {1}   THEN
        DO:
            FIND FIRST {3} WHERE {3}.cdcooper = glb_cdcooper  AND
                                 {3}.dtmvtolt = aux_contdata  NO-LOCK NO-ERROR.
            
            IF   NOT AVAILABLE {3}   THEN
                 NEXT.
        END.
 
   { includes/gerarazao_dtl.i } 

   FOR EACH craphis WHERE craphis.cdcooper = glb_cdcooper AND
                         (craphis.nmestrut = "{1}"        OR
                          craphis.nmestrut = "{3}")       NO-LOCK 
                          BY craphis.cdhistor:
       
       ASSIGN rel_cdhistor = craphis.cdhistor
              rel_dshistor = craphis.dsexthst
              rel_nrctadeb = craphis.nrctadeb
              rel_nrctacrd = craphis.nrctacrd
              aux_histcred = CAPS(craphis.indebcre) = "C" 
              aux_tpctbcxa = craphis.tpctbcxa.

       FIND FIRST {1} WHERE {1}.cdcooper = glb_cdcooper  AND
                            {1}.cdhistor = rel_cdhistor  AND
                            {1}.dtmvtolt = aux_contdata  NO-LOCK NO-ERROR.

       IF   NOT AVAILABLE {1}   THEN
            DO:
                FIND FIRST {3} WHERE {3}.cdcooper = glb_cdcooper  AND
                                     {3}.cdhistor = rel_cdhistor  AND
                                     {3}.dtmvtolt = aux_contdata 
                                     NO-LOCK NO-ERROR.

                IF   NOT AVAILABLE {3}   THEN
                     NEXT.
            END.
            
       { includes/gerarazao_his.i } 
    
       IF    AVAILABLE {1}   THEN
             DO:
                 { includes/gerarazao_det.i {1} {2} }
             END.
       ELSE
       IF    AVAILABLE {3}   THEN
             DO:
                 { includes/gerarazao_det.i {3} {2} }          
             END.
    
       IF   AVAILABLE {1} OR AVAILABLE {3}   THEN
            DO:
                { includes/gerarazao_tot.i }
            END.

   END. /* Fim do FOR EACH craphis */
   
   IF   "{1}" = "craplem"   THEN
        DO:
             FIND FIRST crapcdb WHERE crapcdb.cdcooper = glb_cdcooper  AND
                                      crapcdb.dtmvtolt = aux_contdata 
                                      NO-LOCK NO-ERROR.
                                
             IF   AVAILABLE crapcdb   THEN
                  DO:
                      ASSIGN rel_cdhistor = 9998
                             rel_dshistor = "DEBITO DESCONTO DE CHEQUES"
                             rel_nrctadeb = 1641
                             rel_nrctacrd = 4954
                             aux_histcred = FALSE.
           
                      { includes/gerarazao_chq.i }
          
                      ASSIGN rel_cdhistor = 9999
                             rel_dshistor = "CREDITO DESCONTO DE CHEQUES"
                             rel_nrctadeb = 4954
                             rel_nrctacrd = 1642
                             aux_histcred = TRUE.
                    
                      { includes/gerarazao_chq.i }  
                      
                  END.
        END.          /*  Fim IF craplem  */
        
   { includes/gerarazao_dat.i }                
   rel_ttcrddia = 0.
   rel_ttdebdia = 0.
 
END. /* Fim do DO aux_contdata */

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper EXCLUSIVE-LOCK NO-ERROR.

IF   "{1}" = "craplcm"   THEN
     DO:
         rel_nrdlivro = crapcop.nrlivdpv.
         crapcop.nrlivdpv = crapcop.nrlivdpv + 1.
     END.
ELSE
IF   "{1}" = "craplem"   THEN
     DO:
         rel_nrdlivro = crapcop.nrlivepr.
         crapcop.nrlivepr = crapcop.nrlivepr + 1.
     END.
ELSE
IF   "{1}" = "craplct"   THEN
     DO:
         rel_nrdlivro = crapcop.nrlivcap.
         crapcop.nrlivcap = crapcop.nrlivcap + 1.
     END.
ELSE
IF   "{1}" = "craplap" AND "{3}" = "craplpp"   THEN
     DO:
         rel_nrdlivro = crapcop.nrlivapl.
         crapcop.nrlivapl = crapcop.nrlivapl + 1.
     END.

IF   aux_contlinh > 1    THEN
     DO:
        { includes/gerarazao_nul.i }

        ASSIGN rel_dtterabr = aux_dtperfim
               rel_contapag = rel_contapag + 1.
               
        { includes/gerarazao_abr.i STRING(rel_contapag) "TERMO DE ENCERRAMENTO"}

     END.
     
OUTPUT STREAM str_1 CLOSE.

IF   aux_contlinh > 1    THEN
     DO:

        OUTPUT STREAM str_1 TO VALUE(aux_nmarqabr).

        rel_dtterabr = aux_dtperini.

        { includes/gerarazao_abr.i "1" "TERMO DE ABERTURA" }

        OUTPUT STREAM str_1 CLOSE.

        UNIX SILENT VALUE("cat " + aux_nmarqabr + " " + aux_nmarqlan + " > " +
                           aux_nmarquiv + " 2> /dev/null").

        UNIX SILENT VALUE("rm " + aux_nmarqabr).
        
     END.
     
UNIX SILENT VALUE("rm " + aux_nmarqlan).

/*...........................................................................*/

