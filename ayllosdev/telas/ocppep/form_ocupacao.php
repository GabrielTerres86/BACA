<?php
/*****************************************************************
  Fonte        : form_ocupacao.php						Última Alteração: 
  Criação      : Adriano
  Data criação : Fevereiro/2017
  Objetivo     : Mostrar o formulário da ocupação
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

<form id="frmOcupacao" name="frmOcupacao" class="formulario" style="display:none;">	
		
	<fieldset id="fsetOcupacao" name="fsetOcupacao" style="padding:0px; margin:0px; padding-bottom:10px;">
	
		<legend> Ocupa&ccedil;&otilde;es</legend>
	
		<div id="divOcupacao" style="display: none;">	
		
			<label for="cdocupa">Código da Ocupa&ccedil;&atilde;o:</label>
			<input id="cdocupa" name="cdocupa" type="text"></input>
			<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa('2'); return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>			
			
			<br style="clear:both" />			
					
		</div>

	</fieldset>
	
</form>

<div id="divBotoesOcupacao" style="margin-top:5px; margin-bottom :10px; display:none; text-align: center;">
		
	<a href="#" class="botao" id="btVoltar" onClick="controlaVoltar('V3');">Voltar</a>
	<a href="#" class="botao" id="btProsseguir" >Prosseguir</a>
		
</div>

