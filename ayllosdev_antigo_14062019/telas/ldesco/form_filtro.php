<?
/*!
 * FONTE        : form_filtro.php                           
 * CRIAÇÃO      : Otto - RKAM
 * DATA CRIAÇÃO : 14/01/2015
 * OBJETIVO     : Mostrar tela de filtro para pesquisa da tela LDESCO
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
		
		<legend><? echo utf8ToHtml("Filtro"); ?></legend>
		
		<div id="divFiltro">

			<label class="rotulo txtNormalBold" for="cdcodigo"><? echo utf8ToHtml("Código:"); ?></label>
			<input class="campoTelaSemBorda" type="text" id="cdcodigo" name="cdcodigo" >
			
			<label class="rotulo-linha txtNormalBold" for="tdesconto"><? echo utf8ToHtml("Tipo Desconto:"); ?></label>
			<!-- <input class="campoTelaSemBorda" type="text" id="tdesconto" name="tdesconto" > -->

			<select id="tdesconto" name="tdesconto" class="campoTelaSemBorda">
				<option value="2" selected="true">Cheque</option>
				<option value="3"><? echo utf8ToHtml('Título') ?></option>
			</select>
			
		</div>

	</fieldset>
	
</form>
<div id="divBotoesFiltro" style='text-align:center; margin-bottom: 10px; margin-top: 10px; display:none;' >
	<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(1); return false;">Voltar</a>																
	<a href="#" class="botao" id="btProsseguir" name="btProsseguir" onClick="btnProsseguir();return false;" style="float:none;">Prosseguir</a>																				
</div>
