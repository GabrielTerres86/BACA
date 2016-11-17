/* ............................................................................

   Programa: Fontes/sldccr_ct3.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio
   Data    : Fevereiro/2004                      Ultima atualizacao: 20/10/2010

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Chama a rotina que imprime o contrato de cartao de credito para
               administradora 2 "BRADESCO VISA".
               
   Alteracoes: 10/06/2009 - Inclusao de parametro par_b1wgen0028 (Handle da BO)
                            na chamada do programa sldccr_ct2.p (GATI - Eder).
                            
               20/10/2010 - Alteracao para imprimir termo de pessoa jurica
                          (Gati - Daniel).
............................................................................ */
DEF  INPUT  PARAM par_nrctrcrd   AS  INTEGER       NO-UNDO.

{includes/var_online.i}
{includes/var_atenda.i}

DEF VAR h_b1wgen0028  AS HANDLE              NO-UNDO.
DEF VAR h_termos      AS HANDLE              NO-UNDO.
DEFINE VARIABLE  aux_tipopess AS INTEGER     NO-UNDO.


RUN sistema/generico/procedures/b1wgen0028.p 
                PERSISTENT SET h_b1wgen0028.


RUN verifica_associado IN h_b1wgen0028 (INPUT glb_cdcooper,
                                        INPUT tel_nrdconta,
                                        OUTPUT aux_tipopess).

DELETE PROCEDURE h_b1wgen0028.


IF  aux_tipopess = 1 THEN 
    DO:
        RUN fontes/sldccr_ct2.p (INPUT par_nrctrcrd).
    END.

ELSE DO: 
    RUN fontes/termos_pj.p PERSISTENT SET h_termos.

    RUN imprime_entrega IN h_termos (INPUT par_nrctrcrd,
                                     INPUT tel_nrdconta).

    DELETE PROCEDURE h_termos.
END.
    




RETURN RETURN-VALUE.
/* ......................................................................... */
