/* .............................................................................

   Programa: Fontes/tab045.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme
   Data    : Agosto/2007                        Ultima alteracao: 26/05/2018

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Tab045 -  Limites para Internet
   
   Alteracao : 01/10/2007 - Gera registros na craplgm e craplgi e cria arquivo
                            de log quando houver alteracoes no limite da
                            internet (Elton).
                            
               15/10/2007 - Nr de tentativas erradas de senha(Guilherme)
               
               22/10/2007 - Acerto no LOG (Diego).
               
               22/01/2008 - Dividido parametros p/ pessoa fis e jur(Guilherme).
                          - Limite de dias para primeiro acesso (David).
                          
               19/02/2008 - Incluido campo valor para conferencia envio
                            (Gabriel).
                            
               02/05/2008 - critica para permitir somente os operadores: 1, 799
                            996, 997 na opcao "A" (Guilherme).

               10/02/2009 - Retirar op. 996 e incluir o 979 (Gabriel).

               03/04/2009 - Nao atualizar campo vllimweb  quando for alterado o
                            limite maximo para transacoes (David).
                            
               25/05/2009 - Alteracao CDOPERAD (Kbase).
               
               24/06/2009 - Inclusao de campos para CECRED (GATI - Eder)
               
               22/07/2009 - Alimentar os campos "Limite tentativas", 
                            "Limite de dias" e "Valor para conferencia" do
                            Operacional com os valor da CECRED (Fernando).
                            
               30/07/2009 - Alteracoes do Projeto de Transferencia para 
                            Credito de Salario (David).
                            
               31/03/2012 - Inclusao de campos "Valor Limite/Dia TED:"
                            para pessoa fisica e juridica operacao de
                            transferencia on-line (David Kruger).
                            
               19/03/2013 - Inclusao dos campos "Valor Limite VR Boletos"
                            para pessoa fisica e juridica. (Rafael)
                            
               24/04/2013 - Adionado campos de bloqueio de senha. (Jorge)             
               
               10/09/2013 - Habilitar campos de bloqueio de senha para
                            alteracao na cooperativa (David).
                            
               28/02/2014 - Liberada alteraçao para "SUPORTE" (Lucas).
               
               24/03/2014 - Ajustes para o projeto captacao (Adriano).
               
               22/07/2014 - Ajuste referente a segunda fase do projeto
                            de captacao (Adriano).
                            
               22/08/2014 - Retirado os campos de horario referente a 
                            captacao (Adriano).
                                         
               17/10/2014 - Retirado os campos do valor maximo de agendamento
                            (Douglas - Projeto Captaçao Internet 2014/2).
               
               05/11/2014 - Alteraçao da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)
                           
               12/11/2014 - (Chamado 217240) Alterar formato do numero de caracteres 
                            de todos os valores de parametros para pessoa juridica
                            (Tiago Castro - RKAM).
                            
               24/11/2015 - Ajustes referente projeto Assinatura Multipla (Daniel)
               
               15/03/2016 - #Projeto117 Inclusao dos campos 
                            Quantidade de meses para agendamento TED e
                            Qtd. meses p/ agendamento recorrente TED (Carlos)
                                         
               24/03/2016 - Ajustes de permissao conforme solicitado no chamado 358761 (Kelvin).
                                               
               06/05/2016 - Projeto 117 - aumento dos formats do log para a tab045
                            (Carlos)

               17/05/2016 - Ajuste no tamanho do frame (Adriano - M117)
              
               08/09/2016 - Adição do campo para valor máximo de integralização (Ricardo Linhares - M169)
               
               07/12/2016 - Alterado campo dsdepart para cddepart.
                            PRJ341 - BANCENJUD (Odirlei-AMcom)

			   26/05/2018 - Ajustes referente alteracao da nova marca (P413 - Jonata Mouts).
               
			   03/06/2019 - Retirados campos de validação de bloqueio de conta. (RITM0019350 - Lombardi).
               
............................................................................. */

{ includes/var_online.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }

DEF VAR tel_inpessoa AS LOGI FORMAT "Fisica/Juridica"                 NO-UNDO.

DEF VAR tel_nrderros AS INTE FORMAT "z9"              EXTENT 2        NO-UNDO.
DEF VAR tel_qtdiaace AS INTE FORMAT "zz9"             EXTENT 2        NO-UNDO.
DEF VAR tel_qtmesagd AS INTE FORMAT "zz9"             EXTENT 2        NO-UNDO.

DEF VAR tel_vlpconfe AS DECI FORMAT "z,zzz,zz9.99"    EXTENT 2        NO-UNDO.

DEF VAR tel_vllimweb AS DECI FORMAT "zzz,zzz,zz9.99"    EXTENT 2        NO-UNDO.

DEF VAR tel_vllimtrf AS DECI FORMAT "zzz,zzz,zz9.99"    EXTENT 2        NO-UNDO.
DEF VAR tel_vllimpgo AS DECI FORMAT "zzz,zzz,zz9.99"    EXTENT 2        NO-UNDO.

DEF VAR tel_vllimted AS DECI FORMAT "zzz,zzz,zz9.99"    EXTENT 2        NO-UNDO.
DEF VAR tel_vlvrbole AS DECI FORMAT "zzz,zzz,zz9.99"    EXTENT 2        NO-UNDO.

DEF VAR tel_vlmaxapl AS DECI FORMAT "z,zzz,zz9.99"    EXTENT 2        NO-UNDO.
DEF VAR tel_vlminapl AS DECI FORMAT "z,zzz,zz9.99"    EXTENT 2        NO-UNDO.
DEF VAR tel_vlmaxres AS DECI FORMAT "z,zzz,zz9.99"    EXTENT 2        NO-UNDO.

DEF VAR tel_vllimint AS DECI FORMAT "z,zzz,zz9.99"  EXTENT 2        NO-UNDO. /* Valor maximo integralizacao de capital */

/* qtd maxima de MESES para agendamento de TED (maximo de meses p/ frente) */
DEF VAR tel_mesested AS INTE FORMAT "zz9"    EXTENT 2        NO-UNDO. 
/* qtd maxima de Meses para agendamento RECOrrente de TED */
DEF VAR tel_mrecoted AS INTE FORMAT "zz9"    EXTENT 2        NO-UNDO.

DEF VAR tel_vctoproc AS INTE FORMAT "zz9"             EXTENT 2        NO-UNDO.

DEF VAR aux_cddopcao AS CHAR                                          NO-UNDO.
DEF VAR aux_confirma AS CHAR FORMAT "!"                               NO-UNDO.
DEF VAR aux_dstextab AS CHAR                                          NO-UNDO.

DEF VAR aux_contador AS INTE                                          NO-UNDO.

DEF VAR aux_dadosusr AS CHAR                                          NO-UNDO.
DEF VAR par_loginusr AS CHAR                                          NO-UNDO.
DEF VAR par_nmusuari AS CHAR                                          NO-UNDO.
DEF VAR par_dsdevice AS CHAR                                          NO-UNDO.
DEF VAR par_dtconnec AS CHAR                                          NO-UNDO.
DEF VAR par_numipusr AS CHAR                                          NO-UNDO.
DEF VAR h-b1wgen9999 AS HANDLE                                        NO-UNDO.

DEF VAR tel_textoaux AS CHAR FORMAT "x(42)"                           NO-UNDO.

tel_textoaux = "Qtd.meses p/ aviso antes venct.procuracao:".

FORM WITH ROW 4 OVERLAY SIZE 80 BY 18 TITLE glb_tldatela FRAME f_tab045.

FORM glb_cddopcao AT 05 LABEL "Opcao"          AUTO-RETURN FORMAT "!"
                        HELP "Informe a opcao desejada (A,C)."
                        VALIDATE(CAN-DO("A,C",glb_cddopcao),
                                 "014 - Opcao errada.")
     WITH ROW 6 COLUMN 2 WIDTH 20 OVERLAY SIDE-LABELS NO-BOX FRAME f_opcao. 

FORM tel_inpessoa LABEL "Tipo de Pessoa" AUTO-RETURN
                  HELP "Informe 'F' para fisica 'J' para juridica."
     WITH ROW 6 COLUMN 30 WIDTH  50 OVERLAY SIDE-LABELS 
                                    NO-BOX FRAME f_inpessoa.

    
FORM "Operacional"   AT 48
     "AILOS"         AT 69
     SKIP(1)
     "Valor Limite/Dia (Transf/Pagamentos):" AT 06
     tel_vllimweb[1] AT 45 NO-LABEL 
        HELP "Informe o valor maximo para operacoes na internet."
     tel_vllimweb[2] AT 61 NO-LABEL
        HELP "Entre com o limite para o Operacional." 
     SKIP
     "Valor Limite/Dia TED:" AT 22
     tel_vllimted[1] AT 45 NO-LABEL
         HELP "Informe o valor maximo para operacoes com TED."
     tel_vllimted[2] AT 61 NO-LABEL
         HELP "Informe o valor maximo para operacoes com TED."
     SKIP
     "Valor Limite VR Boletos:" AT 19
     tel_vlvrbole[1] AT 45 NO-LABEL
         HELP "Informe o valor maximo para operacoes com VR Boleto."
     tel_vlvrbole[2] AT 61 NO-LABEL
         HELP "Informe o valor maximo para operacoes com VR Boleto."
     SKIP
     "Limite de dias para primeiro acesso:"  AT 07
     tel_qtdiaace[1] AT 54 NO-LABEL 
        HELP "Informe o maximo de dias para efetuar primeiro acesso a internet."
     tel_qtdiaace[2] AT 72 NO-LABEL  
        HELP "Entre com o limite para o Operacional."
     SKIP
     "Limite tentativas senha errada:"       AT 12
     tel_nrderros[1] AT 57 NO-LABEL 
        HELP "Informe o maximo de tentavivas para senha errada na internet."
     tel_nrderros[2] AT 73 NO-LABEL
        HELP "Entre com o limite para o Operacional."
     SKIP
     "Valor para conferencia envio:"         AT 14
     tel_vlpconfe[1] AT 47 NO-LABEL 
        HELP "Informe o valor para conferencia envio"
     tel_vlpconfe[2] AT 63 NO-LABEL
        HELP "Entre com o limite para o Operacional."
     SKIP
     "Limite de meses para agendamento:"     AT 10
     tel_qtmesagd[1] AT 56 NO-LABEL
        HELP "Informe a quantidade maxima de meses para agendamento."
     tel_qtmesagd[2] AT 72 NO-LABEL
        HELP "Entre com o limite para o Operacional."
     WITH ROW 8 OVERLAY SIDE-LABELS NO-BOX WIDTH 78 CENTERED 
          FRAME f_dados_fisica.
          
FORM "Operacional"   AT 47
     "AILOS"         AT 68
     SKIP(1)
     "Valor Limite/Dia Transferencia:" AT 11
     tel_vllimtrf[1] AT 44 NO-LABEL 
        HELP "Informe o valor maximo para transferencias na internet."
     tel_vllimtrf[2] AT 60 NO-LABEL
        HELP "Entre com o limite para o Operacional." 
     SKIP
     "Valor Limite/Dia Pagamentos:"    AT 14
     tel_vllimpgo[1] AT 44 NO-LABEL 
        HELP "Informe o valor maximo para pagamentos na internet."
     tel_vllimpgo[2] AT 60 NO-LABEL
        HELP "Entre com o limite para o Operacional."
     SKIP   
     "Valor Limite/Dia TED:" AT 21
     tel_vllimted[1] AT 44 NO-LABEL
        HELP "Informe o valor maximo para operacoes com TED."
     tel_vllimted[2] AT 60 NO-LABEL
        HELP "Informe o valor maximo para operacoes com TED."
     SKIP
     "Valor Limite VR Boletos:" AT 18
     tel_vlvrbole[1] AT 44 NO-LABEL
        HELP "Informe o valor maximo para operacoes com VR Boleto."
     tel_vlvrbole[2] AT 60 NO-LABEL
        HELP "Informe o valor maximo para operacoes com VR Boleto."
     SKIP
     "Limite de dias para primeiro acesso:"  AT 06
     tel_qtdiaace[1] AT 55 NO-LABEL 
        HELP "Informe o maximo de dias para efetuar primeiro acesso a internet."
     tel_qtdiaace[2] AT 71 NO-LABEL  
        HELP "Entre com o limite para o Operacional."
     SKIP
     "Limite tentativas senha errada:"       AT 11
     tel_nrderros[1] AT 56 NO-LABEL 
        HELP "Informe o maximo de tentavivas para senha errada na internet."
     tel_nrderros[2] AT 72 NO-LABEL
        HELP "Entre com o limite para o Operacional."
     SKIP
     "Valor para conferencia envio:"         AT 13
     tel_vlpconfe[1] AT 46 NO-LABEL 
        HELP "Informe o valor para conferencia envio"
     tel_vlpconfe[2] AT 62 NO-LABEL
        HELP "Entre com o limite para o Operacional."
     SKIP
     "Limite de meses para agendamento:"     AT 9
     tel_qtmesagd[1] AT 55 NO-LABEL
        HELP "Informe a quantidade maxima de meses para agendamento."
     tel_qtmesagd[2] AT 71 NO-LABEL
        HELP "Entre com o limite para o Operacional."
     WITH ROW 8 OVERLAY SIDE-LABELS NO-BOX WIDTH 78 CENTERED 
          FRAME f_dados_juridica.      

FORM "Operacional"   AT 48
     "AILOS"         AT 69
     SKIP(1)
     "Valor maximo aplicacao:"          AT 21
     tel_vlmaxapl[1] NO-LABEL 
     tel_vlmaxapl[2] NO-LABEL           AT 62
     SKIP
     "Valor minimo aplicacao:"          AT 21
     tel_vlminapl[1] NO-LABEL 
     tel_vlminapl[2] NO-LABEL           AT 62
     SKIP
     "Valor maximo resgate:"            AT 23
     tel_vlmaxres[1] NO-LABEL
     tel_vlmaxres[2] NO-LABEL           AT 62
     SKIP
     tel_textoaux    NO-LABEL           AT 2
     tel_vctoproc[1] NO-LABEL           AT 54
     tel_vctoproc[2] NO-LABEL           AT 71
     SKIP
     "Quantidade de meses para agendamento TED:" AT 3
     tel_mesested[1] NO-LABEL           AT 54
     tel_mesested[2] NO-LABEL           AT 71
     SKIP
     "Qtd. meses p/ agendamento recorrente TED:" AT 3
     tel_mrecoted[1] NO-LABEL           AT 54
     tel_mrecoted[2] NO-LABEL           AT 71
     SKIP
     "Valor maximo integralizacao de capital:" AT 5
     tel_vllimint[1] NO-LABEL           AT 45
     tel_vllimint[2] NO-LABEL           AT 62     
    
     SKIP(5)
     WITH ROW 7 OVERLAY SIDE-LABELS NO-BOX WIDTH 78 CENTERED 
          FRAME f_dados_captacao.      

ASSIGN glb_cddopcao = "C" 
       glb_cdcritic = 0.

VIEW FRAME f_tab045.
PAUSE(0).

RUN fontes/inicia.p.
 
DO WHILE TRUE:
       
   CLEAR FRAME f_tipo_valor     NO-PAUSE.
   CLEAR FRAME f_dados_fisica   NO-PAUSE.
   CLEAR FRAME f_dados_juridica NO-PAUSE.
   CLEAR FRAME f_captacao       NO-PAUSE.
   CLEAR FRAME f_dados_captacao NO-PAUSE.
   CLEAR FRAME f_inpessoa       NO-PAUSE.

   HIDE  FRAME f_dados_fisica   
         FRAME f_dados_juridica
         FRAME f_captacao      
         FRAME f_dados_captacao
         FRAME f_tipo_valor
         FRAME f_inpessoa NO-PAUSE.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      
      UPDATE glb_cddopcao
             WITH FRAME f_opcao.
            
      LEAVE.
     
   END. /* Fim do DO WHILE TRUE */
   
   IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN     /*   F4 OU FIM   */
      DO:
         RUN fontes/novatela.p.
         
         IF CAPS(glb_nmdatela) <> "tab045"  THEN
            DO:
               HIDE FRAME f_tab045.
               HIDE FRAME f_opcao.
               RETURN.
            END.
         ELSE
            NEXT.

      END.

   HIDE MESSAGE NO-PAUSE.
  
   IF aux_cddopcao <> glb_cddopcao  THEN
      DO:              
          { includes/acesso.i }

          aux_cddopcao = glb_cddopcao.
          
      END.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      
      UPDATE tel_inpessoa 
             WITH FRAME f_inpessoa.
            
      LEAVE.
     
   END. /* Fim do DO WHILE TRUE */
   
   IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN /*   F4 OU FIM   */
      DO:
         HIDE FRAM f_inpessoa.
         NEXT.

      END.

   RUN busca_dados(INPUT glb_cdcooper,        
                   INPUT glb_cdagenci,        
                   INPUT 0, /*nrdcaixa*/      
                   INPUT glb_cdoperad,        
                   INPUT glb_dtmvtolt,        
                   INPUT 1, /*ayllos*/        
                   INPUT glb_cdprogra,        
                   INPUT tel_inpessoa,        
                   OUTPUT aux_dstextab,       
                   OUTPUT TABLE tt-erro).     
   
   IF RETURN-VALUE <> "OK" THEN
      DO:
         FIND FIRST tt-erro.

         IF AVAIL tt-erro THEN
            MESSAGE tt-erro.dscritic.
         ELSE
            MESSAGE "Nao foi possivel consultar a tabela de limites.".

         PAUSE 3 NO-MESSAGE.
         NEXT.

      END.
   
   IF tel_inpessoa THEN
      ASSIGN tel_vllimweb[1] = DECI(ENTRY(01,aux_dstextab,";"))
             tel_nrderros[1] = INTE(ENTRY(02,aux_dstextab,";"))
             tel_qtdiaace[1] = INTE(ENTRY(03,aux_dstextab,";"))
             tel_vlpconfe[1] = DECI(ENTRY(04,aux_dstextab,";"))
             tel_qtmesagd[1] = INTE(ENTRY(05,aux_dstextab,";"))
             tel_vllimted[1] = DECI(ENTRY(13,aux_dstextab,";"))
             tel_vlvrbole[1] = DECI(ENTRY(15,aux_dstextab,";"))
             tel_vllimweb[2] = DECI(ENTRY(07,aux_dstextab,";"))
             tel_nrderros[2] = INTE(ENTRY(08,aux_dstextab,";"))
             tel_qtdiaace[2] = INTE(ENTRY(09,aux_dstextab,";"))
             tel_vlpconfe[2] = DECI(ENTRY(10,aux_dstextab,";"))
             tel_qtmesagd[2] = INTE(ENTRY(11,aux_dstextab,";"))
             tel_vllimted[2] = DECI(ENTRY(14,aux_dstextab,";"))
             tel_vlvrbole[2] = DECI(ENTRY(16,aux_dstextab,";"))
             tel_vlmaxapl[1] = DECI(ENTRY(23,aux_dstextab,";"))
             tel_vlminapl[1] = DECI(ENTRY(24,aux_dstextab,";"))
             tel_vlmaxres[1] = DECI(ENTRY(25,aux_dstextab,";"))
             tel_vlmaxapl[2] = DECI(ENTRY(26,aux_dstextab,";"))
             tel_vlminapl[2] = DECI(ENTRY(27,aux_dstextab,";"))
             tel_vlmaxres[2] = DECI(ENTRY(28,aux_dstextab,";"))
             tel_vctoproc[1] = INTE(ENTRY(29,aux_dstextab,";"))
             tel_vctoproc[2] = INTE(ENTRY(30,aux_dstextab,";"))
             tel_mesested[1] = INTE(ENTRY(31,aux_dstextab,";"))
             tel_mesested[2] = INTE(ENTRY(32,aux_dstextab,";"))
             tel_mrecoted[1] = INTE(ENTRY(33,aux_dstextab,";"))
             tel_mrecoted[2] = INTE(ENTRY(34,aux_dstextab,";"))
             tel_vllimint[1] = DECI(ENTRY(35,aux_dstextab,";"))
             tel_vllimint[2] = DECI(ENTRY(36,aux_dstextab,";")).             
   ELSE
      ASSIGN tel_vllimtrf[1] = DECI(ENTRY(01,aux_dstextab,";"))
             tel_nrderros[1] = INTE(ENTRY(02,aux_dstextab,";"))
             tel_qtdiaace[1] = INTE(ENTRY(03,aux_dstextab,";"))
             tel_vlpconfe[1] = DECI(ENTRY(04,aux_dstextab,";"))
             tel_qtmesagd[1] = INTE(ENTRY(05,aux_dstextab,";"))
             tel_vllimpgo[1] = DECI(ENTRY(06,aux_dstextab,";"))
             tel_vllimted[1] = DECI(ENTRY(13,aux_dstextab,";"))
             tel_vlvrbole[1] = DECI(ENTRY(15,aux_dstextab,";"))
             tel_vllimtrf[2] = DECI(ENTRY(07,aux_dstextab,";"))
             tel_nrderros[2] = INTE(ENTRY(08,aux_dstextab,";"))
             tel_qtdiaace[2] = INTE(ENTRY(09,aux_dstextab,";"))
             tel_vlpconfe[2] = DECI(ENTRY(10,aux_dstextab,";"))
             tel_qtmesagd[2] = INTE(ENTRY(11,aux_dstextab,";"))
             tel_vllimpgo[2] = DECI(ENTRY(12,aux_dstextab,";"))  
             tel_vllimted[2] = DECI(ENTRY(14,aux_dstextab,";"))
             tel_vlvrbole[2] = DECI(ENTRY(16,aux_dstextab,";"))
             tel_vlmaxapl[1] = DECI(ENTRY(23,aux_dstextab,";"))
             tel_vlminapl[1] = DECI(ENTRY(24,aux_dstextab,";"))
             tel_vlmaxres[1] = DECI(ENTRY(25,aux_dstextab,";"))
             tel_vlmaxapl[2] = DECI(ENTRY(26,aux_dstextab,";"))
             tel_vlminapl[2] = DECI(ENTRY(27,aux_dstextab,";"))
             tel_vlmaxres[2] = DECI(ENTRY(28,aux_dstextab,";"))
             tel_vctoproc[1] = INTE(ENTRY(29,aux_dstextab,";"))
             tel_vctoproc[2] = INTE(ENTRY(30,aux_dstextab,";"))
             tel_mesested[1] = INTE(ENTRY(31,aux_dstextab,";"))
             tel_mesested[2] = INTE(ENTRY(32,aux_dstextab,";"))
             tel_mrecoted[1] = INTE(ENTRY(33,aux_dstextab,";"))
             tel_mrecoted[2] = INTE(ENTRY(34,aux_dstextab,";"))
             tel_vllimint[1] = DECI(ENTRY(35,aux_dstextab,";"))
             tel_vllimint[2] = DECI(ENTRY(36,aux_dstextab,";")).

   IF glb_cddopcao = "C" THEN
      DO:  
         IF tel_inpessoa THEN
            DO: 
                DISPLAY tel_vllimweb[1] tel_nrderros[1] tel_qtdiaace[1] 
                        tel_vlpconfe[1] tel_qtmesagd[1] tel_vllimted[1]
                        tel_vlvrbole[1] 
                        tel_vllimweb[2] tel_nrderros[2] tel_qtdiaace[2]
                        tel_vlpconfe[2] tel_qtmesagd[2] tel_vllimted[2]
                        tel_vlvrbole[2]
                        WITH FRAME f_dados_fisica.
             
                MESSAGE "Tecle <Enter> para continuar ou <End> para encerrar".
                   
                WAIT-FOR RETURN, END-ERROR OF CURRENT-WINDOW.
                
                IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                   NEXT.
               
                DISPLAY tel_vlmaxapl[1]
                        tel_vlminapl[1]
                        tel_vlmaxres[1]
                        tel_mesested[1]
                        tel_mrecoted[1]
                        tel_vllimint[1]
                        tel_vlmaxapl[2]
                        tel_vlminapl[2]
                        tel_vlmaxres[2]
                        tel_mesested[2]
                        tel_mrecoted[2]
                        tel_vllimint[2]
                        WITH FRAME f_dados_captacao.
                
                MESSAGE "Tecle <Enter> para continuar ou <End> para encerrar".
                   
                WAIT-FOR RETURN, END-ERROR OF CURRENT-WINDOW.
                
                IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                   NEXT.

            END.
         ELSE
            DO:                                                    
               DISPLAY tel_vllimtrf[1] tel_vllimpgo[1] tel_nrderros[1]
                       tel_qtdiaace[1] tel_vlpconfe[1] tel_qtmesagd[1]
                       tel_vllimted[1] tel_vlvrbole[1]
                       tel_vllimtrf[2] tel_vllimpgo[2] tel_nrderros[2] 
                       tel_qtdiaace[2] tel_vlpconfe[2] tel_qtmesagd[2] 
                       tel_vllimted[2] tel_vlvrbole[2]
                       WITH FRAME f_dados_juridica.
              
               MESSAGE "Tecle <Enter> para continuar ou <End> para encerrar".
                  
               WAIT-FOR RETURN, END-ERROR OF CURRENT-WINDOW.
               
               IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                  NEXT.
               
               DISPLAY tel_vlmaxapl[1]
                       tel_vlminapl[1]
                       tel_vlmaxres[1]
                       tel_mesested[1]
                       tel_mrecoted[1]
                       tel_vllimint[1]                       
                       tel_vlmaxapl[2]
                       tel_vlminapl[2]
                       tel_vlmaxres[2]
                       tel_mesested[2]
                       tel_mrecoted[2]
                       tel_textoaux
                       tel_vctoproc[1]
                       tel_vctoproc[2]
                       tel_vllimint[2]                       
                       WITH FRAME f_dados_captacao.

               MESSAGE "Tecle <Enter> para continuar ou <End> para encerrar".
                   
               WAIT-FOR RETURN, END-ERROR OF CURRENT-WINDOW.
               
               IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                  NEXT.

            END.

      END.
   ELSE   
      IF glb_cddopcao = "A"  THEN
         DO:
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      
               IF tel_inpessoa  THEN
                  DO:
                    
                     HIDE FRAME f_dados_captacao.
                  
                     DISPLAY tel_vllimweb[2]
                             tel_vllimted[2]
                             tel_vlvrbole[2]
                             tel_qtdiaace[2]
                             tel_nrderros[2]
                             tel_vlpconfe[2]
                             tel_qtmesagd[2]
                             WITH FRAME f_dados_fisica.

                     UPDATE tel_vllimweb[1]
                            tel_vllimted[1]
                            tel_vlvrbole[1]
                            WITH FRAME f_dados_fisica.
                     
                     IF tel_vllimweb[1] > tel_vllimweb[2]  THEN
                        DO:
                           MESSAGE "O valor deve ser inferior ou igual " +
                                   "ao estipulado pelo AILOS.".
      
                           NEXT-PROMPT tel_vllimweb[1]
                                       WITH FRAME f_dados_fisica.
                           NEXT.
      
                        END.
      
                     IF tel_vllimted[1] > tel_vllimted[2]  THEN
                        DO:
                           MESSAGE "O valor deve ser inferior ou igual " +
                                   "ao estipulado pelo AILOS.".
      
                           NEXT-PROMPT tel_vllimted[1]
                                       WITH FRAME f_dados_fisica.
      
                           NEXT.
      
                        END.
      
                     IF tel_vlvrbole[1] > tel_vlvrbole[2]  THEN
                        DO:
                           MESSAGE "O valor deve ser inferior ou igual " +
                                   "ao estipulado pelo AILOS.".
      
                           NEXT-PROMPT tel_vlvrbole[1]
                                       WITH FRAME f_dados_fisica.
      
                           NEXT.
      
                        END.
      
                  END.
               ELSE
                  DO:
                      
                     HIDE FRAME f_dados_captacao.
                  
                     DISPLAY tel_vllimtrf[2]  
                             tel_vllimpgo[2]  
                             tel_vllimted[2]  
                             tel_vlvrbole[2]
                             tel_qtdiaace[2]
                             tel_nrderros[2]  
                             tel_vlpconfe[2]
                             tel_qtmesagd[2] 
                             WITH FRAME f_dados_juridica.

                     UPDATE tel_vllimtrf[1] 
                            tel_vllimpgo[1]
                            tel_vllimted[1]
                            tel_vlvrbole[1]
                            WITH FRAME f_dados_juridica.         
                  
                     IF tel_vllimtrf[1] > tel_vllimtrf[2]  THEN
                        DO:
                           MESSAGE "O valor deve ser inferior ou igual " +
                                   "ao estipulado pelo AILOS.".
      
                           NEXT-PROMPT tel_vllimtrf[1]
                                       WITH FRAME f_dados_juridica.
      
                           NEXT.
      
                        END.
      
                     IF tel_vllimpgo[1] > tel_vllimpgo[2]  THEN
                        DO:
                           MESSAGE "O valor deve ser inferior ou igual " +
                                   "ao estipulado pelo AILOS.".
      
                           NEXT-PROMPT tel_vllimpgo[1]
                                       WITH FRAME f_dados_juridica.
      
                           NEXT.
      
                        END.
      
                     IF tel_vllimted[1] > tel_vllimted[2]  THEN
                        DO:
                           MESSAGE "O valor deve ser inferior ou igual " +
                                   "ao estipulado pelo AILOS.".
      
                           NEXT-PROMPT tel_vllimted[1]
                                       WITH FRAME f_dados_juridica.
      
                           NEXT.
      
                        END.
      
                     IF tel_vlvrbole[1] > tel_vlvrbole[2]  THEN
                        DO:
                           MESSAGE "O valor deve ser inferior ou igual " +
                                   "ao estipulado pelo AILOS.".
      
                           NEXT-PROMPT tel_vlvrbole[1]
                                       WITH FRAME f_dados_juridica.
      
                           NEXT.
      
                        END.
      
                  END.
               
               IF glb_cddepart = 20  OR   /* TI                   */
                  glb_cddepart = 14  OR   /* PRODUTOS             */
                  glb_cddepart = 18  OR   /* SUPORTE              */
                  glb_cddepart =  1  OR   /* CANAIS               */
                  glb_cddepart =  8  OR   /* COORD.ADM/FINANCEIRO */
                  glb_cddepart =  9  THEN /* COORD.PRODUTOS       */
                  DO:
                     DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      
                        IF tel_inpessoa  THEN
                           DO:
                              UPDATE tel_vllimweb[2]
                                     tel_vllimted[2]
                                     tel_vlvrbole[2]
                                     tel_qtdiaace[2]
                                     tel_nrderros[2]
                                     tel_vlpconfe[2]
                                     tel_qtmesagd[2]
                                     WITH FRAME f_dados_fisica.
                        
                              IF tel_vllimweb[1] > tel_vllimweb[2]  THEN
                                 DO:
                                    MESSAGE "O valor deve ser maior"
                                            "ou igual ao estipulado"
                                            "para o Operacional.".
      
                                    NEXT-PROMPT tel_vllimweb[2]
                                         WITH FRAME f_dados_fisica.
      
                                    NEXT.
      
                                 END.
      
                              IF tel_vllimted[1] > tel_vllimted[2]  THEN
                                 DO:
                                    MESSAGE "O valor deve ser maior"
                                            "ou igual ao estipulado"
                                            "para o Operacional.".
      
                                    NEXT-PROMPT tel_vllimted[2]
                                         WITH FRAME f_dados_fisica.
      
                                    NEXT.
      
                                 END.
      
                              IF tel_vlvrbole[1] > tel_vlvrbole[2]  THEN
                                 DO:
                                    MESSAGE "O valor deve ser maior"
                                            "ou igual ao estipulado"
                                            "para o Operacional.".
      
                                    NEXT-PROMPT tel_vlvrbole[2]
                                         WITH FRAME f_dados_fisica.
      
                                    NEXT.
      
                                 END.
      
                           END.
                        ELSE
                           DO:
                              UPDATE tel_vllimtrf[2]  
                                     tel_vllimpgo[2]  
                                     tel_vllimted[2]  
                                     tel_vlvrbole[2]
                                     tel_qtdiaace[2]
                                     tel_nrderros[2]  
                                     tel_vlpconfe[2]
                                     tel_qtmesagd[2]  
                                     WITH FRAME f_dados_juridica.
      
                              IF tel_vllimtrf[1] > tel_vllimtrf[2]  THEN
                                 DO:
                                    MESSAGE "O valor deve ser maior"
                                            "ou igual ao estipulado"
                                            "para o Operacional.".
      
                                    NEXT-PROMPT tel_vllimtrf[2]
                                         WITH FRAME f_dados_juridica.
      
                                    NEXT.
      
                                 END.
                                 
                              IF tel_vllimpgo[1] > tel_vllimpgo[2]  THEN
                                 DO:
                                    MESSAGE "O valor deve ser maior"
                                            "ou igual ao estipulado"
                                            "para o Operacional.".
      
                                    NEXT-PROMPT tel_vllimpgo[2]
                                         WITH FRAME f_dados_juridica.
      
                                    NEXT.
      
                                 END.   
      
                              IF tel_vllimted[1] > tel_vllimted[2]  THEN
                                 DO:
                                    MESSAGE "O valor deve ser maior"
                                            "ou igual ao estipulado"
                                            "para o Operacional.".
      
                                    NEXT-PROMPT tel_vllimted[2]
                                         WITH FRAME f_dados_juridica.
      
                                    NEXT.
      
                                 END.   
      
                              IF tel_vlvrbole[1] > tel_vlvrbole[2]  THEN
                                 DO:
                                    MESSAGE "O valor deve ser maior"
                                            "ou igual ao estipulado"
                                            "para o Operacional.".
      
                                    NEXT-PROMPT tel_vlvrbole[2]
                                         WITH FRAME f_dados_juridica.
      
                                    NEXT.
      
                                 END.
                              
                           END.
                            
                        LEAVE.
                  
                     END. /* Fim do DO WHILE TRUE */
                   
                     IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                      NEXT.
      
                  END.
               
               IF glb_cddepart = 20 OR   /* TI       */
                  glb_cddepart = 14 THEN /* PRODUTOS */
                  DO:

                    IF tel_inpessoa  THEN
                      DISPLAY tel_vlmaxapl[2]
                              tel_vlminapl[2]
                              tel_vlmaxres[2]
                              tel_mesested[2]
                              tel_mrecoted[2]
                              tel_vllimint[2]
                              WITH FRAME f_dados_captacao.
                    ELSE
                      DISPLAY tel_vlmaxapl[2]
                              tel_vlminapl[2]
                              tel_vlmaxres[2]
                              tel_mesested[2]
                              tel_mrecoted[2]
                              tel_textoaux
                              tel_vctoproc[2]
                              tel_vllimint[2]
                              WITH FRAME f_dados_captacao.
                     
                     DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                     
                        IF tel_inpessoa  THEN
                          UPDATE tel_vlmaxapl[1]
                                 tel_vlminapl[1]
                                 tel_vlmaxres[1]
                                 tel_mesested[1]
                                 tel_mrecoted[1]
                                 tel_vllimint[1]
                                 WITH FRAME f_dados_captacao.
                        ELSE
                          UPDATE tel_vlmaxapl[1]
                                 tel_vlminapl[1]
                                 tel_vlmaxres[1]
                                 tel_vctoproc[1]
                                 tel_mesested[1]
                                 tel_mrecoted[1]
                                 tel_vllimint[1]
                                 WITH FRAME f_dados_captacao.

                        IF tel_vlmaxapl[1] > tel_vlmaxapl[2]  THEN
                           DO:
                              MESSAGE "O valor deve ser inferior ou igual " +
                                      "ao estipulado pelo AILOS.".
      
                              NEXT-PROMPT tel_vlmaxapl[1]
                                   WITH FRAME f_dados_captacao.
      
                              NEXT.
      
                           END.

                        IF tel_vlminapl[1] > tel_vlminapl[2]  THEN
                           DO:
                              MESSAGE "O valor deve ser inferior ou igual " +
                                      "ao estipulado pelo AILOS.".
      
                              NEXT-PROMPT tel_vlminapl[1]
                                   WITH FRAME f_dados_captacao.
      
                              NEXT.
      
                           END.

                        IF tel_vlmaxres[1] > tel_vlmaxres[2]  THEN
                           DO:
                              MESSAGE "O valor deve ser inferior ou igual " +
                                      "ao estipulado pelo AILOS.".
      
                              NEXT-PROMPT tel_vlmaxres[1]
                                   WITH FRAME f_dados_captacao.
      
                              NEXT.
      
                           END.

                        IF tel_mesested[1] > tel_mesested[2]  THEN
                           DO:
                              MESSAGE "O valor deve ser inferior ou igual " +
                                      "ao estipulado pelo AILOS.".
      
                              NEXT-PROMPT tel_mesested[1]
                                   WITH FRAME f_dados_captacao.
      
                              NEXT.
      
                           END.

                        IF tel_mrecoted[1] > tel_mrecoted[2]  THEN
                           DO:
                              MESSAGE "O valor deve ser inferior ou igual " +
                                      "ao estipulado pelo AILOS.".
      
                              NEXT-PROMPT tel_mrecoted[1]
                                   WITH FRAME f_dados_captacao.
      
                              NEXT.
      
                           END.

                        IF tel_vctoproc[1] > tel_vctoproc[2]  THEN
                           DO:
                              MESSAGE "O valor deve ser inferior ou igual " +
                                      "ao estipulado pelo AILOS.".
      
                              NEXT-PROMPT tel_vctoproc[1]
                                   WITH FRAME f_dados_captacao.
      
                              NEXT.
      
                           END.
                           
                       /* Limite integralização */
                       IF tel_vllimint[1] > tel_vllimint[2]  THEN
                          DO:
                             MESSAGE "O valor deve ser inferior ou igual " +
                                     "ao estipulado pelo AILOS.".
        
                             NEXT-PROMPT tel_vllimint[1]
                                         WITH FRAME f_dados_captacao.
                             NEXT.
                          END.                                  

                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        
                           IF tel_inpessoa  THEN
                             UPDATE tel_vlmaxapl[2]
                                    tel_vlminapl[2]
                                    tel_vlmaxres[2]
                                    tel_mesested[2]
                                    tel_mrecoted[2]
                                    tel_vllimint[2]
                                    WITH FRAME f_dados_captacao.
                           ELSE
                             UPDATE tel_vlmaxapl[2]
                                      tel_vlminapl[2]
                                      tel_vlmaxres[2]
                                      tel_vctoproc[2]
                                      tel_mesested[2]
                                      tel_mrecoted[2]
                                      tel_vllimint[2]
                                      WITH FRAME f_dados_captacao.
                        
                           IF tel_vlmaxapl[1] > tel_vlmaxapl[2]  THEN
                              DO:
                                 MESSAGE "O valor deve ser maior"
                                         "ou igual ao estipulado"
                                         "para o Operacional.".
                        
                                 NEXT-PROMPT tel_vlmaxapl[2]
                                      WITH FRAME f_dados_captacao.
                        
                                 NEXT.
                        
                              END.
                        
                           IF tel_vlminapl[1] > tel_vlminapl[2]  THEN
                              DO:
                                 MESSAGE "O valor deve ser maior"
                                         "ou igual ao estipulado"
                                         "para o Operacional.".
                        
                                 NEXT-PROMPT tel_vlminapl[2]
                                      WITH FRAME f_dados_captacao.
                        
                                 NEXT.
                        
                              END.
                        
                           IF tel_vlmaxres[1] > tel_vlmaxres[2]  THEN
                              DO:
                                 MESSAGE "O valor deve ser maior"
                                         "ou igual ao estipulado"
                                         "para o Operacional.".
                        
                                 NEXT-PROMPT tel_vlmaxres[2]
                                      WITH FRAME f_dados_captacao.
                        
                                 NEXT.
                        
                              END.

                           IF tel_mesested[1] > tel_mesested[2]  THEN
                              DO:
                                 MESSAGE "O valor deve ser maior"
                                         "ou igual ao estipulado"
                                         "para o Operacional.".
                        
                                 NEXT-PROMPT tel_mesested[2]
                                      WITH FRAME f_dados_captacao.
                        
                                 NEXT.
                        
                              END.

                           IF tel_vctoproc[1] > tel_vctoproc[2]  THEN
                              DO:
                                 MESSAGE "O valor deve ser maior"
                                         "ou igual ao estipulado"
                                         "para o Operacional.".
                        
                                 NEXT-PROMPT tel_vctoproc[2]
                                      WITH FRAME f_dados_captacao.
                        
                                 NEXT.
                        
                              END.
                              
                         /* Limite integralização */
                         IF tel_vllimint[1] > tel_vllimint[2]  THEN
                            DO:
                               MESSAGE  "O valor deve ser maior"
                                         "ou igual ao estipulado"
                                         "para o Operacional.".
          
                               NEXT-PROMPT tel_vllimint[2]
                                           WITH FRAME f_dados_captacao.
                               NEXT.
                            END.                                
                        
                           LEAVE.
                        
                        END.
                        
                        IF KEY-FUNCTION(LAST-KEY) = "END-ERROR" THEN
                           NEXT.

                        LEAVE.

                     END.

                     IF KEY-FUNCTION(LAST-KEY) = "END-ERROR" THEN
                        NEXT.

                  END.
                        
               LEAVE.
                                
            END. /* Fim do DO WHILE TRUE */
      
            IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
              NEXT.
            
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        
               ASSIGN aux_confirma = "N"
                      glb_cdcritic = 78.
               RUN fontes/critic.p.
               BELL.
               ASSIGN glb_cdcritic = 0.
               MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.         
                     
               LEAVE.    
                        
            END. /* Fim do DO WHILE TRUE */
      
            IF KEYFUNCTION(LASTKEY) = "END-ERROR"  OR
               aux_confirma <> "S"                 THEN
               DO:
                   ASSIGN glb_cdcritic = 79.
                   RUN fontes/critic.p.
                   BELL.
                   MESSAGE glb_dscritic.
                   ASSIGN glb_cdcritic = 0.
                   NEXT.

               END.

            RUN grava_dados(INPUT glb_cdcooper,
                            INPUT glb_cdagenci, 
                            INPUT 0, /*nrdcaixa*/ 
                            INPUT glb_cdoperad, 
                            INPUT glb_dtmvtolt, 
                            INPUT 1, /*ayllos*/ 
                            INPUT glb_cdprogra, 
                            INPUT tel_inpessoa, 
                            INPUT tel_nrderros, 
                            INPUT tel_qtdiaace, 
                            INPUT tel_qtmesagd, 
                            INPUT 998, 
                            INPUT 998, 
                            INPUT 998, 
                            INPUT tel_vlpconfe, 
                            INPUT tel_vllimweb, 
                            INPUT tel_vllimtrf, 
                            INPUT tel_vllimpgo, 
                            INPUT tel_vllimted, 
                            INPUT tel_vlvrbole, 
                            INPUT tel_vlmaxapl, 
                            INPUT tel_vlminapl, 
                            INPUT tel_vlmaxres, 
                            INPUT tel_mesested,
                            INPUT tel_mrecoted,
                            INPUT tel_vctoproc,
                            INPUT tel_vllimint,
                            OUTPUT TABLE tt-erro).

            IF RETURN-VALUE <> "OK" THEN
               DO:
                  FIND FIRST tt-erro.

                  IF AVAIL tt-erro THEN
                     MESSAGE tt-erro.dscritic.
                  ELSE
                     MESSAGE "Nao foi possivel gravar os limites.".

                  PAUSE 3 NO-MESSAGE.

                  NEXT.

               END.

         END.

END. /* Fim do DO WHILE */

/*ESTA PROCEDURE TEM A FINALIDADE DE BUSCA OS LIMITES*/
PROCEDURE busca_dados:

   DEF INPUT PARAM par_cdcooper AS INT                          NO-UNDO.
   DEF INPUT PARAM par_cdagenci AS INT                          NO-UNDO.
   DEF INPUT PARAM par_nrdcaixa AS INT                          NO-UNDO.
   DEF INPUT PARAM par_cdoperad AS CHAR                         NO-UNDO.
   DEF INPUT PARAM par_dtmvtolt AS DATE                         NO-UNDO.
   DEF INPUT PARAM par_idorigem AS INT                          NO-UNDO.
   DEF INPUT PARAM par_cdprogra AS CHAR                         NO-UNDO.
   DEF INPUT PARAM par_inpessoa AS LOG                          NO-UNDO.

   DEF OUTPUT PARAM par_dstextab AS CHAR                        NO-UNDO.
   DEF OUTPUT PARAM TABLE FOR tt-erro.

   DEF VAR aux_tpregist AS INT                                  NO-UNDO.
   DEF VAR aux_cdcritic AS INT                                  NO-UNDO.
   DEF VAR aux_dscritic AS CHAR                                 NO-UNDO.

   EMPTY TEMP-TABLE tt-erro.

   ASSIGN aux_cdcritic = 0
          aux_dscritic = ""
          aux_tpregist = 0.
           
   IF par_inpessoa THEN
      ASSIGN aux_tpregist = 1. /*Fisica*/
   ELSE
      ASSIGN aux_tpregist = 2. /*Juridica*/

   /*Limites de internet*/
   FIND craptab WHERE craptab.cdcooper = par_cdcooper   AND
                      craptab.nmsistem = "CRED"         AND
                      craptab.tptabela = "GENERI"       AND
                      craptab.cdempres = 0              AND
                      craptab.cdacesso = "LIMINTERNT"   AND
                      craptab.tpregist = aux_tpregist
                      NO-LOCK NO-ERROR.
 
   IF NOT AVAIL craptab THEN
      DO:
         ASSIGN aux_cdcritic = 55.

         RUN gera_erro(INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,            /** Sequencia **/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic ).
         RETURN "NOK".
        
      END.

   ASSIGN par_dstextab = craptab.dstextab.

   RETURN "OK".

END PROCEDURE.

/*ESTA PROCEDURE TEM A FINALIDADE DE GERAR A GRAVACAO DOS LIMITES NA CRAPTAB*/
PROCEDURE grava_dados:

   DEF INPUT PARAM par_cdcooper AS INT                              NO-UNDO.
   DEF INPUT PARAM par_cdagenci AS INT                              NO-UNDO.
   DEF INPUT PARAM par_nrdcaixa AS INT                              NO-UNDO.
   DEF INPUT PARAM par_cdoperad AS CHAR                             NO-UNDO.
   DEF INPUT PARAM par_dtmvtolt AS DATE                             NO-UNDO.
   DEF INPUT PARAM par_idorigem AS INT                              NO-UNDO.
   DEF INPUT PARAM par_cdprogra AS CHAR                             NO-UNDO.
   DEF INPUT PARAM par_inpessoa AS LOG                              NO-UNDO.
   DEF INPUT PARAM par_nrderros AS INTE EXTENT 2                    NO-UNDO.
   DEF INPUT PARAM par_qtdiaace AS INTE EXTENT 2                    NO-UNDO.
   DEF INPUT PARAM par_qtmesagd AS INTE EXTENT 2                    NO-UNDO.
   DEF INPUT PARAM par_qtdiatro AS INTE EXTENT 2                    NO-UNDO.
   DEF INPUT PARAM par_qtdiaaso AS INTE EXTENT 2                    NO-UNDO.
   DEF INPUT PARAM par_qtdiablo AS INTE EXTENT 2                    NO-UNDO.
   DEF INPUT PARAM par_vlpconfe AS DECI EXTENT 2                    NO-UNDO.
   DEF INPUT PARAM par_vllimweb AS DECI EXTENT 2                    NO-UNDO.
   DEF INPUT PARAM par_vllimtrf AS DECI EXTENT 2                    NO-UNDO.
   DEF INPUT PARAM par_vllimpgo AS DECI EXTENT 2                    NO-UNDO.
   DEF INPUT PARAM par_vllimted AS DECI EXTENT 2                    NO-UNDO.
   DEF INPUT PARAM par_vlvrbole AS DECI EXTENT 2                    NO-UNDO.
   DEF INPUT PARAM par_vlmaxapl AS DECI EXTENT 2                    NO-UNDO.
   DEF INPUT PARAM par_vlminapl AS DECI EXTENT 2                    NO-UNDO.
   DEF INPUT PARAM par_vlmaxres AS DECI EXTENT 2                    NO-UNDO.
   DEF INPUT PARAM par_mesested AS INTE EXTENT 2                    NO-UNDO.
   DEF INPUT PARAM par_mrecoted AS INTE EXTENT 2                    NO-UNDO.
   DEF INPUT PARAM par_vctoproc AS INTE EXTENT 2                    NO-UNDO.
   DEF INPUT PARAM par_vllimint AS DECI EXTENT 2                    NO-UNDO.
   DEF OUTPUT PARAM TABLE FOR tt-erro.

   DEF VAR aux_cdcritic AS INT                                      NO-UNDO.
   DEF VAR aux_dscritic AS CHAR                                     NO-UNDO.
   DEF VAR aux_tpregist AS INT                                      NO-UNDO.
   DEF VAR aux_dspessoa AS CHAR                                     NO-UNDO.
   DEF VAR aux_returnvl AS CHAR                                     NO-UNDO.
   DEF VAR aux_dstextab AS CHAR                                     NO-UNDO.

   EMPTY TEMP-TABLE tt-erro.

   ASSIGN aux_cdcritic = 0
          aux_dscritic = ""
          aux_dspessoa = ""
          aux_dstextab = ""
          aux_returnvl = "NOK"
          aux_tpregist = (IF par_inpessoa THEN
                             1 /*Fisica*/
                          ELSE
                             2). /*Juridica*/


   Grava:
   DO TRANSACTION ON ERROR  UNDO Grava, LEAVE Grava
                  ON QUIT   UNDO Grava, LEAVE Grava
                  ON STOP   UNDO Grava, LEAVE Grava
                  ON ENDKEY UNDO Grava, LEAVE Grava:     

      Contador:
      DO aux_contador = 1 TO 10:
      
         ASSIGN aux_cdcritic = 0.

         FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                            craptab.nmsistem = "CRED"       AND
                            craptab.tptabela = "GENERI"     AND
                            craptab.cdempres = 0            AND
                            craptab.cdacesso = "LIMINTERNT" AND
                            craptab.tpregist = aux_tpregist            
                            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                          
         IF NOT AVAILABLE craptab  THEN
            IF LOCKED craptab  THEN
               DO:
                  IF aux_contador = 10 THEN
                     DO:
                        RUN sistema/generico/procedures/b1wgen9999.p
                        PERSISTENT SET h-b1wgen9999.
                        
                        RUN acha-lock IN h-b1wgen9999 (INPUT RECID(craptab),
                        					 INPUT "banco",
                        					 INPUT "craptab",
                        					 OUTPUT par_loginusr,
                        					 OUTPUT par_nmusuari,
                        					 OUTPUT par_dsdevice,
                        					 OUTPUT par_dtconnec,
                        					 OUTPUT par_numipusr).
                        
                        DELETE PROCEDURE h-b1wgen9999.
                        
                        ASSIGN aux_dadosusr = 
                        "077 - Tabela sendo alterada p/ outro terminal.".
                        
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        MESSAGE aux_dadosusr.
                        PAUSE 3 NO-MESSAGE.
                        LEAVE.
                        END.
                        
                        ASSIGN aux_dadosusr = "Operador: " + par_loginusr +
                        			  " - " + par_nmusuari + ".".
                        
                        HIDE MESSAGE NO-PAUSE.
                        
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        MESSAGE aux_dadosusr.
                        PAUSE 5 NO-MESSAGE.
                        LEAVE.
                        END.
                        
                        LEAVE Contador.

                     END.

                  NEXT Contador.

               END.
            ELSE
               DO:
                  ASSIGN aux_cdcritic = 55.

                  LEAVE Contador.

               END.    
                  
         ASSIGN aux_dstextab = craptab.dstextab.

         IF par_inpessoa  THEN /* dados pessoa fisica */
            ASSIGN craptab.dstextab = STRING(par_vllimweb[1],
                                             "999999999999.99") +
                          ";" + STRING(par_nrderros[2],"99") +
                          ";" + STRING(par_qtdiaace[2],"999") +
                          ";" + STRING(par_vlpconfe[2],
                                       "999999999999.99") +
                          ";" + STRING(par_qtmesagd[2],"999") +
                          ";000000,00" +
                          ";" + STRING(par_vllimweb[2],
                                       "999999999999.99") +
                          ";" + STRING(par_nrderros[2],"99") +
                          ";" + STRING(par_qtdiaace[2],"999") +
                          ";" + STRING(par_vlpconfe[2],
                                       "999999999999.99") +
                          ";" + STRING(par_qtmesagd[2],"999") + 
                          ";000000,00" +
                          ";" + STRING(par_vllimted[1],"999999999999.99") + 
                          ";" + STRING(par_vllimted[2],"999999999999.99") +
                          ";" + STRING(par_vlvrbole[1],"999999999999.99") + 
                          ";" + STRING(par_vlvrbole[2],"999999999999.99") +
                          ";" + STRING(par_qtdiatro[1],"999") +
                          ";" + STRING(par_qtdiaaso[1],"999") +
                          ";" + STRING(par_qtdiablo[1],"999") +
                          ";" + STRING(par_qtdiatro[2],"999") +
                          ";" + STRING(par_qtdiaaso[2],"999") +
                          ";" + STRING(par_qtdiablo[2],"999") +
                          ";" + STRING(par_vlmaxapl[1],"999999999999.99") + 
                          ";" + STRING(par_vlminapl[1],"999999999999.99") +
                          ";" + STRING(par_vlmaxres[1],"999999999999.99") + 
                          ";" + STRING(par_vlmaxapl[2],"999999999999.99") + 
                          ";" + STRING(par_vlminapl[2],"999999999999.99") +
                          ";" + STRING(par_vlmaxres[2],"999999999999.99") +
                          ";" + "0" +
                          ";" + "0" +
                          ";" + STRING(par_mesested[1],"999") +
                          ";" + STRING(par_mesested[2],"999") + 
                          ";" + STRING(par_mrecoted[1],"999") + 
                          ";" + STRING(par_mrecoted[2],"999") +
                          ";" + STRING(par_vllimint[1],"999999999999.99") + 
                          ";" + STRING(par_vllimint[2],"999999999999.99").
                          
         ELSE /* dados pessoa juridica */
            ASSIGN craptab.dstextab = STRING(par_vllimtrf[1],
                                             "999999999999.99") +
                          ";" + STRING(par_nrderros[2],"99") +
                          ";" + STRING(par_qtdiaace[2],"999") +
                          ";" + STRING(par_vlpconfe[2],
                                       "999999999999.99") +
                          ";" + STRING(par_qtmesagd[2],"999") +
                          ";" + STRING(par_vllimpgo[1],
                                       "999999999999.99") +
                          ";" + STRING(par_vllimtrf[2],
                                       "999999999999.99") +
                          ";" + STRING(par_nrderros[2],"99") +
                          ";" + STRING(par_qtdiaace[2],"999") +
                          ";" + STRING(par_vlpconfe[2],
                                       "999999999999.99") +
                          ";" + STRING(par_qtmesagd[2],"999") +
                          ";" + STRING(par_vllimpgo[2],"999999999999.99") +
                          ";" + STRING(par_vllimted[1],"999999999999.99") +
                          ";" + STRING(par_vllimted[2],"999999999999.99") + 
                          ";" + STRING(par_vlvrbole[1],"999999999999.99") + 
                          ";" + STRING(par_vlvrbole[2],"999999999999.99") +
                          ";" + STRING(par_qtdiatro[1],"999") +
                          ";" + STRING(par_qtdiaaso[1],"999") +
                          ";" + STRING(par_qtdiablo[1],"999") +
                          ";" + STRING(par_qtdiatro[2],"999") +
                          ";" + STRING(par_qtdiaaso[2],"999") +
                          ";" + STRING(par_qtdiablo[2],"999") +
                          ";" + STRING(par_vlmaxapl[1],"999999999999.99") + 
                          ";" + STRING(par_vlminapl[1],"999999999999.99") +
                          ";" + STRING(par_vlmaxres[1],"999999999999.99") + 
                          ";" + STRING(par_vlmaxapl[2],"999999999999.99") + 
                          ";" + STRING(par_vlminapl[2],"999999999999.99") +
                          ";" + STRING(par_vlmaxres[2],"999999999999.99") +
                          ";" + STRING(par_vctoproc[1],"999") +
                          ";" + STRING(par_vctoproc[2],"999") +
                          ";" + STRING(par_mesested[1],"999") + 
                          ";" + STRING(par_mesested[2],"999") + 
                          ";" + STRING(par_mrecoted[1],"999") + 
                          ";" + STRING(par_mrecoted[2],"999") +
                          ";" + STRING(par_vllimint[1],"999999999999.99") + 
                          ";" + STRING(par_vllimint[2],"999999999999.99").                          
                          

         LEAVE  Contador.
       
      END. /* Fim do DO ... TO */
      
      IF aux_cdcritic <> 0  OR
         aux_dscritic <> "" THEN
         UNDO Grava, LEAVE Grava.

      ASSIGN aux_returnvl = "OK".

   END. /* Fim do DO TRANSACTION */

   RELEASE craptab.

   IF aux_cdcritic <> 0  OR 
      aux_dscritic <> "" THEN
      DO:
         RUN gera_erro(INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,            /** Sequencia **/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic ).
         
         RETURN "NOK".

      END.

   /*Se a gravaco ocorreu com sucesso entao, gera log das informacoes 
     alteradas*/
   IF aux_returnvl = "OK" THEN
      DO:
         IF par_inpessoa THEN
            DO:
               ASSIGN aux_dspessoa = "Fisica".
               
               IF par_vllimweb[1] <> DECI(ENTRY(1,aux_dstextab,";"))  THEN
                  UNIX SILENT VALUE("echo "                                    +
                       STRING(par_dtmvtolt,"99/99/9999")                       +
                       " " + STRING(TIME,"HH:MM:SS") + "' -->'"                +
                       " Operador " + par_cdoperad                             +
                       " alterou o Valor do limite da internet de"             +
                       " Pessoa " + aux_dspessoa + " do Operador de R$ "       +
                       STRING(DECI(ENTRY(1,aux_dstextab,";")),"zzz,zzz,zz9.99")    +
                       " para R$ " + STRING(par_vllimweb[1],"zzz,zzz,zz9.99")    +
                       " >> log/tab045.log").
      
               IF par_vllimted[1] <> DECI(ENTRY(13,aux_dstextab,";"))  THEN
                  UNIX SILENT VALUE("echo "                                   + 
                       STRING(par_dtmvtolt,"99/99/9999")                      +
                       " " + STRING(TIME,"HH:MM:SS") + "' -->'"               +
                       " Operador " + par_cdoperad                            +
                       " alterou o Valor do limite de TED"                    +
                       " Pessoa " + aux_dspessoa + " do Operador de R$ "      +
                       STRING(DECI(ENTRY(13,aux_dstextab,";")),"zzz,zzz,zz9.99")  +
                       " para R$ " + STRING(par_vllimted[1],"zzz,zzz,zz9.99")     +
                       " >> log/tab045.log").
      
               IF par_vlvrbole[1] <> DECI(ENTRY(15,aux_dstextab,";"))  THEN
                   UNIX SILENT VALUE("echo "                                   +
                        STRING(par_dtmvtolt,"99/99/9999")                      +
                        " " + STRING(TIME,"HH:MM:SS") + "' -->'"               +
                        " Operador " + par_cdoperad                            +
                        " alterou o Valor VR Boleto "                          +
                        " Pessoa " + aux_dspessoa + " do Operador de R$ "      +
                        STRING(DECI(ENTRY(15,aux_dstextab,";")),"zzz,zzz,zz9.99")  +
                        " para R$ " + STRING(par_vlvrbole[1],"zzz,zzz,zz9.99") +
                        " >> log/tab045.log").
      
               IF par_vllimweb[2] <> DECI(ENTRY(7,aux_dstextab,";"))  THEN
                  UNIX SILENT VALUE("echo "                                   +
                       STRING(par_dtmvtolt,"99/99/9999")                      +
                       " " + STRING(TIME,"HH:MM:SS") + "' -->'"               +
                       " Operador " + par_cdoperad                            +
                       " alterou o Valor do limite da internet de"            +
                       " Pessoa " + aux_dspessoa + " do AILOS de R$ "         +
                       STRING(DECI(ENTRY(7,aux_dstextab,";")),"zzz,zzz,zz9.99")   +
                       " para R$ " + STRING(par_vllimweb[2],"zzz,zzz,zz9.99")     +
                       " >> log/tab045.log").
      
               IF par_vllimted[2] <> DECI(ENTRY(14,aux_dstextab,";"))  THEN
                  UNIX SILENT VALUE("echo "                                  + 
                       STRING(par_dtmvtolt,"99/99/9999")                     +
                       " " + STRING(TIME,"HH:MM:SS") + "' -->'"              + 
                       " Operador " + par_cdoperad                           +
                       " alterou o Valor do limite de TED"                   +
                       " Pessoa " + aux_dspessoa + " do AILOS de R$ "        +
                       STRING(DECI(ENTRY(14,aux_dstextab,";")),"zzz,zzz,zz9.99") +
                       " para R$ " + STRING(par_vllimted[2],"zzz,zzz,zz9.99")    +
                       " >> log/tab045.log").
      
               IF par_vlvrbole[2] <> DECI(ENTRY(16,aux_dstextab,";"))  THEN
                   UNIX SILENT VALUE("echo "                                   + 
                        STRING(par_dtmvtolt,"99/99/9999")                      +
                        " " + STRING(TIME,"HH:MM:SS") + "' -->'"               + 
                        " Operador " + par_cdoperad                            +
                        " alterou o Valor VR Boleto "                          +
                        " Pessoa " + aux_dspessoa + " do AILOS de R$ "         +
                        STRING(DECI(ENTRY(16,aux_dstextab,";")),"zzz,zzz,zz9.99")  +
                        " para R$ " + STRING(par_vlvrbole[2],"zzz,zzz,zz9.99") +
                        " >> log/tab045.log").
            END.
         ELSE
            DO:
               ASSIGN aux_dspessoa = "Juridica".
               
               IF par_vllimtrf[1] <> DECI(ENTRY(1,aux_dstextab,";"))  THEN
                  UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999") + 
                       " " + STRING(TIME,"HH:MM:SS") + "' -->'"                 + 
                       " Operador " + par_cdoperad                              +
                       " alterou o Valor do limite de transferencia"            +
                       " da internet de Pessoa " + aux_dspessoa                 + 
                       " do Operador de R$ "                                    +
                       STRING(DECI(ENTRY(1,aux_dstextab,";")),"zzz,zzz,zz9.99")     +
                       " para R$ " + STRING(par_vllimtrf[1],"zzz,zzz,zz9.99")       +
                       " >> log/tab045.log").
                       
               IF par_vllimpgo[1] <> DECI(ENTRY(6,aux_dstextab,";"))  THEN
                  UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999") + 
                       " " + STRING(TIME,"HH:MM:SS") + "' -->'"                 + 
                       " Operador " + par_cdoperad                              +
                       " alterou o Valor do limite de pagamento"                +
                       " da internet de Pessoa " + aux_dspessoa                 + 
                       " do Operador de R$ "                                    + 
                       STRING(DECI(ENTRY(6,aux_dstextab,";")),"zzz,zzz,zz9.99")     +
                       " para R$ " + STRING(par_vllimpgo[1],"zzz,zzz,zz9.99")       +
                       " >> log/tab045.log").  
      
               IF par_vllimted[1] <> DECI(ENTRY(13,aux_dstextab,";"))  THEN
                  UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999")  + 
                       " " + STRING(TIME,"HH:MM:SS") + "' -->'"                  + 
                       " Operador " + par_cdoperad                               +
                       " alterou o Valor do limite de TED"                       +
                       " Pessoa " + aux_dspessoa + " do Operador de R$ "         +
                       STRING(DECI(ENTRY(13,aux_dstextab,";")),"zzz,zzz,zz9.99")     +
                       " para R$ " + STRING(par_vllimted[1],"zzz,zzz,zz9.99")        +
                       " >> log/tab045.log").
      
               IF par_vlvrbole[1] <> DECI(ENTRY(15,aux_dstextab,";"))  THEN
                   UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999") +
                        " " + STRING(TIME,"HH:MM:SS") + "' -->'"                 +
                        " Operador " + par_cdoperad                              +
                        " alterou o Valor VR Boleto "                            +
                        " Pessoa " + aux_dspessoa + " do Operador de R$ "        +
                        STRING(DECI(ENTRY(15,aux_dstextab,";")),"zzz,zzz,zz9.99")    +
                        " para R$ " + STRING(par_vlvrbole[1],"zzz,zzz,zz9.99")   +
                        " >> log/tab045.log").
                        
               IF par_vllimtrf[2] <> DECI(ENTRY(7,aux_dstextab,";"))  THEN
                  UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999") +
                       " " + STRING(TIME,"HH:MM:SS") + "' -->'"                 +
                       " Operador " + par_cdoperad                              +
                       " alterou o Valor do limite de transferencia"            +
                       " da internet de Pessoa " + aux_dspessoa                 +
                       " do AILOS de R$ "                                       +
                       STRING(DECI(ENTRY(7,aux_dstextab,";")),"zzz,zzz,zz9.99")     +
                       " para R$ " + STRING(par_vllimtrf[2],"zzz,zzz,zz9.99")       +
                       " >> log/tab045.log").
                                  
               IF par_vllimpgo[2] <> DECI(ENTRY(12,aux_dstextab,";"))  THEN
                  UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999") +
                       " " + STRING(TIME,"HH:MM:SS") + "' -->'"                 +
                       " Operador " + par_cdoperad                              +
                       " alterou o Valor do limite de pagamento"                +
                       " da internet de Pessoa " + aux_dspessoa                 +
                       " do AILOS de R$ "                                       +
                       STRING(DECI(ENTRY(12,aux_dstextab,";")),"zzz,zzz,zz9.99")    +
                       " para R$ " + STRING(par_vllimpgo[2],"zzz,zzz,zz9.99")       +
                       " >> log/tab045.log").
      
               IF par_vllimted[2] <> DECI(ENTRY(14,aux_dstextab,";"))  THEN
                  UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999") + 
                       " " + STRING(TIME,"HH:MM:SS") + "' -->'"                 + 
                       " Operador " + par_cdoperad                              +
                       " alterou o Valor do limite de TED"                      +
                       " Pessoa " + aux_dspessoa + " do AILOS de R$ "           +
                       STRING(DECI(ENTRY(14,aux_dstextab,";")),"zzz,zzz,zz9.99")    +
                       " para R$ " + STRING(par_vllimted[2],"zzz,zzz,zz9.99")       +
                       " >> log/tab045.log").
      
               IF par_vlvrbole[2] <> DECI(ENTRY(16,aux_dstextab,";"))  THEN
                   UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999") + 
                        " " + STRING(TIME,"HH:MM:SS") + "' -->'"                 + 
                        " Operador " + par_cdoperad                              +
                        " alterou o Valor VR Boleto "                            +
                        " Pessoa " + aux_dspessoa + " do AILOS de R$ "           +
                        STRING(DECI(ENTRY(16,aux_dstextab,";")),"zzz,zzz,zz9.99")    +
                        " para R$ " + STRING(par_vlvrbole[2],"zzz,zzz,zz9.99")   +
                        " >> log/tab045.log").

               IF par_vctoproc[2] <> DECI(ENTRY(30,aux_dstextab,";"))  THEN
                   UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999") + 
                        " " + STRING(TIME,"HH:MM:SS") + "' -->'"                 + 
                        " Operador " + par_cdoperad                              +
                        " alterou Qtd. meses para aviso antes venct. procuracao " +
                        " Pessoa " + aux_dspessoa + " do AILOS de "              +
                        STRING(INTE(ENTRY(30,aux_dstextab,";")),"zz9")    +
                        " para " + STRING(par_vctoproc[2],"zz9")   +
                        " >> log/tab045.log").

               IF par_vctoproc[1] <> DECI(ENTRY(29,aux_dstextab,";"))  THEN
                   UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999") + 
                        " " + STRING(TIME,"HH:MM:SS") + "' -->'"                 + 
                        " Operador " + par_cdoperad                              +
                        " alterou Qtd. meses para aviso antes venct. procuracao " +
                        " Pessoa " + aux_dspessoa + " de "             +
                        STRING(INTE(ENTRY(29,aux_dstextab,";")),"zz9")    +
                        " para " + STRING(par_vctoproc[1],"zz9")   +
                        " >> log/tab045.log").
                
            END.
      
         IF par_qtdiatro[1] <> INTE(ENTRY(17,aux_dstextab,";"))  THEN
            UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999")   + 
                 " " + STRING(TIME,"HH:MM:SS") + "' -->'"                   +
                 " Operador " + par_cdoperad                                +
                 " alterou o prazo de solicitacao de troca de senha na "    +
                 " internet de Pessoa " + aux_dspessoa + " do Operador de " +
                 STRING(INTE(ENTRY(17,aux_dstextab,";")),"zz9")             +
                 " para " + STRING(par_qtdiatro[1],"zz9")                   +
                 " >> log/tab045.log").
      
         IF par_qtdiaaso[1] <> INTE(ENTRY(18,aux_dstextab,";"))  THEN
            UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999")       + 
                 " " + STRING(TIME,"HH:MM:SS") + "' -->'"                       +
                 " Operador " + par_cdoperad                                    +
                 " alterou o prazo de alteracao de senha apos solicitacao"      +
                 " na internet de Pessoa " + aux_dspessoa + " do Operador de "  +
                 STRING(INTE(ENTRY(18,aux_dstextab,";")),"zz9")                 +
                 " para " + STRING(par_qtdiaaso[1],"zz9")                       +
                 " >> log/tab045.log").
      
         IF par_qtdiablo[1] <> INTE(ENTRY(19,aux_dstextab,";"))  THEN
            UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999")   + 
                 " " + STRING(TIME,"HH:MM:SS") + "' -->'"                   +
                 " Operador " + par_cdoperad                                +
                 " alterou o prazo de bloqueio acesso a conta na  "         +
                 " internet de Pessoa " + aux_dspessoa + " do Operador de " +
                 STRING(INTE(ENTRY(19,aux_dstextab,";")),"zz9")             +
                 " para " + STRING(par_qtdiablo[1],"zz9")                   +
                 " >> log/tab045.log").
         
         IF par_nrderros[2] <> INTE(ENTRY(8,aux_dstextab,";"))  THEN
            UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999") + 
                 " " + STRING(TIME,"HH:MM:SS") + "' -->'"                 +
                 " Operador " + par_cdoperad                              +
                 " alterou o Limite de erros para senha incorreta de"     +
                 " Pessoa " + aux_dspessoa + " do AILOS de "              +
                 STRING(INTE(ENTRY(8,aux_dstextab,";")),"z9")             +
                 " para " + STRING(par_nrderros[2],"z9")                  +
                 " >> log/tab045.log").
                           
         IF par_qtdiaace[2] <> INTE(ENTRY(9,aux_dstextab,";"))  THEN
            UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999") + 
                 " " + STRING(TIME,"HH:MM:SS") + "' -->'"                 +
                 " Operador " + par_cdoperad                              +
                 " alterou o Limite de dias para primeiro acesso a"       +
                 " internet de Pessoa " + aux_dspessoa + " do AILOS de "  +
                 STRING(INTE(ENTRY(9,aux_dstextab,";")),"zz9")            +
                 " para " + STRING(par_qtdiaace[2],"zz9")                 +
                 " >> log/tab045.log").                      
            
         IF par_vlpconfe[2] <> DECI(ENTRY(10,aux_dstextab,";"))  THEN
            UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999")  + 
                 " " + STRING(TIME,"HH:MM:SS") + "' -->'"                  +
                 " Operador " + par_cdoperad                               +
                 " alterou o Valor para conferencia envio"                 +
                 " de Pessoa " + aux_dspessoa + " do  AILOS de R$ "        +
                 STRING(DECI(ENTRY(10,aux_dstextab,";")),"z,zzz,zz9.99")     +
                 " para R$ " + STRING(par_vlpconfe[2],"z,zzz,zz9.99")        +
                 " >> log/tab045.log").
                 
         IF par_qtmesagd[2] <> INTE(ENTRY(11,aux_dstextab,";"))  THEN
            UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999")  + 
                 " " + STRING(TIME,"HH:MM:SS") + "' -->'"                  +
                 " Operador " + par_cdoperad                               +
                 " alterou o Limite de meses para agendamento na internet" +
                 " de Pessoa " + aux_dspessoa + " do AILOS de "            +
                 STRING(INTE(ENTRY(11,aux_dstextab,";")),"zz9")            +
                 " para " + STRING(par_qtmesagd[2],"zz9")                  +
                 " >> log/tab045.log").
      
         IF par_qtdiatro[2] <> INTE(ENTRY(20,aux_dstextab,";"))  THEN
            UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999")  + 
                 " " + STRING(TIME,"HH:MM:SS") + "' -->'"                  +
                 " Operador " + par_cdoperad                               +
                 " alterou o prazo de solicitacao de troca de senha na "   +
                 " internet de Pessoa " + aux_dspessoa + " do AILOS de "   +
                 STRING(INTE(ENTRY(20,aux_dstextab,";")),"zz9")            +
                 " para " + STRING(par_qtdiatro[2],"zz9")                  +
                 " >> log/tab045.log").
      
         IF par_qtdiaaso[2] <> INTE(ENTRY(21,aux_dstextab,";"))  THEN
            UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999")     + 
                 " " + STRING(TIME,"HH:MM:SS") + "' -->'"                     +
                 " Operador " + par_cdoperad                                  +
                 " alterou o prazo de alteracao de senha apos solicitacao"    +
                 " na internet de Pessoa " + aux_dspessoa + " do AILOS de "   +
                 STRING(INTE(ENTRY(21,aux_dstextab,";")),"zz9")               +
                 " para " + STRING(par_qtdiaaso[2],"zz9")                     +
                 " >> log/tab045.log").
      
         IF par_qtdiablo[2] <> INTE(ENTRY(22,aux_dstextab,";"))  THEN
            UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999")  + 
                 " " + STRING(TIME,"HH:MM:SS") + "' -->'"                  +
                 " Operador " + par_cdoperad                               +
                 " alterou o prazo de bloqueio acesso a conta na  "        +
                 " internet de Pessoa " + aux_dspessoa + " do AILOS de "   +
                 STRING(INTE(ENTRY(22,aux_dstextab,";")),"zz9")            +
                 " para " + STRING(par_qtdiablo[2],"zz9")                  +
                 " >> log/tab045.log").
      
         IF par_vlmaxapl[1] <> DEC(ENTRY(23,aux_dstextab,";"))  THEN
            UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999")      +
                " " + STRING(TIME,"HH:MM:SS") + "' -->'"                       +
                " Operador " + par_cdoperad + " alterou o valor maximo "       +
                "da aplicacao de Pessoa " + aux_dspessoa + " de "              +
                STRING(DECI(ENTRY(23,aux_dstextab,";")),"zzz,zzz,zzz,zz9.99")  +
                " para " + STRING(par_vlmaxapl[1],"zzz,zzz,zzz,zz9.99")           +
                " >> log/tab045.log").
      
         IF par_vlminapl[1] <> DEC(ENTRY(24,aux_dstextab,";"))  THEN
            UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999")      +
                " " + STRING(TIME,"HH:MM:SS") + "' -->'"                       +
                " Operador " + par_cdoperad + " alterou o valor minimo "       +
                "da aplicacao de Pessoa " + aux_dspessoa + " de "              +
                STRING(DECI(ENTRY(24,aux_dstextab,";")),"zzz,zzz,zzz,zz9.99")  +
                " para " + STRING(par_vlminapl[1],"zzz,zzz,zzz,zz9.99")           +
                " >> log/tab045.log").
      
         IF par_vlmaxres[1] <> DEC(ENTRY(25,aux_dstextab,";"))  THEN
            UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999")      +
                " " + STRING(TIME,"HH:MM:SS") + "' -->'"                       +
                " Operador " + par_cdoperad + " alterou o valor maximo "       +
                "de resgate de pessoa " + aux_dspessoa + " de "                +
                STRING(DECI(ENTRY(25,aux_dstextab,";")),"zzz,zzz,zzz,zz9.99")  +
                " para " + STRING(par_vlmaxres[1],"zzz,zzz,zzz,zz9.99")           +
                " >> log/tab045.log").
      
          IF par_vlmaxapl[2] <> DEC(ENTRY(26,aux_dstextab,";"))  THEN
            UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999")      +
                " " + STRING(TIME,"HH:MM:SS") + "' -->'"                       +
                " Operador " + par_cdoperad + " alterou o valor maximo "       +
                "da aplicacao de Pessoa " + aux_dspessoa                       +
                " do AILOS de " + " de "                                       +
                STRING(DECI(ENTRY(26,aux_dstextab,";")),"zzz,zzz,zzz,zz9.99")  +
                " para " + STRING(par_vlmaxapl[2],"zzz,zzz,zzz,zz9.99")           +
                " >> log/tab045.log").

         IF par_vlminapl[2] <> DEC(ENTRY(27,aux_dstextab,";"))  THEN
            UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999")      +
                " " + STRING(TIME,"HH:MM:SS") + "' -->'"                       +
                " Operador " + par_cdoperad + " alterou o valor minimo "       +
                "da aplicacao de Pessoa " + aux_dspessoa                       + 
                " do AILOS de " + " de "                                       +
                STRING(DECI(ENTRY(27,aux_dstextab,";")),"zzz,zzz,zzz,zz9.99")  +
                " para " + STRING(par_vlminapl[2],"zzz,zzz,zzz,zz9.99")           +
                " >> log/tab045.log").
      
         IF par_vlmaxres[2] <> DEC(ENTRY(28,aux_dstextab,";"))  THEN
            UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999")      +
                " " + STRING(TIME,"HH:MM:SS") + "' -->'"                       +
                " Operador " + par_cdoperad + " alterou o valor maximo "       +
                "de resgate de pessoa " + aux_dspessoa                         + 
                " do AILOS de " + " de "                                       +
                STRING(DECI(ENTRY(28,aux_dstextab,";")),"zzz,zzz,zzz,zz9.99")  +
                " para " + STRING(par_vlmaxres[2],"zzz,zzz,zzz,zz9.99")           +
                " >> log/tab045.log").

         IF par_mesested[1] <> INTE(ENTRY(31,aux_dstextab,";"))  THEN
            UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999")      +
                " " + STRING(TIME,"HH:MM:SS") + "' -->'"                       +
                " Operador " + par_cdoperad + " alterou a quantidade de meses " +
                "para agendamento TED de pessoa " + aux_dspessoa               + 
                " de " + STRING(INTE(ENTRY(31,aux_dstextab,";")),"999")        +
                " para " + STRING(par_mesested[1],"999")                       +
                " >> log/tab045.log").

         IF par_mesested[2] <> INTE(ENTRY(32,aux_dstextab,";"))  THEN
            UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999")      +
                " " + STRING(TIME,"HH:MM:SS") + "' -->'"                       +
                " Operador " + par_cdoperad + " alterou a quantidade de meses " +
                "para agendamento TED de pessoa " + aux_dspessoa               + 
                " do AILOS de " + STRING(INTE(ENTRY(32,aux_dstextab,";")),"999") +
                " para " + STRING(par_mesested[2],"999")                       +
                " >> log/tab045.log").

         IF par_mrecoted[1] <> INTE(ENTRY(33,aux_dstextab,";"))  THEN
            UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999")      +
                " " + STRING(TIME,"HH:MM:SS") + "' -->'"                       +
                " Operador " + par_cdoperad + " alterou a quantidade de meses " +
                "para agendamento recorrente de TED de pessoa " + aux_dspessoa + 
                " de " + STRING(INTE(ENTRY(33,aux_dstextab,";")),"999")        +
                " para " + STRING(par_mrecoted[1],"999")                       +
                " >> log/tab045.log").

         IF par_mrecoted[2] <> INTE(ENTRY(34,aux_dstextab,";"))  THEN
            UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999")      +
                " " + STRING(TIME,"HH:MM:SS") + "' -->'"                       +
                " Operador " + par_cdoperad + " alterou a quantidade de meses " +
                "para agendamento recorrente de TED de pessoa " + aux_dspessoa + 
                " do AILOS de " + STRING(INTE(ENTRY(34,aux_dstextab,";")),"999") +
                " para " + STRING(par_mrecoted[1],"999")                       +
                " >> log/tab045.log").
                
          /* Valor maximo integralizacao de capital */
          IF par_vllimint[1] <> INTE(ENTRY(35,aux_dstextab,";"))  THEN
              UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999")      +
                  " " + STRING(TIME,"HH:MM:SS") + "' -->'"                       +
                  " Operador " + par_cdoperad + " alterou o valor maximo " +
                  "de integralizacao de cotas de pessoa " + aux_dspessoa + 
                  " de " + STRING(INTE(ENTRY(35,aux_dstextab,";")),"zzz,zzz,zzz,zz9.99") +
                  " para " + STRING(par_vllimint[1],"zzz,zzz,zzz,zz9.99")                       +
                  " >> log/tab045.log").        
                  
          /* Valor maximo integralizacao de capital */
          IF par_vllimint[2] <> INTE(ENTRY(36,aux_dstextab,";"))  THEN
              UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999")      +
                  " " + STRING(TIME,"HH:MM:SS") + "' -->'"                       +
                  " Operador " + par_cdoperad + " alterou o valor maximo " +
                  " de integralizacao de cotas de pessoa " + aux_dspessoa + 
                  " do AILOS de " + STRING(INTE(ENTRY(36,aux_dstextab,";")),"zzz,zzz,zzz,zz9.99") +
                  " para " + STRING(par_vllimint[2],"zzz,zzz,zzz,zz9.99")                       +
                  " >> log/tab045.log").                
        
      END.
        
   RETURN aux_returnvl.


END PROCEDURE.


/****************************************************************************/