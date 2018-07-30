<? 
    /*!
     * FONTE        : historico_tabela.php
     * CRIAÇÃO      : Odirlei Busana(AMcom)
     * DATA CRIAÇÃO : Novembro/2017 
     * OBJETIVO     : Cabecalho tela HISPES
     * --------------
     * ALTERAÇÕES   :
     * --------------
     *
     */	
     
    session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");		
	require_once("../../includes/controla_secao.php");
	
	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	if (!isset($_POST["idpessoa"]))  {
		exibeErro("Parâmetros incorretos.");
	}	
	
    $nrcpfcgc = $_POST["nrcpfcgc"] == "" ? 0 : $_POST["nrcpfcgc"];
    $cdcooper = $_POST["cdcooper"] == "" ? 0 : $_POST["cdcooper"];
    $nrdconta = $_POST["nrdconta"] == "" ? 0 : $_POST["nrdconta"];
    $idseqttl = $_POST["idseqttl"] == "" ? 0 : $_POST["idseqttl"];
    $idpessoa = $_POST["idpessoa"] == "" ? 0 : $_POST["idpessoa"];
    $nmtabela = $_POST["nmtabela"] == "" ? 0 : $_POST["nmtabela"];
    $dtaltera = $_POST["dtaltera"] == "" ? "" : $_POST["dtaltera"];
    
 
    $xml = "<Root>";
    $xml .= " <Dados>";   
    $xml .= "   <nrcpfcgc>".$nrcpfcgc."</nrcpfcgc>";
    $xml .= "   <cdcoptel>".$cdcooper."</cdcoptel>";
    $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
    $xml .= "   <idseqttl>".$idseqttl."</idseqttl>";
    $xml .= "   <idpessoa>".$idpessoa."</idpessoa>";    
    $xml .= "   <nmtabela>".$nmtabela."</nmtabela>";   
    $xml .= "   <dtaltera>".$dtaltera."</dtaltera>";   
    
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "TELA_HISPES", "LISTAR_HIST_TABELA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);

    if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
        $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
        if ($msgErro == "") {
            $msgErro = $xmlObj->roottag->tags[0]->cdata;
        }

        exibeErroNew($msgErro);
        exit();
    }

    $registros = $xmlObj->roottag->tags[0]->tags;

    function exibeErroNew($msgErro) {
        echo 'hideMsgAguardo();';
        echo 'showError("error","' . $msgErro . '","Alerta - Ayllos","desbloqueia()");';
        exit();
    }
 
 
?>

<form name="frmResumo" id="frmResumo" class="formulario">
    <div class="divRegistros divRegistrosHis">
        <table>
            <thead>
                <tr>
                   <th><? echo utf8ToHtml('Data de Operacão'); ?></th>
                   <th><? echo utf8ToHtml('Operacão'); ?></th>
                   <th><? echo utf8ToHtml('Desc. Campo'); ?></th>
                   <th><? echo utf8ToHtml('Valor Ant.'); ?></th>
                   <th><? echo utf8ToHtml('Valor Novo'); ?></th>                   
                   <th><? echo utf8ToHtml('Operador'); ?></th>                   
                 </tr>
            </thead>		
            <tbody>
                <? foreach( $registros as $registro ) {?>
                    <tr>
                        <td><? echo getByTagName($registro->tags,'dhalteracao') ?></td>                        
                        <td><? echo getByTagName($registro->tags,'dstpoperac') ?></td>
                        <td style="width:180px; white-space:pre-wrap;"> <? echo getByTagName($registro->tags,'dscampo' ) ?> </div> </td>
                        <td style="width:180px; word-break:break-all;">
                        
                            <? 
                                $idpessoa_ant = getByTagName($registro->tags,'idpessoa_ant');
                                $nmpessoa_ant = getByTagName($registro->tags,'nmpessoa_ant');
                                $nrcpfcgc_ant = getByTagName($registro->tags,'nrcpfcgc_ant');
                                $tppessoa_ant = getByTagName($registro->tags,'tppessoa_ant');
                                
                                if ($idpessoa_ant != "" ){
                                    ?>
                                      <input type='hidden' id="idpessoa_ant" name="idpessoa_ant" value="<? echo $idpessoa_ant;?>">
                                      <input type='hidden' id="nmpessoa_ant" name="nmpessoa_ant" value="<? echo $nmpessoa_ant;?>">
                                      <input type='hidden' id="nrcpfcgc_ant" name="nrcpfcgc_ant" value="<? echo $nrcpfcgc_ant;?>">
                                      <a class="txtNormalBold" onclick="confirmaHistPessoa('<? echo $idpessoa_ant;?>','<? echo $nrcpfcgc_ant ;?>','<? echo $nmpessoa_ant; ?>','<? echo $tppessoa_ant; ?>')"> 
                                            <? echo getByTagName($registro->tags,'dsvalant'); ?> 
                                      </a>                                     
                                    <?
                                }else{
                                     echo getByTagName($registro->tags,'dsvalant') ;
                                }
                            ?>
                        </td>
                        
                        <td style="width:180px; word-break:break-all;">
                        
                            <? 
                                $idpessoa_nov = getByTagName($registro->tags,'idpessoa_nov');
                                $nmpessoa_nov = getByTagName($registro->tags,'nmpessoa_nov');
                                $nrcpfcgc_nov = getByTagName($registro->tags,'nrcpfcgc_nov');
                                $tppessoa_nov = getByTagName($registro->tags,'tppessoa_nov');
                                
                                if ($idpessoa_nov != "" ){
                                    ?>
                                      <input type='hidden' id="idpessoa_nov" name="idpessoa_nov" value="<? echo $idpessoa_nov;?>">
                                      <input type='hidden' id="nmpessoa_nov" name="nmpessoa_nov" value="<? echo $nmpessoa_nov;?>">
                                      <input type='hidden' id="nrcpfcgc_nov" name="nrcpfcgc_nov" value="<? echo $nrcpfcgc_nov;?>">
                                      <a class="txtNormalBold" onclick="confirmaHistPessoa('<? echo $idpessoa_nov;?>','<? echo $nrcpfcgc_nov ;?>','<? echo $nmpessoa_nov; ?>','<? echo $tppessoa_nov; ?>')"> 
                                            <? echo getByTagName($registro->tags,'dsvalnov'); ?> 
                                      </a>                                     
                                    <?
                                }else{
                                     echo getByTagName($registro->tags,'dsvalnov') ;
                                }
                            ?>
                        </td>
                        
                        <td><? echo getByTagName($registro->tags,'nmoperad') ?> </td>
                    </tr>
                <? } ?>			
            </tbody>
        </table>
    </div>
  
</form>
