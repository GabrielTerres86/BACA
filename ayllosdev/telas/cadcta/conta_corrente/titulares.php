<?
/*!
 * FONTE        : titulares.php
 * CRIAÇÃO      : Gabriel Capoia - DB1 Informatica
 * DATA CRIAÇÃO : 14/05/2010 
 * OBJETIVO     : Mostra tabela de titulares para exclusão dos mesmos na rotina CONTA-CORRENTE na tela de Contas
 *
 * ALTERAÇÕES    : 01/12/2016 - P341-Automatização BACENJUD - Removido passagem do departamento como parametros
 *                              pois a BO não utiliza o mesmo (Renato Darosci)
 */	
?>
 
<?
	session_start();
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require("../../../includes/config.php");	
	require("../../../includes/funcoes.php");
	require("../../../includes/controla_secao.php");
	require("../../../class/xmlfile.php");	
	
	$nrdconta = ($_POST['nrdconta'] == '') ? 0 : $_POST['nrdconta'];
	$idseqttl = ($_POST['idseqttl'] == '') ? 0 : $_POST['idseqttl'];
	
	// Monta o xml de requisição
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0074.p</Bo>';
	$xml .= '		<Proc>busca_titulares</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<idseqttl>'.$idseqttl.'</idseqttl>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObj = getObjectXML($xmlResult);
	
	// Variável que representa o registro
	$titulares = $xmlObj->roottag->tags[0]->tags;	
?>

<table id="tbbens"cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td align="center">		
			<table border="0" cellpadding="0" cellspacing="0" width="500">
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">TITULARES</td>
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
											<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen0"><a href="#" id="linkAba0" onClick=<?php echo "acessaOpcaoAba(".count($opcoesTela).",0,'".$opcoesTela[0]."');"; ?> class="txtNormalBold">Principal</a></td>
																																					
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir0"></td>
											<td width="1"></td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
									<div id="divConteudoOpcao">
									<?/********************************TABELA TITULARES*********************************/?>
										<div class='divRegistros'>
											<table>
												<thead>
													<tr><th><? echo utf8ToHtml('Sequência');?></th>
														<th>Nome do Titular</th></tr>			
												</thead>
												<tbody>
													<? foreach( $titulares as $titular ) {?>
													<tr><td><? echo getByTagName($titular->tags,'idseqttl'); ?></td>				
														<td><? echo getByTagName($titular->tags,'nmextttl'); ?></td></tr>				
													<? } ?>	
												</tbody>
											</table>
										</div>	
									<?/*********************************************************************************/?>	
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
<script type="text/javascript">	
	var divRegistro = $('div.divRegistros');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
	
	divRegistro.css('height','50px');
	
	var ordemInicial = new Array();
	ordemInicial = [[0,0]];
	
	var arrayLargura = new Array();
	arrayLargura[0] = '80px';
	
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'center';
	arrayAlinha[1] = 'left';
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha );
	
	hideMsgAguardo();
	
	// Mensagem de confirmação para exclusão dos titulares
	showConfirmacao(msgconfi,'Confirma&ccedil;&atilde;o - Ayllos','controlaOperacao(\'TE\')','fechaRotina($(\'#divUsoGenerico\'),$(\'#divRotina\'))','sim.gif','nao.gif');
</script>