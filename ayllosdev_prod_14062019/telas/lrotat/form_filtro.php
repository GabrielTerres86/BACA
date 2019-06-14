<?
/*!
 * FONTE        : form_filtro.php											Última alteração: 12/07/2016             
 * CRIAÇÃO      : Otto - RKAM
 * DATA CRIAÇÃO : 06/07/2016
 * OBJETIVO     : Mostrar tela de filtro para pesquisa da tela LROTAT
 * --------------
 * ALTERAÇÕES   :  12/07/2016 - Ajustes para finzaliZação da conversáo 
                                (Andrei - RKAM)
 * --------------
 */

session_start();
require_once("../../includes/config.php");
require_once("../../includes/funcoes.php");
require_once("../../includes/controla_secao.php");
isPostMethod();

?>

<form id="frmFiltro" name="frmFiltro" class="formulario" style="display:none;">
	
	<fieldset id="fsetFiltro" name="fsetFiltro" style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<legend><? echo utf8ToHtml("Filtro"); ?></legend>
		
		<div id="divFiltro">
			<label for="cddlinha"><? echo utf8ToHtml("C&oacute;digo:"); ?></label>
			<input type="text" id="cddlinha" name="cddlinha" >
			<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(1); return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>			

		</div>

	</fieldset>
	
</form>
<div id="divBotoesFiltro" style='text-align:center; margin-bottom: 10px; margin-top: 10px; display:none;' >
	<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(1); return false;">Voltar</a>																
	<a href="#" class="botao" id="btProsseguir" name="btProsseguir" onClick="buscaLinhaRotativo();return false;" style="float:none;">Prosseguir</a>																				
</div>
