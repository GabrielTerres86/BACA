/* .............................................................................
   
   Programa: includes/impres.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Outubro/96.                        Ultima atualizacao: 29/08/2011

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Fazer a impressao dos extratos solicitados na hora.

   Alteracoes: 23/02/99 - Tratar tipo = 5 Poupanca Programada (Odair)

               16/03/2000 - Tratar tipo de extrato 6 - IR pessoa juridica
                            (Deborah).

               24/04/2002 - Tratar impressao dos cheques depositados (Edson).
               
               07/10/2004 - Tratar para efetuar impressao CI(Mirtes)

               18/01/2005 - Impressao Extrado de Capital (Evandro).

               31/08/2005 - Passado parametro tt-impres.dtreffim para tipo de
                            extrato igual a 1 (Diego).

               27/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
                
               24/07/2008 - Incluido os parametros "tt-impres.dtrefere" e
                            "tt-impres.dtreffim" na chamada do programa
                            fontes/impextppr.p para poupanca programada (Elton).
               
               26/01/2009 - Incluido tratamento de tarifas (Gabriel).    
               
               01/10/2009 - Incluir opcao para listar depositos identificados
                            no extrato de conta corrente (David).
                            
               16/11/2010 - Inclusao da opcao de extrato de aplicacoes 
                            (Henrique).
                            
               29/08/2011 - Adaptado para uso de BO (Gabriel Capoia - DB1).
                            
............................................................................. */

 DO:

    ASSIGN aux_flgfirst = TRUE
           aux_flgexist = TRUE
           aux_flgcance = FALSE.

    /* Seleciona todos criados agora */
    Impresao: FOR EACH btt-impres:

        IF  NOT btt-impres.flgemiss THEN
            DO:
                DELETE btt-impres.
                RUN Atualizar_Tela.
                NEXT Impresao.
            END.
        
        IF  aux_flgexist THEN
            DO:
                ASSIGN aux_flgexist = FALSE.
                MESSAGE "Aguarde...".
            END.

        RUN Imprimi_Dados (INPUT btt-impres.nrdconta, 
                           INPUT btt-impres.tpextrat, 
                           INPUT btt-impres.dtrefere, 
                           INPUT btt-impres.dtreffim, 
                           INPUT btt-impres.inisenta, 
                           INPUT btt-impres.inrelext, 
                           INPUT btt-impres.inselext, 
                           INPUT btt-impres.nrctremp, 
                           INPUT btt-impres.nraplica, 
                           INPUT btt-impres.nranoref,
                           INPUT TRUE).

        ASSIGN aux_flgfirst = FALSE.

        IF  RETURN-VALUE = "NOK" THEN
            DO:
                ASSIGN aux_flgcance = TRUE.
                LEAVE.
            END.
        ELSE
           DO:
               DELETE btt-impres.
               RUN Atualizar_Tela.
           END.
    END.
        
    IF  aux_flgcance  THEN
        NEXT.

    ASSIGN aux_flgimpri = TRUE
           aux_contaimp = 1.

    HIDE MESSAGE NO-PAUSE.

END.  /*  Fim do includes   */

