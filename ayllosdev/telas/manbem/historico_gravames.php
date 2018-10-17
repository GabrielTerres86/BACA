<?
/*!
 * FONTE        : historico_gravames.php
 * CRIAÇÃO      : Christian Grauppe - Envolti
 * DATA CRIAÇÃO : 19/09/2018 
 * OBJETIVO     : Tabela que apresenta os detalhes do GRAVAMES do bem
 */
?>
 
<?
	session_start();
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../../includes/config.php");
	require_once("../../../../includes/funcoes.php");
//	require_once('../../../../includes/controla_secao.php');
	require_once('../../../../class/xmlfile.php');
	isPostMethod();

	//$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
	$nrctrpro = (isset($_POST['nrctrpro'])) ? $_POST['nrctrpro'] : 0;
	$dschassi = (isset($_POST['dschassi'])) ? $_POST['dschassi'] : '';
	$nrregist = 1000;//(isset($_POST["nrregist"])) ? $_POST["nrregist"] : 15;
	$nriniseq = (isset($_POST["nriniseq"])) ? $_POST["nriniseq"] : 1;

	if ($nrctrpro.length > 0) {

		/* / Monta o xml de requisição
		$xml  = '';
		$xml .= '<Root>';
		$xml .= '	<Dados>';
		$xml .= '       <cdcooper>'.$cdcooper.'</cdcooper>';
		$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
		$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
		$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
		$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
		$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
		$xml .= '		<cdempres>'.$cdempres.'</cdempres>';
		$xml .= '		<nrseqpag>'.$nrseqpag.'</nrseqpag>';
		$xml .= '	</Dados>';
		$xml .= '</Root>'; */

		// Montar o xml de Requisicao
		$xml .= "<Root>";
		$xml .= "	<Dados>";
		$xml .= "		<cddopcao>C</cddopcao>";  
		$xml .= "		<tparquiv>TODAS</tparquiv>";
		$xml .= "		<cdcoptel>".$glbvars["cdcooper"]."</cdcoptel>";			
		$xml .= "		<nrseqlot>0</nrseqlot>";
		$xml .= "		<dtrefere/>";
		$xml .= "		<dtrefate/>";
		$xml .= "		<cdagenci>0</cdagenci>";
		$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
		$xml .= "		<nrctrpro>".$nrctrpro."</nrctrpro>";
		$xml .= "		<flcritic>N</flcritic>"; 
		$xml .= "		<tipsaida>TELA</tipsaida>";
		$xml .= "		<dschassi>".$dschassi."</dschassi>";
		$xml .= "		<nrregist>".$nrregist."</nrregist>";	
		$xml .= "		<nriniseq>".$nriniseq."</nriniseq>";
		$xml .= "	</Dados>";
		$xml .= "</Root>";
		
		//var_dump($xml); die;

		// Executa script para envio do XML e cria objeto para classe de tratamento de XML
		$xmlResult = mensageria($xml
				   ,"GRVM0001"
				   ,"REL670"
				   ,$glbvars["cdcooper"]
				   ,$glbvars["cdagenci"]
				   ,$glbvars["nrdcaixa"]
				   ,$glbvars["idorigem"]
				   ,$glbvars["cdoperad"]
				   ,"</Root>");

		$xmlObjeto = getObjectXML($xmlResult);

		// Se ocorrer um erro, mostra mensagem
		if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
			$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
			exibirErro('error',$msgErro,'Alerta - Aimaro',$retornoAposErro);
		}

		$detalhesGrav = $xmlObjeto->roottag->tags[0]->tags;//->roottag->tags;
		$qtregist  = count($detalhesGrav);

	}
?>
<script type="text/javascript" src="../../../../scripts/funcoes.js"></script>

<table id="tbdetgra"cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td align="center">		
			<table border="0" cellpadding="0" cellspacing="0" width="100%">
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">HIST&Oacute;RICO DE GRAVAMES</td>
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
								<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
									<div id="divConteudoOpcao">
										<?
										include("tabela_historico_gravames.php");
										?>
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