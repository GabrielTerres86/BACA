<?php
/*!
 * FONTE        : form_incluir.php
 * CRIAÇÃO      : Mateus Zimmermann (Mouts)
 * DATA CRIAÇÃO : 18/07/2018
 * OBJETIVO     : Formulario de inclusao da Tela SPBFSE
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */ 

	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();	

	// Montar o xml de Requisicao
	$xml  = "<Root>";
	$xml .= " <Dados>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "TELA_SPBFSE", "BUSCA_TBSPB_FASE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);		
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		if($msgErro == null || $msgErro == ''){
			$msgErro = utf8_encode($xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata);
		}
		exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
		exit();
	}

	$fases = $xmlObj->roottag->tags;

?>

<form id="frmIncluir" name="frmIncluir" class="formulario" style="display: none">
	
	<div id="divDetalhes">
		<fieldset style="margin-top: 10px">

			<legend> Detalhes </legend>

			<label for="cdfase"><? echo utf8ToHtml('Código:') ?></label>
			<input type="text" id="cdfase"/>
			
			<label for="nmfase">Nome Fase:</label>
			<input type="text" id="nmfase"/>
			
			<label for="idfase_controlada">Fase Controlada:</label>
			<input type="checkbox" id="idfase_controlada" />

			<label for="cdfase_anterior">Fase Anterior:</label>
			<select name="cdfase_anterior" id="cdfase_anterior">
				<option value=""></option>
				<? foreach($fases as $fase){ ?>
					<option value="<? echo getByTagName($fase->tags,'cdfase') ?>"><? echo getByTagName($fase->tags,'nmfase') ?></option>
				<? } ?>
			</select>

			<label for="qttempo_alerta">Tempo Alerta:</label>
			<input type="text" id="qttempo_alerta"/>
			<label for="lblMinutos">minutos</label>

			<label for="qtmensagem_alerta">Mensagens Alerta:</label>
			<input type="text" id="qtmensagem_alerta"/>
			
			<label for="idreprocessa_mensagem"><? echo utf8ToHtml('Reprocessar Mensagens:') ?></label>
			<input type="checkbox"  id="idreprocessa_mensagem" />
			
			<label for="idconversao"><? echo utf8ToHtml('Conversão:') ?></label>		
			<input type="checkbox" id="idconversao" />
		</fieldset>
	</div>
</form>
