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
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/



User Function AGX315()
	LOCAL aSeg := GetArea(), aSegSA1 := SA1->(GetArea()), aSegACO := ACO->(GetArea()), aSegSZ8 := SZ8->(GetArea())
	LOCAL aSegACP := ACP->(GetArea()), aSegSB1 := SB1->(GetArea()), nSeg := N
	LOCAL nPos := 0, nLinIni := 0, nLinFim := 0
	LOCAL xRetu := &(ReadVar())
	
	If (Alltrim(ReadVar()) == "M->C6_PRODUTO").or.(Alltrim(ReadVar()) == "M->C6_TES")
		nLinIni  := N
		nLinFim  := N
	Else
		nLinIni  := 1
		nLinFim  := Len(aCols)
	Endif

For _e := nLinIni to nLinFim
   
	//Busco variaveis necessarias
	/////////////////////////////
	If (Alltrim(ReadVar()) == "M->C6_PRODUTO") .OR. (Alltrim(ReadVar()) == "M->C6_TES")   
		nPos     := aScan(aHeader,{|x| Alltrim(x[2])=="C6_TES"})
        cTES     := aCols[_e,nPos]
		nPos     := aScan(aHeader,{|x| Alltrim(x[2])=="C6_CF"})      
		cCF      := aCols[_e,nPos]
    EndIf
  
/*  	If (SM0->M0_CODIGO == '02' .or. (SM0->M0_CODIGO == '01' .And. SM0->M0_CODFIL == '03'));
	    .and. SA1->A1_EST <> SA1->A1_ESTE .and.  SB1->B1_TIPO == 'CO';
	    .and. SA1->A1_TIPO <> 'R' .and. cTES == '679' .and. (SM0->M0_ESTCOB == SA1->A1_ESTE .OR. SM0->M0_ESTCOB == SA1->A1_EST)
    
       nPos := aScan(aHeader,{|x| Alltrim(x[2])=="C6_CF"})
       if !Empty(nPos)
	  		 aCols[_e,nPos] := '5667'
	    endif    */
	    
	    
		//Regra para Combustivel dentro/fora do Estado
		//Ajustado conforme tabela anexa ao chamado 29656 
  	If ( (cEmpAnt == '01' .And. cFilAnt == '03') .OR. cEmpant $ '11/15') .and. (SA1->A1_EST <> SA1->A1_ESTE)
		
				If SB1->B1_TIPO $ "CO/LU/SH" .AND. SA1->A1_TIPO <> "R" 

						//Se For do mesmo estado cadastra com 5.
						If SM0->M0_ESTCOB == SA1->A1_EST/* .OR. ;
							 ( alltrim(SA1->A1_ESTE) == '' .AND.  SA1->A1_EST == SM0->M0_ESTCOB)*/
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
	  endif 
	
		/*If cEmpAnt == '01' .And. cFilAnt == '03';
  	  .AND. SM0->M0_ESTCOB <> SA1->A1_EST .AND. SA1->A1_EST <> SA1->A1_ESTE     
  	  nPos := aScan(aHeader,{|x| Alltrim(x[2])=="C6_CF"})
  	  if !Empty(nPos)
  	  	aCols[_e,nPos] := "6667"
  	  endif
    endif
  	
  	If (SM0->M0_CODIGO == '02' .or. (SM0->M0_CODIGO == '01' .And. SM0->M0_CODFIL == '03'));
	    .and. SA1->A1_EST <> SA1->A1_ESTE .and.  SB1->B1_TIPO == 'CO';
	    .and. SA1->A1_TIPO <> 'R' .and. cTES == '679' .and. SM0->M0_ESTCOB <> SA1->A1_ESTE
       nPos := aScan(aHeader,{|x| Alltrim(x[2])=="C6_CF"})
       if !Empty(nPos)
	  		 aCols[_e,nPos] := '6667'
	    endif
   endif*/
   
next _e         

N := nSeg
RestArea(aSegSA1)
RestArea(aSegSB1)
RestArea(aSegACO)
RestArea(aSegACP)
RestArea(aSegSZ8)
RestArea(aSeg)             


Return(xRetu)