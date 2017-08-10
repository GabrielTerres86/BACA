/* .............................................................................

   Programa: includes/var_conta.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Novembro/94.                    Ultima atualizacao: 24/04/2017

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Definicao das variaveis e forms da tela CONTA.

   Alteracoes: 17/11/94 - Incluido a quantidade de dias de estouro (tot.dias)
                          na tela. (Deborah)

               28/03/96 - Alterado para nao mostrar a quantidade de extratos
                          do mes (qtextmes) (Deborah).

               03/07/97 - Alterado para tratar extrato quinzenal (Deborah).

               21/08/97 - Colocado HELP no campo cdgraupr (Deborah).

               20/03/98 - Tratamento para milenio e troca para V8 - (Margarete)
               
               19/10/98 - Tratar dados do segundo titular (Deborah).

               20/10/98 - Tratar dados do responsavel (Deborah).

               27/11/98 - Colocar Help no tipo e na sit. da conta (Deborah).

               23/12/98 - Melhorar help do tipo de conta (Deborah). 

               13/04/1999 - Tratar tipo de emissao dos avisos (Deborah). 

               16/10/2000 - Alterar fone para 20 posicoes (Margarete/Planner)

               15/01/2001 - Substituir CCOH por COOP (Margarete/Planner).
               
               22/05/2002 - Incluir variavel aux_dstextab (Junior).

               01/08/2002 - Incluir nova situacao da conta (Margarete).

               15/10/2002 - Incluir campos inarqcbr e dsdemail. Foram removidos
                            os campos tel_nmsecext, tel_nmpesext e tel_nrfonext
                            (Junior).
                            
               20/08/2004 - Modificado o HELP e o VALIDATE do campo 
                            crapass.tpextcta para permitir o valor 0 ou 1
                            (0-nao emite, 1-emite) (Evandro).
                            
               22/09/2004 - Incluir opcao T, cadastra titulares (Margarete).
               
               25/11/2004 - Tratamento E/OU no crapttl (Ze).
               
               28/12/2004 - Incluido campo tel_flgiddep (Evandro).
               
               28/01/2005 - Modificados os termos "Agencia" ou "Ag" por "PAC"
                            (Evandro).

               22/02/2005 - Incluir opcao S, Sist.Financeiro Nacional(Evandro).
               
               13/12/2005 - Incluida opcao "E", Exclusao Conta Integracao
                            (Diego).
                            
               18/04/2006 - Alteracao no tel_inarqcbr (Ze).

               30/06/2006 - Substituicao do campo cartao, correspondente ao
                            cartao de cheque especial, pelo campo "Qtd. Folhas
                            Talao" (Julio)

               25/07/2006 - Incluido opcao "CH" no help e validate dos campos
                            tpdoc... (David).
                            
               22/08/2007 - Alterado cdgraupr da crapass para crapttl
                            (Guilherme).
                            
               10/12/2009 - Alterado inhabmen crapass p/ crapttl(Guilherme).
               
               05/01/2010 - Incluido FORMAT para o campo crapass.nmprimtl
                            (Diego).
                            
               26/07/2013 - Removido campo crapass.dsnatstl (Reinert).
               
               30/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               13/12/2013 - Alterado form f_conta de "CPF/CGC" para "CPF/CNPJ".
                            (Reinert)

			   24/04/2017 - Removido o form f_conta pois nao eh mais utilizado
			               (Adriano - P339).

............................................................................. */

DEF {1} SHARED VAR shr_dsnatura AS CHAR                              NO-UNDO.
DEF {1} SHARED VAR shr_inpessoa AS INT                               NO-UNDO.
DEF {1} SHARED VAR shr_cdtipcta LIKE craptip.cdtipcta                NO-UNDO.
DEF {1} SHARED VAR shr_dstipcta LIKE craptip.dstipcta                NO-UNDO.

DEF {1} SHARED VAR tel_nrdconta AS INT     FORMAT "zzzz,zzz,9"       NO-UNDO.
DEF {1} SHARED VAR tel_dsagenci AS CHAR    FORMAT "x(15)"            NO-UNDO.
DEF {1} SHARED VAR tel_dsinadim AS CHAR    FORMAT "x(1)"             NO-UNDO.
DEF {1} SHARED VAR tel_dslbacen AS CHAR    FORMAT "x(1)"             NO-UNDO.
DEF {1} SHARED VAR tel_dsgraupr AS CHAR    FORMAT "x(15)"            NO-UNDO.
DEF {1} SHARED VAR tel_nmsecext AS CHAR    FORMAT "x(24)"            NO-UNDO.
DEF {1} SHARED VAR tel_nmpesext AS CHAR    FORMAT "x(20)"            NO-UNDO.
DEF {1} SHARED VAR tel_nrfonext AS CHAR    FORMAT "X(20)"            NO-UNDO.
DEF {1} SHARED VAR tel_dstipcta AS CHAR    FORMAT "x(15)"            NO-UNDO.
DEF {1} SHARED VAR tel_dssitdct AS CHAR    FORMAT "x(25)"            NO-UNDO.
DEF {1} SHARED VAR tel_inmaicta AS CHAR    FORMAT "x(1)"             NO-UNDO.
DEF {1} SHARED VAR tel_hacartao AS CHAR    FORMAT "x(1)"             NO-UNDO.
DEF {1} SHARED VAR tel_dsddsdev AS CHAR    FORMAT "x(10)"            NO-UNDO.
DEF {1} SHARED VAR tel_flgiddep AS LOGICAL FORMAT "S/N"              NO-UNDO.

DEF {1} SHARED VAR tel_inarqcbr AS INT     FORMAT "9"                NO-UNDO.
DEF {1} SHARED VAR tel_dsdemail AS CHAR    FORMAT "x(43)"            NO-UNDO.

DEF {1} SHARED VAR tel_dslimcre AS CHAR    FORMAT "x(02)"            NO-UNDO.
DEF {1} SHARED VAR tel_nrcpfcgc AS DECIMAL FORMAT "zzzzzzzzzzzzzzzzzz" NO-UNDO.
DEF {1} SHARED VAR tel_nrcpfstl AS DECIMAL FORMAT "zzzzzzzzzzzzzzzzzz" NO-UNDO.
DEF {1} SHARED VAR tel_nrcpfrsp AS DECIMAL FORMAT "zzzzzzzzzzzzzzzzzz" NO-UNDO.
DEF {1} SHARED VAR tel_dtaltera AS DATE    FORMAT "99/99/99"         NO-UNDO.
DEF {1} SHARED VAR dis_nrcpfcgc AS CHAR    FORMAT "x(18)"            NO-UNDO.
DEF {1} SHARED VAR dis_nrcpfstl AS CHAR    FORMAT "x(18)"            NO-UNDO.
DEF {1} SHARED VAR dis_nrcpfrsp AS CHAR    FORMAT "x(18)"            NO-UNDO.
DEF {1} SHARED VAR tel_qtfoltal AS INTEGER FORMAT "99"               NO-UNDO.

DEF {1} SHARED VAR aux_nrdconta AS INT     FORMAT "zzzz,zzz9"        NO-UNDO.
DEF {1} SHARED VAR aux_cdtipcta AS INT     FORMAT "z9"               NO-UNDO.
DEF {1} SHARED VAR aux_cdsitdct AS INT     FORMAT "z9"               NO-UNDO.
DEF {1} SHARED VAR aux_contador AS INT     FORMAT "z9"               NO-UNDO.
DEF {1} SHARED VAR aux_cddopcao AS CHAR                              NO-UNDO.
DEF {1} SHARED VAR aux_nmsegntl AS CHAR                              NO-UNDO.
DEF {1} SHARED VAR aux_cdagenci AS INT     FORMAT "zz9"              NO-UNDO.
DEF {1} SHARED VAR aux_stimeout AS INT                               NO-UNDO.
DEF {1} SHARED VAR aux_nrseqdig AS INT                               NO-UNDO.
DEF {1} SHARED VAR aux_cdsecext AS INT                               NO-UNDO.
DEF {1} SHARED VAR aux_tpextcta AS INT                               NO-UNDO.
DEF {1} SHARED VAR aux_nrdeanos AS INT                               NO-UNDO.
DEF {1} SHARED VAR aux_nrdmeses AS INT                               NO-UNDO.
DEF {1} SHARED VAR aux_dsdidade AS CHAR                              NO-UNDO.
DEF {1} SHARED VAR aux_confirma AS CHAR FORMAT "x"                   NO-UNDO. 
DEF {1} SHARED VAR aux_dstextab AS CHAR                              NO-UNDO.
DEF {1} SHARED VAR aux_nmsegttl AS CHAR                              NO-UNDO.

DEF {1} SHARED VAR par_cdcritic AS INTE                              NO-UNDO.

DEF {1} SHARED FRAME f_conta.

DEF BUFFER crabttl5 FOR crapttl.


/* .......................................................................... */
