begin 
  update SEGURO.tbseg_template_textos set dstexto_template = 'Pessoa(s) designada(s) pelo titular do seguro para receberem a indeniza��o em caso de sua aus�ncia. \n\nNa falta de indica��o de benefici�rios ou se por algum motivo n�o prevalecer a que for feita, ser�o considerados benefici�rios os herdeiros legais do segurado. \n\nPara benefici�rio menor de idade, a indeniza��o ser� paga diretamente na conta corrente do menor de idade (caso possua) ou de seu represente legal.';
  commit;
end;
;  
