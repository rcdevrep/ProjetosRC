#Include 'Protheus.ch'
        

// Funções para CNAB/Boleto SICOOB
User Function AGX636(xFuncao)  
 
 Local xRet        
 Default xFuncao := ""
 
 Do Case
 	Case alltrim(xFuncao) == 'PARCELA'
 		xRet := Parcela() 
 	Case alltrim(xFuncao) == 'NOSSONUM'	
      	xRet := NossoNum('NOSSONUM')  
 	Case alltrim(xFuncao) == 'DV' 
 		xRet := NossoNum('DV')
 	Case alltrim(xFuncao) == 'MSGJUROS' 
 		 xRet := "NAO DISPENSAR JUROS DE MORA E RECUSAR VALOR A MENOR."
 		 xRet += "APOS O VENCIMENTO TITULO SUJEITO A PROTESTO."
 		 xRet += "COBRAR TAXA DE 5% APOS O VENCIMENTO E JUROS DE MORA 2% AO MES."
   	Otherwise
   		xRet := ""
 EndCase

Return xRet  


//Retorna Parcela Formatada com 2 posiçoes e 
//Zeros a esquerda
Static Function Parcela()
     
 Local cRetParc := "01"
    
 Do Case      
	 Case alltrim(SE1->E1_PARCELA) == "A" .OR. alltrim(SE1->E1_PARCELA) == "1" 
	 	cRetParc := "01"
	 Case alltrim(SE1->E1_PARCELA) == "B" .OR. alltrim(SE1->E1_PARCELA) == "2" 
	 	cRetParc := "02"	 
	 Case alltrim(SE1->E1_PARCELA) == "C" .OR. alltrim(SE1->E1_PARCELA) == "3"
	 	cRetParc := "03"	 
	 Case alltrim(SE1->E1_PARCELA) == "D" .OR. alltrim(SE1->E1_PARCELA) == "4"
	 	cRetParc := "04"	
	 Case alltrim(SE1->E1_PARCELA) == "E" .OR. alltrim(SE1->E1_PARCELA) == "5"
	 	cRetParc := "05"
	 Case alltrim(SE1->E1_PARCELA) == "F" .OR. alltrim(SE1->E1_PARCELA) == "6"
	 	cRetParc := "06"	 
	 Case alltrim(SE1->E1_PARCELA) == "G" .OR. alltrim(SE1->E1_PARCELA) == "7"
	 	cRetParc := "07"	 
	 Case alltrim(SE1->E1_PARCELA) == "H" .OR. alltrim(SE1->E1_PARCELA) == "8"
	 	cRetParc := "08"	 
	 Case alltrim(SE1->E1_PARCELA) == "I" .OR. alltrim(SE1->E1_PARCELA) == "9"
	 	cRetParc := "09"	 
	 Case alltrim(SE1->E1_PARCELA) == "J" .OR. alltrim(SE1->E1_PARCELA) == "10"
	 	cRetParc := "10"	 
	 Case alltrim(SE1->E1_PARCELA) == "K" .OR. alltrim(SE1->E1_PARCELA) == "11"
	 	cRetParc := "11"	 
	 Case alltrim(SE1->E1_PARCELA) == "L" .OR. alltrim(SE1->E1_PARCELA) == "12"
	 	cRetParc := "12"	 
	 Case alltrim(SE1->E1_PARCELA) == "M" .OR. alltrim(SE1->E1_PARCELA) == "13"
	 	cRetParc := "13"	 
	 Case alltrim(SE1->E1_PARCELA) == "N" .OR. alltrim(SE1->E1_PARCELA) == "14"
	 	cRetParc := "14"	 
	 Case alltrim(SE1->E1_PARCELA) == "O" .OR. alltrim(SE1->E1_PARCELA) == "15"
	 	cRetParc := "15"	 
	 Case alltrim(SE1->E1_PARCELA) == "P" .OR. alltrim(SE1->E1_PARCELA) == "16"
	 	cRetParc := "16"	 
	 Case alltrim(SE1->E1_PARCELA) == "Q" .OR. alltrim(SE1->E1_PARCELA) == "17"
	 	cRetParc := "17"	 
	 Case alltrim(SE1->E1_PARCELA) == "R" .OR. alltrim(SE1->E1_PARCELA) == "18"
	 	cRetParc := "18"	 
	 Case alltrim(SE1->E1_PARCELA) == "S" .OR. alltrim(SE1->E1_PARCELA) == "19"
	 	cRetParc := "19"	 
	 Case alltrim(SE1->E1_PARCELA) == "T" .OR. alltrim(SE1->E1_PARCELA) == "20"
	 	cRetParc := "20"	 
	 Case alltrim(SE1->E1_PARCELA) == "U" .OR. alltrim(SE1->E1_PARCELA) == "21"
	 	cRetParc := "21"	 
	 Case alltrim(SE1->E1_PARCELA) == "V" .OR. alltrim(SE1->E1_PARCELA) == "22"
	 	cRetParc := "22"	 
	 Case alltrim(SE1->E1_PARCELA) == "X" .OR. alltrim(SE1->E1_PARCELA) == "23"
	 	cRetParc := "23"	 
	 Case alltrim(SE1->E1_PARCELA) == "W" .OR. alltrim(SE1->E1_PARCELA) == "24"
	 	cRetParc := "24"	 
	 Case alltrim(SE1->E1_PARCELA) == "Y" .OR. alltrim(SE1->E1_PARCELA) == "25"
	 	cRetParc := "25"	 
	 Case alltrim(SE1->E1_PARCELA) == "Z" .OR. alltrim(SE1->E1_PARCELA) == "26"
	 	cRetParc := "26"	 
	 Case alltrim(SE1->E1_PARCELA) == "AA" .OR. alltrim(SE1->E1_PARCELA) == "27"
	 	cRetParc := "27"	 
	 Case alltrim(SE1->E1_PARCELA) == "AB" .OR. alltrim(SE1->E1_PARCELA) == "28"
	 	cRetParc := "28"	 
	 Case alltrim(SE1->E1_PARCELA) == "AC" .OR. alltrim(SE1->E1_PARCELA) == "29"
	 	cRetParc := "29"	 
	 Case alltrim(SE1->E1_PARCELA) == "AD" .OR. alltrim(SE1->E1_PARCELA) == "30"
	 	cRetParc := "30"	 
	 Case alltrim(SE1->E1_PARCELA) == "AE" .OR. alltrim(SE1->E1_PARCELA) == "31"
	 	cRetParc := "31"	 
	 Case alltrim(SE1->E1_PARCELA) == "AF" .OR. alltrim(SE1->E1_PARCELA) == "32"
	 	cRetParc := "32"	 
	 Case alltrim(SE1->E1_PARCELA) == "AG" .OR. alltrim(SE1->E1_PARCELA) == "33"
	 	cRetParc := "33"	 
	 Case alltrim(SE1->E1_PARCELA) == "AH" .OR. alltrim(SE1->E1_PARCELA) == "34"
	 	cRetParc := "34"	 
	 Case alltrim(SE1->E1_PARCELA) == "AI" .OR. alltrim(SE1->E1_PARCELA) == "35"
	 	cRetParc := "35"	 
	 Case alltrim(SE1->E1_PARCELA) == "AJ" .OR. alltrim(SE1->E1_PARCELA) == "36"
	 	cRetParc := "36"	 
	 Case alltrim(SE1->E1_PARCELA) == "AK" .OR. alltrim(SE1->E1_PARCELA) == "37"
	 	cRetParc := "37"	 
	 Case alltrim(SE1->E1_PARCELA) == "AL" .OR. alltrim(SE1->E1_PARCELA) == "38"
	 	cRetParc := "38"	 
	 Case alltrim(SE1->E1_PARCELA) == "AM" .OR. alltrim(SE1->E1_PARCELA) == "39"
	 	cRetParc := "39"	 
	 Case alltrim(SE1->E1_PARCELA) == "AM" .OR. alltrim(SE1->E1_PARCELA) == "40"
	 	cRetParc := "40"	
	 Otherwise
	 	If alltrim(SE1->E1_PARCELA) <> ""
	 		cRetParc := strzero(cRetParc,2)
	    Endif
 EndCase

Return cRetParc 


//Retorna Nosso Numero SICOOB
Static Function NossoNUM(xOpc) 
                      
	Local   cRetNN := ""  
	Default xOpc   := "NOSSONUM"
	 
	xcalculoDv := 0 
	
	xnum_contrato_con := alltrim(SEE->EE_CODEMP)//VERIFICAR alltrim(SEE->EE_CONTA)+alltrim(SEE->EE_DVCTA) // Número do contrato: É o mesmo número da conta
	  
	//se ja gerou numero de CNAB pega ele 
	If alltrim(SE1->E1_NUMBCO) <> ''//alltrim(SE1->E1_IDCNAB) <> ''
   		xNossoNumero := STRZERO(val(SE1->E1_NUMBCO),7)//STRZERO(val(SE1->E1_IDCNAB),7)
	Else
		xNossoNumero := STRZERO(val(SEE->EE_ULTDSK),7) // Até 7 dígitos, número sequencial iniciado em 1 (Ex.: 1, 2...)
	Endif
	xqtde_nosso_numero := len(xNossoNumero)
	xsequencia := STRZERO(val(SEE->EE_AGENCIA),4)+;
	              STRZERO(val(xnum_contrato_con),10)+;
	              STRZERO(val(xNossoNumero),7)
	
	xcont=0
	For xnum := 1 to len(xsequencia)
	
		xcont++
		if(xcont == 1)
			xconstante := 3
		elseif(xcont == 2)
			xconstante := 1
		elseif(xcont == 3)
			xconstante := 9
		elseif(xcont == 4)
			xconstante := 7
			xcont := 0     
		Endif      
		
		xCalculoDv := xCalculoDv + ( val(substr(alltrim(xsequencia),xnum,1)) * xconstante);
	
	Next xNum

	xResto = mod(xcalculoDv,11)//xcalculoDv % 11;
	if xResto == 0 .or. xResto == 1
		xDv := 0
	else
		xDv := (11 - xResto)
    Endif  
            
    
    If xOpc  == 'DV'
    	cRetNN := alltrim(str(xDv))   
    Else
   		cRetNN := xNossoNumero+alltrim(str(xDv)) 
    Endif       
    
Return cRetNN 

