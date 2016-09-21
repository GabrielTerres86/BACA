/* ............................................................................

   Programa: Fontes/limite.p
   Sistema : Conta-Corrente - Cooperativa 
   Sigla   : CRED
   Autor   : Odair
   Data    : Janeiro/99.                        Ultima atualizacao: 07/04/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para tratar limite de credito para a tela ATENDA.

   Alteracoes: 14/06/99 - Incluir aplicacoes na proposta (Odair)
   
               07/07/99 - Imprimir cancelamento no mesmo dia (Odair)

               25/10/1999 - Substituir "3CREDIHERING" por glb_nmrescop (Edson).
               
               17/12/1999 - Listar cdmotcan = 4 como cancelado transferencia
                            (Odair) 

               16/10/2000 - Alterar fone para 20 posicoes (Margarete/Planner).
                
               27/11/2000 - Incluir opcao de impressao (Margarete/Planner). 

               11/04/2001 - Incluir tratamento para geracao de
                            nota promissoria (Margarete/Planner).     

               08/06/2001 - Acerto na rotina de limite - mostrava o contrato
                            errado quando tinha mais de um no mes dia
                            (Deborah).

               28/12/2001 - Alterado para tratar a rotina ver_capital (Edson).
    
               18/04/2002 - Forcar a impressao da nota promissoria (Edson).

               01/07/2002 - Colocar opcoes para impressao (Margarete).

               13/03/2003 - Alterado para tratar novos campos craplim (Edson).

               27/06/2003 - Forcar a impressao da proposta (Deborah). 

               31/07/2003 - Inclusao da rotina ver_cadastro (Julio). 
             
               23/06/2004 - Acessar dados Tabela Avalistas Terceiros(Mirtes)
               
               28/06/2004 - Nao confirmar contrato se o processo ja foi
                            pedido (Margarete).
               
               20/07/2004 - Criticar valor utilizado(Mirtes)
               
               05/08/2004 - Incluida consulta Avalistas(Mirtes).

               17/08/2004 - Incluido campos cidade/uf/cep(Evandro).
               
               14/10/2004 - Obter Risco do Rating(Associado)/Verificar 
                            Atualizacao do Rating(Evandro).
                            
               23/12/2004 - Incluida a opcao "Rescisao", para imprimir o termo
                            de cancelamento do Limite de Credito (Evandro).
                            
               18/05/2005 - Alterada tabela craptab por crapcop (Diego). 
                           
               04/07/2005 - Alimentado campo cdcooper das tabelas craplim,
                            crapprp e crapavl (Diego).

               26/07/2005 - Retirar atualizacao Rating para valores menores
                            que 50.000(Mirtes).

               25/08/2005 - Alterada procedure verificar_atualizacao_rating
                            (Mirtes)

               28/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).

               27/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
               
               24/10/2006 - Incluida mensagem para verificar SCR quando valor
                            de limite for maior que o parametrizado (Elton).
                            
               24/04/2007 - Adaptar no programa a estrutura craplrt (Ze).

               24/09/2007 - Conversao de rotina ver_capital e 
                            ver_cadastro para BO (Sidnei/Precise)
                            
               28/09/2007 - Mudanca leitura tabela craplrt(tarefa 13153)

               27/12/2007 - Efetuado acerto na chamada da procedure
                            ver_cadastro (Diego).
                            
               03/08/2008 - Alterado FORMAT do Valor do limite
                            fonte tambem alterado no AYLLOS WEB(Guilherme).
                            
               30/06/2009 - Alteracao na chamada do programa fontes/limite_inp
                            para incluir parametro (handle BO - passado ?) -
                            Alteracao para utilizado de BOs (GATI - Eder)
                            
               08/12/2009 - Efetuadas alterações para o novo RATING - preenchi-
                            mento obrigatorio dos campos do frame f_rating
                            (Fernando)
                          - Alteracoes nos campos do frame f_rating (Elton). 
                          
               01/03/2010 - Mostrar as criticas do Rating (Gabriel).
               
               07/04/2010 - Validar permissao para Confirma Novo Limite
                            (Guilherme).
                          - Evitar erro de critica repetitiva quando
                            valor utilizado excedido (Gabriel). 
                            
               20/04/2010 - Adaptacao do novo RATING para o Ayllos Web (David).
               
               23/06/2010 - Incluir campo de envio a sede (Gabriel).
               
               20/09/2010 - Enviar novo parametro nrdconta para o fonte 
                            implimite.p (David).
                            
               21/10/2010 - Alteracoes para implementacao de limites de credito
                            com taxas diferenciadas:
                            - Inclusao dos campos Codigo e Descricao da linha
                              de credito na tela
                            - Opcao do usuario informar a linha de credito do 
                              novo limite
                            - Opcao de chamar zoom de linhas de credito, 
                              mostrando somente as linhas com tipo relacionado
                              ao tipo de pessoa da conta
                            - Alteracao do padrao do campo Observacoes na nova
                              proposta de limite (FRAME f_observacao) 
                              (GATI - Eder)
                              
               11/01/2011 - Iincluido o campo dsencfi3 no form f_limite 
                            (Adriano).
                            
               05/04/2011 - Alterado parametros da procedure sequencia_rating
                            para atender a nova tabela do rating. (Fabrício)
                            
               11/04/2011 - Inclusao do parametro de entrada 
                            tt-impressao-risco-tl em mostra_rating_gerado,
                            e como parametro de saida em confirmar-novo-limite.
                            (Fabricio)
                            
               19/04/2011 - Alteração para exibir avalistas separadamente
                            devido a CEP integrado. Incluidos campos nrendere,
                            complend e nrcxapst. (André - DB1)           
                            
               13/07/2011 - Voltar atras quando der erro no programa
                            que trata dos avalistas (Gabriel).
                            
               15/09/2011 - Rating das singulares na CECRED (Guilherme).
               
               05/10/2011 - Realizado a chamada da procedure alerta_fraude
                            (Adriano).
                            
               09/11/2011 - Realizado a passagem de dois argumentos na include
                            rating_singulares.i (Adriano).
                            
               12/09/2012 - Corrigir permissoes da tela (Gabriel) 
               
               12/11/2012 - Incluir browse f_ge_limite e f_grupo_limite GE
                            (Lucas R.).
                            
               21/03/2013 - Ajsutes realizados:
                             - Retirado a chamada da procedure alerta_fraude;
                             - Ajuste no layout dos frames f_ge_limite,
                               f_grupo_limite (Adriano).       
                              
               02/07/2014 - Permitir alterar a observacao da proposta 
                            (Chamado 169007) (Jonata - RKAM). 
                            
               07/07/2014 - Inclusao da include b1wgen0138tt para uso da
                            temp-table tt-grupo.(Tiago Castro - RKAM)       
                            
               27/08/2014 - Ajustes referentes ao Projeto CET (Lucas R./Gielow)
               
               23/12/2014 - Incluir a acao Renovar. (James)
               
               07/04/2015 - Consultas automatizadas. Retirar todas
                            as opcoes, deixar somente a consulta principal
                            (Jonata-RKAM).
............................................................................ */

{ includes/var_online.i }
{ includes/var_atenda.i }

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0019tt.i }


DEF VAR tel_confcanc AS CHAR                 INIT "Confirmar/Cancelar" NO-UNDO.
DEF VAR tel_dsplalim AS CHAR                 INIT "Incluir"            NO-UNDO.
DEF VAR tel_dsaltera AS CHAR                 INIT "Alterar"            NO-UNDO.
DEF VAR tel_dsextlim AS CHAR                 INIT "Alteracoes"         NO-UNDO.
DEF VAR tel_dsimprim AS CHAR  FORMAT "x(8)"  INIT "Imprimir"           NO-UNDO.
DEF VAR tel_avalista AS CHAR  FORMAT "x(8)"  INIT "Avais"              NO-UNDO.
DEF VAR tel_dsrenova AS CHAR  FORMAT "x(7)"  INIT "Renovar"            NO-UNDO.

DEF VAR aux_flgconal AS LOGI                                           NO-UNDO.
DEF VAR aux_dstitulo AS CHAR                                           NO-UNDO.

DEF VAR h_b1wgen0019 AS HANDLE                                         NO-UNDO.

          
FORM SKIP
     tt-cabec-limcredito.vllimite AT  2 FORMAT "zz,zzz,zz9.99" 
                                                            LABEL  "Valor do Limite"
     tt-cabec-limcredito.dslimcre AT 33 FORMAT "x(18)"      NO-LABEL
     tt-cabec-limcredito.dtmvtolt AT 53 FORMAT "99/99/9999" LABEL "Contratacao"
     SKIP
     tt-cabec-limcredito.cddlinha AT 12 FORMAT "zz9"        LABEL "Linha"
     tt-cabec-limcredito.dsdlinha AT 23 FORMAT "X(25)"      NO-LABEL
     tt-cabec-limcredito.dtfimvig AT 49 FORMAT "99/99/9999" LABEL "Data de Termino"
     SKIP
     tt-cabec-limcredito.nrctrlim AT 9  FORMAT " z,zzz,zz9" LABEL "Contrato"
     tt-cabec-limcredito.qtdiavig AT 56 FORMAT "zz9"        LABEL "Vigencia"
     "dias"                       AT 72
     SKIP
     tt-cabec-limcredito.dstprenv AT 3  FORMAT "x(10)"      LABEL "Tipo Renovacao"
     tt-cabec-limcredito.qtrenova AT 31 FORMAT "zz9"        LABEL "Renovacoes"
     tt-cabec-limcredito.dtrenova AT 50 FORMAT "99/99/9999" LABEL "Data Renovacao"
     SKIP(1)
     tt-cabec-limcredito.dsencfi1 AT  4 FORMAT "x(50)"      LABEL "Encargos Financeiros"
     tt-cabec-limcredito.dsencfi2 AT 26 FORMAT "x(50)"      NO-LABEL
     tt-cabec-limcredito.dsencfi3 AT 26 FORMAT "x(50)"      NO-LABEL
     SKIP
     tt-cabec-limcredito.dssitlli AT  4 FORMAT "x(10)"      LABEL "Situacao"
     tt-cabec-limcredito.dsmotivo AT 24 FORMAT "x(20)"      NO-LABEL  
     tt-cabec-limcredito.nmoperad AT  4 FORMAT "x(30)"      LABEL "Operador"
     SKIP
     tt-cabec-limcredito.nmopelib AT  4 FORMAT "x(30)"      LABEL "Op. Libe"
     tt-cabec-limcredito.flgenvio AT 58 FORMAT "x(3)"       LABEL "Comite"
     SKIP(1)
     tel_confcanc                 AT  2 FORMAT "x(18)"      NO-LABEL
                                  HELP "  Confirma proposta em estudo."
     tel_dsaltera                 AT 21 FORMAT "x(7)"
                                  HELP "  Alterar proposta."
     tel_dsplalim                 AT 31 FORMAT "x(7)"       NO-LABEL
                                  HELP "  Inclui novo contrato ou exclui proposta."
     tel_dsrenova                 AT 40                     NO-LABEL
                                  HELP "  Renovar o contrato atual."
     tel_dsextlim                 AT 49 FORMAT "x(10)"      NO-LABEL
                                  HELP "  Lista ultimas alteracoes de limite."
     tel_dsimprim                 AT 61 FORMAT "x(08)"      NO-LABEL
                                  HELP "  Imprime limite de credito"
     tel_avalista                 AT 71 FORMAT "x(05)"      NO-LABEL
                                  HELP "  Consulta Avalistas"
     WITH ROW 7 CENTERED SIDE-LABELS NO-LABELS OVERLAY TITLE COLOR NORMAL
          aux_dstitulo WIDTH  78 FRAME f_limite.

/****************** Inicio ***********************/
TRANS_1:
DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   HIDE FRAME f_limite NO-PAUSE.

   RUN sistema/generico/procedures/b1wgen0019.p PERSISTENT SET h_b1wgen0019.
    
   RUN obtem-cabecalho-limite IN h_b1wgen0019
                             ( INPUT  glb_cdcooper,
                               INPUT  0,
                               INPUT  0,
                               INPUT  glb_cdoperad,
                               INPUT  glb_nmdatela,
                               INPUT  1,
                               INPUT  tel_nrdconta,
                               INPUT  1,
                               INPUT  glb_dtmvtolt,
                               INPUT  YES,
                               OUTPUT TABLE tt-cabec-limcredito,
                               OUTPUT TABLE tt-erro).
   DELETE PROCEDURE h_b1wgen0019.
    
   IF   RETURN-VALUE = "NOK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF   AVAIL tt-erro THEN
                 DO:
                     MESSAGE tt-erro.dscritic.
                     RETURN "NOK".
                 END.
        END.
                         
   FIND tt-cabec-limcredito NO-ERROR.
    
   IF   NOT AVAIL tt-cabec-limcredito   THEN
        DO:
            RETURN "NOK".
        END.    
         
   ASSIGN aux_dstitulo = tt-cabec-limcredito.dstitulo.
    
   HIDE MESSAGE NO-PAUSE.
    
   IF   tt-cabec-limcredito.flgpropo = TRUE           THEN
        ASSIGN aux_flgconal    = TRUE
               tel_confcanc    = "Confirmar limite"
               tel_confcanc:HELP IN FRAME f_limite =
                                  "Confirmar. "                      +
                                  "Contrato: "                       +
         TRIM(STRING(tt-cabec-limcredito.nrctrpro,"z,zzz,zz9"))      +
                                  " Linha: "                         +
         TRIM(STRING(tt-cabec-limcredito.cdlinpro,"zz9"))            +
                                  " Valor: "                         + 
         TRIM(STRING(tt-cabec-limcredito.vllimpro,"zzz,zzz,zz9.99")) +
        
         " Comite: " + STRING(tt-cabec-limcredito.flgenpro,"Sim/Nao").
         
   ELSE
   IF   tt-cabec-limcredito.dssitlli <> "CANCELADO"   AND
        tt-cabec-limcredito.dssitlli <> ""            THEN
        ASSIGN aux_flgconal    = TRUE
               tel_confcanc    = "Cancelar limite"
               tel_confcanc:HELP IN FRAME f_limite = 
                                  "Cancela limite atual".
   ELSE
        ASSIGN aux_flgconal = FALSE.                                                            
           
   DISPLAY tt-cabec-limcredito.vllimite   tt-cabec-limcredito.dslimcre
           tt-cabec-limcredito.dtmvtolt   tt-cabec-limcredito.cddlinha
           tt-cabec-limcredito.dsdlinha    
           tt-cabec-limcredito.dtfimvig   tt-cabec-limcredito.nrctrlim
           tt-cabec-limcredito.qtdiavig   tt-cabec-limcredito.dsencfi1
           tt-cabec-limcredito.dsencfi2   tt-cabec-limcredito.dsencfi3
           tt-cabec-limcredito.dstprenv   tt-cabec-limcredito.qtrenova
           tt-cabec-limcredito.dtrenova
           tt-cabec-limcredito.dssitlli
           tt-cabec-limcredito.dsmotivo   tt-cabec-limcredito.nmoperad
           tt-cabec-limcredito.flgenvio
           tel_confcanc                   tel_dsplalim
           tel_dsrenova                   tel_dsaltera
           tel_dsextlim                   tel_dsimprim
           tel_avalista                   tt-cabec-limcredito.nmopelib
           WITH FRAME f_limite.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
 
       IF   aux_flgconal AND tt-cabec-limcredito.dssitlli = "ATIVO" THEN
            CHOOSE FIELD tel_confcanc
                         tel_dsaltera
                         tel_dsplalim
                         tel_dsrenova
                         tel_dsextlim 
                         tel_dsimprim
                         tel_avalista
                         WITH FRAME f_limite.
       ELSE 
       IF   aux_flgconal THEN
            CHOOSE FIELD tel_confcanc
                         tel_dsaltera
                         tel_dsplalim
                         tel_dsextlim 
                         tel_dsimprim
                         tel_avalista
                         WITH FRAME f_limite.
       ELSE /* Limite cancelado */
            CHOOSE FIELD tel_dsplalim
                         tel_dsextlim 
                         tel_dsimprim
                         tel_avalista
                         WITH FRAME f_limite.
    
       DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
           MESSAGE "Opcao nao disponível. Utilize o Ayllos Web.".
           PAUSE 3 NO-MESSAGE.
           HIDE MESSAGE.
           LEAVE.
       END.
                       
   END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
        LEAVE.

END.  /*  DO WHILE TRUE  */

HIDE MESSAGE NO-PAUSE.
HIDE FRAME f_limite.

RETURN "OK".
         
/*......................................................................... */



