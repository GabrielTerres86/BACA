/* Baca para inserir o cartão do cooperado 
 *
 * 
 * CCR30210222388922803201975644440151970005127070189354459RONALDO QUAIOTTO       01101980201010102658687931    000101                                                                                               000F59ECEF4D92A47EC4133664        SSPSCRONALDO QUAIATTO                                                                7564444000000237850N
 *
 * Lucas Ranghetti 
 */
declare 
  vr_exc_saida EXCEPTION;

  -- Local variables here
  vr_des_text VARCHAR2(500);
  vr_dscritic VARCHAR2(4000);
  
  vr_cdcooper   NUMBER          := 0;                              --> Cd. Coopertaiva identificada
  vr_nrdconta   NUMBER          := 0;                              --> Nr. Conta a Debitar
  vr_cdagebcb   NUMBER          := 0;                              --> Cd. Agencia do Bancoob da Cooperativa
  vr_vllimcrd   crawcrd.vllimcrd%TYPE;                             --> Valor de limite de credito
  vr_nmextttl   crapttl.nmextttl%TYPE;                             --> Nome Titular
  vr_tpdpagto   NUMBER          := 0;                              --> Tp de Pagto do cartão
  vr_flgdebcc   NUMBER          := 0;                              --> flg para debitar em conta
  vr_dddebito   NUMBER          := 0;                              --> Dia Déb. em Conta-corrente
  vr_cdlimcrd   crawcrd.cdlimcrd%TYPE;                             --> Codigo da linha do valor de credito
  vr_nrctrcrd   crawcrd.nrctrcrd%TYPE;                             --> Nr. Contrato
  vr_nrseqcrd   crawcrd.nrseqcrd%TYPE;                             --> Nr. Sequencial do Contrato para o Bancoob
  vr_flgdebit   crawcrd.flgdebit%TYPE;                             --> Verifica se o cartao possui funcao de debito habilitada
  vr_vlsalari   crapttl.vlsalari%TYPE;                             --> Salario
  vr_cdadmcrd   crapacb.cdadmcrd%TYPE;                             --> Administradora do Cartao
  vr_cdgraupr   crawcrd.cdgraupr%TYPE;   
  vr_dtsolici   crawcrd.dtsolici%TYPE;                         
  
  -- Cursor para retornar cooperativa com base na conta da central
  CURSOR cr_crapcop_cdagebcb (pr_cdagebcb IN crapcop.cdagebcb%TYPE) IS
  SELECT cop.cdcooper,
         cop.nmrescop
    FROM crapcop cop
   WHERE cop.cdagebcb = pr_cdagebcb;
  rw_crapcop_cdagebcb cr_crapcop_cdagebcb%ROWTYPE;
  
  -- Cursor para pegar o cartao cancelado do cooperado e utilizar os dados da proposta
  CURSOR cr_crawcrd_ant (pr_cdcooper  IN crawcrd.cdcooper%TYPE
                        ,pr_nrdconta  IN crawcrd.nrdconta%TYPE) IS
    SELECT crd.dddebito
          ,crd.tpdpagto
          ,crd.vllimcrd
          ,crd.cdgraupr
          ,crd.cdcooper
          ,crd.nrdconta
          ,crd.nrcrcard
      FROM crawcrd crd
     WHERE crd.cdcooper = pr_cdcooper
       AND crd.nrdconta = pr_nrdconta
       AND crd.nrcrcard = 5127070189354459; -- Cartao 
  rw_crawcrd_ant cr_crawcrd_ant%ROWTYPE;
  
  -- Tabela de Limite de Credito
  CURSOR cr_craptlc(pr_cdcooper craptlc.cdcooper%TYPE,
                    pr_cdadmcrd craptlc.cdadmcrd%TYPE,
                    pr_vllimcrd craptlc.vllimcrd%TYPE) IS
    SELECT craptlc.cdlimcrd
      FROM craptlc
     WHERE craptlc.cdcooper = pr_cdcooper
       AND craptlc.cdadmcrd = pr_cdadmcrd
       AND craptlc.vllimcrd = pr_vllimcrd
       AND craptlc.dddebito = 0           
       AND ROWNUM = 1;
  rw_craptlc cr_craptlc%ROWTYPE;
  
  -- cursor para cooperado PF
  CURSOR cr_crapttl (pr_cdcooper IN crapttl.cdcooper%TYPE,
                     pr_nrdconta IN crapttl.nrdconta%TYPE,
                     pr_nrcpfcgc IN crapttl.nrcpfcgc%TYPE) IS
  SELECT ttl.idseqttl
        ,ttl.nrcpfcgc
        ,ttl.vlsalari
        ,ttl.nmextttl
    FROM crapttl ttl
   WHERE ttl.cdcooper = pr_cdcooper AND
         ttl.nrdconta = pr_nrdconta AND
         ttl.nrcpfcgc = pr_nrcpfcgc;
  rw_crapttl cr_crapttl%ROWTYPE;
  
  -- cursor para busca de proposta de cartão
  CURSOR cr_crawcrd (pr_cdcooper IN crawcrd.cdcooper%TYPE,
                     pr_nrdconta IN crawcrd.nrdconta%TYPE,
                     pr_nrcpftit IN crawcrd.nrcpftit%TYPE,
                     pr_cdadmcrd IN crawcrd.cdadmcrd%TYPE,
                     pr_rowid    IN ROWID := NULL) IS
  SELECT pcr.cdcooper
        ,pcr.nrdconta
        ,pcr.nrcrcard
        ,pcr.nrcpftit
        ,pcr.nmtitcrd
        ,pcr.dddebito
        ,pcr.cdlimcrd
        ,pcr.dtvalida
        ,pcr.nrctrcrd
        ,pcr.cdmotivo
        ,pcr.nrprotoc
        ,pcr.cdadmcrd
        ,pcr.tpcartao
        ,pcr.nrcctitg
        ,pcr.vllimcrd
        ,pcr.flgctitg
        ,pcr.dtmvtolt
        ,pcr.nmextttl
        ,pcr.flgprcrd
        ,pcr.tpdpagto
        ,pcr.flgdebcc
        ,pcr.tpenvcrd
        ,pcr.vlsalari
        ,pcr.insitcrd
        ,pcr.dtnasccr
        ,pcr.nrdoccrd
        ,pcr.dtcancel
        ,pcr.flgdebit
        ,pcr.rowid
    FROM crawcrd pcr
   WHERE pcr.cdcooper = pr_cdcooper  AND
         pcr.nrdconta = pr_nrdconta  AND
         pcr.nrcpftit = pr_nrcpftit  AND
         pcr.cdadmcrd = pr_cdadmcrd  AND
         (pcr.rowid <> pr_rowid OR pr_rowid IS NULL) AND
         pcr.dtcancel IS NULL;
  rw_crawcrd cr_crawcrd%ROWTYPE;
      
  -- Cursor do cartao recem criado
  CURSOR cr_crawcrd_rowid (pr_rowid IN ROWID) IS
  SELECT pcr.cdcooper
        ,pcr.nrdconta
        ,pcr.nrcrcard
        ,pcr.nrcpftit
        ,pcr.nmtitcrd
        ,pcr.dddebito
        ,pcr.cdlimcrd
        ,pcr.dtvalida
        ,pcr.nrctrcrd
        ,pcr.cdmotivo
        ,pcr.nrprotoc
        ,pcr.cdadmcrd
        ,pcr.tpcartao
        ,pcr.nrcctitg
        ,pcr.vllimcrd
        ,pcr.flgctitg
        ,pcr.dtmvtolt
        ,pcr.nmextttl
        ,pcr.flgprcrd
        ,pcr.tpdpagto
        ,pcr.flgdebcc
        ,pcr.tpenvcrd
        ,pcr.vlsalari
        ,pcr.insitcrd
        ,pcr.dtnasccr
        ,pcr.nrdoccrd
        ,pcr.dtcancel
        ,pcr.flgdebit
        ,pcr.rowid
    FROM crawcrd pcr
   WHERE ROWID = pr_rowid;
  
  /* Buscar o próximo NRSEQCRD, conforme regras */
  FUNCTION fn_sequence_nrseqcrd(pr_cdcooper IN NUMBER) RETURN NUMBER IS

    -- Buscar a sequencia
    CURSOR cr_crawcrd(pr_nrseqcrd  NUMBER) IS
      SELECT 1
        FROM crawcrd crd
       WHERE crd.nrseqcrd = pr_nrseqcrd
         AND crd.cdcooper = pr_cdcooper;

    -- Variáveis
    vr_nrseqret     NUMBER;
    vr_nrretsel     NUMBER;

  BEGIN

    LOOP
      -- Lê a próxima sequencia da FN_SEQUENCE, normalmente
      vr_nrseqret := fn_sequence(pr_nmtabela => 'CRAWCRD'
                                ,pr_nmdcampo => 'NRSEQCRD'
                                ,pr_dsdchave => to_char(pr_cdcooper));

      -- verificar se a sequencia lida já está sendo utilizada
      OPEN  cr_crawcrd(vr_nrseqret);
      FETCH cr_crawcrd INTO vr_nrretsel;

      -- Se não encontrar nenhum registro com este sequencial
      EXIT WHEN cr_crawcrd%NOTFOUND;

      -- Fecha o cursor
      CLOSE cr_crawcrd;
    END LOOP;

    -- Se o cursor ainda está aberto, fecha!
    IF cr_crawcrd%ISOPEN THEN
      CLOSE cr_crawcrd;
    END IF;

    RETURN vr_nrseqret;

  END fn_sequence_nrseqcrd;
  
  
begin
  BEGIN
    vr_des_text := 'CCR30210222388922803201975644440151970005127070189354459RONALDO QUAIOTTO       01101980201010102658687931    000101                                                                                               000F59ECEF4D92A47EC4133664        SSPSCRONALDO QUAIATTO                                                                7564444000000237850N';

    -- se for DADOS DO CARTÃO
    IF substr(vr_des_text,5,2) = '02'  THEN
                
      -- Guardar contas do arquivo para verificação
      vr_nrdconta := to_number(TRIM(substr(vr_des_text,337,12)));
      vr_cdlimcrd := 0;
      vr_dtsolici := to_date(substr(vr_des_text,17,8),'DDMMRRRR');
      
      -- Agencia do banco
      vr_cdagebcb := to_number(substr(vr_des_text,333,4));
      -- Se vier agencia bancoob zerada, obtem do Nr. da Conta Cartão
      IF vr_cdagebcb = 0 THEN
        vr_cdagebcb := to_number(substr(vr_des_text,28,4));
      END IF;

      -- busca a cooperativa com base no cod. da agencia central do arquivo
      OPEN cr_crapcop_cdagebcb(pr_cdagebcb => vr_cdagebcb);
      FETCH cr_crapcop_cdagebcb INTO rw_crapcop_cdagebcb;
      IF cr_crapcop_cdagebcb%NOTFOUND THEN
        -- Fechar o cursor pois havera raise
        CLOSE cr_crapcop_cdagebcb;
        -- Montar mensagem de critica
        vr_dscritic := 'Codigo da agencia do Bancoob ' || to_char(vr_cdagebcb) ||
                       ' nao possui Cooperativa correspondente.';
        RAISE vr_exc_saida;
                  
      ELSE
        -- Fecha cursor cooperativa
        CLOSE cr_crapcop_cdagebcb;
      END IF;                

      -- faz associação da variavel cod cooperativa;
      vr_cdcooper := rw_crapcop_cdagebcb.cdcooper;
                
      -- Limpar as variáveis para evitar valores da iteração anterior
      vr_cdadmcrd := 12; -- Classico (nao vem no arquivo, foi identificado no SIPAG)
      vr_flgdebcc := 1;
      
      vr_dddebito:= 19;
      vr_vllimcrd:= 1700; -- Informação está no sipag
      vr_tpdpagto:= 1;
      vr_cdgraupr:= 5;
                  
      -- Para cada cartao, vamos buscar o valor de limite de credito cadastrado
      OPEN cr_craptlc(pr_cdcooper => vr_cdcooper,
                      pr_cdadmcrd => vr_cdadmcrd,
                      pr_vllimcrd => vr_vllimcrd);
      FETCH cr_craptlc INTO rw_craptlc;
      IF cr_craptlc%FOUND THEN
        CLOSE cr_craptlc;
        vr_cdlimcrd := rw_craptlc.cdlimcrd;
      ELSE
        CLOSE cr_craptlc;
        vr_cdlimcrd := 0;
      END IF;  
              
      -- Busca registro pessoa física
      OPEN cr_crapttl(pr_cdcooper => vr_cdcooper,
                      pr_nrdconta => vr_nrdconta,
                      pr_nrcpfcgc => TO_NUMBER(substr(vr_des_text,95,15)));
      FETCH cr_crapttl INTO rw_crapttl;
      -- Se nao encontrar
      IF cr_crapttl%NOTFOUND THEN
        -- Fechar o cursor
        CLOSE cr_crapttl;
        -- Montar mensagem de critica
        vr_dscritic := 'Titular nao encontrado da conta: ' || rw_crawcrd.nrdconta;
        RAISE vr_exc_saida;
      ELSE
        vr_nmextttl := rw_crapttl.nmextttl;
        vr_vlsalari := rw_crapttl.vlsalari;
        -- Apenas fechar o cursor
        CLOSE cr_crapttl;
      END IF;

      -- obter numero do contrato (sequencial)
      vr_nrctrcrd := 39122;
                    
      /* Caso a Conta vinculada estiver 0, significa que o cartao eh do tipo OUTROS,
         para os cartoes do tipo OUTROS sera puro CREDITO... */
      IF to_number(TRIM(substr(vr_des_text,337,12))) = 0 THEN
         vr_flgdebit := 0;
      ELSE
         vr_flgdebit := 1;
      END IF;                  
                    
      -- Deve buscar o contrato para inserir
      vr_nrseqcrd := fn_sequence_nrseqcrd(pr_cdcooper => vr_cdcooper);
      
      -- Cria nova proposta de cartão de crédito
      BEGIN
        INSERT INTO crawcrd
           (nrdconta,
            nrcrcard,
            nrcctitg,
            nrcpftit,
            vllimcrd,
            flgctitg,
            dtmvtolt,
            nmextttl,
            tpdpagto,
            flgdebcc,
            vlsalari,
            dddebito,
            cdlimcrd,
            tpcartao,
            dtnasccr,
            nrdoccrd,
            nmtitcrd,
            nrctrcrd,
            cdadmcrd,
            cdcooper,
            nrseqcrd,
            dtpropos,
            dtsolici,
            flgdebit,
            cdgraupr,
            dtvalida,
            flgimpnp,
            tpenvcrd,
            flgprcrd,           
            insitcrd,
            insitdec)
        VALUES
           (vr_nrdconta,                                      -- nrdconta
            TO_NUMBER(substr(vr_des_text,38,19)),             -- nrcrcard
            TO_NUMBER(substr(vr_des_text,25,13)),             -- nrcctitg
            TO_NUMBER(substr(vr_des_text,95,15)),             -- nrcpftit
            vr_vllimcrd,                                      -- vllimcrd
            3,                                                -- flgctitg
            TRUNC(SYSDATE),                                   -- dtmvtolt
            vr_nmextttl,                                      -- nmextttl
            vr_tpdpagto,                                      -- tpdpagto
            vr_flgdebcc,                                      -- flgdebcc
            vr_vlsalari,                                      -- vlsalari
            vr_dddebito,                                      -- dddebito
            vr_cdlimcrd,                                      -- cdlimcrd
            2,                                                -- tpcartao
            TO_DATE(substr(vr_des_text,80,8), 'DDMMYYYY'),    -- dtnasccr
            substr(vr_des_text,230,15),                       -- nrdoccrd
            TRIM(substr(vr_des_text,57,23)),                  -- nmtitcrd
            vr_nrctrcrd,                                      -- nrctrcrd
            vr_cdadmcrd,                                      -- cdadmcrd
            vr_cdcooper,                                      -- cdcooper
            vr_nrseqcrd,                                      -- nrseqcrd
            vr_dtsolici,                                      -- dtpropos
            vr_dtsolici,                                      -- dtsolici
            vr_flgdebit,                                      -- flgdebit
            vr_cdgraupr,                                      -- cdgraupr
            to_date('30/11/2023','dd/mm/rrrr'),               -- dtvalida
            1,                                                -- flgimpnp
            1,                                                -- tpenvcrd
            1,                                                -- flgprcrd
            3,                                                -- insitcrd
            2)                                                -- insitdec
            RETURNING ROWID INTO rw_crawcrd.rowid;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir crawcrd: '||SQLERRM;
          RAISE vr_exc_saida;
      END;
      
    END IF;

  insert into crawcrd (NRCRCARD, NRDCONTA, NMTITCRD, NRCPFTIT, CDGRAUPR, VLSALARI, VLSALCON, VLOUTRAS, VLALUGUE, DDDEBITO, CDLIMCRD, DTPROPOS, CDOPERAD, INSITCRD, NRCTRCRD, DTMVTOLT, CDAGENCI, CDBCCXLT, NRDOLOTE, NRSEQDIG, DTSOLICI, DTENTREG, DTVALIDA, DTANUIDA, VLANUIDA, INANUIDA, QTANUIDA, QTPARCAN, DTLIBERA, DTCANCEL, CDMOTIVO, NRPROTOC, DTENTR2V, TPCARTAO, CDADMCRD, DTNASCCR, NRDOCCRD, DTULTVAL, NRCTAAV1, FLGIMPNP, NMDAVAL1, DSCPFAV1, DSENDAV1##1, DSENDAV1##2, NRCTAAV2, NMDAVAL2, DSCPFAV2, DSENDAV2##1, DSENDAV2##2, DSCFCAV1, DSCFCAV2, NMCJGAV1, NMCJGAV2, DTSOL2VI, VLLIMDLR, CDCOOPER, FLGCTITG, DTECTITG, FLGDEBCC, FLGRMCOR, FLGPROTE, FLGMALAD, NRCCTITG, DT2VIASN, NRREPINC, NRREPENT, NRREPLIM, NRREPVEN, NRREPSEN, NRREPCAR, NRREPCAN, DDDEBANT, NMEXTTTL, TPENVCRD, TPDPAGTO, VLLIMCRD, NMEMPCRD, FLGPRCRD, NRSEQCRD, CDORIGEM, FLGDEBIT, DTREJEIT, CDOPEEXC, CDAGEEXC, DTINSEXC, CDOPEORI, CDAGEORI, DTINSORI, DTREFATU, INSITDEC, DTAPROVA, DSPROTOC, DSJUSTIF, CDOPEENT, INUPGRAD, CDOPESUP, DSOBSCMT, DTENVEST, DTENEFES)
  values (5474080105603151.00, 19321, 'MAIARA R H MOREIRA', 8083664910.00, 0, 0.00, 0.00, 0.00, 0.00, 32, 0, to_date('19-02-2019', 'dd-mm-yyyy'), null, 3, 1345766, to_date('08-01-2019 16:42:29', 'dd-mm-yyyy hh24:mi:ss'), 0, 0, 0, 0, null, null, null, null, 0.00, 0, 0, 0, to_date('19-02-2019', 'dd-mm-yyyy'), null, 0, 0.00, to_date('19-02-2019', 'dd-mm-yyyy'), 2, 17, to_date('17-01-1990', 'dd-mm-yyyy'), '04675330961', null, 0, 0, null, null, null, null, 0, null, null, null, null, null, null, null, null, null, 0.00, 1, 3, null, 1, 0, 0, 0, 7563239436341, null, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, ' ', 1, 1, 0.00, 'MHM ESTAMPAS', 1, 581107, 0, 1, null, ' ', 0, null, ' ', 0, null, to_date('11-03-2019', 'dd-mm-yyyy'), 1, null, null, null, null, 0, null, null, null, null);

  insert into crawcrd (NRCRCARD, NRDCONTA, NMTITCRD, NRCPFTIT, CDGRAUPR, VLSALARI, VLSALCON, VLOUTRAS, VLALUGUE, DDDEBITO, CDLIMCRD, DTPROPOS, CDOPERAD, INSITCRD, NRCTRCRD, DTMVTOLT, CDAGENCI, CDBCCXLT, NRDOLOTE, NRSEQDIG, DTSOLICI, DTENTREG, DTVALIDA, DTANUIDA, VLANUIDA, INANUIDA, QTANUIDA, QTPARCAN, DTLIBERA, DTCANCEL, CDMOTIVO, NRPROTOC, DTENTR2V, TPCARTAO, CDADMCRD, DTNASCCR, NRDOCCRD, DTULTVAL, NRCTAAV1, FLGIMPNP, NMDAVAL1, DSCPFAV1, DSENDAV1##1, DSENDAV1##2, NRCTAAV2, NMDAVAL2, DSCPFAV2, DSENDAV2##1, DSENDAV2##2, DSCFCAV1, DSCFCAV2, NMCJGAV1, NMCJGAV2, DTSOL2VI, VLLIMDLR, CDCOOPER, FLGCTITG, DTECTITG, FLGDEBCC, FLGRMCOR, FLGPROTE, FLGMALAD, NRCCTITG, DT2VIASN, NRREPINC, NRREPENT, NRREPLIM, NRREPVEN, NRREPSEN, NRREPCAR, NRREPCAN, DDDEBANT, NMEXTTTL, TPENVCRD, TPDPAGTO, VLLIMCRD, NMEMPCRD, FLGPRCRD, NRSEQCRD, CDORIGEM, FLGDEBIT, DTREJEIT, CDOPEEXC, CDAGEEXC, DTINSEXC, CDOPEORI, CDAGEORI, DTINSORI, DTREFATU, INSITDEC, DTAPROVA, DSPROTOC, DSJUSTIF, CDOPEENT, INUPGRAD, CDOPESUP, DSOBSCMT, DTENVEST, DTENEFES)
  values (5158940036941132.00, 8322929, 'DIENIFER F COMIN', 10108212963.00, 5, 1287.00, 0.00, 0.00, 0.00, 19, 20, to_date('11-03-2019', 'dd-mm-yyyy'), 'f0013336', 3, 1358618, to_date('11-03-2019 14:41:28', 'dd-mm-yyyy hh24:mi:ss'), 0, 0, 0, 0, to_date('11-03-2019', 'dd-mm-yyyy'), null, null, null, 0.00, 0, 0, 0, to_date('12-03-2019', 'dd-mm-yyyy'), null, 0, 0.00, null, 2, 13, to_date('28-10-1994', 'dd-mm-yyyy'), '5207222', null, 0, 1, ' ', ' ', ' 0', ' -  - 00000.000 - ', 0, ' ', ' ', ' 0', ' -  - 00000.000 - ', ' ', ' ', ' ', ' ', null, 0.00, 1, 3, null, 1, 0, 0, 0, 7563239455755, null, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 19, 'DIENIFER F. COMIN', 1, 1, 2000.00, '0', 1, 590358, 0, 1, null, ' ', 0, null, 'f0013336', 40, to_date('11-03-2019', 'dd-mm-yyyy'), to_date('12-03-2019', 'dd-mm-yyyy'), 2, null, 'PoliticaCartaoCreditoPF_286529950', null, null, 0, null, null, null, null);
  
  commit;
  
  EXCEPTION
    WHEN vr_exc_saida THEN
      dbms_output.put_line('Erro: ' || vr_dscritic);
    
    WHEN OTHERS THEN
      dbms_output.put_line('Erro: ' || SQLERRM);
  END;  
end;
