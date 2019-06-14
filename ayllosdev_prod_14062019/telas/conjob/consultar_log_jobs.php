<?php
	/*!
	* FONTE        : consultar_log_jobs.php
	* CRIAÇÃO      : Mateus Zimmermann - Mouts
	* DATA CRIAÇÃO : Julho/2018
	* OBJETIVO     : Rotina para realizar a busca do log
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
	
	$cdcooper  = isset($_POST["cdcooper"])  ? $_POST["cdcooper"]  : 0;
	$nmjob     = isset($_POST["nmjob"])     ? $_POST["nmjob"]     : 0;
	$data_de   = isset($_POST["data_de"])   ? $_POST["data_de"]   : 0;
	$data_ate  = isset($_POST["data_ate"])  ? $_POST["data_ate"]  : 0;
	$id_result = isset($_POST["id_result"]) ? $_POST["id_result"] : 0;
	$nrregist = isset($_POST["nrregist"]) ? $_POST["nrregist"] : 0;
	$nriniseq = isset($_POST["nriniseq"]) ? $_POST["nriniseq"] : 0;
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <tlcooper>".$cdcooper."</tlcooper>";
	$xml .= "   <nmjob>".$nmjob."</nmjob>";
	$xml .= "   <data_de>".$data_de."</data_de>";
	$xml .= "   <data_ate>".$data_ate."</data_ate>";
	$xml .= "   <id_result>".$id_result."</id_result>";
	$xml .= "   <nrregist>".$nrregist."</nrregist>";
	$xml .= "   <nriniseq>".$nriniseq."</nriniseq>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "TELA_CONJOB", "CONJOB_LOG_JOBS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"],
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
		
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','$(\'input,select\',\'#divConteudo\').habilitaCampo(); focaCampoErro(\''.$nmdcampo.'\',\'divConteudo\');',false);
	} 
		
	$registros	= $xmlObj->roottag->tags[0]->tags;
	$qtregist   = $xmlObj->roottag->tags[0]->attributes['QTREGIST'];	

?>

<form id="frmConsultaLogJobs" name="frmConsultaLogJobs" class="formulario" style="display:none;">

	<fieldset id="fsetConsultaLogJobs" name="fsetConsultaLogJobs" style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<div class="divRegistros">		
			<table>
				<thead>
					<tr>
						<th>Coop</th>
						<th>JOB</th>
						<th>Data In&iacute;cio</th>
						<th>Data Fim</th>
						<th>Resultado</th>
						<th>Data Ocorr&ecirc;ncia</th>
						<th>LOG</th>
					</tr>
				</thead>
				<tbody>
					<? foreach( $registros as $log ) {    ?>
						<tr>	
							<td><span><? echo getByTagName($log->tags,'dscooper'); ?></span> <? echo getByTagName($log->tags,'dscooper'); ?> </td>
							<td><span><? echo stringTabela(getByTagName($log->tags,'nmjob'), 35, 'maiuscula'); ?></span> <? echo stringTabela(getByTagName($log->tags,'nmjob'), 35, 'maiuscula'); ?> </td>
							<td><span><? echo getByTagName($log->tags,'dtlog_ini'); ?></span> <? echo getByTagName($log->tags,'dtlog_ini'); ?> </td>
							<td><span><? echo getByTagName($log->tags,'dtlog_fim'); ?></span> <? echo getByTagName($log->tags,'dtlog_fim'); ?> </td>
							<td><span><? echo getByTagName($log->tags,'dsresult'); ?></span> <? echo getByTagName($log->tags,'dsresult'); ?> </td>
							<td><span><? echo getByTagName($log->tags,'dtocorre'); ?></span> <? echo getByTagName($log->tags,'dtocorre'); ?> </td>
							<td><span><? echo getByTagName($log->tags,'dslog'); ?></span> <? echo getByTagName($log->tags,'dslog'); ?> </td>
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

<div id="divBotoesConsultaLogJobs" style='text-align:center; margin-bottom: 10px; margin-top: 10px; display:none;' >
	
	<a href="#" class="botao" id="btVoltar" onClick="controlaVoltar('3'); return false;">Voltar</a>	
	
</div>

<script type="text/javascript">	

	$('a.paginacaoAnt').unbind('click').bind('click', function() {

		consultarLogJobs(<? echo ($nriniseq - $nrregist)?>,<?php echo $nrregist?>);

	});
	
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		
		consultarLogJobs(<? echo ($nriniseq + $nrregist)?>,<?php echo $nrregist?>);
		
	});

	formataLogJobs();	
    	 
</script>
