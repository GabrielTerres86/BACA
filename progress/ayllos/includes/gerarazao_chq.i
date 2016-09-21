/* ..........................................................................

   Programa: includes/gerarazao_chq.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio
   Data    : Outubro/2003                      Ultima atualizacao: 03/02/2006
      
   Dados referentes ao programa:

   Frequencia: Mensal.
   Objetivo  : Listar os lancamentos conforme parametro.
   
   Alteracoes: 
               03/02/2006 - Unificacao dos bancos - SQLWorks - Eder
..............................................................................*/

rel_ttlanmto = 0.

{ includes/gerarazao_his.i } 

{ includes/gerarazao_tit.i }

FOR EACH crapbdc WHERE crapbdc.cdcooper = glb_cdcooper  AND
                       crapbdc.dtlibbdc = aux_contdata  AND
                       crapbdc.insitbdc = 3             NO-LOCK:
 
   FOR EACH crapcdb WHERE crapcdb.cdcooper = glb_cdcooper      AND 
                          crapcdb.nrborder = crapbdc.nrborder
                          USE-INDEX crapcdb7 NO-LOCK 
                          BREAK BY crapcdb.cdagenci 
                                   BY crapcdb.nrdconta:
  
       IF   rel_cdhistor = 9998   THEN
            DO:
                rel_vllandeb = rel_vllandeb + crapcdb.vlcheque.
                rel_vllancrd = 0.
            END.
       ELSE
       IF   rel_cdhistor = 9999   THEN
            DO:
                rel_vllancrd = rel_vllancrd + 
                               (crapcdb.vlcheque - crapcdb.vlliquid).
                rel_vllandeb = 0.
            END.
           
       IF   LAST-OF(crapcdb.nrdconta)   THEN
            DO:

                FIND crapass WHERE crapass.cdcooper = glb_cdcooper      AND
                                   crapass.nrdconta = crapcdb.nrdconta 
                                   NO-LOCK NO-ERROR.
                                   
                IF   NOT AVAILABLE crapass   THEN
                     NEXT.
                
                ASSIGN rel_dtlanmto = crapbdc.dtmvtolt
                       rel_nrdconta = crapcdb.nrdconta
                       rel_cdagenci = crapcdb.cdagenci
                       rel_nrdocmto = crapcdb.nrborder
                       rel_ttlanmto = rel_ttlanmto + rel_vllancrd +
                                                     rel_vllandeb
/*                       rel_ttlanage = rel_ttlanage + rel_vllancrd +
                                                     rel_vllandeb
*/                     rel_ttcrddia = rel_ttcrddia + rel_vllancrd
                       rel_ttdebdia = rel_ttdebdia + rel_vllandeb.
  
/*                IF   FIRST-OF(crapcdb.cdagenci)    THEN
                     DO:
                         { includes/gerarazao_tit.i }
                     END.
  */                   
                { includes/gerarazao_lan.i crapass.nmprimtl } 
                
                ASSIGN rel_vllandeb = 0
                       rel_vllancrd = 0.                
            END.

  /*     IF   LAST-OF(crapcdb.cdagenci)   THEN
            DO:
                { includes/gerarazao_pac.i }      
                rel_ttlanage = 0.
            END.
    */                                                                     
   END.  /*  Fim do FOR EACH -- crapcdb  */
   
END.  /*  Fim do FOR EACH -- crapbdc  */

{ includes/gerarazao_tot.i }

/*............................................................................*/
