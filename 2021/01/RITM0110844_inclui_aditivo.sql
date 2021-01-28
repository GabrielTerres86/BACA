DECLARE
--
-- Valores fixos para a execução que seriam informados na tela
--
  vr_cdcooper       crapepr.cdcooper%TYPE := 5; -- Acentra
  vr_flgpagto       crapepr.flgpagto%TYPE := 1; -- Progress usa TRUE para desconto em folha de pagamento. Oracle é number. 0=sim   1=não ?
  vr_cdoperad       crapope.cdoperad%TYPE := 1; -- Operador. Usar superusuário ?
--
-- Variáveis de trabalho do script
--
  rw_crapdat        btch0001.cr_crapdat%ROWTYPE;
  vr_dtultdma       DATE;
  vr_dtultdia       DATE;
  vr_dtcalcul       date;
  vr_cdagenci       crapadt.cdagenci%TYPE;
  vr_vltotpag       craplem.vllanmto%type;
--
  CURSOR cr_crapepr ( pr_cdcooper IN crapepr.cdcooper%TYPE ) is
    SELECT  cdcooper
           ,nrdconta
           ,nrctremp
           ,flgpagto
           ,qtmesdec
           ,vlpreemp
           ,dtdpagto
           ,rowid
    FROM    crapepr
    WHERE cdcooper = pr_cdcooper
    AND   tpemprst = 0   -- TR
    AND   tpdescto = 2   -- Débito em folha de pagamento
    AND   INLIQUID = 0   -- Não liquidado
    AND   CDEMPRES in ( SELECT CDEMPRES
                        FROM   crapemp
                        WHERE NMEXTEMP LIKE '%CECRISA%'
                      )
    AND (nrdconta, nrctremp) in ( 
                                   (  1333  , 8503  )
                                  ,(  1953  , 13119 )
                                  ,(  4022  , 12142 )
                                  ,(  6440  , 12584 )
                                  ,(  8397  , 7388  )
                                  ,(  8397  , 10644 )
                                  ,(  9458  , 13133 )
                                  ,(  9865  , 9974  )
                                  ,(  9865  , 11152 )
                                  ,(  11134 , 7383  )
                                  ,(  12386 , 13708 )
                                  ,(  17426 , 12693 )
                                  ,(  19534 , 12867 )
                                  ,(  22365 , 8033  )
                                  ,(  23493 , 6145  )
                                  ,(  24457 , 10540 )
                                  ,(  25780 , 6362  )
                                  ,(  28622 , 12582 )
                                  ,(  28819 , 10029 )
                                  ,(  29289 , 9826  )
                                  ,(  29769 , 5587  )
                                  ,(  29947 , 12153 )
                                  ,(  29971 , 10561 )
                                  ,(  29980 , 7400  )
                                  ,(  32158 , 11815 )
                                  ,(  32310 , 6216  )
                                  ,(  32310 , 9599  )
                                  ,(  32867 , 8699  )
                                  ,(  33162 , 8257  )
                                  ,(  33448 , 10307 )
                                  ,(  34690 , 10522 )
                                  ,(  36730 , 11198 )
                                  ,(  38210 , 12269 )
                                  ,(  40940 , 5304  )
                                  ,(  41181 , 10236 )
                                  ,(  41483 , 7307  )
                                  ,(  42838 , 13793 )
                                  ,(  43184 , 8039  )
                                  ,(  44130 , 8483  )
                                  ,(  44164 , 6783  )
                                  ,(  45039 , 6611  )
                                  ,(  47040 , 9667  )
                                  ,(  48658 , 12476 )
                                  ,(  55190 , 11530 )
                                  ,(  57908 , 9748  )
                                  ,(  59501 , 11110 )
                                  ,(  60739 , 14555 )
                                  ,(  60933 , 13145 )
                                  ,(  61093 , 6586  )
                                  ,(  63851 , 13584 )
                                  ,(  64432 , 8892  )
                                  ,(  65714 , 14538 )
                                  ,(  67679 , 13079 )
                                  ,(  70530 , 7025  )
                                  ,(  72729 , 6033  )
                                  ,(  73776 , 6045  )
                                  ,(  75728 , 8627  )
                                  ,(  76813 , 14313 )
                                  ,(  78018 , 9463  )
                                  ,(  79057 , 8625  )
                                  ,(  79502 , 13703 )
                                  ,(  79600 , 11793 )
                                  ,(  84492 , 9393  )
                                  ,(  85308 , 10860 )
                                  ,(  95176 , 6388  )
                                  ,(  95273 , 11577 )
                                  ,(  96652 , 10904 )
                                  ,(  98426 , 10141 )
                                  ,(  102202  , 12144 )
                                  ,(  102210  , 12464 )
                                  ,(  104809  , 10792 )
                                  ,(  104809  , 11708 )
                                  ,(  104809  , 14239 )
                                  ,(  104833  , 9467  )
                                  ,(  104833  , 13736 )
                                  ,(  104884  , 12510 )
                                  ,(  108383  , 7480  )
                                  ,(  111414  , 13406 )
                                  ,(  114294  , 12452 )
                                  ,(  114294  , 13318 )
                                  ,(  129682  , 14710 )
                                  ,(  132705  , 7330  )
                                  ,(  141453  , 8781  )
                                  ,(  160636  , 11848 )
                                  ,(  165719  , 13037 )
                                  ,(  180971  , 14821 )
                                );
--
  CURSOR cr_crawepr ( pr_cdcooper IN crawepr.cdcooper%TYPE
                     ,pr_nrdconta IN crawepr.nrdconta%TYPE
                     ,pr_nrctremp IN crawepr.nrctremp%TYPE ) is
    SELECT  flgpagto
           ,dtvencto
           ,rowid
    FROM    crawepr
    WHERE cdcooper = pr_cdcooper
    AND   nrdconta = pr_nrdconta
    AND   nrctremp = pr_nrctremp;
--
  rw_crawepr      cr_crawepr%ROWTYPE;
--
  CURSOR cr_crapope ( pr_cdcooper IN crapepr.cdcooper%TYPE
                     ,pr_cdoperad IN crapope.cdoperad%TYPE ) IS
    SELECT  cdpactra
    FROM    crapope
    WHERE cdcooper = pr_cdcooper
    AND   cdoperad = pr_cdoperad;
--
  rw_crapope      cr_crapope%ROWTYPE;
--
  CURSOR cr_crapadt ( pr_cdcooper IN crapepr.cdcooper%TYPE
                     ,pr_nrdconta IN crapepr.nrdconta%TYPE
                     ,pr_nrctremp IN crapepr.nrctremp%TYPE
                     ,pr_tpctrato IN crapadt.tpctrato%TYPE ) IS
    SELECT  nvl(max(nraditiv), 0) + 1   uladitiv
    FROM    crapadt
    WHERE cdcooper = pr_cdcooper
    AND   nrdconta = pr_nrdconta
    AND   nrctremp = pr_nrctremp
    AND   tpctrato = pr_tpctrato;
--
    rw_crapadt      cr_crapadt%rowtype;
--
-- Sub-rotinas
--
  FUNCTION f_datapossivel ( pr_cdcooper IN crapepr.cdcooper%TYPE
                           ,pr_nrdconta IN crapepr.nrdconta%TYPE
                           ,pr_nrctremp IN crapepr.nrctremp%TYPE
                           ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                           ,pr_flgpagto IN crapepr.flgpagto%TYPE
                           ,pr_vlpreemp IN crapepr.vlpreemp%TYPE ) RETURN DATE IS
--  
    vr_datapossivel   DATE;
    vr_vltotpag_mes   craplem.vllanmto%type;
--
    CURSOR cr_craplem is
      SELECT  nvl(sum(CASE cdhistor
                        WHEN 91  THEN vllanmto  -- Pagto LANDPV
                        WHEN 92  THEN vllanmto  -- Empr.Consig.Caixa On_line
                        WHEN 93  THEN vllanmto  -- Emprestimo Consignado
                        WHEN 95  THEN vllanmto  -- Pagto crps120
                        WHEN 353 THEN vllanmto  -- Transf. Cotas
                        WHEN 393 THEN vllanmto  -- Pagto Avalista
                        WHEN 88  THEN -vllanmto -- Estorno Pagto
                        WHEN 507 THEN -vllanmto -- Est.Transf.C
                      END
                     ), 0)   vltotpag
      FROM    craplem
      WHERE cdcooper  = pr_cdcooper
      AND   nrdconta  = pr_nrdconta
      AND   nrctremp  = pr_nrctremp
      AND   cdhistor in (91, 92, 93, 95, 393, 353, 88, 507);
--
    CURSOR cr_craplem_mes is
      SELECT  nvl(sum(CASE cdhistor
                        WHEN 91  THEN vllanmto  -- Pagto LANDPV
                        WHEN 92  THEN vllanmto  -- Empr.Consig.Caixa On_line
                        WHEN 93  THEN vllanmto  -- Emprestimo Consignado
                        WHEN 95  THEN vllanmto  -- Pagto crps120
                        WHEN 353 THEN vllanmto  -- Transf. Cotas
                        WHEN 393 THEN vllanmto  -- Pagto Avalista
                        ELSE -vllanmto -- Est.Transf.C
                      END
                     ), 0)   vltotpag
      FROM    craplem
      WHERE cdcooper = pr_cdcooper
      AND   nrdconta = pr_nrdconta
      AND   nrctremp = pr_nrctremp
      AND   dtmvtolt > vr_dtultdma;
--
    CURSOR cr_crapavs ( pr_cdcooper IN crapepr.cdcooper%TYPE
                       ,pr_nrdconta IN crapepr.nrdconta%TYPE
                       ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
      SELECT  max(dtrefere)   dtrefere
      FROM    crapavs
      WHERE cdcooper = pr_cdcooper
      AND   nrdconta = pr_nrdconta
      AND   nrdocmto = pr_nrctremp
      AND   tpdaviso = 1
      AND   insitavs = 1;
--
    rw_crapavs      cr_crapavs%rowtype;
--
  BEGIN
    OPEN cr_craplem;
    FETCH  cr_craplem
    INTO   vr_vltotpag;
    CLOSE cr_craplem;
--
    IF  vr_vltotpag = 0 THEN
      vr_datapossivel := vr_dtultdia + 365;
    ELSE
      IF pr_flgpagto = 0 THEN
--
        OPEN cr_craplem_mes;
        FETCH  cr_craplem_mes
        INTO   vr_vltotpag_mes;
        CLOSE cr_craplem_mes;
--
        IF vr_vltotpag_mes >= pr_vlpreemp THEN -- Se houve pagamento no mês
          vr_datapossivel := vr_dtultdia + 35;
          vr_datapossivel := vr_datapossivel - to_number(to_char(vr_datapossivel, 'dd'));
        ELSE
--
          OPEN cr_crapavs( pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrctremp => pr_nrctremp);
          FETCH cr_crapavs
          INTO rw_crapavs;
--
          IF cr_crapavs%NOTFOUND
          OR rw_crapavs.dtrefere is NULL THEN
            vr_datapossivel := vr_dtultdia;
          ELSE
            IF rw_crapavs.dtrefere <= vr_dtultdma THEN
              vr_datapossivel := vr_dtultdia;
            ELSE
              vr_datapossivel := rw_crapavs.dtrefere;
            END IF;
          END IF;
--
          CLOSE cr_crapavs;
        END IF; -- Se houve pagamento no mês
      END IF;
    END IF;
--
    return (vr_datapossivel);
  END; -- f_datapossivel
--
-- Bloco principal
--
BEGIN
  OPEN  btch0001.cr_crapdat(vr_cdcooper);
  FETCH  btch0001.cr_crapdat
  INTO   rw_crapdat;
  CLOSE btch0001.cr_crapdat;
--
  vr_dtultdma := rw_crapdat.dtmvtolt - to_number(to_char(rw_crapdat.dtmvtolt, 'dd'));
  vr_dtultdia :=   ( to_date('28/' || to_char(rw_crapdat.dtmvtolt, 'mm/yyyy'), 'dd/mm/yyyy') + 4)
                 - to_number(to_char(to_date('28/' || to_char(rw_crapdat.dtmvtolt, 'mm/yyyy'), 'dd/mm/yyyy') + 4 , 'dd'));
--
  FOR rw_crapepr in cr_crapepr (pr_cdcooper => vr_cdcooper) LOOP
--
-- Valida dados
--
dbms_output.put_line('Conta:' || rw_crapepr.nrdconta ||
                     ' Contrato:' || rw_crapepr.nrctremp ||
                     ' Data de pagto: ' || to_char(rw_crapepr.dtdpagto, 'dd/mm/yyyy'));
/*
    IF  rw_crapepr.dtdpagto <= rw_crapdat.dtmvtolt THEN
      raise_application_error(-20501, '013 - Data errada. Data de pagamento:' || to_char(rw_crapepr.dtdpagto, 'dd/mm/yyyy') ||
                                      '. Data da cooperativa:' ||  to_char(rw_crapdat.dtmvtolt, 'dd/mm/yyyy'));
    END IF;
*/
--
    vr_dtcalcul := f_datapossivel ( pr_cdcooper => rw_crapepr.cdcooper
                                   ,pr_nrdconta => rw_crapepr.nrdconta
                                   ,pr_nrctremp => rw_crapepr.nrctremp
                                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                   ,pr_flgpagto => rw_crapepr.flgpagto
                                   ,pr_vlpreemp => rw_crapepr.vlpreemp  );
--
    IF  rw_crapepr.dtdpagto > vr_dtcalcul THEN
      dbms_output.put_line('Este contrato nao permite data de pagamento superior a ' ||
--      raise_application_error(-20502, 'Este contrato nao permite data de pagamento superior a ' ||
                                      to_char(vr_dtcalcul, 'dd/mm/yyyy') ||
                                    ' ! Conta:'  ||  to_char(rw_crapepr.nrdconta) ||
                                    ' Contrato:' ||  to_char(rw_crapepr.nrctremp) );
    END IF;

    IF  to_number(to_char(rw_crapepr.dtdpagto, 'dd')) > 28 THEN
      raise_application_error(-20503, 'Dia do pagamento deve ser menor que 29 ! Conta:'  ||
                                      to_char(rw_crapepr.nrdconta) ||
                                      ' Contrato:' ||  to_char(rw_crapepr.nrctremp) );
    END IF;
--
-- Grava dados
--
    OPEN cr_crapope ( pr_cdcooper => rw_crapepr.cdcooper
                     ,pr_cdoperad => vr_cdoperad);
    FETCH cr_crapope
    INTO rw_crapope;
--
    IF cr_crapope%FOUND THEN
      vr_cdagenci := rw_crapope.cdpactra;
    ELSE
      vr_cdagenci := 0;
    END IF;
--
    CLOSE cr_crapope;
--
    OPEN cr_crapadt ( pr_cdcooper => rw_crapepr.cdcooper
                     ,pr_nrdconta => rw_crapepr.nrdconta
                     ,pr_nrctremp => rw_crapepr.nrctremp
                     ,pr_tpctrato => 90); -- Empréstimo
    FETCH cr_crapadt
    INTO rw_crapadt;
--
    IF cr_crapadt%NOTFOUND THEN
      rw_crapadt.uladitiv := 0;
    END IF;
--
    CLOSE cr_crapadt;
--
    INSERT INTO crapadt ( cdcooper
                         ,nrdconta
                         ,nrctremp
                         ,nraditiv
                         ,cdaditiv
                         ,tpctrato
                         ,dtmvtolt
                         ,cdagenci
                         ,cdoperad
                         ,flgdigit
                        )
                 VALUES ( rw_crapepr.cdcooper
                         ,rw_crapepr.nrdconta
                         ,rw_crapepr.nrctremp
                         ,rw_crapadt.uladitiv
                         ,1
                         ,90 -- Empréstimo
                         ,rw_crapdat.dtmvtolt
                         ,vr_cdagenci
                         ,vr_cdoperad
                         ,0 -- Progress inclui NO
                        );
--
    INSERT INTO crapadi ( cdcooper
                         ,nrdconta
                         ,nrctremp
                         ,nraditiv
                         ,tpctrato
                         ,nrsequen
                         ,flgpagto
                         ,dtdpagto
                        )
                 VALUES ( rw_crapepr.cdcooper
                         ,rw_crapepr.nrdconta
                         ,rw_crapepr.nrctremp
                         ,rw_crapadt.uladitiv
                         ,90 -- Empréstimo
                         ,1
                         ,vr_flgpagto
                         ,rw_crapepr.dtdpagto
                        );
--
    OPEN cr_crawepr ( pr_cdcooper => rw_crapepr.cdcooper
                     ,pr_nrdconta => rw_crapepr.nrdconta
                     ,pr_nrctremp => rw_crapepr.nrctremp );
    FETCH  cr_crawepr
    INTO   rw_crawepr;
    CLOSE cr_crawepr;
--
    IF  rw_crapepr.flgpagto = 0 THEN -- Progress usa TRUE para desconto em folha de pagamento. Oracle é number. 0=sim   1=não ?
      UPDATE crapavs
      SET  insitavs = 1
      WHERE cdcooper = rw_crapepr.cdcooper
      AND   nrdconta = rw_crapepr.nrdconta
      AND   nrdocmto = rw_crapepr.nrctremp
      AND   cdhistor = 108
      AND   tpdaviso = 1
      AND   insitavs = 0;
    END IF;
--
    IF  vr_vltotpag = 0 THEN
      DECLARE
        vr_dtvencto      crawepr.dtvencto%TYPE;
      BEGIN
        vr_dtvencto         := rw_crapepr.dtdpagto;
        rw_crapepr.qtmesdec := 1;

        WHILE vr_dtvencto > vr_dtultdma LOOP

            rw_crapepr.qtmesdec := rw_crapepr.qtmesdec - 1;
            vr_dtvencto         := vr_dtvencto - to_number(to_char(vr_dtvencto, 'dd'));
        END LOOP;
      END;
--
      rw_crawepr.dtvencto := rw_crapepr.dtdpagto;
    END IF;
--
    UPDATE crawepr
    SET  flgpagto = vr_flgpagto
    --    ,dtdpagto = rw_crapepr.dtdpagto
    --    ,dtvencto = rw_crawepr.dtvencto
    WHERE rowid = rw_crawepr.rowid;
--
    UPDATE crapepr
    SET  flgpagto = vr_flgpagto
    --    ,dtdpagto = rw_crapepr.dtdpagto
    --    ,qtmesdec = rw_crapepr.qtmesdec
        ,tpdescto = 1   -- Débito em conta-corrente
    WHERE rowid = rw_crapepr.rowid;
--
    UPDATE crapcyb
    SET  dtmangar = rw_crapdat.dtmvtolt
    WHERE cdcooper = rw_crapepr.cdcooper
    AND   nrdconta = rw_crapepr.nrdconta
    AND   nrctremp = rw_crapepr.nrctremp
    AND   cdorigem = 3;
  END LOOP;

  COMMIT;
END;
/
