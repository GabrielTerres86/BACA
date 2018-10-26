<?
/*!
 * FONTE        : limcrd.php
 * CRIAÇÃO      : Amasonas Borges Vieira Jr (Supero)
 * DATA CRIAÇÃO : 04/2018
 * OBJETIVO     : Inserir ou editar 
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */
    session_start();
    require_once('../../includes/config.php');
    require_once('../../includes/funcoes.php');
    require_once('../../includes/controla_secao.php');
    require_once('../../class/xmlfile.php');
    require_once('supfn.php');
    isPostMethod();
    
    function formatValue($value){
       $result =  str_replace(".","",$value);
       $result =  str_replace(",",".",$result);
       return $result;
    }

    $cdadmcrd = isset($_POST['cdadmcrd'])? $_POST['cdadmcrd'] : "";
    $tplimcrd = $_POST['tplimcrd'];
    $vllimite_min = isset($_POST['vllimite_min'])? formatValue($_POST['vllimite_min']) : "0";
    $vllimite_max = isset($_POST['vllimite_max'])? formatValue($_POST['vllimite_max']) : "0";
    $vllimite = isset($_POST['vllimite'])?formatValue($_POST['vllimite']) : "0";
    $cdlimcrd = isset($_POST['cdlimcrd'])? $_POST['cdlimcrd'] : "";
    $nrctamae = isset($_POST['nrctamae'])? $_POST['nrctamae'] : "";
    $insittab = isset($_POST['insittab'])? $_POST['insittab'] : "";
    $tpcartao = isset($_POST['tpcartao'])? $_POST['tpcartao'] : "";
    $dddebito = isset($_POST['dddebito'])? $_POST['dddebito'] : "";
    $tpproces = isset($_POST['tpproces'])? $_POST['tpproces'] : "A";
    $cecred = $cdadmcrd > 9 && $cdadmcrd < 81;
    if($tpproces == "A"){
        if($cecred  ){
            if(is_null($vllimite_min)){
                echo "success = false; message='".utf8ToHtml("Por favor preencha o valor de limite mínimo.")."'";
                return;
            }
            if($vllimite_max == 0){
                echo "success = false; message='".utf8ToHtml("Por favor preencha o valor de limite máximo.")."'";
                return;
            }        
            if(floatval($vllimite_min) > floatval($vllimite_max)){
                echo "success = false; message='".utf8ToHtml("Valor de limite mínimo maior que o máximo.")."'";
                return;
            }

        }else{
            if($vllimite == 0){
                echo "success = false; message='".utf8ToHtml("Por favor preencha o valor de limite.")."'";
                return;
            }
        }
        if(strlen($dddebito) < 1){
            echo "success = false; message='".utf8ToHtml("Por favor, selecione pelo menos um dia para vencimento.")."'";
            return;
        }
    }


    $xml .= "<Root>";
    $xml .= " <Dados>";
    $xml .= "<cdcooper>". $glbvars["cdcooper"] ."</cdcooper>"; 
    $xml .= "<cdadmcrd>". $cdadmcrd."</cdadmcrd>"; 
    $xml .= "<tplimcrd>". $tplimcrd."</tplimcrd>";
    $xml .= "<vllimite_min>".$vllimite_min."</vllimite_min>"; 
    $xml .= "<vllimite_max>".$vllimite_max."</vllimite_max>"; 
    $xml .= "<vllimite>".$vllimite."</vllimite>";         
    $xml .= "<cdlimcrd>".$cdlimcrd."</cdlimcrd>"; 
    $xml .= "<nrctamae>".$nrctamae."</nrctamae>"; 
    $xml .= "<insittab>".$insittab."</insittab>"; 
    $xml .= "<tpcartao>".$tpcartao."</tpcartao>";
    $xml .= "<dddebito>".$dddebito."</dddebito>";
    $xml .= "<tpproces>".$tpproces."</tpproces>"; 
    $xml .= " </Dados>";
    $xml .= "</Root>";

    
    $xmlResult = mensageria($xml, "TELA_LIMCRD", "SALVA_LIMCRD", $glbvars["cdcooper"], $glbvars["cdpactra"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $obj = simplexml_load_string($xmlResult);
    echo "/* req: $xml \n resp: $xmlResult*/";
    echo "hideMsgAguardo();";
    if(isset($obj->Erro->Registro->dscritic)){
       echo "success = false;"; 
       exibirErro('error',preg_replace( "/\r|\n/", "<br>", utf8ToHtml($obj->Erro->Registro->cdcritic." ".$obj->Erro->Registro->dscritic)),'Alerta - Aimaro',$funcaoAposErro,false);
    }else{
		$status = str_replace("Ã§","ç",$obj->Dados->status);
        echo "success = true;message ='".utf8ToHtml($status)."'";
    }
	echo "/* nmdeacao: \n enviado \n $xml   \n recebido \n $xmlResult \n */";
    //echo "$xmlResult";
?>