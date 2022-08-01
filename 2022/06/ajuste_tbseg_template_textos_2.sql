begin 
  update SEGURO.tbseg_template_textos set dstexto_template = 'Pessoa(s) designada(s) pelo titular do seguro para receberem a indenização em caso de sua ausência. \n\nNa falta de indicação de beneficiários ou se por algum motivo não prevalecer a que for feita, serão considerados beneficiários os herdeiros legais do segurado. \n\nPara beneficiário menor de idade, a indenização será paga diretamente na conta corrente do menor de idade (caso possua) ou de seu represente legal.';
  commit;
end;
;  
