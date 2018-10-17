<?php
	/*!
	* FONTE        : buscar_dados_compliance.php
	* CRIAÇÃO      : Mateus Zimmermann - Mouts
	* DATA CRIAÇÃO : Abril/2018
	* OBJETIVO     : Rotina para realizar a busca de compliances
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
		
	$nrcpfcgc     = isset($_POST["nrcpfcgc"])     ? $_POST["nrcpfcgc"]     : 0;
	$dtinicio     = isset($_POST["dtinicio"])     ? $_POST["dtinicio"]     : '';
	$dtfinal      = isset($_POST["dtfinal"])      ? $_POST["dtfinal"]      : '';
	$insituacao   = isset($_POST["insituacao"])   ? $_POST["insituacao"]   : 0;
	$inreportavel = isset($_POST["inreportavel"]) ? $_POST["inreportavel"] : 0;
	$nrregist     = isset($_POST["nrregist"])     ? $_POST["nrregist"]     : 0;
	$nriniseq     = isset($_POST["nriniseq"])     ? $_POST["nriniseq"]     : 0;

	//Validar permissão de consulta do usuário
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],'C', false)) <> "") {
		exibirErro("error",$msgError,"Alerta - Ayllos",'estadoInicial();', false);
	}
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <nrcpfcgc>"    .$nrcpfcgc.    "</nrcpfcgc>";
	$xml .= "   <dtinicio>"    .$dtinicio.    "</dtinicio>";
	$xml .= "   <dtfinal>"     .$dtfinal.     "</dtfinal>";
	$xml .= "   <insituacao>"  .$insituacao.  "</insituacao>";
	$xml .= "   <inreportavel>".$inreportavel."</inreportavel>";
	$xml .= "   <nrregist>"    .$nrregist.    "</nrregist>";
	$xml .= "   <nriniseq>"    .$nriniseq.    "</nriniseq>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "TELA_REPEXT", "BUSCA_DADOS_COMPLIANCE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"],
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
		
	$dados	  = $xmlObj->roottag->tags[0]->tags;
	$qtregist = $xmlObj->roottag->tags[0]->attributes['QTREGIST'];

	if ($qtregist == 0) {
		exibirErro('error','Pesquisa não retornou dados.','Alerta - Ayllos','controlaVoltar(\'2\')',false);
	}
?>

<form id="frmCompliance" name="frmCompliance" class="formulario" style="display:none;">
	<input type="hidden" id="gedservidor" name="gedservidor" value="<? echo $GEDServidor ?>">

	<fieldset id="fsetCompliance" name="fsetCompliance" style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<div class="divRegistros">		
			<table>
				<thead>
					<tr>
						<th>Cooperado</th>
						<th>CPF/CNPJ</th>
						<th><? echo utf8ToHtml('Situação') ?></th>
						<th><? echo utf8ToHtml('Reportável') ?></th>
						<th>Digidoc</th>
					</tr>
				</thead>
				<tbody>
					<? foreach( $dados as $dado ) {    ?>
						<tr>	
							<td><? echo stringTabela(getByTagName($dado->tags,'nmpessoa'), 35, 'maiuscula'); ?> </td>
							<td><? echo getByTagName($dado->tags,'nrcpfcgc'); ?> </td>
							<td><? echo getByTagName($dado->tags,'insituacao'); ?> </td>
							<td><? echo getByTagName($dado->tags,'inreportavel'); ?> </td>
							<td><? echo getByTagName($dado->tags,'dsdigidoc'); ?> </td>
							
							<input type="hidden" id="nrcpfcgc" name="nrcpfcgc" value="<? echo getByTagName($dado->tags,'nrcpfcgc'); ?>" />
							<input type="hidden" id="nmpessoa" name="nmpessoa" value="<? echo getByTagName($dado->tags,'nmpessoa'); ?>" />
							<input type="hidden" id="inreportavel" name="inreportavel" value="<? echo getByTagName($dado->tags,'inreportavel'); ?>" />
							<input type="hidden" id="cdtipo_declarado" name="cdtipo_declarado" value="<? echo getByTagName($dado->tags,'cdtipo_declarado'); ?>" />
							<input type="hidden" id="dstipo_declarado" name="dstipo_declarado" value="<? echo getByTagName($dado->tags,'dstipo_declarado'); ?>" />
							<input type="hidden" id="cdtipo_proprietario" name="cdtipo_proprietario" value="<? echo getByTagName($dado->tags,'cdtipo_proprietario'); ?>" />
							<input type="hidden" id="dstipo_proprietario" name="dstipo_proprietario" value="<? echo getByTagName($dado->tags,'dstipo_proprietario'); ?>" />
							<input type="hidden" id="dsjustificativa" name="dsjustificativa" value="<? echo getByTagName($dado->tags,'dsjustificativa'); ?>" />
							<input type="hidden" id="tppessoa" name="tppessoa" value="<? echo getByTagName($dado->tags,'tppessoa'); ?>" />
							<input type="hidden" id="intem_socio" name="intem_socio" value="<? echo getByTagName($dado->tags,'intem_socio'); ?>" />
							<input type="hidden" id="nrdconta" name="nrdconta" value="<? echo getByTagName($dado->tags,'nrdconta'); ?>" />
							<input type="hidden" id="cdcooper" name="cdcooper" value="<? echo getByTagName($dado->tags,'cdcooper'); ?>" />
							
						</tr>	
					<? } ?>
				</tbody>	
			</table>
		</div>
		<div id="divRegistrosRodape" class="divRegistrosRodape">
			<table>	
				<tr>
					<td>
						<? if (isset($qtregist) and $qtregist == 0){ $nriniseq = 0;} ?>
						<? if ($nriniseq > 1){ ?>
							   <a class="paginacaoAnt"><<< Anterior</a>
						<? }else{ ?>
								&nbsp;
						<? } ?>
					</td>
					<td>
						<? if (isset($nriniseq)) { ?>
							   Exibindo <? echo $nriniseq; ?> at&eacute; <? if (($nriniseq + $nrregist) > $qtregist) { echo $qtregist; } else { echo ($nriniseq + $nrregist - 1); } ?> de <? echo $qtregist; ?>
							<? } ?>
					</td>
					<td>
						<? if($qtregist > ($nriniseq + $nrregist - 1)) { ?>
							  <a class="paginacaoProx">Pr&oacute;ximo >>></a>
						<? }else{ ?>
								&nbsp;
						<? } ?>
					</td>
				</tr>
			</table>
		</div>
	</fieldset>
</form>

<div id="divBotoesCompliance" style='text-align:center; margin-bottom: 10px; margin-top: 10px; display:none;' >

	<a href="#" class="botao" id="btVoltar" onClick="controlaVoltar('2'); return false;">Voltar</a>
	<a href="#" class="botao" id="btSocios" onClick="buscarSocios(1,30); return false;"><? echo utf8ToHtml('Sócios') ?></a>
	<a href="#" class="botao" id="btAlterar" onClick="mostraFormCompliance(); return false;">Alterar</a>
	<a href="#" class="botao" id="btDossieDigidoc" onClick="dossieDigidoc('N'); return false;"><? echo utf8ToHtml('Dossiê DigiDOC') ?></a>
	<a href="#" class="botao" id="btLogAlteracoes" onClick="buscarLogAlteracoes('N'); return false;"><? echo utf8ToHtml('Log Alterações') ?></a>

</div>

<div id="divDadosFatcaCrs"></div>

<div id="divDadosContas"></div>

<div id="divBotoes" style='text-align:center; margin-bottom: 10px; margin-top: 10px; display:none;' >

	<a href="#" class="botao" id="btVoltar" onClick="controlaVoltar('2'); return false;">Voltar</a>

</div>

<script type="text/javascript">
	
	$('a.paginacaoAnt').unbind('click').bind('click', function() {

		buscarDadosCompliance(<? echo ($nriniseq - $nrregist)?>,<?php echo $nrregist?>);

	});
	
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		
		buscarDadosCompliance(<? echo ($nriniseq + $nrregist)?>,<?php echo $nrregist?>);
		
	});	
	
	formataCompliance();
	formataTabelaCompliance();	
    	 
</script>