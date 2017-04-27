<?php
/*****************************************************************
  Fonte        : form_natureza_ocupacao.php						Última Alteração: 
  Criação      : Adriano
  Data criação : Fevereiro/2017
  Objetivo     : Mostrar o formulário para informar o código de natureza de ocupação 
  --------------
	Alterações   : 
  --------------
 ****************************************************************/ 
 
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();	
	
?>

<form id="frmNaturezaOcupacao" name="frmNaturezaOcupacao" class="formulario" style="display:none;">	
	
	<fieldset id="fsetNaturezaOcupacao" name="fsetNaturezaOcupacao" style="padding:0px; margin:0px; padding-bottom:10px;display:none;">
	
		<legend> Natureza de Ocupa&ccedil;&atilde;o</legend>
	
		<div id="divNaturezaOcupacao" style="display: none;">	
		
			<label for="cdnatocp">C&oacute;digo da Natureza:</label>
			<input id="cdnatocp" name="cdnatocp" type="text"></input>
			<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa('1'); return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>			
			
			<input id="dsnatocp" name="dsnatocp" type="text"></input>
			
			<br style="clear:both" />			
					
		</div>
		
	</fieldset>
	
</form>

<div id="divBotoesNaturezaOcupacao" style="margin-top:5px; margin-bottom :10px; display:none; text-align: center;">
		
	<a href="#" class="botao" id="btVoltar">Voltar</a>
	<a href="#" class="botao" id="btProsseguir" >Prosseguir</a>
			
</div>

