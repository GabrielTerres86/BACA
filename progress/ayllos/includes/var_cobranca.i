/*............................................................................

  Programa: includes/var_cobranca.i
  Sistema : Conta-Corrente - Cooperativa de Credito
  Sigla   : CRED
  Autor   : Gabriel
  Data    : Dezembro/2010                    Ultima atualizacao: 24/04/2015
  
  Dados referentes ao programa:
  
  Frequancia: Diario (On-line)
  Objetivo  : Arquivo com variaveis/form da rotina COBRANCA da tela ATENDA.
  
  Alteracoes: 19/05/2011 - Informar se eh cobranca registrada (Guilherme).
  
              21/07/2011 - Implementar a impressao para a Cobranca Registrada
                           (Gabriel)                                  
                           
              22/08/2011 - Alterado campo dsorgarq na coluna origem para o
                           campo dsorgban do browse b-cadastro-bloqueto 
                           (Adriano).                                        
                                                          
              06/09/2011 - Incluido a var h-b1wgen0110 (Adriano).
              
              04/11/2011 - Aumento do formato do vllbolet (Gabriel).
              
              28/03/2013 - Aumento do formato do numero CEB para 5 digitos
                           (53010 - Rafael).
                           
              10/05/2013 - Retirado campo referente ao valor maximo do boleto
                           na internet. Retirado campo vllboleto. (Jorge)
                           
              05/06/2013 - Projeto Melhorias da Cobranca - incluir opcao
                           de arquivo de retorno CNAB400. (Rafael)
                           
              12/09/2013 - Inclusao do campo "Convenio Homologado" (Carlos)
                                                                            
              24/04/2015 - Incluido campos "Cooperado Emite e Expede" e
                           "Cooperativa Emite e Expede", removido opcao de 
                           alteracao e cancelamento de convenio. 
                           (Projeto DP 219 - Reinert)
............................................................................ */

/* Botoes da tela Eventos em andamento */
DEF VAR tel_dsdopcao AS CHAR INIT " Consulta "                       NO-UNDO.

DEF BUTTON btn_titular LABEL " Outros Titulares ".

DEF VAR aux_confirma AS CHAR                                         NO-UNDO.
DEF VAR aux_contador AS INTE                                         NO-UNDO.
DEF VAR aux_dsdmesag AS CHAR                                         NO-UNDO.
DEF VAR aux_iddopcao AS INTE                                         NO-UNDO.
DEF VAR aux_dsdregis AS CHAR                                         NO-UNDO.
DEF VAR par_msgdpsnh AS CHAR                                         NO-UNDO.
DEF VAR aux_dsdlabel AS CHAR                                         NO-UNDO.
DEF VAR aux_flgfirst AS LOGI                                         NO-UNDO.
DEF VAR aux_nrdlinha AS INTE                                         NO-UNDO.
DEF VAR aux_dsarqcbr AS CHAR 
    INIT "Nao recebe,Outros,FEBRABAN 240,CNAB400"                     NO-UNDO.
DEF VAR aux_dsiduser AS CHAR                                         NO-UNDO.

DEF VAR tel_dsarqcbr AS CHAR                                         NO-UNDO.

DEF VAR par_dsdtitul AS CHAR                                         NO-UNDO.
DEF VAR par_flgimpri AS LOGI                                         NO-UNDO.

DEF VAR h-b1wgen0082 AS HANDLE                                       NO-UNDO.
DEF VAR h-b1wgen0110 AS HANDLE                                       NO-UNDO.

DEF QUERY q-cadastro-bloqueto FOR tt-cadastro-bloqueto.
        
DEF BROWSE b-cadastro-bloqueto QUERY q-cadastro-bloqueto
    DISPLAY tt-cadastro-bloqueto.nrconven COLUMN-LABEL "Convenio"
            tt-cadastro-bloqueto.dsorgban COLUMN-LABEL "Origem" 
                                                       FORMAT "x(24)"
            tt-cadastro-bloqueto.flgativo COLUMN-LABEL "Sit.Convenio"
                                                       FORMAT "ATIVO/INATIVO"
            tt-cadastro-bloqueto.nrcnvceb COLUMN-LABEL "CEB" FORMAT "zzzz9"
            tt-cadastro-bloqueto.dssitceb COLUMN-LABEL "Sit.Cob."
            tt-cadastro-bloqueto.flgregis COLUMN-LABEL "Registr."
                                                       FORMAT "SIM/NAO"
            WITH NO-BOX 4 DOWN.
            
DEF QUERY q-titulares-c FOR tt-titulares.

DEF BROWSE b-titulares-c QUERY q-titulares-c
    DISPLAY tt-titulares.idseqttl FORMAT "zz9"
            tt-titulares.nmextttl FORMAT "x(50)"
            WITH 4 DOWN OVERLAY TITLE " Titulares ".

FORM b-cadastro-bloqueto
        HELP "Utilize as SETAS para navegar e ENTER para a consultar."

" -------------------------------------------------------------------------- "
     tt-cadastro-bloqueto.dtcadast  AT 08 LABEL "Ult.Alt"
     tt-cadastro-bloqueto.cdoperad  AT 32 LABEL "Ope." FORMAT "x(38)"
     SKIP
" -------------------------------------------------------------------------- "
     
     tel_dsdopcao    AT 35 NO-LABEL FORMAT "x(10)"

    WITH SIDE-LABELS CENTERED WIDTH 78 OVERLAY ROW 9

                   TITLE " COBRANCA " FRAME f_cobranca.

FORM SKIP(1)
     tt-cadastro-bloqueto.nrconven AT 25 LABEL "Convenio"
        HELP "Entre com o numero do convenio BB ou <F7> para listar."         
     tt-cadastro-bloqueto.dsorgarq AT 18 LABEL "Origem Convenio" FORMAT "x(22)"
                                                     
     tt-cadastro-bloqueto.dssitceb AT 16 LABEL "Situacao Cobranca" 
        HELP "Informe a situacao (A)tivo ou (I)nativo."
     tt-cadastro-bloqueto.flgregis AT 23 LABEL "Registrada" 
                                         FORMAT "SIM/NAO"
     tt-cadastro-bloqueto.flcooexp AT 09 LABEL "Cooperado Emite e Expede"
                                         FORMAT "S/N"
     tt-cadastro-bloqueto.flceeexp AT 07 LABEL "Cooperativa Emite e Expede"
                                         FORMAT "S/N"
     tt-cadastro-bloqueto.inarqcbr AT 11 LABEL "Recebe Arquivo Retorno" FORMAT "9"
        VALIDATE(CAN-DO("0,1,2,3",STRING(tt-cadastro-bloqueto.inarqcbr)),
                        "269 - Valor errado.")
         HELP "Informe (0-Nao recebe Arq,1-Outros,2-FEBRABAN 240,3-CNAB400)"

     tel_dsarqcbr                  AT 37 NO-LABEL FORMAT "x(20)"

     tt-cadastro-bloqueto.dsdemail AT 11 LABEL "E-mail Arquivo Retorno" FORMAT "x(40)"
         HELP "E-mail para retorno do arq. de cobranca - F7 para listar"
     
     tt-cadastro-bloqueto.flgcruni AT 08 LABEL "Utiliza Credito Unificado"
     
     tt-cadastro-bloqueto.flgcebhm AT 14 LABEL "Convenio Homologado"

     btn_titular                   AT 35
         HELP "<ENTER> p/ visualizar os demais titulares."
     
     SKIP(1)

     WITH OVERLAY SIDE-LABELS CENTERED WIDTH 78 ROW 7 FRAME f_habilitacao.    

FORM b-titulares-c  HELP "Use as SETAS para navegar ou F4 para sair"
     SKIP
     WITH NO-BOX ROW 10 COLUMN 2 OVERLAY CENTERED FRAME f_titulares-c.

ON ENTRY , VALUE-CHANGED OF b-cadastro-bloqueto DO:

    IF   NOT AVAIL tt-cadastro-bloqueto   THEN
         RETURN.

    DISPLAY tt-cadastro-bloqueto.dtcadast
            tt-cadastro-bloqueto.cdoperad  WITH FRAME f_cobranca.

END.

ON CHOOSE OF btn_titular IN FRAME f_habilitacao DO:  

   APPLY "GO".
   RETURN.
   
END.


/* ......................................................................... */

