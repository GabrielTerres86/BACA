<?php

	/*****************************************************************************************************
	  Fonte: solicita_consulta_beneficiario.php                                               
	  Autor: Adriano                                                  
	  Data : Maio/2013                       						Última Alteração: 26/06/2017
	                                                                   
	  Objetivo  : Solicita consulta para o beneficiario em questão.
	                                                                 
	  Alterações: 10/03/2015 - Ajuste referente ao Histórico cadastral
						      (Adriano - Softdesk 261226).	
                01/12/2015 - Adicionado aviso caso comprovacao de vida esteja vencido
                             Projeto 255 INSS (Lombardi).
	                                                                  
				26/06/2017 - Ajuste para rotina ser chamada através da tela ATENDA > Produtos (Jonata - RKAM - P364).
	                                                                  
	*****************************************************************************************************/


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
	require_once('../../includes/carrega_permissoes.php');	
	
	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
		
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
	
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	$nrcpfcgc = (isset($_POST["nrcpfcgc"])) ? $_POST["nrcpfcgc"] : 0;
	$nrrecben = (isset($_POST["nrrecben"])) ? $_POST["nrrecben"] : 0;
	$executandoProdutos = $_POST['executandoProdutos'];
			
	validaDados();
	
	$xmlSolicitaConsultaBeneficiario  = "";
	$xmlSolicitaConsultaBeneficiario .= "<Root>";
	$xmlSolicitaConsultaBeneficiario .= "   <Dados>";
	$xmlSolicitaConsultaBeneficiario .= "	   <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";	
	$xmlSolicitaConsultaBeneficiario .= "	   <cddopcao>".$cddopcao."</cddopcao>";
	$xmlSolicitaConsultaBeneficiario .= "	   <nrcpfcgc>".$nrcpfcgc."</nrcpfcgc>";
	$xmlSolicitaConsultaBeneficiario .= "      <nrrecben>".$nrrecben."</nrrecben>";
	$xmlSolicitaConsultaBeneficiario .= "   </Dados>";
	$xmlSolicitaConsultaBeneficiario .= "</Root>";
		
	// Executa script para envio do XML	
	$xmlResult = mensageria($xmlSolicitaConsultaBeneficiario, "INSS", "CONSINSS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	$xmlObjSolicitaConsultaBeneficiario = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjSolicitaConsultaBeneficiario->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro  = $xmlObjSolicitaConsultaBeneficiario->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo = $xmlObjSolicitaConsultaBeneficiario->roottag->tags[0]->attributes["NMDCAMPO"];	
		
		if(empty ($nmdcampo)){ 
			$nmdcampo = "nrrecben";
		}
				 
		exibirErro('error',$msgErro,'Alerta - Ayllos','$(\'input\',\'#divBeneficio\').removeClass(\'campoErro\');unblockBackground(); $(\'#'.$nmdcampo.'\',\'#divBeneficio\').habilitaCampo(); focaCampoErro(\''.$nmdcampo.'\',\'divBeneficio\');',false);		
							
	}   
		
	$registros = $xmlObjSolicitaConsultaBeneficiario->roottag->tags;
	$rotinas = $glbvars["rotinasTela"];	
	
	if($cddopcao == 'C'){	
	
		foreach( $registros as $registro ) { 
			
			include('form_consulta.php');?>
						
			<script type="text/javascript">
				
				formataConsulta();
						
				$('#divDetalhes').css('display','block');
				$('#frmConsulta').css('display','block');
				$('#divBotoesConsulta').css('display','block');
				$('#divBotoesConta').css('display','none');
				$('input','#divBeneficio').desabilitaCampo();
				$('#btVoltar','#divBotoesConsulta').focus();
        alertaProvaDeVida('<? echo getByTagName($registro->tags,'msgpvida')?>');
										
			</script>	
		
		<?}
	
	}else if($cddopcao == 'D'){
			
			foreach( $registros as $registro ) { 
			
				include('form_demonstrativo.php');?>
				
				<script type="text/javascript">
				
					formataDemonstrativo('<?echo $cddopcao?>');
					$('#divDetalhes').css('display','block');
					$('#frmDemonstrativo').css('display','block');
					$('#dtvalida','#frmDemonstrativo').focus();
					$('#divBotoesDemonstrativo').css('display','block');
					$('#divBotoesConta').css('display','none');
					$('input','#divBeneficio').desabilitaCampo();					
          alertaProvaDeVida('<? echo getByTagName($registro->tags,'msgpvida')?>');			
											
				</script>	
		
			<?}
			
	}else if($cddopcao == 'T'){
	
			/*Se encontrou o beneficio em questão então, trata-se de troca de conta
			  entre cooperativas.*/
			if(count($registros) > 0){
			
				foreach( $registros as $registro ) { 
				
					include('form_troca_domicilio.php');
				}?>
					
				<script type="text/javascript">
					
					formataTrocaDomicilio('<?echo $cddopcao?>');
					
					$('#divDetalhes').css('display','block');
					$('#frmTrocaDomicilio').css('display','block');
					$('#nrdconta','#frmTrocaDomicilio').focus();
					$('#divBotoesTrocaDomicilio').css('display','block');
					$('#btConcluirTrocaDomicilio','#divBotoesTrocaDomicilio').show();
					$('#btConcluirTrocaOpCoop','#divBotoesTrocaDomicilio').hide();
					$('#divBotoesConta').css('display','none');
					$('input','#divBeneficio').desabilitaCampo();
          alertaProvaDeVida('<? echo getByTagName($registro->tags,'msgpvida')?>');
					
											
				</script>	
		
				<?
				
			}else{ /*Como não encontrou o beneficio em questão, trata-se de troca de domicilio 
				     (Inclusão).*/
			
				include('form_troca_domicilio.php');
			
				?>
						
				<script type="text/javascript">
				
					formataTrocaDomicilio('<?echo $cddopcao?>');
					inclusao = true;
					$('#divDetalhes').css('display','block');
					$('#frmTrocaDomicilio').css('display','block');
					$('#orgbenef','#frmTrocaDomicilio').val('Outra instituição');
					$('#nrdconta','#frmTrocaDomicilio').focus();
					$('#divBotoesTrocaDomicilio').css('display','block');
					$('#btConcluirTrocaOpCoop','#divBotoesTrocaDomicilio').hide();
					$('#btConcluirTrocaDomicilio','#divBotoesTrocaDomicilio').show();
					$('#divBotoesConta').css('display','none');
					$('input','#divBeneficio').desabilitaCampo();					
          alertaProvaDeVida('<? echo getByTagName($registro->tags,'msgpvida')?>');
											
				</script>	
		
				<?
			}
			
	}
	
	function validaDados(){
				
		//Beneficio
		if ( $GLOBALS["nrrecben"] == 0  ){ 
			exibirErro('error','O campo NB n&atilde;o foi preenchido!','Alerta - Ayllos','$(\'#nrrecben\',\'#divBeneficio\').habilitaCampo();focaCampoErro(\'nrrecben\',\'divBeneficio\');',false);
		}				
			
	}
			 
?>



				


				

