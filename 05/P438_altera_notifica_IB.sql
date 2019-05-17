/*******************************493 - NOVA SITUA��O DE PROPOSTA - APROVADA**********************************************/
--select * from tbgen_notif_msg_cadastro cad where cad.cdmensagem = 493 and cad.cdorigem_mensagem = 8;
--select * from tbgen_notif_automatica_prm prm where prm.cdmensagem = 493 and prm.cdorigem_mensagem = 8;
update tbgen_notif_msg_cadastro cad 
   set cad.dstexto_mensagem = 'Sua proposta de empr�stimo foi aprovada.'
      ,cad.dshtml_mensagem = '<p><b>#nomecompleto</b></p>
  <p>Sua proposta de empr�stimo no valor de <b>R$ #valor</b> foi aprovada e encontra-se dispon�vel para contrata��o no menu <u>EMPR�STIMOS</u> > <u>Acompanhamento de Propostas</u> na Conta Online.</p>
  <p>Ap�s leitura do contrato e confirma��o com a sua senha de seguran�a o valor ser� creditado em conta corrente.</p>'
 where cad.cdmensagem = 493 
   and cad.cdorigem_mensagem = 8;
/*******************************493 - NOVA SITUA��O DE PROPOSTA - APROVADA**********************************************/


/*********************************494 - NOVA SITUA��O DE PROPOSTA*******************************************************/
--select * from tbgen_notif_msg_cadastro cad where cad.cdmensagem = 494 and cad.cdorigem_mensagem = 8;
--select * from tbgen_notif_automatica_prm prm where prm.cdmensagem = 494 and prm.cdorigem_mensagem = 8 and prm.cdmotivo_mensagem = 9;
update tbgen_notif_msg_cadastro cad 
   set cad.dstexto_mensagem = 'Sua proposta de empr�stimo possui uma nova situa��o.'
      ,cad.dshtml_mensagem = '<p><b>#nomecompleto</b></p>
  <p>Sua proposta de empr�stimo no valor de <b>R$ #valor</b> foi atualizada com uma nova situa��o e encontra-se dispon�vel para consulta no menu <u>EMPR�STIMOS</u> > <u>Acompanhamento de Propostas</u> na Conta Online.</p>
  <p>Entre em contato com o PA para maiores informa��es.</p>'
 where cad.cdmensagem = 494 
   and cad.cdorigem_mensagem = 8;
/*********************************494 - NOVA SITUA��O DE PROPOSTA*******************************************************/



/********************************495 - PROPOSTA DE EMPRESTIMO CREDITADA*********************************************/
--select * from tbgen_notif_msg_cadastro cad where cad.cdmensagem = 495 and cad.cdorigem_mensagem = 8;
--select * from tbgen_notif_automatica_prm prm where prm.cdmensagem = 495 and prm.cdorigem_mensagem = 8 and prm.cdmotivo_mensagem = 10;
update tbgen_notif_msg_cadastro cad 
   set cad.dstitulo_mensagem = 'PROPOSTA DE EMPR�STIMO EFETIVADA'
      ,cad.dshtml_mensagem = '<p><b>#nomecompleto</b></p>
  <p>O valor de <b>R$ #valor</b> referente sua proposta de empr�stimo foi creditado em conta corrente. Verifique seu extrato para mais detalhes.</p>'
      ,cad.dstexto_mensagem = 'Sua proposta de empr�stimo foi creditada em sua conta corrente.'
 where cad.cdmensagem = 495 
   and cad.cdorigem_mensagem = 8;
   
update tbgen_notif_automatica_prm prm
   set prm.dsmotivo_mensagem = 'PROPOSTA DE EMPR�STIMO EFETIVADA' -- ERA: PROPOSTA DE EMPRESTIMO CREDITADA 
 where prm.cdmensagem = 495 
   and prm.cdorigem_mensagem = 8 
   and prm.cdmotivo_mensagem = 10;
/********************************495 - PROPOSTA DE EMPRESTIMO CREDITADA*********************************************/

COMMIT;
