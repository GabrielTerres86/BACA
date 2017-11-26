<?
/*!
 * FONTE        : form_filtro_contas_antigas_demitidas.php
 * CRIAÇÃO      : Jonata/RKAM 
 * DATA CRIAÇÃO : Novembro/2017
 * OBJETIVO     : Form para apresentar os filtros de pesquisa da tela MATRIC - H.
 * --------------
 * ALTERAÇÕES   :  

 * --------------
 */ 
 
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();	
	
	// Carrega permissões do operador
	require_once('../../includes/carrega_permissoes.php');		
		
	

?>

<form id="frmFiltroContasAntigasDemitidas" name="frmFiltroContasAntigasDemitidas" class="formulario" style="display:none;">

	<input type="hidden" id="rowidass" name="rowidass" />
	<input type="hidden" id="inmatric" name="inmatric" />
		
	<fieldset id="fsetFiltro" name="fsetFiltro" style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<legend><? echo "Filtros"; ?></legend>
		
		<label for="nrdconta">Conta:</label>
		<input type="text" id="nrdconta" name="nrdconta" value="<?php echo getByTagName($registro,'nrdconta') ?>" alt="Informe o numero da conta do cooperado." />
		<a><img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>		
		
		<br style="clear:both" />	
		
	</fieldset>
		
</form>


<div id="divBotoesFiltroContaAntigasDemitidas" style='text-align:center; margin-bottom: 10px; margin-top: 10px; display:none;'>
																			
	<a href="#" class="botao" id="btVoltar" onClick="controlaVoltar('1'); return false;">Voltar</a>																																							
	<a href="#" class="botao" id="btProsseguir" onClick="buscarContasAntigasDemitidas('1','200'); return false;" >Prosseguir</a>	
		   																			
</div>



