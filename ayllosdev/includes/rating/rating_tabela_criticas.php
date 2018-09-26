<?php
	
	//************************************************************************//
	//*** Fonte: rating_tabela_criticas.php                                ***//
	//*** Autor: David                                                     ***//
	//*** Data : Abril/2010                   Última Alteração: 00/00/0000 ***//
	//***                                                                  ***//
	//*** Objetivo  : Mostra críticas geradas para o rating do cooperado   ***//	
	//***                                                                  ***//
	//*** Alterações:                                                      ***//	
	//************************************************************************//
	
	$criticas   = $xmlObjRating->roottag->tags[0]->tags;
	$qtCriticas = count($criticas);
	
	if ($qtCriticas == 1 && $criticas[0]->tags[3]->cdata <> 830) {
		exibeErro($xmlObjRating->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}
	
	$msgCritica = "Erro na atualiza&ccedil;&atilde;o do rating.";		
	$flgFirst   = true;
	$style      = "";
		
	for ($i = 0; $i < $qtCriticas; $i++) {
		if ($criticas[$i]->tags[3]->cdata == 830) {
			$msgCritica = $criticas[$i]->tags[4]->cdata;
		} else {				
			if ($flgFirst) {
				$flgFirst = false;
				?>
				var strHTML = '';
				strHTML += '<table width="100%" border="0" cellpadding="0" cellspacing="0">';
				strHTML += '  <tr>';
				strHTML += '    <td>';
				strHTML += '      <table width="100%" border="0" cellpadding="0" cellspacing="2">';
				strHTML += '        <tr>';
				strHTML += '          <td width="100">';
				strHTML += '            <table width="100%" border="0" cellpadding="0" cellspacing="0">';
				strHTML += '              <tr>';
				strHTML += '                <td height="1" style="background-color:#999999;"></td>';
				strHTML += '              </tr>';
				strHTML += '            </table>';
				strHTML += '          </td>';						
				strHTML += '          <td height="18" class="txtNormalBold" align="center" style="background-color: #E3E2DD;">CR&Iacute;TICAS DO RATING</td>';
				strHTML += '          <td width="100">';
				strHTML += '            <table width="100%" border="0" cellpadding="0" cellspacing="0">';
				strHTML += '              <tr>';
				strHTML += '                <td height="1" style="background-color:#999999;"></td>';
				strHTML += '              </tr>';
				strHTML += '            </table>';
				strHTML += '          </td>';
				strHTML += '        </tr>';
				strHTML += '      </table>';
				strHTML += '    </td>';
				strHTML += '  </tr>';
				strHTML += '  <tr>';
				strHTML += '    <td>';
				strHTML += '      <div id="divListaCriticasRating" style="overflow-y: scroll; overflow-x: hidden; height: 145px; width: 100%;">';
				strHTML += '        <table width="445" border="0" cellpadding="1" cellspacing="2">';
				<?php 
			}			
			
			if ($style == "") {
				$style = ' style="background-color: #FFFFFF;"';
			} else {
				$style = "";
			}	
								
			?>
			strHTML += '          <tr <?php echo $style; ?>>';
			strHTML += '            <td class="txtNormal"><?php echo $criticas[$i]->tags[4]->cdata; ?></td>';
			strHTML += '          </tr>';
			<?php 
		}
		
		if ($i == ($qtCriticas - 1)) {
			?>
			strHTML += '        </table>';
			strHTML += '      </div>';
			strHTML += '    </td>';
			strHTML += '  <tr>';
			strHTML += '</table>';
			strHTML += '<table width="100%" border="0" cellpadding="0" cellspacing="0">';
			strHTML += '  <tr>';
			strHTML += '    <td height="8"></td>';
			strHTML += '  </tr>';
			strHTML += '  <tr>';
			strHTML += '    <td align="center">';
			strHTML += '      <table border="0" cellpadding="0" cellspacing="3">';			
			strHTML += '        <tr>';
			strHTML += '          <td><input type="image" name="btnCriticaRating" id="btnCriticaRating" src="<?php echo $UrlImagens; ?>botoes/continuar.gif" onClick="eval(fncRatingSuccess);return false;"></td>';
			strHTML += '        </tr>';
			strHTML += '      </table>';
			strHTML += '    </td>';
			strHTML += '  </tr>';
			strHTML += '</table>';
			<?php
			
			// Coloca conteúdo HTML no div
			echo '$("#'.$iddivcri.'").html(strHTML);';							
		}
	}
	
	// Encerra mensagem de aguardo e bloqueia fundo da rotina
	echo 'hideMsgAguardo();';
	echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';
	
	if ($flgfirst) {
		// Aciona função para continuidade da operação
		echo 'eval(fncRatingSuccess);';		
	} else {
		echo 'showError("error","'.$msgCritica.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';	
	}
	
?>