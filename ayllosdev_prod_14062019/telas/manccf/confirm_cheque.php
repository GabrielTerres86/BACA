<?php
/*!
 * FONTE        : confirm_cheque.php
 * CRIAÇÃO      : Andrey Formigari
 * DATA CRIAÇÃO : 26/12/2018
 * OBJETIVO     : Formulário de Cheques
 */


session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');

isPostMethod();
?>

<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td align="center">
			<table border="0" cellpadding="0" cellspacing="0" width="400">
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">Cheque</td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="fechaRotina($('#divRotina')); return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
								<td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td class="tdConteudoTela" align="center">
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px 2px 8px;">
									<div id="divConteudoOpcao">
                                        <form id="frmAprovadores" name="frmAprovadores" class="formulario" style="display:block;">

											<label style="width:130px" for="nrcheque">Cheque:</label>
                                            <input style="margin-left:15px" type="text" id="nrcheque" name="nrcheque" class="campo cheque" autocomplete="off" />

                                            <br style="clear:both" />
											
											<label style="width:130px" for="vlcheque">Valor:</label>
                                            <input style="margin-left:15px" type="text" id="vlcheque" name="vlcheque" class="campo moeda" autocomplete="off" />
											
											<br style="clear:both" />
											<br style="clear:both" />

                                            <hr style="background-color:#666; height:1px;" />
                                        </form>

										<div id="divBotoes" style="margin-bottom: 10px;">
											<a href="#" class="botao" id="btVoltar" onClick="fechaRotina($('#divRotina')); return false;">Voltar</a>
											<a href="#" class="botao" id="btConfirm" onClick="Inclusao_CCF(false); return false;">Confirmar</a>
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
