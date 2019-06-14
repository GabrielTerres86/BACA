<?
/*!
 * FONTE        : form_lote.php
 * CRIAÇÃO      : Rogérius Militão - DB1 Informatica
 * DATA CRIAÇÃO : 02/02/2012 
 * OBJETIVO     : Formulário lotes de cheques para desconto
 * --------------
 * ALTERAÇÕES   : 15/08/2013 - Alteração da sigla PAC para PA (Carlos).
 * --------------
 */	 
?>

<?
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções
	// require_once("../../includes/config.php");
	// require_once("../../includes/funcoes.php");
		
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');	
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();
	
	
	$protocolo = unserialize($_POST['protocolo']);
	
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
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="estadoInicial(); return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
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
									<div id="divConteudo">

										<form id="frmLote" name="frmLote" class="formulario" onsubmit="return false;">

											<fieldset>
												<legend>Lotes De Cheques Para Desconto</legend>
												
												<div class="divRegistros">	
													<table class="tituloRegistros">
														<thead>
															<tr>
																<th></th>
																<th><? echo utf8ToHtml('Data'); ?></th>
																<th><? echo utf8ToHtml('PA'); ?></th>
																<th><? echo utf8ToHtml('Lote');  ?></th>
																<th><? echo utf8ToHtml('Qtd.Chqs.');  ?></th>
																<th><? echo utf8ToHtml('Total');  ?></th>
															</tr>
														</thead>
														<tbody>
															<?
															$qtchqtot = 0;
															$vlchqtot = 0;
															
															foreach ( $protocolo as $r ) { 
															
															?>
																<tr>
																	<td><img src="<?php echo $UrlImagens; ?>geral/excluir.gif" border="0" onclick="btnRemover('<?php echo $qtchqtot ?>');" /></td>
																	<td><span><? echo $r['dtmvtolt']; ?></span>
																			  <? echo $r['dtmvtolt']; ?>
																	</td>
																	<td><span><? echo $r['cdagenci']; ?></span>
																			  <? echo $r['cdagenci']; ?>
																	</td>
																	<td><span><? echo $r['nrdolote']; ?></span>
																			  <? echo $r['nrdolote']; ?>
																	</td>
																	<td><span><? echo $r['qtchqtot']; ?></span>
																			  <? echo $r['qtchqtot']; ?>
																	</td>
																	<td><span><? echo $r['vlchqtot']; ?></span>
																			  <? echo formataMoeda($r['vlchqtot']); ?>
																	</td>
																</tr>
														<? 
																$qtchqtot += 1; 
																$vlchqtot += converteFloat($r['vlchqtot']); 

														} 
														
														?>	
														</tbody>
													</table>
												</div>
												
											</fieldset>	
								
										<center>
										Foram selecionados <b><?php echo $qtchqtot ?></b> cheque(s), totalizando o valor de <b>R$ <?php echo formataMoeda($vlchqtot)?></b>.
										</center>
										</form>
										
										<div id="divBotoes" style="padding-bottom: 10px">
											<a href="#" class="botao" id="btVoltar" onclick="estadoInicial(); return false;">Cancelar</a>
											<a href="#" class="botao" onclick="msgAtencao(); return false;" >Continuar</a>
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