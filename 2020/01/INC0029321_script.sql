declare
  vr_exc_saida EXCEPTION;
  
  -- Local variables here
  vr_des_text VARCHAR2(500);
  vr_dscritic VARCHAR2(4000);

  vr_cdcooper   NUMBER          := 0;                              --> Cd. Cooperativa identificada
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
  vr_nrcpfcpj   crawcrd.nrcpftit%TYPE;
  vr_dtlibera   crawcrd.dtlibera%TYPE;

  -- Cursor para retornar cooperativa com base na conta da central
  CURSOR cr_crapcop_cdagebcb (pr_cdagebcb IN crapcop.cdagebcb%TYPE) IS
  SELECT cop.cdcooper,
         cop.nmrescop
    FROM crapcop cop
   WHERE cop.cdagebcb = pr_cdagebcb;
  rw_crapcop_cdagebcb cr_crapcop_cdagebcb%ROWTYPE;

  -- Cursor para pegar o cartao cancelado do cooperado e utilizar os dados da proposta
  CURSOR cr_crawcrd_ant (pr_cdcooper  IN crawcrd.cdcooper%TYPE
                        ,pr_nrdconta  IN crawcrd.nrdconta%TYPE
                        ,pr_nrcpfcpj  IN crawcrd.nrcpftit%TYPE) IS
    SELECT crd.dddebito
          ,crd.tpdpagto
          ,crd.vllimcrd
          ,crd.cdgraupr
          ,crd.cdcooper
          ,crd.nrdconta
          ,crd.nrcrcard
          ,crd.nmextttl
          ,crd.vlsalari
      FROM crawcrd crd
     WHERE crd.cdcooper = pr_cdcooper
       AND crd.nrdconta = pr_nrdconta
       AND crd.nrcrcard = 5474080142911393; -- Cartao
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
    vr_des_text := 'CCR30204382429402210201975644160049500005474080142911393THIAGO SOUZA CUNHA     04021986000050133207205895    000200                                                                                               0004E3867B739A3597D0              0  0 THIAGO SOUZA CUNHA                                                              7564416000000066672N';

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
      vr_cdadmcrd := 15; -- (nao vem no arquivo, foi identificado no SIPAG)
      vr_dddebito := 19;
      vr_vllimcrd := 5000;
      vr_tpdpagto := 3;
      vr_flgdebcc := 0;
      vr_cdgraupr := 9;
      vr_dtlibera := '12/12/2019';
      vr_nrcpfcpj := 33207205895;

      -- Buscar as informacoes do cartao cancelado para utilizar as mesmas informacoes na proposta
      OPEN cr_crawcrd_ant(pr_cdcooper => vr_cdcooper
                         ,pr_nrdconta => vr_nrdconta
                         ,pr_nrcpfcpj => vr_nrcpfcpj);
      FETCH cr_crawcrd_ant INTO rw_crawcrd_ant;

      IF cr_crawcrd_ant%NOTFOUND THEN
    IF to_number(TRIM(substr(vr_des_text,10,2))) = 10 THEN
      vr_dscritic := 'Proposta do cartao cancelado nao encontrado!!';
      RAISE vr_exc_saida;
    END IF;
      END IF;

      vr_dddebito:= 19;--rw_crawcrd_ant.dddebito;
      vr_vllimcrd:= 5000; -- Informação está no sipag
--      vr_tpdpagto:= rw_crawcrd_ant.tpdpagto;
--      vr_cdgraupr:= rw_crawcrd_ant.cdgraupr;

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
        -- Neste caso é cartão adicional
        vr_nmextttl := rw_crawcrd_ant.nmextttl;
        vr_vlsalari := rw_crawcrd_ant.vlsalari;
        -- Montar mensagem de critica
        --vr_dscritic := 'Titular nao encontrado da conta: ' || rw_crawcrd.nrdconta;
        --RAISE vr_exc_saida;
      ELSE
        vr_nmextttl := rw_crapttl.nmextttl;
        vr_vlsalari := rw_crapttl.vlsalari;
        -- Apenas fechar o cursor
        CLOSE cr_crapttl;
      END IF;

      -- obter numero do contrato (sequencial)
      vr_nrctrcrd := fn_sequence('CRAPMAT','NRCTRCRD', vr_cdcooper);

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
            insitdec,
            dtlibera,
            dtentreg)
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
            0,                                                -- flgprcrd
            4,                                                -- insitcrd
            2,                                                -- insitdec
            vr_dtlibera,
            vr_dtlibera)
            RETURNING ROWID INTO rw_crawcrd.rowid;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir crawcrd: '||SQLERRM;
          RAISE vr_exc_saida;
      END;

      -- Obtem ponteiro do registro de proposta recém criado
      OPEN cr_crawcrd_rowid(pr_rowid => rw_crawcrd.rowid);
      FETCH cr_crawcrd_rowid INTO rw_crawcrd;

      BEGIN
        INSERT INTO crapcrd
           (cdcooper,
            nrdconta,
            nrcrcard,
            nrcpftit,
            nmtitcrd,
            dddebito,
            cdlimcrd,
            dtvalida,
            nrctrcrd,
            cdmotivo,
            nrprotoc,
            cdadmcrd,
            tpcartao,
            dtcancel,
            flgdebit)
        VALUES
           (rw_crawcrd.cdcooper,
            rw_crawcrd.nrdconta,
            rw_crawcrd.nrcrcard,
            rw_crawcrd.nrcpftit,
            rw_crawcrd.nmtitcrd,
            rw_crawcrd.dddebito,
            rw_crawcrd.cdlimcrd,
            rw_crawcrd.dtvalida,
            rw_crawcrd.nrctrcrd,
            rw_crawcrd.cdmotivo,
            rw_crawcrd.nrprotoc,
            rw_crawcrd.cdadmcrd,
            rw_crawcrd.tpcartao,
            rw_crawcrd.dtcancel,
            rw_crawcrd.flgdebit);
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir crapcrd: ' ||
                         ' Coop: ' || rw_crawcrd.cdcooper ||
                         ' Conta: ' ||  rw_crawcrd.nrdconta ||
                         ' Cartao: ' || rw_crawcrd.nrcrcard ||
                         ' - Erro: ' || SQLERRM ;
          RAISE vr_exc_saida;
      END;
    END IF;
  -- 
  -- Atualizar CRAPCRD cartão 5474080006389249 OK
  BEGIN
    update crapcrd c
       set c.dtcancel = '29/03/2018', c.cdmotivo = 16, c.cdlimcrd = 132
     where c.cdcooper =  7 and c.nrdconta = 66672 and c.nrcrcard = 5474080006389249;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      dbms_output.put_line('Cartão 5474080006389249 não encontrado na CRAPCRP');
        WHEN OTHERS THEN
          vr_dscritic := 'Erro update crapcrd 5474080006389249: '||SQLERRM;
          RAISE vr_exc_saida;
    END;
  --
  -- Atualizar CRAPCRD cartão 5474080006389256 OK
  BEGIN
    update crapcrd c
       set c.cdlimcrd = 132
     where c.cdcooper =  7 and c.nrdconta = 66672 and c.nrcrcard = 5474080006389256;  
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      dbms_output.put_line('Cartão 5474080006389256 não encontrado na CRAPCRP');
        WHEN OTHERS THEN
          vr_dscritic := 'Erro update crapcrd 5474080006389256: '||SQLERRM;
          RAISE vr_exc_saida;
      END;
  -- Atualizar CRAPCRD cartão 5474080022033953 OK
  BEGIN
    update crapcrd c
       set c.cdlimcrd = 132, c.dtvalida = '30/09/2022', c.dtcancel = '10/08/2017', c.cdmotivo = 10
     where c.cdcooper =  7 and c.nrdconta = 66672 and c.nrcrcard = 5474080022033953;  
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      dbms_output.put_line('Cartão 5474080022033953 não encontrado na CRAPCRP');
        WHEN OTHERS THEN
          vr_dscritic := 'Erro update crapcrd 5474080022033953: '||SQLERRM;
          RAISE vr_exc_saida;
    END;
  -- Atualizar CRAWCRD cartão 5474080024479105 OK
  BEGIN
    update crawcrd w
       set w.cdgraupr = 5, w.dtsolici = '21/07/2017'
     where w.cdcooper =  7 and w.nrdconta = 66672 and w.nrcrcard = 5474080024479105;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      dbms_output.put_line('Cartão 5474080024479105 não encontrado na CRAWCRP');
        WHEN OTHERS THEN
          vr_dscritic := 'Erro update crawcrd 5474080024479105: '||SQLERRM;
          RAISE vr_exc_saida;
    END;
  -- Atualizar CRAPCRD cartão 5474080024479105 OK
  BEGIN
    update crapcrd c
       set c.cdlimcrd = 132, c.dtvalida = '30/09/2022', c.dtcancel = '13/02/2019', c.cdmotivo = 10
     where c.cdcooper =  7 and c.nrdconta = 66672 and c.nrcrcard = 5474080024479105;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      dbms_output.put_line('Cartão 5474080024479105 não encontrado na CRAPCRP');
        WHEN OTHERS THEN
          vr_dscritic := 'Erro update crapcrd 5474080024479105: '||SQLERRM;
          RAISE vr_exc_saida;
    END;
  -- Atualizar CRAPCRD cartão 5474080060391214 OK
  BEGIN
    update crapcrd c
       set c.cdlimcrd = 132, c.dddebito = 19
     where c.cdcooper =  7 and c.nrdconta = 66672 and c.nrcrcard = 5474080060391214;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      dbms_output.put_line('Cartão 5474080060391214 não encontrado na CRAPCRP');
        WHEN OTHERS THEN
          vr_dscritic := 'Erro update crapcrd 5474080060391214: '||SQLERRM;
          RAISE vr_exc_saida;
    END;
  -- Atualizar CRAWCRD cartão 5474080060391214 OK
  BEGIN
    update crawcrd w
       set w.cdgraupr = 5
     where w.cdcooper =  7 and w.nrdconta = 66672 and w.nrcrcard = 5474080060391214;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      dbms_output.put_line('Cartão 5474080060391214 não encontrado na CRAWCRP');
        WHEN OTHERS THEN
          vr_dscritic := 'Erro update crawcrd 5474080060391214: '||SQLERRM;
          RAISE vr_exc_saida;
    END;
  -- Atualizar CRAPCRD cartão 5474080073963249 OK
  BEGIN
    update crapcrd c
       set c.cdlimcrd = 25, c.dtcancel = '20/08/2019', c.cdmotivo = 10
     where c.cdcooper =  7 and c.nrdconta = 66672 and c.nrcrcard = 5474080073963249;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      dbms_output.put_line('Cartão 5474080073963249 não encontrado na CRAPCRP');
        WHEN OTHERS THEN
          vr_dscritic := 'Erro update crapcrd 5474080073963249: '||SQLERRM;
          RAISE vr_exc_saida;
    END;
  -- Atualizar CRAWCRD cartão 5474080073963249 OK
  BEGIN
    update crawcrd w
       set w.cdlimcrd = 29, w.vllimcrd = 5000
     where w.cdcooper =  7 and w.nrdconta = 66672 and w.nrcrcard = 5474080073963249;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      dbms_output.put_line('Cartão 5474080073963249 não encontrado na CRAWCRP');
        WHEN OTHERS THEN
          vr_dscritic := 'Erro update crawcrd 5474080073963249: '||SQLERRM;
          RAISE vr_exc_saida;
    END;
  -- Atualizar CRAPCRD cartão 5474080073963371 OK
  BEGIN
    update crapcrd c
       set c.cdlimcrd = 21
     where c.cdcooper =  7 and c.nrdconta = 66672 and c.nrcrcard = 5474080073963371;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      dbms_output.put_line('Cartão 5474080073963371 não encontrado na CRAPCRP');
        WHEN OTHERS THEN
          vr_dscritic := 'Erro update crapcrd 5474080073963371: '||SQLERRM;
          RAISE vr_exc_saida;
    END;
  -- Atualizar CRAPCRD cartão 5474080073963371 OK
  BEGIN
    update crawcrd w
       set w.cdlimcrd = 23, w.vllimcrd = 3000
     where w.cdcooper =  7 and w.nrdconta = 66672 and w.nrcrcard = 5474080073963371;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      dbms_output.put_line('Cartão 5474080073963371 não encontrado na CRAWCRP');
        WHEN OTHERS THEN
          vr_dscritic := 'Erro update crawcrd 5474080073963371: '||SQLERRM;
          RAISE vr_exc_saida;
    END;
  -- Atualizar CRAPCRD cartão 5474080073963504 OK
  BEGIN
    update crapcrd c
       set c.cdlimcrd = 21
     where c.cdcooper =  7 and c.nrdconta = 66672 and c.nrcrcard = 5474080073963504;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      dbms_output.put_line('Cartão 5474080073963504 não encontrado na CRAPCRP');
        WHEN OTHERS THEN
          vr_dscritic := 'Erro update crapcrd 5474080073963504: '||SQLERRM;
          RAISE vr_exc_saida;
    END;
  -- Atualizar CRAPCRD cartão 5474080073963504 OK
  BEGIN
    update crawcrd w
       set w.cdlimcrd = 23, w.vllimcrd = 3000
     where w.cdcooper =  7 and w.nrdconta = 66672 and w.nrcrcard = 5474080073963504;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      dbms_output.put_line('Cartão 5474080073963504 não encontrado na CRAWCRP');
        WHEN OTHERS THEN
          vr_dscritic := 'Erro update crawcrd 5474080073963504: '||SQLERRM;
          RAISE vr_exc_saida;
    END;
  -- Atualizar CRAPCRD cartão 5474080073963637 OK
  BEGIN
    update crapcrd c
       set c.cdlimcrd = 21
     where c.cdcooper =  7 and c.nrdconta = 66672 and c.nrcrcard = 5474080073963637;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      dbms_output.put_line('Cartão 5474080073963637 não encontrado na CRAPCRP');
        WHEN OTHERS THEN
          vr_dscritic := 'Erro update crapcrd 5474080073963637: '||SQLERRM;
          RAISE vr_exc_saida;
    END;
  -- Atualizar CRAPCRD cartão 5474080073963637 OK
  BEGIN
    update crawcrd w
       set w.cdlimcrd = 23, w.vllimcrd = 3000
     where w.cdcooper =  7 and w.nrdconta = 66672 and w.nrcrcard = 5474080073963637;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      dbms_output.put_line('Cartão 5474080073963637 não encontrado na CRAWCRP');
        WHEN OTHERS THEN
          vr_dscritic := 'Erro update crawcrd 5474080073963637: '||SQLERRM;
          RAISE vr_exc_saida;
    END;
  -- Atualizar CRAWCRD cartão 5474080102778139 OK
  BEGIN
    update crawcrd w
       set w.cdgraupr = 5, w.dtsolici = '30/01/2019'
     where w.cdcooper =  7 and w.nrdconta = 66672 and w.nrcrcard = 5474080102778139;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      dbms_output.put_line('Cartão 5474080102778139 não encontrado na CRAWCRP');
        WHEN OTHERS THEN
          vr_dscritic := 'Erro update crawcrd 5474080102778139: '||SQLERRM;
          RAISE vr_exc_saida;
    END;
  -- Atualizar CRAPCRD cartão 5474080117457836 OK
  BEGIN
    update crapcrd c
       set c.cdlimcrd = 17
     where c.cdcooper =  7 and c.nrdconta = 66672 and c.nrcrcard = 5474080117457836;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      dbms_output.put_line('Cartão 5474080117457836 não encontrado na CRAPCRP');
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir crapcrd 5474080117457836: '||SQLERRM;
          RAISE vr_exc_saida;
    END;
  -- Atualizar CRAWCRD cartão 5474080117457836 OK
  BEGIN
    update crawcrd w
       set w.cdlimcrd = 20, w.vllimcrd = 2000
     where w.cdcooper =  7 and w.nrdconta = 66672 and w.nrcrcard = 5474080117457836;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      dbms_output.put_line('Cartão 5474080117457836 não encontrado na CRAWCRP');
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir crawcrd 5474080117457836: '||SQLERRM;
          RAISE vr_exc_saida;
    END;
  -- Atualizar CRAPCRD cartão 5474080122893140 OK
  BEGIN
    update crapcrd c
       set c.cdlimcrd = 25, c.dddebito = 19, c.dtcancel = '13/12/2019', c.cdmotivo = 10
     where c.cdcooper =  7 and c.nrdconta = 66672 and c.nrcrcard = 5474080122893140;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      dbms_output.put_line('Cartão 5474080122893140 não encontrado na CRAPCRD');
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir crapcrd 5474080122893140: '||SQLERRM;
          RAISE vr_exc_saida;
    END;
  -- Atualizar CRAWCRD cartão 5474080122893140 OK
  BEGIN
    update crawcrd w
       set w.cdlimcrd = 29, w.vllimcrd = 5000, w.dddebito = 19, w.cdgraupr = 9
     where w.cdcooper =  7 and w.nrdconta = 66672 and w.nrcrcard = 5474080122893140;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      dbms_output.put_line('Cartão 5474080122893140 não encontrado na CRAWCRD');
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir crawcrd 5474080122893140: '||SQLERRM;
          RAISE vr_exc_saida;
    END;

    commit;
	dbms_output.put_line('Sucesso ao executar: Script do INC0029321 - Ajuste da situacao do cartao');
  EXCEPTION
    WHEN vr_exc_saida THEN
      dbms_output.put_line('Erro: ' || vr_dscritic);

    WHEN OTHERS THEN
      dbms_output.put_line('Erro: ' || SQLERRM);
  END;
end;
/
