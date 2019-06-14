<?php

	/*************************************************************************
	 Fonte: ALERTA.php                                                
	 Autor: Adriano                                                   
	 Data : Fevereiro/2013              Última Alteração: 06/02/2013		       
	                                                                  
	 Objetivo  : Mostrar tela ALERTA.                                 
	                                                                  
	Alterações: 
	                                                                  
	************************************************************************/
	
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
	
	setVarSession("rotinasTela",$rotinasTela);
	$glbvars['opcoesTela' ] = $opcoesTela;
	
	$flgConsultar	= (in_array('C', $glbvars['opcoesTela']));	
	$flgAlterar		= (in_array('A', $glbvars['opcoesTela']));
	$flgExcluir 	= (in_array('E', $glbvars['opcoesTela']));	
	$flgIncluir		= (in_array('I', $glbvars['opcoesTela']));
	$flgLiberar 	= (in_array('L', $glbvars['opcoesTela']));	
	$flgRelatorio	= (in_array('R', $glbvars['opcoesTela']));
	$flgVinculos	= (in_array('V', $glbvars['opcoesTela']));
		
	
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

	// Alimenta opções que o operador tem acesso
	var flgConsultar	= '<? echo $flgConsultar; 	?>';
	var flgAlterar		= '<? echo $flgAlterar; 	?>';
	var flgExcluir		= '<? echo $flgExcluir; 	?>';
	var flgIncluir		= '<? echo $flgIncluir; 	?>';
	var flgLiberar		= '<? echo $flgLiberar; 	?>';
	var flgRelatorio	= '<? echo $flgRelatorio; 	?>';
	var flgVinculos	    = '<? echo $flgVinculos;	?>';	

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
   <script type="text/javascript" src="../../includes/pesquisa/pesquisa.js"></script>
   <script type="text/javascript" src="alerta.js"></script>	
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
											<td class="txtBrancoBold" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">ALERTA - Cadastro Restritivo </td>
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
																				
																				<!-- INCLUDE DA TELA DE PESQUISA -->
																				<? require_once("../../includes/pesquisa/pesquisa.php"); ?>
																				
																				<!-- INCLUDE DA TELA DE PESQUISA ASSOCIADO -->
																				<? require_once("../../includes/pesquisa/pesquisa_associados.php"); ?>	
																				
																				
																				<? include('form_cabecalho.php'); ?>
																						
																				<div id="divOpcoesConsulta">
																					<? include('form_opcoes_consulta.php');	?> 
																				</div>
																				
																				<div id="divDetalhes" style="display: none;" ></div>
																				
																				<div id="divTabela" style="display: none;" ></div>
																																							
																				
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
