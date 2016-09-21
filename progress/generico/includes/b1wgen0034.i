/*..............................................................................

    Programa: b1wgen0034.p
    Autor   : Magui/David
    Data    : Setembro/2008                     Ultima Atualizacao:   /  /
           
    Dados referentes ao programa:
                
    Objetivo  : Variaveis para geracao dos arquivos DRM(2040) E DLO.
                    
    Alteracoes:
                        
..............................................................................*/

DEF TEMP-TABLE w_drm
    FIELD cdditdrm LIKE crapdrm.cdditdrm
    FIELD cdfatris LIKE crapdrm.cdfatris
    FIELD cdlocreg LIKE crapdrm.cdlocreg
    FIELD vertice  AS INTE FORMAT "99"
    FIELD valor_vertice AS INTE
    FIELD valor_mam     AS INTE
    INDEX ch-vertice AS PRIMARY UNIQUE
          cdditdrm
          cdfatris
          cdlocreg
          vertice.

DEF TEMP-TABLE w_afc
    FIELD cdditdrm LIKE crapdrm.cdditdrm
    FIELD cdfatris LIKE crapdrm.cdfatris
    FIELD qtdiauti AS INTE
    FIELD vllanris AS INTE
    INDEX ch-afc AS PRIMARY UNIQUE
          cdditdrm
          cdfatris
          qtdiauti.
DEF TEMP-TABLE w_dias_afc
    FIELD qtdiauti AS INTE
    FIELD vllancmp AS INTE
    FIELD vllanvda AS INTE 
    INDEX ch-qtdiauti AS UNIQUE PRIMARY
          qtdiauti.

DEF STREAM str_1.
DEF BUFFER b_w_afc         FOR w_afc.

DEF VAR aux_tagitdrm       AS CHAR                             NO-UNDO.
DEF VAR aux_vertices       AS INTE EXTENT 24                   NO-UNDO.
DEF VAR aux_vertice_antes  AS INTE FORMAT "zzz9"               NO-UNDO.
DEF VAR aux_vertice_poste  AS INTE FORMAT "zzz9"               NO-UNDO.
DEF VAR aux_cdvertic_antes AS INTE FORMAT "99"                 NO-UNDO.
DEF VAR aux_cdvertic_poste AS INTE FORMAT "99"                 NO-UNDO.
DEF VAR aux_qtvertic       AS INTE FORMAT "99"                 NO-UNDO.
DEF VAR aux_valor_antes    AS INTE                             NO-UNDO.
DEF VAR aux_valor_poste    AS INTE                             NO-UNDO.
DEF VAR aux_vllanmto       AS INTE                             NO-UNDO.
DEF VAR aux_occ            AS INTE                             NO-UNDO.
DEF VAR aux_valor_mam      AS INTE                             NO-UNDO.
DEF VAR aux_qtdiaris       AS INTE                             NO-UNDO.
DEF VAR aux_vllanris       AS INTE                             NO-UNDO.
DEF VAR aux_cdditafc       AS CHAR FORMAT "x(03)"              NO-UNDO.
DEF VAR aux_cdlocreg       AS INTE                             NO-UNDO.
/* .......................................................................... */
