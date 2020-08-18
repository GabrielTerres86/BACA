PL/SQL Developer Test script 3.0
125
DECLARE
  CURSOR cr_crapace IS
    SELECT DISTINCT
           p.cdoperad
          ,p.cdcooper
      FROM crapace p
     WHERE p.nmdatela = 'RISCO'
       AND p.cddopcao = 'F'
       AND p.idambace = 1; -- Aimaro Caractere

BEGIN

  BEGIN
    UPDATE craptel t
      SET t.cdopptel = t.cdopptel ||',P,Q'
         ,t.lsopptel = t.lsopptel ||',PREVIA 3040 MES ANT,PREVIA 3040 DIA ANT'
    WHERE t.nmdatela = 'RISCO' AND t.cdopptel NOT LIKE '%,P,Q';
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Erro: ' || SQLERRM);
    END;
  COMMIT;

  --FAZ O INSERT PARA OPERADORES COM OPCAO "F" NA TELA "RISCO"
  FOR rw_crapace IN cr_crapace LOOP
      BEGIN
        INSERT INTO crapace
          (nmdatela,
           cddopcao,
           cdoperad,
           nmrotina,
           cdcooper,
           nrmodulo,
           idevento,
           idambace)
        VALUES
          ('RISCO',
           'P',
           rw_crapace.cdoperad,
           ' ',
           rw_crapace.cdcooper,
           1,
           0,
           2);
      EXCEPTION
        WHEN OTHERS THEN
          DBMS_OUTPUT.PUT_LINE('Erro: cdcoperd:' || rw_crapace.cdoperad || 'cdoperad:' || rw_crapace.cdcooper || ' - '  || SQLERRM);
      END;

      BEGIN
        INSERT INTO crapace
          (nmdatela,
           cddopcao,
           cdoperad,
           nmrotina,
           cdcooper,
           nrmodulo,
           idevento,
           idambace)
        VALUES
          ('RISCO',
           'Q',
           rw_crapace.cdoperad,
           ' ',
           rw_crapace.cdcooper,
           1,
           0,
           2);
      EXCEPTION
        WHEN OTHERS THEN
          DBMS_OUTPUT.PUT_LINE('Erro: cdcoperd:' || rw_crapace.cdoperad || 'cdoperad:' || rw_crapace.cdcooper || ' - '  || SQLERRM);
      END;
  END LOOP;

  UPDATE gnchelp SET DSDOHELP = '
FUNCAO:

OPCOES: (A): Alterar
        (C): Consultar
        (E): Excluir
        (F): Finalizacao
        (K): Gerar Arq. Contabilizacao Provisao
        (I): Incluir
        (R): Solicita Provisao
        (M): Gerar Arq. dos saldos
        (T): Gerar Arq. Contabilizacao Provisao
        (G): Gerar Arq. Provisão das Garantias Prestadas
        (H): Gerar Arq. XML 3026
        (P): Gerar Previa Arq. XML 3040 mes corrente
        (Q): Gerar Previa Arq. XML 3040 mes anterior

CAMPOS: 

Opção F: Gerar o arquivo mensal do 3040 após o fechamento contabil,
na pasta da Cooperativa em L / Cooperativa / Contab.

Opção K: Gera o arquivo de importacao contabil com as informacoes de
provisao, classificacao da carteira em niveis de risco, saldos de
microcrédito, cheque especial, adiantamento a depositantes e limite de
cheque especial nao utilizado, e juros +60.

Opção G: Gera o arquivo de importacao contabil com as informacoes de
garantias.

Opção T: Gera o arquivo de importação contabil com as informações de
cartao de credito (Cartao Ailos e Visa).

Opção M: Gera o arquivo contábil com as informacoes de saldos de
operacoes de credito de cooperativas migradas para lancamento manual
na Contabilidade (Na Alto Vale e gerado o arquivo com saldos de PAs
que foram migrados da Viacredi e os valores sao lancados na Viacredi,
na Viacredi e gerado o arquivo com saldos de PAs que foram migrados
da Acredicoop e os valores sao lancados na Acredicoop).

Opção R: Gera o relatorio de juros + 60 dias de Emprestimos e
Financiamentos e disponibiliza no dia seguinte no Intranet o
relatório 534. Atraves da Opção R, Data de Referência, Relat. Emp/Finan
60d Atraso.

Data Referencia: 

Relat..........:' WHERE nmdatela IN ('RISCO');

  COMMIT;
END;
0
0
