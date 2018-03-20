/* ............................................................................

   Programa: includes/var_contas.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Fevereiro/2006.                  Ultima atualizacao: 25/01/2016

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Definicao das variaveis e forms da tela CONTAS e CONTAJ.

   Alteracoes: 05/02/2007 - Alterado formato da variavel do tipo DATE
                            "tel_dtaltera" para "99/99/9999" (Elton). 
               
               19/03/2007 - Alterado formato do campo tel_dsdemail (Elton).

               31/07/2007 - Aumentado o tamanho do e-mail para 40 caracteres
                            (Evandro).
                            
               13/04/2008 - Retirada dos campos Rec. Arq. Cobranca (Ze).

               19/06/2009 - Incluido ITEM de bens (Gabriel).
               
               03/12/2009 - Incluido na pessoa fisica o item "INF. ADICIONAL" 
                            (Elton).
                            
               25/09/2010 - Incluido opcao "PROCURADORES" p/ pessoa fisica 
                            (Jose Luis, DB1)             
                            
               23/03/2011 - Incluir rotina de DDA (Gabriel).             
                                                 
               04/04/2011 - Incluido variavel aux_impcadto (Adriano).
               
               27/06/2012 - Retirado a declaracao "SHARED FRAME f_conta"
                            (Adriano).
               
               30/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               24/07/2014 - Projeto Automatização de Consultas em Propostas
                            de Crédito (Jonata-RKAM).
                           
               30/12/2014 - Incluir item novo "LIBERAR/BLOQUEAR". (James)
               
               29/01/2015 - Incluido de opcao Convenio CDC
                            (Andre Santos - SUPERO)
                            
               02/03/2015 - Incluido de opcao Convenio CDC - Pessoa Fisica
                            (Andre Santos - SUPERO)
                            
               01/09/2015 - Reformulacao cadastral (Tiago Castro-RKAM). 
               
               25/01/2016 - #383108 Ajuste das opcoes da tela pois nao estavam
                            aparecendo as opcoes BENS e INF. ADICIONAIS
                            corretamente (Carlos)

               08/03/2018 - Declaraçao das variáveis "shr_cdtipcta" e "shr_dstipcta" 
                            alteradas para nao referenciarem mais a tabela CRAPTIP.
                            PRJ366 (Lombardi).
.............................................................................*/

DEF {1} SHARED VAR shr_nrdconta LIKE crapttl.nrdconta                NO-UNDO.
DEF {1} SHARED VAR shr_idseqttl LIKE crapttl.idseqttl                NO-UNDO.
DEF {1} SHARED VAR shr_dsnatura AS CHAR                              NO-UNDO.
DEF {1} SHARED VAR shr_inpessoa AS INT                               NO-UNDO.
DEF {1} SHARED VAR shr_cdtipcta AS INT                               NO-UNDO.
DEF {1} SHARED VAR shr_dstipcta AS CHAR    FORMAT "x(50)"            NO-UNDO.
DEF {1} SHARED VAR shr_cdsecext LIKE crapdes.cdsecext                NO-UNDO.
DEF {1} SHARED VAR shr_nmsecext LIKE crapdes.nmsecext                NO-UNDO.

DEF {1} SHARED VAR tel_dsdopcao AS CHAR    FORMAT "x(24)" EXTENT 24  NO-UNDO.
DEF {1} SHARED VAR tel_dspessoa AS CHAR    FORMAT "x(08)"            NO-UNDO.
DEF {1} SHARED VAR tel_nrdconta AS INT     FORMAT "zzzz,zzz,9"       NO-UNDO.
DEF {1} SHARED VAR tel_dsagenci AS CHAR    FORMAT "x(15)"            NO-UNDO.
DEF {1} SHARED VAR tel_dsinadim AS CHAR    FORMAT "x(1)"             NO-UNDO.
DEF {1} SHARED VAR tel_dslbacen AS CHAR    FORMAT "x(1)"             NO-UNDO.
DEF {1} SHARED VAR tel_dsgraupr AS CHAR    FORMAT "x(15)"            NO-UNDO.
DEF {1} SHARED VAR tel_nmsecext AS CHAR    FORMAT "x(24)"            NO-UNDO.
DEF {1} SHARED VAR tel_nmpesext AS CHAR    FORMAT "x(20)"            NO-UNDO.
DEF {1} SHARED VAR tel_nrfonext AS CHAR    FORMAT "X(20)"            NO-UNDO.
DEF {1} SHARED VAR tel_dstipcta AS CHAR    FORMAT "x(15)"            NO-UNDO.
DEF {1} SHARED VAR tel_dssitdct AS CHAR    FORMAT "x(18)"            NO-UNDO.
DEF {1} SHARED VAR tel_inmaicta AS CHAR    FORMAT "x(1)"             NO-UNDO.
DEF {1} SHARED VAR tel_hacartao AS CHAR    FORMAT "x(1)"             NO-UNDO.
DEF {1} SHARED VAR tel_dsddsdev AS CHAR    FORMAT "x(10)"            NO-UNDO.
DEF {1} SHARED VAR tel_flgiddep AS LOGICAL FORMAT "S/N"              NO-UNDO.
DEF {1} SHARED VAR tel_idseqttl AS INTE    FORMAT "9"                NO-UNDO.
DEF {1} SHARED VAR tel_dsestcvl AS CHAR    FORMAT "X(13)"            NO-UNDO.
DEF {1} SHARED VAR tel_cdsexotl AS CHAR    FORMAT "X"                NO-UNDO.
/** definido que nome fantasia tera 40 posicoes **/
DEF {1} SHARED VAR tel_nmfatasi AS CHAR    FORMAT "X(40)"            NO-UNDO.
DEF {1} SHARED VAR tel_nmdavali AS CHAR    FORMAT "x(40)"            NO-UNDO.

DEF {1} SHARED VAR tel_dsdemail AS CHAR    FORMAT "x(40)"            NO-UNDO.

DEF {1} SHARED VAR tel_dslimcre AS CHAR    FORMAT "x(02)"            NO-UNDO.
DEF {1} SHARED VAR tel_nrcpfcgc AS CHAR    FORMAT "X(18)"            NO-UNDO.
DEF {1} SHARED VAR tel_nrcpfstl AS CHAR    FORMAT "X(18)"            NO-UNDO.
DEF {1} SHARED VAR tel_nrcpfrsp AS CHAR    FORMAT "X(18)"            NO-UNDO.
DEF {1} SHARED VAR tel_dtaltera AS DATE    FORMAT "99/99/9999"       NO-UNDO.
DEF {1} SHARED VAR dis_nrcpfcgc AS CHAR    FORMAT "x(18)"            NO-UNDO.
DEF {1} SHARED VAR dis_nrcpfstl AS CHAR    FORMAT "x(18)"            NO-UNDO.
DEF {1} SHARED VAR dis_nrcpfrsp AS CHAR    FORMAT "x(18)"            NO-UNDO.

DEF {1} SHARED VAR aux_impcadto AS LOG                               NO-UNDO.
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
DEF {1} SHARED VAR aux_confirma AS CHAR FORMAT "!"                   NO-UNDO. 
DEF {1} SHARED VAR aux_dstextab AS CHAR                              NO-UNDO.
DEF {1} SHARED VAR aux_nmsegttl AS CHAR                              NO-UNDO.
DEF {1} SHARED VAR aux_nmmesano AS CHAR    EXTENT 12
                       INIT ["JANEIRO","FEVEREIRO","MARCO",
                             "ABRIL","MAIO","JUNHO",
                             "JULHO","AGOSTO","SETEMBRO",
                             "OUTUBRO","NOVEMBRO","DEZEMBRO"]        NO-UNDO.

DEF {1} SHARED VAR par_cdcritic AS INTE                              NO-UNDO.

DEF BUFFER crabttl5 FOR crapttl.


FORM SKIP(1)
     tel_nrdconta      AT  1 LABEL "Conta/dv"   
                             HELP "Numero da conta do associado"
            VALIDATE(CAN-FIND(crapass WHERE crapass.cdcooper = glb_cdcooper AND
                                             crapass.nrdconta = tel_nrdconta),
                     "009 - Associado nao cadastrado.")
                             
     crapass.cdagenci  AT 24 LABEL "PA"
     "-"               
     tel_dsagenci            NO-LABEL
     crapass.nrmatric  AT 51 LABEL "Matr." 
     tel_idseqttl      AT 68 LABEL "Seq.Ttl." FORMAT "9"
                             HELP "Informe a sequencia ou F7 para listar"
                             VALIDATE (tel_idseqttl <> 0 AND
                                       tel_idseqttl < 5,
                                       "117 - Sequencia errada")
     SKIP
     crapttl.nmextttl       LABEL "Titular" AUTO-RETURN FORMAT "x(40)"
     crapass.inpessoa AT 54 LABEL "Tp.Natureza"
     "-"              AT 68
     tel_dspessoa     AT 69 NO-LABEL
     tel_nrcpfcgc           LABEL "C.P.F."
     tel_cdsexotl     AT 32 LABEL "Sexo"
     crapttl.cdestcvl AT 45 LABEL "Estado Civil" AUTO-RETURN
     tel_dsestcvl           NO-LABEL 
     SKIP
     crapass.cdtipcta       LABEL "Tp.Conta" 
                            HELP "Entre com o tipo de conta ou F7 para listar"
     tel_dstipcta           NO-LABEL
     crapass.cdsitdct AT 30 LABEL "Sit."
        HELP "1-Nor,2-Enc.Ass,3-Enc.COOP,4-Enc.Dem,5-Nao aprov,6-S/Tal,9-Outros"
     tel_dssitdct           NO-LABEL
     crapass.nrdctitg AT 57 LABEL "Conta/ITG"
     SKIP(2)
     tel_dsdopcao[01] AT  1 NO-LABEL
     tel_dsdopcao[10] AT 29 NO-LABEL
     tel_dsdopcao[20] AT 58 NO-LABEL FORMAT "x(21)"
     SKIP
     tel_dsdopcao[02] AT  1 NO-LABEL
     tel_dsdopcao[11] AT 29 NO-LABEL 
     tel_dsdopcao[21] AT 58 NO-LABEL FORMAT "x(21)"
     SKIP
     tel_dsdopcao[03] AT  1 NO-LABEL
     tel_dsdopcao[12] AT 29 NO-LABEL 
     SKIP
     tel_dsdopcao[04] AT  1 NO-LABEL
     tel_dsdopcao[13] AT 29 NO-LABEL
     SKIP
     tel_dsdopcao[05] AT  1 NO-LABEL 
     tel_dsdopcao[14] AT 29 NO-LABEL
     SKIP
     tel_dsdopcao[06] AT  1 NO-LABEL
     tel_dsdopcao[16] AT 29 NO-LABEL
     SKIP
     tel_dsdopcao[07] AT  1 NO-LABEL
     tel_dsdopcao[17] AT 29 NO-LABEL 
     SKIP
     tel_dsdopcao[08] AT  1 NO-LABEL
     tel_dsdopcao[18] AT 29 NO-LABEL
     
     SKIP
     tel_dsdopcao[09] AT  1 NO-LABEL
     tel_dsdopcao[19] AT 29 NO-LABEL FORMAT "x(21)"
     
     WITH ROW 4 OVERLAY SIDE-LABELS WIDTH 80 TITLE glb_tldatela FRAME f_conta.

FORM SKIP(1)
     tel_nrdconta      AT 1  LABEL "Conta/dv"   
                             HELP "Numero da conta do associado"
     crapass.cdagenci  AT 24 LABEL "PA"
     "-"               
     tel_dsagenci            NO-LABEL
     crapass.nrmatric  AT 51 LABEL "Matr." 
     tel_idseqttl      AT 68 LABEL "Seq.Ttl." FORMAT "9"
                             HELP "Informe a sequencia ou F7 para listar"
                             VALIDATE (tel_idseqttl <> 0 AND
                                       tel_idseqttl < 3,
                                       "117 - Sequencia errada")
     SKIP
     crapass.nmprimtl AT 01 LABEL "Razao Social" AUTO-RETURN FORMAT "x(40)"
     crapass.inpessoa AT 56 LABEL "Tp.Natureza"
     "-"              AT 70
     tel_dspessoa     AT 71 NO-LABEL
     SKIP
     tel_nmfatasi     AT 01 LABEL "Nome Fantasia" FORMAT "x(40)"
     SKIP
     tel_nrcpfcgc     AT 01 LABEL "C.N.P.J."
     SKIP
     crapass.cdtipcta AT 01 LABEL "Tp.Conta" 
                            HELP "Entre com o tipo de conta ou F7 para listar"
     tel_dstipcta     AT 14 NO-LABEL
     crapass.cdsitdct AT 30 LABEL "Sit." 
     tel_dssitdct     AT 38 NO-LABEL
     crapass.nrdctitg AT 57 LABEL "Conta/ITG"
     SKIP(2)
     tel_dsdopcao[01] AT  1 NO-LABEL
     tel_dsdopcao[09] AT 30 NO-LABEL
     tel_dsdopcao[23]       NO-LABEL
     SKIP
     tel_dsdopcao[02] AT  1 NO-LABEL
     tel_dsdopcao[10] AT 30 NO-LABEL   
     tel_dsdopcao[16]       NO-LABEL
     SKIP
     tel_dsdopcao[03] AT  1 NO-LABEL
     tel_dsdopcao[12] AT 30 NO-LABEL 
     tel_dsdopcao[17]       NO-LABEL
     SKIP
     tel_dsdopcao[04] AT 1  NO-LABEL
     tel_dsdopcao[13] AT 30 NO-LABEL   
     tel_dsdopcao[18]       NO-LABEL
     SKIP
     tel_dsdopcao[05] AT  1 NO-LABEL
     tel_dsdopcao[21] AT 30 NO-LABEL
     tel_dsdopcao[19]       NO-LABEL
     SKIP
     tel_dsdopcao[06] AT  1 NO-LABEL
     tel_dsdopcao[14] AT 30 NO-LABEL
     tel_dsdopcao[20]       NO-LABEL
     SKIP
     tel_dsdopcao[07] AT  1 NO-LABEL
     tel_dsdopcao[15] AT  30 NO-LABEL                  
     SKIP
     tel_dsdopcao[08] AT  1 NO-LABEL
     tel_dsdopcao[22] AT 30 NO-LABEL 
     
     WITH ROW 4 OVERLAY SIDE-LABELS WIDTH 80 TITLE glb_tldatela 
          FRAME f_conta_juridica.
                                   
  
/* ....................................................................... */
