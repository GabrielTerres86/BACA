/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank218.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Pablão
   Data    : Maio/2018                     Ultima atualizacao: 00/00/0000
   
   Dados referentes ao programa:
   
   Frequencia: Sempre que for chamado (On-Line)
   
   Objetivo  : Retornar lista de horários de operações de pagamento
   
   Alteracoes: 
 
..............................................................................*/
    
{ sistema/internet/includes/var_ibank.i    }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i   }

DEF  INPUT PARAM par_cdcooper LIKE crapttl.cdcooper                    NO-UNDO.
DEF  INPUT PARAM par_cdagenci LIKE crapage.cdagenci                    NO-UNDO.
DEF  INPUT PARAM par_cdcanal  AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nrdconta LIKE crapass.nrdconta                    NO-UNDO.

DEF OUTPUT PARAM TABLE FOR xml_operacao.

DEF VAR xml_ret AS CHAR                                                                                    NO-UNDO.

  { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
 
  RUN STORED-PROCEDURE pc_obtem_horarios_pagamentos aux_handproc = PROC-HANDLE NO-ERROR
                          ( INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_cdcanal,
                            INPUT par_nrdconta,
						   OUTPUT "",
                           OUTPUT "").

  CLOSE STORED-PROC pc_obtem_horarios_pagamentos aux_statproc = PROC-STATUS
          WHERE PROC-HANDLE = aux_handproc.
  
  { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
   
  ASSIGN xml_ret = pc_obtem_horarios_pagamentos.pr_xml_ret.
    
  CREATE xml_operacao.
  ASSIGN xml_operacao.dslinxml = xml_ret.

  RETURN "OK".