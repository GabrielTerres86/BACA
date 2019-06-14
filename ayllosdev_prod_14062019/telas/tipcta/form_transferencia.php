<?
/* * *********************************************************************

  Fonte: form_tipo_de_conta.php
  Autor: Lombardi
  Data : Dezembro/2018                       Última Alteração: 

  Objetivo  : Mostrar valores da TIPCTA.

  Alterações: 

 * ********************************************************************* */

	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');	
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'T',false)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','estadoInicial();',false);
	}
	
	$xml = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cdcooper>0</cdcooper>";
	$xml .= "   <flgativo>1</flgativo>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "CADA0001", "LISTA_COOPERATIVAS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
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
	
?>
<form id="frmTransferencia" name="frmTransferencia" class="formulario" style="display:none;">
	
	<fieldset id="fsetTipoConta" name="fsetTipoConta" style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<legend>Tipo de Conta</legend>

		<label for="inpessoa"><? echo utf8ToHtml("Tipo de Pessoa:"); ?></label>

		<input type="radio" id="inpessoa_1" name="inpessoa" class="radio" value="1">
		<label><? echo utf8ToHtml("F&iacute;sica"); ?></label>
		
		<input type="radio" id="inpessoa_2" name="inpessoa" class="radio" value="2">
		<label><? echo utf8ToHtml("Jur&iacute;dica"); ?></label>
		
		<input type="radio" id="inpessoa_3" name="inpessoa" class="radio" value="3" <? echo (validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'P',false) <> '') ? 'style="display: none;"' : '';?> >
		<label <? echo (validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'P',false) <> '') ? 'style="display: none;"' : '';?> ><? echo utf8ToHtml("Jur&iacute;dica – Cooperativa"); ?></label>
		
		<label for="cdcooper"><? echo utf8ToHtml("Cooperativa:"); ?></label>
		<select id="cdcooper">
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
		<div id="divTransferencia_1">
			<label for="cdtipo_conta"><? echo utf8ToHtml("Tipo de Conta Origem:"); ?></label>
			<input type="text" id="cdtipo_conta" name="cdtipo_conta" >
			
			<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa('divTransferencia_1',false); return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>
			
			<input type="text" id="dstipo_conta" name="dstipo_conta" >
		</div>
		<div id="divTransferencia_2">
			<label for="cdtipo_conta"><? echo utf8ToHtml("Tipo de Conta Destino:"); ?></label>
			<input type="text" id="cdtipo_conta" name="cdtipo_conta" >
			
			<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa('divTransferencia_2',false); return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>
			
			<input type="text" id="dstipo_conta" name="dstipo_conta" >
		</div>
	</fieldset>
	
	<div id="divBotoes" style="display:none;padding-bottom: 15px;">
		<a href="#" class="botao" id="btVoltar">Voltar</a>																																							
		<a href="#" class="botao" id="btProsseguir" ></a>
	</div>
</form>

