<?php
/***********************************************************************************************
  Fonte        : form_troca_op_conta_corrente.php
  Criação      : Adriano
  Data criação : Maio/2013
  Objetivo     : Mostra o form de troca de OP/Conta corrente da tela INSS
  --------------
	Alterações   : 03/08/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
  --------------
 ***********************************************************************************************/ 
	
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();	
?>

<form id="frmTrocaOpContaCorrente" name="frmTrocaOpContaCorrente" class="formulario" style="display:none;">	
	
		
	<fieldset id="fsetTrocaOpContaCorrente" name="fsetTrocaOpContaCorrente" style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<legend> Troca Conta Corrente </legend>
		
		<label for="nrctaant">Conta/dv atual:</label>
		<input id="nrctaant" name="nrctaant" type="text" value="<?echo formataContaDV(getByTagName($registro->tags,'nrdconta'));?>"></input>
		
		<label for="orgpgant">&Oacute;rg&atilde;o pagador atual:</label>
		<input id="orgpgant" name="orgpgant" type="text" value="<?echo getByTagName($registro->tags,'cdorgins');?>"></input>
		
		<br />
		
		<label for="nrdconta">Nova conta/dv:</label>
		<input id="nrdconta" name="nrdconta" type="text"></input>
		<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(2); return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>
		
		<label for="idseqttl">Titular:</label>
		<select id="idseqttl" name="idseqttl" ></select>
		
		<br /> 
		
		<label for="cdorgins">Novo &oacute;rg&atilde;o pagador:</label>
		<input id="cdorgins" name="cdorgins" type="text"></input>
		
		<input id="cdagepac" name="cdagepac" type="hidden" ></input>
		
		<br />
				
	</fieldset>		
	
</form>


<div id="divBotoesTrocaOpContaCorrente" style="margin-top:5px; margin-bottom :10px; display:none; text-align: center;">
		
	<a href="#" class="botao" id="btVoltar">Voltar</a>
	<a href="#" class="botao" id="btConcluir">Concluir</a> 
		
</div>