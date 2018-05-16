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
	private $method;
	private $headers;
	private $service;
	private $timeout;
	private $params;
	private $ch;
	private $isPost;
	/*out*/
	private $status;
	private $response;

	public function __construct($endPoint){
		$this->endPoint 	= $endPoint;
		$this->response 	= null;
		$this->status 		= false;
		$this->timeout 		= false;
		$this->isPost 		= false;
		
	}

	private function exec(){

		//Iniciar variaveis		 
		$this->headers =  array(
				'Accept: application/json',
				'Host: '.$_SERVER['SERVER_NAME']
			);
		$this->ch  = curl_init();
		

		//Carregar cabeçalho para envio de dados
		if ($this->method !== "GET"){

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
		curl_setopt($this->ch, CURLOPT_URL, $this->getFullURL());
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
	
	public function getFullURL(){
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

	public function setParams(array $params){
		//$this->params = http_build_query($params);
		$this->params = $params;
		$this->headers[] = 'Content-Length: '.strlen($this->params);
	}

	public function get($service){
		$this->service = $service;
		$this->method = "GET";
		return $this->exec();
	}

	public function post($service){
		$this->service = $service;
		$this->method = "POST";
		$this->isPost = true;
		return $this->exec();
	}

	public function delete($service){
		$this->service = $service;
		$this->method = "DELETE";

		return $this->exec();
	}

	public function put($service){
		$this->service = $service;
		$this->method = "PUT";
		return $this->exec();
	}

	public function getStringResponse(){
		return $this->response;
	}

	public function getArrayResponse(){
		return json_decode($this->response);
	}

	public function getStatus(){
		return $this->status;
	}
}