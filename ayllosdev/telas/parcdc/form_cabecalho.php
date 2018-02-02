<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Jean Michel Deschamps
 * DATA CRIAÇÃO : 06/12/2017
 * OBJETIVO     : Cabeçalho para a tela PARCDC
 * --------------
 * ALTERAÇÕES   : 
 *				  
 * --------------
 */
	
	session_start();
	
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');		
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();
	
	$xml  = '';
	$xml .= '<Root><Dados>';
	$xml .= '<cdcooper>0</cdcooper>';
	$xml .= '<flgativo>1</flgativo>';
	$xml .= '</Dados></Root>';
		
	// Enviar XML de ida e receber String XML de resposta
	$xmlResultCooper = mensageria($xml, 'CADA0001','LISTA_COOPERATIVAS', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjetoCooper = getObjectXML($xmlResultCooper);

	// Se ocorrer um erro, mostra crítica
	if (isset($xmlObjetoCooper->roottag->tags[0]->name) && strtoupper($xmlObjetoCooper->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjetoCooper->roottag->tags[0]->tags[0]->tags[4]->cdata);
		die();
	}
	
	$lstCooper = $xmlObjetoCooper->roottag->tags[0]->tags;

?>
<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;" style="display:none">
	<table width = "100%">
		<tr>		
			<td> 	
				<label for="cdcooper"><? echo utf8ToHtml('Cooperativa:') ?></label>
				<select id="cdcooper" name="cdcooper">
					<?php
					if ($glbvars["cdcooper"] == 3){
					?>
						<option value="99">Todas</option> 
					<?php
						foreach ($lstCooper as $cooper) {								
							if ( getByTagName($cooper->tags, 'CDCOOPER') <> '' ) {
					?>
						<option value="<?= getByTagName($cooper->tags, 'CDCOOPER'); ?>"><?= getByTagName($cooper->tags, 'NMRESCOP'); ?></option> 
					<?php
							}
						}
					}else{
					?>
						<option value="<?= $glbvars["cdcooper"]?>"><?= strtoupper($glbvars["nmcooper"]) ?></option> 
					<?php
					}
					?>
				</select>
				<a href="#" class="botao" id="btnOK" name="btnOK" style = "text-align:right;">OK</a>
			</td>
		</tr>		
	</table>
</form>