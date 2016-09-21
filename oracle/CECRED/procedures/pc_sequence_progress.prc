CREATE OR REPLACE PROCEDURE CECRED.pc_sequence_progress(pr_nmtabela IN crapsqt.nmtabela%TYPE
                                                ,pr_nmdcampo IN crapsqt.nmdcampo%TYPE
                                                ,pr_dsdchave IN crapsqu.dsdchave%TYPE
                                                ,pr_flgdecre IN VARCHAR2 DEFAULT 'N'
                                                ,pr_sequence OUT VARCHAR2) IS
BEGIN
  -- ..........................................................................

  -- Programa: pc_sequence
  -- Sigla   : CRED
  -- Autor   : Dionathan
  -- Data    : Dezembro/2014.                     Ultima atualizacao: 05/12/2014

  -- Dados referentes ao programa:

  -- Frequencia: Sempre que chamado
  -- Objetivo  : Chamar a fn_sequence para que esta possa ser chamada do progress a
  -- partir de uma STORED-PROCEDURE, e evitar problemas de cursores abertos no banco
  -- que ocorriam com a chamada direta à função via send-sql-statement
  -- .............................................................................

  -- Chama a função e seta o retorno para o parâmetro de saída

  pr_sequence := fn_sequence(pr_nmtabela => pr_nmtabela
                            ,pr_nmdcampo => pr_nmdcampo
                            ,pr_dsdchave => pr_dsdchave
                            ,pr_flgdecre => pr_flgdecre);

END pc_sequence_progress;
/

