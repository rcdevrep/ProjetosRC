#Include 'Protheus.ch' 
#Include "topconn.ch"    

/*/
=============================================================
Programa     : 
Autor        : Cesar Tenfen Heidemann
Data         : 16/11/2017
Alterado por : 
Data         : 
-------------------------------------------------------------
Descricao    : Calcula Captação.
Módulo (Uso) : SIGAGCT
=============================================================
/*/

User Function XAG0013() 

	Local _cMvPlnFnm	:= SuperGetMv("MV_XPLNFNM",.F.,"001")
	Local _cMvPlnCdc	:= SuperGetMv("MV_XPLNCDC",.F.,"008")
	Local nVlrCapt 		:= 0 
	Local _cComp	 	:= ""
	Local _cIndice 		:= M->CN9_INDICE
	Local _DtIndice		:= M->CN9_DTINIC 
	
	// apenas atualiza quando for finame
	If _cMvPlnFnm == _cIndice
		
		dbSelectArea("CN6")
		CN6->(dbSetOrder(1))
		If dbSeek(xFilial("CN6")+_cIndice)   
			If CN6->CN6_TIPO == "1"
				dbSelectArea("CN7")
				CN7->(dbSetOrder(1))
				If dbSeek(xFilial("CN7")+_cIndice+DtoS(_DtIndice))   
					If CN7->CN7_VLREAL > 0
						_nINDCatu	:= CN7->CN7_VLREAL
						nVlrCapt    := (M->CN9_XVLREM/_nINDCatu)  
					Else
						Alert("Valor para o Indice economico "+AllTrim(_cIndice)+" não encontrado, para calculo do valor de Captação!")
					EndIf
				Else
					Alert("Valor para o Indice economico "+AllTrim(_cIndice)+" não encontrado, para calculo do valor de Captação!")
				EndIf
			Else
				// Monta competencia
				_cComp := StrZero(MONTH(_DtIndice),2) +"/"+ YEAR(_DtIndice) 
				// Busca dados na CN7
				dbSelectArea("CN7")
				CN7->(dbSetOrder(2))
				If dbSeek(xFilial("CN7")+_cIndice+_cComp)   
					If CN7->CN7_VLREAL > 0
						_nINDCatu	:= CN7->CN7_VLREAL
						nVlrCapt    := (M->CN9_XVLREM/_nINDCatu)  
					Else
						Alert("Valor para o Indice economico "+AllTrim(_cIndice)+" não encontrado, para calculo do valor de Captação!")
					EndIf
				Else
					Alert("Valor para o Indice economico "+AllTrim(_cIndice)+" não encontrado, para calculo do valor de Captação!")
				EndIf
			EndIf
		EndIf
	
	Else
		nVlrCapt	:= M->CN9_XVLREM
	EndIf 			

Return(nVlrCapt)