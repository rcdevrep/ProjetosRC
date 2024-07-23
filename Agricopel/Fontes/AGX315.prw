#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³NOVO14    ºAutor  ³Microsiga           º Data ³  01/06/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³ ROTINA JA VERIFICADA VIA XAGLOGRT                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AGX315()

LOCAL aSeg := GetArea(), aSegSA1 := SA1->(GetArea()), aSegACO := ACO->(GetArea())
LOCAL aSegACP := ACP->(GetArea()), aSegSB1 := SB1->(GetArea()), nSeg := N
LOCAL nPos := 0, nLinIni := 0, nLinFim := 0
LOCAL xRetu := &(ReadVar())
LOCAL _e:= 0
//Local lxEndEnt :=  ( xFilial('SC6') $  SuperGetMv( "MV_XENDENT" , .F. , "ZZ" ) )  //Trabalha com End. Entrega Customizado? Chamado[466847]
//Local _cEstEnt :=  ""
Local _cUfE  := ""

//_cEstEnt := iif(lxEndEnt,SA1->A1_ESTENT,SA1->A1_ESTE) 

If (Alltrim(ReadVar()) == "M->C6_PRODUTO").or.(Alltrim(ReadVar()) == "M->C6_TES")
	nLinIni  := N
	nLinFim  := N
Else
	nLinIni  := 1
	nLinFim  := Len(aCols)
Endif

For _e:= nLinIni to nLinFim
	
	//Busco variaveis necessarias
	/////////////////////////////
	If (Alltrim(ReadVar()) == "M->C6_PRODUTO") .OR. (Alltrim(ReadVar()) == "M->C6_TES")
		nPos     := aScan(aHeader,{|x| Alltrim(x[2])=="C6_TES"})
		cTES     := aCols[_e,nPos]
		nPos     := aScan(aHeader,{|x| Alltrim(x[2])=="C6_CF"})
		cCF      := aCols[_e,nPos]
	EndIf
	
	//Regra para Combustivel dentro/fora do Estado
	//Ajustado conforme tabela anexa ao chamado 29656
	If ( (cEmpAnt == '01' .And. cFilAnt $ '03/16') .OR. cEmpant $ '15') //.and. (SA1->A1_EST <> SA1->A1_ESTE)

		//Verifica se tem atendimento
		_cUfE := Posicione('SUA',8,xfilial('SUA') + M->C5_NUM, 'UA_ESTE')

		If Empty(_cUfE)
			_cUfE := M->C5_ESTE
		Endif 

		If Empty(_cUfE)
			_cUfE := SA1->A1_ESTE
		Endif 

		If SB1->B1_TIPO $ "CO/LU/SH" .AND. SA1->A1_TIPO <> "R"
			
			//Se a Sede do cliente for em um estado diferente da sede da agricopel
			//If (SA1->A1_EST <> SM0->M0_ESTENT)
			If SA1->A1_EST <> _cUfE
				//Se entrega no mesmo estado
				If (SM0->M0_ESTENT == _cUfE ) .and. (SA1->A1_EST <> SM0->M0_ESTENT)
					nPos := aScan(aHeader,{|x| Alltrim(x[2])=="C6_CF"})
					if !Empty(nPos)
						aCols[_e,nPos] := "5667"
					endif
				Else	
					nPos := aScan(aHeader,{|x| Alltrim(x[2])=="C6_CF"})
					if !Empty(nPos)
						aCols[_e,nPos] := "6667"
					endif
				Endif
			Endif 	
		Endif
		//Endif
	endif
	
	
	//Chamado 232002 - Verificar situação de venda para cliente no estado SC e manda entregar em estado diferente de SC - empresa 44 farol
	
	/*If cEmpAnt == '44' .and. (SA1->A1_EST <> _cEstEnt/*SA1->A1_ESTE*//*)

		If SB1->B1_TIPO $ "CO/LU/SH" .AND. SA1->A1_TIPO <> "R"
		
		   If SA1->A1_TIPO <> "R"
		      If SM0->M0_ESTCOB == _cEstEnt//SA1->A1_ESTE
				 nPos := aScan(aHeader,{|x| Alltrim(x[2])=="C6_CF"})
				 if !Empty(nPos)
					aCols[_e,nPos] := "5667"
				 endif
			   Else
				   nPos := aScan(aHeader,{|x| Alltrim(x[2])=="C6_CF"})
				   if !Empty(nPos)
				    	aCols[_e,nPos] := "6667"
				   endif
			   Endif
		   Endif
	   Endif	
	Endif*/
	
next _e

N := nSeg
RestArea(aSegSA1)
RestArea(aSegSB1)
RestArea(aSegACO)
RestArea(aSegACP)
RestArea(aSeg)

Return(xRetu)
