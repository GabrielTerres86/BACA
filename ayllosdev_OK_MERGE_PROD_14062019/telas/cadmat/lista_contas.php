<?php
/*!
 * FONTE        : lista_contas.php
 * CRIAÇÃO      : Gabriel Ramirez (RKAM)
 * DATA CRIAÇÃO : 30/07/2015
 * OBJETIVO     : Formulario para selecionar conta a duplicar
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
	
	$lscontas = $_POST["lscontas"];
	
	$registros = explode("|",$lscontas);
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
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><? echo utf8ToHtml('DUPLICAR C/C') ?></td>
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
									<div id="divContas">
										<form id="frmContas" name="frmContas" class="formulario" onsubmit="return false;">

											<fieldset>
												<legend><? echo utf8ToHtml('Informe a C/C a ser duplicada') ?></legend>
												
												<div class="divRegistros">
												<table>
													<thead>
														<tr><th>Conta/dv</th>
															<th>Data de admiss&atilde;o</th>
														</tr>			
													</thead>
													<tbody>
														<? foreach( $registros as $registro ) { 
															$registro = explode(";",$registro);
															$nrdconta = $registro[0];
															$dtadmiss = $registro[1];
														?>
															<tr onclick="selecionaConta('<? echo $nrdconta; ?>'); fechaRotina($('#divRotina'));">
																<td><? echo $nrdconta; ?></td>
																<td><? echo $dtadmiss; ?></td>

															</tr>				
														<? } ?>			
													</tbody>
												</table>
											</div> 
												
											</fieldset>	
										</form>

										<div id="divBotoes2">
											<a href="#" class="botao" id="btnVoltar" onclick="fechaRotina($('#divRotina')); return false;">Voltar</a>
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