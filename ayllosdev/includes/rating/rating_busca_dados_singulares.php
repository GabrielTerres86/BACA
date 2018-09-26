<?php 

	//************************************************************************//
	//*** Fonte: rating_busca_dados_singulares.php                         ***//
	//*** Autor: David                                                     ***//
	//*** Data : Setembro/2011                Última Alteração:   /  /     ***//
	//***                                                                  ***//
	//*** Objetivo  : Carregar dados do rating das cooperativas singulares ***//	
	//***                                                                  ***//
	//*** Alterações:                                                      ***//
	//************************************************************************//
	
	// Monta o xml de requisição
	$xmlGetRating  = "";
	$xmlGetRating .= "<Root>";
	$xmlGetRating .= "  <Cabecalho>";
	$xmlGetRating .= "    <Bo>b1wgen0043.p</Bo>";
	$xmlGetRating .= "    <Proc>busca_dados_rating_completo</Proc>";
	$xmlGetRating .= "  </Cabecalho>";
	$xmlGetRating .= "  <Dados>";
	$xmlGetRating .= "    <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetRating .= "    <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetRating .= "    <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetRating .= "    <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetRating .= "    <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlGetRating .= "    <nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetRating .= "    <nrctrrat>".$nrctrrat."</nrctrrat>";
	$xmlGetRating .= "    <tpctrrat>".$tpctrrat."</tpctrrat>";
	$xmlGetRating .= "    <idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlGetRating .= "    <idseqttl>1</idseqttl>";
	$xmlGetRating .= "    <nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	
	$xmlGetRating .= "  </Dados>";
	$xmlGetRating .= "</Root>";	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetRating,false);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjRating = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjRating->roottag->tags[0]->name) == "ERRO") {
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$xmlObjRating->roottag->tags[0]->tags[0]->tags[4]->cdata.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		
	}
	
		
	$itens   = $xmlObjRating->roottag->tags[3]->tags;
	$qtItens = count($itens);
	
	$topicos   = $xmlObjRating->roottag->tags[1]->tags;
	$qtTopicos = count($topicos);

	$topicos_item   = $xmlObjRating->roottag->tags[2]->tags;
	$qtTopicos_Item = count($topicos_item);

	$topicos_seq   = $xmlObjRating->roottag->tags[3]->tags;
	$qtTopicos_Seq = count($topicos_seq);	
	
	$inpessoa = $xmlObjRating->roottag->tags[0]->tags[0]->tags[7]->cdata;
	
	$qtdTotalTopicos = 0;
	
	
?>

var strHTML = '';
	strHTML += '<div id="divDadosRatingSingulares2">';
	strHTML += '	<form name="frmDadosRatingSingulares" id="frmDadosRatingSingulares" method="post" onSubmit="return false;">';
	strHTML += '	<table width="100%" border="0" cellpadding="0" cellspacing="2">';
	strHTML += '		<tr>';
	strHTML += '			<td width="150">';
	strHTML += '				<table width="100%" border="0" cellpadding="0" cellspacing="0">';
	strHTML += '					<tr>';
	strHTML += '						<td height="1" style="background-color:#999999;"></td>';
	strHTML += '					</tr>';
	strHTML += '				</table>';
	strHTML += '			</td>';
	strHTML += '			<td height="18" class="txtNormalBold" align="center" style="background-color: #E3E2DD;"><?php echo 'CLASSIFICA&Ccedil;&Atilde;O DO RISCO';?></td>';
	strHTML += '			<td width="150">';
	strHTML += '				<table width="100%" border="0" cellpadding="0" cellspacing="0">';
	strHTML += '					<tr>';
	strHTML += '						<td height="1" style="background-color:#999999;"></td>';
	strHTML += '					</tr>';
	strHTML += '				</table>';
	strHTML += '			</td>';
	strHTML += '		</tr>';
	strHTML += '	</table>';

<?php for ($i = 0; $i < $qtTopicos; $i++) { //le todos os topicos  ?>
	strHTML += '	<fieldset>';
	strHTML += '	<legend class="txtNormalBold"><?php echo utf8ToHtml($topicos[$i]->tags[0]->cdata. ". ".$topicos[$i]->tags[1]->cdata);?></legend>';
	<?php 
		for ($j = 0; $j < $qtTopicos_Item; $j++) { // todos os itens 
			if ($topicos_item[$j]->tags[2]->cdata == $topicos[$i]->tags[0]->cdata) { // filtra pelos itens do topico 
				?>
	strHTML += '	<br/>';
	
	strHTML += '	<label for="topico_<?php echo $topicos[$i]->tags[0]->cdata; ?>_item_<?php echo $topicos_item[$j]->tags[0]->cdata; ?>"style="float: left; margin-left: 10px; padding-top: 3px;" class="txtNormal"><? echo utf8ToHtml($topicos[$i]->tags[0]->cdata.".".$topicos_item[$j]->tags[0]->cdata.". ".$topicos_item[$j]->tags[1]->cdata.":"); ?></label>';
	strHTML += '	<select id="topico_<?php echo $topicos[$i]->tags[0]->cdata; ?>_item_<?php echo $topicos_item[$j]->tags[0]->cdata; ?>"class="campo" style="float: left; width: 170px; margin-left: 10px;" name="topico_<?php echo $topicos[$i]->tags[0]->cdata; ?>_item_<?php echo $topicos_item[$j]->tags[0]->cdata; ?>">';
	strHTML += '	<option value="0" <?php echo "selected"; ?>> <?php echo "-- Selecione --";?> </option>';
					<?php
					$qtdTotalTopicos = $qtdTotalTopicos + 1;
					for ($k = 0; $k < $qtTopicos_Seq; $k++) { // todas as sequencias
						if ($topicos_seq[$k]->tags[0]->cdata == $topicos[$i]->tags[0]->cdata &&
							$topicos_seq[$k]->tags[1]->cdata == $topicos_item[$j]->tags[0]->cdata) { // filtra as sequencias do item que esta sendo lido
					?>	
	strHTML += '		<option value="<?php echo $topicos_seq[$k]->tags[2]->cdata; ?>" <?php if ($topicos_seq[$k]->tags[4]->cdata == "*") { echo "selected";} ?>> <?php echo $topicos_seq[$k]->tags[2]->cdata." - ".$topicos_seq[$k]->tags[3]->cdata; ?> </option>';
					<?php
						}
					}
					?>
	strHTML += '	</select>';
	
	strHTML += '	<br/>';
<?php		}
		}
	?>
	strHTML += '	<br/>';
	strHTML += '	</fieldset>';
	<?php
	}	
?>
	strHTML += '	<br />';
	strHTML += '	</form>';
	strHTML += '	<table width="100%" border="0" cellpadding="0" cellspacing="0">';
	strHTML += '		<tr>';
	strHTML += '			<td height="8"></td>';
	strHTML += '			</tr>';
	strHTML += '		<tr>';
	strHTML += '			<td align="center">';
	strHTML += '				<table border="0" cellpadding="0" cellspacing="3">';
	strHTML += '					<tr>';
	
	strHTML += '						<td><input type="image" name="9" id="btnCancelarRatingSingulares" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="lcrShowHideDiv(\'divConteudoOpcao\', \'divDadosRatingSingulares\');return false;"/></td>';
	
	strHTML += '						<td width="8"></td>';
	strHTML += '						<td><input type="image" name="btnValidaRating" id="btnValidaRating" src="<?php echo $UrlImagens; ?>botoes/continuar.gif" onClick="<?php if ($cdOperacao == "C") { echo "fncRatingContinue();"; } else { echo "trataRatingSingulares($qtdTotalTopicos);"; } ?>;return false;"/></td>';
	strHTML += '					</tr>';
	strHTML += '				</table>';
	strHTML += '			</td>';
	strHTML += '		</tr>';
	strHTML += '	</table>';
	strHTML += '</div>';

<?php
		
	echo "$('#divDadosRatingSingulares').html(strHTML);";
	echo "$('#divConteudoOpcao').css('display','none');";
	echo "$('#divDadosRatingSingulares').css('display','block');";
	echo 'hideMsgAguardo();';
	echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';
	
?>	