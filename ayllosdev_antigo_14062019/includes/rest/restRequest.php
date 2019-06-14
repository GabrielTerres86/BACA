<?php

	/************************************************************************
	 Fonte: restRequest.php                                              
	 Autor: Leonardo de Freitas Oliveira - GFT                                                    
	 Data : Maio/2018                   Última alteraçÃo: 
	                                                                  
	 Objetivo  : Classe responsável pela logica de envio de requisições a servidores rest        
	                                                                  	 
	 Alterações: 
	
	************************************************************************/

class RestRequest{
	/*in*/
	private $endPoint;
	private $auth;
	private $method;
	private $headers;
	private $service;
	private $timeout;
	private $params;
	private $ch;
	private $isPost;
	private $fullUrl;
	/*out*/
	private $status;
	private $response;

	public function __construct($endPoint){
		if($endPoint){
				$this->endPoint 	= $endPoint;
		}
		$this->response 	= null;
		$this->status 		= false;
		$this->timeout 		= false;
		$this->isPost 		= false;
		
	}

	// execute
	private function exec(){

		//Iniciar variaveis		 
		$this->headers =  array(
				'Accept: application/json',
				'Host: '.$_SERVER['SERVER_NAME']
			);
		$this->ch  = curl_init();
		$fullUrl = $this->getFullURL();


		//Carregar autenticação
		if($this->auth){
			array_push(
					$this->headers,
					'Authorization: Basic '.$this->auth
				);
		}

		//Carregar cabeçalho para envio de dados
		if ($this->method === "GET"){
			if($this->params){
				$fullUrl = $fullUrl.'?'.http_build_query($this->params);
			}
		} else {
			$data = json_encode($this->params);
			array_push(
					$this->headers,
					'Content-Type: application/json',
					'Content-Length: '.strlen($data)
				);

			curl_setopt($this->ch, CURLOPT_POSTFIELDS, $data);
			curl_setopt($this->ch, CURLOPT_POST, $this->isPost);
		}

		//Carregar cabeçalho
		curl_setopt($this->ch, CURLOPT_URL, $fullUrl);
		curl_setopt($this->ch, CURLOPT_HTTPHEADER, $this->headers);
		curl_setopt($this->ch, CURLOPT_RETURNTRANSFER, true);
		curl_setopt($this->ch, CURLOPT_CUSTOMREQUEST, $this->method);
		if($this->timeout){
			curl_setopt($this->ch, CURLOPT_TIMEOUT, $this->timeout);
		}

		//Executar chamada
		$this->response = curl_exec($this->ch);
		
		//Tratamento da resposta
		if(!$this->response){
			$this->status = false;
			curl_close($this->ch);
			return false;
		}
		else{
			$this->status = curl_getinfo($this->ch, CURLINFO_HTTP_CODE); 
			curl_close($this->ch);
			return true;
		}
		return false;
	}
	
	//methods
	public function get($service){
		$this->setService($service);
		$this->method = "GET";
		return $this->exec();
	}

	public function post($service){
		$this->setService($service);
		$this->method = "POST";
		$this->isPost = true;
		return $this->exec();
	}

	public function delete($service){
		$this->setService($service);
		$this->method = "DELETE";

		return $this->exec();
	}

	public function put($service){
		$this->setService($service);
		$this->method = "PUT";
		return $this->exec();
	}

	//get set
	public function getStringResponse(){
		return $this->response;
	}

	public function getArrayResponse(){
		return json_decode($this->response);
	}

	public function setService($service){
		if($service){$this->service = $service;}
		return $this->service;
	}

	public function getStatus(){
		return $this->status;
	}
	public function getParams(){
		return $this->params;
	}

	public function setFullURL($fullUrl){
		$this->fullUrl = $fullUrl;
	}

	public function getFullURL(){
		if($this->fullUrl){
			return $this->fullUrl;
		}
		$endpoint = rtrim($this->endPoint, "/");
		$service  = ltrim($this->service, "/");
		return $endpoint."/".$service;
	}

	public function setHeaders(array $arr){
		$this->headers = $arr;
	}

	public function addHeader($header){
		$this->headers[] = $header;
	}

	public function getHeaders(){
		return $this->headers;
	}

	public function setTimeout($timeout){
		$this->timeout = $timeout;
	}

	public function setAuth($auth){
		$this->auth = $auth;
	}

	public function setParams(array $params){
		//$this->params = http_build_query($params);
		$this->params = $params;
		$this->headers[] = 'Content-Length: '.strlen($this->params);
	}

}