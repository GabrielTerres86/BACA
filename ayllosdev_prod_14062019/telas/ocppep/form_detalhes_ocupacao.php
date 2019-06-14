<?php
/*****************************************************************
  Fonte        : form_detalhes_ocupacao.php						Última Alteração: 
  Criação      : Adriano
  Data criação : Fevereiro/2017
  Objetivo     : Mostrar o formulário de detalhes da ocupação
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

<form id="frmDetalhesOcupacao" name="frmDetalhesOcupacao" class="formulario" style="display:none;">	
		
	<fieldset id="fsetDetalhesOcupacao" name="fsetDetalhesOcupacao" style="padding:0px; margin:0px; padding-bottom:10px;">
	
		<legend> Ocupa&ccedil;&otilde;es</legend>
	
		<div id="divDetalhesOcupacao" style="display: none;">	
		
			<label for="dsdocupa">Descri&ccedil;&atilde;o:</label>
			<input id="dsdocupa" name="dsdocupa" type="text"></input>
			
			<br />
			
			<label for="rsdocupa">Resumo:</label>
			<input id="rsdocupa" name="rsdocupa" type="text"></input>
					
			<br />					
			<br style="clear:both" />			
					
		</div>

	</fieldset>
	
</form>

<div id="divBotoesDetalhesOcupacao" style="margin-top:5px; margin-bottom :10px; display:none; text-align: center;">
		
	<a href="#" class="botao" id="btVoltar" onClick="controlaVoltar('V4');">Voltar</a>
	<a href="#" class="botao" id="btConcluir">Concluir</a>
		
</div>

