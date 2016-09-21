<?php
/*!
 * FONTE        : form_transacao.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 11/11/2011
 * OBJETIVO     : Formulario transacao
 * --------------
 * ALTERAÇÕES   : 17/09/2012 - Implementação do novo layout, botões (David Kruger).
 *
 *				  18/11/2013 - Adicionado opcao de "Bloquear/Desbloquear Saque". (Jorge)
 *
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
?>

<?php
	$cdsitfin = $_POST['cdsitfin'];
	$flgblsaq = $_POST['flgblsaq'];
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
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">&nbsp;</td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="fechaRotina( $('#divUsoGenerico') ); $('#divUsoGenerico').html(''); return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
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
									<div id="divTransacao">
										<div id="divBotoes" style="margin-top:10px">
											<a href="#" class="botao" id="btVoltar" onClick="fechaRotina( $('#divUsoGenerico') ); $('#divUsoGenerico').html(''); return false;">Voltar</a>
											<a href="#" class="botao" onclick="mostraData('lista_transacoes');return false;">Lista das Transa&ccedil;&otilde;es</a>
											<a href="#" class="botao" id="btnBloquear" onclick="btnConfirmar('manterRotina(\'bloquear\');', 'bloqueiaFundo($(\'#divUsoGenerico\'));')"><?php echo $cdsitfin == '3' ? 'Desbloquear Cash' : 'Bloquear Cash' ?> </a>
											<a href="#" class="botao" id="btnBloqSaq"  onclick="btnConfirmar('manterRotina(\'bloquearSaq\');', 'bloqueiaFundo($(\'#divUsoGenerico\'));')"><?php echo $flgblsaq == 'yes'? 'Desbloquear Saque' : 'Bloquear Saque' ?> </a>
											<a href="#" class="botao" onclick="mostraData('depositos');return false;">Dep&oacute;sitos</a>
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