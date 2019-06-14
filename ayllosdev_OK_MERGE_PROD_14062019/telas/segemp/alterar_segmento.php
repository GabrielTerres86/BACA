<?php
/*!
 * FONTE        : alterar_segmento.php                    Última alteração: 
 * CRIAÇÃO      : Douglas Pagel (AMcom)
 * DATA CRIAÇÃO : Fevereiro/2019 
 * OBJETIVO     : Rotina para manter os segmentos de simulação
 * --------------
 * ALTERAÇÕES   :  
 */
?>

<?php	
 
  session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	// Carrega permissões do operador
	require_once('../../includes/carrega_permissoes.php');		
	
	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
	
		exibirErro('error',$msgError,'Alerta - Aimaro','',false);
	}
  
  $codigo_segmento		= (isset($_POST["cdsegmento"])) ? $_POST["cdsegmento"] : 0;
  $dssegmento           = utf8_decode((isset($_POST["dssegmento"])) ? $_POST["dssegmento"] : '');
  $qtsimulacoes_padrao  = (isset($_POST["qtsimulacoes_padrao"])) ? $_POST["qtsimulacoes_padrao"] : 0;
  $limite_max_proposta  = (isset($_POST["limite_max_proposta"])) ? $_POST["limite_max_proposta"] : 0;
  $variacao_parc        = (isset($_POST["variacao_parc"])) ? $_POST["variacao_parc"] : 0;
  $nrintervalo_proposta = (isset($_POST["nrintervalo_proposta"])) ? $_POST["nrintervalo_proposta"] : 0;
  $descricao_segmento   = utf8_decode((isset($_POST["descricao_segmento"])) ? $_POST["descricao_segmento"] : '');
  $qtdias_validade		= (isset($_POST["qtdias_validade"])) ? $_POST["qtdias_validade"] : 0;
  $permis_pf            = (isset($_POST["permis_pf"])) ? $_POST["permis_pf"] : 0;
  $permis_pj            = (isset($_POST["permis_pj"])) ? $_POST["permis_pj"] : 0;
  $canal_3_tp           = (isset($_POST["canal_3_tp"])) ? $_POST["canal_3_tp"] : 0;
  $canal_3_vlr          = (isset($_POST["canal_3_vlr"])) ? $_POST["canal_3_vlr"] : 0;
  $canal_4_tp           = (isset($_POST["canal_4_tp"])) ? $_POST["canal_4_tp"] : 0;
  $canal_4_vlr          = (isset($_POST["canal_4_vlr"])) ? $_POST["canal_4_vlr"] : 0;
  $canal_10_tp          = (isset($_POST["canal_10_tp"])) ? $_POST["canal_10_tp"] : 0;
  $canal_10_vlr         = (isset($_POST["canal_10_vlr"])) ? $_POST["canal_10_vlr"] : 0;
  
  $permis_pf_b = ($permis_pf == 'true') ? 1 : 0;
  $permis_pj_b = ($permis_pj == 'true') ? 1 : 0;
  
  $descricao_segmento = '<![CDATA[' . $descricao_segmento . ']]>';	
  $dssegmento = '<![CDATA[' . $dssegmento . ']]>';
  

  validaDados();
  
  // Monta o xml de requisição para o segmento		
  $xml  	= "";
  $xml 	   .= "<Root>";
  $xml 	   .= "  <Dados>";
  $xml 	   .= "     <idsegmento>".$codigo_segmento."</idsegmento>";
  $xml 	   .= "     <dssegmento>".$dssegmento."</dssegmento>";
  $xml 	   .= "     <qtsimulacoes_padrao>".$qtsimulacoes_padrao."</qtsimulacoes_padrao>";
  $xml 	   .= "     <nrvariacao_parc>".$variacao_parc."</nrvariacao_parc>";
  $xml 	   .= "     <nrintervalo_proposta>".$nrintervalo_proposta."</nrintervalo_proposta>";
  $xml 	   .= "     <nrmax_proposta>".$limite_max_proposta."</nrmax_proposta>";
  $xml 	   .= "     <dssegmento_detalhada>".$descricao_segmento."</dssegmento_detalhada>";
  $xml 	   .= "     <qtdias_validade>".$qtdias_validade."</qtdias_validade>";
  $xml 	   .= "     <perm_pessoa_fisica>".$permis_pf_b."</perm_pessoa_fisica>";
  $xml 	   .= "     <perm_pessoa_juridica>".$permis_pj_b."</perm_pessoa_juridica>";
  $xml 	   .= "  </Dados>";
  $xml 	   .= "</Root>";
  
	
	// Executa script para envio do XML	
	$xmlResult = mensageria($xml, "TELA_SEGEMP", "SEGEMP_ALTERA_SEG", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Aimaro','$(\'#btVoltar\',\'#divBotoesConsulta\').focus();',false);		
					
	}else {
     exibirErro('inform','Segmento alterado com sucesso.','Alerta - Aimaro','$(\'#btVoltar\',\'#divBotoesConsulta\').click();', false);      
  }
 
    //Monta o array com as permissoes para o loop
    
    $permis_canais = array(0 => array('cdcanal' => 3,
	  								  'tppermi' => $canal_3_tp,
	  								  'vlrmaxi' => $canal_3_vlr), 
	  					   1 => array('cdcanal' => 10,
								      'tppermi' => $canal_10_tp,
									  'vlrmaxi' => $canal_10_vlr)
						  );
						
    	
    foreach ($permis_canais as $permis) {
	   
		// Monta o xml de requisição para as permissoes
		$xml  	= "";
		$xml 	   .= "<Root>";
		$xml 	   .= "  <Dados>";
		$xml 	   .= "     <idsegmento>".$codigo_segmento."</idsegmento>";
		$xml 	   .= "     <cdcanal>".$permis['cdcanal']."</cdcanal>";
		$xml 	   .= "     <tppermissao>".$permis['tppermi']."</tppermissao>";
		$xml 	   .= "     <vlmax_autorizado>".$permis['vlrmaxi']."</vlmax_autorizado>";
		$xml 	   .= "  </Dados>";
		$xml 	   .= "</Root>";

		// Executa script para envio do XML	
		$xmlResult = mensageria($xml, "TELA_SEGEMP", "SEGEMP_ALTERA_PERM", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObj = getObjectXML($xmlResult);

		// Se ocorrer um erro, mostra crítica
		if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {

			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
			exibirErro('error',$msgErro,'Alerta - Aimaro','$(\'#btVoltar\',\'#divBotoesConsulta\').focus();',false);		
						
		}else {
		 exibirErro('inform','Segmento alterado com sucesso.','Alerta - Aimaro','$(\'#btVoltar\',\'#divBotoesConsulta\').click();', false);      
		}
	}	
		
	function validaDados(){
			
		IF($GLOBALS["codigo_segmento"] == 0 ){ 
			exibirErro('error','Segmento inv&aacute;lido.','Alerta - Aimaro','formataFormularioConsulta();focaCampoErro(\'codigo_segmento\',\'frmConsulta\');',false);
		}
   
		IF($GLOBALS["dssegmento"] == '' ){ 
			exibirErro('error','Descri&ccedil;&atilde;o do segmento inv&aacute;lido.','Alerta - Aimaro','formataFormularioConsulta();focaCampoErro(\'dssegmento\',\'frmConsulta\');',false);
		}
    
		IF($GLOBALS["qtsimulacoes_padrao"] == 0 OR $GLOBALS["qtsimulacoes_padrao"] > 6){ 
				exibirErro('error','Quantidade de parcelas inválida. O valor deve estar entre 1 e 6.','Alerta - Aimaro','formataFormularioConsulta();focaCampoErro(\'qtsimulacoes_padrao\',\'frmConsulta\');',false);
			}
		
		IF($GLOBALS["limite_max_proposta"] == 0){ 
				exibirErro('error','Limite máximo da proposta inválido','Alerta - Aimaro','formataFormularioConsulta();focaCampoErro(\'limite_max_proposta\',\'frmConsulta\');',false);
			}
		IF($GLOBALS["variacao_parc"] == 0 OR $GLOBALS["variacao_parc"] > 12){ 
				exibirErro('error','Variação de parcelas inválida. O valor deve estar entre 1 e 12.','Alerta - Aimaro','formataFormularioConsulta();focaCampoErro(\'variacao_parc\',\'frmConsulta\');',false);
			}
			
		IF($GLOBALS["nrintervalo_proposta"] == 0){ 
				exibirErro('error','Intervalo inválido','Alerta - Aimaro','formataFormularioConsulta();focaCampoErro(\'nrintervalo_proposta\',\'frmConsulta\');',false);
			}
	   
		IF($GLOBALS["descricao_segmento"] == ''){ 
				exibirErro('error','Descrição inválida.','Alerta - Aimaro','formataFormularioConsulta();focaCampoErro(\'descricao_segmento\',\'frmConsulta\');',false);
			}
		
	    IF($GLOBALS["canal_3_tp"] > 0 && $GLOBALS["canal_3_vlr"] < 0.01){ 
				exibirErro('error','Valor deve ser maior que zero para esta permissão.','Alerta - Aimaro','formataFormularioConsulta();focaCampoErro(\'canal_3_vlr\',\'frmConsulta\');',false);
			}
			
		IF($GLOBALS["canal_4_tp"] > 0 && $GLOBALS["canal_4_vlr"] < 0.01){ 
				exibirErro('error','Valor deve ser maior que zero para esta permissão.','Alerta - Aimaro','formataFormularioConsulta();focaCampoErro(\'canal_3_vlr\',\'frmConsulta\');',false);
			}
			
		IF($GLOBALS["canal_10_tp"] > 0 && $GLOBALS["canal_10_vlr"] < 0.01){ 
				exibirErro('error','Valor deve ser maior que zero para esta permissão.','Alerta - Aimaro','formataFormularioConsulta();focaCampoErro(\'canal_3_vlr\',\'frmConsulta\');',false);
			}  
		
		IF($GLOBALS["permis_pj_b"] == 0 && $GLOBALS["permis_pf_b"] == 0){ 
				exibirErro('error','Um tipo de pessoa deve ser selecionado para as permissões.','Alerta - Aimaro','formataFormularioConsulta();focaCampoErro(\'tipo_pessoa_1\',\'frmConsulta\');',false);
			}  
				
		
    
	}	
  
 ?>
