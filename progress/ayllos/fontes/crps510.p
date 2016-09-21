/* .............................................................................

   Programa: Fontes/crps510.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Sidnei - Precise
   Data    : Abril/2008                        Ultima atualizacao: 29/04/2008

   Dados referentes ao programa:

   Frequencia: On-line         
   Objetivo  : Calculo e credito do retorno de sobras e juros sobre o capital.
               Atende a solicitacao 106. Emite relatorio 43.
               Baseado no programa fontes/crps408.p

   /* ATENCAO: ESSE PROGRAMA SOMENTE CREDITA RETORNO SOBRE JUROS AO CAPITAL E
      ======== SOBRE RENDIMENTOS DE APLICACOES SE FOI PEDIDO CREDITO DE RETORNO
               SOBRE JUROS PAGOS */
  /*************
      O campo BASE DE RENDIMENTOS SOBRE APLICACOES e composto:
      RDCA30 - rendimentos histor 116 durante o ano
      RDCA60 - rendimentos histor 179 durante o ano
      RDCPRE - provisao histor(474) + rendimento histor(475) -
               estorno provisao histor(463)
      RDCPOS - provisao histor(529) + rendimento histor(532) -
               estorno provisao histor(531)
      RDPP   - rendimentos histor(151).
   *************/            
   Alteracoes: 
                            
............................................................................. */

DEF STREAM str_1.  /*  Para relatorio dos juros calculados  */
DEF STREAM str_3.  /*  Para entrada/saida de incorporacao/retorno  */
DEF STREAM str_4.  /*  Para demonstrativo detalhado  */

/* O STREAM STR_2 EH UTILIZADO NO SUB-PROGRAMA CRPS048_2.P  */

{ includes/var_batch.i }
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdcritic = 0
       glb_dscritic = "".
 
glb_cdprogra = "crps510".

glb_flgbatch = FALSE.

RUN fontes/iniprg.p.

IF  glb_cdcritic > 0   THEN
    RETURN.

ETIME(TRUE).

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_emite_retorno_sobras aux_handproc = PROC-HANDLE
   (INPUT glb_cdcooper,                                                  
    INPUT glb_cdprogra,
    OUTPUT 0, 
    OUTPUT "").

IF  ERROR-STATUS:ERROR  THEN DO:
    
    DO  aux_qterrora = 1 TO ERROR-STATUS:NUM-MESSAGES:
        ASSIGN aux_msgerora = aux_msgerora + 
                              ERROR-STATUS:GET-MESSAGE(aux_qterrora) + " ".
    END.
        
    MESSAGE aux_msgerora.

END.
ELSE DO:

    CLOSE STORED-PROCEDURE pc_emite_retorno_sobras
                           WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

    ASSIGN glb_cdcritic = 0
           glb_dscritic = ""
           glb_cdcritic = pc_emite_retorno_sobras.pr_cdcritic 
                          WHEN pc_emite_retorno_sobras.pr_cdcritic <> ?
           glb_dscritic = pc_emite_retorno_sobras.pr_dscritic 
                          WHEN pc_emite_retorno_sobras.pr_dscritic <> ?.

    IF  glb_dscritic <> ""  THEN

       MESSAGE glb_dscritic.

    ELSE DO:
      
       HIDE MESSAGE NO-PAUSE.
       MESSAGE "Relatorios executados com sucesso !".
       RUN fontes/fimprg.p.
     
    END.
END.
