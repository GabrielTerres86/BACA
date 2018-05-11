<?php
/*!
 * FONTE        : form_desligamentoCRM.php
 * CRIAÇÃO      : Renato Darosci (Supero)
 * DATA CRIAÇÃO : 25/07/2017
 * OBJETIVO     : Formulario desligamento
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */ 
?>

<?php

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');	
require_once('../../class/xmlfile.php');
isPostMethod();		


$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '' ;

?>

<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td align="center">		
			<table border="0" cellpadding="0" cellspacing="0" width="600">
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td id="<?php echo $labelRot; ?>" class="txtBrancoBold ponteiroDrag SetWindow SetFoco" background="<?echo $UrlImagens; ?>background/tit_tela_fundo.gif">Desligamentos</td>
								<td width="12" id="tdTitTela" background="<?echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a id="btSair" href="#" onClick="fechaRotina($('#divRotina'));return false;"><img src="<?echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
								<td width="8"><img src="<?echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
							</tr>
						</table>     
					</td> 
				</tr>    
				<tr>
					<td class="tdConteudoTela" align="center">
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
								
									<form id="frmDesligamento" name="frmDesligamento" class="formulario" onsubmit="return false;">
										<input type="hidden" name="rowiddes" id="rowiddes" value="<?php echo $rowiddes; ?>" />
										<input type="hidden" name="dtdemiss" id="dtdemiss" value="<? echo $glbvars['dtmvtolt']; ?>" />
										<input type="hidden" name="cdmotdem" id="cdmotdem" value="<? echo $cdmotivo; ?>" />
										<fieldset>
										
											<label for="vldcotas" style="width: 140px">Valor das cotas: </label>
											<input name="vldcotas" id="vldcotas" type="text" value="<?php echo $vldcotas; ?>" />
											<br />

											<label for="nrdconta" style="width: 140px"><?php echo utf8ToHtml('Conta para crédito:') ?></label>
											<input name="nrdconta" id="nrdconta" type="text" value="<?php echo formataContaDV($nrdconta); ?>" />
											<br />

											<label for="motivosaq" style="width: 140px"><?php echo utf8ToHtml('Motivo do Saque:') ?></label>
											<input name="motivosaq" id="motivosaq" type="text" value="<?php echo $dsmotivo; ?>" />
											<br />

										</fieldset>

									</form>
									<div style="clear: both"></div>
									<div id="divBotoes2">
										<a href="#" class="botao" id="btVoltar" onclick="fechaRotina($('#divRotina')); return false;">Voltar</a>
										<a href="#" class="botao" id="btOk" onclick="confirmarDesligamentoCRM(); return false;">Prosseguir</a>
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

<script>
	exibeRotina($('#divRotina'));
	hideMsgAguardo();
	bloqueiaFundo($('#divRotina'));
	
	formataTelaDesligamentoCRM();
	
	//$('#vldcotas','#frmDesligamento').val('<?php echo $vldcotas; ?>');
	//$('#nrdconta','#frmDesligamento').val('<?php echo formataContaDV($nrdconta); ?>');
	
</script>