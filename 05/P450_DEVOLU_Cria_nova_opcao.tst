PL/SQL Developer Test script 3.0
37
declare 
  SIGLA_TELA varchar2(400) := 'DEVOLU';
 
  CURSOR cr_crapcop is
    SELECT cdcooper 
      FROM crapcop
     WHERE flgativo = 1
     --and cdcooper = 3
    ORDER BY cdcooper
   ;
    rw_crapcop cr_crapcop%ROWTYPE; 
 
  cursor cr_craptel(pr_cdcooper in crapcop.cdcooper%TYPE) is
    SELECT t.rowid
      from craptel t
     where cdcooper = pr_cdcooper
       AND t.lsopptel NOT LIKE '%ALTERAR ALINEA%'
       AND t.nmdatela = 'DEVOLU';

  rw_craptel cr_craptel%ROWTYPE;

begin
/* */

SIGLA_TELA := 'DEVOLU';
  --PARA CADA COOPERATIVA CADASTRADA
  FOR rw_crapcop IN cr_crapcop LOOP
    FOR rw_craptel IN cr_craptel (rw_crapcop.cdcooper) LOOP
      UPDATE craptel t
         SET t.cdopptel = t.cdopptel ||',A'
            ,t.lsopptel = t.lsopptel ||',ALTERAR ALINEA'
       WHERE t.rowid = rw_craptel.rowid;
    END LOOP;
  END LOOP;

  COMMIT;
END;
0
2
SIGLA_TELA
rw_crapcop.cdcooper
