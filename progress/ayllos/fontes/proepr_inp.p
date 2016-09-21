/* .............................................................................

   Programa: fontes/proepr_inp.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Outubro/96.                         Ultima atualizacao: 18/08/2014
                                                                        
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Tratamento dos dados para emissao da NOTA PROMISSORIA.

   Alteracoes: 25/09/1997 - Alterado para emitir quantidade de promissorias
                            variavel (Edson).

               31/10/1997 - Tratar se o avalista e' menor de 18 (Odair)

               26/07/2000 - Tratar menores de 21 e nao de 18 (Odair)

               06/09/2000 - Tratar habilitacao de menores (Deborah).

               16/12/2002 - Tratar nome e documento do conjuge dos fiadores
                            (Deborah).
          
               08/01/2003 - Maioridade de 21 para 18 anos (Deborah). 

               08/09/2003 - Tratamento para Revisao Cadastral Fiadores(Julio).
                            
               16/06/2004 - Atualizar tabela de Avalistas Terceiros(Mirtes).

               13/08/2004 - Incluido campos cidade/uf/cep(Mirtes).

               26/01/2005 - Controle de avalistas nao cadastrados (Edson).
               
               24/02/2005 - Possibilitar desfazer as alteracoes dos avalistas
                            quando "END" ou "F4" (Evandro).

               29/08/2005 - Incluido o estado civil dos fiadores e o
                            cadastramento de Intervenientes Anuentes (Evandro).

               15/12/2005 - Acerto no campo Nro. Conta Aval 1 e Aval 2 (Ze).
               
               30/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
               
               12/09/2006 - Excluidas opcoes "TAB" (Diego).
               
               19/09/2006 - Alterado para nao criticar(585) quando 
                            interveniente anuente tiver menos de 18 anos e
                            for pessoa JURIDICA (Diego).
               
               27/03/2007 - Substituido para buscar dados de endereco do
                            avalista da estrutura crapenc (Elton).
                            
               18/05/2007 - Tratado para nao permitir CPF de Avalistas igual
                            ao do devedor (Diego).
                            
               13/07/2007 - Corrigido controle de digitacao do nro da conta
                            (Evandro).

               01/10/2007 - Conversao de rotina ver_cadastro para BO
                            (Sidnei/Precise)
                            
               22/01/2009 - Alteracao cdempres (Diego).

               13/07/2009 - Cadastro de pessoa fisica e juridica (Gabriel)
               
               06/09/2009 - Alterado campo cdgraupr da tabela crpsass para a 
                            crpsttl. Paulo - Precise.
                            
               10/12/2009 - Alterar inhabmen da ass para ttl (Guilherme).
               
               16/03/2010 - Corrigir erro de associado nao cadastrado
                            para o segundo avalista cooperado (Gabriel).
                            
               29/06/2010 - Adaptar para usar a BO de emprestimo (Gabriel).
               
               22/11/2010 - Arrumar problema de quantidade de promissorias
                            (Gabriel).  
                            
               11/01/2011 - Passar como parametro a conta na validacao
                            dos avalistas (Gabriel)
                           
               13/04/2011 - Alterações devido a CEP integrado. Campos
                            nrendere, complend e nrcxapst. (André - DB1)       
                            
               15/04/2011 - Acerto no CREATE tt-aval-crapbem
                            estava dando duplicates (Guilherme).
                            
               03/05/2011 - Bloqueio de campos ao sair de campo conta do
                            avalista. (André - DB1)        
                            
               30/06/2011 - Ajuste para validar avalista quando cooperado
                            (Gabriel).        
                            
               31/01/2013 - Aumentado format da conta do avalista. 
                            (David Kruger)
                            
               06/05/2013 - Fixar Qtd de impressoes de NP conforme
                            parametro da craptab (Lucas).
                            
               06/06/2014 - Adicionado tratamento para novos campos inpessoa e
                            dtnascto do avalista 1 e 2 (Daniel). 
                            
               18/08/2014 - Projeto Automatização de Consultas em Propostas
                            de Crédito (Jonata-RKAM).            
............................................................................. */

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0038tt.i }

{ includes/var_online.i    }
{ includes/var_proepr.i    }
{ includes/var_bens.i      }
{ includes/var_proposta.i  }


DEF INPUT PARAM par_nrdconta        AS INTE                         NO-UNDO.
DEF INPUT PARAM par_nrctremp        AS INTE                         NO-UNDO.
DEF INPUT PARAM par_qtpreemp        AS INTE                         NO-UNDO.
DEF INPUT PARAM TABLE FOR tt-itens-topico-rating.
DEF INPUT-OUTPUT PARAM par_qtpromis AS INTE                         NO-UNDO.
DEF INPUT-OUTPUT PARAM TABLE FOR tt-dados-avais.
DEF INPUT-OUTPUT PARAM TABLE FOR tt-aval-crapbem.
DEF INPUT-OUTPUT PARAM TABLE FOR tt-dados-analise.

FORM SPACE(1)
     tt-fiador.nrdconta COLUMN-LABEL "Conta/dv"   FORMAT "zzzz,zzz,9"
     tt-fiador.nrctremp COLUMN-LABEL "Contrato"
     tt-fiador.dtmvtolt COLUMN-LABEL "Data"
     tt-fiador.vlemprst COLUMN-LABEL "Valor"      FORMAT "z,zzz,zz9.99"
     tt-fiador.qtpreemp COLUMN-LABEL "Qtd"        FORMAT "zz9"
     tt-fiador.vlpreemp COLUMN-LABEL "Vlr Prest"  FORMAT "zzz,zz9.99"
     tt-fiador.vlsdeved COLUMN-LABEL "Saldo"      FORMAT "z,zzz,zz9.99"
     SPACE(1)
     WITH CENTERED WIDTH 76 ROW 8 OVERLAY 9 DOWN FRAME f_emprestimos
          TITLE aux_titelavl.

/* Inclusão de CEP integrado. (André - DB1) */
ON GO, LEAVE OF tt-dados-avais.nrcepend IN FRAME f_promissoria DO:
    IF  INPUT tt-dados-avais.nrcepend = 0  THEN
        RUN Limpa_Endereco.
END.

ON RETURN OF tt-dados-avais.nrcepend IN FRAME f_promissoria DO:

    HIDE MESSAGE NO-PAUSE.

    ASSIGN INPUT tt-dados-avais.nrcepend.

    IF  tt-dados-avais.nrcepend <> 0  THEN 
        DO:
            RUN fontes/zoom_endereco.p (INPUT tt-dados-avais.nrcepend,
                                        OUTPUT TABLE tt-endereco).
    
            FIND FIRST tt-endereco NO-LOCK NO-ERROR.
    
            IF  AVAIL tt-endereco THEN
                DO:
                    ASSIGN 
                       tt-dados-avais.nrcepend = tt-endereco.nrcepend 
                       tt-dados-avais.dsendre1 = tt-endereco.dsendere 
                       tt-dados-avais.dsendre2 = tt-endereco.nmbairro 
                       tt-dados-avais.nmcidade = tt-endereco.nmcidade 
                       tt-dados-avais.cdufresd = tt-endereco.cdufende.
                END.
            ELSE 
                DO:
                    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                        RETURN NO-APPLY.
                        
                    MESSAGE "CEP nao cadastrado.".
                    RUN Limpa_Endereco.
                    RETURN NO-APPLY.
                END.
        END.
    ELSE
        RUN Limpa_Endereco.

    DISPLAY tt-dados-avais.nrcepend     
            tt-dados-avais.dsendre1
            tt-dados-avais.dsendre2
            tt-dados-avais.nmcidade
            tt-dados-avais.cdufresd WITH FRAME f_promissoria.

    NEXT-PROMPT tt-dados-avais.nrendere WITH FRAME f_promissoria.

END.

ON GO, LEAVE OF tt-dados-avais.nrctaava DO:

   /* Se conta e cpf vazios entao Limpar campos */ 
   IF   INPUT tt-dados-avais.nrctaava = 0   AND
        INPUT tt-dados-avais.nrcpfcgc = 0   THEN
        DO:
            RUN limpa_campos.         
        END.
END.

/* Zerar endividamento e renda quando cooperado */
ON GO, RETURN OF tt-dados-avais.nrctaava DO:

   HIDE MESSAGE NO-PAUSE.

   /* Trazer dados do cooperado */
   IF   INPUT tt-dados-avais.nrctaava > 0   THEN
        DO:
            RUN lista_dados_aval1 (INPUT INPUT tt-dados-avais.nrctaava,
                                   INPUT 0).
                
            IF   RETURN-VALUE <> "OK"    THEN
                 RETURN NO-APPLY.
        END.
END.   
   

ON GO, LEAVE OF tt-dados-avais.nrcpfcgc DO:

   /* Se conta e cpf vazios entao Limpar campos */
   IF   INPUT tt-dados-avais.nrctaava = 0   AND
        INPUT tt-dados-avais.nrcpfcgc = 0   THEN
        DO:
            RUN limpa_campos.
        END.
    
END.

/* Puxar dados do primeiro aval terceiro */
ON GO, RETURN OF tt-dados-avais.nrcpfcgc DO:

   HIDE MESSAGE NO-PAUSE.

   IF   INPUT tt-dados-avais.nrcpfcgc > 0            AND
        INPUT tt-dados-avais.nrctaava = 0           THEN
        DO:             
            RUN lista_dados_aval1 
                     (INPUT 0,
                      INPUT INPUT tt-dados-avais.nrcpfcgc).
         
            IF   RETURN-VALUE <> "OK"    THEN
                 RETURN NO-APPLY.

        END.
END.


/* Nao editar rendimentos quando cooperado */
ON ANY-KEY OF tt-dados-avais.vledvmto, tt-dados-avais.vlrenmes DO:

   IF   CAN-DO("GO,RETURN,TAB,BACK-TAB,CURSOR-DOWN,CURSOR-UP,END-ERROR," +
               "CURSOR-LEFT,CURSOR-RIGHT",KEYFUNCTION(LASTKEY))  THEN
        RETURN.

   IF   INPUT tt-dados-avais.nrctaava <> 0   THEN
        RETURN NO-APPLY.

END.

ASSIGN aux_nrdconta = 0
       aux_nrcpfcgc = 0
       tel_qtpromis = par_qtpromis.

AVALISTA:    
DO aux_contador = 1 TO 2:

    HIDE FRAME f_promissoria.
  
    FIND tt-dados-avais WHERE tt-dados-avais.idavalis = aux_contador 
                              EXCLUSIVE-LOCK NO-ERROR.
  
    IF  NOT AVAIL tt-dados-avais   THEN
        DO:
            CREATE tt-dados-avais.
            ASSIGN tt-dados-avais.idavalis = aux_contador.
        END.
  
    DISPLAY tt-dados-avais.nrcepend  tt-dados-avais.dsendre1
            tt-dados-avais.dsendre2  tt-dados-avais.nmcidade 
            tt-dados-avais.cdufresd  tt-dados-avais.nmdavali                       
            tt-dados-avais.nrcpfcgc  tt-dados-avais.tpdocava     
            tt-dados-avais.nrdocava  tt-dados-avais.dsnacion   
            tt-dados-avais.nmconjug  tt-dados-avais.nrcpfcjg    
            tt-dados-avais.tpdoccjg  tt-dados-avais.nrdoccjg
            tt-dados-avais.nrcepend  tt-dados-avais.nrendere  
            tt-dados-avais.complend  tt-dados-avais.nrcxapst
            tt-dados-avais.nrfonres  tt-dados-avais.dsdemail 
            tt-dados-avais.vledvmto  tt-dados-avais.vlrenmes
            tt-dados-avais.inpessoa  tt-dados-avais.dtnascto
            tel_qtpromis
            WITH FRAME f_promissoria.
  
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
  
        UPDATE tt-dados-avais.nrctaava WITH FRAME f_promissoria

               TITLE COLOR NORMAL " Dados dos Avalistas/Fiadores (" +
                                      STRING(aux_contador,"9") + ") ".
        
        IF   tt-dados-avais.nrctaava <> 0   THEN
             DO:
                 RUN valida_aval.
             
                 IF   RETURN-VALUE <> "OK"   THEN
                      NEXT.
             END.
        
        LEAVE.
    END.

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
        DO:
            HIDE FRAME f_promissoria.
            RETURN "NOK".
        END.

    IF  tt-dados-avais.nrctaava = 0  THEN /* Conta nao prenchida */
        DO:
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
  
                UPDATE tt-dados-avais.nmdavali                       
                       tt-dados-avais.nrcpfcgc  tt-dados-avais.tpdocava     
                       tt-dados-avais.nrdocava  tt-dados-avais.dsnacion  
                       tt-dados-avais.inpessoa  tt-dados-avais.dtnascto
                       tt-dados-avais.nmconjug  tt-dados-avais.nrcpfcjg    
                       tt-dados-avais.tpdoccjg  tt-dados-avais.nrdoccjg
                       tt-dados-avais.nrcepend  tt-dados-avais.nrendere  
                       tt-dados-avais.complend  tt-dados-avais.nrcxapst
                       tt-dados-avais.nrfonres  tt-dados-avais.dsdemail 
                       tt-dados-avais.vledvmto  tt-dados-avais.vlrenmes
                       WITH FRAME f_promissoria
       
                       TITLE COLOR NORMAL " Dados dos Avalistas/Fiadores (" +
                                   STRING(aux_contador,"9") + ") "          
                EDITING:
        
                    READKEY.
                    
                    ON LEAVE, RETURN OF tt-dados-avais.inpessoa IN FRAME f_promissoria DO:

                       ASSIGN INPUT tt-dados-avais.inpessoa.
                      
                       IF tt-dados-avais.inpessoa = 1   THEN
                          aux_dspessoa = "- FISICA".
                       ELSE
                          IF tt-dados-avais.inpessoa = 2   THEN
                             aux_dspessoa = "- JURIDICA".
                          ELSE
                             aux_dspessoa = "".
                    
                       DISPLAY aux_dspessoa WITH FRAME f_promissoria.
                    
                    END.
                    

                    /* Inclusão de CEP integrado. (André - DB1) */
                    IF  FRAME-FIELD = "nrcepend"  THEN
                        DO:
                            IF  LASTKEY = KEYCODE("F7") THEN
                                DO:
                                
                                    RUN fontes/zoom_endereco.p 
                                             ( INPUT 0,
                                              OUTPUT TABLE tt-endereco).
                    
                                    FIND FIRST tt-endereco NO-LOCK NO-ERROR.
                    
                                    IF  AVAIL tt-endereco THEN
                                        ASSIGN 
                                         tt-dados-avais.nrcepend = 
                                                           tt-endereco.nrcepend
                                         tt-dados-avais.dsendre1 = 
                                                           tt-endereco.dsendere
                                         tt-dados-avais.dsendre2 = 
                                                           tt-endereco.nmbairro
                                         tt-dados-avais.nmcidade = 
                                                           tt-endereco.nmcidade
                                         tt-dados-avais.cdufresd = 
                                                           tt-endereco.cdufende.
                                                      
                                    DISPLAY tt-dados-avais.nrcepend    
                                            tt-dados-avais.dsendre1
                                            tt-dados-avais.dsendre2
                                            tt-dados-avais.nmcidade 
                                            tt-dados-avais.cdufresd 
                                            WITH FRAME f_promissoria.
                    
                                    IF  KEYFUNCTION(LASTKEY) <> "END-ERROR" THEN
                                        NEXT-PROMPT tt-dados-avais.nrendere 
                                                    WITH FRAME f_promissoria.
                                END.
                            ELSE
                                APPLY LASTKEY.
                        END.
                    ELSE
                    IF  FRAME-FIELD = "dsnacion"   THEN
                        DO:
                            IF  LASTKEY = KEYCODE("F7") THEN
                                DO:
                                    RUN fontes/nacion.p.
                               
                                    IF  shr_dsnacion <> "" THEN
                                        DO:
                                           tt-dados-avais.dsnacion = 
                                                                shr_dsnacion.
                                       
                                           DISPLAY tt-dados-avais.dsnacion
                                                    WITH FRAME f_promissoria.
                                        END.  
                                END.       
                            ELSE
                                 APPLY LASTKEY.
                        END.
                    ELSE
                        APPLY LASTKEY.
                 
                    IF  GO-PENDING    THEN
                        DO:
                            RUN valida_aval.
                 
                            IF  RETURN-VALUE <> "OK" THEN
                                DO:
                                    { sistema/generico/includes/foco_campo.i
                                                  &VAR-GERAL=SIM
                                                  &NOME-FRAME="f_promissoria"
                                                  &NOME-CAMPO=par_nmdcampo } 
                                
                                END.
                                   
                        END.
                 
                END.  /*  Fim do EDITING  */
                                       
                IF  tt-dados-avais.nrctaava = 0  AND
                    tt-dados-avais.nrcpfcgc = 0  THEN
                    DO:
                        DELETE tt-dados-avais.
                        
                        IF   NOT CAN-FIND (tt-dados-avais WHERE 
                             tt-dados-avais.idavalis = aux_contador + 1) THEN
                             LEAVE AVALISTA. 
                
                        NEXT AVALISTA.
                    END.
                
                /* Salvar dados do 1. aval soh para 
                   validar se prencher os dois aval */
                IF  aux_contador = 1  THEN
                    ASSIGN aux_nrcpfcgc = tt-dados-avais.nrcpfcgc.

                LEAVE.
          
            END.  /* Fim DO WHILE TRUE  */

        END.
    ELSE
        DO:
            /* Salvar dados do 1. aval soh para  
               validar se prencher os dois aval */
            IF  aux_contador = 1  THEN
                ASSIGN aux_nrdconta = tt-dados-avais.nrctaava.

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                PAUSE MESSAGE
                     "Pressione algo para continuar - <F4>/<END> para voltar.".
                LEAVE.
            END.
        END.

  
    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
        DO:
            HIDE FRAME f_promissoria.
            RETURN "NOK".
        END.
  
    RUN fontes/proposta_bens.p (INPUT glb_cdcooper,
                                INPUT tt-dados-avais.nrctaava,
                                INPUT tt-dados-avais.nrcpfcgc,
                                INPUT-OUTPUT TABLE tt-aval-crapbem).

    IF   par_nrctremp <> 0   THEN
         DO:    
             /* Orgaos de protecao ao credito */
             RUN fontes/proepr_org.p (INPUT par_nrdconta,
                                      INPUT par_nrctremp,
                                      INPUT aux_contador,
                                      INPUT tt-dados-avais.inpessoa,
                                      INPUT tt-dados-avais.nrctaava,
                                      INPUT tt-dados-avais.nrcpfcgc,
                                      INPUT TABLE tt-itens-topico-rating,
                                      INPUT-OUTPUT TABLE tt-dados-analise).

             IF   RETURN-VALUE <> "OK"   THEN
                  RETURN "NOK".
         END.

END.  /*  Fim Avalistas  */


HIDE FRAME f_promissoria.

RETURN "OK".


PROCEDURE lista_dados_aval1:
    
    DEF INPUT PARAM par_nrctaava AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nrcpfcgc AS DECI                               NO-UNDO.

    DEF VAR par_nmprimtl         AS CHAR                               NO-UNDO.
    DEF VAR aux_flgretor         AS LOGI                               NO-UNDO.

    RUN sistema/generico/procedures/b1wgen0002.p PERSISTENT SET h-b1wgen0002.

    RUN verifica-traz-avalista IN h-b1wgen0002
                          (INPUT glb_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT glb_cdoperad,
                           INPUT glb_nmdatela,
                           INPUT 1, /* Ayllos*/
                           INPUT par_nrdconta,
                           INPUT par_nrctaava,
                           INPUT par_nrcpfcgc,
                           INPUT 1, /* Tit */
                           INPUT glb_dtmvtolt,
                           INPUT glb_dtmvtopr,
                           OUTPUT TABLE tt-erro,
                           OUTPUT TABLE bb-dados-avais,
                           OUTPUT TABLE tt-crapbem,
                           OUTPUT TABLE tt-fiador,
                           OUTPUT par_nmprimtl).

    DELETE PROCEDURE h-b1wgen0002.

    IF  RETURN-VALUE <> "OK"   THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  AVAIL tt-erro   THEN
                MESSAGE tt-erro.dscritic.
            ELSE
                MESSAGE "Erro na busca dos dados do avalista.".

            RETURN "NOK".

        END.

    CLEAR FRAME f_emprestimos ALL.
                
    ASSIGN  aux_regexist = FALSE
            aux_qtlintel = 0
            aux_titelavl = "Fiador = " + STRING(par_nrctaava, ">>>>,>>>,>") +
                          " - " + (par_nmprimtl).
   
    FOR EACH tt-fiador NO-LOCK:
                         
        ASSIGN aux_regexist = TRUE
               aux_qtlintel = aux_qtlintel + 1.

        IF  aux_qtlintel = 1   THEN
            IF  aux_flgretor   THEN
                DO:
                    PAUSE MESSAGE
                       "Tecle <Entra> para continuar ou <Fim> para encerrar".
                    CLEAR FRAME f_todos ALL NO-PAUSE.
                END.
        ELSE
            aux_flgretor = TRUE.
                    
        DISPLAY tt-fiador.nrdconta  tt-fiador.nrctremp
                tt-fiador.dtmvtolt  tt-fiador.vlemprst
                tt-fiador.qtpreemp  tt-fiador.vlpreemp
                tt-fiador.vlsdeved  
                WITH FRAME f_emprestimos.
        
        IF  aux_qtlintel = 9   THEN
            aux_qtlintel = 0.
        ELSE
            DOWN WITH FRAME f_emprestimos.

    END.  /*  Fim do FOR EACH  */
    
    IF  aux_regexist   THEN
        DO:
            RUN fontes/confirma.p (INPUT "Confirma fiador nestas condicoes?",
                                   OUTPUT aux_confirma).

            HIDE FRAME f_emprestimos.

            IF  aux_confirma <> "S"   THEN
                RETURN "NOK".
        END.

     /* Limpar os bens */
    IF  par_nrctaava > 0   THEN
        FOR EACH tt-aval-crapbem WHERE tt-aval-crapbem.nrdconta = par_nrctaava:          
           DELETE tt-aval-crapbem.
        END.
    ELSE
    IF  par_nrcpfcgc > 0   THEN
        FOR EACH tt-aval-crapbem WHERE tt-aval-crapbem.nrcpfcgc = par_nrcpfcgc:
            DELETE tt-aval-crapbem.
        END.

    ASSIGN aux_idseqbem = 1.

    /* Salvar novos bens */
    FOR EACH tt-crapbem NO-LOCK:

        /* Pegar indice soh para nao dar erro na chave unica */
        FOR EACH tt-aval-crapbem WHERE tt-aval-crapbem.nrdconta = 0 NO-LOCK
                                       BREAK BY tt-aval-crapbem.idseqbem:

            aux_idseqbem = tt-aval-crapbem.idseqbem + 1.

        END.
    
        CREATE tt-aval-crapbem.
        BUFFER-COPY tt-crapbem TO tt-aval-crapbem
        ASSIGN tt-aval-crapbem.nrdconta = par_nrctaava
               tt-aval-crapbem.nrcpfcgc = par_nrcpfcgc.

        IF  par_nrctaava = 0  THEN
            ASSIGN tt-aval-crapbem.idseqbem = aux_idseqbem.    
    END.

    FIND FIRST bb-dados-avais NO-LOCK NO-ERROR.

    IF  AVAIL bb-dados-avais   THEN 
        DO:
            BUFFER-COPY bb-dados-avais EXCEPT idavalis TO tt-dados-avais.

            IF tt-dados-avais.inpessoa = 1   THEN
                  aux_dspessoa = "- FISICA".
               ELSE
                  IF tt-dados-avais.inpessoa = 2   THEN
                     aux_dspessoa = "- JURIDICA".
                  ELSE
                     aux_dspessoa = "".

            DISPLAY tt-dados-avais.nrctaava  tt-dados-avais.nmdavali 
                    tt-dados-avais.tpdocava  tt-dados-avais.nrdocava 
                    tt-dados-avais.dsnacion  tt-dados-avais.nmconjug 
                    tt-dados-avais.nrcpfcjg  tt-dados-avais.tpdoccjg 
                    tt-dados-avais.nrdoccjg  tt-dados-avais.dsendre1 
                    tt-dados-avais.dsendre2  tt-dados-avais.nrfonres
                    tt-dados-avais.dsdemail  tt-dados-avais.nmcidade 
                    tt-dados-avais.cdufresd  tt-dados-avais.nrcepend 
                    tt-dados-avais.vledvmto  tt-dados-avais.vlrenmes 
                    tt-dados-avais.nrcpfcgc  tt-dados-avais.nrendere
                    tt-dados-avais.complend  tt-dados-avais.nrcxapst 
                    tt-dados-avais.inpessoa  tt-dados-avais.dtnascto
                    aux_dspessoa
                    WITH FRAME f_promissoria.     
        END.
    ELSE
        DO:
            MESSAGE "Nenhum avalista terceiro foi encontrado.".  
        END.

    RETURN "OK".

END PROCEDURE.


PROCEDURE valida_aval:
    
    /* Dar ASSIGN de todos os campos que precisam ser passados com parametro */
    DO WITH FRAME f_promissoria:
         
        ASSIGN tel_qtpromis
               tt-dados-avais.nrctaava
               tt-dados-avais.nmdavali
               tt-dados-avais.nrcpfcgc
               tt-dados-avais.nrcpfcjg
               tt-dados-avais.dsendre1
               tt-dados-avais.cdufresd
               tt-dados-avais.nrcepend
               tt-dados-avais.inpessoa
               tt-dados-avais.dtnascto.
    END.

    IF tt-dados-avais.nrcpfcgc <> 0 THEN DO:
        IF tt-dados-avais.inpessoa <> 1 AND 
           tt-dados-avais.inpessoa <> 2 THEN DO:

            aux_dscritic = "Tipo Natureza deve ser Informada.".
            par_nmdcampo = "tt-dados-avais.inpessoa".

            MESSAGE aux_dscritic.
                
            RETURN "NOK".
            
        END.
       
        IF tt-dados-avais.inpessoa = 1 AND
           tt-dados-avais.dtnascto = ? THEN DO:

            aux_dscritic = "Data de Nascimento deve ser Informada.".
            par_nmdcampo = "tt-dados-avais.dtnascto".

            MESSAGE aux_dscritic.
                
            RETURN "NOK".
        END.
    END.
  
    RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT SET h-b1wgen0024.
                   
    RUN valida-avalistas IN h-b1wgen0024 (INPUT glb_cdcooper,
                                          INPUT 0,
                                          INPUT 0,
                                          INPUT par_nrdconta,
                                          INPUT tel_qtpromis,
                                          INPUT par_qtpreemp,
                                          INPUT aux_nrdconta,
                                          INPUT aux_nrcpfcgc,
                                          INPUT aux_contador,
                                          INPUT tt-dados-avais.nrctaava,
                                          INPUT tt-dados-avais.nmdavali,
                                          INPUT tt-dados-avais.nrcpfcgc,
                                          INPUT tt-dados-avais.nrcpfcjg,
                                          INPUT tt-dados-avais.dsendre1,
                                          INPUT tt-dados-avais.cdufresd,
                                          INPUT tt-dados-avais.nrcepend,
                                          INPUT tt-dados-avais.inpessoa,
                                         OUTPUT par_nmdcampo,
                                         OUTPUT TABLE tt-erro).
    DELETE PROCEDURE h-b1wgen0024.
               
    IF   RETURN-VALUE <> "OK"   THEN
         DO: 
             FIND FIRST tt-erro NO-LOCK NO-ERROR.
             
             IF    AVAIL tt-erro   THEN
                   MESSAGE tt-erro.dscritic.
             ELSE
                   MESSAGE "Erro na validaçao dos avalistas".
                
             RETURN "NOK".
         END.        
  
    RETURN "OK".

END PROCEDURE.


PROCEDURE limpa_campos:

    ASSIGN tt-dados-avais.nrctaava = 0
           tt-dados-avais.nmdavali = "" tt-dados-avais.tpdocava = ""  
           tt-dados-avais.nrdocava = "" tt-dados-avais.dsnacion = "" 
           tt-dados-avais.nmconjug = "" tt-dados-avais.nrcpfcjg = 0 
           tt-dados-avais.tpdoccjg = "" tt-dados-avais.nrdoccjg = ""
           tt-dados-avais.dsendre1 = "" tt-dados-avais.dsendre2 = ""
           tt-dados-avais.nrfonres = "" tt-dados-avais.dsdemail = ""    
           tt-dados-avais.nmcidade = "" tt-dados-avais.cdufresd = ""
           tt-dados-avais.nrcepend = 0  tt-dados-avais.vledvmto = 0
           tt-dados-avais.vlrenmes = 0  tt-dados-avais.nrcpfcgc = 0
           tt-dados-avais.nrendere = 0  tt-dados-avais.complend = ""
           tt-dados-avais.nrcxapst = 0
           tt-dados-avais.inpessoa = 0 
           tt-dados-avais.dtnascto = ?
           aux_dspessoa = "".

    DISPLAY tt-dados-avais.nrctaava  tt-dados-avais.nmdavali 
            tt-dados-avais.tpdocava  tt-dados-avais.nrdocava 
            tt-dados-avais.dsnacion  tt-dados-avais.nmconjug 
            tt-dados-avais.nrcpfcjg  tt-dados-avais.tpdoccjg 
            tt-dados-avais.nrdoccjg  tt-dados-avais.dsendre1 
            tt-dados-avais.dsendre2  tt-dados-avais.nrfonres
            tt-dados-avais.dsdemail  tt-dados-avais.nmcidade 
            tt-dados-avais.cdufresd  tt-dados-avais.nrcepend 
            tt-dados-avais.vledvmto  tt-dados-avais.vlrenmes 
            tt-dados-avais.nrcpfcgc  tt-dados-avais.nrendere
            tt-dados-avais.complend  tt-dados-avais.nrcxapst  
            aux_dspessoa
                                     WITH FRAME f_promissoria.

END PROCEDURE.

PROCEDURE Limpa_Endereco:

    ASSIGN tt-dados-avais.nrcepend  = 0  
           tt-dados-avais.dsendre1 = ""  
           tt-dados-avais.dsendre2 = "" 
           tt-dados-avais.nmcidade  = ""  
           tt-dados-avais.cdufresd  = ""
           tt-dados-avais.nrendere  = 0            
           tt-dados-avais.nrcxapst  = 0
           tt-dados-avais.complend  = "".

    DISPLAY tt-dados-avais.nrcepend
            tt-dados-avais.dsendre1
            tt-dados-avais.dsendre2
            tt-dados-avais.nmcidade 
            tt-dados-avais.cdufresd 
            tt-dados-avais.nrendere 
            tt-dados-avais.nrcxapst  
            tt-dados-avais.complend WITH FRAME f_promissoria.
END PROCEDURE.

/* .......................................................................... */


