<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Luis Fernando (Supero)
 * DATA CRIAÇÃO : 28/01/2019
 * OBJETIVO     : Cabeçalho para a tela PARECC
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */
?>

<?
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');	
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();

	$xml = "<Root>";
	$xml .= "  <Dados>";
	$xml .= "    <nmdominio>TPENDERECOENTREGA</nmdominio>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "TELA_PARECC", "BUSCA_DOMINIO_PARECC", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
	
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
	}
	
    $tiposEndereco = $xmlObj->roottag->tags[0]->tags;

	$xml = "<Root>";
	$xml .= "  <Dados>";
	$xml .= "    <nmdominio>TPFUNCIONALIDADEENTREGA</nmdominio>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "TELA_PARECC", "BUSCA_DOMINIO_PARECC", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);		
	
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
	}
	
    $funcionalidades = $xmlObj->roottag->tags[0]->tags;

	$xml = "<Root>";
	$xml .= "  <Dados>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "TELA_PARECC", "BUSCA_COOP_PARECC", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);		
	
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
	}
	
    $cooperativas = $xmlObj->roottag->tags[0]->tags;

?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" width="700px">
	<table width="100%">
		
		<tr>
			<td>
				<div>
				<label for="cddopcao"><? echo utf8ToHtml('Op&ccedil;&atilde;o:') ?></label>
				<select id="cddopcao" name="cddopcao" onchange="desabilitaCampos()">
					
					<?php if (in_array('A', $opcoesTela)) { ?>
					<option value="A"><? echo utf8ToHtml('A - Alterar Par&acirc;metros')?> </option>
					<?php } ?>
					<option value="C"><? echo utf8ToHtml('C - Consultar Par&acirc;metros')?> </option>
				</select>
			</td>
			
		</tr>

		<tr>
			<td>
			    <label for="cdcooperativa">Cooperativa:</label>
				<select class="campo" id="cdcooperativa" onChange="carregarFlagHabilitar()" name="cdcooperativa">
				<? foreach($cooperativas as $coop){ ?>
					<option value="<?=getByTagName($coop->tags, 'cdcooperativa')?>"><? echo utf8ToHtml(getByTagName($coop->tags, 'nmrescop'))?> </option>
				<? } ?>
				</select>
				
			</td>
		</tr>
		<tr>
			<td>
			    <label for="idfuncionalidade">Funcionalidade:</label>
				<select class="campo" id="idfuncionalidade" onChange="carregarFlagHabilitar()" name="idfuncionalidade">
					<? foreach($funcionalidades as $func){ ?>
						<option value="<?=getByTagName($func->tags, 'cddominio')?>"><? echo getByTagName($func->tags, 'dscodigo')?> </option>
					<? } ?>
				</select>
				
			</td>
		</tr>
		<tr>
			<td>
				<div style="float:left">
			    	<label for="idtipoenvio">Tipo de Envio:</label>
					<select class="campo" id="idtipoenvio" name="idtipoenvio" disabled>
						<? foreach($tiposEndereco as $tipo){ ?>
							<option value="<?=getByTagName($tipo->tags, 'cddominio')?>"><? echo getByTagName($tipo->tags, 'dscodigo')?> </option>
						<? } ?>
					</select>
				</div>
				<div style="float:right">
					<a href="#" class="botao" id="btnOK" name="btnOK" style="text-align:center;">OK</a>
				</div>
			</td>
		</tr>
	</table>
</form>