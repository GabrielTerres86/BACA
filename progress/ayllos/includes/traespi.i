/* ............................................................................

   Programa: includes/traespi.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Fernando Hilgenstieler
   Data    : Julho/2003.               Ultima atualizacao: 12/11/2013

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Consulta transacoes realizadas em especie.

   Alteracoes: 23/03/2005 - Inclusao parametro 
                                     bo imp ctr_depositos e
                                     bo imp ctr_saques(Mirtes)

               19/10/2005 - Inclusao parametro cooperativa
                                     bo imp ctr depositos e
                                     bo imp ctr saques(Julio)

               02/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
               
               10/12/2009 - Adicionados parametros na chamada da procedure
                            bo imp ctr saques da bo_controle_saques
                            (Fernando).
                            
               04/05/2010 - Ajustado programa para as movimentações em
                            espécie criadas na rotina 20 (a partir da
                            craptvl). (Fernando) 
                                          
               24/06/2010 - Nao estava imprimindo docto outros dias (Magui).
               
               01/12/2011 - Tratamento para a transferencia intercooperativa.
                            Deletar sempre as instancias das BO´s
                            (Gabriel).
                            
               18/07/2012 - Adicionado parametro tel_nrdconta. (Jorge)
               
               12/11/2013 - Adequacao da regra de negocio a b1wgen0135.p
                            (conversao tela web). (Fabricio)
............................................................................. */
           
UPDATE tel_dtmvtolt
       tel_tpdocmto 
       WITH FRAME f_opcao2.                               

IF   tel_tpdocmto = 4   THEN
     DO:
         UPDATE tel_cdagenci
                tel_nrdcaixa
                tel_nrdocmto
                WITH FRAME f_opcao3.
     
         ASSIGN tel_nrdolote = 11000 + tel_nrdcaixa
                tel_cdbccxlt = 11.
     
     END.
ELSE 
     DO:
         UPDATE tel_cdagenci
                tel_cdbccxlt 
                tel_nrdolote
                tel_nrdocmto
                WITH FRAME f_opcao4.

         IF   tel_tpdocmto = 0 THEN
              DO:
                  ASSIGN tel_nrdconta = 0.
                  DISP tel_nrdconta WITH FRAME f_nrdconta.
                  UPDATE tel_nrdconta WITH FRAME f_nrdconta.
              END.
     END.

ASSIGN aux_regexist = FALSE.

CLEAR FRAME f_transacoes ALL NO-PAUSE.

RUN consulta-controle-movimentacao IN h-b1wgen0135 
                                        (INPUT glb_cdcooper,
                                         INPUT tel_cdagenci,
                                         INPUT 1,
                                         INPUT tel_dtmvtolt,
                                         INPUT tel_cdbccxlt,
                                         INPUT tel_nrdolote,
                                         INPUT tel_nrdocmto,
                                         INPUT tel_nrdconta,
                                        OUTPUT TABLE tt-transacoes-especie,
                                        OUTPUT TABLE tt-erro).

IF RETURN-VALUE = "NOK" THEN
DO:
    FIND FIRST tt-erro NO-LOCK NO-ERROR.
    MESSAGE tt-erro.dscritic.
    CLEAR FRAME f_transacoes ALL NO-PAUSE.
    LEAVE.
END.

FIND FIRST tt-transacoes-especie NO-LOCK NO-ERROR.

IF AVAIL tt-transacoes-especie THEN
DO:
    DISP tt-transacoes-especie.cdagenci
         tt-transacoes-especie.nrdolote
         tt-transacoes-especie.nrdconta
         tt-transacoes-especie.nmprimtl
         tt-transacoes-especie.nrdocmto
         tt-transacoes-especie.tpoperac
         tt-transacoes-especie.vllanmto             
         tt-transacoes-especie.dtmvtolt      
         tt-transacoes-especie.sisbacen     
         WITH FRAME f_transacoes.
    
    ASSIGN aux_tpoperac = IF tt-transacoes-especie.tpoperac = "DEPOSITO" THEN
                               1
                           ELSE
                               2.

    MESSAGE "Deseja imprimir?" UPDATE tel_cddopcao.
               
    IF   tel_cddopcao = NO THEN
         LEAVE.
    
    RUN reimprime-controle-movimentacao IN h-b1wgen0135 
                                        (INPUT glb_cdcooper,
                                         INPUT tt-transacoes-especie.nmrescop,
                                         INPUT tel_cdagenci,
                                         INPUT tt-transacoes-especie.nrdcaixa,
                                         INPUT tt-transacoes-especie.cdopecxa,
                                         INPUT tel_dtmvtolt,
                                         INPUT tel_cdbccxlt,
                                         INPUT tel_nrdolote,
                                         INPUT tel_nrdocmto,
                                         INPUT tel_tpdocmto,
                                         INPUT tt-transacoes-especie.nrseqaut,
                                         INPUT tt-transacoes-especie.nrdctabb,
                                         INPUT aux_tpoperac,
                                         INPUT 1,
                                        OUTPUT aux_nmarqimp,
                                        OUTPUT aux_nmarqpdf,
                                        OUTPUT TABLE tt-erro).
    
    IF RETURN-VALUE = "NOK" THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.
        MESSAGE tt-erro.dscritic.
        CLEAR FRAME f_transacoes ALL NO-PAUSE.
        LEAVE.
    END.     
END.
/*............................................................................*/

