<?php
/*!
 * FONTE        : form_desligamento.php
 * CRIAÇÃO      : Mateus Zimmermann (MoutS)
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
			<table border="0" cellpadding="0" cellspacing="0" width="350">
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
										
										<fieldset>

											<label for="vldcotas" style="width: 140px">Valor das cotas: </label>
											<input name="vldcotas" id="vldcotas" type="text" value="<?php echo $vldcotas; ?>" />
											<br />

											<label for="nrdconta" style="width: 140px"><?php echo utf8ToHtml('Conta para crédito:') ?></label>
											<input name="nrdconta" id="nrdconta" type="text" value="<?php echo formataContaDV($nrdconta); ?>" />
											<br />

											<label for="formaTot" style="width: 140px"><?php echo utf8ToHtml('Forma de devolução:') ?></label>	
											<input name="formadev" id="formaTot" type="radio" class="radio" onclick="alteraFormaDevolucao(1)" value="1" <? echo getByTagName($situacao,'cdsitdct') == 7 && getByTagName($situacao,'cdmotdem') == 12 ? 'checked' : '';  ?> />
											<label for="formaTot" class="radio"><? echo utf8ToHtml('Total') ?></label>
											<input name="formadev" id="formaPar" type="radio" class="radio" onclick="alteraFormaDevolucao(2)" value="2" style="<? echo getByTagName($situacao,'cdsitdct') == 7 && getByTagName($situacao,'cdmotdem') == 12 ? 'display:none' : '';  ?>" />
											<label for="formaPar" class="radio" style="<? echo getByTagName($situacao,'cdsitdct') == 7 && getByTagName($situacao,'cdmotdem') == 12 ? 'display:none' : '';  ?>"><? echo utf8ToHtml('Parcelada') ?></label>
											<br />

											<label for="qtdparce" style="width: 140px; display: none"><?php echo utf8ToHtml('Quantidade de parcelas:') ?></label>
											<input name="qtdparce" id="qtdparce" type="text" class="campo" />
											<br />

											<label for="datadevo" style="width: 140px"><?php echo utf8ToHtml('Data da devolução:') ?></label>
											<input name="datadevo" id="datadevo" type="text" class="data campo"/>
											<br />

										</fieldset>

									</form>
									<div style="clear: both"></div>
									<div id="divBotoes2">
										<a href="#" class="botao" id="btVoltar" onclick="fechaRotina($('#divRotina')); return false;">Voltar</a>
										<a href="#" class="botao" id="btOk" <? echo getByTagName($situacao,'cdmotdem') != 12 && getByTagName($situacao,'cdmotdem') != 13 ? 'onclick="confirmarDesligamento('.getByTagName($situacao,'cdmotdem').', '.getByTagName($situacao,'dsmotdem').');"' : 'onclick="efetuarDevolucaoCotas();"';  ?>>Prosseguir</a>
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