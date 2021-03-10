-- PRJ0022712

-- Carga crapre tipo de produto limite de credito(2)
DECLARE
BEGIN

  FOR rw_crapcop IN (SELECT cop.cdcooper
                       FROM crapcop cop
                      WHERE cop.flgativo = 1) LOOP
  
    -- Pessoa Fisica
    INSERT INTO crappre
      (CDCOOPER
      ,NRMCOTAS
      ,DSRISDOP
      ,DSSITDOP
      ,NRREVCAD
      ,VLLIMMIN
      ,VLLIMCRA
      ,VLLIMCRB
      ,VLLIMCRC
      ,VLLIMCRD
      ,VLLIMCRE
      ,VLLIMCRF
      ,VLLIMCRG
      ,VLLIMCRH
      ,VLMAXLEG
      ,VLLIMCTR
      ,VLMULPLI
      ,CDFINEMP
      ,INPESSOA
      ,VLPERCOM
      ,CDLCREMP
      ,QTMESCTA
      ,QTMESEMP
      ,QTMESADM
      ,DSLSTALI
      ,QTDEVOLU
      ,QTDIADEV
      ,QTCTAATR
      ,QTEPRATR
      ,QTESTOUR
      ,QTDIAEST
      ,QTAVLATR
      ,VLAVLATR
      ,QTAVLOPE
      ,QTCJGATR
      ,VLCJGATR
      ,QTCJGOPE
      ,QTDIAVER
      ,QTMESBLQ
      ,QTDIAVIG
      ,QTDTITUL
      ,VLTITULO
      ,QTCARCRE
      ,VLCARCRE
      ,VLCTAATR
      ,VLDIAEST
      ,VLDIADEV
      ,VLLIMMAN
      ,VLLIMAUT
      ,VLEPRATR
      ,TPPRODUT)
      SELECT pre.cdcooper
            ,pre.nrmcotas
            ,pre.dsrisdop
            ,pre.dssitdop
            ,pre.nrrevcad
            ,pre.vllimmin
            ,pre.vllimcra
            ,pre.vllimcrb
            ,pre.VLLIMCRC
            ,pre.VLLIMCRD
            ,pre.VLLIMCRE
            ,pre.VLLIMCRF
            ,pre.VLLIMCRG
            ,pre.VLLIMCRH
            ,pre.VLMAXLEG
            ,pre.VLLIMCTR
            ,0 --VLMULPLI
            ,0 --CDFINEMP
            ,pre.INPESSOA
            ,pre.VLPERCOM
            ,pre.CDLCREMP
            ,pre.QTMESCTA
            ,pre.QTMESEMP
            ,pre.QTMESADM
            ,pre.DSLSTALI
            ,pre.QTDEVOLU
            ,pre.QTDIADEV
            ,pre.QTCTAATR
            ,pre.QTEPRATR
            ,pre.QTESTOUR
            ,pre.QTDIAEST
            ,pre.QTAVLATR
            ,pre.VLAVLATR
            ,pre.QTAVLOPE
            ,pre.QTCJGATR
            ,pre.VLCJGATR
            ,pre.QTCJGOPE
            ,pre.QTDIAVER
            ,pre.QTMESBLQ
            ,0 --QTDIAVIG
            ,pre.QTDTITUL
            ,pre.VLTITULO
            ,pre.QTCARCRE
            ,pre.VLCARCRE
            ,pre.VLCTAATR
            ,pre.VLDIAEST
            ,pre.VLDIADEV
            ,0 --VLLIMMAN
            ,pre.VLLIMAUT
            ,pre.VLEPRATR
            ,2 --TPPRODUT
        FROM crappre pre
       WHERE pre.cdcooper = rw_crapcop.cdcooper
         AND pre.inpessoa = 1; --Fisica
  
    -- Pessoa Juridica
    INSERT INTO crappre
      (CDCOOPER
      ,NRMCOTAS
      ,DSRISDOP
      ,DSSITDOP
      ,NRREVCAD 
      ,VLLIMMIN
      ,VLLIMCRA
      ,VLLIMCRB
      ,VLLIMCRC
      ,VLLIMCRD
      ,VLLIMCRE
      ,VLLIMCRF
      ,VLLIMCRG
      ,VLLIMCRH
      ,VLMAXLEG
      ,VLLIMCTR
      ,VLMULPLI
      ,CDFINEMP
      ,INPESSOA
      ,VLPERCOM
      ,CDLCREMP
      ,QTMESCTA
      ,QTMESEMP
      ,QTMESADM
      ,DSLSTALI
      ,QTDEVOLU
      ,QTDIADEV
      ,QTCTAATR
      ,QTEPRATR
      ,QTESTOUR
      ,QTDIAEST
      ,QTAVLATR
      ,VLAVLATR
      ,QTAVLOPE
      ,QTCJGATR
      ,VLCJGATR
      ,QTCJGOPE
      ,QTDIAVER
      ,QTMESBLQ
      ,QTDIAVIG
      ,QTDTITUL
      ,VLTITULO
      ,QTCARCRE
      ,VLCARCRE
      ,VLCTAATR
      ,VLDIAEST
      ,VLDIADEV
      ,VLLIMMAN
      ,VLLIMAUT
      ,VLEPRATR
      ,TPPRODUT)
      SELECT pre.cdcooper
            ,pre.nrmcotas
            ,pre.dsrisdop
            ,pre.dssitdop
            ,pre.nrrevcad
            ,pre.vllimmin
            ,pre.vllimcra
            ,pre.vllimcrb
            ,pre.VLLIMCRC
            ,pre.VLLIMCRD
            ,pre.VLLIMCRE
            ,pre.VLLIMCRF
            ,pre.VLLIMCRG
            ,pre.VLLIMCRH
            ,pre.VLMAXLEG
            ,pre.VLLIMCTR
            ,0 --VLMULPLI
            ,0 --CDFINEMP
            ,pre.INPESSOA
            ,pre.VLPERCOM
            ,pre.CDLCREMP
            ,pre.QTMESCTA
            ,pre.QTMESEMP
            ,pre.QTMESADM
            ,pre.DSLSTALI
            ,pre.QTDEVOLU
            ,pre.QTDIADEV
            ,pre.QTCTAATR
            ,pre.QTEPRATR
            ,pre.QTESTOUR
            ,pre.QTDIAEST
            ,pre.QTAVLATR
            ,pre.VLAVLATR
            ,pre.QTAVLOPE
            ,pre.QTCJGATR
            ,pre.VLCJGATR
            ,pre.QTCJGOPE
            ,pre.QTDIAVER
            ,pre.QTMESBLQ
            ,0 --QTDIAVIG
            ,pre.QTDTITUL
            ,pre.VLTITULO
            ,pre.QTCARCRE
            ,pre.VLCARCRE
            ,pre.VLCTAATR
            ,pre.VLDIAEST
            ,pre.VLDIADEV
            ,0 --VLLIMMAN
            ,pre.VLLIMAUT
            ,pre.VLEPRATR
            ,2 --TPPRODUT
        FROM crappre pre
       WHERE pre.cdcooper = rw_crapcop.cdcooper
         AND pre.inpessoa = 2; --Juridica
  END LOOP;
END;
/

COMMIT;
