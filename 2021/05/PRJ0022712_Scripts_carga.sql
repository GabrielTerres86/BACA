-- PRJ0022712

-- Carga crapre tipo de produto limite de credito(1)
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
            ,1 --TPPRODUT
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
            ,1 --TPPRODUT
        FROM crappre pre
       WHERE pre.cdcooper = rw_crapcop.cdcooper
         AND pre.inpessoa = 2; --Juridica
  END LOOP;
END;
/

COMMIT;
/

--criar produto e motivos para Limite credito pre-aprovado
DECLARE 
  vr_max_prod NUMBER(5);
  
   CURSOR cr_motivos IS
    SELECT *
      FROM tbgen_motivo a
     WHERE a.cdproduto = 25
   ORDER BY a.idmotivo ;

  vr_idmotivo NUMBER(5);
  vr_cdproduto NUMBER(5);
  
BEGIN 
    SELECT MAX(cdproduto)+1 INTO vr_max_prod FROM tbcc_produto;

	
      INSERT INTO tbcc_produto
      SELECT vr_max_prod    cdproduto,
             'LIMITE CREDITO PRE-APROVADO' dsproduto,
             a.flgitem_soa,
             a.flgutiliza_interface_padrao,
             a.flgenvia_sms,
             a.flgcobra_tarifa,
             a.idfaixa_valor,
             a.flgproduto_api
      FROM tbcc_produto a
      WHERE a.cdproduto = 25;
      
      INSERT INTO tbcc_operacoes_produto (CDPRODUTO, CDOPERAC_PRODUTO, DSOPERAC_PRODUTO, TPCONTROLE)
      VALUES  (vr_max_prod, 1, 'Limite Credito Pre-Aprovado Liberado', '2');
      
    --- parte cadastramento dos motivos    
    SELECT MAX(idmotivo)
      INTO vr_idmotivo
      FROM tbgen_motivo;
      
    SELECT a.cdproduto
      INTO vr_cdproduto
      FROM tbcc_produto a
     WHERE a.dsproduto = 'LIMITE CREDITO PRE-APROVADO';
     
    FOR rw_motivo IN cr_motivos LOOP
    
      vr_idmotivo := vr_idmotivo + 1;
      INSERT INTO tbgen_motivo
        (idmotivo
        ,dsmotivo
        ,cdproduto
        ,flgreserva_sistema
        ,flgativo
        ,flgexibe
        ,flgtipo)
      VALUES
        (vr_idmotivo
        ,rw_motivo.dsmotivo
        ,vr_cdproduto -- limite credito pre-aprovado
        ,rw_motivo.flgreserva_sistema
        ,rw_motivo.flgativo
        ,rw_motivo.flgexibe
        ,rw_motivo.flgtipo);
    
    END LOOP;

    COMMIT;      
      
      
EXCEPTION
   WHEN OTHERS THEN
     dbms_output.put_line('Erro ao processar: '||SQLERRM);      
END;
/
--- até esse ponto, ja aplicados no ambiente Test.

-- Parametros TAB089
DECLARE
  vr_dscritic VARCHAR2(10000);
BEGIN
  FOR rw_crapcop IN (SELECT cdcooper
                       FROM crapcop c
                      WHERE c.flgativo = 1) LOOP
    BEGIN
      INSERT INTO craptab
        (nmsistem
        ,tptabela
        ,cdempres
        ,cdacesso
        ,tpregist
        ,dstextab
        ,cdcooper)
      VALUES
        ('CRED'
        ,'GENERI'
        ,0
        ,'PARLIMIDIGHIB'
        ,1
        ,'S 000000100,00 000000100,00'
        ,rw_crapcop.cdcooper);
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao inserir na tabela craptab - ' || SQLERRM;
        DBMS_OUTPUT.PUT_LINE(vr_dscritic);
        EXIT;
    END;
  END LOOP;

END;
/

COMMIT;
