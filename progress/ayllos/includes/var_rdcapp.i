/* .............................................................................

   Programa: Includes/var_rdcapp.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Marco/96.                       Ultima atualizacao: 04/06/2013

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Criacao das variaveis para tratamento da poupanca programada.

   Alteracoes: 03/04/98 - Tratamento para milenio e troca para V8 (Margarete).
   
               17/06/2003 - Critica valor maximo prestacao (Margarete).

               14/12/2004 - Alterado o extent de 150 para 200 ocorrencias
                            (Edson).
                            
               23/04/2008 - Incluido variaveis auxiliares para data de venc.
                            de poupanca programada (Guilherme).

               24/07/2008 - Incluido variaveis e FORM para receber a data
                            inicial e a data final do periodo da aplicacao
                            (Elton).
                          
               13/04/2010 - Aumentar ocorrencias de 200 para 250 (Magui).             

               28/04/2010 - Passar para um browse dinamico (Gabriel).
               
               26/12/2011 - Criada a var 'tel_dtmaxvct' para cálculo de prazo
                            máximo de vencimento da Poup. Prog. (Lucas).
                            
               04/06/2013 - Ajustado BROWSE b_poupanca para exibir campo de
                            Saldo Bloqueio Judicial (Andre Santos - SUPERO)             
                            
............................................................................. */

{ sistema/generico/includes/b1wgen0006tt.i }


DEFINE {1} SHARED VARIABLE aux_flgsaida AS LOGI               NO-UNDO.
DEFINE {1} SHARED VARIABLE aux_ultlinha AS INTE               NO-UNDO.

                  
DEF VAR tel_dspesrpp AS CHAR                                  NO-UNDO.
DEF VAR tel_dssitrpp AS CHAR                                  NO-UNDO.
DEF VAR tel_dsaplica AS CHAR                                  NO-UNDO.
DEF VAR tel_dsmensaq AS CHAR                                  NO-UNDO.
DEF VAR tel_tpemiext AS INTE                                  NO-UNDO.

DEF VAR tel_vlprerpp AS DECIMAL                               NO-UNDO.
DEF VAR tel_qtprerpp AS INT                                   NO-UNDO.
DEF VAR tel_vlprepag AS DECIMAL                               NO-UNDO.
DEF VAR tel_vljuracu AS DECIMAL                               NO-UNDO.
DEF VAR tel_vlrgtacu AS DECIMAL                               NO-UNDO.
DEF VAR tel_vlsdrdpp AS DECIMAL                               NO-UNDO.
DEF VAR tel_dtinirpp AS DATE FORMAT "99/99/9999"              NO-UNDO.
DEF VAR tel_dtrnirpp AS DATE                                  NO-UNDO.
DEF VAR tel_dtaltrpp AS DATE                                  NO-UNDO.
DEF VAR tel_dtdebito AS DATE                                  NO-UNDO.
DEF VAR tel_dtcancel AS DATE                                  NO-UNDO.
DEF VAR tel_dtvctopp AS DATE                                  NO-UNDO.
DEF VAR tel_dtmaxvct AS DATE FORMAT "99/99/9999"              NO-UNDO.

DEF VAR tel_diadtvct AS INTE FORMAT "99"                      NO-UNDO.
DEF VAR tel_mesdtvct AS INTE FORMAT "99"                      NO-UNDO.
DEF VAR tel_anodtvct AS INTE FORMAT "9999"                    NO-UNDO.
DEF VAR aux_pzminppr AS INTE                                  NO-UNDO.
DEF VAR aux_pzmaxppr AS INTE                                  NO-UNDO.
DEF VAR aux_nrdmeses AS INTE                                  NO-UNDO.
DEF VAR aux_qtsaqppr AS INT                                   NO-UNDO.
DEF VAR aux_cont     AS INTE                                  NO-UNDO.

DEF VAR aux_dtiniper AS DATE                                  NO-UNDO. 
DEF VAR aux_vlsldrpp AS DEC                                   NO-UNDO.
DEF VAR aux_flgfirst AS LOGICAL                               NO-UNDO.


DEF QUERY  q_poupanca FOR tt-dados-rpp.
DEF BROWSE b_poupanca QUERY q_poupanca
           DISPLAY dtmvtolt COLUMN-LABEL "Data"       FORMAT "99/99/99"
                   dtvctopp COLUMN-LABEL "Vencto."    FORMAT "99/99/99"
                   nrctrrpp COLUMN-LABEL "Contrato"
                   indiadeb COLUMN-LABEL "Dia"
                   vlprerpp COLUMN-LABEL "Prestacao"
                   vlsdrdpp COLUMN-LABEL "Saldo"      FORMAT "zzzz,zz9.99"
                   dssitrpp COLUMN-LABEL "Situacao"
                   dsctainv COLUMN-LABEL "CI"
                   dsresgat COLUMN-LABEL "Resg"
            WITH 3 DOWN WIDTH 76 OVERLAY NO-BOX. 


FORM SKIP(1)
     tel_vlprerpp AT  4 FORMAT "zzz,zzz,zz9.99"  LABEL "Valor da Prestacao"
                        HELP "Entre com o valor da prestacao da P. Programada."
                        AUTO-RETURN

     tel_qtprerpp AT 42 FORMAT "zz9"             LABEL "Qtd. Prest. Pagas"
     SKIP
     tel_vlprepag AT 12 FORMAT "zzz,zzz,zz9.99"  LABEL "Total Pago"
     tel_vljuracu AT 44 FORMAT "zzz,zzz,zz9.99"  LABEL "Total dos Juros"
     SKIP
     tel_vlrgtacu AT  4 FORMAT "zzz,zzz,zz9.99"  LABEL "Total dos Resgates"
     tel_vlsdrdpp AT 48 FORMAT "zzz,zzz,zz9.99-" LABEL "Saldo Atual"
     SKIP(1)
     tel_dtinirpp AT  2 FORMAT "99/99/9999"      LABEL "Inicio do Plano"
     tel_dtrnirpp AT 30 FORMAT "99/99/9999"      LABEL "Reinicio"
     tel_dtaltrpp AT 51 FORMAT "99/99/9999"      LABEL "Ult Alteracao"
     SKIP
     tel_dtdebito AT  3 FORMAT "99/99/9999"     LABEL "Proximo Debito"
     tel_dtcancel AT 52 FORMAT "99/99/9999"     LABEL "Cancelado em"
     SKIP
     tel_dtvctopp AT 07 FORMAT "99/99/9999"     LABEL "Vencimento"
     SKIP
     tel_dsmensaq AT 15 FORMAT "x(47)"           NO-LABEL
     SKIP(1)
     tel_dspesrpp     AT  7 FORMAT "x(27)"       LABEL "Pesquisa"
     tel_dssitrpp     AT 45 FORMAT "x(10)"       LABEL "Situacao"
     tel_extratos     AT 67 FORMAT "x(7)"        NO-LABEL
     WITH ROW 9 CENTERED SIDE-LABELS NO-LABELS OVERLAY TITLE COLOR NORMAL
          tel_dsaplica WIDTH 78 FRAME f_rdcapp.
     
FORM aux_dtpesqui  LABEL "Data Inicial"  AUTO-RETURN
                   VALIDATE (aux_dtpesqui <> ?,"013 - Data errada.")
                   HELP  "Informe a Data Inicial do extrato."
     aux_dtafinal  LABEL "Data Final  "
                   VALIDATE (aux_dtafinal <> ? AND 
                             aux_dtafinal >= 
                                 INPUT aux_dtpesqui,"013 - Data errada.")
                   HELP  "Informe a Data Final do extrato."
                   WITH  ROW 13 CENTERED OVERLAY SIDE-LABELS FRAME f_data_poup.
          

/* .......................................................................... */
