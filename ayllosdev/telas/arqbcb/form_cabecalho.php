<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Lucas Lunelli         
 * DATA CRIAÇÃO : 13/03/2014
 * OBJETIVO     : Cabecalho para a tela ARQCAB
 * --------------
 * ALTERAÇÕES   : 11/05/2018 - Adicionar opcao de C - Configuracao do webservice (Anderson) 
 * --------------
 */
	
	session_start();
	
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');		
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	
	$xml = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cdcooper>0</cdcooper>";
	$xml .= "   <flgativo>1</flgativo>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "PAREST", "PAREST_LISTA_COOPER", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);

	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
		$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		if ($msgErro == "") {
			$msgErro = $xmlObj->roottag->tags[0]->cdata;
		}

		exibeErroNew($msgErro);
		exit();
	}

	$registros = $xmlObj->roottag->tags[0]->tags;

	function exibeErroNew($msgErro) {
		echo 'hideMsgAguardo();';
		echo 'showError("error","' . $msgErro . '","Alerta - Ayllos","desbloqueia()");';
		exit();
	}
	
?>

<form id="frmBcb" name="frmBcb" class="formulario cabecalho" onSubmit="return false;" style="display:none">
	<table width="100%">
		<tr>		
			<td> 	
				<label for="cddopcao"><? echo utf8ToHtml('Op&ccedil;&atilde;o:') ?></label>
				<select id="cddopcao" name="cddopcao" style="width: 460px;">
					<option value="E"> E - Enviar Arquivo </option>
					<option value="R"> R - Receber Arquivo </option>
					<option value="C"> C - Configura&ccedil;&atilde;o WebService </option>
				</select>
				<a href="#" class="botao" id="btnOK" name="btnOK" onClick="LiberaCampos(); return false;" style = "text-align:right;">OK</a>
			</td>
		</tr>
        <tr>		
			<td>				
				<label for="cddarqui"><? echo utf8ToHtml('Tipo:') ?></label>
				<select id="cddarqui" name="cddarqui" style="width: 460px;">
					<option value="A"> Saldo disponível dos Associados </option>
					<option value="C"> Solicitação de Cartão </option>
					<!-- <option value="D"> Conciliação de Débitos </option> -->
				</select>
				<div id="dvconfigws">
					<label for="tlcooper"><? echo utf8ToHtml('Cooperativa:') ?></label>
					<select id="tlcooper" name="tlcooper" style="width: 460px;" onChange="liberaCamposConfiguracaoWebServicePosCooperativa();">
						<option value="0"><? echo utf8ToHtml(' Todas') ?></option> 
						<?php
						foreach ($registros as $r) {
							
							if ( getByTagName($r->tags, 'cdcooper') <> '' ) {
						?>
							<option value="<?= getByTagName($r->tags, 'cdcooper'); ?>"><?= getByTagName($r->tags, 'nmrescop'); ?></option> 
							
							<?php
							}
						}
						?>
					</select>
					<p>
					<label for="flctgbcb"><? echo utf8ToHtml('Habilita Contingencia WebService Bancoob:') ?></label>
					<select id="flctgbcb" name="flctgbcb">
						<option value="0">N&atilde;o</option>;
						<option value="1">Sim</option>;
					</select>
					</p>
				</div>
			</td>
		</tr>		
	</table>
</form>