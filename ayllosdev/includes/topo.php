<?php

	//************************************************************************//
	//*** Fonte: topo.php                                                  ***//
	//*** Autor: David                                                     ***//
	//*** Data : Julho/2007                   Última Alteração: 06/06/2012 ***//
	//***                                                                  ***//
	//*** Objetivo  : Montar o "topo" do layout das páginas                ***//
	//***                                                                  ***//	 
	//*** Alterações: 06/06/2012 - Projeto Viacredi Alto Vale (David).     ***//
	//************************************************************************//
	
	// Verifica o dia da semana
	switch (date("w",mktime(0,0,0,substr($glbvars["dtmvtolt"],3,2),substr($glbvars["dtmvtolt"],0,2),substr($glbvars["dtmvtolt"],6,4)))) {
		case 0: $weekday = "Domingo"; break;
		case 1: $weekday = "Segunda-Feira"; break;
		case 2: $weekday = "Ter&ccedil;a-Feira"; break;
		case 3: $weekday = "Quarta-Feira"; break;
		case 4: $weekday = "Quinta-Feira"; break;
		case 5: $weekday = "Sexta-Feira"; break;
		case 6: $weekday = "S&aacute;bado"; break;
	}
	
	// Verifica o mês
	switch (intval(substr($glbvars["dtmvtolt"],3,2))) {
		case 1: $month = "janeiro"; break;
		case 2: $month = "fevereiro"; break;
		case 3: $month = "mar&ccedil;o"; break;
		case 4: $month = "abril"; break;
		case 5: $month = "maio"; break;
		case 6: $month = "junho"; break;
		case 7: $month = "julho"; break;
		case 8: $month = "agosto"; break;
		case 9: $month = "setembro"; break;
		case 10: $month = "outubro"; break;
		case 11: $month = "novembro"; break;
		case 12: $month = "dezembro"; break;
	}	
	
?>
<table border="0" cellpadding="0" cellspacing="0" width="100%">
	<tr>
		<td id="tdTopo" height="35" valign="middle" background="<?php echo $UrlImagens; ?>background/bg_gradiente_topo.jpg">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr>
					<td width="5" height="30">&nbsp;</td>
					<td><a href="#" onClick="carregarTelaPrincipal();return false;" class="txtSistema">SISTEMA AIMARO</a></td>
					<td width="90" align="right"><img src="<?php echo $UrlImagens; ?>logos/logo_<?php echo str_replace(" ","",$glbvars["nmcooper"]); ?>.gif"></td>
					<td width="5">&nbsp;</td>
				</tr>
			</table> 
		</td>		
	</tr>
	<tr>
		<td bgcolor="#91957B" height="22" valign="middle">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr>
					<td width="5" height="22">&nbsp;</td>
					<td class="txtBranco"><span class="txtBrancoBold">Operador:</span> <?php echo $glbvars["nmoperad"]; ?></td>
					<td class="txtBranco"><?php echo $weekday.", ".substr($glbvars["dtmvtolt"],0,2)." de ".$month." de ".substr($glbvars["dtmvtolt"],6,4); ?></td>
					<td width="55" align="right">
						<table border="0" cellpadding="0" cellspacing="0">
							<tr>
								<td class="txtBrancoBold"><a href="#" onClick="efetuaLogoff();return false;">Sair</a></td>
								<td width="2">&nbsp;</td>
								<td><a href="#" onClick="efetuaLogoff();return false;"><img src="<?php echo $UrlImagens; ?>geral/panel-error_16x16.gif" border="0"></a></td>
							</tr>
						</table>
					</td>
					<td width="5">&nbsp;</td>
				</tr>
			</table> 		
		</td>
	</tr>
</table>