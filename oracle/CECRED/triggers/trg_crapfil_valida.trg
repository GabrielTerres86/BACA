CREATE OR REPLACE TRIGGER CECRED.TRG_CRAPFIL_VALIDA
BEFORE INSERT OR DELETE OR UPDATE ON CRAPFIL
FOR EACH ROW

  -- ..........................................................................
  --
  --  Programa : TRG_CRAPFIL_VALIDA
  --  Sistema  : Rotinas genéricas
  --  Sigla    : GENE
  --  Autor    : Marcos E. Martini - Supero
  --  Data     : Abril/2013.                   Ultima atualizacao: --/--/----
  --
  --  Dados referentes ao programa:
  --
  --   Frequencia: Antes de inserir, atualizar e deletar
  --   Objetivo  : Esta trigger é responsável por:
  --
  --               1   - Caso o nome da fila de impressão seja alterado:
  --               1.1 - Mudar as solicitação pendentes para o nome novo.
  --
  --               2   - Ao excluir ou desativar uma fila ou mudar o nome:
  --               2.1 - Primeiramente validar se a fila não é a padrão e parar
  --                     em caso positivo.
  --               2.2 - Se passar a validação acima, atualizar todas as solicitações
  --                     pendentes e vinculadas ao antigo para que as mesmas sejam
  --                     processadas pela fila padrão
  --
  --               3   - Em caso de inserção ou alteração:
  --               3.1 - Se não houver quantidade máxima de jobs da fila, então usar 1
  --               3.2 - Se não houver quantidade máxima de relatórios por job, então usar 50
  --
  --   Alteracoes: 28/10/2013 - Remover da trigger o processo de trabalho com os Jobs do banco, pois isto será
  --                            feito pela nova rotina gene0002.pc_controla_filas_relato (Marcos-Supero)
  -- .............................................................................

DECLARE
  PRAGMA AUTONOMOUS_TRANSACTION;
  -- Testa se a fila atual é uma das filas padrão
  CURSOR cr_crapprm IS
    SELECT 'S'
      FROM crapprm
     WHERE nmsistem = 'CRED'
       AND cdacesso = 'COD_FILA_RELATO'
       AND cdcooper IS NOT NULL --> Pode ser em qualquer cooperativa
       AND dsvlrprm = :old.cdfilrel;
  vr_flpadrao CHAR(1);
  -- Nome da fila padrão
  vr_nmfilpad VARCHAR2(12);
BEGIN

  -- Se estivermos alterando o nome
  IF updating AND :old.cdfilrel <> :new.cdfilrel THEN
    -- Atualizamos todas as solicitações pendentes
    -- e não iniciadas da fila antiga para a nova
    BEGIN
      UPDATE crapslr
         SET cdfilrel = :new.cdfilrel
       WHERE flgerado = 'N'
         AND cdfilrel = :old.cdfilrel
         AND dtiniger IS NULL;
      -- Gravamos a alteração para garantir que jobs
      -- ativos não busquem novas solicitações
      COMMIT;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000, 'Erro ao alterar solicitações da fila em alteração: '||sqlerrm);
    END;
  END IF;

  -- Se estivermos eliminando ou desativando a fila
  IF deleting OR :new.flgativa = 'N' THEN
    -- Verificamos se a fila é uma fila padrão
    OPEN cr_crapprm;
    FETCH cr_crapprm
     INTO vr_flpadrao;
    CLOSE cr_crapprm;
    -- Se for uma das padrão
    IF vr_flpadrao = 'S' THEN
      -- Montar a mensagem de erro cfme a condição acima
      IF deleting THEN
        RAISE_APPLICATION_ERROR(-20000,'Erro ao eliminar CRAPFIL: Fila de impressão é uma fila padrão');
      ELSIF :new.flgativa = 'N' THEN
        RAISE_APPLICATION_ERROR(-20000,'Erro ao desativar a fila: Fila de impressão é uma fila padrão');
      ELSE
        RAISE_APPLICATION_ERROR(-20000,'Erro ao alterar nome da fila: Fila de impressão é uma fila padrão');
      END IF;
    ELSE -- Não é uma fila padrão
      -- Buscamos o nome da fila padrão
      vr_nmfilpad := gene0001.fn_param_sistema('CRED',0,'COD_FILA_RELATO');
      -- Atualizamos todas as solicitações pendentes
      -- e não iniciadas desta fila para a fila padrão
      BEGIN
        UPDATE crapslr
           SET cdfilrel = vr_nmfilpad
         WHERE flgerado = 'N'
           AND cdfilrel = :old.cdfilrel
           AND dtiniger IS NULL;
        -- Gravamos a alteração para garantir que jobs
        -- ativos não busquem novas solicitações
        COMMIT;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(-20000, 'Erro ao alterar solicitações da fila em exclusão/desativação: '||sqlerrm);
      END;
    END IF;
  END IF;

  -- Se estivermos inserindo ou atualizando
  IF (inserting OR updating)  THEN
    -- Não deixar código de fila com espaços
    IF :NEW.cdfilrel <> REPLACE(:NEW.cdfilrel,' ','') THEN
      RAISE_APPLICATION_ERROR(-20000, 'Não é permitido informar espaços no código da fila.');
    END IF;
    -- Se não foi passado a quantidade máxima por job
    IF :new.qtreljob IS NULL THEN
      -- Utilizaremos a quantidade padrão
      :new.qtreljob := 50;
    END IF;
    -- Se não foi passado a quantidade máxima de jobs da fila
    IF :new.qtjobati IS NULL THEN
      -- Utilizaremos a quantidade padrão
      :new.qtjobati := 1;
    END IF;
  END IF;

  -- Ao final, gravamos as informações
  COMMIT;

END TRG_CRAPFIL_VALIDA;
/

