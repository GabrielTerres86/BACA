PL/SQL Developer Test script 3.0
410
/* Baca para inserir o cartão do cooperado 
 *
 * 
 * CCR30204161400011912201875632650150600005127070173947284LILIANE REGINA LEITE   13061981101010107215685993    000100                                                                                               000C89D9ED851ABBA81458720900      SESSCLILIANE REGINA LEITE                                                            7563265000000574899N
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
    SELECT crd.*
      FROM crawcrd crd
     WHERE crd.cdcooper = pr_cdcooper
       AND crd.nrdconta = pr_nrdconta
       AND crd.nrcrcard = 5127070134419225; -- Cartao 
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
    
    -- Deletar cartão antigo na wcrd
    delete crawcrd d where d.progress_recid = 916289;  
  
    vr_des_text := 'CCR30204161400011912201875632650150600005127070173947284LILIANE REGINA LEITE   13061981101010107215685993    000100                                                                                               000C89D9ED851ABBA81458720900      SESSCLILIANE REGINA LEITE                                                            7563265000000574899N';

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
      vr_cdadmcrd := 12; -- Ailos Classico - Buscado do SipagNet
      vr_dddebito := 0;
      vr_vllimcrd := 0;
      vr_tpdpagto := 0;
      vr_flgdebcc := 0;
      vr_cdgraupr := 0;
      
      -- Buscar as informacoes do cartao cancelado para utilizar as mesmas informacoes na proposta
      OPEN cr_crawcrd_ant(pr_cdcooper => vr_cdcooper
                         ,pr_nrdconta => vr_nrdconta);
      FETCH cr_crawcrd_ant INTO rw_crawcrd_ant;
      
      IF cr_crawcrd_ant%NOTFOUND THEN
        vr_dscritic := 'Proposta do cartao cancelado nao encontrado!!';
        RAISE vr_exc_saida;
      END IF;
      
      vr_dddebito:= rw_crawcrd_ant.dddebito;
      vr_vllimcrd:= rw_crawcrd_ant.vllimcrd;
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
      
      -- obter numero do contrato (sequencial)
      vr_nrctrcrd := 96559; --fn_sequence('CRAPMAT','NRCTRCRD', vr_cdcooper);
                    
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
            insitcrd)
        VALUES
           (vr_nrdconta,                                      -- nrdconta
            TO_NUMBER(substr(vr_des_text,38,19)),             -- nrcrcard
            TO_NUMBER(substr(vr_des_text,25,13)),             -- nrcctitg
            TO_NUMBER(substr(vr_des_text,95,15)),             -- nrcpftit
            vr_vllimcrd,                                      -- vllimcrd
            rw_crawcrd_ant.flgctitg,                          -- flgctitg
            TRUNC(SYSDATE),                                   -- dtmvtolt
            rw_crawcrd_ant.nmextttl,                          -- nmextttl
            vr_tpdpagto,                                      -- tpdpagto
            rw_crawcrd_ant.flgdebcc,                          -- flgdebcc
            rw_crawcrd_ant.vlsalari,                          -- vlsalari
            rw_crawcrd_ant.dddebito,                          -- dddebito
            vr_cdlimcrd,                                      -- cdlimcrd
            rw_crawcrd_ant.tpcartao,                          -- tpcartao
            TO_DATE(substr(vr_des_text,80,8), 'DDMMYYYY'),    -- dtnasccr
            substr(vr_des_text,230,15),                       -- nrdoccrd
            TRIM(substr(vr_des_text,57,23)),                  -- nmtitcrd
            vr_nrctrcrd,                                      -- nrctrcrd
            vr_cdadmcrd,                                      -- cdadmcrd
            vr_cdcooper,                                      -- cdcooper
            vr_nrseqcrd,                                      -- nrseqcrd
            vr_dtsolici,                                      -- dtpropos
            vr_dtsolici,                                      -- dtsolici
            rw_crawcrd_ant.flgdebit,                          -- flgdebit
            vr_cdgraupr,                                      -- cdgraupr
            to_date('31/07/2024','dd/mm/rrrr'),               -- dtvalida
            1,                                                -- flgimpnp
            rw_crawcrd_ant.tpenvcrd,                          -- tpenvcrd
            rw_crawcrd_ant.flgprcrd,                          -- flgprcrd
            4)                                                -- insitcrd
            RETURNING ROWID INTO rw_crawcrd.rowid;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir crawcrd: '||SQLERRM;
          RAISE vr_exc_saida;
      END;

      -- Obtem ponteiro do registro de proposta recém criado
    /*  OPEN cr_crawcrd_rowid(pr_rowid => rw_crawcrd.rowid);
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
      END;*/
    END IF;
  
  commit;
  
  EXCEPTION
    WHEN vr_exc_saida THEN
      dbms_output.put_line('Erro: ' || vr_dscritic);
    
    WHEN OTHERS THEN
      dbms_output.put_line('Erro: ' || SQLERRM);
  END;  
end;
0
0
