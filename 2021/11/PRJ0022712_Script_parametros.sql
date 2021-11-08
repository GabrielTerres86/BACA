DECLARE

BEGIN

  -- Replicar parametros de pre-aprovado de emprestimo para pre-aprovado de limites                  
  FOR rw_crappre IN (SELECT pre.vllimman
                           ,pre.qtdiavig
                           ,pre.inpessoa
                           ,pre.cdcooper
                       FROM crappre pre
                           ,crapcop cop
                      WHERE pre.cdcooper = cop.cdcooper
                        AND pre.tpprodut = 0
                        AND cop.flgativo = 1) LOOP
    UPDATE crappre a
       SET a.vllimman = rw_crappre.vllimman
          ,a.qtdiavig = rw_crappre.qtdiavig
     WHERE a.cdcooper = rw_crappre.cdcooper
       AND a.inpessoa = rw_crappre.inpessoa
       AND a.tpprodut = 1;
  END LOOP;

  COMMIT;

END;
