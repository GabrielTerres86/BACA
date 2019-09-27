DECLARE 
  --Busca contas - Credcrea
  CURSOR cr_crapass IS
    SELECT cdcooper, nrdconta, nrdctitg, flgctitg
    FROM   CRAPASS 
    WHERE  cdcooper = 7 --Crecrea
    AND    nrdconta IN (336610,  173894,  186538,  187470,  188794,  190446,  211168,  219754,  230685,  238708,  249122,  260924,  273546,  312517,  336688
,  174386,  186562,  187496,  188875,  190691,  211443,  220442,  230790,  239356,  249130,  261300,  274224,  312533,  337005
,  174823,  186597,  187518,  188883,  190764,  213225,  221210,  231061,  239550,  249246,  262439,  274763,  312630,  850004
,  174963,  186600,  187550,  188930,  191094,  213438,  221600,  231339,  239623,  249890,  262510,  275000,  312924
,  174971,  186627,  187666,  189049,  191124,  213764,  221627,  231487,  239763,  249947,  263230,  276120,  321087
,  175633,  186643,  187674,  189057,  191183,  214140,  221864,  231592,  239801,  251534,  263362,  276570,  321427
,  175765,  186660,  187690,  189065,  191256,  214280,  222046,  231916,  239887,  251550,  263460,  276650,  321699
,  175986,  186724,  187798,  189081,  191280,  214396,  222097,  232459,  241059,  251950,  264610,  276855,  322113
,  176109,  186732,  187801,  189090,  191345,  214400,  222151,  232637,  241628,  252034,  265128,  276979,  330159
,  176389,  186740,  187810,  189111,  192015,  214590,  222330,  232696,  241849,  252280,  265187,  280828,  331376
,  176737,  186937,  187828,  189120,  192473,  214671,  223409,  233340,  241890,  252719,  266051,  280933,  331627
,  176745,  186970,  187852,  189189,  193348,  214752,  223956,  233358,  242217,  252794,  266388,  280992,  331635)
    AND    flgctitg <> 3
    ORDER BY nrdconta;

    rw_crapass       cr_crapass%rowtype;
    vr_qtdcta        NUMBER;
BEGIN
  FOR rw_crapass IN cr_crapass LOOP
    BEGIN
      --Atualiza status da conta ITG
      UPDATE CRAPASS
      SET    flgctitg = 3
      WHERE  cdcooper = rw_crapass.cdcooper
      AND    nrdconta = rw_crapass.nrdconta;
    END;

    BEGIN
      --Inclui log de alteração da conta ITG
      INSERT INTO crapalt 
        (nrdconta
        ,dtaltera
        ,cdoperad
        ,dsaltera
        ,tpaltera
        ,flgctitg
        ,cdcooper)
      VALUES
        (rw_crapass.nrdconta
        ,sysdate
        ,1
        ,'exclusao conta-itg('||rw_crapass.nrdctitg||')- ope.1'
        ,2 
        ,0  --nao enviada
        ,rw_crapass.cdcooper);
    END;
    vr_qtdcta := cr_crapass%rowcount;
  END LOOP;
  
  dbms_output.put_line('Qtde contas atualizadas:'||vr_qtdcta);
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN 
    ROLLBACK;
END;
 
