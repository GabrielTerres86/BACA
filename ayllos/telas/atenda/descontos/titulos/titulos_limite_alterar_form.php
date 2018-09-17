<?php
/*!
 * FONTE        : titulos_limite_alterar_form.php
 * CRIAÇÃO      : Lucas Lunelli
 * DATA CRIAÇÃO : 16/12/2015 
 * OBJETIVO     : Tela para alteração do número da proposta de limite de desc de títulos. (Lunelli - SD 360072 [M175])
 * --------------
 * ALTERAÇÕES   : 22/03/2018 - Retirado opcao de alteracao do numero da proposta. (Daniel - Projeto 403)
 * --------------
 * 000:
 *
 *
 */	
?>
 
<?php
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../../includes/config.php");
	require_once("../../../../includes/funcoes.php");	
?>

<table id="altera" cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td align="center">		
			<table border="0" cellpadding="0" cellspacing="0" width="288px">
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">Alterar ?</td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="fechaRotina($('#divUsoGenerico'),divRotina);"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
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
											<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen0"><a href="#" id="linkAba0" onClick="return false;" class="txtNormalBold">Principal</a></td>
																																					
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir0"></td>
											<td width="1"></td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
									<div style="width: 240px; height: 100px;" id="divConteudoAltara" class="divBotoes">
												
										<a href="#" class="botao" style="margin: 4px 0px 4px 0px; width:230px; " id="todaProp" onClick="fechaRotinaAltera();carregaDadosAlteraLimiteDscTit();return false;">Toda a proposta </a>
									<!--	<a href="#" class="botao" style="margin: 4px 0px 4px 0px; width:230px; " onClick="exibeAlteraNumero();return false;"> Alterar o n&uacute;mero do contrato </a> -->
										<a href="#" class="botao" style="margin: 6px 0px 0px 0px;" id="btVoltar" onClick="fechaRotinaAltera();return false;"> Voltar </a>
										
																				
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