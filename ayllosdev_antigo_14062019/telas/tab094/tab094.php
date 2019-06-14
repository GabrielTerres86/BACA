<?php
/**************************************************************************************
	ATENÇÃO: SE ESTA TELA ALGUM DIA FOR LIBERADA PARA A PRODUÇÃO TEM QUE SER ALTERADA
			 PARA O NOVO LAYOUT DO AYLLOS WEB.
			 FALAR COM O GABRIEL OU DANIEL. 19/02/2013.
****************************************************************************************/

	/******************************************************************************/
	//*** Fonte: tab094.php                                                		***/
	//*** Autor: Tiago                                                     		***/
	//*** Data : Julho/2012                 Última Alteração: 04/10/2012   		***/
	//***                                                                  		***/
	//*** Objetivo  : Mostrar tela TAB094.                                      ***/
	//***                                                                       ***/
	//*** Alterações: 02/10/2012 - Incluído a chamada para o Busca_Cooperativas ***/
	//***                          (Adriano)                                    ***/
	//***			  04/07/2013 - Alterado para receber o novo layout padrão	***/
	//***						   do Ayllos Web (Reinert).						***/
	//*****************************************************************************/
	
	
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");
	require_once('../../class/xmlfile.php');
	
	
	// Verifica se tela foi chamada pelo método POST
	isPostMethod();
	
	// Carrega permissões do operador
	include("../../includes/carrega_permissoes.php");	
	
		
	// Monta o xml de requisição
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0131.p</Bo>';
	$xml .= '		<Proc>Busca_Cooperativas</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
	$xml .= '		<nmrescop>'.$glbvars['nmrescop'].'</nmrescop>';	
	$xml .= '	</Dados>';
	$xml .= '</Root>';

	
	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult 		= getDataXML($xml);
	$xmlObjeto 		= getObjectXML($xmlResult);

	// Recebe as cooperativas
	$nmcooper		= $xmlObjeto->roottag->tags[0]->attributes['NMCOOPER'];
		
	// Faz o tratamento para criar o select
	$nmcooperArray	= explode(',', $nmcooper);
	
	$qtcooper		= count($nmcooperArray);
	$slcooper		= '';
	    
	
	for ( $j = 0; $j < $qtcooper; $j +=2 ) {
		
		if($j > 0){
			$slcooper = $slcooper . '<option value="'.$nmcooperArray[$j+1].'">'.$nmcooperArray[$j].'</option>';
		}
	}
	
	
?>

<script>

	var slcooper = '<?php echo $slcooper ?>';

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
	<script type="text/javascript" src="tab094.js"></script>	
	
	
  </head>

  <body>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
        <tr>
		   <td><?php  include("../../includes/topo.php"); ?></td>
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
											<td class="txtBrancoBold" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">TAB094 - Par&acirc;metros Fluxo Finaceiro </td>
											<td class="txtBrancoBold" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif" align="right"><a href="#" onClick='mostraAjudaF2()' class="txtNormalBold">F2 = AJUDA</a>&nbsp;&nbsp;</td>
											<td class="txtBrancoBold" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick='mostraAjudaF2()' class="txtNormalBold"><img src="<?php echo $UrlImagens; ?>geral/ico_help.jpg" width="15" height="15" border="0"></a></td>
										 	<td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>						  
									      </tr>
									   </table>
     							    </td>								
								</tr>				
								<tr>
									<td id="tdConteudoTela" class="tdConteudoTela" align="center"> 
										<table width="100%"  border= "0" cellpadding="3" cellspacing="0">
											<tr>
												<td style="border: 1px solid #F4F3F0;">
													<table width="100%"  border= "0" cellpadding="10" cellspacing="0" style="background-color: #F4F3F0;">
														<tr>
															<td align="center">
																<table width="545" border="0" cellpadding="0" cellspacing="0" style="backgroung-color: #F4F3F0;">
																	<tr>
																		<td>
																			<div id="divTela">
																				
																				<? include('form_cabecalho.php'); ?>
																				
																				<div id="divFormulario" style="display:none"> </div>
																				
																				<div id="divMsgAjuda" style="margin-top:5px; margin-bottom :10px; display:none; text-align: center;">
																					<span></span>
																					<a href="#" class="botao" id="btVoltar"  onClick="controlaLayout();voltaDiv();return false;" style="text-align: right;">Voltar</a>
																					<a href="#" class="botao" id="btAlterar" onClick="altera_dados();" style="text-align: right;">Alterar</a>
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
