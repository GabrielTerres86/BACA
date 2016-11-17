<?php
	/*!
	* FONTE        : tabela_chqsin.php
	* CRIAÃ‡ÃƒO      : Rodrigo Bertelli (RKAM)
	* DATA CRIAÃ‡ÃƒO : 27/06/2014
	* OBJETIVO     : Tabela que apresenda as informações na tela chqsin
	****************
	* Alteração    : 16/10/2015 - (Lucas Ranghetti #326872) - Alteração referente ao projeto melhoria 217, cheques sinistrados fora.
	*				 01/08/2016 - Corrigi o uso desnecessario da funcao session_start.Tratei o retorno XML de dados. SD 491672 (Carlos R.)
	*				 09/08/2016 - Corrigi o tratamento de sessao, a forma de recuperacao dos dados do POST e validacao do retorno XML (Carlos R.)
	*/ 
	@session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();
 
	$nriniseq    = ( isset($_POST['nriniseq']) )  ? $_POST['nriniseq'] : 0;
	$nrregist    = ( isset($_POST['nrregist']) )  ? $_POST['nrregist'] : 0;
	$nrbanco     = ( isset($_POST['nrbanco']) )   ? $_POST['nrbanco'] : 0;
	$nragencia   = ( isset($_POST['nragencia']) ) ? $_POST['nragencia'] : 0;
	$nrdconta    = ( isset($_POST['nrdconta']) )  ? $_POST['nrdconta'] : 0;
	$datinicial  = ( isset($_POST['dtinicial']) ) ? $_POST['dtinicial'] : 0;
	$datfinal    = ( isset($_POST['dtfinal']) )   ? $_POST['dtfinal'] : 0;
	$cdtipchq    = ( isset($_POST['cdtipchq']) )  ? $_POST['cdtipchq'] : 0;
	$cddopcao    = ( isset($_POST['cddopcao']) )  ? $_POST['cddopcao'] : 0;
	$nrcheque    = ( isset($_POST['nrcheque']) )  ? $_POST['nrcheque'] : 0;
	$cont_id     = 0;
	$registros = array();
  
	//  Cheques internos
	if($cdtipchq == 'I'){
		//nome da acao enviada para mensageria e o monta o xml
		$strnomacao = 	'CONCHQSIN';	
		$xml  = "";
		$xml .= "<Root>";
		$xml .= " <Dados>";
		$xml .= "    <cdbccxlt>".$nrbanco."</cdbccxlt>";
		$xml .= "    <cdagectl>".$nragencia."</cdagectl>";
		$xml .= "    <nrctachq>".$nrdconta."</nrctachq>";
		$xml .= "    <dtperini>".$datinicial."</dtperini>";
		$xml .= "    <dtfimper>".$datfinal."</dtfimper>";
		$xml .= "    <nriniseq>".$nriniseq."</nriniseq>";
		$xml .= "    <nrregist>".$nrregist."</nrregist>";
		$xml .= " </Dados>";
		$xml .= "</Root>";
	 
		//realiza o processo de mensageria para efetuar a transacao no banco de dados
		$xmlResult = mensageria($xml, "CHQSIN", $strnomacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["nmoperad"], "</Root>");
		$xmlObj = getObjectXML($xmlResult); 

		//retorno dos registros
		$registros = $xmlObj->roottag->tags;
		
		$qtregist  = ( isset($registros[0]->tags) ) ? getByTagName($registros[0]->tags,'qtregist') : 0;
	 
	} 

	if($cdtipchq == 'O') {
		//nome da acao enviada para mensageria e o monta o xml
		$strnomacao = 	'CON_CHQSIN_FORA';	
		$xml  = "";
		$xml .= "<Root>";
		$xml .= " <Dados>";
		$xml .= "    <cdbccxlt>".$nrbanco."</cdbccxlt>";
		$xml .= "    <cdagectl>".$nragencia."</cdagectl>";
		$xml .= "    <nrctachq>".$nrdconta."</nrctachq>";
		$xml .= "    <dtperini>".$datinicial."</dtperini>";
		$xml .= "    <dtfimper>".$datfinal."</dtfimper>";
		$xml .= "    <nrcheque>".$nrcheque."</nrcheque>";
		$xml .= "    <nriniseq>".$nriniseq."</nriniseq>";
		$xml .= "    <nrregist>".$nrregist."</nrregist>";
		$xml .= " </Dados>";
		$xml .= "</Root>";

		//realiza o processo de mensageria para efetuar a transacao no banco de dados
		$xmlResult = mensageria($xml, "CHQSIN", $strnomacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["nmoperad"], "</Root>");
		$xmlObj = getObjectXML($xmlResult); 

		if(isset($xmlObj->roottag->tags[0]->name) && strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO'){
			$msgErro = $xmlObj->roottag->tags->cdata;
			if($msgErro == ""){
				$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
			}
			exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
			exit();
		}
	
		//retorno dos registros
		$registros = $xmlObj->roottag->tags;
		$qtregist  = ( isset($registros[0]->tags) ) ? getByTagName($registros[0]->tags,'qtregist') : 0;
	
	}
?>
<div id="diTbChqsin">
	<table class="tituloRegistros" id="tbChqsin" style="border: 1px solid #777; border-bottom: 0px;">
		<thead>
			<tr>
				<? if( ($cdtipchq == 'O') && ($cddopcao == 'E1') ){ ?>
					<th><input type="checkbox" id="checkTodos" name="checkTodos" onClick="check();"></th>
				<? } ?>
				<th width="100px;">Data</th>
				<th width="100px;">Bco. Sinistro</th>
				<th width="100px;">Ag&ecirc;ncia</th>
				<th width="100px;">Nr. da Conta</th>
				<th width="130px;" id="nrcheque">Nr. do Cheque</th>
				<th style="width: 5px; border: 0px;"></th>
			</tr>			
		</thead>
	</table>
		
	<div id="registros" style='border-left: 1px solid #777; overflow-y:scroll ; height: 180px;'>
	
		<table>
			<tbody>
			<?php
				$class = "corImpar";
				foreach($registros as $chqsin) {
					// Recebo todos valores em variáveis
					$datinclusao= getByTagName($chqsin->tags,'dtmvtolt');
					$codbanco	= getByTagName($chqsin->tags,'cdbccxlt');
					$codagencia	= getByTagName($chqsin->tags,'cdagectl');
					$nrctachq	= getByTagName($chqsin->tags,'nrctachq');
					if($cdtipchq == 'O') {
						$nrcheque	= getByTagName($chqsin->tags,'nrcheque');
						$dscmotivo  = '';
					}else{
						$dscmotivo	= getByTagName($chqsin->tags,'dsmotivo');
						$nrcheque = 0;
					}
					
					$class = ($class == "corImpar") ? "corPar" : "corImpar";
					
					// Caso vier registros vazios pula para o proximo registro
					if($codbanco == ''){
						continue;
					}
			?>      
					<tr style="text-align: center;" class="<?php echo $class; ?>" >
					   <? if( ($cdtipchq == 'O') && ($cddopcao == 'E1') ){ ?>
							<td width="20px;"><input type="checkbox" id="indice" name="indice[]" value="<? echo $cont_id; ?>" />
								<script>
									var id_reg = arrayRegLinha.length;
									arrayRegLinha[id_reg] = new Array();
									arrayRegLinha[id_reg]["cddbanco"] = '<? echo $codbanco; ?>';
									arrayRegLinha[id_reg]["cdagenci"] = '<? echo $codagencia; ?>';
									arrayRegLinha[id_reg]["nrctachq"] = '<? echo $nrctachq; ?>';
									arrayRegLinha[id_reg]["nrcheque"] = '<? echo $nrcheque; ?>';
								</script>
							</td>
							<? 
							$cont_id = $cont_id + 1;
						} ?>
						
						<?  if( ($cdtipchq == 'O') && ($cddopcao == 'E1') ){ ?>
							<td width="110px;"  ><? echo $datinclusao;  ?> </td>
							<td width="115px;"  ><? echo $codbanco;?> </td>
							<td width="110px;"  ><? echo $codagencia;?></td>
							<td width="110px;"  ><?php echo ( isset($nrctachq) ) ? @mascara($nrctachq,'#.###.###-#') : '';?></td>
							<td width="145px;"  id="nrcheque" ><?php echo ( isset($nrcheque) ) ? @mascara($nrcheque,'####.###') : '';?></td>
						<? }elseif(($cdtipchq == 'I') && (($cddopcao == 'E1') || ($cddopcao == 'C')) ) {?>
							<td width="140px;" style="cursor: pointer" onclick="carregaBusca('<?php echo $datinclusao?>',<?php echo $codbanco; ?>, <?php echo $codagencia; ?>,<?php echo $nrctachq; ?>,'<?php echo $dscmotivo; ?>', '<?php echo $nrcheque; ?>')" ><? echo $datinclusao;  ?> </td>
							<td width="145px;" style="cursor: pointer" onclick="carregaBusca('<?php echo $datinclusao?>',<?php echo $codbanco; ?>, <?php echo $codagencia; ?>,<?php echo $nrctachq; ?>,'<?php echo $dscmotivo; ?>', '<?php echo $nrcheque; ?>')"><? echo $codbanco;?> </td>
							<td width="140px;" style="cursor: pointer" onclick="carregaBusca('<?php echo $datinclusao?>',<?php echo $codbanco; ?>, <?php echo $codagencia; ?>,<?php echo $nrctachq; ?>,'<?php echo $dscmotivo; ?>', '<?php echo $nrcheque; ?>')"><? echo $codagencia;?></td>
							<td width="145px;" style="cursor: pointer" onclick="carregaBusca('<?php echo $datinclusao?>',<?php echo $codbanco; ?>, <?php echo $codagencia; ?>,<?php echo $nrctachq; ?>,'<?php echo $dscmotivo; ?>', '<?php echo $nrcheque; ?>')"><?php echo ( isset($nrctachq) && $nrctachq != '' ) ? @mascara($nrctachq,'#.###.###-#') : ''; ?></td>							
							<td width="145px;" style="cursor: pointer" id="nrcheque" onclick="carregaBusca('<?php echo $datinclusao?>',<?php echo $codbanco; ?>, <?php echo $codagencia; ?>,<?php echo $nrctachq; ?>,'<?php echo $dscmotivo; ?>', '<?php echo $nrcheque; ?>')"><?php echo (isset($nrcheque) ) ? @mascara($nrcheque,'####.###') : '';?></td>
						<? }elseif( ($cdtipchq == 'O') && ($cddopcao == 'C') ){ ?>
							<td width="110px;" style="cursor: pointer" onclick="carregaBusca('<?php echo $datinclusao?>',<?php echo $codbanco; ?>, <?php echo $codagencia; ?>,<?php echo $nrctachq; ?>,'<?php echo $dscmotivo; ?>', '<?php echo $nrcheque; ?>')" ><? echo $datinclusao;  ?> </td>
							<td width="115px;" style="cursor: pointer" onclick="carregaBusca('<?php echo $datinclusao?>',<?php echo $codbanco; ?>, <?php echo $codagencia; ?>,<?php echo $nrctachq; ?>,'<?php echo $dscmotivo; ?>', '<?php echo $nrcheque; ?>')"><? echo $codbanco;?> </td>
							<td width="110px;" style="cursor: pointer" onclick="carregaBusca('<?php echo $datinclusao?>',<?php echo $codbanco; ?>, <?php echo $codagencia; ?>,<?php echo $nrctachq; ?>,'<?php echo $dscmotivo; ?>', '<?php echo $nrcheque; ?>')"><? echo $codagencia;?></td>
							<td width="110px;" style="cursor: pointer" onclick="carregaBusca('<?php echo $datinclusao?>',<?php echo $codbanco; ?>, <?php echo $codagencia; ?>,<?php echo $nrctachq; ?>,'<?php echo $dscmotivo; ?>', '<?php echo $nrcheque; ?>')"><?php echo ( isset($nrctachq) && $nrctachq != '' ) ? @mascara($nrctachq,'#.###.###-#') : '';?></td>
							<td width="145px;" style="cursor: pointer" id="nrcheque" onclick="carregaBusca('<?php echo $datinclusao?>',<?php echo $codbanco; ?>, <?php echo $codagencia; ?>,<?php echo $nrctachq; ?>,'<?php echo $dscmotivo; ?>', '<?php echo $nrcheque; ?>')"><?php echo ( isset($nrcheque) ) ? @mascara($nrcheque,'####.###') : '';?></td>
						<? } ?>
							
					</tr>
				
				<? } ?>	
			</tbody>
		</table>
	</div>
	<div id="divPesquisaRodape" class="divPesquisaRodape">
		<table>	
			<tr>
				<td> 
					<?			
						if (isset($qtregist) and $qtregist == 0) $nriniseq = 0;
						
						// Se a paginação não está¡ na primeira, exibe botão voltar
						if ($nriniseq > 1) { 
							?> <a class='paginacaoAnt'><<< Anterior</a> <? 
						} else {
							?> &nbsp; <?
						}
					?>
				</td>
				<td>
					<?
						if (isset($nriniseq) && $nriniseq > 0) { 
							?> Exibindo <? echo $nriniseq; ?> at&eacute; <? if (($nriniseq + $nrregist) > $qtregist) { echo $qtregist; } else { echo ($nriniseq + $nrregist - 1); } ?> de <? echo $qtregist; ?><?
						}
					?>
				</td>
				<td>
					<?
						// Se a paginação não está¡ na última página, exibe botão proximo
						if (isset($qtregist) && $qtregist > ($nriniseq + $nrregist - 1) && $nriniseq > 0) {
							?> <a class='paginacaoProx'>Pr&oacute;ximo >>></a> <?
						} else {
							?> &nbsp; <?
						}
					?>			
				</td>
			</tr>
		</table>
	</div>
</div>
<script type="text/javascript">
	$('a.paginacaoAnt').unbind('click').bind('click', function() {
		buscaChequesSinistrados(<? echo "'".($nriniseq - $nrregist)."','".$nrregist."'"; ?>);
	});
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		buscaChequesSinistrados(<? echo "'".($nriniseq + $nrregist)."','".$nrregist."'"; ?>);
	});	
	$('#divPesquisaRodape').formataRodapePesquisa(); 
	

	
	if( $('#cdtipchq','#frmCab').val() == 'I') {		
		$("#nrcheque","#tbChqsin").css({'display':'none'});
		$("#nrcheque","#registros").css({'display':'none'});
		$('#indice','#registros').css({'display':'none'});
		$("#checkTodos","#diTbChqsin").css({'display':'none'});
	 }else{
		$("#nrcheque","#tbChqsin").css({'display':'block'});
		$("#nrcheque","#registros").css({'display':'block'});
		
		var opcao = '<? echo  $cddopcao?>';
		if(opcao != 'E1'){
			$('#checkTodos','#tbChqsin').css({'display':'none'});
		}
	 }
</script>