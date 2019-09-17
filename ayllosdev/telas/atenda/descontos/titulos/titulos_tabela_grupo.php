<?php
/*!
 * FONTE        : titulos_tabela_grupo.php
 * CRIAÇÃO      : Leonardo de Freitas Olivera
 * DATA CRIAÇÃO : 03/03/2018
 * OBJETIVO     : 
 * ALTERAÇÕES   : 
 * --------------
 * 000:
 *
 *
 */	
?>
 
<?php
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../../includes/config.php");
	require_once("../../../../includes/funcoes.php");
    require_once('../../../../includes/controla_secao.php');
	require_once("../../../../class/xmlfile.php");
	
	$mensagem_03 = (isset($_POST['mensagem_03'])) ? $_POST['mensagem_03'] : '';
	$mensagem_04 = (isset($_POST['mensagem_04'])) ? $_POST['mensagem_04'] : '';
	$nrdconta    = (isset($_POST['nrdconta']))    ? $_POST['nrdconta']    : '';
	$qtctarel    = (isset($_POST['qtctarel']))    ? $_POST['qtctarel']    : 0;
	$grupo       = (isset($_POST['grupo']))       ? $_POST['grupo']    	  : '';
	
?>

<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td align="center">		
			<table border="0" cellpadding="0" cellspacing="0" width="400px">
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">DESCONTO DE T&Iacute;TULOS</td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="telaOperacaoNaoEfetuada();"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
								<td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
							</tr>
						</table>     
					</td> 
				</tr>    
				<tr>
					<td class="tdConteudoTela" align="center">	
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
									<div id="divGrupoEconomico">
										<br style="clear:both" />
										<label> <?echo $mensagem_03;?></label>
										<br style="clear:both" />
										<label>Conta <?echo formataContaDVsimples($nrdconta);?> Pertence a Grupo Economico.
										<br/>
										Valor ultrapassa limite legal permitido.
										<br/>
										Verifique endividamento total das contas.</label>
										<br style="clear:both" />
										
										<br style="clear:both" />
										
											<fieldset style="margin: 3px; padding: 0px 3px 5px 3px; border: 1px solid #bbb; width:260px" >
												<legend>Grupo Possui <? echo $qtctarel;?> Contas Relacionadas</legend>
												<div style="width:250px">
													<div id="divGrupoEconomico" class="divRegistros" style="width:210px">
														<table>
															<thead>
																<tr>
																	<th>Conta/DV</th>
																</tr>
															</thead>
															<tbody>
																<? $array_grupo = explode(";", $grupo); 
																   $grupo_length = count($array_grupo)?>
																
																<? for($i = 0; $i < $grupo_length; $i++ ) { ?>
																	<tr><td align="center"><? echo $array_grupo[$i]; ?></td></tr>
																<? } ?>
															</tbody>
														</table>
													</div>
												</div>
											</fieldset>
									</div>
									<div style="width: 240px;" class="divBotoes">
										<a href="#" class="botao" style="margin: 6px 0px 0px 0px;" id="btVoltar" onClick="telaOperacaoNaoEfetuada();"> Ok </a>
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