create or replace function cecred.fn_sequence(pr_nmtabela in crapsqt.nmtabela%type
                                      ,pr_nmdcampo in crapsqt.nmdcampo%type
                                      ,pr_dsdchave in crapsqu.dsdchave%type
                                      ,pr_flgdecre in varchar2 default 'N') return varchar2 is
  pragma autonomous_transaction;
begin
  -- ..........................................................................

    -- Programa: fn_sequence
    -- Sistema : Conta-Corrente - Cooperativa de Credito
    -- Sigla   : CRED
    -- Autor   : Marcos (Supero)
    -- Data    : Março/2014.                     Ultima atualizacao: 24/03/2017

    -- Dados referentes ao programa:

    -- Frequencia: Sempre que chamado
    -- Objetivo   : Realizar a busca de sequencias específicas, ou seja, aquelas
    --              que não são únicas por banco, por exemplo uma sequencia por
    --              cooperativa.
    -- Parâmetros : PR_NMTABELA: Nome da tabela sequenciada
    --              PR_NMDCAMPO: Nome do campo sequenciado
    --              pr_dsdchave: Texto valor da chave da sequencia, ou seja, se a sequencia
    --                           é por cooperativa, recebemos o código da cooperativa desejada,
    --                           se for por cooperativa + data, recebemos além do código, a data
    --                           desejada formatada em dd/mm/yyyy e separados por ;
    --              PR_FLGDECRE: Quando 'S' decrementa a sequencia, do contrário incrementa (default)
    -- Observações : Utiliza o cadastro nas tabelas CRAPSQT e CRAPSQU.
    --
    -- Alteracoes: Ajuste para melhoria de performace, retirado o upper do campo da tabela,
    --             para que use o index de forma correta, e colocado o upper nos parametros para garantir
    --             que os registros a serem inseridos, ou buscados estejam corretos(Odirlei/Amcom)
    --
    --             20/01/2016 - Incluido o upper nos campos que compoem um index e possuem upper
    --                         (Adriano).
    --
    --             24/03/2017 - Inclui validacao para tirar espacos sobre o campo rw_crapsqt.dstxterr
    --                          e melhorei a descricao do log gerado. SD 637585.
	--
	--             29/07/2019 - Criacao de sequencial diferenciado para lotes removidos no Projeto de Revitalizacao
	--                          Evitando erros de chave duplicada ate a revisao de todos os fontes
	--                          Heitor (Mouts) - Projeto Revitalizacao (Sustentacao)
    -- .............................................................................
  declare
    -- Busca dos dados da configuração
    cursor cr_crapsqt is
      select nvl(sqt.flgciclo,0) flgciclo
            ,nvl(sqt.qtincrem,1) qtincrem
            ,nvl(sqt.qtmaxseq,999999999999999) qtmaxseq
            ,sqt.dsdchave
            ,sqt.dstxterr
        from crapsqt sqt
       where UPPER(sqt.nmtabela) = upper(pr_nmtabela)
         and UPPER(sqt.nmdcampo) = upper(pr_nmdcampo)
         for update;
    rw_crapsqt cr_crapsqt%ROWTYPE;
    -- Busca da sequencia atual
    cursor cr_crapsqu IS
      select squ.nrseqatu
        from crapsqu squ
       where UPPER(squ.nmtabela)  = upper(pr_nmtabela)
         and UPPER(squ.nmdcampo)  = upper(pr_nmdcampo)
         and UPPER(squ.dsdchave)  = upper(pr_dsdchave)
         for update;
    rw_crapsqu cr_crapsqu%rowtype;
    -- Armazenamento dos valores necessários
    vr_qtincrem crapsqt.qtincrem%type;
    vr_qtseqatu crapsqu.nrseqatu%type;
    -- Saída
    vr_des_erro  varchar2(4000);
    vr_exc_saida exception;
  begin
    -- Buscar configuração da sequence
    open cr_crapsqt;
    fetch cr_crapsqt
     into rw_crapsqt;
    -- Se não tiver encontrado
    if cr_crapsqt%notfound then
      --
      close cr_crapsqt;
      -- Iremos cadastrar uma nova sequence com valores padrão
      begin
        insert into crapsqt (nmtabela
                            ,nmdcampo
                            ,dsdchave)
                     values (upper(pr_nmtabela)
                            ,upper(pr_nmdcampo)
                            ,'CDCOOPER')
                     returning qtincrem
                          into vr_qtincrem;
      exception
        when others then
          -- Gerar log
          vr_des_erro := 'Erro ao criar cadastro de sequence, tabela CRAPSQT. '
                      || ' Parâmetros: dsdchave = '||pr_dsdchave||', NMTABELA = '||pr_nmtabela
                      || ', NMDCAMPO = '||pr_nmdcampo||'. Erro --> '||sqlerrm;
          -- Sair
          raise vr_exc_saida;
      end;
      -- Cadastrar o valor inícial para a sequence
      begin
        insert into crapsqu (nmtabela
                            ,nmdcampo
                            ,dsdchave
                            ,nrseqatu)
                     values (upper(pr_nmtabela)
                            ,upper(pr_nmdcampo)
                            ,upper(pr_dsdchave)
                            ,vr_qtincrem)
                     returning nrseqatu
                          into vr_qtseqatu;
      exception
        when others then
          -- Gerar log
          vr_des_erro := 'Erro ao criar valor de sequence, tabela CRAPSQU. '
                      || ' Parâmetros: dsdchave = '||pr_dsdchave||', NMTABELA = '||pr_nmtabela
                      || ', NMDCAMPO = '||pr_nmdcampo||'. Erro --> '||sqlerrm;
          -- Sair
          raise vr_exc_saida;
      end;
    else
      --
      close cr_crapsqt;
      -- Buscar o valor atual da sequencia
      open cr_crapsqu;
      fetch cr_crapsqu
       into rw_crapsqu;
      -- Se não tiver encontrado
      if cr_crapsqu%notfound then
        --
        close cr_crapsqu;
        -- Criar o registro inicial

		--Criar sequencial diferenciado para os lotes removidos no projeto de revitalizacao
		if upper(pr_nmtabela) = 'CRAPLOT' and
           upper(pr_nmdcampo) = 'NRSEQDIG' and
           substr(pr_dsdchave,instr(pr_dsdchave,';',-1)+1) in ('7050'
                                                              ,'8383'
                                                              ,'8473'
                                                              ,'10104'
                                                              ,'10105'
                                                              ,'10115'
                                                              ,'11900'
                                                              ,'15900'
                                                              ,'23900') then
          rw_crapsqt.qtincrem := rw_crapsqt.qtincrem + 10000000;
        end if;

        begin
          insert into crapsqu (nmtabela
                              ,nmdcampo
                              ,dsdchave
                              ,nrseqatu)
                       values (upper(pr_nmtabela)
                              ,upper(pr_nmdcampo)
                              ,upper(pr_dsdchave)
                              ,rw_crapsqt.qtincrem)
                       returning nrseqatu
                            into vr_qtseqatu;
        exception
          when others then
            -- Gerar log
            vr_des_erro := 'Erro ao criar valor de sequence, tabela CRAPSQU. '
                        || ' Parâmetros: dsdchave = '||pr_dsdchave||', NMTABELA = '||pr_nmtabela
                        || ', NMDCAMPO = '||pr_nmdcampo||'. Erro --> '||sqlerrm;
            -- Sair
            raise vr_exc_saida;
        end;
      else
        --
        close cr_crapsqu;
        -- Testar solicitação decremental
        IF pr_flgdecre = 'S' THEN
          -- Inverter a quantidade a incrementar para diminuir a sequencia
          rw_crapsqt.qtincrem := rw_crapsqt.qtincrem * -1;
        END IF;
        -- Se o valor de incremento + sequencia atual estourar a sequencia
        if rw_crapsqt.qtmaxseq < rw_crapsqu.nrseqatu + rw_crapsqt.qtincrem then
          -- Se a sequencia não for ciclica
          if rw_crapsqt.flgciclo = 0 then
            -- Caso existe texto de erro cadastrado
            IF TRIM(rw_crapsqt.dstxterr) IS NOT NULL THEN
              -- Usá-lo
              vr_des_erro := rw_crapsqt.dstxterr;
            ELSE
              -- Gerar erro default
              vr_des_erro := 'Valor máximo '||rw_crapsqt.qtmaxseq||' alcançado para sequencia não cíclica.'
                          || ' Parâmetros: dsdchave = '||pr_dsdchave||', NMTABELA = '||pr_nmtabela
                          || ', NMDCAMPO = '||pr_nmdcampo;
            END IF;
            -- Sair
            raise vr_exc_saida;
          end if;
          -- Reiniciar a sequencia
          begin
            update crapsqu
               set nrseqatu = rw_crapsqt.qtincrem
             where UPPER(nmtabela) = upper(pr_nmtabela)
               and UPPER(nmdcampo) = upper(pr_nmdcampo)
               and UPPER(dsdchave) = upper(pr_dsdchave)
             returning nrseqatu
                  into vr_qtseqatu;
          exception
            when others then
              -- Gerar log
              vr_des_erro := ' Erro ao reiniciar valor de sequence, tabela CRAPSQU. '
                          || ' Parâmetros: dsdchave = '||pr_dsdchave||', NMTABELA = '||pr_nmtabela
                          || ', NMDCAMPO = '||pr_nmdcampo||'. Erro --> '||sqlerrm;
              -- Sair
              raise vr_exc_saida;
          end;
        else
          -- Atualizar a sequencia
          begin
            update crapsqu
               set nrseqatu = nrseqatu + rw_crapsqt.qtincrem
             where UPPER(nmtabela) = upper(pr_nmtabela)
               and UPPER(nmdcampo) = upper(pr_nmdcampo)
               and UPPER(dsdchave) = upper(pr_dsdchave)
             returning nrseqatu
                  into vr_qtseqatu;
          exception
            when others then
              -- Gerar log
             vr_des_erro := 'Erro ao reiniciar valor de sequence, tabela CRAPSQU. '
                         || ' Parâmetros: dsdchave = '||pr_dsdchave||', NMTABELA = '||pr_nmtabela
                         || ', NMDCAMPO = '||pr_nmdcampo||'. Erro --> '||sqlerrm;
              -- Sair
              raise vr_exc_saida;
          end;
        end if;
      end if;
    end if;
    -- Commitar as alterações (Libera os for update)
    commit;
    -- Retornar
    return vr_qtseqatu;
  exception
    when vr_exc_saida then
      -- Gerar no log da Viacredi
      btch0001.pc_gera_log_batch(pr_cdcooper     => 1
                                ,pr_ind_tipo_log => 3
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')
                                                 || ' --> FN_SEQUENCE --> '||vr_des_erro);
      -- Remover as alterações
      rollback;
      -- Retornar o texto do erro
      RETURN vr_des_erro;
    when others then
      -- Erro critico no Log da Viacredi
      btch0001.pc_gera_log_batch(pr_cdcooper     => 1
                                ,pr_ind_tipo_log => 3
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')
                                                 || ' --> FN_SEQUENCE -->  Erro nao tratado na busca de sequence, tabela CRAPSQT. '
                                                 || ' Parâmetros: dsdchave = '||pr_dsdchave||', NMTABELA = '||pr_nmtabela
                                                 || ', NMDCAMPO = '||pr_nmdcampo||'. Erro --> '||sqlerrm);
      -- Remover as alterações
      rollback;
      -- Retornar o texto do erro
      RETURN vr_des_erro;
  end;
end fn_sequence;
/
