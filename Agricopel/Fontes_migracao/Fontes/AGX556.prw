#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AGX556    ºAutor  ³Microsiga           º Data ³  01/24/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Busco comissao televendas                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alteracoes³30/09/2015 - Max Ivan - Retirada condição que "chumbava" co-³±±
±±³          ³           - missão de 2,5% de lubrificantes e 0,20% para   ³±±
±±³          ³           - Televendas, para combos. Deixando a regra de   ³±±
±±³          ³           - calculo como as das inserções manuais.         ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/




User Function AGX556()
LOCAL cCliente := M->UA_cliente , cLoja  := M->UA_loja  , cTabela := M->UA_tabela     
LOCAL nComis1  := 0 ,nComis2 := 0 , nComis3:= 0  
LOCAL cVend1   := M->UA_vend    , cVend2 := M->UA_vend2 , cVend3  := M->UA_vend3




For _e := 1 to Len(aCols)

	nPos     := aScan(aHeader,{|x| Alltrim(x[2]) =="UB_PRODUTO"})
	nPdesc   :=	aScan(aHeader,{|x| alltrim(x[2]) == "UB_DESC"})	 
	nPPai   :=	aScan(aHeader,{|x| alltrim(x[2]) == "UB_CODPAI"})					
	
	cProduto := aCols[_e,nPos]                                     
	nDesc 	 := aCols[_e,nPdesc]		     
	cProPai  := aCols[_e,nPPai] 

    //Inserido por Max Ivan (Nexus) em 30/09/2015, para que as variáveis sejam sempre iniciadas com 0 antes do processamento, pois existiam casos que o
    //o valor trazido era o da linha anterior, enquanto, pela lógica, deveria ser zero.
    nComis1 := 0
	nComis2 := 0
	//Retirada a condição por Max Ivan (Nexus) em 30/09/2015, já que o calculo de comissão para COMBO tem que ser o mesmo das operações normais
	//If alltrim(cProPai) == ""
	If .T.

		TpClien := Space(01)
		dbSelectArea("SA1")
		dbSetOrder(1)
		dbSeek(xFilial("SA1")+cCliente+cLoja)		
		If SA1->A1_SATIV1 == "999999"
			cTpClien := "I"				
		Else
			cTpClien := SA1->A1_TIPO
		EndIf		
			
		//Busco comissao representante
//		aSX3SZ8     := SZ8->(DbStruct())	
		cALiasSZ8   := GetNextAlias()
					
		BeginSql Alias cAliasSZ8  
			SELECT Z8_DESCMIN, Z8_DESCMAX , Z8_COMIS
			FROM %Table:SZ8% (NOLOCK) SZ8
			WHERE                                                                                          
			SZ8.Z8_FILIAL   = %xFilial:SZ8%  AND 
			SZ8.Z8_REPRE    = %Exp:cVend1%   AND
			SZ8.Z8_TPCLIEN = %Exp:cTpClien% AND
	   		SZ8.%notdel%
		EndSql
		
		DbSelectArea(cAliasSZ8)
		DbGoTop()
		While !Eof()	
			If ((Round(nDesc,2) >= (cAliasSZ8)->Z8_DESCMIN).and.(Round(nDesc,2) <= (cAliasSZ8)->Z8_DESCMAX) .Or. (nDesc) <= 0)
				nComis1 := (cAliasSZ8)->Z8_COMIS
				Exit
			Endif
			DbSelectArea(cAliasSZ8)
			DbSkip()
		EndDo   
		
		(cAliasSZ8)->( dbCloseArea() )    
		
		
		//Busco Comissao Televendas     
//		aSX3SZ8     := SZ8->(DbStruct())	
		cALiasSZ8   := GetNextAlias()
					
		BeginSql Alias cAliasSZ8  
			SELECT Z8_DESCMIN, Z8_DESCMAX , Z8_COMIS
			FROM %Table:SZ8% (NOLOCK) SZ8
			WHERE                                                                                          
			SZ8.Z8_FILIAL   = %xFilial:SZ8%  AND 
			SZ8.Z8_REPRE    = %Exp:cVend2%   AND
			SZ8.Z8_TPCLIEN = %Exp:cTpClien% AND
	   		SZ8.%notdel%
		EndSql
		
		DbSelectArea(cAliasSZ8)
		DbGoTop()
		While !Eof()	
			If ((Round(nDesc,2) >= (cAliasSZ8)->Z8_DESCMIN).and.(Round(nDesc,2) <= (cAliasSZ8)->Z8_DESCMAX) .Or. (nDesc) <= 0)
				nComis2 := (cAliasSZ8)->Z8_COMIS
				Exit
			Endif
			DbSelectArea(cAliasSZ8)
			DbSkip()
		EndDo   
		
		(cAliasSZ8)->( dbCloseArea() )     
	Else
		nComis1 := 2.5 //SEM FUNÇÃO
		nComis2 := 0.2 //SEM FUNÇÃO
    EndIf		
	//Atualizo Campo Comissao
	nPos := aScan(aHeader,{|x| Alltrim(x[2])=="UB_COMIS"})
	If !Empty(nPos)
		aCols[_e,nPos] := nComis1
	Endif
	nPos := aScan(aHeader,{|x| Alltrim(x[2])=="UB_COMIS2"})
	If !Empty(nPos)
		aCols[_e,nPos] := nComis2
	Endif 

Next _e
	
Return(.t.)