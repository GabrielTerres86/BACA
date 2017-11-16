<?
/*!
 * FONTE        : confirma_desbloqueio_cobertura.php
 * CRIAÇÃO      : Lombardi
 * DATA CRIAÇÃO : 16/11/2017
 * OBJETIVO     : Confirmar desbloqueio por cobertura de operação de crédito
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
	
	$vlopera = (isset($_POST['vlopera'])) ? $_POST['vlopera'] : '' ; 
	
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
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">Confirmar Desbloqueio</td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a id="btVoltar" href="#" onClick="fechaRotina($('#divRotina')); return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
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
							<td style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
								<form id="frmValorDesbloq">
									<fieldset>
											Antes de prosseguir com o desbloqueio da<br>
											Cobertura da Opera&ccedil;&atilde;o de Cr&eacute;dito selecionada,<br>
											favor informar o valor do Bloqueio. <br>
											Observa&ccedil;&atilde;o: Ser&aacute; necess&aacute;ria aprova&ccedil;&atilde;o do seu Coordenador!
										<div align="center">
											<label for="vldesblo">Valor a Desbloquear:</label>
											<input type="text" id="vldesblo" name="vldesblo" value="<? echo $vlopera; ?>"/>
										</div>
									</fieldset>
									<div align="center">
										<a href="#" class="botao" style="margin: 7px;" id="btDocCadastrais" onclick="fechaRotina($('#divRotina')); return false;">Cancelar</a>
										<a href="#" class="botao" style="margin: 7px;" id="btDocContas" onclick="desbloqueioCobertura();">Confirmar</a>
									</div>
								</form>
							</td>
						  </tr>
						</table>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
