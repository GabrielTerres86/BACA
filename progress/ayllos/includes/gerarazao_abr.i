/* ..........................................................................

   Programa: Includes/gerarazao_abr.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio
   Data    : Outubro/2003.                    Ultima atualizacao: 06/11/2007 

   Dados referentes ao programa:

   Frequencia: Sempre que executado os programas crps(355, 356, 357, 358).p.
   Objetivo  : Imprimir o termo de abertura do razao auxiliar.

                {1} -> Numero da Pagina
                {2} -> Titulo do termo (abertura ou encerramento)

   Alteracoes : 14/11/2003 - Campo CRC contador foi alterado para STRING (Julio)
   
                28/09/2005 - Modificado FIND FIRST para FIND na tabela
                             crapcop.cdcooper = glb_cdcooper (Diego).
                
                21/11/2005 - Alterar Razao para Diario(Mirtes)
                
                06/11/2007 - Acerto no numero de pagina, estouro de campo (Ze).
............................................................................. */

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop  THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> log/proc_batch.log").
         QUIT.
     END.

PUT STREAM str_1 aux_novapagi SKIP.

rel_cablinha = aux_pulalinh + FILL(" ", 65 - INT(LENGTH(rel_nmcooper) / 2)) +
                              STRING(rel_nmcooper, "x(131)").
                              
PUT STREAM str_1 rel_cablinha FORMAT "x(132)" SKIP.

PUT STREAM str_1 aux_novalinh + STRING(FILL(" ", 118) + "PAGINA: " + 
                                       STRING({1}, "99999"), "x(131)")
                                       FORMAT "x(132)"
                                       SKIP.

rel_cablinha = "DIARIO AUXILIAR "+ rel_tpdrazao + " Nr. " + 
               TRIM(STRING(rel_nrdlivro, "zzz9")).

PUT STREAM str_1 aux_novalinh + 
                 STRING(FILL(" ", 65 - INT(LENGTH(rel_cablinha) / 2)) +
                 rel_cablinha, "x(131)") FORMAT "x(132)" 
                 SKIP.

PUT STREAM str_1 aux_pulalinh + FILL(" ", 65 - INT(LENGTH("{2}") / 2)) + "{2}"
                                FORMAT "x(132)" SKIP.

PUT STREAM str_1 aux_pulalinh SKIP.

rel_cablinha = "Contem este livro mensal " + 
               TRIM(STRING(rel_contapag, "zzzz9")) + " paginas, " +
               "numeradas eletronicamente e seguidamente do Nr. 1 ao Nr. " +
               TRIM(STRING(rel_contapag, "zzzz9")) + " e ". 

IF   INT({1}) = 1 THEN
     rel_cablinha = rel_cablinha + "servira".
ELSE
     rel_cablinha = rel_cablinha + "serviu".
     
rel_cablinha = rel_cablinha + " para os lancamentos das operacoes " +
               "proprias do estabelecimento do contribuinte abaixo descrito:".
               
RUN fontes/quebra_str.p (INPUT rel_cablinha, 
                         INPUT 80,
                         INPUT 80,
                         INPUT 80,
                         INPUT 80,
                         OUTPUT rel_txttermo[1],
                         OUTPUT rel_txttermo[2], 
                         OUTPUT rel_txttermo[3],
                         OUTPUT rel_txttermo[4]).

PUT STREAM str_1 aux_pulalinh + FILL(" ", 25) + rel_txttermo[1] 
                                FORMAT "x(132)" SKIP.
PUT STREAM str_1 aux_novalinh + FILL(" ", 25) + rel_txttermo[2] 
                                FORMAT "x(132)" SKIP.
PUT STREAM str_1 aux_novalinh + FILL(" ", 25) + rel_txttermo[3] 
                                FORMAT "x(132)" SKIP.
PUT STREAM str_1 aux_novalinh + FILL(" ", 25) + rel_txttermo[4] 
                                FORMAT "x(132)" SKIP.

PUT STREAM str_1 aux_pulalinh + FILL(" ", 25) + 
                                "Nome da empresa    : " + rel_nmcooper
                                FORMAT "x(132)" SKIP.

PUT STREAM str_1 aux_pulalinh + FILL(" ", 25) + 
                                "Endereco           : " + crapcop.dsendcop
                                FORMAT "x(132)" SKIP.
                                
PUT STREAM str_1 aux_pulalinh + FILL(" ", 25) + 
                                "Cidade             : " + crapcop.nmcidade
                                FORMAT "x(132)" SKIP.
                                
PUT STREAM str_1 aux_pulalinh + FILL(" ", 25) + 
                                "Bairro             : " + crapcop.nmbairro
                                FORMAT "x(132)" SKIP.
                                
PUT STREAM str_1 aux_pulalinh + FILL(" ", 25) + 
                                "Complemento        : " + crapcop.dscomple
                                FORMAT "x(132)" SKIP.

PUT STREAM str_1 aux_pulalinh + FILL(" ", 25) + 
                                "Estado             : " + crapcop.cdufdcop
                                FORMAT "x(132)" SKIP.

PUT STREAM str_1 aux_pulalinh + FILL(" ", 25) + 
                                "CEP                : " +
                                STRING(STRING(crapcop.nrcepend, "99999999"),
                                              "xx.xxx-xxx")
                                FORMAT "x(132)" SKIP.

PUT STREAM str_1 aux_pulalinh + FILL(" ", 25) + 
                              "Registro na Junta  : " + 
                               TRIM(STRING(crapcop.nrrjunta, "zzzzz,zzzzzz,9"))
                               FORMAT "x(132)" SKIP.
                                
PUT STREAM str_1 aux_pulalinh + FILL(" ", 25) + 
                                "Data do Registro   : " + 
                                STRING(crapcop.dtrjunta, "99/99/9999")
                                FORMAT "x(132)" SKIP.
                                
PUT STREAM str_1 aux_pulalinh + FILL(" ", 25) + 
                                "CNPJ               : " + 
                                STRING(STRING(crapcop.nrdocnpj, 
                                       "99999999999999"), "xx.xxx.xxx/xxxx-xx")
                                FORMAT "x(132)" SKIP.

IF   crapcop.nrinsest = 0   THEN
     PUT STREAM str_1 aux_pulalinh + FILL(" ", 25) + 
                                     "Inscricao Estadual : ISENTO" 
                                     FORMAT "x(132)" SKIP.
ELSE
     PUT STREAM str_1 aux_pulalinh + FILL(" ", 25) + 
                                     "Inscricao Estadual : "
                                     STRING(crapcop.nrinsest, "zzz,zzz,zz9") 
                                     FORMAT "x(132)" SKIP.
                                
PUT STREAM str_1 aux_pulalinh + FILL(" ", 25) + 
                                "Inscricao Municipal: " +                      
                                TRIM(STRING(STRING(crapcop.nrinsmun,"zzzzzz9"),
                                                   "xxx.xxx-x"))
                                FORMAT "x(132)" SKIP.

PUT STREAM str_1 aux_pulalinh SKIP.
                                 
PUT STREAM str_1 aux_pulalinh + FILL(" ", 25) + 
                                SUBSTR(CAPS(crapcop.nmcidade), 1, 1) + 
                                SUBSTR(LC(crapcop.nmcidade), 2) + ", " + 
                                STRING(DAY(rel_dtterabr), "99") +
                                " de " + aux_nmmesano[MONTH(rel_dtterabr)] +
                                " de " + 
                                STRING(YEAR(rel_dtterabr), "9999") + "."
                                FORMAT "x(132)" SKIP.

PUT STREAM str_1 aux_pulalinh SKIP.

PUT STREAM str_1 aux_pulalinh + FILL(" ", 25) + 
                                "Titular da Empresa : " + crapcop.nmtitcop    
                                FORMAT "x(132)" SKIP.

PUT STREAM str_1 aux_novalinh + FILL(" ", 25) + 
                                "CPF                : " + 
                                STRING(STRING(crapcop.nrcpftit,"99999999999"),
                                              "xxx.xxx.xxx-xx")
                                FORMAT "x(132)" SKIP.
                                            
PUT STREAM str_1 aux_pulalinh SKIP.

PUT STREAM str_1 aux_pulalinh SKIP.

PUT STREAM str_1 aux_pulalinh + FILL(" ", 25) + 
                                "Contador Responsavel: " + crapcop.nmctrcop    
                                FORMAT "x(132)" SKIP.

PUT STREAM str_1 aux_novalinh + FILL(" ", 25) + 
                                "CPF                 : " + 
                                STRING(STRING(crapcop.nrcpfctr,"99999999999"),
                                              "xxx.xxx.xxx-xx")
                                FORMAT "x(132)" SKIP.

PUT STREAM str_1 aux_novalinh + FILL(" ", 25) + 
                                "CRC                 : " + crapcop.nrcrcctr
                                FORMAT "x(132)" SKIP.

/* .......................................................................... */
