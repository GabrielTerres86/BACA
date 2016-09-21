<?
/*!
 * FONTE        : form_periodo.php
 * CRIAÇÃO      : Lombardi
 * DATA CRIAÇÃO : 18/03/2016
 * OBJETIVO     : Tela do formulario de detalhamento de tarifas
 */	 

	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');	
	require_once('../../../class/xmlfile.php');
	isPostMethod();
	
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
	$dtadesao = (isset($_POST['dtadesao'])) ? $_POST['dtadesao'] : 0;
	
?>
<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td align="center">		
			<table border="0" cellpadding="0" cellspacing="0" width="100%">
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><?echo $tituloTela;?></td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="fechaRotina($('#divUsoGenerico'),$('#divRotina')); return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
								<td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
							</tr>
						</table>     
					</td> 
				</tr>    
				<tr>
					<td class="tdConteudoTela" align="center">
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td>
									<table border="0" cellspacing="0" cellpadding="0">
										<tr>
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq0"></td>
											<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen0"><a href="#" id="linkAba0" class="txtNormalBold">Principal</a></td>
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir0"></td>
											<td width="1"></td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
									<form name="frmPeriodo" id="frmPeriodo" class="formulario" >
										<input type="hidden" id="nrdconta" value="<?echo $nrdconta;?>">
										<input type="hidden" id="dtadesao" value="<?echo $dtadesao;?>">
										<fieldset>
											<legend>Per&iacute;odo</legend>
											
											<label style="padding-left: 60px;" for="dtmesperiodo">M&ecirc;s:</label>
											<select class="campo" name="dtmesperiodo" style="text-align: right;" id="dtmesperiodo">
												<option value="01">Janeiro</option>
												<option value="02">Fevereiro</option>
												<option value="03">Mar&ccedil;o</option>
												<option value="04">Abril</option>
												<option value="05">Maio</option>
												<option value="06">Junho</option>
												<option value="07">Julho</option>
												<option value="08">Agosto</option>
												<option value="09">Setembro</option>
												<option value="10">Outubro</option>
												<option value="11">Novembro</option>
												<option value="12">Dezembro</option>
											</select>
											
											<label style="padding-left: 30px;" for="dtanoperiodo">Ano:</label>
											<input class="campo" type="text" id="dtanoperiodo" name="dtanoperiodo" size="4" value="<?echo date('Y');?>">
											
										</fieldset>
									</form>
									<div id="divBotoes">
										<a href="#" class="botao" style="margin: 4px 0px 4px 0px; width:70px; " id="btVoltar" onClick="fechaRotina($('#divUsoGenerico'),$('#divRotina')); return false;">Voltar</a>
										<a href="#" class="botao" style="margin: 4px 0px 4px 0px; width:70px; " id="btConfirmar" onClick="imprimirER();return false;">Confirmar</a>
									</div>
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>			    
		</td> 
	</tr>
</table>
<script language="JavaScript">
$('#dtanoperiodo','#frmPeriodo').setMask('INTEGER','0000','','');
</script>