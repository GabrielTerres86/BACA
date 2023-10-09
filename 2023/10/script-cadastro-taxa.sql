DECLARE
  vr_dscritic  VARCHAR2(5000) := NULL;
  vr_idprglog  tbgen_prglog.idprglog%TYPE := 0;
  pr_cdprogra VARCHAR2(15) := 'RITM0330690';

  CURSOR cr_crapcop IS
    SELECT cop.cdcooper ,
           cop.nmrescop
      FROM CECRED.crapcop cop
     WHERE cop.flgativo = 1 
       AND cop.cdcooper not in (3,1);       
  rw_crapcop cr_crapcop%ROWTYPE;

BEGIN

  DELETE CECRED.crapttx 
   WHERE tptaxrdc = 7
     AND cdcooper in (SELECT cop.cdcooper 
                        FROM crapcop cop
                       WHERE cop.flgativo = 1
                         AND cop.cdcooper <> 3) ;                         
                         
                         
  DELETE CECRED.crapftx 
   WHERE tptaxrdc = 7
     AND cdcooper in (SELECT cop.cdcooper 
                        FROM crapcop cop
                       WHERE cop.flgativo = 1
                         AND cop.cdcooper <> 3) ;                                                

  insert into CECRED.crapttx (CDCOOPER, TPTAXRDC, CDPERAPL, QTDIAINI, QTDIAFIM, QTDIACAR)
               values (1, 7, 1, 30, 30, 0);

  insert into CECRED.crapttx (CDCOOPER, TPTAXRDC, CDPERAPL, QTDIAINI, QTDIAFIM, QTDIACAR)
               values (1, 7, 2, 90, 90, 0);

  insert into CECRED.crapttx (CDCOOPER, TPTAXRDC, CDPERAPL, QTDIAINI, QTDIAFIM, QTDIACAR)
               values (1, 7, 3, 181, 186, 0);

  insert into CECRED.crapttx (CDCOOPER, TPTAXRDC, CDPERAPL, QTDIAINI, QTDIAFIM, QTDIACAR)
               values (1, 7, 4, 361, 366, 0);

  insert into CECRED.crapttx (CDCOOPER, TPTAXRDC, CDPERAPL, QTDIAINI, QTDIAFIM, QTDIACAR)
               values (1, 7, 5, 721, 721, 0);

  FOR rw_crapcop IN cr_crapcop LOOP
     
    insert into CECRED.crapttx (CDCOOPER, TPTAXRDC, CDPERAPL, QTDIAINI, QTDIAFIM, QTDIACAR)
                 values (rw_crapcop.cdcooper, 7, 1, 30, 30, 0);
    insert into CECRED.crapttx (CDCOOPER, TPTAXRDC, CDPERAPL, QTDIAINI, QTDIAFIM, QTDIACAR)
                 values (rw_crapcop.cdcooper, 7, 2, 90, 90, 0);
    insert into CECRED.crapttx (CDCOOPER, TPTAXRDC, CDPERAPL, QTDIAINI, QTDIAFIM, QTDIACAR)
                 values (rw_crapcop.cdcooper, 7, 3, 181, 181, 0);
    insert into CECRED.crapttx (CDCOOPER, TPTAXRDC, CDPERAPL, QTDIAINI, QTDIAFIM, QTDIACAR)
                 values (rw_crapcop.cdcooper, 7, 4, 361, 361, 0);
    insert into CECRED.crapttx (CDCOOPER, TPTAXRDC, CDPERAPL, QTDIAINI, QTDIAFIM, QTDIACAR)
                 values (rw_crapcop.cdcooper, 7, 5, 721, 721, 0);

  END LOOP;

  COMMIT;

EXCEPTION  
   
  WHEN OTHERS THEN
    vr_dscritic := 'Erro nao tratado ao rodar script : ' || SQLERRM;
    
    ROLLBACK;
    
    CECRED.pc_log_programa(pr_dstiplog   => 'O',
                           pr_dsmensagem => vr_dscritic,
                           pr_cdmensagem => 999,
                           pr_cdprograma => 'RITM0330690',
                           pr_cdcooper   => 3,
                           pr_idprglog   => vr_idprglog);
END;
