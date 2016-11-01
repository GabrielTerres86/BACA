<?php
/*****************************************************************
  Fonte        : form_demonstrativo.php
  Criação      : Adriano
  Data criação : Junho/2013
  Objetivo     : Mostra o form para solicitar demonstrativo
  --------------
	Alterações   : 03/08/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
  --------------
 ****************************************************************/ 
 
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();	
?>

<form id="frmDemonstrativo" name="frmDemonstrativo" class="formulario" style="display:none;">	
			
	<fieldset id="fsetDemonstrativo" name="fsetDemonstrativo" style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<legend> Demonstrativo </legend>
		
		<label for="dtvalida">M&ecirc;s e ano de validade:</label>
		<input id="dtvalida" name="dtvalida" type="text" ></input>
				
		<input id="nrdconta" name="nrdconta" type="hidden" value="<?echo getByTagName($registro->tags,'nrdconta');?>"></input>
		<input id="nrcpfcgc" name="nrcpfcgc" type="hidden" value="<?echo getByTagName($registro->tags,'nrcpfcgc');?>"></input>
		<input id="cdagesic" name="cdagesic" type="hidden" value="<?echo getByTagName($registro->tags,'cdagesic');?>"></input>
				
	</fieldset>		
	
</form>

<div id="divBotoesDemonstrativo" style="margin-top:5px; margin-bottom :10px; display:none; text-align: center;">
	
	<a href="#" class="botao" id="btVoltar">Voltar</a>
	<a href="#" class="botao" id="btConcluir">Concluir</a>
	
</div>