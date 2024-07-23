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
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/




User Function AGX560()
LOCAL cCliente := M->C5_CLIENTE , cLoja  := M->C5_LOJACLI  , cTabela := M->C5_TABELA     
LOCAL nComis1  := 0 ,nComis2 := 0 , nComis3:= 0  
LOCAL cVend1   := M->C5_VEND1    , cVend2 := M->C5_VEND2, cVend3  := M->C5_VEND3   
LOCAL aSeg := GetArea() //, aSegSA1 := SA1->(GetArea()), aSegACO := ACO->(GetArea()), aSegSZ8 := SZ8->(GetArea())




For _e := 1 to Len(aCols)
                                                                                                                                          
	nPos     := aScan(aHeader,{|x| Alltrim(x[2]) == "C6_PRODUTO"})
	nPdesc   :=	aScan(aHeader,{|x| alltrim(x[2]) == "C6_DESCONT"})	 
	nPPai   :=	aScan(aHeader,{|x| alltrim(x[2]) == "C6_CODPAI"})					
	
	cProduto := aCols[_e,nPos]                                     
	nDesc 	 := aCols[_e,nPdesc]		     
	cProPai  := aCols[_e,nPPai] 
	
	If alltrim(cProPai) == "" 

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
		nComis1 := 2.5
		nComis2 := 0.2 
    EndIf		
	//Atualizo Campo Comissao
	nPos := aScan(aHeader,{|x| Alltrim(x[2])=="C6_COMIS1"})
	If !Empty(nPos)
		aCols[_e,nPos] := nComis1
	Endif
	nPos := aScan(aHeader,{|x| Alltrim(x[2])=="C6_COMIS2"})
	If !Empty(nPos)
		aCols[_e,nPos] := nComis2
	Endif  
	
	

Next _e        

RestArea(aSeg)  
	
Return(.t.)