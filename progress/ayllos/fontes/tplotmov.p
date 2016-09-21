/* .............................................................................

   Programa: Fontes/tplotmov.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Abril/2003.                    Ultima atualizacao: 04/05/2010

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela tplotmov.

   Alteracoes: 17/09/2004 - Incluido tplotmov 29(CI) (Mirtes)
   
               12/09/2006 - Excluida opcao "TAB" (Diego).  
               
               18/09/2008 - Alterado layout da tela
                          - Incluido tplotmov 35 - descto titulos (Guilherme).
                          
               08/04/2010 - Retirar o tipo de lote de seguro (tipo 15)
                            (Gabriel).          
                            
               04/05/2010 - Retirar o tipo de lote de poupança (Gabriel).             
............................................................................. */

DEF OUTPUT PARAM par_tplotmov AS INTEGER.

{ includes/var_online.i }

DEF VAR aux_lslotmov AS CHAR VIEW-AS SELECTION-LIST 
                        INNER-CHARS 40 INNER-LINES 12
                        LIST-ITEM-PAIRS 
                        "01 - Depositos a Vista",1,
                        "02 - Capital",2,
                        "03 - Pagto de Planos de Cotas",3,
                        "04 - Contratos de Emprestimos",4,
                        "05 - Lancamentos de Emprestimos",5,
                        "08 - Contratos de Planos de Cotas",8,
                        "09 - Aplicacoes RDCPRE e RDCPOS",9, 
                        "10 - Aplicacoes RDCA 30/60",10,
                        "11 - Resgates de Aplicacoes",11,
                        "12 - Lancamentos Automaticos",12,
                        "13 - Faturas (SAMAE, TELESC, etc)",13,
                        "16 - Proposta Cartao CREDICARD",16,
                        "17 - Debitos de Cartao de Credito",17,
                        "18 - Lancamentos de Cobrancas",18,
                        "19 - Custodia de Cheques",19,
                        "20 - Titulos",20,
                        "21 - Impostos PREFEITURA DE BLUMENAU",21,
                        "22 - Reservado para o SISTEMA",22,
                        "23 - Captura de cheques",23,
                        "24 - DOC",24,
                        "25 - TED",25,
                        "26 - Borderos de Desconto de Cheques",26,
                        "27 - Limite de Desconto de Cheques",27,
                        "29 - Lancamentos Conta de Investimento",29,
                        "35 - Limite de Desconto de Titulos",35
                        INIT 1.

FORM aux_lslotmov 
     WITH OVERLAY NO-BOX ROW 7 COLUMN 19 NO-LABELS FRAME f_tplotmov.
     
ON RETURN OF aux_lslotmov IN FRAME f_tplotmov DO:
   ASSIGN par_tplotmov = INTEGER(aux_lslotmov:SCREEN-VALUE).
   APPLY "GO".
END.

UPDATE aux_lslotmov WITH FRAME f_tplotmov.
HIDE FRAME f_tplotmov NO-PAUSE.

/* .......................................................................... */
