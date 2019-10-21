  --Cadastro na tabela de programas para o relatorio crrl789   
		update crapprg prg
         set cdrelato##1 = 789
         WHERE UPPER(prg.cdprogra) = UPPER('CONVEN');