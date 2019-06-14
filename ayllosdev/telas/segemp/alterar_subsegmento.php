<?php
/*!
 * FONTE        : alterar_subsegmento.php                    Última alteração: 
 * CRIAÇÃO      : Douglas Pagel (AMcom)
 * DATA CRIAÇÃO : Fevereiro/2019 
 * OBJETIVO     : Rotina para manter os subsegmentos de simulação
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
  
	$cdsubsegmento = (isset($_POST["cdsubsegmento"])) ? $_POST["cdsubsegmento"] : 0;
	$codigo_segmento = (isset($_POST["codigo_segmento"])) ? $_POST["codigo_segmento"] : 0;
	$dssubsegmento = (isset($_POST["dssubsegmento"])) ? $_POST["dssubsegmento"] : 0;
	$cdlinha_credito = (isset($_POST["cdlinha_credito"])) ? $_POST["cdlinha_credito"] : 0;
	$cdfinalidade = (isset($_POST["cdfinalidade"])) ? $_POST["cdfinalidade"] : 0;
	$flggarantia = (isset($_POST["flggarantia"])) ? $_POST["flggarantia"] : 0;
	$tpgarantia = (isset($_POST["tpgarantia"])) ? $_POST["tpgarantia"] : 0;
	$pemax_autorizado = (isset($_POST["pemax_autorizad"])) ? $_POST["pemax_autorizad"] : 0;
	$peexcedente = (isset($_POST["peexcedente"])) ? $_POST["peexcedente"] : 0;
	$vlmax_proposta = (isset($_POST["vlmax_proposta"])) ? $_POST["vlmax_proposta"] : 0;
  
  
	validaDados();
  
	// Monta o xml de requisição para o segmento		
	$xml = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";
	$xml .= "     <idsegmento>".$codigo_segmento."</idsegmento>";
	$xml .= "     <idsubsegmento>".$cdsubsegmento."</idsubsegmento>";
	$xml .= "     <dssubsegmento>".$dssubsegmento."</dssubsegmento>";	
	$xml .= "     <cdlinha_credito>".$cdlinha_credito."</cdlinha_credito>";
	$xml .= "     <cdfinalidade>".$cdfinalidade."</cdfinalidade>";
	$xml .= "     <flggarantia>".$flggarantia."</flggarantia>";
	$xml .= "     <tpgarantia>".$tpgarantia."</tpgarantia>";
	$xml .= "     <pemax_autorizado>".$pemax_autorizado."</pemax_autorizado>";
	$xml .= "     <peexcedente>".$peexcedente."</peexcedente>";
	$xml .= "     <vlmax_proposta>".$vlmax_proposta."</vlmax_proposta>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";
	
	// Executa script para envio do XML	
	$xmlResult = mensageria($xml, "TELA_SEGEMP", "SEGEMP_ALTERA_SUB", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Aimaro','$(\'#btVoltarSub\',\'#divRotina\').focus();',false);		
					
	}else {
     exibirErro('inform','Subsegmento alterado com sucesso.','Alerta - Aimaro','$(\'#btVoltarSub\',\'#divRotina\').click();', false);      
  }
 
    function validaDados(){
			
		IF($GLOBALS["codigo_segmento"] == 0 ){ 
			exibirErro('error','Segmento inválido.','Alerta - Aimaro','formataFormularioSubsegmento();focaCampoErro(\'codigo_segmento\',\'frmConsulta\');',false);
		}
   
		IF($GLOBALS["dssubsegmento"] == '' ){ 
			exibirErro('error','Descrição inválida.','Alerta - Aimaro','formataFormularioSubsegmento();focaCampoErro(\'dssubsegmento\',\'divAbaSubsegmento\');',false);
		}
    
		IF($GLOBALS["cdsubsegmento"] == 0){ 
				exibirErro('error','Código de subsegmento inválido.','Alerta - Aimaro','formataFormularioSubsegmento();focaCampoErro(\'qtsimulacoes_padrao\',\'divAbaSubsegmento\');',false);
			}
		
		IF($GLOBALS["cdlinha_credito"] == 0){ 
				exibirErro('error','Linha de Crédito inválida.','Alerta - Aimaro','formataFormularioSubsegmento();focaCampoErro(\'cdlcremp\',\'divAbaSubsegmento\');',false);
			}
		IF($GLOBALS["cdfinalidade"] == 0){ 
				exibirErro('error','Finalidade de Crédito inválida.','Alerta - Aimaro','formataFormularioSubsegmento();focaCampoErro(\'cdfinemp\',\'divAbaSubsegmento\');',false);
			}
			
	}	
  
 ?>
