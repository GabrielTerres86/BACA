 /*---------------------------------------------------------------------------------------------------------------------
    Programa    : Piloto por cooperativa
    Projeto     : 403 - Desconto de T�tulos - Release 4
    Autor       : Luis Fernando (GFT)
    Data        : 07/01/2019
    Objetivo    : Inicia a "virada de chave" do piloto por cooperativa da funcionalidade de border�s de desconto de t�tulos
  ---------------------------------------------------------------------------------------------------------------------*/ 


DECLARE 
  TYPE Cooperativas IS TABLE OF integer;
  coop Cooperativas := Cooperativas(14); -- EX: Cooperativas(1,3,7,11);
  
  pr_cdcooper INTEGER;

BEGIN

  

  FOR i IN coop.FIRST .. coop.LAST
  LOOP
    pr_cdcooper := coop(i);
    UPDATE crapprm SET dsvlrprm = '1' WHERE cdacesso = 'FL_VIRADA_BORDERO' AND cdcooper = (pr_cdcooper);

    -- Inclui a nova op��o na tela TITCTO
    UPDATE craptel
       SET idambtel = 2,
           cdopptel = cdopptel||',B',
           lsopptel = lsopptel||',BORDERO'
     WHERE nmdatela = 'TITCTO'
      AND  cdcooper = (pr_cdcooper);

    -- Insere a permiss�o da nova op��o
    INSERT INTO crapace
        (nmdatela,
         cddopcao,
         cdoperad,   
         nmrotina,   
         cdcooper,   
         nrmodulo,   
         idevento,   
         idambace)
        SELECT acn.nmdatela, 
               'B', 
               ope.cdoperad,
               ' ',
               acn.cdcooper,
               acn.nrmodulo,
               acn.idevento,
               acn.idambace
          FROM crapcop cop,
               crapope ope,
               crapace acn
         WHERE cop.flgativo = 1
           AND cop.cdcooper = (pr_cdcooper)
           AND ope.cdsitope = 1 
           AND cop.cdcooper = ope.cdcooper
           AND acn.cdcooper = ope.cdcooper
           AND trim(upper(acn.cdoperad)) = trim(upper(ope.cdoperad))
           AND acn.cddopcao = 'L'
           AND acn.nmrotina = ' '
           AND acn.nmdatela = 'TITCTO'
           AND acn.idambace = 2;


    /**
     * Atualiza border�s antigos com situa��o liquidao e liberado para a decis�o aprovado
     */
    UPDATE 
      crapbdt 
    SET
      insitapr = 4
    WHERE 
      (crapbdt.insitbdt = 4 OR crapbdt.insitbdt=3)
      AND cdcooper = pr_cdcooper
    ;
    /**
     * Atualiza border�s antigos analisado para a situa��o de em estudo, para que possam ser aproveitados no processo novo
     */
    UPDATE 
      crapbdt
    SET
      insitbdt = 1,
      insitapr = 0,
      flverbor = 1
    WHERE
      insitbdt = 2
      AND cdcooper = pr_cdcooper;
    /**
     * Atualiza border�s antigos EM ESTUDO para virar border� novos
     */
    UPDATE 
      crapbdt
    SET
      insitapr = 0,
      flverbor = 1
    WHERE
      insitbdt = 1
      AND cdcooper = pr_cdcooper;
    /**
     * Atualiza o sequencial da TDB guardado na BDT de todos os border�s
     */
    UPDATE 
      crapbdt 
    SET 
      crapbdt.nrseqtdb = (SELECT COUNT(1) FROM craptdb WHERE crapbdt.nrborder=craptdb.nrborder AND crapbdt.cdcooper=craptdb.cdcooper AND crapbdt.nrdconta=craptdb.nrdconta)
    ;

    /**
     * Arruma o sequencial dos titulos para ficarem com um nrtitulo unico
     */
    MERGE
    INTO    craptdb u
    USING   (
    SELECT  rowid AS rid,
    ROW_NUMBER() OVER (PARTITION BY nrdconta,nrborder,cdcooper ORDER BY nrdconta,nrborder,cdcooper) AS rn
    FROM    craptdb
    where cdcooper = pr_cdcooper
    )
    ON      (u.rowid = rid)
    WHEN MATCHED THEN
    UPDATE
    SET
      nrtitulo = rn;

    /**
     * Arruma a situa��o dos t�tulos de border�s liquidados e liberados
     */
    UPDATE
      craptdb
    SET
      insitapr = 1
    WHERE
      dtlibbdt is not null
      AND cdcooper = pr_cdcooper
    ;

    /*Bloqueia a tela LANBDT do ayllos caracter*/
    UPDATE craptel SET FLGTELBL = 0 WHERE nmdatela = 'LANBDT' AND cdcooper = pr_cdcooper;

    /* INSERE COBTIT */
    -- Insere a tela
    INSERT INTO craptel 
        (nmdatela,
         nrmodulo,
         cdopptel,
         tldatela,
         tlrestel,
         flgteldf,
         flgtelbl,
         nmrotina,
         lsopptel,
         inacesso,
         cdcooper,
         idsistem,
         idevento,
         nrordrot,
         nrdnivel,
         nmrotpai,
         idambtel)
        SELECT 'COBTIT', 
               5, 
               '@,C,B,G,X,D,Y', 
               'Cobran�a de T�tulos', 
               'Cobran�a de T�tulos', 
               0, 
               1, -- bloqueio da tela 
               ' ', 
               'Acesso,Consultar,Baixa,Gerar Boleto,Enviar Email/SMS,Desconto Prejuizo,Boletagem Massiva', 
               0, 
               cdcooper, -- cooperativa
               1, 
               0, 
               1, 
               1, 
               '', 
               2 
          FROM crapcop          
         WHERE cdcooper = pr_cdcooper; 

    -- Permiss�es de consulta para os usu�rios pr�-definidos pela CECRED                       
    INSERT INTO crapace (nmdatela,cddopcao,cdoperad,nmrotina,cdcooper,nrmodulo,idevento,idambace) (SELECT 'COBTIT',cddopcao,cdoperad,nmrotina,cdcooper,nrmodulo,idevento,idambace FROM crapace WHERE nmdatela ='COBEMP' AND cdcooper = pr_cdcooper);
    -- Insere o registro de cadastro do programa
    INSERT INTO crapprg
        (nmsistem,
         cdprogra,
         dsprogra##1,
         dsprogra##2,
         dsprogra##3,
         dsprogra##4,
         nrsolici,
         nrordprg,
         inctrprg,
         cdrelato##1,
         cdrelato##2,
         cdrelato##3,
         cdrelato##4,
         cdrelato##5,
         inlibprg,
         cdcooper) 
        SELECT 'CRED',
               'COBTIT',
               'Cobran�a de T�tulos',
               '.',
               '.',
               '.',
               (SELECT max(nrsolici)+1 FROM crapprg),
               NULL,
               1,
               0,
               0,
               0,
               0,
               0,
               1,
               cdcooper
          FROM crapcop          
         WHERE cdcooper IN pr_cdcooper;
    IF (pr_cdcooper=3) THEN
      UPDATE crapprg c SET cdrelato##1=(SELECT cdrelato##1 FROM crapprg WHERE cdprogra = 'COBEMP' AND cdcooper = 3) WHERE cdprogra='COBTIT' AND cdcooper = 3;
    END IF;

    /* Atualiza o saldo devedor dos t�tulos de border�s em aberto que foram liberados no processo antigo*/
    UPDATE craptdb
       SET vlsldtit = vltitulo
     WHERE cdcooper = pr_cdcooper
       AND dtlibbdt IS NOT NULL
       AND insittit = 4
       AND nrborder IN (SELECT nrborder 
                          FROM crapbdt 
                         WHERE cdcooper = pr_cdcooper
                           AND insitbdt = 3
                           AND dtlibbdt IS NOT NULL
                           AND flverbor = 0);
    
    
    -- Script de carga da TAB052 por cooperativa
    UPDATE craptab  
    SET    dstextab = 
           -- operacional 
              SUBSTR(dstextab, 1, 239)
           || ';'|| to_char(10000,     'FM000000000D00', 'NLS_NUMERIC_CHARACTERS='',.''') -- Valor M�ximo Dispensa Assinatura 
           || ';'|| to_char(1,      'FM0') -- Verificar relacionamento emitente (conjuge/ s�cio)
           || ';'|| to_char(1,      'FM0') -- Verificar Preju�zo do Emitente
           || ';'|| to_char(1,      'FM0') -- Verificar Cooperado Possui Titulos Descontatos na Conta do Pagador
           || ';'|| to_char(80,      'FM000')  -- M�nimo de Liquidez do Cedente x Pagador (Qtd. de Titulos)                                           
           || ';'|| to_char(80,      'FM000')  -- M�nimo de Liquidez do Cedente x Pagador (Valor dos Titulos)                                         
           || ';'|| to_char(90,      'FM000')  -- M�nimo de Liquidez de Titulos Geral do Cedente (Qtd de Titulos)                                          
           || ';'|| to_char(90,      'FM000')  -- M�nimo de Liquidez de Titulos Geral do Cedente (Valor dos Titulos)                                         
           || ';'|| to_char(6,      'FM0000')  --  Per�odo em meses para realizar o c�lculo da liquidez
           || ';'|| to_char(0,      'FM0') -- -- Valor m�ximo permitido por ramo de atividade                               
           || ';'|| SUBSTR(dstextab, 283, 6) -- Concentra��o m�xima de t�tulos por pagador (manter) e Consulta de CPF/CNPJ do pagador (manter)                          
           || ';'|| to_char(20,   'FM0000') -- Quantidade m�xima de dias para envio para esteira
           || ';'|| to_char(60,       'FM0000') -- Dias para expirar border�
           || ';'|| to_char(100,      'FM0000') -- Quantidade m�xima de t�tulos por border� IB
           || ';'|| to_char(300,      'FM0000') -- Quantidade m�xima de t�tulos por border� Ayllos
           -- ailos
           || ';'|| to_char(15000,   'FM000000000D00', 'NLS_NUMERIC_CHARACTERS='',.''') -- Valor M�ximo Dispensa Assinatura 
           || ';'|| to_char(1,      'FM0') -- Verificar relacionamento emitente (conjuge/ s�cio)
           || ';'|| to_char(1,      'FM0') -- Verificar Preju�zo do Emitente
           || ';'|| to_char(1,      'FM0') -- Verificar Cooperado Possui Titulos Descontatos na Conta do Pagador
           || ';'|| to_char(100,      'FM000' , 'NLS_NUMERIC_CHARACTERS='',.''')   -- M�nimo de Liquidez do Cedente x Pagador (Qtd. de Titulos)                                           
           || ';'|| to_char(100,      'FM000', 'NLS_NUMERIC_CHARACTERS='',.''')  -- M�nimo de Liquidez do Cedente x Pagador (Valor dos Titulos)                                         
           || ';'|| to_char(100,      'FM000')  -- M�nimo de Liquidez de Titulos Geral do Cedente (Qtd de Titulos)                                          
           || ';'|| to_char(100,      'FM000', 'NLS_NUMERIC_CHARACTERS='',.''')  -- M�nimo de Liquidez de Titulos Geral do Cedente (Valor dos Titulos)                                         
           || ';'|| to_char(12,      'FM0000')  --  Per�odo em meses para realizar o c�lculo da liquidez
           || ';'|| to_char(1,      'FM0') -- -- Valor m�ximo permitido por ramo de atividade                               
           || ';'|| SUBSTR(dstextab, 352, 6) -- Concentra��o m�xima de t�tulos por pagador (manter) e Consulta de CPF/CNPJ do pagador (manter)                          
           || ';'|| to_char(30,   'FM0000') -- Quantidade m�xima de dias para envio para esteira
           || ';'|| to_char(60,       'FM0000') -- Dias para expirar border�
           || ';'|| to_char(200,      'FM0000') -- Quantidade m�xima de t�tulos por border� IB
           || ';'|| to_char(500,      'FM0000') -- Quantidade m�xima de t�tulos por border� Ayllos
           -- demais campos operacional
           || ';'|| to_char(5,      'FM0000') -- Qtd. M�nima de titulos descontados para c�lculo de liquidez
           || ';'|| to_char(100,    'FM000000000D00', 'NLS_NUMERIC_CHARACTERS='',.''') -- Valor m�nimo para c�culo da liquidez
           || ';'|| SUBSTR(dstextab, 397, 4) -- Concentra��o m�xima de t�tulos por pagador (manter) e Consulta de CPF/CNPJ do pagador (manter)                          
           -- demais campos ailos
           || ';'|| to_char(10,      'FM0000') -- Qtd. M�nima de titulos descontados para c�lculo de liquidez
           || ';'|| to_char(300,    'FM000000000D00', 'NLS_NUMERIC_CHARACTERS='',.''') -- Valor m�nimo para c�culo da liquidez
           || ';'|| SUBSTR(dstextab, 420, 4) -- Concentra��o m�xima de t�tulos por pagador (manter) e Consulta de CPF/CNPJ do pagador (manter)                          
           
    WHERE cdacesso IN ('LIMDESCTITCRPF') 
    AND   cdcooper = pr_cdcooper;

    -- PJ
    UPDATE craptab  
    SET    dstextab = 
           -- operacional 
              SUBSTR(dstextab, 1, 239)
           || ';'|| to_char(20000,     'FM000000000D00', 'NLS_NUMERIC_CHARACTERS='',.''') -- Valor M�ximo Dispensa Assinatura 
           || ';'|| to_char(1,      'FM0') -- Verificar relacionamento emitente (conjuge/ s�cio)
           || ';'|| to_char(1,      'FM0') -- Verificar Preju�zo do Emitente
           || ';'|| to_char(1,      'FM0') -- Verificar Cooperado Possui Titulos Descontatos na Conta do Pagador
           || ';'|| to_char(70,      'FM000')  -- M�nimo de Liquidez do Cedente x Pagador (Qtd. de Titulos)                                           
           || ';'|| to_char(70,      'FM000')  -- M�nimo de Liquidez do Cedente x Pagador (Valor dos Titulos)                                         
           || ';'|| to_char(80,      'FM000')  -- M�nimo de Liquidez de Titulos Geral do Cedente (Qtd de Titulos)                                          
           || ';'|| to_char(80,      'FM000')  -- M�nimo de Liquidez de Titulos Geral do Cedente (Valor dos Titulos)                                         
           || ';'|| to_char(6,      'FM0000')  --  Per�odo em meses para realizar o c�lculo da liquidez
           || ';'|| to_char(0,      'FM0') -- -- Valor m�ximo permitido por ramo de atividade                               
           || ';'|| SUBSTR(dstextab, 283, 6) -- Concentra��o m�xima de t�tulos por pagador (manter) e Consulta de CPF/CNPJ do pagador (manter)                          
           || ';'|| to_char(20,   'FM0000') -- Quantidade m�xima de dias para envio para esteira
           || ';'|| to_char(60,       'FM0000') -- Dias para expirar border�
           || ';'|| to_char(100,      'FM0000') -- Quantidade m�xima de t�tulos por border� IB
           || ';'|| to_char(300,      'FM0000') -- Quantidade m�xima de t�tulos por border� Ayllos
           -- ailos
           || ';'|| to_char(30000,   'FM000000000D00', 'NLS_NUMERIC_CHARACTERS='',.''') -- Valor M�ximo Dispensa Assinatura 
           || ';'|| to_char(1,      'FM0') -- Verificar relacionamento emitente (conjuge/ s�cio)
           || ';'|| to_char(1,      'FM0') -- Verificar Preju�zo do Emitente
           || ';'|| to_char(1,      'FM0') -- Verificar Cooperado Possui Titulos Descontatos na Conta do Pagador
           || ';'|| to_char(100,      'FM000' , 'NLS_NUMERIC_CHARACTERS='',.''')   -- M�nimo de Liquidez do Cedente x Pagador (Qtd. de Titulos)                                           
           || ';'|| to_char(100,      'FM000', 'NLS_NUMERIC_CHARACTERS='',.''')  -- M�nimo de Liquidez do Cedente x Pagador (Valor dos Titulos)                                         
           || ';'|| to_char(100,      'FM000')  -- M�nimo de Liquidez de Titulos Geral do Cedente (Qtd de Titulos)                                          
           || ';'|| to_char(100,      'FM000', 'NLS_NUMERIC_CHARACTERS='',.''')  -- M�nimo de Liquidez de Titulos Geral do Cedente (Valor dos Titulos)                                         
           || ';'|| to_char(12,      'FM0000')  --  Per�odo em meses para realizar o c�lculo da liquidez
           || ';'|| to_char(1,      'FM0') -- -- Valor m�ximo permitido por ramo de atividade                               
           || ';'|| SUBSTR(dstextab, 352, 6) -- Concentra��o m�xima de t�tulos por pagador (manter) e Consulta de CPF/CNPJ do pagador (manter)                          
           || ';'|| to_char(30,   'FM0000') -- Quantidade m�xima de dias para envio para esteira
           || ';'|| to_char(60,       'FM0000') -- Dias para expirar border�
           || ';'|| to_char(200,      'FM0000') -- Quantidade m�xima de t�tulos por border� IB
           || ';'|| to_char(500,      'FM0000') -- Quantidade m�xima de t�tulos por border� Ayllos
           -- demais campos operacional
           || ';'|| to_char(5,      'FM0000') -- Qtd. M�nima de titulos descontados para c�lculo de liquidez
           || ';'|| to_char(100,    'FM000000000D00', 'NLS_NUMERIC_CHARACTERS='',.''') -- Valor m�nimo para c�culo da liquidez
           || ';'|| SUBSTR(dstextab, 397, 4) -- Concentra��o m�xima de t�tulos por pagador (manter) e Consulta de CPF/CNPJ do pagador (manter)                          
           -- demais campos ailos
           || ';'|| to_char(10,      'FM0000') -- Qtd. M�nima de titulos descontados para c�lculo de liquidez
           || ';'|| to_char(300,    'FM000000000D00', 'NLS_NUMERIC_CHARACTERS='',.''') -- Valor m�nimo para c�culo da liquidez
           || ';'|| SUBSTR(dstextab, 420, 4) -- Concentra��o m�xima de t�tulos por pagador (manter) e Consulta de CPF/CNPJ do pagador (manter)                          
           
    WHERE cdacesso IN ('LIMDESCTITCRPJ') 
    AND   cdcooper = pr_cdcooper;
	
	-- Libera os conv�ncios de desconto de t�tulo para essa cooperativa
	UPDATE crapcco SET flgativo = 1 WHERE dsorgarq = 'DESCONTO DE TITULO' AND cdcooper = pr_cdcooper;
    
  END LOOP;
    
  COMMIT;
END;