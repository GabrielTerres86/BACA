/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | includes/crps398.i              | EMPR0001.pc_calc_dias_atraso      |
  +---------------------------------+-----------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/






/* .............................................................................

   Programa: includes/crps398.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme
   Data    : Outubro/2007                        Ultima atualizacao: 30/01/2014

   Dados referentes ao programa:

   Frequencia: Diaria - Sempre que for chamada 
   Objetivo  : Rotina de calculo de dias do ultimo pagamento de  
               emprestimos em atraso
   
   Alteracoes: 13/12/2012 - Diferenciar tipos de emprestimos (Gabriel).
   
               04/04/2013 - Mudanca de parametros na procedure que calcula
                            a qtde de dias de atraso (Gabriel).
                            
               04/04/2013 - Retirada a restricao glb_cdprogra <> "crps005"
                            quando chama o saldo_epr.p (Lucas R.).

               30/01/2014 - Remover a chamada da procedure "saldo_epr.p".
                            (James)
............................................................................. */

DO WHILE TRUE:

   IF  crapepr.tpemprst = 0 THEN
       DO:
           ASSIGN aux_qtmesdec = crapepr.qtmesdec.
        
           IF   crapepr.dtdpagto <> ?   THEN  /* Verif. final mes(dia nao util) */
                DO:
                    IF   DAY(crapepr.dtdpagto)   > DAY(glb_dtmvtolt)    AND
                         MONTH(crapepr.dtdpagto) = MONTH(glb_dtmvtolt)  AND
                         YEAR (crapepr.dtdpagto) = YEAR(glb_dtmvtolt)   THEN
                         DO:
                             ASSIGN aux_qtmesdec = aux_qtmesdec - 1.
                         END.   
                END.    
          
           aux_dias = ((aux_qtmesdec - crapepr.qtprecal) * 30).
        
           IF   aux_dias < 0   THEN 
                LEAVE. /* Em dia */
        
           IF   aux_dias         <= 0              AND
                crapepr.dtdpagto <> ?              AND
                crapepr.flgpagto = NO              AND /* Conta Corrente */
                crapepr.dtdpagto >= glb_dtmvtolt   THEN 
                LEAVE. 
       END.
   ELSE
       DO:
           ASSIGN aux_dias = DYNAMIC-FUNCTION ("busca_dias_atraso_epr" IN h-b1wgen0136, 
                                                                INPUT crapepr.cdcooper,
                                                                INPUT crapepr.nrctremp,           
                                                                INPUT crapepr.nrdconta,
                                                                INPUT glb_dtmvtolt,
                                                                INPUT glb_dtmvtoan).

           IF aux_dias <= 0 THEN
              LEAVE.
           
       END.

   ASSIGN aux_qtprecal = 0
          aux_vlsdeved = 0.

   IF  (MONTH(glb_dtmvtolt) <>
        MONTH(glb_dtmvtopr))   THEN   /* Mensal */
        DO:
            ASSIGN aux_vlsdeved = crapepr.vlsdeved. /*Saldo calculado pelo 78*/         
        END.
   ELSE         
        DO:
            /* Saldo calculado pelo crps616.p e crps665.p */
            ASSIGN aux_vlsdeved = crapepr.vlsdevat.
            
            IF crapepr.tpemprst = 0 THEN
               ASSIGN aux_qtprecal = crapepr.qtlcalat.
            ELSE
               ASSIGN aux_qtprecal = crapepr.qtpcalat.
        END. 

   IF   glb_cdprogra = "crps398"   AND
        aux_vlsdeved <= 0   THEN 
        LEAVE.

   IF  crapepr.tpemprst = 0 THEN
       DO:
           ASSIGN aux_qtprecal = crapepr.qtprecal + aux_qtprecal
                  aux_dias     = ((aux_qtmesdec   - aux_qtprecal) * 30).
          
          
           IF   aux_dias < 0   THEN 
                LEAVE.
          
           /* Em dia */        
           IF   aux_dias         <= 0              AND
                crapepr.flgpagto = NO              AND   /* Conta Corrente */
                crapepr.dtdpagto <> ?              AND
                crapepr.dtdpagto >= glb_dtmvtolt   THEN 
                LEAVE. 
          
           IF   aux_dias <= 0           AND 
                crapepr.flgpagto = NO   THEN   /* Conta corrente */
                DO:
                    ASSIGN aux_dias = glb_dtmvtolt - crapepr.dtdpagto.
                END.

       END.

   LEAVE.

END. /* DO WHILE TRUE */   

/* ......................................................................... */ 
