<?php
	
	//************************************************************************//
	//*** Fonte: rating_mostra_dados.php                                   ***//
	//*** Autor: David                                                     ***//
	//*** Data : Maio/2010                    Última Alteração: 00/00/0000 ***//
	//***                                                                  ***//
	//*** Objetivo  : Mostrar dados do rating efetivado na operação        ***//	
	//***                                                                  ***//
	//*** Alterações:                                                      ***//	
	//************************************************************************//
	
	// Variável que indica se o rating foi efetivado - Utilizado na include rating_armazena_dados_impressao.php
	$flgEfetivacao = true;
		
	// Formatar dados de impressão em arrays
	include("rating_armazena_dados_impressao.php");
	
	if ($qtTagsEfetivacao > 0) {		
		$flgFirst = true;
		$style    = "";
		
		?>
		var strHTML = '';
		strHTML += '<table width="460" border="0" cellpadding="0" cellspacing="0">';
		strHTML += '  <tr>';
		strHTML += '    <td height="30" valign="top">';
		strHTML += '      <table width="100%" border="0" cellpadding="0" cellspacing="2">';
		strHTML += '        <tr>';
		strHTML += '          <td width="100">';
		strHTML += '            <table width="100%" border="0" cellpadding="0" cellspacing="0">';
		strHTML += '              <tr>';
		strHTML += '                <td height="1" style="background-color:#999999;"></td>';
		strHTML += '              </tr>';
		strHTML += '            </table>';
		strHTML += '          </td>';						
		strHTML += '          <td height="18" class="txtNormalBold" align="center" style="background-color: #E3E2DD;">RATING(S) DO COOPERADO</td>';
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
		strHTML += '      <table width="455" border="0" cellpadding="0" cellspacing="0">';
		strHTML += '        <tr>';
		strHTML += '          <td>';
		strHTML += '            <table width="440" border="0" cellpadding="1" cellspacing="2">';
		strHTML += '              <tr style="background-color: #F4D0C9;">';
		strHTML += '                <td width="65" class="txtNormalBold">Data</td>';
		strHTML += '                <td width="110" class="txtNormalBold">Tipo</td>';
		strHTML += '                <td width="60" class="txtNormalBold" align="right">Contrato</td>';
		strHTML += '                <td width="45" class="txtNormalBold" align="center">Risco</td>';
		strHTML += '                <td width="50" class="txtNormalBold" align="right">Nota</td>';
		strHTML += '                <td class="txtNormalBold" align="right">Vlr.Utl.Rating</td>';
		strHTML += '              </tr>';
		strHTML += '            </table>';
		strHTML += '          </td>';
		strHTML += '        </tr>';
		strHTML += '        <tr>';
		strHTML += '          <td>';						
		strHTML += '            <div id="divListaRatings" style="overflow-y: scroll; overflow-x: hidden; height: 145px; width: 100%;">';
		strHTML += '              <table width="440" border="0" cellpadding="1" cellspacing="2">';
		<?php 
		
		$fncImpressao = "";
		
		for ($i = 0; $i < $qtTagsRatings; $i++) {
			if ($ratings[$i]["INSITRAT"] == "2") {
				if (!($ratings[$i]["TPCTRRAT"] == $cooperado["TPCTRRAT"] &&    // Tipo do contrato 
				      $ratings[$i]["NRCTRRAT"] == $cooperado["NRCTRRAT"])) {   // Número do contrato						
					$fncImpressao = "imprimirRating(false,".$ratings[$i]["TPCTRRAT"].",".$ratings[$i]["NRCTRRAT"].",\\'".$divShowDados."\\',fncRatingSuccess);";					
				}
			}
		
			if ($i >= 7) {
				continue;
			}
			
			if ($style == "") {
				$style = ' style="background-color: #FFFFFF;"';
			} else {
				$style = "";
			}	
								
			?>
			strHTML += '                <tr <?php echo $style; ?>>';
			strHTML += '                  <td width="65" class="txtNormal"><?php echo $ratings[$i]["DTMVTOLT"]; ?></td>';
			strHTML += '                  <td width="110" class="txtNormal"><?php echo $ratings[$i]["DSDOPERA"]; ?></td>';
			strHTML += '                  <td width="60" class="txtNormal" align="right"><?php echo number_format($ratings[$i]["NRCTRRAT"],0,",","."); ?></td>';
			strHTML += '                  <td width="45" class="txtNormal" align="center"><?php echo $ratings[$i]["INDRISCO"]; ?></td>';
			strHTML += '                  <td width="50" class="txtNormal" align="right"><?php echo number_format(str_replace(",",".",$ratings[$i]["NRNOTRAT"]),2,",","."); ?></td>';
			strHTML += '                  <td class="txtNormal" align="right"><?php echo number_format(str_replace(",",".",$ratings[$i]["VLUTLRAT"]),2,",","."); ?></td>';
			strHTML += '                </tr>';
			<?php			
		}
		
		?>
		strHTML += '              </table>';
		strHTML += '            </div>';
		strHTML += '          </td>';
		strHTML += '        <tr>';
		strHTML += '      </table>';
		strHTML += '      <table width="100%" border="0" cellpadding="0" cellspacing="0">';
		strHTML += '        <tr>';
		strHTML += '          <td height="8"></td>';
		strHTML += '        </tr>';
		strHTML += '        <tr>';
		strHTML += '          <td align="center">';
		strHTML += '            <table border="0" cellpadding="0" cellspacing="3">';		
		strHTML += '              <tr>';
		strHTML += '                <td><input type="image" src="<?php echo $UrlImagens; ?>botoes/continuar.gif" onClick="imprimirRating(true);<?php if ($fncImpressao <> "") { echo $fncImpressao; } ?>eval(fncRatingSuccess);return false;"></td>';
		strHTML += '              </tr>';
		strHTML += '            </table>';
		strHTML += '          </td>';
		strHTML += '        </tr>';
		strHTML += '      </table>';
		strHTML += '    </td>';
		strHTML += '  </tr>';
		strHTML += '</table>';
		<?php				
		
		// Coloca conteúdo HTML no div - $divShowDados deve ser alimentada no script que está chamando essa include
		echo '$("#'.$divShowDados.'").html(strHTML);';						
		
		// Encerra mensagem de aguardo e bloqueia fundo da rotina
		echo 'hideMsgAguardo();';
		echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';
		
		// Mostra mensagem sobre rating efetivado		
		if (isset($efetivacao[1]) && $efetivacao[1] <> "") {						
			echo 'showError("inform","'.$efetivacao[1].'","Notifica&ccedil;&atilde;o - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';					
		} 				
	} else { 
		// Encerra mensagem de aguardo e bloqueia fundo da rotina
		echo 'hideMsgAguardo();';
		echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';
		
		// Aciona função para atualizar rotina		
		echo 'eval(fncRatingSuccess);';
	}	
	
?>