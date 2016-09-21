<?php
/************************************************************************************************
  Fonte        : form_troca_domicilio.php
  Criação      : Adriano
  Data criação : Maio/2013
  Objetivo     : Mostra o form de troca de domicilio da tela INSS
  --------------
	Alterações   : 03/08/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
  --------------
 ************************************************************************************************/ 

	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();	
 
?>

<form id="frmTrocaDomicilio" name="frmTrocaDomicilio" class="formulario" style="display:none;">	
	
		
	<fieldset id="fsetTrocaDomicilio" name="fsetTrocaDomicilio" style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<legend> Troca OP </legend>
		
		<label for="orgbenef">Origem do beneficio:</label>
		<input id="orgbenef" name="orgbenef" type="text" value="<?echo getByTagName($registro->tags,'razaosoc');?>"></input>
		
		<br />
		
		<label for="nrdconta">Conta/dv para credito:</label>
		<input id="nrdconta" name="nrdconta" type="text" ></input>
		<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(3); return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>
		
		<br />
		<label for="idseqttl">Titular:</label>
		<select id="idseqttl" name="idseqttl"></select>
		
		<input id="dtcompvi" name="dtcompvi" type="hidden" value="<?echo getByTagName($registro->tags,'dtcompvi');?>"></input>
		<input id="dscsitua" name="dscsitua" type="hidden" value="<?echo getByTagName($registro->tags,'dscsitua');?>"></input>
		<input id="idbenefi" name="idbenefi" type="hidden" value="<?echo getByTagName($registro->tags,'idbenefi');?>"></input>
		<input id="cdcopsic" name="cdcopsic" type="hidden" value="<?echo getByTagName($registro->tags,'cdcopsic');?>"></input>
		<input id="cdorgins" name="cdorgins" type="hidden" value="<?echo getByTagName($registro->tags,'cdorgins');?>"></input>
		<input id="nrctaant" name="nrctaant" type="hidden" value="<?echo getByTagName($registro->tags,'nrdconta');?>"></input>
		<input id="nrcpfant" name="nrcpfant" type="hidden" value="<?echo getByTagName($registro->tags,'nrcpfcgc');?>"></input>
		<input id="cdcopant" name="cdcopant" type="hidden" value="<?echo getByTagName($registro->tags,'cdcooper');?>"></input>
							
		<br style="clear:both"/>
				
	</fieldset>		
	
</form>


<div id="divBotoesTrocaDomicilio" style="margin-top:5px; margin-bottom :10px; display:none; text-align: center;">
		
	<a href="#" class="botao" id="btVoltar">Voltar</a>
	<a href="#" class="botao" id="btConcluir">Concluir</a> 
			
</div>
