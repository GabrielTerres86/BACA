/* Define as variaveis compartilhas para fontes/ctremp.p */

DEFINE {1} SHARED VARIABLE s_column   AS INTEGER                     NO-UNDO.
DEFINE {1} SHARED VARIABLE s_hide     AS LOGICAL                     NO-UNDO.
DEFINE {1} SHARED VARIABLE s_row      AS INTEGER                     NO-UNDO.
DEFINE {1} SHARED VARIABLE s_title    AS CHARACTER                   NO-UNDO.
DEFINE {1} SHARED VARIABLE s_wide     AS LOGICAL                     NO-UNDO.

DEFINE {1} SHARED VARIABLE s_chcnt    AS INTEGER                     NO-UNDO.
DEFINE {1} SHARED VARIABLE s_chextent AS INTEGER                     NO-UNDO.
DEFINE {1} SHARED VARIABLE s_chlist   AS CHARACTER EXTENT 400        NO-UNDO.
DEFINE {1} SHARED VARIABLE s_choice   AS INTEGER   EXTENT 400        NO-UNDO.
DEFINE {1} SHARED VARIABLE s_multiple AS LOGICAL                     NO-UNDO.
DEFINE {1} SHARED VARIABLE s_dbfilenm AS CHARACTER                   NO-UNDO.
DEFINE {1} SHARED VARIABLE s_liquidac AS CHARACTER                   NO-UNDO.

DEFINE {1} SHARED VARIABLE s_vlsdeved AS DECIMAL   EXTENT 400        NO-UNDO.

DEFINE {1} SHARED VARIABLE s_vlemprst AS DECIMAL                     NO-UNDO.
