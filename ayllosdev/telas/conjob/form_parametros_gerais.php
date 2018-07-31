<?php
	/*!
	* FONTE        : form_parametros_gerais.php
	* CRIAÇÃO      : Mateus Zimmermann - Mouts
	* DATA CRIAÇÃO : Junho/2018
	* OBJETIVO     : Formulário para realizar a alteração dos valores dos parametros do sistema
	* --------------
	* ALTERAÇÕES   : 
	* -------------- 
	*/		
 
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		

	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
		
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
	
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "TELA_CONJOB", "CONJOB_BUSCA_PARAMET", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"],
	$glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	$xmlObj = getObjectXML($xmlResult);
	
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','',false);
	} 
		
	$registros	= $xmlObj->roottag->tags[0]->tags;
	
?>

<form id="frmParametrosGerais" name="frmParametrosGerais" class="formulario" style="display:none;">

	<fieldset id="fsetParametrosGerais" name="fsetParametrosGerais" style="padding:0px; margin:0px; padding-bottom:10px;">

		<label for="nmjobmaster"><? echo utf8ToHtml('Nome JOB Master:') ?></label>
		<input type="text" id="nmjobmaster" name="nmjobmaster" value="<? echo getByTagName($registros,'nmjobmaster'); ?>" />

		<label for="numminjob"><? echo utf8ToHtml('Intervalo Execução JOB Master:') ?></label>
		<input type="text" id="numminjob" name="numminjob" value="<? echo getByTagName($registros,'numminjob'); ?>" />
		<label for="lblminutos"><? echo utf8ToHtml('minutos') ?></label>

		<label for="qtjobporhor0"><? echo utf8ToHtml('Quantidade máxima de paralelos das: 00:00 até 01:00:') ?></label>
		<input type="text" id="qtjobporhor0" name="qtjobporhor0" value="<? echo getByTagName($registros,'qtjobporhor0'); ?>" />

		<label for="qtjobporhor12"><? echo utf8ToHtml('das: 12:00 até 13:00:') ?></label>
		<input type="text" id="qtjobporhor12" name="qtjobporhor12" value="<? echo getByTagName($registros,'qtjobporhor12'); ?>" />

		<label for="qtjobporhor1"><? echo utf8ToHtml('das: 01:00 até 02:00:') ?></label>
		<input type="text" id="qtjobporhor1" name="qtjobporhor1" value="<? echo getByTagName($registros,'qtjobporhor1'); ?>" />

		<label for="qtjobporhor13"><? echo utf8ToHtml('das: 13:00 até 14:00:') ?></label>
		<input type="text" id="qtjobporhor13" name="qtjobporhor13" value="<? echo getByTagName($registros,'qtjobporhor13'); ?>" />

		<label for="qtjobporhor2"><? echo utf8ToHtml('das: 02:00 até 03:00:') ?></label>
		<input type="text" id="qtjobporhor2" name="qtjobporhor2" value="<? echo getByTagName($registros,'qtjobporhor2'); ?>" />

		<label for="qtjobporhor14"><? echo utf8ToHtml('das: 14:00 até 15:00:') ?></label>
		<input type="text" id="qtjobporhor14" name="qtjobporhor14" value="<? echo getByTagName($registros,'qtjobporhor14'); ?>" />

		<label for="qtjobporhor3"><? echo utf8ToHtml('das: 03:00 até 04:00:') ?></label>
		<input type="text" id="qtjobporhor3" name="qtjobporhor3" value="<? echo getByTagName($registros,'qtjobporhor3'); ?>" />

		<label for="qtjobporhor15"><? echo utf8ToHtml('das: 15:00 até 16:00:') ?></label>
		<input type="text" id="qtjobporhor15" name="qtjobporhor15" value="<? echo getByTagName($registros,'qtjobporhor15'); ?>" />

		<label for="qtjobporhor4"><? echo utf8ToHtml('das: 04:00 até 05:00:') ?></label>
		<input type="text" id="qtjobporhor4" name="qtjobporhor4" value="<? echo getByTagName($registros,'qtjobporhor4'); ?>" />

		<label for="qtjobporhor16"><? echo utf8ToHtml('das: 16:00 até 17:00:') ?></label>
		<input type="text" id="qtjobporhor16" name="qtjobporhor16" value="<? echo getByTagName($registros,'qtjobporhor16'); ?>" />

		<label for="qtjobporhor5"><? echo utf8ToHtml('das: 05:00 até 06:00:') ?></label>
		<input type="text" id="qtjobporhor5" name="qtjobporhor5" value="<? echo getByTagName($registros,'qtjobporhor5'); ?>" />

		<label for="qtjobporhor17"><? echo utf8ToHtml('das: 17:00 até 18:00:') ?></label>
		<input type="text" id="qtjobporhor17" name="qtjobporhor17" value="<? echo getByTagName($registros,'qtjobporhor17'); ?>" />

		<label for="qtjobporhor6"><? echo utf8ToHtml('das: 06:00 até 07:00:') ?></label>
		<input type="text" id="qtjobporhor6" name="qtjobporhor6" value="<? echo getByTagName($registros,'qtjobporhor6'); ?>" />

		<label for="qtjobporhor18"><? echo utf8ToHtml('das: 18:00 até 19:00:') ?></label>
		<input type="text" id="qtjobporhor18" name="qtjobporhor18" value="<? echo getByTagName($registros,'qtjobporhor18'); ?>" />

		<label for="qtjobporhor7"><? echo utf8ToHtml('das: 07:00 até 08:00:') ?></label>
		<input type="text" id="qtjobporhor7" name="qtjobporhor7" value="<? echo getByTagName($registros,'qtjobporhor7'); ?>" />

		<label for="qtjobporhor19"><? echo utf8ToHtml('das: 19:00 até 20:00:') ?></label>
		<input type="text" id="qtjobporhor19" name="qtjobporhor19" value="<? echo getByTagName($registros,'qtjobporhor19'); ?>" />

		<label for="qtjobporhor8"><? echo utf8ToHtml('das: 08:00 até 09:00:') ?></label>
		<input type="text" id="qtjobporhor8" name="qtjobporhor8" value="<? echo getByTagName($registros,'qtjobporhor8'); ?>" />

		<label for="qtjobporhor20"><? echo utf8ToHtml('das: 20:00 até 21:00:') ?></label>
		<input type="text" id="qtjobporhor20" name="qtjobporhor20" value="<? echo getByTagName($registros,'qtjobporhor20'); ?>" />

		<label for="qtjobporhor9"><? echo utf8ToHtml('das: 09:00 até 10:00:') ?></label>
		<input type="text" id="qtjobporhor9" name="qtjobporhor9" value="<? echo getByTagName($registros,'qtjobporhor9'); ?>" />

		<label for="qtjobporhor21"><? echo utf8ToHtml('das: 21:00 até 22:00:') ?></label>
		<input type="text" id="qtjobporhor21" name="qtjobporhor21" value="<? echo getByTagName($registros,'qtjobporhor21'); ?>" />

		<label for="qtjobporhor10"><? echo utf8ToHtml('das: 10:00 até 11:00:') ?></label>
		<input type="text" id="qtjobporhor10" name="qtjobporhor10" value="<? echo getByTagName($registros,'qtjobporhor10'); ?>" />

		<label for="qtjobporhor22"><? echo utf8ToHtml('das: 22:00 até 23:00:') ?></label>
		<input type="text" id="qtjobporhor22" name="qtjobporhor22" value="<? echo getByTagName($registros,'qtjobporhor22'); ?>" />

		<label for="qtjobporhor11"><? echo utf8ToHtml('das: 11:00 até 12:00:') ?></label>
		<input type="text" id="qtjobporhor11" name="qtjobporhor11" value="<? echo getByTagName($registros,'qtjobporhor11'); ?>" />

		<label for="qtjobporhor23"><? echo utf8ToHtml('das: 23:00 até 00:00:') ?></label>
		<input type="text" id="qtjobporhor23" name="qtjobporhor23" value="<? echo getByTagName($registros,'qtjobporhor23'); ?>" />

		<label for="fltpaviso"><? echo utf8ToHtml('Tipo de Aviso / Saída Habilitada:') ?></label>
		<input type="checkbox" id="flmailhab" name="flmailhab" class="checkbox" <? echo getByTagName($registros,'flmailhab') == 'S' ? 'checked' : '' ?> />
		<label for="flmailhab"><? echo utf8ToHtml('Email') ?></label>

		<label for="lblLog"></label>
		<input type="checkbox" id="flarqhab" name="flarqhab" class="checkbox" <? echo getByTagName($registros,'flarqhab') == 'S' ? 'checked' : '' ?> />
		<label for="flarqhab"><? echo utf8ToHtml('LOG') ?></label>

	</fieldset>

</form>

<div id="divBotoesParametros" style='text-align:center; margin-bottom: 10px; margin-top: 10px; display:none;' >
	
	<a href="#" class="botao" id="btVoltar" onClick="controlaVoltar('1'); return false;">Voltar</a>	
	<a href="#" class="botao" id="btConcluir" onClick="gravarParametrosGerais(); return false;">Gravar</a>	
	
</div>

<script type="text/javascript">
	
	formataParametrosGerais();
    	 
</script>
