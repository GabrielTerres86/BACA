/* ..............................................................................

Procedure: imprime_saldo_limite.p 
Objetivo : Montar o comprovante de saldo e limite para impressao
Autor    : Evandro
Data     : Fevereiro 2010


Ultima alteração: 15/10/2010 - Ajustes para TAA compartilhado (Evandro).

                  18/07/2013 - Correção número da agencia da cooperativa (Lucas).
                  
                  07/11/2013 - Alterado Posto de Atendimento ao Cooperado para
                               Posto de Atendimento "PA". (Jorge)
                  
                  20/08/2015 - Adicionado SAC e OUVIDORIA nos comprovantes
                               (Lucas Lunelli - Melhoria 83 [SD 279180])
                               
                  27/01/2016 - Imprimir valor disponível de pré-aprovado
                               (Lucas Lunelli - PRJ261)

............................................................................... */

DEFINE  INPUT PARAM par_nmtitula    AS CHARACTER    EXTENT 2        NO-UNDO.
DEFINE  INPUT PARAM par_vlsddisp    AS DECIMAL                      NO-UNDO.
DEFINE  INPUT PARAM par_vllautom    AS DECIMAL                      NO-UNDO.
DEFINE  INPUT PARAM par_vlsdbloq    AS DECIMAL                      NO-UNDO.
DEFINE  INPUT PARAM par_vlblqtaa    AS DECIMAL                      NO-UNDO.
DEFINE  INPUT PARAM par_vlsdblpr    AS DECIMAL                      NO-UNDO.
DEFINE  INPUT PARAM par_vlsdblfp    AS DECIMAL                      NO-UNDO.
DEFINE  INPUT PARAM par_vlsdchsl    AS DECIMAL                      NO-UNDO.
DEFINE  INPUT PARAM par_vllimcre    AS DECIMAL                      NO-UNDO.
DEFINE  INPUT PARAM par_vldiscrd    AS DECIMAL                      NO-UNDO. /* PRÉ-APROVADO */
DEFINE  INPUT PARAM par_vlstotal    AS DECIMAL                      NO-UNDO.
DEFINE OUTPUT PARAM par_tximpres    AS CHARACTER                    NO-UNDO.

{ includes/var_taa.i }

DEFINE   VARIABLE aux_nrtelsac      AS CHARACTER                    NO-UNDO.
DEFINE   VARIABLE aux_nrtelouv      AS CHARACTER                    NO-UNDO.
DEFINE   VARIABLE aux_flgderro      AS LOGICAL                      NO-UNDO.


/* quando o nome do associado for informado, monta o cabecalho
   completo, senao somente os valores para poder ser usado
   em outras rotinas como ao final do extrato */
IF  par_nmtitula[1] <> ""  THEN
    DO:
        /* São 48 caracteres */

        RUN procedures/obtem_informacoes_comprovante.p (OUTPUT aux_nrtelsac,
                                                        OUTPUT aux_nrtelouv,
                                                        OUTPUT aux_flgderro).
        
        /* centraliza o cabeçalho */
                              /* Coop do associado */
        ASSIGN par_tximpres = TRIM(glb_nmrescop) + " AUTOATENDIMENTO"
               par_tximpres = FILL(" ",INT((48 - LENGTH(par_tximpres)) / 2)) + par_tximpres
               par_tximpres = par_tximpres + FILL(" ",48 - length(par_tximpres))
               par_tximpres = par_tximpres +
                              "                                                "   +
                              "EMISSAO: " + STRING(TODAY,"99/99/9999") + "      "  +
                                      "               " + STRING(TIME,'HH:MM:SS')  +
                              "                                                "   +
                              /* dados do TAA */             /* agencia na central, sem digito */
                              "COOPERATIVA/PA/TERMINAL: " + STRING(glb_agctltfn,"9999") + "/" +
                                                            STRING(glb_cdagetfn,"9999") + "/" +
                                                            STRING(glb_nrterfin,"9999") +
                                                                     "         " +
                              "                                                " +
                              "      CONSULTA DE SALDO DE CONTA CORRENTE       " +
                              "                                                " +
                              "CONTA: " + STRING(glb_nrdconta,"zzzz,zzz,9")      +
                              " - " + STRING(par_nmtitula[1],"x(28)").

        /* Segundo titular */
        IF  par_nmtitula[2] <> ""  THEN
            par_tximpres = par_tximpres +
                           "                    " + STRING(par_nmtitula[2],"x(28)").
    END.


par_tximpres = par_tximpres +
               "                                                "            +
               "              SALDO EM " + STRING(glb_dtmvtocd,"99/99/9999") + 
                                                "               "            +
               "                                                "            +
               "    DISPONIVEL PARA SAQUE:    " + STRING(par_vlsddisp,"zz,zzz,zzz,zz9.99-") +
               "      DEBITOS PROGRAMADOS:    " + STRING(par_vllautom,"zz,zzz,zzz,zz9.99-") +
               "    EMPRESTIMOS A LIBERAR:    " + STRING(par_vlsdbloq,"zz,zzz,zzz,zz9.99-") +
               "DEPOSITOS TAA A CONFIRMAR:    " + STRING(par_vlblqtaa,"zz,zzz,zzz,zz9.99-") +
               "      EM CHEQUES DA PRACA:    " + STRING(par_vlsdblpr,"zz,zzz,zzz,zz9.99-") +
               " EM CHEQUES FORA DA PRACA:    " + STRING(par_vlsdblfp,"zz,zzz,zzz,zz9.99-") +
               "       EM CHEQUES SALARIO:    " + STRING(par_vlsdchsl,"zz,zzz,zzz,zz9.99-") +
               "                              ------------------"                           +
               "              SALDO TOTAL:    " + STRING(par_vlstotal,"zz,zzz,zzz,zz9.99-") +
               "                                                "                           +
               "        LIMITE DE CREDITO:    " + STRING(par_vllimcre,"zz,zzz,zzz,zz9.99-") +
               "                                                ".

IF  par_vldiscrd > 0 THEN
    par_tximpres = par_tximpres +
                   "     CREDITO PRE-APROVADO                       " 							+
                   "        LIMITE DISPONIVEL:    " + STRING(par_vldiscrd,"zz,zzz,zzz,zz9.99-") +
                   " *CREDITO SUJEITO A ALTERACAO ATE O FINAL DO DIA"                           +
                   "                                                ".

/* Saldo na magrugada */
IF   glb_dtmvtolt <> glb_dtmvtocd   THEN
     par_tximpres = par_tximpres + 
                    "                                                " +
                    "                                                " +
                    "* SALDO ANTES DA COMPENSACAO DO DIA " + STRING(glb_dtmvtolt,"99/99/9999") + " *" +
                    "***   S U J E I T O   A   A L T E R A C A O  ***".


IF  par_nmtitula[1] <> ""  THEN
    par_tximpres = par_tximpres +
                   "    SAC - Servico de Atendimento ao Cooperado   " +

                 FILL(" ", 14) + STRING(aux_nrtelsac, "x(20)") + FILL(" ", 14) +
    
                   "     Atendimento todos os dias das 6h as 22h    " +
                   "                                                " +
                   "                   OUVIDORIA                    " +
    
                 FILL(" ", 14) + STRING(aux_nrtelouv, "x(20)") + FILL(" ", 14) +               
        
                   "    Atendimento nos dias uteis das 8h as 17h    " +
                   "                                                " +
                   "            **  FIM DA IMPRESSAO  **            " +
                   "                                                " +
                   "                                                ".

RETURN "OK".

/* ............................................................................ */
