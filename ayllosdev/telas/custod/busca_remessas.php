<?php
	/*!
	 * FONTE        : busca_remessas.php
	 * CRIAÇÃO      : Lucas Reinert
	 * DATA CRIAÇÃO : 15/09/2016
	 * OBJETIVO     : Rotina para buscar as remessas de cheques custodiados
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
	
	$nrdconta = !isset($_POST["nrdconta"]) ? 0  : $_POST["nrdconta"];
	$dtinicst = !isset($_POST["dtinicst"]) ? "" : $_POST["dtinicst"];
	$dtfimcst = !isset($_POST["dtfimcst"]) ? "" : $_POST["dtfimcst"];
	$cdagenci = !isset($_POST["cdagenci"]) ? 0  : $_POST["cdagenci"];
	$insithcc = !isset($_POST["insithcc"]) ? 0  : $_POST["insithcc"];
	$nriniseq = (isset($_POST['nriniseq'])) ? $_POST['nriniseq'] : 1;
	$nrregist = (isset($_POST['nrregist'])) ? $_POST['nrregist'] : 50;

	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],"L")) <> '') {
		exibirErro('error',$msgError,'Alerta - Aimaro','',false);
	}
	
	// Verifica se os parâmetros necessários foram informados
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta inv&aacute;lida.','Alerta - Aimaro','',false);
	if ($dtinicst == "" || $dtfimcst == "") exibirErro('error','Parametro inv&aacute;lido.','Alerta - Aimaro','',false);
		
	// Montar o xml de Requisicao
	$xml  = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <dtinicst>".$dtinicst."</dtinicst>";
	$xml .= "   <dtfimcst>".$dtfimcst."</dtfimcst>";
	$xml .= "   <cdagenci>".$cdagenci."</cdagenci>";
	$xml .= "   <insithcc>".$insithcc."</insithcc>";
	$xml .= "	<nriniseq>".$nriniseq."</nriniseq>";
	$xml .= "	<nrregist>".$nrregist."</nrregist>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "TELA_CUSTOD", "CUSTOD_BUSCA_REMESSAS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);		
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		if($msgErro == null || $msgErro == ''){
			$msgErro = utf8_encode($xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata);
		}
		exibirErro('error',$msgErro,'Alerta - Aimaro','',false);
		exit();
	}
	
	$qtregist = $xmlObj->roottag->tags[1]->cdata;
		
?>
<div class="divRegistros">	
	<table class="tituloRegistros" id="tbCheques">
		<thead>
			<tr>
				<th>Conta</th>
				<th>Data</th>
				<th>Remessa</th>
				<th>Valor Total</th>
				<th>Qtd. Cheques</th>
				<th>Qtd. Conciliados</th>
				<th>Status</th>
				<th>Data Cust&oacute;dia</th>
				<th>Arquivo</th>
			</tr>
		</thead>
		<tbody>
			<input type="hidden" id="nriniseq" value="<? echo $nriniseq ?>"/>
			<input type="hidden" id="nrregist" value="<? echo $nrregist ?>"/>

		<?
			if(strtoupper($xmlObj->roottag->tags[0]->name == 'DADOS')){	
				foreach($xmlObj->roottag->tags[0]->tags as $infoRemessa){
					$aux_nrdconta = $infoRemessa->tags[0]->cdata; // Conta
					$aux_dtmvtolt = $infoRemessa->tags[1]->cdata; // Data
					$aux_nrremret = $infoRemessa->tags[2]->cdata; // Remessa
					$aux_vltotchq = $infoRemessa->tags[3]->cdata; // Valor total dos cheques
					$aux_qtcheque = $infoRemessa->tags[4]->cdata; // Quantidade de Cheques
					$aux_qtconcil = $infoRemessa->tags[5]->cdata; // Quantidade de Cheques
					$aux_insithcc = $infoRemessa->tags[6]->cdata; // Situação
					$aux_dtcustod = $infoRemessa->tags[7]->cdata; // Data de custódia
					$aux_nmarquiv = $infoRemessa->tags[8]->cdata; // Nome arquivo			
					$aux_nrconven = $infoRemessa->tags[9]->cdata; // Convênio
					$aux_intipmvt = $infoRemessa->tags[10]->cdata; // Tipo de movimento (1 - Remessa, 2 - Retorno, 3 - Tela)
					$aux_nmprimtl = $infoRemessa->tags[11]->cdata; // Nome do titular da conta
					$aux_dsorigem = $infoRemessa->tags[12]->cdata; // Descrição da origem
					?>
					<tr>
						<td id="nrdconta" ><span><? echo $aux_nrdconta ?></span><? echo $aux_nrdconta ?></td>
						<td id="dtmvtolt" ><span><? echo $aux_dtmvtolt ?></span><? echo $aux_dtmvtolt ?></td>
						<td id="nrremret" ><span><? echo $aux_nrremret ?></span><? echo $aux_nrremret ?></td>
						<td id="vltotchq" ><span><? echo $aux_vltotchq ?></span><? echo $aux_vltotchq ?></td>
						<td id="qtcheque" ><span><? echo $aux_qtcheque ?></span><? echo $aux_qtcheque ?></td>
						<td id="qtconcil" ><span><? echo $aux_qtconcil ?></span><? echo $aux_qtconcil ?></td>
						<td id="insithcc" ><span><? echo $aux_insithcc ?></span><? echo $aux_insithcc ?></td>
						<td id="dtcustod" ><span><? echo $aux_dtcustod ?></span><? echo $aux_dtcustod ?></td>
						<td id="nmarquiv" ><span><? echo $aux_nmarquiv ?></span><? echo $aux_nmarquiv ?></td>
						<input type="hidden" id="nrconven" value="<? echo $aux_nrconven ?>"/>
						<input type="hidden" id="intipmvt" value="<? echo $aux_intipmvt ?>"/>
						<input type="hidden" id="nmprimtl" value="<? echo $aux_nmprimtl ?>"/>
						<input type="hidden" id="dsorigem" value="<? echo $aux_dsorigem ?>"/>
					</tr>
					<?
				}		
			}
		?>
		</tbody>
	</table>
</div>						
<div id="divPesquisaRodape" class="divPesquisaRodape">
	<table>	
		<tr>
			<td>
				<?
					//
					if (isset($qtregist) and $qtregist == 0) $nriniseq = 0;
					
					// Se a paginação não está na primeira, exibe botão voltar
					if ($nriniseq > 1) { 
						?> <a class='paginacaoAnt'><<< Anterior</a> <? 
					} else {
						?> &nbsp; <?
					}
				?>
			</td>
			<td>
				<?
					if (isset($nriniseq)) { 
						?> Exibindo <? echo $nriniseq; ?> at&eacute; <? if (($nriniseq + $nrregist) > $qtregist) { echo $qtregist; } else { echo ($nriniseq + $nrregist - 1); } ?> de <? echo $qtregist; ?><?
					}
				?>
			</td>
			<td>
				<?
					// Se a paginação não está na &uacute;ltima página, exibe botão proximo
					if ($qtregist > ($nriniseq + $nrregist - 1)) {
						?> <a class='paginacaoProx'>Pr&oacute;ximo >>></a> <?
					} else {
						?> &nbsp; <?
					}
				?>			
			</td>
		</tr>
	</table>
</div>


<script type="text/javascript">

    $('a.paginacaoAnt').unbind('click').bind('click', function() {
        buscaRemessas(<?php echo "'" . ($nriniseq - $nrregist) . "','" . $nrregist . "'"; ?>);
    });

    $('a.paginacaoProx').unbind('click').bind('click', function() {
        buscaRemessas(<?php echo "'" . ($nriniseq + $nrregist) . "','" . $nrregist . "'"; ?>);
    });
</script>
