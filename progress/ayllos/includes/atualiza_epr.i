/* ...........................................................................

   Programa: includes/atualiza_epr.i
   Sistema : Ayllos - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio
   Data    : Outubro/2007                      Ultima atualizacao:   16/11/2012    

   Dados referentes ao programa:

   Frequencia: Diario
   Objetivo  : Rotinas para atualizacao de controles no emprestimo.             
               
   Alteracoes: 16/11/2012 - Alterado para desconsiderar o tipo de emprestimo 1. (Oscar)
    

............................................................................ */

/* Procedure utilizada para atualizar a data de pagamento de emprestimos 
   vinculados a c/c. 

      par_flginclu = TRUE  => inclusao de lancamento
      par_flginclu = FALSE => exclusao de lancamento */

PROCEDURE p_atualiza_dtdpagto:

   DEFINE INPUT PARAMETER par_flginclu AS LOGICAL                    NO-UNDO.
   DEFINE INPUT PARAMETER par_vllanmto AS DECIMAL                    NO-UNDO.

   DEFINE VARIABLE pro_vltotpag AS DECIMAL                           NO-UNDO.
   DEFINE VARIABLE pro_qtprepag AS INTEGER                           NO-UNDO.
   DEFINE VARIABLE pro_qtanopag AS INTEGER                           NO-UNDO.
   DEFINE VARIABLE pro_vldifere AS DECIMAL                           NO-UNDO.
   DEFINE VARIABLE pro_qtdiadec AS INTEGER                           NO-UNDO.
   DEFINE VARIABLE pro_dtdpagto AS DATE                              NO-UNDO.
  
   IF   AVAILABLE crapepr    AND
        crapepr.tpemprst = 0 AND
        par_vllanmto > 0     THEN
        DO:
           FIND crawepr WHERE crawepr.cdcooper = glb_cdcooper     AND
                              crawepr.nrdconta = crapepr.nrdconta AND
                              crawepr.nrctremp = crapepr.nrctremp
                              NO-LOCK NO-ERROR.
                              
           IF   AVAILABLE crawepr   THEN                   
                ASSIGN pro_dtdpagto = crawepr.dtvencto.
           ELSE
                ASSIGN pro_dtdpagto = crapepr.dtinipag.
                
           ASSIGN pro_dtdpagto = DATE(MONTH(pro_dtdpagto),
                                        DAY(crapepr.dtdpagto),
                                       YEAR(pro_dtdpagto)).
           
           /* Contabiliza todos os valores lancados para o emprestimo */

           FOR EACH craplem WHERE craplem.cdcooper = glb_cdcooper     AND
                                  craplem.nrdconta = crapepr.nrdconta AND
                                  craplem.nrctremp = crapepr.nrctremp NO-LOCK:
                
               IF   craplem.cdhistor = 91  OR   /* Pagto LANDPV          */
                    craplem.cdhistor = 92  OR   /* Empr.Consig.Caixa On_line */
                    craplem.cdhistor = 93  OR   /* Emprestimo Consignado */
                    craplem.cdhistor = 95  OR   /* Pagto crps120         */
                    craplem.cdhistor = 393 OR   /* Pagto Avalista        */
                    craplem.cdhistor = 353 THEN /* Transf. Cotas         */
                    ASSIGN pro_vltotpag = pro_vltotpag + craplem.vllanmto.
               ELSE
               IF   craplem.cdhistor = 88  OR
                    craplem.cdhistor = 507 THEN /*Est.Transf.Cot*/
                    ASSIGN pro_vltotpag = pro_vltotpag - craplem.vllanmto.
           END.
           
           IF   par_flginclu   THEN /* Se for inclusao de lancamento ... */
                DO:
                    IF  (his_cdhistor = 88 OR his_cdhistor = 507)  THEN
                        ASSIGN pro_vltotpag = pro_vltotpag - par_vllanmto.
                    ELSE
                        ASSIGN pro_vltotpag = pro_vltotpag + par_vllanmto.
                END.
           ELSE     /* se tiver excluindo lancamento... */
                DO:
                    IF  (his_cdhistor = 88 OR his_cdhistor = 507)  THEN
                        ASSIGN pro_vltotpag = pro_vltotpag + par_vllanmto.
                    ELSE
                        ASSIGN pro_vltotpag = pro_vltotpag - par_vllanmto.
                END.           
               
           ASSIGN pro_qtprepag = TRUNCATE(pro_vltotpag / crapepr.vlpreemp, 0).

           /* Calcula a nova data de pagamento de acordo com a
              quantidade de prestacoes pagas, incluindo o lancamento atual */
                                            
           ASSIGN pro_qtanopag = TRUNCATE(pro_qtprepag / 12, 0)
                  pro_qtprepag = pro_qtprepag MODULO 12.

           RUN fontes/calcdata.p (INPUT  pro_dtdpagto,
                                  INPUT  pro_qtprepag,
                                  INPUT  "M",
                                  INPUT  0,
                                  OUTPUT pro_dtdpagto).
                        
           IF pro_qtanopag > 0 THEN
              RUN fontes/calcdata.p (INPUT  pro_dtdpagto,
                                     INPUT  pro_qtanopag,
                                     INPUT  "A",
                                     INPUT  0,
                                     OUTPUT pro_dtdpagto).

           IF   pro_dtdpagto > glb_dtmvtolt                 AND
                (MONTH(pro_dtdpagto) <> MONTH(glb_dtmvtolt)  OR
                 YEAR(pro_dtdpagto) <> YEAR(glb_dtmvtolt)) THEN
                DO:
                    RUN fontes/calcdata.p (INPUT  DATE(MONTH(glb_dtmvtolt),
                                                       DAY(pro_dtdpagto),
                                                       YEAR(glb_dtmvtolt)),
                                           INPUT  1,
                                           INPUT  "M",
                                           INPUT  0,
                                           OUTPUT pro_dtdpagto).
                END.                                           

           ASSIGN crapepr.dtdpagto = pro_dtdpagto.

           IF   crapepr.dtdpagto < glb_dtultdia   THEN
                ASSIGN crapepr.indpagto = 0.
           ELSE
                ASSIGN crapepr.indpagto = 1.

        END.
END.

/* ......................................................................... */

