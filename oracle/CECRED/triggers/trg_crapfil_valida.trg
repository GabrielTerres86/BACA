CREATE OR REPLACE TRIGGER CECRED.TRG_CRAPFIL_VALIDA
BEFORE INSERT OR DELETE OR UPDATE ON CRAPFIL
FOR EACH ROW

  -- ..........................................................................
  --
  --  Programa : TRG_CRAPFIL_VALIDA
  --  Sistema  : Rotinas gen�ricas
  --  Sigla    : GENE
  --  Autor    : Marcos E. Martini - Supero
  --  Data     : Abril/2013.                   Ultima atualizacao: --/--/----
  --
  --  Dados referentes ao programa:
  --
  --   Frequencia: Antes de inserir, atualizar e deletar
  --   Objetivo  : Esta trigger � respons�vel por:
  --
  --               1   - Caso o nome da fila de impress�o seja alterado:
  --               1.1 - Mudar as solicita��o pendentes para o nome novo.
  --
  --               2   - Ao excluir ou desativar uma fila ou mudar o nome:
  --               2.1 - Primeiramente validar se a fila n�o � a padr�o e parar
  --                     em caso positivo.
  --               2.2 - Se passar a valida��o acima, atualizar todas as solicita��es
  --                     pendentes e vinculadas ao antigo para que as mesmas sejam
  --                     processadas pela fila padr�o
  --
  --               3   - Em caso de inser��o ou altera��o:
  --               3.1 - Se n�o houver quantidade m�xima de jobs da fila, ent�o usar 1
  --               3.2 - Se n�o houver quantidade m�xima de relat�rios por job, ent�o usar 50
  --
  --   Alteracoes: 28/10/2013 - Remover da trigger o processo de trabalho com os Jobs do banco, pois isto ser�
  --                            feito pela nova rotina gene0002.pc_controla_filas_relato (Marcos-Supero)
  -- .............................................................................

DECLARE
  PRAGMA AUTONOMOUS_TRANSACTION;
  -- Testa se a fila atual � uma das filas padr�o
  CURSOR cr_crapprm IS
    SELECT 'S'
      FROM crapprm
     WHERE nmsistem = 'CRED'
       AND cdacesso = 'COD_FILA_RELATO'
       AND cdcooper IS NOT NULL --> Pode ser em qualquer cooperativa
       AND dsvlrprm = :old.cdfilrel;
  vr_flpadrao CHAR(1);
  -- Nome da fila padr�o
  vr_nmfilpad VARCHAR2(12);
BEGIN

  -- Se estivermos alterando o nome
  IF updating AND :old.cdfilrel <> :new.cdfilrel THEN
    -- Atualizamos todas as solicita��es pendentes
    -- e n�o iniciadas da fila antiga para a nova
    BEGIN
      UPDATE crapslr
         SET cdfilrel = :new.cdfilrel
       WHERE flgerado = 'N'
         AND cdfilrel = :old.cdfilrel
         AND dtiniger IS NULL;
      -- Gravamos a altera��o para garantir que jobs
      -- ativos n�o busquem novas solicita��es
      COMMIT;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000, 'Erro ao alterar solicita��es da fila em altera��o: '||sqlerrm);
    END;
  END IF;

  -- Se estivermos eliminando ou desativando a fila
  IF deleting OR :new.flgativa = 'N' THEN
    -- Verificamos se a fila � uma fila padr�o
    OPEN cr_crapprm;
    FETCH cr_crapprm
     INTO vr_flpadrao;
    CLOSE cr_crapprm;
    -- Se for uma das padr�o
    IF vr_flpadrao = 'S' THEN
      -- Montar a mensagem de erro cfme a condi��o acima
      IF deleting THEN
        RAISE_APPLICATION_ERROR(-20000,'Erro ao eliminar CRAPFIL: Fila de impress�o � uma fila padr�o');
      ELSIF :new.flgativa = 'N' THEN
        RAISE_APPLICATION_ERROR(-20000,'Erro ao desativar a fila: Fila de impress�o � uma fila padr�o');
      ELSE
        RAISE_APPLICATION_ERROR(-20000,'Erro ao alterar nome da fila: Fila de impress�o � uma fila padr�o');
      END IF;
    ELSE -- N�o � uma fila padr�o
      -- Buscamos o nome da fila padr�o
      vr_nmfilpad := gene0001.fn_param_sistema('CRED',0,'COD_FILA_RELATO');
      -- Atualizamos todas as solicita��es pendentes
      -- e n�o iniciadas desta fila para a fila padr�o
      BEGIN
        UPDATE crapslr
           SET cdfilrel = vr_nmfilpad
         WHERE flgerado = 'N'
           AND cdfilrel = :old.cdfilrel
           AND dtiniger IS NULL;
        -- Gravamos a altera��o para garantir que jobs
        -- ativos n�o busquem novas solicita��es
        COMMIT;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(-20000, 'Erro ao alterar solicita��es da fila em exclus�o/desativa��o: '||sqlerrm);
      END;
    END IF;
  END IF;

  -- Se estivermos inserindo ou atualizando
  IF (inserting OR updating)  THEN
    -- N�o deixar c�digo de fila com espa�os
    IF :NEW.cdfilrel <> REPLACE(:NEW.cdfilrel,' ','') THEN
      RAISE_APPLICATION_ERROR(-20000, 'N�o � permitido informar espa�os no c�digo da fila.');
    END IF;
    -- Se n�o foi passado a quantidade m�xima por job
    IF :new.qtreljob IS NULL THEN
      -- Utilizaremos a quantidade padr�o
      :new.qtreljob := 50;
    END IF;
    -- Se n�o foi passado a quantidade m�xima de jobs da fila
    IF :new.qtjobati IS NULL THEN
      -- Utilizaremos a quantidade padr�o
      :new.qtjobati := 1;
    END IF;
  END IF;

  -- Ao final, gravamos as informa��es
  COMMIT;

END TRG_CRAPFIL_VALIDA;
/

