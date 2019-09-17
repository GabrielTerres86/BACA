/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank186.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Kelvin Souza Ott
   Data    : Setembro/2016                        Ultima atualizacao:
   
   Dados referentes ao programa:
   Frequencia: Sempre que for chamado (On-Line)
   
   Objetivo  : Retornar o valor do titulo vencido
      
   Alteracoes:
               20/01/2017 - PRJ 340-Nova Plataforma de Cobrança - Incluir os novos
                            parametros que serao retornados para a tela (Renato - Supero)
			   29/04/2019 - RITM0011951 - SCTASK0053162 Adicionar a data de vencimento da CIP 
			                no retorno do InternetBank186 (INC0033893) - Marcio (Mouts)
..............................................................................*/
{ sistema/internet/includes/var_ibank.i    }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i   }

DEF INPUT  PARAM pr_cdcooper        AS INTE         NO-UNDO.
DEF INPUT  PARAM pr_nrdconta        AS INTE         NO-UNDO.
DEF INPUT  PARAM pr_idseqttl        AS INTE         NO-UNDO.
DEF INPUT  PARAM pr_cdagenci        AS INTE         NO-UNDO.
DEF INPUT  PARAM pr_nrdcaixa        AS INTE         NO-UNDO.
DEF INPUT  PARAM pr_flmobile        AS INTE         NO-UNDO.

DEF INPUT  PARAM pr_titulo1         AS DECI         NO-UNDO.
DEF INPUT  PARAM pr_titulo2         AS DECI         NO-UNDO.
DEF INPUT  PARAM pr_titulo3         AS DECI         NO-UNDO.
DEF INPUT  PARAM pr_titulo4         AS DECI         NO-UNDO.
DEF INPUT  PARAM pr_titulo5         AS DECI         NO-UNDO.
DEF INPUT  PARAM pr_codigo_barras   AS CHAR         NO-UNDO.
DEF INPUT  PARAM pr_cdoperad        AS CHAR         NO-UNDO.
DEF INPUT  PARAM pr_cdorigem        AS INTE         NO-UNDO.

DEF VAR aux_vlfatura                AS DECI         NO-UNDO.
DEF VAR aux_vlrjuros                AS DECI         NO-UNDO.
DEF VAR aux_vlrmulta                AS DECI         NO-UNDO.
DEF VAR aux_fltitven                AS INTE         NO-UNDO.
DEF VAR aux_dtvencto                AS CHAR         NO-UNDO.
DEF VAR aux_nrdocbenf               AS DECI         NO-UNDO. 
DEF VAR aux_tppesbenf               AS CHAR         NO-UNDO.
DEF VAR aux_dsbenefic               AS CHAR         NO-UNDO. 
DEF VAR aux_vlrdescto               AS DECI         NO-UNDO.
DEF VAR aux_cdctrlcs                AS CHAR         NO-UNDO.
DEF VAR aux_flblq_vlr               AS INTE         NO-UNDO.
DEF VAR aux_cdcritic                AS INTE         NO-UNDO.
DEF VAR aux_des_erro                AS CHAR         NO-UNDO.
DEF VAR aux_dscritic                AS CHAR         NO-UNDO.
   
DEF OUTPUT PARAM xml_dsmsgerr       AS CHAR         NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.      

{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_consultar_valor_titulo
  aux_handproc = PROC-HANDLE NO-ERROR
                     (INPUT pr_cdcooper
                     ,INPUT pr_nrdconta
                     ,INPUT pr_cdagenci
                     ,INPUT pr_nrdcaixa
                     ,INPUT pr_idseqttl
                     ,INPUT pr_flmobile
                     ,INPUT pr_titulo1
                     ,INPUT pr_titulo2
                     ,INPUT pr_titulo3
                     ,INPUT pr_titulo4
                     ,INPUT pr_titulo5
                     ,INPUT pr_codigo_barras
                     ,INPUT pr_cdoperad
                     ,INPUT pr_cdorigem
                     ,OUTPUT 0     /* pr_nrdocbenf */
                     ,OUTPUT ""    /* pr_tppesb enf */
                     ,OUTPUT ""    /* pr_dsbenefic */
                     ,OUTPUT 0     /* pr_vlrtitulo */
                     ,OUTPUT 0     /* pr_vlrjuros  */
                     ,OUTPUT 0     /* pr_vlrmulta  */
                     ,OUTPUT 0     /* pr_vlrdescto */
                     ,OUTPUT ""    /* pr_cdctrlcs  */
                     ,OUTPUT 0     /* pr_flblq_valor */
                     ,OUTPUT 0     /* pr_fltitven  */
                     ,OUTPUT ""    /* pr_dtvencto  Márcio Mouts -RITM0011951*/					 
                     ,OUTPUT ""    /* pr_des_erro  */
                     ,OUTPUT 0     /* pr_cdcritic  */
                     ,OUTPUT "").  /* pr_dscritic  */
                     
                     
CLOSE STORED-PROC pc_consultar_valor_titulo aux_statproc = PROC-STATUS
      WHERE PROC-HANDLE = aux_handproc.

    ASSIGN aux_cdcritic  = 0
           aux_des_erro  = ""
           aux_dscritic = ""
           aux_vlfatura = 0
           aux_vlrjuros = 0
           aux_vlrmulta = 0
           aux_fltitven = 0
		   aux_dtvencto = ""
           aux_nrdocbenf = 0
           aux_tppesbenf = ""
           aux_dsbenefic = ""
           aux_vlrdescto = 0
           aux_cdctrlcs  = ""
           aux_flblq_vlr = 0
           aux_vlfatura  = pc_consultar_valor_titulo.pr_vlrtitulo
                           WHEN pc_consultar_valor_titulo.pr_vlrtitulo <> ?        
           aux_vlrjuros  = pc_consultar_valor_titulo.pr_vlrjuros
                           WHEN pc_consultar_valor_titulo.pr_vlrjuros <> ?
           aux_vlrmulta  = pc_consultar_valor_titulo.pr_vlrmulta
                           WHEN pc_consultar_valor_titulo.pr_vlrmulta <> ?
           aux_fltitven  = pc_consultar_valor_titulo.pr_fltitven
                           WHEN pc_consultar_valor_titulo.pr_fltitven <> ?
           aux_dtvencto  = pc_consultar_valor_titulo.pr_dtvencto
                           WHEN pc_consultar_valor_titulo.pr_dtvencto <> ?
           aux_nrdocbenf = pc_consultar_valor_titulo.pr_nrdocbenf
                           WHEN pc_consultar_valor_titulo.pr_nrdocbenf <> ?
           aux_tppesbenf = pc_consultar_valor_titulo.pr_tppesbenf
                           WHEN pc_consultar_valor_titulo.pr_tppesbenf <> ?
           aux_dsbenefic = pc_consultar_valor_titulo.pr_dsbenefic
                           WHEN pc_consultar_valor_titulo.pr_dsbenefic <> ?
           aux_vlrdescto = pc_consultar_valor_titulo.pr_vlrdescto
                           WHEN pc_consultar_valor_titulo.pr_vlrdescto <> ?
           aux_cdctrlcs  = pc_consultar_valor_titulo.pr_cdctrlcs
                           WHEN pc_consultar_valor_titulo.pr_cdctrlcs <> ?
           aux_flblq_vlr = pc_consultar_valor_titulo.pr_flblq_valor
                           WHEN pc_consultar_valor_titulo.pr_flblq_valor <> ?
           aux_cdcritic = pc_consultar_valor_titulo.pr_cdcritic
                          WHEN pc_consultar_valor_titulo.pr_cdcritic <> ?
           aux_des_erro = pc_consultar_valor_titulo.pr_des_erro
                          WHEN pc_consultar_valor_titulo.pr_des_erro <> ?
           aux_dscritic = pc_consultar_valor_titulo.pr_dscritic
                          WHEN pc_consultar_valor_titulo.pr_dscritic <> ?.
           
{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

IF  aux_des_erro <> "OK" OR
    aux_dscritic <> ""   THEN DO: 

    IF  aux_dscritic = "" THEN DO:   
        ASSIGN aux_dscritic =  "Nao foi possivel concluir a busca do valor do titulo".
    END.

    ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
    /* Se houver informaçao de controle de consulta */
    /* IF aux_cdctrlcs <> "" THEN*/
      ASSIGN xml_dsmsgerr = xml_dsmsgerr + "<cdctrlcs>" + aux_cdctrlcs + "</cdctrlcs>".  
    RETURN "NOK".
    
END.

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "<cabecalho> 
                                  <vlfatura>"  + TRIM(STRING(aux_vlfatura,'zzz,zzz,zzz,zzz,zzz,zz9.99')) + "</vlfatura>
                                  <vlrjuros>"  + TRIM(STRING(aux_vlrjuros,'zzz,zzz,zzz,zzz,zzz,zz9.99')) + "</vlrjuros>
                                  <vlrmulta>"  + TRIM(STRING(aux_vlrmulta,'zzz,zzz,zzz,zzz,zzz,zz9.99')) + "</vlrmulta>
                                  <fltitven>" + STRING(aux_fltitven) + "</fltitven>
                                  <nrdocbenf>" + STRING(aux_nrdocbenf) + "</nrdocbenf>
                                  <tppesbenf>" + aux_tppesbenf         + "</tppesbenf>
                                  <dsbenefic>" + aux_dsbenefic         + "</dsbenefic>
                                  <vlrdescto>" + TRIM(STRING(aux_vlrdescto,'zzz,zzz,zzz,zzz,zzz,zz9.99')) + "</vlrdescto>
                                  <cdctrlcs>"  + aux_cdctrlcs          + "</cdctrlcs>
                                  <flblq_vlr>" + STRING(aux_flblq_vlr) + "</flblq_vlr>
								  <dtvencto>" + STRING(aux_dtvencto) + "</dtvencto>
                                </cabecalho>".

RETURN "OK".
