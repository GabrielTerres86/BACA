DECLARE

  vr_data_origen  DATE := to_date('09/02/2024', 'DD/MM/RRRR');
  vr_data_destino DATE := to_date('08/02/2024', 'DD/MM/RRRR');

  CURSOR cr_crapcop IS
    SELECT c.cdcooper
      FROM crapcop c
     WHERE c.flgativo = 1
     ORDER BY c.cdcooper DESC;
      
BEGIN


  FOR rw_crapcop IN cr_crapcop LOOP 
    
    dbms_output.put_line('Copiando coop '||rw_crapcop.cdcooper);
    INSERT INTO cecred.crapris
      (nrdconta
      ,dtrefere
      ,innivris
      ,qtdiaatr
      ,vldivida
      ,vlvec180
      ,vlvec360
      ,vlvec999
      ,vldiv060
      ,vldiv180
      ,vldiv360
      ,vldiv999
      ,vlprjano
      ,vlprjaan
      ,inpessoa
      ,nrcpfcgc
      ,vlprjant
      ,inddocto
      ,cdmodali
      ,nrctremp
      ,nrseqctr
      ,dtinictr
      ,cdorigem
      ,cdagenci
      ,innivori
      ,cdcooper
      ,vlprjm60
      ,dtdrisco
      ,qtdriclq
      ,nrdgrupo
      ,vljura60
      ,inindris
      ,cdinfadi
      ,nrctrnov
      ,flgindiv
      ,dsinfaux
      ,dtprxpar
      ,vlprxpar
      ,qtparcel
      ,dtvencop
      ,dttrfprj
      ,vlsld59d
      ,flindbndes
      ,vlmrapar60
      ,vljuremu60
      ,vljurcor60
      ,vljurantpp
      ,vljurparpp
      ,vljurmorpp
      ,vljurmulpp
      ,vljuriofpp
      ,vljurcorpp
      ,inespecie
      ,qtdiaatr_ori
      ,nracordo
      ,flarrasto)
      SELECT /*+parallel */  nrdconta
            ,vr_data_destino dtrefere
            ,innivris
            ,qtdiaatr
            ,vldivida
            ,vlvec180
            ,vlvec360
            ,vlvec999
            ,vldiv060
            ,vldiv180
            ,vldiv360
            ,vldiv999
            ,vlprjano
            ,vlprjaan
            ,inpessoa
            ,nrcpfcgc
            ,vlprjant
            ,inddocto
            ,cdmodali
            ,nrctremp
            ,nrseqctr
            ,dtinictr
            ,cdorigem
            ,cdagenci
            ,innivori
            ,cdcooper
            ,vlprjm60
            ,dtdrisco
            ,qtdriclq
            ,nrdgrupo
            ,vljura60
            ,inindris
            ,cdinfadi
            ,nrctrnov
            ,flgindiv
            ,dsinfaux
            ,dtprxpar
            ,vlprxpar
            ,qtparcel
            ,dtvencop
            ,dttrfprj
            ,vlsld59d
            ,flindbndes
            ,vlmrapar60
            ,vljuremu60
            ,vljurcor60
            ,vljurantpp
            ,vljurparpp
            ,vljurmorpp
            ,vljurmulpp
            ,vljuriofpp
            ,vljurcorpp
            ,inespecie
            ,qtdiaatr_ori
            ,nracordo
            ,flarrasto
        FROM cecred.crapris r
       WHERE r.dtrefere = vr_data_origen
         AND r.cdcooper = rw_crapcop.cdcooper;

    INSERT INTO cecred.crapvri
      (nrdconta
      ,dtrefere
      ,innivris
      ,cdmodali
      ,nrctremp
      ,nrseqctr
      ,cdvencto
      ,vldivida
      ,cdcooper
      ,vljura60
      ,vlempres)
    
      SELECT /*+parallel */ nrdconta
            ,vr_data_destino dtrefere
            ,innivris
            ,cdmodali
            ,nrctremp
            ,nrseqctr
            ,cdvencto
            ,vldivida
            ,cdcooper
            ,vljura60
            ,vlempres
        FROM cecred.crapvri r
       WHERE r.dtrefere = vr_data_origen
         AND r.cdcooper = rw_crapcop.cdcooper;
  
  END LOOP;       

  COMMIT;
  
END;
