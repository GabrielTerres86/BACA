<?
/*!
 * FONTE        : form_justificativa.php
 * CRIAÇÃO      : Fabricio
 * DATA CRIAÇÃO : 19/11/2013
 * OBJETIVO     : Tela do formulario de justificativa por nao informar transacao ao COAF
 */	 
?>

<?
session_start();
	
// Includes para controle da session, variáveis globais de controle, e biblioteca de funções
require_once("../../includes/config.php");
require_once("../../includes/funcoes.php");
	
$qtdregis = $_POST["qtdregis"];
	
?>

<table width="760px" id='telaConsulta' cellpadding="0" cellspacing="0" border="0" >
	<tr>
		<td align="center">		
			<table width="100%" border="0" cellpadding="0" cellspacing="0"  >
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><? echo utf8ToHtml('Justificativa') ?></td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="fechaRotina($('#divRotina')); desmarcaTodos('<?php echo $qtdregis; ?>'); habilitaSelecao('<?php echo $qtdregis; ?>'); return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
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
									<div id="divInfoTransacao" >										
										<ul class="complemento" id="Complemento" style="margin-top:5px; margin-bottom:5px">
											<li>Coop:</li>
											<li id="cdcooper"></li>
											<li>PA:</li>
											<li id="cdagenci"></li>
											<li>Conta:</li>
											<li id="nrdconta"></li>
											<li>Nome:</li>
											<li id="nmprimtl"></li>
											
											<li>Documento:</li>
											<li id="nrdocmto"></li>
											<li>Operação:</li>
											<li id="tpoperac"></li>
											<li>Valor:</li>
											<li id="vllanmto"></li>
											<li>Data:</li>
											<li id="dtmvtolt"></li>
		
											<li>Informações foram prestadas:</li>
											<li id="flinfdst"></li>
											<li>Origem:</li>
											<li id="recursos"></li>
											<li>Destino:</li>
											<li id="dstrecur"></li>
		
											<li>Justificativa:</li>
											<input id="justifica" name="justifica" type="text"/>
										</ul>
										<div id="divBotoes" style="margin-top:5px; margin-bottom:10px">
											<a href="#" class="botao" id="btVoltar" onclick="fechaRotina($('#divRotina')); desmarcaTodos('<?php echo $qtdregis; ?>'); habilitaSelecao('<?php echo $qtdregis; ?>'); return false;" >Voltar</a>
											<a href="#" class="botao" id="btnConcluir" onclick="confirmaDadosSisbacen(0,false);" >Concluir</a>
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