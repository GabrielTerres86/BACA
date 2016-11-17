/* .............................................................................

   Programa: Includes/Sldepr_opcoes.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson/Margarete
   Data    : Junho/2001.                       Ultima atualizacao: 04/07/2012 

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Executa opcoes da tela SLDEPR.

   Alteracoes: 03/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando. 

               13/05/2008 - Ajuste comando FIND(craphis) utilizava FOR p/ acesso
                            (Sidnei - Precise) 
                
               30/12/2008 - Tratar opcao de imprimir (Gabriel).
               
               23/11/2009 - Alteracao Codigo Historico (Kbase).
               
               13/08/2010 - Mudada a passagem de parametros para o proepr_c
                            (Gabriel).
                            
               27/05/2011 - Passado tratameto para fonte extrato_epr.p
                            (Gabriel Capoia/DB1)
                            
               04/07/2012 - Considerar novo tipo de emprestimo (Gabriel)             
............................................................................. */
                                  
IF   FRAME-VALUE = tel_extratos   THEN
     DO:
         RUN fontes/extrato_epr.p(INPUT tt-dados-epr.nrdconta,
                                  INPUT tt-dados-epr.nrctremp,
                                  INPUT tt-dados-epr.tpemprst).
     END.
ELSE
IF   FRAME-VALUE = tel_dsdemais   THEN
     DO:
         IF   tt-dados-epr.nrdrecid = ?   THEN
              DO:
                  MESSAGE "Nao existem informacoes"
                          "complementares para este contrato.".
                  NEXT.
              END.

         RUN fontes/proepr_c.p (INPUT tt-dados-epr.nrdconta,
                                INPUT tt-dados-epr.nrctremp).
     END.
ELSE 
IF  FRAME-VALUE = tel_imprimir   THEN
    DO:
        BUFFER-COPY tt-dados-epr TO tt-proposta-epr.

        RUN fontes/proepr_m.p (INPUT tt-dados-epr.nrdrecid,
                               INPUT TABLE tt-proposta-epr).
    END.
                     
/* ..........................................................................*/

