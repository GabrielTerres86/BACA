<? 
/*!
 * FONTE        : contas.php
 * CRIAÇÃO      : Alexandre Scola (DB1)
 * DATA CRIAÇÃO : Janeiro/03/2010 
 * OBJETIVO     : Mostrar tela CONTAS
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * [12/02/2010] Rodolpho Telmo (DB1): - Incuido plugin do jQuery maskedinput
 * [05/03/2010] Rodolpho Telmo (DB1): - Incuido plugin do jQuery priceFormat
 *                                    - Criado script.js compactado com jquery + maskedinput + price
 * [17/03/2010] Rodolpho Telmo (DB1): - Substituição da pesquisa associado pela contida no arquivo /includes/pesquisa/pesquisa.js
 * [14/04/2011] Rodolpho Telmo e Rogérius Militão (DB1): - Incluido o tela de pesquisa endereco
 * [05/07/2013] Lucas R (CECRED)    : Incluir nova linha <tr> e <td>.
 * [05/09/2013] Carlos  (CECRED)      - Alteração da sigla PAC para PA.
 * [08/08/2014] Jonata  (RKAM)      : Nova rotina de protecao ao credito. 
 * [26/11/2014] Jonata  (RKAM)      : Posicionar corretamente as rotinas.
 * [05/01/2015] James Prust Junior  : Incluir o item Liberar/Bloquear
 * [30/01/2015] Andre Santos(SUPERO): Incluir o item Convenio CDC
 * [03/08/2015] Reformulacao cadastral (Gabriel-RKAM)
 * [19/09/2015] Gabriel (RKAM) Projeto 217: Ajuste para chamada da rotina Produtos.
 * [15/09/2017] Kelvin (CECRED) : Alterações referente a melhoria 339 (Kelvin).

 */
 
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");
	
	// Verifica se tela foi chamada pelo método POST
	isPostMethod();
	
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	// Carrega permissões do operador
	require_once("../../includes/carrega_permissoes.php");		
	
	setVarSession("rotinasTela",$rotinasTela);
	
	$nmtelant = $_POST['nmtelant'];
?>
<html>
    <head>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">	
		<meta http-equiv="Pragma" content="no-cache">
		<title><?php echo $TituloSistema; ?></title>
		<link href="../../css/estilo2.css" rel="stylesheet" type="text/css">
		<link href="../../css/estilo.css" rel="stylesheet" type="text/css">
		<script type="text/javascript" src="../../scripts/scripts.js" charset="utf-8"></script>
		<script type="text/javascript" src="../../scripts/dimensions.js"></script>
		<script type="text/javascript" src="../../scripts/funcoes.js"></script>
		<script type="text/javascript" src="../../scripts/mascara.js"></script>
		<script type="text/javascript" src="../../scripts/menu.js?keyrand<? echo rand(); ?>"></script>
		<script type="text/javascript" src="../../includes/pesquisa/pesquisa.js"></script>
		<script type="text/javascript" src="contas.js?keyrand=<?php echo mt_rand(); ?>"></script>
	</head>
<body>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td><?php include("../../includes/topo.php"); ?></td>
	</tr>
	<tr>
		<td id="tdConteudo" valign="top">
			<table width="100%" height="100%" border="0" cellpadding="0" cellspacing="0">
				<tr> 
					<td width="175" valign="top">
						<table width="100%" border="0" cellpadding="0" cellspacing="0">
							<tr>
								<td id="tdMenu"><?php include("../../includes/menu.php"); ?></td>
							</tr>  
						</table>
					</td>
					<td id="tdTela" valign="top">
						<table width="100%" border="0" cellpadding="0" cellspacing="0">
							<tr>
								<td>
									<table width="100%"  border="0" cellspacing="0" cellpadding="0">
										<tr>
											<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
											<td class="txtBrancoBold" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">CONTAS - Dados da Conta</td>
											<td class="txtBrancoBold" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif" align="right"><a href="#" onClick='mostraAjudaF2()' class="txtNormalBold">F2 = AJUDA</a>&nbsp;&nbsp;</td>
											<td class="txtBrancoBold" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick='mostraAjudaF2()' class="txtNormalBold"><img src="<?php echo $UrlImagens; ?>geral/ico_help.jpg" width="15" height="15" border="0"></a></td>
											<td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td id="tdConteudoTela" class="tdConteudoTela" align="center">								
									<table width="100%" border="0" cellpadding="3" cellspacing="0">
										<tr>
											<td style="border: 1px solid #F4F3F0;">
												<table width="100%" border="0" cellpadding="10" cellspacing="0" style="background-color: #F4F3F0;">
													<tr>
														<td align="center">
															<table width="545" border="0" cellpadding="0" cellspacing="0" style="background-color: #F4F3F0;">
																<tr>
																	<td>
																		<div id="divMsgsAlerta">
																			<table cellpadding="0" cellspacing="0" border="0" width="100%">
																				<tr>
																					<td align="center">		
																						<table border="0" cellpadding="0" cellspacing="0" width="500">
																							<tr>
																								<td>
																									<table width="100%" border="0" cellspacing="0" cellpadding="0">
																										<tr>
																											<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
																											<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">MENSAGENS DE ALERTA</td>
																											<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" id="btVoltar" onClick="encerraMsgsAlerta();return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
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
																												<table width="100%" height="100%" border="0" cellpadding="0" cellspacing="0">
																													<tr>
																														<td align="center" valign="center">
																															<div id="divListaMsgsAlerta" style="overflow-y: scroll; overflow-x: hidden; height: 210px; width: 100%;">&nbsp;</div>																																					
																														</td>
																													</tr>
																												</table>																												
																											</td>
																										</tr>
																									</table>
																								</td>
																							</tr>
																						</table>
																					</td>
																				</tr>
																			</table>																			
																		</div>	
																		
																		<!-- INCLUDE DA TELA DE PESQUISA ENDERECO ASSOCIADO -->
																		<? require_once("../../includes/pesquisa/pesquisa_endereco_associado.php"); ?>
																		
																		<!-- INCLUDE DA TELA DE PESQUISA ENDERECO -->
																		<? require_once("../../includes/pesquisa/pesquisa_endereco.php"); ?>

																		<!-- INCLUDE DA TELA DE INCLUSAO ENDERECO -->
																		<? require_once("../../includes/pesquisa/formulario_endereco.php"); ?>

																		<!-- INCLUDE DA TELA DE PESQUISA -->
																		<? require_once("../../includes/pesquisa/pesquisa.php"); ?>
																		
																		<!-- INCLUDE DA TELA DE PESQUISA ASSOCIADO -->
																		<? require_once("../../includes/pesquisa/pesquisa_associados.php"); ?> 																			
																		
																		<div id="divRotina"></div>
																		<div id="divUsoGenerico"></div>
																		
																		<form name="frmCabContas" id="frmCabContas" class="formulario condensado">
																			
																			<label for="nrdconta">Conta/dv:</label>
																			<input name="nrdconta" id="nrdconta" type="text" />
																			
																			<label for="idseqttl">Seq.Titular:</label>
																			<select id="idseqttl" name="idseqttl">
																				<option value="1"></option>
																			</select>																			

																			<input type="image" src="<? echo $UrlImagens; ?>/botoes/ok.gif" onClick="obtemCabecalho();return false;" />																			
																			<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>												
																			<a>Procurar associado</a>
																			
																			<hr />
																			
																			<label for="cdagenci">PA:</label>
																			<input name="cdagenci" id="cdagenci" type="text" />
																			
																			<label for="nrmatric">Matr.:</label>
																			<input name="nrmatric" id="nrmatric" type="text" />
																			
																			<label for="cdtipcta">Tp.Cta.:</label>
																			<input name="cdtipcta" id="cdtipcta" type="text" />
																			
																			<label for="nrdctitg">Cta./ITG:</label>
																			<input name="nrdctitg" id="nrdctitg" type="text" />
																			
																			<div id="divRotinaPF">
																				<label for="nmextttl">Titular:</label>
																				<input name="nmextttl" id="nmextttl" type="text" />
																				
																				<label for="inpessoa">Nat.:</label>
																				<input name="inpessoa" id="inpessoa" type="text" />
																				<br />
																				
																				<label for="nrcpfcgc">C.P.F.:</label>
																				<input name="nrcpfcgc" id="nrcpfcgc" type="text" />
																				
																				<label for="cdsexotl">Sexo:</label>
																				<input name="cdsexotl" id="cdsexotl" type="text" />
																				
																				<label for="cdestcvl">Est.Civil:</label>
																				<input name="cdestcvl" id="cdestcvl" type="text" />
																				
																				<label for="cdsitdct">Sit.:</label>
																				<input name="cdsitdct" id="cdsitdct" type="text" />
																				
																				<br />
																			</div>
																			
																			 <!-- Pessoa Jurídica - Monta linha da razão social -->
																			<div id="divRotinaPJ"></div>																			
																		</form>
																		
																	</td>
																</tr>
																<tr>																
																	<td style="padding: 3px 3px 3px 3px; border: 1px solid #E3E2DD;">
																		<table width="100%" border="0" cellpadding="5" cellspacing="0">
																			<tr>
																				<td style="background-color: #E3E2DD;">
																					<table width="100%" border="0" cellpadding="0" cellspacing="0">
																						<tr>
																							<td onMouseOver="focoRotina(0,true);"  onMouseOut="focoRotina(0,false);" width="50%"  height="22" align="center" id="labelRot0" class="txtNormalBold">&nbsp;</td>																																														
																							<td onMouseOver="focoRotina(9,true);"  onMouseOut="focoRotina(9,false);" width="50%" height="22" align="center" id="labelRot9" class="txtNormalBold">&nbsp;</td>																							
																						</tr>
																					    <tr>
																							<td onMouseOver="focoRotina(1,true);"  onMouseOut="focoRotina(1,false);"  width="50%" height="22" align="center" id="labelRot1" class="txtNormalBold">&nbsp;</td>																							
																							<td onMouseOver="focoRotina(10,true);" onMouseOut="focoRotina(10,false);" width="50%" height="22" align="center" id="labelRot10" class="txtNormalBold">&nbsp;</td>																							
																						</tr>
																						<tr>
																							<td onMouseOver="focoRotina(2,true);"  onMouseOut="focoRotina(2,false);"  width="50%" height="22" align="center" id="labelRot2" class="txtNormalBold">&nbsp;</td>																																														
																							<td onMouseOver="focoRotina(11,true);" onMouseOut="focoRotina(11,false);" width="50%" height="22" align="center" id="labelRot11" class="txtNormalBold">&nbsp;</td>																							
																						</tr>
																						<tr>
																							<td onMouseOver="focoRotina(3,true);"  onMouseOut="focoRotina(3,false);"  width="50%" height="22" align="center" id="labelRot3" class="txtNormalBold">&nbsp;</td>																							
																							<td onMouseOver="focoRotina(12,true);" onMouseOut="focoRotina(12,false);" width="50%" height="22" align="center" id="labelRot12" class="txtNormalBold">&nbsp;</td>																							
																						</tr>
																						<tr>
																							<td onMouseOver="focoRotina(4,true);"  onMouseOut="focoRotina(4,false);"  width="50%" height="22" align="center" id="labelRot4" class="txtNormalBold">&nbsp;</td>																							
																							<td onMouseOver="focoRotina(13,true);" onMouseOut="focoRotina(13,false);" width="50%" height="22" align="center" id="labelRot13" class="txtNormalBold">&nbsp;</td>																							
																						</tr>
																						<tr>
																							<td onMouseOver="focoRotina(5,true);"  onMouseOut="focoRotina(5,false);"  width="50%" height="22" align="center" id="labelRot5" class="txtNormalBold">&nbsp;</td>																							
																							<td onMouseOver="focoRotina(14,true);" onMouseOut="focoRotina(14,false);" width="50%" height="22" align="center" id="labelRot14" class="txtNormalBold">&nbsp;</td>																							
																						</tr>
																						<tr>
																							<td onMouseOver="focoRotina(6,true);"  onMouseOut="focoRotina(6,false);"  width="50%" height="22" align="center" id="labelRot6" class="txtNormalBold">&nbsp;</td>																							
																							<td onMouseOver="focoRotina(15,true);" onMouseOut="focoRotina(15,false);" width="50%" height="22" align="center" id="labelRot15" class="txtNormalBold">&nbsp;</td>																							
																						</tr>
																						<tr>
																							<td onMouseOver="focoRotina(7,true);"  onMouseOut="focoRotina(7,false);"  width="50%" height="22" align="center" id="labelRot7" class="txtNormalBold">&nbsp;</td>																							
																							<td onMouseOver="focoRotina(16,true);" onMouseOut="focoRotina(16,false);" width="50%" height="22" align="center" id="labelRot16" class="txtNormalBold">&nbsp;</td>																							
																						</tr>
																						<tr>
																							<td onMouseOver="focoRotina(8,true);"  onMouseOut="focoRotina(8,false);"  width="50%" height="22" align="center" id="labelRot8" class="txtNormalBold">&nbsp;</td>																							
																							<td onMouseOver="focoRotina(17,true);" onMouseOut="focoRotina(17,false);" width="50%" height="22" align="center" id="labelRot17" class="txtNormalBold">&nbsp;</td>																							
																						</tr>
																						<tr>
																							<td onMouseOver="focoRotina(9,true);"  onMouseOut="focoRotina(9,false);"  width="50%" height="22" align="center" id="labelRot9" class="txtNormalBold">&nbsp;</td>																							
																							<td onMouseOver="focoRotina(18,true);" onMouseOut="focoRotina(18,false);" width="50%" height="22" align="center" id="labelRot18" class="txtNormalBold">&nbsp;</td>																							
																						</tr>
																						<tr>
																							<td onMouseOver="focoRotina(10,true);"  onMouseOut="focoRotina(10,false);"  width="50%" height="22" align="center" id="labelRot10" class="txtNormalBold">&nbsp;</td>
																							<td onMouseOver="focoRotina(19,true);"  onMouseOut="focoRotina(19,false);"  width="50%" height="22" align="center" id="labelRot19" class="txtNormalBold">&nbsp;</td>
																						</tr>
																						<tr>
																							<td>&nbsp;</td>
																							<td onMouseOver="focoRotina(20,true);"  onMouseOut="focoRotina(20,false);"  width="50%" height="22" align="center" id="labelRot20" class="txtNormalBold">&nbsp;</td>
																						</tr>
																						<tr>
																							<td>&nbsp;</td>
																							<td onMouseOver="focoRotina(21,true);"  onMouseOut="focoRotina(21,false);"  width="50%" height="22" align="center" id="labelRot21" class="txtNormalBold">&nbsp;</td>
																						</tr>
																						<tr>
																							<td>&nbsp;</td>
																							<td onMouseOver="focoRotina(22,true);"  onMouseOut="focoRotina(22,false);"  width="50%" height="22" align="center" id="labelRot22" class="txtNormalBold">&nbsp;</td>
																						</tr>
																					</table>																
																				</td>
																			</tr>																			
																		</table>									
																	</td>
																</tr>
															</table>					
														</td>
													</tr>
												</table>
											</td>
										</tr>
									</table>																
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
</body>
</html>

<script type="text/javascript">

	// Se foi chamada pela tela MATRIC (inclusao de nova conta), carregar as rotinas para finalizar cadastro
	var nmrotina = '<? echo $_POST['nmrotina']; ?>';
	var nrdconta = '<? echo $_POST['nrdconta']; ?>';
	var flgcadas = '<? echo ($nmtelant == 'MATRIC') ? 'M' : 'C'; ?>';
		
	if (nrdconta != '') {
		 $("#nrdconta","#frmCabContas").val(nrdconta);
		 $("#idseqttl","#frmCabContas").val(1);
	}

</script>