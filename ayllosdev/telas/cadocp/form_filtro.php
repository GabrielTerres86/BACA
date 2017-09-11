<?php
/*****************************************************************
  Fonte        : form_filtro.php						Última Alteração:  
  Criação      : Kelvin Souza Ott - CECRED
  Data criação : Agosto/2017
  Objetivo     : Mostrar os filtros para da tela CADOCP
  --------------
	Alterações   :  
	
	
 ****************************************************************/ 
 
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();	
	
?>

<form id="frmFiltro" name="frmFiltro" class="formulario" style="display:none;">	
	
	<fieldset id="fsetFiltro" name="fsetFiltro" style="padding:0px; margin:0px; padding-bottom:10px;">
	
		<legend><? echo "Filtros"; ?></legend>
		
		<label for="cdnatocp">Natureza da ocupa&ccedil&atilde;o:</label>
        <input name="cdnatocp" id="cdnatocp" type="text" class="pesquisa" />        
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
        <input name="dsnatocp" id="dsnatocp" type="text" />
			
		<br style="clear:both" />	

	</fieldset>
							
</form>

<div id="divBotoesFiltro" style="margin-top:5px; margin-bottom :10px; display:none; text-align: center;">
		
	<a href="#" class="botao" id="btVoltar" onClick="controlaVoltar('1');">Voltar</a>
	<a href="#" class="botao" id="btProsseguir" onClick="controlaOperacao();return false;">Prosseguir</a>	
				
</div>


