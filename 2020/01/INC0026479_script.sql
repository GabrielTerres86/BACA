/* Baca para ajustar os cartões do cooperado 
 *
 * Yuri - Mouts
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
  vr_nrcpfcpj   crawcrd.nrcpftit%TYPE;
  
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
            ,pr_nrcrcard  IN crawcrd.nrcrcard%TYPE) IS
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
       AND crd.nrcrcard = pr_nrcrcard; -- Cartao 
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
  -- Item 1 do arquivo de evidências
    -- Exclusão do cartão 5474080000007344 da conta 359408. Este cartão não existe
  BEGIN
    delete crawcrd c where c.cdcooper = 13 and c.nrdconta = 359408 and c.nrcrcard = 5474080000007344;
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('Erro na exclusão da crawcrd conta 359408');
  END;
  
  -- remover o vínculo da conta integração 7564457025077 com a conta 359408, pois esta relação não existe.
  BEGIN
      delete tbcrd_conta_cartao c where c.cdcooper = 13 and c.nrdconta = 359408 and c.nrconta_cartao = 7564457025077;
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('Erro na exclusão da tbcrd_conta_cartao conta 359408');
  END;
  
  -- Item 2 do arquivo de evidencias
  -- ajustes do cartão do Luciano em uso no sipagnet. O cartão atual do Luciano do Aimaro está com numeração errada
  BEGIN
    UPDATE crawcrd c set c.nrcrcard = 5474080135227344,
               c.insitcrd = 4,
               c.dtentreg = '16/10/2019',
               c.dtvalida = '30/04/2025',
               c.dtlibera = '16/10/2019'
     WHERE c.cdcooper = 13
       AND c.nrdconta = 359084
     AND c.nrcrcard = 5474080000007344;
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('Erro ao alterar cartao 5474080000007344');
  END;
  
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
      flgdebit,
      flgprovi)
    VALUES
     (13,
      359084,
      5474080135227344,
      86657151934,
      'LUCIANO H KAUTNICK',
      19,
      0,
      '30/04/2025',
      62052,
      0,
      0,
      15,
      2,
      null,
      1,
      0);
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('Erro ao incluir crapcrd para cartao 5474080135227344');
  END;
  
  -- Item 3 do arquivo de evidencias
    -- alterar o cartão com numero zerado para o cartão 5474080135605523 do sócio Osiel e situacao cancelado, cfme SipagNet
  BEGIN
    UPDATE crawcrd c set c.nrcrcard = 5474080135605523,
               c.insitcrd = 6,
               c.nrcctitg = 7564457025077,
               c.nmextttl = 'FAROL COMUNIDADE CRISTA',
               c.dtcancel = '14/10/2019',
               c.cdmotivo = 3
     WHERE c.cdcooper = 13
       AND c.nrdconta = 359084
     AND c.nrcrcard = 0
     AND c.nrcpftit = 64694453904;
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('Erro ao alterar cartao 5474080000007344');
  END;

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
      flgdebit,
      flgprovi)
    VALUES
     (13,
      359084,
      5474080135605523,
      64694453904,
      'OSIEL LOPES PEREIRA',
      19,
      0,
      '31/05/2025',
      62053,
      3,
      0,
      15,
      2,
      '14/10/2019',
      1,
      0);
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('Erro ao incluir crapcrd para cartao 5474080135227344');
  END;
  -- Termino acoes cartao 5474080135605523  

  -- Item 4 do arquivo de evidencias
  -- Inserir cartão Em Uso do Osiel
    vr_des_text := 'CCR30204368770680210201975644570250770005474080140388388OSIEL LOPES PEREIRA    08051970202030164694453904    000200                                                                                               000C58A714EA15370B10              0  0 OSIEL LOPES PEREIRA                                                             7564457000000000000N';

    -- se for DADOS DO CARTÃO
    IF substr(vr_des_text,5,2) = '02'  THEN
                
      -- Guardar contas do arquivo para verificação
      vr_nrdconta := 359084;
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
      vr_dddebito := 0;
      vr_vllimcrd := 0;
      vr_tpdpagto := 0;
      vr_flgdebcc := 0;
      vr_cdgraupr := 0;
    vr_nrcpfcpj := 64694453904;
      
      -- Buscar as informacoes do cartao anterior para utilizar as mesmas informacoes na proposta
      OPEN cr_crawcrd_ant(pr_cdcooper => vr_cdcooper
                         ,pr_nrdconta => 359084
             ,pr_nrcrcard => 5474080135605523);
      FETCH cr_crawcrd_ant INTO rw_crawcrd_ant;
      
      IF cr_crawcrd_ant%NOTFOUND THEN
    IF to_number(TRIM(substr(vr_des_text,10,2))) = 10 THEN
      vr_dscritic := 'Proposta do cartao anterior nao encontrada!!';
      RAISE vr_exc_saida;
    END IF;
      END IF;
      close cr_crawcrd_ant;
      
      vr_dddebito:= 19;--rw_crawcrd_ant.dddebito;
      vr_vllimcrd:= 5000; -- Informação está no sipag
      vr_tpdpagto:= rw_crawcrd_ant.tpdpagto;
      vr_cdgraupr:= rw_crawcrd_ant.cdgraupr;
                  
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
            to_date('31/05/2025','dd/mm/rrrr'),               -- dtvalida
            1,                                                -- flgimpnp
            1,                                                -- tpenvcrd
            0,                                                -- flgprcrd
            4,                                                -- insitcrd
      2,                          -- insitdec
      '16/10/2019',
      '16/10/2019')
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
      close cr_crawcrd_rowid;
    END IF;
  
  -- Item 5 do arquivo de evidencias
  -- Inserir cartão Liberado do Osiel
    vr_des_text := 'CCR30204393813183110201975644570250770005474080144538947OSIEL LOPES PEREIRA    08051970202030164694453904    000200                                                                                               000C58A714EA15370B10              0  0 OSIEL LOPES PEREIRA                                                             7564457000000000000N';

    -- se for DADOS DO CARTÃO
    IF substr(vr_des_text,5,2) = '02'  THEN
                
      -- Guardar contas do arquivo para verificação
      vr_nrdconta := 359084;--to_number(TRIM(substr(vr_des_text,337,12)));
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
      vr_dddebito := 0;
      vr_vllimcrd := 0;
      vr_tpdpagto := 0;
      vr_flgdebcc := 0;
      vr_cdgraupr := 0;
    vr_nrcpfcpj := 64694453904;
      
      -- Buscar as informacoes do cartao anterior para utilizar as mesmas informacoes na proposta
      OPEN cr_crawcrd_ant(pr_cdcooper => vr_cdcooper
                         ,pr_nrdconta => 359084
             ,pr_nrcrcard => 5474080135605523); -- cartao anterior do Osiel
      FETCH cr_crawcrd_ant INTO rw_crawcrd_ant;
      
      IF cr_crawcrd_ant%NOTFOUND THEN
    IF to_number(TRIM(substr(vr_des_text,10,2))) = 10 THEN
      vr_dscritic := 'Proposta do cartao anterior nao encontrado!!';
      RAISE vr_exc_saida;
    END IF;
      END IF;
      close cr_crawcrd_ant;
      
      vr_dddebito:= 19;--rw_crawcrd_ant.dddebito;
      vr_vllimcrd:= 5000; -- Informação está no sipag
      vr_tpdpagto:= rw_crawcrd_ant.tpdpagto;
      vr_cdgraupr:= rw_crawcrd_ant.cdgraupr;
                  
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
      dtlibera)
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
            to_date('31/07/2025','dd/mm/rrrr'),               -- dtvalida
            1,                                                -- flgimpnp
            1,                                                -- tpenvcrd
            0,                                                -- flgprcrd
            3,                                                -- insitcrd
      2,                          -- insitdec
      '31/10/2019')
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
      close cr_crawcrd_rowid;
    END IF;
  -- Termino cartão Liberado do Osiel

  -- Item 6 do arquivo de evidencias
  -- insere cartao Liberado do Luciano
    vr_des_text := 'CCR30204393814123110201975644570250770005474080144538665LUCIANO H KAUTNICK     28081976202020186657151934    000200                                                                                               000B55F11F19A98B5010              0  0 LUCIANO HANDERSON KAUTNICK                                                      7564457000000000000N';

    -- se for DADOS DO CARTÃO
    IF substr(vr_des_text,5,2) = '02'  THEN
                
      -- Guardar contas do arquivo para verificação
      vr_nrdconta := 359084;--to_number(TRIM(substr(vr_des_text,337,12)));
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
      vr_dddebito := 0;
      vr_vllimcrd := 0;
      vr_tpdpagto := 0;
      vr_flgdebcc := 0;
      vr_cdgraupr := 0;
    vr_nrcpfcpj := 86657151934;
      
      -- Buscar as informacoes do cartao anterior para utilizar as mesmas informacoes na proposta
      OPEN cr_crawcrd_ant(pr_cdcooper => vr_cdcooper
                         ,pr_nrdconta => 359084
             ,pr_nrcrcard => 5474080135227344); -- cartao anterior do Luciano
      FETCH cr_crawcrd_ant INTO rw_crawcrd_ant;
      
      IF cr_crawcrd_ant%NOTFOUND THEN
    IF to_number(TRIM(substr(vr_des_text,10,2))) = 10 THEN
      vr_dscritic := 'Proposta do cartao anterior nao encontrado!!';
      RAISE vr_exc_saida;
    END IF;
      END IF;
      close cr_crawcrd_ant;
      
      vr_dddebito:= 19;--rw_crawcrd_ant.dddebito;
      vr_vllimcrd:= 5000; -- Informação está no sipag
      vr_tpdpagto:= rw_crawcrd_ant.tpdpagto;
      vr_cdgraupr:= rw_crawcrd_ant.cdgraupr;
                  
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
      dtlibera)
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
            to_date('31/07/2025','dd/mm/rrrr'),               -- dtvalida
            1,                                                -- flgimpnp
            1,                                                -- tpenvcrd
            1,                                                -- flgprcrd
            3,                                                -- insitcrd
      2,                          -- insitdec
      '31/10/2019')
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
      close cr_crawcrd_rowid;
    END IF;
  -- termino cartao Liberado Luciano

  COMMIT;
  dbms_output.put_line('Script executado com sucesso.');
  
  EXCEPTION
    WHEN vr_exc_saida THEN
      rollback;
      dbms_output.put_line('Erro: ' || vr_dscritic);
    
    WHEN OTHERS THEN
      rollback;
      dbms_output.put_line('Erro: ' || SQLERRM);
  END;  
end;