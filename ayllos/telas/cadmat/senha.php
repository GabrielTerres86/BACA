<?php
/*!
 * FONTE        : senha.php
 * CRIAÇÃO      : Lucas Reinert (CECRED)
 * DATA CRIAÇÃO : 03/10/2017
 * OBJETIVO     : Tela do formulario de senha
 */	 
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");

	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';
	
?>

<table cellpadding="0" cellspacing="0" border="0" >
	<tr>
		<td align="center">		
			<table border="0" cellpadding="0" cellspacing="0"  >
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><? echo utf8ToHtml('PARA CONTINUAR, PEÇA LIBERAÇÃO AO COORDENADOR') ?></td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="btnVoltar();fechaRotina($('#divRotina')); return false;" ><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
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
									<div id="divConteudoSenha">
										<form id="frmSenha" name="frmSenha" class="formulario" onsubmit="return false;">

											<fieldset>
												<legend><? echo utf8ToHtml('Digite a Senha') ?></legend>
												<label for="operauto">Coordenador:</label>
												<input name="operauto" id="operauto" type="text" />
												
												<br />
												<label for="codsenha">Senha:</label>
												<input name="codsenha" id="codsenha" type="password" />
												
											</fieldset>	
										</form>

										<div id="divBotoes2">
											<a href="#" class="botao" id="btVoltar" onclick="fechaRotina($('#divRotina')); return false;">Cancelar</a>
											<a href="#" class="botao" id="btOk" onclick="validarSenha('<? echo $operacao; ?>'); return false;">Ok</a>
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