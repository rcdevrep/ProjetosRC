#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AGX556    �Autor  �Microsiga           � Data �  01/24/14   ���
�������������������������������������������������������������������������͹��
���Desc.     �  Busco comissao televendas                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������Ĵ��
���Alteracoes�30/09/2015 - Max Ivan - Retirada condi��o que "chumbava" co-���
���          �           - miss�o de 2,5% de lubrificantes e 0,20% para   ���
���          �           - Televendas, para combos. Deixando a regra de   ���
���          �           - calculo como as das inser��es manuais.         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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

    //Inserido por Max Ivan (Nexus) em 30/09/2015, para que as vari�veis sejam sempre iniciadas com 0 antes do processamento, pois existiam casos que o
    //o valor trazido era o da linha anterior, enquanto, pela l�gica, deveria ser zero.
    nComis1 := 0
	nComis2 := 0
	//Retirada a condi��o por Max Ivan (Nexus) em 30/09/2015, j� que o calculo de comiss�o para COMBO tem que ser o mesmo das opera��es normais
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
		nComis1 := 2.5 //SEM FUN��O
		nComis2 := 0.2 //SEM FUN��O
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