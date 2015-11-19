/* ..............................................................................

Procedure: xfs_lite.p 

Objetivo : Charmar as funções da xfs_lite SID para controle dos periféricos.

Autor    : Edson 

Data     : 28 de outubro de 1998


Ultima alteração: 11/02/2009 - Incluídas procedures do novo mecanismo de Depositário (Diego).

                  19/05/2010 - Incluidas procedures para leitor de codigo de
                               barras (Evandro).
                               
                  01/08/2011 - Inlcuidas/Alteradas procedures para o PAINOP (Evandro).

................................................................................*/

/* CHAMADAS AS API´S DO WINDOWS ............................................... */

PROCEDURE LoadLibraryA EXTERNAL "KERNEL32.DLL" PERSISTENT:

    DEFINE INPUT  PARAMETER LL_FILENAME AS CHARACTER.
    DEFINE RETURN PARAMETER LL_HANDLE   AS LONG.

END PROCEDURE.

PROCEDURE FreeLibrary EXTERNAL "KERNEL32.DLL" PERSISTENT:

    DEFINE INPUT PARAMETER LL_FILENAME AS LONG.

END PROCEDURE.

PROCEDURE Sleep EXTERNAL "KERNEL32":

  DEFINE INPUT  PARAMETER lMilliseconds AS LONG  NO-UNDO.

END PROCEDURE.

PROCEDURE ExitWindowsEx EXTERNAL "USER32.DLL" PERSISTENT:

    DEFINE INPUT  PARAMETER UFLAGS      AS SHORT.
    DEFINE INPUT  PARAMETER DWRESERVERD AS SHORT.
    DEFINE RETURN PARAMETER RETORNO     AS SHORT.

END PROCEDURE.

PROCEDURE ShowCursor EXTERNAL "USER32.DLL" PERSISTENT:

    DEFINE INPUT  PARAMETER BFLAGS      AS SHORT.
    DEFINE RETURN PARAMETER RETORNO     AS SHORT.

END PROCEDURE.

/*  ----------------------------------------------------------------------
    API's para TAA da SID                              
    ----------------------------------------------------------------------  */

/* INICIA E FINALIZA XFS_LITE ................................................. */

PROCEDURE XFS_Inicia EXTERNAL "xfs_lite.dll" PERSISTENT:
    
    DEF RETURN PARAMETER LT_Resp AS SHORT.

END PROCEDURE.

PROCEDURE XFS_Finaliza EXTERNAL 'xfs_lite.dll' PERSISTENT:

    DEF RETURN PARAMETER LT_Resp AS SHORT.

END PROCEDURE.

/*  DISPENSADOR DE NOTAS ...................................................... */

PROCEDURE XFS_Abre_Dispensador EXTERNAL 'xfs_lite.dll' PERSISTENT :

    DEF RETURN PARAMETER LT_Resp AS SHORT.

END PROCEDURE.

PROCEDURE XFS_Fecha_Dispensador EXTERNAL 'xfs_lite.dll' PERSISTENT:

    DEF RETURN PARAMETER LT_Resp AS SHORT.

END PROCEDURE.

PROCEDURE XFS_Dispensa_Notas_Por_Cassete EXTERNAL 'xfs_lite.dll' PERSISTENT:

    DEF INPUT  PARAM cQuantNotas AS CHAR.
    DEF OUTPUT PARAM cQuantPaga  AS MEMPTR.
    DEF RETURN PARAMETER LT_Resp AS SHORT.

END PROCEDURE.

PROCEDURE XFS_Dispensa_Notas EXTERNAL 'xfs_lite.dll' PERSISTENT:

    DEF INPUT  PARAM lValorAPagar     AS LONG.
    DEF INPUT  PARAM AltType          AS SHORT.
    DEF OUTPUT PARAM lValorDispensado AS LONG.
    DEF RETURN PARAM LT_Resp          AS SHORT.

END PROCEDURE.

PROCEDURE XFS_Dispensa_Notas_Por_Valor EXTERNAL 'xfs_lite.dll' PERSISTENT:

    DEF INPUT  PARAM lValorAPagar     AS LONG.
    DEF INPUT  PARAM lValorNota       AS LONG.
    DEF OUTPUT PARAM lValorDispensado AS LONG.
    DEF RETURN PARAM LT_Resp          AS SHORT.

END PROCEDURE.

PROCEDURE XFS_Limpa_Dispensador EXTERNAL 'xfs_lite.dll' PERSISTENT:

    DEF RETURN PARAM LT_Resp          AS SHORT.

END PROCEDURE.

PROCEDURE XFS_Inicia_Atualizacao_Dispensador EXTERNAL 'xfs_lite.dll' PERSISTENT:

    DEF RETURN PARAM LT_Resp          AS SHORT.

END PROCEDURE.

PROCEDURE XFS_Finaliza_Atualizacao_Dispensador EXTERNAL 'xfs_lite.dll' PERSISTENT:

    DEF RETURN PARAM LT_Resp          AS SHORT.

END PROCEDURE.

PROCEDURE XFS_Atualiza_Cassete_Dispensador EXTERNAL 'xfs_lite.dll' PERSISTENT:

    DEF INPUT  PARAM cCassete         AS CHAR.
    DEF INPUT  PARAM lValor           AS LONG.
    DEF INPUT  PARAM lQtd             AS LONG.
    DEF RETURN PARAM LT_Resp          AS SHORT.

END PROCEDURE.

PROCEDURE XFS_Nomes_Cassetes_Dispensador EXTERNAL 'xfs_lite.dll' PERSISTENT:

    DEF OUTPUT PARAM cCassetes        AS MEMPTR.
    DEF RETURN PARAM LT_Resp          AS SHORT.

END PROCEDURE.

PROCEDURE XFS_Quant_Notas_Cassete_Dispensador EXTERNAL 'xfs_lite.dll' PERSISTENT:

    DEF INPUT  PARAM cCassete        AS CHAR.
    DEF RETURN PARAM LT_Resp         AS SHORT.

END PROCEDURE.

PROCEDURE XFS_Quant_Notas_Rejeitadas_Cassete EXTERNAL 'xfs_lite.dll' PERSISTENT:

    DEF INPUT  PARAM cCassete        AS CHAR.
    DEF RETURN PARAM LT_Resp         AS SHORT.

END PROCEDURE.

PROCEDURE XFS_Status_Caixa_Rejeicao_Dispensador EXTERNAL 'xfs_lite.dll' PERSISTENT:

    DEF RETURN PARAM LT_Resp         AS SHORT.

END PROCEDURE.

PROCEDURE XFS_Status_Dispensador EXTERNAL 'xfs_lite.dll' PERSISTENT:

    DEF RETURN PARAM LT_Resp         AS SHORT.

END PROCEDURE.

PROCEDURE XFS_Ultimo_Pagamento_Dispensado EXTERNAL 'xfs_lite.dll' PERSISTENT:

    DEF INPUT  PARAM cCassete        AS CHAR.
    DEF RETURN PARAM LT_Resp         AS SHORT.

END PROCEDURE.

PROCEDURE XFS_Valida_Pagamento_Dispensador EXTERNAL 'xfs_lite.dll' PERSISTENT:

    DEF INPUT  PARAM lValorAPagar     AS LONG.
    DEF INPUT  PARAM AltType          AS SHORT.
    DEF RETURN PARAM LT_Resp          AS SHORT.

END PROCEDURE.

PROCEDURE XFS_Valor_Minimo_Dispensador EXTERNAL 'xfs_lite.dll' PERSISTENT:

    DEF RETURN PARAM LT_Resp         AS SHORT.

END PROCEDURE.

PROCEDURE XFS_Valor_Notas_Cassete_Dispensador EXTERNAL 'xfs_lite.dll' PERSISTENT:

    DEF INPUT  PARAM cCassete        AS CHAR.
    DEF RETURN PARAM LT_Resp         AS SHORT.

END PROCEDURE.

/* IMPRESSORA ................................................................. */

PROCEDURE XFS_Abre_Impressora EXTERNAL 'xfs_lite.dll' PASCAL PERSISTENT:
  
    DEF RETURN PARAM LT_Resp          AS SHORT.
  
END PROCEDURE.

PROCEDURE XFS_Imprime EXTERNAL 'xfs_lite.dll' PERSISTENT:

    DEF INPUT  PARAM cDados           AS CHAR.
    DEF RETURN PARAM LT_Resp          AS SHORT.

END PROCEDURE.

PROCEDURE XFS_Fecha_Impressora EXTERNAL 'xfs_lite.dll' PERSISTENT:

    DEF RETURN PARAM LT_Resp          AS SHORT.

END PROCEDURE.

PROCEDURE XFS_Modo_Autenticacao EXTERNAL 'xfs_lite.dll' PERSISTENT:

    DEF RETURN PARAM LT_Resp          AS SHORT.

END PROCEDURE.

PROCEDURE XFS_Picota EXTERNAL 'xfs_lite.dll' PERSISTENT:

    DEF RETURN PARAM LT_Resp          AS SHORT.

END PROCEDURE.

PROCEDURE XFS_Status_Comprovante EXTERNAL 'xfs_lite.dll' PERSISTENT:

    DEF RETURN PARAM LT_Resp          AS SHORT.

END PROCEDURE.

PROCEDURE XFS_Status_Impressora EXTERNAL 'xfs_lite.dll' PERSISTENT:

    DEF RETURN PARAM LT_Resp          AS SHORT.

END PROCEDURE.

PROCEDURE XFS_Ultima_Autenticacao EXTERNAL 'xfs_lite.dll' PERSISTENT:

    DEF INPUT  PARAM cDados           AS CHAR.
    DEF RETURN PARAM LT_Resp          AS SHORT.

END PROCEDURE.

PROCEDURE XFS_Abre_Leitora_Cheque EXTERNAL 'xfs_lite.dll' PERSISTENT:

    DEF RETURN PARAM LT_Resp          AS SHORT.

END PROCEDURE.

PROCEDURE XFS_Fecha_Leitora_Cheque EXTERNAL 'xfs_lite.dll' PERSISTENT:

    DEF RETURN PARAM LT_Resp          AS SHORT.

END PROCEDURE.

PROCEDURE XFS_Le_Cheque EXTERNAL 'xfs_lite.dll' PERSISTENT:

    DEF OUTPUT PARAM cDados           AS MEMPTR.
    DEF INPUT  PARAM lTempo           AS LONG.
    DEF RETURN PARAM LT_Resp          AS SHORT.

END PROCEDURE.

PROCEDURE XFS_Abre_Leitora_Cod_Barras_AB EXTERNAL 'xfs_lite.dll' PERSISTENT:

    DEF RETURN PARAM LT_Resp          AS SHORT.

END PROCEDURE.

PROCEDURE XFS_Fecha_Leitora_Cod_Barras_AB EXTERNAL 'xfs_lite.dll' PERSISTENT:

    DEF RETURN PARAM LT_Resp          AS SHORT.

END PROCEDURE.

PROCEDURE XFS_Le_Cod_Barras_AB EXTERNAL 'xfs_lite.dll' PERSISTENT:

    DEF OUTPUT PARAM cDados           AS MEMPTR.
    DEF INPUT  PARAM lTempo           AS LONG.
    DEF RETURN PARAM LT_Resp          AS SHORT.

END PROCEDURE.

PROCEDURE XFS_Abre_PIN EXTERNAL 'xfs_lite.dll' PERSISTENT:

    DEF RETURN PARAM LT_Resp          AS SHORT.

END PROCEDURE.

PROCEDURE XFS_Fecha_PIN EXTERNAL 'xfs_lite.dll' PERSISTENT:

    DEF RETURN PARAM LT_Resp          AS SHORT.

END PROCEDURE.

PROCEDURE XFS_Le_PIN EXTERNAL 'xfs_lite.dll' PERSISTENT:

    DEF INPUT  PARAM iTamMax          AS SHORT.
    DEF INPUT  PARAM iAutoFim         AS SHORT.
    DEF OUTPUT PARAM cDados           AS MEMPTR.
    DEF INPUT  PARAM lTempo           AS LONG.
    DEF RETURN PARAM LT_Resp          AS SHORT.

END PROCEDURE.

PROCEDURE XFS_Status_PIN EXTERNAL 'xfs_lite.dll' PERSISTENT:

    DEF RETURN PARAM LT_Resp          AS SHORT.

END PROCEDURE.

/* SENSORES ................................................................... */

PROCEDURE XFS_Abre_Sensores EXTERNAL 'xfs_lite.dll' PERSISTENT:

    DEF RETURN PARAM LT_Resp          AS SHORT.

END PROCEDURE.

PROCEDURE XFS_Fecha_Sensores EXTERNAL 'xfs_lite.dll' PERSISTENT:

    DEF RETURN PARAM LT_Resp          AS SHORT.

END PROCEDURE.

PROCEDURE XFS_Status_Sensor_Porta EXTERNAL 'xfs_lite.dll' PERSISTENT:

    DEF RETURN PARAM LT_Resp          AS SHORT.

END PROCEDURE.

PROCEDURE XFS_Status_Sensor_Temperatura EXTERNAL 'xfs_lite.dll' PERSISTENT:

    DEF RETURN PARAM LT_Resp          AS SHORT.

END PROCEDURE.

PROCEDURE XFS_Status_Sensor_Posicao_Modulo EXTERNAL 'xfs_lite.dll' PERSISTENT:

    DEF RETURN PARAM LT_Resp          AS SHORT.

END PROCEDURE.

PROCEDURE XFS_Status_Sensor_Chave_Operador EXTERNAL 'xfs_lite.dll' PERSISTENT:

    DEF RETURN PARAM LT_Resp          AS SHORT.

END PROCEDURE.

PROCEDURE XFS_Status_Sensor_Vibracao EXTERNAL 'xfs_lite.dll' PERSISTENT:

    DEF RETURN PARAM LT_Resp          AS SHORT.

END PROCEDURE.

PROCEDURE XFS_Status_Sensor_Fechadura EXTERNAL 'xfs_lite.dll' PERSISTENT:

    DEF RETURN PARAM LT_Resp          AS SHORT.

END PROCEDURE.

/*  ----------------------------------------------------------------------
    API's para TAA da DIEBOLD PROCOMP                                   
    ----------------------------------------------------------------------  */

/*  Impressora ...........................................................  */

PROCEDURE WinIniciaPrtCh EXTERNAL 'P32PRTCH.DLL' PERSISTENT:

    DEF RETURN PARAM LT_Resp          AS LONG.

END PROCEDURE.

PROCEDURE WinStatusPrtCh EXTERNAL 'P32PRTCH.DLL' PERSISTENT:

    DEF INPUT  PARAM pSTATUS          AS LONG.   /*  Ponteiro p/ memptr  */
    DEF RETURN PARAM LT_Resp          AS LONG.

END PROCEDURE.

PROCEDURE WinImprimePrtCh EXTERNAL 'P32PRTCH.DLL' PERSISTENT:

    DEF INPUT  PARAM Logo             AS LONG.
    DEF INPUT  PARAM cBuffer          AS LONG.   /*  Ponteiro p/ memptr  */
    DEF INPUT  PARAM Tamanho          AS LONG.
    DEF RETURN PARAM LT_Resp          AS LONG.

END PROCEDURE.

PROCEDURE WinCutPrtCh EXTERNAL 'P32PRTCH.DLL' PERSISTENT:

    DEF RETURN PARAM LT_Resp          AS LONG.

END PROCEDURE.

/*  Dispensador .........................................................  */

PROCEDURE WinIniciaContador EXTERNAL 'P32CONTA.DLL' PERSISTENT:

    DEF INPUT  PARAM LpRsp          AS LONG.   /*  Ponteiro p/ memptr  */
    DEF RETURN PARAM LT_Resp        AS LONG.

END PROCEDURE.

PROCEDURE WinStatusContador EXTERNAL 'P32CONTA.DLL' PERSISTENT:

    DEF INPUT  PARAM LpRsp          AS LONG.   /*  Ponteiro p/ memptr  */
    DEF RETURN PARAM LT_Resp        AS LONG.

END PROCEDURE.

PROCEDURE WinContarCedulas EXTERNAL 'P32CONTA.DLL' PERSISTENT:

    DEF INPUT  PARAM LpCmd          AS LONG.   /*  Ponteiro p/ memptr  */
    DEF INPUT  PARAM LpRsp          AS LONG.   /*  Ponteiro p/ memptr  */
    DEF RETURN PARAM LT_Resp        AS LONG.

END PROCEDURE.

PROCEDURE WinContagemTeste EXTERNAL 'P32CONTA.DLL' PERSISTENT:

    DEF INPUT  PARAM LpCmd          AS LONG.   /*  Ponteiro p/ memptr  */
    DEF INPUT  PARAM LpRsp          AS LONG.   /*  Ponteiro p/ memptr  */
    DEF RETURN PARAM LT_Resp        AS LONG.

END PROCEDURE.

PROCEDURE WinEntregarCedulas EXTERNAL 'P32CONTA.DLL' PERSISTENT:

    DEF INPUT  PARAM LpCmd          AS LONG.   /*  Ponteiro p/ memptr  */
    DEF INPUT  PARAM LpRsp          AS LONG.   /*  Ponteiro p/ memptr  */
    DEF RETURN PARAM LT_Resp        AS LONG.

END PROCEDURE.

PROCEDURE WinRejeitarCedulas EXTERNAL 'P32CONTA.DLL' PERSISTENT:

    DEF INPUT  PARAM LpRsp          AS LONG.   /*  Ponteiro p/ memptr  */
    DEF RETURN PARAM LT_Resp        AS LONG.

END PROCEDURE.

PROCEDURE WinGravaNumeroEventosRejeicao EXTERNAL 'P32CONTA.DLL' PERSISTENT:

    DEF INPUT  PARAM LpRsp          AS LONG.   /*  Ponteiro p/ memptr  */
    DEF RETURN PARAM LT_Resp        AS LONG.

END PROCEDURE.

/*  Teclados (Frontal e PAINOP) / Leitora de Passagem .................................  */


PROCEDURE WinIniciaTeclados EXTERNAL 'P32TCATM.DLL' PERSISTENT:

    DEF RETURN PARAM LT_Resp          AS LONG.

END PROCEDURE.


PROCEDURE WinLeEstadoTeclados EXTERNAL 'P32TCATM.DLL' PERSISTENT:

    DEF INPUT  PARAM Teclado         AS LONG.
    DEF OUTPUT PARAM Varredura       AS LONG.
    DEF OUTPUT PARAM Led1            AS LONG.
    DEF OUTPUT PARAM Led2            AS LONG.
    DEF OUTPUT PARAM FlickerCrt      AS LONG.
    DEF OUTPUT PARAM FlickerDispCel  AS LONG.
    DEF OUTPUT PARAM FlickerPtr      AS LONG.

    DEF RETURN PARAM LT_Resp         AS LONG.

END PROCEDURE.



PROCEDURE WinAtualizaEstadoTeclados EXTERNAL 'P32TCATM.DLL' PERSISTENT:

    DEF INPUT  PARAM Teclado         AS LONG.
    DEF INPUT  PARAM Varredura       AS LONG.
    DEF INPUT  PARAM StaBeep         AS LONG.
    DEF INPUT  PARAM Led1            AS LONG.
    DEF INPUT  PARAM Led2            AS LONG.
    DEF INPUT  PARAM FlickerCrt      AS LONG.
    DEF INPUT  PARAM FlickerDispCel  AS LONG.
    DEF INPUT  PARAM FlickerPtr      AS LONG.
    DEF INPUT  PARAM Solenoide       AS LONG.

    DEF RETURN PARAM LT_Resp         AS LONG.

END PROCEDURE.




PROCEDURE WinLeConfiguraTeclados EXTERNAL 'P32TCATM.DLL' PERSISTENT:

    DEF INPUT  PARAM Teclado         AS LONG.
    DEF INPUT  PARAM VersTec         AS LONG.
    DEF OUTPUT PARAM StaEEPROM       AS LONG.
    DEF OUTPUT PARAM TemSmart        AS LONG.
    DEF OUTPUT PARAM TipoCrtMagn     AS LONG.
    DEF OUTPUT PARAM TrCrtMagn       AS LONG.
    DEF OUTPUT PARAM LayoutTec       AS LONG.
    DEF OUTPUT PARAM NlinhasDisplay  AS LONG.
    DEF OUTPUT PARAM NColDisplay     AS LONG.
    
    DEF RETURN PARAM LT_Resp         AS LONG.

END PROCEDURE.



PROCEDURE WinGravaConfiguraTeclados EXTERNAL 'P32TCATM.DLL' PERSISTENT:

    DEF INPUT  PARAM Teclado         AS LONG.
    DEF INPUT  PARAM TemSmart        AS LONG.
    DEF INPUT  PARAM TipoCrtMagn     AS LONG.
    DEF INPUT  PARAM TrCrtMagn       AS LONG.
    DEF INPUT  PARAM LayoutTec       AS LONG.
    DEF INPUT  PARAM LayTec          AS LONG.
    DEF INPUT  PARAM StartCode       AS LONG.
    DEF INPUT  PARAM StopCode        AS LONG.
    
    DEF RETURN PARAM LT_Resp         AS LONG.

END PROCEDURE.




PROCEDURE WinLeSincronoCartaoPassagem EXTERNAL 'P32TCATM.DLL' PERSISTENT:

    DEF INPUT  PARAM TIMELE      AS LONG.
    DEF INPUT  PARAM TAMBUFF     AS LONG.
    DEF INPUT  PARAM LPAPPBUFF   AS LONG.
    
    DEF RETURN PARAM LT_Resp     AS LONG.

END PROCEDURE.


PROCEDURE WinLeSincronoCartaoPassagemEx EXTERNAL 'P32TCATM.DLL' PERSISTENT:

    DEF INPUT  PARAM Teclado      AS LONG.
    DEF INPUT  PARAM TimeLe       AS LONG.
    DEF INPUT  PARAM TamBuff1     AS LONG.
    DEF INPUT  PARAM LpAppBuff1   AS LONG.
    DEF INPUT  PARAM TamBuff2     AS LONG.
    DEF INPUT  PARAM LpAppBuff2   AS LONG.
    DEF INPUT  PARAM TamBuff3     AS LONG.
    DEF INPUT  PARAM LpAppBuff3   AS LONG.
    
    DEF RETURN PARAM LT_Resp      AS LONG.

END PROCEDURE.




PROCEDURE WinAtualizaDisplay EXTERNAL 'P32TCATM.DLL' PERSISTENT:

    /* Obs.: Foi utilizado "oo" na variavel Scrooll porque a palavra correta,
             Scroll eh reservada para o Progress */

    DEF INPUT  PARAM Teclado      AS LONG.
    DEF INPUT  PARAM Limpa        AS LONG.
    DEF INPUT  PARAM Scrooll      AS LONG.
    DEF INPUT  PARAM TpCursor     AS LONG.
    DEF INPUT  PARAM PosLinha     AS LONG.
    DEF INPUT  PARAM PosColuna    AS LONG.
    DEF INPUT  PARAM LpBuffDisp   AS LONG.
    
    DEF RETURN PARAM LT_Resp      AS LONG.

END PROCEDURE.




/*  Leitora de inserção ................................................*/

PROCEDURE WinIniciaLDIP EXTERNAL 'P32LDIP.DLL' PERSISTENT:

    DEF INPUT  PARAM EstadoInicialLed   AS LONG.    /*  Ponteiro p/ memptr  */
    DEF INPUT  PARAM TipoLeituraCMG     AS LONG.    /*  Ponteiro p/ memptr  */
    DEF INPUT  PARAM ModoAcionaTrava    AS LONG.    /*  Ponteiro p/ memptr  */
    DEF OUTPUT PARAM ModeloLeitor       AS LONG.
    DEF RETURN PARAM LT_Resp        AS LONG.

END PROCEDURE.

PROCEDURE WinStatusLDIP EXTERNAL 'P32LDIP.DLL' PERSISTENT:

    DEF INPUT  PARAM EstadoSensores         AS LONG.    /*  Ponteiro p/ memptr  */
    DEF INPUT  PARAM EstadoTrava            AS LONG.    /*  Ponteiro p/ memptr  */
    DEF INPUT  PARAM EstadoBufferTrilha1    AS LONG.    /*  Ponteiro p/ memptr  */
    DEF INPUT  PARAM EstadoBufferTrilha2    AS LONG.    /*  Ponteiro p/ memptr  */
    DEF INPUT  PARAM EstadoBufferTrilha3    AS LONG.    /*  Ponteiro p/ memptr  */
    DEF RETURN PARAM LT_Resp        AS LONG.

END PROCEDURE.

PROCEDURE WinAlteraLedLDIP EXTERNAL 'P32LDIP.DLL' PERSISTENT:

    DEF INPUT  PARAM EstadoLed      AS LONG.    /*  Ponteiro p/ memptr  */
    DEF RETURN PARAM LT_Resp        AS LONG.

END PROCEDURE.

PROCEDURE WinDesativaTravaLDIP EXTERNAL 'P32LDIP.DLL' PERSISTENT:

    DEF RETURN PARAM LT_Resp        AS LONG.

END PROCEDURE.

PROCEDURE WinLeSincronoCmgLDIP EXTERNAL 'P32LDIP.DLL' PERSISTENT:

    DEF INPUT  PARAM Timeout                 AS LONG.
    DEF INPUT  PARAM TamanhoBufferTrilha1    AS LONG.
    DEF INPUT  PARAM TamanhoBufferTrilha2    AS LONG.
    DEF INPUT  PARAM TamanhoBufferTrilha3    AS LONG.
    DEF INPUT  PARAM BufferTrilha1           AS LONG.
    DEF INPUT  PARAM BufferTrilha2           AS LONG.
    DEF INPUT  PARAM BufferTrilha3           AS LONG.
    
    DEF RETURN PARAM LT_Resp                 AS LONG.

END PROCEDURE.

PROCEDURE WinCancelaLeituraCmgLDIP EXTERNAL 'P32LDIP.DLL' PERSISTENT:

    DEF RETURN PARAM LT_Resp        AS LONG.

END PROCEDURE.

PROCEDURE WinFinalizaLDIP EXTERNAL 'P32LDIP.DLL' PERSISTENT:

    DEF RETURN PARAM LT_Resp        AS LONG.

END PROCEDURE.

/*  Módulo Depositário .................................................. */

PROCEDURE WinIniciaDepIbold EXTERNAL 'P32DEPIB.DLL' PERSISTENT:

    DEF INPUT  PARAM ErroDep                 AS LONG.
    DEF RETURN PARAM LT_Resp                 AS LONG.

END PROCEDURE.

PROCEDURE WinIniciaContadorDepIbold EXTERNAL 'P32DEPIB.DLL' PERSISTENT:

    DEF RETURN PARAM LT_Resp                 AS LONG.

END PROCEDURE.

PROCEDURE WinStatusDepIbold EXTERNAL 'P32DEPIB.DLL' PERSISTENT:

    DEF INPUT  PARAM ErroDep                 AS LONG.
    DEF INPUT  PARAM NumDepositos            AS LONG.
    DEF INPUT  PARAM StatusDep               AS LONG.
    DEF RETURN PARAM LT_Resp                 AS LONG.

END PROCEDURE.

PROCEDURE WinDepositaDepIbold EXTERNAL 'P32DEPIB.DLL' PERSISTENT:

    DEF INPUT  PARAM Imprime                 AS LONG.
    DEF INPUT  PARAM TimeOut                 AS LONG.
    DEF INPUT  PARAM ErroDep                 AS LONG.
    DEF RETURN PARAM LT_Resp                 AS LONG.

END PROCEDURE.

PROCEDURE WinCancelaDepIbold EXTERNAL 'P32DEPIB.DLL' PERSISTENT:

    DEF RETURN PARAM LT_Resp                 AS LONG.

END PROCEDURE.

PROCEDURE WinLeCRCFWDep EXTERNAL 'P32DEPIB.DLL' PERSISTENT:

    DEF INPUT  PARAM LpRsp                   AS LONG.
    DEF RETURN PARAM LT_Resp                 AS LONG.

END PROCEDURE.

PROCEDURE WinRecuperaErroDepIbold EXTERNAL 'P32DEPIB.DLL' PERSISTENT:

    DEF INPUT  PARAM ErroDepos               AS LONG.
    DEF INPUT  PARAM CmpRes                  AS LONG.
    DEF RETURN PARAM LT_Resp                 AS LONG.

END PROCEDURE.

/*  Módulo Depositário utilizado a partir dos TAAs modelo ATM 4535-231   */

PROCEDURE WinIniciaDepositario EXTERNAL "P32DEPPS.DLL" PERSISTENT:

    DEFINE INPUT  PARAMETER TempoDep    AS LONG.
    DEFINE INPUT  PARAMETER TempoDev    AS LONG.
    DEFINE INPUT  PARAMETER TipoLetra   AS LONG.
    DEFINE INPUT  PARAMETER SobrepoeMsg AS LONG.
    DEFINE OUTPUT PARAMETER CodRetGeral AS LONG.
    DEFINE OUTPUT PARAMETER CodRetDet   AS LONG.

END PROCEDURE.


PROCEDURE WinStatusDepositario EXTERNAL "P32DEPPS.DLL" PERSISTENT:

    DEFINE OUTPUT PARAMETER CodRetGeral  AS LONG.
    DEFINE OUTPUT PARAMETER CodRetDet    AS LONG.
    DEFINE OUTPUT PARAMETER NumDep       AS LONG.
    DEFINE OUTPUT PARAMETER StatusCasDep AS LONG.

END PROCEDURE.


PROCEDURE WinStatusUltDep EXTERNAL "P32DEPPS.DLL" PERSISTENT:

    DEFINE OUTPUT PARAMETER CodRetGeral  AS LONG.
    DEFINE OUTPUT PARAMETER CodRetDet    AS LONG.
    DEFINE OUTPUT PARAMETER StatusUltDep AS LONG.
    DEFINE OUTPUT PARAMETER StatusCasDep AS LONG.

END PROCEDURE.


PROCEDURE WinDeposita EXTERNAL "P32DEPPS.DLL" PERSISTENT:

    DEFINE INPUT  PARAMETER MsgImp       AS CHARACTER.
    DEFINE OUTPUT PARAMETER CodRetGeral  AS LONG.
    DEFINE OUTPUT PARAMETER CodRetDet    AS LONG.

END PROCEDURE.


PROCEDURE WinDevolveEnvelope EXTERNAL "P32DEPPS.DLL" PERSISTENT:

    DEFINE OUTPUT PARAMETER CodRetGeral  AS LONG.
    DEFINE OUTPUT PARAMETER CodRetDet    AS LONG.

END PROCEDURE.


PROCEDURE WinLeSensoresDep EXTERNAL "P32DEPPS.DLL" PERSISTENT:

    DEFINE OUTPUT PARAMETER CodRetGeral  AS LONG.
    DEFINE OUTPUT PARAMETER CodRetDet    AS LONG.

END PROCEDURE.


PROCEDURE WinZeraContadorDep EXTERNAL "P32DEPPS.DLL" PERSISTENT:

    DEFINE OUTPUT PARAMETER CodRetGeral  AS LONG.
    DEFINE OUTPUT PARAMETER CodRetDet    AS LONG.

END PROCEDURE.



/*  Leitor de Codigo de Barras ..........................................  */

PROCEDURE WinIniciaLcbCh EXTERNAL 'P32LCBCH.DLL' PERSISTENT:

    DEF RETURN PARAM LT_Resp        AS LONG.

END PROCEDURE.

/* leitura assincrona */
PROCEDURE WinStartLeAssincronoCodBarLcbCh EXTERNAL 'P32LCBCH.DLL' PERSISTENT:

    DEF INPUT  PARAM Tempo            AS LONG.
    DEF INPUT  PARAM Tamanho          AS LONG.
    DEF RETURN PARAM LT_Resp          AS LONG.

END PROCEDURE.

PROCEDURE WinLeAssincronoCodBarLcbCh EXTERNAL 'P32LCBCH.DLL' PERSISTENT:

    DEF INPUT  PARAM cBuffer          AS LONG.  /*  Ponteiro p/ memptr  */
    DEF RETURN PARAM LT_Resp          AS LONG.

END PROCEDURE.

PROCEDURE WinCancelaLeituraCodBarLcbCh EXTERNAL 'P32LCBCH.DLL' PERSISTENT:

    DEF RETURN PARAM LT_Resp        AS LONG.

END PROCEDURE.
/* fim leitura assincrona */


/* leitura sincrona */
PROCEDURE WinLeCodBarLcbCh EXTERNAL 'P32LCBCH.DLL' PERSISTENT:

    DEF INPUT  PARAM cBuffer          AS LONG.   /*  Ponteiro p/ memptr  */
    DEF INPUT  PARAM Tamanho          AS LONG.
    DEF RETURN PARAM LT_Resp          AS LONG.

END PROCEDURE.
/* fim leitura sincrona */

PROCEDURE WinFinalizaLcbCh EXTERNAL 'P32LCBCH.DLL' PERSISTENT:

    DEF RETURN PARAM LT_Resp        AS LONG.

END PROCEDURE.


/*  .....................................................................  */
