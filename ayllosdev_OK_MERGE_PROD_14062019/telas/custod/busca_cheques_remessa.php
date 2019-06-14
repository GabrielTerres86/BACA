<?php
	/*!
	 * FONTE        : busca_cheques_remessa.php
	 * CRIAÇÃO      : Lucas Reinert
	 * DATA CRIAÇÃO : 16/09/2016
	 * OBJETIVO     : Rotina para buscar os cheques (custodiados/a serem custodiados) da remessa
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
	$nrconven = !isset($_POST["nrconven"]) ? 0  : $_POST["nrconven"];
	$nrremret = !isset($_POST["nrremret"]) ? 0  : $_POST["nrremret"];
	$intipmvt = !isset($_POST["intipmvt"]) ? 0  : $_POST["intipmvt"];
	$insithcc = !isset($_POST["insithcc"]) ? ''  : $_POST["insithcc"];
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],"L")) <> '') {
		exibirErro('error',$msgError,'Alerta - Aimaro','',false);
	}
	
	// Verifica se os parâmetros necessários foram informados
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta inv&aacute;lida.','Alerta - Aimaro','',false);
	if ($nrconven == "" || $nrremret == "" || $intipmvt == "") exibirErro('error','Parametro inv&aacute;lido.','Alerta - Aimaro','',false);
		
	// Montar o xml de Requisicao
	$xml  = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <nrconven>".$nrconven."</nrconven>";
	$xml .= "   <nrremret>".$nrremret."</nrremret>";
	$xml .= "   <intipmvt>".$intipmvt."</intipmvt>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "TELA_CUSTOD", "CUSTOD_BUSCA_CHEQUES_REMESSA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
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
		
?>
<div class="divRegistros" id="divCheques">	
	<table class="tituloRegistros" id="tbCheques">
		<thead>
			<tr>
				<th>Compe</th>
				<th>Banco</th>
				<th>Ag&ecirc;ncia</th>
				<th>Conta</th>
				<th>Cheque</th>
				<th>Valor</th>
				<th>Conciliado</th>
				<th>Ocorr&ecirc;ncia</th>
				<th/>
				<th/>
			</tr>
		</thead>
		<tbody>
		<?
			if(strtoupper($xmlObj->roottag->tags[0]->name == 'DADOS')){	
				foreach($xmlObj->roottag->tags[0]->tags as $infoRemessa){
					$aux_dsdocmc7 = $infoRemessa->tags[0]->cdata; // Cmc7
					$aux_cddbanco = substr($aux_dsdocmc7, 0, 3); // Cód. do banco
					$aux_cdagenci = substr($aux_dsdocmc7, 3, 4); // Cód. da agencia
					$aux_compcheq = substr($aux_dsdocmc7, 8, 3); // Comp
					$aux_nrcheque = substr($aux_dsdocmc7, 11, 6); // Nr. do cheque
					$aux_nrctachq = ($aux_cddbanco == 1) ? substr($aux_dsdocmc7, 21, 8) : substr($aux_dsdocmc7, 19, 10); // Nr. conta
					$aux_vlcheque = $infoRemessa->tags[1]->cdata; // Valor do cheque
					$aux_inconcil = $infoRemessa->tags[2]->cdata; // Indicador de conciliação
					$aux_cdocorre = $infoRemessa->tags[3]->cdata; // Código da ocorrência
					
					$aux_nrctachq = substr($aux_nrctachq, 1, (strlen($aux_nrctachq) - 2)) . '.' . substr($aux_nrctachq, -1);
					$aux_nrctachq = number_format($aux_nrctachq,1,".",".");
					?>
					<tr>
						<td id="compcheq" ><span><? echo number_format($aux_compcheq,0,'.','.') ?></span><? echo number_format($aux_compcheq,0,'.','.') ?></td>
						<td id="cddbanco" ><span><? echo number_format($aux_cddbanco,0,'.','.') ?></span><? echo number_format($aux_cddbanco,0,'.','.') ?></td>
						<td id="cdagenci" ><span><? echo number_format($aux_cdagenci,0,'.','.') ?></span><? echo number_format($aux_cdagenci,0,'.','.') ?></td>
						<td id="nrctachq" ><span><? echo $aux_nrctachq ?></span><? echo $aux_nrctachq ?></td>
						<td id="nrcheque" ><span><? echo number_format($aux_nrcheque,0,'.','.') ?></span><? echo number_format($aux_nrcheque,0,'.','.') ?></td>
						<td id="vlcheque" ><span><? echo $aux_vlcheque ?></span><? echo $aux_vlcheque ?></td>
						<td>
						<input type="hidden" id="inconcil_original" value="<? echo $aux_inconcil ?>" />
						<input type="checkbox" id="inconcil" style="float: none" onchange="verificaInconcil(this);" value="<? echo $aux_inconcil ?>" 
						<? if ($aux_inconcil == 1){ 
							echo 'checked '; 
							if ($insithcc == 'Processado'){
								echo 'disabled ';
							}
						}else{ 
							echo 'disabled ';}?> ></input></td>
						<td id="cdocorre" ><span></span><? echo $aux_cdocorre ?></td>
						<td><img src="<?php echo $UrlImagens; ?>geral/detalhes.gif" style="width:15px" title="Detalhar" onclick="mostraDetalhamentoCheque();" /></td>
						<td><img <?if ($insithcc == 'Processado'){ echo ' style="opacity: 0.4; cursor: default;"'; } ?> src="<?php echo $UrlImagens; ?>geral/<? if ($insithcc == 'Processado'){ echo 'panel-delete_desabilita.gif'; }else{ echo 'panel-delete_16x16.gif'; }?>" title="Excluir" onclick="confirmaExcluiCheque();" /></td>
						<input type="hidden" id="dsdocmc7" name="dsdocmc7" value="<? echo $aux_dsdocmc7?>">
					</tr>
					<?
				}		
			}
		?>
		</tbody>
	</table>
</div>