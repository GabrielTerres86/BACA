<? 
/*!
 * FONTE        : consulta_comissao.php
 * CRIAÇÃO      : Diego Simas         
 * DATA CRIAÇÃO : 01/05/2018
 * OBJETIVO     : Rotina para consultar comissão
 * --------------
 * ALTERAÇÕES   : 
 * -------------- 
 */
?> 

<?	
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	// Inicializa
	$procedure 		= '';
	$retornoAposErro= '';
	
	echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';	
	
	// Recebe a operação que está sendo realizada
	$cdcomissao = (isset($_POST['cdcomissao'])) ? $_POST['cdcomissao'] : 0  ;	
    $cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : 0  ;	
	
    $retornoAposErro = 'focaCampoErro(\'cdcomissao\', \'frmComissao\');';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
    $xml  = "<Root>";
    $xml .= " <Dados>";
    $xml .= "  <idcomissao>".$cdcomissao."</idcomissao>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "TELA_PARCDC", "BUSCAR_COMISSAO_CDC", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObjeto = getObjectXML($xmlResult);

    if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
        $msgError = utf8_encode($xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata);
        echo 'showError("error","'.$msgError.'","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));controlaCamposInclusao();");';				                
    }else{    
        $comissao = $xmlObjeto->roottag->tags[0]->tags[0]->tags; 

        $cdcomissao = getByTagName($comissao, 'idcomissao');	 
        $dscomissao = getByTagName($comissao, 'nmcomissao');	 
        $tpcomissao = getByTagName($comissao, 'tpcomissao');
        $flgativo = getByTagName($comissao, 'flgativo');	 
        $dtcriacao = getByTagName($comissao, 'dtinsori');	 
        $dtalteracao = getByTagName($comissao, 'dtrefaut');	 

        echo "$('#dscomissao','#frmComissao').val('$dscomissao');";
        echo "$('#tpvalor','#frmComissao').val('$tpcomissao');";
        
        if($flgativo == 1){
            echo "$('#flgativo','#frmComissao').prop('checked', true);";
        }else{
            echo "$('#flgativo','#frmComissao').prop('checked', false);";
        }
        
        echo "$('#dtcriacao','#frmComissao').val('$dtcriacao');";
        echo "$('#dtalteracao','#frmComissao').val('$dtalteracao');";

        switch ($cddopcao) {
            case 'A':
                echo "trocaBotao('Alterar');";
                echo "$('#cdcomissao','#frmComissao').desabilitaCampo();";
                echo "$('#dscomissao','#frmComissao').desabilitaCampo();";
                echo "$('#tpvalor','#frmComissao').habilitaCampo();";
                echo "$('#flgativo','#frmComissao').habilitaCampo();";
                echo "$('#dtcriacao','#frmComissao').desabilitaCampo();";
                echo "$('#dtalteracao','#frmComissao').desabilitaCampo();";
                break;      

            case 'I':
                echo "trocaBotao('');";
                echo "$('#cdcomissao','#frmComissao').desabilitaCampo();";
                echo "$('#dscomissao','#frmComissao').desabilitaCampo();";
                echo "$('#tpvalor','#frmComissao').desabilitaCampo();";
                echo "$('#flgativo','#frmComissao').desabilitaCampo();";
                echo "$('#dtcriacao','#frmComissao').desabilitaCampo();";
                echo "$('#dtalteracao','#frmComissao').desabilitaCampo();";
                break;

            case 'E':
                echo "trocaBotao('Excluir');";
                echo "$('#cdcomissao','#frmComissao').desabilitaCampo();";
                echo "$('#dscomissao','#frmComissao').desabilitaCampo();";
                echo "$('#tpvalor','#frmComissao').desabilitaCampo();";
                echo "$('#flgativo','#frmComissao').desabilitaCampo();";
                echo "$('#dtcriacao','#frmComissao').desabilitaCampo();";
                echo "$('#dtalteracao','#frmComissao').desabilitaCampo();";
                break;

            case 'C':
                echo "trocaBotao('');";
                echo "$('#cdcomissao','#frmComissao').desabilitaCampo();";
                echo "$('#dscomissao','#frmComissao').desabilitaCampo();";
                echo "$('#tpvalor','#frmComissao').desabilitaCampo();";
                echo "$('#flgativo','#frmComissao').desabilitaCampo();";
                echo "$('#dtcriacao','#frmComissao').desabilitaCampo();";
                echo "$('#dtalteracao','#frmComissao').desabilitaCampo();";
                break;    

            default:
                # code...
                break;

        }                     
        
        echo "carregaDetalhamento();";	
    }
			
?>
