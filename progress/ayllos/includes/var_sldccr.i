/* .............................................................................

   Programa: Includes/var_sldccr.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Marco/97.                           Ultima atualizacao: 07/10/2010

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Criacao das variaveis para tratamento de cartao de credito.
   Alteracoes: 09/06/2009 - Inclusao de Temp-table tt_dados_promissoria para
                            utilizacao na impressao da promissoria 
                            (GATI - Eder)
                            
               07/10/2010 - A defini‡Æo da tabela tt_dados_promissora foi
                            movida para a include b1wgen0028tt.i
                            GATI - Sandro             
                                                        
............................................................................. */

DEF {1} SHARED VAR aux_flgimp2v AS LOGI                                NO-UNDO.

DEF {1} SHARED VAR aux_dsgraupr AS CHAR INIT
        "Conjuge,Filhos,Companheiro,Primeiro Titular,Segundo Titular"  NO-UNDO.
DEF {1} SHARED VAR aux_cdgraupr AS CHAR INIT "1,3,4,5,6"               NO-UNDO.

/* .......................................................................... */
