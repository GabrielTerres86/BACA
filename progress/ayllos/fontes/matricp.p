/* .............................................................................

   Programa: Fontes/matric.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Abril/2006                     Ultima atualizacao: 05/10/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela MATRIC.

   Alteracoes: 05/09/2006 - Criticar digito e conta nao cadastrada (Evandro).
   
               29/11/2006 - Criticar qdo tipo de conta for Individual e tiver
                            mais de um titular (Ze).
                            
               19/03/2008 - Opcao <> 'C' somente se inproces = 1 (Guilherme).
               
               26/02/2009 - Substituir a leitura da tabela craptab pelo 
                            ver_ctace.p para informacoes de conta convenio
                            (Sidnei - Precise IT)
                            
               07/06/2010 - Adaptar para uso de BO (Jose Luis, DB1)
               
               05/10/2015 - Adicionado nova opção "J" para alteração apenas do cpf/cnpj e 
                             removido a possibilidade de alteração pela opção "X", conforme 
                             solicitado no chamado 321572 (Kelvin).             
                            
............................................................................. */

{ includes/var_online.i }
{ includes/var_matric.i }

DEFINE VARIABLE h-b1wgen0060 AS HANDLE                                NO-UNDO.
DEFINE VARIABLE aux_lscontas AS CHAR                                  NO-UNDO.

ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0.

IF  NOT VALID-HANDLE(h-b1wgen0060) THEN
    RUN sistema/generico/procedures/b1wgen0060.p 
        PERSISTENT SET h-b1wgen0060.

/*  Le tabela com as contas convencio do Banco do Brasil  */
IF  NOT DYNAMIC-FUNCTION("BuscaCtaCe" IN h-b1wgen0060,
                         INPUT glb_cdcooper,
                         INPUT 0,
                        OUTPUT aux_lscontas,
                        OUTPUT glb_dscritic) OR aux_lscontas = "" THEN 
    DO:
       DELETE OBJECT h-b1wgen0060.
       BELL.
       MESSAGE glb_dscritic.
       RETURN.
    END.

IF  VALID-HANDLE(h-b1wgen0060) THEN
    DELETE OBJECT h-b1wgen0060.

RUN fontes/inicia.p. 

DO WHILE TRUE:

    DISPLAY glb_cddopcao WITH FRAME f_matric.
    NEXT-PROMPT tel_nrdconta WITH FRAME f_matric.

    ASSIGN glb_nmrotina = "".
    
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
       UPDATE glb_cddopcao tel_nrdconta WITH FRAME f_matric
       EDITING:
           READKEY.
           HIDE MESSAGE NO-PAUSE.

           APPLY LASTKEY.
       END.
       
       ASSIGN aux_nrdconta = INPUT FRAME f_matric tel_nrdconta
              glb_nrcalcul = INPUT FRAME f_matric tel_nrdconta.

       LEAVE.
    END.
    
    IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
         DO:
             RUN fontes/novatela.p.
             IF   CAPS(glb_nmdatela) <> "MATRIC"   THEN
                  DO:
                      HIDE FRAME f_matric.
                      RETURN.
                  END.
             ELSE
                  NEXT.
         END.

    glb_cddopcao = INPUT FRAME f_matric glb_cddopcao.
    
    IF   aux_cddopcao <> glb_cddopcao   THEN
         DO:
             { includes/acesso.i }
             aux_cddopcao = glb_cddopcao.
         END.

    CASE glb_cddopcao:
        WHEN "A" THEN RUN fontes/matrica.p.
        WHEN "C" THEN RUN fontes/matricc.p.
        WHEN "I" THEN RUN fontes/matrici.p.
        WHEN "X" THEN RUN fontes/matricx.p.
        WHEN "R" THEN RUN fontes/impmatric.p. 
        WHEN "D" THEN RUN fontes/matricd.p.
        WHEN "J" THEN RUN fontes/matricj.p.
    END CASE.

    IF  RETURN-VALUE <> "OK" THEN
        DO:
           NEXT-PROMPT tel_nrdconta WITH FRAME f_matric.
           NEXT.
        END.
END.

/* ......................................................................... */
