<?
/*!
 * FONTE        : form_filtro.php                         Última alteração:  
 * CRIAÇÃO      : Jonathan - RKAM
 * DATA CRIAÇÃO : 14/01/2015
 * OBJETIVO     : Mostrar tela de filtro para pesquisa da tela RATING
 * --------------
 * ALTERAÇÕES   :  
 * --------------
 */

	session_start();
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");
	require_once("../../includes/controla_secao.php");
	isPostMethod();

	require_once("../../class/xmlfile.php");

	
?>

<form id="frmFiltro" name="frmFiltro" class="formulario" style="display:none;">
	
	<fieldset id="fsetFiltro" name="fsetFiltro" style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<legend>Filtro</legend>
		
		<div id="divFiltro">
		
			<label for="nrdconta"><? echo utf8ToHtml('Conta/dv:') ?></label>
			<input id="nrdconta" name="nrdconta" type="text" ></input>
			<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(1); return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>
			
		</div>

	</fieldset>
	
</form>

<div id="divBotoesFiltro" style='text-align:center; margin-bottom: 10px; margin-top: 10px; display:none;' >
	<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(1); return false;">Voltar</a>																
	<a href="#" class="botao" id="btProsseguir" name="btProsseguir" onClick="btnProsseguir();return false;" style="float:none;">Prosseguir</a>																				
</div>