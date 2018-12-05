<?php 

	//************************************************************************//
	//*** Fonte: logspb.php                                                ***//
	//*** Autor: David                                                     ***//
	//*** Data : Novembro/2009                Última Alteração: 11/05/2017 ***//
	//***                                                                  ***//
	//*** Objetivo  : Mostrar tela LOGSPB                                  ***//
	//***                                                                  ***//
	//*** Alterações: 21/05/2010 - Corrigir textarea do MOTIVO (David).    ***//
	//***                                                                  ***//
	//***             23/07/2010 - Incluido consulta de transacoes 		   ***//
	//***                          rejeitadas (Elton).      			   ***//
	//***                                                                  ***//
	//***             18/04/2012 - Criado a div "ContaOrigem". (Fabricio)  ***//
	//***                                                                  ***//
	//***			  05/07/2012 - Adicionado input sidlogin em form       ***//
	//***						   frmLogSPB. (Jorge)                      ***//
	//***	                                                               ***//
    //***	          27/03/2013 - Alteração na padronização da tela para  ***//
	//***                          novo layout (David Kruger).     		   ***//
	//***																   ***//
	//***			  18/11/2014 - Tratamento para a Incorporação Concredi ***//
	//***                          e Credimilsul SD 223543 (Vanessa).      ***//
	//***																   ***//
	//***             06/07/2015 - Inclusão do campo ISPB (Vanessa)	       ***//
	//***            													   ***//
	//***			  07/08/2015 - Gestão de TEDs/TECs - melhoria 85 (Lucas Ranghetti)
	//***																   ***//
	//***			  09/11/2015 - Adicionado campo "Crise" no formulario  ***//
	//***						   (Jorge/Andrino) 						   ***//
	//***																   ***//	
    //***             14/09/2016 - Adicionado campo Sicredi                ***//
    //***                          (Evandro - RKAM) 			           ***//
	//***																   ***//	
    //***             07/11/2016 - Ajustes para corrigir problemas encontrados ***//
    //***                          durante a homologação da área		   ***//
	//***                          (Adriano - M211)				           ***//
	//***														           ***//
    //***             11/04/2017 - Permitir acessar o Ayllos mesmo vindo   ***//
    //***                          do CRM. (Jaison/Andrino)				   ***//
	//***														           ***//
    //***             27/01/2016 - Permitir exibir TEDs Extornadas         ***//
    //***                          PRJ335 - Analise de Fraude(Odirlei-AMcom) ***//
	//***                                                                 ***//
	//***             11/05/2017 - Adicionado o "Devoluções" no campo     ***//
	//***                          "TIPO" (Douglas - Chamado 541233)      ***//
	//***             19/11/2018 - Renomear tela para hstspb		     ***//
	//***                          (Bruno Luiz Katzjarowski - Mout's))      ***//
	//***********************************************************************//
	
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
	include("../../includes/carrega_permissoes.php");	

	setVarSession("opcoesTela",$opcoesTela);
		
?>
<script>
	var cdcooper = '<? echo $glbvars['cdcooper']?>';
	var nmcooper = '<? echo strtoupper($glbvars['nmcooper'])?>';
</script>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<meta http-equiv="Pragma" content="no-cache">
<title><?php echo $TituloSistema; ?></title>
<link href="../../css/estilo2.css" rel="stylesheet" type="text/css">
<script type="text/javascript" src="../../scripts/scripts.js"></script>
<script type="text/javascript" src="../../scripts/dimensions.js"></script>
<script type="text/javascript" src="../../scripts/funcoes.js"></script>
<script type="text/javascript" src="../../scripts/mascara.js"></script>
<script type="text/javascript" src="../../scripts/menu.js"></script>
<script type="text/javascript" src="hstspb.js?keyrand=<?php echo mt_rand(); ?>"></script>	
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
											<td class="txtBrancoBold" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">HSTSPB - Hist&oacute;rico das transa&ccedil;&otilde;es SPB</td>
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
															<table width="760" border="0" cellpadding="0" cellspacing="0" style="background-color: #F4F3F0;">
																<tr>
																	<td>															
																		<table width="100%" border="0" cellspacing="0" cellpadding="0">
																			<tr>
																				<td>
																					<form name="frmLogSPB" id="frmLogSPB" class="formulario cabecalho">
                                                                                        <input type="hidden" name="crm_inacesso" id="crm_inacesso" value="<?php echo $_SESSION["glbvars"][$glbvars["sidlogin"]]['CRM_INACESSO']; ?>" />
                                                                                        <input type="hidden" name="crm_nrdconta" id="crm_nrdconta" value="<?php echo $_SESSION["glbvars"][$glbvars["sidlogin"]]['CRM_NRDCONTA']; ?>" />
																					    <input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
																						<label for="cddopcao" class="txtNormalBold"><? echo utf8ToHtml('Op&ccedil;&atilde;o:') ?></label>
                                            
																						<select id="cddopcao" name="cddopcao" class="campo">
																					  <!-- <option value="L" selected> L - Consultar o log das Teds</option> 
																						   	 <option value="R"> R - Gerar relatório de transações SPB</option> -->
																						</select>

                                            <div id="divBotaoOk">
                                              <a href="#" class="botao" id="btOK" onClick="obtemLog(); return false;">OK</a>
                                            </div>
																						
																						<br/>
																						<br style="clear:both" />

                                            <fieldset class="logspb">
                                              <legend>Filtro</legend>                                                  
																						
																						  <div id="divLog">
																						  <label for="flgidlog" class="txtNormalBold">Log:</label>
																							  <select name="flgidlog" id="flgidlog" class="campo">
																								  <option value="1">Bancoob</option>
																								  <option value="2" selected>Ailos</option>
																								  <option value="3">Sicredi</option>
																							  </select>
																						  </div>

                                              <div id="divData">
                                                <label for="dtmvtlog" class="txtNormalBold">Data:</label>
                                                <input name="dtmvtlog" type="text" class="campo" id="dtmvtlog" value=""<?php echo $glbvars["dtmvtolt"]; ?>">
                                              </div>                                          																						  
                                            
																						  <div id="divTipo">	
																						  <label for="numedlog" class="txtNormalBold">Tipo:</label>
																							  <select name="numedlog" id="numedlog" class="campo">
																								  <option value="1" selected>Enviadas</option>
																								  <option value="2">Recebidas</option>
																								  <option value="5">Devolu&ccedil;&otilde;es</option>
																								  <option value="3">Log</option>		
																								  <option value="4">Todos</option>
																							  </select>
																						  </div>	
																						
																						  <div id="divCoop">	
																						   <label for="cdcopmig" class="txtNormalBold" style="width: 65px">Coop:</label>
																							  <select name="cdcopmig" id="cdcopmig" class="campo" >
																								
																							  </select>
																						  </div>
																						
																						  <div id="divContaOrigem">
																							  <br/>
																							  <br style="clear:both" />
																							  <div id="divSituacao">																								    
																								  <label for="cdsitlog" class="txtNormalBold">Situa&ccedil;&atilde;o:</label>
																									  <select name="cdsitlog" id="cdsitlog" class="campo" >
																										  <option value="P" id="optProcessada" selected>Processadas</option>
																										  <option value="D" id="optDevolvida">Devolvidas</option>
																										  <option value="R" id="optRejeitada">Rejeitadas</option>
                                                                                                          <option value="E" id="optEstornada">Estornadas</option>
																										  <option value="T" id="optTodas">Todos</option>
																									  </select>																												
																							  </div>																								
																							
																							  <label for="nrdconta" class="txtNormalBold" width="62" align="left">Conta/dv:</label>
																							  <input name="nrdconta" type="text" class="campo" id="nrdconta">
																							
																							  <label for="dsorigem" class="txtNormalBold">Origem:</label>
																							  <select name="dsorigem" id="dsorigem" class="campo">
																								  <option value="1">Ayllos</option>
																								  <option value="2">Caixa Online</option>
																								  <option value="3">Internet</option>
																								  <option value="0" selected>Todos</option>
																							  </select>
																							
																							  <br style="clear:both" />
																							
																							  <label for="inestcri" class="txtNormalBold">Somente Crise:</label>
																							  <select name="inestcri" id="inestcri" class="campo">
																								  <option value="0">N&atilde;o</option>
																								  <option value="1">Sim</option>
																							  </select>
                                                  
																							  <label for="vlrdated" class="txtNormalBold">Valor:</label>
																							  <input name="vlrdated" type="text" class="campo" id="vlrdated" value="0,00">
                                                 
                                                  
																						  </div>
                                            </fieldset>
                                                <div class="Botoes">
                                                  <div id="divBotaoVoltar">
                                                    <a class="botao" id="btVoltar" onClick="VoltarLoad(); return false;">Voltar</a>
                                                  </div>

                                                  <div id="divBotaoOk">
                                                    <a href="#" class="botao" id="btOK" onClick="obtemLog(); return false;">Concluir</a>
                                                  </div>
                                                </div>
																						</br>
																						<br style="clear:both" />

																					</form>
																					
																					<form id="frmImpressao"></form>																					
																					
																				</td>
																			</tr>
																			<tr>
																				<td height="10"></td>
																			</tr>																	
																			<tr>
																				<td>
																					<table width="100%" cellpadding="0" cellspacing="0" border="0">
																						<tr>
																							<td height="300" align="center">
																								<div id="divConteudoLog" style="width: 100%; display: none;">&nbsp;</div>
																								<div id="divDetalhesLog" style="width: 100%; display: none;">
																									<form action="" method="post" name="frmDetalheLog" id="frmDetalheLog">
																									<table border="0" cellpadding="0" cellspacing="0">
																										<tr>
																											<td width="150" class="txtNormalBold" height="23" align="right">JDSPB:&nbsp;</td>
																											<td width="205" class="txtNormal"><input name="dstransa" type="text" class="campoTelaSemBorda" id="dstransa" style="width: 200px;"></td>
																										</tr>
																										<tr>
																											<td width="150" class="txtNormalBold" height="23" align="right">Mensagem:&nbsp;</td>
																											<td width="205" class="txtNormal"><input name="nmevento" type="text" class="campoTelaSemBorda" id="nmevento" style="width: 200px;"></td>
																										</tr>
																										<tr>
																											<td width="150" class="txtNormalBold" height="23" align="right">Número Controle:&nbsp;</td>
																											<td width="205" class="txtNormal"><input name="nrctrlif" type="text" class="campoTelaSemBorda" id="nrctrlif" style="width: 200px;"></td>
																										</tr>
																										<tr>
																											<td width="150" class="txtNormalBold" height="23" align="right">Valor:&nbsp;</td>
																											<td width="205" class="txtNormal"><input name="vltransa" type="text" class="campoTelaSemBorda" id="vltransa" style="width: 200px;"></td>
																										</tr>
																										<tr>
																											<td width="150" class="txtNormalBold" height="23" align="right">Hora:&nbsp;</td>
																											<td width="205" class="txtNormal"><input name="hrtransa" type="text" class="campoTelaSemBorda" id="hrtransa" style="width: 200px;"></td>
																										</tr>
																										<tr>
																											<td class="txtNormalBold" height="23" align="right" id="tdMotivoDetalhe" valign="top">MOTIVO:&nbsp;</td>
																											<td colspan="3" class="txtNormal"><div id="divCampoMotivo"><textarea name="dsmotivo" class="campoTelaSemBorda" id="dsmotivo" style="width: 480px; height: 33px;" style="overflow: hidden;" readonly></textarea></div></td>
																										</tr>
																										<tr>
																											<td colspan="4" height="10"></td>
																										</tr>
																										<tr>
																											<td colspan="2" class="txtNormalBold" height="23" align="center">REMETENTE</td>
																											<td colspan="2" class="txtNormalBold" height="23" align="center">DESTINAT&Aacute;RIO</td>
																										</tr>
																										<tr>
																											<td width="150" class="txtNormalBold" height="23" align="right">Banco:&nbsp;</td>
																											<td width="205" class="txtNormal"><input name="cdbanrem" type="text" class="campoTelaSemBorda" id="cdbanrem" style="width: 200px;"></td>
																											<td width="75" class="txtNormalBold" height="23" align="right">Banco:&nbsp;</td>
																											<td width="205" class="txtNormal"><input name="cdbandst" type="text" class="campoTelaSemBorda" id="cdbandst" style="width: 200px;"></td>																											
																										</tr>
																										<tr>
																											<td width="150" class="txtNormalBold" height="23" align="right">ISPB:&nbsp;</td>
																											<td width="205" class="txtNormal"><input name="cdispbrem" type="text" class="campoTelaSemBorda" id="cdispbrem" style="width: 200px;"></td>
																											<td width="75" class="txtNormalBold" height="23" align="right">ISPB:&nbsp;</td>
																											<td width="205" class="txtNormal"><input name="cdispbdst" type="text" class="campoTelaSemBorda" id="cdispbdst" style="width: 200px;"></td>																											
																										</tr>
																										<tr>
																											<td class="txtNormalBold" height="23" align="right">Ag&ecirc;ncia:&nbsp;</td>
																											<td class="txtNormal"><input name="cdagerem" type="text" class="campoTelaSemBorda" id="cdagerem" style="width: 200px;"></td>
																											<td class="txtNormalBold" height="23" align="right">Ag&ecirc;ncia:&nbsp;</td>
																											<td class="txtNormal"><input name="cdagedst" type="text" class="campoTelaSemBorda" id="cdagedst" style="width: 200px;"></td>
																										</tr>
																										<tr>
																											<td class="txtNormalBold" height="23" align="right">Conta/dv:&nbsp;</td>
																											<td class="txtNormal"><input name="nrctarem" type="text" class="campoTelaSemBorda" id="nrctarem" style="width: 200px;"></td>
																											<td class="txtNormalBold" height="23" align="right">Conta/dv:&nbsp;</td>
																											<td class="txtNormal"><input name="nrctadst" type="text" class="campoTelaSemBorda" id="nrctadst" style="width: 200px;"></td>
																										</tr>
																										<tr>
																											<td class="txtNormalBold" height="23" align="right">Nome:&nbsp;</td>
																											<td class="txtNormal"><input name="dsnomrem" type="text" class="campoTelaSemBorda" id="dsnomrem" style="width: 200px;"></td>
																											<td class="txtNormalBold" height="23" align="right">Nome:&nbsp;</td>
																											<td class="txtNormal"><input name="dsnomdst" type="text" class="campoTelaSemBorda" id="dsnomdst" style="width: 200px;"></td>
																										</tr>
																										<tr>
																											<td class="txtNormalBold" height="23" align="right">CPF/CNPJ:&nbsp;</td>
																											<td class="txtNormal"><input name="dscpfrem" type="text" class="campoTelaSemBorda" id="dscpfrem" style="width: 200px;"></td>
																											<td class="txtNormalBold" height="23" align="right">CPF/CNPJ:&nbsp;</td>
																											<td class="txtNormal"><input name="dscpfdst" type="text" class="campoTelaSemBorda" id="dscpfdst" style="width: 200px;"></td>
																										</tr>	
																										<tr>
																											<td colspan="4" height="10"></td>
																										</tr>
																										<tr>
																										<td colspan="4" align="center"><a href="#" class="botao" id="btVoltar" onClick="voltarDetalhes(); return false;">Voltar</a></td>
																										</tr>
																									</table>
																									</form>
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

