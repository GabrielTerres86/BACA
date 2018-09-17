<?php
/*!
 * FONTE        : form_desligamento.php
 * CRIAÇÃO      : Mateus Zimmermann (MoutS)
 * DATA CRIAÇÃO : 25/07/2017
 * OBJETIVO     : Formulario desligamento
 * --------------
 * ALTERAÇÕES   : 14/11/2017 - Retirado informções de parcelamento (Jonata - RKAM P364).
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

									<div id="divMotivoDesligamento">

										<form id="frmMotivoDesligamento" name="frmMotivoDesligamento" class="formulario" onsubmit="return false;">

											  <fieldset>

												<label for="dtdemiss"><? echo utf8ToHtml('Saída:') ?></label>
												<input type="text" name="dtdemiss" id="dtdemiss" value="<? echo $glbvars['dtmvtolt'] ?>" />

												<label for="cdmotdem">Motivo:</label>
												<input type="text" name="cdmotdem" id="cdmotdem" value="<? echo getByTagName($registro,'cdmotdem') ?>" />
												<a style="padding: 3px 0 0 3px;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
												<input type="text" name="dsmotdem" id="dsmotdem" value="<? echo getByTagName($registro,'dsmotdem') ?>" />
												<br style="clear:both" />

											  </fieldset>

										</form>
										<div style="clear: both"></div>

										<div id="divBotoes2">
										  <a href="#" class="botao" id="btVoltar" onclick="controlaVoltarTelaDesligamento('1'); return false;">Voltar</a>
										  <a href="#" class="botao" id="btOk" onclick="controlaVoltarTelaDesligamento('2'); return false;">Prosseguir</a>
										</div>

									</div>

									<div id="divDesligamento">

										<form id="frmDesligamento" name="frmDesligamento" class="formulario" onsubmit="return false;">

										  <fieldset style="padding:0px; margin:0px; padding-bottom:10px;">

											<label for="vldcotas" >Valor das cotas: </label>
											<input name="vldcotas" id="vldcotas" type="text" />
											<br style="clear:both">

											<label for="nrdconta" ><?php echo utf8ToHtml('Conta para crédito:') ?></label>
											<input name="nrdconta" id="nrdconta" type="text" />
											<br style="clear:both">										

										  </fieldset>

										</form>

										<div style="clear: both"></div>

										<div id="divBotoes2">
										  <a href="#" class="botao" id="btVoltar" onclick="controlaVoltarTelaDesligamento('3'); return false;">Voltar</a>
										  <a href="#" class="botao" id="btOk" onclick="controlaVoltarTelaDesligamento('4'); return false;">Prosseguir</a>
										  
										</div>

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
	
	formataTelaDesligamento();
	
	$('#vldcotas','#frmDesligamento').val('<?php echo $vldcotas; ?>');
	$('#nrdconta','#frmDesligamento').val('<?php echo formataContaDV($nrdconta); ?>');
	
</script>