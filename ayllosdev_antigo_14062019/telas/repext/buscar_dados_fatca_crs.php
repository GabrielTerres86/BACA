<?php
	/*!
	* FONTE        : buscar_dados_fatca_crs.php
	* CRIAÇÃO      : Mateus Zimmermann - Mouts
	* DATA CRIAÇÃO : Abril/2018
	* OBJETIVO     : Rotina para realizar a busca dos dados fatca/crs do cooperado
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
	
	$nrcpfcgc = isset($_POST["nrcpfcgc"]) ? $_POST["nrcpfcgc"] : 0;
	$nrregist = isset($_POST["nrregist"]) ? $_POST["nrregist"] : 0;
	$nriniseq = isset($_POST["nriniseq"]) ? $_POST["nriniseq"] : 0;

	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <nrcpfcgc>".$nrcpfcgc."</nrcpfcgc>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "TELA_REPEXT", "BUSCA_DADOS_FATCA_CRS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"],
	$glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	$xmlObj = getObjectXML($xmlResult);
	
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		$nmdcampo = $xmlObj->roottag->tags[0]->attributes["NMDCAMPO"];	
		
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','$(\'input,select\',\'#divConteudo\').habilitaCampo(); focaCampoErro(\''.$nmdcampo.'\',\'divConteudo\');',false);
	} 
		
	$dados = $xmlObj->roottag->tags[0]->tags[0]->tags;
	
?>

<form id="frmFatcaCrs" name="frmFatcaCrs" class="formulario" style="display:none;">

	<fieldset id="fsetFatcaCrs" name="fsetFatcaCrs" style="padding:0px; margin:0px;">

		<label for="inacordo">Tipo Acordo:</label>
		<input id="inacordo" name="inacordo" type="text" value="<? echo getByTagName($dados,'inacordo') ?>" />

		<label for="dtinicio"><? echo utf8ToHtml('Dt.Início:') ?></label>
		<input id="dtinicio" name="dtinicio" type="text" value="<? echo getByTagName($dados,'dtinicio') ?>"/>
		
		<label for="dtfinal">Dt.Fim:</label>
		<input id="dtfinal" name="dtfinal" type="text" value="<? echo getByTagName($dados,'dtfinal') ?>"/>

		<label for="cdpais"><? echo utf8ToHtml('País aonde possui domicilio/obrigação fiscal:') ?></label>
        <input name="cdpais" id="cdpais" type="text" class="pesquisa" value="<? echo getByTagName($dados,'cdpais') ?>"/>
        <input name="nmpais" id="nmpais" type="text" value="<? echo getByTagName($dados,'nmpais') ?>"/>

        <label for="nridentificacao">NIF:</label>
		<input id="nridentificacao" name="nridentificacao" type="text" value="<? echo getByTagName($dados,'nridentificacao') ?>"/>

        <label for="cdpais_exterior"><? echo utf8ToHtml('País Endereço:') ?></label>
        <input name="cdpais_exterior" id="cdpais_exterior" type="text" class="pesquisa" value="<? echo getByTagName($dados,'cdpais_exterior') ?>"/>        
        <input name="nmpais_exterior" id="nmpais_exterior" type="text" value="<? echo getByTagName($dados,'nmpais_exterior') ?>"/>
			
	</fieldset>	
</form>

<script type="text/javascript">
	
	formataFatcaCrs();
    	 
</script>
