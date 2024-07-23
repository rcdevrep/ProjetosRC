#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AGX300    ºAutor  ³RODRIGO             º Data ³  07/07/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ RESTRIÇÃO PARA EMISSÃO DE PEDIDO                           º±±
±±º          ³ ROTINA JA VERIFICADA VIA XAGLOGRT                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP 10 R1.3                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
                                                

User Function AGX300()
	LOCAL aSeg       := GetArea()
	LOCAL aSegSB1    := SB1->(GetArea())
    LOCAL aSegSA1    := SA1->(GetArea())                 
	LOCAL lRet       := .T.   
	LOCAL cProdArla := ""

	cGRTRIB := ""
	cUFCLI  := ""  
	cTIPPRO := ""  
	cCLIOK  := ""
    nPLocal	:= ""	
	
	nPosTab  	:= aScan(aHeader,{|x| alltrim(x[2])=="UB_PRCTAB"}) 
	nPosTabAux  := aScan(aHeader,{|x| alltrim(x[2])=="UB_AUXTAB"})    
	nPQuant     := aScan(aHeader,{|x| alltrim(x[2])=="UB_QUANT"})
	nPCodPai    := aScan(aHeader,{|x| alltrim(x[2]) == "UB_CODPAI"})   
	
	nPProduto	:=  aScan(aHeader,{|x| alltrim(x[2]) == "UB_PRODUTO"})
	nPQuant		:=	aScan(aHeader,{|x| alltrim(x[2]) == "UB_QUANT"})
	nPVrUnit	:=	aScan(aHeader,{|x| alltrim(x[2]) == "UB_VRUNIT"})
	nPVlrItem 	:=	aScan(aHeader,{|x| alltrim(x[2]) == "UB_VLRITEM"})
	nPPDesTab 	:=	aScan(aHeader,{|x| alltrim(x[2]) == "UB_PDESTAB"})	
	nPPdescom 	:=	aScan(aHeader,{|x| alltrim(x[2]) == "UB_PDESCOM"})		
	nPDesc    	:=	aScan(aHeader,{|x| alltrim(x[2]) == "UB_DESC"})
	nPVlrDesc 	:=	aScan(aHeader,{|x| alltrim(x[2]) == "UB_VALDESC"})
	nPVdescom 	:=	aScan(aHeader,{|x| alltrim(x[2]) == "UB_VDESCOM"})
	nPosTabAux 	:=  aScan(aHeader,{|x| alltrim(x[2]) == "UB_AUXTAB"})    
	
	nPTpVlr	 :=  aScan(aHeader,{|x| alltrim(x[2]) == "UB_TPVLR"}) 
	nPLocal  :=  aScan(aHeader,{|x| alltrim(x[2]) == "UB_LOCAL"})
	
	
/*	If !Empty(aCols[n][nPCodPai])    
		// Busco Preco da estrutura
		cALiasSG1 := GetNextAlias()
		cCodPai   := aCols[n][nPCodPai]
		cProduto   := aCols[n][nPProd]
				
		BeginSql Alias cAliasSG1  
			SELECT G1_XPVENDA, G1_QUANT
			FROM %Table:SG1% (NOLOCK) SG1
			WHERE                                                                                          
			SG1.G1_FILIAL = %xFilial:SG1% AND 
			SG1.G1_COD    = %Exp:cCodPai% AND 
			SG1.G1_COMP   = %Exp:cProduto% AND
			SG1.%notdel%
		EndSql
				
		dbSelectArea(cAliasSG1)
		nPreComp   := (cALiasSG1)->G1_XPVENDA
		nQuantComp := (cALiasSG1)->G1_QUANT

		(cAliasSG1)->( dbCloseArea() )

		aCols[N,nPosTab] := nPreComp 
		aCols[n][nPQuant]    := nQuantComp 
	EndIf      */

	aCols[N,nPosTabAux]	:= aCols[N,nPosTab]

//	If aCols[N,nPTpVlr] <> "S"
		aCols[N,nPosTab]    := aCols[N,nPosTab] + ROUND(((aCols[N,nPosTab]* M->UA_X_ACRES) / 100),4) 
		aCols[n][nPVrUnit]	:= aCols[n][nPosTab] - Round(((aCols[n][nPosTab] * aCols[n][nPDesc] /100)),4)
		aCols[n][nPVlrItem] := aCols[n][nPVrUnit] * aCols[n][nPQuant]
//	EndIf

   If SM0->M0_CODIGO == '01' .or. SM0->M0_CODIGO == '02' .or. SM0->M0_CODIGO == '11'
  		lRet := .T.
		dbSelectArea("SB1")
		dbSetOrder(1)
		DbSeek(xFilial("SB1")+M->UB_PRODUTO)
		cGRTRIB  := SB1->B1_GRTRIB
		cTIPPRO  := SB1->B1_TIPO

		dbSelectArea("SA1")
		dbSetOrder(1)
		DbSeek(xFilial("SA1")+M->UA_CLIENTE+M->UA_LOJA)
		cUFCLI := SA1->A1_EST
		cCLIOK := SA1->A1_LIBORC

        /*
         * incluida validacao pelo Thiago Padilha 17/07/2017 para sugerir o armazem 
         * que esta no cadastro do cliente, somente para Agricopel Base
         */                   
        if ((AllTrim(SM0->M0_CODIGO) == '01' .and. (Alltrim(SM0->M0_CODFIL) == '03' .or. Alltrim(SM0->M0_CODFIL) $ '11/15/17/18/05' .or. Alltrim(SM0->M0_CODFIL) == '16')) .or. AllTrim(SM0->M0_CODIGO) == '11') .AND. AllTrim(cTIPPRO) == "CO"
           if !empty(AllTrim(SA1->A1_ARMAZEM))
              aCols[n][nPLocal] := SA1->A1_ARMAZEM
           EndIf   
        EndIf


        /*
         * Chamado[37069] - Armazem para Arla
         */                 
        if (AllTrim(SM0->M0_CODIGO) == '01' .and. (Alltrim(SM0->M0_CODFIL) == '03' .or. Alltrim(SM0->M0_CODFIL) $ '11/15/17/18/05')) //.AND. AllTrim(cTIPPRO) == "AG"
			cProdArla := SuperGetMV("MV_XPDARLA",.F.,"") 
            if !empty(AllTrim(SA1->A1_XARARLA)) .AND. alltrim(aCols[N,nPProduto]) $ cProdArla  .AND. !Empty(cProdArla)
              aCols[n][nPLocal] := SA1->A1_XARARLA
            EndIf   
        EndIf


		If SM0->M0_ESTCOB <> cUFCLI .AND. cTIPPRO <> "CO" .AND. cGRTRIB <> "00" .AND. trim(cCLIOK) == ""
			MSGSTOP("Operação não permitida! Contate o contador!")
 		    lRet := .F.
			RestArea(aSegSB1)
			RestArea(aSegSA1)
			RestArea(aSeg)

   	        Return lRet
		EndIf
	EndIf

	//Retorno area original do arquivo
	//////////////////////////////////

	RestArea(aSegSB1)
	RestArea(aSegSA1)
	RestArea(aSeg)
Return lRet






