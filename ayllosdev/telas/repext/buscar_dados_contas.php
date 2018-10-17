<?php
	/*!
	* FONTE        : buscar_dados_contas.php
	* CRIAÇÃO      : Mateus Zimmermann - Mouts
	* DATA CRIAÇÃO : Abril/2018
	* OBJETIVO     : Rotina para realizar a busca das contas do cooperado
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
	$nrregist = isset($_POST["nrregist"]) ? $_POST["nrregist"] : 30;
	$nriniseq = isset($_POST["nriniseq"]) ? $_POST["nriniseq"] : 1;
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <nrcpfcgc>".$nrcpfcgc."</nrcpfcgc>";
	$xml .= "   <nrregist>".$nrregist."</nrregist>";
	$xml .= "   <nriniseq>".$nriniseq."</nriniseq>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "TELA_REPEXT", "BUSCA_DADOS_CONTAS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"],
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
		
	$contas	  = $xmlObj->roottag->tags[0]->tags;
	$qtregist = $xmlObj->roottag->tags[0]->attributes['QTREGIST'];

?>


<form id="frmContas" name="frmContas" class="formulario" style="display:none;">
	<fieldset id="fsetContas" name="fsetContas" style="padding:0px; margin:0px;">
		<div id="divTabelaContas" class="divRegistros">		
			<table>
				<thead>
					<tr>
						<th>Cooperativa</th>
						<th>PA</th>
						<th>Conta</th>
						<th>Nome</th>
						<th>Tipo Conta</th>
						<th><? echo utf8ToHtml('% Sócio') ?></th>
					</tr>
				</thead>
				<tbody>
					<? foreach( $contas as $conta ) {    ?>
						<tr>	
							<td><? echo getByTagName($conta->tags,'dscooper'); ?> </td>
							<td><? echo getByTagName($conta->tags,'cdagenci'); ?> </td>
							<td><? echo getByTagName($conta->tags,'nrdconta'); ?> </td>
							<td><? echo stringTabela(getByTagName($conta->tags,'nmpessoa'), 25, 'maiuscula'); ?> </td>
							<td><? echo getByTagName($conta->tags,'tppessoa'); ?> </td>
							<td><? echo getByTagName($conta->tags,'prsocio'); ?> </td>

							<input type="hidden" id="nrdconta" name="nrdconta" value="<? echo getByTagName($conta->tags,'nrdconta'); ?>" />
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
							   <a class="paginacaoAntContas"><<< Anterior</a>
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
							  <a class="paginacaoProxContas">Pr&oacute;ximo >>></a>
						<? }else{ ?>
								&nbsp;
						<? } ?>
					</td>
				</tr>
			</table>
		</div>	
	</fieldset>	
</form>

<div id="divBotoes" style='text-align:center; margin-bottom: 10px; margin-top: 10px;' >

	<a href="#" class="botao" id="btVoltar" onClick="controlaVoltar('2'); return false;">Voltar</a>

</div>

<script type="text/javascript">
	
	$('a.paginacaoAntContas').unbind('click').bind('click', function() {

		buscarDadosContas(<? echo $nrcpfcgc ?>,<? echo ($nriniseq - $nrregist)?>,<?php echo $nrregist?>);

	});
	
	$('a.paginacaoProxContas').unbind('click').bind('click', function() {
		
		buscarDadosContas(<? echo $nrcpfcgc ?>,<? echo ($nriniseq + $nrregist)?>,<?php echo $nrregist?>);
		
	});	
	
	//formataFatcaCrs();
	formataTabelaContas();
    	 
</script>
