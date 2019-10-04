--SELECT * from tbconv_dominio_campo d WHERE d.nmdominio='INTPCONVENIO';
--Script para popular o campo Tipo de Convênio 
--Data:19/09/2019
--Atualizar o script com os novos convênios criados após a dia 19/09/2019
BEGIN 
  --1-ARRECADAÇÃO
  BEGIN  
   UPDATE gnconve
      SET gnconve.intpconvenio = 1
    WHERE gnconve.cdconven in( 6
                              ,7
                              ,12
                              ,17
                              ,18
                              ,21
                              ,27
                              ,29
                              ,40
                              ,44
                              ,56
                              ,59
                              ,60
                              ,84
                              ,97
                              ,98
                              ,102
                              ,103
                              ,104
                              ,105
                              ,106
                              ,107
                              ,109
                              ,110
                              ,113
                              ,116
                              ,117
                              ,119
                              ,120
                              ,121
                              ,123
                              ,130
                              ,131
                              ,134
                              ,137
                              ,141
                              ,144);
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('1-ARRECADAÇÃO - ERRO: '|| sqlerrm);
  END; 
  --2-DEBITO AUTOMATICO
  BEGIN  
   UPDATE gnconve
      SET gnconve.intpconvenio = 2
    WHERE gnconve.cdconven in( 14
                              ,22
                              ,28
                              ,32
                              ,35
                              ,36
                              ,37
                              ,38
                              ,39
                              ,43
                              ,46
                              ,47
                              ,50
                              ,52
                              ,55
                              ,57
                              ,58
                              ,61
                              ,63
                              ,64
                              ,65
                              ,66
                              ,67
                              ,68
                              ,69
                              ,70
                              ,71
                              ,72
                              ,73
                              ,74
                              ,75
                              ,76
                              ,77
                              ,78
                              ,79
                              ,80
                              ,81
                              ,82
                              ,83
                              ,85
                              ,87
                              ,89
                              ,90
                              ,92
                              ,93
                              ,94
                              ,95
                              ,108
                              ,111
                              ,112
                              ,114
                              ,115
                              ,118
                              ,122
                              ,124
                              ,125
                              ,126
                              ,127
                              ,128
                              ,129
                              ,132
                              ,133
                              ,135
                              ,136
                              ,138
                              ,139
                              ,140
                              ,143
                              ,145
                              ,146 );
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('2-DEBITO AUTOMATICO - ERRO: '|| sqlerrm);
  END;                            
  --3-ARRECADAÇÃO/DEBITO AUTOMATICO
  BEGIN  
   UPDATE gnconve
      SET gnconve.intpconvenio = 3
    WHERE gnconve.cdconven in( 1
                              ,2
                              ,3
                              ,4
                              ,5
                              ,8
                              ,9
                              ,10
                              ,11
                              ,13
                              ,15
                              ,16
                              ,19
                              ,20
                              ,23
                              ,24
                              ,25
                              ,26
                              ,30
                              ,31
                              ,33
                              ,34
                              ,41
                              ,42
                              ,45
                              ,48
                              ,49
                              ,51
                              ,53
                              ,54
                              ,62
                              ,86
                              ,88
                              ,91
                              ,96
                              ,99
                              ,100
                              ,101
                              ,142);
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('3-ARRECADAÇÃO/DEBITO AUTOMATICO - ERRO: '|| sqlerrm);
  END;
  --
  COMMIT;
  --
END;  
