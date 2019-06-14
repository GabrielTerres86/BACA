<?php
	/*!
	* FONTE        : pesquisa_empresas.php
	* CRIAÇÃO      : Vanessa Klein
	* DATA CRIAÇÃO : 05/08/2014 
	* OBJETIVO     : Formulário para pesquisar empresas que pode ser chamado de diferentes pontos do sistema
	*
	ALTERACOES     : 28/07/2016 - Removi o comando session_start desnecessário. SD 491425 (Carlos R.)
	*/	
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
?>

<div id="divPesquisaEmpresa" >
	<table cellpadding="0" cellspacing="0" border="0" width="100%">
		<tr>
			<td align="center">		
				<table border="0" cellpadding="0" cellspacing="0" width="550" >
					<tr>
						<td>
							<table width="100%" border="0" cellspacing="0" cellpadding="0">
								<tr>
									<td width="11"><img src="<? echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
									<td class="txtBrancoBold ponteiroDrag" style="text-transform: uppercase;" background="<? echo $UrlImagens; ?>background/tit_tela_fundo.gif"><span class="tituloJanelaPesquisa">PESQUISA DE EMPRESAS</span></td>
									<td width="12" id="tdTitTela" background="<? echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a class="fecharPesquisa" onClick="estadoInicial();"><img src="<? echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
									<td width="8"><img src="<? echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
								</tr>
							</table>     
						</td> 
					</tr> 																						
					<tr>
						<td class="tdConteudoTela" align="center" width="100%">
							<table width="100%" border="0" cellspacing="0" cellpadding="0">
								<tr>
									<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
										<table width="100%" border="0" cellpadding="0" cellspacing="0">
											<tr>
												<td align="center">												

													<!-- INICIO DO FORMULARIO -->
													<form name="frmPesquisaEmpresa" id="frmPesquisaEmpresa" class="formulario">														
														<input type="hidden" name="cddopcao" id="cddopcao" value="P">													
														<label for="cdtppesq">Pesquisar por:</label>														
														<input type="radio" name="cdtppesq" id="nomeEmpresa" checked value="1" class="radio" /> 
														<label for="nomeEmpresa" class="radio">Nome da Empresa</label> 														
														<input type="radio" name="cdtppesq" id="razaoSocial" value="0" class="radio" /> 
														<label for="razaoSocial" class="radio">Raz&atilde;o Social</label>													
																								
														<br /><br />
														<label for="nmdbusca" style="float:left;">Nome a pesquisar:</label>
														<input type="text" name="nmdbusca" id="nmdbusca" class="campo alphanum" style="width:179px;" value=""/>
														
														<label for="botao"></label>
														<input type="image" src="<? echo $UrlImagens; ?>botoes/pesquisar.gif" onClick="buscaEmpresas();return false;">
														
														<br clear="both" />
													</form>												
														<!-- CABEÇALHO DO RESULTADO DA CONSULTA -->
													<div id="divCabecalhoPesquisaEmpresa" class="divCabecalhoPesquisa" style="width:550px">
														<table width="100%" border="0" cellspacing="0" cellpadding="0">
															<thead>
																<tr>
																    <td style="font-size:11px;width:50px">C&oacute;digo</td>  
																	<td style="font-size:11px;width:250px">Empresa</td>
																	<td style="font-size:11px;width:250px">Raz&atilde;o Social</td>
																</tr>
															</thead>
														</table>
													</div>
													<div id="divConteudo" style="height:270px;"></div>
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