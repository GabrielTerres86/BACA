<?
/*!
 * FONTE        : antecipacao.php
 * CRIAÇÃO      : Daniel Zimmermann (Cecred)
 * DATA CRIAÇÃO : 16/06/2014 
 * OBJETIVO     : Tela com parcelas antecipadas
 * --------------
 * ALTERAÇÕES   :
 */	
?>
 
<?

	session_start();	
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../../includes/config.php");
	require_once("../../../../includes/funcoes.php");
	require_once("../../../../includes/controla_secao.php");
	isPostMethod();	
	
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';
	
?>

<table id="tdAntecip"cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td align="center">		
			<table border="0" cellpadding="0" cellspacing="0" width="500">
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><? echo utf8ToHtml('Impressão de Antecipação') ?></td>
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
											<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen0"><a href="#" id="linkAba0" class="txtNormalBold">Principal</a></td>
																																					
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir0"></td>
											<td width="1"></td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px 2px 8px;">
									<div id="divConteudoOpcao" style="height: 270px">
										<form class="formulario" id="frmAntecipacao">
										<div id="divAntecip" >
										    <label class="txtNormalBold" for="nrctremp" style="width: 70px" ><? echo utf8ToHtml('Contrato:') ?></label>
											<input name="nrctremp" id="nrctremp" class="campo" type="text" value="" style="width: 80px" disabled />
											<label class="txtNormalBold" for="vlpreemp" style="width: 90px;" ><? echo utf8ToHtml('Parcela:') ?></label>
											<input name="vlpreemp" id="vlpreemp" class="campo" type="text" style="text-align: right;width: 80px" value="" disabled />																
											
										</div>	
										</form>
										<br style="clear:both" />
										<div id="divParcelasAntecipadas">
										</div>
										<br style="clear:both" />
										<div id="divBtnAntecip" style="margin-top:5px; margin-bottom :10px" >
											<input type="image" src="<?php echo $UrlImagens; ?>botoes/imprimir.gif" onClick="imprimirAntecipacao(); return false;">
											<input type="image" id="btVoltar" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="fechaRotina($('#divUsoGenerico'),divRotina);" />
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